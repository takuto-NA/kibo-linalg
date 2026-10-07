?factorize_llt@linalg@kibo@@YA?AV?$Result@VLltFactorView@linalg@kibo@@@12@V?$MatrixView@$$CBN@12@V?$MatrixView@N@12@ULltOptions@12@@Z PROC ; kibo::linalg::factorize_llt, COMDAT

; 132  :                                          LltOptions options={}) noexcept {

$LN610:
	mov	r11, rsp
	mov	QWORD PTR [r11+32], r9
	mov	QWORD PTR [r11+24], r8
	mov	QWORD PTR [r11+8], rcx
	push	rbp
	push	rbx
	push	rsi
	push	rdi
	push	r13
	push	r15
	lea	rbp, QWORD PTR [r11-184]
	sub	rsp, 392				; 00000188H

; 133  :     const auto n=input.rows();

	mov	r13, QWORD PTR [rdx+16]
	mov	rbx, r9
	mov	QWORD PTR n$1$[rbp-256], r13
	mov	rdi, r8
	mov	rsi, rdx
	mov	r15, rcx

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
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 146  :     return a.rows() == b.rows() && a.cols() == b.cols();

	movq	rcx, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 134  :     if (n==0 || input.cols()!=n || !detail::same_shape(input,storage)) return StatusCode::invalid_shape;

	movups	xmm0, XMMWORD PTR [r8+32]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 146  :     return a.rows() == b.rows() && a.cols() == b.cols();

	movq	rax, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 134  :     if (n==0 || input.cols()!=n || !detail::same_shape(input,storage)) return StatusCode::invalid_shape;

	movaps	XMMWORD PTR $T5[rbp-256], xmm1
	movaps	XMMWORD PTR $T6[rbp-224], xmm0
	movups	xmm0, XMMWORD PTR [rdx+32]
	movaps	XMMWORD PTR $T5[rbp-224], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 146  :     return a.rows() == b.rows() && a.cols() == b.cols();

	cmp	rcx, rax
	jne	$LN36@factorize_
	psrldq	xmm3, 8
	psrldq	xmm2, 8
	movq	rcx, xmm3
	movq	rax, xmm2
	cmp	rcx, rax
	jne	$LN36@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 135  :     if (!detail::llt_is_finite(options.symmetry_tolerance) || options.symmetry_tolerance<0 || options.symmetry_tolerance>=1)

	movsd	xmm1, QWORD PTR [r9]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 146  :     return a.rows() == b.rows() && a.cols() == b.cols();

	movaps	XMMWORD PTR [r11-88], xmm6
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movaps	xmm0, xmm1
	movdqa	xmm6, XMMWORD PTR __xmm@7fffffffffffffff7fffffffffffffff
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 146  :     return a.rows() == b.rows() && a.cols() == b.cols();

	movaps	XMMWORD PTR [r11-216], xmm14
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	movsd	xmm14, QWORD PTR __real@7fefffffffffffff
	comisd	xmm14, xmm0
	movaps	XMMWORD PTR [r11-232], xmm15

; 135  :     if (!detail::llt_is_finite(options.symmetry_tolerance) || options.symmetry_tolerance<0 || options.symmetry_tolerance>=1)

	jb	$LN38@factorize_
	xorps	xmm15, xmm15
	comisd	xmm15, xmm1
	ja	$LN38@factorize_
	comisd	xmm1, QWORD PTR __real@3ff0000000000000
	jae	$LN38@factorize_

; 137  :     double scale=0;
; 138  :     if (options.check_symmetry && input.col_stride()==1) {

	mov	QWORD PTR [r11-56], r12
	xorps	xmm1, xmm1
	mov	QWORD PTR [r11-64], r14
	movaps	XMMWORD PTR [r11-104], xmm7
	movaps	XMMWORD PTR [r11-120], xmm8
	movaps	XMMWORD PTR [r11-136], xmm9
	movaps	XMMWORD PTR [r11-152], xmm10
	movaps	XMMWORD PTR [r11-168], xmm11
	movaps	XMMWORD PTR [r11-184], xmm12
	movaps	XMMWORD PTR [r11-200], xmm13
	movzx	r11d, BYTE PTR [r9+8]
	movsd	QWORD PTR scale$[rbp-256], xmm1
	test	r11b, r11b
	je	$LN511@factorize_
	cmp	QWORD PTR [rdx+40], 1
	jne	$LN511@factorize_

; 139  :         // The whole input, including the unused triangle, is still validated
; 140  :         // before storage is touched. Combine the finite and scale scans.
; 141  :         if (input.row_stride()==n) {

	mov	rax, QWORD PTR [rdx+32]
	cmp	rax, r13
	jne	SHORT $LN41@factorize_

; 142  :             if (!detail::finite_max_abs(&input(0,0),n*n,scale)) return StatusCode::non_finite_input;

	mov	rcx, QWORD PTR [rsi]
	lea	r8, QWORD PTR scale$[rbp-256]
	mov	rdx, r13
	imul	rdx, r13
	call	?finite_max_abs@detail@linalg@kibo@@YA_NPEBN_KAEAN@Z ; kibo::linalg::detail::finite_max_abs
	test	al, al
	je	$LN394@factorize_
	movsd	xmm1, QWORD PTR scale$[rbp-256]
	jmp	$LN516@factorize_
$LN41@factorize_:

; 144  :         for (std::size_t i=0;i<n;++i)

	xor	r9d, r9d
	test	r13, r13
	je	$LN516@factorize_
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rdx, QWORD PTR [rdx]
	lea	r11, QWORD PTR [rax*8]
	movdqa	xmm5, XMMWORD PTR __xmm@80000000000000008000000000000000
	xorps	xmm8, xmm8
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\detail\row_kernels.hpp

; 20   :     const auto sign=_mm_set1_pd(-0.0);

	movdqa	xmm7, XMMWORD PTR __xmm@7fefffffffffffff7fefffffffffffff
	xorps	xmm0, xmm0
	cmpeqpd	xmm8, xmm8
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	r10, QWORD PTR [rdx+32]
	npad	8
$LL4@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\detail\row_kernels.hpp

; 22   :     auto largest0=_mm_set1_pd(maximum);

	movaps	xmm2, xmm0
	xor	ecx, ecx
	unpcklpd xmm2, xmm2

; 23   :     auto valid0=_mm_cmpeq_pd(_mm_setzero_pd(),_mm_setzero_pd());

	movaps	xmm3, xmm8

; 24   :     auto largest1=_mm_set1_pd(maximum);

	movaps	xmm9, xmm2

; 25   :     auto valid1=_mm_cmpeq_pd(_mm_setzero_pd(),_mm_setzero_pd());
; 26   :     auto largest2=_mm_set1_pd(maximum);

	movaps	xmm10, xmm2

; 27   :     auto valid2=_mm_cmpeq_pd(_mm_setzero_pd(),_mm_setzero_pd());
; 28   :     auto largest3=_mm_set1_pd(maximum);

	movaps	xmm11, xmm2
	movaps	xmm4, xmm8
	movaps	xmm12, xmm8

; 29   :     auto valid3=_mm_cmpeq_pd(_mm_setzero_pd(),_mm_setzero_pd());

	movaps	xmm13, xmm8

; 30   :     for (;count-i>=8;i+=8) {

	cmp	r13, 8
	jb	$LN312@factorize_
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	r8, r10
	npad	14
$LL313@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\detail\row_kernels.hpp

; 31   :         const auto absolute0=_mm_andnot_pd(sign,_mm_loadu_pd(values+i+0));

	movups	xmm0, XMMWORD PTR [r8-32]
	lea	r8, QWORD PTR [r8+64]
	add	rcx, 8
	movaps	xmm1, xmm5
	mov	rax, r13
	andnps	xmm1, xmm0
	sub	rax, rcx

; 32   :         valid0=_mm_and_pd(valid0,_mm_cmple_pd(absolute0,limit));

	movaps	xmm0, xmm1
	cmplepd	xmm0, xmm7
	andps	xmm3, xmm0

; 33   :         largest0=_mm_max_pd(largest0,absolute0);
; 34   :         const auto absolute1=_mm_andnot_pd(sign,_mm_loadu_pd(values+i+2));

	movups	xmm0, XMMWORD PTR [r8-80]
	maxpd	xmm2, xmm1
	movaps	xmm1, xmm5
	andnps	xmm1, xmm0

; 35   :         valid1=_mm_and_pd(valid1,_mm_cmple_pd(absolute1,limit));

	movaps	xmm0, xmm1
	cmplepd	xmm0, xmm7
	andps	xmm4, xmm0

; 36   :         largest1=_mm_max_pd(largest1,absolute1);
; 37   :         const auto absolute2=_mm_andnot_pd(sign,_mm_loadu_pd(values+i+4));

	movups	xmm0, XMMWORD PTR [r8-64]
	maxpd	xmm9, xmm1
	movaps	xmm1, xmm5
	andnps	xmm1, xmm0

; 38   :         valid2=_mm_and_pd(valid2,_mm_cmple_pd(absolute2,limit));

	movaps	xmm0, xmm1
	cmplepd	xmm0, xmm7
	andps	xmm12, xmm0

; 39   :         largest2=_mm_max_pd(largest2,absolute2);
; 40   :         const auto absolute3=_mm_andnot_pd(sign,_mm_loadu_pd(values+i+6));

	movups	xmm0, XMMWORD PTR [r8-48]
	maxpd	xmm10, xmm1
	movaps	xmm1, xmm5
	andnps	xmm1, xmm0

; 41   :         valid3=_mm_and_pd(valid3,_mm_cmple_pd(absolute3,limit));

	movaps	xmm0, xmm1
	cmplepd	xmm0, xmm7
	andps	xmm13, xmm0

; 42   :         largest3=_mm_max_pd(largest3,absolute3);

	maxpd	xmm11, xmm1
	cmp	rax, 8
	jae	$LL313@factorize_
$LN312@factorize_:

; 43   :     }
; 44   :     for (;count-i>=2;i+=2) {

	mov	rax, r13
	sub	rax, rcx
	cmp	rax, 2
	jb	SHORT $LN315@factorize_
$LL316@factorize_:

; 45   :         const auto absolute=_mm_andnot_pd(sign,_mm_loadu_pd(values+i));

	movups	xmm0, XMMWORD PTR [rdx+rcx*8]
	add	rcx, 2
	mov	rax, r13
	movaps	xmm1, xmm5
	sub	rax, rcx
	andnps	xmm1, xmm0

; 46   :         valid0=_mm_and_pd(valid0,_mm_cmple_pd(absolute,limit));

	movaps	xmm0, xmm1
	cmplepd	xmm0, xmm7
	andps	xmm3, xmm0

; 47   :         largest0=_mm_max_pd(largest0,absolute);

	maxpd	xmm2, xmm1
	cmp	rax, 2
	jae	SHORT $LL316@factorize_
$LN315@factorize_:

; 48   :     }
; 49   :     valid0=_mm_and_pd(valid0,valid1);
; 50   :     largest0=_mm_max_pd(largest0,largest1);

	maxpd	xmm2, xmm9
	andps	xmm4, xmm3

; 51   :     valid0=_mm_and_pd(valid0,valid2);

	andps	xmm4, xmm12

; 52   :     largest0=_mm_max_pd(largest0,largest2);

	maxpd	xmm2, xmm10

; 53   :     valid0=_mm_and_pd(valid0,valid3);

	andps	xmm4, xmm13

; 54   :     largest0=_mm_max_pd(largest0,largest3);
; 55   :     if (_mm_movemask_pd(valid0)!=3) return false;

	movmskpd eax, xmm4
	maxpd	xmm2, xmm11
	cmp	eax, 3
	jne	$LN394@factorize_

; 56   :     maximum=std::max(_mm_cvtsd_f64(largest0),_mm_cvtsd_f64(_mm_unpackhi_pd(largest0,largest0)));

	movaps	xmm1, xmm2
	unpckhpd xmm1, xmm2
	maxsd	xmm1, xmm2
	movaps	xmm0, xmm1

; 57   : #endif
; 58   :     for (;i<count;++i) {

	cmp	rcx, r13
	jae	SHORT $LN318@factorize_
	movaps	xmm2, xmm1
	npad	9
$LL319@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rdx+rcx*8]
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\detail\row_kernels.hpp

; 59   :         if (!(std::abs(values[i])<=std::numeric_limits<double>::max())) return false;

	comisd	xmm14, xmm0
	jb	$LN394@factorize_

; 60   :         maximum=std::max(maximum,std::abs(values[i]));

	maxsd	xmm0, xmm2
	inc	rcx
	movaps	xmm1, xmm0
	movaps	xmm2, xmm0
	cmp	rcx, r13
	jb	SHORT $LL319@factorize_
$LN318@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 144  :         for (std::size_t i=0;i<n;++i)

	inc	r9
	add	rdx, r11
	add	r10, r11
	cmp	r9, r13
	jb	$LL4@factorize_
	jmp	$LN516@factorize_
$LN511@factorize_:

; 148  :         for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<n;++j)

	xor	r9d, r9d
	test	r13, r13
	je	SHORT $LN413@factorize_
	mov	rax, QWORD PTR [rdx+40]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r10, QWORD PTR [rsi+32]
	mov	r8, QWORD PTR [rsi]
	shl	r10, 3
	lea	rdx, QWORD PTR [rax*8]
	npad	5
$LL7@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 148  :         for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<n;++j)

	xor	ecx, ecx
	mov	rax, r8
	npad	11
$LL10@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rax]
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm14, xmm0

