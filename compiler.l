%%
"main" {printf("tMAIN");}
"{" {printf("tLCURL");}
"}" {printf("tRCURL");}
"(" {printf("tLPAR");}
")" {printf("tRPAR");}
"const" {printf("tCONST");}
"int" {printf("tINT");}
[A-Za-z][A-Za-z0-9_]* {printf("tID");}
"," {printf("tCOMMA");}
"+" {printf("tPLUS");}
"-" {printf("tMINUS");}
"*" {printf("tMUL");}
"/" {printf("tDIV");}
"=" {printf("tEQUAL");}
";" {printf("tENDINST");}
[0-9]+(\^[0-9]+)? {printf("tINTVAL");}
[ \t\n]+ {printf(".");}
"printf" {printf("tPRINTF");}
