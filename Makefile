CC = gcc
FLEX = flex
BISON = bison
CFLAGS = -D_POSIX_C_SOURCE=200809L -std=c11 -Wall -Wextra -pedantic

all: upl

parser.tab.c parser.tab.h: parser.y ast.h
	$(BISON) -Wall -d -o parser.tab.c parser.y

scanner.c: lexer.l parser.tab.h ast.h
	$(FLEX) -o scanner.c lexer.l

upl: main.c ast.c parser.tab.c scanner.c ast.h
	$(CC) $(CFLAGS) -o upl main.c ast.c parser.tab.c scanner.c

clean:
	rm -f upl parser.tab.c parser.tab.h scanner.c

.PHONY: all clean
