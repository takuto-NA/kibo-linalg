??$unblocked@V?$Block@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@$0?0$0?0$0A@@Eigen@@@?$llt_inplace@N$00@internal@Eigen@@SA_JAEAV?$Block@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@$0?0$0?0$0A@@2@@Z PROC ; Eigen::internal::llt_inplace<double,1>::unblocked<Eigen::Block<Eigen::Matrix<double,-1,-1,0,-1,-1>,-1,-1,0> >, COMDAT

; 286  :   static Index unblocked(MatrixType& mat) {

$LN878:
	mov	rax, rsp
	mov	QWORD PTR [rax+8], rcx
	push	rbp
	push	rbx
	push	rsi
	push	rdi
	push	r12
	push	r13
	push	r14
	push	r15
	lea	rbp, QWORD PTR [rax-392]
	sub	rsp, 584				; 00000248H
	movaps	XMMWORD PTR [rax-88], xmm6

; 291  :     for (Index k = 0; k < size; ++k) {

	xor	r11d, r11d
	movaps	XMMWORD PTR [rax-104], xmm7
	mov	r13, rcx
	movaps	XMMWORD PTR [rax-120], xmm8
	mov	edi, r11d
	mov	rax, QWORD PTR [rcx+8]
	mov	QWORD PTR size$1$[rsp], rax
	mov	QWORD PTR k$1$[rbp-256], r11
	test	rax, rax
	jle	$LN3@unblocked
	movsd	xmm7, QWORD PTR __real@bff0000000000000
	lea	r9, QWORD PTR [rcx+24]
	mov	QWORD PTR tv4964[rbp-256], r9
	mov	r10, r9
	mov	QWORD PTR tv5008[rsp], r9
	xorps	xmm8, xmm8
	npad	1
$LL4@unblocked:

; 292  :       Index rs = size - k - 1;  // remaining size
; 293  : 
; 294  :       Block<MatrixType, Dynamic, 1> A21(mat, k + 1, k, rs, 1);

	mov	rdx, QWORD PTR [r13]
	lea	r8, QWORD PTR [rdi+1]
	mov	r14, rax
	sub	r14, rdi
	lea	rsi, QWORD PTR [r14-1]
	mov	QWORD PTR rs$1$[rsp], rsi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	test	rsi, rsi
	je	SHORT $LN16@unblocked

; 319  :     return base != nullptr ? base + offset : nullptr;

	test	rdx, rdx
	je	SHORT $LN16@unblocked

; 389  :     return internal::traits<BlockType>::HasSameStorageOrderAsXprType ? m_xpr.outerStride() : m_xpr.innerStride();

	mov	rax, QWORD PTR [r10]
	mov	rcx, rdi

; 319  :     return base != nullptr ? base + offset : nullptr;

	mov	r9, r10
	mov	QWORD PTR tv4964[rbp-256], r10

; 389  :     return internal::traits<BlockType>::HasSameStorageOrderAsXprType ? m_xpr.outerStride() : m_xpr.innerStride();

	imul	rcx, QWORD PTR [rax+8]

; 319  :     return base != nullptr ? base + offset : nullptr;

	add	rcx, r8
	lea	rbx, QWORD PTR [rdx+rcx*8]
	jmp	SHORT $LN21@unblocked
$LN16@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MapBase.h

; 154  :       : m_data(dataPtr), m_rows(rows), m_cols(cols) {

	mov	rbx, r11
$LN21@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 413  :     m_outerStride =

	mov	rax, QWORD PTR [r13+24]

; 370  :         m_xpr(xpr),

	movsd	xmm1, QWORD PTR [r13+48]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MapBase.h

; 154  :       : m_data(dataPtr), m_rows(rows), m_cols(cols) {

	mov	QWORD PTR A21$7[rbp-256], rbx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	QWORD PTR A21$7[rbp-248], rsi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 413  :     m_outerStride =

	mov	rcx, QWORD PTR [rax+8]

; 370  :         m_xpr(xpr),

	movsd	QWORD PTR A21$7[rbp-184], xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	QWORD PTR A21$7[rbp-176], r8
	mov	QWORD PTR A21$7[rbp-168], rdi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 413  :     m_outerStride =

	mov	QWORD PTR A21$7[rbp-160], rcx

; 370  :         m_xpr(xpr),

	movups	xmm0, XMMWORD PTR [r13]
	movups	xmm2, XMMWORD PTR [r13+16]
	movups	XMMWORD PTR A21$7[rbp-232], xmm0
	movups	xmm0, XMMWORD PTR [r13+32]
	movups	XMMWORD PTR A21$7[rbp-216], xmm2
	movups	XMMWORD PTR A21$7[rbp-200], xmm0

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	test	rdi, rdi
	je	SHORT $LN59@unblocked

; 319  :     return base != nullptr ? base + offset : nullptr;

	lea	r15, QWORD PTR [rdx+rdi*8]
	test	rdx, rdx
	jne	SHORT $LN64@unblocked
$LN59@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MapBase.h

; 154  :       : m_data(dataPtr), m_rows(rows), m_cols(cols) {

	mov	r15, r11
$LN64@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 370  :         m_xpr(xpr),

	movsd	xmm1, QWORD PTR [r13+48]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MapBase.h

; 154  :       : m_data(dataPtr), m_rows(rows), m_cols(cols) {

	mov	QWORD PTR A10$6[rbp-256], r15
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	QWORD PTR A10$6[rbp-240], rdi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 370  :         m_xpr(xpr),

	movsd	QWORD PTR A10$6[rbp-184], xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	QWORD PTR A10$6[rbp-176], rdi
	mov	QWORD PTR A10$6[rbp-168], r11
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 373  :     init();

	mov	QWORD PTR A10$6[rbp-160], 1
	movups	xmm0, XMMWORD PTR [r13]
	movups	XMMWORD PTR A10$6[rbp-216], xmm2
	movups	XMMWORD PTR A10$6[rbp-232], xmm0
	movups	xmm0, XMMWORD PTR [r13+32]
	movups	XMMWORD PTR A10$6[rbp-200], xmm0

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	test	rsi, rsi
	je	SHORT $LN93@unblocked
	test	rdi, rdi
	je	SHORT $LN93@unblocked

; 319  :     return base != nullptr ? base + offset : nullptr;

	lea	r12, QWORD PTR [rdx+r8*8]
	test	rdx, rdx
	jne	SHORT $LN98@unblocked
$LN93@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MapBase.h

; 154  :       : m_data(dataPtr), m_rows(rows), m_cols(cols) {

	mov	r12, r11
$LN98@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 370  :         m_xpr(xpr),

	movups	xmm0, XMMWORD PTR [r13]

; 413  :     m_outerStride =

	mov	QWORD PTR A20$1$[rsp], rax
	mov	rax, QWORD PTR [rax+8]
	mov	QWORD PTR A20$4[rbp-160], rax
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MapBase.h

; 101  :     return m_data[colId * colStride() + rowId * rowStride()];

	mov	rax, QWORD PTR [r9]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 370  :         m_xpr(xpr),

	movups	XMMWORD PTR A20$4[rsp+24], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MapBase.h

; 154  :       : m_data(dataPtr), m_rows(rows), m_cols(cols) {

	mov	QWORD PTR A20$4[rsp], r12
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 370  :         m_xpr(xpr),

	movups	xmm0, XMMWORD PTR [r13+32]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MapBase.h

; 101  :     return m_data[colId * colStride() + rowId * rowStride()];

	mov	rax, QWORD PTR [rax+8]
	mov	QWORD PTR tv4963[rbp-256], rax
	inc	rax
	imul	rax, rdi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 370  :         m_xpr(xpr),

	movups	XMMWORD PTR A20$4[rsp+40], xmm2
	movups	XMMWORD PTR A20$4[rbp-200], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	QWORD PTR A20$4[rsp+8], rsi
	mov	QWORD PTR A20$4[rsp+16], rdi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 370  :         m_xpr(xpr),

	movsd	QWORD PTR A20$4[rbp-184], xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	QWORD PTR A20$4[rbp-176], r8
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LLT.h

; 298  :       RealScalar x = numext::real(mat.coeff(k, k));

	movsd	xmm5, QWORD PTR [rdx+rax*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	QWORD PTR A20$4[rbp-168], r11
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LLT.h

; 299  :       if (k > 0) x -= A10.squaredNorm();

	test	rdi, rdi
	je	$LN5@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	rcx, QWORD PTR A10$6[rbp-208]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Redux.h

; 490  :   return derived().redux(Eigen::internal::scalar_sum_op<Scalar, Scalar>());

	mov	r11d, 1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 251  :   EIGEN_DEVICE_FUNC static inline RealScalar run(const Scalar& x) { return x * x; }

	movsd	xmm4, QWORD PTR [r15]
	mulsd	xmm4, xmm4
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	rcx, QWORD PTR [rcx+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Redux.h

; 245  :     for (Index k = 1; k < xpr.size(); ++k) res = func(res, eval.coeff(k));

	cmp	rdi, r11
	jbe	$LN725@unblocked
	lea	rax, QWORD PTR [rdi-1]
	cmp	rax, 4
	jl	$LN787@unblocked
	lea	rax, QWORD PTR [rcx+rcx*2]
	mov	r10, rcx
	lea	rdx, QWORD PTR [r15+rax*8]
	neg	r10
	lea	rax, QWORD PTR [rdi-5]
	mov	r13, rcx
	mov	r9, rcx
	shr	rax, 2
	shl	r13, 5
	neg	r9
	add	r10, r10
	inc	rax
	lea	r11, QWORD PTR [rax*4+1]
$LL727@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 251  :   EIGEN_DEVICE_FUNC static inline RealScalar run(const Scalar& x) { return x * x; }

	movsd	xmm0, QWORD PTR [rdx+r10*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 41   :     return a + b;

	lea	r8, QWORD PTR [rcx*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 251  :   EIGEN_DEVICE_FUNC static inline RealScalar run(const Scalar& x) { return x * x; }

	movsd	xmm1, QWORD PTR [rdx+r9*8]
	movsd	xmm2, QWORD PTR [rdx]
	movsd	xmm3, QWORD PTR [r8+rdx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Redux.h

; 245  :     for (Index k = 1; k < xpr.size(); ++k) res = func(res, eval.coeff(k));

	add	rdx, r13
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 251  :   EIGEN_DEVICE_FUNC static inline RealScalar run(const Scalar& x) { return x * x; }

	mulsd	xmm0, xmm0
	mulsd	xmm1, xmm1
	mulsd	xmm2, xmm2
	mulsd	xmm3, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 41   :     return a + b;

	addsd	xmm4, xmm0
	addsd	xmm4, xmm1
	addsd	xmm4, xmm2
	addsd	xmm4, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Redux.h

; 245  :     for (Index k = 1; k < xpr.size(); ++k) res = func(res, eval.coeff(k));

	sub	rax, 1
	jne	SHORT $LL727@unblocked
	mov	r13, QWORD PTR mat$[rbp-256]
	jmp	SHORT $LC726@unblocked
$LN787@unblocked:
	lea	r8, QWORD PTR [rcx*8]
$LC726@unblocked:
	cmp	r11, rdi
	jge	SHORT $LN725@unblocked
	imul	rcx, r11
	lea	rax, QWORD PTR [r15+rcx*8]
	mov	rcx, rdi
	sub	rcx, r11
$LC207@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 251  :   EIGEN_DEVICE_FUNC static inline RealScalar run(const Scalar& x) { return x * x; }

	movsd	xmm0, QWORD PTR [rax]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Redux.h

; 245  :     for (Index k = 1; k < xpr.size(); ++k) res = func(res, eval.coeff(k));

	add	rax, r8
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 251  :   EIGEN_DEVICE_FUNC static inline RealScalar run(const Scalar& x) { return x * x; }

	mulsd	xmm0, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Redux.h

; 245  :     for (Index k = 1; k < xpr.size(); ++k) res = func(res, eval.coeff(k));

	addsd	xmm4, xmm0
	sub	rcx, 1
	jne	SHORT $LC207@unblocked
$LN725@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Dot.h

; 25   :     return numext::real(result) + numext::imag(result);

	addsd	xmm4, xmm8
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LLT.h

; 299  :       if (k > 0) x -= A10.squaredNorm();

	subsd	xmm5, xmm4
$LN5@unblocked:

; 300  :       if (x <= RealScalar(0)) return k;

	comisd	xmm8, xmm5
	jae	$LN688@unblocked

; 301  :       mat.coeffRef(k, k) = x = sqrt(x);

	xorps	xmm0, xmm0
	ucomisd	xmm0, xmm5
	ja	SHORT $LN809@unblocked
	xorps	xmm6, xmm6
	sqrtsd	xmm6, xmm5
	jmp	SHORT $LN810@unblocked
$LN809@unblocked:
	movaps	xmm0, xmm5
	call	sqrt
	movaps	xmm6, xmm0
$LN810@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MapBase.h

; 242  :     return this->m_data[col * colStride() + row * rowStride()];

	mov	rcx, QWORD PTR tv4963[rbp-256]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LLT.h

; 301  :       mat.coeffRef(k, k) = x = sqrt(x);

	mov	rax, QWORD PTR [r13]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MapBase.h

; 242  :     return this->m_data[col * colStride() + row * rowStride()];

	inc	rcx
	imul	rcx, rdi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LLT.h

; 301  :       mat.coeffRef(k, k) = x = sqrt(x);

	movsd	QWORD PTR [rax+rcx*8], xmm6

; 302  :       if (k > 0 && rs > 0) A21.noalias() -= A20 * A10.adjoint();

	test	rdi, rdi
	je	$LN291@unblocked
	test	rsi, rsi
	jle	$LN2@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\ProductEvaluators.h

; 361  :     scaleAndAddTo(dst, lhs, rhs, Scalar(-1));

	movsd	QWORD PTR $T9[rbp-256], xmm7

; 384  :     if (lhs.rows() == 1 && rhs.cols() == 1) {

	cmp	rsi, 1
	jne	$LN292@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	r9, QWORD PTR A20$1$[rsp]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	mov	rdx, rsi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	rax, QWORD PTR A10$6[rbp-208]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movsd	xmm2, QWORD PTR [r15]
	mulsd	xmm2, QWORD PTR [r12]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	r9, QWORD PTR [r9+8]
	mov	r10, QWORD PTR [rax+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\InnerProduct.h

; 121  :     for (Index k = 1; k < size; k++) {

	cmp	rdi, rdx
	jbe	$LN728@unblocked
	lea	rax, QWORD PTR [rdi-1]
	cmp	rax, 4
	jl	$LC729@unblocked
	mov	rax, r9
	mov	r11, r10
	shl	rax, 5
	mov	r13, r9
	mov	QWORD PTR tv4940[rsp], rax
	neg	r11
	mov	rax, r10
	neg	r13
	shl	rax, 5
	mov	QWORD PTR tv4939[rsp], rax
	lea	rax, QWORD PTR [r9+r9*2]
	lea	rcx, QWORD PTR [r12+rax*8]
	lea	rax, QWORD PTR [r10+r10*2]
	lea	r8, QWORD PTR [r15+rax*8]
	mov	rax, r10
	neg	rax
	shl	rax, 4
	mov	QWORD PTR tv4983[rbp-256], rax
	mov	rax, r9
	mov	rsi, QWORD PTR tv4983[rbp-256]
	neg	rax
	shl	rax, 4
	mov	QWORD PTR tv4981[rsp], rax
	lea	rax, QWORD PTR [rdi-5]
	mov	rdi, QWORD PTR tv4981[rsp]
	shr	rax, 2
	inc	rax
	lea	rdx, QWORD PTR [rax*4+1]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\CoreEvaluators.h

; 1256 :     return m_data[index * m_innerStride.value()];

$LL730@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 1003 :     return x * y + z;

	movsd	xmm1, QWORD PTR [rdi+rcx]
	mulsd	xmm1, QWORD PTR [rsi+r8]
	movsd	xmm0, QWORD PTR [r8+r11*8]
	mulsd	xmm0, QWORD PTR [rcx+r13*8]
	addsd	xmm2, xmm1
	movsd	xmm1, QWORD PTR [rcx]
	mulsd	xmm1, QWORD PTR [r8]
	addsd	xmm2, xmm0
	movsd	xmm0, QWORD PTR [rcx+r9*8]
	mulsd	xmm0, QWORD PTR [r8+r10*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\InnerProduct.h

; 122  :       result = eval.coeff(result, k);

	add	r8, QWORD PTR tv4939[rsp]
	add	rcx, QWORD PTR tv4940[rsp]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 1003 :     return x * y + z;

	addsd	xmm2, xmm1
	addsd	xmm2, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\InnerProduct.h

; 122  :       result = eval.coeff(result, k);

	sub	rax, 1
	jne	SHORT $LL730@unblocked

; 121  :     for (Index k = 1; k < size; k++) {

	mov	rdi, QWORD PTR k$1$[rbp-256]
	mov	rsi, QWORD PTR rs$1$[rsp]
	cmp	rdx, rdi
	jge	SHORT $LN728@unblocked
$LC729@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\CoreEvaluators.h

; 1256 :     return m_data[index * m_innerStride.value()];

	mov	rcx, rdx
	mov	rax, rdx
	imul	rcx, r10
	imul	rax, r9
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 1003 :     return x * y + z;

	movsd	xmm0, QWORD PTR [r15+rcx*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\InnerProduct.h

; 121  :     for (Index k = 1; k < size; k++) {

	inc	rdx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 1003 :     return x * y + z;

	mulsd	xmm0, QWORD PTR [r12+rax*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\InnerProduct.h

; 122  :       result = eval.coeff(result, k);

	addsd	xmm2, xmm0
	cmp	rdx, rdi
	jl	SHORT $LC729@unblocked
$LN728@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\ProductEvaluators.h

; 386  :       return;

	mov	r13, QWORD PTR mat$[rbp-256]
	mulsd	xmm2, xmm7
	addsd	xmm2, QWORD PTR [rbx]
	movsd	QWORD PTR [rbx], xmm2
	jmp	$LN291@unblocked
$LN292@unblocked:

; 387  :     }
; 388  :     LhsNested actual_lhs(lhs);

	movups	xmm0, XMMWORD PTR A20$4[rsp]

; 389  :     RhsNested actual_rhs(rhs);
; 390  :     internal::gemv_dense_selector<Side, (int(MatrixType::Flags) & RowMajorBit) ? RowMajor : ColMajor,
; 391  :                                   bool(internal::blas_traits<MatrixType>::HasUsableDirectAccess)>::run(actual_lhs,

	lea	r9, QWORD PTR $T9[rbp-256]
	movups	xmm1, XMMWORD PTR A20$4[rsp+16]
	lea	r8, QWORD PTR A21$7[rbp-256]
	movups	XMMWORD PTR actual_lhs$8[rbp-256], xmm0
	lea	rdx, QWORD PTR actual_rhs$5[rsp]
	movups	xmm0, XMMWORD PTR A20$4[rsp+32]
	lea	rcx, QWORD PTR actual_lhs$8[rbp-256]
	movups	XMMWORD PTR actual_lhs$8[rbp-240], xmm1
	movups	xmm1, XMMWORD PTR A20$4[rbp-208]
	movups	XMMWORD PTR actual_lhs$8[rbp-224], xmm0
	movups	xmm0, XMMWORD PTR A20$4[rbp-192]
	movups	XMMWORD PTR actual_lhs$8[rbp-208], xmm1
	movups	xmm1, XMMWORD PTR A20$4[rbp-176]
	movups	XMMWORD PTR actual_lhs$8[rbp-192], xmm0
	movsd	xmm0, QWORD PTR A20$4[rbp-160]
	movups	XMMWORD PTR actual_lhs$8[rbp-176], xmm1
	movups	xmm1, XMMWORD PTR A10$6[rbp-256]
	movsd	QWORD PTR actual_lhs$8[rbp-160], xmm0
	movups	xmm0, XMMWORD PTR A10$6[rbp-240]
	movups	XMMWORD PTR actual_rhs$5[rsp], xmm1
	movups	xmm1, XMMWORD PTR A10$6[rbp-224]
	movups	XMMWORD PTR actual_rhs$5[rsp+16], xmm0
	movups	xmm0, XMMWORD PTR A10$6[rbp-208]
	movups	XMMWORD PTR actual_rhs$5[rsp+32], xmm1
	movups	xmm1, XMMWORD PTR A10$6[rbp-192]
	movups	XMMWORD PTR actual_rhs$5[rbp-208], xmm0
	movups	xmm0, XMMWORD PTR A10$6[rbp-176]
	movups	XMMWORD PTR actual_rhs$5[rbp-192], xmm1
	movsd	xmm1, QWORD PTR A10$6[rbp-160]
	movups	XMMWORD PTR actual_rhs$5[rbp-176], xmm0
	movsd	QWORD PTR actual_rhs$5[rbp-160], xmm1
	call	??$run@V?$Block@V?$Block@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@$0?0$0?0$0A@@Eigen@@$0?0$0?0$0A@@Eigen@@V?$Transpose@$$CBV?$Block@V?$Block@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@$0?0$0?0$0A@@Eigen@@$00$0?0$0A@@Eigen@@@2@V?$Block@V?$Block@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@$0?0$0?0$0A@@Eigen@@$0?0$00$0A@@2@@?$gemv_dense_selector@$01$0A@$00@internal@Eigen@@SAXAEBV?$Block@V?$Block@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@$0?0$0?0$0A@@Eigen@@$0?0$0?0$0A@@2@AEBV?$Transpose@$$CBV?$Block@V?$Block@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@$0?0$0?0$0A@@Eigen@@$00$0?0$0A@@Eigen@@@2@AEAV?$Block@V?$Block@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@$0?0$0?0$0A@@Eigen@@$0?0$00$0A@@2@AEBN@Z ; Eigen::internal::gemv_dense_selector<2,0,1>::run<Eigen::Block<Eigen::Block<Eigen::Matrix<double,-1,-1,0,-1,-1>,-1,-1,0>,-1,-1,0>,Eigen::Transpose<Eigen::Block<Eigen::Block<Eigen::Matrix<double,-1,-1,0,-1,-1>,-1,-1,0>,1,-1,0> const >,Eigen::Block<Eigen::Block<Eigen::Matrix<double,-1,-1,0,-1,-1>,-1,-1,0>,-1,1,0> >
$LN291@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LLT.h

; 303  :       if (rs > 0) A21 /= x;

	test	rsi, rsi
	jle	$LN2@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\Memory.h

; 555  :   } else if ((std::uintptr_t(array) & (sizeof(Scalar) - 1)) || (Alignment % ScalarSize) != 0) {

	mov	rdx, rsi
	test	bl, 7
	jne	SHORT $LN616@unblocked

; 559  :   } else {
; 560  :     Index first = (AlignmentSize - (Index((std::uintptr_t(array) / sizeof(Scalar))) & AlignmentMask)) & AlignmentMask;

	mov	rax, rbx
	shr	rax, 3
	neg	rax
	and	eax, 1

; 561  :     return (first < size) ? first : size;

	cmp	rax, rsi
	cmovl	rdx, rax
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 490  :     const Index alignedEnd = alignedStart + numext::round_down(size - alignedStart, PacketSize);

	mov	rax, rsi
	sub	rax, rdx
	xor	r8d, r8d
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 1357 :   return ub * (ua / ub);

	shr	rax, 1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 490  :     const Index alignedEnd = alignedStart + numext::round_down(size - alignedStart, PacketSize);

	lea	rcx, QWORD PTR [rdx+rax*2]

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	test	rdx, rdx
	jle	$LN731@unblocked
	jmp	SHORT $LN792@unblocked
$LN616@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\Memory.h

; 558  :     return size;

	mov	rcx, rsi
	xor	r8d, r8d
$LN792@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	cmp	rdx, 8
	jb	SHORT $LN791@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\CoreEvaluators.h

; 1263 :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE Scalar& coeffRef(Index index) { return m_data[index * m_innerStride.value()]; }

	xor	r8d, r8d
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	lea	rax, QWORD PTR [rbx+32]
	mov	r9, rdx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 489  :     const Index alignedStart = DstIsAligned ? 0 : first_aligned<Alignment>(kernel.dstDataPtr(), size);

	movaps	xmm2, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	and	r9, -8
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 489  :     const Index alignedStart = DstIsAligned ? 0 : first_aligned<Alignment>(kernel.dstDataPtr(), size);

	unpcklpd xmm2, xmm2
	npad	4
$LL623@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movups	xmm0, XMMWORD PTR [rax-32]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	add	r8, 8
	lea	rax, QWORD PTR [rax+64]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	divpd	xmm0, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movups	XMMWORD PTR [rax-96], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movups	xmm0, XMMWORD PTR [rax-80]
	divpd	xmm0, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movups	XMMWORD PTR [rax-80], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movups	xmm1, XMMWORD PTR [rax-64]
	divpd	xmm1, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movups	XMMWORD PTR [rax-64], xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movups	xmm0, XMMWORD PTR [rax-48]
	divpd	xmm0, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movups	XMMWORD PTR [rax-48], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	cmp	r8, r9
	jl	SHORT $LL623@unblocked
	cmp	r8, rdx
	jge	$LN731@unblocked
$LN791@unblocked:
	mov	rax, rdx
	sub	rax, r8
	cmp	rax, 4
	jl	SHORT $LL830@unblocked
	lea	rax, QWORD PTR [r8+2]
	mov	r9, rdx
	sub	r9, r8
	lea	rax, QWORD PTR [rbx+rax*8]
	sub	r9, 4
	shr	r9, 2
	inc	r9
	lea	r8, QWORD PTR [r8+r9*4]
	npad	1
$LL733@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movsd	xmm0, QWORD PTR [rax-16]
	movsd	xmm1, QWORD PTR [rax-8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	lea	rax, QWORD PTR [rax+32]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	divsd	xmm0, xmm6
	divsd	xmm1, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movsd	QWORD PTR [rax-48], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movsd	xmm0, QWORD PTR [rax-32]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movsd	QWORD PTR [rax-40], xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movsd	xmm1, QWORD PTR [rax-24]
	divsd	xmm0, xmm6
	divsd	xmm1, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movsd	QWORD PTR [rax-32], xmm0
	movsd	QWORD PTR [rax-24], xmm1
	sub	r9, 1
	jne	SHORT $LL733@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	cmp	r8, rdx
	jge	SHORT $LN731@unblocked
	npad	9
$LL830@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movsd	xmm0, QWORD PTR [rbx+r8*8]
	divsd	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movsd	QWORD PTR [rbx+r8*8], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	inc	r8
	cmp	r8, rdx
	jl	SHORT $LL830@unblocked
$LN731@unblocked:

; 494  :     for (Index index = alignedStart; index < alignedEnd; index += PacketSize)

	cmp	rdx, rcx
	jge	SHORT $LN601@unblocked
	movaps	xmm1, xmm6
	unpcklpd xmm1, xmm1
	npad	12
$LL602@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 680  :   return _mm_div_pd(a, b);

	movups	xmm0, XMMWORD PTR [rbx+rdx*8]
	divpd	xmm0, xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 65   :     assign_op<DstScalar, DstScalar>().template assignPacket<Alignment, Packet>(

	movups	XMMWORD PTR [rbx+rdx*8], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 494  :     for (Index index = alignedStart; index < alignedEnd; index += PacketSize)

	add	rdx, 2
	cmp	rdx, rcx
	jl	SHORT $LL602@unblocked
$LN601@unblocked:

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	mov	rax, rsi
	sub	rax, rcx
	cmp	rcx, rsi
	jge	$LN2@unblocked
	cmp	rax, 8
	jb	SHORT $LN789@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	cdq
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	movaps	xmm2, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	and	edx, 7
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	unpcklpd xmm2, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	add	rax, rdx
	and	eax, 7
	sub	rax, rdx
	mov	rdx, rsi
	sub	rdx, rax
	lea	rax, QWORD PTR [rcx+4]
	lea	rax, QWORD PTR [rbx+rax*8]
	npad	3
$LL662@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movups	xmm0, XMMWORD PTR [rax-32]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	add	rcx, 8
	lea	rax, QWORD PTR [rax+64]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	divpd	xmm0, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movups	XMMWORD PTR [rax-96], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movups	xmm0, XMMWORD PTR [rax-80]
	divpd	xmm0, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movups	XMMWORD PTR [rax-80], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movups	xmm1, XMMWORD PTR [rax-64]
	divpd	xmm1, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movups	XMMWORD PTR [rax-64], xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movups	xmm0, XMMWORD PTR [rax-48]
	divpd	xmm0, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movups	XMMWORD PTR [rax-48], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	cmp	rcx, rdx
	jl	SHORT $LL662@unblocked
	cmp	rcx, rsi
	jge	$LN2@unblocked
$LN789@unblocked:
	mov	rax, rsi
	sub	rax, rcx
	cmp	rax, 4
	jl	SHORT $LL834@unblocked
	sub	r14, rcx
	lea	rax, QWORD PTR [rcx+2]
	sub	r14, 5
	lea	rax, QWORD PTR [rbx+rax*8]
	shr	r14, 2
	inc	r14
	lea	rcx, QWORD PTR [rcx+r14*4]
	npad	4
$LL736@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movsd	xmm0, QWORD PTR [rax-16]
	movsd	xmm1, QWORD PTR [rax-8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	lea	rax, QWORD PTR [rax+32]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	divsd	xmm0, xmm6
	divsd	xmm1, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movsd	QWORD PTR [rax-48], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movsd	xmm0, QWORD PTR [rax-32]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movsd	QWORD PTR [rax-40], xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movsd	xmm1, QWORD PTR [rax-24]
	divsd	xmm0, xmm6
	divsd	xmm1, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movsd	QWORD PTR [rax-32], xmm0
	movsd	QWORD PTR [rax-24], xmm1
	sub	r14, 1
	jne	SHORT $LL736@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	cmp	rcx, rsi
	jge	SHORT $LN2@unblocked
	npad	9
$LL834@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movsd	xmm0, QWORD PTR [rbx+rcx*8]
	divsd	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movsd	QWORD PTR [rbx+rcx*8], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	inc	rcx
	cmp	rcx, rsi
	jl	SHORT $LL834@unblocked
$LN2@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LLT.h

; 291  :     for (Index k = 0; k < size; ++k) {

	mov	rax, QWORD PTR size$1$[rsp]
	inc	rdi
	mov	r9, QWORD PTR tv4964[rbp-256]
	mov	r11d, 0
	mov	r10, QWORD PTR tv5008[rsp]
	mov	QWORD PTR k$1$[rbp-256], rdi
	cmp	rdi, rax
	jl	$LL4@unblocked
$LN3@unblocked:

; 304  :     }
; 305  :     return -1;

	mov	rax, -1
$LN1@unblocked:

; 306  :   }

	lea	r11, QWORD PTR [rsp+584]
	movaps	xmm6, XMMWORD PTR [r11-24]
	movaps	xmm7, XMMWORD PTR [r11-40]
	movaps	xmm8, XMMWORD PTR [r11-56]
	mov	rsp, r11
	pop	r15
	pop	r14
	pop	r13
	pop	r12
	pop	rdi
	pop	rsi
	pop	rbx
	pop	rbp
	ret	0
$LN688@unblocked:

; 300  :       if (x <= RealScalar(0)) return k;

	mov	rax, rdi
	jmp	SHORT $LN1@unblocked
??$unblocked@V?$Block@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@$0?0$0?0$0A@@Eigen@@@?$llt_inplace@N$00@internal@Eigen@@SA_JAEAV?$Block@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@$0?0$0?0$0A@@2@@Z ENDP ; Eigen::internal::llt_inplace<double,1>::unblocked<Eigen::Block<Eigen::Matrix<double,-1,-1,0,-1,-1>,-1,-1,0> >