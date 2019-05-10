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
    INF   = 0xA,
    INFE  = 0xB,
    SUP   = 0xC,
    SUPE  = 0xD,
    JMP   = 0xE,
    JMPC  = 0xF,
    NEQU  = 0x10
} operation;

extern const char* OPERATIONS_STR[];

typedef struct instr {
   operation ope;
   u8 val0;
   u8 val1;
   u8 val2;
} instr;

typedef struct instr_table {
    instr *tab;
    size_t length;
    int position;
} instr_table;

void instr_add(instr_table *table, operation ope, u8 val0, u8 val1, u8 val2);
int instr_table_init(instr_table **table, size_t size);
int instr_table_write_bin(instr_table *table, FILE *file);
int instr_table_write_asm(instr_table *table, FILE *file);