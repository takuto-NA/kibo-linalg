"""Plot completed benchmark summaries; optional matplotlib dependency."""
import argparse
import json
from pathlib import Path

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

parser = argparse.ArgumentParser()
parser.add_argument('primary', type=Path)
parser.add_argument('scalar', type=Path)
parser.add_argument('output', type=Path)
args = parser.parse_args()
series = [(args.primary, 'Windows MSVC: default Eigen SIMD'),
          (args.scalar, 'Linux Clang: both backends scalar')]
figure, axes = plt.subplots(2, 2, figsize=(11, 7), sharex=True)
for column, (directory, title) in enumerate(series):
    data = json.loads((directory/'summary.json').read_text(encoding='utf-8'))
    for row, solver in enumerate(['normal-LLT', 'augmented-QR']):
        axis = axes[row, column]
        for multiplier, color, marker in [(1, '#1769aa', 'o'), (4, '#ba451b', 's')]:
            cases = sorted((item for item in data if item['solver'] == solver
                and item['phase'] == 'factor_solve' and item['m'] == multiplier*item['n']),
                key=lambda item: item['n'])
            if [item['n'] for item in cases] != [2, 8, 32, 128, 512]:
                raise ValueError('incomplete factor/solve summary')
            x = [item['n'] for item in cases]
            axis.plot(x, [item['kibo_over_eigen_ratio'] for item in cases],
                      marker=marker, color=color, label='m = n' if multiplier==1 else 'm = 4n')
            axis.fill_between(x, [item['ratio_95_low'] for item in cases],
                              [item['ratio_95_high'] for item in cases], color=color, alpha=0.16)
        axis.axhline(1, color='#555555', linestyle='--', linewidth=1)
        axis.set_xscale('log', base=2)
        axis.set_yscale('log', base=2)
        axis.set_xticks([2, 8, 32, 128, 512], ['2', '8', '32', '128', '512'])
        axis.grid(True, which='both', alpha=0.18)
        axis.set_title(f'{title}\n{solver}', fontsize=11)
        axis.set_ylabel('kibo time / Eigen time')
        axis.legend(fontsize=9)
        if row == 1:
            axis.set_xlabel('variables n')
figure.suptitle('Prepared factor + solve: five independent process runs', fontsize=14)
figure.text(0.5, 0.02,
    'Ratio > 1: kibo is slower. Shading: paired 95% bootstrap interval.\n'
    'Each column compares its own backends; compiler/OS differ. Input assembly is excluded.',
    ha='center', fontsize=9)
figure.tight_layout(rect=(0, 0.07, 1, 0.94))
args.output.parent.mkdir(parents=True, exist_ok=True)
for extension in ['png', 'svg', 'pdf']:
    figure.savefig(args.output.with_suffix('.'+extension), dpi=180)
plt.close(figure)
