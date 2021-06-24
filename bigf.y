%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	int yylex(void);
	int yyerror(const char *s);
	int success = 1;
	int cur_dtype;
	int expn_type = -1;
	int temp;
	int idx = 0;
	int table_idx = 0;
	int tab_count = 0;
	char for_var[30];
	struct symbol_table{char var_name[30]; int type;} sym[20];
	extern int lut(char var[30]);
	extern void insert_to_table(char var[30], int type);
	extern void print_tabs();
	char var_list[20][30];	//Creating a list allowing 20 variables of 30 character names
	int string_or_var[20];
	extern int *yytext;
%}
%union{
int data_type;
char var_name[30];
}

%token NUMBER PROC MAIN BGIN COLON END ASSIGNMENT VAR_START COMA SEMICOLON VAR READ LB RB WRITE QUOTED_STRING IF ELSE ENDIF GEQ LEQ GT LT NEQ DEQ NOT LAND LOR GOTO ELSEIF FOR TO DO ENDFOR PLUS MINUS MUL DIV MOD REPEAT UNTIL WHILE ENDWHILE COMMENT DOT BRK EPLUS EMINUS

%left LAND LOR GEQ LEQ NOT GT LT NEQ DEQ PLUS MINUS MUL DIV MOD

%token<data_type>INT
%token<data_type>CHAR
%token<data_type>FLOAT
%token<data_type>DOUBLE

%type<data_type>TYPE
%type<var_name>VAR

%start prm
%%

prm:	 			PROC MAIN BGIN COLON{
						printf("#include<stdio.h>\nint main()\n{\n");
						tab_count++;
					}
					STATEMENTS END COLON{
						printf("}\n");
					}

STATEMENTS: 		STATEMENTS {print_tabs();} STATEMENT
					| ;

STATEMENT: 			VAR_START DOT TYPE DOT VAR_LIST SEMICOLON {
						if(cur_dtype == 0)
							printf("int ");
						else if(cur_dtype == 1)
							printf("char ");
						else if(cur_dtype == 2)
							printf("float ");
						else if(cur_dtype == 3)
							printf("double ");
						for(int i = 0; i < idx - 1; i++){
							insert_to_table(var_list[i], cur_dtype);	
							printf("%s,", var_list[i]);
						}
						insert_to_table(var_list[idx - 1], cur_dtype);
						printf("%s;\n", var_list[idx - 1]);
						idx = 0;
					}
					| VAR {
							printf("%s", yylval.var_name);
							if((temp=lut(yylval.var_name))!=-1) {
								if(expn_type==-1)
									expn_type=temp;
								else if(expn_type!=temp) {
									printf("\n type mismatch in the expression\n");
									yyerror("");
									exit(0);
								}
							}
							else {
								printf("\n variable \" %s\" undeclared\n", yylval.var_name);
								yyerror("");
								exit(0);
							}
							expn_type=-1;
					} 
					ASSIGNMENT {printf("=");} A_EXPN SEMICOLON {
						printf(";\n");
					}
					| READ LB READ_VAR_LIST RB SEMICOLON {
						printf("scanf(\"");
						for(int i = 0; i < idx; i++) {
							if((temp=lut(var_list[i])) != -1) {
								if(temp==0)
									printf("%%d");
								else if(temp==1)
									printf("%%c");
								else if(temp==2)
									printf("%%f");
								else
									printf("%%e");
							}
							else
							{
								printf("Cannot read undeclared variable %s !", yylval.var_name);
								yyerror("");
								exit(0);
							}
						}
						printf("\"");
						for(int i = 0; i < idx; i++) {
							printf(",&%s", var_list[i]);
						}
						printf(");\n");
						idx=0;
					}

					| WRITE LB WRITE_VAR_LIST RB SEMICOLON {
						char *s;
						printf("printf(\"");
						for(int i = 0; i < idx; i++) {
							if(string_or_var[i] == 1) {
								s = var_list[i];
								s++;
								s[strlen(s)-1] = 0;
								printf("%s", s);
							}
							else {	
								if((temp=lut(var_list[i])) != -1) {
									if(temp==0)
										printf("%%d");
									else if(temp==1)
										printf("%%c");
									else if(temp==2)
										printf("%%f");
									else
										printf("%%e");
								}
								else
								{
									printf("Cannot read undeclared variable %s !", yylval.var_name);
									yyerror("");
									exit(0);
								}
							}
						}
						printf("\"");
						for(int i = 0; i < idx; i++) {
							if(string_or_var[i] != 1)
								printf(",%s", var_list[i]);
						}
						printf(");\n");
						idx = 0;
					}
					| IF_BLOCK ELSEIF_BLOCKS ELSE_BLOCK ENDIF
					| IF_BLOCK ENDIF
					| GOTO {printf("goto ");} 
    				  VAR {printf("%s", yylval.var_name);} 
					  SEMICOLON {printf(";\n");}
					| FOR LB {printf("for(");} 
					  VAR_START DOT VAR {strcpy(for_var, yylval.var_name); printf("%s", for_var);} 
					  ASSIGNMENT {printf("=");}
					  TERMINALS {printf("; %s", for_var);} 
					  UNTIL {printf("<=");} 
					  A_EXPN {printf(";");}
					  COMA VAR_START PLUS {printf("%s++", for_var);}
					  RB DO {printf("){\n"); tab_count++;} 
					  STATEMENTS ENDFOR {tab_count--;print_tabs();printf("}\n");}
					| REPEAT {printf("do{\n");tab_count++;}
					  STATEMENTS UNTIL LB {tab_count--;print_tabs();printf("}while(");} 
				      A_EXPN RB {printf(");\n");}
					| WHILE LB {tab_count++; printf("while(");}
					  A_EXPN RB DO {printf("){\n");}
					  STATEMENTS ENDWHILE {tab_count--;print_tabs();printf("}\n");}
					| VAR COLON {printf("\b\b\b\b\b\b\b\b%s:\n", yylval.var_name);}
					| COMMENT {printf("/%s/\n", yylval.var_name);}
					| BRK SEMICOLON {printf("break;\n");}

