?factorize_llt@linalg@kibo@@YA?AV?$Result@VLltFactorView@linalg@kibo@@@12@V?$MatrixView@$$CBN@12@V?$MatrixView@N@12@ULltOptions@12@@Z PROC ; kibo::linalg::factorize_llt, COMDAT

; 132  :                                          LltOptions options={}) noexcept {

$LN572:
	mov	r11, rsp
	mov	QWORD PTR [r11+32], r9
	mov	QWORD PTR [r11+24], r8
	mov	QWORD PTR [r11+16], rdx
	mov	QWORD PTR [r11+8], rcx
	push	rbp
	push	rbx
	push	rsi
	push	r13
	push	r14
	push	r15
	lea	rbp, QWORD PTR [r11-72]
	sub	rsp, 280				; 00000118H

; 133  :     const auto n=input.rows();

	mov	r13, QWORD PTR [rdx+16]
	mov	rbx, r9
	mov	r14, r8
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
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 146  :     return a.rows() == b.rows() && a.cols() == b.cols();

	movq	rcx, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 134  :     if (n==0 || input.cols()!=n || !detail::same_shape(input,storage)) return StatusCode::invalid_shape;

	movups	xmm0, XMMWORD PTR [r8+32]
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 146  :     return a.rows() == b.rows() && a.cols() == b.cols();

	movq	rax, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 134  :     if (n==0 || input.cols()!=n || !detail::same_shape(input,storage)) return StatusCode::invalid_shape;

	movaps	XMMWORD PTR $T5[rbp-256], xmm1
	movaps	XMMWORD PTR $T6[rbp-224], xmm0
	movups	xmm0, XMMWORD PTR [rdx+32]
	movaps	XMMWORD PTR $T5[rbp-224], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 146  :     return a.rows() == b.rows() && a.cols() == b.cols();

	cmp	rcx, rax
	jne	$LN36@factorize_
	psrldq	xmm3, 8
	psrldq	xmm2, 8
	movq	rcx, xmm3
	movq	rax, xmm2
	cmp	rcx, rax
	jne	$LN36@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 135  :     if (!detail::llt_is_finite(options.symmetry_tolerance) || options.symmetry_tolerance<0 || options.symmetry_tolerance>=1)

	movsd	xmm1, QWORD PTR [r9]
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 146  :     return a.rows() == b.rows() && a.cols() == b.cols();

	movaps	XMMWORD PTR [r11-88], xmm6
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movaps	xmm0, xmm1
	movdqa	xmm6, XMMWORD PTR __xmm@7fffffffffffffff7fffffffffffffff
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 146  :     return a.rows() == b.rows() && a.cols() == b.cols();

	movaps	XMMWORD PTR [r11-120], xmm8
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	movsd	xmm8, QWORD PTR __real@7fefffffffffffff
	comisd	xmm8, xmm0
	movaps	XMMWORD PTR [r11-136], xmm9

; 135  :     if (!detail::llt_is_finite(options.symmetry_tolerance) || options.symmetry_tolerance<0 || options.symmetry_tolerance>=1)

	jb	$LN38@factorize_
	xorps	xmm9, xmm9
	comisd	xmm9, xmm1
	ja	$LN38@factorize_
	comisd	xmm1, QWORD PTR __real@3ff0000000000000
	jae	$LN38@factorize_

; 137  :     double scale=0;
; 138  :     if (options.check_symmetry && input.col_stride()==1) {

	mov	QWORD PTR [r11-56], rdi
	xorps	xmm1, xmm1
	mov	QWORD PTR [r11-64], r12
	lea	rdi, QWORD PTR [rdx+40]
	movaps	XMMWORD PTR [r11-104], xmm7
	movzx	r11d, BYTE PTR [r9+8]
	test	r11b, r11b
	je	$LN435@factorize_
	cmp	QWORD PTR [rdi], 1
	jne	$LN435@factorize_

; 141  :         for (std::size_t i=0;i<n;++i)

	xor	r8d, r8d
	test	r13, r13
	je	$LN487@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r9, QWORD PTR [rdx+32]
	xorps	xmm7, xmm7
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\detail\row_kernels.hpp

; 20   :     const auto sign=_mm_set1_pd(-0.0);

	movdqa	xmm4, XMMWORD PTR __xmm@80000000000000008000000000000000
	movdqa	xmm5, XMMWORD PTR __xmm@7fefffffffffffff7fefffffffffffff
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	rdx, QWORD PTR [rdx]
	cmpeqpd	xmm7, xmm7
	shl	r9, 3
	npad	12
$LL4@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\detail\row_kernels.hpp

; 18   :     std::size_t i=0;

	xor	ecx, ecx

; 21   :     const auto limit=_mm_set1_pd(std::numeric_limits<double>::max());
; 22   :     auto largest=_mm_set1_pd(maximum);

	movaps	xmm2, xmm1
	unpcklpd xmm2, xmm2

; 23   :     auto valid=_mm_cmpeq_pd(_mm_setzero_pd(),_mm_setzero_pd());

	movaps	xmm3, xmm7

; 24   :     for (;count-i>=2;i+=2) {

	cmp	r13, 2
	jb	SHORT $LN309@factorize_
$LL310@factorize_:

; 25   :         const auto absolute=_mm_andnot_pd(sign,_mm_loadu_pd(values+i));

	movups	xmm0, XMMWORD PTR [rdx+rcx*8]
	add	rcx, 2
	mov	rax, r13
	movaps	xmm1, xmm4
	sub	rax, rcx
	andnps	xmm1, xmm0

; 26   :         valid=_mm_and_pd(valid,_mm_cmple_pd(absolute,limit));

	movaps	xmm0, xmm1
	cmplepd	xmm0, xmm5
	andps	xmm3, xmm0

; 27   :         largest=_mm_max_pd(largest,absolute);

	maxpd	xmm2, xmm1
	cmp	rax, 2
	jae	SHORT $LL310@factorize_
$LN309@factorize_:

; 28   :     }
; 29   :     if (_mm_movemask_pd(valid)!=3) return false;

	movmskpd eax, xmm3
	cmp	eax, 3
	jne	$LN369@factorize_

; 30   :     maximum=std::max(_mm_cvtsd_f64(largest),_mm_cvtsd_f64(_mm_unpackhi_pd(largest,largest)));

	movaps	xmm1, xmm2
	unpckhpd xmm1, xmm2
	maxsd	xmm1, xmm2

; 31   : #endif
; 32   :     for (;i<count;++i) {

	cmp	rcx, r13
	jae	SHORT $LN312@factorize_
	movaps	xmm2, xmm1
	npad	5
$LL313@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rdx+rcx*8]
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\detail\row_kernels.hpp

; 33   :         if (!(std::abs(values[i])<=std::numeric_limits<double>::max())) return false;

	comisd	xmm8, xmm0
	jb	$LN369@factorize_

; 34   :         maximum=std::max(maximum,std::abs(values[i]));

	maxsd	xmm0, xmm2
	inc	rcx
	movaps	xmm2, xmm0
	movaps	xmm1, xmm0
	cmp	rcx, r13
	jb	SHORT $LL313@factorize_
$LN312@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 141  :         for (std::size_t i=0;i<n;++i)

	inc	r8
	add	rdx, r9
	cmp	r8, r13
	jb	$LL4@factorize_

; 174  :                 if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	lea	rdi, QWORD PTR [rsi+40]
	jmp	$LN487@factorize_
$LN435@factorize_:

; 144  :         for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<n;++j)

	xor	r9d, r9d
	test	r13, r13
	je	SHORT $LN387@factorize_
	mov	rax, QWORD PTR [rdi]
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r10, QWORD PTR [rsi+32]
	mov	r8, QWORD PTR [rsi]
	shl	r10, 3
	lea	rdx, QWORD PTR [rax*8]
	npad	5
$LL7@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 144  :         for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<n;++j)

	xor	ecx, ecx
	mov	rax, r8
	npad	11
