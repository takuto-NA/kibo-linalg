#include <kibo/llt.hpp>
#include "test_check.hpp"
#include <array>
#include <string_view>
#include <vector>

int main(int argc,char** argv) {
    using namespace kibo::linalg;
    const bool small=argc>1 && std::string_view{argv[1]}=="--small";
    for (std::size_t n:{127,128,129,512}) {
        if (small && n==512) continue;
        std::vector<double> lower(n*n),input(n*n),truth(n),rhs(n),answer(n),work(n);
        for (std::size_t i=0;i<n;++i) {
            truth[i]=i%2==0 ? 1 : -.25;
            for (std::size_t j=0;j<=i;++j)
                lower[i*n+j]=i==j ? 2+double(i%3) : (double((i*7+j*3)%5)-2)*.125;
        }
        for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<=i;++j) {
            double value=0;
            for (std::size_t k=0;k<=j;++k) value+=lower[i*n+k]*lower[j*n+k];
            input[i*n+j]=input[j*n+i]=value;
        }
        for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<n;++j) rhs[i]+=input[i*n+j]*truth[j];
        const auto a=MatrixView<const double>::checked(input,n,n,n).value();
        auto workspace=std::as_writable_bytes(std::span<double>{work});
        for (const auto strides:std::array<std::array<std::size_t,2>,4>{{{n,1},{n+3,1},{2*n+3,2},{1,n+3}}}) {
            std::vector<double> backing(n*strides[0]+n*strides[1],999);
            auto target=MatrixView<double>::checked(backing,n,n,strides[0],strides[1]).value();
            auto factor=factorize_llt(a,target);
            CHECK(factor && solve_into(factor.value(),rhs,answer,workspace));
            std::vector<bool> logical(backing.size());
            for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<n;++j) {
                CHECK(target(i,j)==lower[i*n+j]);
                logical[i*strides[0]+j*strides[1]]=true;
            }
            for (std::size_t i=0;i<n;++i) CHECK(std::abs(answer[i]-truth[i])<1e-11);
            for (std::size_t i=0;i<backing.size();++i) if (!logical[i]) CHECK(backing[i]==999);
        }
        // Overflow occurs in the last backward substitution, after many
        // successful rows. No answer may be committed from a partial solve.
        std::fill(input.begin(),input.end(),0);
        for (std::size_t i=0;i<n;++i) input[i*n+i]=1;
        input[0]=1e-300;
        std::vector<double> storage(n*n);
        auto target=MatrixView<double>::checked(storage,n,n,n).value();
        auto factor=factorize_llt(a,target);
        CHECK(factor);
        std::fill(rhs.begin(),rhs.end(),1);rhs[0]=1e150;
        std::fill(answer.begin(),answer.end(),123);
        auto status=solve_into(factor.value(),rhs,answer,workspace);
        CHECK(status.code==StatusCode::arithmetic_failure && status.index==0);
        for (double value:answer) CHECK(value==123);
        input[0]=1;input[n*n-1]=-1;
        auto pivot=factorize_llt(a,target);
        CHECK(!pivot && pivot.status().code==StatusCode::non_positive_pivot && pivot.status().index==n-1);
        input[n*n-1]=1;input[0]=1e-300;input[1]=input[n]=1e300;
        auto overflow=factorize_llt(a,target);
        CHECK(!overflow && overflow.status().code==StatusCode::arithmetic_failure && overflow.status().index==0);
    }
    std::puts("large LLT boundaries, exact factors, padded layouts and late failures passed");
}
