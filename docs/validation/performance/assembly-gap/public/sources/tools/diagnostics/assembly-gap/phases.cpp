#include <kibo/llt.hpp>
#include <Eigen/Cholesky>
#include "controlled_fixture.hpp"
#include "../solver-locality/affinity.hpp"
#include <algorithm>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <vector>
using namespace kibo::linalg;
volatile double consumed=0;
int main(int argc,char** argv){
 if(!pin_probe()||probe_core_type()!=64)return 2;
 std::size_t n=argc>1?std::atoi(argv[1]):32;int samples=argc>2?std::atoi(argv[2]):15;
 auto f=kibo::tests::performance_fixture(n*4,n);
 Eigen::MatrixXd a=f.matrix.transpose()*f.matrix;a.diagonal().array()+=1e-3;
 Eigen::VectorXd b=f.matrix.transpose()*f.rhs,expected=a.ldlt().solve(b),esolution(n);
 kibo::tests::RowMatrix input=a;
 std::vector<double>storage(n*n),w(n),solution(n);
 auto av=MatrixView<const double>::checked(std::span<const double>(input.data(),input.size()),n,n,n).value();
 auto pv=MatrixView<double>::checked(storage,n,n,n).value();auto ws=std::as_writable_bytes(std::span<double>(w));
 auto factor=factorize_llt(av,pv);if(!factor)return 3;Eigen::LLT<Eigen::MatrixXd> eigen(a);esolution.setZero();
 auto core_factor=[&]{factor=factorize_llt(av,pv);return bool(factor);};
 auto core_solve=[&]{return bool(solve_into(factor.value(),std::span<const double>(b.data(),n),solution,ws));};
 auto eigen_factor=[&]{eigen.compute(a);return eigen.info()==Eigen::Success;};
 auto eigen_solve=[&]{esolution=eigen.solve(b);return esolution.allFinite();};
 auto valid=[&]{return core_solve()&&eigen_solve()&&(Eigen::Map<Eigen::VectorXd>(solution.data(),n)-expected).norm()/expected.norm()<1e-8&&(esolution-expected).norm()/expected.norm()<1e-8;};
 for(int phase=0;phase<3;++phase){
  auto core=[&]{if(phase!=1&&!core_factor())return false;if(phase!=0&&!core_solve())return false;consumed=storage[0]+solution[0];return true;};
  auto ref=[&]{if(phase!=1&&!eigen_factor())return false;if(phase!=0&&!eigen_solve())return false;consumed=eigen.matrixLLT()(0,0)+esolution[0];return true;};
  auto timed=[&](auto& fn,std::size_t count){auto start=std::chrono::steady_clock::now();for(std::size_t i=0;i<count;++i)if(!fn())return -1.0;return std::chrono::duration<double>(std::chrono::steady_clock::now()-start).count();};
  if(!core()||!ref()||!valid())return 4;for(int i=0;i<5;++i){core();ref();}
  std::size_t batch=1;for(;;){auto c=timed(core,batch),e=timed(ref,batch);if(c<0||e<0)return 5;if(std::min(c,e)>=.03)break;batch*=2;}
  for(int sample=0;sample<samples;++sample){double c,e;if(sample%2){e=timed(ref,batch);c=timed(core,batch);}else{c=timed(core,batch);e=timed(ref,batch);}if(c<0||e<0||!valid())return 6;
  std::printf("{\"phase\":%d,\"n\":%zu,\"sample\":%d,\"calls\":%zu,\"core\":%.17g,\"eigen\":%.17g,\"minBatch\":%.17g}\n",phase,n,sample,batch,c/batch,e/batch,std::min(c,e));}
 }
}
