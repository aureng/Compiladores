/*

	Elaboro: Aurelio Rojas Eng, Emilio Garcia Sanchez
	Fecha de entrega: 17 de marzo de 2022

*/
%{
#include <stdio.h>
#include <stdlib.h>
int valor;
int i,j; //Solo sirve para hacer iteraciones
FILE *tablaSimbolos; //Crea el txt para la tabla de simbolos
FILE *tablaLiteralesCadenas; //Lo mismo 
FILE *tablaLiteralesConstantes; // Tambien
FILE *tablaTokens; //Es la salida mas importante, tiene todos en uno mismo
//Funciones para generar tokens
void agregarTablaLiteralesCadenas(); //Aqui se meten puras cadenas
void agregarTablaSimbolos();  //Solo identificadores
void agregarTablaLiteralesReales();  //Puros numeros reales
void agregarToken(int clase, int valor);
//Enteros, simbolos especiales y operadores dan como tal en los tokens.

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
{palabra_reservada}    {agregarToken(4, valor);}
{op_aritmetico}     {int valor; int bandera=0;
			for(i=0; i<6; i++){
				for(j=0; j<yyleng; j++){
					if(tabla_op_aritmetico[i][j] != yytext[i]) bandera=1;
				}
				if(bandera == 0) valor = i;
			}
			agregarToken(6, valor);}
{op_asignacion}     {agregarToken(3, valor);}
{op_relacional}     {agregarToken(2, valor);}
{identificador}     {agregarTablaSimbolos();
			agregarToken(0, valor);}
{const_cadena}     {agregarToken(7,valor);}
{const_num_real}     {agregarToken(8, valor);}
{const_num_entera}     {agregarToken(1, valor);}
{especial}     {agregarToken(5,(int)*yytext);}
{error}    {printf("No se encuentra %s",yytext);}
%%
void agregarTablaSimbolos(){
}

void agregarToken(int clase, int valor){
	printf("\nClase: %d, Valor: %d",clase,valor);	
}

int main(int argc, char *argv[]){	
	yyin = fopen(argv[1],"r");
	yylex();
	return(0);
}
