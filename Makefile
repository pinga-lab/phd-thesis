# This is a simple Makefile for compiling LaTeX documents.

# Based on the work of
# Joshua Ryan Smith (https://github.com/jrsmith3/latex_template)
# and
# Jason Hiebel (https://github.com/JasonHiebel/latex.makefile)

# CONFIGURATION
###############################################################################

# The name of the main .tex file to build.
# Other files can be included into this one.
PROJECT = thesis

# Folder with the Latex source files
SRC = .

# Folder where the figure files are (will assume they are EPS format)
FIGS = figures

# Folder where the BibTex .bib files are
BIB = .

# Folder where the .cls .bst and .sty style files are
STYLES = $(SRC)

# Folder where output will be placed
OUTPUT = output

### File Types (for dependencies)
TEX_FILES = $(shell find $(SRC) -maxdepth 1 -name '*.tex')
BIB_FILES = $(shell find $(BIB) -maxdepth 1 -name '*.bib')
STY_FILES = $(shell find $(STYLES) -maxdepth 1 -name '*.sty')
CLS_FILES = $(shell find $(STYLES) -maxdepth 1 -name '*.cls')
BST_FILES = $(shell find $(STYLES) -maxdepth 1 -name '*.bst')
EPS_FILES = $(shell find $(FIGS) -name '*.eps')

### Compilation Flags
LATEX_FLAGS  = -halt-on-error -output-directory $(OUTPUT)/

### Standard PDF Viewers
UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
PDFVIEWER = okular
endif
ifeq ($(UNAME), Darwin)
PDFVIEWER = open
endif


# MAIN TARGETS
###############################################################################

all: $(OUTPUT)/$(PROJECT).pdf

show: all
	@ # Redirect stdout and stderr to /dev/null for silent execution
	@ (${PDFVIEWER} $(OUTPUT)/$(PROJECT).pdf > /dev/null 2>&1 & )

wc: all
	@ pdftotext $(OUTPUT)/$(PROJECT).pdf - | wc -w

### Clean
# This target cleans the temporary files generated by the tex programs in
# use. All temporary files generated by this makefile will be placed in OUTPUT
# so cleanup is easy.
clean::
	rm -rf $(OUTPUT)/ *.aux
	find . -name "*-eps-converted-to.pdf" -exec rm -v {} \;


# BUILD THE SOURCES
###############################################################################
# Performs the typical build process for latex generations so that all
# references are resolved correctly. If adding components to this run-time
# always take caution and implement the worst case set of commands.
# Example: latex, bibtex, latex, latex
#
# Note the use of order-only prerequisites (prerequisites following the |).
# Order-only prerequisites do not affect the target -- if the order-only
# prerequisite has changed and none of the normal prerequisites have changed
# then this target IS NOT run.

$(OUTPUT)/:
	mkdir -p $(OUTPUT)/

$(OUTPUT)/$(PROJECT).aux: $(TEX_FILES) $(STY_FILES) $(CLS_FILES) $(EPS_FILES) | $(OUTPUT)/
	pdflatex $(LATEX_FLAGS) $(SRC)/$(PROJECT)
	cp $@ .
	# Copy the aux file next to the tex file for Vim completion purposes

$(OUTPUT)/$(PROJECT).bbl: $(BIB_FILES) $(BST_FILES) | $(OUTPUT)/$(PROJECT).aux
	cp $(BIB_FILES) $(OUTPUT)
	cp $(BST_FILES) $(OUTPUT)
	cd $(OUTPUT) && bibtex $(PROJECT)
	pdflatex $(LATEX_FLAGS) $(SRC)/$(PROJECT)

$(OUTPUT)/$(PROJECT).pdf: $(OUTPUT)/$(PROJECT).aux $(OUTPUT)/$(PROJECT).bbl
	pdflatex $(LATEX_FLAGS) $(SRC)/$(PROJECT) 1>/dev/null
