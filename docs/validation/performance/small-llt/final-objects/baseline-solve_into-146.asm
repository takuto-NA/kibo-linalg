?solve_into@linalg@kibo@@YA?AUStatus@12@VLltFactorView@12@V?$span@$$CBN$0?0@std@@V?$span@N$0?0@6@V?$span@W4byte@std@@$0?0@6@@Z PROC ; kibo::linalg::solve_into, COMDAT

; 151  :                          std::span<std::byte> workspace) noexcept {

$LN366:
	mov	QWORD PTR [rsp+32], r9
	push	rbp
	push	rbx
	push	rsi
	lea	rbp, QWORD PTR [rsp-63]
	sub	rsp, 144				; 00000090H

; 17   :     bool valid() const noexcept { return lower_.rows()!=0; }

	mov	r10, QWORD PTR [rdx+16]

; 151  :                          std::span<std::byte> workspace) noexcept {

	mov	r11, r8
	mov	rsi, rcx

; 152  :     if (!factor.valid()) return {StatusCode::invalid_factor};

	test	r10, r10
	jne	SHORT $LN20@solve_into
	mov	DWORD PTR $T1[rbp-81], 11
$LN362@solve_into:

; 178  : }

	xor	ebx, ebx
	mov	rax, rsi
	mov	QWORD PTR $T1[rbp-73], rbx
	movups	xmm0, XMMWORD PTR $T1[rbp-81]
	mov	QWORD PTR $T1[rbp-65], rbx
	movsd	xmm1, QWORD PTR $T1[rbp-65]
	movups	XMMWORD PTR [rcx], xmm0
	movsd	QWORD PTR [rcx+16], xmm1
	add	rsp, 144				; 00000090H
	pop	rsi
	pop	rbx
	pop	rbp
	ret	0
$LN20@solve_into:

; 153  :     const auto n=factor.size();
; 154  :     if (rhs.size()!=n || output.size()!=n) return {StatusCode::invalid_shape};

	mov	r8, QWORD PTR [r8+8]
	cmp	r8, r10
	jne	$LN22@solve_into
	cmp	QWORD PTR [r9+8], r10
	jne	$LN22@solve_into
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\workspace.hpp

; 9    :     if (count > std::numeric_limits<std::size_t>::max()/sizeof(double)) return StatusCode::size_overflow;

	mov	rax, 2305843009213693951		; 1fffffffffffffffH
	cmp	r10, rax
	jbe	SHORT $LN128@solve_into
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	mov	DWORD PTR requirement$[rbp-81], 5
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 156  :     if (!requirement) return requirement.status();

	jmp	SHORT $LN362@solve_into
$LN128@solve_into:

; 157  :     auto prepared=detail::workspace_doubles(workspace,requirement.value());

	mov	rax, QWORD PTR workspace$[rbp-81]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\workspace.hpp

; 10   :     return WorkspaceRequirement{count*sizeof(double),alignof(double)};

	lea	rcx, QWORD PTR [r10*8]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 157  :     auto prepared=detail::workspace_doubles(workspace,requirement.value());

	movups	xmm0, XMMWORD PTR [rax]
	movaps	XMMWORD PTR $T7[rbp-81], xmm0
	cmp	QWORD PTR [rax+8], rcx
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\workspace.hpp

; 13   :     if (storage.size() < requirement.bytes) return StatusCode::insufficient_capacity;

	jae	SHORT $LN168@solve_into
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	mov	DWORD PTR prepared$[rbp-81], 4
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\workspace.hpp

; 13   :     if (storage.size() < requirement.bytes) return StatusCode::insufficient_capacity;

	jmp	SHORT $LN359@solve_into
$LN168@solve_into:

; 14   :     if (requirement.bytes!=0 && reinterpret_cast<std::uintptr_t>(storage.data())%requirement.alignment!=0)

	mov	r9, QWORD PTR $T7[rbp-81]
	test	rcx, rcx
	je	SHORT $LN169@solve_into
	test	r9b, 7
	je	SHORT $LN169@solve_into
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	mov	DWORD PTR prepared$[rbp-81], 2
$LN359@solve_into:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 158  :     if (!prepared) return prepared.status();

	xor	ebx, ebx

