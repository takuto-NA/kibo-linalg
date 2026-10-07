# LLT内側storeと小行列ビュー生成の対照

開始ソースは `2f23d66af38fe4aed42811cdf6438af73de620c5`。この報告と同じcommitの公開headerへ、局所累積とビュー生成の簡約を反映した。API、workspace、rank/pivot/失敗契約は変えていない。正式受入は後続の固定commit測定で判断する。

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

Spec/Standards両reviewは指摘0。WASM/ESPの新source CIと正式性能測定は後続であり、直前ソースの結果を今回の保証へ転用しない。

## 再現

[保存source](../validation/performance/llt-store-view/sources/)は各対照のinclude treeとhashを含む。リポジトリで再現するときは、保存した `sources/<variant>/kibo` を `.scratch/large-llt-next/variants/<variant>/kibo`、`full-adaptive.cpp` と `uninitialized-setup.cpp` を `.scratch/large-llt-next/` へ戻す。fixture/affinity includeはリポジトリの `tests` と `tools/diagnostics/solver-locality` を使う。

診断には `sources/scripts/CMakeLists.txt` を同じscratch directoryへ戻し、`build/large-llt-next` にconfigure、Release buildする。この専用CMakeは必要targetだけを持ち、`public_large` も保存した2f23d66 snapshotを指定する。`run-llt-store-inline-controls.py` は `.scratch/` へ戻してrepo rootから実行する。`uninitialized` targetは対応するビューvariantを使う。開始公開版のsnapshotはobject manifestの元ファイルhashと一致する改行を復元して保存した。

公開object/正式測定には `CMakeLists-public.txt` を `CMakeLists.txt` として使う。`before_store` は保存snapshot、`public_large` と `uninitialized_setup` は公開includeを使う。診断と公開のCMakeを同時に使わない。元の全target登録も `CMakeLists-as-built.txt` として残すが、専用再現CMakeには未保存の旧harnessを要求しない。

[公開source snapshot](../validation/performance/llt-store-view/public-source/)と[checksums](../validation/performance/llt-store-view/SHA256SUMS.json)は、検証・公開object・sourceを結び付ける。`run-llt-store-formal.py` は未コミットのinclude/tests/CMake変更を拒否し、正式測定sourceのcommitとbinary/fixture hashを記録する。
