import {LinearAlgebra} from './facade.mjs';
export async function runTests(createModule) {
    const module=await createModule();
    const check=(condition,message)=>{if(!condition)throw new Error(message);};
    const close=(a,b)=>Math.abs(a-b)<=1e-14+1e-12*Math.abs(b);
    check(module._kibo_calibrate_allocation_probe()>0,'allocation probe calibration');
    const la=new LinearAlgebra(module,2,2);
    const product=la.matvec([4,1,1,3],[1,2]);
    check(product.status===0 && product.output[0]===6 && product.output[1]===7,'matvec');
    check(module._kibo_allocation_count()===0,'matvec allocations');
    const llt=la.solveLlt([4,1,1,3],[1,2]);
    check(llt.status===0 && close(llt.output[0],1/11) && close(llt.output[1],7/11),'LLT');
    check(module._kibo_allocation_count()===0,'LLT allocations');
    const qr=la.leastSquares([4,1,1,3],[1,2]);
    check(qr.status===0 && qr.diagnostics.rank===2 && close(qr.output[0],1/11) && close(qr.output[1],7/11),'QR');
    check(module._kibo_allocation_count()===0,'QR allocations');
    const bytes=la.allocatedNumericBytes;
    check(bytes<=4096,'numeric budget');
    const oldView=la.viewOutput(),oldBuffer=oldView.buffer;
    const growth=module._kibo_allocate(20*1024*1024);
    check(growth && module.HEAPU8.buffer!==oldBuffer,'memory growth');
    const reacquired=la.viewOutput();
    check(reacquired.buffer===module.HEAPU8.buffer && close(reacquired[0],1/11),'reacquisition');
    module._kibo_release(growth);
    const raw=module._kibo_allocate(64);
    module.HEAPF64.set([4,1,1,3,1,2,51,52],raw/8);
    const rejected=module._kibo_matvec(raw,32,2,2,2,1,raw+32,16,raw+48,15);
    check(rejected===4 && module.HEAPF64[(raw+48)/8]===51,'capacity and output preservation');
    check(module._kibo_matvec(raw+1,32,2,2,2,1,raw+32,16,raw+48,16)===2,'alignment');
    check(module._kibo_matvec(0xfffffff8,32,2,2,2,1,raw+32,16,raw+48,16)===4,'pointer range');
    check(module._kibo_matvec(raw,32,2,2,2,1,raw,16,raw+48,16)===3,'overlap');
    module._kibo_release(raw);
    const rawQr=module._kibo_allocate(168);
    module.HEAPU8.fill(91,rawQr,rawQr+168);
    module.HEAPF64.set([4,1,1,3,1,2],rawQr/8);
    const savedOutputs=module.HEAPU8.slice(rawQr+48,rawQr+168);
    const outputsPreserved=()=>savedOutputs.every((value,index)=>module.HEAPU8[rawQr+48+index]===value);
    const rawQrCall=(tauBytes,permutationBytes)=>module._kibo_qr(rawQr,32,2,2,2,1,
        rawQr+32,16,rawQr+48,16,rawQr+64,32,rawQr+96,tauBytes,rawQr+112,permutationBytes,
        rawQr+120,32,rawQr+152,16);
    check(rawQrCall(15,8)===4 && outputsPreserved(),'QR tau capacity preserves all outputs');
    check(rawQrCall(16,7)===4 && outputsPreserved(),'QR permutation capacity preserves all outputs');
    module.HEAPF64[rawQr/8]=NaN;
    check(rawQrCall(16,8)===7 && outputsPreserved(),'QR non-finite input preserves all outputs');
    check(module._kibo_llt(rawQr,32,2,2,1,rawQr+32,16,rawQr+48,16,rawQr+64,32,
        rawQr+120,32,rawQr+152,16)===7 && outputsPreserved(),'LLT non-finite input preserves all outputs');
    module._kibo_release(rawQr);
    let resizeRejected=false;
    try {la.resize(4096,4096);} catch {resizeRejected=true;}
    check(resizeRejected && la.rows===2 && close(la.viewOutput()[0],1/11),'failed resize preserves instance');
    const deficient=la.leastSquares([1,1,2,2],[3,6]);
    check(deficient.status===9 && deficient.diagnostics.rank===1,'rank deficient');
    la.resize(3,2);
    const ls=la.leastSquares([1,0,0,1,1,1],[0,1,4]);
    check(ls.status===0 && close(ls.output[0],1) && close(ls.output[1],2),'inconsistent least squares');
    la.dispose(); la.dispose();
    let rejectedDisposed=false;
    try {la.viewOutput();} catch {rejectedDisposed=true;}
    check(rejectedDisposed && product.output[0]===6 && close(llt.output[1],7/11),'dispose and copy lifetime');
    return {passed:true,numericBytes2x2:bytes,initialMemoryBytes:16777216,maxMemoryBytes:134217728,stackBytes:65536,abi:module._kibo_abi_version()};
}
