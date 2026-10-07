?run@?$general_matrix_vector_product@_JNV?$const_blas_data_mapper@N_J$0A@@internal@Eigen@@$0A@$0A@NV123@$0A@$0A@@internal@Eigen@@SAX_J0AEBV?$const_blas_data_mapper@N_J$0A@@23@1PEAN0N@Z PROC ; Eigen::internal::general_matrix_vector_product<__int64,double,Eigen::internal::const_blas_data_mapper<double,__int64,0>,0,0,double,Eigen::internal::const_blas_data_mapper<double,__int64,0>,0,0>::run, COMDAT

; 110  :                                             ResScalar* res, Index resIncr, RhsScalar alpha) {

$LN770:
	mov	QWORD PTR [rsp+32], r9
	mov	QWORD PTR [rsp+16], rdx
	mov	QWORD PTR [rsp+8], rcx
	push	rsi
	push	r13
	push	r15
	sub	rsp, 256				; 00000100H

; 111  :   EIGEN_UNUSED_VARIABLE(resIncr);
; 112  :   eigen_internal_assert(resIncr == 1);
; 113  : 
; 114  :   // The following copy tells the compiler that lhs's attributes are not modified outside this function
; 115  :   // This helps GCC to generate proper code.
; 116  :   LhsMapper lhs(alhs);

	movups	xmm0, XMMWORD PTR [r8]
	mov	r13, QWORD PTR res$[rsp]

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

	lea	rsi, QWORD PTR [rcx-15]

; 136  :   const Index n4 = rows - 4 * ResPacketSize + 1;
; 137  :   const Index n3 = rows - 3 * ResPacketSize + 1;
; 138  :   const Index n2 = rows - 2 * ResPacketSize + 1;
; 139  :   const Index n1 = rows - 1 * ResPacketSize + 1;
; 140  :   const Index n_half = rows - 1 * ResPacketSizeHalf + 1;
; 141  :   const Index n_quarter = rows - 1 * ResPacketSizeQuarter + 1;
; 142  : 
; 143  :   // TODO: improve the following heuristic:
; 144  :   const Index block_cols = cols < 128 ? cols : (lhsStride * sizeof(LhsScalar) < 32000 ? 16 : 4);

	mov	r11, QWORD PTR [r8+8]
	mov	r15, r9
	mov	r9, rcx
	movaps	XMMWORD PTR [rsp+96], xmm12
	add	rcx, -7
	movaps	XMMWORD PTR [rsp+80], xmm13
	movsd	xmm13, QWORD PTR alpha$[rsp]
	mov	rax, rdx
	mov	QWORD PTR n4$1$[rsp], rcx
	movaps	xmm12, xmm13
	mov	QWORD PTR n8$1$[rsp], rsi
	lea	rcx, QWORD PTR [r9-5]
	mov	QWORD PTR n3$1$[rsp], rcx
	lea	rcx, QWORD PTR [r9-3]
	mov	QWORD PTR n2$1$[rsp], rcx
	lea	rcx, QWORD PTR [r9-1]
	mov	QWORD PTR n1$1$[rsp], rcx
	unpcklpd xmm12, xmm12
	movups	XMMWORD PTR lhs$[rsp], xmm0
	cmp	rdx, 128				; 00000080H
	jge	SHORT $LN42@run

; 149  :   for (Index j2 = 0; j2 < cols; j2 += block_cols) {

	xor	r10d, r10d
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	mov	QWORD PTR tv14474[rsp], rdx
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 149  :   for (Index j2 = 0; j2 < cols; j2 += block_cols) {

	mov	QWORD PTR block_cols$1$[rsp], rdx
	mov	rcx, rdx
	test	rdx, rdx
	jle	$LN3@run
	jmp	SHORT $LN738@run
$LN42@run:

; 136  :   const Index n4 = rows - 4 * ResPacketSize + 1;
; 137  :   const Index n3 = rows - 3 * ResPacketSize + 1;
; 138  :   const Index n2 = rows - 2 * ResPacketSize + 1;
; 139  :   const Index n1 = rows - 1 * ResPacketSize + 1;
; 140  :   const Index n_half = rows - 1 * ResPacketSizeHalf + 1;
; 141  :   const Index n_quarter = rows - 1 * ResPacketSizeQuarter + 1;
; 142  : 
; 143  :   // TODO: improve the following heuristic:
; 144  :   const Index block_cols = cols < 128 ? cols : (lhsStride * sizeof(LhsScalar) < 32000 ? 16 : 4);

	lea	rax, QWORD PTR [r11*8]
	mov	ecx, 16
	cmp	rax, 32000				; 00007d00H
	mov	edx, 4
	mov	rax, QWORD PTR cols$[rsp]
	cmovb	edx, ecx
	xor	r10d, r10d
	mov	QWORD PTR tv14474[rsp], rdx
	mov	ecx, edx
	mov	QWORD PTR block_cols$1$[rsp], rdx
$LN738@run:
	mov	QWORD PTR [rsp+248], rbx
	mov	r8d, 2
	mov	QWORD PTR [rsp+240], rbp
	mov	r9d, 1
	mov	QWORD PTR [rsp+232], rdi
	mov	QWORD PTR [rsp+224], r12
	mov	r12, QWORD PTR lhs$[rsp]
	mov	QWORD PTR [rsp+216], r14
	movaps	XMMWORD PTR [rsp+192], xmm6
	movaps	XMMWORD PTR [rsp+176], xmm7
	movaps	XMMWORD PTR [rsp+160], xmm8
	movaps	XMMWORD PTR [rsp+144], xmm9
	movaps	XMMWORD PTR [rsp+128], xmm10
	movaps	XMMWORD PTR [rsp+112], xmm11
	npad	7
$LL4@run:

; 150  :     Index jend = numext::mini(j2 + block_cols, cols);

	add	rcx, r10
	mov	rbp, r9
	add	r9, rdx
	mov	QWORD PTR tv14599[rsp], rcx
	mov	r14, r8
	mov	QWORD PTR $T2[rsp], r9
	add	r8, rdx
	mov	rbx, rcx
	cmp	rax, rcx
	mov	QWORD PTR $T1[rsp], r8
	cmovl	rbx, rax

; 151  :     Index i = 0;

	xor	r9d, r9d

; 152  :     for (; i < n8; i += ResPacketSize * 8) {

	test	rsi, rsi
	jle	$LN6@run

; 150  :     Index jend = numext::mini(j2 + block_cols, cols);

	xorps	xmm11, xmm11
	lea	rdx, QWORD PTR [r13+32]
	npad	4
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

	cmp	r10, rbx
	jge	$LN9@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	mov	rax, QWORD PTR [r15]
	lea	rdi, QWORD PTR [r11*8]
	lea	r8, QWORD PTR [rax+r10*8]
	mov	rax, r11
	imul	rax, r10
	add	rax, 4
	add	rax, r9
	lea	rcx, QWORD PTR [r12+rax*8]
	mov	rax, rbx
	sub	rax, r10
$LL10@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	movsd	xmm2, QWORD PTR [r8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 158  :       for (Index j = j2; j < jend; j += 1) {

	add	r8, 8
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

	add	rcx, rdi
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

	add	r9, 16
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
	cmp	r9, rsi
	jl	$LL7@run
$LN6@run:

; 177  :     }
; 178  :     if (i < n4) {

	cmp	r9, QWORD PTR n4$1$[rsp]
	jge	$LN35@run

; 182  :       for (Index j = j2; j < jend; j += 1) {

	xorps	xmm6, xmm6
	xorps	xmm7, xmm7
	xorps	xmm8, xmm8
	xorps	xmm9, xmm9
	mov	r8, r10
	cmp	r10, rbx
	jge	$LN665@run
	mov	rcx, QWORD PTR [r15]
	mov	rax, rbx
	sub	rax, r10
	cmp	rax, 4
	jl	$LC666@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	imul	rbp, r11
	mov	rax, rbx
	lea	r14, QWORD PTR [rcx+r14*8]
	sub	rax, r10
	add	rbp, 4
	add	rbp, r9
	sub	rax, 4
	mov	rsi, r11
	shr	rax, 2
	mov	rdi, r11
	shl	rsi, 5
	neg	rdi
	inc	rax
	lea	rdx, QWORD PTR [r12+rbp*8]
	lea	rbp, QWORD PTR [r11+r11]
	lea	r8, QWORD PTR [r10+rax*4]
	npad	7
$LL667@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	movsd	xmm2, QWORD PTR [r14-16]

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx+rdi*8-32]

; 395  :   return _mm_set1_pd(from);

	movsd	xmm3, QWORD PTR [r14-8]
	movsd	xmm4, QWORD PTR [r14]

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm1, XMMWORD PTR [rdx+r11*8-32]

; 395  :   return _mm_set1_pd(from);

	movsd	xmm5, QWORD PTR [r14+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 187  :         c3 = pcj.pmadd(lhs.template load<LhsPacket, LhsAlignment>(i + LhsPacketSize * 3, j), b0, c3);

	add	r14, 32					; 00000020H
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm2, xmm2

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm2

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm3, xmm3

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx-32]

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm4, xmm4

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm3
	mulpd	xmm1, xmm4

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx+rbp*8-32]

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm1

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm1, XMMWORD PTR [rdx+r11*8-16]

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm5, xmm5

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm5
	mulpd	xmm1, xmm4

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx+rdi*8-16]
	mulpd	xmm0, xmm2

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx-16]
	mulpd	xmm0, xmm3

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx+rbp*8-16]

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm1

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm5
	movaps	xmm1, xmm3

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx+rdi*8]
	mulpd	xmm0, xmm2

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx]
	mulpd	xmm1, xmm0
	movups	xmm0, XMMWORD PTR [rdx+r11*8]

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm1

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm1, XMMWORD PTR [rdx+rbp*8]
	mulpd	xmm0, xmm4
	mulpd	xmm1, xmm5

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx+rdi*8+16]

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm1

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm1, XMMWORD PTR [rdx+r11*8+16]
	mulpd	xmm0, xmm2
	mulpd	xmm1, xmm4

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm9, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx+16]
	mulpd	xmm0, xmm3

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm9, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx+rbp*8+16]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 187  :         c3 = pcj.pmadd(lhs.template load<LhsPacket, LhsAlignment>(i + LhsPacketSize * 3, j), b0, c3);

	add	rdx, rsi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm9, xmm1

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm5

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm9, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 187  :         c3 = pcj.pmadd(lhs.template load<LhsPacket, LhsAlignment>(i + LhsPacketSize * 3, j), b0, c3);

	sub	rax, 1
	jne	$LL667@run

