#!/bin/python

import sys
import subprocess
import urllib.parse
import tempfile
import os

# we get as a input something like:
# mailto: user@domain?subject=XYZ&cc=...&body=...
# or
# mailto://user@domain?subject=XYZ&cc=...&body=...

o     = urllib.parse.urlparse(sys.argv[1])
query = urllib.parse.parse_qs(o.query)

address = o.netloc + o.path # one of them is empty

# >>> from urllib.parse import urlparse
# >>> urlparse('mailto:bla@blub.com')
# ParseResult(scheme='mailto', netloc='', path='bla@blub.com', params='', query='', fragment='')
# >>> urlparse('mailto://bla@blub.com')
# ParseResult(scheme='mailto', netloc='bla@blub.com', path='', params='', query='', fragment='')

draft = tempfile.NamedTemporaryFile(mode='w',delete=False)
if 'body' in query:
    draft.write(query['body'][0] + '\n')
draft.close()


proc = [ ]
#proc += [ "urxvt", "-e" ]
proc += [ "mutt" ]
if 'subject' in query:
    proc += [ '-s', query['subject'][0] ]
if 'cc' in query:
    for cc in query['cc']:
        proc += [ '-c', cc ]
proc += [ '-H', draft.name ]
proc += [ '--', address ]

mutt = subprocess.Popen(proc) #, stdin=subprocess.PIPE)
mutt.wait()
#print(draft.name)
os.unlink(draft.name)
#print (proc)

#if 'body' in query:
#mutt.stdin.write(b'test');
#mutt.stdin.close()
#(address,parameters) = sys.argv[1].split('?', 1)
#
#param_dict = {}
#
#for x in parameters.split('&'):
#    (name,value) = x.split('=', 
#    param_dict[
