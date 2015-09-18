
.PHONY: all install xdefaults xrdb

all: install

install:
	./lsfiles.sh | dryrun=0 ./link.sh -

xrdb: xdefaults

xdefaults:
	xrdb -cpp cpp -merge ~/.Xdefaults


