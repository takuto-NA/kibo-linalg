# Solverの配置と入力検証を改善する

2026-10-07。[原因調査](../research/eigen-root-cause.md)で確認したボトルネックを公開実装へ反映した。
対象はLLTの列方向panelと検証の走査、QRのrow/column kernelとcopyである。
対称性・有限値・更新時overflowの検査、Status、caller storage/workspaceの契約を維持する。
診断試作の検査遅延は採用していない。

512変数・2048残差では、LLTは3.757→2.605 ms、QR rowは167.358→158.226 ms、
QR columnは427.265→105.296 msとなった。同layoutのprocess対応比では時間をそれぞれ32.1%、5.1%、75.5%削減。
通常Eigenへの時間比はLLT1.116、QR row1.682、QR column1.150であり、全形状の同等性能には到達していない。
32変数LLTはEigen比1.87〜1.88、8変数・32残差QR columnは1.59など、中小規模にも差が残る。
LLTの8変数・8残差は旧版比1.030 [1.020,1.039]の小さな悪化がある。
20%以上の悪化が95%区間込みで再現したcaseはなかった。

各process内p95の5 process中央値もcomparisons.jsonに保存した。最大caseのQR row p95は
195.656→200.916 msで改善しておらず、中央値の短縮をtail latencyの改善とは扱わない。

## 変更と原因

- LLTは64列以上の連続行・SSE2経路で、既存storageの転置ビューを使って8列panelを連続方向へ計算する。
  この変更により、4096-byte行間隔の列アクセスで観測したpanelの遅さを回避する。
  係数の一時領域も既存storageの未使用上三角を使い、成功時にcallerのlower layoutへ戻して上三角を0にする。
- LLTの入力有限性と最大絶対値を1走査で求める。両三角を検査し、同一値の対称要素だけは割り算を省く。
  異なる要素には従来と同じ正規化差と閾値を使う。対称性を無効化する高速化はしていない。
  後続行列更新は16出力をregisterで保持してループ回数を減らす。
- QRのrow格納は4行でprojectionのload/storeを共有する。column格納は4列でHouseholder vectorを共有し、
  projectionとchecked updateをまとめる。連続列のsolveもSIMD化した。
  factorのcopyは検証済み入力を再検証せず、row→columnでは8×8 tileを使う。
- QRの更新検査は各pivotを進める前に全要素へ行う。solveの残差側のoverflowも検出し、失敗時の出力を保持する。
  公開API、factor storageの配置、自然alignment、追加workspace量は変えない。

列方向LLTでpanel幅32も試したが、短い対照で8列より遅くなったため採用していない。
packingの違いが支配的という仮説は先行microprobeで支持されておらず、この変更の説明には使わない。

## 比較条件

旧版は公開source `83c7a143599cd9e73bc97e6ecae3680daee3418f`。計測時計を挿入した診断snapshotではなく、
Gitから元のheader bytesを取り出して同じharnessで再ビルドした。
修正版の公開実装は`512721484157f3fc4ad5c04c91af3d1318c291c9`。
測定中のsource SHA256とpublic.patchも保存している。
CPUはi9-14900Kのlogical CPU0/P-coreに固定。MSVC19.44.35222.0、C++20、
Release `/O2 /Ob2 /DNDEBUG /fp:precise`、fast-mathなし、single-thread、両backendともSSE2 double packet=2。
Eigen5.0.1の固定archiveと全header bytesを照合した。

Jは既存の固定seed fixture、lambda=1e-3、D=I。n=2/8/32/128/512、m=n/4n。
LLTはnormal system、QRはm+n行のaugmented systemを使う。
独立Eigen LDLT oracleとのrelative error1e-8を毎sampleで確認する。
LLTは両版ともrow factor storage、QRはrowとcolumnを別caseで測る。Eigenはcolumn-majorである。
外部buffer準備・入力組立て・Eigen用の事前column copyは時間外。
内部copy・検査・factor+solveを時間に含め、setup/allocation込み時間と混同しない。

各target/shapeは5 fresh processes、5 warmups、30交替samples。
両backendで25ms以上になる共通batchを選び、実sampleが20ms未満の観測を無効にする。
target/shape順をprocessごとに固定seedでshuffleし、全負荷を直列実行した。
時間はprocess中央値の5 process中央値、比率はprocess内中央値の比の5 process中央値。
95%区間は5 processの経験分布から5個選ぶ全5^5 bootstrapの中央値の2.5/97.5 percentiles。
同じprocess内の30 samplesを独立processとして扱わない。
p95は30 samplesのnearest-rank（29番目）をprocessごとに求め、その5 process中央値を記録する。