; 182  :       for (Index j = j2; j < jend; j += 1) {

	cmp	r8, rbx
	jge	SHORT $LN665@run
$LC666@run:
	mov	rax, r8
	lea	rdx, QWORD PTR [rcx+r8*8]
	imul	rax, r11
	lea	rdi, QWORD PTR [r11*8]
	add	rax, 4
	add	rax, r9
	lea	rcx, QWORD PTR [r12+rax*8]
	mov	rax, rbx
	sub	rax, r8
$LC13@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	movsd	xmm1, QWORD PTR [rdx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 182  :       for (Index j = j2; j < jend; j += 1) {

	add	rdx, 8
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
	mulpd	xmm0, xmm1

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx+16]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 182  :       for (Index j = j2; j < jend; j += 1) {

	add	rcx, rdi
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm1

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm9, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 182  :       for (Index j = j2; j < jend; j += 1) {

	sub	rax, 1
	jne	SHORT $LC13@run
$LN665@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	movups	xmm0, XMMWORD PTR [r13+r9*8]

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm6, xmm12
	mulpd	xmm7, xmm12

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0
	movups	xmm0, XMMWORD PTR [r13+r9*8+16]

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm8, xmm12

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0
	movups	xmm0, XMMWORD PTR [r13+r9*8+32]

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm9, xmm12

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm0
	movups	xmm0, XMMWORD PTR [r13+r9*8+48]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 189  :       pstoreu(res + i + ResPacketSize * 0, pmadd(c0, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 0)));

	movups	XMMWORD PTR [r13+r9*8], xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm9, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 190  :       pstoreu(res + i + ResPacketSize * 1, pmadd(c1, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 1)));

	movups	XMMWORD PTR [r13+r9*8+16], xmm7

; 191  :       pstoreu(res + i + ResPacketSize * 2, pmadd(c2, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 2)));
; 192  :       pstoreu(res + i + ResPacketSize * 3, pmadd(c3, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 3)));

	movups	XMMWORD PTR [r13+r9*8+48], xmm9
	movups	XMMWORD PTR [r13+r9*8+32], xmm8

