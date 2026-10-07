# LLT内側storeと小行列ビュー生成の対照

開始ソースは `2f23d66af38fe4aed42811cdf6438af73de620c5`。この報告と同じcommitの公開headerへ、局所累積とビュー生成の簡約を反映した。API、workspace、rank/pivot/失敗契約は変えていない。固定commitの正式測定は末尾に記載し、残る差を受入済みにしない。

## 実COFFで確認した差

[全dump・選択した関数・hash](../validation/performance/llt-store-view/objects/manifest.json) は実際のMSVC `/O2 /fp:precise` objectから生成した。Eigenも同じharnessに含め、SSE2 double packet、single thread、CPU0/P-coreに揃える。source listingだけをコンパイル後命令の根拠にしない。

- 公開LLTの対角更新は `public_large-factorize_column_llt-143.txt` の `1250–129C` で、増加k順の減算ごとに `125E/126F/127F/1294 movsd [rsi],xmm1` がある。局所累積した対照では `diagonal_pair_register-factorize_column_llt-143.txt` の `1230–126C` がload/multiply/subtractのみとなり、`12CF` で一度storeする。
- 同対照のscalar末尾も `167C–169C` の内側kループからstoreが消え、`169E/16A7` で二つの出力をcommitする。mutable MatrixViewが論理要素の重複を拒否し、出力列は既計算panel・係数の列範囲と異なるため、途中storeを保持する必要がない。係数とpanel同士の重複は許される。要素ごとの減算順は変えていない。
- 元のビューfactoryは連続配置にも一般strideのGCDと整数除算を実行する。`public_large-checked-142.txt` のmutable factoryにはoverflow用2個とGCD後2個の `div` があり、const側にも2個ある。setupのcore lambda6がfactoryを二度呼ぶ。
- inlineだけの `view_inline-R_lambda_6_-120.txt` はfactory callを二つ除くが、`02E3` のGCD callと `02F2/02FF` の除算を残す。unit-strideの等価な条件も明示した `view_fast_inline-R_lambda_6_-119.txt` はこのGCDと二つの除算を除く。容量・加算overflow・alignment・mutable aliasの検査は残る。

公開headerを再コンパイルした[最終object](../validation/performance/llt-store-view/public-objects/manifest.json)も別に保存した。追加SIMD命令セット、PMU、cache-missの計測を根拠にした変更ではない。

## 変更を分けた診断

3 fresh processes × 5 samples、四つのphase、warmup≥5、各sampleのbatch≥20ms、交互の実行順。以下はprocess medianの中央値であり、5×30の正式受入ではない。Eigen比はpaired sample比を各processで中央値にした後の中央値。[全生データ](../validation/performance/llt-store-view/controls/manifest.json)を保持する。

| factor対照 | n128/m512 µs | Eigen比 | n512/m2048 µs | Eigen比 |
| --- | ---: | ---: | ---: | ---: |
| 開始公開版 | 44.654 | 1.0183 | 2047.013 | 0.9201 |
| 対角の局所累積のみ | 45.245 | 1.0342 | 2033.456 | 0.9011 |
| scalar末尾の局所累積のみ | 44.530 | 1.0130 | 2015.119 | 0.8930 |
| panel loadの寿命短縮のみ | 44.482 | 1.0140 | 2020.488 | 0.8970 |
| 対角＋scalar末尾の局所累積 | 43.660 | 0.9960 | 1999.731 | 0.8875 |

単独の対角変更は128変数で改善せず、panelの寿命変更も明確な効果を支持しない。採用したのは二つの局所累積の組合せで、命令上のstore減少と全processの時間短縮が対応する。128変数のfactor+solveは46.703→45.511µs、paired Eigen比0.9831→0.9678。ただし正式測定の区間確認は残る。

| n2/m8 setupのビュー対照 | 元の4確保・初期化あり µs | 3確保・上書き領域の初期化なし µs |
| --- | ---: | ---: |
| 開始公開版 | 0.1516 | 0.1269 |
| unit-stride簡約 | 0.1409 | 0.1233 |
| factory inline | 0.1365 | 0.1148 |
| 両方 | 0.1350 | 0.1133 |

