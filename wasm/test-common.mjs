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
    let unpreparedRefinement=false;
    try {la.computeQrRefined();} catch {unpreparedRefinement=true;}
    check(unpreparedRefinement,'unprepared refinement rejected');
    const refinedLa=new LinearAlgebra(module,8,2,{refinement:true});
    const oracleA=[.2500000025,.2499999975,.2499999975,.2500000025,
        .2500000025,.2499999975,.2499999975,.2500000025,
        .2500000025,.2499999975,.2499999975,.2500000025,
        .2500000025,.2499999975,.2499999975,.2500000025];
    const oracleB=[-.11499999625,-.11500000374999998,-.13499999625,-.13500000374999999,
        -.11499999625,-.11500000374999998,-.13499999625,-.13500000374999999];
    const refined=refinedLa.leastSquaresRefined(oracleA,oracleB);
    check(refined.status===0 && refined.diagnostics.rank===2 &&
        close(refined.output[0],.4999999986122212) && close(refined.output[1],-.9999999986122212),'refined QR rounded-input oracle');
    check(module._kibo_allocation_count()===0,'refined QR allocations');
    refinedLa.resize(2,2);
    const refinedSmall=refinedLa.leastSquaresRefined([4,1,1,3],[1,2]);
    check(refinedSmall.status===0 && close(refinedSmall.output[0],1/11) && close(refinedSmall.output[1],7/11),'refinement after resize');
    refinedLa.dispose();
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
    check(module._kibo_qr_refined(rawQr,32,2,2,2,1,
        rawQr+32,16,rawQr+48,16,rawQr+64,32,rawQr+96,16,rawQr+112,8,
        rawQr+120,32,rawQr+152,16)===4 && outputsPreserved(),'refined QR workspace capacity preserves all outputs');
    module.HEAPF64[rawQr/8]=NaN;
    check(rawQrCall(16,8)===7 && outputsPreserved(),'QR non-finite input preserves all outputs');
    check(module._kibo_llt(rawQr,32,2,2,1,rawQr+32,16,rawQr+48,16,rawQr+64,32,
        rawQr+120,32,rawQr+152,16)===7 && outputsPreserved(),'LLT non-finite input preserves all outputs');
    module._kibo_release(rawQr);
    const rawRefined=module._kibo_allocate(144);
    module.HEAPF64.set([1e-300,0,0,1e300,123],rawRefined/8);
    const lateFailure=module._kibo_qr_refined(rawRefined,16,2,1,1,1,
        rawRefined+16,16,rawRefined+32,8,rawRefined+40,16,rawRefined+56,8,
        rawRefined+64,4,rawRefined+72,56,rawRefined+128,16);
    check(lateFailure===10 && module.HEAPF64[(rawRefined+32)/8]===123,'refined QR late failure preserves solution');
    module._kibo_release(rawRefined);
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
    return {passed:true,refinedQr:true,numericBytes2x2:bytes,initialMemoryBytes:16777216,maxMemoryBytes:134217728,stackBytes:65536,abi:module._kibo_abi_version()};
}
