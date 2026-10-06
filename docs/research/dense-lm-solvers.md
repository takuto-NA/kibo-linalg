# 密なLM計算を支える分解・解法の事実確認

確認日: 2026-10-06。一次資料の読み取りによる調査。採否の決定、実装・実行・性能測定は行っていない。

## 分解の適用条件と診断

- LLTは対称正定値（SPD）用でrank-revealingではない。EigenのinfoがNumericalIssueを返すことは、数学的なrankや可解性の判定ではない。[LLT](https://libeigen.gitlab.io/eigen/docs-nightly/classEigen_1_1LLT.html)
- Eigen LDLTは正/負の半正定値を対象とするpivot付き分解だが、rank-revealingではない。一般の対称不定値系へ同じ保証を広げない。[LDLT](https://libeigen.gitlab.io/eigen/docs-nightly/classEigen_1_1LDLT.html)
- 列pivot付きHouseholder QRはrank診断を持つ。ただしEigenのinfoは常にSuccessで、rankはthresholdに基づく別判定。thresholdは分解自体には使わない。複数解がある場合のsolveを最小ノルム解の保証とは解釈しない。[ColPivHouseholderQR](https://libeigen.gitlab.io/eigen/docs-nightly/classEigen_1_1ColPivHouseholderQR.html)
- Eigen PartialPivLUは正方・可逆系を前提とし、rank診断を持たずinfoも常にSuccess。FullPivLUはrank-revealingだが、thresholdに基づく数値判定。[PartialPivLU](https://libeigen.gitlab.io/eigen/docs-nightly/classEigen_1_1PartialPivLU.html)、[解法説明](https://libeigen.gitlab.io/eigen/docs-nightly/group__TutorialLinearAlgebra.html)

## Rank、残差、解の誤差

数値rank推定は、threshold、スケール、丸め誤差に依存し、数学的な厳密rankの証明ではない。列pivot QRの採用からSVDと同等のrank判定や最小ノルム保証は導けない。LAPACKはrank不足の最小ノルム最小二乗にSVDとcomplete orthogonal factorizationを提供する。[LAPACK最小二乗](https://www.netlib.org/lapack/lug/node27.html)

小さい残差から正規化したbackward errorを評価できるが、小さいbackward errorだけでは小さいforward errorを保証しない。条件数の影響があり、過決定最小二乗では正しい解でも残差が0とは限らない。[LAPACK誤差解析](https://www.netlib.org/lapack/lug/node78.html)

## Damped LMの記号と数学的導出

ここでは目的を min_p ||Jp+r||² + lambda ||Dp||² と定義する。
normal equationsは H=JᵀJ+lambda DᵀD、Hp=-Jᵀr。
augmented least squaresは B=[J; sqrt(lambda)D]、c=[-r;0] に対する min_p ||Bp-c||²。

lambda>0でDの対角が全て正なら、非零vに対してvᵀHv=||Jv||²+lambda||Dv||²>0。厳密演算ではHはSPD、Bはfull column rankで、Jがrank不足でも一意解になる。
H=JᵀJ+lambda Dという別の記号を使う場合、augmented側はsqrt(lambda)D^(1/2)になり、Dの意味を混同しない。[Ceres LM説明](https://ceres-solver.readthedocs.io/latest/nnls_solving.html#levenberg-marquardt)

lambda=0ではJのfull column rankが必要。Jの二列が同一ならJᵀJは特異。
Dにゼロ対角がありker(J)とker(D)が非自明に交われば、lambda>0でもSPDにならない。
厳密演算のSPDはdoubleでの分解成功や精度を無条件に保証しない。
full-rank Bではkappa_2(BᵀB)=kappa_2(B)²となり、damping後に二乗されるのはBの条件数。[正規方程式のリスク](https://libeigen.gitlab.io/eigen/docs-nightly/group__LeastSquares.html)

## 設計上の推論

列pivot QRはn×nのfull-rank一般系も解けるため、初期のLMとm>=nの範囲だけからLUの初期必須性は導けない。
Ax=bやLM stepは分解と三角solveで計算でき、明示inverseは数学的に必須ではない。ただしEigenの小固定行列の説明も考慮し、inverseが常に劣るとは一般化しない。[Eigen解法説明](https://libeigen.gitlab.io/eigen/docs-nightly/group__TutorialLinearAlgebra.html)

QRの数値rank不足を独自APIで明示的な失敗にする場合は、Eigenのinfoをそのまま模倣せず、rank診断と許容閾値を契約として規定する必要がある。
この調査後の採否、閾値とworkspace契約は[解法判断](https://github.com/takuto-NA/kibo-linalg/issues/5#issuecomment-6016061989)、許容誤差と検証条件は[合格基準判断](https://github.com/takuto-NA/kibo-linalg/issues/8#issuecomment-6016198293)で確定した。実装・精度測定済みという意味ではない。

