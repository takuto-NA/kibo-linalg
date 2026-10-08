# 製品の精度gateとEigen自身の解精度を分ける

kiboの精度は既知解・独立100桁oracle・失敗契約を必須判定し、Eigen自身のforward errorは入力条件・誤差・閾値・合否・失敗件数を残す比較診断とする。比較対象の解精度が基準を外れたことで、基準を満たすkiboのCIまで失敗していたためである。
kiboのCHECK、精度閾値、対象形状、rank/条件数を含むfixtureの検証は維持し、Eigenとの性能比較と同等以上の目標も継続する。Eigen診断は成功したCTestの詳細ログにも保存し、通常solveと元入力を使う補正solveの保証範囲はADR 0009を維持する。

[悪条件・特異・尺度変化を既知解と独立oracleで検証する](https://github.com/takuto-NA/kibo-linalg/issues/15)。
