		ORG 	$0011
p	 	RMB	1
q		RMB	1
s		RMB	2

;; s = p + q - r
;; s = 11 + 12 - 13 = 10 
	
		ORG	$C000
		CLRA
		CLRB
		LDAA	#p
		LDAB	#q
		ABA
		LDAB	#s
		SBA
		STAA	s
		







		

	