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
    FILE *asm_file;

    void asm_add(int reg_store, int reg_a, int reg_b) {
        fprintf(asm_file, "ADD %d %d %d\n", reg_store, reg_a, reg_b);
    }

    void asm_mul(int reg_store, int reg_a, int reg_b) {
        fprintf(asm_file, "MUL %d %d %d\n", reg_store, reg_a, reg_b);
    }

    void asm_sou(int reg_store, int reg_a, int reg_b) {
        fprintf(asm_file, "SOU %d %d %d\n", reg_store, reg_a, reg_b);
    }

    void asm_div(int reg_store, int reg_a, int reg_b) {
        fprintf(asm_file, "DIV %d %d %d\n", reg_store, reg_a, reg_b);
    }

    void asm_sou(int reg_store, int reg_val) {
        fprintf(asm_file, "COP %d %d\n", reg_store, reg_val);
    }

    void asm_afc(int reg, int val) {
        fprintf(asm_file, "AFC %d %d\n", reg, val);
    }

    void asm_load(int reg, int addr) {
        fprintf(asm_file, "LOAD %d %d\n", reg, addr);
    }

    void asm_store(int addr, int reg) {
        fprintf(asm_file, "STORE %d %d\n", addr, reg);
    }

    void asm_equ(int reg_store, int reg_a, int reg_b) {
        fprintf(asm_file, "EQU %d %d %d\n", reg_store, reg_a, reg_b);
    }

    void asm_inf(int reg_store, int reg_a, int reg_b) {
        fprintf(asm_file, "INF %d %d %d\n", reg_store, reg_a, reg_b);
    }

    void asm_infe(int reg_store, int reg_a, int reg_b) {
        fprintf(asm_file, "INFE %d %d %d\n", reg_store, reg_a, reg_b);
    }

    void asm_sup(int reg_store, int reg_a, int reg_b) {
        fprintf(asm_file, "SUP %d %d %d\n", reg_store, reg_a, reg_b);
    }

    void asm_supe(int reg_store, int reg_a, int reg_b) {
        fprintf(asm_file, "SUPE %d %d %d\n", reg_store, reg_a, reg_b);
    }

    void asm_jmp(int addr) {
        fprintf(asm_file, "JMP %d\n", addr);
    }

    void asm_jmpc(int addr, int reg) {
        fprintf(asm_file, "JMPC %d %d\n", addr, reg);
    }
%}

%union {
    int nb;
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
        asm_file = fopen("out.asm", "w");
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
val: tID | tINTVAL {int add_temp = add_temporary_symbol(table,curr_type); asm_afc(0, yylval.nb),  asm_store(add_temp, 0);};

//TODO LE DEPOP DES VARIABLES TEMPORAIRE ET TROUVER POURQUOI çA PRINT PAS :'(