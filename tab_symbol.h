#pragma once

#include <stdlib.h>

typedef enum type {
    INT
} type;

typedef struct symbol {
    int address;
    char* name;
    type type;
    int depth;
    char is_const;
} symbol;

typedef struct symbol_table {
    symbol *tab;
    size_t length;
    int position;
} symbol_table;



int get_size(type type);
void print_table(symbol_table *table);

int symbol_table_init(symbol_table **table, size_t size);
void symbol_table_pop(symbol_table *table);
void symbol_table_pop_depth(symbol_table *table);
void symbol_table_push(symbol_table *table, char *name, type type, int depth, char is_const);
int add_temporary_symbol(symbol_table *table, type type);
symbol* get_symbol_from_name(symbol_table *table, char* name);
int get_curr_depth(symbol_table *table);
