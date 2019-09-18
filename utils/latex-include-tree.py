#!/usr/bin/env python3

# visualize the include order and dependencies between latex
# packages given its log file
import sys
import re


class Tree:
    def __init__(self):
        self.children = []
        self.nodename = ''

    def print(self, depth=0):
        print(' |' * depth, end='')
        print('-+-' + self.nodename)
        for c in self.children:
            c.print(depth + 1)


def insertnewline(line):
    line = line.replace('\n', '')
    if len(line) == 79:
        return line
    else:
        return line + '\n'


def main():
    with open(sys.argv[1], "r") as fh:
        buf = ''.join([insertnewline(l.replace('\r', '')) for l in fh.readlines()])
    tokenized = []
    for l in buf.split('\n'):
        tokenized += [i for i in re.split('([() ])', l)]
    tokenized = [i for i in tokenized if i != '' and i != ' ']
    first_token = False
    tree_root = Tree() # create a dummy node
    cur_tree = tree_root
    stack = []
    for t in tokenized:
        if t == '(':
            stack.append(cur_tree)
            cur_tree = Tree()
            first_token = True
        elif t == ')':
            # pop stack
            if cur_tree.nodename[0] == '.' or cur_tree.nodename[0] == '/':
                stack[-1].children.append(cur_tree)
            cur_tree = stack[-1]
            stack = stack[0:-1]
        elif first_token:
            cur_tree.nodename = t
            first_token = False
        else:
            pass
    # close all open trees in the stack
    while stack != []:
        stack[-1].children.append(cur_tree)
        cur_tree = stack[-1]
        stack = stack[0:-1]
    for c in cur_tree.children:
        c.print()


main()
