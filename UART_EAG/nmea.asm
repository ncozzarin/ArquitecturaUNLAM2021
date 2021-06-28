;; Este programa recibe por serie un STRING NMEA
;; Ej: $GNRMC,094807.00,A,3439.283676,S,05831.227410,W,0.0,,020720,5.3,W,A,V*6F
;; Verifica el checksum y muestra la fecha y hora en el LCD.
;; Si el checksum es invalido, muestra E (error)

ROM		EQU		$C000
RWM		EQU		$0000
RESET		EQU		$FFFE
SERIE		EQU		$FFD6
LCDDATA		EQU		$1040

;;; Posiciones de memoria donde se controla el puerto serie
BAUD		EQU		$102B
SCC2		EQU		$102D
SCDR		EQU		$102F
SCSR		EQU		$102E

;;; Los datos NMEA tienen un largo maximo de 83 bytes
NMEAMAX		EQU		83

;;; Variables
		ORG		RWM
FLAG		RMB		1	;; Flag para indicar llego NMEA
BUFFPOINTER	RMB		1	;; Puntero a buffer
BUFFER		RMB		NMEAMAX ;; Buffer para guardar lo que llega por serie


;;; Programa principal
		ORG		ROM
MAIN:
		; apunto el puntero al comienzo del buffer y limpio flagTX
		CLR		BUFFPOINTER
		CLR		FLAG
		CLR		LCDDATA

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
	
		;;Main Loop, esperando flag
WaitFlag:	LDAA		FLAG
		BEQ		WaitFlag
		CLR		FLAG
		JSR		MuestraHora
		CLR		BUFFPOINTER ;; ya no lo usamos mas
					;;Lo apuntamos al inicio para
					;;seguir recibiendo
		BRA		WaitFlag

;;Esta rutina verifica si el checksum es valido
;; Retorna: Carry=0, Checksum Invalido
;; 	 	 Carry=1, Checksum Valido
ValidaChecksum:
		;;Buffpointer esta apuntando al fin del NMEA
		;;Convertimos los dos ultimos bytes
		;;que son HEX representado en ASCII en un 
		;;valor
;;Ejemplo: $GNRMC,094807.00,A,2439.283676,S,05831.227410,W,0.0,,020720,5.3,W,A,V*6F = $6F
		LDAB		BUFFPOINTER
		DECB
		LDX		#BUFFER
		ABX		;;Ahora X apunta al fin del buffer -1
		LDAA		0,X ;Parte alta, convertimos a BYTE
		JSR		ASCIIHEX2BYTE
		LSLA
		LSLA
		LSLA
		LSLA 		;;Multiplicamos por 16
		TAB		;;Guardamos en B el valor
		INX	
		LDAA		0,X ;Parte baja, convertimos a BYTE
		JSR		ASCIIHEX2BYTE
		ABA		;;Suma A+B = A
		PSHA		;;Guardamos el checksum en el Stack
		JSR		CALCULACHKSUM
		PULB		
		CBA		;;Resto A-B, si son iguales pongo carry en 1
		BEQ		RETCARRY1
		CLC		;; Carry = 0 ya que el Checksum es invalido
		RTS
RETCARRY1
		SEC		;; Carry = 1 ya que el Checksum es valido
		RTS

;;Realiza Xor de todos los valores entre $ y *
;; Ejemplo: $GNRMC,094807.00,A,3439.283676,S,05831.227410,W,0.0,,020720,5.3,W,A,V*6F
CALCULACHKSUM
		LDX		#BUFFER
		INX
		LDAA		0,X
LOOPASTERISCO
		EORA		1,X
		LDAB		2,X
		INX
		CMPB		#'*
		BNE		LOOPASTERISCO
		RTS


;;Recibe en Acc A el valor a convertir
;; O sea, recibe un ASCII entre $30 y $39 (0 a 9)
;; o entre $41 y $46 (A a F) y devuelve su valor binario.
ASCIIHEX2BYTE
		;;Si A es menor que $39, es un numero
		CMPA		#$3A
		BHS		ESA2F 
		;; Dado que es un numero, ponemos en 0
		;; los 4 bits mas significativos
		ANDA		#$0F
		RTS ;; Esto fue facil
ESA2F:
		;; Dado que es A~F y A=$41
		;; Decrementamos A
		DECA
		;; Borramos la parte alta
		ANDA		#$0F
		;; Ahora sumamos 0x0A
		ADDA		#$0A
		;; No fue mucho mas complicado		
		RTS

;;; Esta rutina muestra la fecha/hora en el LCD
MuestraHora:
		PSHA
		PSHB
		PSHX
		CLR	LCDDATA
		JSR	ValidaChecksum
		BCS	ChksumValido
		;;Mostrar ERROR
		LDAA	#'E
		STAA	LCDDATA
		PULX
		PULB
		PULA
		RTS
ChksumValido
;; Ej: $GNRMC,094807.00,A,3439.283676,S,05831.227410,W,0.0,,020720,5.3,W,A,V*6F		
		LDX	#BUFFER
		LDAA	7,X
		STAA	LCDDATA
		LDAA	8,X
		STAA	LCDDATA
		LDAA	#':
		STAA	LCDDATA
		LDAA	9,X
		STAA	LCDDATA
		LDAA	10,X
		STAA	LCDDATA
		LDAA	#':
		STAA	LCDDATA
		LDAA	11,X
		STAA	LCDDATA
		LDAA	12,X
		STAA	LCDDATA
		PULX
		PULB
		PULA
		RTS


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

		;; luego del asterisco llega el checksum que
		;; son dos caracteres, por ende miramos dos
		;; caracteres atras para buscar el asterisco
		;; Pero no lo hacemos a menos que BUFFPOINTER>2
		LDAA		BUFFPOINTER
		CMPA		#2
		BLS		Sigue
		;; Ahora si, miramos dos atras
		DEX
		DEX
		LDAA		0,X
		CMPA		#'*
		BNE		Sigue ;; Si no es * entonces seguimos
		;; Si es asterisco, levantamos flag
		LDAA		#1
		STAA		FLAG
		RTI
;; Ej: $GNRMC,094807.00,A,3439.283676,S,05831.227410,W,0.0,,020720,5.3,W,A,V*6F		
		;; Incremento el puntero de buffer
Sigue		LDAA		BUFFPOINTER
		ADDA		#1
		CMPA		#NMEAMAX
		BHI		BUFFEROVERFLOW
		STAA		BUFFPOINTER
		;; Fin de la interrupcion
		RTI
BUFFEROVERFLOW
		CLR		BUFFPOINTER
		RTI
		

		ORG	SERIE
		DW	SERIAL_ISR
		ORG	RESET
		DW	MAIN