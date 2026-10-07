??$unblocked@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@@?$llt_inplace@N$00@internal@Eigen@@SA_JAEAV?$Matrix@N$0?0$0?0$0A@$0?0$0?0@2@@Z PROC ; Eigen::internal::llt_inplace<double,1>::unblocked<Eigen::Matrix<double,-1,-1,0,-1,-1> >, COMDAT

; 286  :   static Index unblocked(MatrixType& mat) {

$LN796:
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
	lea	rbp, QWORD PTR [rsp-88]
	sub	rsp, 344				; 00000158H
	movaps	XMMWORD PTR [rax-88], xmm6

; 291  :     for (Index k = 0; k < size; ++k) {

	xor	edi, edi
	movaps	XMMWORD PTR [rax-104], xmm7
	mov	r10, rcx
	movaps	XMMWORD PTR [rax-120], xmm8
	movaps	XMMWORD PTR [rax-136], xmm9
	mov	rax, QWORD PTR [rcx+8]
	mov	QWORD PTR size$1$[rbp-256], rax
	test	rax, rax
	jle	$LN3@unblocked
	movdqa	xmm7, XMMWORD PTR __xmm@00000000000000010000000000000000
	xorps	xmm9, xmm9
	movsd	xmm8, QWORD PTR __real@bff0000000000000
$LL4@unblocked:

; 292  :       Index rs = size - k - 1;  // remaining size
; 293  : 
; 294  :       Block<MatrixType, Dynamic, 1> A21(mat, k + 1, k, rs, 1);

	mov	rcx, QWORD PTR [r10]
	lea	r8, QWORD PTR [rdi+1]
	mov	r14, rax
	mov	QWORD PTR startRow$1$[rbp-256], r8
	sub	r14, rdi
	lea	rsi, QWORD PTR [r14-1]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	test	rsi, rsi
	je	SHORT $LN16@unblocked

; 319  :     return base != nullptr ? base + offset : nullptr;

	test	rcx, rcx
	je	SHORT $LN16@unblocked

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	mov	rax, rdi
	imul	rax, QWORD PTR [r10+8]

; 319  :     return base != nullptr ? base + offset : nullptr;

	add	rax, r8
	lea	rbx, QWORD PTR [rcx+rax*8]
	jmp	SHORT $LN21@unblocked
$LN16@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MapBase.h

; 154  :       : m_data(dataPtr), m_rows(rows), m_cols(cols) {

	xor	ebx, ebx
$LN21@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 413  :     m_outerStride =

	mov	rdx, QWORD PTR [r10+8]
	mov	QWORD PTR A21$7[rbp-208], rdx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MapBase.h

; 154  :       : m_data(dataPtr), m_rows(rows), m_cols(cols) {

	mov	QWORD PTR A21$7[rbp-256], rbx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	QWORD PTR A21$7[rbp-248], rsi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 370  :         m_xpr(xpr),

	mov	QWORD PTR A21$7[rbp-232], r10
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	QWORD PTR A21$7[rbp-224], r8
	mov	QWORD PTR A21$7[rbp-216], rdi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	test	rdi, rdi
	je	SHORT $LN49@unblocked

; 319  :     return base != nullptr ? base + offset : nullptr;

	test	rcx, rcx
	je	SHORT $LN49@unblocked
	lea	r15, QWORD PTR [rcx+rdi*8]
	jmp	SHORT $LN54@unblocked
$LN49@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MapBase.h

; 154  :       : m_data(dataPtr), m_rows(rows), m_cols(cols) {

	xor	r15d, r15d
$LN54@unblocked:
	mov	QWORD PTR A10$6[rsp], r15
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	QWORD PTR A10$6[rsp+16], rdi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 370  :         m_xpr(xpr),

	mov	QWORD PTR A10$6[rsp+24], r10
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	QWORD PTR A10$6[rsp+32], rdi
	movdqu	XMMWORD PTR A10$6[rbp-216], xmm7
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	test	rsi, rsi
	je	SHORT $LN78@unblocked
	test	rdi, rdi
	je	SHORT $LN78@unblocked

; 319  :     return base != nullptr ? base + offset : nullptr;

	test	rcx, rcx
	je	SHORT $LN78@unblocked
	lea	r12, QWORD PTR [rcx+r8*8]
	jmp	SHORT $LN83@unblocked
$LN78@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MapBase.h

; 154  :       : m_data(dataPtr), m_rows(rows), m_cols(cols) {

	xor	r12d, r12d
$LN83@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	QWORD PTR A20$4[rsp+32], r8
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\PlainObjectBase.h

; 176  :       return m_storage.data()[rowId + colId * m_storage.rows()];

	lea	r8, QWORD PTR [rdx*8]
	lea	r13, QWORD PTR [r8+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MapBase.h

; 154  :       : m_data(dataPtr), m_rows(rows), m_cols(cols) {

	mov	QWORD PTR A20$4[rsp], r12
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\PlainObjectBase.h

; 176  :       return m_storage.data()[rowId + colId * m_storage.rows()];

	imul	r13, rdi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	QWORD PTR A20$4[rsp+8], rsi
	mov	QWORD PTR A20$4[rsp+16], rdi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 370  :         m_xpr(xpr),

	mov	QWORD PTR A20$4[rsp+24], r10
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	QWORD PTR A20$4[rsp+40], 0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LLT.h

; 298  :       RealScalar x = numext::real(mat.coeff(k, k));

	movsd	xmm5, QWORD PTR [rcx+r13]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 413  :     m_outerStride =

	mov	QWORD PTR A20$4[rsp+48], rdx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\PlainObjectBase.h

; 176  :       return m_storage.data()[rowId + colId * m_storage.rows()];

	mov	QWORD PTR tv4947[rbp-256], r13
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LLT.h

; 299  :       if (k > 0) x -= A10.squaredNorm();

	test	rdi, rdi
	je	$LN5@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 251  :   EIGEN_DEVICE_FUNC static inline RealScalar run(const Scalar& x) { return x * x; }

	movsd	xmm4, QWORD PTR [r15]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Redux.h

; 490  :   return derived().redux(Eigen::internal::scalar_sum_op<Scalar, Scalar>());

	mov	r11d, 1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 251  :   EIGEN_DEVICE_FUNC static inline RealScalar run(const Scalar& x) { return x * x; }

	mulsd	xmm4, xmm4
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Redux.h

; 245  :     for (Index k = 1; k < xpr.size(); ++k) res = func(res, eval.coeff(k));

	cmp	rdi, r11
	jbe	$LN643@unblocked
	lea	rax, QWORD PTR [rdi-1]
	cmp	rax, 4
	jl	SHORT $LN710@unblocked
	lea	rax, QWORD PTR [rdx+rdx*2]
	mov	r10, rdx
	lea	rcx, QWORD PTR [r15+rax*8]
	neg	r10
	lea	rax, QWORD PTR [rdi-5]
	mov	r13, rdx
	mov	r9, rdx
	shr	rax, 2
	shl	r13, 5
	neg	r9
	add	r10, r10
	inc	rax
	lea	r11, QWORD PTR [rax*4+1]
	npad	9
$LL645@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 251  :   EIGEN_DEVICE_FUNC static inline RealScalar run(const Scalar& x) { return x * x; }

	movsd	xmm0, QWORD PTR [rcx+r10*8]
	movsd	xmm1, QWORD PTR [rcx+r9*8]
	movsd	xmm2, QWORD PTR [rcx]
	movsd	xmm3, QWORD PTR [rcx+r8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Redux.h

; 245  :     for (Index k = 1; k < xpr.size(); ++k) res = func(res, eval.coeff(k));

	add	rcx, r13
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
	jne	SHORT $LL645@unblocked
	cmp	r11, rdi
	jge	SHORT $LN643@unblocked
$LN710@unblocked:
	imul	rdx, r11
	mov	rcx, rdi
	sub	rcx, r11
	lea	rax, QWORD PTR [r15+rdx*8]
$LC166@unblocked:
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
	jne	SHORT $LC166@unblocked
$LN643@unblocked:
	mov	r13, QWORD PTR tv4947[rbp-256]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Dot.h

; 25   :     return numext::real(result) + numext::imag(result);

	addsd	xmm4, xmm9
	mov	r10, QWORD PTR mat$[rbp-256]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LLT.h

; 299  :       if (k > 0) x -= A10.squaredNorm();

	subsd	xmm5, xmm4
$LN5@unblocked:

; 300  :       if (x <= RealScalar(0)) return k;

	comisd	xmm9, xmm5
	jae	$LN606@unblocked

; 301  :       mat.coeffRef(k, k) = x = sqrt(x);

	xorps	xmm0, xmm0
	ucomisd	xmm0, xmm5
	ja	SHORT $LN727@unblocked
	xorps	xmm6, xmm6
	sqrtsd	xmm6, xmm5
	jmp	SHORT $LN728@unblocked
$LN727@unblocked:
	movaps	xmm0, xmm5
	call	sqrt
	mov	r10, QWORD PTR mat$[rbp-256]
	movaps	xmm6, xmm0
$LN728@unblocked:
	mov	rax, QWORD PTR [r10]
	movsd	QWORD PTR [rax+r13], xmm6

; 302  :       if (k > 0 && rs > 0) A21.noalias() -= A20 * A10.adjoint();

	test	rdi, rdi
	je	$LN239@unblocked
	test	rsi, rsi
	jle	$LN2@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\ProductEvaluators.h

; 361  :     scaleAndAddTo(dst, lhs, rhs, Scalar(-1));

	movsd	QWORD PTR $T9[rbp-256], xmm8

; 384  :     if (lhs.rows() == 1 && rhs.cols() == 1) {

	cmp	rsi, 1
	jne	$LN240@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movsd	xmm2, QWORD PTR [r12]
	mov	rcx, rsi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	r9, QWORD PTR [r10+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	mulsd	xmm2, QWORD PTR [r15]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\InnerProduct.h

; 121  :     for (Index k = 1; k < size; k++) {

	cmp	rdi, rcx
	jbe	$LN646@unblocked
	lea	rax, QWORD PTR [rdi-1]
	cmp	rax, 4
	jl	$LC373@unblocked
	lea	rax, QWORD PTR [r9+r9*2]
	mov	r11, r9
	lea	rdx, QWORD PTR [r12+rax*8]
	neg	r11
	lea	r8, QWORD PTR [r15+rax*8]
	mov	r13, r9
	lea	rax, QWORD PTR [rdi-5]
	shl	r13, 5
	mov	r10, r9
	shr	rax, 2
	neg	r10
	add	r11, r11
	inc	rax
	lea	rcx, QWORD PTR [rax*4+1]
	npad	7
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\CoreEvaluators.h

; 1256 :     return m_data[index * m_innerStride.value()];

$LL648@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 1003 :     return x * y + z;

	movsd	xmm1, QWORD PTR [rdx+r11*8]
	mulsd	xmm1, QWORD PTR [r8+r11*8]
	movsd	xmm0, QWORD PTR [rdx+r10*8]
	mulsd	xmm0, QWORD PTR [r8+r10*8]
	addsd	xmm2, xmm1
	movsd	xmm1, QWORD PTR [rdx]
	mulsd	xmm1, QWORD PTR [r8]
	addsd	xmm2, xmm0
	movsd	xmm0, QWORD PTR [r8+r9*8]
	mulsd	xmm0, QWORD PTR [rdx+r9*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\InnerProduct.h

; 122  :       result = eval.coeff(result, k);

	add	r8, r13
	add	rdx, r13
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 1003 :     return x * y + z;

	addsd	xmm2, xmm1
	addsd	xmm2, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\InnerProduct.h

; 122  :       result = eval.coeff(result, k);

	sub	rax, 1
	jne	SHORT $LL648@unblocked

; 121  :     for (Index k = 1; k < size; k++) {

	cmp	rcx, rdi
	jge	SHORT $LN646@unblocked
$LC373@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\CoreEvaluators.h

; 1256 :     return m_data[index * m_innerStride.value()];

	mov	rax, rcx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\InnerProduct.h

; 121  :     for (Index k = 1; k < size; k++) {

	inc	rcx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\CoreEvaluators.h

; 1256 :     return m_data[index * m_innerStride.value()];

	imul	rax, r9
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 1003 :     return x * y + z;

	movsd	xmm0, QWORD PTR [r15+rax*8]
	mulsd	xmm0, QWORD PTR [r12+rax*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\InnerProduct.h

; 122  :       result = eval.coeff(result, k);

	addsd	xmm2, xmm0
	cmp	rcx, rdi
	jl	SHORT $LC373@unblocked
$LN646@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\ProductEvaluators.h

; 385  :       dst.coeffRef(0, 0) += alpha * lhs.row(0).conjugate().dot(rhs.col(0));

	mulsd	xmm2, xmm8
	addsd	xmm2, QWORD PTR [rbx]
	movsd	QWORD PTR [rbx], xmm2

; 386  :       return;

	jmp	SHORT $LN793@unblocked
$LN240@unblocked:

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
	movsd	xmm1, QWORD PTR A20$4[rsp+48]
	movsd	QWORD PTR actual_lhs$8[rbp-208], xmm1
	movups	xmm1, XMMWORD PTR A10$6[rsp+16]
	movups	XMMWORD PTR actual_lhs$8[rbp-224], xmm0
	movups	xmm0, XMMWORD PTR A10$6[rsp]
	movups	XMMWORD PTR actual_rhs$5[rsp+16], xmm1
	movups	XMMWORD PTR actual_rhs$5[rsp], xmm0
	movups	xmm0, XMMWORD PTR A10$6[rsp+32]
	movaps	xmm1, xmm7
	unpckhpd xmm1, xmm7
	movups	XMMWORD PTR actual_rhs$5[rsp+32], xmm0
	movsd	QWORD PTR actual_rhs$5[rsp+48], xmm1
	call	??$run@V?$Block@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@$0?0$0?0$0A@@Eigen@@V?$Transpose@$$CBV?$Block@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@$00$0?0$0A@@Eigen@@@2@V?$Block@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@$0?0$00$0A@@2@@?$gemv_dense_selector@$01$0A@$00@internal@Eigen@@SAXAEBV?$Block@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@$0?0$0?0$0A@@2@AEBV?$Transpose@$$CBV?$Block@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@$00$0?0$0A@@Eigen@@@2@AEAV?$Block@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@$0?0$00$0A@@2@AEBN@Z ; Eigen::internal::gemv_dense_selector<2,0,1>::run<Eigen::Block<Eigen::Matrix<double,-1,-1,0,-1,-1>,-1,-1,0>,Eigen::Transpose<Eigen::Block<Eigen::Matrix<double,-1,-1,0,-1,-1>,1,-1,0> const >,Eigen::Block<Eigen::Matrix<double,-1,-1,0,-1,-1>,-1,1,0> >
$LN793@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LLT.h

; 303  :       if (rs > 0) A21 /= x;

	mov	r10, QWORD PTR mat$[rbp-256]
$LN239@unblocked:
	test	rsi, rsi
	jle	$LN2@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\Memory.h

; 555  :   } else if ((std::uintptr_t(array) & (sizeof(Scalar) - 1)) || (Alignment % ScalarSize) != 0) {

	mov	rdx, rsi
	test	bl, 7
	jne	SHORT $LN534@unblocked

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
	jle	$LN649@unblocked
	jmp	SHORT $LN709@unblocked
$LN534@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\Memory.h

; 558  :     return size;

	mov	rcx, rsi
	xor	r8d, r8d
$LN709@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	cmp	rdx, 8
	jb	SHORT $LN708@unblocked
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
	npad	2
$LL541@unblocked:
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
	jl	SHORT $LL541@unblocked
	cmp	r8, rdx
	jge	$LN649@unblocked
$LN708@unblocked:
	mov	rax, rdx
	sub	rax, r8
	cmp	rax, 4
	jl	SHORT $LL748@unblocked
	lea	rax, QWORD PTR [r8+2]
	mov	r9, rdx
	sub	r9, r8
	lea	rax, QWORD PTR [rbx+rax*8]
	sub	r9, 4
	shr	r9, 2
	inc	r9
	lea	r8, QWORD PTR [r8+r9*4]
	npad	1
$LL651@unblocked:
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
	jne	SHORT $LL651@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	cmp	r8, rdx
	jge	SHORT $LN649@unblocked
	npad	9
$LL748@unblocked:
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
	jl	SHORT $LL748@unblocked
$LN649@unblocked:

; 494  :     for (Index index = alignedStart; index < alignedEnd; index += PacketSize)

	cmp	rdx, rcx
	jge	SHORT $LN519@unblocked
	movaps	xmm1, xmm6
	unpcklpd xmm1, xmm1
	npad	12
$LL520@unblocked:
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
	jl	SHORT $LL520@unblocked
$LN519@unblocked:

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	mov	rax, rsi
	sub	rax, rcx
	cmp	rcx, rsi
	jge	$LN2@unblocked
	cmp	rax, 8
	jb	SHORT $LN706@unblocked
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
$LL580@unblocked:
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
	jl	SHORT $LL580@unblocked
	cmp	rcx, rsi
	jge	$LN2@unblocked
$LN706@unblocked:
	mov	rax, rsi
	sub	rax, rcx
	cmp	rax, 4
	jl	SHORT $LL752@unblocked
	sub	r14, rcx
	lea	rax, QWORD PTR [rcx+2]
	sub	r14, 5
	lea	rax, QWORD PTR [rbx+rax*8]
	shr	r14, 2
	inc	r14
	lea	rcx, QWORD PTR [rcx+r14*4]
	npad	4
$LL654@unblocked:
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
	jne	SHORT $LL654@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	cmp	rcx, rsi
	jge	SHORT $LN2@unblocked
	npad	9
$LL752@unblocked:
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
	jl	SHORT $LL752@unblocked
$LN2@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LLT.h

; 291  :     for (Index k = 0; k < size; ++k) {

	mov	rdi, QWORD PTR startRow$1$[rbp-256]
	mov	rax, QWORD PTR size$1$[rbp-256]
	cmp	rdi, rax
	jl	$LL4@unblocked
$LN3@unblocked:

; 304  :     }
; 305  :     return -1;

	mov	rax, -1
$LN1@unblocked:

; 306  :   }

	lea	r11, QWORD PTR [rsp+344]
	movaps	xmm6, XMMWORD PTR [r11-24]
	movaps	xmm7, XMMWORD PTR [r11-40]
	movaps	xmm8, XMMWORD PTR [r11-56]
	movaps	xmm9, XMMWORD PTR [r11-72]
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
$LN606@unblocked:

; 300  :       if (x <= RealScalar(0)) return k;

	mov	rax, rdi
	jmp	SHORT $LN1@unblocked
??$unblocked@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@@?$llt_inplace@N$00@internal@Eigen@@SA_JAEAV?$Matrix@N$0?0$0?0$0A@$0?0$0?0@2@@Z ENDP ; Eigen::internal::llt_inplace<double,1>::unblocked<Eigen::Matrix<double,-1,-1,0,-1,-1> >