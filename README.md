# BigF
BigF is a small step I took in designing my own computer programming language. Using Lex and Yacc, which are tools for creating a compiler, I have created one such compiler which takes syntax written in my language (BigF) and converts it to C.

steps to set up the compiler and run a sample program:

	$ flex project.l
	$ yacc -dv project.y
	$ gcc -o mini-compiler lex.yy.c y.tab.c -lfl
	$./mini-compiler < squarenumbers.c 
(Make sure that the compiler and the file to be executed are in the same folder)

Check out the Documentation file for information about the language
