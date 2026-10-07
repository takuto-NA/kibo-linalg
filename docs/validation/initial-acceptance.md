# 初期保証の受入状況

2026-10-07。実装を利用・レビューできる段階にあり、初期保証全体の受入は未完了。

公開補正APIは`6ef5701`、保存証拠は`137656d`。元入力を受ける無確保QR補正を追加し、
7構成714件で独立100桁oracleの精度gateとPC/WASMの契約検証を通過した。
[補正の精度・費用・ポータビリティ](../research/qr-refined-public-validation.md)を参照。
ユーザー承認により、condition1e8・大残差の強い精度保証は補正経路へ適用し、通常solveの診断を残す。
Eigen自身の精度判定を合否条件へ含めるかは別の判断待ちで、CHECKを維持した数値CTestは各8件のEigen-only失敗を返す。
補正APIの [hosted CI](https://github.com/takuto-NA/kibo-linalg/actions/runs/37620734174) は完了し、
PC4 jobsの失敗はEigen-only精度CHECK、WASM・ESP cross compileは通過した。
[hosted証拠](numerical/refined-public/hosted/evidence.json)を保存した。

LLTの公開実装`8fe28e5`では、9〜64変数の列更新、入力走査・対称性検査とbackward solveを追加改善した。
[実COFF命令比較と公開API再測定](../research/small-llt-assembly.md)ではn31/m124が4.247→1.776 µs、Eigen比0.844。
factor+solveはn2〜64の測定形状で改善したが、n128/512、2変数のsetup phase、QRを含む全体同等の受入は未完了。

前段の公開実装`5127214`では、LLTの列方向panelと入力走査、QRのrow/column kernelとcopyを改善した。
[同条件での旧版・修正版・Eigen比較](2026-10-07-solver-locality.md)を参照。
以下のdispatch性能報告は旧版`83c7a14`の全phase・容量baselineであり、最新factor+solveの時間は新報告に分けている。
[補正追加前のCI](https://github.com/takuto-NA/kibo-linalg/actions/runs/37602800569)は通常test・無確保・package・
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
| 悪条件・尺度・rank | 補正経路で既存精度/backward/normality gateを通過。通常solveのstress診断とrank境界を維持。全数値CTestはEigen自身の精度CHECKで失敗 | [公開補正の保存結果](numerical/refined-public/metadata.json)、[精度調査](../research/qr-rounded-input-accuracy.md)。Eigen比較gateだけ判断待ち |
| WASM | NodeとChromium/Firefox/WebKitの数値・容量・寿命・growth・disposeが通過。prepared compute確保0、2×2数値領域168 bytes | [連続行カーネル更新後のhosted結果とhash](portability/hosted/dispatch/evidence.json)、[利用方法](../wasm.md) |
| ESP32-S3/C3 cross compile | 補正solveを使うC++20・例外/RTTI offサンプルで両targetのELF/bin/configを生成。数値構造体248 bytesと校正付きheap/stack probeを準備 | [補正追加後のcommand/firmware hash](numerical/refined-public/metadata.json)、[実機手順](../esp32.md) |
| ESP32-S3/C3各実機 | 未検証。利用者は現在実機を持っていない | 入手・接続後にboard型番・chip revision、各実機のserial数値/heap/stack証拠を取得する。現時点で追加情報を求めない |

現在のprecision gateを変更・skipした結果を合格にしない。
丸め済みA/bの100桁oracleで入力感度と追加演算誤差を分け、元A/bの高精度残差で補正可能と確認した。
閾値を維持し、承認済みの補正APIで保証を提供する。[実装と残る受入](https://github.com/takuto-NA/kibo-linalg/issues/28)を参照。
cross compileとPC代替では、実機のallocation count0・stack最小空き2 KiBの受入を完了できない。

残る受入は[悪条件・特異・尺度変化を既知解と独立oracleで検証する](https://github.com/takuto-NA/kibo-linalg/issues/15)、
[PCのLM参照問題と2〜512変数のEigen比較を実行する](https://github.com/takuto-NA/kibo-linalg/issues/16)、
[ESP32-S3とC3の各実機で数値・容量・stackの受入証拠を取得する](https://github.com/takuto-NA/kibo-linalg/issues/19)で管理する。
全gateを満たすまで[導入・Eigen移行例と初期保証の受入報告を整える](https://github.com/takuto-NA/kibo-linalg/issues/20)を完了にしない。

後続の拡張候補は実測から優先順位を決める。より広いISA/backend、疎行列、float主体の保証、
SVD/最小ノルム、macOS/ARM PC、numopt-js optimizer本体は今回の初期範囲外。
公開license・registry登録・tag/release配布は別のmaintainer判断として残す。
