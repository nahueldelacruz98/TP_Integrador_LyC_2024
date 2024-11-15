include macros2.asm
include number.asm

.MODEL  SMALL
.386
.STACK 200h

.DATA
;variables de la tabla de simbolos
a dd ?
b dd ?
result dd ?
R dd ?
_100m dd 100000.0

.CODE

MOV AX,@DATA
MOV DS,AX
FINIT; Inicializa el coprocesador


;asignacion 
FFREE
 FLD _100m
 FSTP a
 
;imprimiendo real

  DisplayFloat a,2


FINAL:
   mov ah, 1 ; pausa, espera que oprima una tecla
   int 21h ; AH=1 es el servicio de lectura
   MOV AX, 4C00h ; Sale del Dos
   INT 21h       ; Enviamos la interripcion 21h
END ; final del archivo.