?factorize_column_llt@detail@linalg@kibo@@YA?AV?$Result@VLltFactorView@linalg@kibo@@@23@V?$MatrixView@$$CBN@23@V?$MatrixView@N@23@@Z PROC ; kibo::linalg::detail::factorize_column_llt, COMDAT

; 30   : inline Result<LltFactorView> factorize_column_llt(MatrixView<const double> input, MatrixView<double> storage) noexcept {

$LN1058:
	mov	rax, rsp
	mov	QWORD PTR [rax+24], r8
	mov	QWORD PTR [rax+16], rdx
	mov	QWORD PTR [rax+8], rcx
	push	rbp
	push	rbx
	push	rsi
	push	rdi
	push	r12
	push	r13
	push	r14
	push	r15
	lea	rbp, QWORD PTR [rax-72]
	sub	rsp, 264				; 00000108H

; 31   :     // Input is fully validated and independent of storage. Compute through a
; 32   :     // transposed view so panel columns are contiguous without heap/workspace.
; 33   :     const auto n=input.rows();

	mov	r11, QWORD PTR [rdx+16]

; 35   :     if (n<=64) {

	xor	ebx, ebx
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 57   :         : storage_(storage), rows_(rows), cols_(cols), row_stride_(rs), col_stride_(cs) {}

	mov	r14, QWORD PTR [r8+40]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 30   : inline Result<LltFactorView> factorize_column_llt(MatrixView<const double> input, MatrixView<double> storage) noexcept {

	mov	r13, rdx
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 57   :         : storage_(storage), rows_(rows), cols_(cols), row_stride_(rs), col_stride_(cs) {}

	mov	rsi, QWORD PTR [r8+32]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 30   : inline Result<LltFactorView> factorize_column_llt(MatrixView<const double> input, MatrixView<double> storage) noexcept {

	movaps	XMMWORD PTR [rax-88], xmm6
	movaps	XMMWORD PTR [rax-104], xmm7
	movaps	XMMWORD PTR [rax-120], xmm8
	mov	rax, r8

; 31   :     // Input is fully validated and independent of storage. Compute through a
; 32   :     // transposed view so panel columns are contiguous without heap/workspace.
; 33   :     const auto n=input.rows();

	mov	QWORD PTR n$1$[rsp], r11
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 57   :         : storage_(storage), rows_(rows), cols_(cols), row_stride_(rs), col_stride_(cs) {}

	mov	QWORD PTR working$$sroa$3617$1$[rsp], r14
	mov	QWORD PTR working$$sroa$3618$1$[rbp-256], rsi
	movups	xmm0, XMMWORD PTR [r8]
	movups	XMMWORD PTR working$[rsp], xmm0
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 35   :     if (n<=64) {

	cmp	r11, 64					; 00000040H
	ja	$LN77@factorize_

; 36   :         for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<=i;++j) working(i,j)=input(i,j);

	mov	r8d, ebx
	test	r11, r11
	je	$LN942@factorize_
	mov	r14, QWORD PTR [rdx]
	lea	r10, QWORD PTR [rsi*8]
	mov	rsi, QWORD PTR [rdx+40]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	eax, ebx
	mov	rcx, QWORD PTR [r13+32]
	mov	edx, ebx
	mov	rdi, QWORD PTR working$[rsp]
	mov	QWORD PTR tv17183[rsp], r14
	lea	r11, QWORD PTR [rsi*8]
	mov	QWORD PTR tv16911[rsp], rsi
	mov	QWORD PTR tv17134[rsp], rbx
	mov	QWORD PTR tv17133[rbp-256], rbx
	mov	QWORD PTR tv17132[rsp], rcx
$LL4@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 36   :         for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<=i;++j) working(i,j)=input(i,j);

	lea	rcx, QWORD PTR [r8+1]
	mov	r9, rbx
	mov	QWORD PTR tv16910[rsp], rcx
	cmp	rcx, 4
	jb	$LN897@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r9, QWORD PTR working$$sroa$3618$1$[rbp-256]
	mov	r12, rsi
	mov	r13, rsi
	shl	r12, 5
	mov	r15, r9
	neg	r13
	shl	r15, 5
	lea	rax, QWORD PTR [rax+r9*2]
	lea	rcx, QWORD PTR [rdi+rax*8]
	lea	rax, QWORD PTR [rdx+rsi*2]
	neg	rsi
	lea	rdx, QWORD PTR [r14+rax*8]
	add	rsi, rsi
	mov	r14, r9
	mov	rax, r9
	mov	r9, QWORD PTR tv16910[rsp]
	neg	rax
	neg	r14
	mov	QWORD PTR tv17553[rsp], rax
	mov	rdi, QWORD PTR tv17553[rsp]
	add	r14, r14
	shr	r9, 2
	lea	rax, QWORD PTR [r9*4]
	mov	QWORD PTR j$1$[rsp], rax
	npad	13
$LL698@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 36   :         for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<=i;++j) working(i,j)=input(i,j);

	mov	rax, QWORD PTR [rdx+rsi*8]
	mov	QWORD PTR [rcx+r14*8], rax
	mov	rax, QWORD PTR [rdx+r13*8]
	mov	QWORD PTR [rcx+rdi*8], rax
	mov	rax, QWORD PTR [rdx]
	mov	QWORD PTR [rcx], rax
	mov	rax, QWORD PTR [r11+rdx]
	add	rdx, r12
	mov	QWORD PTR [rcx+r10], rax
	add	rcx, r15
	sub	r9, 1
	jne	SHORT $LL698@factorize_
	mov	r9, QWORD PTR j$1$[rsp]
	mov	rdi, QWORD PTR working$[rsp]
	mov	rsi, QWORD PTR tv16911[rsp]
	mov	r14, QWORD PTR tv17183[rsp]
	cmp	r9, r8
	ja	SHORT $LN962@factorize_
	mov	rdx, QWORD PTR tv17134[rsp]
$LN897@factorize_:
	mov	r12, QWORD PTR working$$sroa$3618$1$[rbp-256]
	sub	r8, r9
	mov	rax, r12
	imul	rax, r9
	add	rax, QWORD PTR tv17133[rbp-256]
	lea	rcx, QWORD PTR [rdi+rax*8]
	mov	rax, rsi
	imul	rax, r9
	add	rax, rdx
	inc	r8
	lea	rdx, QWORD PTR [r14+rax*8]
$LC7@factorize_:
	mov	rax, QWORD PTR [rdx]
	add	rdx, r11
	mov	QWORD PTR [rcx], rax
	add	rcx, r10
	sub	r8, 1
	jne	SHORT $LC7@factorize_
	jmp	SHORT $LN2@factorize_
$LN962@factorize_:
	mov	r12, QWORD PTR working$$sroa$3618$1$[rbp-256]
$LN2@factorize_:
	mov	rax, QWORD PTR tv17133[rbp-256]
	mov	rdx, QWORD PTR tv17134[rsp]
	add	rdx, QWORD PTR tv17132[rsp]
	mov	r13, QWORD PTR working$$sroa$3617$1$[rsp]
	mov	r8, QWORD PTR tv16910[rsp]
	add	rax, r13
	mov	QWORD PTR tv17133[rbp-256], rax
	mov	QWORD PTR tv17134[rsp], rdx
	cmp	r8, QWORD PTR n$1$[rsp]
	jb	$LL4@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	movdqa	xmm6, XMMWORD PTR __xmm@7fffffffffffffff7fffffffffffffff
	lea	rcx, QWORD PTR [r12+r13]
	movsd	xmm7, QWORD PTR __real@7fefffffffffffff
	lea	rax, QWORD PTR [r13*8]
	mov	r11, QWORD PTR n$1$[rsp]
	lea	rcx, QWORD PTR [rcx*8]
	add	rax, rdi
	mov	QWORD PTR tv17081[rsp], rcx
	mov	QWORD PTR tv17079[rbp-256], rax
	mov	rsi, rbx
	mov	QWORD PTR tv17086[rsp], rbx
	mov	r15, rdi
	mov	QWORD PTR tv17080[rsp], rdi
	mov	r14, rbx
	xorps	xmm8, xmm8
$LL16@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 44   :             double diagonal=working(k,k);

	movsd	xmm4, QWORD PTR [r15]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r10, rbx
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 45   :             for (std::size_t j=0;j<k;++j) diagonal-=working(k,j)*working(k,j);

	cmp	r14, 4
	jb	SHORT $LC703@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	lea	rax, QWORD PTR [rsi+r12*2]
	mov	rdx, r12
	lea	rcx, QWORD PTR [rdi+rax*8]
	neg	rdx
	lea	rax, QWORD PTR [r14-4]
	mov	r8, r12
	mov	r9, r12
	shr	rax, 2
	shl	r8, 5
	neg	r9
	add	rdx, rdx
	inc	rax
	lea	r10, QWORD PTR [rax*4]
$LL704@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 45   :             for (std::size_t j=0;j<k;++j) diagonal-=working(k,j)*working(k,j);

	movsd	xmm0, QWORD PTR [rcx+rdx*8]
	movsd	xmm1, QWORD PTR [rcx+r9*8]
	movsd	xmm2, QWORD PTR [rcx]
	movsd	xmm3, QWORD PTR [rcx+r12*8]
	add	rcx, r8
	mulsd	xmm0, xmm0
	mulsd	xmm1, xmm1
	mulsd	xmm2, xmm2
	mulsd	xmm3, xmm3
	subsd	xmm4, xmm0
	subsd	xmm4, xmm1
	subsd	xmm4, xmm2
	subsd	xmm4, xmm3
	sub	rax, 1
	jne	SHORT $LL704@factorize_
	cmp	r10, r14
	jb	SHORT $LN904@factorize_
	jmp	SHORT $LN702@factorize_
$LC703@factorize_:
	test	r14, r14
	je	SHORT $LN702@factorize_
$LN904@factorize_:
	mov	rax, r12
	lea	rdx, QWORD PTR [r12*8]
	imul	rax, r10
	add	rax, rsi
	lea	rcx, QWORD PTR [rdi+rax*8]
	mov	rax, r14
	sub	rax, r10
$LC19@factorize_:
	movsd	xmm0, QWORD PTR [rcx]
	add	rcx, rdx
	mulsd	xmm0, xmm0
	subsd	xmm4, xmm0
	sub	rax, 1
	jne	SHORT $LC19@factorize_
$LN702@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movaps	xmm0, xmm4
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm7, xmm0

; 46   :             if (!llt_is_finite(diagonal)) return Status{StatusCode::arithmetic_failure,k};

	jb	$LN580@factorize_

; 47   :             if (diagonal<=0) return Status{StatusCode::non_positive_pivot,k};

	comisd	xmm8, xmm4
	jae	$LN581@factorize_

; 48   :             working(k,k)=std::sqrt(diagonal);

	xorps	xmm0, xmm0
	ucomisd	xmm0, xmm4
	ja	SHORT $LN956@factorize_
	xorps	xmm0, xmm0
	sqrtsd	xmm0, xmm4
	jmp	SHORT $LN957@factorize_
$LN956@factorize_:
	movaps	xmm0, xmm4
	call	sqrt
	mov	r11, QWORD PTR n$1$[rsp]
$LN957@factorize_:

; 49   :             if (k+1<n) {

	lea	r10, QWORD PTR [r14+1]
	movsd	QWORD PTR [r15], xmm0
	cmp	r10, r11
	jae	$LN14@factorize_

; 50   :                 auto* coefficients=&working(0,n-1); // unused upper entries

	lea	rax, QWORD PTR [r11-1]
	mov	r9, rbx
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	imul	rax, r12
	lea	r11, QWORD PTR [rdi+rax*8]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 51   :                 for (std::size_t j=0;j<k;++j) coefficients[j]=working(k,j);

	cmp	r14, 4
	jb	$LC706@factorize_
	mov	rbx, QWORD PTR working$$sroa$3618$1$[rbp-256]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	lea	r13, QWORD PTR [r12*4]
	mov	r15, r12
	lea	rdx, QWORD PTR [r12+r12]
	add	r10, -5
	lea	r8, QWORD PTR [r11+16]
	neg	r15
	shr	r10, 2
	neg	r12
	inc	r10
	lea	r9, QWORD PTR [r10*4]
$LL707@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	rax, QWORD PTR [rdx+r12*2]
	add	rax, rsi
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 51   :                 for (std::size_t j=0;j<k;++j) coefficients[j]=working(k,j);

	lea	r8, QWORD PTR [r8+32]
	mov	rax, QWORD PTR [rdi+rax*8]
	mov	QWORD PTR [r8-48], rax
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	rax, QWORD PTR [rdx+rsi]
	add	rax, r15
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 51   :                 for (std::size_t j=0;j<k;++j) coefficients[j]=working(k,j);

	mov	rax, QWORD PTR [rdi+rax*8]
	mov	QWORD PTR [r8-40], rax
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	rax, QWORD PTR [rdx+rsi]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 51   :                 for (std::size_t j=0;j<k;++j) coefficients[j]=working(k,j);

	mov	rcx, QWORD PTR [rdi+rax*8]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	rax, QWORD PTR [rbx+rdx]
	add	rax, rsi
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 51   :                 for (std::size_t j=0;j<k;++j) coefficients[j]=working(k,j);

	mov	QWORD PTR [r8-32], rcx
	add	rdx, r13
	mov	rax, QWORD PTR [rdi+rax*8]
	mov	QWORD PTR [r8-24], rax
	sub	r10, 1
	jne	SHORT $LL707@factorize_
	mov	r12, QWORD PTR working$$sroa$3618$1$[rbp-256]
	xor	ebx, ebx
	mov	r13, QWORD PTR working$$sroa$3617$1$[rsp]
	cmp	r9, r14
	jb	SHORT $LN940@factorize_
	jmp	SHORT $LN705@factorize_
$LC706@factorize_:
	test	r14, r14
	je	SHORT $LN705@factorize_
$LN940@factorize_:
	mov	rdx, r12
	imul	rdx, r9
$LC22@factorize_:
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	rax, QWORD PTR [rdx+rsi]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 51   :                 for (std::size_t j=0;j<k;++j) coefficients[j]=working(k,j);

	add	rdx, r12
	mov	rcx, QWORD PTR [rdi+rax*8]
	mov	QWORD PTR [r11+r9*8], rcx
	inc	r9
	cmp	r9, r14
	jb	SHORT $LC22@factorize_
$LN705@factorize_:

; 52   :                 row_update_panel(&working(k+1,k),&working(k+1,0),working.col_stride(),coefficients,k,n-k-1);

	mov	rdx, QWORD PTR tv17079[rbp-256]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	rax, QWORD PTR [rsi+r13]
	add	rax, QWORD PTR tv17086[rsp]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 52   :                 row_update_panel(&working(k+1,k),&working(k+1,0),working.col_stride(),coefficients,k,n-k-1);

	mov	r9, r11
	mov	r8, r12
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	r15, QWORD PTR [rdi+rax*8]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 52   :                 row_update_panel(&working(k+1,k),&working(k+1,0),working.col_stride(),coefficients,k,n-k-1);

	mov	rax, QWORD PTR n$1$[rsp]
	sub	rax, r14
	mov	rcx, r15
	dec	rax
	mov	QWORD PTR [rsp+40], rax
	mov	QWORD PTR [rsp+32], r14
	call	?row_update_panel@detail@linalg@kibo@@YAXPEANPEBN_K122@Z ; kibo::linalg::detail::row_update_panel
	mov	r11, QWORD PTR n$1$[rsp]

; 53   :                 for (std::size_t i=k+1;i<n;++i) {

	lea	rcx, QWORD PTR [r12+r13]
	imul	rcx, r14
	lea	rax, QWORD PTR [r14+1]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	lea	rdx, QWORD PTR [r13*8]
	npad	7
$LL25@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 54   :                     const auto value=working(i,k)/working(k,k);

	movsd	xmm1, QWORD PTR [r15]
	divsd	xmm1, QWORD PTR [rdi+rcx*8]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movaps	xmm0, xmm1
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm7, xmm0

; 55   :                     if (!llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,k};

	jb	$LN580@factorize_

; 56   :                     working(i,k)=value;

	movsd	QWORD PTR [r15], xmm1
	inc	rax
	add	r15, rdx
	cmp	rax, r11
	jb	SHORT $LL25@factorize_
	mov	r15, QWORD PTR tv17080[rsp]
$LN14@factorize_:

; 39   :     }
; 40   :     if (n<=64) {
; 41   :         // Small matrices remain in cache. Apply all preceding columns once
; 42   :         // per new column instead of repeatedly reading/writing trailing tiles.
; 43   :         for (std::size_t k=0;k<n;++k) {

	add	r15, QWORD PTR tv17081[rsp]
	lea	rax, QWORD PTR [r13*8]
	add	QWORD PTR tv17079[rbp-256], rax
	inc	r14
	add	QWORD PTR tv17086[rsp], r12
	add	rsi, r13
	mov	QWORD PTR tv17080[rsp], r15
	cmp	r14, r11
	jb	$LL16@factorize_
	mov	rax, QWORD PTR storage$[rbp-256]
$LN942@factorize_:

; 97   :         for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<i;++j) {

	mov	QWORD PTR i$1$[rbp-256], rbx
	mov	r9, rbx
	test	r11, r11
	je	$LN60@factorize_
	mov	rsi, QWORD PTR [rax+40]
	mov	r8, QWORD PTR [rax+32]
	mov	rcx, QWORD PTR n$1$[rsp]
	npad	6
$LL55@factorize_:
	mov	r11, rbx
	cmp	r9, 4
	jb	$LC718@factorize_
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rdx, QWORD PTR [rax]
	lea	r10, QWORD PTR [r9-4]
	mov	rax, rsi
	mov	QWORD PTR $T2[rsp], rdx
	shl	rax, 5
	mov	r15, rsi
	mov	QWORD PTR tv16970[rbp-256], rax
	neg	r15
	mov	rax, rsi
	shr	r10, 2
	imul	rax, r9
	mov	r11, r8
	mov	r13, r8
	neg	r11
	shl	r13, 5
	mov	rdi, r8
	add	r15, r15
	neg	rdi
	add	r11, r11
	lea	rax, QWORD PTR [rax+r8*2]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r14, rsi
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	rcx, QWORD PTR [rdx+rax*8]
	mov	rax, r8
	imul	rax, r9
	mov	r9, QWORD PTR tv16970[rbp-256]
	lea	rax, QWORD PTR [rax+rsi*2]
	lea	rdx, QWORD PTR [rdx+rax*8]
	mov	rax, rsi
	neg	rax
	mov	QWORD PTR tv17491[rsp], rax
	inc	r10
	mov	r12, QWORD PTR tv17491[rsp]
	lea	rax, QWORD PTR [r10*4]
	mov	QWORD PTR j$1$[rsp], rax
	npad	4
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

$LL719@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 98   :             storage(i,j)=storage(j,i);storage(j,i)=0;

	mov	rax, QWORD PTR [rcx+r11*8]
	mov	QWORD PTR [rdx+r15*8], rax
	mov	QWORD PTR [rcx+r11*8], rbx
	mov	rax, QWORD PTR [rcx+rdi*8]
	mov	QWORD PTR [rdx+r12*8], rax
	mov	QWORD PTR [rcx+rdi*8], rbx
	mov	rax, QWORD PTR [rcx]
	mov	QWORD PTR [rdx], rax
	mov	QWORD PTR [rcx], rbx
	mov	rax, QWORD PTR [rcx+r8*8]
	mov	QWORD PTR [rdx+rsi*8], rax
	add	rdx, r9
	mov	QWORD PTR [rcx+r8*8], rbx
	add	rcx, r13
	sub	r10, 1
	jne	SHORT $LL719@factorize_

; 97   :         for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<i;++j) {

	mov	r9, QWORD PTR i$1$[rbp-256]
	mov	r12, r8
	mov	r11, QWORD PTR j$1$[rsp]
	cmp	r11, r9
	jae	SHORT $LN1051@factorize_
	mov	r10, QWORD PTR $T2[rsp]
$LN930@factorize_:
	mov	rax, r14
	lea	r15, QWORD PTR [r14*8]
	mov	rcx, r12
	lea	rdi, QWORD PTR [r12*8]
	imul	rcx, r11
	imul	rax, r9
	imul	r14, r11
	imul	r12, r9
	add	rcx, rax
	lea	rdx, QWORD PTR [r10+rcx*8]
	add	r14, r12
	lea	rcx, QWORD PTR [r10+r14*8]
	mov	r10, r9
	sub	r10, r11
$LC58@factorize_:

; 98   :             storage(i,j)=storage(j,i);storage(j,i)=0;

	mov	rax, QWORD PTR [rdx]
	mov	QWORD PTR [rcx], rax
	add	rcx, r15
	mov	QWORD PTR [rdx], rbx
	add	rdx, rdi
	sub	r10, 1
	jne	SHORT $LC58@factorize_
$LN1051@factorize_:

; 97   :         for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<i;++j) {

	mov	rcx, QWORD PTR n$1$[rsp]
	mov	rax, QWORD PTR storage$[rbp-256]
$LN53@factorize_:
	inc	r9
	mov	QWORD PTR i$1$[rbp-256], r9
	cmp	r9, rcx
	jb	$LL55@factorize_

; 99   :         }
; 100  :     } else {

	jmp	$LN60@factorize_
$LN581@factorize_:

; 47   :             if (diagonal<=0) return Status{StatusCode::non_positive_pivot,k};

	mov	DWORD PTR $T7[rsp], 8
	jmp	SHORT $LN1054@factorize_
$LN580@factorize_:

; 116  : }

	mov	DWORD PTR $T8[rsp], 10
$LN1054@factorize_:
	mov	QWORD PTR $T8[rbp-248], r14
$LN1055@factorize_:
	mov	rax, QWORD PTR __$ReturnUdt$[rbp-256]
	movups	xmm0, XMMWORD PTR $T8[rsp]
	mov	QWORD PTR $T8[rbp-240], rbx
	movsd	xmm1, QWORD PTR $T8[rbp-240]
	movups	XMMWORD PTR [rax], xmm0
	movsd	QWORD PTR [rax+16], xmm1
	mov	BYTE PTR [rax+72], 0
	jmp	$LN1@factorize_
$LC718@factorize_:

; 97   :         for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<i;++j) {

	test	r9, r9
	je	SHORT $LN53@factorize_
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	r10, QWORD PTR [rax]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r14, rsi
	mov	r12, r8
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 97   :         for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<i;++j) {

	jmp	$LN930@factorize_
$LN77@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	lea	rdx, QWORD PTR [r14+r14]
	mov	QWORD PTR tv17112[rsp], rbx
	mov	QWORD PTR tv17106[rsp], rdx
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 38   :         for (std::size_t j=0;j<n;++j) for (std::size_t i=j;i<n;++i) working(i,j)=input(i,j);

	mov	r10, rbx
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	rcx, rbx
	npad	4
$LL10@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 38   :         for (std::size_t j=0;j<n;++j) for (std::size_t i=j;i<n;++i) working(i,j)=input(i,j);

	mov	r8, QWORD PTR [r13]
	mov	rax, r11
	sub	rax, r10
	mov	QWORD PTR tv17182[rsp], r8
	mov	r12, r10
	cmp	rax, 4
	jb	$LN939@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r9, QWORD PTR [r13+32]
	lea	rax, QWORD PTR [rdx+rcx]
	mov	rcx, QWORD PTR [r13+40]
	mov	rsi, r14
	mov	rdx, QWORD PTR working$[rsp]
	add	rcx, r9
	mov	rdi, QWORD PTR working$$sroa$3617$1$[rsp]
	mov	r14, r9
	mov	r11, QWORD PTR working$$sroa$3617$1$[rsp]
	mov	r15, r9
	mov	r13, QWORD PTR working$$sroa$3617$1$[rsp]
	neg	rdi
	imul	rcx, r10
	lea	rdx, QWORD PTR [rdx+rax*8]
	shl	rsi, 5
	shl	r14, 5
	neg	r15
	neg	r11
	add	rdi, rdi
	lea	rax, QWORD PTR [rcx+r9*2]
	lea	rcx, QWORD PTR [r8+rax*8]
	mov	r8, QWORD PTR n$1$[rsp]
	sub	r8, r10
	lea	rax, QWORD PTR [r9*8]
	sub	r8, 4
	neg	r9
	shr	r8, 2
	add	r9, r9
	inc	r8
	mov	rbx, rax
	lea	r12, QWORD PTR [r10+r8*4]
	npad	12
$LL701@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 38   :         for (std::size_t j=0;j<n;++j) for (std::size_t i=j;i<n;++i) working(i,j)=input(i,j);

	mov	rax, QWORD PTR [rcx+r9*8]
	mov	QWORD PTR [rdx+rdi*8], rax
	mov	rax, QWORD PTR [rcx+r15*8]
	mov	QWORD PTR [rdx+r11*8], rax
	mov	rax, QWORD PTR [rcx]
	mov	QWORD PTR [rdx], rax
	mov	rax, QWORD PTR [rbx+rcx]
	add	rcx, r14
	mov	QWORD PTR [rdx+r13*8], rax
	add	rdx, rsi
	sub	r8, 1
	jne	SHORT $LL701@factorize_
	mov	r11, QWORD PTR n$1$[rsp]
	mov	r13, QWORD PTR input$[rbp-256]
	mov	rsi, QWORD PTR working$$sroa$3618$1$[rbp-256]
	mov	r14, QWORD PTR working$$sroa$3617$1$[rsp]
	cmp	r12, r11
	jb	SHORT $LN963@factorize_
	mov	r15, QWORD PTR working$[rsp]
	jmp	SHORT $LN8@factorize_
$LN963@factorize_:
	mov	r8, QWORD PTR tv17182[rsp]
$LN939@factorize_:
	mov	rcx, QWORD PTR [r13+32]
	lea	r9, QWORD PTR [r14*8]
	mov	r15, QWORD PTR working$[rsp]
	mov	rax, r14
	imul	rax, r12
	lea	r11, QWORD PTR [rcx*8]
	add	rax, QWORD PTR tv17112[rsp]
	imul	rcx, r12
	lea	rdx, QWORD PTR [r15+rax*8]
	mov	rax, r10
	imul	rax, QWORD PTR [r13+40]
	add	rcx, rax
	lea	r8, QWORD PTR [r8+rcx*8]
	mov	rcx, QWORD PTR [r13+16]
	sub	rcx, r12
$LC13@factorize_:
	mov	rax, QWORD PTR [r8]
	add	r8, r11
	mov	QWORD PTR [rdx], rax
	add	rdx, r9
	sub	rcx, 1
	jne	SHORT $LC13@factorize_
	mov	r11, QWORD PTR [r13+16]
$LN8@factorize_:
	mov	rdx, QWORD PTR tv17106[rsp]
	inc	r10
	mov	rcx, QWORD PTR tv17112[rsp]
	add	rdx, r14
	add	rcx, rsi
	mov	QWORD PTR tv17106[rsp], rdx
	mov	QWORD PTR tv17112[rsp], rcx
	cmp	r10, r11
	jb	$LL10@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	movdqa	xmm6, XMMWORD PTR __xmm@7fffffffffffffff7fffffffffffffff
	lea	rcx, QWORD PTR [rsi+r14]
	movsd	xmm7, QWORD PTR __real@7fefffffffffffff
	xor	ebx, ebx
	mov	r9d, ebx
	mov	QWORD PTR first$1$[rsp], rbx
	mov	QWORD PTR tv17198[rsp], rcx
	xorps	xmm8, xmm8
	npad	13
$LL28@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 62   :             const auto end=first+std::min(std::size_t{8},n-first);

	mov	edx, 8

; 63   :             for (std::size_t k=first;k<end;++k) {

	mov	QWORD PTR k$1$[rsp], r9
	mov	rax, r11
	mov	r10, r9
	sub	rax, r9
	cmp	rax, rdx
	cmovb	rdx, rax
	mov	QWORD PTR tv17195[rbp-256], rdx
	lea	r12, QWORD PTR [rdx+r9]
	mov	QWORD PTR end$1$[rbp-256], r12
	cmp	r9, r12
	jae	$LN959@factorize_

; 62   :             const auto end=first+std::min(std::size_t{8},n-first);

	mov	r11, rsi
	lea	r13, QWORD PTR [r9+1]
	imul	r11, r9
	mov	rsi, r14
	mov	rax, rcx
	imul	rsi, r13
	imul	rax, r9
	mov	QWORD PTR tv17045[rsp], r11
	mov	QWORD PTR tv17043[rsp], rsi
	lea	rdi, QWORD PTR [r15+rax*8]
	mov	QWORD PTR tv17041[rsp], rdi
	npad	5
$LL31@factorize_:

; 64   :                 const double diagonal=working(k,k);

	movsd	xmm1, QWORD PTR [rdi]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movaps	xmm0, xmm1
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm7, xmm0

; 65   :                 if (!detail::llt_is_finite(diagonal)) return Status{StatusCode::arithmetic_failure,k};

	jb	$LN583@factorize_

; 66   :                 if (diagonal<=0) return Status{StatusCode::non_positive_pivot,k};

	comisd	xmm8, xmm1
	jae	$LN584@factorize_

; 67   :                 working(k,k)=std::sqrt(diagonal);

	xorps	xmm0, xmm0
	ucomisd	xmm0, xmm1
	ja	SHORT $LN954@factorize_
	sqrtpd	xmm0, xmm1
	jmp	SHORT $LN955@factorize_
$LN954@factorize_:
	movaps	xmm0, xmm1
	call	sqrt
	mov	r11, QWORD PTR tv17045[rsp]
	mov	r10, QWORD PTR k$1$[rsp]
	mov	rcx, QWORD PTR tv17198[rsp]
$LN955@factorize_:
	movsd	QWORD PTR [rdi], xmm0

; 68   :                 for (std::size_t i=k+1;i<end;++i) {

	mov	rdx, r13
	cmp	r13, r12
	jae	$LN29@factorize_
	mov	r8, rcx
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	lea	rax, QWORD PTR [r11+rsi]
	imul	r8, r10
	lea	rcx, QWORD PTR [r15+rax*8]
	lea	r9, QWORD PTR [r14*8]
	npad	4
$LL34@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 69   :                     const double value=working(i,k)/working(k,k);

	movsd	xmm1, QWORD PTR [rcx]
	divsd	xmm1, QWORD PTR [r15+r8*8]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movaps	xmm0, xmm1
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm7, xmm0

; 70   :                     if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,k};

	jb	$LN583@factorize_

; 71   :                     working(i,k)=value;

	movsd	QWORD PTR [rcx], xmm1
	inc	rdx
	add	rcx, r9
	cmp	rdx, r12
	jb	SHORT $LL34@factorize_

; 73   :                 for (std::size_t j=k+1;j<end;++j)

	mov	r15, QWORD PTR tv17198[rsp]
	lea	rax, QWORD PTR [r11+rsi]
	mov	rdx, QWORD PTR working$[rsp]
	lea	r12, QWORD PTR [r14*8]
	mov	r14, r13
	lea	r15, QWORD PTR [r15*8]
	lea	r11, QWORD PTR [rdx+rax*8]
	mov	rax, QWORD PTR end$1$[rbp-256]
	lea	r10, QWORD PTR [r15+rdi]
	npad	10
$LL37@factorize_:

; 74   :                     row_update(&working(j,j),&working(j,k),end-j,working(j,k));

	movsd	xmm3, QWORD PTR [r11]
	mov	r8, rax
	sub	r8, r14
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\detail\row_kernels.hpp

; 75   :     for (;j<count;++j) row[j]-=value*projection[j];

	movaps	xmm4, xmm3
	unpcklpd xmm4, xmm4
	movaps	xmm2, xmm3
	unpcklpd xmm2, xmm2
	mov	rdx, rbx
	cmp	r8, 4
	jb	SHORT $LN226@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r9, r11
	lea	rcx, QWORD PTR [r10+16]
	sub	r9, r10
	npad	4
$LL227@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\detail\row_kernels.hpp

; 69   :         _mm_storeu_pd(row+j,_mm_sub_pd(_mm_loadu_pd(row+j),_mm_mul_pd(multiplier,_mm_loadu_pd(projection+j))));

	movups	xmm1, XMMWORD PTR [r9+rcx-16]
	add	rdx, 4
	mov	rax, r8
	movups	xmm0, XMMWORD PTR [rcx-16]
	sub	rax, rdx
	mulpd	xmm1, xmm2
	subpd	xmm0, xmm1
	movups	XMMWORD PTR [rcx-16], xmm0

; 70   :         _mm_storeu_pd(row+j+2,_mm_sub_pd(_mm_loadu_pd(row+j+2),_mm_mul_pd(multiplier,_mm_loadu_pd(projection+j+2))));

	movups	xmm1, XMMWORD PTR [r9+rcx]
	movups	xmm0, XMMWORD PTR [rcx]
	mulpd	xmm1, xmm2
	subpd	xmm0, xmm1
	movups	XMMWORD PTR [rcx], xmm0
	add	rcx, 32					; 00000020H
	cmp	rax, 4
	jae	SHORT $LL227@factorize_
$LN226@factorize_:

; 71   :     }
; 72   :     for (;count-j>=2;j+=2)

	mov	rax, r8
	sub	rax, rdx
	cmp	rax, 2
	jb	SHORT $LN229@factorize_
	mov	r9, r11
	lea	rcx, QWORD PTR [r10+rdx*8]
	sub	r9, r10
	npad	13
$LL230@factorize_:

; 73   :         _mm_storeu_pd(row+j,_mm_sub_pd(_mm_loadu_pd(row+j),_mm_mul_pd(multiplier,_mm_loadu_pd(projection+j))));

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
	jae	SHORT $LL230@factorize_
$LN229@factorize_:

; 75   :     for (;j<count;++j) row[j]-=value*projection[j];

	mov	r9, r8
	sub	r9, rdx
	cmp	rdx, r8
	jae	$LN35@factorize_
	cmp	r9, 8
	jb	$LN949@factorize_
	mov	rdi, r8
	lea	rax, QWORD PTR [r8-1]
	shl	rdi, 4
	lea	rax, QWORD PTR [r11+rax*8]
	add	rdi, -16
	lea	rsi, QWORD PTR [r11+rdx*8]
	mov	rcx, rdx
	add	rdi, r10
	shl	rcx, 4
	add	rcx, r10
	cmp	rcx, rax
	ja	SHORT $LN653@factorize_
	cmp	rdi, rsi
	jae	$LN949@factorize_
$LN653@factorize_:
	and	r9d, 7
	mov	rdi, r8
	sub	rdi, r9
	lea	rax, QWORD PTR [rdx+2]
	mov	rcx, r11
	lea	rax, QWORD PTR [r10+rax*8]
	sub	rcx, r10
	npad	6
$LL233@factorize_:
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
	cmp	rdx, rdi
	jb	SHORT $LL233@factorize_
	cmp	rdx, r8
	jae	$LN35@factorize_
$LN949@factorize_:
	mov	rax, r8
	sub	rax, rdx
	cmp	rax, 4
	jb	$LN948@factorize_
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
	npad	6
$LL710@factorize_:
	movsd	xmm0, QWORD PTR [rax-8]
	movaps	xmm1, xmm3
	mulsd	xmm1, QWORD PTR [rcx+rax-8]
	movaps	xmm2, xmm3
	subsd	xmm0, xmm1
	movaps	xmm1, xmm3
	movsd	QWORD PTR [rax-8], xmm0
	mulsd	xmm2, QWORD PTR [rcx+rax]
	movsd	xmm0, QWORD PTR [rax]
	subsd	xmm0, xmm2
	movsd	QWORD PTR [rax], xmm0
	mulsd	xmm1, QWORD PTR [rcx+rax+8]
	movsd	xmm0, QWORD PTR [rax+8]
	subsd	xmm0, xmm1
	movaps	xmm1, xmm3
	movsd	QWORD PTR [rax+8], xmm0
	mulsd	xmm1, QWORD PTR [rcx+rax+16]
	movsd	xmm0, QWORD PTR [rax+16]
	subsd	xmm0, xmm1
	movsd	QWORD PTR [rax+16], xmm0
	add	rax, 32					; 00000020H
	sub	r9, 1
	jne	SHORT $LL710@factorize_
	cmp	rdx, r8
	jae	SHORT $LN35@factorize_
$LN948@factorize_:
	mov	rcx, r11
	lea	rax, QWORD PTR [r10+rdx*8]
	sub	rcx, r10
	sub	r8, rdx
$LC651@factorize_:
	movsd	xmm0, QWORD PTR [rax]
	movaps	xmm1, xmm3
	mulsd	xmm1, QWORD PTR [rcx+rax]
	subsd	xmm0, xmm1
	movsd	QWORD PTR [rax], xmm0
	add	rax, 8
	sub	r8, 1
	jne	SHORT $LC651@factorize_
$LN35@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 73   :                 for (std::size_t j=k+1;j<end;++j)

	mov	rax, QWORD PTR end$1$[rbp-256]
	inc	r14
	add	r11, r12
	add	r10, r15
	cmp	r14, rax
	jb	$LL37@factorize_
	mov	rdi, QWORD PTR tv17041[rsp]
	mov	r12, rax
	mov	r11, QWORD PTR tv17045[rsp]
	mov	rsi, QWORD PTR tv17043[rsp]
	mov	r10, QWORD PTR k$1$[rsp]
	mov	r15, QWORD PTR working$[rsp]
	mov	r14, QWORD PTR working$$sroa$3617$1$[rsp]
	mov	rcx, QWORD PTR tv17198[rsp]
$LN29@factorize_:

; 63   :             for (std::size_t k=first;k<end;++k) {

	add	r11, QWORD PTR working$$sroa$3618$1$[rbp-256]
	lea	rax, QWORD PTR [rcx*8]
	add	rdi, rax
	mov	QWORD PTR tv17045[rsp], r11
	inc	r10
	mov	QWORD PTR tv17041[rsp], rdi
	add	rsi, r14
	mov	QWORD PTR k$1$[rsp], r10
	inc	r13
	mov	QWORD PTR tv17043[rsp], rsi
	cmp	r10, r12
	jb	$LL31@factorize_
	mov	rsi, QWORD PTR working$$sroa$3618$1$[rbp-256]
	mov	r9, QWORD PTR first$1$[rsp]
	mov	r11, QWORD PTR n$1$[rsp]
$LN959@factorize_:

; 75   :             }
; 76   :             if (end<n) for (std::size_t k=first;k<end;++k) {

	cmp	r12, r11
	jae	$LN91@factorize_
	mov	QWORD PTR k$1$[rsp], r9
	mov	r8, r9
	cmp	r9, r12
	jae	$LN38@factorize_
	mov	rcx, QWORD PTR first$1$[rsp]
	lea	rdi, QWORD PTR [rsi*8]
	mov	rax, r14
	lea	r13, QWORD PTR [r14*8]
	imul	rax, r12
	mov	r9, rsi
	lea	r10, QWORD PTR [rcx+1]
	imul	r9, rcx
	imul	r10, r14
	add	rax, r9
	sub	rdi, r15
	mov	QWORD PTR tv17000[rsp], rdi
	lea	r14, QWORD PTR [r15+rax*8]
$LN1052@factorize_:

; 77   :                 for (std::size_t i=end;i<n;++i) {

	mov	rdx, QWORD PTR tv17198[rsp]
	mov	rcx, r12
	imul	rdx, r8
	mov	QWORD PTR tv16876[rsp], r10
	mov	rax, r14
	mov	QWORD PTR tv16874[rsp], r9
	npad	1
$LL43@factorize_:

; 78   :                     const double value=working(i,k)/working(k,k);

	movsd	xmm1, QWORD PTR [rax]
	divsd	xmm1, QWORD PTR [r15+rdx*8]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\cstdlib

; 24   :     return _CSTD fabs(_Xx);

	movaps	xmm0, xmm1
	andps	xmm0, xmm6
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 25   :     return std::abs(value)<=std::numeric_limits<double>::max();

	comisd	xmm7, xmm0

; 79   :                     if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,k};

	jb	$LN585@factorize_

; 80   :                     working(i,k)=value;

	movsd	QWORD PTR [rax], xmm1
	inc	rcx
	add	rax, r13
	cmp	rcx, r11
	jb	SHORT $LL43@factorize_

; 82   :                 for (std::size_t j=k+1;j<end;++j)

	lea	rcx, QWORD PTR [r8+1]
	cmp	rcx, r12
	jae	$LN967@factorize_
	lea	rax, QWORD PTR [r10+r9]
	mov	r8, r11
	mov	r10, QWORD PTR working$[rsp]
	lea	r11, QWORD PTR [rsi*8]
	add	r10, rdi
	lea	r15, QWORD PTR [r15+rax*8]
	add	r10, r14
	sub	r8, r12
	neg	r10
	add	r11, r14
	sub	r12, rcx
$LL46@factorize_:

; 83   :                     row_update(&working(end,j),&working(end,k),n-end,working(j,k));

	movsd	xmm3, QWORD PTR [r15]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\detail\row_kernels.hpp

; 65   :     std::size_t j=0;

	mov	rdx, rbx

; 75   :     for (;j<count;++j) row[j]-=value*projection[j];

	movaps	xmm4, xmm3
	movaps	xmm2, xmm3
	unpcklpd xmm4, xmm4
	unpcklpd xmm2, xmm2
	cmp	r8, 4
	jb	SHORT $LN133@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	lea	rcx, QWORD PTR [r11+16]
	lea	r9, QWORD PTR [r10+r14]
	npad	12
$LL134@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\detail\row_kernels.hpp

; 69   :         _mm_storeu_pd(row+j,_mm_sub_pd(_mm_loadu_pd(row+j),_mm_mul_pd(multiplier,_mm_loadu_pd(projection+j))));

	movups	xmm1, XMMWORD PTR [r9+rcx-16]
	add	rdx, 4
	mov	rax, r8
	movups	xmm0, XMMWORD PTR [rcx-16]
	sub	rax, rdx
	mulpd	xmm1, xmm2
	subpd	xmm0, xmm1
	movups	XMMWORD PTR [rcx-16], xmm0

; 70   :         _mm_storeu_pd(row+j+2,_mm_sub_pd(_mm_loadu_pd(row+j+2),_mm_mul_pd(multiplier,_mm_loadu_pd(projection+j+2))));

	movups	xmm1, XMMWORD PTR [r9+rcx]
	movups	xmm0, XMMWORD PTR [rcx]
	mulpd	xmm1, xmm2
	subpd	xmm0, xmm1
	movups	XMMWORD PTR [rcx], xmm0
	add	rcx, 32					; 00000020H
	cmp	rax, 4
	jae	SHORT $LL134@factorize_
$LN133@factorize_:

; 71   :     }
; 72   :     for (;count-j>=2;j+=2)

	mov	rax, r8
	sub	rax, rdx
	cmp	rax, 2
	jb	SHORT $LN136@factorize_
	lea	rcx, QWORD PTR [r11+rdx*8]
	lea	r9, QWORD PTR [r10+r14]
$LL137@factorize_:

; 73   :         _mm_storeu_pd(row+j,_mm_sub_pd(_mm_loadu_pd(row+j),_mm_mul_pd(multiplier,_mm_loadu_pd(projection+j))));

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
	jae	SHORT $LL137@factorize_
$LN136@factorize_:

; 75   :     for (;j<count;++j) row[j]-=value*projection[j];

	mov	r9, r8
	sub	r9, rdx
	cmp	rdx, r8
	jae	$LN44@factorize_
	cmp	r9, 8
	jb	$LN947@factorize_
	mov	rdi, r8
	lea	rax, QWORD PTR [r8-1]
	shl	rdi, 4
	lea	rax, QWORD PTR [r14+rax*8]
	add	rdi, -16
	lea	rsi, QWORD PTR [r14+rdx*8]
	mov	rcx, rdx
	add	rdi, r11
	shl	rcx, 4
	add	rcx, r11
	cmp	rcx, rax
	ja	SHORT $LN656@factorize_
	cmp	rdi, rsi
	jae	$LN966@factorize_
$LN656@factorize_:
	and	r9d, 7
	mov	rcx, r8
	sub	rcx, r9
	lea	rax, QWORD PTR [rdx+2]
	lea	rax, QWORD PTR [r11+rax*8]
	lea	r9, QWORD PTR [r10+r14]
	npad	7
$LL140@factorize_:
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
	jb	SHORT $LL140@factorize_
	mov	rsi, QWORD PTR working$$sroa$3618$1$[rbp-256]
	cmp	rdx, r8
	jae	$LN44@factorize_
	jmp	SHORT $LN947@factorize_
$LN966@factorize_:
	mov	rsi, QWORD PTR working$$sroa$3618$1$[rbp-256]
$LN947@factorize_:
	mov	rax, r8
	sub	rax, rdx
	cmp	rax, 4
	jb	$LN946@factorize_
	lea	rax, QWORD PTR [rdx+1]
	mov	rcx, r8
	sub	rcx, rdx
	lea	rax, QWORD PTR [r11+rax*8]
	sub	rcx, 4
	lea	r9, QWORD PTR [r10+r14]
	shr	rcx, 2
	inc	rcx
	lea	rdx, QWORD PTR [rdx+rcx*4]
	npad	10
$LL713@factorize_:
	movsd	xmm0, QWORD PTR [rax-8]
	movaps	xmm1, xmm3
	mulsd	xmm1, QWORD PTR [r9+rax-8]
	movaps	xmm2, xmm3
	subsd	xmm0, xmm1
	movaps	xmm1, xmm3
	movsd	QWORD PTR [rax-8], xmm0
	mulsd	xmm2, QWORD PTR [r9+rax]
	movsd	xmm0, QWORD PTR [rax]
	subsd	xmm0, xmm2
	movsd	QWORD PTR [rax], xmm0
	mulsd	xmm1, QWORD PTR [r9+rax+8]
	movsd	xmm0, QWORD PTR [rax+8]
	subsd	xmm0, xmm1
	movaps	xmm1, xmm3
	movsd	QWORD PTR [rax+8], xmm0
	mulsd	xmm1, QWORD PTR [r9+rax+16]
	movsd	xmm0, QWORD PTR [rax+16]
	subsd	xmm0, xmm1
	movsd	QWORD PTR [rax+16], xmm0
	add	rax, 32					; 00000020H
	sub	rcx, 1
	jne	SHORT $LL713@factorize_
	cmp	rdx, r8
	jae	SHORT $LN44@factorize_
$LN946@factorize_:
	mov	rcx, r8
	lea	rax, QWORD PTR [r11+rdx*8]
	sub	rcx, rdx
	lea	r9, QWORD PTR [r10+r14]
$LC654@factorize_:
	movsd	xmm0, QWORD PTR [rax]
	movaps	xmm1, xmm3
	mulsd	xmm1, QWORD PTR [r9+rax]
	subsd	xmm0, xmm1
	movsd	QWORD PTR [rax], xmm0
	add	rax, 8
	sub	rcx, 1
	jne	SHORT $LC654@factorize_
$LN44@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 82   :                 for (std::size_t j=k+1;j<end;++j)

	lea	rax, QWORD PTR [rsi*8]
	add	r15, r13
	sub	r10, rax
	lea	rax, QWORD PTR [rsi*8]
	add	r11, rax
	sub	r12, 1
	jne	$LL46@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r8, QWORD PTR k$1$[rsp]
	lea	r14, QWORD PTR [r14+rsi*8]
	mov	r10, QWORD PTR tv16876[rsp]
	inc	r8
	add	r10, QWORD PTR working$$sroa$3617$1$[rsp]
	mov	r9, QWORD PTR tv16874[rsp]
	mov	r12, QWORD PTR end$1$[rbp-256]
	add	r9, rsi
	mov	rdi, QWORD PTR tv17000[rsp]
	mov	r15, QWORD PTR working$[rsp]
	mov	r11, QWORD PTR n$1$[rsp]
	mov	QWORD PTR k$1$[rsp], r8
	jmp	$LN1052@factorize_
$LN967@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 82   :                 for (std::size_t j=k+1;j<end;++j)

	mov	r9, QWORD PTR first$1$[rsp]
	mov	r14, QWORD PTR working$$sroa$3617$1$[rsp]
$LN38@factorize_:

; 86   :                 auto* coefficients=&working(0,n-1); // unused upper column, width<=n-1

	mov	rcx, QWORD PTR working$$sroa$3617$1$[rsp]
	lea	rax, QWORD PTR [r11-1]
	mov	r8, QWORD PTR working$[rsp]
	mov	rdi, QWORD PTR end$1$[rbp-256]
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	imul	rax, rsi
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 86   :                 auto* coefficients=&working(0,n-1); // unused upper column, width<=n-1

	imul	r14, r12
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	rbx, QWORD PTR [r15+rax*8]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 87   :                 for (std::size_t j=end;j<n;++j) {

	mov	r15, r12
	lea	rax, QWORD PTR [rsi+rcx]
	shl	rax, 3
	mov	QWORD PTR tv16986[rsp], rax
	lea	rax, QWORD PTR [rsi+rcx]
	imul	rax, r12
	lea	r12, QWORD PTR [r8+rax*8]
	mov	rax, rsi
	imul	rax, r9
	add	rax, r14
	lea	r13, QWORD PTR [r8+rax*8]
	npad	7
$LL49@factorize_:

; 88   :                     for (std::size_t k=first;k<end;++k) coefficients[k-first]=working(j,k);

	mov	rsi, r9
	cmp	r9, rdi
	jae	$LN714@factorize_
	mov	rax, rdi
	sub	rax, r9
	cmp	rax, 4
	jb	$LC715@factorize_
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	rsi, QWORD PTR working$$sroa$3618$1$[rbp-256]
	lea	rcx, QWORD PTR [r9+2]
	sub	r9, rcx
	lea	rdx, QWORD PTR [rbx+16]
	mov	rax, rsi
	mov	r10, rsi
	imul	rax, rcx
	mov	rcx, QWORD PTR end$1$[rbp-256]
	lea	r11, QWORD PTR [r9+1]
	add	rax, r14
	shl	r10, 5
	lea	rdi, QWORD PTR [r9+3]
	imul	r11, rsi
	imul	rdi, rsi
	imul	r9, rsi
	lea	r8, QWORD PTR [r8+rax*8]
	mov	rax, QWORD PTR first$1$[rsp]
	sub	rcx, rax
	sub	rcx, 4
	shr	rcx, 2
	inc	rcx
	lea	rsi, QWORD PTR [rax+rcx*4]
	npad	1
$LL716@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 88   :                     for (std::size_t k=first;k<end;++k) coefficients[k-first]=working(j,k);

	mov	rax, QWORD PTR [r8+r9*8]
	mov	QWORD PTR [rdx-16], rax
	lea	rdx, QWORD PTR [rdx+32]
	mov	rax, QWORD PTR [r8+r11*8]
	mov	QWORD PTR [rdx-40], rax
	mov	rax, QWORD PTR [r8]
	mov	QWORD PTR [rdx-32], rax
	mov	rax, QWORD PTR [r8+rdi*8]
	add	r8, r10
	mov	QWORD PTR [rdx-24], rax
	sub	rcx, 1
	jne	SHORT $LL716@factorize_
	mov	rdi, QWORD PTR end$1$[rbp-256]
	cmp	rsi, rdi
	jae	SHORT $LN714@factorize_
	mov	r8, QWORD PTR working$[rsp]
$LC715@factorize_:
	mov	rdx, QWORD PTR working$$sroa$3618$1$[rbp-256]
	mov	rax, rsi
	sub	rax, QWORD PTR first$1$[rsp]
	lea	r9, QWORD PTR [rdx*8]
	lea	rcx, QWORD PTR [rbx+rax*8]
	mov	rax, rdx
	imul	rax, rsi
	add	rax, r14
	lea	rdx, QWORD PTR [r8+rax*8]
	mov	r8, rdi
	sub	r8, rsi
$LC52@factorize_:
	mov	rax, QWORD PTR [rdx]
	add	rdx, r9
	mov	QWORD PTR [rcx], rax
	lea	rcx, QWORD PTR [rcx+8]
	sub	r8, 1
	jne	SHORT $LC52@factorize_
$LN714@factorize_:

; 89   :                     row_update_panel(&working(j,j),&working(j,first),working.col_stride(),coefficients,end-first,n-j);

	mov	rax, QWORD PTR n$1$[rsp]
	mov	r9, rbx
	mov	rsi, QWORD PTR working$$sroa$3618$1$[rbp-256]
	sub	rax, r15
	mov	QWORD PTR [rsp+40], rax
	mov	r8, rsi
	mov	rax, QWORD PTR tv17195[rbp-256]
	mov	rdx, r13
	mov	rcx, r12
	mov	QWORD PTR [rsp+32], rax
	call	?row_update_panel@detail@linalg@kibo@@YAXPEANPEBN_K122@Z ; kibo::linalg::detail::row_update_panel
	mov	rcx, QWORD PTR working$$sroa$3617$1$[rsp]
	inc	r15
	add	r12, QWORD PTR tv16986[rsp]
	add	r14, rcx
	mov	r11, QWORD PTR n$1$[rsp]
	mov	r8, QWORD PTR working$[rsp]
	mov	r9, QWORD PTR first$1$[rsp]
	lea	rax, QWORD PTR [rcx*8]
	add	r13, rax
	cmp	r15, r11
	jb	$LL49@factorize_

; 57   :                 }
; 58   :             }
; 59   :         }
; 60   :     } else {
; 61   :         for (std::size_t first=0;first<n;) {

	mov	r14, rcx
	mov	QWORD PTR first$1$[rsp], rdi
	mov	rcx, QWORD PTR tv17198[rsp]
	mov	r9, rdi
	xor	ebx, ebx
	mov	r15, r8
	jmp	$LL28@factorize_
$LN584@factorize_:

; 66   :                 if (diagonal<=0) return Status{StatusCode::non_positive_pivot,k};

	mov	DWORD PTR $T5[rsp], 8
	mov	QWORD PTR $T5[rbp-248], r10
	jmp	$LN1055@factorize_
$LN583@factorize_:

; 116  : }

	mov	DWORD PTR $T6[rsp], 10
	mov	QWORD PTR $T6[rbp-248], r10
	jmp	$LN1055@factorize_
$LN585@factorize_:

; 79   :                     if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,k};

	mov	DWORD PTR $T4[rsp], 10
	mov	QWORD PTR $T4[rbp-248], r8
	jmp	$LN1055@factorize_
