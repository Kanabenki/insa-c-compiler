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

%left tPLUS tMINUS
%left tMUL tDIV

%%
start:tMAIN tLPAR tRPAR tLCURL body tRCURL;
body: exprs | ;
exprs: expr exprs | expr ;
expr: exprL tENDINST | exprL tEQUAL expArth tENDINST | expArth tENDINST | tPRINTF tLPAR tSTRING tRPAR tENDINST;
exprL: type tID;
type: tCONST tINT | tINT | tINT tCONST;
expArth: tLCURL expArth tRCURL | expArth tMUL expArth | expArth tDIV expArth | expArth tPLUS expArth | expArth tMINUS expArth |val;
val: tID | tINTVAL ;