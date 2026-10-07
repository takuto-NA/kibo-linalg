# 元入力を使うQR補正APIの公開経路検証

公開実装は `6ef5701`。ユーザー承認の [ADR0009](../adr/0009-original-input-qr-refinement.md) に従い、
通常solveを維持し、元Aを受け取る `solve_refined_into` を追加した。
同じdouble Rを再利用し、power-of-two scalingしたdouble-double残差・勾配で2回補正する。
元入力の保持と追加の計算費用を必要とする。

## PCの精度と契約

Windows MSVC 19.44.35222、GCC 15.3、Clang 20.1.8/libc++、Clang/ASan+UBSanで検証した。
Linuxの各構成には、明示SIMDと自動vectorizationを無効にした別構成も含む。
7構成の各102件、計714件を、実際の丸め済み入力を解く独立100桁oracleへ照合した。
6既存oracleとcontrolled n=2/8/32/128/512、m=n/4n、condition=2/1e4/1e8、row/column factorを使う。
square full-rankに非零orthogonal residualを作らない。

全件で補正status成功、rank=n、oracleとの差は最大1.11023e-16、normalized optimalityは最大3.66926e-17。
condition<=1e4で既知解との差<=1e-8、condition1e8で<=1e-4、consistent系のnormalized backwardと
全系のoptimality<=100 epsilon max(m,n)を維持する。通常solveの同じstress結果も保存した。
大問題のoracleは、全要素のbit一致を検証したXOR-circulant構造専用であり、任意の密行列への証明ではない。

公開契約テストは、row/column/interleaved/padded stride、pivot permutation、RHS/output完全一致、
無効factor、形状・容量・alignment、非有限A/RHS、補正途中のoverflowと解保持、
denorm_min/1e-300/1e300/2^1023のscale端点を検証した。既存rank不足診断も維持する。
例外・RTTI不要のconsumer、scalar、移設したfind_package consumerも通過した。
prepared allocationの校正と測定はWindows Debug・Linux Debug/Releaseで通過した。
計測器のないMSVC Releaseは従来どおり未測定のskipで、確保0と偽って扱わない。
ASan/UBSan異常は検出していない。

Windows・Linuxの数値CTest全体は失敗状態である。各row/column実行の残り8 CHECKは
Eigen自身の既存forward-error判定だけで、kiboの精度・status・rank・LLT判定はすべて通過した。
Eigenを診断比較へ変える別の判断が未回答のため、Eigen精度CHECKを削除していない。
この結果を親の精度受入やCI全体の完了とは扱わない。

## 公開APIの費用と容量

CPU0/P-coreに固定し、他のbuild/testを止め、warmup5回、各batch>=20ms、1 process×5 samplesで測った。
setupを除外した公開APIの費用診断であり、正式なEigen性能受入の代わりにしない。
以下はm=4n、condition1e8、column factorの中央値。refined solveには初回の通常solveも含む。

| n | 通常solve | 補正solve | factor+通常solve | factor+補正solve | 全体費用の比 |
|---:|---:|---:|---:|---:|---:|
| 2 | 0.0424 us | 0.297 us | 0.168 us | 0.421 us | 2.50 |
| 8 | 0.195 us | 3.343 us | 1.966 us | 5.195 us | 2.64 |
| 32 | 1.634 us | 54.273 us | 37.958 us | 91.278 us | 2.40 |
| 128 | 23.404 us | 877.794 us | 1324.831 us | 2175.925 us | 1.64 |
| 512 | 555.263 us | 16676.400 us | 82116.100 us | 98335.700 us | 1.20 |

workspaceは2m+3n doubles。最大のm=2048/n=512では44 KiB、元Aは8 MiB。
元A/RHS・factor/tau/permutation・解・workspaceを同時に保持する明示数値領域は約16.1 MiBで、
64 MiB予算に収まる。元Aはこの呼出し中だけ有効でよく、factorが元Aを所有する契約には変えていない。

## WASMとESP32

固定Emscripten 6.0.10のwasm32・single-thread・SIMD必須なしでビルドし、Node 24.21.0と
Chromium/Firefox/WebKitで同じ補正oracle、prepared allocation0、容量不足時の全出力保持、
途中算術失敗時の解保持、resize後の補正を確認した。追加C exportはABI v1の引数形式を保つ。
通常facadeの容量を保ち、`{refinement:true}` で補正領域を準備する。

ESP32-S3/C3はC++20・exceptions/RTTI offで補正を呼ぶ共通サンプルのELF生成まで確認した。
サンプルの数値構造体はESP32/wasm32で248 bytes、Windows x64実測256 bytes。
ユーザーから実機なしとの回答があり、ESPの精度実行・stack high-water・無確保は未受入である。

## 証拠

[metadata](../validation/numerical/refined-public/metadata.json) と
[全保存ファイルのSHA256](../validation/numerical/refined-public/SHA256SUMS.json) に、
生入力・解・oracle、全CTest結果、compile flags、ソース、module/firmware/binary hashと実行コマンドを保存した。
元prototypeの [保存証拠](../validation/numerical/rounded-input/metadata.json) は上書きしていない。
hosted CIの新しい実行証拠は、この公開実装をpushした後に別途保存する。