$LL10@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rax]
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm8, xmm0

; 145  :             if (!detail::llt_is_finite(input(i,j))) return StatusCode::non_finite_input;

	jb	$LN369@factorize_

; 144  :         for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<n;++j)

	inc	rcx
	add	rax, rdx
	cmp	rcx, r13
	jb	SHORT $LL10@factorize_
	inc	r9
	add	r8, r10
	cmp	r9, r13
	jb	SHORT $LL7@factorize_
	lea	rdi, QWORD PTR [rsi+40]
$LN387@factorize_:

; 146  :         if (options.check_symmetry) {

	test	r11b, r11b
	je	$LN388@factorize_

; 147  :             for (std::size_t i=0;i<n;++i)

	test	r13, r13
	je	$LN12@factorize_
	mov	rbx, QWORD PTR [rdi]
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r15, r13
	mov	r12, QWORD PTR [rsi]
	xor	edi, edi
	lea	r8, QWORD PTR [rbx*8]
$LL13@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 148  :                 for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));

	xor	r11d, r11d
	cmp	r13, 4
	jb	$LC418@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

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
	npad	1
$LL423@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rcx+rdx*8]
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 148  :                 for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));

	comisd	xmm0, xmm1
	jbe	SHORT $LN419@factorize_
	movaps	xmm1, xmm0
