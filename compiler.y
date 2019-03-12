%{
    int yylex();
    void yyerror(char*);
%}

%token tMAIN 
%token tLCURL
%token tRCURL
%token tLPAR
%token tRPAR
%token tCONST
%token tINT
%token tID
%token tCOMMA
%token tPLUS
%token tMINUS
%token tMUL
%token tDIV
%token tEQUAL
%token tENDINST
%token tINTVAL
%token tPRINTF
%token tSTRING


%%
start:tMAIN tLPAR tRPAR tLCURL body tRCURL;
body: exprs | ;
exprs: expr exprs | expr ;
expr: exprL tENDINST | exprL tEQUAL expArth tENDINST | expArth tENDINST | tPRINTF tLPAR tSTRING tRPAR tENDINST;
exprL: type tID | tID;
type: tCONST tINT | tINT | tINT tCONST;
expArth: tLCURL expArth tRCURL | expArth oper expArth | val;
oper: tMUL | tDIV | tPLUS | tMINUS;
val: tID | tINTVAL;