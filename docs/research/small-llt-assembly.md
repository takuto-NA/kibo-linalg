# LLTの小行列境界と入力検査を命令から改善する

2026-10-07。公開実装 `8fe28e552bfc485c4744a193cc9e677b3e2ce309`。
Eigen 5.0.1、commit `bc3b39870ecb690a623a3f49149a358b95c5781d` と比較する。
以前の32変数の修正だけでは31変数に約2倍の時間差が残っていた。
今回も最小の公開API再現、実COFF objectの逆アセンブル、単独変更を突き合わせた。

## 支持された原因と修正

固定MSVCの従来の31×31入力走査は、要素ごとに `_dclass` を呼び、最大絶対値も別に走査していた。
全入力の有限値検査を維持して走査をまとめ、scalar tailも順序付きabs比較にする。
実objectの新しい `factorize_llt` にはこのCRT呼出しがない。
staticなcall site数と、961要素を通過するdynamic call回数を区別する。

従来の小行列分解は一つの出力へ `mulsd/subsd` を繰り返す。
Eigenのunblocked LLTは、連続列のGEMVを使い、`mulpd/addpd` を複数の出力packetへ並行して蓄積する。
この複数accumulatorは異なる出力行を担当する。
同じ出力の内積を4個の部分和へ分けるという説明とは区別する。
双方SSE2・double packet幅2で、AVX/FMAの有無の差ではない。

9〜64変数のrow-contiguous factor storageは、transposed viewを通して新しい列へ既存列を適用する。
先行列の順序を維持し、factor用の追加workspaceは0のままである。
入力copy、lower triangleの復元、backward solveも単独対照と明示した組合せで確認した。
128/512変数では同じleft-looking方式が遅くなったため、この方式を全サイズへ広げていない。

これだけでは31変数のfactorに18〜20%の差が残った。
現在候補から有限値走査だけ、対称性だけ、両方を順に外す原因対照で、
factor約1.81 µsのうち、両検査を外すと約1.22 µsになることを確認した。
これらの対照は公開契約を満たさず、採用していない。

有限値と最大値の走査には、`maxpd` とvalid maskの一つずつの依存鎖があった。
連続したdense inputを一走査し、4本の独立packet accumulatorで走査して最後に結合する。
実objectでも `maxpd` の更新先が複数のレジスタへ分かれている。
同じSSE2幅で依存関係を変えた効果であり、より広いISAへ変更した結果ではない。

対称性は2×2 tileの連続loadとunpackで比較する。
完全一致しない値にも元と同じ `abs(a/scale-b/scale)<=tolerance` を適用する。
tileが不合格なら元のscalar row順で再検査し、失敗indexと出力保持を維持する。
完全一致だけのshortcutは31変数で効果がなく、許容誤差まで含む対照で改善を確認した。

実命令の確認箇所を以下に示す。offsetは各COFF COMDAT内の位置である。
listingだけでなく、`dumpbin /disasm` のopcodeとrelocated call名を保存した。

| 比較点 | 旧版/修正版の実命令 | 保存ファイル |
| --- | --- | --- |
| 旧入力検査 | `0208: E8 00 00 00 00 call _dclass`、`02E4`にも別経路のcall site | `final-objects/baseline-factorize_llt-149-object.txt` |
| 旧分解の依存鎖 | `06E8/06F6/0708/070C`で繰り返し `subsd xmm2,...` | 同上 |
| 修正後の最大値走査 | `0240 maxpd xmm2,xmm1`、`025B ... xmm6`、`0276 ... xmm10`、`0291 ... xmm11` | `final-objects/actual-factorize_llt-148-object.txt` |
| Eigenの列GEMV | `01F8 addpd xmm3,xmm0`、`0204 ... xmm4`、`0213 ... xmm5` | `final-objects/actual-run-7-object.txt` |
| 修正後のpanel | `mulpd/subpd`を各出力packetへ適用。calleeの保存命令も含む | `final-objects/actual-row_update_panel-151-object.txt` |

ファイルのsymbol、object/binary/listing/full dump hashと実commandは
`final-objects/manifest.json`で照合できる。n31で選ばれるscalar分解、n32以上の旧panel、
修正後の9〜64の分岐を区別し、実行されない分岐のstatic命令数を原因量にしない。

## 棄却した対照

零から積の和を作って最後に一回減算する更新、6要素SIMD末尾処理、対角和の2 accumulator化、
係数copyの統合、reciprocalによる除算置換、強制inline、panel幅だけの変更は、
対象の公開factor+solveを明確に改善しなかった。採用していない。
calleeのstack frameやXMM保存は逆アセンブルで確認したが、inline対照が全体を速くしなかったので
主要因とは断定しない。hardware counterによるcache missは測定していない。

