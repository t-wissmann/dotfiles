#!/bin/python

import sys
import subprocess
import urllib.parse

# we get as a input something like:
# user@domain?subject=XYZ&cc=...&body=...


o     = urllib.parse.urlparse(sys.argv[1])
query = urllib.parse.parse_qs(o.query)

proc = [ ]
#proc += [ "urxvt", "-e" ]
proc += [ "mutt" ]
if 'subject' in query:
    proc += [ '-s', query['subject'][0] ]
#proc += [ '-H', '-' ] # read message body from stdin
proc += [ '--', o.path ]

#print (proc)
mutt = subprocess.Popen(proc) #, stdin=subprocess.PIPE)
mutt.wait()
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
