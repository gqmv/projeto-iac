; Gabriel Queiroz Monteiro Vieira & Yassir Mahomed Yassin
; Except where otherwise noted, this work is licensed under: https://www.gnu.org/licenses/gpl-3.0.html

; -----------------
; CONSTANTS
; -----------------
; CallStack
SP_INIT         EQU     7000h

; 7 Segments Display
DISP7_D0        EQU     FFF0h
DISP7_D1        EQU     FFF1h
DISP7_D2        EQU     FFF2h
DISP7_D3        EQU     FFF3h
DISP7_D4        EQU     FFEEh
DISP7_D5        EQU     FFEFh

; Terminal
TERM_READ       EQU     FFFFh
TERM_STATUS     EQU     FFFDh
TERM_CURSOR     EQU     FFFCh
TERM_WRITE      EQU     FFFEh
TERM_COLOR      EQU     FFFBh

; Timer
TIMER_CONTROL   EQU     FFF7h
TIMER_COUNTER   EQU     FFF6h
TIMER_SETSTART  EQU     1
TIMER_SETSTOP   EQU     0
TIMER_COUNTVAL  EQU     2

; Interruption Handling
INT_MASK        EQU     FFFAh
INT_MASK_VAL    EQU     8009h ; 1000 0000 0000 1001 b

; Game Data
MAX_JUMP        EQU     5
MAX_CACTUS_H    EQU     3
GAME_BASE       EQU     21
DIN_CHAR        EQU     '>'
DIN_COLUMN      EQU     7
FIELD_SIZE      EQU     80
FIELD_FLOOR     EQU     '-'
FIELD_CACTUS    EQU     '#'

; GUI Data
JMP_KEY         EQU     ' '
GAME_OVER_STR   STR     0,1,a00h,0,2,ffh,'                                         GAME OVER',0,1,b00h,'                               PRESS ANY KEY TO TRY AGAIN',0,0
WELCOME_STR     STR     0,1,c00h,'                          WELCOME TO THE DINOSSAUR GAME',0,1,d00h,'                      USE THE SPACEBAR OR THE UPKEY TO JUMP',0,1,f00h,'                             PRESS ANY KEY TO BEGIN',0,1,2800h,'</> BY GABRIEL VIEIRA AND YASSIR YASSIN',0,0

; -----------------
; PROGRAM GLOBAL VARIABLES
; -----------------

TIMER_TICK      WORD    0
SEED            WORD    125 ; Arbitrary value
IS_JUMPING      WORD    0
IS_FALLING      WORD    0
DIN_HEIGHT      WORD    0
SCORE           WORD    0
PLAY_AGAIN      WORD    0
FIELD           TAB     FIELD_SIZE

; -----------------
; MAIN
; -----------------

ORIG            0000h
MAIN:           MVI     R6, SP_INIT ; Stack initiation

                ; Interruption handling setup
                MVI     R1, INT_MASK
                MVI     R2, INT_MASK_VAL
                STOR    M[R1], R2
                ENI

                MVI     R1, TIMER_COUNTER
                MVI     R2, TIMER_COUNTVAL
                STOR    M[R1], R2

                MVI     R1, TIMER_TICK
                STOR    M[R1], R0

                MVI     R1, TIMER_CONTROL
                MVI     R2, TIMER_SETSTART
                STOR    M[R1], R2

                MVI     R1, WELCOME_STR
                JAL     PRINT_TEXT

                MVI     R4, PLAY_AGAIN
                STOR    M[R4], R0
                MVI     R5, TERM_STATUS
.WAIT_FOR_BEGIN:
                LOAD    R1, M[R4]
                CMP     R1, R0
                BR.NZ   START

                LOAD    R1, M[R5]
                CMP     R1, R0
                BR.NZ   START

                BR.Z    .WAIT_FOR_BEGIN

                ; Timer setup
