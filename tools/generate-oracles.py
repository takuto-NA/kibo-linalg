"""Offline-only 100-digit oracle for rounded double stress inputs.

Requires mpmath 1.3.0. The generated C++ fixture has no Python dependency.
Normal equations here are evaluated at 100 decimal digits, independently of
the core's Householder QR and double LLT algorithms.
"""
import hashlib
import json
import math
from pathlib import Path
import mpmath as mp

mp.mp.dps = 100
root = Path(__file__).resolve().parent.parent
cases = []
for n in (2, 8):
    for scale in (1e-150, 1.0, 1e150):
        m = 4 * n
        sigma = [10 ** (-8 * j / (n - 1)) for j in range(n)]
        a = [[float(sum((-1 if ((i ^ j) & k).bit_count() % 2 else 1) * sigma[k]
                        for k in range(n)) * scale / (2*n)) for j in range(n)] for i in range(m)]
        truth = [(-1.0 if j % 2 else 1.0) * (j+1)/n for j in range(n)]
        b = [float(sum(a[i][j] * truth[j] for j in range(n)) +
                   (-1 if i & n else 1) * scale * 0.01) for i in range(m)]
        exact_a = mp.matrix([[mp.mpf(value) for value in row] for row in a])
        exact_b = mp.matrix([mp.mpf(value) for value in b])
        expected = mp.lu_solve(exact_a.T * exact_a, exact_a.T * exact_b)
        cases.append(dict(m=m, n=n, scale=scale, matrix=a, rhs=b,
                          solution=[mp.nstr(value, 100) for value in expected]))
rank_cases=[]
for delta in (1e-11,1e-9):
    matrix=[[1.0,1.0],[0.0,delta],[0.0,0.0]]
    tolerance=1e-10
    exact=mp.matrix(matrix)
    columns=[exact[:,j] for j in range(2)]
    if mp.norm(columns[1])>mp.norm(columns[0]): columns.reverse()
    largest=mp.norm(columns[0])
    q=columns[0]/largest
    second=mp.norm(columns[1]-q*(q.T*columns[1])[0])
    rank=sum(value>mp.mpf(tolerance)*largest for value in (largest,second))
    rank_cases.append(dict(m=3,n=2,matrix=matrix,rhs=[0.0,-delta,0.0],
        tolerance=tolerance,rank=rank,r_diagonal=[mp.nstr(largest,100),mp.nstr(second,100)],solution=['1','-1']))
artifact = dict(method='mpmath 1.3.0; 100 digits; rounded IEEE double inputs',
                rank_method='independent 100-digit column projection; threshold well above/below second pivot',
                seed='deterministic Hadamard; no random generator', cases=cases,rank_cases=rank_cases)
serialized = json.dumps(artifact, indent=2) + '\n'
destination = root / 'tests' / 'fixtures'
destination.mkdir(parents=True, exist_ok=True)
(destination / 'oracles.json').write_text(serialized, encoding='utf-8')
lines = ['#pragma once', '#include <array>', 'namespace kibo::tests {',
         'struct OracleCase { std::size_t m,n; const double* matrix; const double* rhs; const double* solution; };']
for index, case in enumerate(cases):
    for name, data in [('matrix',[x for row in case['matrix'] for x in row]),
                       ('rhs',case['rhs']),('solution',[float(x) for x in case['solution']])]:
        lines.append(f'inline constexpr std::array<double,{len(data)}> oracle_{index}_{name}'+'{'+
                     ','.join(repr(x) for x in data)+'};')
lines.append('inline constexpr std::array<OracleCase,6> oracles{{')
for index, case in enumerate(cases):
    lines.append(f'{{{case["m"]},{case["n"]},oracle_{index}_matrix.data(),oracle_{index}_rhs.data(),oracle_{index}_solution.data()}},')
lines.append('}};')
lines.append('struct RankOracleCase { std::size_t m,n; const double* matrix; const double* rhs; double tolerance; std::size_t rank; };')
for index,case in enumerate(rank_cases):
    for name,data in [('matrix',[x for row in case['matrix'] for x in row]),('rhs',case['rhs'])]:
        lines.append(f'inline constexpr std::array<double,{len(data)}> rank_{index}_{name}'+'{'+','.join(repr(x) for x in data)+'};')
lines.append(f'inline constexpr std::array<RankOracleCase,{len(rank_cases)}> rank_oracles'+ '{{')
for index,case in enumerate(rank_cases):
    lines.append(f'{{{case["m"]},{case["n"]},rank_{index}_matrix.data(),rank_{index}_rhs.data(),{case["tolerance"]},{case["rank"]}}},')
lines.extend(['}};','}'])
(destination / 'oracles.hpp').write_text('\n'.join(lines)+'\n', encoding='utf-8')
checksum=hashlib.sha256(serialized.encode()).hexdigest()
(destination / 'oracles.sha256').write_text(checksum+'  oracles.json\n',encoding='utf-8')
print('100-digit oracle:', checksum)
