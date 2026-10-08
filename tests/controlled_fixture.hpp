#pragma once
#include <Eigen/Core>
#include <bit>
#include <cmath>
#include <cstdint>
#include <vector>

namespace kibo::tests {
using RowMatrix=Eigen::Matrix<double,Eigen::Dynamic,Eigen::Dynamic,Eigen::RowMajor>;
struct Fixture { RowMatrix matrix; Eigen::VectorXd rhs, truth; double condition; };
inline Fixture controlled_fixture(Eigen::Index m,Eigen::Index n,double condition,bool inconsistent,bool deficient=false) {
    std::vector<double> spectrum(static_cast<std::size_t>(n));
    for (Eigen::Index k=0;k<n;++k) spectrum[k]=std::pow(condition,-static_cast<double>(k)/static_cast<double>(n-1));
    if (deficient) spectrum[n-1]=0;
    // FWHT gives H diag(sigma) H entries at (row xor column).
    for (std::size_t width=1;width<static_cast<std::size_t>(n);width*=2)
        for (std::size_t start=0;start<static_cast<std::size_t>(n);start+=2*width)
            for (std::size_t j=0;j<width;++j) {
                const double a=spectrum[start+j],b=spectrum[start+j+width];
                spectrum[start+j]=a+b; spectrum[start+j+width]=a-b;
            }
    Fixture fixture{RowMatrix(m,n),Eigen::VectorXd(m),Eigen::VectorXd(n),condition};
    const double normalization=std::sqrt(static_cast<double>(m*n));
    for (Eigen::Index j=0;j<n;++j) fixture.truth[j]=(j%2 ? -1.0 : 1.0)*(static_cast<double>(j)+1)/static_cast<double>(n);
    for (Eigen::Index i=0;i<m;++i)
        for (Eigen::Index j=0;j<n;++j) fixture.matrix(i,j)=spectrum[(i%n)^j]/normalization;
    fixture.rhs=fixture.matrix*fixture.truth;
    if (inconsistent && m>n)
        for (Eigen::Index i=0;i<m;++i) fixture.rhs[i]+=(static_cast<std::size_t>(i)&static_cast<std::size_t>(n) ? -1.0 : 1.0)*0.01/std::sqrt(static_cast<double>(m));
    return fixture;
}
inline Fixture performance_fixture(Eigen::Index m,Eigen::Index n) {
    Fixture fixture{RowMatrix(m,n),Eigen::VectorXd(m),Eigen::VectorXd(n),0};
    std::uint32_t seed=0x6b69626f;
    for (Eigen::Index i=0;i<m;++i) for (Eigen::Index j=0;j<n;++j) {
        seed^=seed<<13; seed^=seed>>17; seed^=seed<<5;
        fixture.matrix(i,j)=(static_cast<double>(seed)/4294967296.0-0.5)/std::sqrt(static_cast<double>(m));
        if(i==j) fixture.matrix(i,j)+=2;
    }
    fixture.truth.setOnes();
    // Pin summation order so SIMD settings do not change the input RHS bits.
    for(Eigen::Index i=0;i<m;++i) {
        double sum=0;
        for(Eigen::Index j=0;j<n;++j) sum+=fixture.matrix(i,j);
        fixture.rhs[i]=sum;
    }
    return fixture;
}
}
