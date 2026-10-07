# LLTの大行列を実COFF命令と公開APIで比較する

2026-10-07。公開実装 `48439196aa80f5c2678e8b7a15c1bf4cfcb438b5`、
変更前 `8fe28e552bfc485c4744a193cc9e677b3e2ce309`、
Eigen 5.0.1 `bc3b39870ecb690a623a3f49149a358b95c5781d`。

512変数のsolveは約58 µsから24 µsへ短縮した。128変数の分解＋solveも改善したが、
正式測定ではEigenより3.2〜3.7%遅い。512変数の分解＋solveは中央値でEigenを下回るものの、
比較区間が1をまたぐ。全shape・全phaseの同等性能を達成したとは扱わない。

## 実命令から支持された変更

両者はSSE2、double packet幅2、single-threadである。AVX/FMAの有無を差の原因にしない。
`dumpbin /disasm` による実COFF opcode・symbol・relocated callと、listingを分けて保存した。
object、binary、listing、sourceのSHA-256を `public-objects/manifest.json` で対応付ける。
下のoffsetはCOMDAT内であり、実行addressではない。

| 比較点 | 実命令・変更 | 証拠（validation/performance/large-llt配下） |
| --- | --- | --- |
| 旧forward solve | `023A/0247/025D/0261 subsd xmm2,...` の同じ出力への依存鎖 | `public-objects/actual-solve_into-175.txt` |
| 新forward solve | 4行×2部分和で同じcandidate packetを共有。`01E2 addpd xmm2`、`01EF xmm4`、`01FC xmm5`、`0213 xmm6`、さらにxmm3/8/9/10 | `public-objects/public_large-llt_forward_shared-147.txt` |
| 新trailing更新 | 2出力列×4packetの8 accumulatorへ一つのpanel loadを再利用。各要素の増加k順の減算は維持 | `public-objects/public_large-factorize_column_llt-143.txt` |
| 新除算 | `09BC divpd xmm1,xmm4` 等のexact divisionと有限値mask。reciprocal multiplicationは採用しない | 同上 |
| 新backward solve | 隣接2変数を先に解き、candidateの一度のload/storeで旧順序の二つの減算を行う | `public-objects/public_large-row_update_two_ordered-161.txt` と `public_large-solve_into-177.txt` |
| Eigen | blocked LLTからtriangular solve、SYRK/packed gebp kernelへ進む。複数出力のpacket計算を行う | `public-objects/actual-_blocked-22.txt`、`actual-R__gebp_kernel-129.txt`、manifestのtriangular symbols |

forwardの部分和化は丸め順を変える。後述の数値gateで確認した。
他の更新は各要素の減算順を維持する。factor workspace0、solve workspace n doublesは変わらない。

sqrtのstaticなCRT call siteは負値等のfallback branchであり、正常な正のpivotの
dynamicな呼出し回数を表さない。positive branchの `sqrtsd` と区別した。
PMU/cache missは測定していないため、cache missが支配的とは断定しない。

## 単独変更の対照

panel幅16/32/64、係数packing、4列×4行更新、2×2 transposeによるcopy/restore、
保守的MXCSR条件下の対称性shortcut、固定幅への特殊化を別々に測った。
改善を支持しなかったものは採用していない。部分的なkernel結果を公開API全体の改善と扱わない。
reciprocal multiplicationは128変数に小さい差があるが512変数を改善せず、採用していない。

MSVCのpair更新のinlineとcandidate共有を組み合わせた後、公開headerを改めてコンパイルして測定した。
scalar、WASM、ESPではSSE2を必要としない。`controls/third` の初期短batchは20msを満たさず、
正式受入から除外し、再測定した `third-adaptive` と区別して保存した。

追加の検査対照は `controls/validation-cost` に保存した。
128変数の分解＋solveは検査を除いた対照で約44.8 µs、検査を維持した公開版で約48.7 µsだった。
全入力の有限値と対称性の契約を削除する対照は、原因を測るためだけで採用しない。
走査統合候補は約47.6 µsで、まだ差がある。
大行列用frameを小行列から分離する候補には、明確な全体改善を確認できなかった。

2変数のsetupでは既存harnessが4回の確保を行い、Eigenが3回である。
factor/workspaceを一つのownerへまとめる別のcaller配置で約0.15→0.13 µsになったが、
それでもEigenを下回っていない。これはsolver計算の修正と区別する。
通常の4確保の正式結果を置換・除外しない。

## 正式測定

