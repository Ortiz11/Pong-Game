;Nicholas Ortiz
;**********************************************************
include dos.mac
STACK_SEG SEGMENT STACK	
	DB 100h DUP(?)
STACK_SEG ENDS
;**********************************************************
DATA_SEG SEGMENT 'DATA'	
	LIST DB 200h DUP(?)
	FileBuff DB 200h Dup(?)
	SLIST DB 10h DUP(?)
	NLIST DB 11 DUP(?)
	BUFF DB 20h,?,20h DUP(?)
	MSG1 DB 0Ah, 0Dh, "Would you like to: ", '$'
	MSGA DB 0Ah, 0Dh, "a. Play the game?", '$'
	MSGB DB 0Ah, 0Dh, "b. See the high scores?", '$'
	MSGC DB 0Ah, 0Dh, "c. Access options menu?", '$'
	MSGD DB 0Ah, 0Dh, "d. Exit the program?", '$'
	MSGA1 DB 0Ah, 0Dh, "Haven't made the game yet.", '$'
	MSGB1 DB 0Ah, 0Dh, "Haven't made the file yet.", '$'
	MSGC1 DB 0Ah, 0Dh, "Haven't made the options menu yet.", '$'
	INVALID DB 0Ah, 0Dh, "Invalid input.", '$'
	MSGO DB 0Ah, 0Dh, "Do you want to: ", '$'
	MSGO1 DB 0Ah, 0Dh, "1.) Edit highscores", '$'
	MSGO2 DB 0Ah, 0Dh, "2.) Change color scheme", '$'
	MSGO3 DB 0Ah, 0Dh, "3.) Exit sub-menu", '$'
	MSGD1 DB 0Ah, 0Dh, "Please Click on a color.", '$'
	MSGD2 DB 0Ah, 0Dh, "Choose your Colors:", '$'
	MSGD3 DB 0Ah, 0Dh, "Selected colors are:", '$'
	MSGD4 DB 0Ah, 0Dh, "1st Click=Paddle,2nd Click=Ball", '$'
	MSGD5 DB 0Ah, 0Dh, "Movement=(a,d),Start=(s),Exit=(e)                      Score:",'$'
	MSGD6 DB 0Ah, 0Dh, "                                                       Score:",'$'
	MSGD7 DB 0Ah, 0Dh, "                               Game Over",'$'
	ENAME DB 0Ah, 0Dh, "Enter a name and score separated by a :.", '$'
	Empty DB 0Ah, 0Dh, "The high score list is empty", '$'
	Stars DB 0Ah, 0Dh, "*************************", '$'
	Hscores DB 0Ah, 0Dh,"*******High Scores*******", '$'
	NL		DB	0AH, 0DH, '$'
	FileName DB 'Scores.bin',0
	FileHandle DW 0
	NoFile DB 0
	XB DW ?
	YB DW ?
	BallLine DW ?
	XBS DW 320
	YBS DW 173
	XCS DW 316
	YCS DW 173
	XC DW ?
	YC DW ?
	ClrW DW ?
	ClrH DW ?
	Tick DB 0
	PaddleXS DW 250
	PaddleXE DW 400
	X DW ?
	Y DW ?
	RecW DW ?
	RecH DW ?
	NoColor DB ?
	Color DB ?
	PadColor DB 1
	BallColor DB 10
	ColorCount DB 0
	Num_char DW ?
	GameOver DB 0
	Score DB 0
	Bytes2R DW 0
	Bytes2W DW 0
	BytesRead DW 0
	BytesWritten DW 0
	NumHex DB 4 DUP(0)
	NumAsc DB 9 DUP(0)
	AscHolder DB ?
	Holder DB 4 DUP(0)
	Count DB 4 DUP(0)
	FirstItem DW OFFSET LIST
	NextItem DW ?
	LastItem DW ?
	FirstTime DB 0
	PTR1 DW 0
	CountHolder DW 0
	CountHolder2 DW 0
	ByteMul DB 0
	CountL DW ?
	IsInv DB ?
	CHAR DB ?
	Last DW ?
DATA_SEG ENDS 
;**********************************************************
CODE_SEG SEGMENT 'CODE'  
ASSUME CS:CODE_SEG, DS:DATA_SEG, SS:STACK_SEG
;**********************************************************
;Menu for the console window
MAIN PROC FAR 	
	PUSH DS    
	MOV AX,DATA_SEG ;set the data segment location    
	MOV DS,AX
	MOV ES,AX
	MOV AX,STACK_SEG ;set the stack segment location	
	MOV SS,AX
Call Initialize
Call ReadFile
Start: 
	@disp MSG1    ;print msg1
    @disp MSGA    ;print msga
	@disp MSGB    ;print msgb
	@disp MSGC    ;print msgc
	@disp MSGD    ;print msgd
	@disp NL
	@read_char    ;read character
	   
	CMP AL, 60h          ;Checks to see if it is lowercase a,b,c,d
	JA Lowercase
	CMP AL, 40h          ;Checks to see if it is Uppercase A,B,C,D
	JA Uppercase
	CMP AL, 41h          ;Anything below 41h will be invalid
	JB readinvalidx
Lowercase:  
        CMP AL,65h             ;If between 61-64h it will jump to MainmenuLow
		JB MainmenuLow
		CMP AL, 64h
		JA readinvalidx          ;If above 64h it will be invalid
Uppercase:
		CMP AL,45h              ;If between 41-44h it will jump to MainmenuUp
		JB MainmenuUp
		CMP AL, 44h
		JA readinvalidx          ;If between 45-60h it will be Invalid
MainmenuLow:	
	CMP AL, 'a'
	JE READA
	
	CMP AL, 'b'
	JE READB
	
	CMP AL, 'c'
	JE READC
	
	CMP AL, 'd'
	JE READD
mainmenuUp:	
	CMP AL, 'A'
	JE READA
	
	CMP AL, 'B'
	JE READB
	
	CMP AL, 'C'
	JE READC
	
	CMP AL, 'D'
	JE READD
