# ポータビリティ実装の検証記録

2026-10-06。固定toolchainは[lock manifest](../../tools/toolchains.lock.json)、
再現方法は[CI文書](../ci.md)を参照。これは初期保証全体の受入完了を意味しない。

| 対象 | 実行した検証 | 結果・制限 |
| --- | --- | --- |
| Windows MSVC19.44.35222.0 / VS17.14.25 | Debug/Release、公開API、無例外/RTTI、LM、移行例、移動後find_package | numerical以外は通過。Debug確保probeは校正後0回。Release確保probeはskip |
| Linux GCC15.3.0 / libstdc++15.3 | Debug/Release、移動後find_package、Eigen oracle suite | numerical以外は通過、allocator probeは両構成で校正後0回。numericalは精度gateで失敗 |
| Linux Clang20.1.8 / libc++20.1.8 | 同tests、移動後find_package、Eigen oracle suite | numerical以外は通過、allocator probeは両構成で0回。numericalは精度gateで失敗 |
| Clang ASan/UBSan | 同tests、移動後find_package、Eigen oracle suite | numerical以外は通過。numericalは精度gateで失敗 |
| wasm32 Emscripten6.0.10 / Node24.21.0 | matvec/LLT/QR、容量・事前出力保持、growth、resize失敗、copy寿命、dispose | 通過、校正後compute確保0回、2×2数値領域168 bytes |
| Chromium153.0.8010.12 / Firefox155.0 / WebKit26.6 | Playwright1.63.0でHTTP経由の同WASM tests | 3 engineすべて通過 |
| ESP32-S3 / ESP-IDF6.1 / Xtensa15.2.0 | 共通2×2と校正付きheap/stack probeをC++20でcross compile | hosted CI通過。ELF/bin/map生成、最終規格と例外・RTTI off確認。実機未検証 |
| ESP32-C3 / ESP-IDF6.1 / RISC-V15.2.0 | 同C++20 cross compile | hosted CI通過、同flags確認。実機未検証 |

[Node結果](portability/node.json)、[browser結果](portability/browsers.json)、
[WASM hash・firmware hash・ESP実compile command・source hashes](portability/evidence.json)を保存した。
このlocal firmware記録は規格修正前のC++26のもので、C++20受入には使用しない。
新しい[hosted evidence](portability/hosted/evidence.json)にC++20の実commandとfirmware/config hashを保存した。
firmwareに対する実機受入には、このhosted hashと対応するserial結果が必要。
SDK全体のheap空きとstack値は実機実行後に取得するため、ここでは合格値を記載しない。

Windowsの全11 testsには、100桁stress oracleの既存基準に対する失敗が含まれる。
condition1e8、大残差、scale1e-150の2変数で、oracle解[0.5,-1]に対して
core解[0.493356,-0.993356]となり、解誤差1e-4を満たしていない。
raw Eigenにも尺度と大残差による精度低下がある。この結果を速度優位や合格として扱わない。
consistent backward errorと100桁rank境界oracleは追加済みだが、全stress suiteの合格は未達。
精度条件を黙って変更・skipせず、採用する保証範囲の判断を待つ。

GitHub [run 37482428992](https://github.com/takuto-NA/kibo-linalg/actions/runs/37482428992)、
source `d5d6503670da7946e5528afd77643f0d432800b2` でWASMとESP32-S3/C3のjobが通過した。
[Node](portability/hosted/node-results.json)と[browser](portability/hosted/browser-results.json)結果、
Windows固定版の新規install metadataも保存した。PCの4 jobはnumerical gateで失敗し、run全体はfailure。
[Windows Release](numerical/windows-release.txt)、[GCC Release](numerical/gcc-release.txt)、
[GCC Debug](numerical/gcc-debug.txt)の失敗を含む数値結果を保存した。
入力logと抽出結果のhashは[diagnostic source](portability/hosted/diagnostic-source.json)を参照。
追加の[run 37484637536](https://github.com/takuto-NA/kibo-linalg/actions/runs/37484637536)、
source `8b10a9e0efb13d820962a41e753d21a9a4d79253` ではGCC/Clang/ASan/UBSanの
Releaseでn=2/8/32/128/512、m=n/4nの全10構成のprepared LLT/QR allocation count0を確認した。
Debugはn<=32の6構成を確認した。[実command・結果・入力log hash](portability/hosted/prepared-allocation.json)を保存した。
数値stress gateは引き続き失敗している。
MSVCのscalar候補 /Qvec- はD9002で無視されたため棄却し、
supported flagsを用いるLinux Clang scalar系列を主Windows系列と分けて測定する。
