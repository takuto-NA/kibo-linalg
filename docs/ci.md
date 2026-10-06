# 再現用toolchainとCI

固定URL/SHA256、Docker image digest、Actions full commit SHAは `tools/toolchains.lock.json`。
`tools/fetch-dependencies.py` はchecksumが一致するarchiveだけを使用する。
Eigenはtest/benchmark-onlyで、installしたlibraryには含めない。
numerical suiteはReleaseでn=2/8/32/128/512の全規模、Debugでn<=32を実行する。
100桁stress/rank oracleと精度の合格値は両構成で同じ。失敗を全件記録して最後に非zeroで終了する。
制御fixtureの実条件数は独立SVDで公称値の1%以内と確認する。
GitLabの通常archive URLがchallengeページを返したため、固定commitを指定した公開APIを使う。

## Windows

Microsoftの[固定版bootstrapper一覧](https://learn.microsoft.com/en-us/visualstudio/releases/2022/release-history)から
17.14.25/build17.14.36915.13のBuild Toolsを取得し、SHA256とMicrosoft署名を確認した。
既存インストールのVS版、toolset14.44.35207、cl19.44.35222.0とcl.exe hashも一致した。
新規インストールをローカルPCで実行したという証拠ではない。
GitHubの[hosted Windows job](https://github.com/takuto-NA/kibo-linalg/actions/runs/37482428992/job/112333743363)では
固定bootstrapperから `C:\kibo-vs17.14.25` に新規installし、版とcl.exe hashを検証して
Debug/Releaseおよび移動後consumerを実行した。[install metadata](validation/portability/hosted/windows-toolchain.json)を保存した。
このjobは数値stress gateで失敗しており、固定toolchain取得の成功と全tests合格を区別する。

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

```sh
python tools/fetch-dependencies.py --eigen --llvm
docker run --rm -v "$PWD:/work" -w /work \
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
workflowを書いたこととGitHubでの成功runは別で、受入報告に実際のrun URLを記録する。

[run 37484637536](https://github.com/takuto-NA/kibo-linalg/actions/runs/37484637536)では、
Windows Debug/Releaseの個別EH解除・GR無効・STL設定の実commandと構成別CTest log、
GCC/Clang/ASan/UBSanのcompile commands・image digest・test/relocated consumer logを保存した。
[抽出したcommandと無確保probeの証拠](validation/portability/hosted/prepared-allocation.json)を参照。
Linux Releaseの全10構成でprepared LLT/QR確保0回を確認した。
4つのPC jobは数値stress gateでfailureとなり、通常consumerやtoolchain取得の成功を
全tests合格とは表示しない。WASMとESP32-S3/C3のjobは再度通過した。
