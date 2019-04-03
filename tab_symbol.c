#include <stdio.h> 
#include <stdlib.h>
#include <string.h>

#include "tab_symbol.h"

//function
//TODO error handling

int get_size(type type) {
    int size;
    switch (type)
    {
        case INT:
            size = sizeof(int);
            break;
        default:
            break;
    }

    return size;
}

int symbol_table_init(symbol_table **table, size_t size) {
    if ((*table = malloc(size * sizeof(symbol_table))) == NULL) {
        return -1;
    }
    if (((*table)->tab = malloc(size * sizeof(symbol))) == NULL) {
        return -1;
    }
    
    (*table)->length = size;
    (*table)->position = 0;

    ((*table)->tab[0]).address = 4000;
    ((*table)->tab[0]).depth = -2;
    return 0;
}

void symbol_table_pop(symbol_table *table) {
    if (table->position == 0) {
        return;
    }
    free(table->tab[table->position--].name);
}

void symbol_table_pop_depth(symbol_table *table) {
    int depth = table->tab[table->position].depth;
    while (table->tab[table->position].depth == depth) {
        symbol_table_pop(table);
    }
}

void symbol_table_push(symbol_table *table, char *name, type type, int depth, char is_const) {
    int prev_addr = (table->tab[table->position]).address;
    symbol *sym = &(table->tab[++table->position]);
    sym->address = prev_addr + get_size(type);
    sym->name = strdup(name);
    sym->type = type;
    sym->depth = depth;
    sym->is_const = is_const;
}

symbol* get_symbol_from_name(symbol_table *table, char* name) {
    symbol *sym = NULL;
    for (int i = 1; i <= table->position; i++) {
        if (strcmp(name, table->tab[i].name)) {
            sym = &table->tab[i];
            break;
        }
    }
    return sym;
}

void print_table(symbol_table *table) {
    printf("[DEBUG] Symbol table content\n");
    for (int i = 1; i <= table->position; i++) {
        symbol s = table->tab[i];
        printf("[DEBUG] Index: %d Address: %d Name: %s Type: %d Depth: %d Const: %d\n",
            i, s.address, s.name, s.type, s.depth, s.is_const);
    }
}

int add_temporary_symbol(symbol_table *table, type type) {

    int prev_addr = (table->tab[table->position]).address;
    symbol *sym = &(table->tab[++table->position]);
    sym->address = prev_addr + get_size(type);
    sym->depth = -1;
    return sym->address;

}

int get_curr_depth(symbol_table *table) {
    return table->tab[table->position].depth;
}