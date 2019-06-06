#pragma once

#include <stdlib.h>

#include "utils.h"

typedef enum type {
    INT
} type;

typedef struct symbol {
    u16 address;
    int alloc;
    char* name;
    type type;
    int depth;
    char is_const;
} symbol;

typedef struct symbol_table {
    symbol *tab;
    size_t length;
    int position;
    u16 max_address;
    int start_addr;
} symbol_table;



int get_size(type type);
void print_table(symbol_table *table);

int symbol_table_init(symbol_table **table, size_t size, int start_addr);
void symbol_table_pop(symbol_table *table);
void symbol_table_pop_depth(symbol_table *table, int depth);
void symbol_table_pop_temp(symbol_table *table);
symbol* symbol_table_push(symbol_table *table, char *name, type type, int depth, char is_const);
symbol* add_temporary_symbol(symbol_table *table, type type);
symbol* add_temporary_symbol_redirect(symbol_table *table, symbol *redir_symbol);
symbol* get_symbol_from_name(symbol_table *table, char* name, int depth);
int get_curr_depth(symbol_table *table);
symbol* get_last_symbol(symbol_table* table);
