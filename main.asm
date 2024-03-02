    DOSSEG
    .MODEL SMALL
    .STACK 32
    .DATA

encoded     DB  80 DUP(0)
message     DB  80 DUP(0)
encrypted DB 80 DUP(0)
nrBiti DW 0
store DB 6 DUP(0)
COD64 DB 'Bqmgp86CPe9DfNz7R1wjHIMZKGcYXiFtSU2ovJOhW41y5EkrqsnAxubTv03a=L/d'
encrypted_binary DB 640 DUP(0)
prenume DB '6Stefan'
nume DB '8Raileanu'
clock DB 4 DUP(0)


x           DW  ?
x0          DW  ?
a           DW  0
b           DW  0
temp        DB  '0x', 160 DUP(0)
fileHandler DW  ?
filename    DB  'in/in.txt', 0          ; Trebuie sa existe acest fisier 'in/in.txt'!
outfile     DB  'out/out.txt', 0        ; Trebuie sa existe acest director 'out'!
msglen      DW  ?
padding     DW  0
iterations  DW  0
two DW 2
numar DW 0
case DB 0
var DW 0


    .CODE
START:
    MOV     AX, @DATA
    MOV     DS, AX

    CALL    FILE_INPUT                  ; NU MODIFICATI!
    
    CALL    SEED                        ; TODO - Trebuie implementata 

    CALL    ENCRYPT                     ; TODO - Trebuie implementata
    
    CALL    ENCODE                      ; TODO - Trebuie implementata
    
                                        ; Mai jos se regaseste partea de
                                        ; afisare pe baza valorilor care se
                                        ; afla in variabilele x0, a, b, respectiv
                                        ; in sirurile message si encoded.
                                        ; NU MODIFICATI!
    MOV     AH, 3CH                     ; BIOS Int - Open file
    MOV     CX, 0
    MOV     AL, 1                       ; AL - Access mode ( Write - 1 )
    MOV     DX, OFFSET outfile          ; DX - Filename
    INT     21H
    MOV     [fileHandler], AX           ; Return: AX - file handler or error code

    CALL    WRITE                       ; NU MODIFICATI!

    MOV     AH, 4CH                     ; Bios Int - Terminate with return code
    MOV     AL, 0                       ; AL - Return code
    INT     21H

FILE_INPUT:
    MOV     AH, 3DH                     ; BIOS Int - Open file
    MOV     AL, 0                       ; AL - Access mode ( Read - 0 )
    MOV     DX, OFFSET fileName         ; DX - Filename
    INT     21H
    MOV     [fileHandler], AX           ; Return: AX - file handler or error code

    MOV     AH, 3FH                     ; BIOD Int - Read from file or device
    MOV     BX, [fileHandler]           ; BX - File handler
    MOV     CX, 80                      ; CX - Number of bytes to read
    MOV     DX, OFFSET message          ; DX - Data buffer
    INT     21H
    MOV     [msglen], AX                ; Return: AX - number of read bytes

    MOV     AH, 3EH                     ; BIOS Int - Close file
    MOV     BX, [fileHandler]           ; BX - File handler
    INT     21H

    RET

SEED:
    MOV     AH, 2CH                     ; BIOS Int - Get System Time
    INT     21H
                                        ; TODO1: Completati subrutina SEED
                                        ; astfel incat la final sa fie salvat
                                        ; in variabila 'x' si 'x0' continutul 
                                        ; termenului initial

    MOV SI, OFFSET clock
    MOV [SI], CH 
    INC SI 
    MOV [SI], CL   
    INC SI
    MOV [SI], DH
    INC SI
    MOV [SI], DL ; salvam clock ul

    MOV SI, OFFSET clock
    MOV AL, [SI]
    INC SI
    MOV BL, 60
    MUL BL
    MOV BL, [SI]
    INC SI
    ADD AX, BX 

    MOV BX, 60
    MUL BX
    MOV BL, [SI]
    INC SI
    ADD AX, BX

    MOV BX, 100
    MUL BX
    MOV BL, [SI]
    ADD AX, BX

    MOV BX, 255
    DIV BX

    MOV x, DX
    MOV x0, DX ; am aflat x0

    MOV SI, OFFSET prenume
    MOV BH, 0
    MOV BL, [SI]
    INC SI
    AND BL, 0FH
    MOV CX, BX
    MOV AX, 0

    initialize_a: 
        MOV BL, [SI]
        ADD AX, BX
        INC SI
        LOOP initialize_a

    MOV DX, 0
    MOV BX, 255
    DIV BX 
    MOV a, DX ; am aflat a

    MOV SI, OFFSET nume
    MOV BL, [SI]
    INC SI
    AND BL, 0FH
    MOV CX, BX
    MOV AX, 0

    initialize_b:
        MOV BL, [SI]
        ADD AX, BX
        INC SI 
        LOOP initialize_b    
    
    MOV DX, 0
    MOV BX, 255
    DIV BX
    MOV b, DX ; am aflat b
    
    RET

