# Eigen性能差の原因を一変更ずつ切り分ける

2026-10-07。対象は初期PC評価のdouble密行列、512変数・2048残差のLM linear step。
[先行調査](eigen-kernel-gap.md)の複合試作を分解し、共通の計算構成とSSE2実装の影響を区別した。
この調査は原因の特定であり、全サイズの同等性能や悪条件精度、release readinessの認定ではない。
公開 `include/kibo/` は変更せず、[独立診断コード](../../tools/diagnostics/eigen-root-cause/)で実験した。

## 固定条件

Windows/MSVC19.44.35222.0、Release `/O2 /Ob2 /DNDEBUG /fp:precise`、C++20、single-thread。
Eigen5.0.1 commit `bc3b39870ecb690a623a3f49149a358b95c5781d` のarchiveと全Eigen headerを照合した。
ISA追加指定なし、Eigen double packet=2、coreのSSE2経路は有効。
全計測processをlogical CPU0に固定し、CPUID core type=64（Intel P-core）を確認した。
以前のCPU固定なしの絶対時間とは合算しない。

正式harnessと同じseedのJ（2048×512）、r、lambda=1e-3、D=Iを使う。
QRはA=[J; sqrt(lambda)I]（2560×512）、b=[r;0]。
LLTはH=JᵀJ+lambda I、g=Jᵀr。全backendの解を独立したEigen LDLTによるnormal-system解と
relative error1e-8以内で照合する。入力組立て、oracle生成、外部buffer準備は時間外。
coreの内部copy・検査、Eigenの内部copy・packingは時間内。allocatorの正式監査は今回行っていない。

各variantは5 warmup、同じbatch長でcore/Eigenの順を交替した30 samples、5 process。
processごとのvariant順も固定seedで並べ替えた。各processは両backendとも25 ms以上になるbatchを
測定前に選ぶ。中央値はprocess中央値の中央値、比率は各processのcore/Eigen比の中央値。
phaseは各processの測定call平均を求め、その5 processの中央値を取る。wall中央値の和とは一致しない。
追加時計の負担を全variantへ共通に入れた。

[計測manifest・compiler・source/binary hash](../validation/performance/eigen-root-cause/matrix/manifest.json)、
[集計](../validation/performance/eigen-root-cause/matrix/summary.json)、
各sample原記録とchecksumを保存した。CPU/ISA条件とinput hashは各processのrawにも記録する。

## QRの因果比較

比較段階を一つずつ変えた。入力・数式・rank threshold・solveの失敗検査は共通。

| Variant | 変更 |
| --- | --- |
| row | 現行row-majorの計算構成 |
| cpp | column storageと連続列kernel。新しいcolumn dot/updateだけC++ scalar loop |
| sse | cppのcolumn dot/updateだけを明示SSE2に変更 |
| four | sseに4列projectionでのHouseholder vector読み込み共有を追加 |
| copy | fourから、preflight済みinputのcopyにある重複shape/有限値検査だけを除く |
| tile | copyと同じ検査配置で、copy順を8×8 tileへ変更 |
| defer | tileから、factor更新の検査を後続norm/projectionへ遅延。solveの検査は保持 |

cppのcolumn helperにはMSVC `#pragma loop(no_vector)` を指定した。
process全体がscalarになるわけではなく、既存row kernelなどはSSE2を保持する。
cpp→sseはこの限定された処理のSIMD化を比較するもので、異なるCPUアーキテクチャの比較ではない。
row→cppはlayout・access順・accumulator構成と、column helperのSIMD利用を一緒に変える比較で、layoutだけの寄与とは扱わない。
cpp→sseもreductionの加算順を変えるため、数式が共通でも丸めやrank判断が全入力で同じとは保証しない。

| variant | core ms | Eigen ms | 比率 |
| --- | ---: | ---: | ---: |
| `qr_row` | 166.435 | 87.299 | 1.903 |
| `qr_cpp` | 251.120 | 87.343 | 2.871 |
| `qr_sse` | 114.886 | 87.482 | 1.313 |
| `qr_four` | 109.277 | 87.748 | 1.245 |
| `qr_copy` | 107.532 | 87.772 | 1.225 |
| `qr_tile` | 107.232 | 87.793 | 1.221 |
| `qr_defer` | 91.792 | 87.529 | 1.048 |

