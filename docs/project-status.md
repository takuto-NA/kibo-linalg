# 初期コアの整理と到達状況

2026-10-08。今回のmain導入は、利用・検証できる初期コアを確立するもの。
Eigen同等の性能達成、ESP32各実機の受入、release-readyの宣言は後続とする。
この分離は同日のユーザー判断による。性能目標やkiboの数値精度閾値を緩めるものではない。

## できていること

| 対象 | 実装と確認済みの範囲 | 整理版での確認 |
| --- | --- | --- |
| 行列・基本演算 | C++20、固定/動的所有行列、外部stride view、明示的な確保と失敗通知 | 整理版の公開API・失敗・alias・容量testsはPC CIで通過 |
| LLT | SPD分解/solve、caller storage、無確保経路、小行列とpanel更新 | 通常/scalar、大きい境界サイズ、非SPD・非対称・overflow tests通過 |
| 列pivot QR | full-column-rank最小二乗、rank診断、row/column factor、無確保solve | 通常/scalar、rank境界、途中失敗時の解保持tests通過 |
| QR補正 | 元A/bを使う追加API、2m+3n doubles、失敗時の解保持 | 既存の独立100桁oracle fixtureを含むkiboのCHECKは通過 |
| PC/package | Windows MSVC、Linux GCC/Clang/libc++、ASan/UBSan、移設find_package consumer | 8構成のkibo CHECKと移設consumerは通過。Eigen-onlyでCI全体は失敗 |
| LM参照問題 | 直線/指数fit、normal-LLT/augmented-QRを同じ反復設定で評価 | CTest通過。optimizer製品APIではない |
| WASM | wasm32、Node、Chromium/Firefox/WebKit、容量・growth・dispose・補正API | 整理版のhosted CI成功 |
| ESP32 | ESP-IDF S3/C3のC++20サンプル、heap/stack probe | 整理版の両cross compile成功。実機は未検証 |

## できていないこと

- 全形状・全phaseでのEigen同等以上。過去の一部改善を全体達成と扱わない。
- 最新の先読み候補の全形状正式性能測定。300実行中92件で中断した。
- S3/C3各実機での数値・allocation・stack受入。現在は実機がない。
- MSVC Releaseでのallocation計測。現計測器はskipを返し、他構成の結果で代用しない。
- numopt-js本体のWASM移植、疎行列、SVD/最小ノルム、float主体の保証、macOS/ARM PC。
- 公開licenseの選定、registry、tag/release配布。

## 採用した実装と保留した実験

整理版の数値ヘッダーは、`95f15bd2db8d3e81245ed64694c5233f1b75a6f5`と全ファイル同一で開始した。
この実装には局所累積・scalarの4反射panel・packet命令生成の修正を含む。
正式scalar比較300実行と品質検証を終えた実装である。
初期導入の作業では、数値カーネルに新しい最適化を加えない。

`dac5666`のGNU/Clang x64 scalar prefetchは、品質検証と私的対照を終えたが、
公開版の正式性能測定が未完了のため今回の導入から外した。
整数による範囲検査、2反射panelなど不採用の試行も公開カーネルに取り込まない。

95f15bdの正式scalar測定では、512変数prepared solveのkibo/Eigen比が、
Eigen column保存との比較で正方形約2.07、縦長約3.93だった。
prefetchの私的5 process × 30 samplesでは縦長solveが約33%改善したが、
Eigen比は約2.59。これらは異なる実装・測定系列であり、最新全体の速度保証ではない。
実COFF/ELFによる命令比較は実施済み。row pitchとprefetchへの感度は観測したが、
PMUでcache/TLBの寄与まで確定したとは扱わない。

## 証拠と履歴

今回の統合は[初期コア・検証・履歴を整理し、main導入を完了する](https://github.com/takuto-NA/kibo-linalg/issues/29)で管理する。

- 公開済み履歴は[旧Draft PR #21](https://github.com/takuto-NA/kibo-linalg/pull/21)に残す。
- 整理前の先端は`6cc08d57fdb2898b33103d9b468fd97af67f1fa6`。
  全履歴を含むGit bundleをローカルに保存し、`git bundle verify`を通過した。
  未公開部分をGitHubで参照できるとは扱わない。
- 過去の主要な成果は[証拠の索引](evidence-index.md)から辿れる。
- 整理版の必須判定は新しいPRの固定commitに対するCIで確認し、
  以前のソースに対する成功runを転用しない。
- mainとの差分b397aa9の独立レビューはStandards/Specともblocking findings 0件。
  [整理版ca7749bのCI](https://github.com/takuto-NA/kibo-linalg/actions/runs/37738081204)でも、
  PC全8構成のnumericalとnumerical_columnの各8件が、従来のEigen forward-error CHECKだけだった。
  kiboのCHECKは通過した。WASM・S3/C3 cross compileは成功した。
  Eigen自身の精度を比較診断へ分けるユーザー判断が残り、CI全体はfailureである。
- 実験ごとのソース複製、object、実行バイナリ、生ログをmainの通常ツリーへ持ち込まない。
  コード・fixture・実行スクリプトを保持し、新しいログはCI artifactに保存する。

## 進め方の反省と是正

追加実験の終了条件を決めず、PR反映を後回しにした。
コード3ファイルの追加に対して、12,449ファイル・約372MiBの検証資料を積み上げた。
成果物の保存を進捗と取り違え、利用者が到達状況を把握しにくくした。

さらに、製品自身の精度判定と比較対象Eigenの精度、初期コアのmergeと最終受入を混在させた。
Issuesと受入表の更新も遅れ、過去の数値が現状のように読める状態を残した。
これはagentの作業管理の失敗であり、ユーザーの指示不足に帰するものではない。

今後は各Issueに、対象、現在の固定commit、未達条件、次の一つの検証、終了条件を記す。
診断実験は一つの仮説と一つの変更に絞り、採否を決めてから次へ進む。
正式な全形状測定は、採用候補が固まり契約・数値検証を通過した時点で行う。
一つの実装単位ごとに文書・Issue・PRを同期させ、mergeを完了してから次の改善へ進む。
