%option yylineno

%{
	#include<stdio.h>
	#include<string.h>
	#include"y.tab.h"
	#include<math.h>
%}
%%

"##"(.|\n)*"##"							{strcpy(yylval.var_name, yytext);return COMMENT;}
"Bigf"								{return PROC;}
"main()"							{return MAIN;}
"oof"								{return BGIN;}
":"								{return COLON;}
"endoof"							{return END;}
"f"								{return VAR_START;}
"int"								{yylval.data_type=0; return INT;}
"char"								{yylval.data_type=1; return CHAR;}
"float"								{yylval.data_type=2; return FLOAT;}
"double"							{yylval.data_type=3; return DOUBLE;}
"fin"								{return READ;}
"fout"								{return WRITE;}
"elif"								{return ELSEIF;}
"if"								{return IF;}
"else"								{return ELSE;}
"fif"								{return ENDIF;}
"goto"								{return GOTO;}
"for"								{return FOR;}
"to"								{return TO;}
"do"								{return DO;}
"ffor"								{return ENDFOR;}
"yeet"								{return REPEAT;}
"till"								{return UNTIL;}
"while"								{return WHILE;}
"fwhile"							{return ENDWHILE;}
"("								{return LB;}
")"								{return RB;}
";"								{return SEMICOLON;}
","								{return COMA;}
"="								{return ASSIGNMENT;}
"andf"								{return LAND;}
"orf"								{return LOR;}
">="								{return GEQ;}
"<="								{return LEQ;}
">"								{return GT;}
"<"								{return LT;}
"!="								{return NEQ;}
"=="								{return DEQ;}
"+"								{return PLUS;}
"+="								{return EPLUS;}
"-="								{return EMINUS;}
"-"								{return MINUS;}
"*"								{return MUL;}
"/"								{return DIV;}
"%"								{return MOD;}
"notf"								{return NOT;}
"."								{return DOT;}
"break"								{return BRK;}
'[^'"]*'							{strcpy(yylval.var_name, yytext); return QUOTED_STRING;}
[a-zA-Z]+							{strcpy(yylval.var_name, yytext); return VAR;}
[0-9]+ 								{strcpy(yylval.var_name, yytext); return NUMBER;}
[\n\t ]+							{/* to ignore tabs+spaces+newlines */}

%%

int yywrap(void) {
	return 1;
}