; 149  :             if (!detail::llt_is_finite(input(i,j))) return StatusCode::non_finite_input;

	jb	$LN394@factorize_

; 148  :         for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<n;++j)

	inc	rcx
	add	rax, rdx
	cmp	rcx, r13
	jb	SHORT $LL10@factorize_
	inc	r9
	add	r8, r10
	cmp	r9, r13
	jb	SHORT $LL7@factorize_
$LN413@factorize_:

; 150  :         if (options.check_symmetry) {

	test	r11b, r11b
	je	$LN414@factorize_

; 151  :             for (std::size_t i=0;i<n;++i)

	test	r13, r13
	je	$LN516@factorize_
	mov	rbx, QWORD PTR [rsi+40]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	xor	r14d, r14d
	mov	r15, QWORD PTR [rsi]
	mov	r12, r13
	lea	r8, QWORD PTR [rbx*8]
	npad	1
$LL13@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 152  :                 for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));

	xor	r11d, r11d
	cmp	r13, 4
	jb	$LC446@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	lea	rax, QWORD PTR [r14+rbx*2]
	mov	rdx, rbx
	lea	rcx, QWORD PTR [r15+rax*8]
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
	npad	2
$LL451@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rcx+rdx*8]
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 152  :                 for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));

	comisd	xmm0, xmm1
	jbe	SHORT $LN447@factorize_
	movaps	xmm1, xmm0
