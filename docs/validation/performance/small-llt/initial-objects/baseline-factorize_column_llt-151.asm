?factorize_column_llt@detail@linalg@kibo@@YA?AV?$Result@VLltFactorView@linalg@kibo@@@23@V?$MatrixView@$$CBN@23@V?$MatrixView@N@23@@Z PROC ; kibo::linalg::detail::factorize_column_llt, COMDAT

; 30   : inline Result<LltFactorView> factorize_column_llt(MatrixView<const double> input, MatrixView<double> storage) noexcept {

$LN735:
	mov	rax, rsp
	mov	QWORD PTR [rax+24], r8
	mov	QWORD PTR [rax+16], rdx
	mov	QWORD PTR [rax+8], rcx
	push	rbx
	push	rbp
	push	rsi
	push	rdi
	push	r12
	push	r13
	push	r14
	push	r15
	sub	rsp, 232				; 000000e8H

; 31   :     // Input is fully validated and independent of storage. Compute through a
; 32   :     // transposed view so panel columns are contiguous without heap/workspace.
; 33   :     const auto n=input.rows();

	mov	r12, QWORD PTR [rdx+16]
	mov	r13, rdx
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 57   :         : storage_(storage), rows_(rows), cols_(cols), row_stride_(rs), col_stride_(cs) {}

	movups	xmm0, XMMWORD PTR [r8]
	mov	rdi, QWORD PTR [r8+40]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 30   : inline Result<LltFactorView> factorize_column_llt(MatrixView<const double> input, MatrixView<double> storage) noexcept {

	movaps	XMMWORD PTR [rax-88], xmm6
	movaps	XMMWORD PTR [rax-104], xmm7
	movaps	XMMWORD PTR [rax-120], xmm8
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 57   :         : storage_(storage), rows_(rows), cols_(cols), row_stride_(rs), col_stride_(cs) {}

	mov	rax, QWORD PTR [r8+32]
	mov	QWORD PTR working$$sroa$2685$1$[rsp], rax
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 30   : inline Result<LltFactorView> factorize_column_llt(MatrixView<const double> input, MatrixView<double> storage) noexcept {

	xor	eax, eax

; 31   :     // Input is fully validated and independent of storage. Compute through a
; 32   :     // transposed view so panel columns are contiguous without heap/workspace.
; 33   :     const auto n=input.rows();

	mov	QWORD PTR n$1$[rsp], r12
	mov	r10d, eax
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 57   :         : storage_(storage), rows_(rows), cols_(cols), row_stride_(rs), col_stride_(cs) {}

	mov	QWORD PTR working$$sroa$2684$1$[rsp], rdi
	movups	XMMWORD PTR working$[rsp], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 35   :     for (std::size_t j=0;j<n;++j) for (std::size_t i=j;i<n;++i) working(i,j)=input(i,j);

	test	r12, r12
	je	$LN36@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	lea	rdx, QWORD PTR [rdi+rdi]
	mov	QWORD PTR tv12802[rsp], rax
	mov	QWORD PTR tv12793[rsp], rdx
	mov	ecx, eax
	npad	9
$LL4@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 35   :     for (std::size_t j=0;j<n;++j) for (std::size_t i=j;i<n;++i) working(i,j)=input(i,j);

	mov	r15, QWORD PTR [r13]
	mov	rax, r12
	sub	rax, r10
	mov	r14, r10
	cmp	rax, 4
	jb	$LN643@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r9, QWORD PTR [r13+32]
	lea	rax, QWORD PTR [rdx+rcx]
	mov	rdx, QWORD PTR working$[rsp]
	lea	rcx, QWORD PTR [r10+2]
	imul	rcx, r9
	mov	rsi, rdi
	mov	rbp, r9
	lea	r12, QWORD PTR [r9*8]
	shl	rsi, 5
	mov	r11, r9
	shl	rbp, 5
	mov	rbx, rdi
	lea	rdx, QWORD PTR [rdx+rax*8]
	neg	r9
	neg	rdi
	mov	rax, r10
	neg	r11
	imul	rax, QWORD PTR [r13+40]
	mov	r13, QWORD PTR working$$sroa$2684$1$[rsp]
	neg	rbx
	add	rcx, rax
	add	r9, r9
	add	rdi, rdi
	lea	r8, QWORD PTR [r15+rcx*8]
	mov	rcx, QWORD PTR n$1$[rsp]
	sub	rcx, r10
	sub	rcx, 4
	shr	rcx, 2
	inc	rcx
	lea	r14, QWORD PTR [r10+rcx*4]
	npad	4
$LL478@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 35   :     for (std::size_t j=0;j<n;++j) for (std::size_t i=j;i<n;++i) working(i,j)=input(i,j);

	mov	rax, QWORD PTR [r8+r9*8]
	mov	QWORD PTR [rdx+rdi*8], rax
	mov	rax, QWORD PTR [r8+r11*8]
	mov	QWORD PTR [rdx+rbx*8], rax
	mov	rax, QWORD PTR [r8]
	mov	QWORD PTR [rdx], rax
	mov	rax, QWORD PTR [r12+r8]
	add	r8, rbp
	mov	QWORD PTR [rdx+r13*8], rax
	add	rdx, rsi
	sub	rcx, 1
	jne	SHORT $LL478@factorize_
	mov	r12, QWORD PTR n$1$[rsp]
	mov	r13, QWORD PTR input$[rsp]
	mov	rdi, QWORD PTR working$$sroa$2684$1$[rsp]
	cmp	r14, r12
	jb	SHORT $LN643@factorize_
	mov	rbp, QWORD PTR working$[rsp]
	jmp	SHORT $LN2@factorize_
$LN643@factorize_:
	mov	rcx, QWORD PTR [r13+32]
	lea	r9, QWORD PTR [rdi*8]
	mov	rbp, QWORD PTR working$[rsp]
	mov	rax, rdi
	imul	rax, r14
	lea	r11, QWORD PTR [rcx*8]
	add	rax, QWORD PTR tv12802[rsp]
	imul	rcx, r14
	lea	rdx, QWORD PTR [rax*8]
	mov	rax, r10
	imul	rax, QWORD PTR [r13+40]
	add	rdx, rbp
	add	rcx, rax
	lea	r8, QWORD PTR [r15+rcx*8]
	mov	rcx, r12
	sub	rcx, r14
$LC7@factorize_:
	mov	rax, QWORD PTR [r8]
	add	r8, r11
	mov	QWORD PTR [rdx], rax
	add	rdx, r9
	sub	rcx, 1
	jne	SHORT $LC7@factorize_
$LN2@factorize_:
	mov	rdx, QWORD PTR tv12793[rsp]
	inc	r10
	mov	rcx, QWORD PTR tv12802[rsp]
	add	rdx, rdi
	mov	r11, QWORD PTR working$$sroa$2685$1$[rsp]
	add	rcx, r11
	mov	QWORD PTR tv12793[rsp], rdx
	mov	QWORD PTR tv12802[rsp], rcx
	cmp	r10, r12
	jb	$LL4@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	movdqa	xmm6, XMMWORD PTR __xmm@7fffffffffffffff7fffffffffffffff
	lea	r14, QWORD PTR [r11+rdi]
	movsd	xmm7, QWORD PTR __real@7fefffffffffffff
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 38   :         for (std::size_t k=first;k<end;++k) {

	xor	ecx, ecx
	mov	QWORD PTR first$1$[rsp], rcx
	xorps	xmm8, xmm8
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	QWORD PTR tv12845[rsp], r14
	npad	11
$LL10@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 37   :         const auto end=first+std::min(std::size_t{8},n-first);

	mov	edx, 8

; 38   :         for (std::size_t k=first;k<end;++k) {

	mov	QWORD PTR k$1$[rsp], rcx
	mov	rax, r12
	mov	r10, rcx
	sub	rax, rcx
	cmp	rax, rdx
	cmovb	rdx, rax
	mov	QWORD PTR tv12843[rsp], rdx
	lea	rbx, QWORD PTR [rdx+rcx]
	mov	QWORD PTR end$1$[rsp], rbx
	cmp	rcx, rbx
	jae	$LN664@factorize_

; 37   :         const auto end=first+std::min(std::size_t{8},n-first);

	mov	r13, r11
	lea	r15, QWORD PTR [rcx+1]
	mov	rax, r14
	mov	r11, r15
	imul	rax, rcx
	imul	r11, rdi
	imul	r13, rcx
	lea	r12, QWORD PTR [rax*8]
	mov	QWORD PTR tv12758[rsp], r11
	add	r12, rbp
	npad	3
$LL13@factorize_:

; 39   :             const double diagonal=working(k,k);

	movsd	xmm1, QWORD PTR [r12]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movaps	xmm0, xmm1
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm7, xmm0

; 40   :             if (!detail::llt_is_finite(diagonal)) return Status{StatusCode::arithmetic_failure,k};

	jb	$LN388@factorize_

; 41   :             if (diagonal<=0) return Status{StatusCode::non_positive_pivot,k};

	comisd	xmm8, xmm1
	jae	$LN389@factorize_

; 42   :             working(k,k)=std::sqrt(diagonal);

	xorps	xmm0, xmm0
	ucomisd	xmm0, xmm1
	ja	SHORT $LN655@factorize_
	sqrtpd	xmm0, xmm1
	jmp	SHORT $LN656@factorize_
$LN655@factorize_:
	movaps	xmm0, xmm1
	call	sqrt
	mov	r11, QWORD PTR tv12758[rsp]
	mov	r10, QWORD PTR k$1$[rsp]
$LN656@factorize_:
	movsd	QWORD PTR [r12], xmm0

; 43   :             for (std::size_t i=k+1;i<end;++i) {

	mov	rdx, r15
	cmp	r15, rbx
	jae	$LN11@factorize_
	mov	r8, r14
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	lea	rax, QWORD PTR [r11+r13]
	imul	r8, r10
	lea	rcx, QWORD PTR [rax*8]
	add	rcx, rbp
	lea	r9, QWORD PTR [rdi*8]
$LL16@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 44   :                 const double value=working(i,k)/working(k,k);

	movsd	xmm1, QWORD PTR [rcx]
	divsd	xmm1, QWORD PTR [rbp+r8*8]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movaps	xmm0, xmm1
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm7, xmm0

; 45   :                 if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,k};

	jb	$LN388@factorize_

; 46   :                 working(i,k)=value;

	movsd	QWORD PTR [rcx], xmm1
	inc	rdx
	add	rcx, r9
	cmp	rdx, rbx
	jb	SHORT $LL16@factorize_

; 48   :             for (std::size_t j=k+1;j<end;++j)

	mov	rdx, QWORD PTR working$[rsp]
	lea	rbp, QWORD PTR [r14*8]
	lea	rax, QWORD PTR [r11+r13]
	mov	rsi, r15
	lea	r14, QWORD PTR [rdi*8]
	lea	r10, QWORD PTR [r12+rbp]
	lea	r11, QWORD PTR [rdx+rax*8]
$LL19@factorize_:

; 49   :                 row_update(&working(j,j),&working(j,k),end-j,working(j,k));

	movsd	xmm3, QWORD PTR [r11]
	mov	r8, rbx
	sub	r8, rsi
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\detail\row_kernels.hpp

; 39   :     std::size_t j=0;

	xor	edx, edx

; 48   : #endif
; 49   :     for (;j<count;++j) row[j]-=value*projection[j];

	movaps	xmm4, xmm3
	movaps	xmm2, xmm3
	unpcklpd xmm4, xmm4
	unpcklpd xmm2, xmm2
	cmp	r8, 4
	jb	SHORT $LN204@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r9, r11
	lea	rcx, QWORD PTR [r10+16]
	sub	r9, r10
	npad	5
$LL205@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\detail\row_kernels.hpp

; 43   :         _mm_storeu_pd(row+j,_mm_sub_pd(_mm_loadu_pd(row+j),_mm_mul_pd(multiplier,_mm_loadu_pd(projection+j))));

	movups	xmm1, XMMWORD PTR [rcx+r9-16]
	add	rdx, 4
	mov	rax, r8
	movups	xmm0, XMMWORD PTR [rcx-16]
	sub	rax, rdx
	mulpd	xmm1, xmm2
	subpd	xmm0, xmm1
	movups	XMMWORD PTR [rcx-16], xmm0

; 44   :         _mm_storeu_pd(row+j+2,_mm_sub_pd(_mm_loadu_pd(row+j+2),_mm_mul_pd(multiplier,_mm_loadu_pd(projection+j+2))));

	movups	xmm1, XMMWORD PTR [rcx+r9]
	movups	xmm0, XMMWORD PTR [rcx]
	mulpd	xmm1, xmm2
	subpd	xmm0, xmm1
	movups	XMMWORD PTR [rcx], xmm0
	add	rcx, 32					; 00000020H
	cmp	rax, 4
	jae	SHORT $LL205@factorize_
$LN204@factorize_:

; 45   :     }
; 46   :     for (;count-j>=2;j+=2)

	mov	rax, r8
	sub	rax, rdx
	cmp	rax, 2
	jb	SHORT $LN207@factorize_
	mov	r9, r11
	lea	rcx, QWORD PTR [r10+rdx*8]
	sub	r9, r10
	npad	13
$LL208@factorize_:

; 47   :         _mm_storeu_pd(row+j,_mm_sub_pd(_mm_loadu_pd(row+j),_mm_mul_pd(multiplier,_mm_loadu_pd(projection+j))));

	movups	xmm1, XMMWORD PTR [r9+rcx]
	add	rdx, 2
	mov	rax, r8
	movups	xmm0, XMMWORD PTR [rcx]
	sub	rax, rdx
	mulpd	xmm1, xmm2
	subpd	xmm0, xmm1
	movups	XMMWORD PTR [rcx], xmm0
	add	rcx, 16
	cmp	rax, 2
	jae	SHORT $LL208@factorize_
$LN207@factorize_:

; 48   : #endif
; 49   :     for (;j<count;++j) row[j]-=value*projection[j];

	mov	r9, r8
	sub	r9, rdx
	cmp	rdx, r8
	jae	$LN17@factorize_
	cmp	r9, 8
	jb	$LN651@factorize_
	mov	rbx, r8
	lea	rax, QWORD PTR [r8-1]
	shl	rbx, 4
	lea	rax, QWORD PTR [r11+rax*8]
	add	rbx, -16
	lea	rdi, QWORD PTR [r11+rdx*8]
	mov	rcx, rdx
	add	rbx, r10
	shl	rcx, 4
	add	rcx, r10
	cmp	rcx, rax
	ja	SHORT $LN441@factorize_
	cmp	rbx, rdi
	jae	$LN661@factorize_
$LN441@factorize_:
	and	r9d, 7
	mov	rbx, r8
	sub	rbx, r9
	lea	rax, QWORD PTR [rdx+2]
	mov	rcx, r11
	lea	rax, QWORD PTR [r10+rax*8]
	sub	rcx, r10
	npad	6
$LL211@factorize_:
	movups	xmm1, XMMWORD PTR [rax-16]
	add	rdx, 8
	movups	xmm0, XMMWORD PTR [rax+rcx-16]
	mulpd	xmm0, xmm4
	subpd	xmm1, xmm0
	movups	xmm0, XMMWORD PTR [rax+rcx]
	movups	XMMWORD PTR [rax-16], xmm1
	movups	xmm2, XMMWORD PTR [rax]
	mulpd	xmm0, xmm4
	subpd	xmm2, xmm0
	movups	xmm0, XMMWORD PTR [rcx+rax+16]
	movups	XMMWORD PTR [rax], xmm2
	movups	xmm1, XMMWORD PTR [rax+16]
	mulpd	xmm0, xmm4
	subpd	xmm1, xmm0
	movups	xmm0, XMMWORD PTR [rcx+rax+32]
	movups	XMMWORD PTR [rax+16], xmm1
	movups	xmm1, XMMWORD PTR [rax+32]
	mulpd	xmm0, xmm4
	subpd	xmm1, xmm0
	movups	XMMWORD PTR [rax+32], xmm1
	add	rax, 64					; 00000040H
	cmp	rdx, rbx
	jb	SHORT $LL211@factorize_
	mov	rbx, QWORD PTR end$1$[rsp]
	cmp	rdx, r8
	jae	$LN17@factorize_
	jmp	SHORT $LN651@factorize_
$LN661@factorize_:
	mov	rbx, QWORD PTR end$1$[rsp]
$LN651@factorize_:
	mov	rax, r8
	sub	rax, rdx
	cmp	rax, 4
	jb	$LN650@factorize_
	lea	rax, QWORD PTR [rdx+1]
	mov	r9, r8
	sub	r9, rdx
	lea	rax, QWORD PTR [r10+rax*8]
	sub	r9, 4
	mov	rcx, r11
	shr	r9, 2
	sub	rcx, r10
	inc	r9
	lea	rdx, QWORD PTR [rdx+r9*4]
	npad	4
$LL481@factorize_:
	movsd	xmm0, QWORD PTR [rax-8]
	movaps	xmm1, xmm3
	mulsd	xmm1, QWORD PTR [rax+rcx-8]
	movaps	xmm2, xmm3
	subsd	xmm0, xmm1
	movaps	xmm1, xmm3
	movsd	QWORD PTR [rax-8], xmm0
	mulsd	xmm2, QWORD PTR [rax+rcx]
	movsd	xmm0, QWORD PTR [rax]
	subsd	xmm0, xmm2
	movsd	QWORD PTR [rax], xmm0
	mulsd	xmm1, QWORD PTR [rax+rcx+8]
	movsd	xmm0, QWORD PTR [rax+8]
	subsd	xmm0, xmm1
	movaps	xmm1, xmm3
	movsd	QWORD PTR [rax+8], xmm0
	mulsd	xmm1, QWORD PTR [rax+rcx+16]
	movsd	xmm0, QWORD PTR [rax+16]
	subsd	xmm0, xmm1
	movsd	QWORD PTR [rax+16], xmm0
	add	rax, 32					; 00000020H
	sub	r9, 1
	jne	SHORT $LL481@factorize_
	cmp	rdx, r8
	jae	SHORT $LN17@factorize_
$LN650@factorize_:
	mov	rcx, r11
	lea	rax, QWORD PTR [r10+rdx*8]
	sub	rcx, r10
	sub	r8, rdx
$LC439@factorize_:
	movsd	xmm0, QWORD PTR [rax]
	movaps	xmm1, xmm3
	mulsd	xmm1, QWORD PTR [rcx+rax]
	subsd	xmm0, xmm1
	movsd	QWORD PTR [rax], xmm0
	add	rax, 8
	sub	r8, 1
	jne	SHORT $LC439@factorize_
$LN17@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 48   :             for (std::size_t j=k+1;j<end;++j)

	inc	rsi
	add	r11, r14
	add	r10, rbp
	cmp	rsi, rbx
	jb	$LL19@factorize_
	mov	r11, QWORD PTR tv12758[rsp]
	mov	r10, QWORD PTR k$1$[rsp]
	mov	rbp, QWORD PTR working$[rsp]
	mov	rdi, QWORD PTR working$$sroa$2684$1$[rsp]
	mov	r14, QWORD PTR tv12845[rsp]
$LN11@factorize_:

; 38   :         for (std::size_t k=first;k<end;++k) {

	mov	rdx, QWORD PTR storage$[rsp]
	lea	rax, QWORD PTR [r14*8]
	inc	r10
	add	r11, rdi
	add	r12, rax
	mov	QWORD PTR k$1$[rsp], r10
	inc	r15
	mov	QWORD PTR tv12758[rsp], r11
	add	r13, QWORD PTR [rdx+32]
	cmp	r10, rbx
	jb	$LL13@factorize_
	mov	r11, QWORD PTR working$$sroa$2685$1$[rsp]
	mov	rcx, QWORD PTR first$1$[rsp]
	mov	r12, QWORD PTR n$1$[rsp]
	jmp	SHORT $LN658@factorize_
$LN664@factorize_:
	mov	rdx, QWORD PTR storage$[rsp]
$LN658@factorize_:

; 50   :         }
; 51   :         if (end<n) for (std::size_t k=first;k<end;++k) {

	cmp	rbx, r12
	jae	$LN644@factorize_
	mov	QWORD PTR k$1$[rsp], rcx
	mov	r8, rcx
	cmp	rcx, rbx
	jae	$LN20@factorize_
	mov	rax, rdi
	lea	r10, QWORD PTR [rcx+1]
	imul	rax, rbx
	imul	r10, rdi
	lea	r15, QWORD PTR [rdi*8]
	mov	r9, r11
	imul	r9, rcx
	lea	rcx, QWORD PTR [r11*8]
	add	rax, r9
	mov	rdi, rcx
	lea	rsi, QWORD PTR [rax*8]
	add	rsi, rbp
	sub	rdi, rbp
	mov	QWORD PTR tv12712[rsp], rdi
$LN729@factorize_:

; 52   :             for (std::size_t i=end;i<n;++i) {

	mov	rdx, r14
	mov	QWORD PTR tv12611[rsp], r10
	imul	rdx, r8
	mov	QWORD PTR tv12609[rsp], r9
	mov	rcx, rbx
	mov	rax, rsi
	npad	3
$LL25@factorize_:

; 53   :                 const double value=working(i,k)/working(k,k);

	movsd	xmm1, QWORD PTR [rax]
	divsd	xmm1, QWORD PTR [rbp+rdx*8]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movaps	xmm0, xmm1
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm7, xmm0

; 54   :                 if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,k};

	jb	$LN390@factorize_

; 55   :                 working(i,k)=value;

	movsd	QWORD PTR [rax], xmm1
	inc	rcx
	add	rax, r15
	cmp	rcx, r12
	jb	SHORT $LL25@factorize_

; 57   :             for (std::size_t j=k+1;j<end;++j)

	lea	rcx, QWORD PTR [r8+1]
	cmp	rcx, rbx
	jae	$LN663@factorize_
	lea	rax, QWORD PTR [r10+r9]
	mov	r8, r12
	mov	r10, QWORD PTR working$[rsp]
	lea	r12, QWORD PTR [r11*8]
	add	r10, rdi
	lea	r13, QWORD PTR [r11*8]
	add	r10, rsi
	lea	r11, QWORD PTR [r12+rsi]
	neg	r10
	lea	rbp, QWORD PTR [rbp+rax*8]
	sub	r8, rbx
	mov	r14, rbx
	sub	r14, rcx
	npad	3
$LL28@factorize_:

; 58   :                 row_update(&working(end,j),&working(end,k),n-end,working(j,k));

	movsd	xmm3, QWORD PTR [rbp]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\detail\row_kernels.hpp

; 39   :     std::size_t j=0;

	xor	edx, edx

; 48   : #endif
; 49   :     for (;j<count;++j) row[j]-=value*projection[j];

	movaps	xmm4, xmm3
	movaps	xmm2, xmm3
	unpcklpd xmm4, xmm4
	unpcklpd xmm2, xmm2
	cmp	r8, 4
	jb	SHORT $LN117@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	lea	rcx, QWORD PTR [r11+16]
	lea	r9, QWORD PTR [r10+rsi]
$LL118@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\detail\row_kernels.hpp

; 43   :         _mm_storeu_pd(row+j,_mm_sub_pd(_mm_loadu_pd(row+j),_mm_mul_pd(multiplier,_mm_loadu_pd(projection+j))));

	movups	xmm1, XMMWORD PTR [rcx+r9-16]
	add	rdx, 4
	mov	rax, r8
	movups	xmm0, XMMWORD PTR [rcx-16]
	sub	rax, rdx
	mulpd	xmm1, xmm2
	subpd	xmm0, xmm1
	movups	XMMWORD PTR [rcx-16], xmm0

; 44   :         _mm_storeu_pd(row+j+2,_mm_sub_pd(_mm_loadu_pd(row+j+2),_mm_mul_pd(multiplier,_mm_loadu_pd(projection+j+2))));

	movups	xmm1, XMMWORD PTR [rcx+r9]
	movups	xmm0, XMMWORD PTR [rcx]
	mulpd	xmm1, xmm2
	subpd	xmm0, xmm1
	movups	XMMWORD PTR [rcx], xmm0
	add	rcx, 32					; 00000020H
	cmp	rax, 4
	jae	SHORT $LL118@factorize_
$LN117@factorize_:

; 45   :     }
; 46   :     for (;count-j>=2;j+=2)

	mov	rax, r8
	sub	rax, rdx
	cmp	rax, 2
	jb	SHORT $LN120@factorize_
	lea	rcx, QWORD PTR [r11+rdx*8]
	lea	r9, QWORD PTR [r10+rsi]
	npad	12
$LL121@factorize_:

; 47   :         _mm_storeu_pd(row+j,_mm_sub_pd(_mm_loadu_pd(row+j),_mm_mul_pd(multiplier,_mm_loadu_pd(projection+j))));

	movups	xmm1, XMMWORD PTR [rcx+r9]
	add	rdx, 2
	mov	rax, r8
	movups	xmm0, XMMWORD PTR [rcx]
	sub	rax, rdx
	mulpd	xmm1, xmm2
	subpd	xmm0, xmm1
	movups	XMMWORD PTR [rcx], xmm0
	add	rcx, 16
	cmp	rax, 2
	jae	SHORT $LL121@factorize_
$LN120@factorize_:

; 48   : #endif
; 49   :     for (;j<count;++j) row[j]-=value*projection[j];

	mov	r9, r8
	sub	r9, rdx
	cmp	rdx, r8
	jae	$LN26@factorize_
	cmp	r9, 8
	jb	$LN649@factorize_
	mov	rbx, r8
	lea	rax, QWORD PTR [r8-1]
	shl	rbx, 4
	lea	rax, QWORD PTR [rsi+rax*8]
	add	rbx, -16
	lea	rdi, QWORD PTR [rsi+rdx*8]
	mov	rcx, rdx
	add	rbx, r11
	shl	rcx, 4
	add	rcx, r11
	cmp	rcx, rax
	ja	SHORT $LN444@factorize_
	cmp	rbx, rdi
	jae	$LN649@factorize_
$LN444@factorize_:
	and	r9d, 7
	mov	rcx, r8
	sub	rcx, r9
	lea	rax, QWORD PTR [rdx+2]
	lea	rax, QWORD PTR [r11+rax*8]
	lea	r9, QWORD PTR [r10+rsi]
	npad	8
$LL124@factorize_:
	movups	xmm1, XMMWORD PTR [rax-16]
	add	rdx, 8
	movups	xmm0, XMMWORD PTR [rax+r9-16]
	mulpd	xmm0, xmm4
	subpd	xmm1, xmm0
	movups	xmm0, XMMWORD PTR [rax+r9]
	movups	XMMWORD PTR [rax-16], xmm1
	movups	xmm2, XMMWORD PTR [rax]
	mulpd	xmm0, xmm4
	subpd	xmm2, xmm0
	movups	xmm0, XMMWORD PTR [rax+r9+16]
	movups	XMMWORD PTR [rax], xmm2
	movups	xmm1, XMMWORD PTR [rax+16]
	mulpd	xmm0, xmm4
	subpd	xmm1, xmm0
	movups	xmm0, XMMWORD PTR [rax+r9+32]
	movups	XMMWORD PTR [rax+16], xmm1
	movups	xmm1, XMMWORD PTR [rax+32]
	mulpd	xmm0, xmm4
	subpd	xmm1, xmm0
	movups	XMMWORD PTR [rax+32], xmm1
	add	rax, 64					; 00000040H
	cmp	rdx, rcx
	jb	SHORT $LL124@factorize_
	cmp	rdx, r8
	jae	$LN26@factorize_
$LN649@factorize_:
	mov	rax, r8
	sub	rax, rdx
	cmp	rax, 4
	jb	$LN648@factorize_
	lea	rax, QWORD PTR [rdx+1]
	mov	rcx, r8
	sub	rcx, rdx
	lea	rax, QWORD PTR [r11+rax*8]
	sub	rcx, 4
	lea	r9, QWORD PTR [r10+rsi]
	shr	rcx, 2
	inc	rcx
	lea	rdx, QWORD PTR [rdx+rcx*4]
	npad	4
$LL484@factorize_:
	movsd	xmm0, QWORD PTR [rax-8]
	movaps	xmm1, xmm3
	mulsd	xmm1, QWORD PTR [rax+r9-8]
	movaps	xmm2, xmm3
	subsd	xmm0, xmm1
	movaps	xmm1, xmm3
	movsd	QWORD PTR [rax-8], xmm0
	mulsd	xmm2, QWORD PTR [rax+r9]
	movsd	xmm0, QWORD PTR [rax]
	subsd	xmm0, xmm2
	movsd	QWORD PTR [rax], xmm0
	mulsd	xmm1, QWORD PTR [rax+r9+8]
	movsd	xmm0, QWORD PTR [rax+8]
	subsd	xmm0, xmm1
	movaps	xmm1, xmm3
	movsd	QWORD PTR [rax+8], xmm0
	mulsd	xmm1, QWORD PTR [rax+r9+16]
	movsd	xmm0, QWORD PTR [rax+16]
	subsd	xmm0, xmm1
	movsd	QWORD PTR [rax+16], xmm0
	add	rax, 32					; 00000020H
	sub	rcx, 1
	jne	SHORT $LL484@factorize_
	cmp	rdx, r8
	jae	SHORT $LN26@factorize_
$LN648@factorize_:
	mov	rcx, r8
	lea	rax, QWORD PTR [r11+rdx*8]
	sub	rcx, rdx
	lea	r9, QWORD PTR [r10+rsi]
$LC442@factorize_:
	movsd	xmm0, QWORD PTR [rax]
	movaps	xmm1, xmm3
	mulsd	xmm1, QWORD PTR [rax+r9]
	subsd	xmm0, xmm1
	movsd	QWORD PTR [rax], xmm0
	add	rax, 8
	sub	rcx, 1
	jne	SHORT $LC442@factorize_
$LN26@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 57   :             for (std::size_t j=k+1;j<end;++j)

	add	rbp, r15
	sub	r10, r12
	add	r11, r13
	sub	r14, 1
	jne	$LL28@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r11, QWORD PTR working$$sroa$2685$1$[rsp]
	mov	r8, QWORD PTR k$1$[rsp]
	mov	r10, QWORD PTR tv12611[rsp]
	inc	r8
	add	r10, QWORD PTR working$$sroa$2684$1$[rsp]
	mov	r9, QWORD PTR tv12609[rsp]
	lea	rsi, QWORD PTR [rsi+r11*8]
	mov	rbx, QWORD PTR end$1$[rsp]
	add	r9, r11
	mov	rdi, QWORD PTR tv12712[rsp]
	mov	rbp, QWORD PTR working$[rsp]
	mov	r12, QWORD PTR n$1$[rsp]
	mov	r14, QWORD PTR tv12845[rsp]
	mov	QWORD PTR k$1$[rsp], r8
	jmp	$LN729@factorize_
$LN663@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 57   :             for (std::size_t j=k+1;j<end;++j)

	mov	rcx, QWORD PTR first$1$[rsp]
	mov	rdi, QWORD PTR working$$sroa$2684$1$[rsp]
$LN20@factorize_:

; 61   :             auto* coefficients=&working(0,n-1); // unused upper column, width<=n-1

	mov	r8, QWORD PTR working$[rsp]
	lea	rax, QWORD PTR [r12-1]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	imul	rax, r11
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 61   :             auto* coefficients=&working(0,n-1); // unused upper column, width<=n-1

	mov	rsi, rdi
	lea	r13, QWORD PTR [rdi+r11]
	imul	rsi, rbx
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	r12, QWORD PTR [rax*8]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 61   :             auto* coefficients=&working(0,n-1); // unused upper column, width<=n-1

	shl	r13, 3
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	add	r12, rbp
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 61   :             auto* coefficients=&working(0,n-1); // unused upper column, width<=n-1

	lea	rax, QWORD PTR [rdi+r11]
	imul	rax, rbx

; 62   :             for (std::size_t j=end;j<n;++j) {

	mov	rbp, rbx
	lea	r14, QWORD PTR [r8+rax*8]
	mov	rax, r11
	imul	rax, rcx
	add	rax, rsi
	lea	r15, QWORD PTR [r8+rax*8]
	mov	rax, QWORD PTR n$1$[rsp]
	npad	1
$LL31@factorize_:

; 63   :                 for (std::size_t k=first;k<end;++k) coefficients[k-first]=working(j,k);

	mov	rdi, rcx
	cmp	rcx, rbx
	jae	$LN485@factorize_
	mov	rax, rbx
	sub	rax, rcx
	cmp	rax, 4
	jb	$LC486@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	rdi, QWORD PTR first$1$[rsp]
	lea	rdx, QWORD PTR [r12+16]
	mov	rbx, QWORD PTR working$$sroa$2685$1$[rsp]
	add	rcx, 2
	mov	rax, rcx
	mov	r9, r11
	imul	rax, r11
	shl	r9, 5
	add	rax, rsi
	lea	r8, QWORD PTR [r8+rax*8]
	mov	rax, rdi
	sub	rax, rcx
	mov	rcx, QWORD PTR end$1$[rsp]
	sub	rcx, rdi
	sub	rcx, 4
	imul	rbx, rax
	lea	r10, QWORD PTR [rax+1]
	shr	rcx, 2
	imul	r10, r11
	lea	r11, QWORD PTR [rax+3]
	imul	r11, QWORD PTR working$$sroa$2685$1$[rsp]
	inc	rcx
	lea	rdi, QWORD PTR [rdi+rcx*4]
	npad	6
$LL487@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 63   :                 for (std::size_t k=first;k<end;++k) coefficients[k-first]=working(j,k);

	mov	rax, QWORD PTR [r8+rbx*8]
	mov	QWORD PTR [rdx-16], rax
	lea	rdx, QWORD PTR [rdx+32]
	mov	rax, QWORD PTR [r8+r10*8]
	mov	QWORD PTR [rdx-40], rax
	mov	rax, QWORD PTR [r8]
	mov	QWORD PTR [rdx-32], rax
	mov	rax, QWORD PTR [r8+r11*8]
	add	r8, r9
	mov	QWORD PTR [rdx-24], rax
	sub	rcx, 1
	jne	SHORT $LL487@factorize_
	mov	rbx, QWORD PTR end$1$[rsp]
	mov	r11, QWORD PTR working$$sroa$2685$1$[rsp]
	cmp	rdi, rbx
	jae	SHORT $LN662@factorize_
	mov	r8, QWORD PTR working$[rsp]
	mov	rcx, QWORD PTR first$1$[rsp]
$LC486@factorize_:
	mov	rax, rdi
	lea	r9, QWORD PTR [r11*8]
	sub	rax, rcx
	lea	rcx, QWORD PTR [r12+rax*8]
	mov	rax, r11
	imul	rax, rdi
	add	rax, rsi
	lea	rdx, QWORD PTR [r8+rax*8]
	mov	r8, rbx
	sub	r8, rdi
$LC34@factorize_:
	mov	rax, QWORD PTR [rdx]
	add	rdx, r9
	mov	QWORD PTR [rcx], rax
	lea	rcx, QWORD PTR [rcx+8]
	sub	r8, 1
	jne	SHORT $LC34@factorize_
$LN662@factorize_:

; 64   :                 row_update_panel(&working(j,j),&working(j,first),working.col_stride(),coefficients,end-first,n-j);

	mov	rax, QWORD PTR n$1$[rsp]
$LN485@factorize_:
	sub	rax, rbp
	mov	r9, r12
	mov	QWORD PTR [rsp+40], rax
	mov	r8, r11
	mov	rax, QWORD PTR tv12843[rsp]
	mov	rdx, r15
	mov	rcx, r14
	mov	QWORD PTR [rsp+32], rax
	call	?row_update_panel@detail@linalg@kibo@@YAXPEANPEBN_K122@Z ; kibo::linalg::detail::row_update_panel
	mov	rdi, QWORD PTR working$$sroa$2684$1$[rsp]
	inc	rbp
	mov	r8, QWORD PTR working$[rsp]
	add	rsi, rdi
	mov	r11, QWORD PTR working$$sroa$2685$1$[rsp]
	add	r14, r13
	mov	rcx, QWORD PTR first$1$[rsp]
	lea	rax, QWORD PTR [rdi*8]
	add	r15, rax
	mov	rax, QWORD PTR n$1$[rsp]
	cmp	rbp, rax
	jb	$LL31@factorize_

; 36   :     for (std::size_t first=0;first<n;) {

	mov	r14, QWORD PTR tv12845[rsp]
	mov	rcx, rbx
	mov	QWORD PTR first$1$[rsp], rbx
	mov	rbp, r8
	mov	r12, rax
	jmp	$LL10@factorize_
$LN389@factorize_:

; 41   :             if (diagonal<=0) return Status{StatusCode::non_positive_pivot,k};

	mov	DWORD PTR $T3[rsp], 8
	jmp	SHORT $LN731@factorize_
$LN388@factorize_:

; 84   : }

	mov	DWORD PTR $T2[rsp], 10
$LN731@factorize_:
	mov	QWORD PTR $T2[rsp+8], r10
$LN732@factorize_:
	mov	rax, QWORD PTR __$ReturnUdt$[rsp]
	movups	xmm0, XMMWORD PTR $T2[rsp]
	mov	QWORD PTR $T2[rsp+16], 0
	movsd	xmm1, QWORD PTR $T2[rsp+16]
	movups	XMMWORD PTR [rax], xmm0
	movsd	QWORD PTR [rax+16], xmm1
	mov	BYTE PTR [rax+72], 0
	jmp	$LN1@factorize_
$LN390@factorize_:

; 54   :                 if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,k};

	mov	DWORD PTR $T4[rsp], 10
	mov	QWORD PTR $T4[rsp+8], r8
	jmp	SHORT $LN732@factorize_
$LN644@factorize_:
	mov	rbx, QWORD PTR [rdx+40]

; 65   :             }
; 66   :         }
; 67   :         first=end;
; 68   :     }
; 69   :     // Restore the caller's lower triangle and clear every logical upper entry.
; 70   :     for (std::size_t first=0;first<n;) {

	xor	r13d, r13d
	mov	rdi, QWORD PTR [rdx+32]
	mov	esi, r13d
	mov	QWORD PTR first$1$[rsp], r13
	mov	QWORD PTR tv12837[rsp], rbx
	mov	QWORD PTR tv12836[rsp], rdi
	npad	7
$LL37@factorize_:

; 71   :         const auto end=first+std::min(std::size_t{8},n-first);

	mov	r11d, 8
	mov	rax, r12
	sub	rax, rsi
	cmp	rax, r11
	cmovb	r11, rax
	mov	rax, r13
	add	r11, rsi
	mov	QWORD PTR column$1$[rsp], rax
	mov	QWORD PTR end$1$[rsp], r11

; 72   :         for (std::size_t column=0;column<first;column+=8) {

	test	rsi, rsi
	je	$LN39@factorize_
	npad	1
$LL40@factorize_:

; 73   :             const auto stop=std::min(column+8,first);

	lea	rdi, QWORD PTR [rax+8]

; 74   :             for (std::size_t j=column;j<stop;++j) for (std::size_t i=first;i<end;++i) {

	mov	QWORD PTR j$1$[rsp], rax
	cmp	rsi, rdi
	mov	rbp, rax
	cmovb	rdi, rsi
	mov	QWORD PTR stop$1$[rsp], rdi
	cmp	rax, rdi
	jae	$LN38@factorize_
$LL43@factorize_:
	mov	r15, rsi
	cmp	rsi, r11
	jae	$LN41@factorize_
	mov	r14, QWORD PTR [rdx]
	mov	rax, r11
	mov	r10, QWORD PTR [rdx+32]
	sub	rax, rsi
	mov	rbx, QWORD PTR [rdx+40]
	mov	QWORD PTR $T5[rsp], r14
	cmp	rax, 4
	jb	$LN645@factorize_
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	rdx, QWORD PTR [rsi+2]
	mov	rax, rbp
	imul	rax, r10
	mov	rcx, rdx
	mov	r11, rsi
	imul	rcx, rbx
	sub	r11, rdx
	mov	r12, rbx
	add	rcx, rax
	shl	r12, 5
	mov	rax, rbp
	mov	r13, r10
	imul	rax, rbx
	lea	rdi, QWORD PTR [r11+3]
	shl	r13, 5
	lea	r8, QWORD PTR [r14+rcx*8]
	mov	rcx, rdx
	imul	rcx, r10
	lea	rdx, QWORD PTR [r11+1]
	add	rcx, rax
	mov	rax, rdx
	imul	rax, r10
	imul	rdx, rbx
	lea	r9, QWORD PTR [r14+rcx*8]
	mov	rcx, QWORD PTR end$1$[rsp]
	mov	QWORD PTR tv12921[rsp], rax
	sub	rcx, rsi
	mov	rax, rdi
	sub	rcx, 4
	imul	rax, r10
	imul	rdi, rbx
	mov	QWORD PTR tv12919[rsp], rax
	mov	rax, r11
	mov	rbp, QWORD PTR tv12919[rsp]
	imul	rax, r10
	imul	r11, rbx
	shr	rcx, 2
	mov	r14, rax
	inc	rcx
	lea	r15, QWORD PTR [rsi+rcx*4]
	mov	rsi, QWORD PTR tv12921[rsp]
	npad	4
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

$LL490@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 75   :                 storage(i,j)=storage(j,i);storage(j,i)=0;

	mov	rax, QWORD PTR [r8+r11*8]
	mov	QWORD PTR [r9+r14*8], rax
	mov	QWORD PTR [r8+r11*8], 0
	mov	rax, QWORD PTR [r8+rdx*8]
	mov	QWORD PTR [r9+rsi*8], rax
	mov	QWORD PTR [r8+rdx*8], 0
	mov	rax, QWORD PTR [r8]
	mov	QWORD PTR [r9], rax
	mov	QWORD PTR [r8], 0
	mov	rax, QWORD PTR [r8+rdi*8]
	mov	QWORD PTR [r9+rbp*8], rax
	add	r9, r13
	mov	QWORD PTR [r8+rdi*8], 0
	add	r8, r12
	sub	rcx, 1
	jne	SHORT $LL490@factorize_

; 74   :             for (std::size_t j=column;j<stop;++j) for (std::size_t i=first;i<end;++i) {

	mov	r11, QWORD PTR end$1$[rsp]
	mov	rsi, QWORD PTR first$1$[rsp]
	mov	rbp, QWORD PTR j$1$[rsp]
	mov	r14, QWORD PTR $T5[rsp]
	mov	rdi, QWORD PTR stop$1$[rsp]
	cmp	r15, r11
	jb	SHORT $LN659@factorize_
	xor	r13d, r13d
	jmp	SHORT $LN730@factorize_
$LN659@factorize_:
	xor	r13d, r13d
$LN645@factorize_:
	mov	r8, QWORD PTR end$1$[rsp]
	lea	r11, QWORD PTR [r10*8]
	mov	rax, r10
	lea	r9, QWORD PTR [rbx*8]
	mov	rcx, rbx
	imul	rcx, r15
	imul	rax, rbp
	imul	r10, r15
	imul	rbx, rbp
	add	rcx, rax
	lea	rdx, QWORD PTR [r14+rcx*8]
	add	r10, rbx
	sub	r8, r15
	lea	rcx, QWORD PTR [r14+r10*8]
$LC46@factorize_:

; 75   :                 storage(i,j)=storage(j,i);storage(j,i)=0;

	mov	rax, QWORD PTR [rdx]
	mov	QWORD PTR [rcx], rax
	add	rcx, r11
	mov	QWORD PTR [rdx], r13
	add	rdx, r9
	sub	r8, 1
	jne	SHORT $LC46@factorize_
	mov	r11, QWORD PTR end$1$[rsp]
$LN730@factorize_:

; 74   :             for (std::size_t j=column;j<stop;++j) for (std::size_t i=first;i<end;++i) {

	mov	rdx, QWORD PTR storage$[rsp]
$LN41@factorize_:
	inc	rbp
	mov	QWORD PTR j$1$[rsp], rbp
	cmp	rbp, rdi
	jb	$LL43@factorize_
	mov	rax, QWORD PTR column$1$[rsp]
$LN38@factorize_:

; 72   :         for (std::size_t column=0;column<first;column+=8) {

	add	rax, 8
	mov	QWORD PTR column$1$[rsp], rax
	cmp	rax, rsi
	jb	$LL40@factorize_
	mov	rbx, QWORD PTR tv12837[rsp]
	mov	rdi, QWORD PTR tv12836[rsp]
	mov	r12, QWORD PTR n$1$[rsp]
$LN39@factorize_:

; 76   :             }
; 77   :         }
; 78   :         for (std::size_t i=first;i<end;++i) for (std::size_t j=first;j<i;++j) {

	mov	QWORD PTR i$1$[rsp], rsi
	mov	r10, rsi
	cmp	rsi, r11
	jae	$LN48@factorize_
$LL49@factorize_:
	mov	r12, rsi
	cmp	rsi, r10
	jae	$LN47@factorize_
	mov	r15, QWORD PTR [rdx]
	mov	rax, r10
	sub	rax, rsi
	mov	QWORD PTR $T1[rsp], r15
	mov	QWORD PTR tv12635[rsp], rax
	mov	rbp, rbx
	mov	r14, rdi
	cmp	rax, 4
	jb	$LN642@factorize_
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	rdx, QWORD PTR [rsi+2]
	mov	rax, rbx
	shl	rax, 5
	mov	rcx, rbx
	imul	rcx, r10
	mov	QWORD PTR tv12667[rsp], rax
	mov	r11, rbx
	mov	rax, rdx
	mov	r13, rdi
	imul	rax, rdi
	shl	r13, 5
	add	rcx, rax
	mov	rax, rdx
	imul	rax, rbx
	lea	r8, QWORD PTR [r15+rcx*8]
	mov	rcx, rdi
	imul	rcx, r10
	mov	r10, rbx
	add	rcx, rax
	lea	r9, QWORD PTR [r15+rcx*8]
	mov	rcx, rsi
	sub	rcx, rdx
	mov	rdx, rbx
	imul	r10, rcx
	lea	rax, QWORD PTR [rcx+1]
	mov	rbx, rdi
	imul	rdx, rax
	mov	QWORD PTR tv12884[rsp], r10
	mov	r15, QWORD PTR tv12884[rsp]
	mov	QWORD PTR tv12889[rsp], rdx
	mov	rdx, rdi
	imul	rdi, rcx
	imul	rdx, rax
	lea	rax, QWORD PTR [rcx+3]
	mov	rcx, QWORD PTR tv12635[rsp]
	imul	r11, rax
	imul	rbx, rax
	add	rcx, -4
	mov	QWORD PTR tv12885[rsp], r11
	mov	r10, QWORD PTR tv12885[rsp]
	mov	r11, QWORD PTR tv12667[rsp]
	shr	rcx, 2
	inc	rcx
	lea	r12, QWORD PTR [rsi+rcx*4]
	mov	rsi, QWORD PTR tv12889[rsp]
	npad	10
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

$LL493@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 79   :             storage(i,j)=storage(j,i);storage(j,i)=0;

	mov	rax, QWORD PTR [r8+rdi*8]
	mov	QWORD PTR [r9+r15*8], rax
	mov	QWORD PTR [r8+rdi*8], 0
	mov	rax, QWORD PTR [r8+rdx*8]
	mov	QWORD PTR [r9+rsi*8], rax
	mov	QWORD PTR [r8+rdx*8], 0
	mov	rax, QWORD PTR [r8]
	mov	QWORD PTR [r9], rax
	mov	QWORD PTR [r8], 0
	mov	rax, QWORD PTR [r8+rbx*8]
	mov	QWORD PTR [r9+r10*8], rax
	add	r9, r11
	mov	QWORD PTR [r8+rbx*8], 0
	add	r8, r13
	sub	rcx, 1
	jne	SHORT $LL493@factorize_

; 76   :             }
; 77   :         }
; 78   :         for (std::size_t i=first;i<end;++i) for (std::size_t j=first;j<i;++j) {

	mov	r10, QWORD PTR i$1$[rsp]
	mov	rsi, QWORD PTR first$1$[rsp]
	mov	r11, QWORD PTR end$1$[rsp]
	mov	r15, QWORD PTR $T1[rsp]
	cmp	r12, r10
	jb	SHORT $LN642@factorize_
	xor	r13d, r13d
	jmp	SHORT $LN47@factorize_
$LN642@factorize_:
	mov	rax, rbp
	lea	rbx, QWORD PTR [rbp*8]
	mov	rcx, r14
	lea	r9, QWORD PTR [r14*8]
	imul	rcx, r12
	imul	rax, r10
	imul	rbp, r12
	imul	r14, r10
	add	rcx, rax
	mov	r8, r10
	sub	r8, r12
	lea	rdx, QWORD PTR [r15+rcx*8]
	add	rbp, r14
	xor	r13d, r13d
	lea	rcx, QWORD PTR [r15+rbp*8]
$LC52@factorize_:

; 79   :             storage(i,j)=storage(j,i);storage(j,i)=0;

	mov	rax, QWORD PTR [rdx]
	mov	QWORD PTR [rcx], rax
	add	rcx, rbx
	mov	QWORD PTR [rdx], r13
	add	rdx, r9
	sub	r8, 1
	jne	SHORT $LC52@factorize_
$LN47@factorize_:

; 76   :             }
; 77   :         }
; 78   :         for (std::size_t i=first;i<end;++i) for (std::size_t j=first;j<i;++j) {

	mov	rbx, QWORD PTR tv12837[rsp]
	inc	r10
	mov	rdi, QWORD PTR tv12836[rsp]
	mov	rdx, QWORD PTR storage$[rsp]
	mov	QWORD PTR i$1$[rsp], r10
	cmp	r10, r11
	jb	$LL49@factorize_
	mov	r12, QWORD PTR n$1$[rsp]
$LN48@factorize_:

; 65   :             }
; 66   :         }
; 67   :         first=end;
; 68   :     }
; 69   :     // Restore the caller's lower triangle and clear every logical upper entry.
; 70   :     for (std::size_t first=0;first<n;) {

	mov	rbx, QWORD PTR tv12837[rsp]

; 80   :         }
; 81   :         first=end;

	mov	rsi, r11
	mov	rdi, QWORD PTR tv12836[rsp]
	mov	rdx, QWORD PTR storage$[rsp]
	mov	QWORD PTR first$1$[rsp], r11
	cmp	r11, r12
	jb	$LL37@factorize_
	mov	rcx, QWORD PTR __$ReturnUdt$[rsp]
	mov	r8, rdx
	xor	eax, eax
$LN36@factorize_:

; 82   :     }
; 83   :     return LltAccess::create(storage);

	movups	xmm0, XMMWORD PTR [r8]
	mov	DWORD PTR [rcx], eax
	movups	xmm1, XMMWORD PTR [r8+16]
	mov	QWORD PTR [rcx+8], rax
	movups	xmm2, XMMWORD PTR [r8+32]
	mov	QWORD PTR [rcx+16], rax
	mov	rax, rcx
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\optional

; 82   :         : _Value(_STD forward<_Types>(_Args)...), _Has_value{true} {} // initialize contained value with _Args...

	movq	QWORD PTR [rcx+24], xmm0
	psrldq	xmm0, 8
	movq	QWORD PTR [rcx+32], xmm0
	movq	QWORD PTR [rcx+40], xmm1
	psrldq	xmm1, 8
	movq	QWORD PTR [rcx+48], xmm1
	movq	QWORD PTR [rcx+56], xmm2
	psrldq	xmm2, 8
	movq	QWORD PTR [rcx+64], xmm2
	mov	BYTE PTR [rcx+72], 1
$LN1@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 84   : }

	lea	r11, QWORD PTR [rsp+232]
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
	pop	rbp
	pop	rbx
	ret	0
?factorize_column_llt@detail@linalg@kibo@@YA?AV?$Result@VLltFactorView@linalg@kibo@@@23@V?$MatrixView@$$CBN@23@V?$MatrixView@N@23@@Z ENDP ; kibo::linalg::detail::factorize_column_llt