%debug
%{
    #include<bits/stdc++.h>
    #include "2005118_symboltable.h"
    using namespace std;


    extern int yylineno; //debug
    int yyparse(void);
    int yylex(void);
    extern FILE *yyin;
    SymbolTable *symbolTable= new SymbolTable(11);
    vector<SymbolInfo*>parameterList,variableList;
    bool zero=false,func=false;
    ofstream outputLog,outputParse,outputError;
    int errorcount=0,space=0,line=0;

    void yyerror(string s)
    {
        cout<<yylineno<<" "<<s<<endl; //debug
    }
    void insertParameters(){
        for(SymbolInfo* s : parameterList){
            SymbolInfo *temp=new SymbolInfo(s);
            if(s->getName()==""&&s->getType()==""){
             }
            if(!symbolTable->insertSymbol(temp)){
                cout<<"error redefined\n";
            }
        }
    }

    void insertFunction(SymbolInfo* symbol,string typeSpecifier){
        symbol->function=true;
        symbol->defined=true;
        symbol->typeSpecifier=typeSpecifier;
        SymbolInfo *cur =symbolTable->lookup(symbol->getName());
        if(cur==NULL){
            for(SymbolInfo *s : parameterList){
                symbol->parameter_list.push_back(s);
            }
            SymbolInfo *temp =new SymbolInfo(symbol);
            //symbolTable->insertSymbol(temp);
        }
        else{
            if(!cur->function){
                errorcount++;// modify
                outputError<<"Line# "<<yylineno<<": '"<<cur->getName()<<"' redeclared as different kind of symbol\n";
            }
            else if(cur->defined){
                errorcount++;
                cout<<"Error func previously defined\n";//modify

            }
            else if(cur->declared){
                cout<<cur->getName()<<" "<<cur->typeSpecifier<<" "<<typeSpecifier<<endl;
                if(cur->typeSpecifier==typeSpecifier){
                    bool flag=false;
                    if(parameterList.size()==symbol->parameter_list.size()){
                        flag=true;
                        for(int i=0;i<parameterList.size();i++){
                            if(parameterList[i]->typeSpecifier!=symbol->parameter_list[i]->typeSpecifier){
                                flag=false;
                                errorcount++;
                                outputError<<"Line# "<<yylineno<<": Type mismatch for arguement "<<i+1<<" of '"<<symbol->getName()<<"'\n";
                                return;            
                            }
                        }    
                    }
                    if(flag){
                        symbol->defined=true;
                    }
                    else{
                        // if(parameterList.size()<symbol->parameter_list.size()){
                        //     outputError<<"Line# "<<yylineno<<": Too few arguements to function '"<<symbol->getName()<<"'\n";
                        // }
                        // else{
                        //     outputError<<"Line# "<<yylineno<<": Too many arguements to function '"<<symbol->getName()<<"'\n";
                        // }
                        errorcount++;
                        outputError<<"Line# "<<yylineno<<": Conflicting types for '"<<symbol->getName()<<"'\n"; //modify
                    }
                }
                else{
                    errorcount++;
                    outputError<<"Line# "<<yylineno<<": Conflicting types for '"<<symbol->getName()<<"'\n"; //modify
                }

            }
        }
    }
    void printTree(SymbolInfo *cur,int space){
        if(cur!=NULL){
            for(int i=0;i<space;i++)outputParse<<" ";
            outputParse<<cur->getType()<<" : "<<cur->getName()<<" <Line: ";
            if(cur->child)outputParse<<cur->startLineNo<<" >"<<endl;
            else outputParse<<cur->startLineNo<<"-"<<cur->endLineNo<<" >"<<endl;
            for(SymbolInfo *s:cur->parseList){
                //cout<<cur->getName()<<"---->"<<s->getName()<<endl;
                printTree(s,space + 1);
            }
        }
    }
%}

%union{
    SymbolInfo * symbolInfo;
}
%token <symbolInfo> IF ELSE FOR DO WHILE BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE CONTINUE DEFAULT ADDOP MULOP INCOP DECOP RELOP LOGICOP BITOP NOT LPAREN RPAREN LTHIRD RTHIRD LCURL RCURL COMMA SEMICOLON CONST_INT CONST_FLOAT ID PRNTLN ASSIGNOP

%type <symbolInfo> start program unit var_declaration func_declaration func_definition type_specifier parameter_list compound_statement statements declaration_list statement expression_statement expression variable logic_expression rel_expression simple_expression term unary_expression factor arguement_list arguements

%start start

%nonassoc THEN
%nonassoc ELSE

%%

start : program 
        {
            outputLog<<"start : program"<<"\n";
            $$=new SymbolInfo("program","start");
            $$->startLineNo=$1->startLineNo;
            $$->endLineNo=$1->endLineNo;
            line=$$->endLineNo;
            $$->child=false;
            $$->parseList.push_back($1);
            printTree($$,0);
           //$$->parse(0,outputParse);
        }
        ;
program : program unit
        {
            outputLog<<"program : program unit"<<endl;
            $$=new SymbolInfo("program unit","program");
            $$->startLineNo=$1->startLineNo;
            $$->endLineNo=$2->endLineNo;
            $$->child=false;
            $$->parseList.push_back($1);
            $$->parseList.push_back($2);
        }
        | unit{
            outputLog<<"program : unit "<<endl;
            $$=new SymbolInfo("unit","program");
            $$->startLineNo=$1->startLineNo;
            $$->endLineNo=$1->endLineNo;
            $$->child=false;
            $$->parseList.push_back($1);
        }
        ;
