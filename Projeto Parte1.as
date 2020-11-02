ORIG            0000h

Terreno         TAB     10

                MVI     R4, 0009h
                MVI     R5, 5
                
                STOR    M[R4], R5

                MVI     R1, Terreno
                MVI     R2, 10
                
                MVI     R6, 4000h
                JAL     atualizajogo
                
Fim:            BR      Fim

atualizajogo:   NOP
                STOR    M[R6], R7
                DEC     R6
                
atualizajogoIt: DEC     R2
                CMP     R2, R0
                BR.Z    return
                
                INC     R1
                LOAD    R4, M[R1]
                
                DEC     R1
                STOR    M[R1], R4
                
                INC     R1
                JMP     atualizajogoIt

return:         NOP
PreviousR1      WORD    0
                MVI     R4, PreviousR1
                STOR    M[R4], R1
                
                JAL     geracacto ; TODO: Implement geracacto function.
                
                MVI     R4, PreviousR1
                LOAD    R1, M[R4]
                
                STOR    M[R1], R3
                
                DEC     R6
                LOAD    R7, M[R6]
                
                JMP     R7
                
geracacto:      MVI     R3, 5
                JMP     R7
                
                
                
                