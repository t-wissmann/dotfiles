
.PHONY: all install xdefaults xrdb xdg checkpackages

install:
	./lsfiles.sh | dryrun=0 ./link.sh -

all: install xdg man checkpackages

xrdb: xdefaults

#	xrdb -cpp cpp -merge ~/.Xdefaults
xdefaults:
	xrdb -cpp cpp -load ~/.Xdefaults

xdg:
	xdg/setup.sh

man:
	./mkmandir.sh

checkpackages:
	./checkpackages.sh

