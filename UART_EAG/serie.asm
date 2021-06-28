;; Este programa recibe mediante interrupciones un valor por el puerto serie
;; usando 9600 baudios 8.N.1.
;; Acumula todos los bytes recibidos en un buffer y cuando llega un '*'
;; devuelve mediante serie (usando polling por cada byte enviado) el inverso
;; de los datos recibidos.

;; Para enviar / recibir datos usando el simulador:
;; View > Serial Receiver / Serial Transmitter

;;; Posiciones de memoria donde se controla el puerto serie
BAUD		EQU		$102B
SCC2		EQU		$102D
SCDR		EQU		$102F
SCSR		EQU		$102E
ROM		EQU		$C000
RWM		EQU		$0000
RESET		EQU		$FFFE
SERIE		EQU		$FFD6


;;; Variables
		ORG		RWM
BUFFER		RMB		50    ;; Buffer para guardar lo que llega por serie
BUFFPOINTER	RMB		1     ;; Puntero al ultimo byte del buffer
FLAGTX		RMB		1     ;; Bandera para indicar que hay que transmitir


;;; Programa principal
		ORG		ROM
MAIN:
		; apunto el puntero al comienzo del buffer y limpio flagTX
		CLR		BUFFPOINTER
		CLR		FLAGTX

		;Seteo el puerto serie en 9600 bauds
		; Esto se define en la pagina 113 del datasheet
		LDAA		#%00110000
		STAA		BAUD

		;Prendo las interrupciones para recibir serie
		; Ver pagina 111 del manual
		LDAA		#%00101100
		STAA		SCC2

		;Activo las interrupciones globales
		CLI
		
		; Rutina principal... verifica si tengo que mandar
		; algo por puerto serie. Si es asi, llama a SendSerie
WaitFlag:	LDAA		FLAGTX
		BEQ		WaitFlag
		CLR		FlAGTX
		JSR		SendSerie
		BRA		WaitFlag



;;;;;;;;; Rutina SendSerie
;;;;
;;;;  Envia por puerto serie byte a byte los valores del buffer.
;;;;  NO utiliza interrupciones, por ende debe esperar a que cada
;;;;  byte sea enviado para enviar el siguiente.
SendSerie:
		; Busco el fin del buffer
		LDAB		BUFFPOINTER
		LDX		#BUFFER
		ABX
		
LoopSend:
		; Verifico si estoy al principio del buffer
		DEX
		CPX		#BUFFER-1
		BEQ		FinLoop
		LDAA		0,X
		;En A tengo el valor a enviar
		;Necesito verificar que el puerto serie
		;esta libre para enviar bytes. Esto se hace
		;leyendo el bit mas significativo de SCSR.
		; Si el bit esta en 0, entonces se puede transmitir
WaitTX		
		LDAB		SCSR
		ANDB		#%10000000
		BEQ		WaitTX
		;Para transmitir escribo el byte en SCDR
		STAA		SCDR
		BRA		LoopSend
FinLoop:
		CLR		BUFFPOINTER
		RTS

;;;;;;;;;; Rutina de servicio a la interrupcion de puerto serie

		ORG		$C300
SERIAL_ISR:
		;; Hay que leer SCSR y verificar cual fue la interrupcion
		;; que disparo la rutina. Como en este caso solo esta encendida
		;; la interrupcion de recepcion de bytes, solo leemos el valor
		;; pero no verificamos nada. El Hardware REQUIERE leer este valor
		;; siempre aunque no lo usemos para nada. Esto limpia internamente
		;; los flags sino vuelve a dispararse la interrupcion luego del RTI.
		LDAA		SCSR

		;; Busco en que lugar del buffer se puede escribir
		LDAB		BUFFPOINTER
		LDX		#BUFFER
		ABX

		;; Leo del puerto serie el valor recibido.
		LDAA		SCDR
		;; Lo guardo en el buffer
		STAA		0,X

		;; En el caso que haya sido un asterisco, levanto el flag
		;; de fin de mensaje para que se transmita el buffer invertido.
		CMPA		#'*'
		BNE		Sigue
		LDAA		#1
		STAA		FlagTX
		;; Incremento el puntero de buffer
Sigue		INC		BUFFPOINTER
		;; Fin de la interrupcion
		RTI

		ORG		SERIE
		dw		SERIAL_ISR

		ORG		RESET
		dw		MAIN


