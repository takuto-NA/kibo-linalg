?row_update_panel@detail@linalg@kibo@@YAXPEANPEBN_K122@Z PROC ; kibo::linalg::detail::row_update_panel, COMDAT

; 114  :                              const double* coefficients, std::size_t width, std::size_t count) noexcept {

$LN135:
	mov	rax, rsp
	mov	QWORD PTR [rax+32], r9
	mov	QWORD PTR [rax+16], rdx
	mov	QWORD PTR [rax+8], rcx
	push	rsi
	push	r14
	push	r15
	sub	rsp, 320				; 00000140H

; 115  :     std::size_t j=0;
; 116  : #if defined(KIBO_DETAIL_ROW_SSE2)
; 117  :     for(;count-j>=16;j+=16) {

	mov	r14, QWORD PTR count$[rsp]
	xor	r11d, r11d
	mov	r10, QWORD PTR width$[rsp]
	mov	r15, rdx
	mov	QWORD PTR [rax+24], rbx
	mov	rsi, rcx
	mov	QWORD PTR [rax-32], rbp
	mov	QWORD PTR [rax-40], rdi
	mov	QWORD PTR [rax-48], r12
	mov	QWORD PTR [rax-56], r13
	movaps	XMMWORD PTR [rax-72], xmm6
	movaps	XMMWORD PTR [rax-88], xmm7
	movaps	XMMWORD PTR [rax-104], xmm8
	movaps	XMMWORD PTR [rax-120], xmm9
	mov	QWORD PTR j$1$[rsp], r11
	cmp	r14, 16
	jb	$LN104@row_update
	lea	rdx, QWORD PTR [rcx+16]
	movaps	XMMWORD PTR [rax-136], xmm10
	movaps	XMMWORD PTR [rax-152], xmm11
	lea	rcx, QWORD PTR [r8*8+16]
	sub	rcx, rsi
	movaps	XMMWORD PTR [rax-168], xmm12
	add	rcx, r15
	movaps	XMMWORD PTR [rax-184], xmm13
	mov	QWORD PTR tv12631[rsp], rcx
	lea	rdi, QWORD PTR [r8*8]
	mov	QWORD PTR tv12632[rsp], rdx
	npad	3
$LL4@row_update:

; 118  :         auto p0=_mm_loadu_pd(row+j+0);

	movups	xmm6, XMMWORD PTR [rdx-16]
	xor	ebx, ebx

; 119  :         auto p1=_mm_loadu_pd(row+j+2);

	movups	xmm7, XMMWORD PTR [rdx]

; 120  :         auto p2=_mm_loadu_pd(row+j+4);

	movups	xmm8, XMMWORD PTR [rdx+16]

; 121  :         auto p3=_mm_loadu_pd(row+j+6);

	movups	xmm9, XMMWORD PTR [rdx+32]

; 122  :         auto p4=_mm_loadu_pd(row+j+8);

	movups	xmm10, XMMWORD PTR [rdx+48]

; 123  :         auto p5=_mm_loadu_pd(row+j+10);

	movups	xmm11, XMMWORD PTR [rdx+64]

; 124  :         auto p6=_mm_loadu_pd(row+j+12);

	movups	xmm12, XMMWORD PTR [rdx+80]

; 125  :         auto p7=_mm_loadu_pd(row+j+14);

	movups	xmm13, XMMWORD PTR [rdx+96]

; 126  :         for(std::size_t k=0;k<width;++k) {

	cmp	r10, 4
	jb	$LN86@row_update

; 118  :         auto p0=_mm_loadu_pd(row+j+0);

	lea	r12, QWORD PTR [r8-2]
	mov	rax, r8
	shl	rax, 5
	lea	rbp, QWORD PTR [r8+4]
	mov	QWORD PTR tv12637[rsp], rax
	lea	r15, QWORD PTR [r9+16]
	lea	rax, QWORD PTR [r12*8]
	mov	QWORD PTR tv12692[rsp], r15
	mov	QWORD PTR tv12687[rsp], rax
	add	rcx, rdx
	lea	rax, QWORD PTR [rbp*8]
	mov	r13, r8
	mov	QWORD PTR tv12674[rsp], rax
	add	r13, r13
	lea	rax, QWORD PTR [r8+2]
	add	rbp, rbp
	shl	rax, 4
	add	r12, r12
	mov	QWORD PTR tv12664[rsp], rax
	lea	rax, QWORD PTR [r8+3]
	mov	rsi, QWORD PTR tv12664[rsp]
	shl	rax, 4
	mov	QWORD PTR tv12663[rsp], rax
	lea	rax, QWORD PTR [r8+5]
	mov	r14, QWORD PTR tv12663[rsp]
	shl	rax, 4
	mov	QWORD PTR tv12661[rsp], rax
	mov	rax, -2
	sub	rax, r8
	mov	QWORD PTR tv13008[rsp], rax
	mov	rax, r8
	mov	r9, QWORD PTR tv13008[rsp]
	neg	rax
	mov	QWORD PTR tv13007[rsp], rax
	mov	eax, 2
	sub	rax, r8
	mov	QWORD PTR tv13005[rsp], rax
	mov	eax, 4
	mov	rdx, QWORD PTR tv13005[rsp]
	sub	rax, r8
	mov	QWORD PTR tv13003[rsp], rax
	mov	eax, 6
	mov	r11, QWORD PTR tv13003[rsp]
	sub	rax, r8
	mov	QWORD PTR tv13001[rsp], rax
	mov	eax, 8
	sub	rax, r8
	mov	QWORD PTR tv12999[rsp], rax
	mov	eax, 10
	sub	rax, r8
	mov	QWORD PTR tv12997[rsp], rax
	mov	rax, -4
	sub	rax, r8
	mov	QWORD PTR tv12993[rsp], rax
	lea	rax, QWORD PTR [r10-4]
	mov	r10, QWORD PTR tv13007[rsp]
	shr	rax, 2
	inc	rax
	lea	rbx, QWORD PTR [rax*4]
	mov	QWORD PTR k$1$[rsp], rbx
	mov	rbx, QWORD PTR tv13001[rsp]

; 135  :             p7=_mm_sub_pd(p7,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+14)));

	jmp	SHORT $LN76@row_update
	npad	3
$LL105@row_update:
	mov	r15, QWORD PTR tv12692[rsp]

; 126  :         for(std::size_t k=0;k<width;++k) {

$LN76@row_update:

; 127  :             const auto multiplier=_mm_set1_pd(coefficients[k]);

	movsd	xmm2, QWORD PTR [r15-16]
	movsd	xmm3, QWORD PTR [r15-8]
	movsd	xmm4, QWORD PTR [r15]
	movsd	xmm5, QWORD PTR [r15+8]

; 128  :             p0=_mm_sub_pd(p0,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+0)));

	mov	r15, QWORD PTR tv12993[rsp]
	movups	xmm1, XMMWORD PTR [rcx-32]
	unpcklpd xmm2, xmm2
	movups	xmm0, XMMWORD PTR [rcx+r15*8]

