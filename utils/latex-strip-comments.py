#!/usr/bin/env python3

import argparse
import re
import sys
import textwrap

def remove_comments(texsrc, comments_re, summary={}):
    def replacement(matchobj):
        replacement.count += 1
        return matchobj.group(1)
    replacement.count = 0
    newsrc = re.sub(comments_re, replacement, texsrc)
    summary['comments removed'] = replacement.count
    return newsrc

def remove_macros(texsrc, macro_re, summary={}):
    newsrc = ''
    pos = 0  # the next position to copy to 'newsrc'
    macro2count = {}
    # everything after index i is in line newlineidx2lineno[i]:
    # (and character 0 is in line '1')
    newlineidx2lineno = {-1: 1}
    for idx, ch in enumerate(texsrc):
        if ch == '\n':
            assert(texsrc[idx] == '\n')
            newlineidx2lineno[idx] = len(newlineidx2lineno) + 1
    def idx2line(idx):
        """given a position of a character, return its line number"""
        for i in range(idx, 0, -1):
            if texsrc[i] == '\n':
                return newlineidx2lineno[i]
        return 1

    for m in macro_re.finditer(texsrc):
        start = m.start(0)
        end = m.end(0)  # the first character after the match
        if start < pos:
            # skipping nested macro
            print('Line {}: Skipping »{}« which was nested in another macro that has been already removed'
                    .format(idx2line(start), m.group(0)),
                  file=sys.stderr)
            continue
        if end >= len(texsrc) or texsrc[end] != '{':
            expected = '{'
            instead = re.sub('\n.*$', '', texsrc[end:end + 20])
            line = str(idx2line(start))
            print(f'Line {line}: {m.group(0)} is not followed by »{expected}« but by »{instead}« instead.', file=sys.stderr)
            print(f'     {len(line)*" "}  Ignoring this occurrence. (Maybe it is the macro\'s definition)', file=sys.stderr)
        else:
            # in this branch, we actually do the replacement
            macro2count[m.group(0)] = macro2count.get(m.group(0), 0) + 1

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
    for k, v in macro2count.items():
        summary[f'parameters removed {k}' ] = v
    return newsrc

def main():
    longdesc = textwrap.dedent("""
    Clear the parameters of certain tex macros. In a latex source file, remove
    comments of various shapes in the following order:

      1. remove source code comments (text following %%)
      2. remove macros for PDF comments, controlled by the --macros regex.
         Here, the macro call is not removed, but the parameter passed
         to the macros is cleared. For example for --macros='\\\\takeout'
         the code

            foo \\takeout{bar $\{\\frac{1}{2}\}$} baz

         is replaced by

            foo \\takeout{} baz

    """)
    parser = argparse.ArgumentParser(
                description=longdesc,
                formatter_class=argparse.RawDescriptionHelpFormatter,
                )
    parser.add_argument('--comments', default=r'(%)[^\n]*',
                        help='Regex for comments: replace the regex by its first group')
    parser.add_argument('--macros', default=r'\\..note(\[[^]]*\])?|\\takeout',
                        help='Regex for the macros whose parameter are to be stripped')
    parser.add_argument('--summary', action='store_const', const=True, default=False,
                        help='Print summary to stderr')
    parser.add_argument('file', metavar='FILE', nargs='+',
                        help='tex sources')
    args = parser.parse_args()

    macros_re = re.compile(args.macros)
    comments_re = re.compile(args.comments)
    for filepath in args.file:
        with open(filepath, 'r') as fh:
            texsrc = fh.read()
        summary = {}
        texsrc = remove_comments(texsrc, comments_re, summary=summary)
        texsrc = remove_macros(texsrc, macros_re, summary=summary)
        print(texsrc)
        if args.summary:
            def p(text):
                print(text, file=sys.stderr)
            p(f"Summary for »{filepath}«:")
            for k, v in summary.items():
                p(f'  {k}: {v}')


main()