## 測定条件

Intel Core i9-14900K、Windows、CPU0/P-core（CPUID type64）、MSVC19.44.35222.0、
x64 Release `/O2 /fp:precise`、C++20、SSE2、single-thread。
Eigenは通常のcolumn-major、kiboの公開LLT factorはrow-major。
両者が同じ丸め済み入力を使うことをhashで確認し、独立LDLT解へrelative error1e-8以内で照合する。
入力生成とGram/gradient組立ては時間外。内部copy/validationはfactorの時間に含む。

短い単独変更対照と正式測定を別のdirectoryへ保存する。
正式測定は5 fresh processes、各30 alternating samples、warmup>=5、各batch>=20 ms。
process中央値、process p95、前後のprocess対、Eigen比、5^5通りの経験bootstrap 95%区間を報告する。
1.1という旧診断probeのexit signalを同等性能の許容幅として採用しない。

factor+solve専用probeと4-phase probeは別の測定系列である。
4-phase probeのEigen solveには既存harnessのallFinite確認も含む。
setup phaseは入力copyと一時的なfactor/work/outputの確保を含み、結果ownerを移して時間外に検証する。
絶対時間と比を異なるharness間で混ぜない。

## 結果と範囲

| n | m | 旧版 µs | 修正版 µs | Eigen µs | 修正版/Eigen [95%] |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 2 | 2 | 0.044 | 0.041 | 0.050 | 0.821 [0.816, 0.825] |
| 2 | 8 | 0.044 | 0.041 | 0.050 | 0.818 [0.772, 0.826] |
| 8 | 8 | 0.326 | 0.215 | 0.329 | 0.655 [0.652, 0.656] |
| 8 | 32 | 0.326 | 0.216 | 0.332 | 0.652 [0.647, 0.656] |
| 16 | 16 | 1.174 | 0.530 | 0.799 | 0.664 [0.658, 0.667] |
| 16 | 64 | 1.185 | 0.532 | 0.799 | 0.666 [0.663, 0.671] |
| 31 | 31 | 4.222 | 1.777 | 2.115 | 0.841 [0.819, 0.842] |
| 31 | 124 | 4.247 | 1.776 | 2.103 | 0.844 [0.813, 0.846] |
| 32 | 32 | 2.761 | 1.860 | 2.811 | 0.662 [0.643, 0.663] |
| 32 | 128 | 2.764 | 1.858 | 2.880 | 0.644 [0.641, 0.666] |
| 33 | 33 | 3.006 | 1.987 | 3.249 | 0.611 [0.580, 0.613] |
| 33 | 132 | 3.011 | 1.983 | 3.250 | 0.611 [0.593, 0.613] |
| 64 | 64 | 12.448 | 9.383 | 10.507 | 0.893 [0.839, 0.905] |
| 64 | 256 | 12.326 | 9.405 | 10.449 | 0.903 [0.869, 0.908] |
| 128 | 128 | 65.620 | 56.550 | 48.232 | 1.172 [1.166, 1.192] |
| 128 | 512 | 66.336 | 57.095 | 48.188 | 1.186 [1.180, 1.186] |
| 512 | 512 | 2481.841 | 2351.125 | 2180.634 | 1.081 [1.025, 1.085] |
| 512 | 2048 | 2472.081 | 2342.109 | 2259.528 | 1.031 [1.020, 1.059] |


4-phase系列の比は次の通り。各cellはprocess中央値の比 [経験bootstrap 95%区間]。
factor+solve専用系列と時計の取り方が異なるため、上表の絶対時間へ混ぜない。

