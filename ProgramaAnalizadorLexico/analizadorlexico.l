/*

	Elaboro: Aurelio Rojas Eng, Emilio Garcia Sanchez
	Fecha de entrega: 17 de marzo de 2022

*/
%{
#include <stdio.h>
#include <stdlib.h>

int i;
//A PARTIR DE AQUI SOLO ES LA CREACION DE LOS CATALOGOS O LAS TABLAS QUE NO SE MODIFICAN
char tabla_palabras_reservadas[11][9]={	"cadena",
					"devuelve",
					"entero",
					"flotante",
					"hacer",
					"mientras",
					"nulo",
					"para",
					"si",
					"sino",
					"vacio"	};

char tabla_op_relacional[6][5]={"<M>", "<m>", "<=>", "<M=>", "<m=>", "<$=>"};
char tabla_op_asignacion[9][4]={"i_i", "M_i", "m_i", "a_i", "d_i", "p_i", "A_i", "P_i", "B_i"};
char tabla_op_aritmetico[6][5]={"sum", "res", "mult", "div", "mod", "pow"};
//TERMINA EL APARTADO PARA LOS CATALOGOS
%}
identificador    [0-9][A-Za-z_]+|[A-Za-z][A-Za-z0-9_]*
const_num_entera    [1-9][0-9]*|0[0-7]|0[xX][0-9A-Fa-f]+
op_relacional    <[mM=]>|<[mM$]=>
op_asignacion    [iMmadpAPB]_i
palabra_reservada    "cadena"|"devuelve"|"entero"|"flotante"|"hacer"|"mientras"|"nulo"|"para"|"si"|"sino"|"vacio"
especial    [.:{}()]
op_aritmetico    "sum"|"res"|"mult"|"div"|"mod"|"pow"
const_cadena    \"[^"]{0,38}\"
const_num_real    [0-9]*\.[0-9]+|[0-9]+\.[0-9]*
error    [^{identificador}|{const_num_entera}|{op_relacional}|{op_asignacion}|{palabra_reservada}|{especial}|{op_aritmetico}|{const_cadena}|{const_num_real}|\h|\n|" "]
%%
{palabra_reservada}    {printf("Se acepto %s como palabra reservada\n",yytext);}
{op_aritmetico}     {printf("Se acepto %s como operador aritmetico\n",yytext);}
{op_asignacion}     {printf("Se acepto %s como operador de asignacion\n",yytext);}
{op_relacional}     {printf("Se acepto %s como operador relacional\n",yytext);}
{identificador}     {printf("Se acepto %s como identificador\n",yytext);}
{const_cadena}     {printf("Se acepto %s como constante cadena\n",yytext);}
{const_num_real}     {printf("Se acepto %s como constante numerica real\n",yytext);}
{const_num_entera}     {printf("Se acepto %s como constante numerica entera\n",yytext);}
{especial}     {printf("Se acepto %s como caracter especial\n",yytext);}
{error}    {printf("%s no es valido para ningun caso\n",yytext);}
%%
int main(int argc, char *argv){
	
	yylex();
	/*
	yyin() = fopen(argv[1],"r");
	*/
	return(0);
}
