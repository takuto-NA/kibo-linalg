?run@?$general_matrix_vector_product@_JNV?$const_blas_data_mapper@N_J$00@internal@Eigen@@$00$0A@NV?$const_blas_data_mapper@N_J$0A@@23@$0A@$0A@@internal@Eigen@@SAX_J0AEBV?$const_blas_data_mapper@N_J$00@23@AEBV?$const_blas_data_mapper@N_J$0A@@23@PEAN0N@Z PROC ; Eigen::internal::general_matrix_vector_product<__int64,double,Eigen::internal::const_blas_data_mapper<double,__int64,1>,1,0,double,Eigen::internal::const_blas_data_mapper<double,__int64,0>,0,0>::run, COMDAT

; 303  :                                             ResScalar* res, Index resIncr, ResScalar alpha) {

$LN812:
	mov	rax, rsp
	mov	QWORD PTR [rax+32], r9
	mov	QWORD PTR [rax+8], rcx
	push	rbx
	push	rbp
	push	rsi
	push	rdi
	push	r12
	push	r13
	push	r14
	push	r15
	sub	rsp, 248				; 000000f8H

; 304  :   // The following copy tells the compiler that lhs's attributes are not modified outside this function
; 305  :   // This helps GCC to generate proper code.
; 306  :   LhsMapper lhs(alhs);

	mov	r10, QWORD PTR [r8+8]
	mov	rbx, rdx
	mov	rdi, QWORD PTR [r8]
	mov	rdx, rcx

; 307  : 
; 308  :   eigen_internal_assert(rhs.stride() == 1);
; 309  :   conj_helper<LhsScalar, RhsScalar, ConjugateLhs, ConjugateRhs> cj;
; 310  :   conj_helper<LhsPacket, RhsPacket, ConjugateLhs, ConjugateRhs> pcj;
; 311  :   conj_helper<LhsPacketHalf, RhsPacketHalf, ConjugateLhs, ConjugateRhs> pcj_half;
; 312  :   conj_helper<LhsPacketQuarter, RhsPacketQuarter, ConjugateLhs, ConjugateRhs> pcj_quarter;
; 313  : 
; 314  :   // TODO: fine tune the following heuristic. The rationale is that if the matrix is very large,
; 315  :   //       processing 8 rows at once might be counter productive wrt cache.
; 316  :   const Index n8 = lhs.stride() * sizeof(LhsScalar) > 32000 ? 0 : rows - 7;
; 317  :   const Index n4 = rows - 3;
; 318  :   const Index n2 = rows - 1;
; 319  : 
; 320  :   // TODO: for padded aligned inputs, we could enable aligned reads
; 321  :   enum {
; 322  :     LhsAlignment = Unaligned,
; 323  :     ResPacketSize = Traits::ResPacketSize,
; 324  :     ResPacketSizeHalf = HalfTraits::ResPacketSize,
; 325  :     ResPacketSizeQuarter = QuarterTraits::ResPacketSize,
; 326  :     LhsPacketSize = Traits::LhsPacketSize,
; 327  :     LhsPacketSizeHalf = HalfTraits::LhsPacketSize,
; 328  :     LhsPacketSizeQuarter = QuarterTraits::LhsPacketSize,
; 329  :     HasHalf = (int)ResPacketSizeHalf < (int)ResPacketSize,
; 330  :     HasQuarter = (int)ResPacketSizeQuarter < (int)ResPacketSizeHalf
; 331  :   };
; 332  : 
; 333  :   using UnsignedIndex = typename make_unsigned<Index>::type;
; 334  :   const Index fullColBlockEnd = LhsPacketSize * (UnsignedIndex(cols) / LhsPacketSize);
; 335  :   const Index halfColBlockEnd = LhsPacketSizeHalf * (UnsignedIndex(cols) / LhsPacketSizeHalf);
; 336  :   const Index quarterColBlockEnd = LhsPacketSizeQuarter * (UnsignedIndex(cols) / LhsPacketSizeQuarter);
; 337  : 
; 338  :   Index i = 0;

	mov	r13, QWORD PTR resIncr$[rsp]
	xor	esi, esi
	movaps	XMMWORD PTR [rax-184], xmm12
	mov	r8d, esi

; 339  :   for (; i < n8; i += 8) {

	movsd	xmm12, QWORD PTR alpha$[rsp]
	lea	rcx, QWORD PTR [r10*8]
	movaps	XMMWORD PTR [rax-88], xmm6
	cmp	rcx, 32000				; 00007d00H
	movaps	XMMWORD PTR [rax-104], xmm7
	mov	r14, r9
	movaps	XMMWORD PTR [rax-120], xmm8
	movaps	XMMWORD PTR [rax-136], xmm9
	movaps	XMMWORD PTR [rax-152], xmm10
	movaps	XMMWORD PTR [rax-168], xmm11
	lea	rax, QWORD PTR [rdx-7]
	cmovbe	r8, rax
	movaps	XMMWORD PTR [rsp+112], xmm13
	lea	rax, QWORD PTR [rdx-1]
	mov	QWORD PTR tv15209[rsp], r8
	mov	QWORD PTR n2$1$[rsp], rax
	mov	rdx, rbx
	shr	rdx, 1
	mov	rax, r13
	shl	rax, 5
	add	rdx, rdx
	mov	QWORD PTR $T2[rsp], rax
	test	r8, r8
	jle	$LN775@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	mov	rcx, QWORD PTR res$[rsp]
	lea	r14, QWORD PTR [r13*2]
	add	r14, r13
	lea	r15, QWORD PTR [r13*4]
	add	r15, r13
	shl	r14, 3
	mov	rax, r13
	shl	r15, 3
	shl	rax, 6
	lea	r8, QWORD PTR [rdi+rdx*8]
	mov	QWORD PTR tv15196[rsp], rax
	mov	r11, r13
	shl	r11, 4
	mov	rax, r10
	shl	rax, 6
	mov	r9, r13
	mov	QWORD PTR tv15195[rsp], rax
	add	rcx, r11
	mov	rax, r10
	mov	QWORD PTR tv15107[rsp], r11
	sub	rax, rdx
	mov	QWORD PTR tv15192[rsp], r8
	neg	r9
	mov	QWORD PTR tv15106[rsp], r14
	mov	ebp, 1
	mov	QWORD PTR tv15104[rsp], r15
	xorps	xmm7, xmm7
	mov	QWORD PTR $T3[rsp], rbp
	lea	r12, QWORD PTR [rax*8]
	mov	rax, r12
	mov	QWORD PTR tv15190[rsp], r12
	sub	rax, rdi
	mov	QWORD PTR tv15189[rsp], rax
	lea	rax, QWORD PTR [rdi+rdx*8]
	neg	rax
	mov	QWORD PTR tv15187[rsp], rax
	mov	rax, r13
	neg	rax
	shl	rax, 3
	shl	r9, 4
	mov	QWORD PTR tv15111[rsp], r9
	mov	QWORD PTR tv15109[rsp], rax
	npad	11
$LL4@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 340  :     ResPacket c0 = pset1<ResPacket>(ResScalar(0)), c1 = pset1<ResPacket>(ResScalar(0)),

	movaps	xmm2, xmm7
	movaps	xmm4, xmm7

; 341  :               c2 = pset1<ResPacket>(ResScalar(0)), c3 = pset1<ResPacket>(ResScalar(0)),

	movaps	xmm5, xmm7
	movaps	xmm6, xmm7

; 342  :               c4 = pset1<ResPacket>(ResScalar(0)), c5 = pset1<ResPacket>(ResScalar(0)),

	movaps	xmm9, xmm7
	movaps	xmm10, xmm7

; 343  :               c6 = pset1<ResPacket>(ResScalar(0)), c7 = pset1<ResPacket>(ResScalar(0));

	movaps	xmm11, xmm7
	movaps	xmm13, xmm7

; 345  :     for (Index j = 0; j < fullColBlockEnd; j += LhsPacketSize) {

	test	rdx, rdx
	jle	$LN6@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	mov	rax, QWORD PTR rhs$[rsp]
	lea	r11, QWORD PTR [r12+r8]
	mov	r9, rsi
	lea	r14, QWORD PTR [r10+r10]
	sub	r9, rbp
	lea	r15, QWORD PTR [r10+r10*2]
	lea	rbp, QWORD PTR [r10+r10*2]
	mov	rax, QWORD PTR [rax]
	lea	r12, QWORD PTR [r10*4]
	sub	rax, QWORD PTR tv15189[rsp]
	lea	r13, QWORD PTR [r10+r10*4]
	sub	rax, r8
	add	rbp, rbp
	lea	r8, QWORD PTR [rdx-1]
	sub	rax, rdi
	shr	r8, 1
	imul	r9, r10
	inc	r8
	npad	2
$LL7@run:

; 218  :     return ploadt<PacketT, AlignmentT>(&operator()(i, j));

	movups	xmm1, XMMWORD PTR [rax+r11]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [r11+r9*8]
	mulpd	xmm0, xmm1

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm2, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [r11]
	mulpd	xmm0, xmm1

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm4, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [r11+r10*8]
	mulpd	xmm0, xmm1

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm5, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [r11+r14*8]
	mulpd	xmm0, xmm1

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [r11+r15*8]
	mulpd	xmm0, xmm1

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm9, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [r11+r12*8]
	mulpd	xmm0, xmm1

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm10, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [r11+r13*8]
	mulpd	xmm0, xmm1

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm11, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [r11+rbp*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 345  :     for (Index j = 0; j < fullColBlockEnd; j += LhsPacketSize) {

	add	r11, 16
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm1

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm13, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 345  :     for (Index j = 0; j < fullColBlockEnd; j += LhsPacketSize) {

	sub	r8, 1
	jne	SHORT $LL7@run
	mov	r13, QWORD PTR resIncr$[rsp]
	mov	r8, QWORD PTR tv15192[rsp]
	mov	rax, QWORD PTR tv15109[rsp]
	mov	r9, QWORD PTR tv15111[rsp]
	mov	rbp, QWORD PTR $T3[rsp]
	mov	r11, QWORD PTR tv15107[rsp]
	mov	r14, QWORD PTR tv15106[rsp]
	mov	r15, QWORD PTR tv15104[rsp]
$LN6@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\Reductions.h

; 270  :     tmp = Op::packetOp(a, _mm_unpackhi_pd(a, a));

	movaps	xmm1, xmm2
	movaps	xmm3, xmm4
	unpckhpd xmm1, xmm2
	movaps	xmm8, xmm9
	unpckhpd xmm3, xmm4
	unpckhpd xmm8, xmm9
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm1, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\Reductions.h

; 270  :     tmp = Op::packetOp(a, _mm_unpackhi_pd(a, a));

	movaps	xmm2, xmm5
	unpckhpd xmm2, xmm5
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm3, xmm4
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\Reductions.h

; 270  :     tmp = Op::packetOp(a, _mm_unpackhi_pd(a, a));

	movaps	xmm4, xmm6
	unpckhpd xmm4, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm2, xmm5
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\Reductions.h

; 270  :     tmp = Op::packetOp(a, _mm_unpackhi_pd(a, a));

	movaps	xmm5, xmm10
	unpckhpd xmm5, xmm10
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm4, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\Reductions.h

; 270  :     tmp = Op::packetOp(a, _mm_unpackhi_pd(a, a));

	movaps	xmm6, xmm13
	unpckhpd xmm6, xmm13
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm9
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\Reductions.h

; 270  :     tmp = Op::packetOp(a, _mm_unpackhi_pd(a, a));

	movaps	xmm9, xmm11
	unpckhpd xmm9, xmm11
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm5, xmm10
	addpd	xmm6, xmm13
	addpd	xmm9, xmm11
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 366  :     for (Index j = fullColBlockEnd; j < cols; ++j) {

	cmp	rdx, rbx
	jge	$LN9@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	mov	rax, r8
	lea	r12, QWORD PTR [r10+r10*2]
	imul	r8, r10, 56				; 00000038H
	movaps	xmm0, xmm3
	movaps	xmm3, xmm1
	unpcklpd xmm3, xmm0
	movaps	xmm0, xmm4
	movaps	xmm4, xmm2
	unpcklpd xmm4, xmm0
	movaps	xmm0, xmm5
	movaps	xmm5, xmm8
	lea	r11, QWORD PTR [r10+r10*2]
	mov	QWORD PTR tv15113[rsp], r8
	lea	r14, QWORD PTR [r10+r10*4]
	mov	r8, QWORD PTR rhs$[rsp]
	mov	rbp, r10
	mov	r13, QWORD PTR tv15113[rsp]
	mov	r15, r10
	unpcklpd xmm5, xmm0
	add	rbp, rbp
	movaps	xmm0, xmm6
	shl	r15, 5
	mov	r8, QWORD PTR [r8]
	movaps	xmm6, xmm9
	sub	r8, QWORD PTR tv15187[rsp]
	add	r12, r12
	sub	r8, QWORD PTR tv15192[rsp]
	mov	r9, rbx
	sub	r8, rdi
	unpcklpd xmm6, xmm0
	sub	r9, rdx
	npad	1
$LL10@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 367  :       RhsScalar b0 = rhs(j, 0);

	movsd	xmm2, QWORD PTR [rax+r8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movaps	xmm1, xmm2
	movaps	xmm0, xmm2
	mulsd	xmm0, QWORD PTR [rax]
	mulsd	xmm1, QWORD PTR [rax+r10*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 369  :       cc0 += cj.pmul(lhs(i + 0, j), b0);

	unpcklpd xmm0, xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movaps	xmm1, xmm2
	mulsd	xmm1, QWORD PTR [rax+r11*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 369  :       cc0 += cj.pmul(lhs(i + 0, j), b0);

	addpd	xmm3, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movaps	xmm0, xmm2
	mulsd	xmm0, QWORD PTR [rax+rbp*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 371  :       cc2 += cj.pmul(lhs(i + 2, j), b0);

	unpcklpd xmm0, xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movaps	xmm1, xmm2
	mulsd	xmm1, QWORD PTR [rax+r14*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 371  :       cc2 += cj.pmul(lhs(i + 2, j), b0);

	addpd	xmm4, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movaps	xmm0, xmm2
	mulsd	xmm0, QWORD PTR [rax+r15]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 373  :       cc4 += cj.pmul(lhs(i + 4, j), b0);

	unpcklpd xmm0, xmm1
	addpd	xmm5, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movaps	xmm0, xmm2
	mulsd	xmm2, QWORD PTR [rax+r12*8]
	mulsd	xmm0, QWORD PTR [rax+r13]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 366  :     for (Index j = fullColBlockEnd; j < cols; ++j) {

	add	rax, 8

; 374  :       cc5 += cj.pmul(lhs(i + 5, j), b0);
; 375  :       cc6 += cj.pmul(lhs(i + 6, j), b0);

	movaps	xmm1, xmm2
	unpcklpd xmm1, xmm0
	addpd	xmm6, xmm1
	sub	r9, 1
	jne	SHORT $LL10@run
	mov	r13, QWORD PTR resIncr$[rsp]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	movaps	xmm1, xmm3
	mov	r8, QWORD PTR tv15192[rsp]
	movaps	xmm2, xmm4
	mov	rax, QWORD PTR tv15109[rsp]
	movaps	xmm8, xmm5
	mov	r9, QWORD PTR tv15111[rsp]
	movaps	xmm9, xmm6
	mov	rbp, QWORD PTR $T3[rsp]
	mov	r11, QWORD PTR tv15107[rsp]
	mov	r14, QWORD PTR tv15106[rsp]
	mov	r15, QWORD PTR tv15104[rsp]
	unpckhpd xmm3, xmm3
	unpckhpd xmm4, xmm4
	unpckhpd xmm5, xmm5
	unpckhpd xmm6, xmm6
$LN9@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 384  :     res[(i + 6) * resIncr] += alpha * cc6;

	mov	r12, QWORD PTR $T2[rsp]
	add	rbp, 8
	add	r8, QWORD PTR tv15195[rsp]
	add	rsi, 8
	mulsd	xmm1, xmm12
	mov	QWORD PTR tv15192[rsp], r8
	mulsd	xmm3, xmm12
	mov	QWORD PTR $T3[rsp], rbp
	mulsd	xmm2, xmm12
	addsd	xmm1, QWORD PTR [rcx+r9]
	mulsd	xmm4, xmm12
	mulsd	xmm8, xmm12
	movsd	QWORD PTR [rcx+r9], xmm1
	addsd	xmm3, QWORD PTR [rax+rcx]
	mulsd	xmm5, xmm12
	mulsd	xmm9, xmm12
	movsd	QWORD PTR [rax+rcx], xmm3
	addsd	xmm2, QWORD PTR [rcx]

; 385  :     res[(i + 7) * resIncr] += alpha * cc7;

	mulsd	xmm6, xmm12
	movsd	QWORD PTR [rcx], xmm2
	addsd	xmm4, QWORD PTR [rcx+r13*8]
	movsd	QWORD PTR [rcx+r13*8], xmm4
	addsd	xmm8, QWORD PTR [r11+rcx]
	movsd	QWORD PTR [r11+rcx], xmm8
	addsd	xmm5, QWORD PTR [r14+rcx]
	movsd	QWORD PTR [r14+rcx], xmm5
	addsd	xmm9, QWORD PTR [r12+rcx]
	movsd	QWORD PTR [r12+rcx], xmm9
	addsd	xmm6, QWORD PTR [r15+rcx]
	mov	r12, QWORD PTR tv15190[rsp]
	movsd	QWORD PTR [r15+rcx], xmm6
	add	rcx, QWORD PTR tv15196[rsp]
	cmp	rsi, QWORD PTR tv15209[rsp]
	jl	$LL4@run
	mov	r14, QWORD PTR rhs$[rsp]
	jmp	SHORT $LN3@run
$LN775@run:
	mov	QWORD PTR $T2[rsp], rax
$LN3@run:

; 386  :   }
; 387  :   for (; i < n4; i += 4) {

	mov	rax, QWORD PTR rows$[rsp]
	mov	r12d, 16
	add	rax, -3
	cmp	rsi, rax
	jge	$LN12@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	mov	rcx, QWORD PTR res$[rsp]
	lea	r9, QWORD PTR [rsi+1]
	mov	rax, r10
	mov	QWORD PTR $T1[rsp], r9
	shl	rax, 5
	lea	r15, QWORD PTR [rsi+1]
	mov	QWORD PTR tv15176[rsp], rax
	mov	r8, r9
	imul	r8, r10
	imul	r15, r10
	xorps	xmm13, xmm13
	mov	rax, rsi
	mov	QWORD PTR tv15178[rsp], r8
	imul	rax, r13
	shl	r15, 3
	lea	r11, QWORD PTR [rcx+rax*8]
	mov	rax, r10
	neg	rax
	mov	ecx, r12d
	shl	rax, 5
	sub	rcx, r15
	mov	QWORD PTR tv15173[rsp], rax
	sub	rcx, rdi
	lea	rax, QWORD PTR [rdx+1]
	mov	QWORD PTR tv15166[rsp], rcx
	add	rax, r8
	lea	rbp, QWORD PTR [rdi+rax*8]
	mov	rax, r13
	shl	rax, 4
	mov	QWORD PTR tv15083[rsp], rax
	lea	rax, QWORD PTR [r13*2]
	add	rax, r13
	mov	QWORD PTR tv15165[rsp], rbp
	shl	rax, 3
	mov	QWORD PTR tv15082[rsp], rax
	npad	4
$LL13@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 388  :     ResPacket c0 = pset1<ResPacket>(ResScalar(0)), c1 = pset1<ResPacket>(ResScalar(0)),

	movaps	xmm2, xmm13
	movaps	xmm3, xmm13

; 389  :               c2 = pset1<ResPacket>(ResScalar(0)), c3 = pset1<ResPacket>(ResScalar(0));

	movaps	xmm4, xmm13
	movaps	xmm5, xmm13

; 391  :     for (Index j = 0; j < fullColBlockEnd; j += LhsPacketSize) {

	test	rdx, rdx
	jle	$LN15@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	mov	r8, rsi
	lea	rcx, QWORD PTR [rdx-1]
	sub	r8, r9
	shr	rcx, 1
	mov	r9, QWORD PTR [r14]
	lea	rax, QWORD PTR [r15+rdi]
	sub	r9, r15
	lea	rbp, QWORD PTR [r10+r10]
	sub	r9, rdi
	imul	r8, r10
	inc	rcx
	npad	2
$LL16@run:

; 218  :     return ploadt<PacketT, AlignmentT>(&operator()(i, j));

	movups	xmm1, XMMWORD PTR [rax+r9]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rax+r8*8]
	mulpd	xmm0, xmm1

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm2, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rax]
	mulpd	xmm0, xmm1

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm3, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rax+r10*8]
	mulpd	xmm0, xmm1

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm4, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rax+rbp*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 391  :     for (Index j = 0; j < fullColBlockEnd; j += LhsPacketSize) {

	add	rax, 16
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm1

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm5, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 391  :     for (Index j = 0; j < fullColBlockEnd; j += LhsPacketSize) {

	sub	rcx, 1
	jne	SHORT $LL16@run
	mov	rcx, QWORD PTR tv15166[rsp]
	mov	r8, QWORD PTR tv15178[rsp]
	mov	r9, QWORD PTR $T1[rsp]
	mov	rbp, QWORD PTR tv15165[rsp]
$LN15@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\Reductions.h

; 270  :     tmp = Op::packetOp(a, _mm_unpackhi_pd(a, a));

	movaps	xmm8, xmm2
	movaps	xmm9, xmm3
	unpckhpd xmm8, xmm2
	movaps	xmm10, xmm4
	unpckhpd xmm9, xmm3
	movaps	xmm11, xmm5
	unpckhpd xmm10, xmm4
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 404  :     for (Index j = fullColBlockEnd; j < cols; ++j) {

	mov	r12, rdx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\Reductions.h

; 270  :     tmp = Op::packetOp(a, _mm_unpackhi_pd(a, a));

	unpckhpd xmm11, xmm5
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm2
	addpd	xmm9, xmm3
	addpd	xmm10, xmm4
	addpd	xmm11, xmm5
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 404  :     for (Index j = fullColBlockEnd; j < cols; ++j) {

	cmp	rdx, rbx
	jge	$LN713@run
	mov	r8, QWORD PTR [r14]
	mov	rax, rbx
	sub	rax, rdx
	cmp	rax, 4
	jl	$LC714@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	add	rcx, r8
	lea	r14, QWORD PTR [r10+r10]
	mov	QWORD PTR tv15094[rsp], rcx
	mov	rax, rbp
	mov	r13, QWORD PTR tv15094[rsp]
	mov	rcx, rbx
	sub	rcx, rdx
	mov	r9, r8
	sub	rcx, 4
	sub	r9, r15
	mov	rbp, r10
	shr	rcx, 2
	neg	rbp
	sub	r9, rdi
	inc	rcx
	lea	r12, QWORD PTR [rdx+rcx*4]
	npad	8
$LL715@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 405  :       RhsScalar b0 = rhs(j, 0);

	movsd	xmm7, QWORD PTR [rax+r9-8]
	movsd	xmm4, QWORD PTR [rax+r9]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movaps	xmm2, xmm7
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 405  :       RhsScalar b0 = rhs(j, 0);

	movsd	xmm5, QWORD PTR [rax+r9+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movaps	xmm0, xmm4
	mulsd	xmm0, QWORD PTR [rax+rbp*8]
	movaps	xmm1, xmm5
	mulsd	xmm1, QWORD PTR [rax+rbp*8+8]
	movaps	xmm3, xmm7
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 405  :       RhsScalar b0 = rhs(j, 0);

	movsd	xmm6, QWORD PTR [rax+r13]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	mulsd	xmm2, QWORD PTR [rax+rbp*8-8]
	mulsd	xmm3, QWORD PTR [rax-8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 407  :       cc0 += cj.pmul(lhs(i + 0, j), b0);

	addsd	xmm8, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movaps	xmm2, xmm7
	mulsd	xmm2, QWORD PTR [rax+r10*8-8]
	mulsd	xmm7, QWORD PTR [rax+r14*8-8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 408  :       cc1 += cj.pmul(lhs(i + 1, j), b0);

	addsd	xmm9, xmm3
	addsd	xmm8, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movaps	xmm0, xmm6
	mulsd	xmm0, QWORD PTR [rax+rbp*8+16]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 409  :       cc2 += cj.pmul(lhs(i + 2, j), b0);

	addsd	xmm10, xmm2

; 410  :       cc3 += cj.pmul(lhs(i + 3, j), b0);

	addsd	xmm11, xmm7
	addsd	xmm8, xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movaps	xmm1, xmm5
	mulsd	xmm1, QWORD PTR [rax+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 407  :       cc0 += cj.pmul(lhs(i + 0, j), b0);

	addsd	xmm8, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movaps	xmm0, xmm4
	mulsd	xmm0, QWORD PTR [rax]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 408  :       cc1 += cj.pmul(lhs(i + 1, j), b0);

	addsd	xmm9, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movaps	xmm0, xmm6
	mulsd	xmm0, QWORD PTR [rax+16]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 408  :       cc1 += cj.pmul(lhs(i + 1, j), b0);

	addsd	xmm9, xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movaps	xmm1, xmm5
	mulsd	xmm1, QWORD PTR [rax+r10*8+8]
	mulsd	xmm5, QWORD PTR [rax+r14*8+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 408  :       cc1 += cj.pmul(lhs(i + 1, j), b0);

	addsd	xmm9, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movaps	xmm0, xmm4
	mulsd	xmm0, QWORD PTR [rax+r10*8]
	mulsd	xmm4, QWORD PTR [rax+r14*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 409  :       cc2 += cj.pmul(lhs(i + 2, j), b0);

	addsd	xmm10, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movaps	xmm0, xmm6
	mulsd	xmm0, QWORD PTR [rax+r10*8+16]
	mulsd	xmm6, QWORD PTR [rax+r14*8+16]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 410  :       cc3 += cj.pmul(lhs(i + 3, j), b0);

	addsd	xmm11, xmm4
	add	rax, 32					; 00000020H
	addsd	xmm10, xmm1
	addsd	xmm11, xmm5
	addsd	xmm10, xmm0
	addsd	xmm11, xmm6
	sub	rcx, 1
	jne	$LL715@run

; 404  :     for (Index j = fullColBlockEnd; j < cols; ++j) {

	mov	r13, QWORD PTR resIncr$[rsp]
	cmp	r12, rbx
	jge	SHORT $LN809@run
$LC714@run:
	mov	rax, QWORD PTR tv15178[rsp]
	lea	rbp, QWORD PTR [r10+r10]
	add	rax, r12
	sub	r8, r15
	mov	r9, r10
	sub	r8, rdi
	neg	r9
	lea	rcx, QWORD PTR [rdi+rax*8]
	mov	rax, rbx
	sub	rax, r12
$LC19@run:

; 405  :       RhsScalar b0 = rhs(j, 0);

	movsd	xmm2, QWORD PTR [rcx+r8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movaps	xmm0, xmm2
	movaps	xmm1, xmm2
	mulsd	xmm0, QWORD PTR [rcx+r9*8]
	mulsd	xmm1, QWORD PTR [rcx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 407  :       cc0 += cj.pmul(lhs(i + 0, j), b0);

	addsd	xmm8, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movaps	xmm0, xmm2
	mulsd	xmm0, QWORD PTR [rcx+r10*8]
	mulsd	xmm2, QWORD PTR [rcx+rbp*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 408  :       cc1 += cj.pmul(lhs(i + 1, j), b0);

	addsd	xmm9, xmm1
	add	rcx, 8

; 409  :       cc2 += cj.pmul(lhs(i + 2, j), b0);

	addsd	xmm10, xmm0

; 410  :       cc3 += cj.pmul(lhs(i + 3, j), b0);

	addsd	xmm11, xmm2
	sub	rax, 1
	jne	SHORT $LC19@run
$LN809@run:

; 411  :     }
; 412  :     res[(i + 0) * resIncr] += alpha * cc0;

	mov	rbp, QWORD PTR tv15165[rsp]
	mov	r9, QWORD PTR $T1[rsp]
	mov	r8, QWORD PTR tv15178[rsp]
	mov	rcx, QWORD PTR tv15166[rsp]
$LN713@run:

; 413  :     res[(i + 1) * resIncr] += alpha * cc1;
; 414  :     res[(i + 2) * resIncr] += alpha * cc2;

	mov	r12, QWORD PTR tv15083[rsp]
	lea	rax, QWORD PTR [r10*4]
	add	rcx, QWORD PTR tv15173[rsp]
	add	r8, rax
	add	rbp, QWORD PTR tv15176[rsp]
	add	r9, 4
	mov	rax, QWORD PTR rows$[rsp]
	add	rsi, 4
	add	r15, QWORD PTR tv15176[rsp]
	add	rax, -3
	mov	r14, QWORD PTR rhs$[rsp]
	mulsd	xmm8, xmm12
	mov	QWORD PTR tv15166[rsp], rcx
	mulsd	xmm9, xmm12
	mov	QWORD PTR tv15165[rsp], rbp
	mulsd	xmm10, xmm12
	mov	QWORD PTR tv15178[rsp], r8
	addsd	xmm8, QWORD PTR [r11]

; 415  :     res[(i + 3) * resIncr] += alpha * cc3;

	mulsd	xmm11, xmm12
	mov	QWORD PTR $T1[rsp], r9
	movsd	QWORD PTR [r11], xmm8
	addsd	xmm9, QWORD PTR [r11+r13*8]
	movsd	QWORD PTR [r11+r13*8], xmm9
	addsd	xmm10, QWORD PTR [r12+r11]
	movsd	QWORD PTR [r12+r11], xmm10
	mov	r12, QWORD PTR tv15082[rsp]
	addsd	xmm11, QWORD PTR [r12+r11]
	movsd	QWORD PTR [r12+r11], xmm11
	add	r11, QWORD PTR $T2[rsp]
	cmp	rsi, rax
	jl	$LL13@run
	mov	r12d, 16
$LN12@run:
	movaps	xmm13, XMMWORD PTR [rsp+112]

; 416  :   }
; 417  :   for (; i < n2; i += 2) {

	movaps	xmm11, XMMWORD PTR [rsp+144]
	movaps	xmm10, XMMWORD PTR [rsp+160]
	cmp	rsi, QWORD PTR n2$1$[rsp]
	jge	$LN21@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	mov	rcx, QWORD PTR resIncr$[rsp]
	lea	r9, QWORD PTR [rsi+1]
	mov	r8, QWORD PTR res$[rsp]
	lea	r14, QWORD PTR [rsi+1]
	imul	r14, r10
	xorps	xmm9, xmm9
	mov	rax, rcx
	mov	QWORD PTR $T4[rsp], r9
	shl	rax, 4
	mov	r13, r9
	mov	QWORD PTR tv15154[rsp], rax
	mov	r11, r10
	shl	r14, 3
	mov	rax, rsi
	imul	rax, rcx
	imul	r13, r10
	sub	r12, r14
	shl	r11, 4
	lea	rbp, QWORD PTR [r8+rax*8]
	mov	QWORD PTR tv15153[rsp], r11
	sub	r12, rdi
	lea	r8, QWORD PTR [rdx+1]
	mov	rax, r10
	mov	QWORD PTR tv15143[rsp], r12
	neg	rax
	shl	rax, 4
	add	r8, r13
	mov	QWORD PTR tv15150[rsp], rax
	lea	r8, QWORD PTR [rdi+r8*8]
	mov	QWORD PTR tv15142[rsp], r8
	npad	2
$LL22@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 418  :     ResPacket c0 = pset1<ResPacket>(ResScalar(0)), c1 = pset1<ResPacket>(ResScalar(0));

	movaps	xmm2, xmm9
	movaps	xmm3, xmm9

; 420  :     for (Index j = 0; j < fullColBlockEnd; j += LhsPacketSize) {

	test	rdx, rdx
	jle	SHORT $LN24@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	mov	rcx, QWORD PTR rhs$[rsp]
	lea	rax, QWORD PTR [r14+rdi]
	mov	r8, rsi
	sub	r8, r9
	imul	r8, r10
	mov	r9, QWORD PTR [rcx]
	lea	rcx, QWORD PTR [rdx-1]
	sub	r9, r14
	shr	rcx, 1
	sub	r9, rdi
	inc	rcx
	npad	10
$LL25@run:

; 218  :     return ploadt<PacketT, AlignmentT>(&operator()(i, j));

	movups	xmm1, XMMWORD PTR [rax+r9]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rax+r8*8]
	mulpd	xmm0, xmm1

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm2, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rax]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 420  :     for (Index j = 0; j < fullColBlockEnd; j += LhsPacketSize) {

	add	rax, 16
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm1

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm3, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 420  :     for (Index j = 0; j < fullColBlockEnd; j += LhsPacketSize) {

	sub	rcx, 1
	jne	SHORT $LL25@run
	mov	rcx, QWORD PTR resIncr$[rsp]
	mov	r9, QWORD PTR $T4[rsp]
	mov	r8, QWORD PTR tv15142[rsp]
$LN24@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\Reductions.h

; 270  :     tmp = Op::packetOp(a, _mm_unpackhi_pd(a, a));

	movaps	xmm7, xmm2
	movaps	xmm8, xmm3
	unpckhpd xmm7, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 429  :     for (Index j = fullColBlockEnd; j < cols; ++j) {

	mov	r15, rdx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\Reductions.h

; 270  :     tmp = Op::packetOp(a, _mm_unpackhi_pd(a, a));

	unpckhpd xmm8, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm2
	addpd	xmm8, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 429  :     for (Index j = fullColBlockEnd; j < cols; ++j) {

	cmp	rdx, rbx
	jge	$LN716@run
	mov	rax, QWORD PTR rhs$[rsp]
	mov	r9, QWORD PTR [rax]
	mov	rax, rbx
	sub	rax, rdx
	cmp	rax, 4
	jl	$LN777@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	mov	rax, r8
	mov	rcx, rbx
	sub	rcx, rdx
	mov	r11, r9
	sub	rcx, 4
	sub	r11, r14
	mov	r8, r10
	shr	rcx, 2
	neg	r8
	add	r12, r9
	sub	r11, rdi
	inc	rcx
	lea	r15, QWORD PTR [rdx+rcx*4]
	npad	7
$LL718@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 430  :       RhsScalar b0 = rhs(j, 0);

	movsd	xmm6, QWORD PTR [r11+rax-8]
	movsd	xmm3, QWORD PTR [r11+rax]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movaps	xmm2, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 430  :       RhsScalar b0 = rhs(j, 0);

	movsd	xmm4, QWORD PTR [r11+rax+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movaps	xmm0, xmm3
	mulsd	xmm0, QWORD PTR [rax+r8*8]
	movaps	xmm1, xmm4
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 430  :       RhsScalar b0 = rhs(j, 0);

	movsd	xmm5, QWORD PTR [r12+rax]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	mulsd	xmm2, QWORD PTR [rax+r8*8-8]
	mulsd	xmm6, QWORD PTR [rax-8]
	mulsd	xmm3, QWORD PTR [rax]
	mulsd	xmm1, QWORD PTR [rax+r8*8+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 432  :       cc0 += cj.pmul(lhs(i + 0, j), b0);

	addsd	xmm7, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	mulsd	xmm4, QWORD PTR [rax+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 433  :       cc1 += cj.pmul(lhs(i + 1, j), b0);

	addsd	xmm8, xmm6
	addsd	xmm7, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movaps	xmm0, xmm5
	mulsd	xmm0, QWORD PTR [rax+r8*8+16]
	mulsd	xmm5, QWORD PTR [rax+16]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 433  :       cc1 += cj.pmul(lhs(i + 1, j), b0);

	addsd	xmm8, xmm3
	add	rax, 32					; 00000020H
	addsd	xmm7, xmm1
	addsd	xmm8, xmm4
	addsd	xmm7, xmm0
	addsd	xmm8, xmm5
	sub	rcx, 1
	jne	$LL718@run

; 429  :     for (Index j = fullColBlockEnd; j < cols; ++j) {

	mov	r11, QWORD PTR tv15153[rsp]
	mov	r12, QWORD PTR tv15143[rsp]
	cmp	r15, rbx
	jge	SHORT $LN810@run
$LN777@run:
	lea	rax, QWORD PTR [r15+r13]
	sub	r9, r14
	lea	rcx, QWORD PTR [rdi+rax*8]
	mov	r8, r10
	mov	rax, rbx
	neg	r8
	sub	r9, rdi
	sub	rax, r15
$LC28@run:

; 430  :       RhsScalar b0 = rhs(j, 0);

	movsd	xmm1, QWORD PTR [rcx+r9]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movaps	xmm0, xmm1
	mulsd	xmm1, QWORD PTR [rcx]
	mulsd	xmm0, QWORD PTR [rcx+r8*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 429  :     for (Index j = fullColBlockEnd; j < cols; ++j) {

	add	rcx, 8

; 433  :       cc1 += cj.pmul(lhs(i + 1, j), b0);

	addsd	xmm8, xmm1
	addsd	xmm7, xmm0
	sub	rax, 1
	jne	SHORT $LC28@run
$LN810@run:

; 434  :     }
; 435  :     res[(i + 0) * resIncr] += alpha * cc0;

	mov	r8, QWORD PTR tv15142[rsp]
	mov	r9, QWORD PTR $T4[rsp]
	mov	rcx, QWORD PTR resIncr$[rsp]
$LN716@run:

; 416  :   }
; 417  :   for (; i < n2; i += 2) {

	add	r12, QWORD PTR tv15150[rsp]
	lea	r13, QWORD PTR [r13+r10*2]
	add	r8, r11

; 434  :     }
; 435  :     res[(i + 0) * resIncr] += alpha * cc0;

	mulsd	xmm7, xmm12
	add	r9, 2
	add	rsi, 2

; 436  :     res[(i + 1) * resIncr] += alpha * cc1;

	mulsd	xmm8, xmm12
	add	r14, r11
	mov	QWORD PTR tv15143[rsp], r12
	mov	QWORD PTR tv15142[rsp], r8
	addsd	xmm7, QWORD PTR [rbp]
	mov	QWORD PTR $T4[rsp], r9
	movsd	QWORD PTR [rbp], xmm7
	addsd	xmm8, QWORD PTR [rbp+rcx*8]
	movsd	QWORD PTR [rbp+rcx*8], xmm8
	add	rbp, QWORD PTR tv15154[rsp]
	cmp	rsi, QWORD PTR n2$1$[rsp]
	jl	$LL22@run
	mov	r13, QWORD PTR resIncr$[rsp]
$LN21@run:
	movaps	xmm9, XMMWORD PTR [rsp+176]

; 437  :   }
; 438  :   for (; i < rows; ++i) {

	movaps	xmm8, XMMWORD PTR [rsp+192]
	movaps	xmm7, XMMWORD PTR [rsp+208]
	movaps	xmm6, XMMWORD PTR [rsp+224]
	cmp	rsi, QWORD PTR rows$[rsp]
	jge	$LN30@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	mov	rcx, QWORD PTR res$[rsp]
	lea	r14, QWORD PTR [r13*8]
	mov	rax, rsi
	lea	r15, QWORD PTR [r10*8]
	imul	rax, r13
	xorps	xmm3, xmm3
	mov	r13, QWORD PTR rows$[rsp]
	lea	r12, QWORD PTR [rdi+rdx*8]
	mov	r11, r10
	imul	r11, rsi
	lea	rbp, QWORD PTR [rcx+rax*8]
	shl	r11, 3
	sub	r13, rsi
	npad	12
$LL31@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 443  :     for (Index j = 0; j < fullColBlockEnd; j += LhsPacketSize) {

	mov	r9, QWORD PTR rhs$[rsp]
	movaps	xmm2, xmm3
	test	rdx, rdx
	jle	SHORT $LN33@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	mov	rax, QWORD PTR [r9]
	lea	rcx, QWORD PTR [rdx-1]
	mov	r8, r11
	shr	rcx, 1
	sub	r8, rax
	add	r8, rdi
	inc	rcx
	npad	10
$LL34@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm1, XMMWORD PTR [rax+r8]
	movups	xmm0, XMMWORD PTR [rax]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 443  :     for (Index j = 0; j < fullColBlockEnd; j += LhsPacketSize) {

	add	rax, 16
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm1, xmm0

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm2, xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 443  :     for (Index j = 0; j < fullColBlockEnd; j += LhsPacketSize) {

	sub	rcx, 1
	jne	SHORT $LL34@run
$LN33@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\Reductions.h

; 270  :     tmp = Op::packetOp(a, _mm_unpackhi_pd(a, a));

	movaps	xmm1, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 462  :     for (Index j = quarterColBlockEnd; j < cols; ++j) {

	mov	rsi, rdx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\Reductions.h

; 270  :     tmp = Op::packetOp(a, _mm_unpackhi_pd(a, a));

	unpckhpd xmm1, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm1, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 462  :     for (Index j = quarterColBlockEnd; j < cols; ++j) {

	cmp	rdx, rbx
	jge	$LN719@run
	mov	r10, QWORD PTR [r9]
	mov	rax, rbx
	sub	rax, rdx
	cmp	rax, 4
	jl	SHORT $LC720@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	lea	rax, QWORD PTR [r11+16]
	mov	r9, r10
	lea	rcx, QWORD PTR [rax+r12]
	sub	r9, rdi
	sub	r9, rax
	mov	r8, r10
	sub	r8, r11
	mov	rax, rbx
	sub	rax, rdx
	sub	r8, rdi
	sub	rax, 4
	shr	rax, 2
	inc	rax
	lea	rsi, QWORD PTR [rdx+rax*4]
	npad	1
$LL721@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movsd	xmm2, QWORD PTR [r9+rcx]
	mulsd	xmm2, QWORD PTR [rcx-16]
	movsd	xmm0, QWORD PTR [r8+rcx-8]
	mulsd	xmm0, QWORD PTR [rcx-8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 463  :       cc0 += cj.pmul(lhs(i, j), rhs(j, 0));

	addsd	xmm2, xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movsd	xmm1, QWORD PTR [rcx]
	mulsd	xmm1, QWORD PTR [r8+rcx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 463  :       cc0 += cj.pmul(lhs(i, j), rhs(j, 0));

	addsd	xmm2, xmm0
	addsd	xmm2, xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movsd	xmm1, QWORD PTR [r8+rcx+8]
	mulsd	xmm1, QWORD PTR [rcx+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 463  :       cc0 += cj.pmul(lhs(i, j), rhs(j, 0));

	add	rcx, 32					; 00000020H
	addsd	xmm1, xmm2
	sub	rax, 1
	jne	SHORT $LL721@run

; 462  :     for (Index j = quarterColBlockEnd; j < cols; ++j) {

	cmp	rsi, rbx
	jge	SHORT $LN719@run
$LC720@run:
	mov	r8, r11
	lea	rax, QWORD PTR [r10+rsi*8]
	sub	r8, r10
	mov	rcx, rbx
	add	r8, rdi
	sub	rcx, rsi
$LC765@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movsd	xmm0, QWORD PTR [rax+r8]
	mulsd	xmm0, QWORD PTR [rax]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 462  :     for (Index j = quarterColBlockEnd; j < cols; ++j) {

	add	rax, 8

; 463  :       cc0 += cj.pmul(lhs(i, j), rhs(j, 0));

	addsd	xmm1, xmm0
	sub	rcx, 1
	jne	SHORT $LC765@run
$LN719@run:

; 464  :     }
; 465  :     res[i * resIncr] += alpha * cc0;

	mulsd	xmm1, xmm12
	add	r11, r15
	addsd	xmm1, QWORD PTR [rbp]
	movsd	QWORD PTR [rbp], xmm1
	add	rbp, r14
	sub	r13, 1
	jne	$LL31@run
$LN30@run:

; 466  :   }
; 467  : }

	movaps	xmm12, XMMWORD PTR [rsp+128]
	add	rsp, 248				; 000000f8H
	pop	r15
	pop	r14
	pop	r13
	pop	r12
	pop	rdi
	pop	rsi
	pop	rbp
	pop	rbx
	ret	0
?run@?$general_matrix_vector_product@_JNV?$const_blas_data_mapper@N_J$00@internal@Eigen@@$00$0A@NV?$const_blas_data_mapper@N_J$0A@@23@$0A@$0A@@internal@Eigen@@SAX_J0AEBV?$const_blas_data_mapper@N_J$00@23@AEBV?$const_blas_data_mapper@N_J$0A@@23@PEAN0N@Z ENDP ; Eigen::internal::general_matrix_vector_product<__int64,double,Eigen::internal::const_blas_data_mapper<double,__int64,1>,1,0,double,Eigen::internal::const_blas_data_mapper<double,__int64,0>,0,0>::run