| QRの詳細phase（平均、ms） | row | sse | tile | defer |
| --- | ---: | ---: | ---: | ---: |
| preflight | 1.127 | 1.111 | 1.115 | 1.105 |
| copy | 1.635 | 4.446 | 1.537 | 1.400 |
| 初期norm | 3.478 | 0.908 | 0.948 | 0.939 |
| pivot選択/swap | 9.784 | 0.646 | 0.638 | 0.634 |
| selected-column norm | 2.889 | 0.983 | 0.985 | 1.004 |
| Householder vector | 3.552 | 1.689 | 1.690 | 1.686 |

QRでは初期全列norm、各pivotで選んだ1列のnorm、必要なときだけのnorm刷新を別に数えた。
両実装はpartial norm downdateを使う。normを毎回全列で再計算している、という仮説はソースと
今回の計測counterで切り分けた。各factorでselected normは512回、cancellationによるrefreshは0回だった。
このfixtureで全列norm再計算は差の原因ではない。他の入力でrefreshが不要という意味ではない。

`defer`は診断用の試作。公開QR test snapshotと、2×1の残差変換overflow時の
`arithmetic_failure`・caller出力保持を確認するが、全入力のdiagnostic indexや
既存の難しい数値suiteを認定するものではない。検査を外しただけの速度を採用可能とは扱わない。

### 同じ配置でprojectionのループだけを変える

`q=Aᵀv`の独立microprobeも実施した。row single/fourは同じrow配置、column single/fourは同じcolumn配置を使う。
dyadic入力で全成分をexact oracleと照合する。layout copy・oracle・検査は時間外、projectionと出力初期化は時間内。
3 fresh process、2 warmup、各method・shapeにつき15 samples、各batch20 ms以上。各sampleでmethod順を回転・反転した。
外部process番号はmanifestで管理し、この実行ではharnessのprocess引数を省略したためraw内のprocessは全て0。
各process中央値の3 process中央値を示す。

| rows×columns | row single µs | row four µs | column single µs | column four µs | Eigen row µs | Eigen column µs |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 1024×512 | 85.145 | 63.533 | 74.823 | 55.449 | 57.734 | 52.958 |
| 2560×512 | 221.101 | 163.109 | 196.152 | 143.254 | 147.583 | 130.235 |

2560×512では同じrow配置で221.101→163.109 µs、同じcolumn配置で196.152→143.254 µs。
行の処理を束ねてprojectionのload/storeを減らす、または4列でHouseholder vectorのloadを共有する効果は、
layoutの変更なしでも確認できた。compiler assemblyではcolumn CPP wrapperがscalar `mulsd/addsd`、
SSE2 wrapperの主ループがpacked `mulpd/addpd`を実行する。これは命令経路の確認であり、assemblyだけで改善量を求めたものではない。
純粋なprojectionの改善率をQR全体へそのまま掛けることはできない。

## LLTの因果比較

| Variant | 変更 |
| --- | --- |
| row | 現行8列panel、row-major storage |
| width64 | rowからpanel幅だけを64へ変更 |
| column | caller storageをtransposeして列方向に計算し、最後に公開lower layoutへ戻す |
| symmetry | columnから対称性検査のshortcutだけを変更 |
| wide | columnからtrailing updateの出力ループ幅だけを変更 |

symmetryとwideを同時に変えた先行試作の時間を、一変更の効果として扱わない。
columnへの変更はpanel構成とcopy/commitを含み、それぞれのphaseを計測する。
特にrow経路はpreflight後も `copy_into` で全入力の有限性を再検査し、全n²要素をcopyする。
column経路は検証済みinputの下三角だけをcopyする。copy時間の減少をlayoutだけに帰属しない。

| variant | core ms | Eigen ms | 比率 |
| --- | ---: | ---: | ---: |
| `llt_row` | 3.699 | 2.177 | 1.701 |
| `llt_width64` | 4.049 | 2.159 | 1.874 |
| `llt_column` | 2.914 | 2.164 | 1.346 |
| `llt_symmetry` | 2.800 | 2.198 | 1.279 |
| `llt_wide` | 2.763 | 2.174 | 1.291 |

