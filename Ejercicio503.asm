		ORG		3000
INICIO		CLRA
		LDAB		$F5
Otro		ADDA		$F7
		DECB
		BNE		Otro
		STAA		$F8
fin		BRA		FIn

;F5 * F7 = F8