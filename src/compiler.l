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
"==" {return tBOOLEQUAL;}
"!=" {return tINEQUAL;}
">=" {return tSUPE;}
"<=" {return tINFE;}
">" {return tSUP;}
"<" {return tINF;}
"," {return tCOMMA;}
"+" {return tPLUS;}
"-" {return tMINUS;}
"*" {return tMUL;}
"/" {return tDIV;}
"=" {return tEQUAL;}
";" {return tENDINST;}
"if" {return tIF;}
"else" {return tELSE;}
"while" {return tWHILE;}
"&&" {return tAND;}
"||" {return tOR;}
"&" {return tANDBIN;}
"|" {return tORBIN;}
"^" {return tXORBIN;}
\/\/[A-Za-z0-9_ ]* {;}
[0-9]+(\^[0-9]+)? {yylval.nb = atoi(yytext); return tINTVAL;}
\"[A-Za-z0-9_ ]*\" {yylval.text = strdup(yytext); return tSTRING;}
[A-Za-z][A-Za-z0-9_]* {yylval.text = strdup(yytext); return tID;}