ReadInvalidx:
	JMP ReadInvalid
READA:	
	;@disp MSGA1    ;print msga1
	Call SplashScreen
	Call GraphicMenu
	@Video2
	JMP START

READB: 	
	Call displaylist    ;Display List
	JMP START

READC: 	
	Call OptionsMenu    ;Call the subProc OptionsMenu
	JMP START
	
READD: 
	MOV DL,0
	MOV DL,NoFile
	CMP DL,1
	JE DontSave
	Call ResetList
	Call WriteFile
DontSave:
	.exit	
	
READINVALID: 
	@disp INVALID	;print invalid
	JMP START

	.exit				;return to DOS
MAIN    ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;splashscreen when the game is opened
SplashScreen proc near
	@Clear_Screen
	@Cursor
	@Video
	@Logo
	MOV BX,9
	MOV X,10
	MOV Y,10
	MOV RecW,620
	MOV RecH,190
	MOV Color,1
LogoPic:
	PUSH BX
	@Draw_RecNF X Y RecW RecH Color
	ADD X,10
	ADD Y,10
	SUB RecW,10
	SUB RecH,10
	ADD Color,1
	POP BX
	DEC BX
	CMP BX,0
	JNE LogoPic
	@TimeD1
	@Clear_Screen
	RET
SplashScreen endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;draw the game board and paddle
ColorBox Proc Near
	@CursorC
	MOV Num_char,21
	MOV DH,0
	@GMenu MSGD2 Num_Char
	MOV Num_char,33
	MOV DH,1
	@GMenu MSGD4 Num_Char
	MOV CX,50
	MOV DX,50
	MOV DI,30
	MOV SI,10
	MOV AL,1
	MOV X,CX
	MOV Y,DX
	MOV RecW,DI
	MOV RecH,SI
	MOV Color,AL
	@Draw_RecF X Y RecW RecH Color
	MOV CX,X
	MOV DX,Y
	MOV AL,Color
	MOV BX,3
Col1:
	PUSH BX
	ADD DX,10
	ADD AL,1
	MOV Y,DX
	MOV Color,AL
	@Draw_RecF X Y RecW RecH Color
	MOV CX,X
	MOV DX,Y
	MOV AL,Color
	POP BX
	DEC BX
	CMP BX,0
	JNE Col1
	MOV AL,Color
	MOV BX,4
	MOV CX,80
	MOV DX,40
	MOV X,CX
Col2:
	PUSH BX
	ADD DX,10
	ADD AL,1
	MOV Y,DX
	MOV Color,AL
	@Draw_RecF X Y RecW RecH Color
	MOV CX,X
	MOV DX,Y
	MOV AL,Color
	POP BX
	DEC BX
	CMP BX,0
	JNE col2
	MOV AL,Color
	MOV BX,4
	MOV CX,110
	MOV DX,40
	MOV X,CX
Col3:
	PUSH BX
	ADD DX,10
	ADD AL,1
	MOV Y,DX
	MOV Color,AL
	@Draw_RecF X Y RecW RecH Color
	MOV CX,X
	MOV DX,Y
	MOV AL,Color
	POP BX
	DEC BX
	CMP BX,0
	JNE Col3
	MOV BX,4
	MOV CX,140
	MOV DX,40
	MOV X,CX
Col4:
	PUSH BX
	ADD DX,10
	ADD AL,1
	MOV Y,DX
	MOV Color,AL
	@Draw_RecF X Y RecW RecH Color
	MOV CX,X
	MOV DX,Y
	MOV AL,Color
	POP BX
	DEC BX
	CMP BX,0
	JNE Col4
Inside:
	MOV AX,03
	INT 33h
	CMP BX,1
	JNE Inside
	MOV AX,02
	INT 33h
	CMP CX,50
	JB Not_Inside
	CMP CX,170
	JA Not_Inside
	CMP DX,50
	JB Not_Inside
	CMP DX,90
	JA Not_Inside
	JMP ChangeColor
Not_Inside:
	@Clear_Screen
	MOV Num_char,25
	MOV DH,20
	@GMenu MSGD1 Num_Char
	ADD NoColor,1
	MOV ColorCount,0
	MOV PadColor,1
	RET
ChangeColor:
	CMP CX,110
	JB LeftC
	JA RightC
LeftC:
	CMP DX,70
	JA BottomL
	JB TopL
RightC:
	CMP DX,70
	JA BottomR
	JB TopR
BottomL:
	CMP CX,80
	JB LBottomL
	JA RBottomL
TopL:
	CMP CX,80
	JB LTopL
	JA RTopL
LBottomL:
	CMP DX,80
	JB Cyan
	JA Red
Cyan:
	MOV Color,0011b
	Call ColorPick
	RET
Red:
	MOV Color,0100b
	Call ColorPick
	RET
RBottomL:
	CMP DX,80
	JB White
	JA Gray
White:
	MOV Color,0111b
	Call ColorPick
	RET
Gray:
	MOV Color,1000b
	Call ColorPick
	RET
BottomR:
	CMP CX,140
	JB LBottomR
	JA RBottomR
TopR:
	CMP CX,140
	JB LTopR
	JA RTopR
LTopL:
	CMP DX,60
	JA Green
	JB Blue
Green:
	MOV Color,0010b
	Call ColorPick
	RET
Blue:
	MOV Color,0001b
	Call ColorPick
	RET
RTopL:
	CMP DX,60
	JA Brown
	JB Magenta
Brown:
	MOV Color,0110b
	Call ColorPick
	RET
Magenta:
	MOV Color,0101b
	Call ColorPick
	RET
LBottomR:
	CMP DX,80
	JA LightR
	JB LightC
LightR:
	MOV Color,1100b
	Call ColorPick
	RET
LightC:
	MOV Color,1011b
	Call ColorPick
	RET
RBottomR:
	CMP DX,80
	JA Black
	JB HWhite
Black:
	MOV Color,0000b
	Call ColorPick
	RET
