# numopt-jsとの将来連携に向けた事実確認

確認日: 2026-10-06。ソースの読み取りによる調査で、性能測定・実行テストは行っていない。
numopt-jsの参照commitは `138a7df5681e2c00f212510434ecab5e1c98a527`。

## 確認した事実

- 行列の実依存は `ml-matrix`。package.jsonの指定は `^6.10.5`、lockfileは6.12.1。ユーザーが示したmljs/ml全体をimportしているわけではない。[package.json](https://github.com/takuto-NA/numopt-js/blob/138a7df5681e2c00f212510434ecab5e1c98a527/package.json)、[package-lock.json](https://github.com/takuto-NA/numopt-js/blob/138a7df5681e2c00f212510434ecab5e1c98a527/package-lock.json)
- パラメータ・勾配・残差・状態にはFloat64Arrayを使う。目的関数はnumberを返し、解析ヤコビアンはml-matrixのMatrixを返す。これらは同期JavaScriptコールバック。[型定義](https://github.com/takuto-NA/numopt-js/blob/138a7df5681e2c00f212510434ecab5e1c98a527/src/core/types.ts)
- 公開アルゴリズムにはGD、BFGS、L-BFGS、Gauss–Newton、Levenberg–Marquardt、CMA-ES、制約付きGN/LM、adjointがある。[公開exports](https://github.com/takuto-NA/numopt-js/blob/138a7df5681e2c00f212510434ecab5e1c98a527/src/index.ts)
- 実使用には密行列の生成、要素アクセス、転置、行列積、加減算、スカラー倍、eye、cloneと、ベクトルdot/normがある。配列とMatrixの変換はコピーを伴い、2D配列のflattenはrow-major。[変換・ベクトル演算](https://github.com/takuto-NA/numopt-js/blob/138a7df5681e2c00f212510434ecab5e1c98a527/src/utils/matrix.ts)
- GN/LMは正規方程式とCholesky/general solveを使う。CMA-ESも共分散行列のCholeskyを使う。調べた公開ソースでは明示的なinverse、SVD、QR、EVDの直接使用は見つからなかった。[GN](https://github.com/takuto-NA/numopt-js/blob/138a7df5681e2c00f212510434ecab5e1c98a527/src/core/gaussNewton.ts)、[LM](https://github.com/takuto-NA/numopt-js/blob/138a7df5681e2c00f212510434ecab5e1c98a527/src/core/levenbergMarquardt.ts)、[CMA-ES](https://github.com/takuto-NA/numopt-js/blob/138a7df5681e2c00f212510434ecab5e1c98a527/src/core/cmaEs.ts)
- ml-matrix 6.12.1の一般solveは正方ならLU、非正方ならQR、第三引数trueならSVD。ただしnumopt-jsが正規方程式の正方系へ変換する経路から、QRが初期必須とは断定できない。[ml-matrixの依存版ソース](https://github.com/mljs/matrix/blob/8cc77fc8fbb7c57d161425240ea2ed40a1c0b165/src/decompositions.js)、[制約solve](https://github.com/takuto-NA/numopt-js/blob/138a7df5681e2c00f212510434ecab5e1c98a527/src/core/constrainedUtils.ts)
- 代表テストには1〜2変数の問題、LM例には2変数・5残差の問題がある。これらは必要な対応上限や性能目標ではない。[GNテスト](https://github.com/takuto-NA/numopt-js/blob/138a7df5681e2c00f212510434ecab5e1c98a527/test/gaussNewton.test.ts)、[LM例](https://github.com/takuto-NA/numopt-js/blob/138a7df5681e2c00f212510434ecab5e1c98a527/examples/curve-fitting-lm.ts)
- LMの統合テストには直線モデルと指数モデルのフィットがあり、どちらも2変数・5残差。指数モデルは `a * exp(b * x)` で、既存テストでは数値ヤコビアンを使う。これは非線形の再現確認に使う候補であり、大きな密行列の速度を代表する根拠ではない。[既存統合テスト](https://github.com/takuto-NA/numopt-js/blob/138a7df5681e2c00f212510434ecab5e1c98a527/test/classicProblems.test.ts)
- Eigen公式は正規方程式で元の行列の条件数が二乗され、悪条件では精度を失いやすいことを説明する。正常系の速度比較と難しい入力の精度・診断は分けて評価する必要がある。[最小二乗の公式説明](https://libeigen.gitlab.io/eigen/docs-nightly/group__LeastSquares.html)

## 設計上の推論と未確認事項

- 動的サイズの密行列double、行列積、行列ベクトル積、Cholesky/LU solveは、最小機能を考える際の候補になる。実装範囲は未決定。
- 線形代数だけをWASMで実行する場合、最適化の反復と目的関数はJavaScript側に残せる。反復までWASMに移す場合も、目的関数をJavaScriptに残すかは別の判断になる。
- どちらの境界でも、配列とWASMメモリの所有権・配置・コピー・寿命・呼出し頻度を明示する必要がある。コピーや境界の呼出しコストを含めた速度は未測定。
- QR/SVDの採用は現行importの再現だけでなく、悪条件・特異・階数不足に対してどの数値的な信頼性を保証するかで判断する。
- 調査開始時点で未確定だった初期評価範囲と合格基準は、後続の[ワークロード判断](https://github.com/takuto-NA/kibo-linalg/issues/2#issuecomment-6014648500)と[合格基準判断](https://github.com/takuto-NA/kibo-linalg/issues/8#issuecomment-6016198293)で確定した。実測したボトルネックはまだ未確認。小さな既存テストのサイズを、そのままライブラリの性能目標にはしない。
