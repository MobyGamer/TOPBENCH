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
;* Filename:	$RCSfile: pztimer.asm $
;* Version:		$Revision: 1.4 $
;*
;* Language:	8086 Assembler
;* Environment:	IBM PC (MS DOS)
;*
;* Description:	Uses the 8253 timer to time the performance of code that
;*				takes less than about 54 milliseconds to execute, with a
;*				resolution of better than 10 microseconds.
;*
;*	Externally 'C' callable routines:
;*
;*	PZTimerOn:		Starts the Zen timer, with interrupts disabled.
;*
;*	PZTimerOff:		Stops the Zen timer, saves the timer count, times the
;*					overhead code, and restores interrupts to the state they
;*					were in when ZTimerOn was called.
;*
;*	PZTimerReport:	Prints the net time that passed between starting and
;*					stopping the timer.
;*
;*	PZTimerCount:	Returns an unsigned long integer representing the timed
;*					count in microseconds. If the timer overflowed,
;*					PZTimerCount() returns the value 0xFFFFFFFF (which is
;*					not a valid timer count).
;*
;*	Note:	If longer than about 54 ms passes between ZTimerOn and ZTimerOff
;*			calls, the timer turns over and the count is inaccurate. When
;*			this happens, an error message is displayed instead of a count.
;*			The long period Zen timer should be used in such cases.
;*
;*	Note:	Interrupts "MUST" be left off between calls to ZTimerOn and
;*			ZTimerOff for accurate timing and for detection of timer
;*			overflow.
;*
;*	Note:	These routines can introduce slight inaccuracies into the
;*			system clock count for each code section timed even if
;*			timer 0 doesn't overflow. If timer 0 does overflow, the
;*			system clock can become slow by virtually any amount of
;*			time, since the system clock can't advance while the
;*			precision timer is timing. Consequently, it's a good idea
;*			to reboot at the end of each timing session. (The
;*			battery-backed clock, if any, is not affected by the Zen
;*			timer.)
;*
;*  All registers and all flags except the interrupt flag, are preserved
;*	by all routines. Interrupts are enabled and then disabled by ZTimerOn,
;*	and are restored by ZTimerOff to the state they were in when ZTimerOn
;*	was called.
;*
;* $Id: pztimer.asm 1.4 92/01/27 21:39:30 kjb release $
;*
;* Revision History:
;* -----------------
;*
;* $Log:	pztimer.asm $
;* Revision 1.4  92/01/27  21:39:30  kjb
;* Converted to a memory model independant library, and released to the
;* public.,
;* 
;* Revision 1.3  91/12/31  19:34:30  kjb
;* Changed include file directories.
;* 
;* Revision 1.2  91/11/16  17:11:15  kjb
;* Modified to return a long integer count rather than a string.
;* 
;* Revision 1.1  91/11/14  17:17:29  kjb
;* Initial revision
;* 
;****************************************************************************

		IDEAL

INCLUDE "model.mac"				; Memory model macros

header	pztimer					; Set up memory model

;****************************************************************************
;
; Equates used by precision Zen Timer
;
;****************************************************************************

; Base address of 8253 timer chip

BASE_8253		=		40h

; The address of the timer 0 count registers in the 8253

TIMER_0_8253	=		BASE_8253 + 0

; The address of the mode register in the 8253

MODE_8253		=		BASE_8253 + 3

; The address of Operation Command Word 3 in the 8259 programmable
; interrupt controller (PIC) (write only, and writable only when
; bit 4 of the byte written to this address is 0 and bit 3 is 1).

OCW3			=		20h

; The address of the Interrupt Request register in the 8259 PIC
; (read only, and readable only when bit 1 of OCW3 = 1 and bit 0 of
; OCW3 = 0).

IRR				=		20h

; Macro to emulate a POPF instruction in order to fix the bug in some
; 80286 chips which allows interrupts to occur during a POPF even when
; interrupts are disabled.

macro	MPOPF
		local	p1,p2
		jmp		short p2
p1:		iret					; Jump to pushed address & pop flags
p2:		push	cs				; construct far return address to
		call	p1				;  the next instructionz
endm

; Macro to delay briefly to ensure that enough time has elapsed between
; successive I/O accesses so that the device being accessed can respond
; to both accesses even on a very fast PC.

macro	DELAY
		jmp		$+2
		jmp		$+2
		jmp		$+2
endm

begcodeseg  pztimer             ; Start of code segment

OriginalFlags	db	?			; Storage for upper byte of FLAGS register
								;  when ZTimerOn was called
TimedCount		dw	?			; Timer 0 count when the time was stopped

ReferenceCount	dw	?			; Number of counts required to execute timer
								;  overhead code