START:          MVI     R1, TIMER_CONTROL
                MVI     R2, TIMER_SETSTOP
                STOR    M[R1], R2

                MVI     R1, TIMER_COUNTER
                MVI     R2, TIMER_COUNTVAL
                STOR    M[R1], R2

                MVI     R1, TIMER_TICK
                STOR    M[R1], R0

                MVI     R1, TIMER_CONTROL
                MVI     R2, TIMER_SETSTART
                STOR    M[R1], R2

                MVI     R4, TIMER_TICK
                MVI     R5, TERM_STATUS
.LOOP:          LOAD    R1, M[R4]
                CMP     R1, R0
                JAL.NZ  PROCESS_TIMER_EVENT
                
                LOAD    R1, M[R5]
                CMP     R1, R0
                JAL.NZ  PROCESS_KEYBOARD_EVENT

                JAL     CHECK_LOST
                CMP     R3, R0
                BR.Z    .LOOP

                MVI     R1, SCORE
                STOR    M[R1], R0

                MVI     R1, FIELD
                MVI     R2, FIELD_SIZE
                JAL     CLEAR_FIELD

                MVI     R1, GAME_OVER_STR
                JAL     PRINT_TEXT

                MVI     R4, PLAY_AGAIN
                STOR    M[R4], R0
                MVI     R5, TERM_STATUS
.WAIT_FOR_PLAYAGAIN:
                LOAD    R1, M[R4]
                CMP     R1, R0
                BR.NZ   START

                LOAD    R1, M[R5]
                CMP     R1, R0
                BR.NZ   START

                BR.Z    .WAIT_FOR_PLAYAGAIN

; -----------------
; EVENT HANDLERS
; -----------------
PROCESS_TIMER_EVENT:
                DEC     R6
                STOR    M[R6], R7
                
                MVI     R1, TIMER_TICK
                DSI
                LOAD    R2, M[R1]
                DEC     R2
                STOR    M[R1], R2
                ENI

                MVI     R2, SCORE
                LOAD    R1, M[R2]
                INC     R1
                STOR    M[R2], R1

                JAL     PRINT_DISP7

                MVI     R1, FIELD
                MVI     R2, FIELD_SIZE
                JAL     UPDATE_GAME

                JAL     CLEAR_TERMINAL

                MVI     R1, IS_JUMPING
                LOAD    R1, M[R1]
                CMP     R1, R0
                BR.Z    .CONTINUE

                MVI     R1, IS_FALLING
                LOAD    R1, M[R1]
                CMP     R1, R0
                BR.Z    .NOT_FALLING

                MVI     R1, DIN_HEIGHT
                LOAD    R2, M[R1]
                DEC     R2
                STOR    M[R1], R2

                CMP     R2, R0
                BR.NZ   .CONTINUE
                MVI     R1, IS_FALLING
                STOR    M[R1], R0
                MVI     R1, IS_JUMPING
                STOR    M[R1], R0
                BR      .CONTINUE

.NOT_FALLING:   MVI     R1, DIN_HEIGHT
                LOAD    R2, M[R1]
                INC     R2
                STOR    M[R1], R2

                MVI     R1, MAX_JUMP
                CMP     R2, R1
                BR.NZ   .CONTINUE
                MVI     R1, IS_FALLING
                MVI     R2, 1
                STOR    M[R1], R2

.CONTINUE:      MVI     R1, DIN_HEIGHT
                LOAD    R1, M[R1]
                JAL     PRINT_DINO

                MVI     R1, FIELD
                MVI     R2, FIELD_SIZE
                JAL     PRINT_FIELD
                
                LOAD    R7, M[R6]
                INC     R6
                JMP     R7

PROCESS_KEYBOARD_EVENT:
                MVI     R1, TERM_READ
                LOAD    R1, M[R1]
                
                MVI     R2, JMP_KEY
                CMP     R1, R2
                JMP.NZ  R7
                
                INT     30
                JMP     R7