$LN447@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rcx+r10*8]
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 152  :                 for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));

	comisd	xmm0, xmm1
	jbe	SHORT $LN448@factorize_
	movaps	xmm1, xmm0
$LN448@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rcx]
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 152  :                 for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));

	comisd	xmm0, xmm1
	jbe	SHORT $LN449@factorize_
	movaps	xmm1, xmm0
$LN449@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rcx+r8]
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 152  :                 for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));

	comisd	xmm0, xmm1
	jbe	SHORT $LN450@factorize_
	movaps	xmm1, xmm0
$LN450@factorize_:
	add	rcx, r9
	sub	rax, 1
	jne	SHORT $LL451@factorize_
	cmp	r11, r13
	jae	SHORT $LN11@factorize_
$LC446@factorize_:
	mov	rax, rbx
	imul	rax, r11
	add	rax, r14
	lea	rcx, QWORD PTR [r15+rax*8]
	mov	rax, r13
	sub	rax, r11
$LC16@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rcx]
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

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

	add	r14, QWORD PTR [rsi+32]
	sub	r12, 1
	jne	$LL13@factorize_
	mov	r15, QWORD PTR __$ReturnUdt$[rbp-256]
	mov	rbx, QWORD PTR options$[rbp-256]
$LN516@factorize_:

