#!/usr/bin/env python3
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.

import sys
import struct
import os

if len(sys.argv) != 4:
    print("USE: python3 makecoe.py <input.bin> <output.coe> <size_in_words>")
    sys.exit(1)

input_bin = sys.argv[1]
output_coe = sys.argv[2]
total_words = int(sys.argv[3])

# If the file does not exist (e.g. no .data in the C code), create an empty COE
if not os.path.exists(input_bin) or os.path.getsize(input_bin) == 0:
    words = []
else:
    with open(input_bin, "rb") as f:
        bin_data = f.read()

    words = []
    for i in range(0, len(bin_data), 4):
        chunk = bin_data[i:i+4]
        if len(chunk) < 4:
            chunk += b'\x00' * (4 - len(chunk))
        word = struct.unpack("<I", chunk)[0]
        words.append(f"{word:08X}")

# Pad with NOPs or zeros to the desired size
while len(words) < total_words:
    words.append("00000000")

with open(output_coe, "w") as f:
    f.write("memory_initialization_radix=16;\n")
    f.write("memory_initialization_vector=\n")
    f.write(",\n".join(words[:-1]))
    f.write(",\n" + words[-1] + ";\n")

print(f"[{output_coe}] generated: {len(words)} words (32-bit).")