所有方針は別の対照である。3確保側はfactor/workspaceを一つのarenaの非重複spanへ配置し、input copyとanswerを別ownerで保持する。Eigenと同じく、完全に上書きする領域は初期化しない。双方の解をtimed batchの外で検証し、answerを次の呼出しまで保持する。元の4確保結果を置き換えない。3確保側にはEigen測定が大きく遅れたsampleもあり、生データを残す。小問題のsetup同等は、この診断だけでは達成扱いにしない。

## 契約と正しさ

`matrix_view_tests.cpp` はsmall extent/strideとcapacity境界を列挙し、GCD式を使わず物理offsetの集合からmutable aliasを判定する。readonly overlap、empty shape、単位/一般stride、容量不足の優先順位とSIZE_MAX近傍を確認する。LLTのexact factor・padding・solve・late failureテストには130/135変数も加え、8列panelやpacketの末尾を通す。

公開変更について、MSVC、GCC15.3、Clang20.1.8/libc++、Clang/libc++ ASan/UBSanのDebug/Release全8構成で、matrix view・LLT/QR・refinement・scalar・無例外/RTTI・LMのgateを通過した。数値CTestの失敗は既存のEigen forward-error CHECK各layout8件のみで、数値閾値とEigen CHECKは変えていない。MSVC Release allocation計測は既存のskip。その他のallocation計測はpass。[失敗集合監査とログ](../validation/performance/llt-store-view/validation/failure-set.json)を参照。

Spec/Standards両reviewは指摘0。同じ公開source19e210aの移植先CIと正式性能測定を末尾に結び付ける。

## 再現

[保存source](../validation/performance/llt-store-view/sources/)は各対照のinclude treeとhashを含む。リポジトリで再現するときは、保存した `sources/<variant>/kibo` を `.scratch/large-llt-next/variants/<variant>/kibo`、`full-adaptive.cpp` と `uninitialized-setup.cpp` を `.scratch/large-llt-next/` へ戻す。fixture/affinity includeはリポジトリの `tests` と `tools/diagnostics/solver-locality` を使う。

診断には `sources/scripts/CMakeLists.txt` を同じscratch directoryへ戻し、`build/large-llt-next` にconfigure、Release buildする。この専用CMakeは必要targetだけを持ち、`public_large` も保存した2f23d66 snapshotを指定する。`run-llt-store-inline-controls.py` は `.scratch/` へ戻してrepo rootから実行する。`uninitialized` targetは対応するビューvariantを使う。開始公開版のsnapshotはobject manifestの元ファイルhashと一致する改行を復元して保存した。

公開object/正式測定には `CMakeLists-public.txt` を `CMakeLists.txt` として使う。`before_store` は保存snapshot、`public_large` と `uninitialized_setup` は公開includeを使う。診断と公開のCMakeを同時に使わない。元の全target登録も `CMakeLists-as-built.txt` として残すが、専用再現CMakeには未保存の旧harnessを要求しない。

[公開source snapshot](../validation/performance/llt-store-view/public-source/)と[checksums](../validation/performance/llt-store-view/SHA256SUMS.json)は、検証・公開object・sourceを結び付ける。`run-llt-store-formal.py` は未コミットのinclude/tests/CMake変更を拒否し、正式測定sourceのcommitとbinary/fixture hashを記録する。

## 公開実装19e210aの正式測定

CPU0/P-core、MSVC19.44.35222.0、x64 Release `/O2 /fp:precise`、SSE2 packet2、single thread。変更前2f23d66と公開19e210aの順をprocessごとに反転し、core/Eigen順もsample/processごとに反転した。5 fresh processes × 30 samples × 4 phases、warmup≥5、**全sampleでbatch≥20msを確認**。11 shape、2変数には別の3確保policyも加え、120実行を保存した。

[正式raw・command/source/binary hash・summary](../validation/performance/llt-store-view/formal/summary.json)にはEigenのmedian/p95と全process結果もある。以下は5 process medianの中央値、p95はprocessごとのnearest-rank p95の中央値。比はsampleごとのpaired比→process中央値→5 process中央値、95%区間は5^5のprocess bootstrap。単純な二つのmedianの商とは異なる。

