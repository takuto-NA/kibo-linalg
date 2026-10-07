?run@?$general_matrix_vector_product@_JNV?$const_blas_data_mapper@N_J$0A@@internal@Eigen@@$0A@$0A@NV?$const_blas_data_mapper@N_J$00@23@$0A@$0A@@internal@Eigen@@SAX_J0AEBV?$const_blas_data_mapper@N_J$0A@@23@AEBV?$const_blas_data_mapper@N_J$00@23@PEAN0N@Z PROC ; Eigen::internal::general_matrix_vector_product<__int64,double,Eigen::internal::const_blas_data_mapper<double,__int64,0>,0,0,double,Eigen::internal::const_blas_data_mapper<double,__int64,1>,0,0>::run, COMDAT

; 110  :                                             ResScalar* res, Index resIncr, RhsScalar alpha) {

$LN784:
	mov	QWORD PTR [rsp+32], r9
	mov	QWORD PTR [rsp+16], rdx
	mov	QWORD PTR [rsp+8], rcx
	push	rbx
	push	r12
	push	r15
	sub	rsp, 320				; 00000140H

; 111  :   EIGEN_UNUSED_VARIABLE(resIncr);
; 112  :   eigen_internal_assert(resIncr == 1);
; 113  : 
; 114  :   // The following copy tells the compiler that lhs's attributes are not modified outside this function
; 115  :   // This helps GCC to generate proper code.
; 116  :   LhsMapper lhs(alhs);

	movups	xmm0, XMMWORD PTR [r8]

; 117  : 
; 118  :   conj_helper<LhsScalar, RhsScalar, ConjugateLhs, ConjugateRhs> cj;
; 119  :   conj_helper<LhsPacket, RhsPacket, ConjugateLhs, ConjugateRhs> pcj;
; 120  :   conj_helper<LhsPacketHalf, RhsPacketHalf, ConjugateLhs, ConjugateRhs> pcj_half;
; 121  :   conj_helper<LhsPacketQuarter, RhsPacketQuarter, ConjugateLhs, ConjugateRhs> pcj_quarter;
; 122  : 
; 123  :   const Index lhsStride = lhs.stride();
; 124  :   // TODO: for padded aligned inputs, we could enable aligned reads
; 125  :   enum {
; 126  :     LhsAlignment = Unaligned,
; 127  :     ResPacketSize = Traits::ResPacketSize,
; 128  :     ResPacketSizeHalf = HalfTraits::ResPacketSize,
; 129  :     ResPacketSizeQuarter = QuarterTraits::ResPacketSize,
; 130  :     LhsPacketSize = Traits::LhsPacketSize,
; 131  :     HasHalf = (int)ResPacketSizeHalf < (int)ResPacketSize,
; 132  :     HasQuarter = (int)ResPacketSizeQuarter < (int)ResPacketSizeHalf
; 133  :   };
; 134  : 
; 135  :   const Index n8 = rows - 8 * ResPacketSize + 1;
; 136  :   const Index n4 = rows - 4 * ResPacketSize + 1;
; 137  :   const Index n3 = rows - 3 * ResPacketSize + 1;
; 138  :   const Index n2 = rows - 2 * ResPacketSize + 1;
; 139  :   const Index n1 = rows - 1 * ResPacketSize + 1;
; 140  :   const Index n_half = rows - 1 * ResPacketSizeHalf + 1;
; 141  :   const Index n_quarter = rows - 1 * ResPacketSizeQuarter + 1;
; 142  : 
; 143  :   // TODO: improve the following heuristic:
; 144  :   const Index block_cols = cols < 128 ? cols : (lhsStride * sizeof(LhsScalar) < 32000 ? 16 : 4);

	mov	rbx, QWORD PTR [r8+8]
	lea	r15, QWORD PTR [rcx-15]
	mov	rax, rdx
	movaps	XMMWORD PTR [rsp+160], xmm12
	lea	rdx, QWORD PTR [rcx-5]
	movaps	XMMWORD PTR [rsp+144], xmm13
	movsd	xmm13, QWORD PTR alpha$[rsp]
	lea	r12, QWORD PTR [rcx-7]
	mov	QWORD PTR n3$1$[rsp], rdx
	movaps	xmm12, xmm13
	lea	rdx, QWORD PTR [rcx-3]
	mov	QWORD PTR n8$1$[rsp], r15
	dec	rcx
	mov	QWORD PTR n4$1$[rsp], r12
	mov	QWORD PTR n2$1$[rsp], rdx
	mov	QWORD PTR n1$1$[rsp], rcx
	mov	QWORD PTR lhs$2$[rsp], rbx
	unpcklpd xmm12, xmm12
	movups	XMMWORD PTR lhs$[rsp], xmm0
	cmp	rax, 128				; 00000080H
	jge	SHORT $LN42@run

; 149  :   for (Index j2 = 0; j2 < cols; j2 += block_cols) {

	xor	r11d, r11d
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	mov	QWORD PTR tv15721[rsp], rax
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 149  :   for (Index j2 = 0; j2 < cols; j2 += block_cols) {

	mov	QWORD PTR j2$1$[rsp], r11
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	mov	r10, rax
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 149  :   for (Index j2 = 0; j2 < cols; j2 += block_cols) {

	mov	QWORD PTR block_cols$1$[rsp], rax
	mov	rdx, rax
	test	rax, rax
	jle	$LN3@run
	jmp	SHORT $LN737@run
$LN42@run:

; 117  : 
; 118  :   conj_helper<LhsScalar, RhsScalar, ConjugateLhs, ConjugateRhs> cj;
; 119  :   conj_helper<LhsPacket, RhsPacket, ConjugateLhs, ConjugateRhs> pcj;
; 120  :   conj_helper<LhsPacketHalf, RhsPacketHalf, ConjugateLhs, ConjugateRhs> pcj_half;
; 121  :   conj_helper<LhsPacketQuarter, RhsPacketQuarter, ConjugateLhs, ConjugateRhs> pcj_quarter;
; 122  : 
; 123  :   const Index lhsStride = lhs.stride();
; 124  :   // TODO: for padded aligned inputs, we could enable aligned reads
; 125  :   enum {
; 126  :     LhsAlignment = Unaligned,
; 127  :     ResPacketSize = Traits::ResPacketSize,
; 128  :     ResPacketSizeHalf = HalfTraits::ResPacketSize,
; 129  :     ResPacketSizeQuarter = QuarterTraits::ResPacketSize,
; 130  :     LhsPacketSize = Traits::LhsPacketSize,
; 131  :     HasHalf = (int)ResPacketSizeHalf < (int)ResPacketSize,
; 132  :     HasQuarter = (int)ResPacketSizeQuarter < (int)ResPacketSizeHalf
; 133  :   };
; 134  : 
; 135  :   const Index n8 = rows - 8 * ResPacketSize + 1;
; 136  :   const Index n4 = rows - 4 * ResPacketSize + 1;
; 137  :   const Index n3 = rows - 3 * ResPacketSize + 1;
; 138  :   const Index n2 = rows - 2 * ResPacketSize + 1;
; 139  :   const Index n1 = rows - 1 * ResPacketSize + 1;
; 140  :   const Index n_half = rows - 1 * ResPacketSizeHalf + 1;
; 141  :   const Index n_quarter = rows - 1 * ResPacketSizeQuarter + 1;
; 142  : 
; 143  :   // TODO: improve the following heuristic:
; 144  :   const Index block_cols = cols < 128 ? cols : (lhsStride * sizeof(LhsScalar) < 32000 ? 16 : 4);

	lea	rax, QWORD PTR [rbx*8]
	mov	ecx, 16
	cmp	rax, 32000				; 00007d00H
	mov	r10d, 4
	mov	rax, QWORD PTR cols$[rsp]
	cmovb	r10d, ecx
	xor	r11d, r11d
	mov	edx, r10d
	mov	QWORD PTR tv15721[rsp], r10
	mov	QWORD PTR block_cols$1$[rsp], rdx
	mov	QWORD PTR j2$1$[rsp], r11
$LN737@run:
	mov	r8, QWORD PTR lhs$[rsp]
	mov	QWORD PTR [rsp+312], rbp
	mov	QWORD PTR [rsp+304], rsi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	mov	esi, 1
	mov	QWORD PTR [rsp+296], rdi
	mov	edi, 2
	mov	QWORD PTR [rsp+288], r13
	mov	QWORD PTR [rsp+280], r14
	movaps	XMMWORD PTR [rsp+256], xmm6
	movaps	XMMWORD PTR [rsp+240], xmm7
	movaps	XMMWORD PTR [rsp+224], xmm8
	movaps	XMMWORD PTR [rsp+208], xmm9
	movaps	XMMWORD PTR [rsp+192], xmm10
	movaps	XMMWORD PTR [rsp+176], xmm11
$LL4@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 150  :     Index jend = numext::mini(j2 + block_cols, cols);

	mov	rcx, rdi
	add	rdx, r11
	add	rdi, r10
	mov	QWORD PTR tv16267[rsp], rcx
	mov	QWORD PTR $T1[rsp], rdi
	mov	r13, rsi
	add	rsi, r10
	mov	QWORD PTR tv15883[rsp], rdx
	cmp	rax, rdx
	mov	QWORD PTR $T2[rsp], rsi
	mov	rdi, rdx
	cmovl	rdi, rax

; 151  :     Index i = 0;

	xor	r10d, r10d
	mov	QWORD PTR jend$1$[rsp], rdi

; 152  :     for (; i < n8; i += ResPacketSize * 8) {

	test	r15, r15
	jle	$LN739@run

; 150  :     Index jend = numext::mini(j2 + block_cols, cols);

	mov	rdx, QWORD PTR res$[rsp]
	xorps	xmm11, xmm11
	mov	rsi, QWORD PTR lhs$[rsp]
	add	rdx, 32					; 00000020H
	npad	9
$LL7@run:

; 153  :       ResPacket c0 = pset1<ResPacket>(ResScalar(0)), c1 = pset1<ResPacket>(ResScalar(0)),

	movaps	xmm3, xmm11
	movaps	xmm4, xmm11

; 154  :                 c2 = pset1<ResPacket>(ResScalar(0)), c3 = pset1<ResPacket>(ResScalar(0)),

	movaps	xmm5, xmm11
	movaps	xmm6, xmm11

; 155  :                 c4 = pset1<ResPacket>(ResScalar(0)), c5 = pset1<ResPacket>(ResScalar(0)),

	movaps	xmm7, xmm11
	movaps	xmm8, xmm11

; 156  :                 c6 = pset1<ResPacket>(ResScalar(0)), c7 = pset1<ResPacket>(ResScalar(0));

	movaps	xmm9, xmm11
	movaps	xmm10, xmm11

; 158  :       for (Index j = j2; j < jend; j += 1) {

	cmp	r11, rdi
	jge	$LN9@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	mov	rcx, QWORD PTR [r9+8]
	lea	r14, QWORD PTR [rbx*8]
	mov	rax, QWORD PTR [r9]
	lea	rbp, QWORD PTR [rcx*8]
	imul	rcx, r11
	lea	r8, QWORD PTR [rax+rcx*8]
	mov	rax, rbx
	imul	rax, r11
	add	rax, 4
	add	rax, r10
	lea	rcx, QWORD PTR [rsi+rax*8]
	mov	rax, rdi
	sub	rax, r11
$LL10@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	movsd	xmm2, QWORD PTR [r8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 158  :       for (Index j = j2; j < jend; j += 1) {

	add	r8, rbp
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx-32]

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm2, xmm2

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm2
	movaps	xmm1, xmm2

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm3, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx-16]
	mulpd	xmm0, xmm2

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm4, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx]
	mulpd	xmm1, xmm0
	movups	xmm0, XMMWORD PTR [rcx+16]

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm5, xmm1

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm2

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx+32]
	mulpd	xmm0, xmm2

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx+48]
	mulpd	xmm0, xmm2

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx+64]
	mulpd	xmm0, xmm2

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm9, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx+80]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 158  :       for (Index j = j2; j < jend; j += 1) {

	add	rcx, r14
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm2

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm10, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 158  :       for (Index j = j2; j < jend; j += 1) {

	sub	rax, 1
	jne	SHORT $LL10@run
$LN9@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx-32]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 152  :     for (; i < n8; i += ResPacketSize * 8) {

	add	r10, 16
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm3, xmm12
	mulpd	xmm4, xmm12

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm3, xmm0
	movups	xmm0, XMMWORD PTR [rdx-16]

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm5, xmm12

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm4, xmm0
	movups	xmm0, XMMWORD PTR [rdx]

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm6, xmm12

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm5, xmm0
	movups	xmm0, XMMWORD PTR [rdx+16]

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm7, xmm12

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0
	movups	xmm0, XMMWORD PTR [rdx+32]

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm8, xmm12

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0
	movups	xmm0, XMMWORD PTR [rdx+48]

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm9, xmm12

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm0
	movups	xmm0, XMMWORD PTR [rdx+64]

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm10, xmm12

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm9, xmm0
	movups	xmm0, XMMWORD PTR [rdx+80]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 169  :       pstoreu(res + i + ResPacketSize * 0, pmadd(c0, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 0)));

	movups	XMMWORD PTR [rdx-32], xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm10, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 170  :       pstoreu(res + i + ResPacketSize * 1, pmadd(c1, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 1)));

	movups	XMMWORD PTR [rdx-16], xmm4

; 171  :       pstoreu(res + i + ResPacketSize * 2, pmadd(c2, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 2)));
; 172  :       pstoreu(res + i + ResPacketSize * 3, pmadd(c3, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 3)));
; 173  :       pstoreu(res + i + ResPacketSize * 4, pmadd(c4, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 4)));
; 174  :       pstoreu(res + i + ResPacketSize * 5, pmadd(c5, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 5)));
; 175  :       pstoreu(res + i + ResPacketSize * 6, pmadd(c6, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 6)));
; 176  :       pstoreu(res + i + ResPacketSize * 7, pmadd(c7, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 7)));

	movups	XMMWORD PTR [rdx+80], xmm10
	movups	XMMWORD PTR [rdx], xmm5
	movups	XMMWORD PTR [rdx+16], xmm6
	movups	XMMWORD PTR [rdx+32], xmm7
	movups	XMMWORD PTR [rdx+48], xmm8
	movups	XMMWORD PTR [rdx+64], xmm9
	sub	rdx, -128				; ffffffffffffff80H
	cmp	r10, r15
	jl	$LL7@run