; 129  :             p1=_mm_sub_pd(p1,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+2)));

	mov	r15, QWORD PTR tv12687[rsp]
	unpcklpd xmm3, xmm3
	mulpd	xmm0, xmm2
	mulpd	xmm1, xmm3
	subpd	xmm6, xmm0
	movups	xmm0, XMMWORD PTR [rcx+r8*8-32]
	subpd	xmm6, xmm1
	movups	xmm1, XMMWORD PTR [rcx+r12*8]
	unpcklpd xmm4, xmm4
	mulpd	xmm0, xmm4
	unpcklpd xmm5, xmm5
	subpd	xmm6, xmm0
	movups	xmm0, XMMWORD PTR [rcx+r9*8]
	mulpd	xmm1, xmm5
	mulpd	xmm0, xmm2
	subpd	xmm6, xmm1
	movups	xmm1, XMMWORD PTR [rcx-16]
	subpd	xmm7, xmm0
	movups	xmm0, XMMWORD PTR [r15+rcx]

; 132  :             p4=_mm_sub_pd(p4,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+8)));

	mov	r15, QWORD PTR tv12674[rsp]
	mulpd	xmm1, xmm3
	mulpd	xmm0, xmm4
	subpd	xmm7, xmm1
	movups	xmm1, XMMWORD PTR [rcx+r13*8-16]
	subpd	xmm7, xmm0
	movups	xmm0, XMMWORD PTR [rcx+r10*8]
	mulpd	xmm1, xmm5
	mulpd	xmm0, xmm2
	subpd	xmm7, xmm1
	subpd	xmm8, xmm0
	movups	xmm0, XMMWORD PTR [rcx]
	movaps	xmm1, xmm3
	mulpd	xmm1, xmm0
	movups	xmm0, XMMWORD PTR [rdi+rcx]
	subpd	xmm8, xmm1
	movups	xmm1, XMMWORD PTR [rcx+r13*8]
	mulpd	xmm0, xmm4
	mulpd	xmm1, xmm5
	subpd	xmm8, xmm0
	movups	xmm0, XMMWORD PTR [rcx+rdx*8]
	subpd	xmm8, xmm1
	movups	xmm1, XMMWORD PTR [rcx+16]
	mulpd	xmm0, xmm2
	mulpd	xmm1, xmm3
	subpd	xmm9, xmm0
	movups	xmm0, XMMWORD PTR [rcx+r8*8+16]
	subpd	xmm9, xmm1
	movups	xmm1, XMMWORD PTR [rcx+r13*8+16]
	mulpd	xmm0, xmm4
	mulpd	xmm1, xmm5
	subpd	xmm9, xmm0
	movups	xmm0, XMMWORD PTR [rcx+r11*8]
	subpd	xmm9, xmm1
	movups	xmm1, XMMWORD PTR [rcx+32]
	mulpd	xmm0, xmm2
	mulpd	xmm1, xmm3
	subpd	xmm10, xmm0
	movups	xmm0, XMMWORD PTR [rcx+r15]
	subpd	xmm10, xmm1
	movups	xmm1, XMMWORD PTR [rcx+rsi]
	mulpd	xmm0, xmm4
	mulpd	xmm1, xmm5
	subpd	xmm10, xmm0