; 178  : }

	mov	rax, rsi
	mov	QWORD PTR prepared$[rbp-73], rbx
	movups	xmm0, XMMWORD PTR prepared$[rbp-81]
	mov	QWORD PTR prepared$[rbp-65], rbx
	movsd	xmm1, QWORD PTR prepared$[rbp-65]
	movups	XMMWORD PTR [rsi], xmm0
	movsd	QWORD PTR [rsi+16], xmm1
	add	rsp, 144				; 00000090H
	pop	rsi
	pop	rbx
	pop	rbp
	ret	0
$LN169@solve_into:

; 159  :     for (auto value:rhs) if (!detail::llt_is_finite(value)) return {StatusCode::non_finite_input};

	movdqa	xmm3, XMMWORD PTR __xmm@7fffffffffffffff7fffffffffffffff
	movsd	xmm4, QWORD PTR __real@7fefffffffffffff
	mov	QWORD PTR [rsp+112], r15
	mov	r15, QWORD PTR [r11]
	mov	rax, r15
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 542  :         return _Mydata + _Mysize;

	lea	rcx, QWORD PTR [r15+r8*8]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 159  :     for (auto value:rhs) if (!detail::llt_is_finite(value)) return {StatusCode::non_finite_input};

	cmp	r15, rcx
	je	SHORT $LN3@solve_into
	npad	9
$LL4@solve_into:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rax]
	andps	xmm0, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm4, xmm0

; 159  :     for (auto value:rhs) if (!detail::llt_is_finite(value)) return {StatusCode::non_finite_input};

	jb	$LN235@solve_into
	add	rax, 8
	cmp	rax, rcx
	jne	SHORT $LL4@solve_into
$LN3@solve_into:

; 19   :     MatrixView<const double> lower() const noexcept { return lower_; }

	movups	xmm0, XMMWORD PTR [rdx+16]
	mov	QWORD PTR [rsp+192], rdi

