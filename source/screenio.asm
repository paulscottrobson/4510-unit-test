; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		screenio.asm
;		Purpose :	Screen I/O functions, that use the personality code.
;		Date :		25th July 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;						Initialise, Clear Home, and Home routines
;
; *******************************************************************************************

SIOInitialise:
		jsr 	EXTReset 					; reset video
SIOClearScreen:		
		jsr 	EXTClearScreen 				; clear screen
SIOHomeCursor:
		pha 								; home cursor
		lda 	#0
		sta 	xCursor
		sta 	yCursor
		pla
		rts

; *******************************************************************************************
;
;								 Print ASCIIZ string at XY
;
; *******************************************************************************************

SIOPrintString:
		pha 								; save registers
		phx
		phy
		stx 	zTemp2 						; set up indirect pointer
		sty 	zTemp2+1
		ldy 	#0 
_SIOPSLoop:
		lda 	(zTemp2),y 					; read next, exit if 0
		beq 	_SIOPSExit
		jsr 	SIOPrintCharacter 			; print and bump
		iny
		bne 	_SIOPSLoop
_SIOPSExit:
		ply 								; restore and exit.
		plx
		pla
		rts


; *******************************************************************************************
;
;						  Print a single character out (characters and CR)
;
; *******************************************************************************************

SIOPrintCharacter:
		pha 								; save AXY
		phx
		phy
		cmp 	#13 						; CR ?
		beq 	_SIOPReturn
		cmp 	#9
		beq 	_SIOPTab
		jsr 	SIOLoadCursor 				; load cursor position in.
		and 	#$3F 						; PETSCII conversion
		jsr 	EXTWriteScreen 				; write character out.
		inc 	xCursor 					; move right
		lda 	xCursor 					; reached the RHS
		cmp 	#EXTWidth
		bcc 	_SIOPExit
_SIOPReturn:
		lda 	#0 							; zero x
		sta 	xCursor
		inc 	yCursor 					; go down
		lda 	yCursor
		cmp 	#EXTHeight 					; off the bottom ?
		bcc 	_SIOPExit
		jsr 	EXTScrollDisplay 			; scroll display up
		dec 	yCursor 					; cursor on bottom line.
_SIOPExit:		
		ply 								; restore and exit.
		plx
		pla
		rts

_SIOPTab:
		lda 	#32 						; tab.
		jsr 	SIOPrintCharacter
		lda 	xCursor
		and 	#7
		bne 	_SIOPTab
		bra 	_SIOPExit		

; *******************************************************************************************
;
;										Get a single key
;
; *******************************************************************************************

SIOGetKey:
		jsr 	EXTReadKeyPort 				; wait for a key
		beq 	SIOGetKey
		jmp 	EXTRemoveKeyPressed 		; remove from the queue.


; *******************************************************************************************
;
;								Load Cursor position into XY
;
; *******************************************************************************************

SIOLoadCursor:
		pha 			
		lda 	yCursor  					; Y Position
		asl 	a 							; x 2 	(80)
		asl 	a 							; x 2 	(160)
		adc 	yCursor 					; x 5 	(200) (CC)
		sta 	zTemp1 						
		lda 	#0
		sta 	zTemp1+1
		asl 	zTemp1						; x 10
		rol 	zTemp1+1
		asl 	zTemp1						; x 20
		rol 	zTemp1+1
		asl 	zTemp1						; x 40
		rol 	zTemp1+1 					; 
		asl 	zTemp1						; x 80
		rol 	zTemp1+1 					; (CC)
		lda 	zTemp1 						; add X
		adc 	xCursor
		tax
		lda 	zTemp1+1
		adc 	#0
		tay
		pla 								; restore and exit
		rts

; *******************************************************************************************
;
;								Print A as hex digit.
;
; *******************************************************************************************

SIOPrintHex:
		pha
		pha
		lda 	#32
		jsr 	SIOPrintCharacter
		pla
		pha
		lsr 	a
		lsr 	a
		lsr 	a
		lsr 	a
		jsr 	_SIOPHex
		pla
		jsr 	_SIOPHex
		pla
		rts

_SIOPHex:
		and 	#15
		cmp 	#10
		bcc 	_SIOPHex2
		adc 	#6
_SIOPHex2:
		adc 	#48
		jmp 	SIOPrintCharacter				