| LLT phase（平均、ms） | row | width64 | column | symmetry | wide |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 入力検査 | 0.446 | 0.451 | 0.457 | 0.338 | 0.451 |
| copy | 0.259 | 0.260 | 0.082 | 0.079 | 0.078 |
| panel | 0.907 | 1.431 | 0.187 | 0.181 | 0.182 |
| trailing update | 1.968 | 1.797 | 1.998 | 1.996 | 1.849 |
| commit | 0.027 | 0.027 | 0.112 | 0.114 | 0.112 |

### 対称性検査だけの追加対照

同じcolumn試作・copy・panel・update・commitで、公開`LltOptions::check_symmetry`だけをtrue/falseに変えた。
finite検査は両方で保持する。3 fresh process、5 warmup、core/Eigen交替30 samples、共通batch25 ms以上を選んだ。
対称な正常入力を使う診断であり、falseの時間を既定の検査契約を満たす候補の速度として扱わない。

| option | core ms | Eigen ms | process内中央値比の3 process中央値 | input validation ms |
| --- | ---: | ---: | ---: | ---: |
| check_symmetry=true | 2.922 | 2.170 | 1.346 | 0.453 |
| check_symmetry=false | 2.684 | 2.171 | 1.230 | 0.200 |

検査phaseは0.453→0.200 ms、全体中央値は2.922→2.684 ms。
検査の仕事量が時間差の一部を作ることを一変更で確認した。ただし残る約0.200 msの入力検証と
約0.113 msのcommitは観測されたphase負担であり、Eigenにも自身のcopy・setupがあるので差へそのまま加算しない。
この対照でも約1.23倍であり、全体差が対称性検査だけという仮説は否定される。

### 後続行列更新だけの比較

coreとEigenで同じCの配置と下三角C-=UUᵀだけを実行し、rank8/64・残り64/128/256/448/504行を比較した。
入力とoracle、Cのresetは時間外。Eigen packingと、core columnの係数gatherは時間内。
row kernelの係数はfactor終了時と同じ配置であらかじめ用意する。
各methodは2 warmup batch・15 samples・20 ms以上のbatch、3 processで実行した。
dyadicな入力の全下三角をC0-calls*UUᵀと照合し、finiteとrelative-scaled error1e-10以下を要求する。
これはfull factor+solveの比率と合算しない。

coreのSSE2 kernelは1×8個の出力を保持するが、次の出力行へ進むたびにpanel値を再ロードする。
幅を16へ広げても、出力行をまたいだ共有は増えない。
Eigenはpackingした入力から複数行×複数列の出力tileを同時に計算する。
これは同じSSE2でも入力load数を減らす構成の違いである。
ソース上の論理load数と実際のcache miss数を混同しない。
この構造差から生じる速度差は仮説であり、下のmatched microprobeで検証した。

| remaining | rank | core row µs | Eigen row µs | core/Eigen row | core column µs | Eigen column µs | core/Eigen column |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 64 | 8 | 1.624 | 1.870 | 0.868 | 1.815 | 1.899 | 0.956 |
| 64 | 64 | 10.144 | 12.186 | 0.832 | 11.786 | 12.226 | 0.964 |
| 128 | 8 | 5.980 | 6.610 | 0.905 | 6.357 | 6.628 | 0.959 |
| 128 | 64 | 45.909 | 45.240 | 1.015 | 57.157 | 45.254 | 1.263 |
| 256 | 8 | 23.185 | 24.532 | 0.945 | 24.204 | 24.600 | 0.984 |
| 256 | 64 | 185.066 | 171.105 | 1.082 | 224.448 | 170.820 | 1.314 |
| 448 | 8 | 71.037 | 72.756 | 0.976 | 72.323 | 72.721 | 0.995 |
| 448 | 64 | 520.286 | 515.480 | 1.009 | 540.472 | 535.769 | 1.009 |
| 504 | 8 | 89.388 | 91.401 | 0.978 | 91.249 | 91.851 | 0.993 |
| 504 | 64 | 648.844 | 677.453 | 0.958 | 676.784 | 665.950 | 1.016 |

## strideとプロセッサ依存の部分