; 152  :     for (; i < n8; i += ResPacketSize * 8) {

	mov	r8, QWORD PTR lhs$[rsp]
	mov	rcx, QWORD PTR tv16267[rsp]
$LN739@run:

; 177  :     }
; 178  :     if (i < n4) {

	mov	rsi, QWORD PTR res$[rsp]
	cmp	r10, r12
	jge	$LN35@run

; 182  :       for (Index j = j2; j < jend; j += 1) {

	xorps	xmm6, xmm6
	xorps	xmm7, xmm7
	xorps	xmm8, xmm8
	xorps	xmm9, xmm9
	mov	rbp, r11
	cmp	r11, rdi
	jge	$LN665@run
	mov	r15, QWORD PTR [r9]
	mov	rax, rdi
	sub	rax, r11
	cmp	rax, 4
	jl	$LC666@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	mov	r12, QWORD PTR [r9+8]
	mov	rdx, rdi
	imul	r13, rbx
	imul	rcx, r12
	sub	rdx, r11
	mov	rax, r12
	shl	rax, 5
	add	r13, r10
	mov	QWORD PTR tv15828[rsp], rax
	sub	rdx, 4
	mov	rsi, QWORD PTR tv15828[rsp]
	mov	rax, rbx
	shl	rax, 5
	mov	r8, r12
	mov	QWORD PTR tv15827[rsp], rax
	neg	r8
	mov	r9, QWORD PTR tv15827[rsp]
	shr	rdx, 2
	lea	rax, QWORD PTR [r15+rcx*8]
	mov	QWORD PTR tv15845[rsp], rax
	mov	rax, QWORD PTR lhs$[rsp]
	mov	rdi, QWORD PTR tv15845[rsp]
	add	rax, 32					; 00000020H
	lea	r14, QWORD PTR [rax+r13*8]
	mov	r13, rbx
	neg	r13
	inc	rdx
	lea	rbp, QWORD PTR [r11+rdx*4]
	lea	r11, QWORD PTR [rbx+rbx]
	npad	2
$LL667@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [r14+r13*8-32]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	mov	rax, rdi
	mov	rcx, r12
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	movsd	xmm3, QWORD PTR [rdi+r8*8]
	movsd	xmm4, QWORD PTR [rdi]

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm1, XMMWORD PTR [r14+rbx*8-32]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	shl	rcx, 4
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	movsd	xmm5, QWORD PTR [rdi+r12*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	sub	rax, rcx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm3, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 187  :         c3 = pcj.pmadd(lhs.template load<LhsPacket, LhsAlignment>(i + LhsPacketSize * 3, j), b0, c3);

	add	rdi, rsi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm4, xmm4

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm1, xmm4

; 395  :   return _mm_set1_pd(from);

	movsd	xmm2, QWORD PTR [rax]
	unpcklpd xmm2, xmm2

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm2

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm5, xmm5

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [r14-32]
	mulpd	xmm0, xmm3

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [r14+r11*8-32]

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm1

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm1, XMMWORD PTR [r14+rbx*8-16]
	mulpd	xmm0, xmm5
	mulpd	xmm1, xmm4

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [r14+r13*8-16]
	mulpd	xmm0, xmm2

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [r14-16]
	mulpd	xmm0, xmm3

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [r14+r11*8-16]

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm1

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm1, XMMWORD PTR [r14+rbx*8]
	mulpd	xmm0, xmm5
	mulpd	xmm1, xmm4

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [r14+r13*8]
	mulpd	xmm0, xmm2

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [r14]
	mulpd	xmm0, xmm3

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [r14+r11*8]

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm1

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm1, XMMWORD PTR [r14+rbx*8+16]
	mulpd	xmm0, xmm5
	mulpd	xmm1, xmm4

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [r14+r13*8+16]
	mulpd	xmm0, xmm2

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm9, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [r14+16]
	mulpd	xmm0, xmm3

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm9, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [r14+r11*8+16]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 187  :         c3 = pcj.pmadd(lhs.template load<LhsPacket, LhsAlignment>(i + LhsPacketSize * 3, j), b0, c3);

	add	r14, r9
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm9, xmm1

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm5

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm9, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 187  :         c3 = pcj.pmadd(lhs.template load<LhsPacket, LhsAlignment>(i + LhsPacketSize * 3, j), b0, c3);

	sub	rdx, 1
	jne	$LL667@run

; 182  :       for (Index j = j2; j < jend; j += 1) {

	mov	rdi, QWORD PTR jend$1$[rsp]
	mov	r11, QWORD PTR j2$1$[rsp]
	mov	r9, QWORD PTR rhs$[rsp]
	mov	rsi, QWORD PTR res$[rsp]
	cmp	rbp, rdi
	jge	$LN778@run
$LC666@run:
	mov	rcx, QWORD PTR [r9+8]
	lea	r14, QWORD PTR [rbx*8]
	mov	rax, rbp
	imul	rax, rcx
	lea	r8, QWORD PTR [rcx*8]
	mov	rcx, QWORD PTR lhs$[rsp]
	lea	rdx, QWORD PTR [r15+rax*8]
	mov	rax, rbp
	imul	rax, rbx
	add	rax, r10
	lea	rcx, QWORD PTR [rcx+rax*8]
	mov	rax, rdi
	add	rcx, 32					; 00000020H
	sub	rax, rbp
$LC13@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	movsd	xmm2, QWORD PTR [rdx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 182  :       for (Index j = j2; j < jend; j += 1) {

	add	rdx, r8
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx-32]

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm2, xmm2

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm2
	movaps	xmm1, xmm2

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx-16]
	mulpd	xmm0, xmm2

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx]
	mulpd	xmm1, xmm0
	movups	xmm0, XMMWORD PTR [rcx+16]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 182  :       for (Index j = j2; j < jend; j += 1) {

	add	rcx, r14
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm1

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm2

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm9, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 182  :       for (Index j = j2; j < jend; j += 1) {

	sub	rax, 1
	jne	SHORT $LC13@run
$LN778@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	mov	r8, QWORD PTR lhs$[rsp]
$LN665@run:

; 504  :   return _mm_add_pd(a, b);

	movups	xmm0, XMMWORD PTR [rsi+r10*8]

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm6, xmm12
	mulpd	xmm7, xmm12

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0
	movups	xmm0, XMMWORD PTR [rsi+r10*8+16]

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm8, xmm12

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0
	movups	xmm0, XMMWORD PTR [rsi+r10*8+32]

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm9, xmm12

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm0
	movups	xmm0, XMMWORD PTR [rsi+r10*8+48]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 189  :       pstoreu(res + i + ResPacketSize * 0, pmadd(c0, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 0)));

	movups	XMMWORD PTR [rsi+r10*8], xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm9, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 190  :       pstoreu(res + i + ResPacketSize * 1, pmadd(c1, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 1)));

	movups	XMMWORD PTR [rsi+r10*8+16], xmm7

; 191  :       pstoreu(res + i + ResPacketSize * 2, pmadd(c2, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 2)));
; 192  :       pstoreu(res + i + ResPacketSize * 3, pmadd(c3, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 3)));

	movups	XMMWORD PTR [rsi+r10*8+48], xmm9
	movups	XMMWORD PTR [rsi+r10*8+32], xmm8

; 193  : 
; 194  :       i += ResPacketSize * 4;

	add	r10, 8
$LN35@run:

; 195  :     }
; 196  :     if (i < n3) {

	cmp	r10, QWORD PTR n3$1$[rsp]
	jge	$LN36@run

; 200  :       for (Index j = j2; j < jend; j += 1) {

	xorps	xmm6, xmm6
	xorps	xmm7, xmm7
	xorps	xmm8, xmm8
	mov	r12, r11
	cmp	r11, rdi
	jge	$LN668@run
	mov	rcx, QWORD PTR [r9]
	mov	rax, rdi
	sub	rax, r11
	mov	QWORD PTR tv15857[rsp], rcx
	cmp	rax, 4
	jl	$LC669@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	mov	r15, QWORD PTR [r9+8]
	lea	rdx, QWORD PTR [r11+1]
	imul	rdx, rbx
	mov	r8, rdi
	lea	rsi, QWORD PTR [rbx+rbx]
	sub	r8, r11
	add	rdx, r10
	sub	r8, 4
	mov	rax, r15
	shl	rax, 5
	mov	r14, rbx
	mov	QWORD PTR tv15810[rsp], rax
	mov	r13, r15
	mov	r9, QWORD PTR tv15810[rsp]
	mov	rax, rbx
	shl	rax, 5
	neg	r14
	mov	QWORD PTR tv15826[rsp], rax
	neg	r13
	mov	rdi, QWORD PTR tv15826[rsp]
	lea	rax, QWORD PTR [r11+2]
	imul	rax, r15
	shr	r8, 2
	lea	rbp, QWORD PTR [rcx+rax*8]
	mov	rcx, QWORD PTR lhs$[rsp]
	add	rcx, 32					; 00000020H
	inc	r8
	lea	rdx, QWORD PTR [rcx+rdx*8]
	lea	r12, QWORD PTR [r11+r8*4]
	npad	3
$LL670@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx+r14*8-32]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	mov	rax, rbp
	mov	rcx, r15
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	movsd	xmm3, QWORD PTR [rbp+r13*8]
	movsd	xmm4, QWORD PTR [rbp]

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm1, XMMWORD PTR [rdx+rbx*8-32]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	shl	rcx, 4
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	movsd	xmm5, QWORD PTR [rbp+r15*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	sub	rax, rcx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm3, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 204  :         c2 = pcj.pmadd(lhs.template load<LhsPacket, LhsAlignment>(i + LhsPacketSize * 2, j), b0, c2);

	add	rbp, r9
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm4, xmm4

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm1, xmm4

; 395  :   return _mm_set1_pd(from);

	movsd	xmm2, QWORD PTR [rax]
	unpcklpd xmm2, xmm2

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm2

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm5, xmm5

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx-32]
	mulpd	xmm0, xmm3

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx+rsi*8-32]

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm1

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm1, XMMWORD PTR [rdx+rbx*8-16]
	mulpd	xmm0, xmm5
	mulpd	xmm1, xmm4

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx+r14*8-16]
	mulpd	xmm0, xmm2

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx-16]
	mulpd	xmm0, xmm3

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx+rsi*8-16]

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm1

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm1, XMMWORD PTR [rdx+rsi*8]
	mulpd	xmm0, xmm5
	mulpd	xmm1, xmm5

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx+r14*8]
	mulpd	xmm0, xmm2

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx]
	mulpd	xmm3, xmm0
	movups	xmm0, XMMWORD PTR [rdx+rbx*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 204  :         c2 = pcj.pmadd(lhs.template load<LhsPacket, LhsAlignment>(i + LhsPacketSize * 2, j), b0, c2);

	add	rdx, rdi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm3

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm4

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm0
	addpd	xmm8, xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 204  :         c2 = pcj.pmadd(lhs.template load<LhsPacket, LhsAlignment>(i + LhsPacketSize * 2, j), b0, c2);

	sub	r8, 1
	jne	$LL670@run

; 200  :       for (Index j = j2; j < jend; j += 1) {

	mov	rdi, QWORD PTR jend$1$[rsp]
	mov	r9, QWORD PTR rhs$[rsp]
	mov	rsi, QWORD PTR res$[rsp]
	cmp	r12, rdi
	jl	SHORT $LN728@run
	jmp	SHORT $LN779@run
$LC669@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	mov	QWORD PTR tv15857[rsp], rcx
$LN728@run:
	mov	rcx, QWORD PTR [r9+8]
	lea	rbp, QWORD PTR [rbx*8]
	mov	rax, r12
	imul	rax, rcx
	lea	r8, QWORD PTR [rcx*8]
	mov	rcx, QWORD PTR tv15857[rsp]
	lea	rdx, QWORD PTR [rcx+rax*8]
	mov	rcx, QWORD PTR lhs$[rsp]
	mov	rax, r12
	imul	rax, rbx
	add	rax, r10
	lea	rcx, QWORD PTR [rcx+rax*8]
	mov	rax, rdi
	add	rcx, 32					; 00000020H
	sub	rax, r12
$LC16@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	movsd	xmm1, QWORD PTR [rdx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 200  :       for (Index j = j2; j < jend; j += 1) {

	add	rdx, r8
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx-32]

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm1, xmm1

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm1

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx-16]
	mulpd	xmm0, xmm1

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 200  :       for (Index j = j2; j < jend; j += 1) {

	add	rcx, rbp
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm1

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 200  :       for (Index j = j2; j < jend; j += 1) {

	sub	rax, 1
	jne	SHORT $LC16@run
$LN779@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	mov	r8, QWORD PTR lhs$[rsp]
$LN668@run:

; 504  :   return _mm_add_pd(a, b);

	movups	xmm0, XMMWORD PTR [rsi+r10*8]

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm6, xmm12
	mulpd	xmm7, xmm12

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0
	movups	xmm0, XMMWORD PTR [rsi+r10*8+16]

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm8, xmm12

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0
	movups	xmm0, XMMWORD PTR [rsi+r10*8+32]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 206  :       pstoreu(res + i + ResPacketSize * 0, pmadd(c0, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 0)));

	movups	XMMWORD PTR [rsi+r10*8], xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 207  :       pstoreu(res + i + ResPacketSize * 1, pmadd(c1, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 1)));

	movups	XMMWORD PTR [rsi+r10*8+16], xmm7

; 208  :       pstoreu(res + i + ResPacketSize * 2, pmadd(c2, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 2)));

	movups	XMMWORD PTR [rsi+r10*8+32], xmm8

; 209  : 
; 210  :       i += ResPacketSize * 3;

	add	r10, 6
$LN36@run:

; 211  :     }
; 212  :     if (i < n2) {

	cmp	r10, QWORD PTR n2$1$[rsp]
	jge	$LN37@run

; 215  :       for (Index j = j2; j < jend; j += 1) {

	xorps	xmm6, xmm6
	xorps	xmm7, xmm7
	mov	r13, r11
	cmp	r11, rdi
	jge	$LN671@run
	mov	rdx, QWORD PTR [r9]
	mov	rax, rdi
	sub	rax, r11
	mov	QWORD PTR tv15855[rsp], rdx
	cmp	rax, 4
	jl	$LN730@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	mov	r14, QWORD PTR [r9+8]
	lea	rcx, QWORD PTR [r11+2]
	mov	rax, r14
	mov	rbp, rdi
	shl	rax, 5
	sub	rbp, r11
	mov	QWORD PTR tv15793[rsp], rax
	sub	rbp, 4
	mov	r9, QWORD PTR tv15793[rsp]
	mov	rax, rbx
	shl	rax, 5
	mov	r15, rbx
	mov	QWORD PTR tv15825[rsp], rax
	mov	r12, r14
	mov	rdi, QWORD PTR tv15825[rsp]
	mov	rax, r14
	imul	rax, rcx
	neg	r15
	shr	rbp, 2
	neg	r12
	lea	r8, QWORD PTR [rdx+rax*8]
	mov	rax, rbx
	imul	rax, rcx
	mov	rcx, QWORD PTR lhs$[rsp]
	add	rax, r10
	add	rcx, 16
	lea	rdx, QWORD PTR [rcx+rax*8]
	mov	rax, rbx
	neg	rax
	inc	rbp
	lea	rsi, QWORD PTR [rax+rax]
	lea	r13, QWORD PTR [r11+rbp*4]
	npad	3
$LL673@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx+rsi*8-16]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	mov	rax, r8
	mov	rcx, r14
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	movsd	xmm3, QWORD PTR [r8+r12*8]
	movsd	xmm4, QWORD PTR [r8]

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm1, XMMWORD PTR [rdx-16]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	shl	rcx, 4
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	movsd	xmm5, QWORD PTR [r8+r14*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	sub	rax, rcx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm3, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 218  :         c1 = pcj.pmadd(lhs.template load<LhsPacket, LhsAlignment>(i + LhsPacketSize * 1, j), b0, c1);

	add	r8, r9
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm4, xmm4

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm1, xmm4

; 395  :   return _mm_set1_pd(from);

	movsd	xmm2, QWORD PTR [rax]
	unpcklpd xmm2, xmm2

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm2

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm5, xmm5

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx+r15*8-16]
	mulpd	xmm0, xmm3

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx+rbx*8-16]

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm1

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm5

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx+rsi*8]
	mulpd	xmm0, xmm2

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx+r15*8]
	mulpd	xmm0, xmm3

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx]
	mulpd	xmm4, xmm0
	movups	xmm0, XMMWORD PTR [rdx+rbx*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 218  :         c1 = pcj.pmadd(lhs.template load<LhsPacket, LhsAlignment>(i + LhsPacketSize * 1, j), b0, c1);

	add	rdx, rdi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm4

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm5

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 218  :         c1 = pcj.pmadd(lhs.template load<LhsPacket, LhsAlignment>(i + LhsPacketSize * 1, j), b0, c1);

	sub	rbp, 1
	jne	$LL673@run

; 215  :       for (Index j = j2; j < jend; j += 1) {

	mov	rdi, QWORD PTR jend$1$[rsp]
	mov	r9, QWORD PTR rhs$[rsp]
	mov	rsi, QWORD PTR res$[rsp]
	cmp	r13, rdi
	jge	SHORT $LN780@run
	mov	rdx, QWORD PTR tv15855[rsp]
$LN730@run:
	mov	rax, QWORD PTR [r9+8]
	lea	rbp, QWORD PTR [rbx*8]
	mov	rcx, QWORD PTR lhs$[rsp]
	lea	r8, QWORD PTR [rax*8]
	imul	rax, r13
	lea	rdx, QWORD PTR [rdx+rax*8]
	mov	rax, r13
	imul	rax, rbx
	add	rax, r10
	lea	rcx, QWORD PTR [rcx+rax*8]
	mov	rax, rdi
	sub	rax, r13
$LC19@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	movsd	xmm1, QWORD PTR [rdx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 215  :       for (Index j = j2; j < jend; j += 1) {

	add	rdx, r8
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx]

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm1, xmm1

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm1

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx+16]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 215  :       for (Index j = j2; j < jend; j += 1) {

	add	rcx, rbp
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm1

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 215  :       for (Index j = j2; j < jend; j += 1) {

	sub	rax, 1
	jne	SHORT $LC19@run
$LN780@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	mov	r8, QWORD PTR lhs$[rsp]
$LN671@run:

; 504  :   return _mm_add_pd(a, b);

	movups	xmm0, XMMWORD PTR [rsi+r10*8]

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm6, xmm12
	mulpd	xmm7, xmm12

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0
	movups	xmm0, XMMWORD PTR [rsi+r10*8+16]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 220  :       pstoreu(res + i + ResPacketSize * 0, pmadd(c0, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 0)));

	movups	XMMWORD PTR [rsi+r10*8], xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 221  :       pstoreu(res + i + ResPacketSize * 1, pmadd(c1, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 1)));

	movups	XMMWORD PTR [rsi+r10*8+16], xmm7

; 222  :       i += ResPacketSize * 2;

	add	r10, 4
$LN37@run:

; 223  :     }
; 224  :     if (i < n1) {

	cmp	r10, QWORD PTR n1$1$[rsp]
	jge	$LN38@run

; 226  :       for (Index j = j2; j < jend; j += 1) {

	xorps	xmm3, xmm3
	mov	r13, r11
	cmp	r11, rdi
	jge	$LN674@run
	mov	rdx, QWORD PTR [r9]
	mov	rax, rdi
	sub	rax, r11
	mov	QWORD PTR tv15854[rsp], rdx
	cmp	rax, 4
	jl	$LN732@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	mov	r14, QWORD PTR [r9+8]
	lea	rcx, QWORD PTR [r11+2]
	mov	rax, r14
	mov	rbp, rdi
	shl	rax, 5
	sub	rbp, r11
	mov	QWORD PTR tv15784[rsp], rax
	sub	rbp, 4
	mov	rsi, QWORD PTR tv15784[rsp]
	mov	rax, rbx
	shl	rax, 5
	mov	r15, rbx
	mov	QWORD PTR tv15824[rsp], rax
	neg	r15
	mov	r9, QWORD PTR tv15824[rsp]
	mov	rax, r14
	imul	rax, rcx
	mov	r12, r14
	shr	rbp, 2
	add	r15, r15
	neg	r12
	lea	rdx, QWORD PTR [rdx+rax*8]
	mov	rax, rbx
	imul	rax, rcx
	mov	rcx, QWORD PTR lhs$[rsp]
	add	rax, r10
	lea	r8, QWORD PTR [rcx+rax*8]
	mov	rax, rbx
	neg	rax
	inc	rbp
	mov	rdi, rax
	lea	r13, QWORD PTR [r11+rbp*4]
	npad	3
$LL676@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [r8+r15*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	mov	rax, rdx
	mov	rcx, r14
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	movsd	xmm2, QWORD PTR [rdx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	shl	rcx, 4
	sub	rax, rcx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm2, xmm2
	movsd	xmm1, QWORD PTR [rax]
	unpcklpd xmm1, xmm1

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm1, xmm0
	movups	xmm0, XMMWORD PTR [r8+rdi*8]

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm3, xmm1

; 395  :   return _mm_set1_pd(from);

	movsd	xmm1, QWORD PTR [rdx+r12*8]
	unpcklpd xmm1, xmm1

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm1, xmm0
	movups	xmm0, XMMWORD PTR [r8]

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm3, xmm1

; 395  :   return _mm_set1_pd(from);

	movsd	xmm1, QWORD PTR [rdx+r14*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 228  :         c0 = pcj.pmadd(lhs.template load<LhsPacket, LhsAlignment>(i + 0, j), b0, c0);

	add	rdx, rsi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm2, xmm0
	movups	xmm0, XMMWORD PTR [r8+rbx*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 228  :         c0 = pcj.pmadd(lhs.template load<LhsPacket, LhsAlignment>(i + 0, j), b0, c0);

	add	r8, r9
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm1, xmm1

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm1, xmm0

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm3, xmm2
	addpd	xmm3, xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 228  :         c0 = pcj.pmadd(lhs.template load<LhsPacket, LhsAlignment>(i + 0, j), b0, c0);

	sub	rbp, 1
	jne	SHORT $LL676@run

; 226  :       for (Index j = j2; j < jend; j += 1) {

	mov	rdi, QWORD PTR jend$1$[rsp]
	mov	r9, QWORD PTR rhs$[rsp]
	mov	rsi, QWORD PTR res$[rsp]
	mov	r8, QWORD PTR lhs$[rsp]
	cmp	r13, rdi
	jge	SHORT $LN674@run
	mov	rdx, QWORD PTR tv15854[rsp]
$LN732@run:
	mov	rax, QWORD PTR [r9+8]
	lea	r14, QWORD PTR [rbx*8]
	lea	rbp, QWORD PTR [rax*8]
	imul	rax, r13
	lea	rcx, QWORD PTR [rdx+rax*8]
	mov	rax, r13
	imul	rax, rbx
	add	rax, r10
	lea	rdx, QWORD PTR [r8+rax*8]
	mov	rax, rdi
	sub	rax, r13
$LC22@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	movsd	xmm1, QWORD PTR [rcx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 226  :       for (Index j = j2; j < jend; j += 1) {

	add	rcx, rbp
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 226  :       for (Index j = j2; j < jend; j += 1) {

	add	rdx, r14
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm1, xmm1

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm1, xmm0

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm3, xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 226  :       for (Index j = j2; j < jend; j += 1) {

	sub	rax, 1
	jne	SHORT $LC22@run
$LN674@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	movups	xmm0, XMMWORD PTR [rsi+r10*8]

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm3, xmm12

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm3, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 230  :       pstoreu(res + i + ResPacketSize * 0, pmadd(c0, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 0)));

	movups	XMMWORD PTR [rsi+r10*8], xmm3

; 231  :       i += ResPacketSize;

	add	r10, 2
$LN38@run:

; 232  :     }
; 233  :     if (HasHalf && i < n_half) {
; 234  :       ResPacketHalf c0 = pset1<ResPacketHalf>(ResScalar(0));
; 235  :       for (Index j = j2; j < jend; j += 1) {
; 236  :         RhsPacketHalf b0 = pset1<RhsPacketHalf>(rhs(j, 0));
; 237  :         c0 = pcj_half.pmadd(lhs.template load<LhsPacketHalf, LhsAlignment>(i + 0, j), b0, c0);
; 238  :       }
; 239  :       pstoreu(res + i + ResPacketSizeHalf * 0,
; 240  :               pmadd(c0, palpha_half, ploadu<ResPacketHalf>(res + i + ResPacketSizeHalf * 0)));
; 241  :       i += ResPacketSizeHalf;
; 242  :     }
; 243  :     if (HasQuarter && i < n_quarter) {
; 244  :       ResPacketQuarter c0 = pset1<ResPacketQuarter>(ResScalar(0));
; 245  :       for (Index j = j2; j < jend; j += 1) {
; 246  :         RhsPacketQuarter b0 = pset1<RhsPacketQuarter>(rhs(j, 0));
; 247  :         c0 = pcj_quarter.pmadd(lhs.template load<LhsPacketQuarter, LhsAlignment>(i + 0, j), b0, c0);
; 248  :       }
; 249  :       pstoreu(res + i + ResPacketSizeQuarter * 0,
; 250  :               pmadd(c0, palpha_quarter, ploadu<ResPacketQuarter>(res + i + ResPacketSizeQuarter * 0)));
; 251  :       i += ResPacketSizeQuarter;
; 252  :     }
; 253  :     for (; i < rows; ++i) {

	cmp	r10, QWORD PTR rows$[rsp]
	jge	$LN2@run
	npad	6
$LL31@run:
	xorps	xmm2, xmm2

; 255  :       for (Index j = j2; j < jend; j += 1) c0 += cj.pmul(lhs(i, j), rhs(j, 0));

	mov	r8, r11
	cmp	r11, rdi
	jge	$LN677@run
	mov	rdx, QWORD PTR [r9]
	mov	rax, rdi
	sub	rax, r11
	mov	QWORD PTR tv15853[rsp], rdx
	cmp	rax, 4
	jl	$LN736@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	mov	rsi, QWORD PTR [r9+8]
	lea	rcx, QWORD PTR [r11+2]
	mov	r14, rbx
	mov	rax, rsi
	imul	rax, rcx
	mov	rbp, rsi
	shl	r14, 5
	shl	rbp, 5
	lea	r8, QWORD PTR [rdx+rax*8]
	mov	rdx, QWORD PTR lhs$[rsp]
	mov	rax, rbx
	imul	rax, rcx
	add	rax, r10
	lea	r9, QWORD PTR [rdx+rax*8]
	mov	rdx, r11
	sub	rdx, rcx
	mov	r13, rdx
	imul	r13, rbx
	lea	rax, QWORD PTR [rdx+3]
	mov	r12, rax
	lea	r15, QWORD PTR [rdx+1]
	imul	r12, rbx
	imul	r15, rbx
	lea	rcx, QWORD PTR [rdx+1]
	mov	rbx, rsi
	imul	rbx, rax
	imul	rcx, rsi
	imul	rsi, rdx
	mov	QWORD PTR tv15725[rsp], rbx
	mov	rax, rdi
	mov	rbx, QWORD PTR lhs$2$[rsp]
	sub	rax, r11
	sub	rax, 4
	shr	rax, 2
	inc	rax
	lea	rdx, QWORD PTR [r11+rax*4]
	mov	QWORD PTR j$1$[rsp], rdx
	mov	rdx, QWORD PTR tv15725[rsp]
	npad	4
$LL679@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movsd	xmm1, QWORD PTR [r9+r13*8]
	mulsd	xmm1, QWORD PTR [r8+rsi*8]
	movsd	xmm0, QWORD PTR [r9+r15*8]
	mulsd	xmm0, QWORD PTR [r8+rcx*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 255  :       for (Index j = j2; j < jend; j += 1) c0 += cj.pmul(lhs(i, j), rhs(j, 0));

	addsd	xmm2, xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movsd	xmm1, QWORD PTR [r9]
	mulsd	xmm1, QWORD PTR [r8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 255  :       for (Index j = j2; j < jend; j += 1) c0 += cj.pmul(lhs(i, j), rhs(j, 0));

	addsd	xmm2, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movsd	xmm0, QWORD PTR [r9+r12*8]
	mulsd	xmm0, QWORD PTR [r8+rdx*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 255  :       for (Index j = j2; j < jend; j += 1) c0 += cj.pmul(lhs(i, j), rhs(j, 0));

	add	r9, r14
	add	r8, rbp
	addsd	xmm2, xmm1
	addsd	xmm2, xmm0
	sub	rax, 1
	jne	SHORT $LL679@run
	mov	r8, QWORD PTR j$1$[rsp]
	mov	r9, QWORD PTR rhs$[rsp]
	cmp	r8, rdi
	jge	SHORT $LN781@run
	mov	rdx, QWORD PTR tv15853[rsp]
$LN736@run:
	mov	rax, QWORD PTR [r9+8]
	lea	rsi, QWORD PTR [rbx*8]
	lea	r9, QWORD PTR [rax*8]
	imul	rax, r8
	lea	rcx, QWORD PTR [rdx+rax*8]
	mov	rdx, QWORD PTR lhs$[rsp]
	mov	rax, r8
	imul	rax, rbx
	add	rax, r10
	lea	rdx, QWORD PTR [rdx+rax*8]
	mov	rax, rdi
	sub	rax, r8
$LC34@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movsd	xmm0, QWORD PTR [rdx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 255  :       for (Index j = j2; j < jend; j += 1) c0 += cj.pmul(lhs(i, j), rhs(j, 0));

	add	rdx, rsi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	mulsd	xmm0, QWORD PTR [rcx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 255  :       for (Index j = j2; j < jend; j += 1) c0 += cj.pmul(lhs(i, j), rhs(j, 0));

	add	rcx, r9
	addsd	xmm2, xmm0
	sub	rax, 1
	jne	SHORT $LC34@run
	mov	r9, QWORD PTR rhs$[rsp]
$LN781@run:

; 256  :       res[i] += alpha * c0;

	mov	rsi, QWORD PTR res$[rsp]
$LN677@run:
	mulsd	xmm2, xmm13
	addsd	xmm2, QWORD PTR [rsi+r10*8]
	movsd	QWORD PTR [rsi+r10*8], xmm2
	inc	r10
	cmp	r10, QWORD PTR rows$[rsp]
	jl	$LL31@run
	mov	r8, QWORD PTR lhs$[rsp]
$LN2@run:

; 149  :   for (Index j2 = 0; j2 < cols; j2 += block_cols) {

	mov	r11, QWORD PTR tv15883[rsp]
	mov	rax, QWORD PTR cols$[rsp]
	mov	r15, QWORD PTR n8$1$[rsp]
	mov	r10, QWORD PTR tv15721[rsp]
	mov	rdi, QWORD PTR $T1[rsp]
	mov	rsi, QWORD PTR $T2[rsp]
	mov	rdx, QWORD PTR block_cols$1$[rsp]
	mov	r12, QWORD PTR n4$1$[rsp]
	mov	QWORD PTR j2$1$[rsp], r11
	cmp	r11, rax
	jl	$LL4@run
	movaps	xmm11, XMMWORD PTR [rsp+176]
	movaps	xmm10, XMMWORD PTR [rsp+192]
	movaps	xmm9, XMMWORD PTR [rsp+208]
	movaps	xmm8, XMMWORD PTR [rsp+224]
	movaps	xmm7, XMMWORD PTR [rsp+240]
	movaps	xmm6, XMMWORD PTR [rsp+256]
	mov	r14, QWORD PTR [rsp+280]
	mov	r13, QWORD PTR [rsp+288]
	mov	rdi, QWORD PTR [rsp+296]
	mov	rsi, QWORD PTR [rsp+304]
	mov	rbp, QWORD PTR [rsp+312]
$LN3@run:

; 257  :     }
; 258  :   }
; 259  : }

	movaps	xmm12, XMMWORD PTR [rsp+160]
	movaps	xmm13, XMMWORD PTR [rsp+144]
	add	rsp, 320				; 00000140H
	pop	r15
	pop	r12
	pop	rbx
	ret	0
?run@?$general_matrix_vector_product@_JNV?$const_blas_data_mapper@N_J$0A@@internal@Eigen@@$0A@$0A@NV?$const_blas_data_mapper@N_J$00@23@$0A@$0A@@internal@Eigen@@SAX_J0AEBV?$const_blas_data_mapper@N_J$0A@@23@AEBV?$const_blas_data_mapper@N_J$00@23@PEAN0N@Z ENDP ; Eigen::internal::general_matrix_vector_product<__int64,double,Eigen::internal::const_blas_data_mapper<double,__int64,0>,0,0,double,Eigen::internal::const_blas_data_mapper<double,__int64,1>,0,0>::run