Hwhite:
	MOV Color,1111b
	Call ColorPick
	RET
LTopR:
	CMP DX,60
	JA LGreen
	JB LBlue
LGreen:
	MOV Color,1010b
	Call ColorPick
	RET
LBlue:
	MOV Color,1001b
	Call ColorPick
	RET
RTopR:
	CMP DX,60
	JA Yellow
	JB LMegenta
Yellow:
	MOV Color,1110b
	Call ColorPick
	RET
LMegenta:
	MOV Color,1101b
	Call ColorPick
	RET
ColorBox Endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;pick the color and ball color
ColorPick proc near
	@Clear_Screen
	MOV CL,ColorCount
	ADD CL,1
	MOV ColorCount,CL
	CMP CL,1
	JNE BallC
	MOV AL,Color
	MOV PadColor,AL
	RET
BallC:
	MOV AL,Color
	MOV BallColor,AL
	MOV Num_char,22
	MOV DH,20
	@GMenu MSGD3 Num_Char
	MOV CX,175
	MOV DX,160
	MOV DI,60
	MOV SI,20
	MOV X,CX
	MOV Y,DX
	MOV RecW,DI
	MOV RecH,SI
	MOV AL,PadColor
	MOV Color,AL
	@Draw_RecF X Y RecW RecH Color
	MOV CX,245
	MOV DX,160
	MOV DI,60
	MOV SI,20
	MOV X,CX
	MOV Y,DX
	MOV RecW,DI
	MOV RecH,SI
	MOV AL,BallColor
	MOV Color,AL
	@Draw_RecF X Y RecW RecH Color
	RET
ColorPick ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;the menu for the game using graphics not console
GraphicMenu proc near
StartG:
	MOV Num_char,20
	MOV DH,0
	@GMenu MSG1 Num_Char
	MOV DH,1
	MOV Num_char,19
	@GMenu MSGA Num_Char
	MOV DH,2
	MOV Num_char,25
	@GMenu MSGB Num_Char
	MOV DH,3
	MOV Num_char,25
	@GMenu MSGC Num_Char
	MOV DH,4
	MOV Num_char,22
	@GMenu MSGD Num_Char
	@disp NL
	@read_char
	
	CMP AL, 60h          ;Checks to see if it is lowercase a,b,c,d
	JA LowercaseG
	CMP AL, 40h          ;Checks to see if it is Uppercase A,B,C,D
	JA UppercaseG
	CMP AL, 41h          ;Anything below 41h will be invalid
	JB readinvalidxG
LowercaseG:  
        CMP AL,65h             ;If between 61-64h it will jump to MainmenuLow
		JB MainmenuLowG
		CMP AL, 64h
		JA readinvalidxG        ;If above 64h it will be invalid
UppercaseG:
		CMP AL,45h              ;If between 41-44h it will jump to MainmenuUp
		JB MainmenuUpG
		CMP AL, 44h
		JA readinvalidxG          ;If between 45-60h it will be Invalid
MainmenuLowG:	
	CMP AL, 'a'
	JE READAG
	
	CMP AL, 'b'
	JE READBG
	
	CMP AL, 'c'
	JE READCG
	
	CMP AL, 'd'
	JE READDG
mainmenuUpG:	
	CMP AL, 'A'
	JE READAG
	
	CMP AL, 'B'
	JE READBG
	
	CMP AL, 'C'
	JE READCG
	
	CMP AL, 'D'
	JE READDG
StartG2:
	JMP StartG
ReadInvalidxG:
	JMP ReadInvalidG
READDG:
	JMP ExitG
READBG:
	@Clear_Screen
	Call displaylist
	JMP STARTG2
READCG:
	@Clear_Screen
	Call OptionGMenu
	JMP STARTG2
READAG:
	@Clear_Screen
	Call Game
	MOV XBS,320
	MOV YBS,173
	MOV XCS,316
	MOV YCS,173
	MOV Tick,0
	MOV PaddleXS,250
	MOV PaddleXE,400
	MOV GameOver,0
	@Clear_Screen
	MOV DH,Score
	CMP DH,0
	JE STARTG2
	MOV Num_char,63
	MOV DH,0
	@GMenu MSGD6 Num_Char
	MOV Num_char,42
	MOV DH,10
	@GMenu MSGD7 Num_Char
	Call ScoreScreen
	MOV Score,0
	@disp ENAME
	@disp NL
	@read_str BUFF
	Call parse			;Splits Name and Score
	CMP IsInv,0
	JE AddToList2		;If Valid then add item
	JNE READInvalidG
READInvalidG:
	@Clear_Screen
	@disp INVALID	;print invalid
	JMP STARTG2
AddToList2:
	Call AddItem
	@Clear_Screen
	JMP STARTG2
ExitG:
RET
GraphicMenu EndP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;paddle movement and checks for exit
Game proc near
	MOV Num_char,63
	MOV DH,0
	@GMenu MSGD5 Num_Char
	MOV XB,0
	MOV YB,20
	MOV BallLine,640
	@Draw_Hline XB YB BallLine BallColor
	MOV XB,0
	MOV YB,20
	MOV BallLine,160
	@Draw_Vline XB YB BallLine BallColor
	MOV XB,1
	@Draw_Vline XB YB BallLine BallColor
	MOV XB,638
	@Draw_Vline XB YB BallLine BallColor
	MOV XB,639
	@Draw_Vline XB YB BallLine BallColor
	MOV X,215
	MOV Y,92
	MOV RecW,175
	MOV RecH,3
	MOV AL,PadColor
	MOV Color,AL
	@Draw_RecF X Y RecW RecH Color
	MOV X,250
	MOV Y,180
	MOV RecW,150
	MOV RecH,10
	@Draw_RecF X Y RecW RecH Color
	Call DrawBall
StartGame:
	MOV AH,0
	INT 16h
	MOV AH,1
	INT 16h
	CMP AL,'e'
	JE ExitGame
	CMP AL,'s'
	JNE StartGame
