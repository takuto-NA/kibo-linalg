# CMake、CI、WASM adapterと比較対象の一次資料

確認日: 2026-10-06。一次資料の読み取りのみ。SDK導入、library build、CI実行、実機runは行っていない。

## 公開された固定基準

- CMake3.30のINTERFACE libraryはcompile済みlibraryを生成せずinstall/exportできる。cxx_std_20は利用側の最低modeを要求するが全機能適合の証明ではない。[INTERFACE](https://cmake.org/cmake/help/v3.30/command/add_library.html#interface-libraries)、[C++ feature](https://cmake.org/cmake/help/v3.30/prop_gbl/CMAKE_CXX_KNOWN_FEATURES.html)、[export/package](https://cmake.org/cmake/help/v3.30/guide/tutorial/Adding%20Export%20Configuration.html)
- MSVCの/GR-はRTTIを無効化する。/EHsc-は/EHsと/EHc-として解釈され、例外無効の指定ではない。個別解除/EHa- /EHs- /EHc-、compiler macros、STL設定、source不使用を区別する。無unwind設定でもMSVCがthrowソースを禁止する保証とはしない。[EH](https://learn.microsoft.com/en-us/cpp/build/reference/eh-exception-handling-model?view=msvc-170)、[GR](https://learn.microsoft.com/en-us/cpp/build/reference/gr-enable-run-time-type-information?view=msvc-170)、[macros](https://learn.microsoft.com/en-us/cpp/preprocessor/predefined-macros?view=msvc-170)
- GitHub hosted imageは更新され、windows-2022/ubuntu-24.04という世代labelだけではcompiler patchやCPU/負荷まで固定しない。固定toolchain/OCI digestはユーザー空間の再現性を改善するが性能基準機の代わりではない。[runner images](https://github.com/actions/runner-images#image-definitions)
- Emscripten6.0.10固定資料はextern C、EXPORTED_FUNCTIONS、heap上の配列交換を説明する。C++ object layoutをextern CだけでJSへ渡せるとは解釈しない。独自viewはgrowth後に再取得する。[固定資料](https://raw.githubusercontent.com/emscripten-core/emscripten/6.0.10/site/source/docs/porting/connecting_cpp_and_javascript/Interacting-with-code.rst)
- Playwright1.63.0の公開releaseとfixed browsers.jsonを確認。対応Chromium153.0.8010.12/revision1243、Firefox155.0/revision1543、WebKit26.6/revision2359。package完全版、lockfile、対応binaryを組で固定する。3engineは全製品/OS/版の保証ではない。[release](https://github.com/microsoft/playwright/releases/tag/v1.63.0)、[browsers.json](https://raw.githubusercontent.com/microsoft/playwright/v1.63.0/packages/playwright-core/browsers.json)
- Node24はLTS系列で、確認時の公開patch24.21.0を基準にする。majorだけの指定をpatch固定とは扱わない。[Node releases](https://nodejs.org/en/about/previous-releases)
- Eigen3.4.0はcommit3147391d946bb4b6c68edd901f2add6ac1f31f8cで公開されている。一方、初期主比較は公開tag5.0.1/commitbc3b39870ecb690a623a3f49149a358b95c5781dにする。古い版だけの比較をEigen全体へ一般化しない。[3.4.0 tag API](https://gitlab.com/api/v4/projects/libeigen%2Feigen/repository/tags/3.4.0)、[5.0.1 tag API](https://gitlab.com/api/v4/projects/libeigen%2Feigen/repository/tags/5.0.1)

## 実装で確認する項目

固定compiler/SDKの取得と版一致、Windows無例外consumer、prefix移動後find_package、3engine WASM、両ESP target cross compileと各実機runは、採用した計画と実際の通過結果を分けて記録する。
concrete OCI digest/Actions SHA/download checksumは実装チケットの受入条件としてlock manifestに固定する。

現在の正式な判断は[合格基準](https://github.com/takuto-NA/kibo-linalg/issues/8#issuecomment-6016198293)、実装の親仕様は[初期仕様](https://github.com/takuto-NA/kibo-linalg/issues/9)。

