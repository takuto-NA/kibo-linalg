# QRの追加誤差と高精度残差による補正

2026-10-07。公開数値実装 `8fe28e552bfc485c4744a193cc9e677b3e2ce309`、
Eigen 5.0.1 `bc3b39870ecb690a623a3f49149a358b95c5781d`。
[精度原因調査](https://github.com/takuto-NA/kibo-linalg/issues/27) の診断結果。
公開API、既存test、閾値、seed、入力は変更していない。

## 結論と適用範囲

現在の大残差・condition 1e8の失敗には、丸め済み入力の感度だけでは説明できない
QR演算の追加誤差がある。実際のdouble A/bを100桁で解くと、既知解との差の最大は
Windowsで4.24e-9、今回の5構成全体でも6.04e-9だった。
同じ入力に対する公開QRの追加forward errorは最大0.0181である。
一般的なcondition boundやEigenの失敗を根拠に「不可避」と扱うことはできない。

元のA/bを保持し、高精度で残差 `b-Ax` と勾配 `Aᵀ(b-Ax)` を計算すると、
既存のdouble Rとpermutationを再利用した補正で誤差を減らせた。
外部高精度ライブラリを使わないdouble-doubleの2回補正は、検証した全510結果で
丸め済み入力のoracleとの差が1.12e-16以下になった。
これは限定したfixtureでの実現可能性の証拠であり、任意入力・全尺度の保証ではない。

## 実際の入力を参照計算へ渡す

Windows MSVC 19.44.35222、GCC 15.3、Clang 20.1.8で、各51問題をrow/column factor
layoutで解いた。Linux両compilerはSIMDとscalarを分けた。scalarは両backendの明示SIMDに加え
compilerの自動vectorizationも無効化した。Clangのこの診断はlibstdc++15を使う。
libc++、WASM、ESPの補正prototypeはまだ検証していない。

各構成には既存の6 oracle（n=2/8、scale=1e-150/1/1e150）と、
n=2/8/32/128/512、m=n/4n、condition=2/1e4/1e8、consistent/inconsistentの45問題を含む。
m=nでは非零orthogonal residualを作らない。全結果でcoreのrankはn、statusは成功。
既存のrank不足・境界・overflow testはこの診断とは別に維持する。

`audit.cpp`はsolverに渡した値を17桁で保存する。Python floatからmpmathへ渡し、
同じIEEE doubleを正確に再構成する。100桁でpower-of-two scalingした後、小問題は独立QRで解く。
大問題は全m*n要素について `A(i,j)` と `firstRow[(i mod n) xor j]` のbit一致を確認した。
その実際の丸め済みXOR-circulant行列を100桁FWHTで対角化し、実際のRHSのblock平均を解く。
生成時に指定した特異値やlibraryの解から期待値を作っていない。
この構造専用oracleを一般の密行列oracleとして扱わない。

raw Eigenとdoubleで正規化したEigenの解も元の丸め済み入力のoracleへ照合した。
正規化したEigenへ渡る丸め済みA/scale、b/scale自体の独立oracleは今回作っていない。
したがってnormalized Eigenの差を入力正規化と分解誤差へ完全分離したとは言わない。
構成間でfixture生成のRHS丸めが変わるため、各構成の入力hashとoracleを使う。
同一構成のrow/column入力hashは全問題で一致する。

## 原因を切り分ける対照

condition 1e8で非零残差があると、QR中の射影・更新の微小な丸めが弱い特異方向の解に大きく出る。
ただし今回の対照だけで、分解とQᵀbの各命令へ誤差量を完全配分してはいない。
確実に観測したのは、元の入力から計算する残差・勾配の精度が補正の成否を変えることである。

小問題の対照では、100桁の残差・勾配と既存double Rを使う1回補正で約1e-10、
2回で約1e-16に改善した。Rの再分解・全面的な高精度化なしでも改善可能だった。
残差・勾配を通常doubleで計算した2回補正には0.0004〜0.009程度の誤差が残る。
単に反復回数を増やす方法を解決とみなさない。

double-double prototypeはerror-free productの低位成分を `std::fma(a,b,-high)` で求め、
高低2成分の加算で残差・勾配を蓄積する。元A/bとRは同じpower-of-twoで正規化する。
`Rᵀz=Pᵀg`、`Rδ=z` をdoubleで解き、`x += Pδ` を2回行う。
通常のnormal equationsを新たに形成せず、既存Rを補正に再利用する。
全構成で既存forward/optimality値を満たし、consistent caseのbackward値も満たした。
inconsistent caseの残差normが零になることは要求しない。

Windowsの大残差問題の実例:

| n / m | coreのoracle誤差 row / column | 補正後oracle誤差の最大 |
| --- | --- | --- |
| 32 / 128 | 2.82e-4 / 1.53e-4 | 4.57e-17 |
| 128 / 512 | 1.09e-4 / 1.24e-4 | 4.26e-17 |
| 512 / 2048 | 1.35e-4 / 6.55e-5 | 4.16e-17 |

全構成の補正後optimality最大は3.67e-17だった。一方、補正前も小さなoptimalityを
返す例がある。小さなoptimalityだけから小さなforward errorを保証することはできない。

## 費用の診断

Windows固定CPU0/P-core、warmup 5回、5 sample、各batch 20ms以上。
m=4n、column factor layout、condition 1e8のmedianを示す。
prepared QR factor+solveと、その結果に追加する2回補正を別々に測った。
prototype内のvector確保・解copyも補正時間へ含めている。
1 processの費用診断であり、5 process×30 sampleの最終性能受入ではない。

| n | 現行QR factor+solve µs | 追加補正 µs |
| --- | ---: | ---: |
| 2 | 0.162 | 0.256 |
| 8 | 1.946 | 2.703 |
| 32 | 38.376 | 47.071 |
| 128 | 1331.338 | 796.803 |
| 512 | 82634.6 | 15556.3 |

小問題では補正費用が現行QRを上回る。512変数では約19%の追加だった。
両phaseの合計は将来の公開APIの正式測定ではなく、このprototypeの費用見積りである。
通常性能のEigen比較と難しい入力の精度費用を混ぜない。

## 判断待ちの具体案

現行の `QrFactorView` は元Aへの参照を持たず、factorize後に元Aを破棄できる。
packed QRから元の丸め済みAを正確に復元できないため、元入力を必要とする補正を
既存solveへ黙って組み込むとlifetime・容量契約が変わる。

推奨案は追加の
`solve_refined_into(factor, original_A, rhs, output, workspace)` と
`qr_refined_solve_requirement(m,n)` を用意すること。
既存factor/通常solveの性能・容量・lifetime契約を保つ。
condition 1e8・大残差でforward<=1e-4という強い保証を追加の補正経路で受け入れる。
通常solveも同じstress入力で測定・診断を残すが、この強い保証の適用経路が変わる点は
ユーザーの判断を必要とする。閾値を緩める案とは区別する。

候補workspaceは2m+3n doubles（残差高低2m、勾配n、解候補n、補正n）。
初回通常solveのm+nを再利用できる設計とする。成功時だけoutputへcommitし、失敗時は保持する。
original_Aはfactorと同じ元入力で、呼出し中だけ有効ならよい。行列形状・stride、
RHS/output/workspaceの容量・alignment・alias、NaN/Inf、途中overflow、iteration失敗を検証する。
rank不足は引き続き診断し、prepared allocation count0・例外/RTTI不要を維持する。
現在のstd::vector prototypeはこれらの公開契約を満たす実装ではない。
1e-300/1e300など全尺度、WASM/ESP、libc++での `std::fma` の精度・費用確認も必要。

もう一つの判断はEigenの位置付けである。現行testはraw/normalized Eigen自身にも
同じ精度CHECKをかけるため、kiboの補正を実装してもEigenの失敗だけでCIが失敗する。
推奨案はkiboの受入を既知解・独立oracle・statusで判定し、Eigenの精度失敗は
同じ入力の比較結果として保存・表示すること。Eigen側の失敗を削除・隠蔽しない。
これもCIの合否条件を変更するため未採用である。現在のtest CHECKは維持している。

全面的にQRの中間演算・factor storageを高精度化する代案は、容量・通常性能への
影響が大きく、今回prototypeの費用からその効果を推定しない。
補正経路の追加もEigen比較の合否変更も、承認前に親仕様・ADR・testsへ反映しない。

## 保存証拠と再現

生入力・解・oracle結果・費用・compiler flags・source/binary hashは
[`docs/validation/numerical/rounded-input`](../validation/numerical/rounded-input/metadata.json) に保存した。
`SHA256SUMS.json`は保存fileのbyte hash。Windowsの元scratch sourceと移設後tools sourceを
両方保存し、移設後のauditを再build/runして全102 recordsの完全一致を確認した。
Linuxの4構成は移設後toolsを使用する。

再現手順は [`tools/diagnostics/qr-accuracy/README.md`](../../tools/diagnostics/qr-accuracy/README.md)。
既存公開実装CIのnumerical失敗集合と契約結果は
[small LLTの保存検証](../validation/performance/small-llt/validation/hosted/evidence.json) を参照する。
この診断は既存CI全数値gate合格や精度親Issueの完了を意味しない。
