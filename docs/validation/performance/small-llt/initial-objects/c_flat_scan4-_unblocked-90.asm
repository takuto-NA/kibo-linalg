??$unblocked@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@V?$Transpositions@$0?0$0?0H@2@V?$Matrix@N$0?0$00$0A@$0?0$00@2@@?$ldlt_inplace@$00@internal@Eigen@@SA_NAEAV?$Matrix@N$0?0$0?0$0A@$0?0$0?0@2@AEAV?$Transpositions@$0?0$0?0H@2@AEAV?$Matrix@N$0?0$00$0A@$0?0$00@2@AEAW4SignMatrix@12@@Z PROC ; Eigen::internal::ldlt_inplace<1>::unblocked<Eigen::Matrix<double,-1,-1,0,-1,-1>,Eigen::Transpositions<-1,-1,int>,Eigen::Matrix<double,-1,1,0,-1,1> >, COMDAT

; 280  :   static bool unblocked(MatrixType& mat, TranspositionType& transpositions, Workspace& temp, SignMatrix& sign) {

$LN2545:
	push	rbp
	push	rsi
	push	r12
	push	r13
	push	r14
	push	r15
	lea	rbp, QWORD PTR [rsp-264]
	sub	rsp, 520				; 00000208H
	mov	rax, QWORD PTR __security_cookie
	xor	rax, rsp
	mov	QWORD PTR __$ArrayPad$[rbp-256], rax

; 281  :     using std::abs;
; 282  :     typedef typename MatrixType::Scalar Scalar;
; 283  :     typedef typename MatrixType::RealScalar RealScalar;
; 284  :     typedef typename TranspositionType::StorageIndex IndexType;
; 285  :     eigen_assert(mat.rows() == mat.cols());
; 286  :     const Index size = mat.rows();

	mov	rsi, QWORD PTR [rcx+8]

; 287  :     bool found_zero_pivot = false;

	xor	al, al

; 288  :     bool ret = true;
; 289  : 
; 290  :     if (size <= 1) {

	xor	r13d, r13d
	mov	QWORD PTR sign$GSCopy$1$[rsp], r9
	mov	QWORD PTR temp$1$[rsp], r8
	mov	r12, r8
	mov	QWORD PTR transpositions$GSCopy$1$[rbp-256], rdx
	mov	r14, rdx
	mov	QWORD PTR A20$2$[rbp-256], rcx
	mov	r15, rcx
	mov	QWORD PTR size$1$[rsp], rsi
	mov	BYTE PTR found_zero_pivot$1$[rsp], al
	mov	BYTE PTR ret$1$[rsp], 1
	cmp	rsi, 1
	jg	SHORT $LN11@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Transpositions.h

; 67   :     for (StorageIndex i = 0; i < indices().size(); ++i) coeffRef(i) = i;

	mov	ecx, r13d
	cmp	QWORD PTR [rdx+8], rcx
	jle	SHORT $LN2065@unblocked
	mov	edx, r13d
	npad	1
$LL2066@unblocked:
	mov	rax, QWORD PTR [r14]
	lea	rdx, QWORD PTR [rdx+4]
	mov	DWORD PTR [rdx+rax-4], ecx
	inc	ecx
	movsxd	rax, ecx
	cmp	rax, QWORD PTR [r14+8]
	jl	SHORT $LL2066@unblocked
$LN2065@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LDLT.h

; 292  :       if (size == 0)

	test	rsi, rsi
	je	SHORT $LN16@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\PlainObjectBase.h

; 176  :       return m_storage.data()[rowId + colId * m_storage.rows()];

	mov	rax, QWORD PTR [r15]
	xorps	xmm1, xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 77   :   EIGEN_DEVICE_FUNC static inline RealScalar run(const Scalar& x) { return x; }

	movsd	xmm0, QWORD PTR [rax]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LDLT.h

; 294  :       else if (numext::real(mat.coeff(0, 0)) > static_cast<RealScalar>(0))

	comisd	xmm0, xmm1
	jbe	SHORT $LN14@unblocked

; 295  :         sign = PositiveSemiDef;

	mov	DWORD PTR [r9], r13d

; 300  :       return true;

	mov	al, 1
	jmp	$LN1@unblocked
$LN14@unblocked:

; 296  :       else if (numext::real(mat.coeff(0, 0)) < static_cast<RealScalar>(0))

	comisd	xmm1, xmm0
	jbe	SHORT $LN16@unblocked

; 297  :         sign = NegativeSemiDef;

	mov	DWORD PTR [r9], 1

; 300  :       return true;

	mov	al, 1
	jmp	$LN1@unblocked
$LN16@unblocked:

; 298  :       else
; 299  :         sign = ZeroSign;

	mov	DWORD PTR [r9], 2

; 300  :       return true;

	mov	al, 1
	jmp	$LN1@unblocked
$LN11@unblocked:
	mov	QWORD PTR [rsp+592], rbx

; 301  :     }
; 302  : 
; 303  :     for (Index k = 0; k < size; ++k) {

	mov	rbx, QWORD PTR $T1[rsp+8]
	mov	QWORD PTR [rsp+512], rdi
	mov	rdi, r13
	movaps	XMMWORD PTR [rsp+496], xmm6
	xorps	xmm6, xmm6
	movaps	XMMWORD PTR [rsp+480], xmm7
	movsd	xmm7, QWORD PTR __real@bff0000000000000
	movaps	XMMWORD PTR [rsp+464], xmm8
	movdqa	xmm8, XMMWORD PTR __xmm@7fffffffffffffff7fffffffffffffff
	mov	QWORD PTR A20$4$[rsp], r13
$LL4@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Diagonal.h

; 82   :     return m_index.value() < 0 ? numext::mini<Index>(m_matrix.cols(), m_matrix.rows() + m_index.value())

	mov	rdx, QWORD PTR [r15+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LDLT.h

; 306  :       mat.diagonal().tail(size - k).cwiseAbs().maxCoeff(&index_of_biggest_in_corner);

	mov	r9, rsi
	sub	r9, rdi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\plugins\BlockMethods.inc

; 1213 :   return typename FixedSegmentReturnType<internal::get_fixed_value<NType>::value>::Type(

	mov	rcx, rdx
	cmp	QWORD PTR [r15+16], rdx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LDLT.h

; 306  :       mat.diagonal().tail(size - k).cwiseAbs().maxCoeff(&index_of_biggest_in_corner);

	mov	QWORD PTR tv13560[rsp], r9
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\plugins\BlockMethods.inc

; 1213 :   return typename FixedSegmentReturnType<internal::get_fixed_value<NType>::value>::Type(

	cmovl	rcx, QWORD PTR [r15+16]
	sub	rcx, r9
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	test	r9, r9
	je	SHORT $LN873@unblocked
	mov	r8, QWORD PTR [r15]

; 319  :     return base != nullptr ? base + offset : nullptr;

	test	r8, r8
	je	SHORT $LN873@unblocked
	lea	rax, QWORD PTR [rdx+1]
	imul	rax, rcx
	lea	rdx, QWORD PTR [r8+rax*8]
	jmp	SHORT $LN878@unblocked
$LN873@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MapBase.h

; 154  :       : m_data(dataPtr), m_rows(rows), m_cols(cols) {

	mov	rdx, r13
$LN878@unblocked:
	mov	QWORD PTR $T25[rbp-256], rdx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\FindCoeff.h

; 459  :   return internal::findCoeff(derived(), func, indexPtr);

	lea	r8, QWORD PTR index_of_biggest_in_corner$21[rsp]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	QWORD PTR $T25[rbp-216], rcx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\FindCoeff.h

; 459  :   return internal::findCoeff(derived(), func, indexPtr);

	lea	rdx, QWORD PTR func$15[rsp]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	QWORD PTR $T25[rbp-248], r9
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\FindCoeff.h

; 459  :   return internal::findCoeff(derived(), func, indexPtr);

	lea	rcx, QWORD PTR $T26[rbp-256]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\CwiseUnaryOp.h

; 61   :       : m_xpr(xpr), m_functor(func) {}

	movups	xmm0, XMMWORD PTR $T25[rbp-256]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 370  :         m_xpr(xpr),

	mov	QWORD PTR $T25[rbp-232], r15
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\CwiseUnaryOp.h

; 61   :       : m_xpr(xpr), m_functor(func) {}

	movups	xmm1, XMMWORD PTR $T25[rbp-240]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 370  :         m_xpr(xpr),

	mov	QWORD PTR $T25[rbp-224], rbx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\CwiseUnaryOp.h

; 61   :       : m_xpr(xpr), m_functor(func) {}

	movups	XMMWORD PTR $T26[rbp-248], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 373  :     init();

	mov	QWORD PTR $T25[rbp-200], r13
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\CwiseUnaryOp.h

; 61   :       : m_xpr(xpr), m_functor(func) {}

	movups	xmm0, XMMWORD PTR $T25[rbp-224]
	movups	XMMWORD PTR $T26[rbp-232], xmm1
	movups	xmm1, XMMWORD PTR $T25[rbp-208]
	movups	XMMWORD PTR $T26[rbp-216], xmm0
	movups	XMMWORD PTR $T26[rbp-200], xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\FindCoeff.h

; 459  :   return internal::findCoeff(derived(), func, indexPtr);

	call	??$findCoeff@V?$CwiseUnaryOp@U?$scalar_abs_op@N@internal@Eigen@@$$CBV?$Block@V?$Diagonal@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@$0A@@Eigen@@$0?0$00$0A@@3@@Eigen@@_JU?$max_coeff_functor@N$0A@$0A@@internal@2@@internal@Eigen@@YANAEBV?$DenseBase@V?$CwiseUnaryOp@U?$scalar_abs_op@N@internal@Eigen@@$$CBV?$Block@V?$Diagonal@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@$0A@@Eigen@@$0?0$00$0A@@3@@Eigen@@@1@AEAU?$max_coeff_functor@N$0A@$0A@@01@PEA_J@Z ; Eigen::internal::findCoeff<Eigen::CwiseUnaryOp<Eigen::internal::scalar_abs_op<double>,Eigen::Block<Eigen::Diagonal<Eigen::Matrix<double,-1,-1,0,-1,-1>,0>,-1,1,0> const >,__int64,Eigen::internal::max_coeff_functor<double,0,0> >
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LDLT.h

; 307  :       index_of_biggest_in_corner += k;

	mov	r10, QWORD PTR index_of_biggest_in_corner$21[rsp]

; 308  : 
; 309  :       transpositions.coeffRef(k) = IndexType(index_of_biggest_in_corner);

	mov	rax, QWORD PTR [r14]
	add	r10, rdi
	mov	QWORD PTR index_of_biggest_in_corner$21[rsp], r10
	mov	DWORD PTR [rax+rdi*4], r10d

; 310  :       if (k != index_of_biggest_in_corner) {

	cmp	rdi, r10
	je	$LN6@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 330  :       : Base((BlockRows == 0 || BlockCols == 0)

	mov	rax, QWORD PTR [r15]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LDLT.h

; 313  :         Index s = size - index_of_biggest_in_corner - 1;  // trailing size after the biggest element

	mov	r8, rsi
	sub	r8, r10
	dec	r8
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 319  :     return base != nullptr ? base + offset : nullptr;

	lea	rcx, QWORD PTR [rax+rdi*8]
	test	rax, rax
	jne	SHORT $LN1476@unblocked
	mov	rcx, r13
$LN1476@unblocked:

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	test	rdi, rdi
	mov	rdx, r13
	cmovne	rdx, rcx

; 319  :     return base != nullptr ? base + offset : nullptr;

	lea	rcx, QWORD PTR [rax+r10*8]

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	mov	QWORD PTR $T18[rsp], rdx

; 319  :     return base != nullptr ? base + offset : nullptr;

	test	rax, rax
	jne	SHORT $LN1396@unblocked
	mov	rcx, r13
$LN1396@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	r12, QWORD PTR [r15+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	test	rdi, rdi
	mov	r11, r13
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 565  :     const Index size = kernel.size();

	mov	rax, r13
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	cmovne	r11, rcx
	mov	QWORD PTR $T17[rsp], r11
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 565  :     const Index size = kernel.size();

	lea	r9, QWORD PTR [r12*8]

; 566  :     for (Index i = 0; i < size; ++i) kernel.assignCoeff(i);

	cmp	rdi, 4
	jl	$LN2340@unblocked

; 813  :                                                                                 const Functor& func) {

	mov	rax, r12
	lea	r14, QWORD PTR [rdi-4]
	shl	rax, 4
	mov	rsi, r12
	neg	rsi
	shr	r14, 2
	add	rdx, rax
	mov	rbx, r12
	shl	rbx, 5
	add	rsi, rsi
	lea	rcx, QWORD PTR [rax+r11]
	mov	r11, r12
	neg	r11
	inc	r14
	lea	rax, QWORD PTR [r14*4]
	mov	QWORD PTR i$1$[rsp], rax
	npad	4

; 566  :     for (Index i = 0; i < size; ++i) kernel.assignCoeff(i);

$LL2206@unblocked:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\utility

; 140  :     _Left    = _STD move(_Right);

	mov	rax, QWORD PTR [rcx+rsi*8]
	movsd	xmm0, QWORD PTR [rdx+rsi*8]
	mov	QWORD PTR [rdx+rsi*8], rax

; 141  :     _Right   = _STD move(_Tmp);

	movsd	QWORD PTR [rcx+rsi*8], xmm0
	mov	rax, QWORD PTR [rcx+r11*8]
	movsd	xmm1, QWORD PTR [rdx+r11*8]
	mov	QWORD PTR [rdx+r11*8], rax
	movsd	QWORD PTR [rcx+r11*8], xmm1
	mov	rax, QWORD PTR [rcx]
	movsd	xmm0, QWORD PTR [rdx]
	mov	QWORD PTR [rdx], rax
	movsd	QWORD PTR [rcx], xmm0
	mov	rax, QWORD PTR [rcx+r9]
	movsd	xmm1, QWORD PTR [rdx+r9]
	mov	QWORD PTR [rdx+r9], rax
	add	rdx, rbx
	movsd	QWORD PTR [rcx+r9], xmm1
	add	rcx, rbx
	sub	r14, 1
	jne	SHORT $LL2206@unblocked
	mov	rbx, QWORD PTR $T1[rsp+8]
	mov	rax, QWORD PTR i$1$[rsp]
	mov	rdx, QWORD PTR $T18[rsp]
	mov	r11, QWORD PTR $T17[rsp]
$LN2340@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 566  :     for (Index i = 0; i < size; ++i) kernel.assignCoeff(i);

	cmp	rax, rdi
	jge	SHORT $LN2204@unblocked
	imul	r12, rax
	lea	rcx, QWORD PTR [r11+r12*8]
	mov	r11, rdi
	sub	r11, rax
	lea	rdx, QWORD PTR [rdx+r12*8]
$LC1913@unblocked:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\utility

; 140  :     _Left    = _STD move(_Right);

	mov	rax, QWORD PTR [rcx]
	movsd	xmm0, QWORD PTR [rdx]
	mov	QWORD PTR [rdx], rax
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 566  :     for (Index i = 0; i < size; ++i) kernel.assignCoeff(i);

	add	rdx, r9
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\utility

; 141  :     _Right   = _STD move(_Tmp);

	movsd	QWORD PTR [rcx], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 566  :     for (Index i = 0; i < size; ++i) kernel.assignCoeff(i);

	add	rcx, r9
	sub	r11, 1
	jne	SHORT $LC1913@unblocked
$LN2204@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 330  :       : Base((BlockRows == 0 || BlockCols == 0)

	mov	rdx, QWORD PTR [r15]
	mov	rcx, QWORD PTR [r15+8]

; 319  :     return base != nullptr ? base + offset : nullptr;

	test	rdx, rdx
	je	SHORT $LN1718@unblocked
	mov	rax, rcx
	imul	rax, rdi
	lea	r9, QWORD PTR [rdx+rax*8]
	jmp	SHORT $LN1719@unblocked
$LN1718@unblocked:
	mov	r9, r13
$LN1719@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\plugins\BlockMethods.inc

; 1213 :   return typename FixedSegmentReturnType<internal::get_fixed_value<NType>::value>::Type(

	mov	rax, rcx
	sub	rax, r8
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	test	r8, r8
	je	SHORT $LN1796@unblocked

; 319  :     return base != nullptr ? base + offset : nullptr;

	test	r9, r9
	lea	r9, QWORD PTR [r9+rax*8]
	jne	SHORT $LN1801@unblocked
$LN1796@unblocked:
	mov	r9, r13
$LN1801@unblocked:
	test	rdx, rdx
	je	SHORT $LN1759@unblocked
	imul	rcx, r10
	lea	r11, QWORD PTR [rdx+rcx*8]
	jmp	SHORT $LN1760@unblocked
$LN1759@unblocked:
	mov	r11, r13
$LN1760@unblocked:

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	test	r8, r8
	je	SHORT $LN1662@unblocked

; 319  :     return base != nullptr ? base + offset : nullptr;

	lea	r12, QWORD PTR [r11+rax*8]
	test	r11, r11
	jne	SHORT $LN1667@unblocked
$LN1662@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\Memory.h

; 555  :   } else if ((std::uintptr_t(array) & (sizeof(Scalar) - 1)) || (Alignment % ScalarSize) != 0) {

	mov	r12, r13
$LN1667@unblocked:
	mov	r11, r8
	test	r9b, 7
	jne	SHORT $LN1597@unblocked

; 556  :     // The array is not aligned to the size of a single scalar, or the requested alignment is not a multiple of the
; 557  :     // scalar size. Consequently, no element of the array is well aligned.
; 558  :     return size;
; 559  :   } else {
; 560  :     Index first = (AlignmentSize - (Index((std::uintptr_t(array) / sizeof(Scalar))) & AlignmentMask)) & AlignmentMask;

	mov	rax, r9
	shr	rax, 3
	neg	rax
	and	eax, 1

; 561  :     return (first < size) ? first : size;

	cmp	rax, r8
	cmovl	r11, rax
$LN1597@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 490  :     const Index alignedEnd = alignedStart + numext::round_down(size - alignedStart, PacketSize);

	mov	rax, r8
	sub	rax, r11
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 1357 :   return ub * (ua / ub);

	shr	rax, 1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 490  :     const Index alignedEnd = alignedStart + numext::round_down(size - alignedStart, PacketSize);

	lea	r14, QWORD PTR [r11+rax*2]

; 349  :     for (Index outer = 0; outer < kernel.outerSize(); ++outer) {

	mov	rax, r13

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	cmp	r11, 4
	jl	$LC2208@unblocked

; 490  :     const Index alignedEnd = alignedStart + numext::round_down(size - alignedStart, PacketSize);

	mov	rdx, r9
	lea	rsi, QWORD PTR [r11-4]
	sub	rdx, r12
	shr	rsi, 2
	inc	rsi
	lea	rcx, QWORD PTR [r12+8]
	lea	rax, QWORD PTR [rsi*4]
	mov	QWORD PTR index$1$[rsp], rax
	npad	7

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

$LL2209@unblocked:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\utility

; 140  :     _Left    = _STD move(_Right);

	mov	rax, QWORD PTR [rcx-8]
	movsd	xmm0, QWORD PTR [rdx+rcx-8]
	mov	QWORD PTR [rdx+rcx-8], rax
	mov	rax, QWORD PTR [rcx]

; 141  :     _Right   = _STD move(_Tmp);

	movsd	QWORD PTR [rcx-8], xmm0
	movsd	xmm0, QWORD PTR [rdx+rcx]
	mov	QWORD PTR [rdx+rcx], rax
	mov	rax, QWORD PTR [rcx+8]
	movsd	QWORD PTR [rcx], xmm0
	movsd	xmm1, QWORD PTR [rdx+rcx+8]
	mov	QWORD PTR [rdx+rcx+8], rax
	mov	rax, QWORD PTR [rcx+16]
	movsd	QWORD PTR [rcx+8], xmm1
	movsd	xmm0, QWORD PTR [rdx+rcx+16]
	mov	QWORD PTR [rdx+rcx+16], rax
	movsd	QWORD PTR [rcx+16], xmm0
	lea	rcx, QWORD PTR [rcx+32]
	sub	rsi, 1
	jne	SHORT $LL2209@unblocked
	mov	rax, QWORD PTR index$1$[rsp]
$LC2208@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	cmp	rax, r11
	jge	SHORT $LN2207@unblocked
	mov	rdx, r9
	lea	rcx, QWORD PTR [r12+rax*8]
	sub	rdx, r12
	mov	rsi, r11
	sub	rsi, rax
$LC2164@unblocked:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\utility

; 140  :     _Left    = _STD move(_Right);

	mov	rax, QWORD PTR [rcx]
	movsd	xmm0, QWORD PTR [rcx+rdx]
	mov	QWORD PTR [rcx+rdx], rax

; 141  :     _Right   = _STD move(_Tmp);

	movsd	QWORD PTR [rcx], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	lea	rcx, QWORD PTR [rcx+8]
	sub	rsi, 1
	jne	SHORT $LC2164@unblocked
$LN2207@unblocked:

; 494  :     for (Index index = alignedStart; index < alignedEnd; index += PacketSize)

	cmp	r11, r14
	jge	SHORT $LN1583@unblocked
	mov	rcx, r14
	lea	rax, QWORD PTR [r9+r11*8]
	sub	rcx, r11
	mov	rdx, r12
	dec	rcx
	sub	rdx, r9
	shr	rcx, 1
	inc	rcx
	npad	8
$LL1584@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\CoreEvaluators.h

; 1284 :     pstoret<Scalar, PacketType, StoreMode>(m_data + index * m_innerStride.value(), x);

	movups	xmm0, XMMWORD PTR [rax]

; 1273 :     return ploadt<PacketType, LoadMode>(m_data + index * m_innerStride.value());

	movups	xmm1, XMMWORD PTR [rax+rdx]

; 1284 :     pstoret<Scalar, PacketType, StoreMode>(m_data + index * m_innerStride.value(), x);

	movups	XMMWORD PTR [rax+rdx], xmm0
	movups	XMMWORD PTR [rax], xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 494  :     for (Index index = alignedStart; index < alignedEnd; index += PacketSize)

	lea	rax, QWORD PTR [rax+16]
	sub	rcx, 1
	jne	SHORT $LL1584@unblocked
$LN1583@unblocked:

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	cmp	r14, r8
	jge	$LN2210@unblocked
	mov	rax, r8
	sub	rax, r14
	cmp	rax, 4
	jl	$LN2352@unblocked
	lea	rcx, QWORD PTR [r14+1]
	mov	r11, r8
	sub	r11, r14
	lea	rcx, QWORD PTR [r12+rcx*8]
	sub	r11, 4
	mov	rdx, r9
	shr	r11, 2
	sub	rdx, r12
	inc	r11
	lea	r14, QWORD PTR [r14+r11*4]
	npad	12
$LL2212@unblocked:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\utility

; 140  :     _Left    = _STD move(_Right);

	mov	rax, QWORD PTR [rcx-8]
	movsd	xmm0, QWORD PTR [rcx+rdx-8]
	mov	QWORD PTR [rcx+rdx-8], rax
	mov	rax, QWORD PTR [rcx]

; 141  :     _Right   = _STD move(_Tmp);

	movsd	QWORD PTR [rcx-8], xmm0
	movsd	xmm0, QWORD PTR [rcx+rdx]
	mov	QWORD PTR [rcx+rdx], rax
	mov	rax, QWORD PTR [rcx+8]
	movsd	QWORD PTR [rcx], xmm0
	movsd	xmm1, QWORD PTR [rcx+rdx+8]
	mov	QWORD PTR [rcx+rdx+8], rax
	mov	rax, QWORD PTR [rcx+16]
	movsd	QWORD PTR [rcx+8], xmm1
	movsd	xmm0, QWORD PTR [rcx+rdx+16]
	mov	QWORD PTR [rcx+rdx+16], rax
	movsd	QWORD PTR [rcx+16], xmm0
	lea	rcx, QWORD PTR [rcx+32]
	sub	r11, 1
	jne	SHORT $LL2212@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	cmp	r14, r8
	jge	SHORT $LN2210@unblocked
$LN2352@unblocked:
	sub	r9, r12
	lea	rcx, QWORD PTR [r12+r14*8]
	sub	r8, r14
$LC2166@unblocked:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\utility

; 140  :     _Left    = _STD move(_Right);

	mov	rax, QWORD PTR [rcx]
	movsd	xmm0, QWORD PTR [rcx+r9]
	mov	QWORD PTR [rcx+r9], rax

; 141  :     _Right   = _STD move(_Tmp);

	movsd	QWORD PTR [rcx], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	lea	rcx, QWORD PTR [rcx+8]
	sub	r8, 1
	jne	SHORT $LC2166@unblocked
$LN2210@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\PlainObjectBase.h

; 195  :       return m_storage.data()[rowId + colId * m_storage.rows()];

	mov	r8, QWORD PTR [r15]
	mov	rax, QWORD PTR [r15+8]
	lea	rdx, QWORD PTR [rax*8+8]
	mov	rcx, rdx
	imul	rdx, r10
	imul	rcx, rdi
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\utility

; 140  :     _Left    = _STD move(_Right);

	mov	rax, QWORD PTR [rdx+r8]
	movsd	xmm0, QWORD PTR [rcx+r8]
	mov	QWORD PTR [rcx+r8], rax

; 141  :     _Right   = _STD move(_Tmp);

	movsd	QWORD PTR [rdx+r8], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LDLT.h

; 317  :         for (Index i = k + 1; i < index_of_biggest_in_corner; ++i) {

	lea	r8, QWORD PTR [rdi+1]
	cmp	r8, r10
	jge	SHORT $LN2427@unblocked
	npad	9
$LL7@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\PlainObjectBase.h

; 195  :       return m_storage.data()[rowId + colId * m_storage.rows()];

	mov	rax, QWORD PTR [r15+8]
	mov	rdx, QWORD PTR [r15]
	mov	rcx, rax
	imul	rax, r8
	imul	rcx, rdi
	add	rax, r10
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LDLT.h

; 319  :           mat.coeffRef(i, k) = numext::conj(mat.coeffRef(index_of_biggest_in_corner, i));

	mov	rax, QWORD PTR [rdx+rax*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\PlainObjectBase.h

; 195  :       return m_storage.data()[rowId + colId * m_storage.rows()];

	add	rcx, r8
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LDLT.h

; 318  :           Scalar tmp = mat.coeffRef(i, k);

	movsd	xmm0, QWORD PTR [rdx+rcx*8]

; 319  :           mat.coeffRef(i, k) = numext::conj(mat.coeffRef(index_of_biggest_in_corner, i));

	mov	QWORD PTR [rdx+rcx*8], rax
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\PlainObjectBase.h

; 195  :       return m_storage.data()[rowId + colId * m_storage.rows()];

	mov	rcx, r8
	imul	rcx, QWORD PTR [r15+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LDLT.h

; 320  :           mat.coeffRef(index_of_biggest_in_corner, i) = numext::conj(tmp);

	mov	rax, QWORD PTR [r15]
	inc	r8
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\PlainObjectBase.h

; 195  :       return m_storage.data()[rowId + colId * m_storage.rows()];

	add	rcx, r10
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LDLT.h

; 320  :           mat.coeffRef(index_of_biggest_in_corner, i) = numext::conj(tmp);

	movsd	QWORD PTR [rax+rcx*8], xmm0
	cmp	r8, r10
	jl	SHORT $LL7@unblocked
$LN2427@unblocked:

; 321  :         }
; 322  :         if (NumTraits<Scalar>::IsComplex)
; 323  :           mat.coeffRef(index_of_biggest_in_corner, k) = numext::conj(mat.coeff(index_of_biggest_in_corner, k));
; 324  :       }
; 325  : 
; 326  :       // partition the matrix:
; 327  :       //       A00 |  -  |  -
; 328  :       // lu  = A10 | A11 |  -
; 329  :       //       A20 | A21 | A22
; 330  :       Index rs = size - k - 1;

	mov	r12, QWORD PTR temp$1$[rsp]
$LN6@unblocked:
	mov	r14, QWORD PTR tv13560[rsp]

; 331  :       Block<MatrixType, Dynamic, 1> A21(mat, k + 1, k, rs, 1);

	lea	rcx, QWORD PTR [rdi+1]
	mov	r9, QWORD PTR [r15]
	sub	r14, 1
	mov	QWORD PTR A20$3$[rbp-256], r14
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	je	SHORT $LN62@unblocked

; 319  :     return base != nullptr ? base + offset : nullptr;

	test	r9, r9
	je	SHORT $LN62@unblocked

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	mov	rax, rdi
	imul	rax, QWORD PTR [r15+8]

; 319  :     return base != nullptr ? base + offset : nullptr;

	add	rax, rcx
	lea	rsi, QWORD PTR [r9+rax*8]
	jmp	SHORT $LN67@unblocked
$LN62@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MapBase.h

; 154  :       : m_data(dataPtr), m_rows(rows), m_cols(cols) {

	mov	rsi, r13
$LN67@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 413  :     m_outerStride =

	mov	rdx, QWORD PTR [r15+8]
	mov	QWORD PTR A21$28[rbp-208], rdx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MapBase.h

; 154  :       : m_data(dataPtr), m_rows(rows), m_cols(cols) {

	mov	QWORD PTR A21$28[rbp-256], rsi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	QWORD PTR A21$28[rbp-248], r14
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 370  :         m_xpr(xpr),

	mov	QWORD PTR A21$28[rbp-232], r15
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	QWORD PTR A21$28[rbp-224], rcx
	mov	QWORD PTR A21$28[rbp-216], rdi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	test	rdi, rdi
	je	SHORT $LN95@unblocked

; 319  :     return base != nullptr ? base + offset : nullptr;

	lea	r8, QWORD PTR [r9+rdi*8]
	test	r9, r9
	jne	SHORT $LN2539@unblocked
$LN95@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LDLT.h

; 333  :       Block<MatrixType, Dynamic, Dynamic> A20(mat, k + 1, 0, rs, k);

	mov	r8, r13
$LN2539@unblocked:
	mov	QWORD PTR $T16[rsp], r8
	lea	rcx, QWORD PTR [rdi+1]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	test	r14, r14
	je	SHORT $LN2341@unblocked
	test	rdi, rdi
	je	SHORT $LN2341@unblocked

; 319  :     return base != nullptr ? base + offset : nullptr;

	lea	rax, QWORD PTR [r9+rcx*8]
	test	r9, r9
	jne	SHORT $LN2540@unblocked
$LN2341@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MapBase.h

; 154  :       : m_data(dataPtr), m_rows(rows), m_cols(cols) {

	mov	rax, r13
$LN2540@unblocked:
	mov	QWORD PTR eval$12$sroa$3256$1$[rsp], rax
	mov	QWORD PTR A20$23[rbp-256], rax
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	QWORD PTR A20$23[rbp-248], r14
	mov	QWORD PTR A20$23[rbp-240], rdi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 370  :         m_xpr(xpr),

	mov	QWORD PTR A20$23[rbp-232], r15
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	QWORD PTR A20$23[rbp-224], rcx
	mov	QWORD PTR A20$23[rbp-216], r13
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 413  :     m_outerStride =

	mov	QWORD PTR A20$23[rbp-208], rdx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LDLT.h

; 335  :       if (k > 0) {

	test	rdi, rdi
	jle	$LN920@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	mov	rcx, QWORD PTR [r12]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Diagonal.h

; 88   :   EIGEN_DEVICE_FUNC constexpr Index innerStride() const noexcept { return m_matrix.outerStride() + 1; }

	lea	r12, QWORD PTR [rdx+1]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	mov	QWORD PTR $T19[rsp], rcx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 565  :     const Index size = kernel.size();

	mov	rax, r13
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	QWORD PTR srcEvaluator$9$sroa$3261$1$[rsp], rdx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 566  :     for (Index i = 0; i < size; ++i) kernel.assignCoeff(i);

	cmp	rdi, 4
	jl	$LN2342@unblocked
	mov	rbx, QWORD PTR srcEvaluator$9$sroa$3261$1$[rsp]
	lea	r8, QWORD PTR [rcx+16]
	mov	rax, r12
	mov	rcx, r12
	shl	rax, 5
	mov	r15, r12
	mov	QWORD PTR tv13340[rbp-256], rax
	neg	r15
	mov	rax, rdx
	shl	rcx, 4
	shl	rax, 5
	add	rcx, r9
	mov	QWORD PTR tv13339[rbp-256], rax
	mov	rax, QWORD PTR srcEvaluator$9$sroa$3261$1$[rsp]
	mov	r13, rax
	shl	rdx, 4
	add	rdx, QWORD PTR $T16[rsp]
	neg	rax
	shl	rax, 4
	neg	r13
	mov	QWORD PTR tv13473[rbp-256], rax
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\ProductEvaluators.h

; 920  :       return m_diagImpl.coeff(idx) * m_matImpl.coeff(idx);

	mov	rax, r12
	mov	r14, QWORD PTR tv13473[rbp-256]
	neg	rax
	shl	rax, 4
	mov	QWORD PTR tv13474[rbp-256], rax
	lea	rax, QWORD PTR [rdi-4]
	mov	rdi, QWORD PTR tv13474[rbp-256]
	shr	rax, 2
	inc	rax
	mov	QWORD PTR tv13451[rsp], rax
	lea	rax, QWORD PTR [rax*4]
	npad	9
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 566  :     for (Index i = 0; i < size; ++i) kernel.assignCoeff(i);

$LL2215@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\ProductEvaluators.h

; 920  :       return m_diagImpl.coeff(idx) * m_matImpl.coeff(idx);

	movsd	xmm0, QWORD PTR [rdx+r14]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	lea	r11, QWORD PTR [rbx*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\ProductEvaluators.h

; 920  :       return m_diagImpl.coeff(idx) * m_matImpl.coeff(idx);

	mulsd	xmm0, QWORD PTR [rcx+rdi]
	lea	r10, QWORD PTR [r12*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	lea	r8, QWORD PTR [r8+32]
	movsd	QWORD PTR [r8-48], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\ProductEvaluators.h

; 920  :       return m_diagImpl.coeff(idx) * m_matImpl.coeff(idx);

	movsd	xmm1, QWORD PTR [rdx+r13*8]
	mulsd	xmm1, QWORD PTR [rcx+r15*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movsd	QWORD PTR [r8-40], xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\ProductEvaluators.h

; 920  :       return m_diagImpl.coeff(idx) * m_matImpl.coeff(idx);

	movsd	xmm0, QWORD PTR [rdx]
	mulsd	xmm0, QWORD PTR [rcx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movsd	QWORD PTR [r8-32], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\ProductEvaluators.h

; 920  :       return m_diagImpl.coeff(idx) * m_matImpl.coeff(idx);

	movsd	xmm0, QWORD PTR [rdx+r11]
	mulsd	xmm0, QWORD PTR [rcx+r10]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	add	rdx, QWORD PTR tv13339[rbp-256]
	add	rcx, QWORD PTR tv13340[rbp-256]
	sub	QWORD PTR tv13451[rsp], 1
	movsd	QWORD PTR [r8-24], xmm0
	jne	SHORT $LL2215@unblocked
	mov	rbx, QWORD PTR $T1[rsp+8]
	xor	r13d, r13d
	mov	rdi, QWORD PTR A20$4$[rsp]
	mov	r14, QWORD PTR A20$3$[rbp-256]
	mov	r15, QWORD PTR A20$2$[rbp-256]
	mov	rdx, QWORD PTR srcEvaluator$9$sroa$3261$1$[rsp]
	mov	r8, QWORD PTR $T16[rsp]
	jmp	SHORT $LC2214@unblocked
$LN2342@unblocked:
	lea	r10, QWORD PTR [r12*8]
	lea	r11, QWORD PTR [rdx*8]
$LC2214@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 566  :     for (Index i = 0; i < size; ++i) kernel.assignCoeff(i);

	cmp	rax, rdi
	jge	SHORT $LN2213@unblocked
	imul	r12, rax
	imul	rdx, rax
	lea	rcx, QWORD PTR [r9+r12*8]
	mov	r9, QWORD PTR $T19[rsp]
	lea	rdx, QWORD PTR [r8+rdx*8]
$LC734@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\ProductEvaluators.h

; 920  :       return m_diagImpl.coeff(idx) * m_matImpl.coeff(idx);

	movsd	xmm0, QWORD PTR [rdx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 566  :     for (Index i = 0; i < size; ++i) kernel.assignCoeff(i);

	add	rdx, r11
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\ProductEvaluators.h

; 920  :       return m_diagImpl.coeff(idx) * m_matImpl.coeff(idx);

	mulsd	xmm0, QWORD PTR [rcx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 566  :     for (Index i = 0; i < size; ++i) kernel.assignCoeff(i);

	add	rcx, r10
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movsd	QWORD PTR [r9+rax*8], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 566  :     for (Index i = 0; i < size; ++i) kernel.assignCoeff(i);

	inc	rax
	cmp	rax, rdi
	jl	SHORT $LC734@unblocked
$LN2213@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	mov	rdx, QWORD PTR temp$1$[rsp]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\CoreEvaluators.h

; 146  :       : data(ptr) {

	lea	rax, QWORD PTR $T29[rbp-248]
	mov	QWORD PTR $T29[rbp-256], rax
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	r9, QWORD PTR [r15+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	mov	r12, QWORD PTR [rdx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\InnerProduct.h

; 118  :     if (size == 0) return Scalar(0);

	test	rdi, rdi
	jne	SHORT $LN535@unblocked
	movaps	xmm2, xmm6
	jmp	$LN531@unblocked
$LN535@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movsd	xmm2, QWORD PTR [r8]
	mov	ecx, 1
	mulsd	xmm2, QWORD PTR [r12]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\InnerProduct.h

; 121  :     for (Index k = 1; k < size; k++) {

	cmp	rdi, rcx
	jle	$LN2216@unblocked
	lea	rax, QWORD PTR [rdi-1]
	cmp	rax, 4
	jl	$LC534@unblocked
	mov	rax, r9
	lea	rdx, QWORD PTR [r12+24]
	shl	rax, 5
	mov	r11, r9
	mov	QWORD PTR tv13331[rsp], rax
	neg	r11
	lea	rax, QWORD PTR [r9+r9*2]
	mov	r10, r9
	lea	r8, QWORD PTR [r8+rax*8]
	neg	r10
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\CoreEvaluators.h

; 1256 :     return m_data[index * m_innerStride.value()];

	lea	rax, QWORD PTR [rdi-5]
	add	r11, r11
	shr	rax, 2
	inc	rax
	lea	rcx, QWORD PTR [rax*4+1]
	npad	9
$LL2218@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 1003 :     return x * y + z;

	movsd	xmm1, QWORD PTR [r8+r11*8]
	mulsd	xmm1, QWORD PTR [rdx-16]
	movsd	xmm0, QWORD PTR [r8+r10*8]
	mulsd	xmm0, QWORD PTR [rdx-8]
	addsd	xmm2, xmm1
	movsd	xmm1, QWORD PTR [r8]
	mulsd	xmm1, QWORD PTR [rdx]
	addsd	xmm2, xmm0
	movsd	xmm0, QWORD PTR [r8+r9*8]
	mulsd	xmm0, QWORD PTR [rdx+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\InnerProduct.h

; 122  :       result = eval.coeff(result, k);

	add	rdx, 32					; 00000020H
	add	r8, QWORD PTR tv13331[rsp]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 1003 :     return x * y + z;

	addsd	xmm2, xmm1
	addsd	xmm2, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\InnerProduct.h

; 122  :       result = eval.coeff(result, k);

	sub	rax, 1
	jne	SHORT $LL2218@unblocked

; 121  :     for (Index k = 1; k < size; k++) {

	cmp	rcx, rdi
	jge	SHORT $LN2216@unblocked
	mov	r8, QWORD PTR $T16[rsp]
$LC534@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\CoreEvaluators.h

; 1256 :     return m_data[index * m_innerStride.value()];

	mov	rax, rcx
	imul	rax, r9
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 1003 :     return x * y + z;

	movsd	xmm0, QWORD PTR [r8+rax*8]
	mulsd	xmm0, QWORD PTR [r12+rcx*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\InnerProduct.h

; 121  :     for (Index k = 1; k < size; k++) {

	inc	rcx

; 122  :       result = eval.coeff(result, k);

	addsd	xmm2, xmm0
	cmp	rcx, rdi
	jl	SHORT $LC534@unblocked
$LN2216@unblocked:
	mov	rdx, QWORD PTR temp$1$[rsp]
$LN531@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\PlainObjectBase.h

; 195  :       return m_storage.data()[rowId + colId * m_storage.rows()];

	mov	rcx, QWORD PTR [r15+8]
	mov	rax, QWORD PTR [r15]
	inc	rcx
	imul	rcx, rdi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\ProductEvaluators.h

; 241  :     dst.coeffRef(0, 0) = impl::run(lhs, rhs);

	movsd	QWORD PTR $T29[rbp-248], xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LDLT.h

; 337  :         mat.coeffRef(k, k) -= (A10 * temp.head(k)).value();

	movsd	xmm0, QWORD PTR [rax+rcx*8]
	subsd	xmm0, xmm2
	movsd	QWORD PTR [rax+rcx*8], xmm0

; 338  :         if (rs > 0) A21.noalias() -= A20 * temp.head(k);

	test	r14, r14
	jle	$LN920@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	mov	r10, QWORD PTR [rdx]

; 413  :     m_outerStride =

	mov	rax, QWORD PTR [rdx+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MapBase.h

; 154  :       : m_data(dataPtr), m_rows(rows), m_cols(cols) {

	mov	QWORD PTR $T27[rbp-256], r10
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 413  :     m_outerStride =

	mov	QWORD PTR $T27[rbp-208], rax
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\ProductEvaluators.h

; 361  :     scaleAndAddTo(dst, lhs, rhs, Scalar(-1));

	movsd	QWORD PTR $T20[rsp], xmm7
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	QWORD PTR $T27[rbp-248], rdi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 370  :         m_xpr(xpr),

	mov	QWORD PTR $T27[rbp-232], rdx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	QWORD PTR $T27[rbp-224], r13
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\ProductEvaluators.h

; 384  :     if (lhs.rows() == 1 && rhs.cols() == 1) {

	cmp	r14, 1
	jne	$LN921@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\XprHelper.h

; 174  :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE explicit variable_if_dynamic(T value = 0) noexcept : m_value(value) {}

	mov	r9, QWORD PTR [r15+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\InnerProduct.h

; 118  :     if (size == 0) return Scalar(0);

	test	rdi, rdi
	jne	SHORT $LN1060@unblocked
	movaps	xmm2, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\ProductEvaluators.h

; 385  :       dst.coeffRef(0, 0) += alpha * lhs.row(0).conjugate().dot(rhs.col(0));

	mulsd	xmm2, xmm7
	addsd	xmm2, QWORD PTR [rsi]
	movsd	QWORD PTR [rsi], xmm2

; 386  :       return;

	jmp	$LN920@unblocked
$LN1060@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	mov	r8, QWORD PTR eval$12$sroa$3256$1$[rsp]
	mov	ecx, 1
	movsd	xmm2, QWORD PTR [r8]
	mulsd	xmm2, QWORD PTR [r10]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\InnerProduct.h

; 121  :     for (Index k = 1; k < size; k++) {

	cmp	rdi, rcx
	jle	$LN2219@unblocked
	lea	rax, QWORD PTR [rdi-1]
	cmp	rax, 4
	jl	$LC1059@unblocked
	mov	rax, r9
	lea	rdx, QWORD PTR [r10+24]
	shl	rax, 5
	mov	r12, r9
	mov	QWORD PTR tv13328[rsp], rax
	neg	r12
	lea	rax, QWORD PTR [r9+r9*2]
	mov	r11, r9
	lea	r8, QWORD PTR [r8+rax*8]
	neg	r11
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\CoreEvaluators.h

; 1256 :     return m_data[index * m_innerStride.value()];

	lea	rax, QWORD PTR [rdi-5]
	add	r12, r12
	shr	rax, 2
	inc	rax
	lea	rcx, QWORD PTR [rax*4+1]
$LL2221@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 1003 :     return x * y + z;

	movsd	xmm1, QWORD PTR [r8+r12*8]
	mulsd	xmm1, QWORD PTR [rdx-16]
	movsd	xmm0, QWORD PTR [r8+r11*8]
	mulsd	xmm0, QWORD PTR [rdx-8]
	addsd	xmm2, xmm1
	movsd	xmm1, QWORD PTR [r8]
	mulsd	xmm1, QWORD PTR [rdx]
	addsd	xmm2, xmm0
	movsd	xmm0, QWORD PTR [r8+r9*8]
	mulsd	xmm0, QWORD PTR [rdx+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\InnerProduct.h

; 122  :       result = eval.coeff(result, k);

	add	rdx, 32					; 00000020H
	add	r8, QWORD PTR tv13328[rsp]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 1003 :     return x * y + z;

	addsd	xmm2, xmm1
	addsd	xmm2, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\InnerProduct.h

; 122  :       result = eval.coeff(result, k);

	sub	rax, 1
	jne	SHORT $LL2221@unblocked

; 121  :     for (Index k = 1; k < size; k++) {

	cmp	rcx, rdi
	jge	SHORT $LN2219@unblocked
	mov	r8, QWORD PTR eval$12$sroa$3256$1$[rsp]
$LC1059@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\CoreEvaluators.h

; 1256 :     return m_data[index * m_innerStride.value()];

	mov	rax, rcx
	imul	rax, r9
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 1003 :     return x * y + z;

	movsd	xmm0, QWORD PTR [r8+rax*8]
	mulsd	xmm0, QWORD PTR [r10+rcx*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\InnerProduct.h

; 121  :     for (Index k = 1; k < size; k++) {

	inc	rcx

; 122  :       result = eval.coeff(result, k);

	addsd	xmm2, xmm0
	cmp	rcx, rdi
	jl	SHORT $LC1059@unblocked
$LN2219@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\ProductEvaluators.h

; 385  :       dst.coeffRef(0, 0) += alpha * lhs.row(0).conjugate().dot(rhs.col(0));

	mulsd	xmm2, xmm7
	addsd	xmm2, QWORD PTR [rsi]
	movsd	QWORD PTR [rsi], xmm2

; 386  :       return;

	jmp	SHORT $LN920@unblocked
$LN921@unblocked:

; 387  :     }
; 388  :     LhsNested actual_lhs(lhs);

	movups	xmm0, XMMWORD PTR A20$23[rbp-256]

; 389  :     RhsNested actual_rhs(rhs);
; 390  :     internal::gemv_dense_selector<Side, (int(MatrixType::Flags) & RowMajorBit) ? RowMajor : ColMajor,
; 391  :                                   bool(internal::blas_traits<MatrixType>::HasUsableDirectAccess)>::run(actual_lhs,

	lea	r9, QWORD PTR $T20[rsp]
	movups	xmm1, XMMWORD PTR A20$23[rbp-240]
	lea	r8, QWORD PTR A21$28[rbp-256]
	movups	XMMWORD PTR actual_lhs$24[rbp-256], xmm0
	lea	rdx, QWORD PTR actual_rhs$22[rbp-256]
	movups	xmm0, XMMWORD PTR A20$23[rbp-224]
	lea	rcx, QWORD PTR actual_lhs$24[rbp-256]
	movups	XMMWORD PTR actual_lhs$24[rbp-240], xmm1
	movsd	xmm1, QWORD PTR A20$23[rbp-208]
	movups	XMMWORD PTR actual_lhs$24[rbp-224], xmm0
	movups	xmm0, XMMWORD PTR $T27[rbp-256]
	movsd	QWORD PTR actual_lhs$24[rbp-208], xmm1
	movups	xmm1, XMMWORD PTR $T27[rbp-240]
	movups	XMMWORD PTR actual_rhs$22[rbp-256], xmm0
	movups	xmm0, XMMWORD PTR $T27[rbp-224]
	movups	XMMWORD PTR actual_rhs$22[rbp-240], xmm1
	movsd	xmm1, QWORD PTR $T27[rbp-208]
	movups	XMMWORD PTR actual_rhs$22[rbp-224], xmm0
	movsd	QWORD PTR actual_rhs$22[rbp-208], xmm1
	call	??$run@V?$Block@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@$0?0$0?0$0A@@Eigen@@V?$Block@V?$Matrix@N$0?0$00$0A@$0?0$00@Eigen@@$0?0$00$0A@@2@V?$Block@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@$0?0$00$0A@@2@@?$gemv_dense_selector@$01$0A@$00@internal@Eigen@@SAXAEBV?$Block@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@$0?0$0?0$0A@@2@AEBV?$Block@V?$Matrix@N$0?0$00$0A@$0?0$00@Eigen@@$0?0$00$0A@@2@AEAV?$Block@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@$0?0$00$0A@@2@AEBN@Z ; Eigen::internal::gemv_dense_selector<2,0,1>::run<Eigen::Block<Eigen::Matrix<double,-1,-1,0,-1,-1>,-1,-1,0>,Eigen::Block<Eigen::Matrix<double,-1,1,0,-1,1>,-1,1,0>,Eigen::Block<Eigen::Matrix<double,-1,-1,0,-1,-1>,-1,1,0> >
$LN920@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\PlainObjectBase.h

; 195  :       return m_storage.data()[rowId + colId * m_storage.rows()];

	mov	rcx, QWORD PTR [r15+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LDLT.h

; 345  :       RealScalar realAkk = numext::real(mat.coeffRef(k, k));

	mov	rax, QWORD PTR [r15]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\PlainObjectBase.h

; 195  :       return m_storage.data()[rowId + colId * m_storage.rows()];

	inc	rcx
	imul	rcx, rdi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LDLT.h

; 345  :       RealScalar realAkk = numext::real(mat.coeffRef(k, k));

	movsd	xmm2, QWORD PTR [rax+rcx*8]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movaps	xmm0, xmm2
	andps	xmm0, xmm8
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LDLT.h

; 346  :       bool pivot_is_valid = (abs(realAkk) > RealScalar(0));

	comisd	xmm0, xmm6
	seta	r10b

; 347  : 
; 348  :       if (k == 0 && !pivot_is_valid) {

	test	rdi, rdi
	jne	SHORT $LN22@unblocked
	test	r10b, r10b
	je	$LN2113@unblocked
$LN22@unblocked:

; 357  :       }
; 358  : 
; 359  :       if ((rs > 0) && pivot_is_valid)

	test	r14, r14
	jle	$LN2426@unblocked
	test	r10b, r10b
	je	$LN23@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\Memory.h

; 555  :   } else if ((std::uintptr_t(array) & (sizeof(Scalar) - 1)) || (Alignment % ScalarSize) != 0) {

	mov	r8, r14
	test	sil, 7
	jne	SHORT $LN1265@unblocked

; 556  :     // The array is not aligned to the size of a single scalar, or the requested alignment is not a multiple of the
; 557  :     // scalar size. Consequently, no element of the array is well aligned.
; 558  :     return size;
; 559  :   } else {
; 560  :     Index first = (AlignmentSize - (Index((std::uintptr_t(array) / sizeof(Scalar))) & AlignmentMask)) & AlignmentMask;

	mov	rax, rsi
	shr	rax, 3
	neg	rax
	and	eax, 1

; 561  :     return (first < size) ? first : size;

	cmp	rax, r14
	cmovl	r8, rax
$LN1265@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 490  :     const Index alignedEnd = alignedStart + numext::round_down(size - alignedStart, PacketSize);

	mov	rax, r14
	mov	r9, r13
	sub	rax, r8
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\MathFunctions.h

; 1357 :   return ub * (ua / ub);

	shr	rax, 1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 490  :     const Index alignedEnd = alignedStart + numext::round_down(size - alignedStart, PacketSize);

	lea	rcx, QWORD PTR [r8+rax*2]

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	test	r8, r8
	jle	$LN2222@unblocked
	cmp	r8, 8
	jb	SHORT $LN2351@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	mov	rax, r8
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 489  :     const Index alignedStart = DstIsAligned ? 0 : first_aligned<Alignment>(kernel.dstDataPtr(), size);

	movaps	xmm3, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	cdq
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 489  :     const Index alignedStart = DstIsAligned ? 0 : first_aligned<Alignment>(kernel.dstDataPtr(), size);

	unpcklpd xmm3, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	and	edx, 7
	add	rax, rdx
	and	eax, 7
	sub	rax, rdx
	mov	rdx, r8
	sub	rdx, rax
	lea	rax, QWORD PTR [rsi+32]
	npad	2
$LL1273@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movups	xmm0, XMMWORD PTR [rax-32]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	add	r9, 8
	lea	rax, QWORD PTR [rax+64]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	divpd	xmm0, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movups	XMMWORD PTR [rax-96], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movups	xmm0, XMMWORD PTR [rax-80]
	divpd	xmm0, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movups	XMMWORD PTR [rax-80], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movups	xmm1, XMMWORD PTR [rax-64]
	divpd	xmm1, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movups	XMMWORD PTR [rax-64], xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movups	xmm0, XMMWORD PTR [rax-48]
	divpd	xmm0, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movups	XMMWORD PTR [rax-48], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	cmp	r9, rdx
	jl	SHORT $LL1273@unblocked
	cmp	r9, r8
	jge	$LN2222@unblocked
$LN2351@unblocked:
	mov	rax, r8
	sub	rax, r9
	cmp	rax, 4
	jl	SHORT $LL2415@unblocked
	lea	rax, QWORD PTR [r9+2]
	mov	rdx, r8
	sub	rdx, r9
	lea	rax, QWORD PTR [rsi+rax*8]
	sub	rdx, 4
	shr	rdx, 2
	inc	rdx
	lea	r9, QWORD PTR [r9+rdx*4]
	npad	1
$LL2224@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movsd	xmm0, QWORD PTR [rax-16]
	movsd	xmm1, QWORD PTR [rax-8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	lea	rax, QWORD PTR [rax+32]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	divsd	xmm0, xmm2
	divsd	xmm1, xmm2
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
	divsd	xmm0, xmm2
	divsd	xmm1, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movsd	QWORD PTR [rax-32], xmm0
	movsd	QWORD PTR [rax-24], xmm1
	sub	rdx, 1
	jne	SHORT $LL2224@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	cmp	r9, r8
	jge	SHORT $LN2222@unblocked
	npad	9
$LL2415@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movsd	xmm0, QWORD PTR [rsi+r9*8]
	divsd	xmm0, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movsd	QWORD PTR [rsi+r9*8], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	inc	r9
	cmp	r9, r8
	jl	SHORT $LL2415@unblocked
$LN2222@unblocked:

; 494  :     for (Index index = alignedStart; index < alignedEnd; index += PacketSize)

	cmp	r8, rcx
	jge	SHORT $LN1251@unblocked
	movaps	xmm1, xmm2
	unpcklpd xmm1, xmm1
	npad	12
$LL1252@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 680  :   return _mm_div_pd(a, b);

	movups	xmm0, XMMWORD PTR [rsi+r8*8]
	divpd	xmm0, xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 65   :     assign_op<DstScalar, DstScalar>().template assignPacket<Alignment, Packet>(

	movups	XMMWORD PTR [rsi+r8*8], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 494  :     for (Index index = alignedStart; index < alignedEnd; index += PacketSize)

	add	r8, 2
	cmp	r8, rcx
	jl	SHORT $LL1252@unblocked
$LN1251@unblocked:

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	mov	rax, r14
	sub	rax, rcx
	cmp	rcx, r14
	jge	$LN2426@unblocked
	cmp	rax, 8
	jb	SHORT $LN2349@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	cdq
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	movaps	xmm3, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	and	edx, 7
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	unpcklpd xmm3, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	add	rax, rdx
	and	eax, 7
	sub	rax, rdx
	mov	rdx, r14
	sub	rdx, rax
	lea	rax, QWORD PTR [rcx+4]
	lea	rax, QWORD PTR [rsi+rax*8]
	npad	1
$LL1312@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movups	xmm0, XMMWORD PTR [rax-32]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	add	rcx, 8
	lea	rax, QWORD PTR [rax+64]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	divpd	xmm0, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movups	XMMWORD PTR [rax-96], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movups	xmm0, XMMWORD PTR [rax-80]
	divpd	xmm0, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movups	XMMWORD PTR [rax-80], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movups	xmm1, XMMWORD PTR [rax-64]
	divpd	xmm1, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movups	XMMWORD PTR [rax-64], xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movups	xmm0, XMMWORD PTR [rax-48]
	divpd	xmm0, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movups	XMMWORD PTR [rax-48], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	cmp	rcx, rdx
	jl	SHORT $LL1312@unblocked
	cmp	rcx, r14
	jge	$LN2426@unblocked
$LN2349@unblocked:
	mov	rax, r14
	sub	rax, rcx
	cmp	rax, 4
	jl	SHORT $LL2419@unblocked
	lea	rax, QWORD PTR [rcx+2]
	mov	rdx, r14
	sub	rdx, rcx
	lea	rax, QWORD PTR [rsi+rax*8]
	sub	rdx, 4
	shr	rdx, 2
	inc	rdx
	lea	rcx, QWORD PTR [rcx+rdx*4]
	npad	1
$LL2227@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movsd	xmm0, QWORD PTR [rax-16]
	movsd	xmm1, QWORD PTR [rax-8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	lea	rax, QWORD PTR [rax+32]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	divsd	xmm0, xmm2
	divsd	xmm1, xmm2
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
	divsd	xmm0, xmm2
	divsd	xmm1, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movsd	QWORD PTR [rax-32], xmm0
	movsd	QWORD PTR [rax-24], xmm1
	sub	rdx, 1
	jne	SHORT $LL2227@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	cmp	rcx, r14
	jge	SHORT $LN2426@unblocked
	npad	9
$LL2419@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 422  :     return a / b;

	movsd	xmm0, QWORD PTR [rsi+rcx*8]
	divsd	xmm0, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\AssignmentFunctors.h

; 26   :   EIGEN_DEVICE_FUNC EIGEN_STRONG_INLINE constexpr void assignCoeff(DstScalar& a, const SrcScalar& b) const { a = b; }

	movsd	QWORD PTR [rsi+rcx*8], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	inc	rcx
	cmp	rcx, r14
	jl	SHORT $LL2419@unblocked
$LN2426@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LDLT.h

; 364  :       if (found_zero_pivot && pivot_is_valid)

	movzx	r8d, BYTE PTR ret$1$[rsp]
$LN43@unblocked:
	cmp	BYTE PTR found_zero_pivot$1$[rsp], 0
	je	SHORT $LN26@unblocked
	test	r10b, r10b
	je	SHORT $LN2292@unblocked

; 365  :         ret = false;  // factorization failed

	xor	r8b, r8b
	mov	BYTE PTR ret$1$[rsp], r8b
	jmp	SHORT $LN28@unblocked
$LN23@unblocked:

; 362  :         ret = ret && (A21.array() == Scalar(0)).all();

	cmp	BYTE PTR ret$1$[rsp], 0
	je	SHORT $LN42@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Visitor.h

; 235  :     if (size == 0) return;

	test	r14, r14
	je	SHORT $LN2325@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 214  :     return a == b ? result_type(1) : result_type(0);

	movsd	xmm0, QWORD PTR [rsi]
	ucomisd	xmm0, xmm6
	jp	SHORT $LN42@unblocked
	jne	SHORT $LN42@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Visitor.h

; 238  :     for (Index k = 1; k < size; k++) {

	mov	eax, 1
	cmp	r14, rax
	jle	SHORT $LN2325@unblocked
$LL1994@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 214  :     return a == b ? result_type(1) : result_type(0);

	movsd	xmm0, QWORD PTR [rsi+rax*8]
	ucomisd	xmm0, xmm6
	jp	SHORT $LN42@unblocked
	jne	SHORT $LN42@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Visitor.h

; 238  :     for (Index k = 1; k < size; k++) {

	inc	rax
	cmp	rax, r14
	jl	SHORT $LL1994@unblocked
$LN2325@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LDLT.h

; 362  :         ret = ret && (A21.array() == Scalar(0)).all();

	mov	r8b, 1
	mov	BYTE PTR ret$1$[rsp], r8b
	jmp	SHORT $LN43@unblocked
$LN42@unblocked:
	xor	r8b, r8b
	mov	BYTE PTR ret$1$[rsp], r8b
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	jmp	SHORT $LN43@unblocked
$LN26@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LDLT.h

; 366  :       else if (!pivot_is_valid)

	test	r10b, r10b
	jne	SHORT $LN28@unblocked
$LN2292@unblocked:

; 367  :         found_zero_pivot = true;

	mov	BYTE PTR found_zero_pivot$1$[rsp], 1
$LN28@unblocked:

; 368  : 
; 369  :       if (sign == PositiveSemiDef) {

	mov	r10, QWORD PTR sign$GSCopy$1$[rsp]
	mov	eax, DWORD PTR [r10]
	test	eax, eax
	jne	SHORT $LN29@unblocked

; 370  :         if (realAkk < static_cast<RealScalar>(0)) sign = Indefinite;

	comisd	xmm6, xmm2
	ja	SHORT $LN2353@unblocked
	jmp	SHORT $LN2@unblocked
$LN29@unblocked:

; 371  :       } else if (sign == NegativeSemiDef) {

	cmp	eax, 1
	jne	SHORT $LN32@unblocked

; 372  :         if (realAkk > static_cast<RealScalar>(0)) sign = Indefinite;

	comisd	xmm2, xmm6
	jbe	SHORT $LN2@unblocked
$LN2353@unblocked:
	mov	DWORD PTR [r10], 3
	jmp	SHORT $LN2@unblocked
$LN32@unblocked:

; 373  :       } else if (sign == ZeroSign) {

	cmp	eax, 2
	jne	SHORT $LN2@unblocked

; 374  :         if (realAkk > static_cast<RealScalar>(0))

	comisd	xmm2, xmm6
	jbe	SHORT $LN36@unblocked

; 375  :           sign = PositiveSemiDef;

	mov	DWORD PTR [r10], r13d
	jmp	SHORT $LN2@unblocked
$LN36@unblocked:

; 376  :         else if (realAkk < static_cast<RealScalar>(0))

	comisd	xmm6, xmm2
	jbe	SHORT $LN2@unblocked

; 377  :           sign = NegativeSemiDef;

	mov	DWORD PTR [r10], 1
$LN2@unblocked:

; 301  :     }
; 302  : 
; 303  :     for (Index k = 0; k < size; ++k) {

	mov	rsi, QWORD PTR size$1$[rsp]
	inc	rdi
	mov	QWORD PTR A20$4$[rsp], rdi
	cmp	rdi, rsi
	jge	$LN2139@unblocked
	mov	r14, QWORD PTR transpositions$GSCopy$1$[rbp-256]
	mov	r12, QWORD PTR temp$1$[rsp]
	jmp	$LL4@unblocked
$LN2113@unblocked:

; 351  :         sign = ZeroSign;

	mov	rax, QWORD PTR sign$GSCopy$1$[rsp]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\AssignEvaluator.h

; 417  :     for (Index index = start; index < end; ++index) kernel.assignCoeff(index);

	mov	r8, r13
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LDLT.h

; 351  :         sign = ZeroSign;

	mov	r10, QWORD PTR size$1$[rsp]
	mov	r11, QWORD PTR transpositions$GSCopy$1$[rbp-256]
	mov	DWORD PTR [rax], 2
	lea	rcx, QWORD PTR [r10-1]
	npad	5
$LL10@unblocked:

; 354  :           ret = ret && (mat.col(j).tail(size - j - 1).array() == Scalar(0)).all();

	cmp	BYTE PTR ret$1$[rsp], 0
	mov	rax, QWORD PTR [r11]
	mov	DWORD PTR [rax+r8*4], r8d
	je	SHORT $LN40@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 330  :       : Base((BlockRows == 0 || BlockCols == 0)

	mov	r9, QWORD PTR [r15]
	mov	rdx, QWORD PTR [r15+8]

; 319  :     return base != nullptr ? base + offset : nullptr;

	test	r9, r9
	je	SHORT $LN321@unblocked
	mov	rax, rdx
	imul	rax, r8
	lea	r9, QWORD PTR [r9+rax*8]
	jmp	SHORT $LN322@unblocked
$LN321@unblocked:
	mov	r9, r13
$LN322@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\plugins\BlockMethods.inc

; 1213 :   return typename FixedSegmentReturnType<internal::get_fixed_value<NType>::value>::Type(

	sub	rdx, r10
	lea	rax, QWORD PTR [rdx+1]
	add	rax, r8
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Block.h

; 364  :       : Base((blockRows == 0 || blockCols == 0)

	test	rcx, rcx
	je	SHORT $LN358@unblocked

; 319  :     return base != nullptr ? base + offset : nullptr;

	lea	rdx, QWORD PTR [r9+rax*8]
	test	r9, r9
	jne	SHORT $LN363@unblocked
$LN358@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Visitor.h

; 235  :     if (size == 0) return;

	mov	rdx, r13
$LN363@unblocked:
	test	rcx, rcx
	je	SHORT $LN2326@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 214  :     return a == b ? result_type(1) : result_type(0);

	movsd	xmm0, QWORD PTR [rdx]
	ucomisd	xmm0, xmm6
	jp	SHORT $LN40@unblocked
	jne	SHORT $LN40@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Visitor.h

; 238  :     for (Index k = 1; k < size; k++) {

	mov	eax, 1
	cmp	rcx, rax
	jle	SHORT $LN2326@unblocked
$LL230@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\functors\BinaryFunctors.h

; 214  :     return a == b ? result_type(1) : result_type(0);

	movsd	xmm0, QWORD PTR [rdx+rax*8]
	ucomisd	xmm0, xmm6
	jp	SHORT $LN40@unblocked
	jne	SHORT $LN40@unblocked
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\Visitor.h

; 238  :     for (Index k = 1; k < size; k++) {

	inc	rax
	cmp	rax, rcx
	jl	SHORT $LL230@unblocked
$LN2326@unblocked:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Cholesky\LDLT.h

; 354  :           ret = ret && (mat.col(j).tail(size - j - 1).array() == Scalar(0)).all();

	mov	al, 1
	jmp	SHORT $LN2542@unblocked
$LN40@unblocked:
	xor	al, al
$LN2542@unblocked:

; 352  :         for (Index j = 0; j < size; ++j) {

	inc	r8
	mov	BYTE PTR ret$1$[rsp], al
	dec	rcx
	cmp	r8, r10
	jl	$LL10@unblocked

; 355  :         }
; 356  :         return ret;

	jmp	SHORT $LN2538@unblocked
$LN2139@unblocked:

; 378  :       }
; 379  :     }
; 380  : 
; 381  :     return ret;

	movzx	eax, r8b
$LN2538@unblocked:
	movaps	xmm7, XMMWORD PTR [rsp+480]
	movaps	xmm6, XMMWORD PTR [rsp+496]
	mov	rdi, QWORD PTR [rsp+512]
	mov	rbx, QWORD PTR [rsp+592]
	movaps	xmm8, XMMWORD PTR [rsp+464]
$LN1@unblocked:

; 382  :   }

	mov	rcx, QWORD PTR __$ArrayPad$[rbp-256]
	xor	rcx, rsp
	call	__security_check_cookie
	add	rsp, 520				; 00000208H
	pop	r15
	pop	r14
	pop	r13
	pop	r12
	pop	rsi
	pop	rbp
	ret	0
??$unblocked@V?$Matrix@N$0?0$0?0$0A@$0?0$0?0@Eigen@@V?$Transpositions@$0?0$0?0H@2@V?$Matrix@N$0?0$00$0A@$0?0$00@2@@?$ldlt_inplace@$00@internal@Eigen@@SA_NAEAV?$Matrix@N$0?0$0?0$0A@$0?0$0?0@2@AEAV?$Transpositions@$0?0$0?0H@2@AEAV?$Matrix@N$0?0$00$0A@$0?0$00@2@AEAW4SignMatrix@12@@Z ENDP ; Eigen::internal::ldlt_inplace<1>::unblocked<Eigen::Matrix<double,-1,-1,0,-1,-1>,Eigen::Transpositions<-1,-1,int>,Eigen::Matrix<double,-1,1,0,-1,1> >