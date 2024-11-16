include number.asm
include macros2.asm

.MODEL SMALL
.386
.STACK 200h

.DATA
	y	dd	?
	a	dd	?
	_2	dd	2
	_1	dd	1
	@res	dd	?
	_0	dd	0
	_10	dd	10
	@count	dd	?
	@aux	dd	?
	@flag	dd	?

.CODE
START:

	MOV AX, @DATA
	MOV DS, AX

	FLD _2
	FSTP y
	DisplayInteger y
	FLD _0
	FSTP @count
	FLD _1
	FSTP @aux
	FLD _1
	FSTP @flag
ET_START_WHILE_1:
	FLD @aux
	FLD _0
	FXCH
	FCOM
	FSTSW ax
	SAHF
	JNA ET_END_WHILE_1
	FLD @aux
	FLD _10
	FPREM
	FSTP @res
ET_START_IF_1:
	FLD @res
	FLD _0
	FXCH
	FCOM
	FSTSW ax
	SAHF
	JE ET_END_IF_1
	FLD @res
	FLD _1
	FXCH
	FCOM
	FSTSW ax
	SAHF
	JE ET_END_IF_1
	FLD _0
	FSTP @flag
ET_END_IF_1:
	FLD @aux
	FLD _10
	FDIV
	FSTP @aux
	JMP ET_START_WHILE_1
ET_END_WHILE_1:
ET_START_IF_2:
	FLD @flag
	FLD _1
	FXCH
	FCOM
	FSTSW ax
	SAHF
	JNE ET_END_IF_2
	FLD @count
	FLD _1
	FADD
	FSTP @count
ET_END_IF_2:
	FLD @aux
	FLD _10
	FDIV
	FSTP @aux
	FLD @res
	FSTP y
	DisplayInteger y

	MOV AX, 4C00h
	INT 21h

END START