| n | m | phase | 公開median µs | 公開p95 µs | Eigen比 [95%] | 変更後/前比 |
| ---: | ---: | --- | ---: | ---: | --- | ---: |
| 2 | 2 | factor | 0.0177 | 0.0179 | 0.5394 [0.5370, 0.5398] | 0.9980 |
| 2 | 2 | solve | 0.0155 | 0.0158 | 0.7550 [0.6563, 0.7815] | 1.0004 |
| 2 | 2 | factor+solve | 0.0464 | 0.0469 | 0.8544 [0.8352, 0.8635] | 0.9978 |
| 2 | 2 | setup/copy | 0.1362 | 0.1375 | 1.2279 [1.2074, 1.2333] | 0.8975 |
| 2 | 8 | factor | 0.0177 | 0.0179 | 0.5355 [0.4378, 0.5399] | 0.9984 |
| 2 | 8 | solve | 0.0157 | 0.0159 | 0.7463 [0.6718, 0.7806] | 0.9968 |
| 2 | 8 | factor+solve | 0.0463 | 0.0470 | 0.8454 [0.7361, 0.8606] | 0.9965 |
| 2 | 8 | setup/copy | 0.1350 | 0.1375 | 1.2159 [1.1478, 1.2290] | 0.8891 |
| 8 | 32 | factor | 0.1277 | 0.1296 | 0.5608 [0.5562, 0.5652] | 0.9999 |
| 8 | 32 | solve | 0.0640 | 0.0656 | 0.5821 [0.5117, 0.5894] | 0.9996 |
| 8 | 32 | factor+solve | 0.2203 | 0.2243 | 0.6536 [0.6286, 0.6579] | 1.0034 |
| 8 | 32 | setup/copy | 0.3256 | 0.3314 | 0.7889 [0.7583, 0.8051] | 0.9653 |
| 31 | 124 | factor | 1.4742 | 1.4946 | 0.9398 [0.9335, 0.9682] | 0.9992 |
| 31 | 124 | solve | 0.3046 | 0.3081 | 0.5513 [0.5005, 0.5543] | 0.9991 |
| 31 | 124 | factor+solve | 1.7984 | 1.8395 | 0.8466 [0.8387, 0.8708] | 1.0029 |
| 31 | 124 | setup/copy | 2.0345 | 2.0802 | 0.8383 [0.8083, 0.8394] | 0.9944 |
| 32 | 128 | factor | 1.5500 | 1.5852 | 0.7023 [0.6989, 0.7180] | 1.0044 |
| 32 | 128 | solve | 0.3161 | 0.3232 | 0.5685 [0.5521, 0.5712] | 0.9960 |
| 32 | 128 | factor+solve | 1.8842 | 1.9162 | 0.6621 [0.6613, 0.6748] | 1.0007 |
| 32 | 128 | setup/copy | 2.1318 | 2.1577 | 0.6499 [0.6200, 0.6563] | 0.9890 |
| 33 | 132 | factor | 1.6619 | 1.6779 | 0.6258 [0.6245, 0.6378] | 1.0076 |
| 33 | 132 | solve | 0.3296 | 0.3336 | 0.5522 [0.4993, 0.5556] | 0.9981 |
| 33 | 132 | factor+solve | 2.0065 | 2.0684 | 0.6132 [0.6007, 0.6222] | 1.0031 |
| 33 | 132 | setup/copy | 2.2558 | 2.2925 | 0.6215 [0.6206, 0.6277] | 0.9917 |
| 64 | 256 | factor | 8.5153 | 8.5859 | 0.9510 [0.9063, 0.9672] | 0.9976 |
| 64 | 256 | solve | 0.8708 | 0.8811 | 0.6876 [0.6225, 0.6912] | 1.0026 |
| 64 | 256 | factor+solve | 9.3474 | 9.5099 | 0.9052 [0.8720, 0.9130] | 0.9942 |
| 64 | 256 | setup/copy | 10.2210 | 10.3394 | 0.8486 [0.8476, 0.8513] | 0.9962 |
| 128 | 128 | factor | 43.5208 | 43.9680 | 0.9925 [0.9912, 1.0124] | 0.9810 |
| 128 | 128 | solve | 2.0036 | 2.0497 | 0.6295 [0.5838, 0.6331] | 1.0055 |
| 128 | 128 | factor+solve | 45.5438 | 46.2163 | 0.9658 [0.9616, 0.9857] | 0.9831 |
| 128 | 128 | setup/copy | 49.4744 | 60.8178 | 0.8802 [0.8462, 0.8818] | 0.9783 |
| 128 | 512 | factor | 43.7531 | 44.3095 | 0.9977 [0.9889, 1.0007] | 0.9837 |
| 128 | 512 | solve | 2.0045 | 2.0904 | 0.5860 [0.5817, 0.6306] | 1.0068 |
| 128 | 512 | factor+solve | 45.6097 | 46.3945 | 0.9663 [0.9558, 0.9716] | 0.9788 |
| 128 | 512 | setup/copy | 49.5869 | 59.1863 | 0.8735 [0.8728, 0.8807] | 0.9809 |
| 512 | 512 | factor | 1990.7531 | 2022.1000 | 0.9470 [0.8834, 0.9856] | 0.9789 |
| 512 | 512 | solve | 23.9171 | 24.3864 | 0.8112 [0.8049, 0.8346] | 1.0131 |
| 512 | 512 | factor+solve | 2026.9438 | 2066.3750 | 0.9502 [0.9438, 0.9958] | 0.9807 |
| 512 | 512 | setup/copy | 2785.8188 | 2850.8688 | 0.9434 [0.9261, 0.9648] | 0.9818 |
| 512 | 2048 | factor | 1988.3594 | 2019.9375 | 0.9338 [0.8660, 0.9407] | 0.9760 |
| 512 | 2048 | solve | 23.9098 | 24.3759 | 0.8331 [0.8278, 0.8371] | 1.0069 |
| 512 | 2048 | factor+solve | 2023.3563 | 2060.9000 | 0.9478 [0.9365, 0.9543] | 0.9760 |
| 512 | 2048 | setup/copy | 2790.4875 | 2854.8500 | 0.9424 [0.9420, 0.9602] | 0.9817 |

