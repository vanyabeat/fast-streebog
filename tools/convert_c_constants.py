#!/usr/bin/env python3
import re


with open('../fast-streebog-lib/windows_x64/streebog_key_schedule.asm', 'r') as f:
    content = f.read()

output = []
output.append('// Streebog round constants C[0]..C[11]')
output.append('// Each constant is 64 bytes')
output.append('')
output.append('.data')
output.append('.align 4')
output.append('')


for i in range(12):
    pattern = rf'C_{i}:\s*\n((?:\s*DB\s+[^\n]+\n)+)'
    match = re.search(pattern, content)
    
    if match:
        output.append(f'.global _STREEBOG_C_{i}')
        output.append(f'_STREEBOG_C_{i}:')
        
        
        db_lines = match.group(1).strip().split('\n')
        bytes_list = []
        
        for line in db_lines:
            
            hex_values = re.findall(r'0([0-9a-fA-F]+)h', line)
            bytes_list.extend(hex_values)
        
        
        for j in range(0, len(bytes_list), 8):
            chunk = bytes_list[j:j+8]
            byte_str = ', '.join(f'0x{b}' for b in chunk)
            output.append(f'    .byte {byte_str}')
        
        output.append('')

with open('../fast-streebog-lib/unix_arm64/streebog_constants.S', 'w') as f:
    f.write('\n'.join(output))

print("Generated streebog_constants.S")
