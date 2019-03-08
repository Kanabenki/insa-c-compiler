all: compiler

compiler: compiler.l
	flex compiler.l
	gcc -o compiler lex.yy.c -lfl

clean:
	rm lex.yy.c compiler
