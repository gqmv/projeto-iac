ORIG            0000h

X               WORD    5 ; Semente.

vector          TAB     80
                
Teste:          MVI     R1, vector ; Primeiro elemento do vector.
                MVI     R2, 80 ; Numero de elementos.
                
                MVI     R6, 4000h ; Inicializacao da pilha.
                
                JAL     atualizajogo
                
                BR      Teste ; Loop utilizado apenas para depuracao.
                              ; Deve ser removido para producao.


atualizajogo:   ; A funcao recebe em R1 o endereco de memoria do primeiro elemento.
                ; A funcao recebe em R2 a quantidade de elementos
                DEC     R6 ; PUSH
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
                
                JMP     R7 ; Retorna.
                
geracacto:      ; A funcao recebe em R1 o valor da altura.
                DEC     R6 ; PUSH
                STOR    M[R6], R4 ; PUSH
                DEC     R6 ; PUSH
                STOR    M[R6], R5 ; PUSH
                
                ; A funcao geracacto segue a risca o pseudo-codigo descrito
                ; nas especificacoes do projeto e, portanto, nao sera extensivamente comentada.
                
                MVI     R4, X 
                LOAD    R4, M[R4] ; R4 Contem o valor de X.
                
                
                MVI     R5, 1b
                AND     R5, R4, R5
                
                SHR     R4
                
                CMP     R5, R0
                BR.Z    else ; Executa o salto se R5 == 0
                
                MVI     R2, b400h
                XOR     R4, R4, R2
                
else:           MVI     R5, X
                STOR    M[R5], R4
                
                MVI     R2, 62258
                CMP     R4, R2
                BR.C    ret0 ; Executa o salto se R4 < R2
                
                DEC     R1
                AND     R3, R1, R4
                INC     R3
                
                LOAD    R5, M[R6] ; POP
                INC     R6 ; POP
                LOAD    R4, M[R6] ; POP
                INC     R6 ; POP
                
                JMP     R7 ; Retorna valor entre 1 e altura.
                
ret0:           MVI     R3, 0

                LOAD    R5, M[R6] ; POP
                INC     R6 ; POP
                LOAD    R4, M[R6] ; POP
                INC     R6 ; POP
                
                JMP     R7 ; Retorna 0.
