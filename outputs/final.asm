include numbers.asm
include macros2.asm

.MODEL SMALL
.386
.STACK 200h

.DATA
	b	dd	?
	j	dd	?
	a	dd	?
	x	dd	?
	_434.0	dd	434.00
	_1.0	dd	1.00
	_2.0	dd	2.00

.CODE
START:

	MOV AX, @DATA
	MOV DS, AX

ET_START_IF_1:
	FLD x
	FLD _434.0
	FXCH
	FCOM
	FSTSW ax
	SAHF
	JB ET_END_IF_1
	FLD b
	FLD _1.0
	FXCH
	FCOM
	FSTSW ax
	SAHF
	JA ET_END_IF_1
	FLD a
	FLD _2.0
	FXCH
	FCOM
	FSTSW ax
	SAHF
	JNA ET_END_IF_1
	FSTP a
	FLD x
	FLD 32
	FADD
	FSTP j
	FSTP a
ET_END_IF_1:

	MOV AX, 4C00h
	INT 21h

END START