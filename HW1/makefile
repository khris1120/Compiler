CC = gcc
TARGET = scanner

all:$(TARGET)

$(TARGET): lex.yy.c
	$(CC) -o $(TARGET) lex.yy.c -lfl

lex.yy.c: scanner.l
	flex scanner.l

clean:
	rm -f  lex.yy.c $(TARGET)