#include <kibo/llt.hpp>
#include <kibo/qr.hpp>
#include "../tests/controlled_fixture.hpp"
#include <Eigen/Cholesky>
#include <Eigen/Eigenvalues>
#include <Eigen/QR>
#include <algorithm>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <stdexcept>
#include <string_view>
#include <vector>

namespace {
using namespace kibo::linalg;
using kibo::tests::RowMatrix;
volatile double consumed=0;
struct Timing { double median,p95; std::size_t calls; };
template<class Function> Timing measure(Function function) {
    for(int warmup=0;warmup<5;++warmup) function();
    std::vector<double> samples;
    std::size_t total_calls=0;
    std::size_t batch_calls=1;
    for(int sample=0;sample<30;++sample) {
        double elapsed=0;
        do {
            const auto start=std::chrono::steady_clock::now();
            for(std::size_t call=0;call<batch_calls;++call) function();
            elapsed=std::chrono::duration<double>(std::chrono::steady_clock::now()-start).count();
            if(elapsed<0.020) batch_calls*=2;
        } while(elapsed<0.020);
        samples.push_back(elapsed/static_cast<double>(batch_calls)); total_calls+=batch_calls;
    }
    std::sort(samples.begin(),samples.end());
    return {(samples[14]+samples[15])/2,samples[28],total_calls};
}
MatrixView<const double> input_view(const RowMatrix& a) {
    return MatrixView<const double>::checked({a.data(),static_cast<std::size_t>(a.size())},a.rows(),a.cols(),a.cols()).value();
}
MatrixView<double> output_view(RowMatrix& a) {
    return MatrixView<double>::checked({a.data(),static_cast<std::size_t>(a.size())},a.rows(),a.cols(),a.cols()).value();
}
void require(Status status) {if(!status) throw std::runtime_error("core computation failed");}
template<class T> T require(Result<T> result) {if(!result) throw std::runtime_error("core factorization failed"); return std::move(result).value();}
std::uint64_t hash_fixture(const kibo::tests::Fixture& fixture) {
    std::uint64_t hash=14695981039346656037ULL;
    const auto append=[&](std::uint64_t bits){for(int byte=0;byte<8;++byte){hash^=(bits>>(8*byte))&255;hash*=1099511628211ULL;}};
    append(fixture.matrix.rows());append(fixture.matrix.cols());
    for(Eigen::Index i=0;i<fixture.matrix.size();++i) append(std::bit_cast<std::uint64_t>(fixture.matrix.data()[i]));
    for(Eigen::Index i=0;i<fixture.rhs.size();++i) append(std::bit_cast<std::uint64_t>(fixture.rhs[i]));
    return hash;
}
void print_result(int run,Eigen::Index m,Eigen::Index n,double condition,const char* solver,const char* backend,const char* phase,std::size_t bytes,Timing timing,std::uint64_t hash) {
    std::printf("%d,%lld,%lld,%.17g,%s,%s,%s,%zu,%.17g,%.17g,%zu,%016llx\n",run,static_cast<long long>(m),static_cast<long long>(n),condition,solver,backend,phase,bytes,timing.median,timing.p95,timing.calls,static_cast<unsigned long long>(hash));
    std::fflush(stdout);
}
void benchmark(int run,const kibo::tests::Fixture& fixture,bool qr,bool eigen_backend,double condition) {
    const auto fixture_hash=hash_fixture(fixture);
    const auto print=[&](int process,Eigen::Index rows,Eigen::Index cols,double observed,const char* solver,const char* backend,const char* phase,std::size_t bytes,Timing timing){
        print_result(process,rows,cols,observed,solver,backend,phase,bytes,timing,fixture_hash);
    };
    const auto n=fixture.matrix.cols(),m=fixture.matrix.rows();
    const double lambda=1e-3;
    RowMatrix input;
    Eigen::VectorXd rhs;
    if(qr) {
        input=RowMatrix::Zero(m+n,n); input.topRows(m)=fixture.matrix;
        input.bottomRows(n).diagonal().setConstant(std::sqrt(lambda));
        rhs=Eigen::VectorXd::Zero(m+n); rhs.head(m)=fixture.rhs;
    } else {input=fixture.matrix.transpose()*fixture.matrix; input.diagonal().array()+=lambda; rhs=fixture.matrix.transpose()*fixture.rhs;}
    const auto rows=input.rows();
    const auto shared=static_cast<std::size_t>(fixture.matrix.size()+fixture.rhs.size()+fixture.truth.size()+
                                             input.size()+rhs.size()+n); // includes independent expected solution
    const auto backend_doubles=eigen_backend ? static_cast<std::size_t>(2*input.size()+(qr?5*n+rows:n))
                                             : static_cast<std::size_t>(input.size()+2*n+(qr?rows+n:n));
    // Eigen QR has two index vectors; sizeof(size_t) bounds their combined x64 storage.
    const auto index_bytes=(!eigen_backend || qr) ? static_cast<std::size_t>(n)*sizeof(std::size_t) : 0;
    const auto capacity=(shared+backend_doubles)*8+index_bytes;
    // Include the simultaneously live prepared resources and the temporary
    // input/factor copies used by the end-to-end harness.
    const auto end_capacity=capacity+2*static_cast<std::size_t>(input.size())*8+
                            static_cast<std::size_t>(eigen_backend?(qr?5*n+rows:n):(qr?4*n+rows:2*n))*8+
                            (qr?static_cast<std::size_t>(n)*sizeof(std::size_t):0);
    // Eigen LLT's blocked triangular solve/rank update also packs panels.
    // Raw numeric_bytes records explicit live buffers; the summary adds this
    // conservative bound, including stack-backed packing, to Eigen's capacity.
    const auto internal_packing=(eigen_backend && !qr)
        ? 4*static_cast<std::size_t>(n)*static_cast<std::size_t>(n)*sizeof(double) : 0;
    if(end_capacity+internal_packing>64*1024*1024) throw std::runtime_error("numeric capacity exceeds 64 MiB");
    const char* solver=qr?"augmented-QR":"normal-LLT";
    const char* backend=eigen_backend?"Eigen-column-major":"kibo-row-major";
    Eigen::VectorXd expected;
    {
        Eigen::MatrixXd normal=fixture.matrix.transpose()*fixture.matrix;
        normal.diagonal().array()+=lambda;
        const Eigen::VectorXd gradient=fixture.matrix.transpose()*fixture.rhs;
        expected=normal.ldlt().solve(gradient);
    }
    if(eigen_backend) {
        Eigen::MatrixXd column=input;
        Eigen::VectorXd solution(n);
        if(qr) {
            Eigen::ColPivHouseholderQR<Eigen::MatrixXd> factor(rows,n);
            factor.setThreshold(static_cast<double>(rows)*std::numeric_limits<double>::epsilon());
            const auto factorize=[&] {factor.compute(column);if(factor.rank()!=n)throw std::runtime_error("Eigen rank deficient");consumed=factor.matrixQR()(0,0);};
            factorize(); solution=factor.solve(rhs);
            if((solution-expected).norm()/expected.norm()>1e-8) throw std::runtime_error("Eigen QR accuracy gate failed");
            print(run,m,n,condition,solver,backend,"factor",capacity,measure(factorize));
            print(run,m,n,condition,solver,backend,"solve",capacity,measure([&]{solution=factor.solve(rhs);consumed=solution[0];}));
            print(run,m,n,condition,solver,backend,"factor_solve",capacity,measure([&]{factorize();solution=factor.solve(rhs);consumed=solution[0];}));
            print(run,m,n,condition,solver,backend,"setup_copy_factor_solve",end_capacity,measure([&]{
                Eigen::MatrixXd copied=input;
                Eigen::ColPivHouseholderQR<Eigen::MatrixXd> temporary(copied);
                temporary.setThreshold(static_cast<double>(rows)*std::numeric_limits<double>::epsilon());
                Eigen::VectorXd result=temporary.solve(rhs);consumed=result[0];
            }));
        } else {
            Eigen::LLT<Eigen::MatrixXd> factor(n);
            const auto factorize=[&]{factor.compute(column);if(factor.info()!=Eigen::Success)throw std::runtime_error("Eigen LLT failed");consumed=factor.matrixLLT()(0,0);};
            factorize(); solution=factor.solve(rhs);
            if((solution-expected).norm()/expected.norm()>1e-8) throw std::runtime_error("Eigen LLT accuracy gate failed");
            print(run,m,n,condition,solver,backend,"factor",capacity,measure(factorize));
            print(run,m,n,condition,solver,backend,"solve",capacity,measure([&]{solution=factor.solve(rhs);consumed=solution[0];}));
            print(run,m,n,condition,solver,backend,"factor_solve",capacity,measure([&]{factorize();solution=factor.solve(rhs);consumed=solution[0];}));
            print(run,m,n,condition,solver,backend,"setup_copy_factor_solve",end_capacity,measure([&]{
                Eigen::MatrixXd copied=input; Eigen::LLT<Eigen::MatrixXd> temporary(copied);
                Eigen::VectorXd result=temporary.solve(rhs);consumed=result[0];
            }));
        }
    } else {
        RowMatrix packed(rows,n);
        std::vector<double> tau(n),solution(n),work(qr?rows+n:n);
        std::vector<std::size_t> permutation(n);
        auto workspace=std::as_writable_bytes(std::span<double>{work});
        const std::span<const double> rhs_span{rhs.data(),static_cast<std::size_t>(rhs.size())};
        if(qr) {
            QrFactorView factor;
            const auto factorize=[&]{factor=require(factorize_qr(input_view(input),output_view(packed),tau,permutation,workspace));consumed=packed(0,0);};
            factorize(); require(solve_into(factor,rhs_span,solution,workspace));
            if((Eigen::Map<const Eigen::VectorXd>(solution.data(),n)-expected).norm()/expected.norm()>1e-8) throw std::runtime_error("core QR accuracy gate failed");
            print(run,m,n,condition,solver,backend,"factor",capacity,measure(factorize));
            print(run,m,n,condition,solver,backend,"solve",capacity,measure([&]{require(solve_into(factor,rhs_span,solution,workspace));consumed=solution[0];}));
            print(run,m,n,condition,solver,backend,"factor_solve",capacity,measure([&]{factorize();require(solve_into(factor,rhs_span,solution,workspace));consumed=solution[0];}));
            print(run,m,n,condition,solver,backend,"setup_copy_factor_solve",end_capacity,measure([&]{
                RowMatrix copied=input,temporary(rows,n);
                std::vector<double> t(n),x(n),w(rows+n);std::vector<std::size_t> p(n);
                auto ws=std::as_writable_bytes(std::span<double>{w});
                auto f=require(factorize_qr(input_view(copied),output_view(temporary),t,p,ws));
                require(solve_into(f,rhs_span,x,ws));consumed=x[0];
            }));
        } else {
            LltFactorView factor;
            const auto factorize=[&]{factor=require(factorize_llt(input_view(input),output_view(packed)));consumed=packed(0,0);};
            factorize(); require(solve_into(factor,rhs_span,solution,workspace));
            if((Eigen::Map<const Eigen::VectorXd>(solution.data(),n)-expected).norm()/expected.norm()>1e-8) throw std::runtime_error("core LLT accuracy gate failed");
            print(run,m,n,condition,solver,backend,"factor",capacity,measure(factorize));
            print(run,m,n,condition,solver,backend,"solve",capacity,measure([&]{require(solve_into(factor,rhs_span,solution,workspace));consumed=solution[0];}));
            print(run,m,n,condition,solver,backend,"factor_solve",capacity,measure([&]{factorize();require(solve_into(factor,rhs_span,solution,workspace));consumed=solution[0];}));
            print(run,m,n,condition,solver,backend,"setup_copy_factor_solve",end_capacity,measure([&]{
                RowMatrix copied=input,temporary(n,n);std::vector<double> x(n),w(n);
                auto ws=std::as_writable_bytes(std::span<double>{w});
                auto f=require(factorize_llt(input_view(copied),output_view(temporary)));
                require(solve_into(f,rhs_span,x,ws));consumed=x[0];
            }));
        }
    }
}
}
int main(int argc,char** argv) {
    if(argc>1 && std::string_view{argv[1]}=="--fixtures") {
        std::puts("m,n,fixture_fnv1a64");
        for(const Eigen::Index n:{2,8,32,128,512}) for(const Eigen::Index m:{n,4*n}) {
            const auto fixture=kibo::tests::performance_fixture(m,n);
            std::printf("%lld,%lld,%016llx\n",static_cast<long long>(m),static_cast<long long>(n),static_cast<unsigned long long>(hash_fixture(fixture)));
        }
        return 0;
    }
    const int run=argc>1?std::atoi(argv[1]):1;
    Eigen::setNbThreads(1);
    std::puts("run,m,n,condition,solver,backend,phase,numeric_bytes,median_seconds,p95_seconds,calls,fixture_fnv1a64");
    try {
        for(const Eigen::Index n:{2,8,32,128,512}) for(const Eigen::Index m:{n,4*n}) {
            auto fixture=kibo::tests::performance_fixture(m,n);
            double condition=0;
            {
                Eigen::MatrixXd gram=fixture.matrix.transpose()*fixture.matrix;
                Eigen::SelfAdjointEigenSolver<Eigen::MatrixXd> spectrum(gram,Eigen::EigenvaluesOnly);
                if(spectrum.info()!=Eigen::Success || spectrum.eigenvalues()[0]<=0) throw std::runtime_error("fixture condition verification failed");
                condition=std::sqrt(spectrum.eigenvalues().tail(1)[0]/spectrum.eigenvalues()[0]);
            } // reference workspaces are released before measured resources are prepared
            if(condition>100) throw std::runtime_error("fixture condition exceeds 100");
            for(bool qr:{false,true}) {
                const bool first_eigen=run%2==0;
                benchmark(run,fixture,qr,first_eigen,condition);
                benchmark(run,fixture,qr,!first_eigen,condition);
            }
        }
    } catch(const std::exception& error) {std::fprintf(stderr,"benchmark rejected: %s\n",error.what());return 1;}
}
