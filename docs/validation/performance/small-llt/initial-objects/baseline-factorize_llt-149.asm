?factorize_llt@linalg@kibo@@YA?AV?$Result@VLltFactorView@linalg@kibo@@@12@V?$MatrixView@$$CBN@12@V?$MatrixView@N@12@ULltOptions@12@@Z PROC ; kibo::linalg::factorize_llt, COMDAT

; 100  :                                          LltOptions options={}) noexcept {

$LN570:
	mov	QWORD PTR [rsp+32], r9
	mov	QWORD PTR [rsp+24], r8
	mov	QWORD PTR [rsp+16], rdx
	mov	QWORD PTR [rsp+8], rcx
	push	rbp
	push	rdi
	push	r13
	push	r14
	lea	rbp, QWORD PTR [rsp-120]
	sub	rsp, 376				; 00000178H
	mov	r11, r9
	mov	r14, r8

; 101  :     const auto n=input.rows();

	mov	r9, QWORD PTR [rdx+16]
	mov	r13, rdx
	mov	QWORD PTR n$1$[rsp], r9
	mov	r8, rcx

; 102  :     if (n==0 || input.cols()!=n || !detail::same_shape(input,storage)) return StatusCode::invalid_shape;

	test	r9, r9
	je	$LN30@factorize_
	cmp	QWORD PTR [rdx+24], r9
	jne	$LN30@factorize_
	movups	xmm0, XMMWORD PTR [r14]
	movups	xmm2, XMMWORD PTR [r14+16]
	movups	xmm3, XMMWORD PTR [rdx+16]
	movups	xmm1, XMMWORD PTR [rdx]
	movaps	XMMWORD PTR $T8[rbp-256], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 146  :     return a.rows() == b.rows() && a.cols() == b.cols();

	movq	rcx, xmm3
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 102  :     if (n==0 || input.cols()!=n || !detail::same_shape(input,storage)) return StatusCode::invalid_shape;

	movups	xmm0, XMMWORD PTR [r14+32]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 146  :     return a.rows() == b.rows() && a.cols() == b.cols();

	movq	rax, xmm2
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 102  :     if (n==0 || input.cols()!=n || !detail::same_shape(input,storage)) return StatusCode::invalid_shape;

	movaps	XMMWORD PTR $T7[rbp-256], xmm1
	movaps	XMMWORD PTR $T8[rbp-224], xmm0
	movups	xmm0, XMMWORD PTR [rdx+32]
	movaps	XMMWORD PTR $T7[rbp-224], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 146  :     return a.rows() == b.rows() && a.cols() == b.cols();

	cmp	rcx, rax
	jne	$LN30@factorize_
	psrldq	xmm3, 8
	psrldq	xmm2, 8
	movq	rcx, xmm3
	movq	rax, xmm2
	cmp	rcx, rax
	jne	$LN30@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 103  :     if (!detail::llt_is_finite(options.symmetry_tolerance) || options.symmetry_tolerance<0 || options.symmetry_tolerance>=1)

	movsd	xmm1, QWORD PTR [r11]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 146  :     return a.rows() == b.rows() && a.cols() == b.cols();

	movaps	XMMWORD PTR [rsp+304], xmm7
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movaps	xmm0, xmm1
	movdqa	xmm7, XMMWORD PTR __xmm@7fffffffffffffff7fffffffffffffff
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 146  :     return a.rows() == b.rows() && a.cols() == b.cols();

	movaps	XMMWORD PTR [rsp+224], xmm12
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	andps	xmm0, xmm7
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	movsd	xmm12, QWORD PTR __real@7fefffffffffffff
	comisd	xmm12, xmm0
	movaps	XMMWORD PTR [rsp+208], xmm13

; 103  :     if (!detail::llt_is_finite(options.symmetry_tolerance) || options.symmetry_tolerance<0 || options.symmetry_tolerance>=1)

	jb	$LN32@factorize_
	xorps	xmm13, xmm13
	comisd	xmm13, xmm1
	ja	$LN32@factorize_
	comisd	xmm1, QWORD PTR __real@3ff0000000000000
	jae	$LN32@factorize_

; 105  :     double scale=0;
; 106  :     if (options.check_symmetry && input.col_stride()==1 && n>=32) {

	cmp	BYTE PTR [r11+8], 0
	movaps	XMMWORD PTR [rsp+320], xmm6
	xorps	xmm6, xmm6
	mov	QWORD PTR [rsp+368], rbx
	mov	QWORD PTR [rsp+360], rsi
	mov	QWORD PTR [rsp+352], r12
	mov	QWORD PTR [rsp+344], r15
	movaps	XMMWORD PTR [rsp+288], xmm8
	movaps	XMMWORD PTR [rsp+272], xmm9
	movaps	XMMWORD PTR [rsp+256], xmm10
	movaps	XMMWORD PTR [rsp+240], xmm11
	je	$LN33@factorize_
	cmp	QWORD PTR [rdx+40], 1
	jne	$LN33@factorize_
	cmp	r9, 32					; 00000020H
	jb	$LN33@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r12, QWORD PTR [rdx+32]
	xorps	xmm9, xmm9
	mov	rdi, QWORD PTR [rdx]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\detail\row_kernels.hpp

; 18   :     std::size_t i=0;

	xor	ebx, ebx

; 19   : #if defined(KIBO_DETAIL_ROW_SSE2)
; 20   :     const auto sign=_mm_set1_pd(-0.0);

	movdqa	xmm10, XMMWORD PTR __xmm@80000000000000008000000000000000
	xorps	xmm2, xmm2
	movdqa	xmm11, XMMWORD PTR __xmm@7fefffffffffffff7fefffffffffffff

; 23   :     auto valid=_mm_cmpeq_pd(_mm_setzero_pd(),_mm_setzero_pd());

	mov	rsi, rdi
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	shl	r12, 3
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\detail\row_kernels.hpp

; 23   :     auto valid=_mm_cmpeq_pd(_mm_setzero_pd(),_mm_setzero_pd());

	xor	r15d, r15d
	cmpeqpd	xmm9, xmm9
$LN562@factorize_:

; 24   :     for (;count-i>=2;i+=2) {
; 25   :         const auto absolute=_mm_andnot_pd(sign,_mm_loadu_pd(values+i));

	movaps	xmm3, xmm9
	unpcklpd xmm2, xmm2
	npad	2
$LL299@factorize_:
	movups	xmm0, XMMWORD PTR [rdi+rbx*8]
	add	rbx, 2
	mov	rax, r9
	movaps	xmm1, xmm10
	sub	rax, rbx
	andnps	xmm1, xmm0

; 26   :         valid=_mm_and_pd(valid,_mm_cmple_pd(absolute,limit));

	movaps	xmm0, xmm1
	cmplepd	xmm0, xmm11
	andps	xmm0, xmm3
	movaps	xmm3, xmm0

; 27   :         largest=_mm_max_pd(largest,absolute);

	maxpd	xmm2, xmm1
	cmp	rax, 2
	jae	SHORT $LL299@factorize_

; 28   :     }
; 29   :     if (_mm_movemask_pd(valid)!=3) return false;

	movmskpd eax, xmm0
	cmp	eax, 3
	jne	SHORT $LN369@factorize_

; 30   :     maximum=std::max(_mm_cvtsd_f64(largest),_mm_cvtsd_f64(_mm_unpackhi_pd(largest,largest)));

	movaps	xmm6, xmm2
	unpckhpd xmm6, xmm2
	maxsd	xmm6, xmm2

; 31   : #endif
; 32   :     for (;i<count;++i) {

	cmp	rbx, r9
	jae	SHORT $LN301@factorize_
	movaps	xmm8, xmm6
	npad	5
$LL302@factorize_:
; File C:\Program Files (x86)\Windows Kits\10\Include\10.0.26100.0\ucrt\corecrt_math.h

; 326  :         return _dtest(&_X);

	movsd	xmm6, QWORD PTR [rdi+rbx*8]
	movaps	xmm0, xmm6
	call	_dclass
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\detail\row_kernels.hpp

; 33   :         if (!std::isfinite(values[i])) return false;

	test	ax, ax
	jg	SHORT $LN369@factorize_

; 31   : #endif
; 32   :     for (;i<count;++i) {

	mov	r9, QWORD PTR [r13+16]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	andps	xmm6, xmm7
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\detail\row_kernels.hpp

; 34   :         maximum=std::max(maximum,std::abs(values[i]));

	maxsd	xmm6, xmm8
	inc	rbx
	movaps	xmm8, xmm6
	cmp	rbx, r9
	jb	SHORT $LL302@factorize_
$LN301@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 109  :         for (std::size_t i=0;i<n;++i)

	add	rsi, r12
	inc	r15
	mov	rdi, rsi
	cmp	r15, r9
	jae	$LN499@factorize_
	xor	ebx, ebx
	movaps	xmm2, xmm6
	jmp	$LN562@factorize_
$LN369@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	mov	r8, QWORD PTR __$ReturnUdt$[rbp-256]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 110  :             if (!detail::finite_max_abs(&input(i,0),n,scale)) return StatusCode::non_finite_input;

	mov	rax, r8
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	mov	DWORD PTR [r8], 7
	mov	QWORD PTR [r8+8], 0
	mov	QWORD PTR [r8+16], 0
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\optional

; 77   :     constexpr _Optional_destruct_base() noexcept : _Dummy{}, _Has_value{false} {} // initialize an empty optional

	mov	BYTE PTR [r8+72], 0
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 110  :             if (!detail::finite_max_abs(&input(i,0),n,scale)) return StatusCode::non_finite_input;

	jmp	$LN561@factorize_
$LN33@factorize_:

; 112  :         if (!detail::finite(input)) return StatusCode::non_finite_input;

	movups	xmm0, XMMWORD PTR [rdx+16]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 139  :     for (std::size_t i = 0; i < a.rows(); ++i)

	xor	r12d, r12d
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 112  :         if (!detail::finite(input)) return StatusCode::non_finite_input;

	movups	xmm1, XMMWORD PTR [rdx+32]
	movups	xmm2, XMMWORD PTR [rdx]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 139  :     for (std::size_t i = 0; i < a.rows(); ++i)

	movq	rax, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 112  :         if (!detail::finite(input)) return StatusCode::non_finite_input;

	movaps	XMMWORD PTR $T5[rsp+16], xmm0
	movaps	XMMWORD PTR $T5[rsp+32], xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 139  :     for (std::size_t i = 0; i < a.rows(); ++i)

	mov	QWORD PTR $T1[rsp], rax
	test	rax, rax
	je	$LN36@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 112  :         if (!detail::finite(input)) return StatusCode::non_finite_input;

	mov	rsi, QWORD PTR $T5[rsp+24]
	movq	rax, xmm1
	movq	r13, xmm2
	lea	rax, QWORD PTR [rax*8]
	mov	QWORD PTR tv4309[rsp], rax
	mov	rcx, QWORD PTR tv4309[rsp]
	mov	rax, QWORD PTR $T1[rsp]
$LL277@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 140  :         for (std::size_t j = 0; j < a.cols(); ++j)

	xor	edi, edi
	test	rsi, rsi
	je	SHORT $LN275@factorize_

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	rax, QWORD PTR $T5[rsp+40]
	mov	rbx, r13
	lea	r15, QWORD PTR [rax*8]
	npad	7
$LL280@factorize_:
; File C:\Program Files (x86)\Windows Kits\10\Include\10.0.26100.0\ucrt\corecrt_math.h

; 326  :         return _dtest(&_X);

	movsd	xmm0, QWORD PTR [rbx]
	call	_dclass
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 141  :             if (!std::isfinite(a(i,j))) return false;

	test	ax, ax
	jg	$LN472@factorize_

; 140  :         for (std::size_t j = 0; j < a.cols(); ++j)

	inc	rdi
	add	rbx, r15
	cmp	rdi, rsi
	jb	SHORT $LL280@factorize_
	mov	rax, QWORD PTR $T1[rsp]
	mov	rcx, QWORD PTR tv4309[rsp]
$LN275@factorize_:

; 139  :     for (std::size_t i = 0; i < a.rows(); ++i)

	inc	r12
	add	r13, rcx
	cmp	r12, rax
	jb	SHORT $LL277@factorize_
	mov	r13, QWORD PTR input$[rbp-256]
	mov	r9, QWORD PTR n$1$[rsp]
	mov	r11, QWORD PTR options$[rbp-256]
$LN36@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 113  :         if (options.check_symmetry) {

	cmp	BYTE PTR [r11+8], 0
	je	$LN389@factorize_

; 114  :             for (std::size_t i=0;i<n;++i)

	test	r9, r9
	je	$LN487@factorize_
	mov	rbx, QWORD PTR [r13+40]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	xor	edi, edi
	mov	r15, QWORD PTR [r13]
	mov	rsi, r9
	mov	r12, QWORD PTR [r13+32]
	lea	r8, QWORD PTR [rbx*8]
$LL7@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 115  :                 for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));

	xor	r11d, r11d
	cmp	r9, 4
	jb	$LC419@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	lea	rax, QWORD PTR [rdi+rbx*2]
	mov	rdx, rbx
	lea	rcx, QWORD PTR [r15+rax*8]
	neg	rdx
	mov	rax, QWORD PTR [r13+16]
	mov	r9, rbx
	add	rax, -4
	shl	r9, 5
	mov	r10, rbx
	shr	rax, 2
	neg	r10
	add	rdx, rdx
	inc	rax
	lea	r11, QWORD PTR [rax*4]
	npad	12
$LL424@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rcx+rdx*8]
	andps	xmm0, xmm7
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 115  :                 for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));

	comisd	xmm0, xmm6
	jbe	SHORT $LN420@factorize_
	movaps	xmm6, xmm0
