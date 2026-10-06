# Eigenとの差を減らす連続行カーネル

2026-10-07。最初の正式比較ではWindowsの512変数QRがEigenの約5倍、
LLTが約3.4倍の時間だった。[性能改善ticket](https://github.com/takuto-NA/kibo-linalg/issues/22)で、
競合との差を縮める追加最適化を行う。

## 切り分け

QRの公開APIへ1024行・512列の固定通常fixtureを渡し、factor+solveをEigenと交互に実行。
warmup1、各3回の中央値、全要素の既知解誤差1e-10を確認する短い診断を作った。
最初のcore 134.844 ms / Eigen 29.487 ms（約4.57倍）で、2倍を超える差の診断が失敗した。
この2倍は局所診断の閾値で、公開性能保証やCI gateではない。

候補は有限値検査、vectorizationを妨げるlayout/alias情報、更新のmemory locality、列norm計算。
有限値チェックを単に後続loopへ移すだけでは改善せず、約5.00倍だった。
連続行を独立した内部処理へ渡すとcompilerはprojection/updateをvectorizeしたが、
チェックloopのearly exitが残る構成は約4.23倍だった。
有限値の成否を行単位に集計すると約2.58倍、計算と検査をまとめた通常C++処理では約2.51倍。
SSE2の2要素処理を使うと約2.01倍、4要素を処理して検査maskの依存も分けると約1.66倍だった。
32列/128列に分割した更新はそれぞれ約2.94倍/2.04倍となり、採用しなかった。
単一ケースの短い計測であり、これらを正式5-process比較と合算しない。

LLTは同じ正式harnessの512変数・2048残差だけを切り出し、30 samples/20 ms batchで診断。
列の結果を出力上三角へ写して連続行を更新する方式を試し、
小さなpanelをfactorしてから残りの行をまとめて更新する方式へ進めた。
追加heap/workspaceは使わない。診断のEigen比は約3.31倍から約1.70倍に縮まった。
最初の正式結果は後述の5-process測定で判断した。

## 採用する処理と契約

連続行のproject、checked update、panel updateをprivate headerに集める。
コンパイル対象がSSE2を含むx86だけで、unaligned packetを使う。高いISAを必須にしない。
NaN/Infはabs(value)<=max(double)のordered比較とpacket maskで検出し、scalar tailも検査する。
要素ごとの乗算・加減算の順を保ち、FMAや横方向の再結合を導入しない。
失敗したQR factor storageは全体が無効なので、同じ行の追加要素を更新してから
arithmetic_failureを返しても、公開失敗契約は変わらない。

最初の候補はLLTの連続行storageでn>=32のときに8列panelを使い、上三角を現在の下三角columnのmirrorにする。
各係数はkの昇順で減算し、次のpivot/columnを利用する前に有限性を検査する。
成功時は上三角を0へ戻す。column-majorや非単位column strideは従来のscalar解法を使う。
factor workspace=0、QR=2n doubles、solveの候補出力を完成してからcommitする契約は変えない。

`KIBO_DISABLE_SIMD=1`でC++ fallbackを選択する。WASM baseline/ESPはこのfallbackで動く。
scalar benchmarkはこの定義とEigenのSIMD無効化を同時に指定する。
奇数寸法、8列panel境界、padded row/column、非単位stride、既知解、padding保持を
公開APIから確認し、同じtestsをSSE2とfallback双方で実行する。

精度gateを緩める変更は含まない。大残差の未達と実機受入は別に残す。

## 正式測定

Windowsの5独立processで、512変数・2048残差のfactor+solveは
QR390.754→144.644 ms（core2.701倍改善）、LLT6.770→3.432 ms（1.972倍改善）。
Eigenへのpaired比はQR1.815 [1.759,1.909]、LLT1.747 [1.720,1.786]。
通常fixtureの独立解照合、容量上限64 MiB以下を通過した。
[正式報告](../validation/2026-10-07-contiguous-performance.md)に全規模・phase・scalar系列を保存する。
source2462796の数値headersとCMakeは、[全環境CIのsourceb20118e](https://github.com/takuto-NA/kibo-linalg/actions/runs/37506029228)とbyte単位で同一。
通常版/fallback公開tests・準備済み無確保・WASM/ESP cross compileを確認した。
precision gateは未達のまま維持し、Eigenより速いとの結論は出していない。

## LLT処理選択の追加修正

source2462796の両系列5-processで、Windows32変数LLTのfactor+solveが変更前比1.205、
scalar128変数LLTが約1.23となり、20%悪化のレビュー対象になった。
scalar2変数のfactor単独にも約2倍の悪化があった。
[中間測定と全phaseの変更前比較](../validation/2026-10-07-contiguous-performance.md)は履歴として保持する。

panelの処理を内部関数へ分離し、SSE2有効・unit column stride・n>=64に選択を限定した。
それ以外は従来のscalar LLTに戻す。private処理の追加で小さい入口の展開を妨げない構成にする。
64/65の公開APIで通常版/fallback双方の境界・padding・失敗通知を確認した。
短い5形状診断ではWindows32変数が変更前比約1.01、scalar128変数が約0.99に戻った。
この診断は5-process正式値には混ぜない。[修正版の正式比較](../validation/2026-10-07-dispatch-performance.md)で評価する。


修正版source83c7a14の5-process正式測定では、Windowsの最大QRを137.587 ms、LLTを3.469 msへ短縮した。
Eigenへのpaired比はQR1.688、LLT1.714で、まだ遅い。
Windows32変数LLTは初期baseline比0.979 [0.971,1.009]、scalar128変数LLTは0.989 [0.977,1.011]に戻った。
全80phaseの変更前比較で、Windows2変数・8残差のQR factor+solveは0.266→0.321 µs（1.208 [1.175,1.216]）となり、20%悪化のレビュー対象が1件残る。
scalarのレビュー対象は0件。小規模QRの改善と性能の総合受入は[PC性能ticket](https://github.com/takuto-NA/kibo-linalg/issues/16)に残し、解消済みとはしない。