IF_BLOCK:		 	IF LB {printf("if(");} 
					A_EXPN RB {printf("){\n");tab_count++;} DO
					STATEMENTS
					{tab_count--;print_tabs();printf("}\n");}
					  	

ELSEIF_BLOCKS:		ELSEIF_BLOCKS ELSEIF_BLOCK
					| ;


ELSEIF_BLOCK:		ELSEIF LB {print_tabs();printf("else if(");}
					A_EXPN RB {printf("){\n");tab_count++;} DO
					STATEMENTS
					{tab_count--;print_tabs();printf("}\n");}

ELSE_BLOCK: 	    ELSE {print_tabs();printf("else{\n");tab_count++;} 
					STATEMENTS
					{tab_count--;print_tabs();printf("}\n");}
				
VAR_LIST: 			VAR {
						strcpy(var_list[idx], $1); 
						idx++;
					} COMA VAR_LIST
					| VAR {
						strcpy(var_list[idx], $1); 
						idx++;
					}


TYPE : 				INT {
						$$=$1;
						cur_dtype=$1;	
					}
					| CHAR  {
						$$=$1;
						cur_dtype=$1;
					}
					| FLOAT {
						$$=$1;
						cur_dtype=$1;
					}
					| DOUBLE {
						$$=$1;
						cur_dtype=$1; 
					}

WRITE_VAR_LIST:		QUOTED_STRING {
						strcpy(var_list[idx], yylval.var_name); 
						string_or_var[idx]=1; 
						idx++;
					} COMA WRITE_VAR_LIST
					| VAR {
						strcpy(var_list[idx], yylval.var_name); 
						idx++;
					} COMA WRITE_VAR_LIST
					| QUOTED_STRING{
						strcpy(var_list[idx], yylval.var_name);
						string_or_var[idx]=1;
						idx++;
					}
					| VAR{
						strcpy(var_list[idx], yylval.var_name);
						idx++;
					}

READ_VAR_LIST:		VAR {
						strcpy(var_list[idx], yylval.var_name); 
						idx++;
					} COMA READ_VAR_LIST
					| VAR {
						strcpy(var_list[idx], yylval.var_name); 
						idx++;
					}

A_EXPN: 		A_EXPN LAND {printf("&&");} A_EXPN
				| A_EXPN LOR {printf("||");} A_EXPN
	 			| A_EXPN LEQ {printf("<=");} A_EXPN
				| A_EXPN GT {printf(">");} A_EXPN
				| A_EXPN LT {printf("<");} A_EXPN
				| A_EXPN NEQ {printf("!=");} A_EXPN
				| A_EXPN DEQ {printf("==");} A_EXPN
				| NOT {printf("!");} A_EXPN 
				| A_EXPN PLUS {printf("+");} A_EXPN
				| A_EXPN MINUS {printf("-");} A_EXPN
				| A_EXPN MUL {printf("*");} A_EXPN
				| A_EXPN DIV {printf("/");} A_EXPN
				| A_EXPN MOD {printf("%%");} A_EXPN
				| A_EXPN EPLUS {printf("%s+", for_var);} A_EXPN	
				| TERMINALS

TERMINALS:			VAR {
						if((temp=lut(yylval.var_name))!=-1) {
							printf("%s", yylval.var_name);
							if(expn_type==-1){
								expn_type=temp;
							}
							else if(expn_type!=temp){
								printf("\ntype mismatch in the expression\n");
								yyerror("");
								exit(0);
							}
						}
						else{
							printf("\n variable \"%s\" undeclared\n", yylval.var_name);
							yyerror("");
							exit(0);
						}
					}
					| NUMBER {printf("%s", yylval.var_name);}


%%

int lut(char var[30])
{
	for(int i=0; i<table_idx; i++)
	{
		if(strcmp(sym[i].var_name, var)==0)
			return sym[i].type;
	}
	return -1;
}

void insert_to_table(char var[30], int type)
{
	if(lut(var)==-1)
	{
		strcpy(sym[table_idx].var_name,var);
		sym[table_idx].type = type;
		table_idx++;
	}
	else {
		printf("Multiple declaration of variable\n");
		yyerror("");
		exit(0);
	}
}

void print_tabs() {
	for(int i = 0; i < tab_count; i++){
		printf("\t");
	}
	return;
}

int main() {
	yyparse();
	return 0;
}

int yyerror(const char *msg) {
	extern int yylineno;
	printf("Parsing failed\nLine number: %d %s\n", yylineno, msg);
	success = 0;
	return 0;
}
