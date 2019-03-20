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

void symbol_table_init(symbol_table *table, size_t size) {
    table = malloc(sizeof(symbol_table));
    table->tab = malloc(size * sizeof(symbol));
    table->length = size;
    table->position = 0;

    (table->tab[0]).address = 4000;
}

void symbol_table_pop(symbol_table *table) {
    table->position--;
}

void symbol_table_push(symbol_table *table, char *name, type type, int depth) {
    int prev_addr = table->tab[table->position].address;
    symbol *sym = &table->tab[++table->position];
    sym->address = prev_addr + get_size(type);
    sym->type = type;
    sym->depth = depth;
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