row strideの比較は同じ64-byte alignedのcaller backing allocationを使う。
512/520 doubles（4096/4160 bytes）など64-byteの倍数のstrideで、row開始alignmentと数式を固定した。
変えるのはrow間の距離だけで、検査・演算順・SSE2命令幅は変えない。

3 fresh process、各strideにつき5 warmup・30 samples・20 ms以上。2つ目のprocessではstride順を逆転した。
全strideでfinite・LDLT相対解誤差1e-8・relative residual1e-10を確認した。
全時間はfactor+solve中央値の3 process中央値、phaseは各processのfactor call平均の3 process中央値。

| stride doubles | stride bytes | factor+solve ms | panel ms | trailing update ms |
| ---: | ---: | ---: | ---: | ---: |
| 512 | 4096 | 3.665 | 0.870 | 2.006 |
| 520 | 4160 | 3.149 | 0.335 | 1.979 |
| 528 | 4224 | 3.146 | 0.339 | 1.990 |
| 576 | 4608 | 3.154 | 0.345 | 1.983 |
| 640 | 5120 | 3.412 | 0.599 | 1.981 |
| 768 | 6144 | 3.579 | 0.754 | 1.992 |
| 1024 | 8192 | 4.009 | 0.948 | 2.096 |
| 1032 | 8256 | 3.169 | 0.336 | 1.993 |

512→520の変更だけで全体3.665→3.149 ms、panel0.870→0.335 ms。trailing updateはほぼ変わらない。
同じ算術とSSE2のまま約0.5 msを回復でき、row panelのアドレス間隔が遅さを作ることを特定した。
この比較にはEigen測定を含めず、他系列のEigen時間で速度比を作らない。

CPUID leaf4がCPU0のL1 data cacheを64-byte line・64 sets・12 ways・48 KiBと報告した。
単純なset indexingでは4096/8192-byte strideは同じsetへ集中し、4160/8256-byte strideは行ごとにsetを進める。
書き込みや数値分解を含まない、volatile read-onlyの8成分・独立accumulator対照も3 processで測った。
同じ64-byte aligned backing pointer、同じrow数と演算、5 warmup・30 samples・20 ms以上を使う。
各process中央値の3 process中央値（ns/全row走査）を示す。

| live rows | 4096-byte stride | 4160-byte stride | 8192-byte stride | 8256-byte stride |
| ---: | ---: | ---: | ---: | ---: |
| 4 | 3.468 | 3.467 | 3.470 | 3.470 |
| 8 | 6.327 | 6.321 | 6.324 | 6.316 |
| 12 | 9.190 | 9.164 | 9.181 | 9.165 |
| 16 | 17.909 | 12.016 | 17.525 | 12.019 |
| 24 | 29.218 | 17.704 | 29.275 | 17.731 |
| 32 | 37.907 | 23.397 | 38.832 | 23.409 |
| 64 | 74.475 | 46.239 | 96.954 | 70.224 |
| 128 | 188.844 | 143.434 | 215.295 | 144.137 |
| 256 | 403.545 | 294.044 | 443.789 | 295.411 |
| 512 | 837.332 | 584.332 | 1172.777 | 587.556 |

12 rowsまでは差がほぼなく、16 rowsから4096/8192-byte strideで遅くなる。
12-way容量の境目と整合し、store-to-load依存がない対照でも差が出るため、L1 set競合を強く支持する。
ただしstride変更はTLB/page footprint・prefetchも変える。L1 miss counterによる機構の直接証明はしていない。
既存WPR/PMU recorderがないことを確認して固有instanceで記録開始を試みたが、
Windowsが`Access is denied / 0x80070005`を返した。記録は開始されず、他のsessionを停止していない。
[権限結果](../validation/performance/eigen-root-cause/hardware/pmu-attempt.json)を保存した。
汎用CacheMisses/LLCイベントをL1 missと呼び替えることもしていない。

[追加実験のmanifest・assembly・原記録](../validation/performance/eigen-root-cause/hardware/)、
[集計](../validation/performance/eigen-root-cause/hardware/summary.json)、source/binary hashとchecksumを保存した。
main系列とは別のfresh buildで、同じEigen archive・compiler flags・CPU0を使用した。


