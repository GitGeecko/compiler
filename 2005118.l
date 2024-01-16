%option noyywrap
%option yylineno
%x STRING_STATE
%x CHAR_STATE
%x SINGLE_COMMENT_STATE
%x MULTI_COMMENT_STATE
%x INDENTATION
%{
	#include<iostream>
	#include<string>
	#include<cstdlib>
	#include<cstring>
	#include<fstream>
	#include"2005118_symboltable.h"
	using namespace std;
	#include "y.tab.h"

    extern YYSTYPE yylval;
	
	int bucketsize=10;	
	int lineCount=1;
	int errorCount=0;
    int warningCount=0;
    int multiline=0,strtyp=0,charcnt=0;
    int tabneed=0,tabfound=0;
	
	SymbolTable *s;
	
	extern ofstream outputLog;

	ofstream tokenOut;
	
    string str;
	string chr;
	string comment;
    string tokenstr,tokenchr,tokencomment;
    char charac;
	
	string capitalise(string s){
		for(char &c:s){
			c=toupper(c);
		}
		return s;
	}
	//logPrint<<"Line# << lineCount<<": Token <"<< capitalise(yytext)<<"> Lexeme " << yytext<<" found\n";
		//tokenPrint<<"< "<<yytext<<", "<<capitalise(yytext)<<">/n";
	void logPrint(int lineCount, string text){
	  	outputLog<<"Line# "<< lineCount<<": Token <"<< capitalise(text)<<"> Lexeme " << text<<" found"<<endl;
	  }
      void tokenPrint(string text){
        tokenOut<<"<"<<capitalise(text)<<", "<<text<<">"<<endl;
      }
      void modTokenOut(string text,string lexeme){
        //tokenOut<<"<"<<text<<", "<<lexeme<<">"<<endl;
    }
%}

DIGIT[0-9]
DIGITS{DIGIT}+
LETTERS[_A-Za-z]
WS[ \f\r\t\v]+
space[ ]
ID{LETTERS}({LETTERS}|{DIGIT})*
EXPONENT([Ee][+-]?{DIGITS})
FLOAT {DIGITS}{EXPONENT}|{DIGITS}\.{DIGITS}{EXPONENT}?|\.{DIGITS}{EXPONENT}?
NEWLINE \r?\n

%%
<INDENTATION>\r?\n {
    //outputLog<<"debug  "<<yytext[0]<<endl;
    lineCount++;
}
<INDENTATION>\t*{space}+ {
    //outputLog<<"Line# "<<lineCount<<": Warning, tab required but got space.\n";
    warningCount++; 
    BEGIN INITIAL;
}
<INDENTATION>\t*"}" {
    if(tabneed!=0)tabneed--;
    int tab=yyleng-1;
    if(tabneed!=tab){
        //outputLog<<"Line# "<<lineCount<<": warning, "<<tabneed<<" of tabs needed but got "<<tab<<" tabs.\n";
        warningCount++;        
    }
    outputLog<<"Line# "<<lineCount<<": Token <" << "RCURL" << "> Lexeme " << yytext <<" found"<<endl;
    modTokenOut("RCURL",yytext);
    tabneed--;
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"RCURL");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return RCURL;
    BEGIN INITIAL;
}
<INDENTATION>[\t]* {
    int tab=yyleng;
    if(tab!=tabneed){
        //outputLog<<"Line# "<<lineCount<<": warning, "<<tabneed<<" of tabs needed but got "<<tab<<" tabs.\n";
        warningCount++;
    }
    BEGIN INITIAL;
}
<INDENTATION>. {

    if(tabneed!=0){
        //outputLog<<"Line# "<<lineCount<<": warning, "<<tabneed<<" of tabs needed but got "<<0<<" tabs.\n";
        warningCount++;
    }
    unput(yytext[0]);
    BEGIN INITIAL;
}
"if" {
    
     logPrint(lineCount,yytext);
    tokenPrint(yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"IF");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return IF;
}

