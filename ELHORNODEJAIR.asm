		ORG	$0000
opera		rmb	1
tempe		rmb	2
puerta		rmb	1
off		rmb	1
alarma		rmb	1

		ORG	$C000
inicio
		ldd	#499
		std	tempe
		clr 	alarma
		clr	off
		clr	opera
		clr	puerta

loop		
		ldaa	opera   
		anda	#%10000000  
		cmpa	#%10000000
		beq	arranco
		ldd	tempe
		cpd	#500
		bhi	set_alarm
		bra 	loop

arranco
		ldd	tempe
		cpd	#500
		bhi	set_alarm ;supero los 500 grados
		ldaa	puerta
		cmpa	#$00
		bne	set_alarm ;esta la puerta abierta
		ldaa	opera
		anda	#%10000000  
		cmpa	#%00000000
		beq	loop		
		bra     arranco

set_alarm
		clr	off
		ldaa	#1
		staa	alarma
while1		bra	while1


fin		bra	fin

		ORG	$fffe
		dw	inicio		