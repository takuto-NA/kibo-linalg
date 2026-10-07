#include <kibo/qr.hpp>
#include "controlled_fixture.hpp"
#include "fixtures/oracles.hpp"
#include <Eigen/QR>
#include <bit>
#include <cstdio>
#include <vector>
using namespace kibo::linalg;
using kibo::tests::RowMatrix;
#include "refine.hpp"
void vector_json(const char* key,const double* x,std::size_t n) {
    std::printf(",\"%s\":[",key);
    for(std::size_t i=0;i<n;++i) std::printf("%s%.17g",i?",":"",x[i]);
    std::printf("]");
}
void audit(const RowMatrix& a,const Eigen::VectorXd& b,const Eigen::VectorXd& truth,
           const char* id,double condition,double scale,bool inconsistent) {
    const std::size_t m=a.rows(),n=a.cols();
    std::uint64_t hash=14695981039346656037ULL;
    auto append=[&](std::uint64_t x){for(int i=0;i<8;++i){hash^=(x>>(8*i))&255;hash*=1099511628211ULL;}};
    append(m);append(n);
    for(Eigen::Index i=0;i<a.size();++i) append(std::bit_cast<std::uint64_t>(a.data()[i]));
    for(Eigen::Index i=0;i<b.size();++i) append(std::bit_cast<std::uint64_t>(b[i]));
    const double normalization=a.cwiseAbs().maxCoeff();
    RowMatrix normalized=a/normalization;
    Eigen::VectorXd normalized_b=b/normalization;
    Eigen::VectorXd raw=a.colPivHouseholderQr().solve(b);
    Eigen::VectorXd reference=normalized.colPivHouseholderQr().solve(normalized_b);
    for(bool column:{false,true}) {
        RowMatrix packed(m,n);
        std::vector<double> tau(n),work(m+n),x(n),r(n*n);
        std::vector<std::size_t> permutation(n);
        QrDiagnostics diagnostics;
        auto input=MatrixView<const double>::checked({a.data(),m*n},m,n,n).value();
        auto storage=MatrixView<double>::checked({packed.data(),m*n},m,n,column?1:n,column?m:1).value();
        auto workspace=std::as_writable_bytes(std::span<double>(work));
        auto factor=factorize_qr(input,storage,tau,permutation,workspace,{},&diagnostics);
        const auto status=factor?solve_into(factor.value(),{b.data(),m},x,workspace):factor.status();
        if(!status) {std::printf("{\"id\":\"%s\",\"m\":%zu,\"n\":%zu,\"column\":%d,\"status\":%d}\n",id,m,n,column,int(status.code));continue;}
        Eigen::Map<const Eigen::VectorXd> answer(x.data(),n);
        const double forward=(answer-truth).norm()/truth.norm();
        Eigen::VectorXd residual=normalized*answer-normalized_b;
        const double denominator=normalized.norm()*(normalized.norm()*answer.norm()+normalized_b.norm());
        const double optimality=(normalized.transpose()*residual).norm()/denominator;
        for(std::size_t i=0;i<n;++i) for(std::size_t j=0;j<n;++j) r[i*n+j]=j<i?0:storage(i,j);
        auto plain=diagnostic_refine(a,b,r,permutation,x,false);
        auto dd=diagnostic_refine(a,b,r,permutation,x,true);
        std::printf("{\"id\":\"%s\",\"m\":%zu,\"n\":%zu,\"column\":%d,\"status\":0,\"rank\":%zu,\"condition\":%.17g,\"scale\":%.17g,\"inconsistent\":%d,\"inputHash\":\"%016llx\",\"coreSIMD\":%d,\"coreForward\":%.17g,\"coreOptimality\":%.17g,\"eigenRawForward\":%.17g,\"eigenNormalizedForward\":%.17g",
            id,m,n,column,diagnostics.rank,condition,scale,inconsistent,static_cast<unsigned long long>(hash),detail::row_simd_available,forward,optimality,(raw-truth).norm()/truth.norm(),(reference-truth).norm()/truth.norm());
        std::printf(",\"plainRefinedForward\":%.17g,\"ddRefinedForward\":%.17g",
                    (Eigen::Map<const Eigen::VectorXd>(plain.data(),n)-truth).norm()/truth.norm(),
                    (Eigen::Map<const Eigen::VectorXd>(dd.data(),n)-truth).norm()/truth.norm());
        if(n<=8) {
            vector_json("matrix",a.data(),m*n);vector_json("rhs",b.data(),m);
            vector_json("truth",truth.data(),n);vector_json("core",x.data(),n);
            vector_json("eigenRaw",raw.data(),n);vector_json("eigenNormalized",reference.data(),n);
            vector_json("refinedPlain",plain.data(),n);vector_json("refinedDD",dd.data(),n);
            vector_json("R",r.data(),n*n);
            std::printf(",\"permutation\":[");
            for(std::size_t i=0;i<n;++i) std::printf("%s%zu",i?",":"",permutation[i]);
            std::printf("]");
        }
        if(n>8) {
            bool verified=true;
            for(std::size_t i=0;i<m;++i) for(std::size_t j=0;j<n;++j)
                verified&=std::bit_cast<std::uint64_t>(a(i,j))==std::bit_cast<std::uint64_t>(a(0,(i%n)^j));
            std::printf(",\"xorCirculantVerified\":%s",verified?"true":"false");
            vector_json("firstRow",a.data(),n);vector_json("rhs",b.data(),m);
            vector_json("truth",truth.data(),n);vector_json("core",x.data(),n);
            vector_json("eigenRaw",raw.data(),n);vector_json("eigenNormalized",reference.data(),n);
            vector_json("refinedPlain",plain.data(),n);vector_json("refinedDD",dd.data(),n);
        }
        std::printf("}\n");
    }
}
int main() {
    int index=0;
    for(const auto& oracle:kibo::tests::oracles) {
        RowMatrix a=Eigen::Map<const RowMatrix>(oracle.matrix,oracle.m,oracle.n);
        Eigen::VectorXd b=Eigen::Map<const Eigen::VectorXd>(oracle.rhs,oracle.m),truth(oracle.n);
        for(std::size_t j=0;j<oracle.n;++j) truth[j]=(j%2?-1:1)*double(j+1)/double(oracle.n);
        char id[80];std::snprintf(id,sizeof id,"oracle-%d",index++);
        audit(a,b,truth,id,1e8,a.cwiseAbs().maxCoeff(),true);
    }
    for(Eigen::Index n:{2,8,32,128,512}) for(Eigen::Index m:{n,4*n})
        for(double condition:{2.0,1e4,1e8}) for(bool inconsistent:{false,true}) {
            if(m==n&&inconsistent)continue;
            auto f=kibo::tests::controlled_fixture(m,n,condition,inconsistent);
            char id[100];std::snprintf(id,sizeof id,"controlled-m%lld-n%lld-c%.0f-r%d",static_cast<long long>(m),static_cast<long long>(n),condition,inconsistent);
            audit(f.matrix,f.rhs,f.truth,id,condition,1,inconsistent);
        }
}
