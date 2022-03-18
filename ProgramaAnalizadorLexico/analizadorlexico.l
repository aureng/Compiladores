/*

	Elaboraron: 		Aurelio Rojas Eng, Emilio Garcia Sanchez
	
	Fecha de entrega: 	18 de marzo de 2022
	
	Descripcion: 		Este programa es un analizador lexico con base en los requisitos mostrados y cumpliendo con el orden de clases y valores.
				Nuestro analizador lexico es puede leer una entrada de texto y conseguir las diferentes tablas de valores, asi como la de
				tokens, dentro de un formato .txt. Esta entrada de texto debe estar contenida dentro de las reglas definidas por la rubri
				ca de las clases y las expresiones regulares. Se adjunta un archivo entrada.txt para prueba del mismo.
*/
%{
#include <stdio.h>
#include <stdlib.h>

//Declaracion de variables auxiliares
int valor; 									//Variable auxiliar para conseguir tokens
int i,j;									//Variables auxiliares para el uso de ciclos
int numL=1;									//Variable auxiliar para conocer el numero de linea en el que se encuentra

//Apuntadores de archivos para la creacion de salidas .txt
FILE *tablaSimbolos; 								//Crea el txt para la tabla de simbolos
FILE *tablaLiteralesCadenas; 							//Crea el txt para la tabla de literales de cadenas
FILE *tablaLiteralesReales; 							//Crea el txt para la tabla de literales de constantes reales
FILE *tablaTokens; 								//Es la salida mas importante, genera los tokens con los valores y las clases
FILE *tablaErrores;								//Archivo exclusivamente para errores, mostrando el error y la linea.

//Funciones para crear las Tablas de ayuda, los operadores, palabras reservadas, constantes reales y caracteres especiales tienen sus propias tablas.
void agregarTablaLiteralesCadenas(int posicion, char cadena[]); 		//Tabla de ayuda para las cadenas. Debe llevar posicion, y la cadena
void agregarTablaSimbolos(int posicion, char nombre[]);  			//Tabla de ayuda para identificadores. Tiene posicion, nombre del identificador y valor entero en -1
void agregarTablaLiteralesReales(int posicion, char constReal[]);  		//Tabla de ayuda para los numeros reales. Lleva la posicion y la constante real
void agregarToken(int clase, int valor);					//Sirve dando el numero de la clase y el valor en tablas o de la constante, si fuera el caso.
void agregarTablaErrores(char error[], int linea);				//Tabla auxiliar para conseguir numero de errores, el error y la linea del error. Utiliza la variable auxiliar numL
int  calcularDecimal(char );
//Banderas para conocer la posicion de los valores en sus respectivas listas. Todas inicializadas en 0 por ser globales.
int tamC, tamS, tamR, tamT, tamE;

//Apuntadores de las tablas, sirven de ayuda para conseguir las listas ligadas.
//NOTA: No fue necesario utilizarlos, pero pueden ser de utilidad para crear las listas ligadas en caso que sea necesario.
char  *apuntadorCadenas; 
char  *apuntadorSimbolos;
float *apuntadorReales;
int   *apuntadorTokens;

//Creacion de las tablas/catalogos fijos, con los valores declarados por nuestros requisitos
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
%}
identificador           [0-9][A-Za-z_]+|[A-Za-z][A-Za-z0-9_]*
const_num_entera        [1-9][0-9]*|0[0-7]|0[xX][0-9A-Fa-f]+
op_relacional           <[mM=]>|<[mM$]=>
op_asignacion           [iMmadpAPB]_i
palabra_reservada       "cadena"|"devuelve"|"entero"|"flotante"|"hacer"|"mientras"|"nulo"|"para"|"si"|"sino"|"vacio"
especial                [.:{}()]
op_aritmetico           "sum"|"res"|"mult"|"div"|"mod"|"pow"
const_cadena            \"[^"]{0,38}\"
const_num_real          [0-9]*\.[0-9]+|[0-9]+\.[0-9]*
newline                 [\n]       
error                   [^{identificador}|{const_num_entera}|{op_relacional}|{op_asignacion}|{palabra_reservada}|{especial}|{op_aritmetico}|{const_cadena}|{const_num_real}|\t|" "|\r|\v]
%%
{palabra_reservada}	{
				int valor, bandera;
				char lectura[9];
				strcpy(lectura, yytext);
				for(i=0; i<11; i++){
					bandera=0;
					for(j=0; j<yyleng; j++){
						if(tabla_palabras_reservadas[i][j] != lectura[j]){
							bandera=1;
						}
					}
				if(bandera == 0) valor = i;
				}
				agregarToken(4, valor);
			}
{op_aritmetico}     	{
				int valor, bandera;
				char lectura[5];
				strcpy(lectura, yytext);
				for(i=0; i<6; i++){
					bandera=0;
					for(j=0; j<yyleng; j++){
						if(tabla_op_aritmetico[i][j] != lectura[j]){
							bandera=1;
						}
					}
					if(bandera == 0) valor = i;
				}
				agregarToken(6, valor);
			}
{op_asignacion} 	{
				int valor, bandera;
				char lectura[5];
				strcpy(lectura, yytext);
				for(i=0; i<6; i++){
					bandera=0;
					for(j=0; j<yyleng; j++){
						if(tabla_op_asignacion[i][j] != lectura[j]){
							bandera=1;
						}
					}
					if(bandera == 0) valor = i;
				}
				agregarToken(3, valor);
			}
{op_relacional}     	{	
				int valor, bandera;
				char lectura[4];
				strcpy(lectura, yytext);
				for(i=0; i<9; i++){
					bandera=0;
					for(j=0; j<yyleng; j++){
						if(tabla_op_relacional[i][j] != lectura[j]){
							bandera=1;
						}
					}
					if(bandera == 0) valor = i;
				}
				agregarToken(2, valor);
			}
{identificador}     	{
				char lectura[yyleng];
				strcpy(lectura,yytext);
				agregarToken(0, tamS);
				agregarTablaSimbolos(tamS, lectura);
			}
{const_cadena}     	{
				char lectura[40];
				strcpy(lectura,yytext);
				agregarToken(7,tamC);
				agregarTablaLiteralesCadenas(tamC, lectura);
			}
{const_num_real}     	{
				char lectura[yyleng];
				strcpy(lectura, yytext);
				agregarToken(8, tamR);
				agregarTablaLiteralesReales(tamR, lectura);
			}
{const_num_entera}     	{
				char lectura[yyleng];
				strcpy(lectura, yytext);
				fprintf(tablaTokens,"clase: 1\tvalor: %-5s\n",lectura);
			}
{especial}     		{
				agregarToken(5,(int)*yytext);
			}
{newline}		{
				numL++;
			}
{error}    		{
				char lectura[yyleng];
				strcpy(lectura, yytext);
				tamE++;
				agregarTablaErrores(lectura, numL);
			}
