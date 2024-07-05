CC = gcc
SCANNER = scanner.l
PARSER = parser.y
OUT_EXE = parser

all: $(OUT_EXE)

$(OUT_EXE): lex.yy.c y.tab.h y.tab.c
	$(CC) -o $(OUT_EXE) lex.yy.c y.tab.c -lfl

lex.yy.c: $(SCANNER)
	flex $(SCANNER)

y.tab.h y.tab.c: $(PARSER)
	byacc -d $(PARSER)

clean:
	rm -f lex.yy.c y.tab.h y.tab.c $(OUT_EXE)

compare: FILE1 ?=

compare: 
	@if [ -z "$(FILE1)" ]; then \
		echo "Usage: make compare FILE1=<file1>"; \
		exit 1; \
	fi
	dos2unix ${FILE1}
	./parser < ${FILE1} --> ./output/my_parser.txt 
	./golden_parser < ${FILE1} --> ./output/golden_parser.txt
	diff ./output/my_parser.txt ./output/golden_parser.txt