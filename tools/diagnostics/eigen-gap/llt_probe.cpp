#include <kibo/llt.hpp>
#include "controlled_fixture.hpp"
#include <Eigen/Cholesky>
#include <chrono>
#include <algorithm>
#include <cstdio>
volatile double consumed_llt;
int main(){
 using namespace kibo::linalg;
 const std::size_t n=512;
 const auto fixture=kibo::tests::performance_fixture(2048,n);
 Eigen::MatrixXd h=fixture.matrix.transpose()*fixture.matrix;
 h.diagonal().array()+=1e-3;
 Eigen::Matrix<double,Eigen::Dynamic,Eigen::Dynamic,Eigen::RowMajor> row=h;
 Eigen::VectorXd rhs=h*Eigen::VectorXd::Ones(n),ref(n);
 Eigen::LLT<Eigen::MatrixXd> eigen(n);
#if defined(KIBO_DIAG_LLT_PADDING)
 const std::size_t stride=n+1;
#else
 const std::size_t stride=n;
#endif
 std::vector<double> packed(n*stride),workspace(n),out(n);
 auto input=MatrixView<const double>::checked(std::span<const double>(row.data(),n*n),n,n,n).value();
 auto storage=MatrixView<double>::checked(packed,n,n,stride).value();
 auto work=std::as_writable_bytes(std::span<double>(workspace));
 std::vector<double> ct,et;
 for(int repeat=0;repeat<12;++repeat){
  auto core=[&]{auto t=std::chrono::steady_clock::now();auto f=factorize_llt(input,storage,
#if defined(KIBO_DIAG_LLT_SKIP_SYMMETRY)
 LltOptions{.check_symmetry=false}
#else
 LltOptions{}
#endif
 );
   if(!f||!solve_into(f.value(),std::span<const double>(rhs.data(),n),out,work))return false;
   consumed_llt=out[0];double s=std::chrono::duration<double>(std::chrono::steady_clock::now()-t).count();
   for(double v:out)if(!std::isfinite(v) || std::abs(v-1)>1e-10)return false;if(repeat>=2)ct.push_back(s);return true;};
  auto eig=[&]{auto t=std::chrono::steady_clock::now();eigen.compute(h);ref=eigen.solve(rhs);consumed_llt=ref[0];
   double s=std::chrono::duration<double>(std::chrono::steady_clock::now()-t).count();
   if(!ref.allFinite() || (ref.array()-1).abs().maxCoeff()>1e-10)return false;if(repeat>=2)et.push_back(s);return true;};
  if(repeat%2==0){if(!core()||!eig())return 2;}else if(!eig()||!core())return 2;
 }
 std::sort(ct.begin(),ct.end());std::sort(et.begin(),et.end());
 std::printf("{\"coreSeconds\":%.9g,\"eigenSeconds\":%.9g,\"ratio\":%.9g,\"accuracyPassed\":true}\n",ct[5],et[5],ct[5]/et[5]);
 for(int i=0;i<5;++i) std::printf("[DEBUG-eigen-cause] lltphase%d=%.3f ms\n",i,lltcause::times[i]*1000/12);
 return ct[5]/et[5]>1.1?1:0;
}