unit : var_declaration{
        outputLog<<"unit : var_declaration"<<endl;
        $$=new SymbolInfo("var_declaration","unit");
            $$->startLineNo=$1->startLineNo;
            $$->endLineNo=$1->endLineNo;
            $$->child=false;
            $$->parseList.push_back($1);
    }
    | func_declaration {
        outputLog<<"unit : func_declaration"<<endl;
        $$=new SymbolInfo("func_declaration","unit");
            $$->startLineNo=$1->startLineNo;
            $$->endLineNo=$1->endLineNo;
            $$->child=false;
            $$->parseList.push_back($1);
    }
    | func_definition{
        outputLog<<"unit : func_definition"<<endl;
        $$=new SymbolInfo("func_definition","unit");
            $$->startLineNo=$1->startLineNo;
            $$->endLineNo=$1->endLineNo; 
            $$->child=false;
            $$->parseList.push_back($1);      
    }
    ;

func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON{
    func=false;
    outputLog<<"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"<<endl;
    $$ = new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN SEMICOLON","func_declaration");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$6->endLineNo;
    $$->child=false;
    $$->parseList.push_back($1);
    $$->parseList.push_back($2);
    $$->parseList.push_back($3);
    $$->parseList.push_back($4);
    $$->parseList.push_back($5);
    $$->parseList.push_back($6);
    SymbolInfo *cur= symbolTable->lookup($2->getName());

    if(cur==NULL){
        $2->typeSpecifier=$1->getName();
        $2->declared=true;
        $2->function=true;
        for(SymbolInfo *s : parameterList){
            $2->parameter_list.push_back(s);
        }
        SymbolInfo *newEntry=new SymbolInfo($2);
        symbolTable->insertSymbol(newEntry);
    }
    else{
        $2->typeSpecifier=$1->getName();
        if(!$2->function){
            errorcount++;
            //cout<<"Error declared but not as a function\n";//modify it
            outputError<<"Line# "<<yylineno<<": '"<<$2->getName()<<"' redeclared s different kind of symbol\n";
        }
        else if(cur->getType()==$2->getType()){
            bool flag=false;
            if(cur->parameter_list.size()==$2->parameter_list.size()){
                flag-true;
                for(int i=0;i<cur->parameter_list.size();i++){
                    if(cur->parameter_list[i]->typeSpecifier!=$2->parameter_list[i]->typeSpecifier){
                        flag=false;
                        errorcount++;
                        outputError<<"Line# "<<yylineno<<": Type mismatch for argument "<<i+1<<"of '"<<cur->getName()<<"' \n";///modify written lately
                    
                        //cout<<"error parameters dont match\n"; //modify
                    }
                }
                if(flag){
                    cur->declared=true;//modify  follow other function errors
                }
            }
        }
        else{
            errorcount++;
            cout<<"error arg numb dont match\n";//modify
        }
    }
    parameterList.clear();
}
|type_specifier ID LPAREN RPAREN SEMICOLON{
    func=false;
    outputLog<<"fun_declaration : type_specifier ID LPAREN RPAREN SEMICOLON"<<endl;
    $$=new SymbolInfo("type_specifier ID LPAREN RPAREN SEMICOLON","func_declaration");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$5->endLineNo;
    $$->child=false;
    $$->parseList.push_back($1);
    $$->parseList.push_back($2);
    $$->parseList.push_back($3);
    $$->parseList.push_back($4);
    $$->parseList.push_back($5);
    SymbolInfo *cur =symbolTable->lookup($2->getName());
    if(cur==NULL){
        $2->typeSpecifier=$1->getName();
        $2->function=true;
        $2->declared=true;
        SymbolInfo* newEntry=new SymbolInfo($2);
        symbolTable->insertSymbol(newEntry);
    }
    else{
        if(!cur->function){
            errorcount++;
            //cout<<"Error not a function\n"; //modify
            outputError<<"Line# "<<yylineno<<": '"<<cur->getName()<<"' redeclared as different kind of symbol\n";

        }
        else {
            errorcount++;
            cout<<"previously declared function error\n";// modify
        }
    }
    parameterList.clear();
    // check if need to clear parameterList
}
;
func_definition : type_specifier ID LPAREN parameter_list RPAREN
                {
                    insertFunction($2,$1->getName());
                    func=true;
                }compound_statement{
                    outputLog<<"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement"<<endl;
                    $$=new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN compound_statement","func_definition");
                    $$->startLineNo=$1->startLineNo;
                    $$->endLineNo=$7->endLineNo;
                    $$->child=false;
                    $$->parseList.push_back($1);
                    $$->parseList.push_back($2);
                    $$->parseList.push_back($3);
                    $$->parseList.push_back($4);
                    $$->parseList.push_back($5);
                    $$->parseList.push_back($7);
                    parameterList.clear();
                    func=false;
                    symbolTable->insertSymbol($2);
                }
                |type_specifier ID LPAREN RPAREN{
                    insertFunction($2,$1->getName());
                    func=true;
                }compound_statement{
                    outputLog<<"func_definition : type_specifier ID LPAREN  RPAREN compound_statement"<<endl;
                    $$=new SymbolInfo("type_specifier ID LPAREN RPAREN compound_statement","func_definition");
                    $$->startLineNo=$1->startLineNo;
                    $$->endLineNo=$6->endLineNo;
                    $$->child=false;
                    $$->parseList.push_back($1);
                    $$->parseList.push_back($2);
                    $$->parseList.push_back($3);
                    $$->parseList.push_back($4);
                    $$->parseList.push_back($6);
                    parameterList.clear();
                    func=false;
                    symbolTable->insertSymbol($2);
                }
                |type_specifier ID LPAREN error {
                    //cout<<yylineno<<" Syntax error\n";//mod
                    outputLog<<"Error at line no "<<yylineno<<" : syntax error\n";
                    parameterList.clear();
                    // chechk if needed after rparen error check
                }RPAREN compound_statement{
                    outputError<<"Line# "<<yylineno<<": Syntax error at parameter list of function definition\n";
                    outputLog<<"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement"<<endl;
                    $$=new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN compound_statement","func_definition");
                    $$->startLineNo=$1->startLineNo;
                    $$->endLineNo=$6->endLineNo; //check line no
                    $$->child=false;
                    $$->parseList.push_back($1);
                    $$->parseList.push_back($2);
                    $$->parseList.push_back($3);
                    SymbolInfo *temp=new SymbolInfo("error","parameter_list");
                    temp->startLineNo=$3->startLineNo;
                    temp->endLineNo=$6->endLineNo;
                    $$->parseList.push_back(temp);
                    //$$->addParseList($5);//check
                    $$->parseList.push_back($6);//check //$8 push
                    $$->parseList.push_back($7);///my intuition vvimp to check
                    func=false;
                }
                ;
                /// type_specifier ID LPAREN error "identify this error and try its grammer"
