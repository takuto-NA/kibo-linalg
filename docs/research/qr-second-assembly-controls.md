# QRのnorm・有限検査・stride付きsolveを単独対照する

2026-10-08。[列配置QRの性能課題](https://github.com/takuto-NA/kibo-linalg/issues/25)と
[行配置QRの性能課題](https://github.com/takuto-NA/kibo-linalg/issues/26)の継続調査。
公開QRのsource19e210aとprivate対照を比較した。公開採用・強い精度保証・正式性能受入は未完了。
[全phase集計](../validation/performance/qr-second-controls/summary.json)、120 executionsの生データ、実COFF全文と関連関数、source/object/binary hashを保存した。

## 条件

[最初の対照](qr-first-assembly-controls.md)と同じ入力・factor保存・setup policyを使う。
両backendへ同じrow-major augmented `[J;sqrt(lambda)I]` と `[r;0]`、lambda=1e-3を渡す。
Eigen5.0.1、MSVC14.44 /O2 /fp:precise、CPU0 P core、single-thread、SSE2幅2、warmup5。
3 process×5 samples、各sampleの両backendが20ms以上のbatchで、backend/variant順を交替する。
正式5 process×30 samplesの合否には使わない。全実行で正常系の解全要素をbatch外で照合し、
入力hash一致と64 MiB以下の数値領域を確認した。悪条件・rank・極端な値・失敗契約はまだprivate対照で検証していない。

以下の時間はprocess medianの3 process median。Eigen比はpaired sample比をprocess内でmedianし、その3 process medianを取る。
時間median同士の商と比の統計は同一ではない。全factor/solve/both/setupと比は保存集計にある。

## normと有限検査

`adaptive_norm`は通常の範囲で一回の平方和を使い、平方和が非有限またはunderflow誤差が支配し得る範囲なら従来のScaledSquaresへ戻す。
count<16も従来経路。normの丸めとpivot順は変わり得る。overflowを検知して戻るまでにFP exception flagを設定し得るため、FP環境の同一性を証明していない。
実COFFの高速ループはscalar `mulsd/addsd`で、従来の値ごとの分岐・除算を除く。fallbackの`divsd`は残る。

`exponent_check`はrow/column更新の結果の指数部をmaskし、`maxpd`でInf/NaNの指数をstickyに保持する。
算術・加減算順序は同じ。row更新の実COFFでは`0073/0081 maxpd`、最終`00D4 maxpd / 00D8 cmpltpd`を確認した。
従来のpacketごとのabs/compare/ANDをmask/MAXへ変える。NaN/Inf各laneやoverflowの失敗契約の追加検証前である。

| n/m | column対照 | factor µs | solve µs | 両方 µs | 両方Eigen比 |
| --- | --- | ---: | ---: | ---: | ---: |
| 8/32 | 公開 | 2.0514 | 0.2569 | 2.3036 | 1.5043 |
| 8/32 | adaptive norm | 1.7711 | 0.2609 | 2.0095 | 1.3242 |
| 32/128 | 公開 | 44.3644 | 2.0540 | 46.8643 | 1.5308 |
| 32/128 | adaptive norm | 41.0270 | 2.0365 | 43.0479 | 1.4304 |
| 128/512 | 公開 | 1596.6063 | 27.5549 | 1625.2594 | 1.3147 |
| 128/512 | exponent check | 1531.3812 | 27.3053 | 1562.7938 | 1.2432 |
| 512/2048 | 公開 | 102603.7000 | 478.7258 | 104105.3000 | 1.0955 |
| 512/2048 | exponent check | 98080.1000 | 492.3484 | 99073.1000 | 1.0156 |

adaptive normの512 factorは102661.1 µsで、公開との差は小さい。全サイズの優位を宣言しない。
指数検査も512でEigen同等の正式判定には届いていない。solveはこの対照で改善していない。

## stride付きHouseholder solve

row factorでは各列から2要素をgatherするSSE2 dotと、transformed RHSを連続packetで更新するSSE2 updateを別々に試した。
dotは2本の累積を最後に足すため、従来scalarの加算順を変更する。updateの各要素の算術順は同じ。
実COFFを各単独variantと両方のvariantから抽出した。scalar尾部、arithmetic failureのpivot indexと最終出力commitの形は維持しているが、全契約の検証は未完了。

比較先はEigen column factorである。同じrow layoutへの比較は最初のbaselineに残す。

| n/m | row solve対照 | solve µs | solve Eigen比 |
| --- | --- | ---: | ---: |
| 8/32 | 公開 | 0.6687 | 2.9224 |
| 8/32 | scalar有限検査をinline化 | 0.2661 | 1.1815 |
| 8/32 | gather dot＋packet update | 0.2847 | 1.2619 |
| 32/128 | 公開 | 8.2257 | 4.6942 |
| 32/128 | scalar有限検査をinline化 | 3.7623 | 2.1334 |
| 32/128 | gather dot＋packet update | 2.5010 | 1.4061 |
| 128/512 | 公開 | 114.7261 | 4.5196 |
| 128/512 | packet updateのみ | 63.8107 | 2.5010 |
| 128/512 | gather dot＋packet update | 64.4011 | 2.6298 |
| 512/2048 | 公開 | 5477.2625 | 12.7908 |
| 512/2048 | gather dot＋packet update | 5414.3711 | 12.6418 |

小〜中規模のupdateで有限検査・scalar更新が時間に寄与することを単独対照で確認した。
512の約5〜6msは同じ変更で解消しない。行間隔4096 bytesの影響、同じcache lineの再読込、三角solveは候補だが、
hardware counterを採取しておらずcache missを断定しない。次は行間隔だけの変更と複数列をまとめて読む対照で切り分ける。

## 再現

保存`sources`の最小CMakeListsは保存baseline/variant、fixture、affinityで10 targetsを作る。
`EIGEN_SOURCE_DIR`へ固定Eigen headersを指定し、MSVC Releaseでbuildする。
`full-adaptive-repro.cpp`は保存したas-built harnessのaffinity include位置だけを保存構成へ合わせたもの。
runnerのexe pathをそのbuildへ合わせ、同じ引数順`n samples m process`で順次実行する。
COFF全文はgzipで保存し、展開した内容のhashはobject manifestにある。
[SHA256一覧](../validation/performance/qr-second-controls/SHA256SUMS.json)で保存物を確認する。
公開へ適用する前に独立oracle、rank、scale端点、padding、無確保、失敗時出力保持と各基準環境を検証する。
