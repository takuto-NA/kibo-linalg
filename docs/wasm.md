# WASM ABI v1とJavaScript facade

Emscripten6.0.10、wasm32、single-thread、SIMD必須なし。
初期memory16 MiB、最大128 MiB、stack64 KiB、growth許可。
libraryはC++ object layout、例外、RTTIを境界に出さない。
`tools/wasm-build.sh` は `build/wasm/kibo.mjs` / `kibo.wasm` を生成する。

`kibo_abi_version()` は1。C exportsは `wasm/adapter.cpp` に署名を示す。
offset/byte容量/shape/stride/statusはuint32、数値はdouble。
offsetはWASM memoryの先頭からのbyte位置、strideはdouble要素単位。
`kibo_matvec`、`kibo_llt`、`kibo_qr` は入力/出力/factor/workspaceを明示する一括call。
LLTはn×n、QRはm>=n>0。factor/tau/permutationの領域は別に渡す。
diagは16 bytes: little-endian uint32 index、uint32 rank、float64 tolerance。
permutationはwasm32のuint32配列。statusはC++ StatusCodeのABI v1での固定値（0が成功）。
byte範囲、alignment、size overflow、容量、領域間の重複を検証する。
ABIでは領域をすべてdisjointにする。メモリの割当元・任意の外部freeを検出する保証はない。

setupは `kibo_allocate(bytes)`、解放は `kibo_release(offset)`。
releaseにはこのmoduleでまだ解放していない割当の先頭または0を渡す。
校正済みmalloc/calloc/realloc/aligned_alloc wrappersで、各計算call中の確保回数を測定する。
setup、JavaScript配列のcopy、module予約memoryはprepared core計算とは別集計。

```javascript
import createModule from './kibo.mjs';
import {LinearAlgebra} from './facade.mjs';
const module = await createModule();
const core = new LinearAlgebra(module, 2, 2);
const result = core.solveLlt(new Float64Array([4,1,1,3]), new Float64Array([1,2]));
if (result.status === 0) console.log(result.output); // JS所有の独立copy
core.dispose();
```

通常配列/Float64Arrayはcopy-in/out。`viewInput`/`viewRhs`/`viewOutput` は非所有WASM-backed view。
入力viewへ書いて `computeMatvec/computeLlt/computeQr` を呼ぶと入力copyを省ける。
既存TypedArrayはgrowth後に使わず、offsetを保持するfacadeから再取得する。
copyOutputと戻り値outputはgrowth/resize/dispose後も生存する。
resize成功後はviewを再取得する。resize失敗は元instanceを保持する。
disposeはidempotentで、解放後のcallは拒否する。

将来のnumopt-js連携ではJavaScriptで残差/Jacobian/反復を維持し、
J/r/dampingから線形stepを一括callする。現在は最適化全体のWASM移植や連携済みを意味しない。
Node24.21.0とPlaywright1.63.0のChromium/Firefox/WebKitで同じHTTP例を実行する。
再現コマンドはCI workflow。kernel時間とJS copy境界時間は別に計測できる。
LLT処理選択修正後の[Node結果](validation/portability/hosted/dispatch/node-results.json)と
[3 browser結果](validation/portability/hosted/dispatch/browser-results.json)、
[sourceとmodule hash](validation/portability/hosted/dispatch/evidence.json)を保存した。
