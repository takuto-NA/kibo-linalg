# LLTの8列幅をコンパイル時に固定する対照

Issue24の128変数factorの不確実性に対し、公開LLTの2列共有updateにtemplate幅8を渡す単独対照を作った。
ほかの幅は元のruntime経路へ戻す。各要素の増加k順と確保・workspace契約は変えない。
公開版と対照のMSVC /O2 /fp:precise、CPU0 P-core、SSE2、単一threadを揃えた。
同じfixture hash、backend順交替、warmup5、各batch20ms以上、3 process×5 samples、4phaseを測定した。
これは診断であり正式5×30の性能受入ではない。

| n/m | 公開factor µs | 固定幅factor µs | 固定幅/公開 |
| --- | ---: | ---: | ---: |
| 31/124 | 1.4522 | 1.4581 | 1.0041 |
| 32/128 | 1.5347 | 1.5370 | 1.0015 |
| 33/132 | 1.6425 | 1.6454 | 1.0017 |
| 128/128 | 43.5839 | 44.2064 | 1.0143 |
| 128/512 | 43.7007 | 44.1437 | 1.0101 |
| 512/2048 | 1995.375 | 1995.8125 | 1.0002 |

値はprocess中央値の中央値。128変数で改善せず、公開採用を見送った。
コンパイル時の定数化だけで差が埋まるという仮説は、この対照では支持されない。
実COFF全文・公開/Eigen/対照関数、binary/source hash、36実行のrawを
[証拠archive](../validation/performance/llt-fixed8-controls/SHA256SUMS.json)に保存した。
固定幅で既存LLT・large LLTのSIMD/scalar四つの契約testも通過した。
保存sourcesの最小CMakeListsに固定Eigenを渡して再buildできる。
public LLTは変更せず、正式測定へ進む。小行列の確保policy差と128factorの未達を完了扱いにしない。
