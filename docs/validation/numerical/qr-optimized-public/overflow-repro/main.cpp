#include <kibo/qr.hpp>
#include <array>
#include <cstdio>
#include <limits>
int main() {
  using namespace kibo::linalg;
  int failures=0;
  for(bool column:{false,true})for(double sign:{1.0,-1.0}) {
    std::array<double,9> a{2,.7,sign*.7,0,.1,0,0,0,.1},packed{};
    const auto maximum=std::numeric_limits<double>::max();
    std::array<double,3> rhs{.4*maximum,.09*maximum,.09*maximum},tau{},out{123,123,123};
    std::array<std::size_t,3> order{};
    std::array<double,6> work{};
    auto input=MatrixView<const double>::checked(a,3,3,3).value();
    auto p=MatrixView<double>::checked(packed,3,3,column?1:3,column?3:1).value();
    auto ws=std::as_writable_bytes(std::span<double>{work});
    auto factor=factorize_qr(input,p,tau,order,ws);
    if(!factor){std::printf("factor failure\n");return 2;}
    auto status=solve_into(factor.value(),rhs,out,ws);
    std::printf("column=%d sign=%g code=%d index=%zu normalized=[%.17g,%.17g,%.17g]\n",column,sign,int(status.code),status.index,out[0]/maximum,out[1]/maximum,out[2]/maximum);
    if(!status)++failures;
  }
  {
    constexpr std::size_t m=17;
    constexpr std::size_t n=2;
    std::array<double,m*n> a{},packed{};std::array<double,m> rhs{};
    const auto maximum=std::numeric_limits<double>::max();
    for(std::size_t i=1;i<m;++i){a[i*n]=i%2?1:-1;rhs[i]=.6*maximum;}
    a[n+1]=1;a[3*n+1]=-1;
    rhs[0]=.1*maximum;
    std::array<double,n> tau{},out{123,123};std::array<std::size_t,n> order{};
    std::array<double,m+n> work{};
    auto input=MatrixView<const double>::checked(a,m,n,n).value();
    auto p=MatrixView<double>::checked(packed,m,n,n).value();
    auto ws=std::as_writable_bytes(std::span<double>{work});
    auto factor=factorize_qr(input,p,tau,order,ws);
    auto status=solve_into(factor.value(),rhs,out,ws);
    std::printf("alternating Q: code=%d index=%zu normalized=[%.17g,%.17g]\n",int(status.code),status.index,out[0]/maximum,out[1]/maximum);
    if(!status)++failures;
  }
  return failures;
}
