# 2変数LLTのループ展開と、採用しなかった対照

2026-10-08。[小行列性能課題](https://github.com/takuto-NA/kibo-linalg/issues/23)の続き。
source19e210aを基準に、同じ入力・Eigen5.0.1・CPU0 P core・MSVC14.44 /O2 /fp:precise・SSE2で比較した。
ここでの時間は3 process×5 samples、warmup5、各sampleの両者のbatchが20ms以上の**診断**であり、5×30の正式受入ではない。
[生データ・集計](../validation/performance/llt-tiny/summary.json)、実COFF全文、source/harness/object/binary hash、再現scriptを保存した。

## 原因を分けた対照

2変数は入力・factor・workspaceの準備費用が計算に対して大きい。
先行のビュー最適化後も残った整数除算について、MSVC x64の`_umul128`で積の上位桁を検査する対照を作った。
実COFFのmainは基準の`07D4/086E: div`が対照の`07F9/0807/08A4/08B2: mul`へ変わった。
SIZE_MAX境界と独立offset列挙も通過したが、2変数setupの改善は3 processで安定せず、公開実装には採用しなかった。

128変数ではpanel幅を8から4にするとfactorが約2〜5%遅くなった。
512変数でも改善せず、128だけ4列にする対照も採用しなかった。
lower入力copyを8×8 tileにする別対照にも安定した短縮がなく、従来のcopyを維持した。
命令を変えたという事実だけで高速化を主張しない。

2変数のfactorとsolveを個別に展開すると、それぞれの計算phaseが短縮した。
両方の展開を合わせても効果が維持されたため、この変更を公開LLTに適用した。
実COFFのsolveは`0188: cmp r14,2`から四つのscalar divisionと有限性検査へ入り、
最後に二つの出力をcommitする。以前の2回の汎用三角solveループを通らない。
四つのdivisionは近似逆数へ変えていない。factorも元のsqrt・division・subtractionの順を保つ。

| n/m | 実装 | factor µs | solve µs | 両方 µs | setup µs | 両方Eigen比 | setup Eigen比 |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 2/2 | 基準・4確保 | 0.01765 | 0.01554 | 0.04610 | 0.13369 | 0.8561 | 1.2168 |
| 2/2 | factorのみ展開 | 0.01505 | 0.01549 | 0.04334 | 0.12906 | 0.7929 | 1.1558 |
| 2/2 | solveのみ展開 | 0.01776 | 0.00979 | 0.03696 | 0.12616 | 0.6727 | 1.1338 |
| 2/2 | 両方展開・4確保 | 0.01508 | 0.00977 | 0.03487 | 0.12051 | 0.6467 | 1.0956 |
| 2/2 | 基準・3確保 | 0.01770 | 0.01536 | 0.04651 | 0.11381 | 0.8549 | 1.0245 |
| 2/2 | 両方展開・3確保 | 0.01503 | 0.00977 | 0.03470 | 0.09771 | 0.6326 | 0.8793 |
| 2/8 | 基準・4確保 | 0.01768 | 0.01575 | 0.04632 | 0.13484 | 0.8519 | 1.2176 |
| 2/8 | 両方展開・4確保 | 0.01502 | 0.00973 | 0.03489 | 0.12068 | 0.6538 | 1.0924 |
| 2/8 | 基準・3確保 | 0.01765 | 0.01541 | 0.04625 | 0.11330 | 0.8586 | 0.9944 |
| 2/8 | 両方展開・3確保 | 0.01500 | 0.00969 | 0.03460 | 0.09782 | 0.6344 | 0.8838 |

時間はprocess内medianの3 process median、比はpaired sample比のprocess medianをさらにmedianした。
3確保はcaller policyの別対照。入力copy、disjoint factor/workを同じarena、独立answerを確保し、
全上書き領域のゼロ初期化を省く。Eigenと同じように解を実体化して次の呼出しまで保持し、全要素をbatch外で照合する。
元の4確保policyの約9%の差は残っており、この診断で全setup同等と判定しない。

## 公開契約と検証

入力全体のfinite/symmetry検証、workspace容量・alignment、stride要素アクセス、
pivot/arithmetic failureのindex、solve失敗時の出力保持、RHS/output完全一致を維持する。
2変数のpadding・general stride・既知解・in-place solve・late backward overflowと最初のpivot失敗を追加確認した。
追加契約テストは変更前のnative Release SIMD/scalarでも通過してから公開変更を適用した。

MSVC、GCC15.3、Clang20.1.8 libc++、Clang ASan/UBSanのDebug/Release全8構成で19 CTestを実行した。
[失敗集合](../validation/performance/llt-tiny/validation/failure-set.json)は全構成とも既存Eigen precision CHECKの16件のみ。
kiboの数値・scalar・失敗契約に新規失敗なし。MSVC Releaseのallocation計測は従来どおりskip、その他のallocationは通過。
Standards・Specレビューは双方指摘0。WASM/ESP cross compileと固定sourceの正式性能は後続証拠で確認する。
ESP実機はない。Eigen精度CHECKを診断へ変更する判断は未回答で、CHECKを維持している。

## 再現

保存した`sources/baseline`と各variantを`.scratch/large-llt-next/variants/<name>`へ戻し、
`sources/scripts`のcppと最小CMakeListsを`.scratch/large-llt-next/`に置く。
同じEigen、repo tests、`tools/diagnostics/solver-locality/affinity.hpp`を使う。
保存したrunnerを`.scratch/`へ置き、Releaseでbuildして順次実行する。
各runnerは3 process×5 samplesの診断であり、正式受入条件を短縮するためのものではない。
[SHA256一覧](../validation/performance/llt-tiny/SHA256SUMS.json)で保存物を確認できる。

128変数factorと全形状・全layout/scalarの統合受入は未完了。QRの残差調査を続ける。