; -----------------
; SUB ROUTINES
; -----------------
CLEAR_FIELD:    ; R1: Memory address of the vector.
                ; R2: Number of elements in the vector.
                STOR    M[R1], R0
                INC     R1

                DEC     R2
                CMP     R2, R0
                BR.NN   CLEAR_FIELD

                JMP     R7

PRINT_DISP7:    ; R1: The numeric value that should be displayed.
                MVI     R3, Fh
                AND     R3, R3, R1

                MVI     R2, DISP7_D0
                STOR    M[R2], R3
                
                SHR     R1
                SHR     R1
                SHR     R1
                SHR     R1
                MVI     R3, Fh
                AND     R3, R3, R1
                MVI     R2, DISP7_D1
                STOR    M[R2], R3
                
                SHR     R1
                SHR     R1
                SHR     R1
                SHR     R1
                MVI     R3, Fh
                AND     R3, R3, R1
                MVI     R2, DISP7_D2
                STOR    M[R2], R3
                
                SHR     R1
                SHR     R1
                SHR     R1
                SHR     R1
                MVI     R3, Fh
                AND     R3, R3, R1
                MVI     R2, DISP7_D3
                STOR    M[R2], R3
                
                SHR     R1
                SHR     R1
                SHR     R1
                SHR     R1
                MVI     R3, Fh
                AND     R3, R3, R1
                MVI     R2, DISP7_D4
                STOR    M[R2], R3
                
                SHR     R1
                SHR     R1
                SHR     R1
                SHR     R1
                MVI     R3, Fh
                AND     R3, R3, R1
                MVI     R2, DISP7_D5
                STOR    M[R2], R3
                
                JMP     R7

CHECK_LOST:
                DEC     R6
                STOR    M[R6], R4
                
                MVI     R1, DIN_HEIGHT
                LOAD    R1, M[R1]

                MVI     R2, FIELD
                MVI     R3, DIN_COLUMN

                ADD     R2, R2, R3

                LOAD    R4, M[R2]
                CMP     R1, R4
                BR.N    .LOST
                
                INC     R2

                LOAD    R4, M[R2]
                CMP     R1, R4
                BR.N    .LOST

                INC     R2

                LOAD    R4, M[R2]
                CMP     R1, R4
                BR.N    .LOST

                MVI     R3, 0
                LOAD    R4, M[R6]
                INC     R6
                JMP     R7

.LOST:          MVI     R3, 1
                LOAD    R4, M[R6]
                INC     R6
                JMP     R7

CLEAR_TERMINAL:
                MVI     R1, TERM_CURSOR
                MVI     R2, 0
                STOR    M[R1], R2

                MVI     R1, TERM_WRITE
                MVI     R2, ' '
                MVI     R3, 3600

.LOOP:          STOR    M[R1], R2
                DEC     R3
                BR.NZ   .LOOP

                JMP     R7

PRINT_FIELD:    ; R1: Memory address of the vector.
                ; R2: Number of elements in the vector.
                DEC     R6
                STOR    M[R6], R7
                DEC     R6
                STOR    M[R6], R4
                DEC     R6
                STOR    M[R6], R5

                MOV     R4, R1
                ADD     R4, R4, R2

.LOOP:          DEC     R2
                MVI     R1, GAME_BASE
                
                JAL     GET_CURSOR
                
                MVI     R5, TERM_CURSOR
                STOR    M[R5], R3

                MVI     R5, TERM_WRITE
                MVI     R3, FIELD_FLOOR
                STOR    M[R5], R3
                
                MVI     R5, GAME_BASE
                LOAD    R3, M[R4]
                SUB     R1, R5, R3

.C_LOOP:        MVI     R5, GAME_BASE
                CMP     R1, R5
                BR.Z    .CONTINUE
                
                DEC     R6
                STOR    M[R6], R1
                JAL     GET_CURSOR
                LOAD    R1, M[R6]
                INC     R6

                MVI     R5, TERM_CURSOR
                STOR    M[R5], R3

                MVI     R5, TERM_WRITE
                MVI     R3, FIELD_CACTUS
                STOR    M[R5], R3

                INC     R1

                BR      .C_LOOP
            
