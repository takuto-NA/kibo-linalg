# 再現用toolchainとCI

固定URL/SHA256、Docker image digest、Actions full commit SHAは `tools/toolchains.lock.json`。
`tools/fetch-dependencies.py` はchecksumが一致するarchiveだけを使用する。
Eigenはtest/benchmark-onlyで、installしたlibraryには含めない。
numerical suiteはReleaseでn=2/8/32/128/512の全規模、Debugでn<=32を実行する。
100桁stress/rank oracleとkiboの精度の合格値は両構成で同じ。必須CHECKの失敗を全件記録して最後に非zeroで終了する。
Eigen自身のforward errorは入力条件・誤差・閾値・合否を比較診断として保存し、製品の終了コードには加えない。
rank/条件数を含むfixture検証は必須のまま。[判断記録](adr/0010-reference-accuracy-diagnostics.md)を参照。
Linuxは構成別の`Testing/Temporary/LastTest.log`、Windowsは`Debug-LastTest.log`と`Release-LastTest.log`に、
成功した数値testのEigen診断も残し、CI artifactへ保存する。
制御fixtureの実条件数は独立SVDで公称値の1%以内と確認する。
Eigenは固定commitを指定した公開APIから取得する。

## 検証範囲

| 環境 | CIでの確認 |
| --- | --- |
| Windows x64 MSVC | Debug/Release、公開API・数値精度、無例外/RTTI、移設package |
| Linux x64 GCC・Clang/libc++ | Debug/Release、公開API・数値精度、無例外/RTTI、移設package |
| Linux Clang ASan/UBSan | Debug/Releaseの上記testsとsanitizer |
| WASM wasm32 | NodeとChromium/Firefox/WebKitの数値・メモリ寿命tests |
| ESP32-S3/C3 | ESP-IDFでのcross compile。実機動作は未検証 |

通常/scalarのLLT・QR契約テストと、通常構成のrow/column数値suiteを実行する。
全PC構成におけるscalar数値suiteの完全な組合せは未検証。
allocation計測はWindows DebugとLinuxで行い、MSVC Releaseは計測器がないためskipする。
必須CHECKの失敗と未実行の計測を区別する。絶対速度はCIの合格条件にしない。
現在のrunは[GitHub Actions](https://github.com/takuto-NA/kibo-linalg/actions/workflows/ci.yml)で確認できる。

## Windows

Windowsの基準構成はVS 2022 17.14.25、toolset14.44.35207、cl19.44.35222.0。
固定bootstrapper、archive、compilerの版とchecksumはlock manifestで検証する。

```powershell
python tools/fetch-dependencies.py --platform windows --eigen --msvc
./tools/windows-test.ps1
```

通常は既存の固定版を検証する。GitHubの使い捨てrunnerでは
`-AllowToolchainInstall` を付け、該当版がなければ固定bootstrapperから専用installPathへ取得する。
取得不能/版不一致/hash不一致はfailとし、hosted runnerの別版を固定版passにしない。
手元の保持にはbootstrapper・lockfile・CMake archiveを保存し、基準toolsetを更新で置換しない。
新規installを行う場合はWindows SDK26100とVC.Tools.x86.x64を選択する。

## Linux

数値suiteを実行するにはEigenの取得とinclude設定の両方が必要。
以下の手順はリポジトリのルートで実行する。

```sh
python tools/fetch-dependencies.py --eigen --llvm
docker run --rm -v "$PWD:/work" -w /work \
  -e KIBO_CMAKE_OPTIONS=-DKIBO_EIGEN_INCLUDE_DIR=/work/.cache/eigen \
  gcc:15.3@sha256:ead103e6d03b69232962d467f3520c3f70b6718c69ff71efcc08efe9011fadb6 \
  sh tools/linux-test.sh
```

Clangは公式LLVM20.1.8 archiveから展開し、libc++のリンクとrpathを指定する。
exact commandsは `.github/workflows/ci.yml`。ASan/UBSanは独立jobで実行する。
Debug/Release、無例外/RTTI、公開API、prepared allocation、移動したinstall prefixからの
find_package consumerを検証する。数値referenceはEigen include pathを追加して実行する。
sanitizerとLinux allocator wrappersはmalloc系とreplacement newを観測する。
別shared library内部のすべてのmallocを追跡する一般的なsystem profilerとは区別する。

## 更新

版の更新はURL/digest/checksumを一緒に変更し、compiler version、公開API、install consumer、
数値精度、各対象のbuild/runを再検証する。性能baselineの更新は固定PCの5 process runsを別に取る。
通常CIでは絶対計算時間をgateにしない。CI artifactsには版、flags、configure/test logを保存する。
実行結果と環境ごとの未検証事項は関連Issueへ記録する。
