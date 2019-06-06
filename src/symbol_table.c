#include <stdio.h> 
#include <stdlib.h>
#include <string.h>

#include "utils.h"
#include "symbol_table.h"

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

int symbol_table_init(symbol_table **table, size_t size, int start_addr) {
    if ((*table = malloc(sizeof(symbol_table))) == NULL) {
        return -1;
    }
    if (((*table)->tab = malloc(size * sizeof(symbol))) == NULL) {
        return -1;
    }
    
    (*table)->length = size;
    (*table)->position = 0;
    (*table)->start_addr = start_addr;
    return 0;
}

void symbol_table_pop(symbol_table *table) {
    if (table->position == 0) {
        return;
    }
    free(table->tab[--table->position].name);
}

void symbol_table_pop_depth(symbol_table *table, int depth) {
    while (table->tab[table->position-1].depth == depth || table->tab[table->position-1].depth == -1) {
        symbol_table_pop(table);
    }
}

void symbol_table_pop_temp(symbol_table *table) {
    while (table->tab[table->position-1].depth == -1) {
        symbol_table_pop(table);
    }
}

symbol* symbol_table_push(symbol_table *table, char *name, type type, int depth, char is_const) {
    int pos = table->position;
    //while(!table->tab[pos].alloc) {
    //    pos--;
    //}
    symbol *sym = &(table->tab[table->position++]);
    if (pos != 0) {
        int prev_addr = (table->tab[pos-1]).address;
        int prev_type = (table->tab[pos-1]).type;
        sym->address = prev_addr + get_size(prev_type);
    } else  {
        sym->address = table->start_addr;
    }

    sym->name = strdup(name);
    sym->type = type;
    sym->depth = depth;
    sym->is_const = is_const;
    sym->alloc = 1;
    return sym;
}

symbol* get_symbol_from_name(symbol_table *table, char* name, int depth) {
    symbol *sym = NULL;
    for (int i = 0; i < table->position; i++) {
        symbol *s = &table->tab[i];
        if (0 <= s->depth && s->depth <= depth && s->name != NULL && strcmp(name, s->name) == 0) {
            sym = s;
            break;
        }
    }
    return sym;
}

void print_table(symbol_table *table) {
    printf("[DEBUG] Symbol table content\n");
    for (int i = 0; i < table->position; i++) {
        symbol s = table->tab[i];
        printf("[DEBUG] Index: %d Address: %d Name: %s Type: %d Depth: %d Const: %d Alloc: %d\n",
            i, s.address, s.name, s.type, s.depth, s.is_const, s.alloc);
    }
}

symbol* add_temporary_symbol(symbol_table *table, type type) {
    int pos = table->position;

    symbol *sym = &(table->tab[table->position++]);
    if (pos != 0) {
        int prev_addr = (table->tab[pos-1]).address;
        int prev_type = (table->tab[pos-1]).type;
        sym->address = prev_addr + get_size(prev_type);
    } else  {
        sym->address = table->start_addr;
    }
    sym->depth = -1;
    sym->alloc = 1;
    sym->name = NULL;
    return sym;
}

symbol* add_temporary_symbol_redirect(symbol_table *table, symbol *redir_symbol) {
    symbol *sym = add_temporary_symbol(table, redir_symbol->type);
    sym->alloc = 0;
    sym->address = redir_symbol->address;
    return sym;
}

int get_curr_depth(symbol_table *table) {
    return table->tab[table->position-1].depth;
}

symbol* get_last_symbol(symbol_table* table) {
    return &(table->tab[table->position-1]);
}