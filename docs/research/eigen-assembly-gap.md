# アセンブリからLLTの残差を切り分ける

2026-10-07。公開実装c3c10dfの32変数・128残差のLLTは、短い再現でEigen比1.814だった。
小さい計算を同じMSVC19.44.35222.0・CPU0/P-core・SSE2・/O2 /fp:preciseで切り出し、
生成アセンブリ、object codeの逆アセンブリ、単独変更の時間を突き合わせた。

## 分かったこと

32変数LLTの遅さには、入力走査と有限値判定、ブロック分解の切替漏れが寄与していた。
単にSIMD幅を増やす必要があるという説明ではなかった。検査を維持した3点の変更で、
診断系列のfactor+solveは5.257→2.758 µs、Eigen比1.858→0.975となった。
この結果を公開実装`3c7d2c8b54701e1e5f826bfb171d5a442e14d10a`へ反映した。
公開APIそのものを使った再測定は下表で別に示す。

## 命令として確認できた差

[compiler listing](../validation/performance/assembly-gap/kernels.asm)と
[実objectの逆アセンブリ](../validation/performance/assembly-gap/kernels-disassembly.txt)を保存した。

従来の入力確認を切り出すと、要素ごとにランタイム関数を呼ぶ。

```asm
movsd xmm0, QWORD PTR [rbp+rbx*8]
call  _dclass
test  ax, ax
jg    reject
```

このMSVC/UCRTと精度設定での結果であり、std::isfiniteが常に関数呼出しになるという主張ではない。
32×32入力のfinite走査だけで1,024回呼ばれ、さらに最大絶対値のためにもう一度読む。
大規模用のfused scanはSSE2比較とmaxを一走査で実行していたが、32変数では選択されていなかった。
1,024要素の単独走査は、3 process中央値で従来約991 ns、fused約348 ns。

公開LLTのscalar検査はabs(value)<=double最大値へ置き換えた。NaNは順序比較がfalse、
両無限大は範囲外なので検出を維持する。生成コードは次の5命令となり、callはない。

```asm
andps  xmm0, ABS_MASK
movsd  xmm1, DBL_MAX
comisd xmm1, xmm0
setae  al
ret
```

[公開helperのlisting](../validation/performance/assembly-gap/public_finite.asm)を参照。
浮動小数点のtrapやexception flagの一致は今回の検証対象ではなく、Status/出力/数値の契約を確認した。

内積にも違いがある。素朴なLLT内積は同じxmm3にsubsdを繰り返す直列依存を持つ。
Eigenの動的dotは4本のpacket accumulatorにmulpd/addpdを分配していた。
既存kibo helperは2本であり、独立の4本版を試すと512要素の内積は約60→43 nsに縮まる。
同じ対照のEigenは約36 ns。8〜32要素では準備処理も効き、命令数やSIMD幅だけで優劣は決まらない。

## 1変更ずつの対照

n32/m128、通常のwell-conditioned fixture、3 fresh processes・各phase15 alternating samples。
全sampleのbatchは20ms以上。factor/solve/bothは別ループで測るため、phaseの和とbothは厳密には一致しない。
各process内中央値の3 process中央値。Eigen比もprocess内比の中央値である。
この診断harnessのEigen solveにはallFinite確認が含まれる。

| 変更 | factor+solve µs | Eigen比 |
| --- | ---: | ---: |
| 現行公開版 | 5.257 | 1.858 |
| 分解の内積だけSIMD化 | 5.427 | 1.909 |
| 前進代入の内積だけSIMD化 | 5.295 | 1.867 |
| panel開始を32に変更 | 4.675 | 1.625 |
| 入力走査統合を32から有効化 | 4.061 | 1.399 |
| LLT内のscalar有限値判定だけinline化 | 4.561 | 1.581 |
| panel＋入力走査 | 3.258 | 1.147 |
| panel＋入力走査＋inline判定（採用） | 2.758 | 0.975 |
| 入力検査除去（原因対照・不採用） | 3.694 | 1.291 |