parameter_list : parameter_list COMMA type_specifier ID{
    outputLog<<"parameter_list : parameter_list COMMA type_specifier ID"<<endl;
    $$= new SymbolInfo("parameter_list COMMA type_specifier ID","parameter_list");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$4->endLineNo;
    $$->child=false;
    $$->parseList.push_back($1);
    $$->parseList.push_back($2);
    $$->parseList.push_back($3);
    $$->parseList.push_back($4);
    
   
    $4->typeSpecifier=$3->getName();
    bool flag=true;
    for(int i=0;i<parameterList.size();i++){
        if(parameterList[i]->getName()==$4->getName()){
            flag=false;
            errorcount++;
            outputError<<"Line# "<<yylineno<<": Redefinition of parameter '"<<$4->getName()<<"'\n";
            //break;
        }
    }
    if(flag)parameterList.push_back($4);
}
|parameter_list COMMA type_specifier{
    outputLog<<"parameter_list : parameter_list COMMA type_specifier"<<endl;
    $$=new SymbolInfo("parameter_list COMMA type_specifier","parameter_list");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$3->endLineNo;
    $$->child=false;
    $$->parseList.push_back($1);
    $$->parseList.push_back($2);
    $$->parseList.push_back($3);
    SymbolInfo* newEntry=new SymbolInfo("","");
    newEntry->typeSpecifier=$3->getName();
    parameterList.push_back(newEntry);
} 
|type_specifier ID{
    outputLog<< "parameter_list  : type_specifier ID" <<endl;
    $$=new SymbolInfo("type_specifier ID","parameter_list");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$2->endLineNo;
    $$->child=false;
    $$->parseList.push_back($1);
    $$->parseList.push_back($2);
    $2->typeSpecifier=$1->getName(); 
    bool flag=true;
    for(int i=0;i<parameterList.size();i++){
        if(parameterList[i]->getName()==$2->getName()){
            flag=false;
            errorcount++;
            outputError<<"Line# "<<yylineno<<": Redefinition of parameter '"<<$2->getName()<<"'\n";
            //break;
        }
    }
    if(flag)parameterList.push_back($2);

}
|type_specifier{
    outputLog<<"parameter_list : type_specifier"<<endl;
    $$=new SymbolInfo("type_specifier","parameter_list");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$1->endLineNo;
    $$->child=false;
    $$->parseList.push_back($1);
    SymbolInfo* newEntry=new SymbolInfo("","");
    newEntry->typeSpecifier=$1->getName();
    parameterList.push_back(newEntry);
};
compound_statement : LCURL {
    symbolTable->enterScope();
    if(func){
        insertParameters();
        parameterList.clear();
    }
    
    } statements RCURL{
        outputLog<< "compound_statement : LCURL statements RCURL"<<endl;
        $$=new SymbolInfo( "LCURL statements RCURL","compound_statement");
        $$->startLineNo=$1->startLineNo;
        $$->endLineNo=$4->endLineNo;//check this
        $$->child=false;
        $$->parseList.push_back($1);
        $$->parseList.push_back($3);
        $$->parseList.push_back($4);
        symbolTable->printAllScopeTable(outputLog);
        symbolTable->exitScope();
    }
    |LCURL{
        
        symbolTable->enterScope();
        if(func){
            insertParameters();
            parameterList.clear();
        }
    }RCURL{
        
        outputLog<< "compound_statement : LCURL RCURL"<<endl;
        $$=new SymbolInfo( "LCURL RCURL","compound_statement");
        $$->startLineNo=$1->startLineNo;
        $$->endLineNo=$3->endLineNo;//check this
        $$->child=false;
        $$->parseList.push_back($1);
        $$->parseList.push_back($3);
        symbolTable->printAllScopeTable(outputLog);
        symbolTable->exitScope();
    }
    ;
