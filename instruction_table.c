#include <stdio.h> 
#include <stdlib.h>
#include <string.h>

#include "instruction_table.h"

int instr_table_init(instr_table **table, size_t size){
    if ((*table = malloc(size * sizeof(instr_table))) == NULL) {
        return -1;
    }
    if (((*table)->tab = malloc(size * sizeof(instr))) == NULL) {
        return -1;
    }
    
    (*table)->length = size;
    (*table)->position = 0;

    ((*table)->tab[0]).ope = "BEGIN";
    return 0;
}

void instr_add(instr_table *table, char* ope, int val0, int val1, int val2){

    instr *instr = &(table->tab[++table->position]);
    instr->ope = ope;
    instr->val0 = val0;
    instr->val1 = val1;
    instr->val2 = val2;

}
void instr_add_2(instr_table *table, char* ope, int val0, int val1){
    
    instr *instr = &(table->tab[++table->position]);
    instr->ope = ope;
    instr->val0 = val0;
    instr->val1 = val1;
    instr->val2 = NULL;
}
void instr_add_jmp(instr_table *table, char* ope, int val0){
    instr *instr = &(table->tab[++table->position]);
    instr->ope = ope;
    instr->val0 = val0;
    instr->val1 = NULL;
    instr->val2 = NULL;
}

int get_last_position(instr_table *table){
    return table->position;
}


