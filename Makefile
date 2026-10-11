CC = gcc
LOCAL_TOOLS = $(CURDIR)/.tools/usr/bin
FLEX = $(if $(wildcard $(LOCAL_TOOLS)/flex),$(LOCAL_TOOLS)/flex,flex)
BISON = $(if $(wildcard $(LOCAL_TOOLS)/bison),$(LOCAL_TOOLS)/bison,bison)
CFLAGS = -D_POSIX_C_SOURCE=200809L -std=c11 -Wall -Wextra -pedantic

all: upl

parser.tab.c parser.tab.h: parser.y ast.h
	PATH="$(LOCAL_TOOLS):$$PATH" $(BISON) -Wall -d -o parser.tab.c parser.y

scanner.c: lexer.l parser.tab.h ast.h
	PATH="$(LOCAL_TOOLS):$$PATH" M4="$(LOCAL_TOOLS)/m4" $(FLEX) -o scanner.c lexer.l

upl: main.c ast.c parser.tab.c scanner.c ast.h
	$(CC) $(CFLAGS) -o upl main.c ast.c parser.tab.c scanner.c

clean:
	rm -f upl parser.tab.c parser.tab.h scanner.c

.PHONY: all clean
