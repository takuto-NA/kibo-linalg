# 成果と証拠の索引

過去の証拠は測定対象commitとセットで読む。以下の成功や速度を整理版全体へ転用しない。
整理版の状態と残課題は[到達状況](project-status.md)、新しいCIの結果は[受入状況](validation/initial-acceptance.md)を参照。

| 成果 | 保存済みの根拠 | 現在の扱い |
| --- | --- | --- |
| 元入力を使うQR補正 | [公開APIの精度・契約・費用](https://github.com/takuto-NA/kibo-linalg/blob/9103a15/docs/research/qr-refined-public-validation.md) | 採用。通常solveとは保証・費用を分ける |
| QRの精度原因の分離 | [丸め済み入力と独立oracle](https://github.com/takuto-NA/kibo-linalg/blob/2f1c987/docs/research/qr-rounded-input-accuracy.md) | 原因調査完了。検証用audit/oracleを保持 |
| 小行列LLTの命令比較 | [実COFFと単独対照](https://github.com/takuto-NA/kibo-linalg/blob/2120cd9/docs/research/small-llt-assembly.md) | 改善採用。全形状の同等達成は未完 |
| 大行列LLTの命令比較 | [panel・更新・正式測定](https://github.com/takuto-NA/kibo-linalg/blob/6ce6863/docs/research/large-llt-assembly.md) | 改善採用。source/phaseごとに読む |
| 入力走査・store・view | [実命令の対照](https://github.com/takuto-NA/kibo-linalg/blob/80e0495/docs/research/llt-store-and-view-assembly.md) | 採用。SIMDの有無だけでは説明できない差を確認 |
| QRの初期単独対照 | [実行記録と採否](https://github.com/takuto-NA/kibo-linalg/blob/71317f7/docs/research/qr-second-assembly-controls.md) | 履歴。私的試行と公開版を区別 |
| 過去のWASM/ESP cross compile | [固定sourceのCI](https://github.com/takuto-NA/kibo-linalg/actions/runs/37644418342) | 実行済み。ESP実機の証明ではない |
| 初期の全phase比較 | [dispatch性能報告](https://github.com/takuto-NA/kibo-linalg/blob/e772855/docs/validation/2026-10-07-dispatch-performance.md) | baseline履歴。最新の性能ではない |

旧PR公開先端e772855より後の実験資料は、整理前branchとローカルGit bundleに保存している。
これには95f15bdの正式scalar300実行、714件のoracle検証、命令生成の復旧対照、
row pitchの単独対照、不採用の範囲検査/2反射panel、prefetch候補、92/300件の中断記録が含まれる。
大量の生データを新しいPRの差分へ再投入しない。

再現に必要な公開API tests・固定fixture・toolchain lock・通常benchmark harness・
100桁oracle生成とauditはこのリポジトリに残す。CI artifactには保存期限があるため、
将来の性能Issueの採否に使う証拠は対象commit・コマンド・環境・結果要約をIssueに記録する。