; 193  : 
; 194  :       i += ResPacketSize * 4;

	add	r9, 8
$LN35@run:

; 195  :     }
; 196  :     if (i < n3) {

	cmp	r9, QWORD PTR n3$1$[rsp]
	jge	$LN36@run

; 200  :       for (Index j = j2; j < jend; j += 1) {

	xorps	xmm6, xmm6
	xorps	xmm7, xmm7
	xorps	xmm8, xmm8
	mov	rdi, r10
	cmp	r10, rbx
	jge	$LN668@run
	mov	rsi, QWORD PTR [r15]
	mov	rax, rbx
	sub	rax, r10
	cmp	rax, 4
	jl	$LC669@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	lea	rax, QWORD PTR [r10+1]
	mov	r14, r11
	imul	rax, r11
	mov	r8, r11
	shl	r14, 5
	add	rax, 4
	lea	rdx, QWORD PTR [r10+2]
	add	rax, r9
	lea	rdx, QWORD PTR [rsi+rdx*8]
	neg	r8
	lea	rbp, QWORD PTR [r11+r11]
	lea	rcx, QWORD PTR [r12+rax*8]
	mov	rax, rbx
	sub	rax, r10
	sub	rax, 4
	shr	rax, 2
	inc	rax
	lea	rdi, QWORD PTR [r10+rax*4]
	npad	3
$LL670@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	movsd	xmm2, QWORD PTR [rdx-16]

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx+r8*8-32]

; 395  :   return _mm_set1_pd(from);

	movsd	xmm3, QWORD PTR [rdx-8]
	movsd	xmm4, QWORD PTR [rdx]

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm1, XMMWORD PTR [rcx+r11*8-32]

; 395  :   return _mm_set1_pd(from);

	movsd	xmm5, QWORD PTR [rdx+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 204  :         c2 = pcj.pmadd(lhs.template load<LhsPacket, LhsAlignment>(i + LhsPacketSize * 2, j), b0, c2);

	add	rdx, 32					; 00000020H
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm2, xmm2

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm2

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm3, xmm3

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx-32]

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm4, xmm4

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm3
	mulpd	xmm1, xmm4

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx+rbp*8-32]

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm1

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm1, XMMWORD PTR [rcx+r11*8-16]

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm5, xmm5

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm5
	mulpd	xmm1, xmm4

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx+r8*8-16]
	mulpd	xmm0, xmm2

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx-16]
	mulpd	xmm0, xmm3

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx+rbp*8-16]

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm1

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm1, XMMWORD PTR [rcx+r11*8]
	mulpd	xmm0, xmm5
	mulpd	xmm1, xmm4

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx+r8*8]
	mulpd	xmm0, xmm2

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx]
	mulpd	xmm0, xmm3

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx+rbp*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 204  :         c2 = pcj.pmadd(lhs.template load<LhsPacket, LhsAlignment>(i + LhsPacketSize * 2, j), b0, c2);

	add	rcx, r14
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm1

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm5

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 204  :         c2 = pcj.pmadd(lhs.template load<LhsPacket, LhsAlignment>(i + LhsPacketSize * 2, j), b0, c2);

	sub	rax, 1
	jne	$LL670@run

