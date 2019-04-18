#pragma once

#include <stdlib.h>

typedef struct instr {
   char* ope;
   int val0;
   int val1;
   int val2;
} instr;

typedef struct instr_table {
    instr *tab;
    size_t length;
    int position;
} instr_table;

void instr_add(instr_table *table, char* ope, int val0, int val1, int val2);
void instr_add_2(instr_table *table, char* ope, int val0, int val1);
void instr_add_jmp(instr_table *table, char* ope, int val0);
int instr_table_init(instr_table **table, size_t size);
int get_last_position(instr_table *table);
