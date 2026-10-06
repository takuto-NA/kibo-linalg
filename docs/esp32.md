# ESP32-S3/C3の最小実行確認

`examples/esp32` をESP-IDF6.1、esp-15.2.0_20251204でクロスコンパイルする。
componentはC++20、exceptions/RTTI off、内部RAM、PSRAM不要。
PCと同じ `examples/common_2x2.hpp` でmatvecとLLT solveを実行する。
数値バッファ128 bytes、task stack8 KiB。heap trace recordsは数値領域と別に集計する。

caller/staticのinput/output/factor/workspaceを準備してから100回計算する。
まず16 bytesの確保・解放をHEAP_TRACE_ALLで検出して計測器を校正する。
traceをリセットしてから、開始/終了間にログ・通信を行わず、total_allocations=0とoverflowなしを検証する。
SDK全体でtraceされるため、他taskが測定中に確保すればfailになり得る。
実機での結果を見ずに確保0、stack空き>=2 KiBの合格とはしない。

serial JSONはtarget/SDK/status、期待値との一致、numeric_bytes、calibration_allocations、allocations、
stack_budget_bytes/stack_free_min_bytes、SDK heap総空き/最大連続領域を別々に報告する。
ESP-IDFのstack size/high-water APIはbyte単位を使用する。
完全なJSON formatterを一度実行した後にstack high-waterを取得し、同じformatterで最終結果を出す。
`phase=probe` は出力経路の確認用、受入には `phase=final` の `accepted` を使う。
stack値は計算とこの出力経路を含み、task解放後の実行を含まない。

```sh
idf.py -B /work/build/esp32-s3 -D SDKCONFIG=/work/build/esp32-s3/sdkconfig -D IDF_TARGET=esp32s3 build
idf.py -B /work/build/esp32-c3 -D SDKCONFIG=/work/build/esp32-c3/sdkconfig -D IDF_TARGET=esp32c3 build
```

作業directoryはexamples/esp32、fixed image/全artifactはCI workflowを参照。
実機では該当targetのbuild directoryとserial portを指定して `idf.py -B <build> -p <port> flash monitor`。
ボード型番、SDK/compiler版、firmware SHA256、電源/PSRAM設定、serial JSONを実機チケットへ保存する。
PCでの共通例passと両targetのELF生成は、実機runの代わりにならない。

[最新hosted CI evidence](validation/portability/hosted/dispatch/evidence.json)にC++20で通過したS3/C3の
実compile commandとfirmware/configのSHA256を保存した。
componentのsource optionを最終位置に置き、SDKの既定規格の後に `-std=c++20` を適用する。
`static_assert(__cplusplus == 202002L)` により規格が変わればbuildを失敗させる。
compiler archiveのURL/checksumは固定image内の `tools/tools.json` から取得してlock manifestへ記録した。
CIはimage digestで取得物全体を固定する。実機へ渡すfirmwareは、この新しいC++20のhashを使用する。
