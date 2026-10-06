# Eigen LLTの内部packing容量

固定Eigen5.0.1 commit bc3b39870ecb690a623a3f49149a358b95c5781dのsourceで確認した。
測定後の監査で、LLTの内部packingが明示buffer容量に含まれていないことを見つけた。
時間測定と原CSVを変更せず、全caseへ保守的な追加上限を適用して64 MiB gateを再検証する。

`Eigen/src/Cholesky/LLT.h` のblocked decompositionはn>=32でpanelを分割し、
三角solveとselfadjoint rankUpdateを順に呼ぶ。三角solveの
`Core/products/TriangularSolverMatrix.h` とrankUpdateの
`Core/products/GeneralMatrixMatrixTriangular.h` は各々blockA/blockBを作る。
sourceのsizeA=kc*mc、sizeB=kc*cols（またはkc*size）における各寸法はn以下。
`Core/products/SelfadjointProduct.h` のblocking constructorにもこのサイズが渡る。
stack/heapのどちらを使っても数値領域として数える。
rankUpdateの固定サイズmicro-blockも、次の余裕を持った上限に含める。

panelの三角solveとrankUpdateは順次実行され、同時に必要なpackingは各2領域。
追加上限を4*n*n doublesとし、実サイズより余裕を持って両phaseのpackingを覆う。
alignmentやvector補助領域にも余裕がある上限で、実際のpeak heap/RSS測定値ではない。
これをEigen normal-LLTの全phaseに一律加え、solve-onlyにも過大な側で適用する。
n<32のunblocked系にも同じ上限を加え、GEMVの非連続vector copyなどの補助領域を覆う。
coreには追加せず、列pivot QRの既存係数/norm/index/solve領域の計算も保持する。

raw CSVのnumeric_bytesは明示bufferのsubtotalとして保存する。
summaryのexplicit_numeric_bytesはそのsubtotal、numeric_bytesは内部packing上限を加えた値。
測定source29739d1はsubtotalでgateしていたため、受入の容量判定にはこの監査後のsummaryを使う。
以後のbenchmark harnessも同じ追加上限でgateするが、rawの意味を変えない。

この修正は計測対象のloop・入力・solver・clock・binaryに変更を加えない。
新しい容量の集計は固定した5-process結果から再計算でき、時間測定を取り直す必要はない。
