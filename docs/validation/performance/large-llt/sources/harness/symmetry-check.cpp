#include <kibo/llt.hpp>
#include <bit>
#include <cstdint>
#include <cstdio>
#include <array>
#include <algorithm>
int main() {
    using namespace kibo::linalg;
    const auto original=_mm_getcsr();
    std::uint64_t random=0x6b69626f;
    auto next=[&](){random^=random<<13;random^=random>>7;random^=random<<17;return random;};
    const double epsilon=std::numeric_limits<double>::epsilon();
    std::size_t count=0;
    for(unsigned state:{0u,0x2000u,0x4000u,0x6000u,0x8000u,0x40u,0x8040u}) {
        _mm_setcsr((original&~0xe040u)|state);
        for(int sample=0;sample<20000;++sample) {
            auto bits=next()&0x7fefffffffffffffULL;
            const double a=std::bit_cast<double>(bits);
            const auto distance=(sample%5==0?1024ULL:sample%5==1?128ULL:sample%5==2?16ULL:sample%5==3?2ULL:1ULL);
            const double b=sample%7==0?-a:std::bit_cast<double>(std::min(bits+distance,0x7fefffffffffffffULL));
            double scale=std::max(std::abs(a),std::abs(b));
            if(sample%11==0)scale=std::max(scale,std::bit_cast<double>(next()&0x7fefffffffffffffULL));
            if(scale==0)continue;
            for(double tolerance:{0.0,epsilon,8*epsilon,std::nextafter(16*epsilon,0.0),16*epsilon,32*epsilon,0.125,0.999}) {
                std::array<double,64> matrix{};
                for(std::size_t i=0;i<8;++i)matrix[8*i+i]=scale;
                matrix[2*8]=a;matrix[2]=b;
                auto view=MatrixView<const double>::checked(matrix,8,8,8).value();
                const bool reference=a==b || !(std::abs(a/scale-b/scale)>tolerance);
                const bool actual=detail::symmetric_rows_within_tolerance(view,scale,tolerance);
                if(reference!=actual) {
                    _mm_setcsr(original);
                    std::printf("Mismatch csr=%x a=%a b=%a scale=%a tolerance=%a\n",state,a,b,scale,tolerance);
                    return 1;
                }
                ++count;
            }
        }
    }
    _mm_setcsr(original);
    std::printf("Matched scalar normalized contract in %zu exponent/tolerance/rounding/FTZ/DAZ cases\n",count);
}
