# 初期コアのmain導入と最終受入

2026-10-08のユーザー判断により、検証済み初期コアのmain導入と、
Eigen同等の性能・ESP実機を含む最終受入を分ける。
機能・履歴・未達項目の一覧は[到達状況](../project-status.md)、過去の根拠は[証拠の索引](../evidence-index.md)を参照。

## 今回のmerge gate

| 判定 | 必須の範囲 | 整理版の結果 |
| --- | --- | --- |
| 公開API・契約 | 行列/LLT/QR/補正、通常/scalar、失敗時出力保持、容量、無例外/RTTI | Windows Debug/Release通過。hosted CI待ち |
| 数値精度 | 既知解、独立100桁oracle、条件数・rank・尺度、既存閾値 | Windowsのkibo CHECKは通過。Eigen-only各配置8件で全体は失敗 |
| PCとpackage | 固定MSVC/GCC/Clang Debug/Release、ASan/UBSan、移設consumer | Windows移設consumer通過。hosted CI待ち |
| 無確保 | 計測器校正付きtests。MSVC Releaseのskipは未検証と明示 | 検証待ち |
| WASM | Node・Chromium/Firefox/WebKit、数値・寿命・容量 | 検証待ち |
| ESP32 | S3/C3 cross compile | 検証待ち。実機実行は対象外 |
| レビュー | mainとの差分に対するStandards/Spec | b397aa9で両観点blocking findings 0件 |

現在のPRの固定commitに対する結果を記入する。旧branchの成功を合格欄へ転記しない。
Eigen自身の精度を製品CIの必須判定から比較診断へ分ける判断は、まだ回答待ち。

## merge後も未完了として残すもの

- [Eigen同等の性能の最終受入](https://github.com/takuto-NA/kibo-linalg/issues/16)：全形状・全phase・median/p95・95%区間。
- [ESP32-S3/C3各実機の受入](https://github.com/takuto-NA/kibo-linalg/issues/19)：数値・heap・stack。
- [初期保証とrelease-readiness](https://github.com/takuto-NA/kibo-linalg/issues/20)：全条件の統合。mainに入っただけでは完了しない。

Eigen同等の目標、64MiBの数値領域、prepared compute無確保、補正APIの精度閾値は維持する。
普通のCI runnerの絶対速度をmerge gateにしない。性能の採否は固定PCの測定に基づく。
