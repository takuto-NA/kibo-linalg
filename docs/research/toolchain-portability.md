# C++20と初期ターゲットのツールチェーン調査

確認日: 2026-10-06。この文書は一次資料とローカル環境の読み取りによる事実確認。ライブラリの実装、SDKの導入、クロスコンパイル、実機実行は行っていない。

## ローカルで確認したもの

- Visual Studio 2022 CommunityとBuild Tools: 17.14.25 / installationVersion 17.14.36915.13。vswhereでC++ツールを含むインストールを確認した。
- Build Toolsの既定VC toolset: 14.44.35207。cl.exeのFileVersion: 19.44.35222.0。
- CMake: 3.30.5。
- Docker CLI: 28.3.0。エンジンやコンテナの利用可否は未確認。
- cl、clang++、g++、emccは通常のPowerShellのPATHでは見つからなかった。MSVCについては、上記のインストール先にcl.exeが存在することを別途確認した。
- 確認した標準的なESP-IDF/emsdk候補ディレクトリは見つからなかった。マシン全体を探索したわけではなく、未インストールと断定しない。

## 一次資料で確認したもの

- MSVCはC++20、concepts、std::spanへの対応を公開し、spanにはC++20以上を要求する。[言語対応表](https://learn.microsoft.com/en-us/cpp/overview/visual-cpp-language-conformance?view=msvc-170)、[span](https://learn.microsoft.com/en-us/cpp/standard-library/span?view=msvc-170)
- GCC/Clangと標準ライブラリはconcepts/spanの対応を公開している。C++20の使用機能を実際に検証することと、規格の全機能が完全実装されていると主張することは区別する。[GCC](https://gcc.gnu.org/projects/cxx-status.html)、[libstdc++](https://gcc.gnu.org/onlinedocs/libstdc++/manual/status.html)、[Clang](https://clang.llvm.org/cxx_status.html)、[libc++](https://libcxx.llvm.org/Status/Cxx20.html)
- GCC 15系列には15.3が公開されている。LLVM/Clangの固定版として20.1.8の公開リリースが存在する。どちらも、このプロジェクトで既に動作確認した版ではない。[GCC 15系列](https://gcc.gnu.org/gcc-15/)、[LLVM 20.1.8](https://github.com/llvm/llvm-project/releases/tag/llvmorg-20.1.8)
- ESP-IDF v6.1が公開され、固定されたtools.jsonではXtensaとRISC-Vの推奨GCCはesp-15.2.0_20251204。chip向けの既定C++規格とcomponent側で指定する最低C++規格は区別する。例外とRTTIは既定で無効。[v6.1リリース](https://github.com/espressif/esp-idf/releases/tag/v6.1)、[固定tools.json](https://github.com/espressif/esp-idf/blob/v6.1/tools/tools.json)、[固定版C++ガイド](https://docs.espressif.com/projects/esp-idf/en/v6.1/esp32s3/api-guides/cplusplus.html)
- Emscripten 6.0.10の公開リリースが存在する。一方、確認したemsdk manifestのlatest aliasは6.0.11。公開ReleaseとSDKのlatest aliasを同一値として扱わず、番号指定でSDKを固定する。[6.0.10](https://github.com/emscripten-core/emscripten/releases/tag/6.0.10)、[固定emsdk manifest](https://github.com/emscripten-core/emsdk/blob/96c657fc60920d2a6a82318aa50e0abf82749604/emscripten-releases-tags.json)、[SDK導入方法](https://emscripten.org/docs/getting_started/downloads.html)
- EmscriptenのSIMDとpthreadは明示的に有効化する構成。pthreadには配信側のCOOP/COEP等も必要。例外catchが既定で無効なことと、ソースを例外なしでコンパイルできることは別なので、ポータブルなコアの構成は明示的に検証する。[emcc](https://emscripten.org/docs/tools_reference/emcc.html)、[SIMD](https://emscripten.org/docs/porting/simd.html)、[pthread](https://emscripten.org/docs/porting/pthreads.html)、[例外](https://emscripten.org/docs/porting/exceptions.html)
- Node 24は確認時点でLTS系列。ブラウザ検証の候補となるPlaywrightはChromium/Firefox/WebKitを扱い、各リリースに対応するbrowser binaryの版を要求する。検証ツールとエンジンの版は組で固定できるが、それは全ブラウザ製品・全バージョンを保証することとは異なる。[Node](https://nodejs.org/en/about/previous-releases)、[browser構成](https://playwright.dev/docs/browsers)

## 設計への示唆

- 最低言語規格と、保証するコンパイラ/SDKの版を別に定める。latestの変化で保証範囲が暗黙に変わらない構成にする。
- 例外・RTTI・ヒープを必要とするかは、コンパイラの対応表だけでは決まらない。APIとアルゴリズムの契約を定め、該当構成を実際にビルド・実行する。
- ESP32のクロスコンパイルと実機実行を区別する。PC向けの最大規模の評価をESP32のメモリ予算に転用しない。
- コアC++20の使用機能、最小の数値計算、例外/RTTIなし、無確保構成を確認する具体的なprobeとCIは、実装・検証段階で作る。