CheckKey:
	Call BallMovement
	MOV AL,GameOver
	CMP AL,1
	JE ExitGame
	@TimeD2
	MOV AH,1
	INT 16h
	JZ CheckKey
	MOV AH,0
	INT 16h
	CMP AL,'e'
	JE ExitGame
	JNE Movement
ExitGame:
RET
Movement:
	CMP AL,'d'
	JE Right
	CMP AL,'a'
	JE Left
	JNE CheckKey
CheckKey2:
	JMP CheckKey
Right:
	MOV BP,PaddleXE
	CMP BP,650
	JE CheckKey2
	MOV Color,0
	@Draw_RecF X Y RecW RecH Color
	ADD X,50
	MOV CX,X
	MOV PaddleXS,CX
	ADD CX,150
	MOV PaddleXE,CX
	MOV AL,PadColor
	MOV Color,AL
	@Draw_RecF X Y RecW RecH Color
	JMP CheckKey
Left:
	MOV BP,PaddleXS
	CMP BP,0
	JE CheckKey2
	MOV Color,0
	@Draw_RecF X Y RecW RecH Color
	SUB X,50
	MOV CX,X
	MOV PaddleXS,CX
	MOV CX,PaddleXE
	SUB CX,50
	MOV PaddleXE,CX
	MOV AL,PadColor
	MOV Color,AL
	@Draw_RecF X Y RecW RecH Color
	JMP CheckKey2
Game EndP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;draw the ball
DrawBall Proc Near
	MOV CX,XBS
	MOV XB,CX
	MOV CX,YBS
	MOV YB,CX
	MOV BallLine,4
	@Draw_Hline XB YB BallLine BallColor
	SUB XB,2
	ADD YB,1
	MOV BallLine,8
	@Draw_Hline XB YB BallLine BallColor
	SUB XB,2
	ADD YB,1
	MOV BallLine,12
	@Draw_Hline XB YB BallLine BallColor
	ADD YB,1
	@Draw_Hline XB YB BallLine BallColor
	ADD XB,2
	ADD YB,1
	MOV BallLine,8
	@Draw_Hline XB YB BallLine BallColor
	ADD XB,2
	ADD YB,1
	MOV BallLine,4
	@Draw_Hline XB YB BallLine BallColor
	RET
DrawBall ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;control the ball movement on the board
BallMovement proc near
	MOV CX,XCS
	MOV XC,CX
	MOV CX,YCS
	MOV YC,CX
	MOV ClrW,12
	MOV ClrH,6
	MOV Color,0
	@Draw_RecFC XC YC ClrW ClrH Color
	MOV AL,Tick
	CMP AL,0
	JE RUp
	CMP AL,1
	JE LUp2
	CMP AL,2
	JE LDown2
	CMP AL,3
	JE RDown
RUp:
	MOV AL,0
	MOV Tick,AL
	ADD XBS,3
	SUB YBS,1
	ADD XCS,3
	SUB YCS,1
	MOV CX,XBS
	CMP CX,212
	JE ChkBlkHRU
	CMP CX,632
	JE LUp2
	MOV DX,YBS
	CMP DX,96
	JE ChkBlkWRU
	CMP DX,21
	JE	RDown
	JNE Continue3
ChkBlkHRU:
	MOV DX,YBS
	CMP DX,89
	JA ChkHRU
	JB Continue3
ChkHRU:
	CMP DX,96
	JB LUp2
	JA Continue3
RUp3:
	JMP RUp
LUp2:
	JMP LUp
ChkBlkWRU:
	MOV CX,XBS
	CMP CX,211
	JA ChkWRU
	JB Continue2
ChkWRU:
	CMP CX,391
	JB RDown
	JA Continue2
Continue3:
	JMP Continue2
LDown2:
	JMP LDown
RDown:
	MOV AL,3
	MOV Tick,AL
	ADD XBS,3
	ADD YBS,1
	ADD XCS,3
	ADD YCS,1
	MOV DX,YBS
	CMP DX,87
	JE ChkBlkWRD
	CMP DX,176
	JE CheckPad2
	MOV CX,XBS
	CMP CX,212
	JE ChkBlkHRD
	CMP CX,632
	JE LDown3
	JNE Continue2
ChkBlkHRD:
	MOV DX,YBS
	CMP DX,86
	JA ChkHRD
	JB Continue2
ChkHRD:
	CMP DX,96
	JB LDown3
	JA Continue2
ChkBlkWRD:
	MOV CX,XBS
	CMP CX,211
	JA ChkWRD
	JB Continue2
ChkWRD:
	CMP CX,391
	JB RUp3
	JA Continue2
Continue2:
	JMP Continue
CheckPad2:
	JMP CheckPad
RDown2:
	JMP RDown
LDown3:
	JMP LDown
LUp:
	MOV AL,1
	MOV Tick,AL
	SUB XBS,3
	SUB YBS,1
	SUB XCS,3
	SUB YCS,1
	MOV DX,YBS
	CMP DX,96
	JE ChkBlkWLU
	CMP DX,21
	JB FixError
	JE FixError
	MOV CX,XBS
	CMP CX,389
	JE ChkBlkHLU
	CMP CX,5
	JB Rdown2
	JE RUp2
	JNE Continue4
FixError:
	MOV CX,XBS
	CMP CX,2
	JB RDown2
	JA LDown
ChkBlkHLU:
	MOV DX,YBS
	CMP DX,88
	JA ChkHLU
	JB Continue4
ChkHLU:
	CMP DX,97
	JB RUp2
	JA Continue4
ChkBlkWLU:
	MOV CX,XBS
	CMP CX,211
	JA ChkWLU
	JB Continue4
ChkWLU:
	CMP CX,391
	JB LDown
	JA Continue4
RDown3:
	JMP RDown2
Continue4:
	JMP Continue
