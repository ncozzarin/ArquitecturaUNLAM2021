;BURBUJEO

RAM        EQU    $0000
ROM        EQU    $C000
VRST        EQU    $FFFE

        ORG        RAM    ;VARIABLES
vector        RMB    8
dirini        RMB    2    ;Direccion de inicio
dirfin        RMB    2    ;Direccion final
i        RMB    2    ;Contador de posicion dentro del vector
j        RMB    1    ;Contador
aux        RMB    1    ;Auxiliar para intercambiar elementos
coso        RMB    2    ;Auxiliar para loop2



        ORG        ROM    ;PROGRAMA
inicio
        LDX    #$0000
        STX    dirini
        LDX    #$0007
        STX    dirfin
        ;Calcular la cantidad de elementos a partir de dirfinal-dirinicial
        LDD    dirfin
        SUBD    dirini
    
        LDX    dirini
        
        ;Inicializamos los contadores
        LDAA    #$00
        STAA    i    
        LDAA    #$00
        STAA    j
        CLRA
        CLRB
        LDD    #$00
        STD    coso
        LDY    coso
        
        ;Ordenamos el vector
        ;DEC     dirfin+1
loop1

        ;Reiniciamos el registro "Y" antes de entrar a loop2
        LDD    #$00
        STD    coso
        LDY    coso
loop2        
        ;Revisamos si se tiene que intercambiar
        LDAA    0,Y
        STAA    aux
        LDAA    1,Y
        CMPA    aux
        BLS    sigue
        STAA    0,Y
        LDAA    aux
        STAA    1,Y
sigue
        
        ;Seguimos con el loop2
        LDD     dirfin
        STX    i    
        SUBD    i    
        STD    coso
        INY
        CMPY    coso
        BNE    loop2        
        
        INX
        CMPX    dirfin
        BNE    loop1
        


fin        BRA    fin

        ORG    vector
        DB    $03,$13,$14,$22,$05,$04,$15,$12        

        ORG    VRST
        DW    inicio