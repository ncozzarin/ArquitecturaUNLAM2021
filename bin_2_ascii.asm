		ORG	$0000
numero		RMB	1
centenas	RMB	1
decenas		RMB	1
unidades	RMB	1

		ORG	$C000
inicio
		clra
		ldab	numero
		ldx	#100
		idiv
		xgdx
		addb	#$30
		stab	centenas
		xgdx
		ldx	#10
		idiv
		addb	#$30
		stab	unidades
		xgdx	
		addb	#$30
		stab	decenas

fin		bra	fin

		ORG	numero
		db	168


		ORG	$fffe
		dw	inicio