$LN420@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rcx+r10*8]
	andps	xmm0, xmm7
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 115  :                 for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));

	comisd	xmm0, xmm6
	jbe	SHORT $LN421@factorize_
	movaps	xmm6, xmm0
$LN421@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rcx]
	andps	xmm0, xmm7
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 115  :                 for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));

	comisd	xmm0, xmm6
	jbe	SHORT $LN422@factorize_
	movaps	xmm6, xmm0
$LN422@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [r8+rcx]
	andps	xmm0, xmm7
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 115  :                 for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));

	comisd	xmm0, xmm6
	jbe	SHORT $LN423@factorize_
	movaps	xmm6, xmm0
$LN423@factorize_:
	add	rcx, r9
	sub	rax, 1
	jne	SHORT $LL424@factorize_
	mov	r9, QWORD PTR [r13+16]
	cmp	r11, r9
	jae	SHORT $LN5@factorize_
$LC419@factorize_:
	mov	rax, rbx
	imul	rax, r11
	add	rax, rdi
	lea	rcx, QWORD PTR [r15+rax*8]
	mov	rax, r9
	sub	rax, r11
$LC10@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movsd	xmm0, QWORD PTR [rcx]
	andps	xmm0, xmm7
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 115  :                 for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));

	comisd	xmm0, xmm6
	jbe	SHORT $LN8@factorize_
	movaps	xmm6, xmm0