"else" {
    logPrint(lineCount,yytext);
    tokenPrint(yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"ELSE");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return ELSE;
}
"for" {
    logPrint(lineCount,yytext);
    tokenPrint(yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"FOR");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return FOR;
}
"do" {
    logPrint(lineCount,yytext);
    tokenPrint(yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"DO");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return DO;
} 
"while" {
    logPrint(lineCount,yytext);
    tokenPrint(yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"WHILE");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return WHILE;
}
"break" {
    logPrint(lineCount,yytext);
    tokenPrint(yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"BREAK");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return BREAK;
}
"int" {
    logPrint(lineCount,yytext);
    tokenPrint(yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"INT");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return INT;
}
"char" {
    logPrint(lineCount,yytext);
    tokenPrint(yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"CHAR");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return CHAR;
}
"float" {
    logPrint(lineCount,yytext);
    tokenPrint(yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"FLOAT");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return FLOAT;
}
"double" {
    logPrint(lineCount,yytext);
    tokenPrint(yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"DOUBLE");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return DOUBLE;
}
"void" {
    logPrint(lineCount,yytext);
    tokenPrint(yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"VOID");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return VOID;
}
"return" {
    logPrint(lineCount,yytext);
    tokenPrint(yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"RETURN");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return RETURN;
}
"switch" {
    logPrint(lineCount,yytext);
    tokenPrint(yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"SWITCH");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return SWITCH;
}
"case" {
    logPrint(lineCount,yytext);
    tokenPrint(yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"CASE");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return CASE;
}
"continue" {
    logPrint(lineCount,yytext);
    tokenPrint(yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"CONTINUE");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return CONTINUE;
}
"default" {
    logPrint(lineCount,yytext);
    tokenPrint(yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"DEFAULT");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return DEFAULT;
}
"println" {
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"PRNTLN");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return PRNTLN;
}
	
