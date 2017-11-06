LATEX=lualatex

LATEXOPT=--shell-escape --synctex=1
NONSTOP=--interaction=nonstopmode

LATEXMK=latexmk
LATEXMKOPT=-pdf
CONTINUOUS=-pvc

MAIN=main
SUBDIRS :=
CONTENT_SOURCE := $(shell gfind content -type f -iname "*.tex")
SOURCES=$(MAIN).tex Makefile $(CONTENT_SOURCE)
BIB_SOURCES := $(shell gfind . -type f -iname "*.bibpart")

all: once

.refresh:
	touch .refresh

force:
	touch .refresh
	rm -f $(MAIN).pdf
	$(LATEXMK) $(LATEXMKOPT) $(CONTINUOUS) \
		-pdflatex="$(LATEX) $(LATEXOPT) %O %S" $(MAIN)

clean:
	$(LATEXMK) -C $(MAIN)
	rm -f main.auxlock
	rm -f bibtex.bib
	rm -f figures/*.dpth figures/*.md5 figures/*.pdf figures/*.log figures/*.run.xml

once: $(MAIN).tex .refresh $(SOURCES) $(FIGURES) bibtex.bib
	$(LATEXMK) $(LATEXMKOPT) -pdflatex=\"$(LATEX) $(LATEXOPT) $(NONSTOP) %O %S\" $(MAIN)

continuous: $(MAIN).tex .refresh $(SOURCES) $(FIGURES) bibtex.bib
	$(LATEXMK) $(LATEXMKOPT) $(CONTINUOUS) \
		-pdflatex="$(LATEX) $(LATEXOPT) $(NONSTOP) %O %S" $(MAIN)

bibtex.bib: $(BIB_SOURCES)
	cat $^ > bibtex.bib

lint:
	chktex -v0 $(shell gfind . -type f -name "*.tex")

test: clean bibtex.bib
	latexmk -pdf -pdflatex="echo X | lualatex --draftmode --shell-escape --interaction=errorstopmode %O %S \; touch %D" $(MAIN)

.PHONY: clean force once lint continuous test all
