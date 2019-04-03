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

    void asm_cop(int reg_store, int reg_val) {
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

    type asm_load_symbols_op() {
        type type = get_last_symbol(table)->type;
        asm_load(0, get_last_symbol(table)->address);
        symbol_table_pop(table);
        asm_load(1, get_last_symbol(table)->address);
        symbol_table_pop(table);
        return type;
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
expr: exprL tENDINST | exprL tEQUAL expArth tENDINST {if(get_curr_depth(table)==-1){symbol_table_pop_depth(table);}}| expArth tENDINST {if(get_curr_depth(table)==-1){symbol_table_pop_depth(table);}} | tPRINTF tLPAR tSTRING tRPAR tENDINST;
exprL: type tID {symbol_table_push(table, yylval.text, curr_type, curr_depth, curr_const);}
type: tCONST tINT { curr_type = INT; curr_const = 1;}
    | tINT { curr_type = INT; curr_const = 0;}
    | tINT tCONST { curr_type = INT; curr_const = 0;}
expArth: tLCURL expArth tRCURL
    | expArth tMUL expArth {type op_type = asm_load_symbols_op(); asm_mul(0, 0, 1); symbol* sym = add_temporary_symbol(table, op_type); asm_store(sym->address, 0);}
    | expArth tDIV expArth {type op_type = asm_load_symbols_op(); asm_div(0, 0, 1);  symbol* sym = add_temporary_symbol(table, op_type); asm_store(sym->address, 0);}
    | expArth tPLUS expArth {type op_type = asm_load_symbols_op(); asm_add(0, 0, 1);  symbol* sym = add_temporary_symbol(table, op_type); asm_store(sym->address, 0);}
    | expArth tMINUS expArth {type op_type = asm_load_symbols_op(); asm_sou(0, 0, 1);  symbol* sym = add_temporary_symbol(table, op_type); asm_store(sym->address, 0);}
    | val;
val: tID {symbol *sym = get_symbol_from_name(table, yylval.text); symbol *temp = add_temporary_symbol_redirect(table, sym);}
    | tINTVAL {symbol *temp = add_temporary_symbol(table, INT); asm_afc(0, yylval.nb),  asm_store(temp->address, 0);};