{NEWLINE} {
    lineCount++;
    tabfound=0;
    BEGIN INDENTATION;
}
{WS} {}
{ID} {
    outputLog<<"Line# "<<lineCount<<": Token <" << "ID" << "> Lexeme " << yytext <<" found"<<endl;
    // if(s->insert(yytext,"ID",outputLog)){
    //     s->printAllScopeTable(outputLog);
    // }
    modTokenOut("ID",yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"ID");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return ID;
}
{DIGITS} {
    outputLog<<"Line# "<<lineCount<<": Token <" << "CONST_INT" << "> Lexeme " << yytext <<" found"<<endl;
    tokenOut<<"<CONST_INT"<<", "<<yytext<<">"<<endl;
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"CONST_INT");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->typeSpecifier="INT";
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return CONST_INT;
}
{FLOAT} {
    outputLog<<"Line# "<<lineCount<<": Token <" << "CONST_FLOAT" << "> Lexeme " << yytext <<" found"<<endl;
    tokenOut<<"<CONST_FLOAT"<<", "<<yytext<<">"<<endl;
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"CONST_FLOAT");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->typeSpecifier="FLOAT";
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return CONST_FLOAT;
}
"+"|"-" {
    outputLog<<"Line# "<<lineCount<<": Token <" << "ADDOP" << "> Lexeme " << yytext <<" found"<<endl;
    modTokenOut("ADDOP",yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"ADDOP");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return ADDOP;
}
"*"|"/"|"%" {
    outputLog<<"Line# "<<lineCount<<": Token <" << "MULOP" << "> Lexeme " << yytext <<" found"<<endl;
    modTokenOut("MULOP",yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"MULOP");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return MULOP;
}
"++" { 
    outputLog<<"Line# "<<lineCount<<": Token <" << "INCOP" << "> Lexeme " << yytext <<" found"<<endl;
    modTokenOut("INCOP",yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"INCOP");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return INCOP;
}
"--" { 
    outputLog<<"Line# "<<lineCount<<": Token <" << "DECOP" << "> Lexeme " << yytext <<" found"<<endl;
    modTokenOut("DECOP",yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"DECOP");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return DECOP;
}
"<"|"<="|">"|">="|"=="|"!=" {
    outputLog<<"Line# "<<lineCount<<": Token <" << "RELOP" << "> Lexeme " << yytext <<" found"<<endl;
    modTokenOut("RELOP",yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"RELOP");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return RELOP;
}
"=" {
    outputLog<<"Line# "<<lineCount<<": Token <" << "ASSIGNOP" << "> Lexeme " << yytext <<" found"<<endl;
    modTokenOut("ASSIGNOP",yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"ASSIGNOP");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return ASSIGNOP;
}
"&&"|"||" {
    outputLog<<"Line# "<<lineCount<<": Token <" << "LOGICOP" << "> Lexeme " << yytext <<" found"<<endl;
    modTokenOut("LOGICOP",yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"LOGICOP");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return LOGICOP;
}
"&"|"|"|"^"|"<<"|">>" {
    outputLog<<"Line# "<<lineCount<<": Token <" << "BITOP" << "> Lexeme " << yytext <<" found"<<endl;
    modTokenOut("BITOP",yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"BITOP");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return BITOP;
}
"!" {
    outputLog<<"Line# "<<lineCount<<": Token <" << "NOT" << "> Lexeme " << yytext <<" found"<<endl;
    modTokenOut("NOT",yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"NOT");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return NOT;
}
"(" {
    outputLog<<"Line# "<<lineCount<<": Token <" << "LPAREN" << "> Lexeme " << yytext <<" found"<<endl;
    modTokenOut("LPAREN",yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"LPAREN");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return LPAREN;
}
")" {
    outputLog<<"Line# "<<lineCount<<": Token <" << "RPAREN" << "> Lexeme " << yytext <<" found"<<endl;
    modTokenOut("RPAREN",yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"RPAREN");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return RPAREN;
}
"{" {
    //s->enterScope();
    outputLog<<"Line# "<<lineCount<<": Token <" << "LCURL" << "> Lexeme " << yytext <<" found"<<endl;
    modTokenOut("LCURL",yytext);
    tabneed++;
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"LCURL");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return LCURL;
}
"}" {
    outputLog<<"Line# "<<lineCount<<": Token <" << "RCURL" << "> Lexeme " << yytext <<" found"<<endl;
    modTokenOut("RCURL",yytext);
    tabneed--;
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"RCURL");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return RCURL;
}
"[" {
    outputLog<<"Line# "<<lineCount<<": Token <" << "LTHIRD" << "> Lexeme " << yytext <<" found"<<endl;
    modTokenOut("LTHIRD",yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"LTHIRD");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return LTHIRD;
}
"]" {
    outputLog<<"Line# "<<lineCount<<": Token <" << "RTHIRD" << "> Lexeme " << yytext <<" found"<<endl;
    modTokenOut("RTHIRD",yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"RTHIRD");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return RTHIRD;
}
"," {
    outputLog<<"Line# "<<lineCount<<": Token <" << "COMMA" << "> Lexeme " << yytext <<" found"<<endl;
    modTokenOut("COMMA",yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"COMMA");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return COMMA;
}
";" {
    outputLog<<"Line# "<<lineCount<<": Token <" << "SEMICOLON" << "> Lexeme " << yytext <<" found"<<endl;
    modTokenOut("SEMICOLON",yytext);
    SymbolInfo* symbolInfo=new SymbolInfo(yytext,"SEMICOLON");
    symbolInfo->startLineNo=lineCount;
    symbolInfo->endLineNo=lineCount;
    symbolInfo->child=true;
    yylval.symbolInfo=symbolInfo;
    return SEMICOLON;
}
{DIGITS}\.?{DIGITS}?[Ee][+-]?{FLOAT}* {
    errorCount++;
    outputLog << "Error at line# " << lineCount << ": ILLFORMED_NUMBER " << yytext << '\n';
}
{DIGIT}*\.{DIGIT}*\.{DIGIT}*(\.{DIGIT}*)*{FLOAT}? {
    errorCount++;
    outputLog << "Error at line# " << lineCount << ": TOO_MANY_DECIMAL_POINTS " << yytext << '\n';
}
{DIGIT}*{ID} {
    errorCount++;
    outputLog << "Error at line# " << lineCount << ": INVALID_ID_SUFFIX_NUM_PREFIX " << yytext << '\n';
}


\" {
    str="";
    tokenstr="";
    BEGIN STRING_STATE;
}
<STRING_STATE>\\\r\n {
    multiline++;
    strtyp=1;
    str+="\\";
    str+="\n";
    //tokenstr+=" ";
}
<STRING_STATE>\\\n { 
    multiline++;
    strtyp=1;
    str+="\\";
    str+="\n";
}

