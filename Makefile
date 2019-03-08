all: compiler

compiler: compiler.l compiler.y
	flex -d compiler.l
	yacc -d compiler.y
	gcc -o compiler y.tab.c lex.yy.c -ly -lfl

clean:
	rm lex.yy.c compiler
