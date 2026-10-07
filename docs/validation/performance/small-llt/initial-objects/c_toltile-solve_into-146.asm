?solve_into@linalg@kibo@@YA?AUStatus@12@VLltFactorView@12@V?$span@$$CBN$0?0@std@@V?$span@N$0?0@6@V?$span@W4byte@std@@$0?0@6@@Z PROC ; kibo::linalg::solve_into, COMDAT

; 184  :                          std::span<std::byte> workspace) noexcept {

$LN415:
	mov	QWORD PTR [rsp+32], r9
	push	rbp
	push	rdi
	push	r14
	push	r15
	lea	rbp, QWORD PTR [rsp-55]
	sub	rsp, 216				; 000000d8H

; 17   :     bool valid() const noexcept { return lower_.rows()!=0; }

	mov	rdi, QWORD PTR [rdx+16]

; 184  :                          std::span<std::byte> workspace) noexcept {

	mov	r10, r8
	mov	r15, rcx

; 185  :     if (!factor.valid()) return {StatusCode::invalid_factor};

	test	rdi, rdi
	jne	SHORT $LN23@solve_into
	xor	r14d, r14d
	mov	DWORD PTR $T1[rsp], 11
	mov	QWORD PTR $T1[rbp-153], r14
	mov	rax, rcx
	movups	xmm0, XMMWORD PTR $T1[rsp]
	mov	QWORD PTR $T1[rbp-145], r14
	movsd	xmm1, QWORD PTR $T1[rbp-145]
	movups	XMMWORD PTR [rcx], xmm0
	movsd	QWORD PTR [rcx+16], xmm1

; 220  : }

	add	rsp, 216				; 000000d8H
	pop	r15
	pop	r14
	pop	rdi
	pop	rbp
	ret	0
$LN23@solve_into:

; 186  :     const auto n=factor.size();
; 187  :     if (rhs.size()!=n || output.size()!=n) return {StatusCode::invalid_shape};

	mov	r8, QWORD PTR [r8+8]
	cmp	r8, rdi
	jne	$LN25@solve_into
	cmp	QWORD PTR [r9+8], rdi
	jne	$LN25@solve_into
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\workspace.hpp

; 9    :     if (count > std::numeric_limits<std::size_t>::max()/sizeof(double)) return StatusCode::size_overflow;

	mov	rax, 2305843009213693951		; 1fffffffffffffffH
	cmp	rdi, rax
	jbe	SHORT $LN156@solve_into
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\linalg.hpp

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	xor	r14d, r14d
	mov	DWORD PTR requirement$[rsp], 5
	mov	QWORD PTR requirement$[rbp-153], r14
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\llt.hpp

; 189  :     if (!requirement) return requirement.status();

	mov	rax, r15
	movups	xmm0, XMMWORD PTR requirement$[rsp]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\linalg.hpp

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	mov	QWORD PTR requirement$[rbp-145], r14
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\llt.hpp

; 189  :     if (!requirement) return requirement.status();

	movsd	xmm1, QWORD PTR requirement$[rbp-145]
	movups	XMMWORD PTR [rcx], xmm0
	movsd	QWORD PTR [rcx+16], xmm1

; 220  : }

	add	rsp, 216				; 000000d8H
	pop	r15
	pop	r14
	pop	rdi
	pop	rbp
	ret	0
$LN156@solve_into:

; 190  :     auto prepared=detail::workspace_doubles(workspace,requirement.value());

	mov	rax, QWORD PTR workspace$[rbp-161]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\workspace.hpp

; 10   :     return WorkspaceRequirement{count*sizeof(double),alignof(double)};

	lea	rcx, QWORD PTR [rdi*8]
	mov	QWORD PTR [rsp+272], rbx
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\llt.hpp

; 190  :     auto prepared=detail::workspace_doubles(workspace,requirement.value());

	movups	xmm0, XMMWORD PTR [rax]
	movaps	XMMWORD PTR $T8[rsp], xmm0
	cmp	QWORD PTR [rax+8], rcx
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\workspace.hpp

; 13   :     if (storage.size() < requirement.bytes) return StatusCode::insufficient_capacity;

	jae	SHORT $LN202@solve_into
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\linalg.hpp

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	mov	DWORD PTR prepared$[rsp], 4
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\workspace.hpp