初回300実行のうち2実行（n128/m512、process2の修正版QR row/column）は、
校正後の一部batchが20ms未満となったため時間規定で不採用とした。解照合は両方成功している。
同じbinary・入力で各実行全体を1回ずつ再実行し、両方とも時間・解照合に合格した。
[accepted-manifest.json](performance/solver-locality/accepted-manifest.json)の300実行・9000 paired samplesを採用し、
元のmanifest・不採用raw・再実行commandをすべて保存している。速さによる除外はしていない。
初回summary.jsonは不採用実行を含むため、最終集計にはcomparisons.jsonを使う。

[再現harness](../../tools/diagnostics/solver-locality/)、
[manifest・raw samples・hashes](performance/solver-locality/)、
[比較集計](performance/solver-locality/comparisons.json)を保存した。
以前のCPU未固定系列の時間とは合算しない。

## LLT（row factor storage）

| n | m | 旧版 ms | 修正版 ms | Eigen ms | 新/旧 [95%] | 修正版/Eigen [95%] |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 2 | 2 | 0.000047 | 0.000047 | 0.000051 | 0.996 [0.986, 1.059] | 0.940 [0.930, 0.986] |
| 2 | 8 | 0.000048 | 0.000046 | 0.000050 | 1.001 [0.951, 1.007] | 0.925 [0.913, 0.956] |
| 8 | 8 | 0.000385 | 0.000397 | 0.000330 | 1.030 [1.020, 1.039] | 1.205 [1.171, 1.229] |
| 8 | 32 | 0.000387 | 0.000400 | 0.000336 | 1.027 [0.985, 1.034] | 1.189 [1.132, 1.241] |
| 32 | 32 | 0.005574 | 0.005446 | 0.002891 | 0.958 [0.939, 0.983] | 1.884 [1.858, 1.896] |
| 32 | 128 | 0.005569 | 0.005361 | 0.002871 | 0.959 [0.926, 0.963] | 1.868 [1.867, 1.872] |
| 128 | 128 | 0.120291 | 0.070407 | 0.048322 | 0.597 [0.583, 0.641] | 1.490 [1.450, 1.529] |
| 128 | 512 | 0.121226 | 0.070946 | 0.048406 | 0.589 [0.585, 0.611] | 1.494 [1.189, 1.538] |
| 512 | 512 | 3.759041 | 2.529644 | 2.270178 | 0.674 [0.657, 0.696] | 1.147 [1.114, 1.164] |
| 512 | 2048 | 3.757231 | 2.604550 | 2.344737 | 0.679 [0.631, 0.716] | 1.116 [1.103, 1.158] |


## QR（row factor storage）

| n | m | 旧版 ms | 修正版 ms | Eigen ms | 新/旧 [95%] | 修正版/Eigen [95%] |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 2 | 2 | 0.000135 | 0.000124 | 0.000199 | 0.908 [0.857, 0.925] | 0.617 [0.615, 0.623] |
| 2 | 8 | 0.000313 | 0.000250 | 0.000226 | 0.805 [0.750, 0.847] | 1.109 [1.087, 1.137] |
| 8 | 8 | 0.001720 | 0.001446 | 0.001084 | 0.854 [0.792, 0.858] | 1.334 [1.282, 1.343] |
| 8 | 32 | 0.004105 | 0.003353 | 0.001406 | 0.822 [0.811, 0.837] | 2.407 [2.383, 2.431] |
| 32 | 32 | 0.031201 | 0.025927 | 0.012492 | 0.855 [0.804, 0.879] | 2.077 [2.058, 2.124] |
| 32 | 128 | 0.080709 | 0.068936 | 0.028808 | 0.874 [0.769, 0.916] | 2.387 [2.340, 2.437] |
| 128 | 128 | 0.940891 | 0.857577 | 0.496907 | 0.914 [0.897, 0.943] | 1.761 [1.726, 1.799] |
| 128 | 512 | 2.441934 | 2.213522 | 1.109927 | 0.899 [0.891, 0.935] | 1.988 [1.924, 2.025] |
| 512 | 512 | 61.437400 | 54.411250 | 32.765450 | 0.905 [0.801, 0.964] | 1.661 [1.624, 1.707] |
| 512 | 2048 | 167.358100 | 158.225650 | 94.666100 | 0.949 [0.900, 0.955] | 1.682 [1.671, 1.710] |


