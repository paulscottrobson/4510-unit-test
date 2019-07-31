; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		unittest.asm
;		Purpose :	Basic Interpreter (Main)
;		Date :		31st July 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

zTemp1 	= $20
zTemp2 	= $24
xCursor = $26
yCursor = $27	

ac = $30
xc = $31
yc = $32
zc = $33
pcl = $34
pch = $35
sr = $36

		.include 	"porting.asm"			; implementation specific stuff
		.include 	"screenio.asm"			; I/O functions.

		* = $E000
				
Start:
		#EXTResetStack 						; reset CPU stack.
		jsr 	SIOInitialise 				; initialise the I/O system.		
		ldx 	#BootMsg1 & 255 			; boot text.
		ldy 	#BootMsg1 >> 8
		jsr 	SIOPrintString

		ldx 	#$80
_Copy:		
		lda 	$B000,x
		sta 	$8000,x
		sta 	$80,x
		dex
		bpl 	_Copy

		neg
		neg
		inc 	$8000

		neg
		neg
		lda 	$BFF4

		
		jsr 	CheckStatus
		.byte 	$CC,$DD,$EE,$FF,$FF

		ldx 	#BootMsg2 & 255 			; boot text.
		ldy 	#BootMsg2 >> 8
		jsr 	SIOPrintString
Wait:
		jmp		Wait

BootMsg1:
		.text 	"*** 4510 UNIT TEST ***",13,13,0
BootMsg2:
		.text 	"COMPLETE.",13,13,0

; *******************************************************************************************
;
;										Save and Check CPU Status
;
; *******************************************************************************************

CheckStatus:
		sta 	ac
		stx 	xc
		sty 	yc
		.if TARGET=1
		stz 	zc
		.endif
		php 	
		pla
		and 	#$C3 				; only interested in NV....ZC
		sta 	sr
		plx
		ply
		stx 	pcl
		sty 	pch

		ldy 	#1
_CheckReg:		
		lda 	ac-1,y
		cmp 	(pcl),y
		bne 	ShowStatus
		iny
		cpy 	#5
		bne 	_CheckReg
		lda 	(pcl),y
		cmp 	#$FF 				; $FF = ignore status.
		beq 	_ExitCS
		eor 	sr
		and 	#$C3
		bne 	_CheckReg
		;
_ExitCS:
		lda 	pch
		jsr 	SIOPrintHex
		lda 	pcl
		jsr 	SIOPrintHex
		lda 	#13
		jsr 	SIOPrintCharacter
		lda 	pcl
		clc
		adc 	#5
		tax
		lda 	pch
		adc 	#0
		pha
		phx

		lda 	#0
		tax
		tay
		.if TARGET=1
		taz
		.endif
		clc
		clv
		rts

; *******************************************************************************************
;
;									Display CPU Status
;
; *******************************************************************************************

ShowStatus:
		ldx 	#RegMsg & 255
		ldy 	#RegMsg >> 8
		jsr 	SIOPrintString
		ldx 	#0
_SSLoop:lda 	ac,x
		jsr 	SIOPrintHex
		inx
		cpx 	#7
		bne 	_SSLoop
		lda 	#32
		jsr 	SIOPrintCharacter
		ldx 	#8
_SSStatus:		
		lda 	#'.'
		asl 	sr
		bcc 	_SSClear
		lda 	#'*'
_SSClear:		
		jsr 	SIOPrintCharacter
		dex
		bne 	_SSStatus
		lda 	#13
		jsr 	SIOPrintCharacter
_SSHalt:bra 	_SSHalt		

RegMsg:	.text 	" A  X  Y  Z  PC    S  NV----ZC",13,0