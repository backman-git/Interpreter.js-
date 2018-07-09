%{
    //import {Node,OpNode,NumNode,VarNode,AssignNode} from '@bx/ast';
%}

%lex

%%


\s+                   /* skip whitespace */
//keywords
"function"            return 'FUNCTION'


//
[0-9]+                return 'NUMBER'
\$[a-zA-Z_][a-zA-Z_0-9]*     return 'VARIABLE'
[a-zA-Z_][a-zA-Z_0-9]*  return 'NAME'
"*"                   return '*'
"/"                   return '/'
"-"                   return '-'
"+"                   return '+'
"("                   return  '('
")"                   return  ')'
";"                   return  ';'
"if"                  return "IF"
">"                   return '>'
"<"                   return '<'
"="                   return '='
"{"                   return '{'
"}"                   return '}'
","                   return ','






<<EOF>>               return 'EOF'
.                     return 'INVALID'


/lex

/* operator associations and precedence */
%left '='
%left '>' '<'
%left '+' '-'
%left '*' '/'



%% /* language grammar */


start
    :top_statement_list EOF   
    {
        Node.genGraph($1); 
        var interpreter = new Interpreter($1);

        $$=$1;
    }
    ;


top_statement_list
    :top_statement_list top_statement   
        {

            ($1).addStmt($2);
            $$ = $1;
        }
    | top_statement                     {$$ = new ProgramNode($1);   }
    ;


top_statement
    :statement                        { $$=$1; }
    ;



statement
    : expr ';'     { $$ = new StmtNode($1);    }
    | function_statement   {$$=new StmtNode($1);}
    | '{' inner_statement_list '}'    {$$ = new StmtNode($2);}
    ;


function_statement
    : FUNCTION NAME '(' parameter_list  ')' compound_statement
        {$$ = new FunctNode($2,$4,$6);}
    ;



parameter_list
    :  parameter   {$$= new ParaListNode($1);}
    |  parameter_list ',' parameter 
        {
            $1.addPara($3);
            $$=$1;
        }
    ;

parameter
    :VARIABLE   {$$ = new PNode($1);}
    | {$$ = new PNode("");}
    ;

compound_statement
    : '{' inner_statement_list '}'   {$$=$2;}
    ;



inner_statement_list
    : inner_statement_list inner_statement  
        {  
            ($1).addStmt($2);
            $$ = $1;
        }
    | inner_statement  {$$= new CompoundStmtNode($1);}
    ;

inner_statement
    : statement   {$$=$1;}
    ;



expr
    : VARIABLE '=' expr  
        {$$ = new AssignNode(new VarNode($1),$3); } 
    | expr '+' expr
        {$$ = new OpNode('+',$1,$3); }
    | expr '-' expr
        {$$ = new OpNode('-',$1,$3); }
    | expr '*' expr
        {$$ = new OpNode('*',$1,$3); }
    | expr '/' expr
        {$$ = new OpNode('/',$1,$3); }
    | expr '>' expr
        {}
    | expr '<' expr
        {}
    | '(' expr ')'
        {$$=$2}
    | NUMBER
        {$$ = new NumNode(Number(yytext));}
    |VARIABLE
        {$$ = new VarNode(yytext);}
    ;