## QR（column factor storage）

| n | m | 旧版 ms | 修正版 ms | Eigen ms | 新/旧 [95%] | 修正版/Eigen [95%] |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 2 | 2 | 0.000126 | 0.000114 | 0.000209 | 0.906 [0.888, 0.972] | 0.570 [0.536, 0.579] |
| 2 | 8 | 0.000282 | 0.000202 | 0.000227 | 0.718 [0.658, 0.724] | 0.894 [0.860, 0.896] |
| 8 | 8 | 0.001946 | 0.001082 | 0.001083 | 0.559 [0.534, 0.581] | 1.007 [0.995, 1.016] |
| 8 | 32 | 0.004618 | 0.002268 | 0.001412 | 0.490 [0.484, 0.498] | 1.590 [1.580, 1.624] |
| 32 | 32 | 0.080107 | 0.019392 | 0.012563 | 0.242 [0.242, 0.247] | 1.553 [1.527, 1.568] |
| 32 | 128 | 0.160374 | 0.047267 | 0.028134 | 0.295 [0.293, 0.318] | 1.680 [1.637, 1.732] |
| 128 | 128 | 3.841428 | 0.666786 | 0.509302 | 0.173 [0.168, 0.184] | 1.321 [1.287, 1.389] |
| 128 | 512 | 9.208109 | 1.650000 | 1.109898 | 0.180 [0.178, 0.185] | 1.487 [1.486, 1.534] |
| 512 | 512 | 204.812150 | 37.034900 | 33.091550 | 0.181 [0.180, 0.191] | 1.127 [1.119, 1.152] |
| 512 | 2048 | 427.265400 | 105.295550 | 91.839750 | 0.245 [0.244, 0.247] | 1.150 [1.106, 1.167] |


row→columnの結果には配置変更が含まれる。callerのrow storageを黙ってcolumnへ変更するAPIにはしていない。
columnを選ぶには`MatrixView<double>::checked(buffer,m,n,1,m)`を使う。
同layoutの旧版比較と、通常Eigenのcolumn格納との比較を上表で区別した。

## 正しさと残る受入

Windows MSVC Release/Debugのsolver・scalar fallback、自然alignmentとpadding、既知解、失敗Status、
更新時overflow・出力保持を検証した。LLTのvector検証には65列のtail、両三角のNaN/Inf、
対称性閾値ちょうどとnextafter直上を追加した。
Windows Debugの校正付き無確保probe、Linux Clang ASan/UBSanの2〜512変数全形状の
無確保probeへQR column格納も加えた。MSVC Release allocation測定は既存どおりskipである。
WASMは固定Emscriptenで再ビルドし、固定Nodeの数値・容量検査を通した。

既存の厳しい数値gateは緩和・skipしていない。Windows/GCC/ClangのReleaseではrowのnumericalに19件の未達が残る。
今回追加したcolumnの同じsuiteは18件未達。旧columnを同じsuiteで動かすと19件であり、
column対応を追加して全入力の精度受入が済んだとは扱わない。
Debugの小規模suiteはrow/columnとも17件未達。通常fixtureの独立解照合を、悪条件・大残差での速度優位へ一般化しない。

実装commitの[hosted CI](https://github.com/takuto-NA/kibo-linalg/actions/runs/37578152963)でも、
Windows・GCC・Clang・Clang ASan/UBSanの失敗はこの2数値testに限られる。
その他のtest、無例外/RTTI consumer、移動後find_packageは通過した。
WASMのNode・Chromium・Firefox・WebKit、ESP32-S3/C3のcross compileは成功した。
[実command・test出力・hash](performance/solver-locality/validation/)を保存した。
測定workspaceとCI commitのinclude/tests/CMakeLists.txtはCRLF→LF正規化後のbytesを照合した。
manifestのsource SHA256は正規化前の測定ファイルを示す。
ESP各実機は未検証のままである。

[PC性能受入](https://github.com/takuto-NA/kibo-linalg/issues/16)、
[精度保証](https://github.com/takuto-NA/kibo-linalg/issues/15)、
[ESP実機受入](https://github.com/takuto-NA/kibo-linalg/issues/19)は継続する。
全形状でEigen同等の性能、setup全phaseの更新、全platformのrelease readinessは完了扱いにしない。
