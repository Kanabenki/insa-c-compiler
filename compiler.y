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


%%
start:tMAIN tLPAR tRPAR tLCURL body tRCURL;
body: exprs | ;
exprs: exprs | expr ;
expr: tINT tID tEQUAL tINTVAL tENDINST; 