<STRING_STATE>\\t {
    str+=yytext;
    tokenstr+="\t";
}
<STRING_STATE>\\\" {
    str+=yytext;
    tokenstr+="\"";
}
<STRING_STATE>\\\' {
    str+=yytext;
    tokenstr+="'";
}
<STRING_STATE>\\\\ {
    str+=yytext;
    tokenstr+="\\";
}
<STRING_STATE>\\a {
    str+=yytext;
    tokenstr+="\a";
}
<STRING_STATE>\\f {
    str+=yytext;
    tokenstr+="\f";
}
<STRING_STATE>\\b {
    str+=yytext;
    tokenstr+="\b";
}
<STRING_STATE>\\v {
    str+=yytext;
    tokenstr+="\v";
}
<STRING_STATE>\\r {
    str+=yytext;
    tokenstr+="\r";
}
<STRING_STATE>\\n {
    str+=yytext;
    tokenstr+="\n";
}
<STRING_STATE>\" {
    str="\""+str+"\"";
    string type="";
    if(strtyp==0){
        type="SINGLE LINE STRING";
    }
    else{
        type="MULTI LINE STRING";
    }
    outputLog << "Line# " << lineCount << ": Token <" << type << "> Lexeme " << str <<" found\n";
    tokenOut<<"<"<<type<<", "<<tokenstr<<">"<<endl;
    lineCount+=multiline;
    multiline=0;
    strtyp=0;
    BEGIN INITIAL;
}
<STRING_STATE>[^\r\n] {
    tokenstr+=yytext;
    str+= yytext;
}
<STRING_STATE>\r?\n {
    errorCount++;
    str="\""+str;
    outputLog << "Error at line# " << lineCount+multiline << ": UNFINISHED_STRING " <<  str <<"\n";
    lineCount+=multiline;
    lineCount++;  //check
    multiline=0;
    strtyp=0;
    BEGIN INITIAL;
}
<STRING_STATE><<EOF>> {
    errorCount++;
    str="\""+str;
    outputLog << "Error at line# " << lineCount+multiline << ": UNFINISHED_STRING " <<  str <<"\n";
    strtyp=0;
    lineCount+=multiline;
    //if(multiline==0)lineCount++; //check
    multiline=0;
    BEGIN INITIAL;
}

\' {
    charcnt=0;
    chr="";
    BEGIN CHAR_STATE;
}
<CHAR_STATE><<EOF>> {
    errorCount++;
    chr="'"+chr;
    //outputLog<<chr.length()<<endl;
    outputLog << "Error at line# " << lineCount<< ": UNFINISHED_CONST_CHAR " <<  chr <<"\n";
    //lineCount++; //check this
    BEGIN INITIAL;
}
<CHAR_STATE>\r?\n {
    errorCount++;
    chr="'"+chr;
    //outputLog<<chr.length()<<endl;
    outputLog << "Error at line# " << lineCount<< ": UNFINISHED_CONST_CHAR " <<  chr <<"\n";
    lineCount++;
    BEGIN INDENTATION;
}
<CHAR_STATE>\\\' {
    charcnt++;
    chr+=yytext;
    charac='\'';    
}
<CHAR_STATE>\\\" {
    charcnt++;
    chr+=yytext;
    charac='\"';    
}
<CHAR_STATE>\\t {
    charcnt++;
    chr+=yytext;
    charac='\t';
}
CHAR_STATE>\\a {
    charcnt++;
    chr+=yytext;
    charac='\a';
}
<CHAR_STATE>\\n {
    charcnt++;
    chr+=yytext;
    charac='\n';
}
<CHAR_STATE>\\r {
    charcnt++;
    chr+=yytext;
    charac='\r';
}
<CHAR_STATE>\\v {
    charcnt++;
    chr+=yytext;
    charac='\v';
}
<CHAR_STATE>\\b {
    charcnt++;
    chr+=yytext;
    charac='\b';
}
<CHAR_STATE>\\0 {
    charcnt++;
    chr+=yytext;
    charac='\0';
}
<CHAR_STATE>\' {
    if(chr==""){
        chr="'"+chr+"'";
        errorCount++;
        outputLog << "Error at line# " << lineCount<< ": EMPTY_CONST_CHAR " <<  chr <<"\n";
    }
    else if(charcnt!=1){
        chr="'"+chr+"'";
        errorCount++;
        outputLog << "Error at line# " << lineCount<< ": MULTICHAR_CONST_CHAR " <<  chr <<"\n";
    }
    else{
        outputLog << "Line# " << lineCount << ": Token <" << "CONST_CHAR" << "> Lexeme " <<charac<<" found\n";
        tokenOut<<"<CONST_CHAR, "<<charac<<">"<<endl;
    }
    BEGIN INITIAL;

}

