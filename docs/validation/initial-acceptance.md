# 初期保証の受入状況

2026-10-07。実装を利用・レビューできる段階にあり、初期保証全体の受入は未完了。

最新の公開実装は`3c7d2c8`。32変数LLTの入力走査・panel切替・有限値判定を追加改善した。
[アセンブリ比較と公開API再測定](../research/eigen-assembly-gap.md)ではn32/m128が5.330→2.775 µs、Eigen比0.973。
その他の形状やQRを含む全体同等の受入は未完了。

前段の公開実装`5127214`では、LLTの列方向panelと入力走査、QRのrow/column kernelとcopyを改善した。
[同条件での旧版・修正版・Eigen比較](2026-10-07-solver-locality.md)を参照。
以下のdispatch性能報告は旧版`83c7a14`の全phase・容量baselineであり、最新factor+solveの時間は新報告に分けている。
[最新CI](https://github.com/takuto-NA/kibo-linalg/actions/runs/37581895862)は通常test・無確保・package・
WASM・ESP cross compileを通過し、PC4 jobsは数値gate未達で失敗。
Releaseはrow19件・column18件、Debugの小規模suiteは各17件の数値未達が残る。
親仕様は[PCのLM計算を起点とするポータブルC++20線形代数コアの初期仕様](https://github.com/takuto-NA/kibo-linalg/issues/9)、
変更は[Draft PR](https://github.com/takuto-NA/kibo-linalg/pull/21)で確認できる。

| 項目 | 確認した結果 | 証拠・残作業 |
| --- | --- | --- |
| 行列・基本演算・LLT・列pivot QR | 公開APIから所有・view・失敗・workspace・数値例を検証 | [core](2026-10-06-core.md)、[solvers](2026-10-06-solvers.md)、[API](../api.md) |
| Windows/GCC/Clang・package | Debug/Releaseの通常と無例外/RTTI consumer、移動後find_packageが通過。Clang ASan/UBSanでも確認 | [ポータビリティ](2026-10-06-portability.md)。全testの成功は数値gate未達のため保留 |
| 固定Windows SDK取得 | hosted runnerにVS17.14.25を新規install、cl.exe版/hash確認後に実行 | [install metadata](portability/hosted/windows-toolchain.json)、[CI](../ci.md) |
| 無確保計算経路 | 校正付き基本演算/LLT/QR probeが通過。2〜32変数6構成はWindows Debugで0回。GCC/Clang/ASan/UBSanはReleaseの2〜512変数10構成すべて0回 | [連続行カーネル更新後の実command・各構成の結果](portability/hosted/dispatch/prepared-allocation.json)。MSVC Releaseは計測skipで代用しない |
| LM参照fit | 直線・指数、normal-LLT/augmented-QRの4ケースが各2反復で合格 | [設定と範囲](../benchmarks.md)。optimizer製品化・numopt-js移植は含めない |
| PC性能・64 MiB gate | 主比較とscalarを各5 process実行。通常fixtureの独立解照合、入力hash一致、内部packingを補った容量gateが通過 | [正式報告・全phase CSV・図](2026-10-07-dispatch-performance.md)。512変数・2048残差のQRは主系列でEigen比1.688、LLTは1.714、ピーク数値上限60,952,576 bytes。Eigen全体への優位は宣言しない |
| 悪条件・尺度・rank | 一貫系の精度/backward error、normality、rank境界等を検証。condition1e8・大残差の解誤差gateは未達 | [連続行カーネル更新後の失敗を含む数値結果](portability/hosted/dispatch/numerical/windows-release.txt)、[精度調査](../research/least-squares-accuracy.md)。保証範囲の判断待ち |
| WASM | NodeとChromium/Firefox/WebKitの数値・容量・寿命・growth・disposeが通過。prepared compute確保0、2×2数値領域168 bytes | [連続行カーネル更新後のhosted結果とhash](portability/hosted/dispatch/evidence.json)、[利用方法](../wasm.md) |
| ESP32-S3/C3 cross compile | C++20・例外/RTTI offで両targetのELF/bin/map/configを生成。数値領域128 bytesと校正付きheap/stack probeを準備 | [連続行カーネル更新後のhosted実commandとhash](portability/hosted/dispatch/evidence.json)、[実機手順](../esp32.md) |
| ESP32-S3/C3各実機 | 未検証 | board型番・接続環境・chip revision、各実機のserial数値/heap/stack証拠が必要 |

現在のprecision gateを変更・skipした結果を合格にしない。
condition1e8に大きな消せない残差がある問題については、doubleの保証を
小残差の精度gateと大残差の診断評価へ分けるか、高精度計算を追加するかの判断を待つ。
cross compileとPC代替では、実機のallocation count0・stack最小空き2 KiBの受入を完了できない。

残る受入は[悪条件・特異・尺度変化を既知解と独立oracleで検証する](https://github.com/takuto-NA/kibo-linalg/issues/15)、
[PCのLM参照問題と2〜512変数のEigen比較を実行する](https://github.com/takuto-NA/kibo-linalg/issues/16)、
[ESP32-S3とC3の各実機で数値・容量・stackの受入証拠を取得する](https://github.com/takuto-NA/kibo-linalg/issues/19)で管理する。
全gateを満たすまで[導入・Eigen移行例と初期保証の受入報告を整える](https://github.com/takuto-NA/kibo-linalg/issues/20)を完了にしない。

後続の拡張候補は実測から優先順位を決める。より広いISA/backend、疎行列、float主体の保証、
SVD/最小ノルム、macOS/ARM PC、numopt-js optimizer本体は今回の初期範囲外。
公開license・registry登録・tag/release配布は別のmaintainer判断として残す。
