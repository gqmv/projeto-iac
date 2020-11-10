ORIG            0100h
X               WORD    5

ORIG            0000h


vector          TAB     10
                
Teste:          MVI     R1, vector
                MVI     R2, 10
                
                MVI     R6, 4000h
                
                JAL     atualizajogo
                
                BR      Teste


atualizajogo:   DEC     R6 ; PUSH
                STOR    M[R6], R4 ; PUSH
                DEC     R6 ; PUSH
                STOR    M[R6], R5 ; PUSH
                
                ADD     R2,R2,R1 ; Obtem o ultimo elemento do array.
                
                INC     R1 ; Pula o primeiro elemento.
                DEC     R2 ; Define R2 como o penultimo elemento.

recurs1:        LOAD    R4, M[R1] ; Obtem o valor na posicao indicada por R1.
                DEC     R1 ; Volta para a posicao anterior.
                
                STOR    M[R1], R4 ; Coloca o valor que estava em n em n-1.
                
                INC     R1 ; Volta ao valor n de R1.
                
                CMP     R1,R2 ; Verifica se n e o ultimo elemento que deve ser movido.
                BR.Z    acaboumatriz
                
                INC     R1 ; Passa para o proximo elemento.
                
                BR      recurs1
                
acaboumatriz:   DEC     R6 ; PUSH
                STOR    M[R6], R7 ; PUSH
                DEC     R6 ; PUSH
                STOR    M[R6], R1 ; PUSH
                
                MVI     R1, 4 ; Chama a funcao geracacto com o parametro 4.
                JAL     geracacto
                
                LOAD    R1, M[R6] ; POP
                INC     R6 ; POP
                LOAD    R7, M[R6] ; POP
                INC     R6 ; POP
                
                STOR    M[R1], R3 ; Guarda no ultimo elemento do vetor o valor de retorno de geracacto.
                
                LOAD    R5, M[R6] ; POP
                INC     R6 ; POP
                LOAD    R4, M[R6] ; POP
                INC     R6 ; POP
                
                JMP     R7 ; Return
                
geracacto:      DEC     R6 ; PUSH
                STOR    M[R6], R4 ; PUSH
                DEC     R6 ; PUSH
                STOR    M[R6], R5 ; PUSH
                
                ; A funcao geracacto segue a risca o pseudo-codigo descrito
                ; nas especificacoes do projeto e, portanto, nao sera extensivamente comentada.
                
                MVI     R4, X 
                LOAD    R4, M[R4]
                
                
                MVI     R5, 1b
                AND     R5, R4, R5
                
                SHR     R4
                
                CMP     R5, R0
                BR.Z    else
                
                MVI     R2, b400h
                XOR     R4, R4, R2
                
else:           MVI     R5, X
                STOR    M[R5], R4
                
                MVI     R2, 62258
                CMP     R4, R2
                BR.N    ret0
                
                DEC     R1
                AND     R3, R1, R4
                INC     R3
                
                LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6
                
                JMP     R7
                
ret0:           MVI     R3, 0
                LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6
                
                JMP     R7     
