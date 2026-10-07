#pragma once
// Diagnosis only. Range/status/output/workspace contracts are not yet public.
struct DoubleDouble { double high=0,low=0; };
inline DoubleDouble add_dd(DoubleDouble a,DoubleDouble b) {
    const double sum=a.high+b.high;
    const double virtual_b=sum-a.high;
    const double error=(a.high-(sum-virtual_b))+(b.high-virtual_b)+a.low+b.low;
    const double high=sum+error;
    return {high,error-(high-sum)};
}
inline DoubleDouble product_dd(double a,double b) {
    const double high=a*b;
    return {high,std::fma(a,b,-high)};
}
inline DoubleDouble product_dd(double a,DoubleDouble b) {
    auto result=product_dd(a,b.high);
    return add_dd(result,{a*b.low,0});
}
template<class Matrix>
std::vector<double> diagnostic_refine(const Matrix& a,const Eigen::VectorXd& b,
                                     const std::vector<double>& r,const std::vector<std::size_t>& permutation,
                                     const std::vector<double>& original,bool dd) {
    const std::size_t m=a.rows(),n=a.cols();
    int exponent=0;std::frexp(a.cwiseAbs().maxCoeff(),&exponent);
    const double multiplier=std::ldexp(1.0,-exponent);
    auto current=original;
    std::vector<DoubleDouble> residual(m);
    std::vector<double> gradient(n),correction(n);
    for(int iteration=0;iteration<2;++iteration) {
        for(std::size_t i=0;i<m;++i) {
            DoubleDouble value{b[i]*multiplier,0};
            for(std::size_t j=0;j<n;++j) {
                if(dd)value=add_dd(value,product_dd(-a(i,j)*multiplier,current[j]));
                else value.high-=a(i,j)*multiplier*current[j];
            }
            residual[i]=value;
        }
        for(std::size_t j=0;j<n;++j) {
            DoubleDouble value;
            for(std::size_t i=0;i<m;++i) {
                if(dd)value=add_dd(value,product_dd(a(i,j)*multiplier,residual[i]));
                else value.high+=a(i,j)*multiplier*residual[i].high;
            }
            gradient[j]=value.high+value.low;
        }
        for(std::size_t i=0;i<n;++i) {
            double value=gradient[permutation[i]];
            for(std::size_t j=0;j<i;++j)value-=r[j*n+i]*multiplier*correction[j];
            correction[i]=value/(r[i*n+i]*multiplier);
        }
        for(std::size_t i=n;i-->0;) {
            double value=correction[i];
            for(std::size_t j=i+1;j<n;++j)value-=r[i*n+j]*multiplier*correction[j];
            correction[i]=value/(r[i*n+i]*multiplier);
        }
        for(std::size_t i=0;i<n;++i)current[permutation[i]]+=correction[i];
    }
    return current;
}
