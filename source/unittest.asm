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

zTemp1 	= $20 								; used in the I/O stuff nicked from AtomicBasic
zTemp2 	= $24
xCursor = $26
yCursor = $27	

ac = $30 									; Registers stored here.
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

		ldx 	#$80 						; copy ROM at $B000 which should be
_Copy:		 								; stable from build to build (!)
		lda 	$B000,x 					; to $80 and $8000
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

		
		jsr 	CheckStatus 				; check status
		.byte 	$CC,$DD,$EE,$FF,$FF 		; what we should see. A X Y Z S (S = $FF = ignore)

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
		sta 	ac 							; save AXYZ
		stx 	xc
		sty 	yc
		.if TARGET=1
		stz 	zc
		.endif
		php 	 							; save PSW
		pla
		and 	#$C3 						; only interested in NV....ZC
		sta 	sr
		plx 								; save return - 1
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
		cmp 	#$FF 						; $FF = ignore status.
		beq 	_ExitCS
		eor 	sr 							; zero bits are the same
		and 	#$C3 						; only into NV....ZC
		bne 	_CheckReg
		;
_ExitCS:
		lda 	pch 						; okay, so print out PCHL
		jsr 	SIOPrintHex
		lda 	pcl
		jsr 	SIOPrintHex
		lda 	#13
		jsr 	SIOPrintCharacter
		lda 	pcl 						; skip over the comparing values
		clc
		adc 	#5
		tax
		lda 	pch
		adc 	#0
		pha
		phx

		lda 	#0 							; zero everything, clear overflow and carry
		tax 								; for next go.
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
		ldx 	#RegMsg & 255 				; print the line
		ldy 	#RegMsg >> 8
		jsr 	SIOPrintString
		ldx 	#0 							; print regs
_SSLoop:lda 	ac,x
		jsr 	SIOPrintHex
		inx
		cpx 	#7
		bne 	_SSLoop
		lda 	#32
		jsr 	SIOPrintCharacter
		ldx 	#8 							; print PSW
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

