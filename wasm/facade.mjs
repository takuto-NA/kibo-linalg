export class LinearAlgebra {
    #regions = {};
    constructor(module, rows, cols) {
        if (module._kibo_abi_version() !== 1) throw new Error('unsupported kibo ABI');
        if (![rows, cols].every(x => Number.isSafeInteger(x) && x > 0) || rows * cols * 8 > 0xffffffff)
            throw new RangeError('matrix size overflow');
        this.module = module;
        this.rows = rows; this.cols = cols;
        this.disposed = false;
        this.#regions = {};
        this.outputLength = 0;
        const sizes = {matrix: rows*cols*8, rhs: Math.max(rows,cols)*8, output: Math.max(rows,cols)*8,
            factor: rows*cols*8, tau: cols*8, permutation: cols*4, workspace: Math.max(2*cols,rows+cols)*8, diagnostics:16};
        try {
            for (const [name, bytes] of Object.entries(sizes)) {
                if (bytes > 0xffffffff) throw new RangeError('buffer size overflow');
                const offset = module._kibo_allocate(bytes);
                if (!offset) throw new Error('allocation failure');
                this.#regions[name] = {offset, bytes};
            }
        } catch (error) { this.dispose(); throw error; }
    }
    #alive() { if (this.disposed) throw new Error('linear algebra instance disposed'); }
    #view(name, length) {
        this.#alive();
        return new Float64Array(this.module.HEAPU8.buffer, this.#regions[name].offset, length);
    }
    get allocatedNumericBytes() { this.#alive(); return Object.values(this.#regions).reduce((sum,r)=>sum+r.bytes,0); }
    viewInput() { return this.#view('matrix', this.rows*this.cols); }
    viewRhs() { return this.#view('rhs', Math.max(this.rows,this.cols)); }
    viewOutput() { return this.#view('output', this.outputLength); }
    copyOutput() { return this.viewOutput().slice(); }
    #copy(matrix, rhs, rhsLength) {
        this.#alive();
        if (matrix.length !== this.rows*this.cols || rhs.length !== rhsLength) throw new RangeError('input shape mismatch');
        // Copying inputs protects callers passing a view that aliases a facade-owned region.
        const matrixCopy = Float64Array.from(matrix), rhsCopy = Float64Array.from(rhs);
        this.viewInput().set(matrixCopy); this.viewRhs().set(rhsCopy);
    }
    matvec(matrix, rhs) { this.#copy(matrix,rhs,this.cols); return this.computeMatvec(); }
    solveLlt(matrix, rhs) { this.#copy(matrix,rhs,this.rows); return this.computeLlt(); }
    leastSquares(matrix, rhs) { this.#copy(matrix,rhs,this.rows); return this.computeQr(); }
    computeMatvec() {
        this.#alive(); const r=this.#regions;
        const status=this.module._kibo_matvec(r.matrix.offset,r.matrix.bytes,this.rows,this.cols,this.cols,1,
            r.rhs.offset,r.rhs.bytes,r.output.offset,r.output.bytes);
        this.outputLength=status===0 ? this.rows : 0;
        return {status, output:status===0 ? this.copyOutput() : undefined};
    }
    #solve(kind) {
        this.#alive(); const r=this.#regions;
        this.module.HEAPU8.fill(0,r.diagnostics.offset,r.diagnostics.offset+16);
        let status;
        if (kind==='llt') {
            if (this.rows!==this.cols) throw new RangeError('LLT requires square matrix');
            status=this.module._kibo_llt(r.matrix.offset,r.matrix.bytes,this.cols,this.cols,1,
                r.rhs.offset,r.rhs.bytes,r.output.offset,r.output.bytes,r.factor.offset,r.factor.bytes,
                r.workspace.offset,r.workspace.bytes,r.diagnostics.offset,r.diagnostics.bytes);
        } else {
            status=this.module._kibo_qr(r.matrix.offset,r.matrix.bytes,this.rows,this.cols,this.cols,1,
                r.rhs.offset,r.rhs.bytes,r.output.offset,r.output.bytes,r.factor.offset,r.factor.bytes,
                r.tau.offset,r.tau.bytes,r.permutation.offset,r.permutation.bytes,r.workspace.offset,r.workspace.bytes,
                r.diagnostics.offset,r.diagnostics.bytes);
        }
        const diag=new DataView(this.module.HEAPU8.buffer,r.diagnostics.offset,16);
        const diagnostics={index:diag.getUint32(0,true),rank:diag.getUint32(4,true),tolerance:diag.getFloat64(8,true)};
        this.outputLength=status===0 ? this.cols : 0;
        return {status, diagnostics, output:status===0 ? this.copyOutput() : undefined};
    }
    computeLlt() { return this.#solve('llt'); }
    computeQr() { return this.#solve('qr'); }
    resize(rows,cols) {
        this.#alive();
        const replacement=new LinearAlgebra(this.module,rows,cols);
        this.dispose();
        this.rows=replacement.rows; this.cols=replacement.cols; this.#regions=replacement.#regions;
        this.outputLength=0; this.disposed=false;
        replacement.#regions={}; replacement.disposed=true;
    }
    dispose() {
        if (this.disposed) return;
        for (const region of Object.values(this.#regions)) this.module._kibo_release(region.offset);
        this.#regions={}; this.disposed=true; this.outputLength=0;
    }
}
