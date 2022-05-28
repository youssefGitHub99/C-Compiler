%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#include "number.h" // i can't understand

extern FILE *yyin;
extern int yylex(void);
extern int yyparse();

void yyerror(const char *str);

extern char* yytext;
extern int scope ;
extern int nline ;
extern int COMMENT ;

%}

%union {
    struct number num;
}

%start program 

%token <num> INTEGER
%token <num> RATIONAL

%token DECL ENDDECL DEFINE RET 

%token MAIN

%token IDENTIFIER CONST 
%token PRINT STRING
%token RELOP AND OR BOOLTRUE BOOLFALSE
%token IF THEN ELSE ENDIF
%token DO WHILE ENDWHILE ENDDO
%token FOR ENDFOR
%token SWITCH CASE ENDSWITCH DEFAULT BREAK

%token END

%right '='
%left RELOP
%left AND OR
 
%left '+' '-'
%left '*' '/'
%left '^'
%left '(' ')'


//%right '^' 

%type<num> expr

%%

program: declarations mainBlock {printf("\tStart the program\n")};

declarations : 
    DECL declList ENDDECL           
	| DECL ENDDECL 
    ;

declList: 
    declare declList
	| declare 
    ;

declare: 
    expr_stmt
    | func_def
    ;

func_def:
    DEFINE IDENTIFIER '(' PARAM ')' '{' func_body '}' { printf("Function Def\n"); }
    ;

func_call:
    IDENTIFIER '(' PARAM ')' ';' { printf("Function call\n"); }
    ;

PARAM:
    PARAM ',' expr
    | expr
    |
    ; 

func_body:
    Slist RET expr ';'
    ;


mainBlock: MAIN '(' ')' '{' { printf("main block\n"); } Slist '}' ;

Slist: Slist stmt | stmt;

stmt:
    expr_stmt 
    | print_stmt { printf("PRINT statement\n"); }
    | if_stmt { printf("IF statement\n"); }
    | while_stmt { printf("WHILE statement\n"); }
    | do_stmt { printf("DO WHILE statement\n"); }
    | for_loop { printf("FOR LOOP\n"); }
    | switch_stmt { printf("SWITCH statement\n"); }
    | func_call 
    | END { printf("Main block ends\n"); }
    ;

expr_stmt:
    IDENTIFIER '=' expr ';' { printf("Variable Assignement statement\n"); }
    | CONST IDENTIFIER '=' expr ';' { printf("Constant Assignement statement\n"); }
    ;

print_stmt:
    PRINT '(' expr ')' ';'
    | PRINT '(' STRING ')' ';'
    ;

expr:
    INTEGER { $$ = $1; }
    |  RATIONAL { $$ = $1; }
    |  IDENTIFIER
    |  expr '+' expr { $$ = ADD($1, $3); printf("+"); }
    |  expr '-' expr { $$ = SUBTRACT($1, $3); printf("-");}
    |  expr '*' expr { $$ = MULTIPLY($1, $3); printf("*");}
    |  expr '/' expr { $$ = DIVIDE($1, $3); printf("/");}
    |  expr '^' expr { $$ = POW($1, $3); printf("^");}
    //|  expr '&&' expr { $$ = POW($1, $3); printf("^");}
    //|  expr '==' expr { $$ = POW($1, $3); printf("^");}
    //|  expr '>=' expr { $$ = POW($1, $3); printf("^");}
    //|  expr '<=' expr { $$ = POW($1, $3); printf("^");}
    //|  expr '>' expr { $$ = POW($1, $3); printf("^");}
    //|  expr '<' expr { $$ = POW($1, $3); printf("^");}
    |  '(' expr ')'  { $$ = $2; }
    ;

condition_stmt: 
    IDENTIFIER RELOP IDENTIFIER {printf("/t%s/n",$2);}
    | IDENTIFIER RELOP INTEGER {printf("/t%s/n",$2);}
    | IDENTIFIER RELOP RATIONAL {printf("/t%s/n",$2);}
    | INTEGER RELOP IDENTIFIER {printf("/t%s/n",$2);}
    | RATIONAL RELOP IDENTIFIER {printf("/t%s/n",$2);}
    | condition_stmt AND condition_stmt 
    | condition_stmt OR condition_stmt 
    | BOOLTRUE {printf("/t%s/n",$1);}
    | BOOLFALSE {printf("/t%s/n",$1);}
    ;

if_stmt: 
    IF condition_stmt THEN Slist ELSE Slist ENDIF 
    | IF condition_stmt THEN Slist ENDIF
    ;

while_stmt: 
    WHILE condition_stmt THEN Slist ENDWHILE
    ;

do_stmt: 
    DO Slist WHILE condition_stmt ENDDO
    ;

for_loop: 
    FOR '(' for_stmt1 ';' condition_stmt ';' IDENTIFIER '='  expr  ')' DO Slist ENDFOR
    ;

for_stmt1:
    expr
    | IDENTIFIER '=' expr
    |
    ;
    
switch_stmt: 
    SWITCH '(' IDENTIFIER ')' DO cases ENDSWITCH
    ;

cases : 
    case cases
    | default 
    ;

case :
    CASE INTEGER ':' Slist BREAK    
    
default:
    DEFAULT ':' Slist  BREAK

%%

void yyerror(const char *str)
{
	fprintf(stderr,"error: %s\n",str);
}

int main()
{
	FILE * pt = fopen("tests/test2.txt", "r" );
    if(!pt)
    {
        printf("Non existant file");
        return -1;
    }
    yyin = pt;
    do
    {
        yyparse();
    }   while (!feof(yyin));
    return 0;
}