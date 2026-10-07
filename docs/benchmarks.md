# PCの参照ワークロードと性能測定

`kibo_lm_reference` は評価harnessで、optimizer製品APIではない。
normal-LLTとaugmented-QRで同じ中央差分Jacobian、lambda、D=I、受理/停止設定を使う。
差分stepは1e-6*(1+|parameter|)、tolGradient1e-6、最大100反復。
lambda初期1e-3、受理時0.3倍（下限1e-15）、棄却時10倍。
直線/指数の両solverはWindowsで2反復以内に所定のcostとparameter誤差を満たした。

```powershell
./tools/windows-cmake.ps1 -S . -B build/native '-DKIBO_EIGEN_INCLUDE_DIR=<fixed Eigen headers>'
./tools/windows-cmake.ps1 --build build/native --config Release --target kibo_dense_benchmark
./tools/run-benchmarks.ps1 -OutputDirectory build/benchmarks-new-primary
python tools/summarize-benchmarks.py build/benchmarks-new-primary
```

出力directoryは空のものを使う。runnerは既存の証拠を上書きせず、非空directoryを拒否する。
Linux scalar binaryは固定Docker imageで `tools/scalar-build.sh` を実行して作る。
同じPCで主系列を終えてから追加系列を測定する。

```powershell
./tools/run-benchmarks.ps1 -Executable build/linux-scalar/kibo_dense_benchmark -OutputDirectory build/benchmarks-new-scalar -LinuxScalar
python tools/summarize-benchmarks.py build/benchmarks-new-scalar
python tools/plot-benchmarks.py build/benchmarks-new-primary build/benchmarks-new-scalar build/performance-comparison
```

plotは任意のMatplotlib依存でPNG・SVG・PDFを生成する。library consumerには不要。
2026-10-07の正式比較は[性能報告](validation/2026-10-07-performance.md)にまとめる。

性能fixtureはxorshift32 seed0x6b69626fで生成する。
Jの各要素は[-0.5,0.5)/sqrt(m)に上部対角2を加えたもの。
既知解は全要素1、RHSは各行をcolumn indexの昇順で加算する。
入力生成にEigenのSIMD依存の積を使わず、主比較とscalar比較のfixture hashを照合する。
Eigenの対称固有値解法でJᵀJを独立に評価し、condition<=100を確認する。
SHA256付きraw artifacts、m/n別FNV1a64 fixture hash、CPU/OS/flags/solver/layoutを保存する。
FNVの入力はlittle-endianのuint64 m,n、row-major double J、double RHSの順。

Release、fast-math off、single-thread、warmup5、30 samples、各sample20ms以上のbatch。
5 process runsでcore/Eigenの順を交替し、factorの要素と解をvolatileへ消費して消去を防ぐ。
各sampleは固定回数のbatchの前後だけで時計を取得する。
20ms未満ならbatch回数を倍にして取り直し、採用したbatchの時間を呼出し数で割る。
lambda1e-3、D=Iのlinear stepを、別のEigen LDLTから求めた解にrelative error1e-8以内で照合してから測定する。
失敗は速度結果として採用せず実行を停止する。
Eigen5.0.1は通常のx64 SIMDを主比較とし、別buildの `KIBO_SCALAR_EIGEN=ON` で公平scalar比較を取れる。
scalar設定は同じtranslation unitの両backendに適用する。
`EIGEN_DONT_VECTORIZE=1`と`KIBO_DISABLE_SIMD=1`で両者の明示SIMDを無効にし、
下記flagsで自動vectorizationも無効にする。
固定MSVCでは /Qvec- がD9002で無視されることを確認したため、scalar構成を受理しない。
主比較はWindows MSVC、追加scalar比較は固定Linux Clangで行う。
Clangでは -fno-vectorize -fno-slp-vectorize -ffp-contract=off、
GCCでは -fno-tree-vectorize -fno-tree-slp-vectorize -ffp-contract=offを使う。
異なるcompiler/OSの比較を主比較へ混ぜず、それぞれ同じprocess内の両backendを比較する。

phaseはfactor、solve、factor+solve、setup/allocation/copy込みを分ける。
全phaseで、JᵀJ+lambda IとJᵀb、またはaugmented matrix/RHSの組立ては計測前に済ませる。
setup phaseは組立て済み入力からの領域確保・layout copy・factor・solveを含む。
Jacobian生成やGram/augmented組立てを含むLM反復全体の時間ではない。
coreはrow-major、Eigenはcolumn-majorへの準備済みcopyを使い、変換の費用はsetup phaseに含める。
容量はharnessで同時に生存するinput/output/factor/copy/workspaceを含む数値領域の保守的な計算値。
allocator管理領域やmodule/OS予約は数値領域と別。64 MiB以下をgateにする。
raw CSVのnumeric_bytesは既知の明示bufferの合計で、Eigen内部packingを別に補う。
summaryのnumeric_bytesはEigen LLTの内部補助領域に4*n*n*sizeof(double)の
保守的上限を加えた容量、explicit_numeric_bytesはrawと同じ明示buffer容量。
[固定Eigenの容量監査](research/eigen-capacity.md)に根拠を記録する。
正式な測定で未完了runや途中試行を合算しない。

summaryは5 process mediansの中央値と各process p95の中央値。
95%区間は5個のpaired process ratioを10000回bootstrapした中央値の区間。
少数processによる区間であり、30個の同一process sampleを独立processとして扱わない。
ratio=kibo/Eigen、1より大きければそのcaseではcoreが遅い。
hosted CIで絶対速度をgateにせず、固定PCで20%以上の悪化が区間込みで再現したらレビューする。

悪条件・大残差の精度保証は別の数値検証チケットで扱う。
通常fixtureの速度を、Eigen全体や未知のworkloadへの優位として一般化しない。

公開solverの配置改善については、[row/column格納ごとの旧版比較](validation/2026-10-07-solver-locality.md)を参照する。
こちらは同じharnessから元の公開headerと修正版をビルドし、CPU0固定でfactor+solveを測る追加系列である。
QR column格納も比較するが、setup/allocation込みの全phase測定の代わりにはしない。

[アセンブリから特定した32変数LLTの改善](research/eigen-assembly-gap.md)では、
入力走査・CRT分類呼出し・panel切替を単独対照で測り、公開実装へ反映した。
32変数の5 process再測定と周辺サイズの診断を区別して報告する。

[小行列LLTの実COFF命令比較](research/small-llt-assembly.md)では、31/32/33の分岐と
入力検査の依存関係を単独変更で比較し、公開実装`8fe28e5`を5 processで再測定した。
SSE2幅2を維持して改善している。n128/512と2変数の確保込みに残る差も報告し、
この結果を全shape・全phaseのEigen同等受入として扱わない。