; 200  :       for (Index j = j2; j < jend; j += 1) {

	cmp	rdi, rbx
	jge	SHORT $LN668@run
$LC669@run:
	mov	rax, rdi
	lea	rdx, QWORD PTR [rsi+rdi*8]
	imul	rax, r11
	lea	r8, QWORD PTR [r11*8]
	add	rax, 4
	add	rax, r9
	lea	rcx, QWORD PTR [r12+rax*8]
	mov	rax, rbx
	sub	rax, rdi
$LC16@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	movsd	xmm1, QWORD PTR [rdx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 200  :       for (Index j = j2; j < jend; j += 1) {

	add	rdx, 8
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

	add	rcx, r8
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm1

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 200  :       for (Index j = j2; j < jend; j += 1) {

	sub	rax, 1
	jne	SHORT $LC16@run
$LN668@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	movups	xmm0, XMMWORD PTR [r13+r9*8]

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm6, xmm12
	mulpd	xmm7, xmm12

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0
	movups	xmm0, XMMWORD PTR [r13+r9*8+16]

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm8, xmm12

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0
	movups	xmm0, XMMWORD PTR [r13+r9*8+32]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 206  :       pstoreu(res + i + ResPacketSize * 0, pmadd(c0, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 0)));

	movups	XMMWORD PTR [r13+r9*8], xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm8, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 207  :       pstoreu(res + i + ResPacketSize * 1, pmadd(c1, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 1)));

	movups	XMMWORD PTR [r13+r9*8+16], xmm7

; 208  :       pstoreu(res + i + ResPacketSize * 2, pmadd(c2, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 2)));

	movups	XMMWORD PTR [r13+r9*8+32], xmm8

; 209  : 
; 210  :       i += ResPacketSize * 3;

	add	r9, 6
$LN36@run:

; 211  :     }
; 212  :     if (i < n2) {

	cmp	r9, QWORD PTR n2$1$[rsp]
	jge	$LN37@run

; 215  :       for (Index j = j2; j < jend; j += 1) {

	xorps	xmm6, xmm6
	xorps	xmm7, xmm7
	mov	rdi, r10
	cmp	r10, rbx
	jge	$LN671@run
	mov	r14, QWORD PTR [r15]
	mov	rax, rbx
	sub	rax, r10
	cmp	rax, 4
	jl	$LC672@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	lea	rax, QWORD PTR [r10+2]
	mov	rbp, r11
	lea	rdx, QWORD PTR [r14+rax*8]
	shl	rbp, 5
	imul	rax, r11
	mov	r8, r11
	add	rax, 2
	neg	r8
	add	rax, r9
	lea	rcx, QWORD PTR [r12+rax*8]
	mov	rax, r11
	neg	rax
	lea	rsi, QWORD PTR [rax+rax]
	mov	rax, rbx
	sub	rax, r10
	sub	rax, 4
	shr	rax, 2
	inc	rax
	lea	rdi, QWORD PTR [r10+rax*4]
	npad	4
$LL673@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	movsd	xmm2, QWORD PTR [rdx-16]

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx+rsi*8-16]

; 395  :   return _mm_set1_pd(from);

	movsd	xmm3, QWORD PTR [rdx-8]
	movsd	xmm4, QWORD PTR [rdx]

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm1, XMMWORD PTR [rcx-16]

; 395  :   return _mm_set1_pd(from);

	movsd	xmm5, QWORD PTR [rdx+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 218  :         c1 = pcj.pmadd(lhs.template load<LhsPacket, LhsAlignment>(i + LhsPacketSize * 1, j), b0, c1);

	add	rdx, 32					; 00000020H
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm2, xmm2

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm2

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm3, xmm3

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx+r8*8-16]

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm4, xmm4

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm3
	mulpd	xmm1, xmm4

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx+r11*8-16]

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm1

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm1, XMMWORD PTR [rcx]

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm5, xmm5

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm5
	mulpd	xmm1, xmm4

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx+rsi*8]
	mulpd	xmm0, xmm2

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx+r8*8]
	mulpd	xmm0, xmm3

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rcx+r11*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 218  :         c1 = pcj.pmadd(lhs.template load<LhsPacket, LhsAlignment>(i + LhsPacketSize * 1, j), b0, c1);

	add	rcx, rbp
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm1

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm5

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 218  :         c1 = pcj.pmadd(lhs.template load<LhsPacket, LhsAlignment>(i + LhsPacketSize * 1, j), b0, c1);

	sub	rax, 1
	jne	$LL673@run

