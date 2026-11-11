#!/usr/bin/env python3
"""Dependency-free checks of project assets and an independent FIR cycle model.
This does NOT compile or simulate the Verilog, nor validate Xilinx IP generation.
"""
from pathlib import Path
import cmath
import random
import re
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
coeff = [int(v) for v in (ROOT / 'coefficients/fir_coefficients.txt').read_text().split()]
assert len(coeff) == 21 and coeff == coeff[::-1]
assert all(-32768 <= v <= 32767 for v in coeff)
pkg = (ROOT / 'ece524_lab5.srcs/sources_1/new/fir_defs.vh').read_text()
assert [(-1 if sign else 1)*int(v) for sign, v in re.findall(r"^\s*\d+: coeff = (-?)16'sd(\d+);", pkg, re.M)] == coeff
coe = (ROOT / 'coefficients/fir_coefficients.coe').read_text().split('coefdata=')[1]
assert list(map(int, re.findall(r'-?\d+', coe))) == coeff
for node in ET.parse(ROOT / 'ece524_lab5.xpr').iter('File'):
    path = node.attrib['Path'].replace('$PSRCDIR', str(ROOT / 'ece524_lab5.srcs'))
    assert Path(path).is_file(), path

rng = random.Random(524)
inputs = [32767] + [0]*25 + [-32768, 32767] + [rng.randrange(-32768, 32768) for _ in range(1000)]
reference = [sum(coeff[k] * inputs[n-k] for k in range(min(n+1, 21))) for n in range(len(inputs))]
# Serial scheduling independent of the convolution reference: a circular sample
# buffer, one product on each busy edge, and random source idle intervals.
history = [0]*21
head = 0
index = 0
acc = 0
busy = False
accepted = 0
outputs = []
cycle = 0
accept_cycles = []
output_cycles = []
while len(outputs) < len(inputs):
    if not busy:
        if accepted < len(inputs) and rng.random() > .2:
            head = (head - 1) % 21
            history[head] = inputs[accepted]
            accepted += 1
            acc = history[head] * coeff[0]
            index = 1
            busy = True
            accept_cycles.append(cycle)
    else:
        acc += history[(head + index) % 21] * coeff[index]
        if index == 20:
            outputs.append(acc)
            output_cycles.append(cycle)
            busy = False
        else:
            index += 1
    cycle += 1
assert outputs == reference
assert all(b-a == 20 for a,b in zip(accept_cycles, output_cycles))
assert all(b-a >= 21 for a,b in zip(accept_cycles, accept_cycles[1:]))
assert max(map(abs, reference)) < 2**36
for freq in (500000, 1600000):
    gain = abs(sum(c*cmath.exp(-2j*cmath.pi*freq*k/5000000) for k,c in enumerate(coeff))) / 32767
    print(f'{freq/1e6:.1f} MHz normalized magnitude: {gain:.8f}')
print(f'PASS: coefficient consistency, XPR source paths, {len(outputs)} reference-model outputs, serial timing.')
print('HDL simulation and Vivado implementation still require the vendor tools.')
