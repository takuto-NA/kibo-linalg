?factorize_llt@linalg@kibo@@YA?AV?$Result@VLltFactorView@linalg@kibo@@@12@V?$MatrixView@$$CBN@12@V?$MatrixView@N@12@ULltOptions@12@@Z PROC ; kibo::linalg::factorize_llt, COMDAT

; 132  :                                          LltOptions options={}) noexcept {

$LN538:
	mov	r11, rsp
	mov	QWORD PTR [r11+32], r9
	mov	QWORD PTR [r11+24], r8
	mov	QWORD PTR [r11+8], rcx
	push	rbp
	push	rsi
	push	r12
	push	r13
	push	r14
	lea	rbp, QWORD PTR [r11-72]
	sub	rsp, 288				; 00000120H

; 133  :     const auto n=input.rows();

	mov	r13, QWORD PTR [rdx+16]
	mov	r14, r8
	mov	QWORD PTR n$1$[rbp-256], r13
	mov	rsi, rdx
	mov	r12, rcx

; 134  :     if (n==0 || input.cols()!=n || !detail::same_shape(input,storage)) return StatusCode::invalid_shape;

	test	r13, r13
	je	$LN36@factorize_
	cmp	QWORD PTR [rdx+24], r13
	jne	$LN36@factorize_
	movups	xmm0, XMMWORD PTR [r8]
	movups	xmm2, XMMWORD PTR [r8+16]
	movups	xmm3, XMMWORD PTR [rdx+16]
	movups	xmm1, XMMWORD PTR [rdx]
	movaps	XMMWORD PTR $T6[rbp-256], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 146  :     return a.rows() == b.rows() && a.cols() == b.cols();

	movq	rcx, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 134  :     if (n==0 || input.cols()!=n || !detail::same_shape(input,storage)) return StatusCode::invalid_shape;

	movups	xmm0, XMMWORD PTR [r8+32]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 146  :     return a.rows() == b.rows() && a.cols() == b.cols();

	movq	rax, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 134  :     if (n==0 || input.cols()!=n || !detail::same_shape(input,storage)) return StatusCode::invalid_shape;

	movaps	XMMWORD PTR $T5[rbp-256], xmm1
	movaps	XMMWORD PTR $T6[rbp-224], xmm0
	movups	xmm0, XMMWORD PTR [rdx+32]
	movaps	XMMWORD PTR $T5[rbp-224], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 146  :     return a.rows() == b.rows() && a.cols() == b.cols();

	cmp	rcx, rax
	jne	$LN36@factorize_
	psrldq	xmm3, 8
	psrldq	xmm2, 8
	movq	rcx, xmm3
	movq	rax, xmm2
	cmp	rcx, rax
	jne	$LN36@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 135  :     if (!detail::llt_is_finite(options.symmetry_tolerance) || options.symmetry_tolerance<0 || options.symmetry_tolerance>=1)

	movsd	xmm1, QWORD PTR [r9]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 146  :     return a.rows() == b.rows() && a.cols() == b.cols();

	movaps	XMMWORD PTR [r11-88], xmm6
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movaps	xmm0, xmm1
	movdqa	xmm6, XMMWORD PTR __xmm@7fffffffffffffff7fffffffffffffff
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 146  :     return a.rows() == b.rows() && a.cols() == b.cols();

	movaps	XMMWORD PTR [r11-104], xmm7
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	movsd	xmm7, QWORD PTR __real@7fefffffffffffff
	comisd	xmm7, xmm0
	movaps	XMMWORD PTR [r11-120], xmm8

; 135  :     if (!detail::llt_is_finite(options.symmetry_tolerance) || options.symmetry_tolerance<0 || options.symmetry_tolerance>=1)

	jb	$LN38@factorize_
	xorps	xmm8, xmm8
	comisd	xmm8, xmm1
	ja	$LN38@factorize_
	comisd	xmm1, QWORD PTR __real@3ff0000000000000
	jae	$LN38@factorize_

; 137  :     double scale=0;
; 138  :     if (options.check_symmetry && input.col_stride()==1) {

	mov	QWORD PTR [r11-48], rbx
	xorps	xmm1, xmm1
	mov	QWORD PTR [r11-56], rdi
	mov	QWORD PTR [r11-64], r15
	movzx	r11d, BYTE PTR [r9+8]
	movsd	QWORD PTR scale$[rbp-256], xmm1
	test	r11b, r11b
	je	$LN460@factorize_
	cmp	QWORD PTR [rdx+40], 1
	jne	$LN460@factorize_

; 139  :         // The whole input, including the unused triangle, is still validated
; 140  :         // before storage is touched. Combine the finite and scale scans.
; 141  :         if (input.row_stride()==n) {

	mov	r15, QWORD PTR [rdx+32]
	cmp	r15, r13
	jne	SHORT $LN41@factorize_

; 142  :             if (!detail::finite_max_abs(&input(0,0),n*n,scale)) return StatusCode::non_finite_input;

	mov	rcx, QWORD PTR [rsi]
	lea	r8, QWORD PTR scale$[rbp-256]
	mov	rdx, r13
	imul	rdx, r13
	call	?finite_max_abs@detail@linalg@kibo@@YA_NPEBN_KAEAN@Z ; kibo::linalg::detail::finite_max_abs
	test	al, al
	jne	$LN473@factorize_
$LN358@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	mov	DWORD PTR [r12], 7
	mov	QWORD PTR [r12+8], 0
	mov	QWORD PTR [r12+16], 0
$LN535@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 166  :             return detail::factorize_column_llt(input,storage);

	mov	BYTE PTR [r12+72], 0
$LN534@factorize_:
	mov	rax, r12
$LN530@factorize_:
	mov	rbx, QWORD PTR [rsp+280]
	mov	rdi, QWORD PTR [rsp+272]
	mov	r15, QWORD PTR [rsp+264]
$LN527@factorize_:
	movaps	xmm8, XMMWORD PTR [rsp+208]
	movaps	xmm6, XMMWORD PTR [rsp+240]
	movaps	xmm7, XMMWORD PTR [rsp+224]

; 185  : }

	add	rsp, 288				; 00000120H
	pop	r14
	pop	r13
	pop	r12
	pop	rsi
	pop	rbp
	ret	0
$LN41@factorize_:

; 143  :         } else {
; 144  :         for (std::size_t i=0;i<n;++i)

	xor	ebx, ebx
	test	r13, r13
	je	$LN465@factorize_
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rdi, QWORD PTR [rdx]
	lea	r15, QWORD PTR [r15*8]
	npad	5
$LL4@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 145  :             if (!detail::finite_max_abs(&input(i,0),n,scale)) return StatusCode::non_finite_input;

	lea	r8, QWORD PTR scale$[rbp-256]
	mov	rdx, r13
	mov	rcx, rdi
	call	?finite_max_abs@detail@linalg@kibo@@YA_NPEBN_KAEAN@Z ; kibo::linalg::detail::finite_max_abs
	test	al, al
	je	$LN358@factorize_

; 143  :         } else {
; 144  :         for (std::size_t i=0;i<n;++i)

	inc	rbx
	add	rdi, r15
	cmp	rbx, r13
	jb	SHORT $LL4@factorize_
$LN473@factorize_:

; 153  :         }
; 154  :     }
; 155  :     if (options.check_symmetry) {
; 156  :         if (scale!=0) {

	movsd	xmm1, QWORD PTR scale$[rbp-256]
	jmp	$LN477@factorize_
$LN460@factorize_:

; 148  :         for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<n;++j)

	xor	r9d, r9d
	test	r13, r13
	je	SHORT $LN374@factorize_
	mov	rax, QWORD PTR [rdx+40]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r10, QWORD PTR [rsi+32]
	mov	r8, QWORD PTR [rsi]
	shl	r10, 3
	lea	rdx, QWORD PTR [rax*8]
	npad	5
$LL7@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 148  :         for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<n;++j)

	xor	ecx, ecx
	mov	rax, r8
