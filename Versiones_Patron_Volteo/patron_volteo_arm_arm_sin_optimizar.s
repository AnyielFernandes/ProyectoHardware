	AREA codigo, CODE, READONLY
	
	EXPORT 	patron_volteo_arm_arm		

;------------------------------------------------------------------------------------
;	Parámetros recibidos:
;		-Dirección en memoria del tablero 					-> Registro R0
;		-Dirección en memoria del flip (longitud) 			-> Registro R1
;		-fila 												-> Registro R2
;		-columna 											-> Registro R3
;		-SF													-> Pila (R13 + 0)
;		-SC													-> Pila (R13 + 4)
;		-color												-> Pila (R13 + 8)
;
;	Devuelve:
;		-PATRON_ENCONTRADO (1) o NO_HAY_PATRON (0)			-> Registro R0
;		-longitud											-> Mem[@longitud]
;
;	Utiliza los registros:
;		-R0 -> Para guardar la dirección en memoria del tablero
;		-R1 -> Para guardar la dirección en memoria de flip (longitud)
;		-R2 -> Para guardar la fila de la siguiente ficha a comprobar
;		-R3 -> Para guardar la columna de la siguiente ficha a comprobar
;		-R4 -> Para guardar la dirección de fila en la que comprobar el patrón
;		-R5 -> Para guardar la dirección de columna en la que comprobar el patrón
;		-R6 -> Para guardar el color de la última ficha colocada en el tablero
;		-R7 -> Para guardar la ficha a comprobar en el tablero
;		-R8 -> Para guardar si la posición de la casilla comprobada es válida o no
;		-R9 -> Para guardar la longitud del patrón encontrado
;
;------------------------------------------------------------------------------------
	
patron_volteo_arm_arm

	STMDB R13!, {r4-r9,lr}

	ADD R4,R13,#28		;R4=@ de par�metros pasadas por pila
	LDMIA R4,{R4-R6}	;R4=SF, R5=SC y R6=color
	
	ADD R2,R2,R4		;FA=FA+SF (Obviamos la operaci�n AND)
	AND R2,R2,#0xFF		;Convertimos el n�mero en uint8
	ADD R3,R3,R5		;CA=CA+SC (Obviamos la operaci�n AND)
	AND R3,R3,#0xFF		;Convertimos el n�mero en uint8
	
ficha_valida_arm

	CMP R2, #8				;fila<8 (los valores que puede tomar son [0,255])
	CMPLT R3, #8			;columna<8 (los valores que puede tomar son [0,255])
	ADDLT R7,R0,R2,LSL #3	;Momentaneamente R7 se utiliza para indexar tablero
	LDRBLT R7,[R7,R3]		;R7=ficha[f][c]
	NEGLTS R8, R7			;tablero[f][c] != CASILLA_VACIA
	MOVLT R8, #1			;posicion_valida = 1
	MOVGE R7, #0			;ficha = CASILLA_VACIA
	MOVGE R8, #0			;posicion_valida = 0
	
fin_ficha_valida_arm
	 
	CMP R7,R6			;casilla!=color
	CMPNE R8,#0			;posicion_valida!=0 (==1)
	MOVEQ R0,#0			;Patr�n no encontrado
	BEQ fin

	LDR R9,[R1]			;R9=longitud 
	
comienzo_while
	
	ADD R2,R2,R4		;FA=FA+SF (Obviamos la operaci�n AND)
	AND R2,R2,#0xFF		;Convertimos el n�mero en uint8
	ADD R3,R3,R5		;CA=CA+SC (Obviamos la operaci�n AND)
	AND R3,R3,#0xFF		;Convertimos el n�mero en uint8
	ADD R9,R9,#1		;longitud++
	
ficha_valida_arm_while

	CMP R2, #8				;fila<8 (los valores que puede tomar son [0,255])
	CMPLT R3, #8			;columna<8 (los valores que puede tomar son [0,255])
	ADDLT R7,R0,R2,LSL #3
	LDRBLT R7,[R7,R3]		;R7=ficha[f][c]
	NEGLTS R8, R7			;tablero[f][c] != CASILLA_VACIA
	MOVLT R8, #1			;posicion_valida = 1
	MOVGE R7, #0			;ficha = CASILLA_VACIA
	MOVGE R8, #0			;posicion_valida = 0

fin_ficha_valida_arm_while	
	
	CMP R7,R6			;casilla!=color
	CMPNE R8,#0			;posicion_valida!=0 (==1)
	BNE comienzo_while
	
fin_while

	STR R9,[R1]			;Guardar longitud (flip)

	CMP R6,R7 			;ficha==color
	CMPEQ R8,#1			;posicion_valida==1
	SUBEQ R9,#1			;restamos 1 a longitud
	LSREQS R9,R9,#31	;miramos si el bit de signo es 0 (positivo -> longitud>0)
	MOVEQ R0,#1			;Patr�n encontrado
	MOVNE R0,#0			;Patr�n no encontrado
	
fin
	LDMIA R13!, {r4-r9,pc}
	
	END