"""Diagnostic only: solve the actual rounded input at 100 decimal digits."""
import argparse
import json
import math
import mpmath as mp
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('input', type=Path)
args = parser.parse_args()
mp.mp.dps = 100
records = []
def fwht(values):
    values=list(values)
    width=1
    while width<len(values):
        for first in range(0,len(values),2*width):
            for j in range(width):
                a,b=values[first+j],values[first+j+width]
                values[first+j],values[first+j+width]=a+b,a-b
        width*=2
    return values
for line in args.input.read_text().splitlines():
    row = json.loads(line)
    m, n = row['m'], row['n']
    # Parsing through Python float reconstructs the same IEEE double values.
    dense='matrix' in row
    if dense:
        a = mp.matrix(m, n)
        for i in range(m):
            for j in range(n):
                a[i, j] = mp.mpf(row['matrix'][i*n+j])
        largest=max(abs(v) for v in a)
    else:
        assert row['xorCirculantVerified'] is True
        first_row=[mp.mpf(v) for v in row['firstRow']]
        largest=max(abs(v) for v in first_row)
    b = mp.matrix([mp.mpf(v) for v in row['rhs']])
    truth = mp.matrix(row['truth'])
    # mpmath's QR uses an absolute singularity test. Exact power-of-two
    # scaling avoids rejecting 1e-150 input against its 1e-100 epsilon.
    # Scaling here is high precision, after exact reconstruction of A/b.
    exponent = math.frexp(float(largest))[1]
    scale = mp.mpf(2)**exponent
    scaled_b = b / scale
    if dense:
        scaled_a=a/scale
        x, residual_norm=mp.qr_solve(scaled_a,scaled_b)
        eigenvalues=mp.eigsy(scaled_a.T*scaled_a,eigvals_only=True)
        condition=mp.sqrt(eigenvalues[n-1]/eigenvalues[0])
        norm_a=mp.sqrt(sum(v*v for v in scaled_a))
        apply=lambda v:scaled_a*v
        transpose_apply=lambda v:scaled_a.T*v
        method='100-digit QR of exact rounded A/b, exact power-of-two scaling'
    else:
        # Verified A(i,j)=c[(i mod n) xor j]. The Hadamard eigenvectors are
        # exact +/-1; FWHT diagonalizes the ACTUAL rounded matrix, not the
        # requested pre-generation spectrum. Repeated rows reduce b to exact
        # high-precision block averages for the least-squares solution.
        c=[v/scale for v in first_row]
        eigenvalues=fwht(c)
        mean=[mp.fsum(scaled_b[k*n+j] for k in range(m//n))/(m//n) for j in range(n)]
        x=mp.matrix([v/n for v in fwht(v/w for v,w in zip(fwht(mean),eigenvalues))])
        condition=max(abs(v) for v in eigenvalues)/min(abs(v) for v in eigenvalues)
        norm_a=mp.sqrt(m*mp.fsum(v*v for v in c))
        def convolution(v):return [w/n for w in fwht(a*b for a,b in zip(eigenvalues,fwht(v)))]
        def apply(v):
            values=convolution(v)
            return mp.matrix([values[i%n] for i in range(m)])
        def transpose_apply(v):
            values=[mp.fsum(v[k*n+j] for k in range(m//n)) for j in range(n)]
            return mp.matrix(convolution(values))
        method='100-digit FWHT diagonalization of bit-verified rounded XOR-circulant repeated rows'
    norm_b = mp.norm(scaled_b)
    records.append({
        'id': row['id'], 'column': row['column'], 'inputHash': row['inputHash'],'m':m,'n':n,'method':method,
        'roundedOracle': [float(v) for v in x],
        'oracleTruthForward': float(mp.norm(x-truth)/mp.norm(truth)),
        'actualCondition': float(condition),
        'residualAngleSine': float(mp.norm(apply(x)-scaled_b)/norm_b),
        'solutions': {},
    })
    result = records[-1]
    solution_names=['core', 'eigenRaw', 'eigenNormalized', 'refinedPlain', 'refinedDD']
    if 'publicRefined' in row:solution_names.append('publicRefined')
    for name in solution_names:
        candidate = mp.matrix(row[name])
        residual = apply(candidate)-scaled_b
        denominator = norm_a*(norm_a*mp.norm(candidate)+norm_b)
        result['solutions'][name] = {
            'oracleForward': float(mp.norm(candidate-x)/mp.norm(x)),
            'truthForward': float(mp.norm(candidate-truth)/mp.norm(truth)),
            'backward': float(mp.norm(residual)/(norm_a*mp.norm(candidate)+norm_b)),
            'optimality': float(mp.norm(transpose_apply(residual))/denominator),
        }
    # Cause control: high-precision residual/gradient, correction through the
    # existing DOUBLE R and permutation. No high-precision core dependency.
    if not dense:continue
    r = [v / float(scale) for v in row['R']]
    permutation = row['permutation']
    current = row['core'][:]
    refinement = []
    for iteration in range(3):
        residual = scaled_b-scaled_a*mp.matrix(current)
        gradient = scaled_a.T*residual
        z = [0.0]*n
        correction = [0.0]*n
        for i in range(n):
            z[i] = (float(gradient[permutation[i]])-math.fsum(r[j*n+i]*z[j] for j in range(i)))/r[i*n+i]
        for i in range(n-1, -1, -1):
            correction[i] = (z[i]-math.fsum(r[i*n+j]*correction[j] for j in range(i+1,n)))/r[i*n+i]
        for i in range(n):
            current[permutation[i]] += correction[i]
        refinement.append(float(mp.norm(mp.matrix(current)-x)/mp.norm(x)))
    result['exactGradientDoubleRRefinement'] = refinement
output = args.input.with_suffix('.oracle.json')
output.write_text(json.dumps(records, indent=2)+'\n', encoding='utf-8')
print('Saved', len(records), 'actual-input oracle comparisons to', output)
