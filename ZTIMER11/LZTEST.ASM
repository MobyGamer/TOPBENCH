;****************************************************************************
;*
;*						   Long Period Zen Timer
;*
;*							   From the book
;*						 "Zen of Assembly Language"
;*							Volume 1, Knowledge
;*
;*							 by Michael Abrash
;*
;*					  Modifications by Kendall Bennett
;*
;* Filename:	$RCSfile: lztest.asm $
;* Version:		$Revision: 1.2 $
;*
;* Language:	8086 Assembler
;* Environment:	IBM PC (MS DOS)
;*
;* Description:	Standalone .exe program to measure the performance of code
;*				that takes more than 54 ms to execute.
;*
;*				Link with LZTIMER.ASM. LZTEST.BAT can be used to assemble,
;*				link and run the test. Code to be measured must be in the
;*				file TESTCODE. See DLYTST.ASM for example test code.
;*
;* $Id: lztest.asm 1.2 92/01/27 21:38:23 kjb release $
;*
;* Revision History:
;* -----------------
;*
;* $Log:	lztest.asm $
;* Revision 1.2  92/01/27  21:38:23  kjb
;* First release to the public.
;* 
;* Revision 1.1  91/11/14  17:16:07  kjb
;* Initial revision
;* 
;****************************************************************************

		IDEAL

INCLUDE "model.mac"				; Memory model macros

segment	mystack para stack 'STACK'
		db		512 dup(?)
ends	mystack

header		lztest				; Set up memory model

begcodeseg	lztest				; Start of code segment

		assume ds:_TEXT			; Access data in the code segment

		extrn _LZTimerOn:far, _LZTimerOff:far, _LZTimerReport:far

; Set up a few equates to map calls to ZTimerOn, ZTimerOff and ZTimerReport
; to the 'C' callable long period timing routines.

ZTimerOn		EQU	_LZTimerOn
ZTimerOff		EQU	_LZTimerOff
ZTimerReport	EQU	_LZTimerReport

proc	Start	near

		push	cs
		pop		ds				; Set ds to point to the code segment,
								; so data as well as code can easily
								; be included in TESTCODE

; Delay for 1-2 seconds, to let the Enter keystroke that started the
; program to come back up (the upstroke).

		mov		ah,2ch
		int		21h				; Get current time
		mov		bh,dh			; set the current time aside
@@DelayLoop:
		mov		ah,2ch
		push	bx				; preserve start time
		int		21h				; get time
		pop		bx				; retrieve start time
		cmp		dh,bh			; Is the new seconds count less than the
								;  start seconds count?
		jnb		@@CheckDelayTime ; no
		add		ah,60			; yes, a minute must have turned over, so
								;  add one minute.
@@CheckDelayTime:
		sub		dh,bh			; Get time that's passed
		cmp		dh,2			; has it been more than 2 seconds yet?
		jb		@@DelayLoop		; not yet

INCLUDE	"testcode"

; Display the results

		call    _LZTimerReport

; Terminate the program

		mov		ah,4ch
		int		21h

endp	Start

endcodeseg	lztest

		END		Start			; End of module
