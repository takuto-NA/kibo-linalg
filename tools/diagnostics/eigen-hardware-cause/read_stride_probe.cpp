#include "affinity.hpp"
#include <algorithm>
#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <vector>
volatile double read_stride_consumed;
__declspec(noinline) double read_panel(const volatile double* base,std::size_t stride,std::size_t rows){
    double a[8]{};
    for(std::size_t row=0;row<rows;++row) {
        const auto p=base+row*stride;
        a[0]+=p[0];a[1]+=p[1];a[2]+=p[2];a[3]+=p[3];
        a[4]+=p[4];a[5]+=p[5];a[6]+=p[6];a[7]+=p[7];
    }
    return a[0]+a[1]+a[2]+a[3]+a[4]+a[5]+a[6]+a[7];
}
int main(int argc,char**argv){
    if(!pin_probe())return 20;
    const int process=argc>1?std::atoi(argv[1]):0;
    constexpr std::size_t maximum=1032,maximum_rows=512;
    std::vector<double> backing(maximum*maximum_rows+8,1.0);
    auto address=(reinterpret_cast<std::uintptr_t>(backing.data())+63)&~std::uintptr_t(63);
    auto base=reinterpret_cast<double*>(address);
    for(auto rows:{4u,8u,12u,16u,24u,32u,64u,128u,256u,512u}) {
        std::vector<std::size_t> strides{512,520,1024,1032};
        if(process%2)std::reverse(strides.begin(),strides.end());
        for(auto stride:strides){
            std::size_t calls=1;std::vector<double> samples;
            for(int sample=-5;sample<30;){
                const auto start=std::chrono::steady_clock::now();
                for(std::size_t call=0;call<calls;++call){
                    const double value=read_panel(base,stride,rows);
                    if(value!=rows*8.0)return 2;read_stride_consumed=value;
                }
                const double seconds=std::chrono::duration<double>(std::chrono::steady_clock::now()-start).count();
                if(seconds<.020){calls*=2;continue;}
                if(sample>=0)samples.push_back(seconds/calls);++sample;
            }
            std::sort(samples.begin(),samples.end());
            std::printf("{\"process\":%d,\"rows\":%u,\"strideDoubles\":%zu,\"seconds\":%.17g,\"samples\":30,\"calls\":%zu,\"accuracyPassed\":true,\"logicalCpu\":0,\"cpuidCoreType\":%u,\"baseAlignment\":%zu,\"containsStoresToPanel\":false}\n",process,rows,stride,(samples[14]+samples[15])/2,calls,probe_core_type(),address%64);
        }
    }
    return 0;
}
