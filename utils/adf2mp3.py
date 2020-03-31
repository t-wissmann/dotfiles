#!/usr/bin/env python3

import sys
import os

def usage(targetfile):
    print("usage: {} INPUTFILE OUTPUTFILE".format(sys.argv[0]),
          file=targetfile)
    print("", file=targetfile)
    print("Convert the adf specified by INPUTFILE", file=targetfile)
    print("to an mp3 file specified by OUTFILE", file=targetfile)

def print_progress(name, ratio):
    print("\r{}: {}%     ".format(name, int(ratio * 100)), file=sys.stderr, end='')

def main():
    # https://gtaforums.com/topic/96504-how-do-i-play-adf-files/#
    if len(sys.argv) < 3:
        usage(sys.stderr)
        sys.exit(1)
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    input_size = os.path.getsize(input_file)
    BLOCK_SIZE = 128 * 8192
    progress = 0
    try:
        with open(input_file, 'rb') as inp:
            with open(output_file, 'wb') as outp:
                print_progress(output_file, progress / input_size)
                while True:
                    block = bytearray(inp.read(BLOCK_SIZE))
                    if len(block) == 0:
                        break
                    progress += len(block)
                    for i, item in enumerate(block):
                        block[i] = item ^ 0x22
                    outp.write(block)
                    print_progress(output_file, progress / input_size)
                print('', file=sys.stderr)
    except IOError as e:
        print("I/O error: {}".format(e), file=sys.stderr)
        sys.exit(1)

main()