var_declaration : type_specifier declaration_list SEMICOLON{
    outputLog<<"var_declaration : type_specifier declaration_list SEMICOLON"<<endl;
    $$= new SymbolInfo("type_specifier declaration_list SEMICOLON","var_declaration");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$3->endLineNo;
    $$->child=false;
    $$->parseList.push_back($1);
    $$->parseList.push_back($2);
    $$->parseList.push_back($3);

    if($1->getName()=="VOID"){
        for(SymbolInfo* s : variableList){
            errorcount++;
            outputError<<"Line# "<<yylineno<<": Variable or field '"<<s->getName()<<"' declared void\n";
        }
    }
    else{
        for(SymbolInfo* s : variableList){
            cout<< s->getName()<<" "<<yylineno<<endl;
            s->typeSpecifier=$1->getName();
            SymbolInfo* cur=symbolTable->lookupCurrent(s->getName());
            if(cur==NULL){
                SymbolInfo *news=new SymbolInfo(s);
                symbolTable->insertSymbol(news);
            }
            else{
                errorcount++;
                if(cur->typeSpecifier!=s->typeSpecifier){
                     outputError<<"Line# "<<yylineno<<": Conflicting types for'"<<s->getName()<<"'\n";
                }
                // else cout<<"error redeclared\n";//modify
                else outputError<<"Line# "<<yylineno<<": Conflicting types for '"<<s->getName()<<"'\n";
            }
            //delete cur;
        }
    }
     variableList.clear();
}
|type_specifier error {
    errorcount++;
    outputLog<<"Error at line no "<<yylineno<<" :syntax error\n";
    //check if need for if condiition
}SEMICOLON {
    outputError<<"Line# "<<yylineno<<": Syntax error at declaration list of variable declaration\n";
    outputLog<<"var_declaration : type_specifier declaration_list SEMICOLON"<<endl;
    $$= new SymbolInfo("type_specifier declaration_list SEMICOLON","var_declaration");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$4->endLineNo;
    $$->child=false;
    $$->parseList.push_back($1);
    SymbolInfo *temp=new SymbolInfo("error","declaration_list");
    temp->child=true;
    temp->startLineNo=yylineno;
    temp->endLineNo=yylineno;
    $$->parseList.push_back(temp);
    $$->parseList.push_back($4);


    // for  errorecover test  modify
    for(SymbolInfo* s : variableList){
            //cout<< s->getName()<<" "<<yylineno<<endl;
            s->typeSpecifier=$1->getName();
            SymbolInfo* cur=symbolTable->lookupCurrent(s->getName());
            if(cur==NULL){
                SymbolInfo *news=new SymbolInfo(s);
                symbolTable->insertSymbol(news);
            }
            else{
                errorcount++;
                if(cur->typeSpecifier!=s->typeSpecifier){
                     outputError<<"Line# "<<yylineno<<": Conflicting types for'"<<s->getName()<<"'\n";
                }
                // else cout<<"error redeclared\n";//modify
                else outputError<<"Line# "<<yylineno<<": Conflicting types for '"<<s->getName()<<"'\n";
            }
            //delete cur;
        }
        variableList.clear();
}
;
//learn and handle type_specifier error
type_specifier : INT{
    outputLog<<"type_specifier\t: INT"<<endl;
    $$=new SymbolInfo("INT","type_specifier");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$1->endLineNo;
    $$->child=false;
    $$->parseList.push_back($1);

}|FLOAT{
    outputLog<<"type_specifier	: FLOAT"<<endl;
    $$=new SymbolInfo("FLOAT","type_specifier");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$1->endLineNo; 
    $$->child=false;
    $$->parseList.push_back($1); 
}|VOID{
    outputLog<<"type_specifier	: VOID"<<endl;
    $$=new SymbolInfo("VOID","type_specifier");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$1->endLineNo;  
    $$->child=false;
    $$->parseList.push_back($1);
}
;
declaration_list : declaration_list COMMA ID{
    outputLog<<"declaration_list : declaration_list COMMA ID"<<endl;
    $$=new SymbolInfo("declaration_list COMMA ID","declaration_list");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$3->endLineNo;
    $$->child=false;
    //$$->parseList.clear(); //additional
    $$->parseList.push_back($1);
    $$->parseList.push_back($2);
    $$->parseList.push_back($3);
    variableList.push_back($3);
}|declaration_list COMMA ID LTHIRD CONST_INT RTHIRD{
    outputLog<<"declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD"<<endl;
    $$=new SymbolInfo("declaration_list COMMA ID LTHIRD CONST_INT RTHIRD","declaration_list");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$6->endLineNo;  
    $$->child=false;
    //$$->parseList.clear(); //additional
    $$->parseList.push_back($1);
    $$->parseList.push_back($2);
    $$->parseList.push_back($3);
    $$->parseList.push_back($4);
    $$->parseList.push_back($5);
    $$->parseList.push_back($6);
    $3->arrSize=stoi($5->getName());
    variableList.push_back($3);
}|ID{
    outputLog<<"declaration_list : ID"<<endl;
    $$=new SymbolInfo("ID","declaration_list");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$1->endLineNo;    
    $$->child=false;
    //$$->parseList.clear(); //additional
    $$->parseList.push_back($1);
    variableList.push_back($1);
}|ID LTHIRD CONST_INT RTHIRD{
    outputLog<<"declaration_list : ID LTHIRD CONST_INT RTHIRD"<<endl;
    $$=new SymbolInfo("ID LTHIRD CONST_INT RTHIRD","declaration_list");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$4->endLineNo;
    $$->child=false;
    $$->parseList.push_back($1);
    $$->parseList.push_back($2);
    $$->parseList.push_back($3);
    $$->parseList.push_back($4);    
    //cout<<$$->getName()<<" ixjwxjwixwkxk   "<<$$->parseList[0]->getName()<<endl;
    $1->arrSize=stoi($3->getName());
    variableList.push_back($1);
}
;
statements : statement {
            outputLog<<"statements : statement"<<endl;
            $$=new SymbolInfo("statement","statements");
            $$->startLineNo=$1->startLineNo;
            $$->endLineNo=$1->endLineNo;
            $$->addParseList($1);
            $$->child=false;   
            
    }|statements statement{
            outputLog<<"statements : statements statement"<<endl;
            $$=new SymbolInfo("statements statement","statements");
            $$->startLineNo=$1->startLineNo;
            $$->endLineNo=$2->endLineNo;
            $$->addParseList($1);
            $$->addParseList($2);
            $$->child=false; 
    }
    ;