$LL10@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rax]
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm7, xmm0

; 149  :             if (!detail::llt_is_finite(input(i,j))) return StatusCode::non_finite_input;

	jb	$LN358@factorize_

; 148  :         for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<n;++j)

	inc	rcx
	add	rax, rdx
	cmp	rcx, r13
	jb	SHORT $LL10@factorize_
	inc	r9
	add	r8, r10
	cmp	r9, r13
	jb	SHORT $LL7@factorize_
$LN374@factorize_:

; 150  :         if (options.check_symmetry) {

	test	r11b, r11b
	je	$LN375@factorize_

; 151  :             for (std::size_t i=0;i<n;++i)

	test	r13, r13
	je	$LN477@factorize_
	mov	rbx, QWORD PTR [rsi+40]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	xor	edi, edi
	mov	r12, QWORD PTR [rsi]
	mov	r15, r13
	lea	r8, QWORD PTR [rbx*8]
$LL13@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 152  :                 for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));

	xor	r11d, r11d
	cmp	r13, 4
	jb	$LC401@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	lea	rax, QWORD PTR [rdi+rbx*2]
	mov	rdx, rbx
	lea	rcx, QWORD PTR [r12+rax*8]
	neg	rdx
	lea	rax, QWORD PTR [r13-4]
	mov	r9, rbx
	mov	r10, rbx
	shr	rax, 2
	shl	r9, 5
	neg	r10
	add	rdx, rdx
	inc	rax
	lea	r11, QWORD PTR [rax*4]
