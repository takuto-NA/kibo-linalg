#include <kibo/qr.hpp>
#include <vector>
#include <cstdio>
#include <cstdlib>
int main() {
    for(std::size_t n: {8,9,15,16,17,31,32,33,64,65})
        for(std::size_t q: {1,2,3,4,5,7,8,31,63,64}) {
            const auto m=q*n;
            std::vector<double> packed(m*n+2,777),work(2*n+2,888);
            for(std::size_t j=0;j<n;++j)for(std::size_t i=0;i<m;++i)
                packed[1+j*m+i]=double(i*n+j);
            kibo::linalg::detail::qr_restore_row_blocks(packed.data()+1,m,n,
                std::span<double>{work}.subspan(1,2*n));
            for(std::size_t i=0;i<m*n;++i)if(packed[i+1]!=double(i)) {
                std::printf("failed n%zu q%zu index%zu value%.0f\n",n,q,i,packed[i+1]);return 1;
            }
            if(packed.front()!=777 || packed.back()!=777 || work.front()!=888 || work.back()!=888)return 2;
        }
    std::puts("100 row restoration shapes and exact workspace sentinels passed");
}
