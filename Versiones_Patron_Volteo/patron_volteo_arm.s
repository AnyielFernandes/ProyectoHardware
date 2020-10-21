;---------------------------------------------------------------
;	Fichero: patron_volteo_arm.s
;	Autores: Carlos Borau González, 778280
;		     Anyiel Fernandes Araujo, 779374
; 	Última Modificación: 21/10/2020
;	Descripción: Versión en código ensamblador de patron_volteo.
;				 Se mantiene la llamada a ficha_valida
;---------------------------------------------------------------

	AREA codigo, CODE, READONLY
	
	EXPORT 	patron_volteo_arm		
	IMPORT ficha_valida
		
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
;		-R4  -> Para guardar la dirección en memoria del tablero
;		-R5  -> Para guardar la dirección en memoria de flip (longitud)
;		-R6  -> Para guardar la fila de la siguiente ficha a comprobar
;		-R7  -> Para guardar la columna de la siguiente ficha a comprobar
;		-R8  -> Para guardar la dirección de fila en la que comprobar el patrón
;		-R9  -> Para guardar la dirección de columna en la que comprobar el patrón
;		-R10 -> Para guardar el color de la última ficha colocada en el tablero
;		-R11 -> Para guardar la longitud del patrón encontrado
;
;------------------------------------------------------------------------------------

patron_volteo_arm

	STMDB R13!, {r3-r11,lr}

	MOV R4,R0			;R4=@tablero
	MOV R5,R1 			;R5=@flip // longitud
	MOV R6,R2			;R6=fila
	MOV R7,R3			;R7=columna
	ADD R8,R13,#40		;Momentaneamente R8=@ de par�metros pasadas por pila
	LDMIA R8,{R8-R10}	;R8=SF, R9=SC y R10=color
	
	ADD R6,R6,R8		;FA=FA+SF
	AND R6,R6,#0xFF		;Convertimos el n�mero en uint8
	ADD R7,R7,R9		;CA=CA+SC
	AND R7,R7,#0xFF		;Convertimos el n�mero en uint8

	MOV R1,R6			;Paso de FA por registro
	MOV R2,R7			;Paso de CA por registro
	MOV R3,R13			;Paso de @posicion_valida por registro
	BL ficha_valida
	
	CMP R0,R10			;casilla!=color
	LDRNE R1,[R13]		;R1=posicion valida
	CMPNE R1,#0			;posicion_valida!=0 (==1)
	MOVEQ R0,#0			;Patr�n no encontrado
	BEQ fin
	
	LDR R11,[R5]		;R11=longitud 
	
comienzo_while
	
	ADD R6,R6,R8		;FA=FA+SF
	AND R6,R6,#0xFF		;Convertimos el n�mero en uint8
	ADD R7,R7,R9		;CA=CA+SC
	AND R7,R7,#0xFF		;Convertimos el n�mero en uint8
	ADD R11,R11,#1		;longitud++
	
	MOV R0,R4			;Paso de @tablero por registro
	MOV R1,R6			;Paso de FA por registro
	MOV R2,R7			;Paso de CA por registro
	MOV R3,R13			;Paso de @posicion_valida por registro
	BL ficha_valida
	
	CMP R0,R10			;casilla!=color
	LDRNE R1,[R13]		;R1=posicion valida
	CMPNE R1,#0			;posicion_valida!=0 (==1)
	BNE comienzo_while
	
fin_while

	STR R11,[R5]		;Guardar longitud (flip)

	CMP R0,R10			;ficha==color
	LDREQ R1,[R13]		;R1=posicion_valida
	CMPEQ R1,#1			;posicion_valida==1
	SUBEQ R11,#1		;restamos 1 a longitud
	LSREQS R11,R11,#31	;miramos si el bit de signo es 0 (positivo -> longitud>0)
	MOVEQ R0,#1			;Patr�n encontrado
	MOVNE R0,#0			;Patr�n no encontrado
	
fin
	LDMIA R13!, {r3-r11,pc}
	
	END