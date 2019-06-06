#include <stdio.h> 
#include <stdlib.h>
#include <string.h>

#include "instruction_table.h"

const char* OPERATIONS_STR[] = {
    "NOP",
    "ADD",
    "MUL",
    "SOU", 
    "DIV", 
    "COP", 
    "AFC", 
    "LOAD",
    "STORE",
    "EQU",
    "NEQU",
    "INF",
    "INFE",
    "SUP",
    "SUPE",
    "JMP",
    "JMPC",
    "JR",
    "JRC",
    "AND",
    "OR",
    "XOR",
    "NOT",
};

int instr_table_init(instr_table **table, size_t size, size_t rewrite_size) {
    if ((*table = malloc(sizeof(instr_table))) == NULL) {
        return -1;
    }
    if (((*table)->tab = malloc(size * sizeof(instr))) == NULL) {
        return -1;
    }
    if (((*table)->tab_rewrite = malloc(rewrite_size * sizeof(instr))) == NULL) {
        return -1;
    }
    
    (*table)->length = size;
    (*table)->position = 0;
    return 0;
}

instr *instr_add(instr_table *table, operation ope, u8 val0, u8 val1, u8 val2) {
    instr *instr = &(table->tab[table->position++]);
    instr->ope = ope;
    instr->val0 = val0;
    instr->val1 = val1;
    instr->val2 = val2;

    return instr;
}

instr_rewrite *instr_add_rewrite(instr_table *table, operation ope, u8 val0, u8 val1, u8 val2) {
    instr* i = instr_add(table, ope, val0, val1, val2);
    instr_rewrite * i_re = &table->tab_rewrite[table->position_rewrite++];
    i_re->instruction = i; 
    i_re->position = table->position-1;
    return i_re;
}

instr_rewrite *instr_pop_rewrite(instr_table *table) {
    return &table->tab_rewrite[--table->position_rewrite];
}

typedef struct instr_bin {
   u8 ope;
   u8 val0;
   u8 val1;
   u8 val2;
} instr_bin;


int instr_table_write_bin(instr_table *table, FILE *file) {
    for (int i = 0; i < table->position; i++) {
        instr *instr = &table->tab[i];
        instr_bin ibin = {(u8) instr->ope, instr->val0, instr->val1, instr->val2};
        if (fwrite(&ibin, sizeof(ibin), 1, file) == 0)
            return -1;
    }
    return 0;
}

int instr_table_write_asm(instr_table *table, FILE *file) {
    for (int i = 0; i < table->position; i++) {
        instr *instr = &table->tab[i];
        if (fprintf(file, "%s %x %x %x\n", OPERATIONS_STR[instr->ope], instr->val0, instr->val1, instr->val2) < 0)
            return -1;
    }
    return 0;
}