statement : var_declaration {
        outputLog<<"statement : var_declaration\n";
        $$= new SymbolInfo("var_declaration","statement");
        $$->startLineNo=$1->startLineNo;
        $$->endLineNo=$1->endLineNo;
        $$->addParseList($1);
        $$->child=false; 
    }|expression_statement{
        outputLog<<"statement : expression_statement\n";
        $$= new SymbolInfo("expression_statement","statement");
        $$->startLineNo=$1->startLineNo;
        $$->endLineNo=$1->endLineNo;    
        $$->addParseList($1);
        $$->child=false; 
    
    }|compound_statement{
        outputLog<<"statement : compound_statement\n";
        $$= new SymbolInfo("compound_statement","statement");
        $$->startLineNo=$1->startLineNo;
        $$->endLineNo=$1->endLineNo;
        $$->addParseList($1);
        $$->child=false; 

    }|FOR LPAREN expression_statement expression_statement expression_statement RPAREN statement{
        outputLog<<"statement : FOR LPAREN expression_statement expression_statement expression_statement RPAREN statement\n";
        $$= new SymbolInfo("FOR LPAREN expression_statement expression_statement expression_statement RPAREN statement","statement");
        $$->startLineNo=$1->startLineNo;
        $$->endLineNo=$7->endLineNo;
        $$->addParseList($1);
        $$->addParseList($2);
        $$->addParseList($3);
        $$->addParseList($4);
        $$->addParseList($5);
        $$->addParseList($6);
        $$->addParseList($7);
        $$->child=false;
    }|IF LPAREN expression RPAREN statement %prec THEN{
        outputLog<<"statement : IF LPAREN expression RPAREN statement\n";
        $$= new SymbolInfo("IF LPAREN expression RPAREN statement","statement");
        $$->startLineNo=$1->startLineNo;
        $$->endLineNo=$5->endLineNo;
        $$->addParseList($1);
        $$->addParseList($2);
        $$->addParseList($3);
        $$->addParseList($4);
        $$->addParseList($5);
        $$->child=false;

    }|IF LPAREN expression RPAREN statement ELSE statement{
        outputLog<<"statement : IF LPAREN expression RPAREN statement ELSE statement\n";
        $$= new SymbolInfo("IF LPAREN expression RPAREN statement ELSE statement","statement");
        $$->startLineNo=$1->startLineNo;
        $$->endLineNo=$7->endLineNo;
        $$->addParseList($1);
        $$->addParseList($2);
        $$->addParseList($3);
        $$->addParseList($4);
        $$->addParseList($5);
        $$->addParseList($6);
        $$->addParseList($7);
        $$->child=false;

    }|WHILE LPAREN expression RPAREN statement{
        outputLog<<"statement : WHILE LPAREN expression RPAREN statement\n";
        $$= new SymbolInfo("WHILE LPAREN expression RPAREN statement","statement");
        $$->startLineNo=$1->startLineNo;
        $$->endLineNo=$5->endLineNo;
        $$->addParseList($1);
        $$->addParseList($2);
        $$->addParseList($3);
        $$->addParseList($4);
        $$->addParseList($5);
        $$->child=false;

    }|PRNTLN LPAREN ID RPAREN SEMICOLON{
        outputLog<<"statement : PRNTLN LPAREN ID RPAREN SEMICOLON\n";
        $$= new SymbolInfo("PRNTLN LPAREN ID RPAREN SEMICOLON","statement");
        $$->startLineNo=$1->startLineNo;
        $$->endLineNo=$5->endLineNo;
        $$->addParseList($1);
        $$->addParseList($2);
        $$->child=false;
        SymbolInfo* cur= symbolTable->lookup($3->getName());
        if(cur==NULL){
            //cout<<"Error undeclared\n";// modify
            errorcount++;
            outputError<<"Line# "<<yylineno<<": Undeclared variable '"<<$3->getName()<<"' \n";
        }
        $$->addParseList($3);
        $$->addParseList($4);
        $$->addParseList($5);
    }|RETURN expression SEMICOLON{
        outputLog<<"statement : RETURN expression SEMICOLON\n";
        $$= new SymbolInfo("RETURN expression SEMICOLON","statement");
        $$->startLineNo=$1->startLineNo;
        $$->endLineNo=$3->endLineNo;
        $$->addParseList($1);
        $$->addParseList($2);
        $$->addParseList($3);
        $$->child=false;
    }
    ;
expression_statement : SEMICOLON{
        outputLog<<"expression_statement : SEMICOLON\n";
        $$= new SymbolInfo("SEMICOLON","expression_statement");
        $$->startLineNo=$1->startLineNo;
        $$->endLineNo=$1->endLineNo;
        $$->addParseList($1);
        $$->child=false;
        
    }|expression SEMICOLON{
        outputLog<<"expression_statement : expression SEMICOLON\n";
        $$= new SymbolInfo("expression SEMICOLON","expression_statement");
        $$->startLineNo=$1->startLineNo;
        $$->endLineNo=$2->endLineNo;
        $$->child=false;
        $$->addParseList($1);
        $$->addParseList($2);        
    }|error{
        //check if conditioning needed
    }SEMICOLON{
        errorcount++;
        outputError<<"Line# "<<yylineno<<": Syntax error at expression of expression statement\n";
        outputLog<<"expression_statement : expression SEMICOLON\t\t\n";
        $$= new SymbolInfo("expression SEMICOLON","expression_statement");
        $$->startLineNo=$3->startLineNo;
        $$->endLineNo=$3->endLineNo;
        $$->child=false;
        SymbolInfo *temp =new SymbolInfo("error","expression");
        temp->startLineNo=yylineno;
        temp->endLineNo=yylineno;
        temp->child=true;
        $$->addParseList(temp);
        $$->addParseList($3);

    }
    ;
    //handle |error SEMICOLON
