# QRのfactor領域と更新順

2026-10-07、Intel Core i9-14900K、Windows11、固定MSVC19.44.35222.0 Release。
最初の5-process比較では512変数のaugmented-QR factor+solveが通常Eigenより29〜32倍遅かった。
この旧実装のraw結果は[旧主比較](../validation/performance/before-locality/summary.csv)に保存しておく。
最終実装の性能結果と混ぜない。

候補をfactor領域のアクセス順、要素ごとの有限値検査、列norm再計算とした。
公開QRに同じxorshift fixture（1024行・512列、既知解は全要素1）を渡し、
inputは行優先のまま、出力factor領域のstrideだけをrow-major／column-majorに変更した。
準備を計測から外し、warmup1、factor3回の平均を取り、各factor後にsolveの要素誤差1e-10以内を確認した。
診断用のrow/column比4超を検出基準にし、public CIの速度保証にはしない。

| 実装 | row-major factor秒 | column-major factor秒 | row/column |
| --- | ---: | ---: | ---: |
| 修正前 | 0.834674433 | 0.122303200 | 6.82463 |
| 修正後 | 0.135956567 | 0.121673200 | 1.11739 |

これはアクセス順が大きな要因だったことを支持する。Eigenとの差全体の原因を証明するものではない。
単一ケース・3回平均の診断値なので、正式な5-process baselineとは区別する。
診断harnessは `.scratch/qr-locality` に隔離し、通常testsやpackageへ含めない。
診断の[固定source](../validation/performance/locality-probe.cpp)と
[修正前JSON](../validation/performance/locality-before.json)・[修正後JSON](../validation/performance/locality-after.json)を保存した。
同sourceを固定MSVCのx64 developer promptから `/std:c++20 /O2 /fp:precise /EHsc`、
include path `include`・`tests`・固定Eigen headersでcompileし、
旧QRを使う場合は `b75b540` のcore、修正後はこの変更のcoreで同じ実行を比較できる。

行優先に近いfactor領域ではprojectionと更新をrow順に行う。
列優先に近い領域では従来のcolumn順を維持する。
未確定のtau[k+1:n]をそのstepのprojectionに使い、各columnをfactorするときに本来の係数で上書きする。
norm tracking、rank閾値、有限値検査を保持し、factor workspaceは2n doublesのまま。
公開回帰testは4列の密行列を連続row-major・column-major・padding付きrow-majorでfactor/solveし、
既知解、rank/pivot、係数の有効性とpadding保持を確認する。

精度gateの変更ではない。悪条件・大残差の未達は元の条件で引き続き検証する。
旧scalar試行は未完了で停止したため採用せず、修正後に主系列とscalar系列の両方を取り直す。