$LN91@factorize_:
	mov	rcx, QWORD PTR storage$[rbp-256]

; 101  :         for (std::size_t first=0;first<n;) {

	mov	r14, rbx
	mov	QWORD PTR first$1$[rsp], rbx
	mov	rsi, QWORD PTR [rcx+40]
	mov	rdi, QWORD PTR [rcx+32]
	mov	QWORD PTR tv17189[rsp], rsi
	mov	QWORD PTR tv17187[rbp-256], rdi
$LL61@factorize_:

; 102  :             const auto end=first+std::min(std::size_t{8},n-first);

	mov	rax, r11
	mov	QWORD PTR column$1$[rsp], rbx
	sub	rax, r14
	mov	r11d, 8
	cmp	rax, r11
	cmovb	r11, rax
	mov	rax, rbx
	add	r11, r14
	mov	QWORD PTR end$1$[rbp-256], r11

; 103  :             for (std::size_t column=0;column<first;column+=8) {

	test	r14, r14
	je	$LN63@factorize_
	npad	4
$LL64@factorize_:

; 104  :                 const auto stop=std::min(column+8,first);

	lea	rsi, QWORD PTR [rax+8]

; 105  :                 for (std::size_t j=column;j<stop;++j) for (std::size_t i=first;i<end;++i) {

	mov	QWORD PTR j$1$[rsp], rax
	cmp	r14, rsi
	mov	r15, rax
	cmovb	rsi, r14
	mov	QWORD PTR stop$1$[rsp], rsi
	cmp	rax, rsi
	jae	$LN62@factorize_
$LL67@factorize_:
	mov	r13, r14
	cmp	r14, r11
	jae	$LN65@factorize_
	mov	r12, QWORD PTR [rcx]
	mov	rax, r11
	mov	rdi, QWORD PTR [rcx+40]
	sub	rax, r14
	mov	r10, QWORD PTR [rcx+32]
	mov	QWORD PTR $T9[rbp-256], r12
	mov	QWORD PTR $T10[rbp-256], rdi
	cmp	rax, 4
	jb	$LN941@factorize_
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	rdx, QWORD PTR [r14+2]
	mov	rax, rdi
	shl	rax, 5
	mov	rcx, r10
	imul	rcx, r15
	mov	QWORD PTR tv16961[rbp-256], rax
	mov	r11, r14
	sub	r11, rdx
	mov	rax, r10
	shl	rax, 5
	mov	rsi, rdi
	mov	QWORD PTR tv16960[rsp], rax
	mov	rax, rdi
	imul	rax, rdx
	add	rcx, rax
	mov	rax, r10
	imul	rax, rdx
	lea	r8, QWORD PTR [r12+rcx*8]
	mov	rdx, rdi
	mov	rcx, rdi
	imul	rcx, r15
	mov	r15, QWORD PTR tv16960[rsp]
	add	rcx, rax
	lea	rax, QWORD PTR [r11+1]
	imul	rdx, rax
	lea	r9, QWORD PTR [r12+rcx*8]
	mov	rcx, r10
	imul	rcx, rax
	lea	rax, QWORD PTR [r11+3]
	mov	QWORD PTR tv17274[rsp], rcx
	mov	rcx, r10
	mov	r12, QWORD PTR tv17274[rsp]
	imul	rcx, rax
	imul	rsi, rax
	mov	QWORD PTR tv17272[rsp], rcx
	mov	rcx, r11
	imul	rcx, r10
	imul	r11, rdi
	mov	QWORD PTR tv17271[rbp-256], rcx
	mov	rcx, QWORD PTR end$1$[rbp-256]
	mov	rdi, QWORD PTR tv17271[rbp-256]
	sub	rcx, r14
	sub	rcx, 4
	shr	rcx, 2
	inc	rcx
	lea	r13, QWORD PTR [r14+rcx*4]
	mov	r14, QWORD PTR tv16961[rbp-256]
	mov	QWORD PTR i$1$[rbp-256], r13
	mov	r13, QWORD PTR tv17272[rsp]
	npad	7
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

$LL722@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 106  :                     storage(i,j)=storage(j,i);storage(j,i)=0;

	mov	rax, QWORD PTR [r8+r11*8]
	mov	QWORD PTR [r9+rdi*8], rax
	mov	QWORD PTR [r8+r11*8], rbx
	mov	rax, QWORD PTR [r8+rdx*8]
	mov	QWORD PTR [r9+r12*8], rax
	mov	QWORD PTR [r8+rdx*8], rbx
	mov	rax, QWORD PTR [r8]
	mov	QWORD PTR [r9], rax
	mov	QWORD PTR [r8], rbx
	mov	rax, QWORD PTR [r8+rsi*8]
	mov	QWORD PTR [r9+r13*8], rax
	add	r9, r15
	mov	QWORD PTR [r8+rsi*8], rbx
	add	r8, r14
	sub	rcx, 1
	jne	SHORT $LL722@factorize_

; 105  :                 for (std::size_t j=column;j<stop;++j) for (std::size_t i=first;i<end;++i) {

	mov	r13, QWORD PTR i$1$[rbp-256]
	mov	r11, QWORD PTR end$1$[rbp-256]
	mov	rdi, QWORD PTR $T10[rbp-256]
	mov	r14, QWORD PTR first$1$[rsp]
	mov	r15, QWORD PTR j$1$[rsp]
	mov	r12, QWORD PTR $T9[rbp-256]
	mov	rsi, QWORD PTR stop$1$[rsp]
	cmp	r13, r11
	jae	SHORT $LN1053@factorize_
$LN941@factorize_:
	mov	r8, QWORD PTR end$1$[rbp-256]
	lea	r11, QWORD PTR [r10*8]
	mov	rax, r10
	lea	r9, QWORD PTR [rdi*8]
	mov	rcx, rdi
	imul	rcx, r13
	imul	rax, r15
	imul	r10, r13
	imul	rdi, r15
	add	rcx, rax
	lea	rdx, QWORD PTR [r12+rcx*8]
	add	r10, rdi
	sub	r8, r13
	lea	rcx, QWORD PTR [r12+r10*8]
$LC70@factorize_:

; 106  :                     storage(i,j)=storage(j,i);storage(j,i)=0;

	mov	rax, QWORD PTR [rdx]
	mov	QWORD PTR [rcx], rax
	add	rcx, r11
	mov	QWORD PTR [rdx], rbx
	add	rdx, r9
	sub	r8, 1
	jne	SHORT $LC70@factorize_
	mov	r11, QWORD PTR end$1$[rbp-256]
$LN1053@factorize_:

; 105  :                 for (std::size_t j=column;j<stop;++j) for (std::size_t i=first;i<end;++i) {

	mov	rcx, QWORD PTR storage$[rbp-256]
$LN65@factorize_:
	inc	r15
	mov	QWORD PTR j$1$[rsp], r15
	cmp	r15, rsi
	jb	$LL67@factorize_
	mov	rax, QWORD PTR column$1$[rsp]
$LN62@factorize_:

; 103  :             for (std::size_t column=0;column<first;column+=8) {

	add	rax, 8
	mov	QWORD PTR column$1$[rsp], rax
	cmp	rax, r14
	jb	$LL64@factorize_
	mov	rsi, QWORD PTR tv17189[rsp]
	mov	rdi, QWORD PTR tv17187[rbp-256]
$LN63@factorize_:

; 107  :                 }
; 108  :             }
; 109  :             for (std::size_t i=first;i<end;++i) for (std::size_t j=first;j<i;++j) {

	mov	QWORD PTR i$1$[rsp], r14
	mov	r10, r14
	cmp	r14, r11
	jae	$LN72@factorize_
	npad	9
$LL73@factorize_:
	mov	r9, r14
	cmp	r14, r10
	jae	$LN71@factorize_
	mov	r13, QWORD PTR [rcx]
	mov	rax, r10
	sub	rax, r14
	mov	QWORD PTR $T1[rsp], r13
	mov	QWORD PTR tv16902[rbp-256], rax
	mov	r15, rsi
	cmp	rax, 4
	jb	$LC724@factorize_
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	lea	rdx, QWORD PTR [r14+2]
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	QWORD PTR $T3[rsp], rdi
; File C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\include\span

; 465  :         return _Mydata[_Off];

	mov	rcx, rsi
	mov	rax, rdi
	shl	rax, 5
	mov	QWORD PTR tv16938[rbp-256], rax
	mov	rax, rsi
	mov	r11, QWORD PTR tv16938[rbp-256]
	shl	rax, 5
	imul	rcx, r10
	mov	QWORD PTR tv16937[rbp-256], rax
	mov	rax, rdi
	imul	rax, rdx
	add	rcx, rax
	mov	rax, rsi
	imul	rax, rdx
	lea	r8, QWORD PTR [rcx*8]
	mov	rcx, rdi
	imul	rcx, r10
	add	r8, r13
	add	rcx, rax
	lea	r9, QWORD PTR [rcx*8]
	mov	rcx, r14
	sub	rcx, rdx
	add	r9, r13
	mov	rdx, rsi
	lea	rax, QWORD PTR [rcx+1]
	imul	rdx, rax
	imul	rdi, rax
	mov	QWORD PTR tv17242[rbp-256], rdx
	lea	rax, QWORD PTR [rcx+3]
	mov	r10, QWORD PTR tv17242[rbp-256]
	mov	rdx, rsi
	imul	rdx, rax
	mov	QWORD PTR tv17240[rbp-256], rdx
	mov	rdx, rcx
	imul	rcx, QWORD PTR tv17187[rbp-256]
	imul	rdx, rsi
	mov	rsi, QWORD PTR tv17187[rbp-256]
	mov	r13, QWORD PTR tv17240[rbp-256]
	imul	rsi, rax
	mov	QWORD PTR tv17239[rsp], rdx
	mov	rdx, QWORD PTR tv16902[rbp-256]
	mov	r12, QWORD PTR tv17239[rsp]
	add	rdx, -4
	shr	rdx, 2
	inc	rdx
	lea	rax, QWORD PTR [r14+rdx*4]
	mov	r14, QWORD PTR tv16937[rbp-256]
	mov	QWORD PTR j$1$[rbp-256], rax
	npad	1
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

$LL725@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 110  :                 storage(i,j)=storage(j,i);storage(j,i)=0;

	mov	rax, QWORD PTR [r8+rcx*8]
	mov	QWORD PTR [r9+r12*8], rax
	mov	QWORD PTR [r8+rcx*8], rbx
	mov	rax, QWORD PTR [r8+rdi*8]
	mov	QWORD PTR [r9+r10*8], rax
	mov	QWORD PTR [r8+rdi*8], rbx
	mov	rax, QWORD PTR [r8]
	mov	QWORD PTR [r9], rax
	mov	QWORD PTR [r8], rbx
	mov	rax, QWORD PTR [r8+rsi*8]
	mov	QWORD PTR [r9+r13*8], rax
	add	r9, r14
	mov	QWORD PTR [r8+rsi*8], rbx
	add	r8, r11
	sub	rdx, 1
	jne	SHORT $LL725@factorize_

; 107  :                 }
; 108  :             }
; 109  :             for (std::size_t i=first;i<end;++i) for (std::size_t j=first;j<i;++j) {

	mov	r10, QWORD PTR i$1$[rsp]
	mov	r9, QWORD PTR j$1$[rbp-256]
	mov	r14, QWORD PTR first$1$[rsp]
	mov	r11, QWORD PTR end$1$[rbp-256]
	mov	r12, QWORD PTR $T3[rsp]
	mov	r13, QWORD PTR $T1[rsp]
	cmp	r9, r10
	jb	SHORT $LN938@factorize_
	jmp	SHORT $LN71@factorize_
$LC724@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\linalg.hpp

; 87   :         return storage_[row * row_stride_ + col * col_stride_];

	mov	r12, rdi
$LN938@factorize_:
	mov	rax, r15
	lea	rsi, QWORD PTR [r15*8]
	mov	rcx, r12
	lea	rdi, QWORD PTR [r12*8]
	imul	rcx, r9
	imul	rax, r10
	imul	r15, r9
	imul	r12, r10
	add	rcx, rax
	mov	r8, r10
	lea	rdx, QWORD PTR [rcx*8]
	add	r15, r12
	add	rdx, r13
	lea	rcx, QWORD PTR [r15*8]
	add	rcx, r13
	sub	r8, r9
$LC76@factorize_:
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 110  :                 storage(i,j)=storage(j,i);storage(j,i)=0;

	mov	rax, QWORD PTR [rdx]
	mov	QWORD PTR [rcx], rax
	add	rcx, rsi
	mov	QWORD PTR [rdx], rbx
	add	rdx, rdi
	sub	r8, 1
	jne	SHORT $LC76@factorize_
$LN71@factorize_:

; 107  :                 }
; 108  :             }
; 109  :             for (std::size_t i=first;i<end;++i) for (std::size_t j=first;j<i;++j) {

	mov	rsi, QWORD PTR tv17189[rsp]
	inc	r10
	mov	rdi, QWORD PTR tv17187[rbp-256]
	mov	rcx, QWORD PTR storage$[rbp-256]
	mov	QWORD PTR i$1$[rsp], r10
	cmp	r10, r11
	jb	$LL73@factorize_
$LN72@factorize_:

; 101  :         for (std::size_t first=0;first<n;) {

	cmp	r11, QWORD PTR n$1$[rsp]

; 111  :             }
; 112  :             first=end;

	mov	r14, r11
	mov	rsi, QWORD PTR tv17189[rsp]
	mov	rdi, QWORD PTR tv17187[rbp-256]
	mov	rcx, QWORD PTR storage$[rbp-256]
	mov	QWORD PTR first$1$[rsp], r11
	mov	r11, QWORD PTR n$1$[rsp]
	jb	$LL61@factorize_
$LN60@factorize_:
	mov	rcx, QWORD PTR __$ReturnUdt$[rbp-256]

; 113  :         }
; 114  :     }
; 115  :     return LltAccess::create(storage);

	mov	rax, QWORD PTR storage$[rbp-256]
	mov	DWORD PTR [rcx], ebx
	movups	xmm0, XMMWORD PTR [rax]
	mov	QWORD PTR [rcx+8], rbx
	movups	xmm1, XMMWORD PTR [rax+16]
	mov	QWORD PTR [rcx+16], rbx
	movups	xmm2, XMMWORD PTR [rax+32]
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
; File C:\Users\owner\Documents\git\kibo-linalg\build\small-llt\variants\c_flat_scan4\kibo\llt.hpp

; 116  : }

	lea	r11, QWORD PTR [rsp+264]
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
	pop	rbx
	pop	rbp
	ret	0
?factorize_column_llt@detail@linalg@kibo@@YA?AV?$Result@VLltFactorView@linalg@kibo@@@23@V?$MatrixView@$$CBN@23@V?$MatrixView@N@23@@Z ENDP ; kibo::linalg::detail::factorize_column_llt