<CHAR_STATE>. {
    charcnt++;
    chr+=yytext;
    if(charcnt==1)charac=yytext[0];
}

"//" {
    comment="//";
    multiline=0;
    BEGIN SINGLE_COMMENT_STATE;
}

<SINGLE_COMMENT_STATE>\\\r\n { 
    multiline++;
    comment+="\\";
    comment+="\n";
}
<SINGLE_COMMENT_STATE>\\\n { 
    multiline++;
    comment+="\\";
    comment+="\n";
}
<SINGLE_COMMENT_STATE>. {
    comment+=yytext;
}
<SINGLE_COMMENT_STATE><<EOF>> {
    outputLog<<"Line# "<<lineCount<<": Token <"<<"SINGLE LINE COMMENT> Lexeme "<<comment<<" found"<<endl;
    //tokenOut<<"<SINGLE LINE COMMENT, "<<comment<<">"<<endl;
    lineCount+=multiline;
    //if(multiline==0)lineCount++; //check
    multiline=0;
    BEGIN INITIAL;
}
<SINGLE_COMMENT_STATE>\r?\n {
    multiline++;
    outputLog<<"Line# "<<lineCount<<": Token <"<<"SINGLE LINE COMMENT> Lexeme "<<comment<<" found"<<endl;
    //tokenOut<<"<SINGLE LINE COMMENT, "<<comment<<">"<<endl;
    lineCount+=multiline;
    multiline=0;
    BEGIN INDENTATION;
}
"/*" {
    comment="/*";
    multiline=0;
    BEGIN MULTI_COMMENT_STATE;
}
<MULTI_COMMENT_STATE>\r\n {

    multiline++;
    comment+="\r\n";
}
<MULTI_COMMENT_STATE>\n {
    multiline++;
    comment+="\n";
}
<MULTI_COMMENT_STATE><<EOF>> {
    errorCount++;
    outputLog<<"Error at line# "<<lineCount+multiline<<": UNFINISHED_COMMENT "<<comment<<endl;
    lineCount+=multiline;
    //if(multiline==0)lineCount++; //check
    multiline=0;
    BEGIN INITIAL;
}
<MULTI_COMMENT_STATE>"*/" {
    //outputLog<<lineCount<<" "<<multiline<<endl;
    comment+="*/";
    outputLog<<"Line# "<<lineCount<<": Token <MULTI LINE COMMENT> Lexeme "<<comment<<" found\n";
    lineCount+=multiline;
    multiline=0;
    BEGIN INITIAL;
}
<MULTI_COMMENT_STATE>. {
    comment+=yytext[0];
}

. {
    errorCount++;
    outputLog<<"Error at line# "<<lineCount<<": UNRECOGNIZED_CHAR "<<yytext<<endl;
}

%%

/* int main(int argc, char *argv[]) {
    if(argc != 2) {
        //cout << "Please provide input file name and try again\n";f
        return 0;
    }
    s=new SymbolTable(bucketsize);	
    FILE *inputFile = fopen(argv[1], "r");
    if(inputFile == NULL) {
        //cout << "Cannot open specified file\n";
        return 0;
    }
    tokenOut.open("2005118_token.txt");
    outputLog.open("2005118_log.txt");

    //symbolTable->enterScope(scopeTableCounter++, num_of_buckets);

    yyin = inputFile;
    yylex();
    s->printAllScopeTable(outputLog);
    outputLog<<"Total lines: "<<lineCount<<endl;
    outputLog<<"Total errors: "<<errorCount<<endl;
    outputLog<<"Total warnings: "<<warningCount<<endl;
    fclose(yyin);

    //symbolTable->printAllScopeTables(logPrint);

    //logPrint << "Total lines: " << lineCount << '\n';
    //logPrint << "Total errors: " << errorCount << '\n';

    //delete symbolTable;

    //tokenPrint.close();
    //logPrint.close();


    /* ^\t* {
    tabfound+=yyleng;
    if(tabfound!=tabneed){
        outputLog<<"Line# "<<lineCount<<": Warning,"<<tabneed<<" of tabs needed but got "<<tabfound<<" tabs.\n";
        warningCount++;
    }
    }

    return 0;
} */