ENCRYPT:
    MOV     CX, [msglen]
    MOV     SI, OFFSET message
                                            ; TODO3: Completati subrutina ENCRYPT
                                            ; astfel incat in cadrul buclei sa fie
                                            ; XOR-at elementul curent din sirul de
                                            ; intrare cu termenul corespunzator din
                                            ; sirul generat, iar mai apoi sa fie generat
                                            ; si termenul urmator
    MOV DI, OFFSET encrypted
    MOV BX, 0
    PUSH BX  

    DO_RAND: 
        CALL RAND 
        POP BX  
        INC BX
        PUSH BX
        LOOP DO_RAND

    POP BX 

    MOV CX, [msglen]
    MOV SI, OFFSET message
    MOV DI, OFFSET encrypted
    
    COPY: 
        MOV AL, [DI]
        MOV [SI], AL
        INC SI
        INC DI 
        LOOP COPY

    RET

RAND:
    MOV     AX, [x]
                                            ; TODO2: Completati subrutina RAND, astfel incat
                                            ; in cadrul acesteia va fi calculat termenul
                                            ; de rang n pe baza coeficientilor a, b si a 
                                            ; termenului de rang inferior (n-1) si salvat
                                            ; in cadrul variabilei 'x'

    MOV BH, 0
    MOV BL, [SI]  ;-P(n)
    INC SI 

    XOR AX, BX  ;-> C(n) 

    MOV [DI], AL 
    INC DI

    CMP CX, 1
    JE No_Modification

    MOV AX, [x]
    MOV BX, [a]
    MUL BX

    MOV DX, 0
    MOV BX, [b]
    ADD AX, BX  
    MOV BX, 255
    DIV BX 

    MOV x, DX

    No_Modification:
    RET

ENCODE:
                                            ; TODO4: Completati subrutina ENCODE, astfel incat
                                            ; in cadrul acesteia va fi realizata codificarea
                                            ; sirului criptat pe baza alfabetului COD64 mentionat
                                            ; in enuntul problemei si rezultatul va fi stocat
                                            ; in cadrul variabilei encoded

    MOV DI, OFFSET encrypted
    MOV CX, [msglen]

    MOV SI, OFFSET encrypted_binary

    DO_ENCODE:
        MOV DH, 0
        MOV DL, [DI]
        MOV [numar], DX 
        
        PUSH CX  ;transformam in binar si il adaugam in vector
        PUSH DI
        CALL ZECBIN
        POP DI
        POP CX
        INC DI
        LOOP DO_ENCODE

    MOV BX,3 ;verificam cati bytes trebuie sa adaugam
    MOV DX, 0
    MOV AX, [msglen]
    DIV BX

    CMP DX, 1
    JE FIRST_CASE
    JMP NO_FIRST_CASE

    FIRST_CASE: 
        MOV CX, 4
        MOV [case], 1
        JMP ZERORIZATION

    NO_FIRST_CASE: 
        CMP DX, 2
        JE SECOND_CASE
        JMP CONTINUE

    SECOND_CASE: 
        MOV CX, 2
        MOV [case], 2

    ZERORIZATION:
        MOV AX, [nrBiti]
        ADD AX, CX
        MOV [nrBiti], AX

    CONTINUE:
        MOV AX, [nrBiti]  ;luam cate 6 biti si ii transformam ca sa stim indexul la care se afla litera corespunzatoare din COD64
        MOV DX, 0
        MOV BX, 6
        DIV BX

        MOV CX, AX
        MOV [iterations], CX
        MOV SI, OFFSET encrypted_binary
        MOV DI, OFFSET encoded

        TAKE_6: 
            PUSH CX
            PUSH DI
            MOV CX, 6
            MOV DI, OFFSET store

            DO_TAKE_6: 
                MOV AL, [SI]
                MOV [DI], AL
                INC DI
                INC SI
                LOOP DO_TAKE_6
            
            PUSH SI
            CALL BINZEC
            POP SI

            POP DI
            PUSH SI
            MOV AX, [numar]
            MOV SI, OFFSET COD64
            ADD SI, AX
            MOV AL, [SI]
            MOV [DI], AL
            INC DI
            POP SI

            POP CX
            LOOP TAKE_6

        MOV DH, 0
        MOV DL, [case] ;vedem daca mai trebuie sa adaugam padding

        CMP DX, 1
        JE FIRST_CASE1
        JMP NO_FIRST_CASE1

        FIRST_CASE1: ; adaugam ++
            MOV CX, 2
            MOV AX, [iterations]
            ADD AX, CX
            MOV [iterations], AX
            CALL ADD_PADDING
            JMP RETURN

        NO_FIRST_CASE1: 
            CMP DX, 2
            JE SECOND_CASE1
            JMP RETURN

        SECOND_CASE1: ;adaugam +
            MOV CX, 1
            MOV AX, [iterations]
            ADD AX, CX
            MOV [iterations], AX
            CALL ADD_PADDING


    RETURN: 
    RET

