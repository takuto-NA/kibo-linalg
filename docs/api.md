# 初期C++ API

`<kibo/linalg.hpp>`、namespace `kibo::linalg`、C++20を使用する。
数値精度の保証対象は `double`。コアは例外・RTTI・外部ライブラリを要求しない。

## 所有行列とビュー

`StaticMatrix<T, Rows, Cols>` はゼロ初期化されたrow-major所有行列。
`view()` は書込み可、`const_view()` は読取り専用。
`MatrixView<T>::checked(span, rows, cols, row_stride, col_stride=1)` は要素単位の
正stride、自然alignment、最後の要素までの容量、size計算overflowを検証する。
書込み可ビューでは異なる論理要素が同じアドレスになる配置も拒否する。
読取り専用ビューでは重複要素を許す。SIMD用の追加alignmentは不要。

片方の次元が0なら空行列とし、要素にアクセスしない。空行列でもstrideは正。
`transpose()` はstrideを交換する。`submatrix(row,col,rows,cols)` は範囲を検証し、
データをコピーせずビューを返す。空部分行列のstorageは空。
要素アクセスのindex範囲と元のspanの有効性は呼出し側のprecondition。
ビューはメモリを所有しない。元の領域は計算の終了まで有効でなければならない。
constビューは、その領域が他の参照から変更されることまでは禁止しない。

## 動的所有行列

`<kibo/dynamic_matrix.hpp>` を追加すると、move-onlyな `DynamicMatrix<T>` を使える。
`try_create(rows,cols,allocator={})` と `try_clone()` は `Result<DynamicMatrix<T>>`、
`try_resize(rows,cols)` は成功時に再取得した `Result<MatrixView<T>>` を返す。
createはゼロ初期化、cloneは明示的な深いコピー。resizeは左上の共通範囲を保持し、
追加要素を0にする。同じshapeのresizeでは確保しない。
resize失敗では元のshapeと全要素を保持する。0要素の所有行列は確保しない。
move後の元ownerは0×0の空行列となる。

成功したサイズ変更・move・解放後には既存ビューを使わず再取得する。
同じshapeのresizeや失敗したresizeでは既存ビューを維持できる。
allocatorは `noexcept allocate(bytes,alignment,context)` / `deallocate(pointer,bytes,alignment,context)`。
既定はmalloc/freeで自然alignmentを満たす。custom allocatorは要求容量以上の
生存領域を返し、ownerとcloneの解放までcontextを有効に保つ。
不足はnullで通知する。alignment違反の領域は返されたallocatorで解放して拒否する。
呼出し側がallocate/deallocateの片方を省略した構成は `invalid_argument`。
固定/外部領域だけのconsumerではこのヘッダをincludeする必要がない。

```cpp
auto created = kibo::linalg::DynamicMatrix<double>::try_create(8, 8);
if (!created) return 1; // created.status().code で失敗理由を取得
auto matrix = std::move(created).value();
auto resized = matrix.try_resize(16, 16);
if (!resized) return 2; // 元のmatrixは保持される
auto current_view = resized.value(); // 成功後のビューを使う
```

## 計算と失敗

`fill_into(output,value)`, `identity_into(output)`, `copy_into(input,output)`、
`add_into(a,b,output)`, `sub_into(a,b,output)`, `scale_into(input,scale,output)`、
`add_diagonal_inplace(matrix,value)`, `matvec_into(a,x,output)`、
`matmul_into(a,b,output)` は `Status` を返す。
identityは長方形でも使用でき、対角のmin(rows,cols)要素を1にする。
`dot(a,b)`, `stable_norm2(a)` は `Result<T>` を返す。空ベクトルでは0。
2ノルムは中間の二乗によるoverflow/underflowを避ける尺度調整を行う。

出力領域は事前準備する。準備済みのこれらの演算はヒープ確保を行わない。
入力と出力は原則として重ならない領域を渡す。
例外としてadd/subの出力は入力の一方または両方と完全に同じ論理ビューにでき、
scaleも同じ入力ビューに上書きできる。部分重複、転置を介したalias、
matvec/matmul/copyのaliasはprecondition違反。実行時alias検出は行わない。

