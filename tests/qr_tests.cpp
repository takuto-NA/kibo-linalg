#include <kibo/qr.hpp>
#include <array>
#include <cmath>
#include <cstdio>
#include <vector>
#include "test_check.hpp"
int main() {
    using namespace kibo::linalg;
    // The first reflector concentrates a finite RHS into row 4. A grouped
    // solve then rejects its next panel after changing the RHS. Restarting
    // must use the original RHS, including on padded caller row storage.
    for (const std::size_t padding : {0,3}) {
        constexpr std::size_t m=512,n=256;
        const auto stride=n+padding;
        std::vector<double> packed(m*stride,777),tau(n),rhs(m),answer(n,123),work(m+n+2,888);
        std::vector<std::size_t> order(n);
        auto view=MatrixView<double>::checked(packed,m,n,stride).value();
        for(std::size_t i=0;i<m;++i)for(std::size_t j=0;j<n;++j)view(i,j)=i==j?1:0;
        const double tail=.8/std::sqrt(double(m-8));
        view(4,0)=.6;
        for(std::size_t i=8;i<m;++i)view(i,0)=tail;
        tau[0]=1;
        for(std::size_t j=0;j<n;++j)order[j]=j;
        double safe=std::numeric_limits<double>::max();
        for(std::size_t i=0;i<5;++i)safe/=8*double(m)+2;
        const double scale=.5*safe;
        std::fill(rhs.begin(),rhs.end(),scale);
        const double dot=1+.6+double(m-8)*tail;
        CHECK(std::abs(1-.6*dot)>2); // row 4 exceeds safe only after panel 0.
        const auto saved=packed;
        const std::span<const std::size_t> permutation{order};
        auto factor=detail::QrAccess::create(MatrixView<const double>{view},tau,permutation,QrDiagnostics{n,0,permutation});
        auto ws=std::as_writable_bytes(std::span<double>{work}.subspan(1,m+n));
        CHECK(solve_into(factor,rhs,answer,ws));
        for(std::size_t j=0;j<n;++j) {
            const double v=j==0?1:(j==4?.6:(j>=8?tail:0));
            CHECK(std::abs(answer[j]/scale-(1-v*dot))<1e-12);
        }
        CHECK(packed==saved && work.front()==888 && work.back()==888);
        std::fill(answer.begin(),answer.end(),123);
        CHECK(solve_into(factor,rhs,answer,ws.first(ws.size()-1)).code==StatusCode::insufficient_capacity);
        for(double value:answer)CHECK(value==123);
        rhs.back()=std::numeric_limits<double>::quiet_NaN();
        CHECK(solve_into(factor,rhs,answer,ws).code==StatusCode::non_finite_input);
        for(double value:answer)CHECK(value==123);
        CHECK(packed==saved && work.front()==888 && work.back()==888);
    }
    // Alternating products cancel in the original reflector order, while
    // separated SIMD accumulators overflow. Retry the complete Q application.
    {
        constexpr std::size_t m=17,n=2;
        std::array<double,m*n> values{},packed{};
        std::array<double,m> rhs{};
        const auto maximum=std::numeric_limits<double>::max();
        for(std::size_t i=1;i<m;++i){values[i*n]=i%2?1:-1;rhs[i]=.6*maximum;}
        values[n+1]=1;values[3*n+1]=-1;rhs[0]=.1*maximum;
        std::array<double,n> tau{},answer{123,123};
        std::array<std::size_t,n> order{};
        std::array<double,m+n> work{};
        auto a=MatrixView<const double>::checked(values,m,n,n).value();
        auto p=MatrixView<double>::checked(packed,m,n,n).value();
        auto ws=std::as_writable_bytes(std::span<double>{work});
        auto factor=factorize_qr(a,p,tau,order,ws);
        CHECK(factor && solve_into(factor.value(),rhs,answer,ws));
        for(double value:answer)CHECK(std::abs(value/maximum)<1e-14);
    }
    // A failed fast projection must retain the original reflector's failure
    // index and leave the caller's entire answer unchanged.
    {
        constexpr std::size_t m=9,n=2;
        std::array<double,m*n> values{},packed{};
        std::array<double,m> rhs{};
        const auto maximum=std::numeric_limits<double>::max();
        for(std::size_t i=1;i<m;++i){values[i*n]=i%2?1:-1;rhs[i]=.9*maximum;}
        values[1]=1;rhs[0]=.1*maximum;
        std::array<double,n> tau{},answer{123,456};
        std::array<std::size_t,n> order{};
        std::array<double,m+n> work{};
        auto a=MatrixView<const double>::checked(values,m,n,n).value();
        auto p=MatrixView<double>::checked(packed,m,n,n).value();
        auto ws=std::as_writable_bytes(std::span<double>{work});
        auto factor=factorize_qr(a,p,tau,order,ws);
        CHECK(factor);
        const auto status=solve_into(factor.value(),rhs,answer,ws);
        CHECK(status.code==StatusCode::arithmetic_failure && status.index==1);
        CHECK(answer[0]==123 && answer[1]==456);
    }
    // Regrouping a finite triangular solve must not introduce an overflow
    // failure. The known solutions are scaled to avoid overflowing the test.
    for(const auto strides:std::array<std::array<std::size_t,2>,3>{{{3,1},{1,3},{7,2}}})
        for(double sign:{1.0,-1.0}) {
            std::array<double,9> values{2,.7,sign*.7,0,.1,0,0,0,.1};
            std::array<double,27> packed{};
            const auto maximum=std::numeric_limits<double>::max();
            std::array<double,3> rhs{.4*maximum,.09*maximum,.09*maximum},tau{},answer{123,123,123};
            std::array<std::size_t,3> order{};
            std::array<double,6> work{};
            auto a=MatrixView<const double>::checked(values,3,3,3).value();
            auto p=MatrixView<double>::checked(packed,3,3,strides[0],strides[1]).value();
            auto ws=std::as_writable_bytes(std::span<double>{work});
            auto factor=factorize_qr(a,p,tau,order,ws);
            CHECK(factor && solve_into(factor.value(),rhs,answer,ws));
            CHECK(std::abs(answer[0]/maximum-(.2-.315*(1+sign)))<1e-14);
            CHECK(std::abs(answer[1]/maximum-.9)<1e-14 && std::abs(answer[2]/maximum-.9)<1e-14);
        }
    // Every position in a packet or its scalar tail can overflow in a
    // residual row after a finite projection. No partial answer is published.
    for (const std::size_t m : {5,6,8,9}) for (std::size_t failing_row=1;failing_row<m;++failing_row) {
        std::vector<double> input(m),packed(m),rhs(m),work(m+1);
        input[0]=1;input[failing_row]=-1;
        rhs[0]=rhs[failing_row]=.9*std::numeric_limits<double>::max();
        std::array<double,1> tau{},answer{123};
        std::array<std::size_t,1> order{};
        auto a=MatrixView<const double>::checked(input,m,1,1).value();
        auto p=MatrixView<double>::checked(packed,m,1,1).value();
        auto ws=std::as_writable_bytes(std::span<double>{work});
        auto factor=factorize_qr(a,p,tau,order,ws);
        CHECK(factor);
        const auto status=solve_into(factor.value(),rhs,answer,ws);
        CHECK(status.code==StatusCode::arithmetic_failure && status.index==0 && answer[0]==123);
    }
    // Logical NaN/Inf input is rejected before writes for both contiguous
    // directions; non-finite padding is outside the input view.
    for (const auto strides:std::array<std::array<std::size_t,2>,3>{{{7,1},{1,11},{14,2}}}) {
        constexpr std::size_t m=9,n=5;
        std::vector<double> input(m*strides[0]+n*strides[1],std::numeric_limits<double>::quiet_NaN());
        for(std::size_t i=0;i<m;++i)for(std::size_t j=0;j<n;++j)input[i*strides[0]+j*strides[1]]=i==j?2:.0625;
        auto a=MatrixView<const double>::checked(input,m,n,strides[0],strides[1]).value();
        std::array<double,m*n> packed{};
        std::array<double,n> tau{};
        std::array<std::size_t,n> order{};
        std::array<double,2*n> work{};
        auto p=MatrixView<double>::checked(packed,m,n,n).value();
        auto ws=std::as_writable_bytes(std::span<double>{work});
        CHECK(factorize_qr(a,p,tau,order,ws));
        for(double bad:{std::numeric_limits<double>::quiet_NaN(),std::numeric_limits<double>::infinity(),-std::numeric_limits<double>::infinity()})
            for(std::size_t i=0;i<m;++i)for(std::size_t j=0;j<n;++j) {
                const auto index=i*strides[0]+j*strides[1];const double saved=input[index];input[index]=bad;
                packed.fill(777);tau.fill(888);order.fill(999);
                auto result=factorize_qr(a,p,tau,order,ws);
                CHECK(!result && result.status().code==StatusCode::non_finite_input);
                for(double value:packed)CHECK(value==777);
                for(double value:tau)CHECK(value==888);
                for(auto value:order)CHECK(value==999);
                input[index]=saved;
            }
    }
    // Boundaries around row/packet widths use the same known solution at
    // ordinary and extreme scales. Padding is never a logical write.
    for(const std::size_t n:{4,7,8,9,15,16,17,31,32,33,64,65})for(double scale:{1.0,1e-300,1e300,1e307}) {
        const auto m=4*n;
        std::vector<double> values(m*n),rhs(m),truth(n),answer(n),tau(n),work(m+n);
        std::vector<std::size_t> order(n);
        for(std::size_t j=0;j<n;++j)truth[j]=j%2?-.5:1;
        for(std::size_t i=0;i<m;++i)for(std::size_t j=0;j<n;++j) {
            values[i*n+j]=scale*((double((i*7+j*3)%11)-5)*.0625+(i==j?4:0));
            rhs[i]+=values[i*n+j]*truth[j];
        }
        auto a=MatrixView<const double>::checked(values,m,n,n).value();
        for(const auto strides:std::array<std::array<std::size_t,2>,4>{{{n,1},{n+3,1},{2*n+3,2},{1,m+3}}}) {
            std::vector<double> packed(m*strides[0]+n*strides[1],777);
            auto p=MatrixView<double>::checked(packed,m,n,strides[0],strides[1]).value();
            auto ws=std::as_writable_bytes(std::span<double>{work});
            auto factor=factorize_qr(a,p,tau,order,ws);
            CHECK(factor && factor.value().diagnostics().rank==n);
            CHECK(solve_into(factor.value(),rhs,answer,ws));
            for(std::size_t j=0;j<n;++j)CHECK(std::abs(answer[j]-truth[j])<1e-10);
            std::vector<bool> logical(packed.size());
            for(std::size_t i=0;i<m;++i)for(std::size_t j=0;j<n;++j)logical[i*strides[0]+j*strides[1]]=true;
            for(std::size_t i=0;i<packed.size();++i)if(!logical[i])CHECK(packed[i]==777);
        }
    }
    // Exact workspace capacity and preflight failure preserve caller storage
    // around the first eight-column dispatch boundary.
    {
        constexpr std::size_t m=32,n=8;
        std::array<double,m*n> values{},packed{};
        std::array<double,n> tau{};
        std::array<std::size_t,n> order{};
        std::array<double,2*n> work{};
        for(std::size_t i=0;i<m;++i)for(std::size_t j=0;j<n;++j)values[i*n+j]=i==j?2:.0625;
        auto a=MatrixView<const double>::checked(values,m,n,n).value();
        auto p=MatrixView<double>::checked(packed,m,n,n).value();
        auto ws=std::as_writable_bytes(std::span<double>{work});
        CHECK(ws.size()==qr_factor_requirement(m,n).value().workspace.bytes);
        CHECK(factorize_qr(a,p,tau,order,ws));
        for(const auto index:std::array<std::size_t,3>{0,m*n/2,m*n-1}) {
            const auto saved=values[index];values[index]=std::numeric_limits<double>::quiet_NaN();
            packed.fill(777);tau.fill(888);order.fill(999);
            CHECK(factorize_qr(a,p,tau,order,ws).status().code==StatusCode::non_finite_input);
            for(double value:packed)CHECK(value==777);
            for(double value:tau)CHECK(value==888);
            for(auto value:order)CHECK(value==999);
            values[index]=saved;
        }
        CHECK(factorize_qr(a,p,tau,order,ws.first(ws.size()-1)).status().code==StatusCode::insufficient_capacity);
        for(double value:packed)CHECK(value==777);
        for(std::size_t i=0;i<m;++i)values[i*n+n-1]=values[i*n+n-2];
        QrDiagnostics diagnostics;
        auto deficient=factorize_qr(a,p,tau,order,ws,{},&diagnostics);
        CHECK(!deficient && deficient.status().code==StatusCode::rank_deficient && diagnostics.rank==n-1);
    }
    // Large row factors use the same transactional solve contract when the
    // transformed RHS exceeds the safe range of a grouped update.
    for(const std::size_t n:{255,256,257}) {
        std::vector<double> values(n*n),packed(n*n),tau(n),work(2*n),rhs(n,1),answer(n,123);
        std::vector<std::size_t> order(n);
        for(std::size_t i=0;i<n;++i)values[i*n+i]=1;
        auto a=MatrixView<const double>::checked(values,n,n,n).value();
        auto p=MatrixView<double>::checked(packed,n,n,n).value();
        auto ws=std::as_writable_bytes(std::span<double>{work});
        auto factor=factorize_qr(a,p,tau,order,ws);
        CHECK(factor && solve_into(factor.value(),rhs,answer,ws));
        for(double value:answer)CHECK(std::abs(value-1)<1e-12);
        rhs[0]=.9*std::numeric_limits<double>::max();
        std::fill(answer.begin(),answer.end(),123);
        const auto failed=solve_into(factor.value(),rhs,answer,ws);
        CHECK(failed.code==StatusCode::arithmetic_failure && failed.index==0);
        for(double value:answer)CHECK(value==123);
    }
    // Rectangular tight row storage keeps its caller-visible factor layout
    // and uses exactly the queried factor workspace, including ratio tails.
    for(const std::size_t n:{8,9})for(const std::size_t ratio:{1,2,3,5,64,65}) {
        const auto m=n*ratio;
        std::vector<double> values(m*n),packed(m*n),tau(n),rhs(m),answer(n),work(m+n,777);
        std::vector<std::size_t> order(n);
        for(std::size_t i=0;i<m;++i)for(std::size_t j=0;j<n;++j) {
            values[i*n+j]=(double((i*7+j*3)%11)-5)*.0625+(i==j?4:0);
            rhs[i]+=values[i*n+j]*(j%2?-.5:1);
        }
        auto a=MatrixView<const double>::checked(values,m,n,n).value();
        auto p=MatrixView<double>::checked(packed,m,n,n).value();
        auto ws=std::as_writable_bytes(std::span<double>{work});
        auto factor=factorize_qr(a,p,tau,order,ws.first(qr_factor_requirement(m,n).value().workspace.bytes));
        CHECK(factor && factor.value().packed().row_stride()==n && factor.value().packed().col_stride()==1);
        for(std::size_t i=2*n;i<work.size();++i)CHECK(work[i]==777);
        CHECK(solve_into(factor.value(),rhs,answer,ws));
        for(std::size_t j=0;j<n;++j)CHECK(std::abs(answer[j]-(j%2?-.5:1))<1e-10);
    }
    // A finite full-rank factor can overflow only in transformed residual rows.
    // Checked contiguous updates must reject it and preserve the output.
    for (const auto stride:std::array<std::array<std::size_t,2>,2>{{{1,3},{2,1}}}) {
        std::array<double,2> input{1,-1};
        std::array<double,6> packed{};
        std::array<double,1> tau{},answer{123};
        std::array<std::size_t,1> order{};
        std::array<double,3> work{};
        const std::array<double,2> rhs{.9*std::numeric_limits<double>::max(),.9*std::numeric_limits<double>::max()};
        auto a=MatrixView<const double>::checked(input,2,1,1).value();
        auto p=MatrixView<double>::checked(packed,2,1,stride[0],stride[1]).value();
        auto factor=factorize_qr(a,p,tau,order,std::as_writable_bytes(std::span<double>{work}));
        CHECK(factor);
        auto status=solve_into(factor.value(),rhs,answer,std::as_writable_bytes(std::span<double>{work}));
        CHECK(status.code==StatusCode::arithmetic_failure && status.index==0 && answer[0]==123);
    }
    // A dense multi-column solve exercises unfinished tau slots and strided
    // factor storage. Padding must remain outside the logical writes.
    {
        constexpr std::array<double,24> values{1,2,-1,10,2,0,3,4,0,1,2,7,3,-1,0,2,1,1,1,-3,-2,0,1,5};
        constexpr std::array<double,4> expected{1,-2,0.5,3};
        auto a=MatrixView<const double>::checked(values,6,4,4).value();
        std::array<double,6> rhs{};
        CHECK(matvec_into(a,std::span<const double>{expected},std::span<double>{rhs}));
        for(const auto strides:std::array<std::array<std::size_t,2>,3>{{{4,1},{1,6},{8,1}}}) {
            std::array<double,48> storage;storage.fill(999);
            std::array<double,4> coefficients;coefficients.fill(std::numeric_limits<double>::quiet_NaN());
            std::array<std::size_t,4> order{};
            alignas(double) std::array<std::byte,80> work{};
            auto view=MatrixView<double>::checked(storage,6,4,strides[0],strides[1]).value();
            auto result=factorize_qr(a,view,coefficients,order,std::span<std::byte>{work}.first(64));
            CHECK(result && result.value().diagnostics().rank==4 && order[0]==3);
            std::array<double,4> answer{};
            CHECK(solve_into(result.value(),std::span<const double>{rhs},std::span<double>{answer},work));
            for(std::size_t j=0;j<4;++j) CHECK(std::abs(answer[j]-expected[j])<1e-12 && std::isfinite(coefficients[j]));
            std::array<bool,48> logical{};
            for(std::size_t i=0;i<6;++i) for(std::size_t j=0;j<4;++j) logical[i*strides[0]+j*strides[1]]=true;
            for(std::size_t index=0;index<48;++index) if(!logical[index]) CHECK(storage[index]==999);
        }
    }
    // Inconsistent b has least-squares solution [1,2]; residual [-1,-1,1] is orthogonal to columns.
    {
        constexpr std::size_t m=15,n=9;
        std::array<double,m*n> values{};
        std::array<double,n> truth{},answer{},coefficients{};
        std::array<double,m> rhs{};
        std::array<std::size_t,n> order{};
        std::array<double,m+n> work{};
        for(std::size_t j=0;j<n;++j) truth[j]=double(j%3)-1;
        for(std::size_t i=0;i<m;++i) for(std::size_t j=0;j<n;++j) {
            values[i*n+j]=(double((i*7+j*3)%11)-5)*0.0625+(i==j?4:0);
            rhs[i]+=values[i*n+j]*truth[j];
        }
        auto dense=MatrixView<const double>::checked(values,m,n,n).value();
        for(const auto strides:std::array<std::array<std::size_t,2>,4>{{{n,1},{n+3,1},{2*n+3,2},{1,m+3}}}) {
            std::array<double,m*(2*n+3)> backing;backing.fill(999);
            auto target=MatrixView<double>::checked(backing,m,n,strides[0],strides[1]).value();
            auto result=factorize_qr(dense,target,coefficients,order,std::as_writable_bytes(std::span<double>{work}.first(2*n)));
            CHECK(result && result.value().diagnostics().rank==n);
            CHECK(solve_into(result.value(),std::span<const double>{rhs},std::span<double>{answer},std::as_writable_bytes(std::span<double>{work})));
            for(std::size_t j=0;j<n;++j) CHECK(std::abs(answer[j]-truth[j])<1e-12);
            std::array<bool,m*(2*n+3)> logical{};
            for(std::size_t i=0;i<m;++i) for(std::size_t j=0;j<n;++j) logical[i*strides[0]+j*strides[1]]=true;
            for(std::size_t i=0;i<backing.size();++i) if(!logical[i]) CHECK(backing[i]==999);
        }
    }
    std::array<double,6> data{1,0,0,1,1,1};
    auto input=MatrixView<const double>::checked(data,3,2,2);
    StaticMatrix<double,3,2> packed;
    std::array<double,2> tau{};
    std::array<std::size_t,2> permutation{};
    alignas(double) std::array<std::byte,32> factor_workspace{};
    QrDiagnostics diagnostics;
    auto factor=factorize_qr(input.value(),packed.view(),tau,permutation,factor_workspace,{},&diagnostics);
    CHECK(factor && diagnostics.rank==2);
    const std::array<double,3> b{0,1,4};
    std::array<double,2> output{99,98};
    alignas(double) std::array<std::byte,40> solve_workspace{};
    CHECK(solve_into(factor.value(),std::span<const double>{b},std::span<double>{output},solve_workspace));
    CHECK(std::abs(output[0]-1)<1e-12 && std::abs(output[1]-2)<1e-12);
    auto required=qr_factor_requirement(3,2);
    CHECK(required && required.value().packed.bytes==48 && required.value().workspace.bytes==32);
    CHECK(qr_solve_requirement(3,2).value().bytes==40);
    output={99,98};
    CHECK(solve_into(factor.value(),std::span<const double>{b},std::span<double>{output},std::span<std::byte>{solve_workspace}.first(39)).code==StatusCode::insufficient_capacity);
    CHECK((output==std::array<double,2>{99,98}));
    CHECK(solve_into(QrFactorView{},std::span<const double>{b},std::span<double>{output},solve_workspace).code==StatusCode::invalid_factor);
    packed(0,0)=77; tau[0]=88; permutation[0]=99;
    auto short_capacity=factorize_qr(input.value(),packed.view(),tau,permutation,std::span<std::byte>{factor_workspace}.first(31));
    CHECK(!short_capacity && short_capacity.status().code==StatusCode::insufficient_capacity);
    CHECK(packed(0,0)==77 && tau[0]==88 && permutation[0]==99);
    data={1,1,2,2,3,3};
    auto deficient=factorize_qr(input.value(),packed.view(),tau,permutation,factor_workspace,{},&diagnostics);
    CHECK(!deficient && deficient.status().code==StatusCode::rank_deficient && deficient.status().rank==1 && diagnostics.rank==1);
    StaticMatrix<double,2,2> square, square_packed;
    square(0,0)=1; square(0,1)=10; square(1,0)=0; square(1,1)=1;
    auto swapped=factorize_qr(square.const_view(),square_packed.view(),tau,permutation,factor_workspace);
    CHECK(swapped && permutation[0]==1);
    const std::array<double,2> square_rhs{-28,-3};
    CHECK(solve_into(swapped.value(),std::span<const double>{square_rhs},std::span<double>{output},solve_workspace));
    CHECK(std::abs(output[0]-2)<1e-12 && std::abs(output[1]+3)<1e-12);
    square(0,0)=1; square(0,1)=0; square(1,0)=0; square(1,1)=1e-4;
    auto below=factorize_qr(square.const_view(),square_packed.view(),tau,permutation,factor_workspace,QrOptions{1e-3},&diagnostics);
    CHECK(!below && diagnostics.rank==1 && diagnostics.tolerance==1e-3);
    auto above=factorize_qr(square.const_view(),square_packed.view(),tau,permutation,factor_workspace,QrOptions{1e-5});
    CHECK(above && above.value().diagnostics().rank==2);
    CHECK(factorize_qr(square.const_view(),square_packed.view(),tau,permutation,factor_workspace,QrOptions{1.0}).status().code==StatusCode::invalid_argument);
    for (const double scale : {1e-300,1e-160,1e-150,1e150,1e300}) {
        data={scale,0,0,scale,scale,scale};
        auto scaled=factorize_qr(input.value(),packed.view(),tau,permutation,factor_workspace);
        const std::array<double,3> consistent_rhs{scale,2*scale,3*scale};
        CHECK(scaled && solve_into(scaled.value(),std::span<const double>{consistent_rhs},std::span<double>{output},solve_workspace));
        CHECK(std::abs(output[0]-1)<1e-12 && std::abs(output[1]-2)<1e-12);
    }
    data={1,1,1,1+1e-8,1,1-1e-8};
    const std::array<double,3> difficult_rhs{0,-1e-8,1e-8}; // known x=[1,-1]
    auto difficult=factorize_qr(input.value(),packed.view(),tau,permutation,factor_workspace);
    CHECK(difficult && solve_into(difficult.value(),std::span<const double>{difficult_rhs},std::span<double>{output},solve_workspace));
    CHECK(std::abs(output[0]-1)<1e-4 && std::abs(output[1]+1)<1e-4);
    CHECK(qr_factor_requirement(1,2).status().code==StatusCode::invalid_shape);
    CHECK(qr_factor_requirement(std::numeric_limits<std::size_t>::max(),2).status().code==StatusCode::size_overflow);
    CHECK(qr_solve_requirement(std::numeric_limits<std::size_t>::max(),1).status().code==StatusCode::size_overflow);
    for (const std::size_t n : {2,8,32,128,512})
        for (const std::size_t m : {n,4*n}) CHECK(qr_factor_requirement(m,n) && qr_solve_requirement(m,n));
    data[5]=std::numeric_limits<double>::quiet_NaN();
    packed(0,0)=77;
    CHECK(factorize_qr(input.value(),packed.view(),tau,permutation,factor_workspace).status().code==StatusCode::non_finite_input && packed(0,0)==77);
    std::puts("public pivoted QR least-squares solve passed");
}