| n | m | factor/Eigen | solve/Eigen | factor+solve/Eigen | setup/Eigen |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 2 | 2 | 0.543 [0.527,0.545] | 0.720 [0.711,0.722] | 0.851 [0.839,0.855] | 1.376 [1.335,1.381] |
| 2 | 8 | 0.543 [0.532,0.550] | 0.711 [0.638,0.722] | 0.842 [0.831,0.856] | 1.374 [1.331,1.393] |
| 8 | 8 | 0.566 [0.563,0.571] | 0.573 [0.497,0.585] | 0.647 [0.618,0.655] | 0.818 [0.783,0.830] |
| 8 | 32 | 0.568 [0.563,0.572] | 0.574 [0.497,0.586] | 0.650 [0.622,0.656] | 0.821 [0.785,0.846] |
| 16 | 16 | 0.680 [0.675,0.689] | 0.556 [0.497,0.560] | 0.664 [0.645,0.673] | 0.732 [0.710,0.737] |
| 16 | 64 | 0.685 [0.607,0.690] | 0.562 [0.497,0.563] | 0.672 [0.597,0.676] | 0.735 [0.683,0.743] |
| 31 | 31 | 0.934 [0.927,0.942] | 0.554 [0.393,0.562] | 0.848 [0.760,0.853] | 0.831 [0.823,0.839] |
| 31 | 124 | 0.924 [0.860,0.937] | 0.555 [0.507,0.565] | 0.840 [0.774,0.845] | 0.840 [0.791,0.849] |
| 32 | 32 | 0.693 [0.691,0.696] | 0.566 [0.515,0.575] | 0.659 [0.640,0.662] | 0.668 [0.661,0.677] |
| 32 | 128 | 0.697 [0.667,0.699] | 0.571 [0.506,0.577] | 0.657 [0.640,0.662] | 0.660 [0.630,0.673] |
| 33 | 33 | 0.627 [0.624,0.630] | 0.552 [0.502,0.561] | 0.610 [0.599,0.612] | 0.627 [0.624,0.628] |
| 33 | 132 | 0.626 [0.599,0.640] | 0.505 [0.503,0.584] | 0.597 [0.578,0.618] | 0.628 [0.613,0.635] |
| 64 | 64 | 0.896 [0.875,0.960] | 0.631 [0.629,0.697] | 0.862 [0.841,0.923] | 0.850 [0.844,0.856] |
| 64 | 256 | 0.952 [0.937,0.960] | 0.691 [0.638,0.696] | 0.907 [0.895,0.916] | 0.852 [0.848,0.856] |

全形状のmedian/p95、変更前後比と区間は[4-phase集計](../validation/performance/small-llt/final-full/comparisons.json)、
[factor+solve専用集計](../validation/performance/small-llt/final-public/comparisons.json)に保存した。
2変数のsetup差は残る。現在のharnessはcoreにcopy/factor/work/outputの4領域、
Eigenにcopy/factor/outputの3領域を毎回確保する。確保をまとめる対照と実ownerの費用を今後測る。
ここではharnessを変更して既存結果を置き換えていない。

31/32/33の境界だけでなく、2/8/16/64を回帰対照、128/512を未完の大規模対照として保存する。
小さいcaseの結果をQR、全CPU、未知の入力に対するEigen同等保証へ一般化しない。
大規模LLT、QRのrow/column配置、数値未達は別のIssueに残す。
2変数のsetup phaseも残る。計算本体の優位から一時領域確保を含む全phaseの合格を推論しない。

## 検証と再現

既知のdense lower factor、8/9/15/16/31/32/33/48/64/65の境界、4つのfactor stride/padding、
NaNを含むinput padding、有限値走査の各packetとtail、対称性の許容境界、
複数tileの不一致index、late pivot/overflow、backward overflow時の出力保持を検証する。
通常版、SIMD無効版、無例外/RTTI、校正付きprepared allocation probeを維持する。
既存の精度gateを変更せず、変更前後の失敗fixture集合と数値を別に保存する。

[公開実装8fe28e5のCI](https://github.com/takuto-NA/kibo-linalg/actions/runs/37602800569)は、
Windows/GCC/Clang/Clang ASan・UBSanのDebug/Releaseで通常・scalar・無例外/RTTIの契約testを通過した。
各PC jobの失敗testはnumericalとnumerical_columnだけで、Debugは17/17件、Releaseは19/18件。
変更前後の数値CSV、oracle診断、失敗を含むlogも保存している。
正常系の速度比較の解照合と、これらの未達精度gateを区別する。

校正付きprepared allocation probeはWindows DebugおよびGCC/Clang/sanitizedのDebug/Releaseで0回。
Windows Releaseはskipであり、0回測定の証拠へ置換しない。
移動後find_package consumer、WASMのNode/Chromium/Firefox/WebKit、ESP-S3/C3のC++20 cross buildも通過した。
ESP32実機は利用者が現在持っていないため、heap/stack/serialの実機受入は未検証。
実command・firmware/module hash・test logは[hosted検証証拠](../validation/performance/small-llt/validation/hosted/evidence.json)に保存する。

raw seriesは`final-public`と`final-full`、短い単独変更は`controls`、
途中の正式候補は`pre-validation-public/full`へ分離した。
`initial-objects/final-objects`は実COFF dumpとcompiler listing、`sources/variants`は対照header、
`sources/public-commit-hashes.json`は公開commitとLF正規化の照合、`SHA256SUMS.json`は保存ファイルのhashである。
コンパイルの末尾と重なった`.scratch/small-llt-range`は正式証拠に含めない。

[再現source](../../tools/diagnostics/small-llt/README.md)、
[raw・hash・実object命令・compiler listing](../validation/performance/small-llt/)を参照。
棄却した対照も残し、コンパイルと重なった測定は正式系列に採用しない。
