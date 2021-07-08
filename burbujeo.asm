RAM        EQU    $0000

ROM        EQU    $C000

RESET        EQU    $FFFE


;Variables
        
ORG    RAM
        
DB    $45,$13,$32,$25,$ff,$12,$cc,$69

dirinicio    EQU    $0000

dirfin        EQU    $0007 ;con $0005 funciona, con $0006 o mayor 
no
cant        RMB    2

i        RMB    2

j        RMB    2

nmenos1        RMB    2

aux        RMB    1 

;Programa        
        
ORG    ROM

inicio
        
;Inicializamos contadores
        
LDX    #$0000
        
LDY    #$0000
        
;Inicializamos las variables
        
CLR    cant
        
CLR    cant+1
        
CLR    i
        
CLR    i+1
        
CLR     j
        
CLR    j+1
        
;Calculamos la cantidad de elementos
        
LDD    #dirfin
        
SUBD    #dirinicio
        
STD    cant
        
SUBD    #$1
        
STD    nmenos1

        
;Recorremos el vector
loop1
        
;Reiniciamos j antes de entrar a loop2
        
LDY    #00
loop2
        
;Comparamos si la posicion actual es mayor que la siguiente
        
LDAA    0,Y
        SUBA    1,Y
        
;Si es mayor no intercambia
        
BGT    sigue
        
LDAA     0,Y
        STAA    aux
        LDAA    1,Y
        STAA    0,Y 
        LDAA    aux
        STAA    1,Y
sigue
        INY
        STY    j
        ;n-1-i
        LDD    nmenos1
        CPD    j
        BHS    loop2

        INX
        STX     i
        LDD    cant
        CPD    i
        BHI    loop1


fin        BRA    fin

        ORG    RESET
        DW    inicio