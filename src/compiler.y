%{
    #include <stdio.h>
    #include <stdlib.h>

    #include "symbol_table.h"
    #include "instruction_table.h"

    int yylex();
    void yyerror(char*);

    symbol_table *table;
    instr_table *tab_instr;
    symbol *affect_sym;
    type curr_type = INT;
    char curr_const = 0;
    int curr_depth = 0;
    FILE *asm_file;
    FILE *bin_file;

    void asm_add(u8 reg_store, u8 reg_a, u8 reg_b) {
        instr_add(tab_instr, ADD, reg_store, reg_a, reg_b);
    }

    void asm_mul(u8 reg_store, u8 reg_a, u8 reg_b) {
        instr_add(tab_instr, MUL, reg_store, reg_a, reg_b);
    }

    void asm_sou(u8 reg_store, u8 reg_a, u8 reg_b) {
        instr_add(tab_instr, SOU, reg_store, reg_a, reg_b);
    }

    void asm_div(u8 reg_store, u8 reg_a, u8 reg_b) {
        instr_add(tab_instr, DIV, reg_store, reg_a, reg_b);
    }

    void asm_cop(u8 reg_store, u8 reg_val) {
        instr_add(tab_instr, COP, reg_store, reg_val, 0);
    }

    void asm_afc(u8 reg, u16 val) {
        instr_add(tab_instr, AFC, reg, HIGHB(val), LOWB(val));
    }

    void asm_load(u8 reg, u16 addr) {
        instr_add(tab_instr, LOAD, reg, HIGHB(addr), LOWB(addr));
    }

    void asm_store(u16 addr, u8 reg) {
        instr_add(tab_instr, STORE, HIGHB(addr), LOWB(addr), reg);
    }

    void asm_equ(u8 reg_store, u8 reg_a, u8 reg_b) {
        instr_add(tab_instr, EQU, reg_store, reg_a, reg_b);
    }

    void asm_nequ(u8 reg_store, u8 reg_a, u8 reg_b) {
        instr_add(tab_instr, NEQU, reg_store, reg_a, reg_b);
    }

    void asm_inf(u8 reg_store, u8 reg_a, u8 reg_b) {
        instr_add(tab_instr, INF, reg_store, reg_a, reg_b);
    }

    void asm_infe(u8 reg_store, u8 reg_a, u8 reg_b) {
        instr_add(tab_instr, INFE, reg_store, reg_a, reg_b);
    }

    void asm_sup(u8 reg_store, u8 reg_a, u8 reg_b) {
        instr_add(tab_instr, SUP, reg_store, reg_a, reg_b);
    }

    void asm_supe(u8 reg_store, u8 reg_a, u8 reg_b) {
        instr_add(tab_instr, SUPE, reg_store, reg_a, reg_b);
    }

    void asm_jmp(u16 addr) {
        instr_add(tab_instr, JMP, HIGHB(addr), LOWB(addr), 0);
    }

    void asm_jmpc(u16 addr, u8 reg) {
        instr_add(tab_instr, JMPC, HIGHB(addr), LOWB(addr), 0);
    }

    type asm_load_symbols_op() {
        type type = get_last_symbol(table)->type;
        asm_load(0, get_last_symbol(table)->address);
        symbol_table_pop(table);
        asm_load(1, get_last_symbol(table)->address);
        symbol_table_pop(table);
        return type;
    }

    void calc_exp_arth(void (*asm_fn)(u8, u8, u8), u8 reg_store, u8 reg_a, u8 reg_b) {
        type op_type = asm_load_symbols_op(); 
        asm_fn(reg_store, reg_a, reg_b);
        symbol* sym = add_temporary_symbol(table, op_type);
        asm_store(sym->address, 0);
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
%token tBOOLEQUAL
%token tINEQUAL
%token tSUPE
%token tINFE
%token tSUP
%token tINF
%token tIF
%token tWHILE
%token tAND
%token tOR

%left tBOOLEQUAL tINEQUAL
%left tSUPE tSUP tINF tINFE 
%left tPLUS tMINUS
%left tMUL tDIV

%%

init: {
        asm_file = fopen("out.asm", "w");
        bin_file = fopen("out.bin", "w");
        if (instr_table_init(&tab_instr, 1024) != 0) {
            printf("[INSTR] Error initializing instruction table\n");
            exit(1);
        }
        if (symbol_table_init(&table, 1024) != 0) {
            printf("[SYMBOL] Error initializing symbol table\n");
            exit(1);
        }
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

    instr_table_write_bin(tab_instr, bin_file);
    instr_table_write_asm(tab_instr, asm_file);
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
    }
    | tPRINTF tLPAR tSTRING tRPAR tENDINST
    | tIF tLPAR expArth tRPAR {
        //asm_jmpc(0xFF,0xF); //TODO fix
        //get_last_position(instr_table);
    }
     tLCURL body tRCURL 
    | tWHILE tLPAR expArth tRPAR tLCURL body tRCURL ;
exprL: type tID {
    affect_sym = symbol_table_push(table, yylval.text, curr_type, curr_depth, curr_const);
}
    | tID  {
    affect_sym = get_symbol_from_name(table, yylval.text);
};

type: tCONST tINT { curr_type = INT; curr_const = 1;}
    | tINT tCONST { curr_type = INT; curr_const = 1;}
    | tINT { curr_type = INT; curr_const = 0;};

expArth: tLCURL expArth tRCURL
    | expArth tMUL expArth {calc_exp_arth(&asm_mul, 0, 0, 1);}
    | expArth tDIV expArth {calc_exp_arth(&asm_div, 0, 0, 1);}
    | expArth tPLUS expArth {calc_exp_arth(&asm_add, 0, 0, 1);}
    | expArth tMINUS expArth {calc_exp_arth(&asm_sou, 0, 0, 1);}
    | expArth tBOOLEQUAL expArth {calc_exp_arth(&asm_equ, 0, 0, 1);}
    | expArth tINEQUAL expArth {calc_exp_arth(&asm_nequ, 0, 0, 1);}
    | expArth tSUPE expArth {calc_exp_arth(&asm_supe, 0, 0, 1);;}
    | expArth tSUP expArth {calc_exp_arth(&asm_sup, 0, 0, 1);}
    | expArth tINFE expArth {calc_exp_arth(&asm_infe, 0, 0, 1);}
    | expArth tINF expArth {calc_exp_arth(&asm_inf, 0, 0, 1);}
    | val;

val: tID {symbol *sym = get_symbol_from_name(table, yylval.text); symbol *temp = add_temporary_symbol_redirect(table, sym);}
    | tINTVAL {symbol *temp = add_temporary_symbol(table, INT); asm_afc(0, yylval.nb),  asm_store(temp->address, 0);};