; 133  :             p5=_mm_sub_pd(p5,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+10)));

	movups	xmm0, XMMWORD PTR [rcx+rbx*8]
	subpd	xmm10, xmm1
	movups	xmm1, XMMWORD PTR [rcx+48]
	mulpd	xmm0, xmm2
	mulpd	xmm1, xmm3
	subpd	xmm11, xmm0
	movups	xmm0, XMMWORD PTR [rcx+r8*8+48]
	subpd	xmm11, xmm1
	mulpd	xmm0, xmm4
	subpd	xmm11, xmm0
	movups	xmm1, XMMWORD PTR [rcx+r14]

; 134  :             p6=_mm_sub_pd(p6,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+12)));

	mov	r15, QWORD PTR tv12999[rsp]

; 135  :             p7=_mm_sub_pd(p7,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+14)));

	add	QWORD PTR tv12692[rsp], 32		; 00000020H
	mulpd	xmm1, xmm5
	movups	xmm0, XMMWORD PTR [rcx+r15*8]
	mov	r15, QWORD PTR tv12997[rsp]
	subpd	xmm11, xmm1
	movups	xmm1, XMMWORD PTR [rcx+64]
	mulpd	xmm0, xmm2
	mulpd	xmm1, xmm3
	subpd	xmm12, xmm0
	movups	xmm0, XMMWORD PTR [rcx+r8*8+64]
	subpd	xmm12, xmm1
	movups	xmm1, XMMWORD PTR [rcx+rbp*8]
	mulpd	xmm0, xmm4
	mulpd	xmm1, xmm5
	subpd	xmm12, xmm0
	movups	xmm0, XMMWORD PTR [rcx+r15*8]
	mov	r15, QWORD PTR tv12661[rsp]
	subpd	xmm12, xmm1
	movups	xmm1, XMMWORD PTR [rcx+80]
	mulpd	xmm0, xmm2
	mulpd	xmm1, xmm3
	subpd	xmm13, xmm0
	movups	xmm0, XMMWORD PTR [rcx+r8*8+80]
	subpd	xmm13, xmm1
	movups	xmm1, XMMWORD PTR [rcx+r15]
	add	rcx, QWORD PTR tv12637[rsp]
	mulpd	xmm0, xmm4
	mulpd	xmm1, xmm5
	subpd	xmm13, xmm0
	subpd	xmm13, xmm1
	sub	rax, 1
	jne	$LL105@row_update
	mov	r10, QWORD PTR width$[rsp]
	lea	rdi, QWORD PTR [r8*8]
	mov	r11, QWORD PTR j$1$[rsp]
	mov	r9, QWORD PTR coefficients$[rsp]
	mov	rdx, QWORD PTR tv12632[rsp]
	mov	rbx, QWORD PTR k$1$[rsp]
	mov	r14, QWORD PTR count$[rsp]
	mov	r15, QWORD PTR panel$[rsp]
$LN86@row_update:

; 126  :         for(std::size_t k=0;k<width;++k) {

	cmp	rbx, r10
	jae	$LN103@row_update
	mov	rcx, rbx
	imul	rcx, r8
	add	rcx, 4
	add	rcx, r11
	lea	rcx, QWORD PTR [r15+rcx*8]
$LC7@row_update:

; 127  :             const auto multiplier=_mm_set1_pd(coefficients[k]);

	movsd	xmm1, QWORD PTR [r9+rbx*8]
	inc	rbx

; 128  :             p0=_mm_sub_pd(p0,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+0)));

	movups	xmm0, XMMWORD PTR [rcx-32]
	unpcklpd xmm1, xmm1
	mulpd	xmm0, xmm1
	subpd	xmm6, xmm0