; 215  :       for (Index j = j2; j < jend; j += 1) {

	cmp	rdi, rbx
	jge	SHORT $LN671@run
$LC672@run:
	mov	rax, rdi
	lea	rdx, QWORD PTR [r14+rdi*8]
	imul	rax, r11
	lea	r8, QWORD PTR [r11*8]
	add	rax, r9
	lea	rcx, QWORD PTR [r12+rax*8]
	mov	rax, rbx
	sub	rax, rdi
$LC19@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	movsd	xmm1, QWORD PTR [rdx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 215  :       for (Index j = j2; j < jend; j += 1) {

	add	rdx, 8
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

	add	rcx, r8
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm0, xmm1

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 215  :       for (Index j = j2; j < jend; j += 1) {

	sub	rax, 1
	jne	SHORT $LC19@run
$LN671@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	movups	xmm0, XMMWORD PTR [r13+r9*8]

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm6, xmm12
	mulpd	xmm7, xmm12

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm6, xmm0
	movups	xmm0, XMMWORD PTR [r13+r9*8+16]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 220  :       pstoreu(res + i + ResPacketSize * 0, pmadd(c0, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 0)));

	movups	XMMWORD PTR [r13+r9*8], xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm7, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 221  :       pstoreu(res + i + ResPacketSize * 1, pmadd(c1, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 1)));

	movups	XMMWORD PTR [r13+r9*8+16], xmm7

; 222  :       i += ResPacketSize * 2;

	add	r9, 4
$LN37@run:

; 223  :     }
; 224  :     if (i < n1) {

	cmp	r9, QWORD PTR n1$1$[rsp]
	jge	$LN38@run

; 226  :       for (Index j = j2; j < jend; j += 1) {

	xorps	xmm3, xmm3
	mov	rbp, r10
	cmp	r10, rbx
	jge	$LN674@run
	mov	r14, QWORD PTR [r15]
	mov	rax, rbx
	sub	rax, r10
	cmp	rax, 4
	jl	$LC675@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	lea	rax, QWORD PTR [r10+2]
	mov	r8, r11
	lea	rcx, QWORD PTR [r14+rax*8]
	neg	r8
	imul	rax, r11
	mov	rdi, r11
	mov	rsi, r11
	add	rax, r9
	shl	rdi, 5
	neg	rsi
	add	r8, r8
	lea	rdx, QWORD PTR [r12+rax*8]
	mov	rax, rbx
	sub	rax, r10
	sub	rax, 4
	shr	rax, 2
	inc	rax
	lea	rbp, QWORD PTR [r10+rax*4]
	npad	12
$LL676@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx+r8*8]

; 395  :   return _mm_set1_pd(from);

	movsd	xmm1, QWORD PTR [rcx-16]
	movsd	xmm2, QWORD PTR [rcx]
	unpcklpd xmm1, xmm1

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm1, xmm0
	movups	xmm0, XMMWORD PTR [rdx+rsi*8]

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm3, xmm1

; 395  :   return _mm_set1_pd(from);

	movsd	xmm1, QWORD PTR [rcx-8]
	unpcklpd xmm1, xmm1

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm1, xmm0
	movups	xmm0, XMMWORD PTR [rdx]

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm3, xmm1

; 395  :   return _mm_set1_pd(from);

	movsd	xmm1, QWORD PTR [rcx+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 228  :         c0 = pcj.pmadd(lhs.template load<LhsPacket, LhsAlignment>(i + 0, j), b0, c0);

	add	rcx, 32					; 00000020H
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	unpcklpd xmm2, xmm2

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm2, xmm0
	movups	xmm0, XMMWORD PTR [rdx+r11*8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 228  :         c0 = pcj.pmadd(lhs.template load<LhsPacket, LhsAlignment>(i + 0, j), b0, c0);

	add	rdx, rdi
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

	sub	rax, 1
	jne	SHORT $LL676@run

; 226  :       for (Index j = j2; j < jend; j += 1) {

	cmp	rbp, rbx
	jge	SHORT $LN674@run
$LC675@run:
	mov	rax, rbp
	lea	rcx, QWORD PTR [r14+rbp*8]
	imul	rax, r11
	lea	r8, QWORD PTR [r11*8]
	add	rax, r9
	lea	rdx, QWORD PTR [r12+rax*8]
	mov	rax, rbx
	sub	rax, rbp
$LC22@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 395  :   return _mm_set1_pd(from);

	movsd	xmm1, QWORD PTR [rcx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 226  :       for (Index j = j2; j < jend; j += 1) {

	add	rcx, 8
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\arch\SSE\PacketMath.h

; 627  :   return _mm_mul_pd(a, b);

	movups	xmm0, XMMWORD PTR [rdx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 226  :       for (Index j = j2; j < jend; j += 1) {

	add	rdx, r8
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

	movups	xmm0, XMMWORD PTR [r13+r9*8]

; 627  :   return _mm_mul_pd(a, b);

	mulpd	xmm3, xmm12

; 504  :   return _mm_add_pd(a, b);

	addpd	xmm3, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 230  :       pstoreu(res + i + ResPacketSize * 0, pmadd(c0, palpha, ploadu<ResPacket>(res + i + ResPacketSize * 0)));

	movups	XMMWORD PTR [r13+r9*8], xmm3

; 231  :       i += ResPacketSize;

	add	r9, 2
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

	mov	rdi, QWORD PTR rows$[rsp]
	cmp	r9, rdi
	jge	$LN2@run
$LL31@run:
	xorps	xmm2, xmm2

; 255  :       for (Index j = j2; j < jend; j += 1) c0 += cj.pmul(lhs(i, j), rhs(j, 0));

	mov	r14, r10
	cmp	r10, rbx
	jge	$LN677@run
	mov	r15, QWORD PTR [r15]
	mov	rax, rbx
	sub	rax, r10
	cmp	rax, 4
	jl	$LN736@run
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\util\BlasUtil.h

; 202  :     return m_data[StorageOrder == RowMajor ? j + i * m_stride : i + j * m_stride];

	lea	rcx, QWORD PTR [r10+2]
	mov	rdi, r10
	sub	rdi, rcx
	lea	rdx, QWORD PTR [r15+rcx*8]
	mov	rax, rcx
	mov	rsi, r11
	imul	rax, r11
	lea	rcx, QWORD PTR [rdi+1]
	shl	rsi, 5
	add	rax, r9
	lea	rbp, QWORD PTR [rdi+3]
	imul	rcx, r11
	imul	rbp, r11
	imul	rdi, r11
	lea	r8, QWORD PTR [r12+rax*8]
	mov	rax, rbx
	sub	rax, r10
	sub	rax, 4
	shr	rax, 2
	inc	rax
	lea	r14, QWORD PTR [r10+rax*4]
	npad	2
$LL679@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movsd	xmm1, QWORD PTR [r8+rdi*8]
	mulsd	xmm1, QWORD PTR [rdx-16]
	movsd	xmm0, QWORD PTR [r8+rcx*8]
	mulsd	xmm0, QWORD PTR [rdx-8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 255  :       for (Index j = j2; j < jend; j += 1) c0 += cj.pmul(lhs(i, j), rhs(j, 0));

	addsd	xmm2, xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movsd	xmm1, QWORD PTR [r8]
	mulsd	xmm1, QWORD PTR [rdx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 255  :       for (Index j = j2; j < jend; j += 1) c0 += cj.pmul(lhs(i, j), rhs(j, 0));

	addsd	xmm2, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movsd	xmm0, QWORD PTR [r8+rbp*8]
	mulsd	xmm0, QWORD PTR [rdx+8]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 255  :       for (Index j = j2; j < jend; j += 1) c0 += cj.pmul(lhs(i, j), rhs(j, 0));

	add	r8, rsi
	add	rdx, 32					; 00000020H
	addsd	xmm2, xmm1
	addsd	xmm2, xmm0
	sub	rax, 1
	jne	SHORT $LL679@run
	mov	rdi, QWORD PTR rows$[rsp]
	cmp	r14, rbx
	jge	SHORT $LN767@run
$LN736@run:
	mov	rax, r14
	lea	rcx, QWORD PTR [r15+r14*8]
	imul	rax, r11
	lea	r8, QWORD PTR [r11*8]
	add	rax, r9
	lea	rdx, QWORD PTR [r12+rax*8]
	mov	rax, rbx
	sub	rax, r14
$LC34@run:
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	movsd	xmm0, QWORD PTR [rcx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 255  :       for (Index j = j2; j < jend; j += 1) c0 += cj.pmul(lhs(i, j), rhs(j, 0));

	add	rcx, 8
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\GenericPacketMath.h

; 365  :   return a * b;

	mulsd	xmm0, QWORD PTR [rdx]
; File C:\Users\owner\Documents\git\kibo-linalg\.cache\eigen\Eigen\src\Core\products\GeneralMatrixVector.h

; 255  :       for (Index j = j2; j < jend; j += 1) c0 += cj.pmul(lhs(i, j), rhs(j, 0));

	add	rdx, r8
	addsd	xmm2, xmm0
	sub	rax, 1
	jne	SHORT $LC34@run
$LN767@run:

; 256  :       res[i] += alpha * c0;

	mov	r15, QWORD PTR rhs$[rsp]
$LN677@run:
	mulsd	xmm2, xmm13
	addsd	xmm2, QWORD PTR [r13+r9*8]
	movsd	QWORD PTR [r13+r9*8], xmm2
	inc	r9
	cmp	r9, rdi
	jl	$LL31@run
$LN2@run:

; 149  :   for (Index j2 = 0; j2 < cols; j2 += block_cols) {

	mov	r10, QWORD PTR tv14599[rsp]
	mov	rax, QWORD PTR cols$[rsp]
	mov	rsi, QWORD PTR n8$1$[rsp]
	mov	rdx, QWORD PTR tv14474[rsp]
	mov	r8, QWORD PTR $T1[rsp]
	mov	r9, QWORD PTR $T2[rsp]
	mov	rcx, QWORD PTR block_cols$1$[rsp]
	cmp	r10, rax
	jl	$LL4@run
	movaps	xmm11, XMMWORD PTR [rsp+112]
	movaps	xmm10, XMMWORD PTR [rsp+128]
	movaps	xmm9, XMMWORD PTR [rsp+144]
	movaps	xmm8, XMMWORD PTR [rsp+160]
	movaps	xmm7, XMMWORD PTR [rsp+176]
	movaps	xmm6, XMMWORD PTR [rsp+192]
	mov	r14, QWORD PTR [rsp+216]
	mov	r12, QWORD PTR [rsp+224]
	mov	rdi, QWORD PTR [rsp+232]
	mov	rbp, QWORD PTR [rsp+240]
	mov	rbx, QWORD PTR [rsp+248]
$LN3@run:

; 257  :     }
; 258  :   }
; 259  : }

	movaps	xmm12, XMMWORD PTR [rsp+96]
	movaps	xmm13, XMMWORD PTR [rsp+80]
	add	rsp, 256				; 00000100H
	pop	r15
	pop	r13
	pop	rsi
	ret	0
?run@?$general_matrix_vector_product@_JNV?$const_blas_data_mapper@N_J$0A@@internal@Eigen@@$0A@$0A@NV123@$0A@$0A@@internal@Eigen@@SAX_J0AEBV?$const_blas_data_mapper@N_J$0A@@23@1PEAN0N@Z ENDP ; Eigen::internal::general_matrix_vector_product<__int64,double,Eigen::internal::const_blas_data_mapper<double,__int64,0>,0,0,double,Eigen::internal::const_blas_data_mapper<double,__int64,0>,0,0>::run