; 160  :     auto candidate=prepared.value();
; 161  :     auto lower=factor.lower();
; 162  :     for (std::size_t i=0;i<n;++i) {

	xor	ebx, ebx
	mov	QWORD PTR [rsp+136], r12
	mov	r8d, ebx
	mov	QWORD PTR [rsp+128], r13
	mov	QWORD PTR [rsp+120], r14

; 19   :     MatrixView<const double> lower() const noexcept { return lower_; }

	movups	xmm2, XMMWORD PTR [rdx]
	movups	xmm1, XMMWORD PTR [rdx+32]
	movups	XMMWORD PTR lower$[rbp-65], xmm0

; 160  :     auto candidate=prepared.value();
; 161  :     auto lower=factor.lower();
; 162  :     for (std::size_t i=0;i<n;++i) {

	test	r10, r10
	je	$LN267@solve_into
	movq	r13, xmm2
	mov	QWORD PTR tv3716[rbp-81], rbx
	movq	r12, xmm1
	mov	QWORD PTR lower$3$[rbp-81], r13
	psrldq	xmm1, 8
	mov	rax, r9
	movq	rdi, xmm1
	mov	QWORD PTR tv3714[rbp-81], rax
	mov	r11d, ebx
	mov	QWORD PTR tv3712[rbp-81], r13
	mov	r14, r13
	lea	rdx, QWORD PTR [rdi+r12]
	shl	rdx, 3
	sub	r15, r9
	mov	QWORD PTR tv3713[rbp-81], rdx
	mov	QWORD PTR tv3686[rbp-81], r15
	npad	12
$LL7@solve_into:

; 163  :         double value=rhs[i];

	movsd	xmm2, QWORD PTR [r15+rax]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rcx, rbx
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 164  :         for (std::size_t j=0;j<i;++j) value-=lower(i,j)*candidate[j];

	cmp	r8, 4
	jb	$LC262@solve_into
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	lea	rax, QWORD PTR [r11+rdi*2]
	mov	r14, rdi
	lea	r11, QWORD PTR [rax*8]
	neg	r14
	add	r11, r13
	lea	rax, QWORD PTR [r8-4]
	mov	r13, rdi
	shr	rax, 2
	mov	r15, rdi
	lea	rdx, QWORD PTR [r9+16]
	neg	r13
	shl	r15, 5
	add	r14, r14
	inc	rax
	lea	rcx, QWORD PTR [rax*4]
	npad	1
$LL263@solve_into:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 164  :         for (std::size_t j=0;j<i;++j) value-=lower(i,j)*candidate[j];

	movsd	xmm0, QWORD PTR [r11+r14*8]
	mulsd	xmm0, QWORD PTR [rdx-16]
	movsd	xmm1, QWORD PTR [r11+r13*8]
	mulsd	xmm1, QWORD PTR [rdx-8]
	subsd	xmm2, xmm0
	movsd	xmm0, QWORD PTR [rdx]
	mulsd	xmm0, QWORD PTR [r11]
	subsd	xmm2, xmm1
	movsd	xmm1, QWORD PTR [r11+rdi*8]
	mulsd	xmm1, QWORD PTR [rdx+8]
	add	r11, r15
	add	rdx, 32					; 00000020H
	subsd	xmm2, xmm0
	subsd	xmm2, xmm1
	sub	rax, 1
	jne	SHORT $LL263@solve_into
	mov	r14, QWORD PTR tv3712[rbp-81]
	mov	r13, QWORD PTR lower$3$[rbp-81]
	cmp	rcx, r8
	jb	SHORT $LN311@solve_into
	jmp	SHORT $LN360@solve_into
$LN235@solve_into:
	mov	r15, QWORD PTR [rsp+112]

; 159  :     for (auto value:rhs) if (!detail::llt_is_finite(value)) return {StatusCode::non_finite_input};

	xor	ebx, ebx
	mov	QWORD PTR $T3[rbp-73], rbx
	mov	rax, rsi
	mov	DWORD PTR $T3[rbp-81], 7
	movups	xmm0, XMMWORD PTR $T3[rbp-81]
	mov	QWORD PTR $T3[rbp-65], rbx
	movsd	xmm1, QWORD PTR $T3[rbp-65]
	movups	XMMWORD PTR [rsi], xmm0
	movsd	QWORD PTR [rsi+16], xmm1

; 178  : }

	add	rsp, 144				; 00000090H
	pop	rsi
	pop	rbx
	pop	rbp
	ret	0
$LC262@solve_into:

; 164  :         for (std::size_t j=0;j<i;++j) value-=lower(i,j)*candidate[j];

	test	r8, r8
	je	SHORT $LN261@solve_into
$LN311@solve_into:
	mov	rax, rdi
	lea	r11, QWORD PTR [rdi*8]
	imul	rax, rcx
	add	rax, QWORD PTR tv3716[rbp-81]
	lea	rdx, QWORD PTR [rax*8]
	add	rdx, r13
$LC10@solve_into:
	movsd	xmm0, QWORD PTR [r9+rcx*8]
	inc	rcx
	mulsd	xmm0, QWORD PTR [rdx]
	add	rdx, r11
	subsd	xmm2, xmm0
	cmp	rcx, r8
	jb	SHORT $LC10@solve_into
$LN360@solve_into:

; 165  :         value/=lower(i,i);

	mov	rdx, QWORD PTR tv3713[rbp-81]
	mov	r11, QWORD PTR tv3716[rbp-81]
	mov	rax, QWORD PTR tv3714[rbp-81]
$LN261@solve_into:
	divsd	xmm2, QWORD PTR [r14]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movaps	xmm0, xmm2
	andps	xmm0, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm4, xmm0

; 166  :         if (!detail::llt_is_finite(value)) return {StatusCode::arithmetic_failure,i};

	jb	$LN236@solve_into

; 160  :     auto candidate=prepared.value();
; 161  :     auto lower=factor.lower();
; 162  :     for (std::size_t i=0;i<n;++i) {

	mov	r15, QWORD PTR tv3686[rbp-81]
	add	r11, r12
	add	r14, rdx

; 167  :         candidate[i]=value;

	movsd	QWORD PTR [rax], xmm2
	add	rax, 8
	mov	QWORD PTR tv3716[rbp-81], r11
	inc	r8
	mov	QWORD PTR tv3712[rbp-81], r14
	mov	QWORD PTR tv3714[rbp-81], rax
	cmp	r8, r10
	jb	$LL7@solve_into

; 168  :     }
; 169  :     for (std::size_t i=n;i-->0;) {

	lea	rax, QWORD PTR [r12+rdi]
	mov	r15, rdi
	mov	rdx, rdi
	lea	r8, QWORD PTR [rax*8]
	imul	rax, r10
	imul	r15, r10
	neg	rdx
	mov	QWORD PTR tv3684[rbp-81], r8
	lea	rdi, QWORD PTR [rax*8]
	mov	QWORD PTR tv3700[rbp-81], rdx
	add	rdi, r13
	mov	r11, r10
	npad	11
$LL13@solve_into:

; 170  :         double value=candidate[i];

	movsd	xmm2, QWORD PTR [r9+r11*8-8]
	mov	rcx, r11
	dec	r11
	sub	rdi, r8
	add	r15, rdx
	mov	QWORD PTR tv3699[rbp-81], rdi

; 171  :         for (std::size_t j=i+1;j<n;++j) value-=lower(j,i)*candidate[j];

	cmp	rcx, r10
	jae	$LN264@solve_into
	mov	rax, r10
	sub	rax, rcx
	cmp	rax, 4
	jb	$LC265@solve_into
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	rax, r12
	lea	rdx, QWORD PTR [r9+16]
	imul	rax, rcx
	mov	rdi, r12
	lea	rdx, QWORD PTR [rdx+rcx*8]
	add	rax, r15
	shl	rdi, 5
	mov	r14, r12
	add	r14, r14
	lea	r8, QWORD PTR [rax*8]
	mov	rax, r10
	sub	rax, rcx
	add	r8, r13
	sub	rax, 4
	lea	r13, QWORD PTR [r12+r12*2]
	shr	rax, 2
	inc	rax
	lea	rcx, QWORD PTR [rcx+rax*4]
	npad	13
$LL266@solve_into:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 171  :         for (std::size_t j=i+1;j<n;++j) value-=lower(j,i)*candidate[j];

	movsd	xmm0, QWORD PTR [rdx-16]
	mulsd	xmm0, QWORD PTR [r8]
	movsd	xmm1, QWORD PTR [r8+r12*8]
	mulsd	xmm1, QWORD PTR [rdx-8]
	subsd	xmm2, xmm0
	movsd	xmm0, QWORD PTR [r8+r14*8]
	mulsd	xmm0, QWORD PTR [rdx]
	subsd	xmm2, xmm1
	movsd	xmm1, QWORD PTR [r8+r13*8]
	mulsd	xmm1, QWORD PTR [rdx+8]
	add	r8, rdi
	add	rdx, 32					; 00000020H
	subsd	xmm2, xmm0
	subsd	xmm2, xmm1
	sub	rax, 1
	jne	SHORT $LL266@solve_into
	mov	rdi, QWORD PTR tv3699[rbp-81]
	mov	r13, QWORD PTR lower$3$[rbp-81]
	cmp	rcx, r10
	jae	SHORT $LN316@solve_into
$LC265@solve_into:
	mov	rax, r12
	lea	r8, QWORD PTR [r12*8]
	imul	rax, rcx
	add	rax, r15
	lea	rdx, QWORD PTR [rax*8]
	add	rdx, r13
$LC16@solve_into:
	movsd	xmm0, QWORD PTR [r9+rcx*8]
	inc	rcx
	mulsd	xmm0, QWORD PTR [rdx]
	add	rdx, r8
	subsd	xmm2, xmm0
	cmp	rcx, r10
	jb	SHORT $LC16@solve_into
$LN316@solve_into:

; 172  :         value/=lower(i,i);

	mov	r8, QWORD PTR tv3684[rbp-81]
	mov	rdx, QWORD PTR tv3700[rbp-81]
$LN264@solve_into:
	divsd	xmm2, QWORD PTR [rdi]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movaps	xmm0, xmm2
	andps	xmm0, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm4, xmm0

; 173  :         if (!detail::llt_is_finite(value)) return {StatusCode::arithmetic_failure,i};

	jb	$LN237@solve_into

; 174  :         candidate[i]=value;

	movsd	QWORD PTR [r9+r11*8], xmm2
	test	r11, r11
	jne	$LL13@solve_into

; 176  :     for (std::size_t i=0;i<n;++i) output[i]=candidate[i];

	mov	r11, QWORD PTR output$[rbp-81]
	mov	r8, rbx
	cmp	r10, 2
	jb	SHORT $LN312@solve_into
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rcx, QWORD PTR [r11]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 176  :     for (std::size_t i=0;i<n;++i) output[i]=candidate[i];

	lea	rax, QWORD PTR [r9-8]
	lea	rax, QWORD PTR [rax+r10*8]
	lea	rdx, QWORD PTR [r10-1]
	lea	rdx, QWORD PTR [rcx+rdx*8]
	cmp	rcx, rax
	ja	SHORT $LN253@solve_into
	cmp	rdx, r9
	jae	SHORT $LN312@solve_into
$LN253@solve_into:
	lea	r8, QWORD PTR [r10*8]
	mov	rdx, r9
	call	memcpy
$LN267@solve_into:

; 177  :     return {};

	mov	DWORD PTR $T6[rbp-81], ebx
	mov	QWORD PTR $T6[rbp-73], rbx
$LN361@solve_into:
	movups	xmm0, XMMWORD PTR $T6[rbp-81]
	mov	r14, QWORD PTR [rsp+120]
	mov	rax, rsi
	mov	r13, QWORD PTR [rsp+128]
	mov	r12, QWORD PTR [rsp+136]
	mov	rdi, QWORD PTR [rsp+192]
	mov	r15, QWORD PTR [rsp+112]
	mov	QWORD PTR $T6[rbp-65], rbx
	movsd	xmm1, QWORD PTR $T6[rbp-65]
	movups	XMMWORD PTR [rsi], xmm0
	movsd	QWORD PTR [rsi+16], xmm1

; 178  : }

	add	rsp, 144				; 00000090H
	pop	rsi
	pop	rbx
	pop	rbp
	ret	0
$LN312@solve_into:

; 176  :     for (std::size_t i=0;i<n;++i) output[i]=candidate[i];

	mov	r11, QWORD PTR [r11]
	mov	rax, r10
	sub	rax, r8
	cmp	rax, 4
	jb	SHORT $LC268@solve_into
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rdi, r10
	lea	rdx, QWORD PTR [r9+16]
	sub	rdi, r8
	lea	rdx, QWORD PTR [rdx+r8*8]
	sub	rdi, 4
	mov	r14, r9
	mov	r15d, 8
	shr	rdi, 2
	mov	r12, -16
	neg	r14
	sub	r15, r9
	sub	r12, r9
	inc	rdi
	lea	r8, QWORD PTR [r8+rdi*4]
$LL269@solve_into:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 176  :     for (std::size_t i=0;i<n;++i) output[i]=candidate[i];

	mov	rax, QWORD PTR [rdx-16]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	rcx, QWORD PTR [r12+r11]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 176  :     for (std::size_t i=0;i<n;++i) output[i]=candidate[i];

	mov	QWORD PTR [rcx+rdx], rax
	mov	rax, QWORD PTR [rdx-8]
	mov	QWORD PTR [rcx+rdx+8], rax
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	rcx, QWORD PTR [r14+r11]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 176  :     for (std::size_t i=0;i<n;++i) output[i]=candidate[i];

	mov	rax, QWORD PTR [rdx]
	mov	QWORD PTR [rcx+rdx], rax
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	rcx, QWORD PTR [r15+r11]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 176  :     for (std::size_t i=0;i<n;++i) output[i]=candidate[i];

	mov	rax, QWORD PTR [rdx+8]
	mov	QWORD PTR [rcx+rdx], rax
	lea	rdx, QWORD PTR [rdx+32]
	sub	rdi, 1
	jne	SHORT $LL269@solve_into
	cmp	r8, r10
	jae	$LN267@solve_into
$LC268@solve_into:
	mov	rax, QWORD PTR [r9+r8*8]
	mov	QWORD PTR [r11+r8*8], rax
	inc	r8
	cmp	r8, r10
	jb	SHORT $LC268@solve_into
	jmp	$LN267@solve_into
$LN237@solve_into:

; 173  :         if (!detail::llt_is_finite(value)) return {StatusCode::arithmetic_failure,i};

	mov	DWORD PTR $T5[rbp-81], 10
	mov	QWORD PTR $T5[rbp-73], r11
	jmp	$LN361@solve_into
$LN236@solve_into:

; 166  :         if (!detail::llt_is_finite(value)) return {StatusCode::arithmetic_failure,i};

	mov	DWORD PTR $T4[rbp-81], 10
	mov	QWORD PTR $T4[rbp-73], r8
	jmp	$LN361@solve_into
$LN22@solve_into:

; 153  :     const auto n=factor.size();
; 154  :     if (rhs.size()!=n || output.size()!=n) return {StatusCode::invalid_shape};

	mov	DWORD PTR $T2[rbp-81], 1
	jmp	$LN362@solve_into
?solve_into@linalg@kibo@@YA?AUStatus@12@VLltFactorView@12@V?$span@$$CBN$0?0@std@@V?$span@N$0?0@6@V?$span@W4byte@std@@$0?0@6@@Z ENDP ; kibo::linalg::solve_into