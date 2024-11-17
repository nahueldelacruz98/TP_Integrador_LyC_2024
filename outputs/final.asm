include number.asm
include macros2.asm

.MODEL SMALL
.386
.STACK 200h

.DATA
@salto_linea db 0Ah, "$"
	c	dd	?
	b	dd	?
	a	dd	?
	e	dd	?
	d	dd	?
	_1	dd	1.00
	_3	dd	3.00
	_5	dd	5.00
	_9	dd	9.00
	_1_50	dd	1.50
	__3	dd	0.30
	_10	dd	10.00
	_20	dd	20.00
	_2	dd	2.00
	_15	dd	15.00
	_C_alcanzo_15	db	"C alcanzo 15",'$', 12 dup (?)
	_C_es_diferente_de_15	db	"C es diferente de 15",'$', 20 dup (?)
	_5_0	dd	5.00
	_3_5	dd	3.50
	_D_supero_3_5	db	"D supero 3.5",'$', 12 dup (?)
	_2_0	dd	2.00
	_D_es_menor_o_igual_a_3_5	db	"D es menor o igual a 3.5",'$', 24 dup (?)
	_50	dd	50.00
	_A_es_mayor_que_50	db	"A es mayor que 50",'$', 17 dup (?)
	_A_sigue_siendo_menor_o_igual_a_50	db	"A sigue siendo menor o igual a 50",'$', 33 dup (?)

.CODE
START:

	MOV AX, @DATA
	MOV DS, AX

	FLD _1
	FSTP a
	FLD _3
	FLD _5
	FMUL
	FLD a
	FADD
	FSTP b
	FLD _9
	FLD a
	FDIV
	FSTP c
	FLD _1_50
	FSTP d
	FLD __3
	FSTP e
ET_START_WHILE_1:
	FLD a
	FLD b
	FXCH
	FCOM
	FSTSW ax
	SAHF
	JAE ET_END_WHILE_1
	FLD a
	FLD _10
	FADD
	FSTP a
ET_START_WHILE_2:
	FLD c
	FLD _20
	FXCH
	FCOM
	FSTSW ax
	SAHF
	JAE ET_END_WHILE_2
	FLD c
	FLD _2
	FADD
	FSTP c
ET_START_IF_1:
	FLD c
	FLD _15
	FXCH
	FCOM
	FSTSW ax
	SAHF
	JNE ET_END_IF_1
	displayString _C_alcanzo_15
	displayString @salto_linea
	JMP ET_END_IF_2
ET_END_IF_1:
	displayString _C_es_diferente_de_15
	displayString @salto_linea
ET_END_IF_2:
ET_START_WHILE_3:
	FLD d
	FLD _5_0
	FXCH
	FCOM
	FSTSW ax
	SAHF
	JAE ET_END_WHILE_3
	FLD d
	FLD e
	FADD
	FSTP d
ET_START_IF_3:
	FLD d
	FLD _3_5
	FXCH
	FCOM
	FSTSW ax
	SAHF
	JNA ET_END_IF_3
	displayString _D_supero_3_5
	displayString @salto_linea
	FLD e
	FLD _2_0
	FMUL
	FSTP e
	JMP ET_END_IF_4
ET_END_IF_3:
	displayString _D_es_menor_o_igual_a_3_5
	displayString @salto_linea
ET_END_IF_4:
	JMP ET_START_WHILE_3
ET_END_WHILE_3:
	JMP ET_START_WHILE_2
ET_END_WHILE_2:
ET_START_IF_5:
	FLD a
	FLD _50
	FXCH
	FCOM
	FSTSW ax
	SAHF
	JNA ET_END_IF_5
	displayString _A_es_mayor_que_50
	displayString @salto_linea
	JMP ET_END_IF_6
ET_END_IF_5:
	displayString _A_sigue_siendo_menor_o_igual_a_50
	displayString @salto_linea
ET_END_IF_6:
	JMP ET_START_WHILE_1
ET_END_WHILE_1:

	MOV AX, 4C00h
	INT 21h

END START