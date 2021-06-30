		ORG	$0000
numero		RMB	1
centenas	RMB	1
decenas		RMB	1
unidades	RMB	1

		ORG $1003
portc		RMB	1
portb		RMB	1


		ORG	$C000
inicio
		clr	numero
loop
		ldab	numero
		ldx	#tabla
		abx
		ldaa	0,x ---> a = tabla[numero];
		staa	portb
		inc	numero
		ldaa	numero
		cmpa	#$10
		beq	inicio
		bra 	loop


fin		bra	fin


;Conversor de BCD a 7 segmentos ----->>
;         a
;       _____
;      |     |
;     f|     |b
;      |  g  |
;       _____
;      |     |
;     e|     |c
;      |     |
;       _____
;         d

;defino los segmentos
;  xgfedcba

seg_a		equ	%00000001
seg_b		equ	%00000010
seg_c		equ	%00000100
seg_d		equ	%00001000
seg_e		equ	%00010000
seg_f		equ	%00100000
seg_g		equ	%01000000

tabla		db (seg_a+seg_b+seg_c+seg_d+seg_e+seg_f)       //0
		db (seg_b+seg_c)                               //1
		db (seg_a+seg_b+seg_d+seg_e+seg_g)             //2
		db (seg_a+seg_b+seg_c+seg_d+seg_g)             //3
		db (seg_b+seg_c+seg_f+seg_g)                   //4
		db (seg_a+seg_c+seg_d+seg_f+seg_g)             //5
		db (seg_a+seg_c+seg_d+seg_e+seg_f+seg_g)       //6
		db (seg_a+seg_b+seg_c)                         //7
		db (seg_a+seg_b+seg_c+seg_d+seg_e+seg_f+seg_g) //8
		db (seg_a+seg_b+seg_c+seg_d+seg_f+seg_g)       //9
		db (seg_a+seg_b+seg_c+seg_e+seg_f+seg_g)       //A
		db (seg_c+seg_d+seg_e+seg_f+seg_g)             //B
		db (seg_a+seg_d+seg_e+seg_f)                   //C
		db (seg_b+seg_c+seg_d+seg_e+seg_g)             //D
		db (seg_a+seg_d+seg_e+seg_f+seg_g)             //E
		db (seg_a+seg_e+seg_f+seg_g)                   //F



		ORG	$fffe
		dw	inicio





