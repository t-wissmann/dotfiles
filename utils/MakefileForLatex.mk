src = $(shell grep -l '\\begin{document}' *.tex)
pdf = $(src:.tex=.pdf)
pdftrimmed = $(pdf:.pdf=-trimmed.pdf)

.PHONY: all clean install trimmed info

all: $(pdf) $(pdftrimmed)

trimmed: $(pdftrimmed)

%-trimmed.pdf: %.tex
	latexmk -pdf -jobname=$(patsubst %.pdf,%,$@) -synctex=1 $<

%.pdf: %.tex $(wildcard *.bib *.sty)
	latexmk -pdf -synctex=1 $<

clean:
	rm -f $(wildcard *.out *.bbl *.bcf *.vtc *.fls *.log *.aux *.blg)
	rm -f $(wildcard  *.fdb_latexmk)
	rm -f $(pdftrimmed) $(pdf)

info:
	@echo Detected '(main)' TeX--Files: ${src}
	@echo PDF files: ${pdf}
	@echo Trimmed PDF files: ${pdftrimmed}