LDown:
	MOV AL,2
	MOV Tick,AL
	SUB XBS,3
	ADD YBS,1
	SUB XCS,3
	ADD YCS,1
	MOV DX,YBS
	CMP DX,87
	JE ChkBlkWLD
	CMP DX,176
	JE CheckPad
	MOV CX,XBS
	CMP CX,389
	JE ChkBlkHLD
	CMP CX,5
	JE RDown3
	JNE Continue
RUp2:
	JMP RUp
LUp3:
	JMP LUp2
ChkBlkHLD:
	MOV DX,YBS
	CMP DX,86
	JA ChkHLD
	JB Continue
ChkHLD:
	CMP DX,96
	JB RDown3
	JA Continue
ChkBlkWLD:
	MOV CX,XBS
	CMP CX,211
	JA ChkWLD
	JB Continue
ChkWLD:
	CMP CX,391
	JB LUp3
	JA Continue
CheckPad:
	MOV CX,XBS
	MOV BP,PaddleXS
	CMP CX,BP
	JA CheckXE
	JB Dead
CheckXE:
	MOV BP,PaddleXE
	CMP CX,BP
	JB CheckAL
	JA Dead
CheckAl:
	PUSH AX
	MOV AL,Score
	ADD AL,1
	MOV Score,AL
	Call ScoreScreen
	POP AX
	CMP AL,2
	JE LUp3
	JNE RUp2
Dead:
	MOV GameOver,1
	RET
Continue:
	Call DrawBall
	RET
BallMovement endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;show the scorescreen in the game
ScoreScreen Proc Near
	MOV AL,Score
	MOV Score,AL
	MOV NumHex,AL
	LEA SI,NumHex
	Call Hex2Asc
	LEA SI,NumAsc+8
	MOV AL,[SI]
	MOV AH,02
	MOV BH,0
	MOV DH,1
	MOV DL,70
	INT 10h
	MOV AH,09
	MOV BH,00
	MOV CX,1
	MOV BL,10
	INT 10h
	MOV AL,Score
	CMP AL,10
	JA NextD
	JB OutLoop
NextD:
	LEA SI,NumAsc+7
	MOV AL,[SI]
	MOV AH,02
	MOV BH,0
	MOV DH,1
	MOV DL,69
	INT 10h
	MOV AH,09
	MOV BH,00
	MOV CX,1
	MOV BL,10
	INT 10h
	MOV AL,Score
	CMP AL,100
	JA NextD2
	JB OutLoop
NextD2:
	LEA SI,NumAsc+6
	MOV AL,[SI]
	MOV AH,02
	MOV BH,0
	MOV DH,1
	MOV DL,68
	INT 10h
	MOV AH,09
	MOV BH,00
	MOV CX,1
	MOV BL,10
	INT 10h
OutLoop:
	RET
ScoreScreen Endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;the options menu in the game
OptionGMenu proc near
StartOG:
	MOV AL,0
	MOV NoColor,AL
	MOV Num_char,17
	MOV DH,0
	@GMenu MSGO Num_Char
	MOV DH,1
	MOV Num_char,25
	@GMenu MSGO2 Num_Char
	MOV DH,2
	MOV Num_char,19
	@GMenu MSGO3 Num_Char

	@disp NL
	@read_char
	
	CMP AL, 30h    ;Checks to see if it is possible for 1,2,3
	JA NumG
	CMP AL, 31h    ;If it is 30h or below it will be invalid
	JB readinvalid2G
NumG:
	CMP AL, 34h    ;If the key is 1,2,or 3 it will go to the submenu
	JB SubMenuG
	CMP AL, 33h     ;If it is 34 or above it will be invalid
	JA readinvalid2G
StartOG2:
	JMP StartOG
SubMenuG:
	CMP AL, '1'
	JE READA2G
	CMP AL, '2'
	JE READA2G
	CMP AL, '3'
	JE READEXITG
READA2G:
	@Clear_Screen
	Call ColorBox
	MOV AL,NoColor
	CMP AL,1
	JE StartOG2
	Call ColorBox
	MOV AL,NoColor
	CMP AL,1
	JE StartOG2
	MOV ColorCount,0
	JMP StartOG2
READInvalid2G:
	@Clear_Screen
	@disp Invalid
	JMP StartOG
READEXITG:
	@Clear_Screen
RET
endp
ResetList proc near
	LEA DI,FileBuff
	XOR DX,DX
	MOV SI,FirstItem
	MOV AX,SI
	MOV BP,CountHolder2
	CMP BP,9
	JA Skip
	
	MOV BP,Last
	MOV [DI],BP
	INC DI
	MOV BP,CountHolder2
	MOV [DI],BP
	INC DI
Startx:
	CMP BP,0
	JE JmpOut
ChangeFirst:
	MOV NextItem,AX
	MOV CX,11h
	ADD DX,11h
	MOV SI,NextItem
	MOV AX,[SI]		
	MOV [SI],DX
CopyList:
	MOV BL,[SI]
	MOV [DI],BL
	INC SI
	INC DI
	LOOP CopyList
	DEC BP
	CMP BP,0
	JE JmpOut
	JNE ChangeFirst
Skip:
	MOV BP,00ACh
	MOV [DI],BP
	INC DI
	MOV BP,10
	MOV [DI],BP
	INC DI
	JMP startx
JmpOut:
	XOR DX,DX
	MOV [DI],DX
RET
ResetList endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WriteFile proc near
@Create FileName FileHandle
@Open FileName FileHandle
MOV CX,00AEh
LEA DX,FileBuff
@Write FileHandle BytesWritten
@Close FileHandle
RET
WriteFile endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ReadFile proc near
@Open FileName FileHandle
CMP AX,2
JE Skip2
MOV CX,00AEh
LEA DX,FileBuff
@Read FileHandle BytesRead
@Close FileHandle
XOR BX,BX
XOR DX,DX
LEA DI,FileBuff
LEA SI,List
MOV DL,[DI]
MOV Last,DX
INC DI
XOR DX,DX
MOV DL,[DI]
MOV CountHolder2,DX
SUB DX,1
MOV FirstTime,DL
INC DI
MOV CX,00AEh
MoveList:
	MOV BL,[DI]
	MOV [SI],BL
	INC DI
	INC SI
	LOOP MoveList