## 実測で特定した原因と保証の境界

| 原因候補 | 結果と範囲 |
| --- | --- |
| QRが列処理に不向きなlayout/access/accumulator構成 | 改善対象と特定。row→column SSE2で166.435→114.886 ms。複数の構成変更なのでlayoutだけの量には分解しない。norm・swapのphase短縮も整合する。 |
| QR column helperのSIMD実装 | CPP→SSE2の一変更で251.120→114.886 ms。ISAは両者SSE2の同じ機械。公開rowも既にSSE2なので「SIMDが全くない」は誤り。 |
| QR projectionの冗長なload/storeとvector load | 同じrow/column配置の独立projection対照で改善を確認。full QRのfourでも114.886→109.277 ms。 |
| QR factor内部の検査配置 | 同じtile構成でdeferすると107.232→91.792 ms。全契約同等性は未証明で、検査を消す採用判断にはしない。 |
| QRの全列normを毎pivot再計算 | このfixtureでは否定。partial norm downdateを使い、selected512回・refresh0回。 |
| LLT row panelのアドレス間隔 | 同じ算術・同じalignmentでstride512→520、panel0.870→0.335 ms。read-only対照の12/16 rows境界もL1 set競合を強く支持。具体的hardware miss数は未計測。 |
| LLTのcopy/検証/commitの仕事量 | 公開側にfinite/symmetry検査があり、column試作でも残る。対称性検査だけの対照で2.922→2.684 ms。Eigenが片三角のみ読むこととは契約が異なる。 |
| LLTがpanel幅8だから遅い | 幅64だけでは3.699→4.049 msへ悪化。単独原因として否定。 |
| Eigen packed GEMMがLLT差を支配する | 大remainingのmatched rank-updateでほぼ同等。支配説はこの実験では支持されない。compact strideであり、全shapeやfull factorの同等性は未証明。 |

差は「CPUごとに専用命令を書けば解消する」だけの問題ではない。
まずcolumnに合わせたbuffer/access、projectionのaccumulator、panelの配置、検査の仕事量と位置という
計算構成を改善し、その上で各ISAのpacket実装へ載せる必要がある。同じSSE2でも差を大幅に縮められた。
ESP/WASMを捨ててPC専用にすることや、C++20 APIをEigen互換にすることが必要という結果ではない。

QRの診断 endpointはこの1 shapeでEigen比1.048まで縮まった。
LLTはcolumn試作で1.346、対称性検査の診断対照でも約1.23が残る。
LLTの残差を1つの未測定kernelや命令へ割り当てず、実装反映時にEigenの各phaseとの追加対照で確認する。
公開実装の速度・精度はこの調査で改善していない。正式2〜512変数、m=n/4n、悪条件・大残差の既存gate、
無確保・失敗通知・scalar fallback・WASM/ESPを含む受入が別途必要である。


固定版Eigenの参照ソース：

- [QRのpivot/norm downdate](https://gitlab.com/libeigen/eigen/-/blob/bc3b39870ecb690a623a3f49149a358b95c5781d/Eigen/src/QR/ColPivHouseholderQR.h)
- [LLTのblocked factor / triangular solve / rankUpdate](https://gitlab.com/libeigen/eigen/-/blob/bc3b39870ecb690a623a3f49149a358b95c5781d/Eigen/src/Cholesky/LLT.h)
- [triangular matrix-matrix productとpacking](https://gitlab.com/libeigen/eigen/-/blob/bc3b39870ecb690a623a3f49149a358b95c5781d/Eigen/src/Core/products/GeneralMatrixMatrixTriangular.h)
- [GEMM register tileのtraitsとkernel](https://gitlab.com/libeigen/eigen/-/blob/bc3b39870ecb690a623a3f49149a358b95c5781d/Eigen/src/Core/products/GeneralBlockPanelKernel.h)

[PCのLM参照問題と2〜512変数のEigen比較を実行する](https://github.com/takuto-NA/kibo-linalg/issues/16)に
実装への反映と全形状での正式性能受入を残す。今回の特定結果を採用する際にも、
精度・失敗通知・workspace・無確保・scalar fallback・WASM/ESPの契約は維持する。