ADD_PADDING:
    MOV AL, '+'
    MOV [DI], AL
    INC DI
    LOOP ADD_PADDING
    RET

BINZEC: 
    MOV [numar], 0
    MOV BX, 2
    MOV CX, 6
    MOV SI, OFFSET store
    ADD SI, 5
    MOV AX, 1

    DO_BINZEC: 
        MOV DH, 0
        MOV DL, [SI]
        DEC SI

        CMP DX, 1
        JE ADD_BIT
        JMP NO_ADD_BIT

        ADD_BIT:
            MOV DX, [numar]
            ADD DX, AX
            MOV [numar], DX

        NO_ADD_BIT:
            MUL BX
            LOOP DO_BINZEC
    
    RET
    
ZECBIN: 
    MOV CX, 8
    ADD SI, 7
    PUSH SI

    MOV AX, [nrBiti] ; numaram cati biti sunt in encrypted_binary
    ADD AX, 8 ; si mai adaugam inca 8 pentru octetul curent
    MOV [nrBiti], AX

    MOV DI, OFFSET two

    DO_ZECBIN: 
        MOV AX, [numar]
        MOV DX, 0
        DIV WORD PTR [DI]
        MOV [numar], AX
        MOV [SI], DL
        DEC SI
        LOOP DO_ZECBIN

    POP SI
    INC SI
    RET

WRITE_HEX:
    MOV     DI, OFFSET temp + 2
    XOR     DX, DX

DUMP:
    MOV     DL, [SI]
    PUSH    CX
    MOV     CL, 4

    ROR     DX, CL
    
    CMP     DL, 0ah
    JB      print_digit1

    ADD     DL, 37h
    MOV     byte ptr [DI], DL
    JMP     next_digit

print_digit1:  
    OR      DL, 30h
    MOV     byte ptr [DI] ,DL

next_digit:
    INC     DI
    MOV     CL, 12
    SHR     DX, CL
    CMP     DL, 0ah
    JB      print_digit2

    ADD     DL, 37h
    MOV     byte ptr [DI], DL
    JMP     AGAIN

print_digit2:    
    OR      DL, 30h
    MOV     byte ptr [DI], DL

AGAIN:
    INC     DI
    INC     SI
    POP     CX
    LOOP    dump
    
    MOV     byte ptr [DI], 10
    RET

WRITE:
    MOV     SI, OFFSET x0
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21h

    MOV     SI, OFFSET a
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET b
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET x
    MOV     CX, 1
    CALL    WRITE_HEX    
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET message
    MOV     CX, [msglen]
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, [msglen]
    ADD     CX, [msglen]
    ADD     CX, 3
    INT     21h

    MOV     AX, [iterations]
    MOV     BX, 4
    MOV     CX, AX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET encoded
    INT     21H

    MOV     AH, 3EH                     ; BIOS Int - Close file
    MOV     BX, [fileHandler]           ; BX - File handler
    INT     21H
    RET
    
    END START