shape不一致と非有限入力（NaN/Inf）は出力変更前に失敗する。
計算途中の非有限結果は `arithmetic_failure` を返す。この場合は出力が部分更新され得るため
全体を無効として扱う。空の積の内側次元が0なら出力は0。
非有限のscale/fill/対角加算値は空行列でも拒否する。

`Status`/`Result` はnodiscard。`if (!result)` を先に確認し、失敗時は
`result.status().code` を使う。成功時だけ `result.value()` を呼ぶ。
valueの失敗時アクセスはprecondition違反（Debugではassert）。
StatusCodeはshape、layout、capacity、size overflow、非有限入力、算術失敗を区別する。

## 分解・solve

`<kibo/llt.hpp>` はdoubleの対称正定値系を扱う。
`factorize_llt(input, factor_storage, options={})` は `Result<LltFactorView>`。
n>0の正方行列と、入力から独立したn×nの書込み可storageを渡す。
既定では `|aij/scale-aji/scale| <= 32*epsilon`（scaleは最大絶対要素）で対称性を検証する。
`check_symmetry=false` は呼出し側が対称性を保証する場合だけ使う。
対称性不一致はinvalid_argument、非正pivotはnon_positive_pivot、非有限中間値はarithmetic_failure。
Status.indexは問題のpivot位置。成功factorの上三角は0。
`llt_factor_requirement(n)` はfactorのbyte/alignmentと追加workspace=0を返す。
`llt_solve_requirement(n)` のworkspaceはn個double。

`<kibo/qr.hpp>` はm>=n>0の密な列pivot付きHouseholder QRを扱う。
`factorize_qr(input, packed, tau, permutation, workspace, options={}, diagnostics=nullptr)`。
packedはm×n、tauはn個double、permutationはn個size_t。
`qr_factor_requirement(m,n)` が各領域のbyte/alignmentと2n個doubleのworkspaceを返す。
各領域を別に渡すため、領域間paddingは呼出し側が各alignmentに合わせる。
packedにはRとHouseholder vectorを保存し、full Qは生成しない。
既定のrelative rank toleranceはmax(m,n)*epsilon。指定する場合は有限の0<=tol<1。
`|Rii| > tol*max|Rjj|` を満たす対角の個数を数値rankとする。
rank<nではrank_deficientで有効factorを返さない。失敗Status.rankと、任意のdiagnosticsに
rank/tolerance/permutationを記録する。数値検証まで到達しない失敗ではdiagnosticsを保持する。
diagnostics.permutationも借用spanなので、rank_deficientの場合も元のpermutation領域を
生存させ、次のfactorizeや書換えより前に使う。永続保存には呼出し側でコピーする。
EigenのColPivHouseholderQR::info()が通常Successを返す契約とは異なる。
数学的rank、SVD、最小ノルム解、m<nへの解は保証しない。
`qr_solve_requirement(m,n)` のworkspaceはm+n個double。

`<kibo/qr_refined.hpp>` を追加すると、元入力から残差・勾配を高精度に求める
`solve_refined_into(factor, original_A, rhs, output, byte_workspace)` を使える。
`original_A` はfactorizeへ渡した同じ行列の値で、呼出し中に生存する読取り専用view。
factor handle自体は元入力を保持しない。既存factor/通常solveのlifetimeは同じである。
`qr_refined_solve_requirement(m,n)` のworkspaceは2m+3n個doubleで、サイズoverflowも検証する。
候補解を通常solveで作り、double-doubleの残差・勾配と同じdouble Rによる補正を2回行う。
power-of-two scalingの極端なexponentでは、reciprocal倍率自体のoverflowを避ける。
外部の高精度libraryを必要とせず、標準C++の `std::fma` を使用する。

