# Eigenからの移行例

Eigenの式を、所有行列・借用ビュー・準備済み出力とworkspaceへ分けます。
[examples/migration.cpp](../examples/migration.cpp)は、以下の操作をまとめた実行可能なconsumerです。

| Eigenでの操作 | kibo-linalgでの操作 | 移行時の契約 |
| --- | --- | --- |
| `Matrix<double,2,2>` | `StaticMatrix<double,2,2>` | row-major、ゼロ初期化 |
| `MatrixXd` | `DynamicMatrix<double>::try_create` | move-only、確保失敗はResult、深いコピーはtry_clone |
| `Map<MatrixXd>` / `Stride` | `MatrixView<T>::checked` | strideは要素単位。alignment・容量・overflowを検証 |
| `a.transpose()` | `view.transpose()` | コピーなし。ownerの寿命が必要 |
| `c = a * b` | `matmul_into(a,b,c)` | cを事前準備。入力と出力を重ねない |
| `a.llt().solve(b)` | `factorize_llt` → `solve_into` | factor storageとsolve workspaceを事前準備 |
| `a.colPivHouseholderQr().solve(b)` | `factorize_qr` → `solve_into` | packed/tau/permutation/workspaceを事前準備。rank不足は失敗 |

## 外部column-majorデータ

```cpp
std::array<double,4> storage{4,1,1,3};
auto mapped=MatrixView<const double>::checked(storage,2,2,1,2);
if (!mapped) return 1;
```

row stride=1、column stride=2でcolumn-majorの2×2を借用します。
書込み可ビューは論理要素が互いに重なる配置を拒否します。
ownerをresize・move・解放したら、古いビューを使わず再取得します。
checkedが成功しても、呼出し側が渡したspanの実際の生存期間を延長することはありません。

## 分解と失敗処理

`llt_factor_requirement`、`llt_solve_requirement`、`qr_factor_requirement`、`qr_solve_requirement`は
byte容量とalignmentを返します。下の固定例では十分な領域をあらかじめ置き、
動的サイズではquery成功後にallocatorまたはcaller arenaから領域を用意します。

```cpp
StaticMatrix<double,2,2> factor_storage;
alignas(double) std::array<std::byte,32> workspace{};
auto factor=factorize_llt(mapped.value(),factor_storage.view());
if (!factor) return 2;
auto status=solve_into(factor.value(),std::span<const double>{rhs},
                      std::span<double>{solution},workspace);
if (!status) return 3;
```

分解は入力を変更しません。途中失敗ではfactor領域を無効とし、古いhandleを使いません。
solveは候補解をworkspaceに作るため、失敗時に解出力を保持します。
返されたfactor handleとQR diagnosticsのpermutationは借用です。元の領域を生存させ、書き換え前に使います。

QRの既定rank閾値はmax(m,n)*epsilonで、`|Rii| > tolerance*max|Rjj|` を数えます。
Eigenの閾値判定と浮動小数点丸めが完全に同じになる保証はありません。
Eigenの列pivot QRで `info()==Success` となる入力でも、kibo-linalgはrank<nなら
`rank_deficient` を返し、Status.rankと任意のQrDiagnosticsで数値rankを示します。
SVD・m<n・rank不足系の最小ノルム解は提供しません。

normal-LLTを使う最小二乗では条件数が二乗され、QRより精度を失う場合があります。
悪条件での精度範囲とstress結果は受入報告を確認してください。
WASMではC++ビューをJSへ直接渡さず、[facadeのcopyとviewの契約](wasm.md)を使います。