$LL406@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rcx+rdx*8]
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 152  :                 for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));

	comisd	xmm0, xmm1
	jbe	SHORT $LN402@factorize_
	movaps	xmm1, xmm0
$LN402@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rcx+r10*8]
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 152  :                 for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));

	comisd	xmm0, xmm1
	jbe	SHORT $LN403@factorize_
	movaps	xmm1, xmm0
$LN403@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rcx]
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 152  :                 for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));

	comisd	xmm0, xmm1
	jbe	SHORT $LN404@factorize_
	movaps	xmm1, xmm0
$LN404@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rcx+r8]
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 152  :                 for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));

	comisd	xmm0, xmm1
	jbe	SHORT $LN405@factorize_
	movaps	xmm1, xmm0
$LN405@factorize_:
	add	rcx, r9
	sub	rax, 1
	jne	SHORT $LL406@factorize_
	cmp	r11, r13
	jae	SHORT $LN11@factorize_
$LC401@factorize_:
	mov	rax, rbx
	imul	rax, r11
	add	rax, rdi
	lea	rcx, QWORD PTR [r12+rax*8]
	mov	rax, r13
	sub	rax, r11
$LC16@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rcx]
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 152  :                 for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));

	comisd	xmm0, xmm1
	jbe	SHORT $LN14@factorize_
	movaps	xmm1, xmm0
$LN14@factorize_:
	add	rcx, r8
	sub	rax, 1
	jne	SHORT $LC16@factorize_
$LN11@factorize_:

; 151  :             for (std::size_t i=0;i<n;++i)

	add	rdi, QWORD PTR [rsi+32]
	sub	r15, 1
	jne	$LL13@factorize_
	mov	r12, QWORD PTR __$ReturnUdt$[rbp-256]
$LN477@factorize_:

; 153  :         }
; 154  :     }
; 155  :     if (options.check_symmetry) {
; 156  :         if (scale!=0) {

	mov	r9, QWORD PTR options$[rbp-256]
$LN465@factorize_:
	ucomisd	xmm1, xmm8
	jp	SHORT $LN471@factorize_
	je	$LN375@factorize_
$LN471@factorize_:

; 157  :             for (std::size_t i=0;i<n;++i)

	xor	r10d, r10d
	test	r13, r13
	je	$LN375@factorize_
	movsd	xmm3, QWORD PTR [r9]
$LL19@factorize_:

; 158  :                 for (std::size_t j=0;j<i;++j)

	xor	r8d, r8d
	test	r10, r10
	je	SHORT $LN17@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	rax, QWORD PTR [rsi+40]
	mov	rcx, QWORD PTR [rsi+32]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rdx, QWORD PTR [rsi]
	lea	rbx, QWORD PTR [rax*8]
	imul	rax, r10
	lea	r11, QWORD PTR [rcx*8]
	imul	rcx, r10
	lea	r9, QWORD PTR [rdx+rax*8]
	lea	rax, QWORD PTR [rdx+rcx*8]
	npad	9
$LL22@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 159  :                     if (input(i,j)!=input(j,i) &&

	movsd	xmm0, QWORD PTR [rax]
	movsd	xmm2, QWORD PTR [r9]
	ucomisd	xmm0, xmm2
	jp	SHORT $LN470@factorize_
	je	SHORT $LN20@factorize_
$LN470@factorize_:
	divsd	xmm0, xmm1
	divsd	xmm2, xmm1
	subsd	xmm0, xmm2
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 159  :                     if (input(i,j)!=input(j,i) &&

	comisd	xmm0, xmm3
	ja	$LN359@factorize_
$LN20@factorize_:

; 158  :                 for (std::size_t j=0;j<i;++j)

	inc	r8
	add	rax, rbx
	add	r9, r11
	cmp	r8, r10
	jb	SHORT $LL22@factorize_
$LN17@factorize_:

; 157  :             for (std::size_t i=0;i<n;++i)

	inc	r10
	cmp	r10, r13
	jb	SHORT $LL19@factorize_
$LN375@factorize_:

; 162  :         }
; 163  :     }
; 164  :     if constexpr (detail::row_simd_available) {
; 165  :         if (storage.col_stride()==1 && n>=9)

	mov	r10, QWORD PTR [r14+40]
	cmp	r10, 1
	jne	$LN463@factorize_
	cmp	r13, 9
	jb	$LN463@factorize_

; 166  :             return detail::factorize_column_llt(input,storage);

	movups	xmm0, XMMWORD PTR [r14]
	lea	r8, QWORD PTR $T4[rsp]
	mov	rcx, r12
	movups	xmm1, XMMWORD PTR [r14+16]
	lea	rdx, QWORD PTR $T7[rbp-256]
	movaps	XMMWORD PTR $T4[rsp], xmm0
	movups	xmm0, XMMWORD PTR [r14+32]
	movaps	XMMWORD PTR $T4[rsp+16], xmm1
	movups	xmm1, XMMWORD PTR [rsi]
	movaps	XMMWORD PTR $T4[rsp+32], xmm0
	movups	xmm0, XMMWORD PTR [rsi+16]
	movaps	XMMWORD PTR $T7[rbp-256], xmm1
	movups	xmm1, XMMWORD PTR [rsi+32]
	movaps	XMMWORD PTR $T7[rbp-240], xmm0
	movaps	XMMWORD PTR $T7[rbp-224], xmm1
	call	?factorize_column_llt@detail@linalg@kibo@@YA?AV?$Result@VLltFactorView@linalg@kibo@@@23@V?$MatrixView@$$CBN@23@V?$MatrixView@N@23@@Z ; kibo::linalg::detail::factorize_column_llt
	jmp	$LN534@factorize_
$LN359@factorize_:

; 161  :                         return Status{StatusCode::invalid_argument,i};

	mov	DWORD PTR $T1[rsp], 3
	mov	QWORD PTR $T1[rsp+8], r10
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 38   :     Result(Status error) noexcept : status_(error) { assert(!error); }

	movups	xmm0, XMMWORD PTR $T1[rsp]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 161  :                         return Status{StatusCode::invalid_argument,i};

	mov	QWORD PTR $T1[rsp+16], 0
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 38   :     Result(Status error) noexcept : status_(error) { assert(!error); }

	movsd	xmm1, QWORD PTR $T1[rsp+16]
	movups	XMMWORD PTR [r12], xmm0
	movsd	QWORD PTR [r12+16], xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 161  :                         return Status{StatusCode::invalid_argument,i};

	jmp	$LN535@factorize_
$LN463@factorize_:

; 168  :     for (std::size_t i=0;i<n;++i) {

	xor	r15d, r15d
	test	r13, r13
	je	$LN377@factorize_
	mov	rax, QWORD PTR [rsi+40]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	xor	r8d, r8d
	shl	rax, 3
	mov	QWORD PTR tv4057[rbp-256], rax
	mov	rax, QWORD PTR [rsi+32]
	shl	rax, 3
	mov	QWORD PTR tv3997[rbp-256], rax
	mov	rax, QWORD PTR [rsi]
	mov	QWORD PTR tv3995[rsp], r10
$LN532@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 169  :         for (std::size_t j=0;j<=i;++j) {

	mov	QWORD PTR tv3998[rsp], rax
	xor	ebx, ebx
	mov	QWORD PTR tv3996[rbp-256], r8
	mov	r12, rax
	mov	QWORD PTR tv4025[rsp], rax
	npad	10
$LL28@factorize_:

; 170  :             double value=input(i,j);

	movsd	xmm2, QWORD PTR [r12]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	xor	r10d, r10d
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 171  :             for (std::size_t k=0;k<j;++k) value-=storage(i,k)*storage(j,k);

	cmp	rbx, 4
	jb	$LC408@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	rdx, QWORD PTR [r14+40]
	mov	r12, QWORD PTR [r14+32]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	r11, rdx
	mov	rcx, QWORD PTR [r14]
	mov	rax, r12
	imul	rax, r15
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r9, r12
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	shl	r11, 5
	add	rax, rdx
	mov	rdi, rdx
	mov	rsi, rdx
	add	rdi, rdi
	neg	rsi
	lea	rcx, QWORD PTR [rcx+rax*8]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	lea	rax, QWORD PTR [r8+rbx]
	imul	r9, rax
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	r8, QWORD PTR [rdx+r9]
	mov	QWORD PTR tv4479[rsp], r8
	lea	r13, QWORD PTR [r9*8]
	lea	r8, QWORD PTR [r9+rdx*2]
	sub	r9, rdx
	mov	QWORD PTR tv4489[rsp], r8
	lea	r8, QWORD PTR [rax-4]
	mov	rax, QWORD PTR tv4479[rsp]
	add	r8, r15
	mov	r14, QWORD PTR tv4489[rsp]
	shr	r8, 2
	inc	r8
	lea	r10, QWORD PTR [r8*4]
	npad	9
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

$LL409@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 171  :             for (std::size_t k=0;k<j;++k) value-=storage(i,k)*storage(j,k);

	movsd	xmm0, QWORD PTR [rcx+rsi*8]
	mulsd	xmm0, QWORD PTR [rcx+r9*8]
	movsd	xmm1, QWORD PTR [rcx+r13]
	mulsd	xmm1, QWORD PTR [rcx]
	subsd	xmm2, xmm0
	movsd	xmm0, QWORD PTR [rcx+rdx*8]
	mulsd	xmm0, QWORD PTR [rcx+rax*8]
	subsd	xmm2, xmm1
	movsd	xmm1, QWORD PTR [rcx+rdi*8]
	mulsd	xmm1, QWORD PTR [rcx+r14*8]
	add	rcx, r11
	subsd	xmm2, xmm0
	subsd	xmm2, xmm1
	sub	r8, 1
	jne	SHORT $LL409@factorize_
	mov	r14, QWORD PTR storage$[rbp-256]
	cmp	r10, rbx
	jb	SHORT $LN475@factorize_
	jmp	SHORT $LN531@factorize_
$LC408@factorize_:
	test	rbx, rbx
	je	SHORT $LN407@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r12, QWORD PTR [r14+32]
	mov	rdx, QWORD PTR [r14+40]
$LN475@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 171  :             for (std::size_t k=0;k<j;++k) value-=storage(i,k)*storage(j,k);

	mov	rcx, QWORD PTR [r14]
	lea	r8, QWORD PTR [rdx*8]
	imul	rdx, r10
	mov	rax, r12
	imul	rax, r15
	add	rdx, rax
	lea	rax, QWORD PTR [rcx+rdx*8]
	mov	rdx, QWORD PTR tv3996[rbp-256]
	add	rdx, rbx
	mov	rcx, rbx
	imul	rdx, r12
	sub	rcx, r10
$LC31@factorize_:
	movsd	xmm0, QWORD PTR [rax+rdx*8]
	mulsd	xmm0, QWORD PTR [rax]
	add	rax, r8
	subsd	xmm2, xmm0
	sub	rcx, 1
	jne	SHORT $LC31@factorize_
$LN531@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	mov	r12, QWORD PTR tv4025[rsp]
$LN407@factorize_:
	movaps	xmm0, xmm2
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm7, xmm0

; 172  :             if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	jb	$LN360@factorize_

; 173  :             if (i==j) {

	cmp	r15, rbx
	jne	SHORT $LN53@factorize_

; 174  :                 if (value<=0) return Status{StatusCode::non_positive_pivot,j};

	comisd	xmm8, xmm2
	jae	$LN361@factorize_
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rdi, QWORD PTR [r14+32]
	xorps	xmm0, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 175  :                 storage(i,j)=std::sqrt(value);

	ucomisd	xmm0, xmm2
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rsi, QWORD PTR [r14]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 175  :                 storage(i,j)=std::sqrt(value);

	ja	SHORT $LN468@factorize_
	xorps	xmm0, xmm0
	sqrtsd	xmm0, xmm2
	jmp	SHORT $LN469@factorize_
$LN468@factorize_:
	movaps	xmm0, xmm2
	call	sqrt
$LN469@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rcx, rbx
	mov	rax, rdi
	imul	rcx, QWORD PTR [r14+40]
	imul	rax, r15
	add	rcx, rax
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 175  :                 storage(i,j)=std::sqrt(value);

	movsd	QWORD PTR [rsi+rcx*8], xmm0

; 176  :             } else {

	jmp	SHORT $LN26@factorize_
$LN53@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	rcx, QWORD PTR [r14+40]
	mov	rdi, QWORD PTR [r14+32]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rsi, QWORD PTR [r14]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	lea	rax, QWORD PTR [rdi+rcx]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	imul	rax, rbx
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 177  :                 value/=storage(j,j);

	divsd	xmm2, QWORD PTR [rsi+rax*8]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movaps	xmm0, xmm2
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm7, xmm0

; 178  :                 if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	jb	$LN360@factorize_
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rax, rdi
	imul	rax, r15
	imul	rcx, rbx
	add	rax, rcx
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 179  :                 storage(i,j)=value;

	movsd	QWORD PTR [rsi+rax*8], xmm2
$LN26@factorize_:

; 169  :         for (std::size_t j=0;j<=i;++j) {

	add	r12, QWORD PTR tv4057[rbp-256]
	inc	rbx
	mov	r8, QWORD PTR tv3996[rbp-256]
	mov	QWORD PTR tv4025[rsp], r12
	cmp	rbx, r15
	jbe	$LL28@factorize_

; 182  :         for (std::size_t j=i+1;j<n;++j) storage(i,j)=0;

	mov	r13, QWORD PTR n$1$[rbp-256]
	lea	r8, QWORD PTR [r15+1]
	cmp	r8, r13
	jae	$LN476@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r9, QWORD PTR tv3995[rsp]
	mov	rcx, r13
	mov	r10, QWORD PTR [r14+40]
	imul	rdi, r15
	lea	rdx, QWORD PTR [r10*8]
	add	rdi, r9
	sub	rcx, r8
	lea	rax, QWORD PTR [rsi+rdi*8]
	npad	11
$LL34@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 182  :         for (std::size_t j=i+1;j<n;++j) storage(i,j)=0;

	mov	QWORD PTR [rax], 0
	add	rax, rdx
	sub	rcx, 1
	jne	SHORT $LL34@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	rax, QWORD PTR tv3998[rsp]
	inc	r15
	add	rax, QWORD PTR tv3997[rbp-256]
	mov	r8, QWORD PTR tv3996[rbp-256]
	dec	r8
	add	r9, r10
	mov	QWORD PTR tv3995[rsp], r9
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 168  :     for (std::size_t i=0;i<n;++i) {

	jmp	$LN532@factorize_
$LN361@factorize_:

; 174  :                 if (value<=0) return Status{StatusCode::non_positive_pivot,j};

	mov	DWORD PTR $T3[rsp], 8
	jmp	SHORT $LN533@factorize_
$LN360@factorize_:

; 172  :             if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	mov	DWORD PTR $T2[rsp], 10
$LN533@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 38   :     Result(Status error) noexcept : status_(error) { assert(!error); }

	mov	rax, QWORD PTR __$ReturnUdt$[rbp-256]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 172  :             if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	mov	QWORD PTR $T2[rsp+8], rbx
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 38   :     Result(Status error) noexcept : status_(error) { assert(!error); }

	movups	xmm0, XMMWORD PTR $T2[rsp]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 172  :             if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	mov	QWORD PTR $T2[rsp+16], 0
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 38   :     Result(Status error) noexcept : status_(error) { assert(!error); }

	movsd	xmm1, QWORD PTR $T2[rsp+16]
	movups	XMMWORD PTR [rax], xmm0
	movsd	QWORD PTR [rax+16], xmm1
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\optional

; 77   :     constexpr _Optional_destruct_base() noexcept : _Dummy{}, _Has_value{false} {} // initialize an empty optional

	mov	BYTE PTR [rax+72], 0
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 172  :             if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	jmp	$LN530@factorize_
$LN476@factorize_:

; 182  :         for (std::size_t j=i+1;j<n;++j) storage(i,j)=0;

	mov	r12, QWORD PTR __$ReturnUdt$[rbp-256]
$LN377@factorize_:

; 184  :     return detail::LltAccess::create(storage);

	movups	xmm0, XMMWORD PTR [r14]
	mov	DWORD PTR [r12], 0
	movups	xmm1, XMMWORD PTR [r14+16]
	mov	QWORD PTR [r12+8], 0
	movups	xmm2, XMMWORD PTR [r14+32]
	mov	QWORD PTR [r12+16], 0
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\optional

; 82   :         : _Value(_STD forward<_Types>(_Args)...), _Has_value{true} {} // initialize contained value with _Args...

	movq	QWORD PTR [r12+24], xmm0
	psrldq	xmm0, 8
	movq	QWORD PTR [r12+32], xmm0
	movq	QWORD PTR [r12+40], xmm1
	psrldq	xmm1, 8
	movq	QWORD PTR [r12+48], xmm1
	movq	QWORD PTR [r12+56], xmm2
	psrldq	xmm2, 8
	movq	QWORD PTR [r12+64], xmm2
	mov	BYTE PTR [r12+72], 1
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 184  :     return detail::LltAccess::create(storage);

	jmp	$LN534@factorize_
$LN38@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	xor	eax, eax
	mov	DWORD PTR [r12], 3
	mov	QWORD PTR [r12+8], rax
	mov	QWORD PTR [r12+16], rax
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\optional

; 77   :     constexpr _Optional_destruct_base() noexcept : _Dummy{}, _Has_value{false} {} // initialize an empty optional

	mov	BYTE PTR [r12+72], al
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 136  :         return StatusCode::invalid_argument;

	mov	rax, r12
	jmp	$LN527@factorize_
$LN36@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\linalg.hpp

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	xor	eax, eax
	mov	DWORD PTR [r12], 1
	mov	QWORD PTR [r12+8], rax
	mov	QWORD PTR [r12+16], rax
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\optional

; 77   :     constexpr _Optional_destruct_base() noexcept : _Dummy{}, _Has_value{false} {} // initialize an empty optional

	mov	BYTE PTR [r12+72], al
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan2\kibo\llt.hpp

; 134  :     if (n==0 || input.cols()!=n || !detail::same_shape(input,storage)) return StatusCode::invalid_shape;

	mov	rax, r12

; 185  : }

	add	rsp, 288				; 00000120H
	pop	r14
	pop	r13
	pop	r12
	pop	rsi
	pop	rbp
	ret	0
?factorize_llt@linalg@kibo@@YA?AV?$Result@VLltFactorView@linalg@kibo@@@12@V?$MatrixView@$$CBN@12@V?$MatrixView@N@12@ULltOptions@12@@Z ENDP ; kibo::linalg::factorize_llt