variable : ID{
        outputLog<<"variable : ID\n";
        $$= new SymbolInfo("ID","variable");
        $$->startLineNo=$1->startLineNo;
        $$->endLineNo=$1->endLineNo;
        $$->child=false;
        $$->addParseList($1);
        SymbolInfo* cur = symbolTable->lookup($1->getName());
        if(cur==NULL){
            //cout<<"error undeclared\n"; //modify
            errorcount++;
            outputError<<"Line# "<<yylineno<<": Undeclared variable '"<<$1->getName()<<"'\n";
        }
        else if(cur->typeSpecifier=="VOID"){
            errorcount++;
            outputError<<"Line# "<<yylineno<<": '"<<$1->getName()<<"' declared as void\n";
        }
        else{
            $$->typeSpecifier=cur->typeSpecifier;
            $$->arrSize=$1->arrSize;
        }
    }|ID LTHIRD expression RTHIRD{
        outputLog<<"variable : ID LTHIRD expression RTHIRD\n";
        $$= new SymbolInfo("ID LTHIRD expression RTHIRD","variable");
        $$->startLineNo=$1->startLineNo;
        $$->endLineNo=$4->endLineNo;
        $$->child=false;
        
        SymbolInfo* cur = symbolTable->lookup($1->getName());
        //cout<<cur->getName()<<" "<<cur->arrSize<<endl;
        if(cur==NULL){
            errorcount++;
            outputError<<"Line# "<<yylineno<<": Undeclared variable '"<<$1->getName()<<"'\n"; //modify
        }
        else if(cur->typeSpecifier=="VOID"){
            errorcount++;
            outputError<<"Line# "<<yylineno<<": '"<<$1->getName()<<"' declared as void\n";//mpdify
        }
        else if(cur->arrSize==-1){ 
            errorcount++;
            outputError<<"Line# "<<yylineno<<": '"<<$1->getName()<<"' is not an array\n"; //modify
        }
        else{
            $$->typeSpecifier=cur->typeSpecifier;
            $$->arrSize=-1;//// imp temp solution check if wrong
        }
        if($3->typeSpecifier!="INT"){
            //cout<<"error index not an integer\n";//modify
            errorcount++;
            outputError<<"Line# "<<yylineno<<": Array subscript is not an integer\n";
        }
        $$->addParseList($1);
        $$->addParseList($2);
        $$->addParseList($3);
        $$->addParseList($4);
    }
    ;
