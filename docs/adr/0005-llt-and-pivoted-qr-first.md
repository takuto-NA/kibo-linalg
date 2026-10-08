# 初期の解法をLLTと列pivot付きQRに絞る

PCの密なdouble最小二乗を起点として、SPD系用のCholesky LLTとm>=nのfull-column-rank最小二乗用の列pivot付きHouseholder QRを採用する。normal equationsの精度リスクを評価するためaugmented-QR経路も用意し、rank不足は成功解として返さず診断する。現行利用先の全解法を複製するより、最初の用途への有用性と失敗契約を明確にすることを優先し、LU、SVD、最小ノルム解などは後続拡張とする。

[最小の演算・分解・線形方程式解法を決める](https://github.com/takuto-NA/kibo-linalg/issues/5)。
