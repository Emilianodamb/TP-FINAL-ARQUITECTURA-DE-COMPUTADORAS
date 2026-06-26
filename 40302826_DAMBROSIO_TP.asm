;----------------------------------------------------------------------
;-------- Trabajo práctico final de Arquitectura de Computadoras ------
;------------------ Tema: Programación en assembler -------------------
;----------------------------------------------------------------------
;- Consigna: Crear un programa en assembler que controle el circuito --
;- de una bomba para simular su detonación. ---------------------------
;----------------------------------------------------------------------
;- Componentes principales del circuito:
;-  PIC16F84A ---------------->	Para controlar componentes del circuito
;-  Buzzer ------------------->	Para los sonidos de la cuenta regresiva	
;-	Speaker	------------------>	Reproduce el sonido de la bomba
;-	Botón -------------------->	Envía el pulso al pin RA3	
;-  Display de 7 segmentos --->	Para simular el reloj de la bomba
;----------------------------------------------------------------------
;- 	Configuración de los puertos:
;-  	PUERTO A:
;-  RA1 -> Salida ------------>	Emite el pulso para controlar el buzzer
;-  RA3 -> Entrada ----------->	Recibe un pulso del botón
;-	RA0, RA2, RA4 ------------>	No se utilizan
;-  	PUERTO B:
;-	Todos los puertos son asignados como Salida
;-  RB0 a RB6 ----------------> Controlan el display de 7 segmentos 
;-	RB7 ----------------------> Emite un pulso para activar el speaker
;----------------------------------------------------------------------

	#include <p16f84a.inc>

	__CONFIG _WDT_OFF
	
	ORG 	0x00
	CBLOCK 0x0C				;Asigno variables a registros
    	CONTADOR1			;Creo la variable CONTADOR1 para el contador del loop exterior
    	CONTADOR2			;Creo la variable CONTADOR2 para el contador del loop intermiedio
    	CONTADOR3			;Creo la variable CONTADOR3	para el contador del loop interior
		CONTADORCUARTOS		;Creo la variable CONTADORCUARTOS para dividir un segundo en 4
		CUENTAREGRESIVA		;Creo la variable CUENTAREGRESIVA para controlar la cuenta regresiva
	ENDC					
	GOTO 	INICIO			;Salto al inicio del programa

INICIO:
	CLRW					;Limpio el registro de trabajo seteando en 0 todos sus bits
	BSF		STATUS,5		;Seteo en 1 el bit RP0 del registro STATUS para seleccionar el banco 1 para trabajar con TRISA y TRISB
	MOVLW	0x08			;Coloco el literal 00001000 en W
	MOVWF	TRISA			;Seteo el pin RA3 como entrada y el pin RA1 como salida, el resto como salida aunque no los voy a utilizar
	CLRF	TRISB			;Limpio el registro TRISB seteando en 0 todos sus bits para configurarlos como salida
	BCF		STATUS,5		;Seteo en 0 el bit RP0 del registro STATUS para seleccionar el banco 0 para trabajar con PORTA y PORTB
	CLRF	PORTA			;Limpio el registro PORTA seteando en 0 todos sus bits para trabajar con el posteriormente
	CLRF	PORTB			;Limpio el registro PORTB seteando en 0 todos sus bits para trabajar con el posteriormente

ESCUCHAR_BOTON:
	BTFSC	PORTA,3			;Espera un 1 para detonar la bomba
	GOTO	CONFIRMAR_BOTON	;Salta a una rutina con delay que confirma el estado del pin RA3 para confirmar la señal del botón y evitar un rebote
	GOTO	ESCUCHAR_BOTON	;Si llega un cero vuelve al inicio del loop en espera de un 1

CONFIRMAR_BOTON:			;MANEJA EL REBOTE DEL BOTÓN
	CALL	DELAY_20MS		;Llama a una subrutina que pruoduce un retraso de 20 milisegundos
	BTFSC	PORTA,3			;Confirma que el pin RA3 continue recibiendo un 1
	GOTO	DETONAR			;Al recibir un uno en la linea anterior saltamos a la rutina que inicia la detonación
	GOTO	ESCUCHAR_BOTON	;Si el pin RA3 no recibe un 1 despues del delay, vuelve a ESCUCHAR_BOTON

DETONAR:
	CALL	REGRESIVA		;Va a la subrutina que inicia la cuenta regresiva
	GOTO	EXPLOSION		;Salta al codigo etiquetado como EXPLOSION que ejecuta las directivas finales del programa

REGRESIVA:
	MOVLW	d'9'			;Coloco el literal 9 en el registro W
	MOVWF	CUENTAREGRESIVA	;Asigno 9 al registro CUENTAREGRESIVA
LOOP_REGRESIVA:
	MOVF	CUENTAREGRESIVA, W	;Muevo el valor de CUENTAREGRESIVA a W 
	CALL	TABLA_DISPLAY	;Llamo a la subrutina TABLA_DISPLAY
	MOVWF	PORTB			;Coloca el valor que devuelve TABLA_DISPLAY en PORTB para simular un numero
	CALL	DELAY_1S		;Llama a la subrutina que genera un delay de 1 segundo entre cada iteración de la cuenta regresiva
	DECFSZ	CUENTAREGRESIVA, F	;Decrementa en 1 el valor la variable CUENTAREGRESIVA y almacena el resultado en el mismo registro, si es 0 salta la siguiente linea, de lo contrario la ejecuta
	GOTO	LOOP_REGRESIVA	;Vuelve a iniciar el loop de la cuenta regresiva con el nuevo valor de CUENTAREGRESIVA
	RETURN					;Finaliza la subrutina y vuelve a la instrucción siguiente a la llamada

