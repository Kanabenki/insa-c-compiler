all: compiler

compiler: src/compiler.l src/compiler.y src/symbol_table.c src/symbol_table.h src/instruction_table.h src/instruction_table.c
	flex -d src/compiler.l
	yacc -d -v src/compiler.y
	gcc -I src -o compiler y.tab.c lex.yy.c src/symbol_table.c src/instruction_table.c -ly -lfl -g -Wall

clean:
	rm lex.yy.c compiler
