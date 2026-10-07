# QRの行間隔・4行更新・Householder除算を実COFFで対照する

2026-10-08。[列配置QR](https://github.com/takuto-NA/kibo-linalg/issues/25)と
[行配置QR](https://github.com/takuto-NA/kibo-linalg/issues/26)の追加診断。
公開QR source19e210a、Eigen5.0.1、MSVC14.44 /O2 /fp:precise、CPU0 P core、SSE2幅2、single-thread。
[前の対照](qr-second-assembly-controls.md)と同じaugmented row入力、lambda、4 phaseと6確保setupを使う。
warmup5、交互順、3 process×5 samples、各sampleの両backendが20ms以上。
[全phase集計](../validation/performance/qr-third-controls/summary.json)と135 executions、実COFF、source/object/binary/harness hashを保存した。
正常系の解全要素照合、入力hash一致、数値領域64 MiB以下を確認した。正式5×30、強い精度・rank・失敗契約の受入とは区別する。
これらのprivate対照は公開採用していない。

## 行間隔だけの変更

512変数・2048残差のfactor row strideを512から513/520/528へ変え、値・算術・入力・workspaceは維持した。
paddingを持つfactor領域を確保し、その追加数値領域とsetup初期化費用も計上する。
同じstride対応の公開APIを呼び、caller指定のrowをcolumnへ置き換えていない。比較先Eigenはcolumn factor。

| row stride | factor µs | solve µs | 両方 µs | 両方Eigen比 |
| ---: | ---: | ---: | ---: | ---: |
| 512 | 152132.0 | 5554.6289 | 148765.9 | 1.5412 |
| 513 | 133652.7 | 3993.1625 | 137427.3 | 1.4484 |
| 520 | 134690.9 | 4279.5234 | 138497.6 | 1.4575 |
| 528 | 134811.7 | 4027.8094 | 139466.2 | 1.4480 |

時間はprocess medianの3 process median、比はpaired sample比のprocess medianの3 process median。
それぞれの統計が別なのでfactor/solveのmedian和が両方のmedianになるとは限らない。
4096-byte間隔からずらすと改善することを確認した。hardware counterは採取しておらず、cache競合・TLB等の内訳は断定しない。
paddingだけで列配置Eigenと同等にはならず、元のcaller layoutの改善とも区別する。

## Householder係数の除算

公開係数生成は極端な入力で`alpha-beta`がoverflowしないよう`(value/beta)/(ratio-1)`を使う。
単独対照では`alpha-beta`が有限でnormalな範囲に限り、一回の除算、または一度作ったreciprocalとの乗算へ置き換えた。
丸めを変更する。reciprocal対照は最大denominatorでreciprocal自身がsubnormalになり得るため、その範囲を公開へそのまま採用しない。

実COFFのcolumn factorで、一回除算のloopは`0D04/0D11/0D20/0D30 divsd`、
fallbackは`0DE4/0DE8`など要素ごと二回の`divsd`を確認した。reciprocal対照ではloopの除算が乗算になる。
Eigenの同じHouseholderは通常範囲で平方和と`tail/(c0-beta)`を使う。実COFF全文も同じharnessから保存し、
source上の式だけで性能原因を決めていない。

| n/m | column対照 | factor µs | 両方 µs | 両方Eigen比 |
| --- | --- | ---: | ---: | ---: |
| 8/32 | 公開 | 2.0577 | 2.3017 | 1.5256 |
| 8/32 | 一回除算 | 1.7944 | 2.0321 | 1.3339 |
| 8/32 | reciprocal | 1.7044 | 1.9434 | 1.2708 |
| 32/128 | 公開 | 44.0573 | 46.7419 | 1.5558 |
| 32/128 | reciprocal | 38.4439 | 40.8245 | 1.3518 |
| 128/512 | 公開 | 1594.7031 | 1628.3438 | 1.3236 |
| 128/512 | reciprocal | 1509.8563 | 1528.8781 | 1.2798 |
| 512/2048 | 公開 | 102558.8 | 103588.7 | 1.0847 |
| 512/2048 | reciprocal | 100849.7 | 101531.3 | 1.0835 |

小問題の係数生成の除算が時間へ寄与する。512の両方比はほぼ変わらず、除算だけを大規模側の主因としない。
row128のreciprocal factorは1998.1→2061.9 µsへ遅くなったので、全配置の優位を宣言しない。

## 4行の適用境界とsolve panel

既存の4行projectionをcount>=16から4へ早める単独対照と、4行updateをcount>=4で共有する対照を分けた。
各要素の増加row順の加算・更新順は維持する。両方を使ったrow factorは、n8で2.8190→2.5238 µs、
n32で57.5562→52.0904 µs、n128で1998.0656→1924.4125 µs、n512で152132.0→136083.2 µs。
512の両方Eigen比は約1.51で、元layoutの残差がある。境界サイズと失敗契約は公開採用前の検証事項。

solve panel対照は4/8列をまとめ、dotとreflector同士の内積から順次係数を作る。
既存candidate workspaceの16/64 doublesを一時使用し、追加heapを使わない。算術・丸めを変える。
有限係数・値と安全な大きさを確認し、使えないときはtransformed RHSを元に戻して従来経路を再実行する。
512 solveは4列panelで5554.6→3804.2 µs、8列で4218.8 µsだが、
128は114.3→177.0/191.4 µsへ遅くなった。全サイズ採用をせず、追加内積とguardの費用があることを記録する。
独立oracleやfailure indexの全検証前であり、速いnormal fixtureの成功だけを公開契約の証拠としない。

## 再現と次の統合

保存sourcesの最小CMakeListsに固定Eigen headersを渡し、MSVC Releaseで14 targetsをbuildする。
通常/padding harnessのrepro版はaffinity include位置だけを保存構成に合わせている。
同じ引数順`n samples m process`でrunnerを順次実行する。実COFF全文はgzip、関連関数はtextで保存した。
[SHA256一覧](../validation/performance/qr-third-controls/SHA256SUMS.json)で照合できる。
支持された入力検査・norm・除算・更新を組み合わせ、同時採用時の性能と独立oracle・極端な値・失敗契約を検証する。
paddingやsolve panelの限定改善で、全shape・全phaseを達成済みにしない。
