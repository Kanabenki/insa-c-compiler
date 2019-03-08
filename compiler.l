%%
"+" {printf("tPLUS");}
"-" {printf("tMINUS");}
"*" {printf("tMUL");}
"/" {printf("tDIV");}
"=" {printf("tEQUAL");}
";" {printf("tENDINST");}
[0-9]+(\^[0-9]+)? {printf("tINTVAL");}
[ \t\n]+ {printf(".");}