RET
Skip2:
MOV DL,0
ADD DL,1
MOV NoFile,DL
RET
ReadFile endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TestDis proc near
@disp NL
	Xor CX,CX
	MOV AX,0
	MOV DX,0
	MOV BX,0
	MOV CX,88h
	MOV SI,OFFSET List
	jmp backx9
backx9:
	MOV AL,[SI]
	MOV DL,AL
	@dispchar1
	INC SI
	LOOP backx9
RET
TestDis endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OptionsMenu PROC NEAR
OptionStart:
	@disp MSGO
	@disp MSGO1
	@disp MSGO2
	@disp MSGO3
	@disp NL
	@read_char
	CMP AL, 30h    ;Checks to see if it is possible for 1,2,3
	JA Num
	CMP AL, 31h    ;If it is 30h or below it will be invalid
	JB readinvalid2
Num:
	CMP AL, 34h    ;If the key is 1,2,or 3 it will go to the submenu
	JB SubMenu
	CMP AL, 33h     ;If it is 34 or above it will be invalid
	JA readinvalid2
SubMenu:
	CMP AL, '1'
	JE READB2
	CMP AL, '2'
	JE READA2
	CMP AL, '3'
	JE READEXIT
READA2:
	@disp MSGA1               ;Print MSGA1
	JMP OptionStart
READB2:
	@disp ENAME
	@disp NL
	@read_str BUFF
	Call parse			;Splits Name and Score
	CMP IsInv,0
	JE AddToList			;If Valid then add item
	JMP OptionStart
READINVALID2:               ;Print Invalid
	@disp Invalid
	JMP OptionStart
READEXIT:                    ;returns to mainmenu
	RET
AddToList:
	Call AddItem
	JMP OptionStart
OptionsMenu		ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Initialize proc near
Mov SI, OFFSET LIST				;Just Initializes the linked list
Mov DI,SI
ADD DI,2
MOV LAST,DI
RET
Initialize endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
AddItem proc near
ADD CountHolder2,1		;Number of items in the list
MOV SI,OFFSET Nlist 	;point SI to string
XOR CX,CX 				;clear count register
MOV CX,CountHolder 		;move legth of string into count register
MOV DI, LAST			;point DI to the end of the list
RPT: 
MOV DL,[SI] 			;copy character to dl
MOV [DI],DL 			;copy character to linked-list
INC SI 				;point to next character
INC DI 				;point to next empty byte
LOOP RPT 			;repeat until cx=0
MOV BX,LAST			
SUB BX,2	
MOV AX,12			
SUB AX,CountHolder			
ADD DI,AX				;Point DI to where the score needs to be
MOV AL, NumHex
MOV [DI], AL
INC DI
MOV AL, NumHex+1
MOV [DI], AL
INC DI
MOV AL, NumHex+2			;Add The 3 Bytes of the Score
MOV [DI], AL
INC DI
MOV DX,[BX]					
MOV [DI],DX				
MOV [BX],DI				;Mov the Pointer at Bx to the end
ADD DI,2				
MOV LAST,DI
Call SortList				;Puts the new item in the correct place
MOV DL,0
MOV NoFile,DL
RET
AddItem endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SortList proc near
XOR CX,CX
XOR BX,BX
XOR DX,DX
XOR AX,AX
MOV AX,CountHolder2
SUB AX,1
MOV CX,AX				;CL holds the number of times the new item needs to be compared
CMP AX,0
JE NoComp
MOV BL,FirstTime			;This value will go to one when the 2nd item enters the list
CMP BL,0
JE FirstC
JNE SecondC					;This is where all items after the 2nd one will go
FirstC:
Call FirstCompare
MOV AX,CountHolder2
ADD AX,1
MOV CountHolder2,AX
RET
SecondC:
Call OtherCompare
MOV AX,CountHolder2
ADD AX,1
MOV CountHolder2,AX
RET
NoComp:
RET
SortList endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FirstCompare proc near
MOV AX,CountHolder2			;The first compare for items 1 and 2
SUB AX,1
MOV CountHolder2,AX
First:
	Mov SI,FirstItem
	Mov AX,[SI]
	Mov NextItem,AX
	MOV BX,NextItem
	MOV AX,[BX]
	MOV BX,AX
	XOR AX,AX
	Mov AL,17
	MUL CountHolder2
	MOV DI,AX
	ADD FirstTime,1
	JMP CompareUpByte
CompareUpByte:
	ADD SI,16
	MOV AL,[SI]
	ADD DI,16
	MOV DL,[DI]
	SUB SI,16
	SUB DI,16
	CMP AL,DL
	JE CompareMidByte
	JB ChangePtr1st
	JA Outx
CompareMidByte:
	ADD SI,15
	MOV AL,[SI]
	ADD DI,15
	MOV DL,[DI]
	SUB SI,15
	SUB DI,15
	CMP AL,DL
	JE CompareLowByte
	JB ChangePtr1st
	JA Outx
CompareLowByte:
	ADD SI,14
	MOV AL,[SI]
	ADD DI,14
	MOV DL,[DI]
	SUB SI,14
	SUB DI,14
	CMP AL,DL
	JE Outx
	JB ChangePtr1st
	JA Outx
ChangePtr1st:
	Mov AX,[BX]
	Mov DX,[DI]
	MOV BP,[SI]
	Mov [DI],AX
	Mov [SI],DX
	Mov [BX],BP
	MOV AX,DI
	MOV FirstItem,AX
Outx:
RET
FirstCompare endp
OtherCompare proc near				;This is where all items after the 2nd will go to be sorted
MOV AX,CountHolder2				
SUB AX,1
MOV CountHolder2,AX
INC CX
Second:
	DEC CX
	CMP CX,0
	JE Outxx
	Mov SI,FirstItem				;Point SI to an item to be compared with the new item.
	Mov AX,[SI]
	Mov NextItem,AX
	MOV BL,CL
	Call GetLast					;This Proc will always get the pointer of last item in the list
	MOV CL,BL
	Mov SI,FirstItem
	XOR AX,AX
	Mov AL,17
	MUL CountHolder2
	MOV DI,AX
	JMP CompareUpByte2
