# QRの列ノルム更新

LAPACKの[DLAQP2一次資料](https://netlib.org/lapack/explore-html/d4/d66/dlaqp2_8f_source.html)と
[Working Note176](https://www.netlib.org/lapack/lawnspdf/lawn176.pdf)を参照した。
reflector適用後の除去成分と元のノルムから残りを更新し、相殺による信頼性低下を
sqrt(epsilon)の条件で検出した場合だけ尺度調整付きノルムを再計算する。
候補ノルムと最後に再計算したノルムを、既存の2n個double workspaceへ保存する。
Householder自体はpivot列の実ノルムから生成する。

この変更で全候補列の毎段階のノルム再走査を減らす。rank、容量、無確保のpublic契約は同じ。
部分更新の信頼性条件を省くと小さい列のpivotを誤るため、再計算条件も含める。
性能測定は変更前の途中試行を正式結果に混ぜず、変更後のbinaryで5 process runsを取得する。