$LN419@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rcx+r10*8]
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 148  :                 for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));

	comisd	xmm0, xmm1
	jbe	SHORT $LN420@factorize_
	movaps	xmm1, xmm0
$LN420@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rcx]
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 148  :                 for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));

	comisd	xmm0, xmm1
	jbe	SHORT $LN421@factorize_
	movaps	xmm1, xmm0
$LN421@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rcx+r8]
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 148  :                 for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));

	comisd	xmm0, xmm1
	jbe	SHORT $LN422@factorize_
	movaps	xmm1, xmm0
$LN422@factorize_:
	add	rcx, r9
	sub	rax, 1
	jne	SHORT $LL423@factorize_
	cmp	r11, r13
	jae	SHORT $LN11@factorize_
$LC418@factorize_:
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
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 148  :                 for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));

	comisd	xmm0, xmm1
	jbe	SHORT $LN14@factorize_
	movaps	xmm1, xmm0
$LN14@factorize_:
	add	rcx, r8
	sub	rax, 1
	jne	SHORT $LC16@factorize_
$LN11@factorize_:

; 147  :             for (std::size_t i=0;i<n;++i)

	add	rdi, QWORD PTR [rsi+32]
	sub	r15, 1
	jne	$LL13@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r15, QWORD PTR __$ReturnUdt$[rbp-256]
	lea	rdi, QWORD PTR [rsi+40]
	mov	rbx, QWORD PTR options$[rbp-256]
	jmp	SHORT $LN487@factorize_
$LN369@factorize_:

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	mov	DWORD PTR [r15], 7
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 145  :             if (!detail::llt_is_finite(input(i,j))) return StatusCode::non_finite_input;

	mov	rax, r15
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	mov	QWORD PTR [r15+8], 0
	mov	QWORD PTR [r15+16], 0
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\optional

; 77   :     constexpr _Optional_destruct_base() noexcept : _Dummy{}, _Has_value{false} {} // initialize an empty optional

	mov	BYTE PTR [r15+72], 0
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 145  :             if (!detail::llt_is_finite(input(i,j))) return StatusCode::non_finite_input;

	jmp	$LN564@factorize_
$LN12@factorize_:

; 149  :         }
; 150  :     }
; 151  :     if (options.check_symmetry) {

	test	r11b, r11b
	je	$LN388@factorize_
$LN487@factorize_:

; 152  :         if (scale!=0) {

	ucomisd	xmm1, xmm9
	jp	SHORT $LN493@factorize_
	je	$LN388@factorize_
$LN493@factorize_:

; 153  :             for (std::size_t i=0;i<n;++i)

	xor	r10d, r10d
	test	r13, r13
	je	$LN388@factorize_
	movsd	xmm3, QWORD PTR [rbx]
$LL19@factorize_:

; 154  :                 for (std::size_t j=0;j<i;++j)

	xor	r8d, r8d
	test	r10, r10
	je	SHORT $LN17@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	rax, QWORD PTR [rdi]
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
	npad	8
$LL22@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 155  :                     if (input(i,j)!=input(j,i) &&

	movsd	xmm0, QWORD PTR [rax]
	movsd	xmm2, QWORD PTR [r9]
	ucomisd	xmm0, xmm2
	jp	SHORT $LN492@factorize_
	je	SHORT $LN20@factorize_
$LN492@factorize_:
	divsd	xmm0, xmm1
	divsd	xmm2, xmm1
	subsd	xmm0, xmm2
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 155  :                     if (input(i,j)!=input(j,i) &&

	comisd	xmm0, xmm3
	ja	SHORT $LN370@factorize_
$LN20@factorize_:

; 154  :                 for (std::size_t j=0;j<i;++j)

	inc	r8
	add	rax, rbx
	add	r9, r11
	cmp	r8, r10
	jb	SHORT $LL22@factorize_
$LN17@factorize_:

; 153  :             for (std::size_t i=0;i<n;++i)

	inc	r10
	cmp	r10, r13
	jb	SHORT $LL19@factorize_
$LN388@factorize_:

; 158  :         }
; 159  :     }
; 160  :     if constexpr (detail::row_simd_available) {
; 161  :         if (storage.col_stride()==1 && n>=9)

	mov	r10, QWORD PTR [r14+40]
	cmp	r10, 1
	jne	$LN485@factorize_
	cmp	r13, 9
	jb	$LN485@factorize_

; 162  :             return detail::factorize_column_llt(input,storage);

	movups	xmm0, XMMWORD PTR [r14]
	lea	r8, QWORD PTR $T4[rsp]
	mov	rcx, r15
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
	mov	rax, r15
	jmp	$LN564@factorize_
$LN370@factorize_:

; 157  :                         return Status{StatusCode::invalid_argument,i};

	mov	DWORD PTR $T1[rsp], 3
	mov	rax, r15
	mov	QWORD PTR $T1[rsp+8], r10
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 38   :     Result(Status error) noexcept : status_(error) { assert(!error); }

	movups	xmm0, XMMWORD PTR $T1[rsp]
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 157  :                         return Status{StatusCode::invalid_argument,i};

	mov	QWORD PTR $T1[rsp+16], 0
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 38   :     Result(Status error) noexcept : status_(error) { assert(!error); }

	movsd	xmm1, QWORD PTR $T1[rsp+16]
	movups	XMMWORD PTR [r15], xmm0
	movsd	QWORD PTR [r15+16], xmm1
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\optional

; 77   :     constexpr _Optional_destruct_base() noexcept : _Dummy{}, _Has_value{false} {} // initialize an empty optional

	mov	BYTE PTR [r15+72], 0
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 157  :                         return Status{StatusCode::invalid_argument,i};

	jmp	$LN564@factorize_
$LN485@factorize_:

; 164  :     for (std::size_t i=0;i<n;++i) {

	xor	r15d, r15d
	test	r13, r13
	je	$LN390@factorize_
	mov	rax, QWORD PTR [rsi+40]
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	xor	r8d, r8d
	shl	rax, 3
	mov	QWORD PTR tv4279[rbp-256], rax
	mov	rax, QWORD PTR [rsi+32]
	shl	rax, 3
	mov	QWORD PTR tv4217[rbp-256], rax
	mov	rax, QWORD PTR [rsi]
	mov	QWORD PTR tv4214[rsp], r10
$LN567@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 165  :         for (std::size_t j=0;j<=i;++j) {

	mov	QWORD PTR tv4218[rsp], rax
	xor	ebx, ebx
	mov	QWORD PTR tv4216[rsp], r8
	mov	r12, rax
	mov	QWORD PTR tv4247[rsp], rax
	npad	4
$LL28@factorize_:

; 166  :             double value=input(i,j);

	movsd	xmm2, QWORD PTR [r12]
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	xor	r10d, r10d
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 167  :             for (std::size_t k=0;k<j;++k) value-=storage(i,k)*storage(j,k);

	cmp	rbx, 4
	jb	$LC425@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	rdx, QWORD PTR [r14+40]
	mov	r12, QWORD PTR [r14+32]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	r11, rdx
	mov	rcx, QWORD PTR [r14]
	mov	rax, r12
	imul	rax, r15
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

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
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	lea	rax, QWORD PTR [r8+rbx]
	imul	r9, rax
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	r8, QWORD PTR [rdx+r9]
	mov	QWORD PTR tv4717[rsp], r8
	lea	r13, QWORD PTR [r9*8]
	lea	r8, QWORD PTR [r9+rdx*2]
	sub	r9, rdx
	mov	QWORD PTR tv4729[rsp], r8
	lea	r8, QWORD PTR [rax-4]
	mov	rax, QWORD PTR tv4717[rsp]
	add	r8, r15
	mov	r14, QWORD PTR tv4729[rsp]
	shr	r8, 2
	inc	r8
	lea	r10, QWORD PTR [r8*4]
	npad	9
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

$LL426@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 167  :             for (std::size_t k=0;k<j;++k) value-=storage(i,k)*storage(j,k);

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
	jne	SHORT $LL426@factorize_
	mov	r14, QWORD PTR storage$[rbp-256]
	cmp	r10, rbx
	jb	SHORT $LN496@factorize_
	jmp	SHORT $LN566@factorize_
$LC425@factorize_:
	test	rbx, rbx
	je	SHORT $LN424@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r12, QWORD PTR [r14+32]
	mov	rdx, QWORD PTR [r14+40]
$LN496@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 167  :             for (std::size_t k=0;k<j;++k) value-=storage(i,k)*storage(j,k);

	mov	rcx, QWORD PTR [r14]
	lea	r8, QWORD PTR [rdx*8]
	imul	rdx, r10
	mov	rax, r12
	imul	rax, r15
	add	rdx, rax
	lea	rax, QWORD PTR [rcx+rdx*8]
	mov	rdx, QWORD PTR tv4216[rsp]
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
$LN566@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	mov	r12, QWORD PTR tv4247[rsp]
$LN424@factorize_:
	movaps	xmm0, xmm2
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm8, xmm0

; 168  :             if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	jb	$LN371@factorize_

; 169  :             if (i==j) {

	cmp	r15, rbx
	jne	SHORT $LN50@factorize_

; 170  :                 if (value<=0) return Status{StatusCode::non_positive_pivot,j};

	comisd	xmm9, xmm2
	jae	$LN372@factorize_
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rdi, QWORD PTR [r14+32]
	xorps	xmm0, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 171  :                 storage(i,j)=std::sqrt(value);

	ucomisd	xmm0, xmm2
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rsi, QWORD PTR [r14]
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 171  :                 storage(i,j)=std::sqrt(value);

	ja	SHORT $LN490@factorize_
	xorps	xmm0, xmm0
	sqrtsd	xmm0, xmm2
	jmp	SHORT $LN491@factorize_
$LN490@factorize_:
	movaps	xmm0, xmm2
	call	sqrt
$LN491@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rcx, rbx
	mov	rax, rdi
	imul	rcx, QWORD PTR [r14+40]
	imul	rax, r15
	add	rcx, rax
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 171  :                 storage(i,j)=std::sqrt(value);

	movsd	QWORD PTR [rsi+rcx*8], xmm0

; 172  :             } else {

	jmp	SHORT $LN26@factorize_
$LN50@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	rcx, QWORD PTR [r14+40]
	mov	rdi, QWORD PTR [r14+32]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rsi, QWORD PTR [r14]
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	lea	rax, QWORD PTR [rdi+rcx]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	imul	rax, rbx
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 173  :                 value/=storage(j,j);

	divsd	xmm2, QWORD PTR [rsi+rax*8]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movaps	xmm0, xmm2
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm8, xmm0

; 174  :                 if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	jb	$LN371@factorize_
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rax, rdi
	imul	rax, r15
	imul	rcx, rbx
	add	rax, rcx
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 175  :                 storage(i,j)=value;

	movsd	QWORD PTR [rsi+rax*8], xmm2
$LN26@factorize_:

; 165  :         for (std::size_t j=0;j<=i;++j) {

	add	r12, QWORD PTR tv4279[rbp-256]
	inc	rbx
	mov	r8, QWORD PTR tv4216[rsp]
	mov	QWORD PTR tv4247[rsp], r12
	cmp	rbx, r15
	jbe	$LL28@factorize_

; 178  :         for (std::size_t j=i+1;j<n;++j) storage(i,j)=0;

	mov	rax, QWORD PTR input$[rbp-256]
	lea	r8, QWORD PTR [r15+1]
	mov	r13, QWORD PTR [rax+16]
	cmp	r8, r13
	jae	$LN390@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r9, QWORD PTR tv4214[rsp]
	mov	rcx, r13
	mov	r10, QWORD PTR [r14+40]
	imul	rdi, r15
	lea	rdx, QWORD PTR [r10*8]
	add	rdi, r9
	sub	rcx, r8
	lea	rax, QWORD PTR [rsi+rdi*8]
	npad	3
$LL34@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 178  :         for (std::size_t j=i+1;j<n;++j) storage(i,j)=0;

	mov	QWORD PTR [rax], 0
	add	rax, rdx
	sub	rcx, 1
	jne	SHORT $LL34@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	rax, QWORD PTR tv4218[rsp]
	inc	r15
	add	rax, QWORD PTR tv4217[rbp-256]
	mov	r8, QWORD PTR tv4216[rsp]
	dec	r8
	add	r9, r10
	mov	QWORD PTR tv4214[rsp], r9
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 164  :     for (std::size_t i=0;i<n;++i) {

	jmp	$LN567@factorize_
$LN372@factorize_:

; 170  :                 if (value<=0) return Status{StatusCode::non_positive_pivot,j};

	mov	DWORD PTR $T3[rsp], 8
	jmp	SHORT $LN568@factorize_
$LN371@factorize_:

; 168  :             if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	mov	DWORD PTR $T2[rsp], 10
$LN568@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 38   :     Result(Status error) noexcept : status_(error) { assert(!error); }

	mov	rcx, QWORD PTR __$ReturnUdt$[rbp-256]
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 168  :             if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	mov	QWORD PTR $T2[rsp+8], rbx
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 38   :     Result(Status error) noexcept : status_(error) { assert(!error); }

	movups	xmm0, XMMWORD PTR $T2[rsp]
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 168  :             if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	mov	QWORD PTR $T2[rsp+16], 0
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 38   :     Result(Status error) noexcept : status_(error) { assert(!error); }

	movsd	xmm1, QWORD PTR $T2[rsp+16]
	movups	XMMWORD PTR [rcx], xmm0
	movsd	QWORD PTR [rcx+16], xmm1
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\optional

; 77   :     constexpr _Optional_destruct_base() noexcept : _Dummy{}, _Has_value{false} {} // initialize an empty optional

	mov	BYTE PTR [rcx+72], 0
$LN569@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 168  :             if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	mov	rax, rcx
$LN564@factorize_:
	mov	rdi, QWORD PTR [rsp+272]
	movaps	xmm7, XMMWORD PTR [rsp+224]
	mov	r12, QWORD PTR [rsp+264]
$LN561@factorize_:
	movaps	xmm9, XMMWORD PTR [rsp+192]
	movaps	xmm6, XMMWORD PTR [rsp+240]
	movaps	xmm8, XMMWORD PTR [rsp+208]

; 181  : }

	add	rsp, 280				; 00000118H
	pop	r15
	pop	r14
	pop	r13
	pop	rsi
	pop	rbx
	pop	rbp
	ret	0
$LN390@factorize_:
	mov	rcx, QWORD PTR __$ReturnUdt$[rbp-256]

; 180  :     return detail::LltAccess::create(storage);

	movups	xmm0, XMMWORD PTR [r14]
	movups	xmm1, XMMWORD PTR [r14+16]
	mov	DWORD PTR [rcx], 0
	movups	xmm2, XMMWORD PTR [r14+32]
	mov	QWORD PTR [rcx+8], 0
	mov	QWORD PTR [rcx+16], 0
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
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 180  :     return detail::LltAccess::create(storage);

	jmp	$LN569@factorize_
$LN38@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	xor	eax, eax
	mov	DWORD PTR [r15], 3
	mov	QWORD PTR [r15+8], rax
	mov	QWORD PTR [r15+16], rax
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\optional

; 77   :     constexpr _Optional_destruct_base() noexcept : _Dummy{}, _Has_value{false} {} // initialize an empty optional

	mov	BYTE PTR [r15+72], al
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 136  :         return StatusCode::invalid_argument;

	mov	rax, r15
	jmp	$LN561@factorize_
$LN36@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\linalg.hpp

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	xor	eax, eax
	mov	DWORD PTR [r15], 1
	mov	QWORD PTR [r15+8], rax
	mov	QWORD PTR [r15+16], rax
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\optional

; 77   :     constexpr _Optional_destruct_base() noexcept : _Dummy{}, _Has_value{false} {} // initialize an empty optional

	mov	BYTE PTR [r15+72], al
; File C:\Users\owner\Documents\git\kibo-linalg\include\kibo\llt.hpp

; 134  :     if (n==0 || input.cols()!=n || !detail::same_shape(input,storage)) return StatusCode::invalid_shape;

	mov	rax, r15

; 181  : }

	add	rsp, 280				; 00000118H
	pop	r15
	pop	r14
	pop	r13
	pop	rsi
	pop	rbx
	pop	rbp
	ret	0
?factorize_llt@linalg@kibo@@YA?AV?$Result@VLltFactorView@linalg@kibo@@@12@V?$MatrixView@$$CBN@12@V?$MatrixView@N@12@ULltOptions@12@@Z ENDP ; kibo::linalg::factorize_llt