; 153  :         }
; 154  :     }
; 155  :     if (options.check_symmetry) {
; 156  :         if (scale!=0) {

	ucomisd	xmm1, xmm15
	jp	SHORT $LN522@factorize_
	je	$LN414@factorize_
$LN522@factorize_:

; 157  :             for (std::size_t i=0;i<n;++i)

	xor	r10d, r10d
	test	r13, r13
	je	$LN414@factorize_
	movsd	xmm3, QWORD PTR [rbx]
	npad	7
$LL19@factorize_:

; 158  :                 for (std::size_t j=0;j<i;++j)

	xor	r8d, r8d
	test	r10, r10
	je	SHORT $LN17@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

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
	npad	13
$LL22@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 159  :                     if (input(i,j)!=input(j,i) &&

	movsd	xmm0, QWORD PTR [rax]
	movsd	xmm2, QWORD PTR [r9]
	ucomisd	xmm0, xmm2
	jp	SHORT $LN521@factorize_
	je	SHORT $LN20@factorize_
$LN521@factorize_:
	divsd	xmm0, xmm1
	divsd	xmm2, xmm1
	subsd	xmm0, xmm2
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 159  :                     if (input(i,j)!=input(j,i) &&

	comisd	xmm0, xmm3
	ja	$LN395@factorize_
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
$LN414@factorize_:

; 162  :         }
; 163  :     }
; 164  :     if constexpr (detail::row_simd_available) {
; 165  :         if (storage.col_stride()==1 && n>=9)

	mov	r10, QWORD PTR [rdi+40]
	cmp	r10, 1
	jne	$LN514@factorize_
	cmp	r13, 9
	jb	$LN514@factorize_

; 166  :             return detail::factorize_column_llt(input,storage);

	movups	xmm0, XMMWORD PTR [rdi]
	lea	r8, QWORD PTR $T4[rsp]
	mov	rcx, r15
	movups	xmm1, XMMWORD PTR [rdi+16]
	lea	rdx, QWORD PTR $T7[rbp-256]
	movaps	XMMWORD PTR $T4[rsp], xmm0
	movups	xmm0, XMMWORD PTR [rdi+32]
	movaps	XMMWORD PTR $T4[rsp+16], xmm1
	movups	xmm1, XMMWORD PTR [rsi]
	movaps	XMMWORD PTR $T4[rsp+32], xmm0
	movups	xmm0, XMMWORD PTR [rsi+16]
	movaps	XMMWORD PTR $T7[rbp-256], xmm1
	movups	xmm1, XMMWORD PTR [rsi+32]
	movaps	XMMWORD PTR $T7[rbp-240], xmm0
	movaps	XMMWORD PTR $T7[rbp-224], xmm1
	call	?factorize_column_llt@detail@linalg@kibo@@YA?AV?$Result@VLltFactorView@linalg@kibo@@@23@V?$MatrixView@$$CBN@23@V?$MatrixView@N@23@@Z ; kibo::linalg::detail::factorize_column_llt
	jmp	SHORT $LN606@factorize_
$LN394@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	mov	DWORD PTR [r15], 7
	mov	QWORD PTR [r15+8], 0
	mov	QWORD PTR [r15+16], 0
$LN607@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 166  :             return detail::factorize_column_llt(input,storage);

	mov	BYTE PTR [r15+72], 0
$LN606@factorize_:
	mov	rax, r15
$LN602@factorize_:
	mov	r12, QWORD PTR [rsp+384]
	movaps	xmm13, XMMWORD PTR [rsp+240]
	movaps	xmm12, XMMWORD PTR [rsp+256]
	movaps	xmm11, XMMWORD PTR [rsp+272]
	movaps	xmm10, XMMWORD PTR [rsp+288]
	movaps	xmm9, XMMWORD PTR [rsp+304]
	movaps	xmm8, XMMWORD PTR [rsp+320]
	movaps	xmm7, XMMWORD PTR [rsp+336]
	mov	r14, QWORD PTR [rsp+376]
$LN593@factorize_:
	movaps	xmm15, XMMWORD PTR [rsp+208]
	movaps	xmm6, XMMWORD PTR [rsp+352]
	movaps	xmm14, XMMWORD PTR [rsp+224]

; 185  : }

	add	rsp, 392				; 00000188H
	pop	r15
	pop	r13
	pop	rdi
	pop	rsi
	pop	rbx
	pop	rbp
	ret	0
$LN395@factorize_:

; 161  :                         return Status{StatusCode::invalid_argument,i};

	mov	DWORD PTR $T1[rsp], 3
	mov	QWORD PTR $T1[rsp+8], r10
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 38   :     Result(Status error) noexcept : status_(error) { assert(!error); }

	movups	xmm0, XMMWORD PTR $T1[rsp]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 161  :                         return Status{StatusCode::invalid_argument,i};

	mov	QWORD PTR $T1[rsp+16], 0
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 38   :     Result(Status error) noexcept : status_(error) { assert(!error); }

	movsd	xmm1, QWORD PTR $T1[rsp+16]
	movups	XMMWORD PTR [r15], xmm0
	movsd	QWORD PTR [r15+16], xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 161  :                         return Status{StatusCode::invalid_argument,i};

	jmp	$LN607@factorize_
$LN514@factorize_:

; 168  :     for (std::size_t i=0;i<n;++i) {

	xor	r14d, r14d
	test	r13, r13
	je	$LN416@factorize_
	mov	rax, QWORD PTR [rsi+40]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	xor	r8d, r8d
	shl	rax, 3
	mov	QWORD PTR tv4736[rbp-256], rax
	mov	rax, QWORD PTR [rsi+32]
	shl	rax, 3
	mov	QWORD PTR tv4673[rbp-256], rax
	mov	rax, QWORD PTR [rsi]
	mov	QWORD PTR tv4671[rsp], r10
$LN604@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 169  :         for (std::size_t j=0;j<=i;++j) {

	mov	QWORD PTR tv4674[rsp], rax
	xor	ebx, ebx
	mov	QWORD PTR tv4672[rbp-256], r8
	mov	r12, rax
	mov	QWORD PTR tv4703[rsp], rax
	npad	8
$LL28@factorize_:

; 170  :             double value=input(i,j);

	movsd	xmm2, QWORD PTR [r12]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	xor	r15d, r15d
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 171  :             for (std::size_t k=0;k<j;++k) value-=storage(i,k)*storage(j,k);

	cmp	rbx, 4
	jb	$LC453@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	rdx, QWORD PTR [rdi+40]
	mov	r12, QWORD PTR [rdi+32]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	r10, rdx
	mov	rcx, QWORD PTR [rdi]
	mov	rax, r12
	imul	rax, r14
	mov	r11, rdx
	shl	r10, 5
	add	rax, rdx
	mov	rsi, rdx
	add	r11, r11
	neg	rsi
	lea	rcx, QWORD PTR [rcx+rax*8]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	lea	rax, QWORD PTR [r8+rbx]
	mov	r9, rax
	imul	r9, r12
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	r8, QWORD PTR [r9*8]
	mov	QWORD PTR tv4693[rsp], r8
	lea	r8, QWORD PTR [r9+rdx]
	mov	QWORD PTR tv5230[rsp], r8
	lea	r8, QWORD PTR [r9+rdx*2]
	mov	r13, QWORD PTR tv5230[rsp]
	sub	r9, rdx
	mov	QWORD PTR tv5245[rbp-256], r8
	lea	r8, QWORD PTR [rax-4]
	mov	rax, QWORD PTR tv4693[rsp]
	add	r8, r14
	mov	rdi, QWORD PTR tv5245[rbp-256]
	shr	r8, 2
	inc	r8
	lea	r15, QWORD PTR [r8*4]
	npad	1
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

$LL454@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 171  :             for (std::size_t k=0;k<j;++k) value-=storage(i,k)*storage(j,k);

	movsd	xmm0, QWORD PTR [rcx+r9*8]
	mulsd	xmm0, QWORD PTR [rcx+rsi*8]
	movsd	xmm1, QWORD PTR [rcx+rax]
	mulsd	xmm1, QWORD PTR [rcx]
	subsd	xmm2, xmm0
	movsd	xmm0, QWORD PTR [rcx+rdx*8]
	mulsd	xmm0, QWORD PTR [rcx+r13*8]
	subsd	xmm2, xmm1
	movsd	xmm1, QWORD PTR [rcx+rdi*8]
	mulsd	xmm1, QWORD PTR [rcx+r11*8]
	add	rcx, r10
	subsd	xmm2, xmm0
	subsd	xmm2, xmm1
	sub	r8, 1
	jne	SHORT $LL454@factorize_
	mov	rdi, QWORD PTR storage$[rbp-256]
	mov	r13, QWORD PTR n$1$[rbp-256]
	cmp	r15, rbx
	jb	SHORT $LN526@factorize_
	jmp	SHORT $LN603@factorize_
$LC453@factorize_:
	test	rbx, rbx
	je	SHORT $LN452@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r12, QWORD PTR [rdi+32]
	mov	rdx, QWORD PTR [rdi+40]
$LN526@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 171  :             for (std::size_t k=0;k<j;++k) value-=storage(i,k)*storage(j,k);

	mov	rcx, QWORD PTR [rdi]
	lea	r8, QWORD PTR [rdx*8]
	imul	rdx, r15
	mov	rax, r12
	imul	rax, r14
	add	rdx, rax
	lea	rax, QWORD PTR [rcx+rdx*8]
	mov	rdx, QWORD PTR tv4672[rbp-256]
	add	rdx, rbx
	mov	rcx, rbx
	imul	rdx, r12
	sub	rcx, r15
$LC31@factorize_:
	movsd	xmm0, QWORD PTR [rax+rdx*8]
	mulsd	xmm0, QWORD PTR [rax]
	add	rax, r8
	subsd	xmm2, xmm0
	sub	rcx, 1
	jne	SHORT $LC31@factorize_
$LN603@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	mov	r12, QWORD PTR tv4703[rsp]
$LN452@factorize_:
	movaps	xmm0, xmm2
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm14, xmm0

; 172  :             if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	jb	$LN396@factorize_

; 173  :             if (i==j) {

	cmp	r14, rbx
	jne	SHORT $LN53@factorize_

; 174  :                 if (value<=0) return Status{StatusCode::non_positive_pivot,j};

	comisd	xmm15, xmm2
	jae	$LN397@factorize_
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rsi, QWORD PTR [rdi+32]
	xorps	xmm0, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 175  :                 storage(i,j)=std::sqrt(value);

	ucomisd	xmm0, xmm2
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	r15, QWORD PTR [rdi]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 175  :                 storage(i,j)=std::sqrt(value);

	ja	SHORT $LN519@factorize_
	xorps	xmm0, xmm0
	sqrtsd	xmm0, xmm2
	jmp	SHORT $LN520@factorize_
$LN519@factorize_:
	movaps	xmm0, xmm2
	call	sqrt
$LN520@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rcx, rsi
	mov	rax, rbx
	imul	rax, QWORD PTR [rdi+40]
	imul	rcx, r14
	add	rcx, rax
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 175  :                 storage(i,j)=std::sqrt(value);

	movsd	QWORD PTR [r15+rcx*8], xmm0

; 176  :             } else {

	jmp	SHORT $LN26@factorize_
$LN53@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	rcx, QWORD PTR [rdi+40]
	mov	rsi, QWORD PTR [rdi+32]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	r15, QWORD PTR [rdi]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	lea	rax, QWORD PTR [rsi+rcx]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	imul	rax, rbx
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 177  :                 value/=storage(j,j);

	divsd	xmm2, QWORD PTR [r15+rax*8]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movaps	xmm0, xmm2
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm14, xmm0

; 178  :                 if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	jb	$LN396@factorize_
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rax, rsi
	imul	rax, r14
	imul	rcx, rbx
	add	rax, rcx
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 179  :                 storage(i,j)=value;

	movsd	QWORD PTR [r15+rax*8], xmm2
$LN26@factorize_:

; 169  :         for (std::size_t j=0;j<=i;++j) {

	add	r12, QWORD PTR tv4736[rbp-256]
	inc	rbx
	mov	r8, QWORD PTR tv4672[rbp-256]
	mov	QWORD PTR tv4703[rsp], r12
	cmp	rbx, r14
	jbe	$LL28@factorize_

; 182  :         for (std::size_t j=i+1;j<n;++j) storage(i,j)=0;

	lea	r8, QWORD PTR [r14+1]
	cmp	r8, r13
	jae	$LN527@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r9, QWORD PTR tv4671[rsp]
	mov	rcx, r13
	mov	r10, QWORD PTR [rdi+40]
	imul	rsi, r14
	lea	rdx, QWORD PTR [r10*8]
	add	rsi, r9
	sub	rcx, r8
	lea	rax, QWORD PTR [r15+rsi*8]
	npad	13
$LL34@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 182  :         for (std::size_t j=i+1;j<n;++j) storage(i,j)=0;

	mov	QWORD PTR [rax], 0
	add	rax, rdx
	sub	rcx, 1
	jne	SHORT $LL34@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	rax, QWORD PTR tv4674[rsp]
	inc	r14
	add	rax, QWORD PTR tv4673[rbp-256]
	mov	r8, QWORD PTR tv4672[rbp-256]
	dec	r8
	add	r9, r10
	mov	QWORD PTR tv4671[rsp], r9
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 168  :     for (std::size_t i=0;i<n;++i) {

	jmp	$LN604@factorize_
$LN397@factorize_:

; 174  :                 if (value<=0) return Status{StatusCode::non_positive_pivot,j};

	mov	DWORD PTR $T3[rsp], 8
	jmp	SHORT $LN605@factorize_
$LN396@factorize_:

; 172  :             if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	mov	DWORD PTR $T2[rsp], 10
$LN605@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 38   :     Result(Status error) noexcept : status_(error) { assert(!error); }

	mov	rax, QWORD PTR __$ReturnUdt$[rbp-256]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 172  :             if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	mov	QWORD PTR $T2[rsp+8], rbx
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 38   :     Result(Status error) noexcept : status_(error) { assert(!error); }

	movups	xmm0, XMMWORD PTR $T2[rsp]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 172  :             if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	mov	QWORD PTR $T2[rsp+16], 0
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 38   :     Result(Status error) noexcept : status_(error) { assert(!error); }

	movsd	xmm1, QWORD PTR $T2[rsp+16]
	movups	XMMWORD PTR [rax], xmm0
	movsd	QWORD PTR [rax+16], xmm1
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\optional

; 77   :     constexpr _Optional_destruct_base() noexcept : _Dummy{}, _Has_value{false} {} // initialize an empty optional

	mov	BYTE PTR [rax+72], 0
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 172  :             if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	jmp	$LN602@factorize_
$LN527@factorize_:

; 182  :         for (std::size_t j=i+1;j<n;++j) storage(i,j)=0;

	mov	r15, QWORD PTR __$ReturnUdt$[rbp-256]
$LN416@factorize_:

; 184  :     return detail::LltAccess::create(storage);

	movups	xmm0, XMMWORD PTR [rdi]
	mov	DWORD PTR [r15], 0
	movups	xmm1, XMMWORD PTR [rdi+16]
	mov	QWORD PTR [r15+8], 0
	movups	xmm2, XMMWORD PTR [rdi+32]
	mov	QWORD PTR [r15+16], 0
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\optional

; 82   :         : _Value(_STD forward<_Types>(_Args)...), _Has_value{true} {} // initialize contained value with _Args...

	movq	QWORD PTR [r15+24], xmm0
	psrldq	xmm0, 8
	movq	QWORD PTR [r15+32], xmm0
	movq	QWORD PTR [r15+40], xmm1
	psrldq	xmm1, 8
	movq	QWORD PTR [r15+48], xmm1
	movq	QWORD PTR [r15+56], xmm2
	psrldq	xmm2, 8
	movq	QWORD PTR [r15+64], xmm2
	mov	BYTE PTR [r15+72], 1
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 184  :     return detail::LltAccess::create(storage);

	jmp	$LN606@factorize_
$LN38@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	xor	eax, eax
	mov	DWORD PTR [r15], 3
	mov	QWORD PTR [r15+8], rax
	mov	QWORD PTR [r15+16], rax
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\optional

; 77   :     constexpr _Optional_destruct_base() noexcept : _Dummy{}, _Has_value{false} {} // initialize an empty optional

	mov	BYTE PTR [r15+72], al
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 136  :         return StatusCode::invalid_argument;

	mov	rax, r15
	jmp	$LN593@factorize_
$LN36@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	xor	eax, eax
	mov	DWORD PTR [r15], 1
	mov	QWORD PTR [r15+8], rax
	mov	QWORD PTR [r15+16], rax
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\optional

; 77   :     constexpr _Optional_destruct_base() noexcept : _Dummy{}, _Has_value{false} {} // initialize an empty optional

	mov	BYTE PTR [r15+72], al
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 134  :     if (n==0 || input.cols()!=n || !detail::same_shape(input,storage)) return StatusCode::invalid_shape;

	mov	rax, r15

; 185  : }

	add	rsp, 392				; 00000188H
	pop	r15
	pop	r13
	pop	rdi
	pop	rsi
	pop	rbx
	pop	rbp
	ret	0
?factorize_llt@linalg@kibo@@YA?AV?$Result@VLltFactorView@linalg@kibo@@@12@V?$MatrixView@$$CBN@12@V?$MatrixView@N@12@ULltOptions@12@@Z ENDP ; kibo::linalg::factorize_llt