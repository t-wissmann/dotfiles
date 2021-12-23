
# Usage:
# Edit inkscape svg files ending with _p[0-9].svg
# Then run 'make'
#
inkscapesvg = $(wildcard *_p*.svg)
inkscapepdf = $(inkscapesvg:.svg=.pdf)
filename_pattern = $(wildcard *_p1.svg)
main_final = $(filename_pattern:_p1.svg=_filled.pdf)

.PHONY: all

all: $(main_final)

%_filled.pdf: $(inkscapepdf) Makefile
	pdftk $(patsubst %.svg,%.pdf,$(wildcard $(patsubst %_filled.pdf,%,$@)_p*.svg)) cat output $@


%.pdf: %.svg
	@echo $< "--->" $@
	inkscape --export-filename=$@ --export-pdf-version=1.5 $<

clean:
	rm -f -v $(inkscapepdf) $(main_tax)
