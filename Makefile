LATEX=lualatex

LATEXOPT=--shell-escape --synctex=1
NONSTOP=--interaction=nonstopmode

LATEXMK=latexmk
LATEXMKOPT=-pdf
CONTINUOUS=-pvc

MAIN=main
SUBDIRS :=
CONTENT_SOURCE := $(shell find content -type f -iname "*.tex")
SOURCES=$(MAIN).tex Makefile $(CONTENT_SOURCE)
BIB_SOURCES := $(shell find . -type f -iname "*.bibpart")
#FIGURES := $(shell for dir in "$(SUBDIRS)"; do find $$dir/img $$dir/fig -type f; done;)

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
	rm -f chktex.txt biblatexcheck.html

once: $(MAIN).tex .refresh $(SOURCES) $(FIGURES) bibtex.bib
	./onfail.sh $(LATEXMK) $(LATEXMKOPT) -pdflatex=\"$(LATEX) $(LATEXOPT) $(NONSTOP) %O %S\" $(MAIN)

continuous: $(MAIN).tex .refresh $(SOURCES) $(FIGURES) bibtex.bib
	$(LATEXMK) $(LATEXMKOPT) $(CONTINUOUS) \
		-pdflatex="$(LATEX) $(LATEXOPT) $(NONSTOP) %O %S" $(MAIN)

debug: once
	rubber-info $(MAIN)

bibtex.bib: $(BIB_SOURCES)
	cat $^ > bibtex.bib

lint: bibtex.bib
	-chktex -H1 -o chktex.txt -v2 -b0 $(shell find . -type f -name "*.tex")
	-python biblatex_check.py -b bibtex.bib -a main.aux -o biblatexcheck.html


test: clean bibtex.bib
	latexmk -pdf -pdflatex="echo X | lualatex --draftmode --shell-escape --interaction=errorstopmode %O %S \; touch %D" $(MAIN)

diff: clean bibtex.bib
	-bash diff_cha.sh

.PHONY: clean force once debug lint continuous test all diff