`dot`と`forward`は1箇所だけ既存packet dotへ置換した対照。全体を速くしなかったため採用しない。
`no_validation`はfinite/scale/symmetry走査を意図的に外す原因切り分け専用で、公開契約を満たさず採用しない。
`panel32`は新しい連続列panelの開始条件だけを64→32に変更する。EigenのLLTも32からblockedへ切り替える。
`fused32`は入力走査統合の開始条件だけを変更する。組合せの効果は単独改善量の単純和として扱わない。

分解側のbaselineは4.790 µs/Eigen2.216 µs。一方solveは0.504/Eigen0.554 µsで、
このshapeの差をsolveへ割り当てる仮説は支持されなかった。

## 公開実装の再測定

[public raw/manifest](../validation/performance/assembly-gap/public/)を保存した。
旧版c3c10dfと修正版3c7d2c8を既存の公開API harnessで比較する。
Eigenはcolumn-major、kibo LLT factorは両版ともrow-major。内部copy・検査・factor+solveを含む。
外部入力準備は時間外。m=4n、同じJ/r/damping、入力hash・独立解誤差1e-8・CPU0を確認した。
32変数は5 process×30 samples、他サイズは3 process×15 samplesの周辺確認であり、
m=nを含む合意済み全形状・全phaseの正式受入を置き換えない。

| n | m | 旧版 µs | 修正版 µs | Eigen µs | 修正版/Eigen |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 2 | 8 | 0.047 | 0.044 | 0.050 | 0.891 |
| 8 | 32 | 0.393 | 0.325 | 0.334 | 0.975 |
| 31 | 124 | 5.069 | 4.243 | 2.173 | 1.961 |
| 32 | 128 | 5.330 | 2.775 | 2.858 | 0.973 |
| 33 | 132 | 5.640 | 3.031 | 3.319 | 0.916 |
| 64 | 256 | 14.082 | 12.400 | 10.361 | 1.195 |
| 128 | 512 | 70.687 | 65.987 | 47.473 | 1.386 |
| 512 | 2048 | 2509.387 | 2483.981 | 2290.763 | 1.102 |

32変数のEigen比の95%経験bootstrap区間は[0.947, 0.980]。5個のprocess比の全5^5 resamplesを使用する。
周辺サイズの3 process結果は診断範囲であり、少数processの値から普遍的な速度保証はしない。
31変数は旧版比で改善してもEigen比約2倍が残る。128/512変数も同等とはしていない。


## 検証と範囲

公開testへ31/32/33変数の既知lower factor、4種類のstride/padding、後半pivot失敗、
overflow、32/33/65変数の両三角有限値検査と対称性境界、1×1のsubnormal・最小正常値・最大値・
符号付き0・NaN/Infを追加した。通常版とSIMD無効版、Debugの無確保probeが通過した。
Release全testの失敗は既存numerical/numerical_columnのみで、19/18件から増えていない。

[実装commitのCI](https://github.com/takuto-NA/kibo-linalg/actions/runs/37581895862)でもWindows/GCC/Clang/Clang ASan/UBSanの
通常test・無確保・無例外/RTTI・移動後package利用を通過した。失敗は同じ数値2 testのみ。
WASMのNode/Chromium/Firefox/WebKit、ESP32-S3/C3 cross compileも成功した。
MSVC Releaseのallocation probeはskip、ESP実機は未検証である。
[command/log/hash](../validation/performance/assembly-gap/validation/)を保存した。

再現sourceは[tools/diagnostics/assembly-gap](../../tools/diagnostics/assembly-gap/)、
全raw/assembly/hashは[検証artifact](../validation/performance/assembly-gap/)に保存した。
9 variantsのbaselineはGitから抽出した不変header。初回診断時のsourceもsources/に保存し、
後続の公開実装・harness追加と区別した。microkernelは独立translation unitのnoinline関数を呼び、
戻り値を消費し、各sampleで順序を回転させた。3 process・15 samples、各batch20ms以上である。

32変数の差は具体的な実装選択から生じ、検査を維持して縮められた。
これを全shape・QR・全CPUでのEigen同等保証へ一般化しない。
[PC性能受入](https://github.com/takuto-NA/kibo-linalg/issues/16)には残るshapeの差と全phase受入を残す。
