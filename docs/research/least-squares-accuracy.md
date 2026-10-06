# 大残差の最小二乗と精度条件

現在の受入条件を変更する判断は保留中。既存stress testはskipせず失敗を返す。

[LAPACK Users' Guide: Error Bounds for Linear Least Squares Problems](https://www.netlib.org/lapack/lug/node82.html)は、
full-rank最小二乗の解誤差の近似上界を、machine epsilon、Aの逆条件数、残差の相対量から求める。
掲載された式には残差角度のtanを条件数の二乗で増幅する項がある。
したがってAの条件数だけでは、大残差の解誤差を小残差の場合と同じ値に一律制限する根拠にならない。

今回の独立100桁oracleは、丸め済みdouble A/RHSを解く。
condition1e8・orthogonal noise0.01*scaleの最初の例で、期待解[0.5,-1]に対する
core QRの相対解誤差は約8.4e-3で、既存gate1e-4を満たさない。
一般的な誤差解析と整合するが、これだけで全失敗を数学的限界と断定しない。
raw Eigenのtiny-scale結果にも大きな誤差があるため、Eigenへの一致だけを正しさの証拠にしない。

判断案は、小残差の既知解・独立oracleを解精度gateにし、大残差をoptimalityとoracle誤差の診断評価として残すこと。
大残差でも同じ解精度を必須にする場合は、高精度計算の追加方式と性能・容量を別に検証する。
いずれの案も未採用であり、現在のIssue・ADRの合格条件を自動で緩めない。
