/*

	Elaboraron: 		Aurelio Rojas Eng, Emilio Garcia Sanchez
	
	Fecha de entrega: 	29 de abril de 2022
	
	Descripcion: 		Este programa es de un analizador sintactico, con el cual partiendo de lo visto anteriormente con el analizador lexico,
				Vamos a poder realizar la lectura de un archivo de entrada con el cual se va a poder leer y describir todos los errores
				sintacticos mediante la creacion de una cadena de atomos con el que podremos realizar lo dicho anteriormente. 
				Finalmente, podremos ver en un archivo de texto .txt la salida de nuestros errores y en donde tenemos dichos errores.
*/
%{
#include <stdio.h>
#include <stdlib.h>

//Declaracion de variables auxiliares
int valor; 									//Variable auxiliar para conseguir tokens
int i,j;									//Variables auxiliares para el uso de ciclos
int numL=1;									//Variable auxiliar para conocer el numero de linea en el que se encuentra
char c;

//Apuntadores de archivos para la creacion de salidas .txt
FILE *tablaSimbolos; 								//Crea el txt para la tabla de simbolos
FILE *tablaLiteralesCadenas; 							//Crea el txt para la tabla de literales de cadenas
FILE *tablaLiteralesReales; 							//Crea el txt para la tabla de literales de constantes reales
FILE *tablaTokens; 								//Es la salida mas importante, genera los tokens con los valores y las clases
FILE *tablaErrores;								//Archivo exclusivamente para errores, mostrando el error y la linea.
FILE *entrada;									//Entrada .txt del analizador sintactico

//Funciones para crear las Tablas de ayuda, los operadores, palabras reservadas, constantes reales y caracteres especiales tienen sus propias tablas.
void agregarTablaLiteralesCadenas(int posicion, char cadena[]); 		//Tabla de ayuda para las cadenas. Debe llevar posicion, y la cadena
void agregarTablaSimbolos(int posicion, char nombre[]);  			//Tabla de ayuda para identificadores. Tiene posicion, nombre del identificador y valor entero en -1
void agregarTablaLiteralesReales(int posicion, char constReal[]);  		//Tabla de ayuda para los numeros reales. Lleva la posicion y la constante real
void agregarToken(int clase, int valor);					//Sirve dando el numero de la clase y el valor en tablas o de la constante, si fuera el caso.
void agregarTablaErrores(char error[], int linea);				//Tabla auxiliar para conseguir numero de errores, el error y la linea del error. Utiliza la variable auxiliar numL
//int  calcularDecimal(char );
void agregarParser(char token);							//AGREGA A UN ARCHIVO TODOS LOS TOKENS NECESARIOS CONFORME SE VAYAN LEYENDO COLOCANDOLOS EN ENTRADA
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
//Estos son utilizados para el analizador sintactico.
char tokenPalRes[11][2]={"s","d","t","f","h","m","u","p","i","w","v"};
char tokenOpRel[6][2]={">","<","=","g","l","!"};
char tokenOpAsig[9][2]={"e","b","c","j","o","q","x","y","z"};
char tokenOpAri[6][2]={"+","-","*","/","%","^"};

//Definicion de las producciones No-Terminales
void Program();
void Decl();
void MasFunc();
void otraFunc();
void D();
void Tipo();
void L();
void Func();
void TipoF();
void Param();
void otroParam();
void R();
void H();
void M();
void P();
void I();
void Llama();
void arg();
void otroArg();
void Devuelve();
void Valor();
void otroValor();
void A();
void opasig();
void E();
void EP();
void T();
void TP();
void F();
void expRel();
void contER();
void opRel();
void S();

//Estructuras de listas ligadas utilizadas para la identificacion de variables repetidas
/*struct node{
	char var[];
	struct node *siguiente;
}

void crearNodo(char iden[]){
	struct node *temp, *ptr;
	temp=(struct node *)malloc(sizeof(struct node));
	if(temp==NULL){
		printf("Fuera de memoria\n");
		exit(0);
	}
	&temp -> var[] = iden[]
}*/

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
				agregarParser(tokenPalRes[valor][0]);
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
				agregarParser(tokenOpAri[valor][0]);
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
				agregarParser(tokenOpAsig[valor][0]);
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
				agregarParser(tokenOpAsig[valor][0]);
			}
{identificador}     	{
				char lectura[yyleng];
				strcpy(lectura,yytext);
				agregarToken(0, tamS);
				agregarTablaSimbolos(tamS, lectura);
				agregarParser('a');
			}
{const_cadena}     	{
				char lectura[40];
				strcpy(lectura,yytext);
				agregarToken(7,tamC);
				agregarTablaLiteralesCadenas(tamC, lectura);
				agregarParser('k');
			}
{const_num_real}     	{
				char lectura[yyleng];
				strcpy(lectura, yytext);
				agregarToken(8, tamR);
				agregarTablaLiteralesReales(tamR, lectura);
				agregarParser('r');
			}
{const_num_entera}     	{
				char lectura[yyleng];
				strcpy(lectura, yytext);
				fprintf(tablaTokens,"clase: 1\tvalor: %-5s\n",lectura);
				agregarParser('n');
			}
{especial}     		{
				agregarToken(5,(int)*yytext);
				agregarParser(*yytext);
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

void agregarParser(char token){
	fprintf(entrada,"%c",token);
}

int main(int argc, char *argv[]){	
	//Se abren los archivos de texto antes del yylex() para poder manejarlos en las funciones correspondientes en forma de escritura
	tablaLiteralesCadenas = fopen("TablaLiteralesCadenas.txt","w");	
	tablaLiteralesReales = fopen("TablaLiteralesReales.txt","w");	
	tablaSimbolos = fopen("TablaSimbolos.txt","w");
	tablaTokens = fopen("TablaTokens.txt","w");
	tablaErrores = fopen("TablaErorres.txt","w");
	entrada = fopen("TokensSintacticos.txt","w");

	//Se corre el codigo con una entrada.txt para poder analizarlo
	yyin = fopen(argv[1],"r");
	yylex();
		
	//Se cierra el archivo y se vuelve a abrir inmediatamente como solo lectura para evitar conflictos con escritura.
	fclose(entrada);
	entrada = fopen("TokensSintacticos.txt","r");
	char c = getc(entrada);
	Program();			//Empieza el Analizador Sintactico a partir de aqui y solo se usa getc(entrada) para leer cada caracter.
	if(c=='\0'){
		printf("El programa esta correcto sintacticamente. Felicidades!\n");
	}else{
		printf("Hubieron errores sintacticos en el programa, checa los .txt para mas informacion\n");
	}

	//Despues de terminar el yylex() y Program()  se cierran los archivos para que no haya problema de sobreescritura
	fclose(tablaLiteralesCadenas);
	fclose(tablaLiteralesReales);
	fclose(tablaSimbolos);
	fclose(tablaErrores);
	fclose(entrada);
	printf("\nSe termino de leer el programa fuente. Consulta las tablas en los archivos .txt generados.\n");
	return(0);
}

void Program(){
	if(c=='s'||c=='t'||c=='f'){
		Decl();
		if(c=='{'){
			c=getc(entrada);
			MasFunc();
			if(c=='}'){
				c=getc(entrada);
			}else{
				printf("Se esperaba un }\n");
			}
		}else{
			printf("Se esperaba un {\n");
			return;				//Produccion 1
		}		
	}else{
		printf("Hubo un error en la estructura del programa\n");
	}
}
void Decl(){
	if(c=='{'){
		return;					//Produccion 2
	}else if(c=='s'||c=='t'||c=='f'){
		D();
		Decl();
		return;	//Produccion 3
	}else{
		printf("Hubo un error en las declaraciones\n}");
		return;
	}		
}
void MasFunc(){
	if(c=='v'||c=='s'||c=='t'||c=='f'){
		Func();
		otraFunc();
		return;		//Produccion 4
	}
}
void otraFunc(){
	if(c=='v'||c=='s'||c=='t'||c=='f'){
		Func();
		otraFunc();
		return;		//Produccion 5
	}else if(c=='}'){
		return;		//Produccion 6
	}
}
void D(){
	if(c=='s'||c=='t'||c=='f'){
		Tipo();
		if(c=='a'){
			c=getc(entrada);
			L();
			return;	//Produccion 7
		}else{
			printf("se esperaba un identificador\n");
		}
	}else{
		printf("Hubo un error en la sentencia declarativa\n");
		return;
	}
}
void Tipo(){
	if(c=='s'){
		c=getc(entrada);
		return;		//Prod 8
	}else if(c=='t'){
		c=getc(entrada);
		return;		//Prod 9
	}else if(c=='f'){
		c=getc(entrada);
		return;		//Prod 10
	}else{
		printf("hubo un error en la declaracion de tipo\n");
		return;
	}
}
void L(){
	if(c==':'){
		c=getc(entrada);
		if(c=='a'){
			L();
			return;	//Prod 11
		}
	}else if(c=='.'){
		c=getc(entrada);
		return;		//Prod 12
	}else{
		printf("Se esperaba un .\n");
		return;
	}
}
void Func(){
	if(c=='v'||c=='s'||c=='t'||c=='f'){
		TipoF();
		if(c=='a'){
			c=getc(entrada);
			if(c=='('){
				c==getc(entrada);
				Param();
				if(c==')'){
					c=getc(entrada);
					if(c=='{'){
						c=getc(entrada);
						R();
						if(c=='}'){
							c=getc(entrada);
							return;				//Prod 13
						}else{printf("Se esperaba un }\n");}
					}else{printf("Se esperaba un {\n");}
				}else{printf("Se esperaba un )\n");}
			}else{printf("Se esperaba un (\n");}
		}else{printf("Se esperaba un identificador\n");}
	}else{
		printf("Hubo un error con las funciones\n");
		return;
	}
}
void TipoF(){
	if(c=='s'||c=='t'||c=='f'){
		Tipo();
		return;	//Prod 14
	}else if(c=='v'){
		c=getc(entrada);
		return; //Prod 15
	}else{
		printf("Hubo un error en la sentencia declarativa\n");
		return;
	}
}
void Param(){
	if(c=='s'||c=='t'||c=='f'){
		Tipo();
		if(c=='a'){
			c=getc(entrada);
			otroParam();
			return; 	//prod 16
		}
	}else if(c==')'){
		return; //Prod 17
	}else{
		printf("Hubo un error en la definicion de parametros\n");
		return;
	}
}
void otroParam(){
	if(c==':'){
		c=getc(entrada);
		Tipo();
		if(c=='a'){
			c=getc(entrada);
			otroParam();
			return;	//Prod 18
		}
	}else if(c==')'){
		return;		//Prod 19
	}else{
		printf("Hubo un error en la definicion de parametros\n");
		return;
	}
}
void R(){
	if(c=='}'){
		return;		//prod 20
	}else if(c=='s'||c=='t'||c=='f'||c=='a'||c=='h'||c=='m'||c=='p'||c=='i'||c=='{'||c=='d'){
		S();
		R();
		return; //Prod 21
	}else{
		printf("Hubo un error en R\n");
		return;
	}
}
void H(){
	if(c=='h'){
		c=getc(entrada);
		if(c=='{'){
			c=getc(entrada);
			S();
			R();
			if(c=='}'){
				c=getc(entrada);
				if(c=='m'){
					c=getc(entrada);
					if(c=='('){
						c=getc(entrada);
						expRel();
						if(c==')'){
							c=getc(entrada);
							if(c=='.'){
								c=getc(entrada);
								return;	//Prod 22	
							}else{printf("Se esperaba un .\n");}	
						}else{printf("Se esperaba un )\n");}	
					}else{printf("Se esperaba un (\n");}	
				}else{printf("Se esperaba un token m\n");}	
			}else{printf("Se esperaba un }\n");}
		}else{printf("Se esperaba un {\n");}	
	}else{
		printf("Se esperaba un token h\n");
		return;
	}
}
void M(){
	if(c=='m'){
		c=getc(entrada);
		if(c=='('){
			c=getc(entrada);
			expRel();
			if(c==')'){
				c=getc(entrada);
				if(c=='{'){
					c=getc(entrada);
					S();
					R();
					if(c=='}'){
						c=getc(entrada);
						if(c=='.'){
							c=getc(entrada);
							return;	//Prod 23
						}else{printf("Se esperaba un .\n");}	
					}else{printf("Se esperaba un }\n");}	
				}else{printf("Se esperaba un {\n");}	
			}else{printf("Se esperaba un )\n");}
		}else{printf("Se esperaba un (\n");}	
	}else{
		printf("Se esperaba un token m\n");
		return;
	}
}
void P(){
	if(c=='p'){
		c=getc(entrada);
		if(c=='n'){
			c=getc(entrada);
			if(c=='{'){
				c=getc(entrada);
				R();
				if(c=='}'){
					c=getc(entrada);
					if(c=='.'){
						c=getc(entrada);
						return; //prod 24	
					}else{printf("Se esperaba un .\n");}	
				}else{printf("Se esperaba un }\n");}	
			}else{printf("Se esperaba un {\n");}
		}else{printf("Se esperaba un token n\n");}	
	}else{
		printf("Se esperaba un token p\n");
		return;
	}
}
void I(){
	if(c=='i'){
		c=getc(entrada);
		if(c=='('){
			c=getc(entrada);
			expRel();
			if(c==')'){
				c=getc(entrada);
				if(c=='{'){
					c=getc(entrada);
					R();
					if(c=='}'){
						c=getc(entrada);
						if(c=='w'){
							c=getc(entrada);
							if(c=='{'){
								c=getc(entrada);
								R();
								if(c=='}'){
									c=getc(entrada);
									if(c=='.'){
										c=getc(entrada);
										return; //Prod 25
									}else{printf("Se esperaba un .\n");}
								}else{printf("Se esperaba un }\n");}
							}else{printf("Se esperaba un {\n");}	
						}else{printf("Se esperaba un token w\n");}	
					}else{printf("Se esperaba un }\n");}	
				}else{printf("Se esperaba un {\n");}	
			}else{printf("Se esperaba un )\n");}
		}else{printf("Se esperaba un (\n");}	
	}else{
		printf("Se esperaba un token i\n");
		return;
	}
}
void Llama(){
	if(c=='{'){
		c=getc(entrada);
		if(c=='a'){
			c=getc(entrada);
			if(c=='('){
				c=getc(entrada);
				arg();
				if(c==')'){
					c=getc(entrada);
					if(c=='}'){
						c=getc(entrada);
						if(c=='.'){
							c=getc(entrada);
							return; //Prod 26	
						}else{printf("Se esperaba un .\n");}	
					}else{printf("Se esperaba un }\n");}	
				}else{printf("Se esperaba un )\n");}	
			}else{printf("Se esperaba un (\n");}
		}else{printf("Se esperaba un a\n");}	
	}else{
		printf("Se esperaba un {\n");
		return;
	}
}
void arg(){
	if(c==')'){
		return;	//Prod 27
	}else if(c=='a'){
		c=getc(entrada);
		otroArg();
		return;	//Prod 28
	}else{
		printf("Se esperaba un identificador\n");
		return;
	}
}
void otroArg(){
	if(c==':'){
		c=getc(entrada);
		if(c=='a'){
			c=getc(entrada);
			otroArg();
			return;	//Prod 29
		}else{printf("Se esperaba un identificador\n");}
	}else if(c==')'){
		return;	//Prod 30
	}else{
		printf("Se esperaba un :\n");
		return;
	}
}
void Devuelve(){
	if(c=='d'){
		c=getc(entrada);
		if(c=='('){
			Valor();
			c=getc(entrada);
			if(c==')'){
				c=getc(entrada);
				if(c=='.'){
					c=getc(entrada);
					return; //Prod 31
				}else{printf("Se esperaba un .\n");}	
			}else{printf("Se esperaba un )\n");}
		}else{printf("Se esperaba un (\n");}	
	}else{
		printf("Se esperaba un token d\n");
		return;
	}
}
void Valor(){
	if(c=='a'){
		c=getc(entrada);
		return;		//prod 32
	}else if(c=='n'){
		c=getc(entrada);
		return;	//Prod 33
	}else if(c=='r'){
		c=getc(entrada);
		return;	//Prod 34
	}else if(c=='u'||c=='k'){
		otroValor();
		return;	//Prod 35
	}else{
		printf("Hubo un error en el valor\n");
		return;
	}
}
void otroValor(){
	if(c=='u'){
		c=getc(entrada);
		return;		//prod 36
	}else if(c=='k'){
		c=getc(entrada);
		return;	//Prod 37
	}else{
		printf("Hubo un error en el valor\n");
		return;
	}
}
void A(){
	if(c=='a'){
		c=getc(entrada);
		opasig();
		E();
		if(c==':'){
			c=getc(entrada);
			return; //Prod 38
		}else{printf("Se esperaba un :\n");}	
	}else{
		printf("Se esperaba un identificador.\n");
		return;
	}
}
void opasig(){
	if(c=='e'){
		c=getc(entrada);
		return;		//prod 39
	}else if(c=='b'){
		c=getc(entrada);
		return;	//Prod 40
	}else if(c=='j'){
		c=getc(entrada);
		return;	//Prod 41
	}else if(c=='o'||c=='k'){
		otroValor();
		return;	//Prod 42
	}else if(c=='q'){
		c=getc(entrada);
		return;	//Prod 43
	}else if(c=='x'){
		c=getc(entrada);
		return;	//Prod 44
	}else if(c=='y'){
		c=getc(entrada);
		return;	//Prod 45
	}else if(c=='z'){
		c=getc(entrada);
		return;	//Prod 46
	}else{
		printf("Hubo un error en la asignacion.\n");
		return;
	}
}
void E(){
	if(c=='('||c=='a'||c=='r'||c=='n'||c=='{'){
		T();
		EP();
		return;	//Prod 47
	}else{
		printf("Error en la expresion aritmetica.\n");
		return;
	}
}
void EP(){
	if(c=='+'){
		c=getc(entrada);
		T();
		EP();
		return;	//Prod 48
	}else if(c=='-'){
		c=getc(entrada);
		T();
		EP();
		return;	//Prod 49
	}else if(c==':'||c==')'||c=='>'||c=='<'||c=='='||c=='g'||c=='l'||c=='!'){
		return;	//Prod 50
	}else{
		printf("Error en la expresion aritmetica.\n");
		return;
	}
}
void T(){
	if(c=='a'||c=='r'||c=='n'||c=='{'){
		F();
		TP();
		return;	//Prod 51
	}else{
		printf("Error en la expresion aritmetica.\n");
		return;
	}
}
void TP(){
	if(c=='*'){
		c=getc(entrada);
		F();
		TP();
		return;		//prod 52
	}else if(c=='/'){
		c=getc(entrada);
		F();
		TP();
		return;	//Prod 53
	}else if(c=='%'){
		c=getc(entrada);
		F();
		TP();
		return;	//Prod 54
	}else if(c=='^'){
		c=getc(entrada);
		F();
		TP();
		return;	//Prod 55
	}else if(c=='+'||c=='-'||c==':'||c==')'||c=='>'||c=='<'||c=='='||c=='g'||c=='l'||c=='!'){
		return;	//Prod 56
	}else{
		printf("Error en la expresion aritmetica.\n");
		return;
	}
}
void F(){
	if(c=='('){
		c=getc(entrada);
		E();
		if(c==')'){
			c=getc(entrada);
			return;	//Prod 57
		}else{printf("Se esperaba un )\n");}	
	}else if(c=='a'){
		c=getc(entrada);
		return;	//Prod 58
	}else if(c=='r'){
		c=getc(entrada);
		return;	//Prod 59
	}else if(c=='n'){
		c=getc(entrada);
		return;	//Prod 60
	}else if(c=='{'){
		Llama();
		return;	//Prod 61
	}else{
		printf("Error en la expresion aritmetica.\n");
		return;
	}
}
void expRel(){
	if(c=='('||c=='a'||c=='r'||c=='n'||c=='{'){
		E();
		contER();
		return; //Prod 62
	}else{
		printf("Error en la expresion regular");
		return;
	}
}
void contER(){
	if(c==')'){
		return;	//Prod 63
	}else if(c=='>'||c=='<'||c=='='||c=='g'||c=='l'||c=='!'){
		opRel();
		E();
		return;	//Prod 64
	}
}
void opRel(){
	if(c=='>'){
		c=getc(entrada);
		return;	//Prod 65	
	}else if(c=='<'){
		c=getc(entrada);
		return;	//Prod 66
	}else if(c=='='){
		c=getc(entrada);
		return;	//Prod 67
	}else if(c=='g'){
		c=getc(entrada);
		return;	//Prod 68
	}else if(c=='l'){
		c=getc(entrada);
		return;	//Prod 69
	}else if(c=='!'){
		c=getc(entrada);
		return;	//Prod 70
	}else{
		printf("Error en el operador relacional.\n");
		return;
	}
}
void S(){
	if(c=='s'||c=='t'||c=='f'){
		D();
		return;	//Prod 71
	}else if(c=='a'){
		A();
		return;	//Prod 72
	}else if(c=='h'){
		H();
		return;	//Prod 73
	}else if(c=='m'){
		M();
		return;	//Prod 74
	}else if(c=='p'){
		P();
		return;	//Prod 75
	}else if(c=='i'){
		I();
		return;	//Prod 76
	}else if(c=='{'){
		Llama();
		return;	//Prod 77
	}else if(c=='d'){
		Devuelve();
		return;	//Prod 78
	}else{
		printf("Error en las sentencias\n");
		return;
	}
}