; 129  :             p1=_mm_sub_pd(p1,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+2)));

	movups	xmm0, XMMWORD PTR [rcx-16]
	mulpd	xmm0, xmm1
	subpd	xmm7, xmm0

; 130  :             p2=_mm_sub_pd(p2,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+4)));

	movups	xmm0, XMMWORD PTR [rcx]
	mulpd	xmm0, xmm1
	subpd	xmm8, xmm0

; 131  :             p3=_mm_sub_pd(p3,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+6)));

	movups	xmm0, XMMWORD PTR [rcx+16]
	mulpd	xmm0, xmm1
	subpd	xmm9, xmm0

; 132  :             p4=_mm_sub_pd(p4,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+8)));

	movups	xmm0, XMMWORD PTR [rcx+32]
	mulpd	xmm0, xmm1
	subpd	xmm10, xmm0

; 133  :             p5=_mm_sub_pd(p5,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+10)));

	movups	xmm0, XMMWORD PTR [rcx+48]
	mulpd	xmm0, xmm1
	subpd	xmm11, xmm0

; 134  :             p6=_mm_sub_pd(p6,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+12)));

	movups	xmm0, XMMWORD PTR [rcx+64]
	mulpd	xmm0, xmm1
	subpd	xmm12, xmm0

; 135  :             p7=_mm_sub_pd(p7,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+14)));

	movups	xmm0, XMMWORD PTR [rcx+80]
	add	rcx, rdi
	mulpd	xmm0, xmm1
	subpd	xmm13, xmm0
	cmp	rbx, r10
	jb	SHORT $LC7@row_update
	jmp	SHORT $LN74@row_update
$LN103@row_update:
	lea	rdi, QWORD PTR [r8*8]
$LN74@row_update:

; 115  :     std::size_t j=0;
; 116  : #if defined(KIBO_DETAIL_ROW_SSE2)
; 117  :     for(;count-j>=16;j+=16) {

	mov	rcx, QWORD PTR tv12631[rsp]
	add	r11, 16
	mov	rax, r14
	mov	QWORD PTR j$1$[rsp], r11

; 136  :         }
; 137  :         _mm_storeu_pd(row+j+0,p0);

	movups	XMMWORD PTR [rdx-16], xmm6
	sub	rax, r11

; 138  :         _mm_storeu_pd(row+j+2,p1);

	movups	XMMWORD PTR [rdx], xmm7

; 139  :         _mm_storeu_pd(row+j+4,p2);

	movups	XMMWORD PTR [rdx+16], xmm8

; 140  :         _mm_storeu_pd(row+j+6,p3);

	movups	XMMWORD PTR [rdx+32], xmm9

; 141  :         _mm_storeu_pd(row+j+8,p4);

	movups	XMMWORD PTR [rdx+48], xmm10

; 142  :         _mm_storeu_pd(row+j+10,p5);

	movups	XMMWORD PTR [rdx+64], xmm11

; 143  :         _mm_storeu_pd(row+j+12,p6);

	movups	XMMWORD PTR [rdx+80], xmm12

; 144  :         _mm_storeu_pd(row+j+14,p7);

	movups	XMMWORD PTR [rdx+96], xmm13
	sub	rdx, -128				; ffffffffffffff80H
	mov	QWORD PTR tv12632[rsp], rdx
	cmp	rax, 16
	jae	$LL4@row_update