%%
void agregarTablaSimbolos(int posicion, char nombre[]){
	fprintf(tablaSimbolos,"posicion: %-5didentificador: %-20s valor: -1\n", posicion, nombre);
	tamS++;
}

void agregarTablaLiteralesCadenas(int posicion, char cadena[]){
	fprintf(tablaLiteralesCadenas,"posicion: %-5dcadena: %-40s\n", posicion, cadena);
	tamC++;
}

void agregarTablaLiteralesReales(int posicion, char constReal[]){
	fprintf(tablaLiteralesReales,"posicion: %-5dvalor: %-40s\n", posicion, constReal);
	tamR++;
}

void agregarToken(int clase, int valor){
	fprintf(tablaTokens,"clase: %d\tvalor: %-5d\n", clase, valor);
	tamT++;
}

void agregarTablaErrores(char error[], int linea){
	fprintf(tablaErrores,"Se encontro como error %s, en la linea %d\n",error,linea);
}

int main(int argc, char *argv[]){	
	//Se abren los archivos de texto antes del yylex() para poder manejarlos en las funciones correspondientes en forma de escritura
	tablaLiteralesCadenas = fopen("TablaLiteralesCadenas.txt","w");	
	tablaLiteralesReales = fopen("TablaLiteralesReales.txt","w");	
	tablaSimbolos = fopen("TablaSimbolos.txt","w");
	tablaTokens = fopen("TablaTokens.txt","w");
	tablaErrores = fopen("TablaErorres.txt","w");
	
	//Se corre el codigo con una entrada.txt para poder analizarlo
	yyin = fopen(argv[1],"r");
	yylex();

	//Despues de terminar el yylex() se cierran los archivos para que no haya problema de sobreescritura
	fclose(tablaLiteralesCadenas);
	fclose(tablaLiteralesReales);
	fclose(tablaSimbolos);
	fclose(tablaErrores);
	printf("\nSe termino de leer el programa fuente. Consulta las tablas en los archivos .txt generados.\n");
	return(0);
}
