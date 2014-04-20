;LAB 8: TSR Programming
;FILENAME: tsr.ASM 
;FILE FORMAT: COM 


INCLUDE DOS.MAC

code SEGMENT
ASSUME CS:code, DS:code, SS:code, ES:code

ORG 100H
begin:
	JMP Initialize
	Color DB ?
	SaveY DW ?
	BallColor DB ?
	FillSto DW ?
	ADD61 DD ?
	ADD62 DD ?
	ADD66 DD ?
	
;begin resident program here
int61 	PROC FAR	;shell format for an interrupt declaration
	MOV BX, DS
	PUSH BX
	
	MOV BX, CS
	MOV DS, BX
	
Clear_Screen:
	MOV AH, 06H	
	MOV AL, 00H
	MOV BH, 00D
	MOV CX, 0000h
	MOV DH, 24D
	MOV DL, 79D
	INT 10H
Close_61:
	POP AX
	MOV DS, AX
	
	IRET
int61	ENDP

int62	PROC FAR	
	;use this interrupt to perform the 
	;drawing functions (draw_rectangle (filled/not filled), draw_line (horizontal/vert.))
	CMP AH,01
	JE RecF
	CMP AH,02
	JE RecNF
	CMP AH,03
	JE Vertical
	CMP AH,04
	JE Horizontal2
RecF:
	XOR BP,BP
	ADD BP,CX
	ADD BP,DI
	MOV FillSto,CX
	MOV Color,AL
	XOR BX,BX
	ADD BX,DX
	ADD BX,SI
Fill:
	MOV AH,0Ch
	MOV AL,Color
	INT 10H
	INC CX
	CMP CX,BP
	JNE Fill
	MOV CX,FillSto
	INC DX
	CMP DX,BX
	JNE Fill
	JE Close_62
Horizontal2:
	JMP Horizontal
RecNF:
	MOV Color,AL
	MOV SaveY,DX
Top:
	MOV AH,0Ch
	MOV AL,Color
	INT 10H
	INC CX
	CMP CX,DI
	JNE Top
	MOV CX,DX
LSide:
	MOV AH,0Ch
	MOV AL,Color
	INT 10H
	INC DX
	CMP DX,SI
	JNE LSide
Bottom:
	MOV AH,0Ch
	MOV AL,Color
	INT 10H
	INC CX
	CMP CX,DI
	JNE Bottom
RSide:
	MOV AH,0Ch
	MOV AL,Color
	INT 10H
	DEC DX
	CMP DX,SaveY
	JNE RSide
	JMP Close_62
	
Vertical:
	XOR BX,BX
	ADD BX,DX
	ADD BX,SI
	MOV BallColor,AL
Vline:
	MOV AH,0Ch
	MOV AL,BallColor
	INT 10H
	INC DX
	CMP DX,BX
	JNE Vline
	JMP Close_62
Horizontal:
	XOR BP,BP
	ADD BP,CX
	ADD BP,DI
	MOV BallColor,AL
Hline:
	MOV AH,0Ch
	MOV AL,BallColor
	INT 10H
	INC CX
	CMP CX,BP
	JNE Hline
	
Close_62:
	IRET
int62	ENDP

int63	PROC FAR	;user interrupts 61-66
	
	IRET
int63	ENDP

int66	PROC FAR
	MOV DS, WORD PTR ADD61
	LEA DX, WORD PTR int61[2]
	MOV AH, 25H
	MOV AL, 61H
	INT 21H
	
	MOV DS, WORD PTR ADD62
	LEA DX, WORD PTR int62[2]
	MOV AH, 25H
	MOV AL, 62H
	INT 21H

	MOV DS, WORD PTR ADD66
	LEA DX, WORD PTR int66[2]
	MOV AH, 25H
	MOV AL, 66H
	INT 21H

	
	IRET
int66	ENDP
;end resident program here

Initialize:
	; Get interrupt vector:
; i) Calling registers:
; (1) AH: 35H
; (2) AL: Interrupt number
; ii) Return registers:
; (1) ES: Code segment of the interrupt service routine
; (2) BX: Offset of the interrupt service routine
;GET INT VECTORS
	MOV AH, 35H
	MOV AL, 61H
	INT 21H
	MOV WORD PTR ADD61, ES
	MOV WORD PTR ADD61[2],BX
	
	MOV AH, 35H
	MOV AL, 62H
	INT 21H
	MOV WORD PTR ADD62, ES
	MOV WORD PTR ADD62[2],BX
	
	MOV AH, 35H
	MOV AL, 66H
	INT 21H
	MOV WORD PTR ADD66, ES
	MOV WORD PTR ADD66[2],BX
	;SET INT VECTORS
	MOV BX, CS
	MOV DS, BX
	LEA DX, int61
	MOV AH, 25H
	MOV AL, 61H
	INT 21H

	LEA DX, int62
	MOV AL, 62H
	INT 21H

	LEA DX, int66
	MOV AL, 66H
	INT 21H

	LEA DX,Initialize
	INT 27H
	
code 	ENDS 
END begin 