$LN8@factorize_:
	add	rcx, r8
	sub	rax, 1
	jne	SHORT $LC10@factorize_
$LN5@factorize_:

; 114  :             for (std::size_t i=0;i<n;++i)

	add	rdi, r12
	sub	rsi, 1
	jne	$LL7@factorize_
$LN499@factorize_:

; 116  :         }
; 117  :     }
; 118  :     if (options.check_symmetry) {
; 119  :         if (scale!=0) {

	mov	r11, QWORD PTR options$[rbp-256]
$LN487@factorize_:
	ucomisd	xmm6, xmm13
	jp	SHORT $LN494@factorize_
	je	$LN389@factorize_
$LN494@factorize_:

; 120  :             for (std::size_t i=0;i<n;++i)

	xor	edi, edi
	mov	r10d, edi
	test	r9, r9
	je	$LN389@factorize_
	movsd	xmm2, QWORD PTR [r11]
$LL13@factorize_:

; 121  :                 for (std::size_t j=0;j<i;++j)

	mov	r8, rdi
	test	r10, r10
	je	SHORT $LN11@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	rax, QWORD PTR [r13+40]
	mov	rcx, QWORD PTR [r13+32]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rdx, QWORD PTR [r13]
	lea	rbx, QWORD PTR [rax*8]
	imul	rax, r10
	lea	r11, QWORD PTR [rcx*8]
	imul	rcx, r10
	lea	r9, QWORD PTR [rdx+rax*8]
	lea	rax, QWORD PTR [rdx+rcx*8]
	npad	4
$LL16@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 122  :                     if (input(i,j)!=input(j,i) &&

	movsd	xmm0, QWORD PTR [rax]
	movsd	xmm1, QWORD PTR [r9]
	ucomisd	xmm0, xmm1
	jp	SHORT $LN493@factorize_
	je	SHORT $LN14@factorize_
$LN493@factorize_:
	divsd	xmm0, xmm6
	divsd	xmm1, xmm6
	subsd	xmm0, xmm1
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	andps	xmm0, xmm7
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 122  :                     if (input(i,j)!=input(j,i) &&

	comisd	xmm0, xmm2
	ja	$LN371@factorize_
$LN14@factorize_:

; 121  :                 for (std::size_t j=0;j<i;++j)

	inc	r8
	add	rax, rbx
	add	r9, r11
	cmp	r8, r10
	jb	SHORT $LL16@factorize_
	mov	r9, QWORD PTR [r13+16]
$LN11@factorize_:

; 120  :             for (std::size_t i=0;i<n;++i)

	inc	r10
	cmp	r10, r9
	jb	SHORT $LL13@factorize_
$LN389@factorize_:

; 125  :         }
; 126  :     }
; 127  :     if constexpr (detail::row_simd_available) {
; 128  :         if (storage.col_stride()==1 && n>=32)

	mov	r11, QWORD PTR [r14+40]
	cmp	r11, 1
	jne	$LN485@factorize_
	cmp	r9, 32					; 00000020H
	jb	$LN485@factorize_

; 129  :             return detail::factorize_column_llt(input,storage);

	movups	xmm0, XMMWORD PTR [r14]
	mov	rcx, QWORD PTR __$ReturnUdt$[rbp-256]
	lea	r8, QWORD PTR $T6[rsp]
	movups	xmm1, XMMWORD PTR [r14+16]
	lea	rdx, QWORD PTR $T9[rbp-256]
	movaps	XMMWORD PTR $T6[rsp], xmm0
	movups	xmm0, XMMWORD PTR [r14+32]
	movaps	XMMWORD PTR $T6[rsp+16], xmm1
	movups	xmm1, XMMWORD PTR [r13]
	movaps	XMMWORD PTR $T6[rsp+32], xmm0
	movups	xmm0, XMMWORD PTR [r13+16]
	movaps	XMMWORD PTR $T9[rbp-256], xmm1
	movups	xmm1, XMMWORD PTR [r13+32]
	movaps	XMMWORD PTR $T9[rbp-240], xmm0
	movaps	XMMWORD PTR $T9[rbp-224], xmm1
	call	?factorize_column_llt@detail@linalg@kibo@@YA?AV?$Result@VLltFactorView@linalg@kibo@@@23@V?$MatrixView@$$CBN@23@V?$MatrixView@N@23@@Z ; kibo::linalg::detail::factorize_column_llt
	mov	rax, QWORD PTR __$ReturnUdt$[rbp-256]
	jmp	SHORT $LN561@factorize_
$LN472@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	mov	rbx, QWORD PTR __$ReturnUdt$[rbp-256]
	xor	edi, edi
	mov	DWORD PTR [rbx], 7
	mov	QWORD PTR [rbx+8], rdi
	mov	QWORD PTR [rbx+16], rdi
$LN567@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 135  :             if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	mov	BYTE PTR [rbx+72], dil
$LN566@factorize_:
	mov	rax, rbx
$LN561@factorize_:
	mov	rbx, QWORD PTR [rsp+368]
	movaps	xmm11, XMMWORD PTR [rsp+240]
	movaps	xmm10, XMMWORD PTR [rsp+256]
	movaps	xmm9, XMMWORD PTR [rsp+272]
	movaps	xmm8, XMMWORD PTR [rsp+288]
	mov	rsi, QWORD PTR [rsp+360]
	mov	r15, QWORD PTR [rsp+344]
	mov	r12, QWORD PTR [rsp+352]
	movaps	xmm6, XMMWORD PTR [rsp+320]
$LN552@factorize_:
	movaps	xmm13, XMMWORD PTR [rsp+208]
	movaps	xmm7, XMMWORD PTR [rsp+304]
	movaps	xmm12, XMMWORD PTR [rsp+224]

; 148  : }

	add	rsp, 376				; 00000178H
	pop	r14
	pop	r13
	pop	rdi
	pop	rbp
	ret	0
$LN371@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 38   :     Result(Status error) noexcept : status_(error) { assert(!error); }

	mov	rbx, QWORD PTR __$ReturnUdt$[rbp-256]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 124  :                         return Status{StatusCode::invalid_argument,i};

	mov	DWORD PTR $T2[rsp], 3
	mov	QWORD PTR $T2[rsp+8], r10
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 38   :     Result(Status error) noexcept : status_(error) { assert(!error); }

	movups	xmm0, XMMWORD PTR $T2[rsp]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 124  :                         return Status{StatusCode::invalid_argument,i};

	mov	QWORD PTR $T2[rsp+16], rdi
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 38   :     Result(Status error) noexcept : status_(error) { assert(!error); }

	movsd	xmm1, QWORD PTR $T2[rsp+16]
	movups	XMMWORD PTR [rbx], xmm0
	movsd	QWORD PTR [rbx+16], xmm1
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 124  :                         return Status{StatusCode::invalid_argument,i};

	jmp	$LN567@factorize_
$LN485@factorize_:

; 131  :     for (std::size_t i=0;i<n;++i) {

	xor	r15d, r15d
	test	r9, r9
	je	$LN391@factorize_
	mov	rax, QWORD PTR [r13+40]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	xor	r8d, r8d
	shl	rax, 3
	mov	QWORD PTR tv4303[rbp-256], rax
	mov	rax, QWORD PTR [r13+32]
	shl	rax, 3
	mov	QWORD PTR tv4249[rbp-256], rax
	mov	rax, QWORD PTR [r13]
	mov	QWORD PTR tv4247[rsp], r11
$LN564@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 132  :         for (std::size_t j=0;j<=i;++j) {

	mov	QWORD PTR tv4250[rsp], rax
	xor	ebx, ebx
	mov	QWORD PTR tv4248[rbp-256], r8
	mov	r12, rax
	mov	QWORD PTR tv4276[rsp], rax
	npad	5
$LL22@factorize_:

; 133  :             double value=input(i,j);

	movsd	xmm2, QWORD PTR [r12]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	xor	r10d, r10d
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 134  :             for (std::size_t k=0;k<j;++k) value-=storage(i,k)*storage(j,k);

	cmp	rbx, 4
	jb	$LC426@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	rdx, QWORD PTR [r14+40]
	mov	r12, QWORD PTR [r14+32]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	r11, rdx
	mov	rcx, QWORD PTR [r14]
	mov	rax, r12
	imul	rax, r15
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

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
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	lea	rax, QWORD PTR [r8+rbx]
	imul	r9, rax
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	r8, QWORD PTR [rdx+r9]
	mov	QWORD PTR tv4765[rbp-256], r8
	lea	r13, QWORD PTR [r9*8]
	lea	r8, QWORD PTR [r9+rdx*2]
	sub	r9, rdx
	mov	QWORD PTR tv4788[rbp-256], r8
	lea	r8, QWORD PTR [rax-4]
	mov	rax, QWORD PTR tv4765[rbp-256]
	add	r8, r15
	mov	r14, QWORD PTR tv4788[rbp-256]
	shr	r8, 2
	inc	r8
	lea	r10, QWORD PTR [r8*4]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

$LL427@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 134  :             for (std::size_t k=0;k<j;++k) value-=storage(i,k)*storage(j,k);

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
	jne	SHORT $LL427@factorize_
	mov	r14, QWORD PTR storage$[rbp-256]
	cmp	r10, rbx
	jb	SHORT $LN497@factorize_
	jmp	SHORT $LN563@factorize_
$LC426@factorize_:
	test	rbx, rbx
	je	SHORT $LN425@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r12, QWORD PTR [r14+32]
	mov	rdx, QWORD PTR [r14+40]
$LN497@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 134  :             for (std::size_t k=0;k<j;++k) value-=storage(i,k)*storage(j,k);

	mov	rcx, QWORD PTR [r14]
	lea	r8, QWORD PTR [rdx*8]
	imul	rdx, r10
	mov	rax, r12
	imul	rax, r15
	add	rdx, rax
	lea	rax, QWORD PTR [rcx+rdx*8]
	mov	rdx, QWORD PTR tv4248[rbp-256]
	add	rdx, rbx
	mov	rcx, rbx
	imul	rdx, r12
	sub	rcx, r10
$LC25@factorize_:
	movsd	xmm0, QWORD PTR [rax+rdx*8]
	mulsd	xmm0, QWORD PTR [rax]
	add	rax, r8
	subsd	xmm2, xmm0
	sub	rcx, 1
	jne	SHORT $LC25@factorize_
$LN563@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	mov	r12, QWORD PTR tv4276[rsp]
$LN425@factorize_:
	movaps	xmm0, xmm2
	andps	xmm0, xmm7
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm12, xmm0

; 135  :             if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	jb	$LN372@factorize_

; 136  :             if (i==j) {

	cmp	r15, rbx
	jne	SHORT $LN44@factorize_

; 137  :                 if (value<=0) return Status{StatusCode::non_positive_pivot,j};

	comisd	xmm13, xmm2
	jae	$LN373@factorize_
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rdi, QWORD PTR [r14+32]
	xorps	xmm0, xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 138  :                 storage(i,j)=std::sqrt(value);

	ucomisd	xmm0, xmm2
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rsi, QWORD PTR [r14]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 138  :                 storage(i,j)=std::sqrt(value);

	ja	SHORT $LN491@factorize_
	xorps	xmm0, xmm0
	sqrtsd	xmm0, xmm2
	jmp	SHORT $LN492@factorize_
$LN491@factorize_:
	movaps	xmm0, xmm2
	call	sqrt
$LN492@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rcx, rdi
	mov	rax, rbx
	imul	rax, QWORD PTR [r14+40]
	imul	rcx, r15
	add	rcx, rax
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 138  :                 storage(i,j)=std::sqrt(value);

	movsd	QWORD PTR [rsi+rcx*8], xmm0

; 139  :             } else {

	jmp	SHORT $LN20@factorize_
$LN44@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	rdi, QWORD PTR [r14+32]
	mov	rcx, QWORD PTR [r14+40]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rsi, QWORD PTR [r14]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	lea	rax, QWORD PTR [rcx+rdi]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	imul	rax, rbx
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 140  :                 value/=storage(j,j);

	divsd	xmm2, QWORD PTR [rsi+rax*8]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movaps	xmm0, xmm2
	andps	xmm0, xmm7
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm12, xmm0

; 141  :                 if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	jb	$LN372@factorize_
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rax, rdi
	imul	rax, r15
	imul	rcx, rbx
	add	rcx, rax
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 142  :                 storage(i,j)=value;

	movsd	QWORD PTR [rsi+rcx*8], xmm2
$LN20@factorize_:

; 132  :         for (std::size_t j=0;j<=i;++j) {

	add	r12, QWORD PTR tv4303[rbp-256]
	inc	rbx
	mov	r8, QWORD PTR tv4248[rbp-256]
	mov	QWORD PTR tv4276[rsp], r12
	cmp	rbx, r15
	jbe	$LL22@factorize_

; 145  :         for (std::size_t j=i+1;j<n;++j) storage(i,j)=0;

	mov	r9, QWORD PTR n$1$[rsp]
	lea	r8, QWORD PTR [r15+1]
	cmp	r8, r9
	jae	$LN391@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r10, QWORD PTR tv4247[rsp]
	mov	rcx, r9
	mov	r11, QWORD PTR [r14+40]
	imul	rdi, r15
	lea	rdx, QWORD PTR [r11*8]
	add	rdi, r10
	sub	rcx, r8
	lea	rax, QWORD PTR [rsi+rdi*8]
	npad	12
$LL28@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 145  :         for (std::size_t j=i+1;j<n;++j) storage(i,j)=0;

	mov	QWORD PTR [rax], 0
	add	rax, rdx
	sub	rcx, 1
	jne	SHORT $LL28@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	rax, QWORD PTR tv4250[rsp]
	inc	r15
	add	rax, QWORD PTR tv4249[rbp-256]
	mov	r8, QWORD PTR tv4248[rbp-256]
	dec	r8
	add	r10, r11
	mov	QWORD PTR tv4247[rsp], r10
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 131  :     for (std::size_t i=0;i<n;++i) {

	jmp	$LN564@factorize_
$LN373@factorize_:

; 137  :                 if (value<=0) return Status{StatusCode::non_positive_pivot,j};

	mov	DWORD PTR $T4[rsp], 8
	jmp	SHORT $LN565@factorize_
$LN372@factorize_:

; 135  :             if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	mov	DWORD PTR $T3[rsp], 10
$LN565@factorize_:
	mov	QWORD PTR $T3[rsp+8], rbx
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 38   :     Result(Status error) noexcept : status_(error) { assert(!error); }

	mov	rbx, QWORD PTR __$ReturnUdt$[rbp-256]
	movups	xmm0, XMMWORD PTR $T3[rsp]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 135  :             if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	mov	QWORD PTR $T3[rsp+16], 0
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 38   :     Result(Status error) noexcept : status_(error) { assert(!error); }

	movsd	xmm1, QWORD PTR $T3[rsp+16]
	movups	XMMWORD PTR [rbx], xmm0
	movsd	QWORD PTR [rbx+16], xmm1
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\optional

; 77   :     constexpr _Optional_destruct_base() noexcept : _Dummy{}, _Has_value{false} {} // initialize an empty optional

	mov	BYTE PTR [rbx+72], 0
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 135  :             if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};

	jmp	$LN566@factorize_
$LN391@factorize_:
	mov	rbx, QWORD PTR __$ReturnUdt$[rbp-256]

; 147  :     return detail::LltAccess::create(storage);

	movups	xmm0, XMMWORD PTR [r14]
	movups	xmm1, XMMWORD PTR [r14+16]
	mov	DWORD PTR [rbx], 0
	movups	xmm2, XMMWORD PTR [r14+32]
	mov	QWORD PTR [rbx+8], 0
	mov	QWORD PTR [rbx+16], 0
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\optional

; 82   :         : _Value(_STD forward<_Types>(_Args)...), _Has_value{true} {} // initialize contained value with _Args...

	movq	QWORD PTR [rbx+24], xmm0
	psrldq	xmm0, 8
	movq	QWORD PTR [rbx+32], xmm0
	movq	QWORD PTR [rbx+40], xmm1
	psrldq	xmm1, 8
	movq	QWORD PTR [rbx+48], xmm1
	movq	QWORD PTR [rbx+56], xmm2
	psrldq	xmm2, 8
	movq	QWORD PTR [rbx+64], xmm2
	mov	BYTE PTR [rbx+72], 1
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 147  :     return detail::LltAccess::create(storage);

	jmp	$LN566@factorize_
$LN32@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	xor	edi, edi
	mov	DWORD PTR [r8], 3
	mov	QWORD PTR [r8+8], rdi
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 104  :         return StatusCode::invalid_argument;

	mov	rax, r8
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	mov	QWORD PTR [r8+16], rdi
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\optional

; 77   :     constexpr _Optional_destruct_base() noexcept : _Dummy{}, _Has_value{false} {} // initialize an empty optional

	mov	BYTE PTR [r8+72], dil
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 104  :         return StatusCode::invalid_argument;

	jmp	$LN552@factorize_
$LN30@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	xor	edi, edi
	mov	DWORD PTR [r8], 1
	mov	QWORD PTR [r8+8], rdi
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 102  :     if (n==0 || input.cols()!=n || !detail::same_shape(input,storage)) return StatusCode::invalid_shape;

	mov	rax, r8
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\linalg.hpp

; 37   :     Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }

	mov	QWORD PTR [r8+16], rdi
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\optional

; 77   :     constexpr _Optional_destruct_base() noexcept : _Dummy{}, _Has_value{false} {} // initialize an empty optional

	mov	BYTE PTR [r8+72], dil
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\baseline\kibo\llt.hpp

; 148  : }

	add	rsp, 376				; 00000178H
	pop	r14
	pop	r13
	pop	rdi
	pop	rbp
	ret	0
?factorize_llt@linalg@kibo@@YA?AV?$Result@VLltFactorView@linalg@kibo@@@12@V?$MatrixView@$$CBN@12@V?$MatrixView@N@12@ULltOptions@12@@Z ENDP ; kibo::linalg::factorize_llt