EXPLOSION:
	MOVLW	b'10111111'		;Coloco el literal 10111111 (en binario)
	MOVWF	PORTB			;Coloco un 0 en el display y un 1 en el pin RB7 para activar el speaker
	SLEEP					;Finaliza el programa mientras queda sondando el speaker


DELAY_1S:
	MOVLW	D'3'			;Coloco el literal 3 en W
	MOVWF	CONTADORCUARTOS	;Coloco un 3 en el registro CONTADORCUARTOS para completar 3/4 de segundo con el buzzer desactivado
	BSF		PORTA,1			;Seteo en 1 el bit 1 del registro PORTA para activar el buzzer 
	CALL	DELAY_1_4_S		;Delay de 1/4 de segundo con buzzer activado
	BCF		PORTA,1			;Seteo en 0 el bit 1 del registro PORTA para desactivar el buzzer
LOOP_CUARTOS:				;Delay de 3/4 de segundo restantes en silencio
	CALL 	DELAY_1_4_S		;Llama a la subrutina que genera un delay de 1/4 de segundo
	DECFSZ	CONTADORCUARTOS, F	;Decrementa en 1 la variable CONTADORCUARTOS y la guarda en el mismo registro, si es 0 salta la siguiente linea, de lo contrario la ejecuta
	GOTO 	LOOP_CUARTOS	;Salta a LOOP_CUARTOS donde vuelve a iniciar el loop con el nuevo valor de la variable CONTADORCUARTOS
	RETURN					;Finaliza la subrutina y vuelve a la instrucción siguiente a la llamada

DELAY_1_4_S:				
    MOVLW   D'3'        	;Coloco el literal 3 en W
    MOVWF   CONTADOR1       ;Coloco un 3 en el registro CONTADOR1 para repetir 3 veces el contador exterior
LOOP1:
    MOVLW   D'110'          ;Coloco el literal 110 en W
    MOVWF   CONTADOR2		;Coloco un 110 en el registro CONTADOR2 para repetir 110 veces el contador intermedio
LOOP2:
    MOVLW   D'250'          ;Coloco el literal 250 en W
    MOVWF   CONTADOR3		;Coloco un 250 en el registro CONTADOR3 para repetir 250 veces el contador interior
LOOP3:
    DECFSZ  CONTADOR3, F	;Decrementa en 1 la variable CONTADOR3 y la guarda en el mismo registro, si es 0 salta la siguiente linea, de lo contrario la ejecuta
    GOTO    LOOP3			;Salta a LOOP3, donde vuelve a iniciar el loop interno con el nuevo valor de la variable CONTADOR3
    DECFSZ  CONTADOR2, F	;Decrementa en 1 la variable CONTADOR2 y la guarda en el mismo registro, si es 0 salta la siguiente linea, de lo contrario la ejecuta
    GOTO    LOOP2			;Salta a LOOP2, donde vuelve a iniciar el loop intermedio con el nuevo valor de la variable CONTADOR2
    DECFSZ  CONTADOR1, F	;Decrementa en 1 la variable CONTADOR1 y la guarda en el mismo registro, si es 0 salta la siguiente linea (donde sale del bucle), de lo contrario la ejecuta  
	GOTO    LOOP1			;Salta a LOOP1, donde vuelve a iniciar el loop exterior con el nuevo valor de la variable CONTADOR1
    RETURN                  ;Finaliza la subrutina y vuelve a la instrucción siguiente a la llamada

DELAY_20MS:					
    MOVLW   D'27'           ;Coloco el literal 27 en W
    MOVWF   CONTADOR1       ;Coloco un 27 en el registro CONTADOR1 para repetir 27 veces el contador exterior
D20_LOOP1:
    MOVLW   D'250'          ;Coloco el literal 250 en W
    MOVWF   CONTADOR2       ;Coloco un 250 en el registro CONTADOR2 para repetir 250 veces el contador interior
D20_LOOP2:
    DECFSZ  CONTADOR2, F    ;Decrementa en 1 la variable CONTADOR2 y la guarda en el mismo registro, si es 0 salta la siguiente línea, de lo contrario la ejecuta
    GOTO    D20_LOOP2       ;Salta a D20_LOOP2, donde vuelve a iniciar el loop interno con el nuevo valor de la variable CONTADOR2
    DECFSZ  CONTADOR1, F    ;Decrementa en 1 la variable CONTADOR1 y la guarda en el mismo registro, si es 0 salta la siguiente línea (donde sale del bucle), de lo contrario la ejecuta
    GOTO    D20_LOOP1       ;Salta a D20_LOOP1, donde vuelve a iniciar el loop exterior con el nuevo valor de la variable CONTADOR1
    RETURN                  ;Finaliza la subrutina y vuelve a la instrucción siguiente a la llamada


TABLA_DISPLAY:
    ADDWF 	PCL, F			;Suma W al contador bajo de programa y lo guarda en el mismo registro
    RETLW 	b'00111111' 	;Devuelve el literal 0 en W para el display
    RETLW 	b'00000110' 	;Devuelve el literal 1 en W para el display
    RETLW 	b'01011011' 	;Devuelve el literal 2 en W para el display
    RETLW 	b'01001111' 	;Devuelve el literal 3 en W para el display
    RETLW 	b'01100110' 	;Devuelve el literal 4 en W para el display
    RETLW 	b'01101101' 	;Devuelve el literal 5 en W para el display
    RETLW 	b'01111101' 	;Devuelve el literal 6 en W para el display
    RETLW 	b'00000111' 	;Devuelve el literal 7 en W para el display
    RETLW	b'01111111' 	;Devuelve el literal 8 en W para el display
    RETLW	b'01101111' 	;Devuelve el literal 9 en W para el display

	END