all: compiler

compiler: compiler.l compiler.y
	flex compiler.l
	bison -d compiler.y
	gcc -o compiler y.tab.c lex.yy.c -ly -lfl

clean:
	rm lex.yy.c compiler
