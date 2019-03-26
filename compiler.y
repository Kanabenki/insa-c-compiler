%{
    #include <stdio.h>
    #include <stdlib.h>

    #include "tab_symbol.h"

    int yylex();
    void yyerror(char*);

    symbol_table *table;
    type curr_type = INT;
    char curr_const = 0;
    int curr_depth = 0;
%}

%union {
    char *text;
}
%token tMAIN 
%token tLCURL
%token tRCURL
%token tLPAR
%token tRPAR
%token tCONST
%token tINT
%token tID
%token tCOMMA
%token tPLUS
%token tMINUS
%token tMUL
%token tDIV
%token tEQUAL
%token tENDINST
%token tINTVAL
%token tPRINTF
%token tSTRING

%left tPLUS tMINUS
%left tMUL tDIV

%%

init: {
        if (symbol_table_init(&table, 1024) != 0) {
            printf("[SYMBOL] Error initializing symbol table\n");
            exit(1);
        }
        printf("[SYMBOL] Symbol table initialized\n");
    } start;

start: tMAIN tLPAR tRPAR tLCURL{curr_depth++;} body tRCURL { print_table(table); printf("[SYMBOL] Pop symbol table\n"); symbol_table_pop_depth(table); print_table(table);curr_depth--;};
body: exprs | ;
exprs: expr exprs | expr ;
expr: exprL tENDINST | exprL tEQUAL expArth tENDINST | expArth tENDINST | tPRINTF tLPAR tSTRING tRPAR tENDINST;
exprL: type tID {symbol_table_push(table, yylval.text, curr_type, curr_depth, curr_const);}
type: tCONST tINT { curr_type = INT; curr_const = 1;}
    | tINT { curr_type = INT; curr_const = 0;}
    | tINT tCONST { curr_type = INT; curr_const = 0;} 
expArth: tLCURL expArth tRCURL | expArth tMUL expArth | expArth tDIV expArth | expArth tPLUS expArth | expArth tMINUS expArth |val;
val: tID | tINTVAL ;