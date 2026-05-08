#!/usr/bin/env python3
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.

import sys
import os

if len(sys.argv) != 4:
    print("Error:\n  Usage: python3 makehex.py <input.bin> <output.hex> <number of 32-bit words>")
    sys.exit(1)

binfile = sys.argv[1]
hexfile = sys.argv[2]
nwords = int(sys.argv[3])

if not os.path.isfile(binfile):
    print(f"Error:\n  File '{binfile}' not found.")
    sys.exit(1)

with open(binfile, "rb") as f:
    bindata = f.read()    

# Ensure that the data is always aligned in 4-byte (32-bit) blocks
while len(bindata) % 4 != 0:
    bindata += b'\x00'

words_in_bin = len(bindata) // 4

if words_in_bin > nwords:
    print(f"Error:\n  The file is too large ({words_in_bin} words). Maximum allowed is {nwords} words.")
    sys.exit(1)

print(f"Generating {hexfile} ({nwords} 32-bit words)...")

with open(hexfile, "w") as f:
    for i in range(nwords):
        if i < words_in_bin:
            w = bindata[4*i : 4*i+4]
            # Write in little-endian / hex format
            f.write("%02x%02x%02x%02x\n" % (w[3], w[2], w[1], w[0]))
        else:
            # Fill the rest of the memory with zeros
            f.write("00000000\n")
