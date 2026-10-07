# Eigenとの性能差の原因調査

2026-10-07。Eigenに性能で届かない理由を、固定ソースの読み取りと条件を変えた実験で調べた。
Eigen相当を開発目標にする根拠はある。現在の約1.7倍の時間差を、ポータビリティや無確保の
必然的な代償として扱う根拠はない。一方、オープンソースであることだけで同等速度が保証されるわけではない。

Eigenは主にMPL2のオープンソースである（[公式ライセンス説明](https://gitlab.com/libeigen/eigen/-/blob/master/COPYING.README)）。
今回の比較ソースはEigen5.0.1、commit `bc3b39870ecb690a623a3f49149a358b95c5781d`。
実装の読み取りはその固定版で行った。試作にはEigen実装をコピーしていない。

## 現行コアと今回の試作の区別

[正式比較](../validation/2026-10-07-dispatch-performance.md)の現行コアは
`83c7a143599cd9e73bc97e6ecae3680daee3418f`。Windowsの512変数・2048残差で
QR factor+solveは137.587 ms / Eigen81.294 ms、paired比1.688、LLTは3.469 ms / Eigen2.001 ms、比1.714。
通常fixtureの結果であり、悪条件・大残差の精度gateは未達のままである。

今回の変更は[独立した診断snapshot](../../tools/diagnostics/eigen-gap/README.md)と調査記録だけ。
インストールされる `include/kibo/` の実装や保証、正式計測の原データは変更していない。
試作の速度を現行ライブラリの速度として表示しない。

## 仮説と反証

| 仮説 | 確認方法 | 結果 |
| --- | --- | --- |
| Eigenだけが広いSIMDを使うため遅い | 同じMSVC flagsでEigen packet幅とcore経路を出力 | 双方SSE2、double 2要素。AVX対scalarという差ではない |
| QRで列normを毎回全計算している | 両ソースのpivot/norm更新を読む | 双方LAPACK DLAQP2型のpartial norm downdate。主因として反証 |
| QRの配置と計算ループが合っていない | Eigenだけrow-major、coreだけcolumn-major、column専用kernelを順に比較 | 配置だけではcoreが悪化。配置とkernelの組合せで大きく改善 |
| 更新ごとの有限値検査が全差を説明する | factor更新だけ検査を外す診断と全更新を外す負の対照 | 一部の時間を説明するが単独では同等にならない。solve検査の全削除は契約違反 |
| LLTのpanel幅をEigenと同じにすれば解決する | 幅8対64、stride512対513、列方向のblocked計算を比較 | 幅変更だけでは解決せず。strideと演算の構成が影響する |

## 診断条件と生データ

Intel Core i9-14900K、Windows、MSVC19.44.35222.0、x64 Release `/O2 /fp:precise`、C++20、single-thread。
`/arch`の追加指定なし。Eigen double packet=2とcore SIMD有効を各QR実行で確認した。
fixtureはseed固定の既知解x=1。両backendで有限な解と絶対誤差1e-10以下を確認する。
QRは1024行×512列、LLTは2048行×512列のJから作った512次のJᵀJ+1e-3 I。

各probeを3 processで実行した。QRはwarmup1回・測定3回、LLTはwarmup2回・測定10回
（sorted index5のupper median）。各process内でbackend順を交替し、測定は直列。
以下はprocess中央値の中央値、比率はprocess内比率の中央値。信頼区間は算出していない。
準備済みbufferを使い、fixture生成とEigen入力のlayout変換は時間外、core内部copyは時間内。
coreのphase時計の負荷も含む。phaseはwarmup込み平均なので、wall-time中央値と一致するとは限らない。

**正式性能suiteと異なる短い原因切り分けであり、全サイズの同等性能認定ではない。**
特にQR1024×512は正式比較のaugmented QR（m=2048なら2560行）と同じ問題ではない。
条件の異なる時間を混ぜて改善倍率を計算しない。

[manifest・source/binary hashes](../validation/performance/eigen-cause/manifest.json)、
[raw集計](../validation/performance/eigen-cause/summary.json)、
[全記録checksum](../validation/performance/eigen-cause/SHA256SUMS.txt)を保存した。
Eigen archiveのSHA256と展開済み全Eigen headerをtoolchain lockの固定archiveへ照合した。
実行command、compiler metadata、build logsは同じディレクトリにある。
以下はcollectorを修正して新規buildで収集した最終系列である。
先行した[3-process系列](../validation/performance/eigen-cause/preliminary/PROVENANCE.md)も原記録を保持した。
先行系列のQR候補比は中央値1.075、最終系列は1.140で、短いprobeの変動がある。
先行collectorのcache引継ぎ問題は独立レビューで発見・修正した。その実測時のcacheは期待どおりだったが、
再現時の取り違えを防ぐため毎回新規build・固定path/flags・有効cache値の保存へ変更した。
修正後の未完了build1回は測定へ含めていない。
最終成果物の独立レビューは規約0件・仕様0件。規約軸のcache引継ぎ指摘1件は修正後に再確認した。
両系列の全記録checksum、最終source hashes、変更していないbase snapshotを照合した。

| 診断target | core ms | Eigen ms | core/Eigen比 |
| --- | ---: | ---: | ---: |
| `qr_baseline` | 50.119 | 28.308 | 1.769 |
| `qr_eigen_row` | 53.574 | 44.497 | 1.203 |
| `qr_row_unchecked` | 45.781 | 28.302 | 1.547 |
| `qr_column_scalar` | 129.339 | 28.285 | 4.544 |
| `qr_column_simd` | 41.609 | 30.384 | 1.400 |
| `qr_column_four` | 39.066 | 29.755 | 1.313 |
| `qr_factor_deferred` | 31.614 | 27.749 | 1.140 |
| `llt_baseline` | 3.656 | 2.132 | 1.678 |
| `llt_width64` | 4.037 | 2.202 | 1.833 |
| `llt_padded` | 2.995 | 2.158 | 1.388 |
| `llt_column` | 2.867 | 2.180 | 1.299 |
| `llt_column_fast` | 2.639 | 2.295 | 1.134 |

QR改善候補のprocess比は1.149 / 1.140 / 1.046（中央値1.140）。約14％の差まで縮まったが、
1.1以下という診断目標も3回中2回は超過しており、安定した同等性能には達していない。
QR/LLT/LLT shortcutの公開test snapshotは各1 processで合格。全unchecked負の対照は3 processとも
overflow検査で失敗したため、性能候補の表から除外した。生データには保持している。

## QRで確認できたこと

現行のrow-major処理はHouseholder projectionとtrailing updateに時間の大半を使う。
Eigenをrow-majorに変えるとEigen側も遅くなる。これはlayoutが重要である証拠だが、
Eigenの速いcolumn-major構成への到達を意味しない。
coreもcolumn-majorへ変えるだけでは、元のscalar column処理がボトルネックとなってさらに遅くなる。

列方向で連続するdot/update、4列でHouseholder vectorの読み込みを共用するprojection、
tileによる入力copyを組み合わせると差を縮められた。QR norm計算とHouseholder vector生成も
連続アクセスとなり、solveの連続dot/updateも改善する。メモリ配置とそれに対応したkernelを
一緒に設計する必要がある。型をrow-majorからcolumn-majorへ変えるだけでは済まない。
4列共有単独の追加効果は先行系列と最終系列で揺れており、combined候補の改善を
その1変更だけの効果として扱わない。baselineのprocess2ではprojection17.378 ms、
trailing update23.315 msが大部分を占める（[phase raw](../validation/performance/eigen-cause/qr_baseline-2.txt)）。

factor更新の各element検査を後続のselected-column norm/projectionに遅延させる試作では、
solveの更新検査を保持した。通常fixture、snapshotの公開QR tests、残差overflow時の失敗通知と
出力保持を確認した。ただし全ての入力・診断index・精度・無確保・fallbackを認定したわけではない。
今後の採用には全数値suiteと契約レビューが必要。

全更新の検査を取り除いた負の対照は、A=[1,-1]、b=[0.9 DBL_MAX,0.9 DBL_MAX]のsolveで
残差変換overflowを見逃した。解候補が有限でも残差側がoverflowするため、通常fixtureの既知解だけでは
この不具合を捕まえられない。各processで負の対照が失敗し、検査を残す候補が
`arithmetic_failure`とcaller出力保持を満たすことを確認した。
検査を消しただけの速度は採用可能な性能として数えない。

固定Eigenの参照箇所：

- [ColPivHouseholderQR：norm downdate、pivot、Householder適用](https://gitlab.com/libeigen/eigen/-/blob/bc3b39870ecb690a623a3f49149a358b95c5781d/Eigen/src/QR/ColPivHouseholderQR.h)
- [Householder：matrix/vector積とrank-1更新](https://gitlab.com/libeigen/eigen/-/blob/bc3b39870ecb690a623a3f49149a358b95c5781d/Eigen/src/Householder/Householder.h)
- [連続方向に合わせたmatrix/vector packet kernel](https://gitlab.com/libeigen/eigen/-/blob/bc3b39870ecb690a623a3f49149a358b95c5781d/Eigen/src/Core/products/GeneralMatrixVector.h)

## LLTで確認できたことと未確定の部分

EigenのLLTは大きい行列でblocked分解、複数RHSの三角solve、self-adjoint rank updateを使う。
512次ではblock幅64。trailing updateはGEMM系のpackingと再利用を使う。
coreの8列panelを単に64列へ拡大しても、この演算構成にはならず改善しなかった。
[固定版LLTソース](https://gitlab.com/libeigen/eigen/-/blob/bc3b39870ecb690a623a3f49149a358b95c5781d/Eigen/src/Cholesky/LLT.h)を参照。
APIの仕事量にも差がある。coreは入力全体の有限値と対称性を検査する一方、Eigen LLTは指定された
片三角だけを読み、反対側は読まない。今回のbaseline process2で入力検査phaseは0.447 ms。
これも差の一部だが全体差は説明しない。coreの検査契約を削除して同等とする解決は採らない。

factor strideを512 doubles（4096 bytes）から513へ変える実験では、panel処理が改善した。
process2のpanelは0.868→0.331 ms、trailing updateは1.873→1.859 msで、改善箇所を切り分けられた
（[stride512](../validation/performance/eigen-cause/llt_baseline-2.txt)、[stride513](../validation/performance/eigen-cause/llt_padded-2.txt)）。
これはアクセス配置の影響を直接示す。4 KiB strideによるcache set競合は原因候補として有力だが、
cache miss/TLBのhardware counterを採っていないため、正確な機構は未確定。
paddingだけで全時間差を説明しない。

caller storageのtransposeを一時的な列方向bufferとして使い、分解後にtileで公開lower layoutへ戻す
試作でも改善した。行列copy・戻し処理を計測時間に含めた。これでもEigenとの時間差は残る。
残りのtrailing updateは、packingを含むGEMM型kernelと比較する必要がある。
column試作とsymmetry shortcut/wider update試作は公開LLT testsで検証した範囲を超えて認定しない。
shortcut/wider版は最終系列で比率が改善したが、先行系列では改善せず、複数変更の効果を
分ける実験と検査shortcutの検証が採用前に必要。

## 次の実装と性能受入

[PCのLM参照問題と2〜512変数のEigen比較を実行する](https://github.com/takuto-NA/kibo-linalg/issues/16)で継続する。
Eigen相当を実装目標とし、今回の遅さを受入理由にしない。

1. QRはcallerのcolumn storageに対応するkernelとcopy改善を切り出し、失敗契約・精度・workspaceを検証する。
2. LLTはlayoutの悪いアクセスを除き、trailing updateをGEMM型の再利用と比較する。小行列の悪化も確認する。
3. PCの最良構成同士と同layout比較を分け、合意済み2〜512変数・m=n/4n・全phaseを正式な5 process手順で再測定する。
4. 悪条件・大残差のgate、準備済み無確保、scalar fallback、WASM/ESPの検証を通してから採用する。

現時点で「少なくとも全ケースで同等」や「Eigenより速い」とは結論しない。
試作で差を縮められることは確認できたが、性能受入・精度受入・公開releaseは完了していない。

## 一変更ずつの追加切り分け

[追加の原因特定](eigen-root-cause.md)で同じSSE2のQRを一変更ずつ比較し、
aligned stride・read-only対照・LLTのmatched rank-updateを追加した。
大きいmatched rank-updateはEigenとほぼ同等であり、packingの構造差がLLT全体差の主因という
仮説は支持されなかった。row panelのアドレス間隔と、入力検証の追加仕事量は別々の対照で確認した。
この先行報告の時間を、新しいCPU固定系列の時間と合算しない。
