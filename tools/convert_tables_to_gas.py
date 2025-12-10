#!/usr/bin/env python3
import re

with open('../fast-streebog-lib/windows_x64/streebog_precalc_tables.asm', 'r') as f:
    content = f.read()

output = []
output.append('// Precalculated lookup tables for optimized Streebog L-transform')
output.append('// This file contains Ax[8][256] lookup table')
output.append('// Total size: 8 * 256 * 8 bytes = 16 KB')
output.append('')
output.append('.data')
output.append('.align 4')
output.append('')

for col in range(8):
    pattern = rf'Ax_COL{col}:\s*((?:QWORD\s+0[0-9a-fA-F]+h\s*)+)'
    match = re.search(pattern, content, re.MULTILINE | re.DOTALL)
    
    if match:
        output.append(f'// Column {col} (byte offset {col})')
        output.append(f'.global _Ax_COL{col}')
        output.append(f'_Ax_COL{col}:')
        
        qwords = re.findall(r'QWORD\s+(0[0-9a-fA-F]+h)', match.group(1))
        
        for i, qword in enumerate(qwords):
            value = '0x' + qword[1:-1]
            output.append(f'    .quad {value}')
            
            if (i + 1) % 4 == 0 and i > 0:
                output.append('')
        
        output.append('')

with open('../fast-streebog-lib/unix_arm64/streebog_precalc_tables.S', 'w') as f:
    f.write('\n'.join(output))

print("Generated streebog_precalc_tables.S")
