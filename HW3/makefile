make:
	make clean
	make build

build:
	flex scanner.l
	byacc -vd parser.y 
	gcc -o codegen lex.yy.c y.tab.c code.c -lfl
clean:
	rm -f lex.yy.c codegen y.output y.tab.c y.tab.h
compile:
	riscv32-unknown-elf-gcc main.c codegen.S
	qemu-riscv32 a.out

