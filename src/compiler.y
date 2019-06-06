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

    void asm_jmp(u16 addr) {
        instr_add(tab_instr, JMP, HIGHB(addr), LOWB(addr), 0);
    }

    instr *asm_jmpc(u16 addr, u8 reg) {
        return instr_add(tab_instr, JMPC, HIGHB(addr), LOWB(addr), 0);
    }

    type asm_load_symbols_op() {
        type type = get_last_symbol(table)->type;
        asm_load(0, get_last_symbol(table)->address);
        printf("POP1");
        print_table(table);
        symbol_table_pop(table);
        print_table(table);
        asm_load(1, get_last_symbol(table)->address);
        printf("POP2");
        print_table(table);
        symbol_table_pop(table);
        print_table(table);
        return type;
    }

    void calc_exp_arth(operation oper, u8 reg_store, u8 reg_a, u8 reg_b) {
        type op_type = asm_load_symbols_op(); 
        instr_add(tab_instr, oper, reg_store, reg_a, reg_b);
        symbol* sym = add_temporary_symbol(table, op_type);
        asm_store(sym->address, 0);
    }

    void asm_log_or(u8 reg_store, u8 reg_a, u8 reg_b) { //TODO short circuit eval and fix
        
        calc_exp_arth(OR, reg_store, reg_a, reg_b);
        asm_afc(reg_a, 0);
        calc_exp_arth(NEQU, reg_store, reg_store, reg_a);
    }

    void asm_log_and(u8 reg_store, u8 reg_a, u8 reg_b) { //TODO short circuit eval and fix
        calc_exp_arth(AND, reg_store, reg_a, reg_b);
        asm_afc(reg_a, 0);
        calc_exp_arth(NEQU, reg_store, reg_store, reg_a);
    }

    void rewrite_prev_jump() {
        instr * i = instr_pop_rewrite(tab_instr)->instruction;
        u16 pos = tab_instr->position;
        i->val0 = HIGHB(pos);
        i->val1 = LOWB(pos);
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
%token tELSE
%token tWHILE
%token tAND
%token tOR
%token tXORBIN
%token tANDBIN
%token tORBIN

%left tBOOLEQUAL tINEQUAL
%left tSUPE tSUP tINF tINFE 
%left tPLUS tMINUS
%left tMUL tDIV
%left tANDBIN
%left tXORBIN
%left tORBIN
%left tAND
%left tOR

%%

init: {
        asm_file = fopen("out.asm", "w");
        bin_file = fopen("out.bin", "w");
        if (instr_table_init(&tab_instr, 1024, 256) != 0) {
            printf("[INSTR] Error initializing instruction table\n");
            exit(1);
        }
        if (symbol_table_init(&table, 1024, 0x100) != 0) {
            printf("[SYMBOL] Error initializing symbol table\n");
            exit(1);
        }
    } start;

start: globExprs tMAIN tLPAR tRPAR
    body globExprs {
    printf("Compilation succedeed\n");
    print_table(table);

    instr_table_write_bin(tab_instr, bin_file);
    instr_table_write_asm(tab_instr, asm_file);


};
body: {curr_depth++;} tLCURL exprs tRCURL {printf("Current DEPTH before pop: %d\n", curr_depth);print_table(table); symbol_table_pop_depth(table, curr_depth); print_table(table); curr_depth--;};
globExprs: exprL tENDINST globExprs | ;
exprs: expr exprs | body exprs | ;
expr: exprL tEQUAL expArth tENDINST  {
    symbol *tmp_sym = get_last_symbol(table);
    asm_load(0, tmp_sym->address);
    asm_store(affect_sym->address, 0);
    symbol_table_pop(table);
}
    | expArth tENDINST {
    symbol_table_pop(table);
}
    | type tID tENDINST {
        symbol_table_push(table, yylval.text, curr_type, curr_depth, curr_const);
    }
    | tPRINTF tLPAR tSTRING tRPAR tENDINST
    | ifExprs
    | tWHILE tLPAR expArth tRPAR { //FIXME wrong jmp address
        instr_add_rewrite(tab_instr, JMPC, 0, 0, 0);
    } body {
        instr_rewrite *ire = instr_pop_rewrite(tab_instr);
        asm_jmp(ire->position);
        instr *i = ire->instruction;
        u16 pos = tab_instr->position;
        i->val0 = HIGHB(pos);
        i->val1 = LOWB(pos);
    } 
//    | tFOR tLPAR trRPAR body ;
ifExprs: ifExpr | ifExpr tELSE ifExprs | ifExpr tELSE body;
ifExpr: tIF tLPAR expArth tRPAR {
        instr_add_rewrite(tab_instr, JMPC, 0, 0, 0);
    }
     body {
        rewrite_prev_jump();
    }
exprL: type tID {
    if (get_symbol_from_name(table, yylval.text, curr_depth) == NULL) {
        affect_sym = symbol_table_push(table, yylval.text, curr_type, curr_depth, curr_const);
    } else {
        printf("[ERROR] Redeclaration of existing symbol %s\n", yylval.text);
        exit(1);
    }
    
}
    | tID  {
    affect_sym = get_symbol_from_name(table, yylval.text, curr_depth);
    if (affect_sym == NULL) {
        printf("[ERROR] Non existing symbol %s\n", yylval.text);
        exit(1);
    }
};

type: tCONST tINT { curr_type = INT; curr_const = 1;}
    | tINT tCONST { curr_type = INT; curr_const = 1;}
    | tINT { curr_type = INT; curr_const = 0;};

expArth: tLPAR expArth tRPAR
    | expArth tMUL expArth {calc_exp_arth(MUL, 0, 0, 1);}
    | expArth tDIV expArth {calc_exp_arth(DIV, 0, 0, 1);}
    | expArth tPLUS expArth {calc_exp_arth(ADD, 0, 0, 1);}
    | expArth tMINUS expArth {calc_exp_arth(SOU, 0, 0, 1);}
    | expArth tBOOLEQUAL expArth {calc_exp_arth(EQU, 0, 0, 1);}
    | expArth tINEQUAL expArth {calc_exp_arth(NEQU, 0, 0, 1);}
    | expArth tSUPE expArth {calc_exp_arth(SUPE, 0, 0, 1);;}
    | expArth tSUP expArth {calc_exp_arth(SUP, 0, 0, 1);}
    | expArth tINFE expArth {calc_exp_arth(INFE, 0, 0, 1);}
    | expArth tINF expArth {calc_exp_arth(INF, 0, 0, 1);}
    | expArth tANDBIN expArth {calc_exp_arth(AND, 0, 0, 1);}
    | expArth tXORBIN expArth {calc_exp_arth(XOR, 0, 0, 1);}
    | expArth tORBIN expArth {calc_exp_arth(OR, 0, 0, 1);}
    | expArth tAND expArth {asm_log_or(0, 0, 1);}
    | expArth tOR expArth {asm_log_and(0, 0, 1);}
    | val;

val: tID {
    symbol *sym = get_symbol_from_name(table, yylval.text, curr_depth);
    
    if (sym == NULL) {
        printf("[ERROR] Non existing symbol %s\n", yylval.text);
        exit(1);
    }
    add_temporary_symbol_redirect(table, sym);
 }
    | tINTVAL {
        symbol *temp = add_temporary_symbol(table, INT);
        asm_afc(0, yylval.nb);
        asm_store(temp->address, 0);
        };


