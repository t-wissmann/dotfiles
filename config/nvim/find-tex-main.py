#!/usr/bin/env python3
import argparse
import textwrap
import os
import sys


def tex_to_fls(tex_file):
    base, ext = os.path.splitext(tex_file)
    if ext == '.tex':
        return base + '.fls'
    else:
        return tex_file + '.fls'


def list_tex_inputs(tex_file):
    fls_file = tex_to_fls(tex_file)
    pwd = None
    try:
        with open(fls_file) as fh:
            for l in fh.readlines():
                if l.startswith('PWD '):
                    pwd = l[len('PWD '):].strip()
                    continue
                if l.startswith('INPUT '):
                    path = l[len('INPUT '):].strip()
                    # path might be relative to tex_file
                    if not os.path.isabs(path) and pwd is not None:
                        path = os.path.join(pwd, path)
                    yield path
    except IOError as error:
        return []


def count_slashes(text):
    return text.count('/')


def main():
    """
    Given the file path of a tex file (NEEDLE), find the corresponding main tex
    file. If a list of candidates is provided, then we first check whether any
    of those is the main file of the tex project in which NEEDLE is used.

    Example usage:
    find-tex-main.py --candidates *.tex */*.tex -- src/some-concrete-file.tex 
    """
    parser = argparse.ArgumentParser(description=main.__doc__)
    parser.add_argument('--print-all', action='store_true', default=False,
                        help='Print all matching main files and not just the best')
    parser.add_argument('--candidates', metavar='TEXFILE', nargs='*',
                        help='A list of potential main tex files to check first')
    parser.add_argument('NEEDLE',
                        help='A file path. Look for the main tex document which includes the provided NEEDLE')
    args = parser.parse_args()
    needle = os.path.normpath(args.NEEDLE)
    if not os.path.isabs(needle):
        needle = os.path.abspath(needle)

    main_files = []
    for fp in args.candidates:
        for included in list_tex_inputs(fp):
            if os.path.normpath(included) == needle:
                main_files.append(os.path.normpath(fp))
                break

    main_files.sort(key=count_slashes)
    if args.print_all:
        print(len(main_files))
        for fp in main_files:
            print(fp)
    else:
        if len(main_files) > 0:
            print(main_files[0])


main()