512変数はm=n/4nの四つのphaseすべてでpaired比の区間が1未満。128変数はsolve・factor+solve・setup/copyが1未満だが、factorはmedianで同程度でも区間が1をまたぐ。これをfactor同等の確定とはしない。31/32/33境界、8/64変数にも退行の受入残差はない。

元の4確保・初期化ありの2変数setupは約1.22倍で未達。3確保・上書き領域初期化なしの独立したcaller policyも次の通りで、まだ小さい差と不確実性が残る。元のpolicyを隠したり、全shape平均で同等にしたりしない。

| n | m | 3確保setup median µs | p95 µs | Eigen比 [95%] |
| ---: | ---: | ---: | ---: | --- |
| 2 | 2 | 0.1133 | 0.1146 | 1.0028 [0.9696, 1.0303] |
| 2 | 8 | 0.1124 | 0.1145 | 1.0173 [0.9901, 1.0281] |

残作業は128変数factor、小行列setup、QRと全shape/全layout/scalarの統合受入。Eigen精度CHECKの別判断も未回答。今回の正式結果だけで性能親Issueを閉じない。

## 同じsourceのhosted検証

[CI37636769541](https://github.com/takuto-NA/kibo-linalg/actions/runs/37636769541)、source19e210aの[artifact監査](../validation/performance/llt-store-view/hosted/evidence.json)を保存した。PC Debug/Release全8実行で新規のkibo失敗はなく、各実行の失敗は各layout8件ずつの既存Eigen forward-error CHECKのみ。WASM NodeとChromium/Firefox/WebKitのrefined QR/無確保/失敗保持、ESP32-S3/C3 cross compileも成功。ESP実機は未検証。全CIはEigen CHECKによりfailureのままで、その判定を無断で診断へ変更しない。
