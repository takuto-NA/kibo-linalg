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
allocation testはMSVC DebugのCRT hookをmallocで校正し、準備済み基本演算を
100回実行して確保回数0を検証する。他の構成では測定未実施としてskipする。