.CONTINUE:      MVI     R1, GAME_BASE
                
                DEC     R4
                CMP     R2, R0
                BR.NZ   .LOOP

                LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6
                LOAD    R7, M[R6]
                INC     R6

                JMP     R7
            
PRINT_DINO: ; R1: Height at which the dinossaur should be printed
            ; Returns 1: If the dinossaur was sucessfully drawn.
            ; Returns 0: If an obstacle was found while trying to drawn the dinossaur.
                DEC     R6
                STOR    M[R6], R7
                DEC     R6
                STOR    M[R6], R4
                DEC     R6
                STOR    M[R6], R5
                
                MVI     R4, TERM_CURSOR
                MVI     R5, TERM_WRITE

                MVI     R2, GAME_BASE
                INC     R1
                SUB     R1, R2, R1

                MVI     R2, DIN_COLUMN
                INC     R2

                DEC     R6
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2
                JAL     GET_CURSOR
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                STOR    M[R4], R3

                MVI     R3, DIN_CHAR
                STOR    M[R5], R3

                DEC     R1
                DEC     R1

                DEC     R6
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2
                JAL     GET_CURSOR
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                STOR    M[R4], R3

                MVI     R3, DIN_CHAR
                STOR    M[R5], R3

                INC     R1
                DEC     R2

                DEC     R6
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2
                JAL     GET_CURSOR
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                STOR    M[R4], R3

                MVI     R3, DIN_CHAR
                STOR    M[R5], R3

                INC     R1
                DEC     R2

                DEC     R6
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2
                JAL     GET_CURSOR
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                STOR    M[R4], R3

                MVI     R3, DIN_CHAR
                STOR    M[R5], R3

                LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6
                LOAD    R7, M[R6]
                INC     R6

                JMP     R7

GET_CURSOR: ; R1: Line
            ; R2: Column
            ; Returns: The value of the cursor at Line <R1> and Column <R2>.
                SHL     R1
                SHL     R1
                SHL     R1
                SHL     R1
                SHL     R1
                SHL     R1
                SHL     R1
                SHL     R1

                OR      R3, R1, R2

                JMP     R7
                
UPDATE_GAME:    ; R1: Address of the vector.
                ; R2: Number of elements in the vector.
                DEC     R6 ; PUSH
                STOR    M[R6], R4 ; PUSH
                DEC     R6 ; PUSH
                STOR    M[R6], R5 ; PUSH
                
                ADD     R2,R2,R1 ; Gets the vector's last element.
                
                INC     R1 ; Skips the first element.
                DEC     R2 ; Assign R2 to the address of the penultimate element.

.LOOP:          LOAD    R4, M[R1]
                DEC     R1
                
                STOR    M[R1], R4 ; Stores the value that was in address <n> at address <n-1>.
                
                INC     R1
                
                CMP     R1,R2
                BR.Z    .DONE
                
                INC     R1
                
                BR      .LOOP
                
.DONE:          DEC     R6 ; PUSH
                STOR    M[R6], R7 ; PUSH
                DEC     R6 ; PUSH
                STOR    M[R6], R1 ; PUSH
                
                MVI     R1, MAX_CACTUS_H
                JAL     GEN_CACTUS
                
                LOAD    R1, M[R6] ; POP
                INC     R6 ; POP
                LOAD    R7, M[R6] ; POP
                INC     R6 ; POP
                
                STOR    M[R1], R3 ; Stores in the last element of the vector the return value of GEN_CACTUS.
                
                LOAD    R5, M[R6] ; POP
                INC     R6 ; POP
                LOAD    R4, M[R6] ; POP
                INC     R6 ; POP
                
                JMP     R7
                
                