; 115  :     std::size_t j=0;
; 116  : #if defined(KIBO_DETAIL_ROW_SSE2)
; 117  :     for(;count-j>=16;j+=16) {

	movaps	xmm13, XMMWORD PTR [rsp+160]
	movaps	xmm12, XMMWORD PTR [rsp+176]
	movaps	xmm11, XMMWORD PTR [rsp+192]
	movaps	xmm10, XMMWORD PTR [rsp+208]
	mov	rsi, QWORD PTR row$[rsp]
$LN104@row_update:

; 145  :     }
; 146  :     for (;count-j>=8;j+=8) {

	mov	rax, r14
	sub	rax, r11
	cmp	rax, 8
	jb	$LN9@row_update
	lea	rax, QWORD PTR [r8*8+16]
	sub	rax, rsi
	lea	rbx, QWORD PTR [r11+2]
	add	rax, r15
	lea	rbx, QWORD PTR [rsi+rbx*8]
	mov	QWORD PTR tv12630[rsp], rax
	npad	13
$LL10@row_update:

; 147  :         auto first=_mm_loadu_pd(row+j);

	movups	xmm6, XMMWORD PTR [rbx-16]
	xor	edx, edx

; 148  :         auto second=_mm_loadu_pd(row+j+2);

	movups	xmm7, XMMWORD PTR [rbx]

; 149  :         auto third=_mm_loadu_pd(row+j+4);

	movups	xmm8, XMMWORD PTR [rbx+16]

; 150  :         auto fourth=_mm_loadu_pd(row+j+6);

	movups	xmm9, XMMWORD PTR [rbx+32]

; 151  :         for (std::size_t k=0;k<width;++k) {

	cmp	r10, 4
	jb	$LN87@row_update

; 147  :         auto first=_mm_loadu_pd(row+j);

	lea	rbp, QWORD PTR [r8-2]
	mov	r12, r8
	lea	rdx, QWORD PTR [rbp*8]
	shl	r12, 5
	mov	QWORD PTR tv12686[rsp], rdx
	lea	rdi, QWORD PTR [r10-4]
	mov	rdx, r8
	shr	rdi, 2
	neg	rdx
	lea	rcx, QWORD PTR [r9+16]
	mov	r9, QWORD PTR tv12686[rsp]
	mov	rsi, r8
	mov	QWORD PTR tv12857[rsp], rdx
	mov	r13, -2
	mov	r14, QWORD PTR tv12857[rsp]
	mov	edx, 2
	sub	rdx, r8
	add	rax, rbx
	mov	QWORD PTR tv12855[rsp], rdx
	add	rsi, rsi
	mov	r10, QWORD PTR tv12855[rsp]
	mov	rdx, -4
	sub	rdx, r8
	sub	r13, r8
	mov	QWORD PTR tv12852[rsp], rdx
	add	rbp, rbp
	mov	r15, QWORD PTR tv12852[rsp]
	inc	rdi
	lea	rdx, QWORD PTR [rdi*4]
	npad	3

; 151  :         for (std::size_t k=0;k<width;++k) {

$LL79@row_update:

; 152  :             const auto multiplier=_mm_set1_pd(coefficients[k]);

	movsd	xmm2, QWORD PTR [rcx-16]

; 153  :             first=_mm_sub_pd(first,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j)));

	movups	xmm0, XMMWORD PTR [rax+r15*8]
	movsd	xmm3, QWORD PTR [rcx-8]
	movups	xmm1, XMMWORD PTR [rax-32]
	movsd	xmm4, QWORD PTR [rcx]
	movsd	xmm5, QWORD PTR [rcx+8]

; 156  :             fourth=_mm_sub_pd(fourth,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+6)));

	add	rcx, 32					; 00000020H
	unpcklpd xmm2, xmm2
	mulpd	xmm0, xmm2
	unpcklpd xmm3, xmm3
	subpd	xmm6, xmm0
	movups	xmm0, XMMWORD PTR [rax+r8*8-32]
	mulpd	xmm1, xmm3
	unpcklpd xmm4, xmm4
	subpd	xmm6, xmm1
	movups	xmm1, XMMWORD PTR [rax+rbp*8]
	mulpd	xmm0, xmm4
	unpcklpd xmm5, xmm5
	mulpd	xmm1, xmm5
	subpd	xmm6, xmm0
	movups	xmm0, XMMWORD PTR [rax+r13*8]
	subpd	xmm6, xmm1
	movups	xmm1, XMMWORD PTR [rax-16]
	mulpd	xmm0, xmm2
	mulpd	xmm1, xmm3
	subpd	xmm7, xmm0
	movups	xmm0, XMMWORD PTR [r9+rax]
	subpd	xmm7, xmm1
	movups	xmm1, XMMWORD PTR [rax+rsi*8-16]
	mulpd	xmm0, xmm4
	mulpd	xmm1, xmm5
	subpd	xmm7, xmm0
	movups	xmm0, XMMWORD PTR [rax+r14*8]
	subpd	xmm7, xmm1
	movups	xmm1, XMMWORD PTR [rax]
	mulpd	xmm0, xmm2
	mulpd	xmm1, xmm3
	subpd	xmm8, xmm0
	movups	xmm0, XMMWORD PTR [rax+r8*8]
	subpd	xmm8, xmm1
	movups	xmm1, XMMWORD PTR [rax+rsi*8]
	mulpd	xmm0, xmm4
	mulpd	xmm1, xmm5
	subpd	xmm8, xmm0
	movups	xmm0, XMMWORD PTR [rax+r10*8]
	subpd	xmm8, xmm1
	movups	xmm1, XMMWORD PTR [rax+16]
	mulpd	xmm0, xmm2
	mulpd	xmm1, xmm3
	subpd	xmm9, xmm0
	movups	xmm0, XMMWORD PTR [rax+r8*8+16]
	subpd	xmm9, xmm1
	movups	xmm1, XMMWORD PTR [rax+rsi*8+16]
	add	rax, r12
	mulpd	xmm0, xmm4
	mulpd	xmm1, xmm5
	subpd	xmm9, xmm0
	subpd	xmm9, xmm1
	sub	rdi, 1
	jne	$LL79@row_update
	mov	r10, QWORD PTR width$[rsp]
	mov	r9, QWORD PTR coefficients$[rsp]
	mov	r14, QWORD PTR count$[rsp]
	mov	r15, QWORD PTR panel$[rsp]