; 13   :     if (storage.size() < requirement.bytes) return StatusCode::insufficient_capacity;

	jmp	SHORT $LN409@solve_into
$LN202@solve_into:

; 14   :     if (requirement.bytes!=0 && reinterpret_cast<std::uintptr_t>(storage.data())%requirement.alignment!=0)

	mov	rbx, QWORD PTR $T8[rsp]
	test	rcx, rcx
	je	SHORT $LN203@solve_into
	test	bl, 7
	je	SHORT $LN203@solve_into
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\linalg.hpp

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	mov	DWORD PTR prepared$[rsp], 2
$LN409@solve_into:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\llt.hpp

; 191  :     if (!prepared) return prepared.status();

	xor	r14d, r14d
	mov	rax, r15
	mov	QWORD PTR prepared$[rbp-153], r14
	movups	xmm0, XMMWORD PTR prepared$[rsp]
	mov	QWORD PTR prepared$[rbp-145], r14
	movsd	xmm1, QWORD PTR prepared$[rbp-145]
	movups	XMMWORD PTR [r15], xmm0
	movsd	QWORD PTR [r15+16], xmm1
	jmp	$LN403@solve_into
$LN203@solve_into:

; 192  :     for (auto value:rhs) if (!detail::llt_is_finite(value)) return {StatusCode::non_finite_input};

	mov	r9, QWORD PTR [r10]
	movaps	XMMWORD PTR [rsp+176], xmm6
	mov	rax, r9
	movdqa	xmm6, XMMWORD PTR __xmm@7fffffffffffffff7fffffffffffffff
	movaps	XMMWORD PTR [rsp+160], xmm7
	movsd	xmm7, QWORD PTR __real@7fefffffffffffff
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 542  :         return _Mydata + _Mysize;

	lea	rcx, QWORD PTR [r9+r8*8]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\llt.hpp

; 192  :     for (auto value:rhs) if (!detail::llt_is_finite(value)) return {StatusCode::non_finite_input};

	cmp	r9, rcx
	je	SHORT $LN3@solve_into
$LL4@solve_into:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rax]
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm7, xmm0

; 192  :     for (auto value:rhs) if (!detail::llt_is_finite(value)) return {StatusCode::non_finite_input};

	jb	$LN270@solve_into
	add	rax, 8
	cmp	rax, rcx
	jne	SHORT $LL4@solve_into
$LN3@solve_into:

