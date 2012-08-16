;****************************************************************************
;*
;*							Precision Zen Timer
;*
;*							   From the book
;*						 "Zen of Assembly Language"
;*							Volume 1, Knowledge
;*
;*							 by Michael Abrash
;*
;*					  Modifications by Kendall Bennett
;*
;* Filename:	$RCSfile: pztest.asm $
;* Version:		$Revision: 1.2 $
;*
;* Language:	8086 Assembler
;* Environment:	IBM PC (MS DOS)
;*
;* Description:	Standalone .exe program to measure the performance of code
;*				that takes less than 54 ms to execute.
;*
;*				Link with PZTIMER.ASM. PZTEST.BAT can be used to assemble,
;*				link and run the test. Code to be measured must be in the
;*				file TESTCODE. See MOVTST.ASM for example test code.
;*
;* $Id: pztest.asm 1.2 92/01/27 21:38:56 kjb release $
;*
;* Revision History:
;* -----------------
;*
;* $Log:	pztest.asm $
;* Revision 1.2  92/01/27  21:38:56  kjb
;* First release to the public.
;* 
;* Revision 1.1  91/11/14  17:17:14  kjb
;* Initial revision
;* 
;****************************************************************************

		IDEAL

INCLUDE "model.mac"				; Memory model macros

segment	mystack para stack 'STACK'
		db		512 dup(?)
ends	mystack

header		pztest				; Set up memory model

begcodeseg	pztest				; Start of code segment

		assume ds:_TEXT			; Access data in the code segment

		extrn _PZTimerOn:far, _PZTimerOff:far, _PZTimerReport:far

; Set up a few equates to map calls to ZTimerOn, ZTimerOff and ZTimerReport
; to the 'C' callable precision timing routines.

ZTimerOn		EQU	_PZTimerOn
ZTimerOff		EQU	_PZTimerOff
ZTimerReport	EQU	_PZTimerReport

proc	Start	near

		push	cs
		pop		ds				; Set ds to point to the code segment,
								; so data as well as code can easily
								; be included in TESTCODE

INCLUDE	"testcode"

; Display the results

		call    _PZTimerReport

; Terminate the program

		mov		ah,4ch
		int		21h

endp	Start

endcodeseg	pztest

		END		Start			; End of module