Outxx:
RET
NextItemx:
	DEC CX
	CMP CX,0
	JE Outxx
	MOV AX,NextItem
	MOV PTR1,SI
	MOV SI,NextItem
	Mov AX,[SI]
	Mov NextItem,AX
	JMP CompareUpByte2
CheckChangePtr:       ;Check to see if the first item needs to be changed or not
	CMP CX,CountHolder2
	JE ChangePtr2nd
	JNE ChangePtr3
CompareUpByte2:				;Compares higher byte first then next then lowest.
	ADD SI,16
	MOV AL,[SI]
	ADD DI,16
	MOV DL,[DI]
	SUB SI,16
	SUB DI,16
	CMP AL,DL
	JE CompareMidByte2
	JB CheckChangePtr
	JA NextItemx
CompareMidByte2:
	ADD SI,15
	MOV AL,[SI]
	ADD DI,15
	MOV DL,[DI]
	SUB SI,15
	SUB DI,15
	CMP AL,DL
	JE CompareLowByte2
	JB CheckChangePtr
	JA NextItemx
CompareLowByte2:
	ADD SI,14
	MOV AL,[SI]
	ADD DI,14
	MOV DL,[DI]
	SUB SI,14
	SUB DI,14
	CMP AL,DL
	JE NextItemx
	JB CheckChangePtr
	JA NextItemx
ChangePtr2nd:    			;Changes the pointer for the new item to be the first.
	MOV SI,FirstItem
	MOV DX,[DI]
	MOV [DI],SI
	MOV AX,DI
	MOV FirstItem,AX
	MOV SI,LastItem
	MOV [SI],DX
	JMP Outxx
ChangePtr3:					;Changes the pointer for the new item to be in the list.
	MOV SI,PTR1
	Mov BX,LastItem
	Mov AX,[BX]
	Mov DX,[DI]
	MOV BP,[SI]
	Mov [DI],BP
	Mov [SI],AX
	Mov [BX],DX
	JMP Outxx
OtherCompare endp
GetLast Proc near
	DEC CL
GetLastItem:					;Gets the last item in the linked list
	MOV AX,[SI]
	Mov LastItem,AX
	MOV SI,AX
	LOOP GetLastItem
RET
GetLast Endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Parse proc near					;Scans the name and score entered to sperate them
    MOV DI,OFFSET BUFF+1
	MOV IsInv,0
	MOV CL,[DI]
	MOV AL,':'
	MOV BX,CX
	REPNE SCASB
	JNE ReadInvalid5		;If does not contain a : will be Invalid.
	INC CX
	SUB BX,CX
	CMP BX,12
	JA ReadInvalid5				;If the name is to long it will be Invalid.
	MOV CountL,CX
	PUSH CX
	PUSH BX
	ADD BX,2
	LEA SI,BUFF[BX]
	LEA DI,slist			
CS_String:				;Add the score to a varible
	MOV AL,[SI]	
	MOV [DI],AL
	INC SI
	INC DI
	DEC CX
	CMP CX,0h
	JNE CS_String
	POP BX
	MOV CountHolder,BX
	MOV CX,BX
	LEA SI,BUFF+2
	LEA DI,nlist
CN_String:				;Add the name to a varible
	MOV AL,[SI]
	MOV [DI],AL
	INC SI
	INC DI
	DEC CX
	CMP CX,0h
	JNE CN_String
	POP CX
	Call SetUp2Hex			;The start of converting the score to Hex
	RET
ReadInvalid5:
	@disp Invalid
	ADD IsInv,1
	RET
parse endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DisplayList proc near
	Xor CX,CX
	XOR BX,BX
	XOR BP,BP
	MOV BP,31h
	MOV BX,CountHolder2
	MOV CX,3
	MOV SI,FirstItem
	MOV DI,0
	CMP BX,0
	JE Empty2
	@disp Stars
	@disp Hscores
	JMP Header
Empty2:
	@disp Empty
	RET
Header2:			;Prints 10. for the last item
	MOV DX,31h
	@dispChar1
	MOV DX,30h
	@dispChar1
	MOV DX,'.'
	@dispChar1
	MOV DX,' '
	@dispChar1
	JMP Backx
Header:
	@disp NL			;Prints 1,2,3,4...
	CMP BP,3Ah
	JE Header2
	MOV DX,' '
	@dispChar1
	MOV DX,BP
	@dispChar1
	MOV DX,'.'
	@dispChar1
	MOV DX,' '
	@dispChar1
backx:
	MOV CX,12		;Moves 12 into cx since the name is 11 bytes long + :
	INC BP
	INC DI
	MOV AX,[SI]		
	MOV NextItem,AX			;Moves next item in linked list into nextitem
	ADD SI,2
backx2:
	MOV AL,[SI]			;Print the name out
	MOV DL,AL
	@dispchar1
	INC SI
	LOOP backx2
	PUSH DI
	PUSH BX
	Call Hex2Asc		;Will convert Hex number to Asc
	LEA SI,NumAsc
	MOV CX,9
	MOV AL,'0'
Compare0:
	DEC CX			;scans for a number not 0 then moves si to there to print just the number
	INC SI
	CMP [SI],AL
	JE Compare0
	JNE backx3
	
backx3:
	MOV AL,[SI]			;Will print the score out
	MOV DL,AL
	@dispchar1
	INC SI
	LOOP backx3
	MOV SI,NextItem			;Now repeat with the next item
	POP BX
	POP DI
	DEC BX
	CMP DI,10			;Only print the the top 10
	JE Outw
	CMP BX,0
	JE Outw
	JNE Header
