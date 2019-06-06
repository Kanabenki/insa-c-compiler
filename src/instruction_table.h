#pragma once

#include <stdlib.h>

#include "utils.h"

typedef enum operation {
    NOP   = 0x0,
    ADD   = 0x1,
    MUL   = 0x2,
    SOU   = 0x3,
    DIV   = 0x4,
    COP   = 0x5,
    AFC   = 0x6,
    LOAD  = 0x7,
    STORE = 0x8,
    EQU   = 0x9,
    NEQU  = 0xA,
    INF   = 0xB,
    INFE  = 0xC,
    SUP   = 0xD,
    SUPE  = 0xE,
    JMP   = 0xF,
    JMPC  = 0x10,
    JR    = 0x11,
    JRC   = 0x12,
    AND   = 0x13,
    OR    = 0x14,
    XOR   = 0x15,
    NOT   = 0x16,
    
} operation;

extern const char* OPERATIONS_STR[];

typedef struct instr {
   operation ope;
   u8 val0;
   u8 val1;
   u8 val2;
} instr;

typedef struct instr_rewrite {
   instr *instruction;
   size_t position;
} instr_rewrite;

typedef struct instr_table {
    instr *tab;
    size_t length;
    size_t position;
    instr_rewrite *tab_rewrite;
    size_t position_rewrite;
} instr_table;

instr *instr_add(instr_table *table, operation ope, u8 val0, u8 val1, u8 val2);
instr_rewrite *instr_add_rewrite(instr_table *table, operation ope, u8 val0, u8 val1, u8 val2);
instr_rewrite *instr_pop_rewrite(instr_table *table);
int instr_table_init(instr_table **table, size_t size, size_t rewrite_size);
int instr_table_write_bin(instr_table *table, FILE *file);
int instr_table_write_asm(instr_table *table, FILE *file);