補正も無確保で、事前失敗・途中算術失敗のどちらでも解出力を保持する。
元入力・factor・workspace・出力は独立領域とし、rhs/outputのみ完全に同じspanを許す。
非有限の元入力/RHSを拒否し、非有限な補正中間値はarithmetic_failureを返す。
Status.indexは非有限になった残差の行、または勾配・三角解・更新の変数位置を示す。
finiteな入力でも正規化した残差が表現範囲を超える場合は成功を返さない。
condition1e8・大残差の強い解精度保証は補正経路で受け入れる方針で、
通常solveの同じ入力の精度結果も診断に残す。
現在は実装検証中であり、全基準環境での保証受入はまだ完了していない。
[判断と根拠](adr/0009-original-input-qr-refinement.md)・[実装課題](https://github.com/takuto-NA/kibo-linalg/issues/28)。

```cpp
// original_Aはfactorize_qrへ渡した入力で、ここまで保持しておく。
auto required = kibo::linalg::qr_refined_solve_requirement(m, n);
if (!required) return required.status();
// caller_workspaceはrequiredのbyte数・alignmentを満たす準備済み領域。
return kibo::linalg::solve_refined_into(factor, original_A, rhs, output, caller_workspace);
```

LLT/QRとも `solve_into(factor, rhs, output, byte_workspace)` を使う。
workspaceはqueryのalignmentを満たす生存領域を渡す。容量不足・misalignmentは出力変更前に失敗する。
候補解をworkspaceで計算し、有限の成功解だけ出力にcommitするため、solveの途中失敗でも解出力は保持する。
既定構築したfactorは無効で、solveはinvalid_factorを返す。
失敗したfactorizeではfactor領域全体を無効として扱い、古いhandleを再利用しない。
factor storage/tau/permutationはhandleを使う間、生存し変更されていなければならない。
input、factor、tau、permutation、workspace、outputはそれぞれ重ならない領域を使う。
rhsとoutputのみ完全に同じspanを許す（workspaceに候補を作るため）。
数値分解での途中失敗ではfactor領域が部分更新され得る。

## 内部最適化の構成

x86のコンパイル対象にSSE2が含まれる場合、連続方向の内部計算にSSE2を使う。
自然なdouble alignmentだけで動き、AVX・外部BLAS・追加workspaceは要求しない。
ESP32・WASM等では通常のC++処理を使う。`KIBO_DISABLE_SIMD=1`を定義すると、
明示SIMDを無効化できる。この定義は同じプログラムの全translation unitで揃える。
コンパイラ自身の自動vectorizationは別のcompile flagで制御する。

LLTはSSE2を使う連続行storageで9列以上のとき、storageを一時的に転置ビューとして扱う。
9〜64列は先行列を新しい列へ適用し、それより大きい行列は8列panelで更新する。
未使用の上三角を係数の一時領域に使う。小さい行列やSIMD無効・非x86の構成ではscalar処理を使う。
成功時はcaller指定のlower layoutへ戻し、上三角を0にする。計算中のfactor storageは読み出さず、
数値失敗後は領域全体を無効とする既存契約を守る。factor workspaceは0のまま。
QRの有限値検査・列pivot/rank診断とfactor workspace=2n doublesも維持する。

QRはcallerが渡したfactor storageの配置を維持する。大きいQRでは
`MatrixView<double>::checked(buffer, m, n, 1, m)`による列方向格納を選べる。
この場合、4列でHouseholder vectorの読み込みを共有し、projectionと更新をSIMDで計算する。
行方向格納では4行のprojectionをまとめる。両方とも更新直後の有限値検査を行い、
solveでは残差部分も含めたoverflow検出と出力保持を維持する。
入力のrow/column変換はfactorizeの内部copyに含まれ、追加heap・追加workspaceは使わない。

## Windowsでの確認

PowerShell 7とCMake 3.30.5、VS 2022のMSVCで:

```powershell
./tools/windows-cmake.ps1 -S . -B build/native -G 'Visual Studio 17 2022' -A x64 -T version=14.44.35207
./tools/windows-cmake.ps1 --build build/native --config Debug --parallel 4
ctest --test-dir build/native -C Debug --output-on-failure
```

スクリプトはビルド子プロセスの環境変数名をWindowsの規則で正規化する。
システム設定を変更しない。通常環境では直接 `cmake` を実行してよい。
無例外・RTTI consumerはコンパイル時macroでも無効化を検証する。
allocation testはMSVC DebugのCRT hook、Linuxのallocator wrappingとnew置換をmallocで校正し、
準備済み基本演算・LLT・QRを100回実行して確保回数0を検証する。
MSVC Releaseなど計測器のない構成では測定未実施としてskipする。
準備済み分解・solveはDebugでn=2/8/32、Linux Releaseでn=2/8/32/128/512、
m=n/4nの外部ビューとcaller workspaceについても確保回数と解を検証する。
