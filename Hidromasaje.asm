;Una ba�era con hidromasaje cuenta con un microcontrolador Motorola HC11 para su operaci�n. El
;mismo tiene conectados dos sensores (INF y SUP) para determinar si el nivel de agua de la ba�era est� en
;el rango de operaci�n. El hidromasaje se debe encender solamente si el nivel de agua est� dentro del
;mismo, caso contrario debe apagarlo de inmediato y activar una se�al luminosa para notificar que el agua
;est� por debajo del m�nimo o por encima del m�ximo (la misma se�al luminosa notifica ambas
;condiciones). El llenado/vaciado del hidromasaje se realiza en forma manual.
;El sensor INF est� mapeado en $1000 y cuando el agua lo alcanza su valor es $00. El sensor SUP est�
;mapeado en $1001 y se comporta de la misma forma (si el agua no los alcanza su valor es distinto de cero).
;La bomba del hidromasaje se activa cuando se escribe el valor 01H en $1002 y se apaga cuando se pone en
;cero. La se�al luminosa se activa si se escribe 01H en $1003 y se apaga si se escribe un cero en la misma
;direcci�n. Si la bomba est� activada se leer� un valor distinto de cero en $1005.
;Se solicita que codifique una rutina en assembler para controlar el funcionamiento del hidromasaje. Tenga
;en cuenta que la bomba no debe recibir las mismas se�ales de encendido o apagado repetidamente.
		ORG	$C000
INF		EQU	$0000
SUP		EQU	$0001
ACTIVADOR	EQU	$0002
ALERTA		EQU	$0003
ESTADOBOMBA	EQU	$0005

INICIO
		; inferior $01 -> POCA AGUA
		; superior $00 -> MUCHA AGUA
		
		; $00 && $01 -> AGUA EN RANGO
		;CHEKEO SI EL SENSOR SUPERIOR ESTA EN 00 Y SI LO ESTA SALTO
		LDAB	SUP
		CMPB	#$00
		BEQ	MAL
		;CHEKEO SI EL INFERIOR ESTA EN 01 Y SI LO ESTA SALTTO A ETIQUETA
		LDAA	INF
		CMPA	#$01
		BEQ	MAL
		
		LDAA	ESTADOBOMBA
		CMPA	#$01
		BEQ	INICIO
		LDAA	#$01
		STAA	ACTIVADOR
		STAA	ESTADOBOMBA
		LDAA	#$00
		STAA	ALERTA
		BRA	INICIO
		
MAL
		LDAA	#$01
		STAA	ALERTA
		LDAA	ESTADOBOMBA
		CMPA	#$00
		BEQ	INICIO
		LDAA	#$00
		STAA	ACTIVADOR
		STAA	ESTADOBOMBA	
		LDAA	#$01
		STAA	ALERTA
		BRA	INICIO	