OverflowFlag	db	?			; Used to indicate whether the timer
								;  overflowed during the timing interval

; String printed to report results.

label	OutputStr byte
		db		0dh, 0ah, 'Timed count: ', 5 dup (?)
label	ASCIICountEnd byte
		db		' microseconds', 0ah, 0dh
		db		'$'

; String printed to report timer overflow.

label	OverflowStr byte
		db		0dh,0ah
		db		'***************************************************',0dh,0ah
		db		'* The timer overflowed, so the interval timed was *',0dh,0ah
		db		'* too long for the precision timer to measure.    *',0dh,0ah
		db		'* Please perform the timing test again with the   *',0dh,0ah
		db		'* long-period timer.                              *',0dh,0ah
		db		'***************************************************',0dh,0ah
		db		'$'

;----------------------------------------------------------------------------
; void PZTimerOn(void);
;----------------------------------------------------------------------------
; Starts the Precision Zen timer counting.
;----------------------------------------------------------------------------
procfar		_PZTimerOn

; Save the context of the program being timed

		push	ax
		pushf
		pop		ax					; Get flags so we can keep interrupts
									;  off when leaving this routine
		mov		[OriginalFlags],ah	; remember the state of the int flag
		and		ah,0fdh				; Set pushed interrupt flag to 0
		push	ax

; Turn on interrupts, so the timer interrupt can occur if it's pending.

		sti

; Set the timer 0 of the 8253 to mode 2 (divide-by-N), to cause
; linear counting rather than count-by-two counting. Also leaves
; the 8253 waiting for the initial timer 0 count to be loaded.

		mov		al,00110100b		; mode 2
		out		MODE_8253,al

; Set the timer count to 0, so we know we won't get another timer
; interrupt right away. Note: this introduces and inaccuracy of up to 54 ms
; in the system clock count each time it is executed.

		DELAY
		sub		al,al
		out		TIMER_0_8253,al		; lsb
		DELAY
		out		TIMER_0_8253,al		; msb

; Wait before clearing interrupts to allow the interrupt generated when
; switching from mode 3 to mode 2 to be recognised. The delay must be at
; least 210ns long to allow time for that interrupt to occur. Here, 10
; jumps are used for the delay to ensure that the delay time will be more
; than enough even on a very fast PC.

		rept	10
		jmp		$+2
		endm

; Disable interrupts to get an accurate count.

		cli

; Set the timer count to 0 again to start the timing interval.

		mov		al,00110100b		; set up to load initial
		out		MODE_8253,al		; timer count
		DELAY
		sub		al,al
		out		TIMER_0_8253,al		; load count lsb
		DELAY
		out		TIMER_0_8253,al		; load count msb

; Restore the context and return.

		MPOPF						; keeps interrupts off
		pop		ax
		ret

procend		_PZTimerOn

;----------------------------------------------------------------------------
; void PZTimerOff(void);
;----------------------------------------------------------------------------
; Stops the Precision Zen timer and save count.
;----------------------------------------------------------------------------
procfar		_PZTimerOff

; Save the context of the program being timed

		push	ax
		push	cx
		pushf

; Latch the count.

		mov		al,00000000b		; latch timer 0
		out		MODE_8253,al

; See if the timer has overflowed by checking the 8259 for a pending
; timer interrupt.

		mov		al,00001010b		; OCW3, set up to read
		out		OCW3,al				;  Interrupt request register
		DELAY
		in		al,IRR				; read Interrupt Request Register
		and		al,1				; set AL to 1 if IRQ0 (the timer
									;  interrupt) is pending
		mov		[OverflowFlag],al	; Store the timer overflow status

; Allow interrupts to happen again.

		sti

; Read out the count we latched earlier.

		in		al,TIMER_0_8253		; least significant byte
		DELAY
		mov		ah,al
		in		al,TIMER_0_8253		; most significant byte
		xchg	ah,al
		neg		ax					; Convert from countdown remaining
									;  to elapsed count
		mov		[TimedCount],ax

; Time a zero-length code fragment, to get a reference count for how
; much overhead this routine has. Time it 16 times and average it, for
; accuracy, rounding the result.

		mov		[ReferenceCount],0
		mov		cx,16
		cli							; interrupts off to allow a precise
									;  reference count
@@RefLoop:
		call	ReferenceTimerOn
		call	ReferenceTimerOff
		loop	@@RefLoop
		sti
		add		[ReferenceCount],8	; total + (0.5 * 16)
		mov		cl,4
		shr		[ReferenceCount],cl	; (total) / 16 + 0.5

; Restore original interrupt state.

		pop		ax					; Retrieve flags when called
		mov		ch,[OriginalFlags]	; get back the original upper
									;  byte of the FLAGS register
		and		ch,not 0fdh			; only care about original interrupt
									;  flag...
		and		ah,0fdh				; ...keep all other flags in
		or		ah,ch				;  their current condition
		push	ax					; Prepare flags to be popped

