all: compiler

compiler: compiler.l compiler.y tab_symbol.c tab_symbol.h
	flex -d compiler.l
	yacc -d -v compiler.y
	gcc -o compiler tab_symbol.c y.tab.c lex.yy.c -ly -lfl -g

clean:
	rm lex.yy.c compiler