Intel Core i9-14900K、Windows、CPU0/P-core（CPUID type64）、MSVC19.44.35222.0、
x64 Release `/O2 /fp:precise`、C++20、SSE2。Eigenは通常column-major、kibo factorはrow-major。
5 fresh processes、各30 alternating samples、warmup>=5、各batch>=20ms。
変更前/後のbinary順とcore/Eigenのsample順を交互にした。他のbuild/testと同時に測らなかった。

入力生成とGram/gradient組立ては時間外。input hash一致と独立LDLT解へのrelative error<=1e-8を検証した。
内部copyと入力検査はfactorに含む。setupはinput copy、factor/work/outputの確保と結果ownerの移動を含む。
Eigen solveの既存allFinite確認も維持した。harnessの違う系列の絶対時間は混ぜない。

時間は5 process中央値の中央値、p95は各processのnearest-rank p95の中央値。
Eigen比はsampleでpaired ratioを作りprocess中央値を取り、5^5通りの経験bootstrapから95%区間を求めた。
変更前比は同じprocess番号のmedian時間の比。未合意の10%許容幅は採用しない。
全32項目、変更前・後・Eigenのmedian/p95、前後比、区間は `formal/summary.json` に保存した。

| n | m | phase | 旧版 µs | 修正版 µs | 修正版p95 µs | Eigen µs | 比 [95%] |
| ---: | ---: | --- | ---: | ---: | ---: | ---: | --- |
| 2 | 2 | factor | 0.0180 | 0.0179 | 0.0181 | 0.0329 | 0.5444 [0.5403, 0.5477] |
| 2 | 2 | solve | 0.0149 | 0.0158 | 0.0161 | 0.0207 | 0.7651 [0.6654, 0.7917] |
| 2 | 2 | factor+solve | 0.0462 | 0.0465 | 0.0481 | 0.0541 | 0.8564 [0.8408, 0.8670] |
| 2 | 2 | setup | 0.1515 | 0.1516 | 0.1548 | 0.1103 | 1.3717 [1.3592, 1.3787] |
| 2 | 8 | factor | 0.0180 | 0.0179 | 0.0181 | 0.0329 | 0.5459 [0.5421, 0.5473] |
| 2 | 8 | solve | 0.0149 | 0.0156 | 0.0158 | 0.0234 | 0.6587 [0.5331, 0.7864] |
| 2 | 8 | factor+solve | 0.0461 | 0.0465 | 0.0474 | 0.0555 | 0.8383 [0.7549, 0.8612] |
| 2 | 8 | setup | 0.1514 | 0.1518 | 0.1547 | 0.1105 | 1.3730 [1.3672, 1.3819] |
| 32 | 128 | factor | 1.5439 | 1.5414 | 1.5616 | 2.2134 | 0.6961 [0.6935, 0.6992] |
| 32 | 128 | solve | 0.3159 | 0.3162 | 0.3207 | 0.5577 | 0.5669 [0.5108, 0.5691] |
| 32 | 128 | factor+solve | 1.8782 | 1.8769 | 1.9034 | 2.8418 | 0.6610 [0.6478, 0.6654] |
| 32 | 128 | setup | 2.1414 | 2.1486 | 2.1766 | 3.1617 | 0.6789 [0.6502, 0.6817] |
| 64 | 256 | factor | 8.5137 | 8.4588 | 8.5395 | 8.9377 | 0.9508 [0.9190, 0.9593] |
| 64 | 256 | solve | 0.8781 | 0.8704 | 0.8843 | 1.2639 | 0.6883 [0.6270, 0.6921] |
| 64 | 256 | factor+solve | 9.3997 | 9.3367 | 9.5365 | 10.2365 | 0.9145 [0.8864, 0.9202] |
| 64 | 256 | setup | 10.3412 | 10.2769 | 10.5451 | 12.1839 | 0.8420 [0.8377, 0.8554] |
| 128 | 128 | factor | 52.8946 | 46.3893 | 47.0493 | 43.8658 | 1.0599 [1.0565, 1.0608] |
| 128 | 128 | solve | 3.2000 | 1.9966 | 2.0692 | 3.1795 | 0.6247 [0.5658, 0.6329] |
| 128 | 128 | factor+solve | 56.1172 | 48.5518 | 48.9777 | 47.1222 | 1.0322 [1.0210, 1.0339] |
| 128 | 128 | setup | 60.5411 | 52.7429 | 63.4887 | 56.3446 | 0.9330 [0.9320, 0.9404] |
| 128 | 512 | factor | 53.6636 | 46.7894 | 47.5737 | 43.8906 | 1.0647 [1.0619, 1.0685] |
| 128 | 512 | solve | 3.2004 | 2.0020 | 2.0734 | 3.2108 | 0.6265 [0.5803, 0.6300] |
| 128 | 512 | factor+solve | 56.8006 | 48.8826 | 50.2015 | 47.0960 | 1.0374 [1.0299, 1.0403] |
| 128 | 512 | setup | 60.2862 | 52.5612 | 63.4840 | 56.3798 | 0.9331 [0.9287, 0.9340] |
| 512 | 512 | factor | 2264.6562 | 2067.7531 | 2106.9313 | 2127.8594 | 0.9711 [0.9166, 1.0187] |
| 512 | 512 | solve | 58.1965 | 23.9819 | 24.4281 | 28.7458 | 0.8353 [0.8054, 0.8422] |
| 512 | 512 | factor+solve | 2328.6187 | 2093.5875 | 2140.2000 | 2145.2844 | 0.9799 [0.9677, 1.0267] |
| 512 | 512 | setup | 3191.2625 | 2926.8156 | 2988.2375 | 2996.0469 | 0.9851 [0.9598, 0.9928] |
| 512 | 2048 | factor | 2261.6219 | 2069.1625 | 2106.1438 | 2227.3312 | 0.9355 [0.9140, 1.0214] |
| 512 | 2048 | solve | 58.1623 | 23.8437 | 24.3076 | 28.7379 | 0.8285 [0.8020, 0.8310] |
| 512 | 2048 | factor+solve | 2323.9313 | 2102.5812 | 2138.8812 | 2145.3750 | 0.9883 [0.9774, 1.0304] |
| 512 | 2048 | setup | 3185.7406 | 2945.1188 | 3001.3063 | 3006.1437 | 0.9787 [0.9611, 1.0012] |

