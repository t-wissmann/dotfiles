#!/usr/bin/env python3
# from https://stackoverflow.com/a/61234067/4400896
# requires the archlinux package: python-pandocfilters
# (but does not work for me at the moment because python
# does not find the pandocfilters package even though it is
# installed)
import pandocfilters
#from import toJSONFilter, Null

def behead(key, value, format, meta):
    if key == "Header" and value[0] == 1 and "title" not in meta:
        meta["title"] = {"t": "MetaInlines", "c": value[2]}
        return Null()

if __name__ == "__main__":
    toJSONFilter(behead)
