src = $(shell grep -l '\\begin{document}' *.tex)
pdf = $(src:.tex=.pdf)
pdftrimmed = $(pdf:.pdf=-trimmed.pdf)

.PHONY: all clean install trimmed info just-trimmed

just-trimmed: $(pdftrimmed)
	@echo -ne '\e[1;33m'
	@LC_ALL=C make -n -d --no-print-directory all 2>&1 | grep 'Must remake' || true
	@echo -ne '\e[0m'

all: $(pdf) $(pdftrimmed)

trimmed: $(pdftrimmed)

%-trimmed.pdf: %.tex
	latexmk -pdf -file-line-error -synctex=1 -halt-on-error -jobname=$(patsubst %.pdf,%,$@) $< || ( rm -v *.bcf;false )

fast: $(src)
	pdflatex -jobname=$(patsubst %.tex,%-trimmed,$<) -synctex=1 $<

%.pdf: %.tex $(wildcard *.bib *.sty)
	latexmk -pdf -file-line-error -synctex=1 -halt-on-error $< || ( rm -v *.bcf;false )

clean:
	rm -f $(wildcard *.out *.bbl *.bcf *.vtc *.fls *.log *.aux *.blg)
	rm -f $(wildcard  *.fdb_latexmk)
	rm -f $(wildcard *.synctex.gz)
	rm -f $(pdftrimmed) $(pdf)

info:
	@echo Detected '(main)' TeX--Files: ${src}
	@echo PDF files: ${pdf}
	@echo Trimmed PDF files: ${pdftrimmed}
