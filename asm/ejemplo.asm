include macros2.asm
include number.asm

.MODEL SMALL
.386
.STACK 200h

.DATA
; Variables de la tabla de s?mbolos
a dd ?
b dd ?
result dd ?
R dd ?
_100m dd 100000.0

.CODE
START:
    ; Inicializa el segmento de datos
    MOV AX, @DATA
    MOV DS, AX

    ; Inicializa el coprocesador matem?tico
    FINIT

    ; Asignaci?n
    FFREE
    FLD _100m
    FSTP a

    ; Imprimir n?mero real usando la macro
    DisplayFloat a, 2

    ; Esperar entrada del usuario antes de salir
FINAL:
    mov ah, 1        ; Pausa, espera que oprima una tecla
    int 21h          ; AH=1 es el servicio de lectura
    MOV AX, 4C00h    ; Salir de DOS
    INT 21h

END START             ; Define el punto de entrada del programa
