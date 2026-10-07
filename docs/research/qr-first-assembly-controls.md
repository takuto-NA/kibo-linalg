# QRの入力検査・norm・行更新を実COFFと単独対照で比較する

2026-10-08。[列配置QRの性能課題](https://github.com/takuto-NA/kibo-linalg/issues/25)と
[行配置QRの性能課題](https://github.com/takuto-NA/kibo-linalg/issues/26)の継続調査。
公開QRはsource19e210aから変更していない。以下の変更はprivate対照であり、公開採用・強い精度保証・正式性能受入は未完了。
[生データ・全phase集計](../validation/performance/qr-first-controls/summary.json)と実COFF全文、関連関数、source/object/binary/harness hashを保存した。

## 条件と公開APIの再現

Eigen5.0.1、CPU0 P core、MSVC14.44 /O2 /fp:precise、SSE2幅2、single-thread、warmup5、
各sampleの両backendが20ms以上のbatch。baselineは1 process×5 samples、単独対照は3 process×5 samples。
5 process×30 samplesの正式受入とは区別する。全159 executionsで解全要素をbatch外で独立LDLT解へ照合し、
入力hash一致、数値領域64 MiB以下を確認した。これは正常系の検証であり、悪条件・rank・失敗契約のprototype検証ではない。

両backendの入力は同じrow-major augmented `[J; sqrt(lambda)I]` と `[r;0]`、lambda=1e-3。
Eigenにも`compute(inputRow)`を直接渡す。以前のEigen準備済みcolumn入力の系列と絶対時間を混ぜない。
kiboのfactor保存をcolumnまたはrowで指定し、rowは同layoutのEigen rowとEigen columnの両方を測る。
setupは入力copy、領域確保、factor、solveを含み、両者とも解を実体化して次の呼出しまで保持する。
kiboの元の6確保・初期化ありcaller policyを保存した。計算中の無確保は別の契約である。

| n/m | kibo factor/Eigen factor | factor µs | solve µs | 両方 µs | 両方Eigen比 |
| --- | --- | ---: | ---: | ---: | ---: |
| 8/32 | column/column | 2.0534 | 0.2559 | 2.2917 | 1.5094 |
| 8/32 | row/row | 2.7287 | 0.6724 | 3.3775 | 1.3700 |
| 8/32 | row/column | 2.7971 | 0.6651 | 3.4493 | 2.2799 |
| 32/128 | column/column | 44.1963 | 2.0490 | 46.7591 | 1.5482 |
| 32/128 | row/row | 57.0591 | 8.7044 | 66.2174 | 1.4076 |
| 32/128 | row/column | 57.7418 | 8.2003 | 66.1757 | 2.2004 |
| 128/512 | column/column | 1594.0906 | 27.3640 | 1623.4969 | 1.3334 |
| 128/512 | row/row | 2009.5250 | 114.5840 | 2139.2188 | 1.0902 |
| 128/512 | row/column | 2013.5375 | 114.7199 | 2150.6219 | 1.7392 |
| 512/2048 | column/column | 101898.7000 | 476.1727 | 102862.8000 | 1.0980 |
| 512/2048 | row/row | 143625.5000 | 5607.5375 | 147491.8000 | 1.0789 |
| 512/2048 | row/column | 143017.1000 | 5349.8078 | 148020.9000 | 1.5827 |

この表はbaselineのprocess内medianとpaired sample比。全10形状・全4phase・3配置は保存集計にある。
配置による差を無断で隠さず、row/rowの小さい差だけで最良構成への同等を宣言しない。

## 命令から予測し、単独で変えた結果

入力検査の実COFFは`0386: movsd`、`038A: call _dclass`、`03A1: jb 0386`で、各入力要素ごとのCRT分類呼出しがある。
packet入力検査だけを変えると、8変数column factorは2.0570→1.5953 µs、32変数は44.2721→39.2086 µs。
正常系のこのサイズでは入力検査の呼出し費用が支持された。一般strideのfallbackは維持する。

QR内のscalar finiteチェックだけを`abs(value)<=DBL_MAX`へ変えた対照では、
row solveが8変数0.6643→0.2655 µs、32変数8.2398→3.7604 µs、128変数114.3525→65.6192 µs。
公開の入力走査はこの対照では変更していない。512変数のrow solveには大きい残差があり、検査呼出しだけでは説明できない。
選択した関数群の`_dclass` call siteは公開21、scalar finite対照5。
これは静的なcall site数であり、全phaseの動的実行回数ではない。

normの実COFFには各要素の比較・scalar division・依存したsumがある。
最大値を先に走査し、scaled sumを別に計算する対照を作り、columnでは`0154/0158: divpd`を確認した。
しかし8/32/128変数では遅く、512変数でも改善しないため、この2回走査案を採用しない。
除算のpacket化という命令の変化だけで性能向上を主張しない。

4行をまとめ、projection packetを共有するupdate対照は算術順・追加領域を変えない。
factorは32変数57.4049→54.7854 µs、128変数2006.3844→1948.9719 µs、512変数141843.8→134589.7 µs。
512変数のfactor+solveも147931.5→140404.8 µsだが、Eigen比1.5716→1.5222でまだ未達。

時間はprocess内medianの3 process median、比はpaired sample比のprocess medianをさらにmedianした。
入力packetとscalar finiteの組合せは小問題に効くが、512変数column factorは102369.6→104853.0 µsと遅くなった。
全サイズへ無条件に採用する根拠とはしない。対照ごとのEigen時間変動も残し、kibo絶対時間の変化とpaired比を区別する。

## 再現と次の検証

保存した`sources/baseline`と各variantを`.scratch/qr-next/variants/<name>`へ戻し、
`sources/scripts`のcpp・CMakeListsを`.scratch/qr-next/`、runnerを`.scratch/`へ置く。
保存したfixture/affinity、同じEigenとMSVCを使い、Releaseでbuildしてbaselineとcontrolsのrunnerを順に実行する。
[SHA256一覧](../validation/performance/qr-first-controls/SHA256SUMS.json)で保存物を確認できる。
benchmarkとbuild/test/CPU負荷の大きい処理を同時に実行しない。

更新kernelのfinite検査命令、stride付きHouseholder solveの内積・updateを、次の単独対照で調べる。
strideやcache競合は現時点で仮説であり、hardware miss counterを測った証拠はない。
採用候補は悪条件・独立oracle・rank/status・失敗保持・stride/padding・無確保・scalar・各基準環境を通した後に公開へ反映する。
Eigen精度CHECKの扱いは別のユーザー判断が未回答で、CHECKを維持する。