; 193  :     auto candidate=prepared.value();
; 194  :     auto lower=factor.lower();
; 195  :     for (std::size_t i=0;i<n;++i) {

	mov	r10, QWORD PTR [rdx+40]
	xor	r14d, r14d
	mov	r11, QWORD PTR [rdx+32]
	mov	r8d, r14d
	mov	QWORD PTR [rsp+208], rsi
	mov	QWORD PTR [rsp+200], r12
	mov	QWORD PTR [rsp+192], r13
	mov	r13, QWORD PTR [rdx]
	mov	QWORD PTR lower$3$[rbp-161], r13
	test	rdi, rdi
	je	$LN6@solve_into
	lea	rdx, QWORD PTR [r11+r10]
	mov	QWORD PTR tv3964[rbp-161], r13
	shl	rdx, 3
	mov	eax, r14d
	sub	r9, rbx
	mov	QWORD PTR tv3968[rbp-161], rax
	mov	QWORD PTR tv3932[rbp-161], r9
	mov	r12, rbx
	mov	QWORD PTR tv3965[rbp-161], rdx
	mov	rsi, r13
	npad	11
$LL7@solve_into:

; 196  :         double value=rhs[i];

	movsd	xmm2, QWORD PTR [r12+r9]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rcx, r14
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\llt.hpp

; 197  :         for (std::size_t j=0;j<i;++j) value-=lower(i,j)*candidate[j];

	cmp	r8, 4
	jb	$LC302@solve_into
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	rcx, QWORD PTR lower$3$[rbp-161]
	lea	rax, QWORD PTR [rax+r10*2]
	mov	rsi, r10
	lea	rdx, QWORD PTR [rbx+16]
	neg	rsi
	mov	r13, r10
	shl	r13, 5
	add	rsi, rsi
	lea	r9, QWORD PTR [rcx+rax*8]
	mov	rax, r10
	neg	rax
	mov	QWORD PTR tv4081[rbp-161], rax
	lea	rax, QWORD PTR [r8-4]
	mov	rbx, QWORD PTR tv4081[rbp-161]
	shr	rax, 2
	inc	rax
	lea	rcx, QWORD PTR [rax*4]
$LL303@solve_into:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\llt.hpp

; 197  :         for (std::size_t j=0;j<i;++j) value-=lower(i,j)*candidate[j];

	movsd	xmm0, QWORD PTR [r9+rsi*8]
	mulsd	xmm0, QWORD PTR [rdx-16]
	movsd	xmm1, QWORD PTR [r9+rbx*8]
	mulsd	xmm1, QWORD PTR [rdx-8]
	subsd	xmm2, xmm0
	movsd	xmm0, QWORD PTR [r9]
	mulsd	xmm0, QWORD PTR [rdx]
	subsd	xmm2, xmm1
	movsd	xmm1, QWORD PTR [r9+r10*8]
	mulsd	xmm1, QWORD PTR [rdx+8]
	add	r9, r13
	add	rdx, 32					; 00000020H
	subsd	xmm2, xmm0
	subsd	xmm2, xmm1
	sub	rax, 1
	jne	SHORT $LL303@solve_into
	mov	rbx, QWORD PTR $T8[rsp]
	mov	rsi, QWORD PTR tv3964[rbp-161]
	mov	r13, QWORD PTR lower$3$[rbp-161]
	cmp	rcx, r8
	jb	SHORT $LN357@solve_into
	jmp	SHORT $LN410@solve_into
$LN270@solve_into:

; 192  :     for (auto value:rhs) if (!detail::llt_is_finite(value)) return {StatusCode::non_finite_input};

	xor	r14d, r14d
	mov	DWORD PTR $T3[rsp], 7
	mov	QWORD PTR $T3[rbp-153], r14
	mov	rax, r15
	movups	xmm0, XMMWORD PTR $T3[rsp]
	mov	QWORD PTR $T3[rbp-145], r14
	movsd	xmm1, QWORD PTR $T3[rbp-145]
	movups	XMMWORD PTR [r15], xmm0
	movsd	QWORD PTR [r15+16], xmm1
	jmp	$LN405@solve_into
$LC302@solve_into:

; 197  :         for (std::size_t j=0;j<i;++j) value-=lower(i,j)*candidate[j];

	test	r8, r8
	je	SHORT $LN301@solve_into
$LN357@solve_into:
	mov	rax, r10
	lea	r9, QWORD PTR [r10*8]
	imul	rax, rcx
	add	rax, QWORD PTR tv3968[rbp-161]
	lea	rdx, QWORD PTR [rax*8]
	add	rdx, r13
$LC10@solve_into:
	movsd	xmm0, QWORD PTR [rbx+rcx*8]
	inc	rcx
	mulsd	xmm0, QWORD PTR [rdx]
	add	rdx, r9
	subsd	xmm2, xmm0
	cmp	rcx, r8
	jb	SHORT $LC10@solve_into
$LN410@solve_into:

; 198  :         value/=lower(i,i);

	mov	rdx, QWORD PTR tv3965[rbp-161]
	mov	r9, QWORD PTR tv3932[rbp-161]
	mov	rax, QWORD PTR tv3968[rbp-161]
$LN301@solve_into:
	divsd	xmm2, QWORD PTR [rsi]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movaps	xmm0, xmm2
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm7, xmm0

; 199  :         if (!detail::llt_is_finite(value)) return {StatusCode::arithmetic_failure,i};

	jb	$LN271@solve_into

; 200  :         candidate[i]=value;

	add	rax, r11
	movsd	QWORD PTR [r12], xmm2
	add	rsi, rdx
	mov	QWORD PTR tv3968[rbp-161], rax
	add	r12, 8
	mov	QWORD PTR tv3964[rbp-161], rsi
	inc	r8
	cmp	r8, rdi
	jb	$LL7@solve_into
$LN6@solve_into:

; 201  :     }
; 202  :     if (detail::row_simd_available && lower.col_stride()==1 && n>=9) {

	cmp	r10, 1
	jne	$LN30@solve_into
	cmp	rdi, 9
	jb	$LN30@solve_into

; 203  :         for (std::size_t i=n;i-->0;) {

	lea	rdx, QWORD PTR [r11*8]
	mov	rax, r11
	imul	rax, rdi
	mov	rcx, -8
	mov	QWORD PTR tv3930[rbp-161], rdx
	sub	rcx, rdx
	mov	rsi, rdi
	mov	QWORD PTR tv3961[rbp-161], rcx
	lea	r12, QWORD PTR [rax*8]
	add	r12, r13
	lea	rax, QWORD PTR [r11+1]
	imul	rax, rdi
	lea	r13, QWORD PTR [r13+rax*8]
	npad	3
$LL13@solve_into:

; 204  :             const auto value=candidate[i]/lower(i,i);

	movsd	xmm3, QWORD PTR [rbx+rsi*8-8]
	dec	rsi
	add	r13, rcx
	sub	r12, rdx
	divsd	xmm3, QWORD PTR [r13]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movaps	xmm0, xmm3
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm7, xmm0

; 205  :             if (!detail::llt_is_finite(value)) return {StatusCode::arithmetic_failure,i};

	jb	SHORT $LN272@solve_into

; 206  :             candidate[i]=value;

	movsd	QWORD PTR [rbx+rsi*8], xmm3

; 207  :             if (i>0) detail::row_update(candidate.data(),&lower(i,0),i,value);

	test	rsi, rsi
	je	$LN360@solve_into
	mov	r8, rsi
	mov	rdx, r12
	mov	rcx, rbx
	call	?row_update@detail@linalg@kibo@@YAXPEANPEBN_KN@Z ; kibo::linalg::detail::row_update
	mov	rcx, QWORD PTR tv3961[rbp-161]
	mov	rdx, QWORD PTR tv3930[rbp-161]
	jmp	SHORT $LL13@solve_into
$LN271@solve_into:

; 199  :         if (!detail::llt_is_finite(value)) return {StatusCode::arithmetic_failure,i};

	mov	QWORD PTR $T4[rbp-153], r8
	jmp	$LN412@solve_into
$LN272@solve_into:

; 205  :             if (!detail::llt_is_finite(value)) return {StatusCode::arithmetic_failure,i};

	mov	QWORD PTR $T5[rbp-153], rsi
	jmp	$LN412@solve_into
$LN30@solve_into:

; 208  :         }
; 209  :     } else {
; 210  :         for (std::size_t i=n;i-->0;) {

	lea	rax, QWORD PTR [r11+r10]
	mov	r12, r10
	mov	rdx, r10
	lea	r8, QWORD PTR [rax*8]
	imul	rax, rdi
	imul	r12, rdi
	neg	rdx
	mov	QWORD PTR tv3929[rbp-161], r8
	lea	r10, QWORD PTR [rax*8]
	mov	QWORD PTR tv3947[rbp-161], rdx
	add	r10, r13
	mov	r9, rdi
	npad	4
$LL16@solve_into:

; 211  :             double value=candidate[i];

	movsd	xmm2, QWORD PTR [rbx+r9*8-8]
	mov	rcx, r9
	dec	r9
	sub	r10, r8
	add	r12, rdx
	mov	QWORD PTR tv3946[rbp-161], r10

; 212  :             for (std::size_t j=i+1;j<n;++j) value-=lower(j,i)*candidate[j];

	cmp	rcx, rdi
	jae	$LN304@solve_into
	mov	rax, rdi
	sub	rax, rcx
	cmp	rax, 4
	jb	$LC305@solve_into
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	lea	rdx, QWORD PTR [rcx+2]
	mov	rax, r11
	imul	rax, rcx
	mov	r10, r11
	lea	rdx, QWORD PTR [rbx+rdx*8]
	add	rax, r12
	shl	r10, 5
	mov	rsi, r11
	add	rsi, rsi
	lea	r8, QWORD PTR [rax*8]
	mov	rax, rdi
	sub	rax, rcx
	add	r8, r13
	sub	rax, 4
	lea	r13, QWORD PTR [r11+r11*2]
	shr	rax, 2
	inc	rax
	lea	rcx, QWORD PTR [rcx+rax*4]
	npad	13
$LL306@solve_into:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\llt.hpp

; 212  :             for (std::size_t j=i+1;j<n;++j) value-=lower(j,i)*candidate[j];

	movsd	xmm0, QWORD PTR [rdx-16]
	mulsd	xmm0, QWORD PTR [r8]
	movsd	xmm1, QWORD PTR [r8+r11*8]
	mulsd	xmm1, QWORD PTR [rdx-8]
	subsd	xmm2, xmm0
	movsd	xmm0, QWORD PTR [r8+rsi*8]
	mulsd	xmm0, QWORD PTR [rdx]
	subsd	xmm2, xmm1
	movsd	xmm1, QWORD PTR [r8+r13*8]
	mulsd	xmm1, QWORD PTR [rdx+8]
	add	r8, r10
	add	rdx, 32					; 00000020H
	subsd	xmm2, xmm0
	subsd	xmm2, xmm1
	sub	rax, 1
	jne	SHORT $LL306@solve_into
	mov	r10, QWORD PTR tv3946[rbp-161]
	mov	r13, QWORD PTR lower$3$[rbp-161]
	cmp	rcx, rdi
	jae	SHORT $LN362@solve_into
$LC305@solve_into:
	mov	rax, r11
	lea	r8, QWORD PTR [r11*8]
	imul	rax, rcx
	add	rax, r12
	lea	rdx, QWORD PTR [rax*8]
	add	rdx, r13
$LC19@solve_into:
	movsd	xmm0, QWORD PTR [rbx+rcx*8]
	inc	rcx
	mulsd	xmm0, QWORD PTR [rdx]
	add	rdx, r8
	subsd	xmm2, xmm0
	cmp	rcx, rdi
	jb	SHORT $LC19@solve_into
$LN362@solve_into:

; 213  :             value/=lower(i,i);

	mov	r8, QWORD PTR tv3929[rbp-161]
	mov	rdx, QWORD PTR tv3947[rbp-161]
$LN304@solve_into:
	divsd	xmm2, QWORD PTR [r10]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movaps	xmm0, xmm2
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm7, xmm0

; 214  :             if (!detail::llt_is_finite(value)) return {StatusCode::arithmetic_failure,i};

	jb	$LN273@solve_into

; 215  :             candidate[i]=value;

	movsd	QWORD PTR [rbx+r9*8], xmm2
	test	r9, r9
	jne	$LL16@solve_into

; 218  :     for (std::size_t i=0;i<n;++i) output[i]=candidate[i];

	mov	rdx, r14
	cmp	rdi, 2
	jb	SHORT $LN364@solve_into
$LN360@solve_into:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	r9, QWORD PTR output$[rbp-161]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\llt.hpp

; 218  :     for (std::size_t i=0;i<n;++i) output[i]=candidate[i];

	lea	rax, QWORD PTR [rdi-1]
	lea	rax, QWORD PTR [rbx+rax*8]
	mov	rdx, r14
	lea	r8, QWORD PTR [rdi-1]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rcx, QWORD PTR [r9]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\llt.hpp

; 218  :     for (std::size_t i=0;i<n;++i) output[i]=candidate[i];

	lea	r8, QWORD PTR [rcx+r8*8]
	cmp	rcx, rax
	ja	SHORT $LN292@solve_into
	cmp	r8, rbx
	jae	SHORT $LN358@solve_into
$LN292@solve_into:
	lea	r8, QWORD PTR [rdi*8]
	mov	rdx, rbx
	call	memcpy

; 219  :     return {};

	mov	DWORD PTR $T7[rsp], r14d
	mov	QWORD PTR $T7[rbp-153], r14
	jmp	$LN411@solve_into
$LN364@solve_into:

; 218  :     for (std::size_t i=0;i<n;++i) output[i]=candidate[i];

	mov	r9, QWORD PTR output$[rbp-161]
$LN358@solve_into:
	mov	r9, QWORD PTR [r9]
	mov	rax, rdi
	sub	rax, rdx
	cmp	rax, 4
	jb	SHORT $LC308@solve_into
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	r8, QWORD PTR [rdx+2]
	mov	r10, rdi
	sub	r10, rdx
	lea	r8, QWORD PTR [rbx+r8*8]
	sub	r10, 4
	mov	rsi, rbx
	mov	r12d, 8
	shr	r10, 2
	mov	r11, -16
	neg	rsi
	sub	r12, rbx
	sub	r11, rbx
	inc	r10
	lea	rdx, QWORD PTR [rdx+r10*4]
	npad	7
$LL309@solve_into:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\llt.hpp

; 218  :     for (std::size_t i=0;i<n;++i) output[i]=candidate[i];

	mov	rax, QWORD PTR [r8-16]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	rcx, QWORD PTR [r8+r9]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\llt.hpp

; 218  :     for (std::size_t i=0;i<n;++i) output[i]=candidate[i];

	mov	QWORD PTR [rcx+r11], rax
	mov	rax, QWORD PTR [r8-8]
	mov	QWORD PTR [rcx+r11+8], rax
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	rcx, QWORD PTR [r8+r9]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\llt.hpp

; 218  :     for (std::size_t i=0;i<n;++i) output[i]=candidate[i];

	mov	rax, QWORD PTR [r8]
	mov	QWORD PTR [rcx+rsi], rax
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	rcx, QWORD PTR [r8+r9]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_toltile\kibo\llt.hpp

; 218  :     for (std::size_t i=0;i<n;++i) output[i]=candidate[i];

	mov	rax, QWORD PTR [r8+8]
	lea	r8, QWORD PTR [r8+32]
	mov	QWORD PTR [rcx+r12], rax
	sub	r10, 1
	jne	SHORT $LL309@solve_into
	cmp	rdx, rdi
	jae	SHORT $LN307@solve_into
$LC308@solve_into:
	mov	rax, QWORD PTR [rbx+rdx*8]
	mov	QWORD PTR [r9+rdx*8], rax
	inc	rdx
	cmp	rdx, rdi
	jb	SHORT $LC308@solve_into
$LN307@solve_into:

; 219  :     return {};

	mov	DWORD PTR $T7[rsp], r14d
	mov	QWORD PTR $T7[rbp-153], r14
	jmp	SHORT $LN411@solve_into
$LN273@solve_into:

; 214  :             if (!detail::llt_is_finite(value)) return {StatusCode::arithmetic_failure,i};

	mov	QWORD PTR $T6[rbp-153], r9
$LN412@solve_into:
	mov	DWORD PTR $T6[rsp], 10
$LN411@solve_into:
	movups	xmm0, XMMWORD PTR $T6[rsp]
	mov	r12, QWORD PTR [rsp+200]
	mov	rax, r15
	mov	r13, QWORD PTR [rsp+192]
	mov	rsi, QWORD PTR [rsp+208]
	mov	QWORD PTR $T6[rbp-145], r14
	movsd	xmm1, QWORD PTR $T6[rbp-145]
	movups	XMMWORD PTR [r15], xmm0
	movsd	QWORD PTR [r15+16], xmm1
$LN405@solve_into:
	movaps	xmm6, XMMWORD PTR [rsp+176]
	movaps	xmm7, XMMWORD PTR [rsp+160]
$LN403@solve_into:
	mov	rbx, QWORD PTR [rsp+272]

; 220  : }

	add	rsp, 216				; 000000d8H
	pop	r15
	pop	r14
	pop	rdi
	pop	rbp
	ret	0
$LN25@solve_into:

; 186  :     const auto n=factor.size();
; 187  :     if (rhs.size()!=n || output.size()!=n) return {StatusCode::invalid_shape};

	xor	r14d, r14d
	mov	DWORD PTR $T2[rsp], 1
	mov	QWORD PTR $T2[rbp-153], r14
	mov	rax, r15
	movups	xmm0, XMMWORD PTR $T2[rsp]
	mov	QWORD PTR $T2[rbp-145], r14
	movsd	xmm1, QWORD PTR $T2[rbp-145]
	movups	XMMWORD PTR [rcx], xmm0
	movsd	QWORD PTR [rcx+16], xmm1

; 220  : }

	add	rsp, 216				; 000000d8H
	pop	r15
	pop	r14
	pop	rdi
	pop	rbp
	ret	0
?solve_into@linalg@kibo@@YA?AUStatus@12@VLltFactorView@12@V?$span@$$CBN$0?0@std@@V?$span@N$0?0@6@V?$span@W4byte@std@@$0?0@6@@Z ENDP ; kibo::linalg::solve_into