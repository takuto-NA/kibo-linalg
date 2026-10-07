#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdio>
#include <vector>
#include "../solver-locality/affinity.hpp"
extern "C" double scalar_subtract(const double*,const double*,std::size_t,double);
extern "C" double packet_subtract(const double*,const double*,std::size_t,double);
extern "C" double eigen_subtract(const double*,const double*,std::size_t,double);
extern "C" double packet4_subtract(const double*,const double*,std::size_t,double);
extern "C" double scan_two_pass(const double*,const double*,std::size_t,double);
extern "C" double scan_fused(const double*,const double*,std::size_t,double);
using Fn=double(*)(const double*,const double*,std::size_t,double);
volatile double consumed=0;
int main() {
 if(!pin_probe()||probe_core_type()!=64)return 2;
 std::vector<double>a(1024),b(1024);
 for(std::size_t i=0;i<a.size();++i){a[i]=std::sin(double(i)+1)*.01;b[i]=std::cos(double(i)+3)*.01;}
 Fn functions[]={scalar_subtract,packet_subtract,eigen_subtract,packet4_subtract,scan_two_pass,scan_fused};const char* names[]={"scalar","packet","eigen","packet4","scan_two_pass","scan_fused"};
 for(std::size_t n:{8,16,32,128,512,1024}) {
  long double expected=1;for(std::size_t i=0;i<n;++i)expected-=(long double)a[i]*b[i];
  for(int j=0;j<4;++j)if(std::abs(functions[j](a.data(),b.data(),n,1)-expected)>1e-13)return 3;
  if(scan_two_pass(a.data(),nullptr,n,0)!=scan_fused(a.data(),nullptr,n,0))return 4;
  auto measure=[&](Fn f,std::size_t batch){auto start=std::chrono::steady_clock::now();double total=0;for(std::size_t c=0;c<batch;++c)total+=f(a.data(),b.data(),n,1);consumed=total;return std::chrono::duration<double>(std::chrono::steady_clock::now()-start).count();};
  std::size_t batch=1;for(;;){double shortest=1;for(auto f:functions)shortest=std::min(shortest,measure(f,batch));if(shortest>=.03)break;batch*=2;}
  for(int sample=0;sample<15;++sample)for(int offset=0;offset<6;++offset){int which=(offset+sample)%6;double sec=measure(functions[which],batch);std::printf("{\"n\":%zu,\"variant\":\"%s\",\"sample\":%d,\"calls\":%zu,\"seconds\":%.17g,\"batchSeconds\":%.17g}\n",n,names[which],sample,batch,sec/batch,sec);}
 }
}
