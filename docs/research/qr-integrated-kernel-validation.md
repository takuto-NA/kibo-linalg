# QRの命令対照を統合し、配置と検査の費用を減らす

Issues25/26の単独対照を組み合わせ、公開QRへ反映するための記録。
基準は19e210a、Eigen5.0.1のbc3b39870ecb690a623a3f49149a358b95c5781d。
MSVC19.44、Release /O2 /fp:precise、SSE2、単一P-coreを固定した。
同じrow入力の拡張最小二乗系と右辺を両者に渡し、Eigenの最良column factorへのcopyも計測内に含める。
独立scalar比較と正式5 process×30 samplesの受入は後続の記録に分ける。

## 保存した対照

[組合せ対照](../validation/performance/qr-combined-controls/SHA256SUMS.json)は240実行、3 process×5 samples。
[配置・三角solve・norm・packet対照](../validation/performance/qr-integrated-controls/SHA256SUMS.json)は68実行、1 process×5 samples。
どちらもwarmup5、backend順交替、各backendのbatch20ms以上、4phaseのraw JSONLとbinary hashを保存した。
実際のCOFFをdumpbin /disasmした全文をgzip、対象関数をtextで保存し、同じtranslation unitのEigen命令も含めた。
sourcesと最小CMakeListsを保存し、固定Eigen headersをEIGEN_SOURCE_DIRへ渡して再現できる。
source annotationだけをアセンブリ証拠とは扱わない。hardware counterは測定していない。

## 公開実装に採用する処理

- 有限入力検査を連続方向のSSE2 ordered比較にし、logical paddingを読まない。scalar・一般strideも検査する。
- column normは通常範囲でpacket平方和を使い、非有限または小さすぎる和ではScaledSquaresへ戻す。
  平方和の試行はFP sticky overflowを立てることがある。浮動小数点例外をtrapする環境は保証していない。
- 通常範囲のHouseholder係数は安全な分母を確認してreciprocalを共有する。極端な分母には従来のscaled計算を残す。
- 更新結果の有限検査は指数maskとMAXPDの4独立累積器へまとめる。checked8実COFFの主loopは0070からで、MULPD/SUBPDと4packetの検査を確認できる。
- tight row factorでn>=8、mがnの倍数、m/n<=64の場合は、同じfactor bufferを内部column配置で計算してcaller row配置へ戻す。
  既存2n doublesのworkspace内で、n doublesのblock退避と残りのvisited bitsを使う。
  row復元はSSE2のblock移動と2×2 transposeを使い、copyと復元の費用はfactor phaseに含む。
  callerへ返すstrideは元のまま。対象外の寸法・padding・一般strideは従来の配置経路を使う。
- column Rは列方向の更新、row Rは連続dotを使う。row Qはstrided packet、n>=256かつ4の倍数では4reflector panelを使う。
  panelの係数・値域を確認し、使用できなければ元rhsから通常Q適用へ戻す。
  4reflectionの更新をlocal値へまとめた対照は、実COFFの0AC2で最後の一回のstoreを確認した。
  panelは既存candidateの10 doublesを一時使用し、追加確保はしない。

公開のfactor workspaceは2n、通常solveはm+n doublesのまま。
無確保、例外・RTTI不要、失敗時の解保持を維持する。

## 採用前の診断結果

以下はfinal private candidateの1×5診断値であり、公開修正後の正式受入値ではない。
比はkibo/Eigenで、1未満がkiboの短い時間。

| row factor / best Eigen | factor+solve µs | 比 | setup/copy込み µs | 比 |
| --- | ---: | ---: | ---: | ---: |
| n8、m32 | 1.3588 | 0.9112 | 1.5928 | 0.9387 |
| n32、m128 | 28.2935 | 0.9435 | 29.8829 | 0.9683 |
| n128、m512 | 1264.08 | 0.9983 | 1565.7 | 1.0479 |
| n512、m2048 | 94074.1 | 0.9892 | 97851.2 | 0.9604 |

column512のchecked8対照はsolve369.589µs、Eigen比0.8551、両方91298µs、比0.9673。
row512のsolveは1501.24µs、最良Eigen比3.5366で残差がある。
内部column計算によりrow512 factorは約143msから約92msへ減ったが、返却後のrow Q適用は依然として費用が大きい。
row128のsetup比1.0479も未解消。両方の合計が近いことだけで全phaseを受入しない。
bounded exponent guardを平方の前に置くnormは8/32/128で遅く、採用しない。
force-inline projectionと常時2pass normも、単独改善だけで全体に採用しない。

## 演算順序変更の失敗を修正する

レビューでR solveのfinite-input regressionが見つかった。
M=DBL_MAX、A=[[2,.7,.7],[0,.1,0],[0,0,.1]]、b=M*[.4,.09,.09]では、
元のj昇順減算は有限だがrow dotの独立累積は-1.26Mへoverflowする。
A[0,2]=-.7のcolumn更新では、先にj2を引く順序がoverflowする。
高速Rが非有限なら、保存済みtransformed RHSから三角solve全体を元のj昇順で再計算する。
candidateの部分結果を引き継がず、成功時だけcaller outputへ反映する。

同型のQ regressionも小入力で確認した。
m17/n2、第一列のrow1..16が交互±1、第二列=e1-e3、b0=.1M、他のb=.6Mのrow factorは、
元の順次dotでは相殺されて解けるが、SIMD分割累積がoverflowする。
高速Qが非有限なら元rhsからQ適用全体を旧順序で再試行する。
元経路自身が失敗するm9/n2の例でも元のfailure index=1と出力保持を検証する。
3×3の両符号・row/column/一般strideと17×2を回帰に追加した。
private候補はこれらの回帰追加前の診断なので、公開契約の合格とは区別する。

## 公開ソフトウェア検証と残作業

公開ヘッダーでPC全8 Debug/Release構成のkibo CHECKが通過した。
SIMD/scalar、失敗契約、ASan/UBSan、無確保と例外/RTTI不要を含む。
独立100桁oracleは7構成×102=714件を通過し、補正解の最大oracleForwardは9.09082e-17だった。
全8構成のCTest失敗集合は各16件の既存Eigen精度CHECKのみ。
Windows Releaseのallocation testは既存probe条件によりskipであり、Windows DebugとLinux6構成では実行して通過した。
WASM NodeとChromium/Firefox/WebKit、ESP32-S3/C3クロスビルドも通過した。
installed consumerは新しいbuild directoryで移設先をfind_packageしてbuild・実行した。
[公開検証archive](../validation/numerical/qr-optimized-public/metadata.json)に結果と固定source hashを保存する。
Eigenの既存精度CHECKはユーザー判断が未回答のため全て維持する。
ESP32実機は現在ない。クロスビルドで実機受入を済ませたとは扱わない。
全10shape・各layout・全phaseの正式性能、Linuxの公平なscalar対照を終えるまで、Issues25/26/16は完了としない。