expression : logic_expression{
    outputLog<<"expression : logic_expression\n";
    $$= new SymbolInfo("logic_expression","expression");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$1->endLineNo;
    $$->typeSpecifier=$1->typeSpecifier;
    $$->arrSize=$1->arrSize;
    $$->child=false;
    $$->addParseList($1);
    
}|variable ASSIGNOP logic_expression{
    outputLog<<"expression : variable ASSIGNOP logic_expression\n";
    $$= new SymbolInfo("variable ASSIGNOP logic_expression","expression");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$3->endLineNo;
    $$->child=false;
    $$->addParseList($1);
    $$->addParseList($2);
    $$->addParseList($3);
    if($3->typeSpecifier=="VOID"||$1->typeSpecifier=="VOID"){
        //cout<<"error void\n"; //modify
        errorcount++;
        outputError<<"Line# "<<yylineno<<": Void cannot be used in expression\n";
    }
    else if($1->typeSpecifier=="FLOAT"&&$3->typeSpecifier=="INT"){
        $$->typeSpecifier=$1->typeSpecifier;
    }
    else if($3->typeSpecifier=="FLOAT"&&$1->typeSpecifier=="INT"){
        //cout<<"Error warning loss of data\n"; //modify
        errorcount++;
        outputError<<"Line# "<<yylineno<<": Warning: possible loss of data in assignment of FLOAT to INT\n";
        $$->typeSpecifier=$1->typeSpecifier;
    }
    else if(($1->arrSize==-1&&$3->arrSize!=-1)||($3->arrSize==-1&&$1->arrSize!=-1)){
        //cout<<$1->arrSize<<" p "<<$3->arrSize<<" "<<yylineno<<" "<<$1->getName()<<endl;
        //cout<<"Wrong type cast error1\n"; //modify
        errorcount++;
        outputError<<"Line# "<<yylineno<<": Warning: wrong type cast\n";//modify and fix urgent 
    }
    else if($1->typeSpecifier!=$3->typeSpecifier && $1->typeSpecifier!=""&&$3->typeSpecifier!=""){ ////recheck this imp
        //cout<<"typemismatch error1\n";//modify and check grammer too
    }
    else $$->typeSpecifier=$1->typeSpecifier;
}
;
logic_expression : rel_expression{
    outputLog<<"logic_expression : rel_expression\n";
    $$= new SymbolInfo("rel_expression","logic_expression");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$1->endLineNo;
    $$->typeSpecifier=$1->typeSpecifier;
    $$->arrSize=$1->arrSize;
    $$->child=false;
    $$->addParseList($1);
}|rel_expression LOGICOP rel_expression{
    outputLog<<"logic_expression : rel_expression\n";
    $$= new SymbolInfo("rel_expression LOGICOP rel_expression","logic_expression");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$3->endLineNo;
    $$->typeSpecifier=$1->typeSpecifier;
    $$->arrSize=$1->arrSize;
    $$->arrSize=$1->arrSize;
    $$->child=false;
    $$->addParseList($1);
    $$->addParseList($2);
    $$->addParseList($3);    
    if($3->typeSpecifier=="VOID"||$1->typeSpecifier=="VOID"){
        //cout<<"error void\n"; //modify
        errorcount++;
        outputError<<"Line# "<<yylineno<<": Void cannot be used in expression\n";
    }
    else{
        $$->typeSpecifier="INT";
    }
}
;
rel_expression : simple_expression{
    outputLog<<"rel_expression : simple_expression\n";
    $$=new SymbolInfo("simple_expression","rel_expression");
     $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$1->endLineNo;
    $$->typeSpecifier=$1->typeSpecifier;
    $$->arrSize=$1->arrSize;
    $$->child=false;
    $$->addParseList($1);
}|simple_expression RELOP simple_expression{
    outputLog<<"rel_expression : simple_expression RELOP simple_expression\n";
    $$=new SymbolInfo("simple_expression RELOP simple_expression","rel_expression");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$3->endLineNo;
    $$->child=false;
    $$->addParseList($1);
    $$->addParseList($2);
    $$->addParseList($3);
    if($3->typeSpecifier=="VOID"||$1->typeSpecifier=="VOID"){
        //cout<<"error void\n"; //modify
        errorcount++;
        outputError<<"Line# "<<yylineno<<": Void cannot be used in expression\n";
    }
    else{
        $$->typeSpecifier="INT";
    }
}
;
simple_expression : term {
    outputLog<<"simple_expression : term\n";
    $$=new SymbolInfo("term","simple_expression");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$1->endLineNo;
    $$->typeSpecifier=$1->typeSpecifier;
    $$->arrSize=$1->arrSize;
    $$->child=false;
    $$->addParseList($1);
}|simple_expression ADDOP term{
    outputLog<<"simple_expression : simple_expression ADDOP term\n";
    $$=new SymbolInfo("simple_expression ADDOP term","simple_expression");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$3->endLineNo;
    $$->child=false;
    $$->addParseList($1);
    $$->addParseList($2);
    $$->addParseList($3);
    if($3->typeSpecifier=="VOID"||$1->typeSpecifier=="VOID"){
        //cout<<"error void\n"; //modify
        errorcount++;
        outputError<<"Line# "<<yylineno<<": Void cannot be used in expression\n";
    }
    else{
        if($3->typeSpecifier=="FLOAT"||$1->typeSpecifier=="FLOAT"){
            $$->typeSpecifier="FLOAT";
        }
        else{
            $$->typeSpecifier=$1->typeSpecifier;
        }
    }
}
;
term : unary_expression {
    outputLog<<"term : unary_expression\n";
    $$=new SymbolInfo("term","simple_expression");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$1->endLineNo;
    $$->typeSpecifier=$1->typeSpecifier;
    $$->arrSize=$1->arrSize;
    
    $$->child=false;
    $$->addParseList($1);
}|term MULOP unary_expression{
    outputLog<<"term : term MULOP unary_expression\n";
    $$=new SymbolInfo("term MULOP unary_expression","simple_expression");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$3->endLineNo;
    $$->child=false;
    $$->addParseList($1);
    $$->addParseList($2);
    $$->addParseList($3);
    if($3->typeSpecifier=="VOID"||$1->typeSpecifier=="VOID"){
        //cout<<"error void\n"; //modify
        errorcount++;
        outputError<<"Line# "<<yylineno<<": Void cannot be used in expression\n";
    }
    if($2->getName()=="%"){
        if($3->typeSpecifier=="INT"&&$1->typeSpecifier=="INT"){
            if(zero){
                //cout<<"error division by zero\n";//modify
                errorcount++;
                outputError<<"Line# "<<yylineno<<": Warning: division by zero\n";//modify
            }
            else{
                $$->typeSpecifier="INT";
            }
        }
        else{
            errorcount++;
                outputError<<"Line# "<<yylineno<<": Operands of modulus must be integers\n"; //modify
        }
    }
    else if($2->getName()=="/"){
        if(zero){
                errorcount++;
                outputError<<"Line# "<<yylineno<<": Warning: division by zero\n";//modify
            }
        if($3->typeSpecifier=="FLOAT"||$1->typeSpecifier=="FLOAT"){
                $$->typeSpecifier="FLOAT";
        }
        else{
            $$->typeSpecifier="INT";
        }
    }
    else{ 
         if($3->typeSpecifier=="FLOAT"||$1->typeSpecifier=="FLOAT"){
            $$->typeSpecifier="FLOAT";
         }
         else if($3->typeSpecifier=="INT"&&$1->typeSpecifier=="INT"){
             $$->typeSpecifier="INT";
         }
         else {
            $$->typeSpecifier="INT";//test nd cchexk
            //void
         }
    }
    zero=false;
}
;
unary_expression : ADDOP unary_expression{
    outputLog<<"unary_expression : ADDOP unary_expression\n";
    $$=new SymbolInfo("ADDOP unary_expression","unary_expression");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$2->endLineNo;
    $$->child=false;
    $$->addParseList($1);
    $$->addParseList($2);
    if($2->typeSpecifier=="VOID"){
        //cout<<"error void\n";//modify
        errorcount++;
        outputError<<"Line# "<<yylineno<<": Void cannot be used in expression\n";
    }
    else $$->typeSpecifier=$2->typeSpecifier;
}|NOT unary_expression {
    outputLog<<"unary_expression : NOT unary_expression\n";
    $$=new SymbolInfo("NOT unary_expression","unary_expression");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$2->endLineNo;
    $$->child=false;
    $$->addParseList($1);
    $$->addParseList($2);
    if($2->typeSpecifier=="VOID"){
        //cout<<"error void\n";//modify
        errorcount++;
        outputError<<"Line# "<<yylineno<<": Void cannot be used in expression\n";
    }
    else $$->typeSpecifier="INT";
}|factor {
    outputLog<<"unary_expression : factor\n";
    $$=new SymbolInfo("factor","unary_expression");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$1->endLineNo;
    $$->typeSpecifier=$1->typeSpecifier;
    $$->arrSize=$1->arrSize;
    $$->child=false;
    $$->addParseList($1);
    
}
;
factor : variable {
    outputLog<<"factor	: variable\n";
    $$=new SymbolInfo("variable","factor");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$1->endLineNo;
    $$->child=false;
    $$->addParseList($1);
    if($1->typeSpecifier=="VOID"){
        //cout<<"error void\n";//modify
        errorcount++;
        outputError<<"Line# "<<yylineno<<": Void cannot be used in expression\n";
    }
    else{
        $$->typeSpecifier=$1->typeSpecifier;
        $$->arrSize=$1->arrSize;
    }
}|ID LPAREN arguement_list RPAREN{
    outputLog<<"factor : ID LPAREN arguement_list RPAREN\n";
    $$=new SymbolInfo("ID LPAREN arguement_list RPAREN","factor");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$4->endLineNo;
    $$->child=false;
    SymbolInfo* cur = symbolTable->lookup($1->getName());
    if(cur==NULL){
        errorcount++;
        outputError<<"Line# "<<yylineno<<": Undeclared function '"<<$1->getName()<<"'\n"; //mdoify
    }
    else{
        $$->typeSpecifier=$1->typeSpecifier;
        if(!cur->function){
            //cout<<"error conflict type\n"; //modfiy
            errorcount++;
            outputError<<"Line# "<<yylineno<<": Conflicting types for '"<<$1->getName()<< "'";
        }
        else if(!cur->defined){
           // cout<<"error not defined\n"; //modify
            errorcount++;
            outputError<<"Line# "<<yylineno<<": Undefiend function '"<<$1->getName()<< "'";
        }
        else{
            if(cur->parameter_list.size()==$3->parameter_list.size()){
                bool flag=true;
                for(int i=0;i<cur->parameter_list.size();i++){
                    if(cur->parameter_list[i]->typeSpecifier!=$3->parameter_list[i]->typeSpecifier){
                        //cout<<cur->parameter_list[i]->getName()<<" "<<cur->parameter_list[i]->typeSpecifier<<" "<<yylineno;
                        //cout<<" "<<$3->parameter_list[i]->typeSpecifier<<" "<<$3->parameter_list[i]->getName()<<endl;
                        flag=false;
                        errorcount++;
                        outputError<<"Line# "<<yylineno<<": Type mismatch for argument "<<i+1<<" of '"<<$1->getName()<<"'\n";
                        //break;
                    }
                }
                if(!flag){
                    //cout<<"args dont match \n"; //modify
                }
                else{
                    $$->typeSpecifier=cur->typeSpecifier;
                }
            }
            else{
                //cout<<"error parameters not equal\n";//modify
                if(cur->parameter_list.size()>$3->parameter_list.size()){
                    errorcount++;
                    outputError<<"Line# "<<yylineno<<": Too few arguments to function '"<<$1->getName()<<"'\n";
                }
                else{
                    errorcount++;
                    outputError<<"Line# "<<yylineno<<": Too many arguments to function '"<<$1->getName()<<"'\n";
                }
            }
        }
    }
     $$->addParseList($1);
    $$->addParseList($2);
    $$->addParseList($3);
    $$->addParseList($4);
}|LPAREN expression RPAREN {
    outputLog<<"factor : LPAREN expression RPAREN\n";
    $$=new SymbolInfo("LPAREN expression RPAREN","factor");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$3->endLineNo;
    $$->child=false;
    $$->addParseList($1);
    $$->addParseList($2);
    $$->addParseList($3);
    if($2->typeSpecifier=="VOID"){
        //cout<<"error void\n";//modify
        errorcount++;
        outputError<<"Line# "<<yylineno<<": Void cannot be used in expression\n";
    }
    else{
        $$->typeSpecifier=$2->typeSpecifier;
    }
}|CONST_INT{
    outputLog<<"factor	: CONST_INT\n";
    $$=new SymbolInfo("CONST_INT","factor");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$1->endLineNo;
    $$->typeSpecifier="INT";
    $$->child=false;
    $$->addParseList($1);
    int x=stoi($1->getName());
    if(x==0)zero=true;

}|CONST_FLOAT{
    outputLog<<"factor	: CONST_FLOAT\n";
    $$=new SymbolInfo("CONST_FLOAT","factor");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$1->endLineNo;
    $$->typeSpecifier="FLOAT";
    $$->child=false;
    $$->addParseList($1);
    int x=stoi($1->getName());
    if(x==0)zero=true;
}|variable INCOP{
    outputLog<<"factor	: variable INCOP\n";
    $$=new SymbolInfo("variable INCOP","factor");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$2->endLineNo;
    $$->child=false;
    $$->addParseList($1);
    $$->addParseList($2);
    if($1->typeSpecifier=="VOID"){
        //cout<<"error void\n";//modify
        errorcount++;
        outputError<<"Line# "<<yylineno<<": Void cannot be used in expression\n";
    }
    else $$->typeSpecifier=$1->typeSpecifier;
}|variable DECOP{
    outputLog<<"factor	: variable DECOP\n";
    $$=new SymbolInfo("variable DECOP","factor");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$2->endLineNo;
    $$->child=false;
    $$->addParseList($1);
    $$->addParseList($2);
    if($1->typeSpecifier=="VOID"){
        //cout<<"error void\n";//modify
        errorcount++;
        outputError<<"Line# "<<yylineno<<": Void cannot be used in expression\n";
    }
    else $$->typeSpecifier=$1->typeSpecifier;
}
;
arguement_list : arguements{
    outputLog<<"arguement_list : arguement\n";
    $$ = new SymbolInfo("arguement","arguement_list");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$1->endLineNo;
    $$->child=false;
    $$->addParseList($1);
    for(SymbolInfo* s: parameterList){
        $$->parameter_list.push_back(s);
    }
    parameterList.clear();
}
|{
    outputLog<<"arguement_list : \n";
    $$ = new SymbolInfo("","arguement_list");
    $$->startLineNo=yylineno;
    $$->endLineNo=yylineno;
    $$->child=false;
    for(SymbolInfo* s: parameterList){
        $$->parameter_list.push_back(s);
    }
    parameterList.clear();
}
;
arguements : arguements COMMA logic_expression{
    outputLog<<"arguements : arguements COMMA logic_expression\n";
    $$=new SymbolInfo("arguements COMMA logic_expression","arguements");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$3->endLineNo;
    parameterList.push_back($3);
    $$->child=false;
    $$->addParseList($1);
    $$->addParseList($2);
    $$->addParseList($3);
}|logic_expression{
    outputLog<<"arguements : logic_expression\n";
    $$=new SymbolInfo("logic_expression","arguements");
    $$->startLineNo=$1->startLineNo;
    $$->endLineNo=$1->endLineNo;
    parameterList.push_back($1);
    $$->child=false;
    $$->addParseList($1);
}
;

%%

int main(int argc ,char *argv[]){
    FILE *fp;
    fp=fopen(argv[1],"r");
    outputLog.open("log.txt");
    outputParse.open("parse.txt");
    outputError.open("error.txt");
    yyin=fp;
    yyparse();
    outputLog<<"Total Lines: "<<line<<endl;
    outputLog<<"Total Errors: "<<errorcount<<endl;
}