Outw:
@disp Stars
RET
DisplayList endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SetUp2HEX PROC near               ;Points Bx to the Asc Score and DI to store the Hex Number
	MOV BH,0 			
	LEA BX,slist 	
	LEA DI,NumHex	
	MOV CH,0		
	CALL Char2Hex			
RET
SetUp2HEX ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Char2Hex Proc near
	PUSH AX		
	XOR AX,AX
	MOV SI, 0	
	MOV NumHex,0
	MOV NumHex+1,0
	MOV NumHex+2,0
	MOV NumHex+3,0
	MOV IsInv,0
AscLoop:	
	MOV AL,[BX+SI]		;First number into AL
	CMP AL,30H		
	JB ReadInvalid4		
	CMP AL,39H					;If not a Number it will be Invalid
	JA ReadInvalid4		
	SUB AL,30H		;Convert from ASCII to a Num
	CALL Addition		
	DEC CX
	CMP CL,0		
	JBE AscDone
	CALL Multiply		;Multiply the number by 10
	XOR AX,AX		
	INC SI			
	JMP AscLoop		;Repeat the loop for all digits

AscDone:
	MOV AL,0
	MOV AL,NumHex+3			;Checks to see if score is over 16777215
	CMP AL,0
	JNE ReadInvalid3
AscDoneWe:
	POP AX
	RET
ReadInvalid3:
	@disp Invalid
	ADD IsInv,1
	JMP AscDoneWe
ReadInvalid4:
	@disp Invalid
	ADD IsInv,1
	JMP AscDone
Char2Hex endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hex2Asc proc near			;Hex Number to Asc
	XOR CX,CX
	MOV AL,[SI]
	MOV NumHex,AL
	INC SI
	MOV AL,[SI]
	MOV NumHex+1,AL
	INC SI
	MOV AL,[SI]
	MOV NumHex+2,AL				;Move the 3 bytes of score into NumHex
	LEA BX,NumHex
	MOV SI,8
	LEA DI,NumAsc+8		;Point DI to the last byte of its space
	
HexLoop:
	CALL Divide		;Calls divide procedure to divide number by 10
	MOV AL,[BX]		;BX holds remainder. Store BX in AL	
	ADD AL,30H		;Add 30H to convert digit to ASCII	
	MOV [DI],AL		;Store ASCII value into NumAsc
	CMP SI,0			
	JBE HexDone		
	DEC SI			
	DEC DI			;Move DI to next byte of NumAsc	
	MOV AL,Count	;Count holds quotient, move quotient to BX	
	MOV [BX],AL				
	MOV AL,Count+1		
	MOV [BX+1],AL				
	MOV AL,Count+2			
	MOV [BX+2],AL					
	JMP Hexloop	;Repeat loop until complete

HexDone:
RET
Hex2Asc endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Addition proc near	;3 byte addition procedur
	ADD AL,[DI]		;Add carries
	MOV [DI],AL		
	MOV AL,[DI+1]	
	ADC AL,0			
	MOV [DI+1],AL	
	MOV AL,[DI+2]	
	ADC AL,0			
	MOV [DI+2],AL
	MOV AL,[DI+3]
	ADC AL,0
	MOV [DI+3],AL
	
RET
Addition endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Multiply proc near
	PUSH CX		
	XOR AX, AX	
	MOV AL,[DI]
	MOV Holder,AL
	MOV AL,[DI+1]
	MOV Holder+1,AL
	MOV AL,[DI+2]
	MOV Holder+2,AL
	MOV AL,[DI+3]
	MOV Holder+3,AL
	MOV CX,9	;Set the loop counter at 9

Multiplier:		;Begin multiplier loop

	MOV AL,[DI]
	ADD AL,Holder		;Add byte 1 of Holder with byte 1 of DI
	MOV Holder,AL
	MOV AL,[DI+1]
	ADC AL,Holder+1		;Add Holder byte 2 and DI byte 2 plus carry
	MOV Holder+1,AL
	MOV AL,[DI+2]
	ADC AL,Holder+2		;Add Holder byte 3 and DI byte 3 plus carry
	MOV Holder+2,AL
	MOV AL,[DI+3]
	ADC AL,Holder+3
	MOV [Holder+3],AL
	LOOP Multiplier		;End multiplier loop

	MOV AL,Holder		;Puts the Holder of the multiplier back in DI
	MOV [DI],AL
	MOV AL,Holder+1
	MOV [DI+1],AL
	MOV AL,Holder+2
	MOV [DI+2],AL
	MOV AL,Holder+3
	MOV [DI+3],AL
	POP CX			;Set CX back 
RET
Multiply endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Divide proc near	;Divide number BX points to by 10
					
	MOV AL,0		
	MOV Holder,AL
	MOV Holder+1,AL
	MOV Holder+2,AL
	MOV Count,AL
	MOV Count+1,AL
	MOV Count+2,AL

Divider:
	CMP Byte Ptr[BX+2],0H 
	JA Counter
	CMP Byte Ptr[BX+1],0H
	JA Counter
	CMP Byte Ptr[BX],0AH
	JB Finished

Counter:
	MOV AL,Count
	ADD AL,01
	MOV Count,AL
	MOV AL,Count+1
	ADC AL,0
	MOV Count+1,AL
	MOV AL,Count+2
	ADC AL,0
	MOV Count+2,AL
	MOV AL,[BX]			;Remove 10 from lowest byte
	SUB AL,0AH
	MOV Holder,AL
	MOV AL,[BX+1]
	SBB AL,0		;Subract and also subtract one more if carry
	MOV Holder+1,AL
	MOV AL,[BX+2]
	SBB AL,0
	MOV Holder+2,AL
	MOV AL,Holder		;Put the new value into BX
	MOV [BX],AL
	MOV AL,Holder+1	
	MOV [BX+1],AL
	MOV AL,Holder+2	
	MOV [BX+2],AL
	JMP Divider					
	
Finished:				;Completes the loop
RET
Divide ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CODE_SEG ENDS
END MAIN					;end