GEN_CACTUS:     ; R1: Maximum height of the cactus.
                ; Returns: An integer in the interval [0, R1]. There is a 95% chance that the return value will be 0.
                DEC     R6 ; PUSH
                STOR    M[R6], R4 ; PUSH
                DEC     R6 ; PUSH
                STOR    M[R6], R5 ; PUSH
                
                ; This function strictly follows the pseudo-python code made availible
                ; in the project's especifications and will therefore not be extensivelly
                ; commented.
                
                MVI     R4, SEED
                LOAD    R4, M[R4]
                
                
                MVI     R5, 1b
                AND     R5, R4, R5
                
                SHR     R4
                
                CMP     R5, R0
                BR.Z    .ELSE
                
                MVI     R2, b400h
                XOR     R4, R4, R2
                
.ELSE:          MVI     R5, SEED
                STOR    M[R5], R4
                
                MVI     R2, 62258
                CMP     R4, R2
                BR.C    .RETURN_0
                
                DEC     R1
                AND     R3, R1, R4
                INC     R3
                
                LOAD    R5, M[R6] ; POP
                INC     R6 ; POP
                LOAD    R4, M[R6] ; POP
                INC     R6 ; POP
                
                JMP     R7
                
.RETURN_0:      MVI     R3, 0

                LOAD    R5, M[R6] ; POP
                INC     R6 ; POP
                LOAD    R4, M[R6] ; POP
                INC     R6 ; POP
                
                JMP     R7

PRINT_TEXT:     ; R1: Memory adress of the string that should be printed.  
                DEC     R6
                STOR    M[R6], R4
                DEC     R6
                STOR    M[R6], R5

                MOV     R4, R1

                MVI     R1, TERM_WRITE
                MVI     R2, TERM_CURSOR
                MVI     R3, TERM_COLOR

.LOOP:          LOAD    R5, M[R4]
                INC     R4
                CMP     R5, R0
                BR.Z    .Control
                STOR    M[R1], R5
                BR      .LOOP

.Control:
                LOAD    R5, M[R4]
                INC     R4
                DEC     R5
                BR.Z    .Position
                DEC     R5
                BR.Z    .Color
                BR      .End

.Position:
                LOAD    R5, M[R4]
                INC     R4
                STOR    M[R2], R5
                BR      .LOOP

.Color:
                LOAD    R5, M[R4]
                INC     R4
                STOR    M[R3], R5
                BR      .LOOP

.End:           
                LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6
                JMP     R7

; -----------------
; AUXILIARY ISR'S (AISR)
; -----------------
AUXILIARY_TIMER_ISR:
                DEC     R6
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2
                
                MVI     R2, TIMER_COUNTVAL
                MVI     R1, TIMER_COUNTER
                STOR    M[R1], R2
                
                MVI     R1, TIMER_SETSTART
                MVI     R2, TIMER_CONTROL
                STOR    M[R2], R1
                
                MVI     R2, TIMER_TICK
                LOAD    R1, M[R2]
                INC     R1
                STOR    M[R2], R1

                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                
                JMP     R7

; -----------------
; INTERRUPT SERVICE ROUTINES (ISR)
; -----------------
ORIG            7FF0h
TIMER_ISR:      DEC     R6
                STOR    M[R6], R7
                
                JAL     AUXILIARY_TIMER_ISR
                
                LOAD    R7, M[R6]
                INC     R6
                RTI

ORIG            7F30h
KEY_UP_ISR:     DEC     R6
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2

                MVI     R1, IS_JUMPING
                LOAD    R2, M[R1]
                INC     R2
                STOR    M[R1], R2

                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                RTI

ORIG            7F00h
KEY_ZERO_ISR:   DEC     R6
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2

                MVI     R1, PLAY_AGAIN
                LOAD    R2, M[R1]
                INC     R2
                STOR    M[R1], R2

                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                RTI     
