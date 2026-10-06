# ポータビリティ実装の検証記録

2026-10-06。固定toolchainは[lock manifest](../../tools/toolchains.lock.json)、
再現方法は[CI文書](../ci.md)を参照。これは初期保証全体の受入完了を意味しない。

| 対象 | 実行した検証 | 結果・制限 |
| --- | --- | --- |
| Windows MSVC19.44.35222.0 / VS17.14.25 | Debug/Release、公開API、無例外/RTTI、LM、移行例、移動後find_package | numerical以外は通過。Debug確保probeは校正後0回。Release確保probeはskip |
| Linux GCC15.3.0 / libstdc++15.3 | Debug/Releaseの10 tests、移動後find_package | 通過、allocator probeは両構成で校正後0回。Eigen oracle suiteはこの構成では未実行 |
| Linux Clang20.1.8 / libc++20.1.8 | 同10 tests、移動後find_package | 通過、allocator probeは両構成で0回。Eigen oracle suiteは未実行 |
| Clang ASan/UBSan | Debug/Releaseの同10 tests、移動後find_package | 通過。Eigen oracle suiteは未実行 |
| wasm32 Emscripten6.0.10 / Node24.21.0 | matvec/LLT/QR、容量・事前出力保持、growth、resize失敗、copy寿命、dispose | 通過、校正後compute確保0回、2×2数値領域168 bytes |
| Chromium153.0.8010.12 / Firefox155.0 / WebKit26.6 | Playwright1.63.0でHTTP経由の同WASM tests | 3 engineすべて通過 |
| ESP32-S3 / ESP-IDF6.1 / Xtensa15.2.0 | 共通2×2と校正付きheap/stack probeをcross compile | ELF/bin/map生成、例外・RTTI off確認。C++26でbuildされていたためC++20での再検証待ち。実機未検証 |
| ESP32-C3 / ESP-IDF6.1 / RISC-V15.2.0 | 同cross compile | ELF/bin/map生成、同flags確認。C++20での再検証待ち。実機未検証 |

[Node結果](portability/node.json)、[browser結果](portability/browsers.json)、
[WASM hash・firmware hash・ESP実compile command・source hashes](portability/evidence.json)を保存した。
firmwareに対する実機受入には、ここに記録したhashと対応するserial結果が必要。
SDK全体のheap空きとstack値は実機実行後に取得するため、ここでは合格値を記載しない。

Windowsの全11 testsには、100桁stress oracleの既存基準に対する失敗が含まれる。
condition1e8、大残差、scale1e-150の2変数で、oracle解[0.5,-1]に対して
core解[0.493356,-0.993356]となり、解誤差1e-4を満たしていない。
raw Eigenにも尺度と大残差による精度低下がある。この結果を速度優位や合格として扱わない。
consistent backward errorと100桁rank境界oracleは追加済みだが、全stress suiteの合格は未達。
精度条件を黙って変更・skipせず、採用する保証範囲の判断を待つ。

GitHub hosted CIの実行は別途記録する。local passをhosted CI passと表記しない。
MSVCのscalar候補 /Qvec- はD9002で無視されたため棄却し、
supported flagsを用いるLinux Clang scalar系列を主Windows系列と分けて測定する。