$LN87@row_update:

; 151  :         for (std::size_t k=0;k<width;++k) {

	cmp	rdx, r10
	jae	SHORT $LN77@row_update
	mov	rcx, rdx
	lea	rdi, QWORD PTR [r8*8]
	imul	rcx, r8
	add	rcx, 4
	add	rcx, r11
	lea	rcx, QWORD PTR [r15+rcx*8]
$LC13@row_update:

; 152  :             const auto multiplier=_mm_set1_pd(coefficients[k]);

	movsd	xmm2, QWORD PTR [r9+rdx*8]
	inc	rdx

; 153  :             first=_mm_sub_pd(first,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j)));

	movups	xmm0, XMMWORD PTR [rcx-32]
	unpcklpd xmm2, xmm2
	mulpd	xmm0, xmm2

; 154  :             second=_mm_sub_pd(second,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+2)));
; 155  :             third=_mm_sub_pd(third,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+4)));

	movaps	xmm1, xmm2
	subpd	xmm6, xmm0
	movups	xmm0, XMMWORD PTR [rcx-16]
	mulpd	xmm0, xmm2
	subpd	xmm7, xmm0
	movups	xmm0, XMMWORD PTR [rcx]
	mulpd	xmm1, xmm0

; 156  :             fourth=_mm_sub_pd(fourth,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+6)));

	movups	xmm0, XMMWORD PTR [rcx+16]
	add	rcx, rdi
	subpd	xmm8, xmm1
	mulpd	xmm0, xmm2
	subpd	xmm9, xmm0
	cmp	rdx, r10
	jb	SHORT $LC13@row_update
$LN77@row_update:

; 145  :     }
; 146  :     for (;count-j>=8;j+=8) {

	add	r11, 8
	mov	rax, r14
	sub	rax, r11

; 157  :         }
; 158  :         _mm_storeu_pd(row+j,first);

	movups	XMMWORD PTR [rbx-16], xmm6

; 159  :         _mm_storeu_pd(row+j+2,second);

	movups	XMMWORD PTR [rbx], xmm7

; 160  :         _mm_storeu_pd(row+j+4,third);

	movups	XMMWORD PTR [rbx+16], xmm8

; 161  :         _mm_storeu_pd(row+j+6,fourth);

	movups	XMMWORD PTR [rbx+32], xmm9
	add	rbx, 64					; 00000040H
	cmp	rax, 8
	mov	rax, QWORD PTR tv12630[rsp]
	jae	$LL10@row_update
	mov	rsi, QWORD PTR row$[rsp]
$LN9@row_update:

; 162  :     }
; 163  :     for (;count-j>=4;j+=4) {

	movaps	xmm9, XMMWORD PTR [rsp+224]
	mov	rax, r14
	movaps	xmm8, XMMWORD PTR [rsp+240]
	sub	rax, r11
	cmp	rax, 4
	jb	$LN15@row_update
	npad	9
$LL16@row_update:

; 164  :         auto first=_mm_loadu_pd(row+j);

	movups	xmm6, XMMWORD PTR [rsi+r11*8]
	xor	edx, edx

; 165  :         auto second=_mm_loadu_pd(row+j+2);

	movups	xmm7, XMMWORD PTR [rsi+r11*8+16]

; 166  :         for (std::size_t k=0;k<width;++k) {

	cmp	r10, 4
	jb	$LN88@row_update

; 164  :         auto first=_mm_loadu_pd(row+j);

	lea	rax, QWORD PTR [r8+1]
	mov	rdi, r8
	lea	rax, QWORD PTR [r11+rax*2]
	neg	rdi
	lea	rcx, QWORD PTR [r15+rax*8]
	mov	rsi, -1
	sub	rsi, r8
	lea	rax, QWORD PTR [r10-4]
	mov	rbp, r8
	shr	rax, 2
	mov	r12, r8
	shl	rbp, 5
	mov	r13, -2
	lea	rbx, QWORD PTR [r9+16]
	neg	r12
	add	rdi, rdi
	sub	r13, r8
	add	rsi, rsi
	inc	rax
	lea	rdx, QWORD PTR [rax*4]
	npad	9

; 166  :         for (std::size_t k=0;k<width;++k) {

$LL82@row_update:

; 167  :             const auto multiplier=_mm_set1_pd(coefficients[k]);

	movsd	xmm2, QWORD PTR [rbx-16]

; 168  :             first=_mm_sub_pd(first,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j)));

	movups	xmm0, XMMWORD PTR [rcx+rsi*8]
	movsd	xmm3, QWORD PTR [rbx-8]
	movups	xmm1, XMMWORD PTR [rcx+r13*8]
	movsd	xmm4, QWORD PTR [rbx]
	movsd	xmm5, QWORD PTR [rbx+8]

; 169  :             second=_mm_sub_pd(second,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+2)));

	add	rbx, 32					; 00000020H
	unpcklpd xmm2, xmm2
	mulpd	xmm0, xmm2
	unpcklpd xmm3, xmm3
	subpd	xmm6, xmm0
	movups	xmm0, XMMWORD PTR [rcx-16]
	mulpd	xmm1, xmm3
	unpcklpd xmm4, xmm4
	mulpd	xmm0, xmm4
	subpd	xmm6, xmm1
	movups	xmm1, XMMWORD PTR [rcx+r8*8-16]
	subpd	xmm6, xmm0
	movups	xmm0, XMMWORD PTR [rcx+rdi*8]
	unpcklpd xmm5, xmm5
	mulpd	xmm0, xmm2
	mulpd	xmm1, xmm5
	subpd	xmm7, xmm0
	movups	xmm0, XMMWORD PTR [rcx]
	subpd	xmm6, xmm1
	movups	xmm1, XMMWORD PTR [rcx+r12*8]
	mulpd	xmm4, xmm0
	movups	xmm0, XMMWORD PTR [rcx+r8*8]
	add	rcx, rbp
	mulpd	xmm1, xmm3
	mulpd	xmm0, xmm5
	subpd	xmm7, xmm1
	subpd	xmm7, xmm4
	subpd	xmm7, xmm0
	sub	rax, 1
	jne	$LL82@row_update
	mov	rsi, QWORD PTR row$[rsp]
$LN88@row_update:

; 166  :         for (std::size_t k=0;k<width;++k) {

	cmp	rdx, r10
	jae	SHORT $LN80@row_update
	mov	rax, rdx
	lea	rbx, QWORD PTR [r8*8]
	imul	rax, r8
	add	rax, r11
	lea	rcx, QWORD PTR [r15+rax*8]
$LC19@row_update:

; 167  :             const auto multiplier=_mm_set1_pd(coefficients[k]);

	movsd	xmm1, QWORD PTR [r9+rdx*8]
	inc	rdx

; 168  :             first=_mm_sub_pd(first,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j)));

	movups	xmm0, XMMWORD PTR [rcx]
	unpcklpd xmm1, xmm1
	mulpd	xmm0, xmm1
	subpd	xmm6, xmm0

; 169  :             second=_mm_sub_pd(second,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+2)));

	movups	xmm0, XMMWORD PTR [rcx+16]
	add	rcx, rbx
	mulpd	xmm0, xmm1
	subpd	xmm7, xmm0
	cmp	rdx, r10
	jb	SHORT $LC19@row_update
$LN80@row_update:

; 170  :         }
; 171  :         _mm_storeu_pd(row+j,first);

	movups	XMMWORD PTR [rsi+r11*8], xmm6
	mov	rax, r14

; 172  :         _mm_storeu_pd(row+j+2,second);

	movups	XMMWORD PTR [rsi+r11*8+16], xmm7
	add	r11, 4
	sub	rax, r11
	cmp	rax, 4
	jae	$LL16@row_update
$LN15@row_update:

