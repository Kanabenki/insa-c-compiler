%{
    #include "y.tab.h"
%}
%%
"main" {return tMAIN;}
"{" {return tLCURL;}
"}" {return tRCURL;}
"("  {return tLPAR;}
")" {return tRPAR;}
"const" {return tCONST;}
"int" {return tINT;}
"printf" {return tPRINTF;}
"," {return tCOMMA;}
"+" {return tPLUS;}
"-" {return tMINUS;}
"*" {return tMUL;}
"/" {return tDIV;}
"=" {return tEQUAL;}
";" {return tENDINST;}
[0-9]+(\^[0-9]+)? {return tINTVAL;}
\"[A-Za-z0-9_ ]*\" {return tSTRING;}
[A-Za-z][A-Za-z0-9_]* {return tID;}

