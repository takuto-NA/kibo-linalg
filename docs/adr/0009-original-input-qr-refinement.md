# 元入力を受ける補正solveで大残差の精度を保証する

丸め済み入力の独立oracleとの比較で、condition 1e8・大残差における現行QRの追加誤差を、
元A/bの高精度残差・勾配と既存double Rによる補正で減らせることが確認できた。
元Aを引数で受ける追加の補正solveでこの強い精度保証を提供する。
通常solveとfactorの元Aを破棄可能なlifetime・性能・容量契約を保ち、全面的なfactor高精度化の費用を避ける。
閾値はcondition 1e8でforward<=1e-4のままとし、通常solveの同じstress結果も診断に残す。
補正もcaller workspace・無確保・失敗時の解保持・例外/RTTI不要を満たす。
精度保証の評価範囲は[API文書](../api.md)、対象構成は[CI文書](../ci.md)に定める。

[元入力を使う無確保QR補正APIで大残差の解精度を保証する](https://github.com/takuto-NA/kibo-linalg/issues/28)。
