# 出力を明示する即時評価APIとヘッダ中心のコアを採用する

初期コアはC++20のヘッダ中心ライブラリとし、出力・factor storage・workspaceを明示する即時評価interfaceを採用する。式テンプレートによる暗黙の一時領域や評価順を初期の利用契約に含めず、無確保経路と失敗を呼出し側が把握できることを優先する。外部backendは将来同じ計算interfaceの内部で差し替えるが、初期のscalar実装だけのためにregistryを設けない。

[C++ APIと評価方式・バックエンドの境界を決める](https://github.com/takuto-NA/kibo-linalg/issues/6)。
