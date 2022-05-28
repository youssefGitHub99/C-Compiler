%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "number.h"
    #include "sym.h"
    extern char* yytext;
    extern FILE *yyin;
    extern int yylex(void);
    extern int yyparse(); 
    void yyerror(const char *str);
%}

/*%union {
   int ival; 
   char * sval; //String value
   float fval; 
}*/

%union {
    struct number num;
    char* lexeme;
}

%start program 

%token <num> INTEGER
%token <num> RATIONAL
%token TYPE_INT TYPE_FLT TYPE_STR TYPE_CHR TYPE_BOOL TYPE_CONST
%token DECL ENDDECL DEFINE RET 
%token MAIN
%token <lexeme> IDENTIFIER 
%token CONST 
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
%left '^' //update
%left '(' ')'

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
    //| func_def
    ;

/*func_def:
    DEFINE IDENTIFIER '(' PARAM ')' '{' func_body '}' { printf("Function Def\n"); }
    ;*/

/*func_call:
    IDENTIFIER '(' PARAM ')' ';' { printf("Function call\n"); }
    ;

PARAM:
    PARAM ',' expr
    | expr
    |
    ; 

func_body:
    Slist RET expr ';'
    ;*/


mainBlock: MAIN '(' ')' '{' { printf("main block\n"); } Slist '}' ;
Slist: Slist stmt | stmt;

stmt:
    expr_stmt 
    | print_stmt { printf("PRINT statement\n"); }
    | END { printf("Main block ends\n"); }
    ;

expr_stmt:
    IDENTIFIER '=' expr ';' {// printf("Variable Assignement statement lexeme = $s and value = %ld \n", $1, $3.integer); 
    }
    | CONST IDENTIFIER '=' expr ';' { //printf("Constant Assignement statement = $s\n", $2);
     }
    | CONST IDENTIFIER ';' { //printf("declare Constant variable without init = $s\n", $2); 
    }
    | IDENTIFIER ';' { //printf("Declare variable without init = $s\n", $1); 
    }
    ;

print_stmt:
    PRINT '(' expr ')' ';'
    | PRINT '(' STRING ')' ';'
    ;

expr:
    RATIONAL { //printf("\t number  %f \n ", $1.rational); 
    $$ = $1; }
    |  INTEGER { //printf("\t number  %ld \n ", $1.integer); 
    $$ = $1; }
    |  IDENTIFIER {printf("\t identifier %ld\n ", $$.integer);}
    |  expr '+' expr { struct number result = ADD($1, $3); 
                        $$ = result; 
                        printf("result = %ld  num1 %ld num2 %ld \n", $$.integer, $1.integer, $3.integer); 
                    } 
    |  expr '-' expr { struct number result = SUBTRACT($1, $3); 
                        $$ = result; 
                        printf("result = %ld  num1 %ld num2 %ld \n", $$.integer, $1.integer, $3.integer); 
                    } 
    |  expr '*' expr { struct number result = MULTIPLY($1, $3); 
                        $$ = result; 
                        printf("result = %ld  num1 %ld num2 %ld \n", $$.integer, $1.integer, $3.integer); 
                    } 
    |  expr '/' expr { struct number result = DIVIDE($1, $3); 
                        $$ = result; 
                        printf("result = %ld  num1 %ld num2 %ld \n", $$.integer, $1.integer, $3.integer); 
                    } 
    |  expr '^' expr { struct number result = POW($1, $3); 
                        $$ = result; 
                        printf("result = %ld  num1 %ld num2 %ld \n", $$.integer, $1.integer, $3.integer); 
                    } 
    //|  expr '&&' expr { $$ = POW($1, $3); printf("^");}
    //|  expr '==' expr { $$ = POW($1, $3); printf("^");}
    //|  expr '>=' expr { $$ = POW($1, $3); printf("^");}
    //|  expr '<=' expr { $$ = POW($1, $3); printf("^");}
    //|  expr '>' expr { $$ = POW($1, $3); printf("^");}
    //|  expr '<' expr { $$ = POW($1, $3); printf("^");}
    |  '(' expr ')'  { $$ = $2; printf("\t result %ld\n", $$.integer);}
    ;

%%

void yyerror(const char *str)
{
	fprintf(stderr,"error: %s\n",str);
}

int main()
{
	FILE * pt = fopen("tests/test4.txt", "r" );
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