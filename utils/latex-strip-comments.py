#!/usr/bin/env python3

import argparse
import re
import sys

def remove_comments(texsrc, comments_re):
    def replacement(matchobj):
        return matchobj.group(1)
    return re.sub(comments_re, replacement, texsrc)

def remove_macros(texsrc, macro_re):
    newsrc = ''
    pos = 0  # the next position to copy to 'newsrc'
    for m in macro_re.finditer(texsrc):
        start = m.start(0)
        end = m.end(0)  # the first character after the match
        if start < pos:
            # skipping nested macro
            continue
        if end >= len(texsrc) or texsrc[end] != '{':
            expected = '{'
            instead = texsrc[end:end + 20].replace('\n', '\\n')
            print(f'Warning: {m.group(0)} is not followed by »{expected}« but by »{instead}« instead.', file=sys.stderr)
            print(f'         Ignoring this occurrence. (Maybe it is the macro\'s definition)', file=sys.stderr)
        else:
            # copy until 'end + 1'
            newsrc += texsrc[pos:end + 1]
            pos = end + 1

            # scan for closing '}'
            stackdepth = 0
            escaped = False
            for i in range(end + 1, len(texsrc)):
                if escaped == True:
                    escaped = False
                    continue
                elif texsrc[i] == '\\':
                    escaped = True
                elif texsrc[i] == '{':
                    stackdepth += 1
                elif texsrc[i] == '}':
                    stackdepth -= 1
                    if stackdepth < 0:
                        # we found the closing '}'
                        # so set 'pos' to this position without copying:
                        pos = i
                        break
    # after all matches being scanned, copy the rest:
    newsrc += texsrc[pos:]
    return newsrc

def main():
    desc = "Clear the parameters of certain tex macros"
    parser = argparse.ArgumentParser(
                description=desc,
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--comments', default=r'(%)[^\n]*',
                        help='Regex for comments: replace the regex by its first group')
    parser.add_argument('--macros', default=r'\\..note(\[[^]]*\])?|\\takeout',
                        help='Regex for the macros whose parameter are to be stripped')
    parser.add_argument('file', metavar='FILE', nargs='+',
                        help='tex sources')
    args = parser.parse_args()

    macros_re = re.compile(args.macros)
    comments_re = re.compile(args.comments)
    for filepath in args.file:
        with open(filepath, 'r') as fh:
            texsrc = fh.read()
        texsrc = remove_comments(texsrc, comments_re)
        texsrc = remove_macros(texsrc, macros_re)
        print(texsrc)


main()

