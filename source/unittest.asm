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

zTemp1 	= $10
zTemp2 	= $14
xCursor = $16
yCursor = $17	

		.include 	"porting.asm"			; implementation specific stuff

		* = $E000
		.include 	"screenio.asm"			; I/O functions.
				
Start:
		#EXTResetStack 						; reset CPU stack.
		jsr 	SIOInitialise 				; initialise the I/O system.
		ldx 	#BootMsg1 & 255 			; boot text.
		ldy 	#BootMsg1 >> 8
		jsr 	SIOPrintString

Wait:
		jmp		Wait

BootMsg1:
		.text 	"*** 4510 UNIT TEST ***",13,13,0