## 契約と移植性

`llt_large_tests` は127/128/129/512変数、row/padded-row/interleaved/columnのfactor storage、
全logical upperのclear、padding不変、既知factor/solution、late overflowとpivot失敗を検証する。
Windows、GCC、Clang libc++、ASan/UBSanのDebug/Release、通常/scalar、無確保、例外/RTTI不要を確認した。
公開APIの形状・workspace・失敗時の解保持を変えていない。

[固定sourceのCI](https://github.com/takuto-NA/kibo-linalg/actions/runs/37622909712) と
`hosted/evidence.json` に全job・artifact hash・失敗集合を保存した。
kibo自身の数値gate、LLT large/scalar、一般契約、package consumerは通過した。
PC jobは既存Eigen精度CHECKの各配置8件だけで失敗する。閾値・入力・CHECKは緩和していない。
WASM Node/Chromium/Firefox/WebKit、ESP-S3/C3 cross compileも通過した。
MSVC Release allocationは計測制約によりskip。ESP実機はユーザー回答「実機なし」のため未検証。

## 残作業と再現

128変数の分解、分解＋solve、512変数の区間、2変数のsetupが残る。
検査を保った走査統合、callerの確保/初期化、packed更新の命令を次に切り分ける。
同layout/scalarと全初期shapeの統合受入、QR性能は別の残作業である。
[大行列LLTの課題](https://github.com/takuto-NA/kibo-linalg/issues/24)を達成済みにしない。

生データ・棄却対照・actual source・実object dump・validation・再現scriptは
`docs/validation/performance/large-llt` に保存した。`SHA256SUMS.json` で照合する。
binary/object自体はcommitせずhashを保存した。`sources/harness/CMakeLists.txt`、
`sources/harness/full-adaptive.cpp` と `sources/scripts/run-large-llt-formal.py` は実行時のcommandと対応する。
再現時は固定公開commitとEigenをcheckoutする。各variantの `kibo` include先には、まず
旧版 `8fe28e5` の `include/kibo` 全体を復元して `workspace.hpp` 等の依存headerを揃え、
保存したvariantの `llt.hpp` と `detail/row_kernels.hpp` を上書きする。
公開4843919由来の追加headerが必要なvariantには4843919のincludeも復元し、
`sources/variant-hashes.json` に列挙した全headerのhashと照合する。
保存harnessを `.scratch/large-llt-next` に戻し、MSVC環境を正規化してCMake configure/buildし、
runnerをrepo rootから実行する。部分headerだけをinclude先へ置く手順では再コンパイルできない。