; Restore the context of the program being timed and return to it.

		MPOPF						; restore the flags with the
									;  original interrupt state
		pop		cx
		pop		ax
		ret

procend		_PZTimerOff

;----------------------------------------------------------------------------
; ReferenceTimerOn
;----------------------------------------------------------------------------
; Called by PZTimerOff to start timer for overhead measurements.
;----------------------------------------------------------------------------
proc		ReferenceTimerOn far

; Save the context of the program being timed

		push	ax
		pushf						; Interrupts are already off

; Set the timer 0 of the 8253 to mode 2 (divide-by-N), to cause
; linear counting rather than count-by-two counting.

		mov		al,00110100b		; set up to load
		out		MODE_8253,al		; timer count
		DELAY

; Set the timer count to 0

		sub		al,al
		out		TIMER_0_8253,al		; load count lsb
		DELAY
		out		TIMER_0_8253,al		; load count msb

; Restore the context and return.

		MPOPF
		pop		ax
		ret

procend		ReferenceTimerOn

;----------------------------------------------------------------------------
; ReferenceTimerOff
;----------------------------------------------------------------------------
; Called by PZTimerOff to stop timer and add result to ReferenceCount
; for overhead measurements.
;----------------------------------------------------------------------------
procfar		ReferenceTimerOff far

; Save the context of the program being timed

		push	ax
		push	cx
		pushf

; Latch the count and read it.

		mov		al,00000000b		; latch timer 0
		out		MODE_8253,al
		DELAY
		in		al,TIMER_0_8253		; least significant byte
		DELAY
		mov		ah,al
		in		al,TIMER_0_8253		; most significant byte
		xchg	ah,al
		neg		ax					; Convert from countdown remaining
									;  to elapsed count
		add		[ReferenceCount],ax

; Restore the context of the program being timed and return to it.

		MPOPF						; restore the flags with the
									;  original interrupt state
		pop		cx
		pop		ax
		ret

procend		ReferenceTimerOff

;----------------------------------------------------------------------------
; void PZTimerReport(void);
;----------------------------------------------------------------------------
; Report timing results found.
;----------------------------------------------------------------------------
procfar		_PZTimerReport

		pushf
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	ds

		push	cs					; DOS functions require that DS point
		pop		ds					;  to text to be displayed on the screen

if codesize
		ASSUME	ds:pztimer_TEXT
else
		ASSUME	ds:_TEXT
endif

; Check for timer 0 overflow.

		cmp		[OverflowFlag],0
		jz		@@GoodCount
		mov		dx,offset OverflowStr
		mov		ah,9
		int		21h
		jmp		short @@Done

; Convert net count to decimal ASCII in microseconds.

@@GoodCount:
		mov		ax,[TimedCount]
		sub		ax,[ReferenceCount]
		mov		si,offset ASCIICountEnd-1

; Convert count to microseconds by multiplying by 0.8381

		mov		dx,8381
		mul		dx
		mov		bx,10000
		div		bx					; * 0.8381 = * 8381 / 10000

; Convert time in microseconds to 5 decimal ASCII digits.

		mov		bx,10
		mov		cx,5

@@CTSLoop:
		sub		dx,dx
		div		bx
		add		dl,'0'
		mov		[si],dl
		dec		si
		loop	@@CTSLoop

; Print the results.

		mov		ah,9
		mov		dx,offset OutputStr
		int		21h

@@Done:
		pop		ds
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		MPOPF
		ret

		ASSUME	ds:DGROUP

procend		_PZTimerReport

;----------------------------------------------------------------------------
; unsigned long PZTimerCount(void);
;----------------------------------------------------------------------------
; Returns an unsigned long representing the net time in microseconds.
;----------------------------------------------------------------------------
procfar		_PZTimerCount

		setupDS

; Check for timer 0 overflow.

		cmp		[OverflowFlag],0
		jz		@@GoodCount

; The timer overflowed, so set set the count to 0xFFFFFFFF
		mov		ax,0FFFFh
		mov		dx,0FFFFh
		jmp		short @@Done

; Convert net count to decimal ASCII in microseconds.

@@GoodCount:
		mov		ax,[TimedCount]
		sub		ax,[ReferenceCount]

; Convert count to microseconds by multiplying by 0.8381

		mov		dx,8381
		mul		dx
		mov		bx,10000
		div		bx					; * 0.8381 = * 8381 / 10000
		xor		dx,dx

@@Done:
		restoreDS

		ret

procend		_PZTimerCount

endcodeseg	pztimer

		END						; End of module
