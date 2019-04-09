%{
    #include <stdio.h>
    #include <stdlib.h>

    #include "tab_symbol.h"

    #define HIGHB(x) x >> 8

    int yylex();
    void yyerror(char*);

    symbol_table *table;
    symbol *affect_sym;
    type curr_type = INT;
    char curr_const = 0;
    int curr_depth = 0;
    FILE *asm_file;
    FILE *bin_file;

    typedef struct asm_1 {
        u8 op;
        u8 b1;
        u8 b2;
        u8 b3;
    } asm_1;

    void write_bin(u8 op, u8 b1, u8 b2, u8 b3) {
        asm_1 oper = {op, b1, b2, b3};
        fwrite(&oper, sizeof(oper), 1, bin_file);
    }

    void asm_add(u8 reg_store, u8 reg_a, u8 reg_b) {
        write_bin(1, reg_store, reg_a, reg_b);
        fprintf(asm_file, "ADD %d %d %d\n", reg_store, reg_a, reg_b);
    }

    void asm_mul(u8 reg_store, u8 reg_a, u8 reg_b) {
        write_bin(2, reg_store, reg_a, reg_b);
        fprintf(asm_file, "MUL %d %d %d\n", reg_store, reg_a, reg_b);
    }

    void asm_sou(u8 reg_store, u8 reg_a, u8 reg_b) {
        write_bin(3, reg_store, reg_a, reg_b);
        fprintf(asm_file, "SOU %d %d %d\n", reg_store, reg_a, reg_b);
    }

    void asm_div(u8 reg_store, u8 reg_a, u8 reg_b) {
        write_bin(4, reg_store, reg_a, reg_b);
        fprintf(asm_file, "DIV %d %d %d\n", reg_store, reg_a, reg_b);
    }

    void asm_cop(u8 reg_store, u8 reg_val) {
        write_bin(5, reg_store, reg_val, 0);
        fprintf(asm_file, "COP %d %d\n", reg_store, reg_val);
    }

    void asm_afc(u8 reg, u16 val) {
        write_bin(6, reg, HIGHB(val), val);
        fprintf(asm_file, "AFC %d %d\n", reg, val);
    }

    void asm_load(u8 reg, u16 addr) {
        write_bin(7, reg, HIGHB(addr), addr);
        fprintf(asm_file, "LOAD %d %d\n", reg, addr);
    }

    void asm_store(u16 addr, u8 reg) {
        write_bin(8, HIGHB(addr), addr, reg);
        fprintf(asm_file, "STORE %d %d\n", addr, reg);
    }

    void asm_equ(u8 reg_store, u8 reg_a, u8 reg_b) {
        write_bin(9, reg_store, reg_a, reg_b);
        fprintf(asm_file, "EQU %d %d %d\n", reg_store, reg_a, reg_b);
    }

    void asm_inf(u8 reg_store, u8 reg_a, u8 reg_b) {
        write_bin(10, reg_store, reg_a, reg_b);
        fprintf(asm_file, "INF %d %d %d\n", reg_store, reg_a, reg_b);
    }

    void asm_infe(u8 reg_store, u8 reg_a, u8 reg_b) {
        write_bin(11, reg_store, reg_a, reg_b);
        fprintf(asm_file, "INFE %d %d %d\n", reg_store, reg_a, reg_b);
    }

    void asm_sup(u8 reg_store, u8 reg_a, u8 reg_b) {
        write_bin(12, reg_store, reg_a, reg_b);
        fprintf(asm_file, "SUP %d %d %d\n", reg_store, reg_a, reg_b);
    }

    void asm_supe(u8 reg_store, u8 reg_a, u8 reg_b) {
        write_bin(13, reg_store, reg_a, reg_b);
        fprintf(asm_file, "SUPE %d %d %d\n", reg_store, reg_a, reg_b);
    }

    void asm_jmp(u16 addr) {
        write_bin(14, HIGHB(addr), addr, 0);
        fprintf(asm_file, "JMP %d\n", addr);
    }

    void asm_jmpc(u16 addr, u8 reg) {
        write_bin(15, HIGHB(addr), addr, reg);
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
        bin_file = fopen("out.bin", "w");
        if (symbol_table_init(&table, 1024) != 0) {
            printf("[SYMBOL] Error initializing symbol table\n");
            exit(1);
        }
        printf("[SYMBOL] Symbol table initialized\n");
    } start;

start: tMAIN tLPAR tRPAR tLCURL {
    curr_depth++;
} 
    body tRCURL {
    print_table(table);
    printf("[SYMBOL] Pop symbol table\n");
    symbol_table_pop_depth(table);
    print_table(table);
    curr_depth--;
};
body: exprs | ;
exprs: expr exprs | expr ;
expr: exprL tEQUAL expArth tENDINST  {
    symbol *tmp_sym = get_last_symbol(table);
    asm_load(0, tmp_sym->address);
    asm_store(affect_sym->address, 0);
    if (get_curr_depth(table)==-1) {
        symbol_table_pop_depth(table);
    }
}
    | expArth tENDINST {
    if (get_curr_depth(table)==-1) {
        symbol_table_pop_depth(table);
    }
}
    | type tID tENDINST {
        symbol_table_push(table, yylval.text, curr_type, curr_depth, curr_const);
    };
    | tPRINTF tLPAR tSTRING tRPAR tENDINST;   
exprL: type tID {
    affect_sym = symbol_table_push(table, yylval.text, curr_type, curr_depth, curr_const);
}
    | tID  {
    affect_sym = get_symbol_from_name(table, yylval.text);
}
type: tCONST tINT { curr_type = INT; curr_const = 1;}
    | tINT tCONST { curr_type = INT; curr_const = 1;}
    | tINT { curr_type = INT; curr_const = 0;}
expArth: tLCURL expArth tRCURL
    | expArth tMUL expArth {type op_type = asm_load_symbols_op(); asm_mul(0, 0, 1); symbol* sym = add_temporary_symbol(table, op_type); asm_store(sym->address, 0);}
    | expArth tDIV expArth {type op_type = asm_load_symbols_op(); asm_div(0, 0, 1);  symbol* sym = add_temporary_symbol(table, op_type); asm_store(sym->address, 0);}
    | expArth tPLUS expArth {type op_type = asm_load_symbols_op(); asm_add(0, 0, 1);  symbol* sym = add_temporary_symbol(table, op_type); asm_store(sym->address, 0);}
    | expArth tMINUS expArth {type op_type = asm_load_symbols_op(); asm_sou(0, 0, 1);  symbol* sym = add_temporary_symbol(table, op_type); asm_store(sym->address, 0);}
    | val;
val: tID {symbol *sym = get_symbol_from_name(table, yylval.text); symbol *temp = add_temporary_symbol_redirect(table, sym);}
    | tINTVAL {symbol *temp = add_temporary_symbol(table, INT); asm_afc(0, yylval.nb),  asm_store(temp->address, 0);};
