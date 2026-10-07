# 大残差の最小二乗と精度条件

2026-10-07、元入力を受ける補正APIに強い解精度保証を適用する方針が承認された。
数値閾値は維持する。Eigen自身の精度失敗をCIの必須条件から診断へ変える判断は保留中。
既存stress testはskipせず、残るEigen精度CHECKの失敗も返す。

2026-10-07の[実入力oracleと補正の追加診断](qr-rounded-input-accuracy.md)では、
丸め済み入力自体の誤差を分離し、元A/bのdouble-double残差・勾配を使う2回補正で
今回の全510結果を既存の数値閾値へ戻せることを確認した。
以下の保証見直し案は当初の未採用案であり、一般的なcondition boundを理由に
今回の追加演算誤差を不可避とは扱わない。承認済みの補正APIは
[ADR0009](../adr/0009-original-input-qr-refinement.md)・[API](../api.md)に反映した。
上記報告ではEigenの比較gateだけを判断待ちとして区別する。

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
