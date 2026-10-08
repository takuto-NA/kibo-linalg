# kibo-linalg

PCでの連続最適化を起点に、ESP32とWASMでも使うC++20の線形代数ライブラリです。
初期実装はdoubleの密行列、基本演算、Cholesky分解のLLT、列pivot付きQRを提供します。
固定行列・外部ビューとcaller workspaceを使う計算経路は、例外・RTTI・ヒープ確保を要求しません。
動的所有行列の確保・resize・cloneは明示的に行います。

現在は開発版です。Eigen同等の性能、ESP32実機での動作は保証していません。
検証する環境と範囲は[CI文書](docs/ci.md)を参照してください。
Eigenとのsource互換はありません。疎行列、SVD、最小ノルム解、最適化アルゴリズム本体は初期範囲の外です。
n=2〜512は初期評価範囲であり、対応サイズの上限ではありません。

## 小さな計算

```cpp
#include <kibo/linalg.hpp>
#include <array>

int main() {
    using namespace kibo::linalg;
    StaticMatrix<double, 2, 2> a;
    a(0,0)=4; a(0,1)=1; a(1,0)=1; a(1,1)=3;
    const std::array<double,2> x{1,2};
    std::array<double,2> y{};
    auto status=matvec_into(a.const_view(),std::span<const double>{x},std::span<double>{y});
    if (!status) return 1;
    return y[0]==6 && y[1]==7 ? 0 : 2;
}
```

headers-onlyで `include/` をinclude pathに追加するか、CMake targetを使用します。
コアのconsumerにはEigen、Python、Node、ESP-IDFは不要です。

```cmake
find_package(kibo_linalg 0.1 CONFIG REQUIRED)
target_link_libraries(my_program PRIVATE kibo::linalg)
```

```sh
cmake -S . -B build/package -DBUILD_TESTING=OFF -DKIBO_BUILD_EXAMPLES=OFF -DKIBO_BUILD_BENCHMARKS=OFF
cmake --build build/package --config Release
cmake --install build/package --config Release --prefix /path/to/prefix
```

利用側のconfigure時に `-DCMAKE_PREFIX_PATH=/path/to/prefix` を指定します。
targetが伝播する要件はC++20とinclude pathです。例外・RTTI・最適化flagは利用側で選びます。

APIと失敗・寿命・aliasの契約は[API文書](docs/api.md)、
所有・ビュー・積・LLT・QRの導入例は[Eigenからの移行](docs/eigen-migration.md)を参照してください。
[CIの再現方法](docs/ci.md)、[WASM facade](docs/wasm.md)、[ESP32 firmware](docs/esp32.md)、
[性能評価方法](docs/benchmarks.md)を用意しています。
用語は[CONTEXT.md](CONTEXT.md)、設計判断は[ADR](docs/adr/)を参照してください。
開発計画・課題・検証履歴は[GitHub Issues](https://github.com/takuto-NA/kibo-linalg/issues/9)で管理します。
ライセンスは未設定です。
