include macros2.asm
include number.asm

.MODEL  LARGE
.386
.STACK 200h

MAXTEXTSIZE equ 50

.DATA

    <SYMBOL_TABLE>

.CODE

START:
    mov AX,@DATA
    mov DS,AX
    mov es,ax
    
    <ASSEMBLY_CODE>

    int 21h
    newLine 1