; 173  :     }
; 174  :     for (;count-j>=2;j+=2) {

	movaps	xmm7, XMMWORD PTR [rsp+256]
	mov	rax, r14
	movaps	xmm6, XMMWORD PTR [rsp+272]
	sub	rax, r11
	mov	r13, QWORD PTR [rsp+288]
	mov	r12, QWORD PTR [rsp+296]
	cmp	rax, 2
	jb	$LN21@row_update
	npad	10
$LL22@row_update:

; 175  :         auto updated=_mm_loadu_pd(row+j);

	movups	xmm3, XMMWORD PTR [rsi+r11*8]
	xor	ebx, ebx

; 176  :         for (std::size_t k=0;k<width;++k)

	cmp	r10, 4
	jb	$LC84@row_update

; 175  :         auto updated=_mm_loadu_pd(row+j);

	lea	rax, QWORD PTR [r11+r8*2]
	mov	rdi, r8
	lea	rdx, QWORD PTR [r15+rax*8]
	neg	rdi
	lea	rax, QWORD PTR [r10-4]
	mov	rsi, r8
	mov	rbp, r8
	shr	rax, 2
	shl	rsi, 5
	lea	rcx, QWORD PTR [r9+16]
	neg	rbp
	add	rdi, rdi
	inc	rax
	lea	rbx, QWORD PTR [rax*4]
	npad	10

; 176  :         for (std::size_t k=0;k<width;++k)

$LL85@row_update:

; 177  :             updated=_mm_sub_pd(updated,_mm_mul_pd(_mm_set1_pd(coefficients[k]),_mm_loadu_pd(panel+k*stride+j)));

	movups	xmm0, XMMWORD PTR [rdx+rdi*8]
	movsd	xmm1, QWORD PTR [rcx-16]
	movsd	xmm2, QWORD PTR [rcx-8]
	unpcklpd xmm1, xmm1
	mulpd	xmm1, xmm0
	movups	xmm0, XMMWORD PTR [rdx+rbp*8]
	subpd	xmm3, xmm1
	movsd	xmm1, QWORD PTR [rcx]
	unpcklpd xmm2, xmm2
	mulpd	xmm2, xmm0
	movups	xmm0, XMMWORD PTR [rdx]
	subpd	xmm3, xmm2
	movsd	xmm2, QWORD PTR [rcx+8]
	add	rcx, 32					; 00000020H
	unpcklpd xmm1, xmm1
	mulpd	xmm1, xmm0
	movups	xmm0, XMMWORD PTR [rdx+r8*8]
	add	rdx, rsi
	unpcklpd xmm2, xmm2
	mulpd	xmm2, xmm0
	subpd	xmm3, xmm1
	subpd	xmm3, xmm2
	sub	rax, 1
	jne	SHORT $LL85@row_update
	mov	rsi, QWORD PTR row$[rsp]
$LC84@row_update:

; 176  :         for (std::size_t k=0;k<width;++k)

	cmp	rbx, r10
	jae	SHORT $LN83@row_update
	mov	rax, rbx
	lea	rdx, QWORD PTR [r8*8]
	imul	rax, r8
	add	rax, r11
	lea	rcx, QWORD PTR [r15+rax*8]
$LC25@row_update:

; 177  :             updated=_mm_sub_pd(updated,_mm_mul_pd(_mm_set1_pd(coefficients[k]),_mm_loadu_pd(panel+k*stride+j)));

	movsd	xmm1, QWORD PTR [r9+rbx*8]
	inc	rbx
	movups	xmm0, XMMWORD PTR [rcx]
	add	rcx, rdx
	unpcklpd xmm1, xmm1
	mulpd	xmm1, xmm0
	subpd	xmm3, xmm1
	cmp	rbx, r10
	jb	SHORT $LC25@row_update
$LN83@row_update:

; 178  :         _mm_storeu_pd(row+j,updated);

	movups	XMMWORD PTR [rsi+r11*8], xmm3
	add	r11, 2
	mov	rax, r14
	sub	rax, r11
	cmp	rax, 2
	jae	$LL22@row_update
$LN21@row_update:
	mov	rdi, QWORD PTR [rsp+304]

; 179  :     }
; 180  : #endif
; 181  :     for (;j<count;++j) for (std::size_t k=0;k<width;++k) row[j]-=coefficients[k]*panel[k*stride+j];

	mov	rbp, QWORD PTR [rsp+312]
	mov	rbx, QWORD PTR [rsp+368]
	cmp	r11, r14
	jae	SHORT $LN27@row_update
	sub	r15, rsi
	lea	rdx, QWORD PTR [rsi+r11*8]
	sub	r14, r11
$LL28@row_update:
	xor	eax, eax
	test	r10, r10
	je	SHORT $LN26@row_update
	movsd	xmm1, QWORD PTR [rdx]
	lea	r11, QWORD PTR [r8*8]
	lea	rcx, QWORD PTR [r15+rdx]
	npad	6
$LL31@row_update:
	movsd	xmm0, QWORD PTR [r9+rax*8]
	inc	rax
	mulsd	xmm0, QWORD PTR [rcx]
	add	rcx, r11
	subsd	xmm1, xmm0
	cmp	rax, r10
	jb	SHORT $LL31@row_update
	movsd	QWORD PTR [rdx], xmm1
$LN26@row_update:
	add	rdx, 8
	sub	r14, 1
	jne	SHORT $LL28@row_update
$LN27@row_update:

; 182  : }

	add	rsp, 320				; 00000140H
	pop	r15
	pop	r14
	pop	rsi
	ret	0
?row_update_panel@detail@linalg@kibo@@YAXPEANPEBN_K122@Z ENDP ; kibo::linalg::detail::row_update_panel