# 行列メモリとポータブルな失敗通知の事実確認

確認日: 2026-10-06。一次資料の読み取りによる調査。SDK導入、ライブラリ実装、メモリ使用量の実測は行っていない。

## 配置、参照、alignment、重複

Eigenの既定配置はcolumn-major。Mapは外部バッファを所有せず共有し、既定はUnaligned。Strideで非連続配置を表現できる。Eigenとの配置比較は性能測定とは別の事実確認である。[配置](https://libeigen.gitlab.io/eigen/docs-nightly/group__TopicStorageOrders.html)、[Map](https://libeigen.gitlab.io/eigen/docs-nightly/classEigen_1_1Map.html)

Unalignedという呼び方もC++の要素型のalignmentを不要にはしない。doubleを要素として扱う領域は対象環境のalignof(double)を満たす必要がある。全ターゲットで同じalignment値とは仮定しない。[C++20 N4861 §6.7.6](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2020/n4861.pdf)

Eigenでは領域が重なる代入・転置に制約があり、evalや専用in-place演算が示される。noaliasは非重複を宣言するもので、重複を解消する機能ではない。[Aliasing](https://libeigen.gitlab.io/eigen/docs-nightly/group__TopicAliasing.html)

## ESP32の容量と測定

S3の内部SRAMは512 KB、C3は400 KB（うち16 KBはcache）。チップ総量は行列用に確保できる容量ではない。SDK、静的データ、task stackなどの使用を別に考慮する。[S3](https://www.espressif.com/en/products/socs/esp32-s3)、[C3 datasheet §4.1.2.1](https://documentation.espressif.com/esp32-c3_datasheet_en.html)

ESP-IDF v6.1のxTaskCreateのstack指定とuxTaskGetStackHighWaterMark/2の最小空きstack値はbyte単位。動的task作成ではstackと管理構造もheapから確保される。[FreeRTOS API](https://docs.espressif.com/projects/esp-idf/en/v6.1/esp32c3/api-reference/system/freertos_idf.html)

heap_caps_get_free_sizeは総空き、heap_caps_get_largest_free_blockは最大単一割当、heap_caps_get_minimum_free_sizeは最低空き。総空きだけでは連続バッファの確保を保証できない。[Heap debugging](https://docs.espressif.com/projects/esp-idf/en/v6.1/esp32c3/api-reference/system/heap_debug.html)

## WASMのビュー寿命

WASM memory growth自体は既存領域の線形メモリoffsetを移動しない。一方、今回のsingle-thread構成で保持したJS TypedArray viewは失効し得る。Emscriptenは標準HEAPビューを更新するが、独自subarrayは再取得が必要。free/reallocによる寿命終了・移動はgrowthとは別に考える。[WASM growth](https://webassembly.github.io/spec/core/exec/modules.html#grow-mem)、[Emscripten JS連携](https://emscripten.org/docs/porting/connecting_cpp_and_javascript/Interacting-with-code.html#access-memory-from-javascript)

## 例外なしの割当失敗

C++20のnew(std::nothrow)は割当失敗をnullptrで通知できるが、コンストラクタが投げる例外までは抑止しない。通常のnewやstd::allocator::allocateが例外無効のコンパイラ設定で失敗返却APIに変わるという標準上の保証はない。[N4861 §17.6.2.1、§7.6.2.7、§20.10.10.1](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2020/n4861.pdf)

## 計算値と設計上の推論

double=8 byteの対象構成では、2×2の係数は32 byte、n=512の密なn×n行列は2 MiB、m=2048,n=512のヤコビアンは8 MiB。これは所有オブジェクト、padding、入力コピー、分解・演算のworkspaceを含む総予算ではない。

数値バッファ＋workspace、stack、heap全体はそれぞれ測定できる。ただしstack上に置いた数値バッファやheapから確保したtask stackを全体容量に集計するときは二重計上しない。

評価予算はチップ総量から自動導出するものではなく、ユーザーと決める受入条件。実現可否は解法選択後の要求量計算と実測で確認する。

