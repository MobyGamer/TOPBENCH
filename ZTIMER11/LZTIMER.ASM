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
;* Filename:	$RCSfile: lztimer.asm $
;* Version:		$Revision: 1.4 $
;*
;* Language:	8086 Assembler
;* Environment:	IBM PC (MS DOS)
;*
;* Description:	Uses the 8253 timer and the BIOS time-of-day count to time
;*				the performance of code that takes less than an hour to
;*				execute.
;*
;*				Because interrupts are left on (in order to allow the timer
;*				interrupt to be recognised), this is less accurate than the
;*				precision Zen Timer, so it is best used only to time code
;*				that takes more than about 54 milliseconds to execute (code
;*				that causes the precision Zen Timer to overflow). Resolution
;*				is limited by the occurrence of timer interrupts.
;*
;*	Externally 'C' callable routines:
;*
;*	LZTimerOn:		Saves the BIOS time of day count and starts the
;*					long period Zen Timer.
;*
;*	LZTimerOff:		Stops the long-period Zen Timer and saves the timer
;*					count and the BIOS time of day count.
;*
;*	LZTimerReport:	Prints the net time that passed between starting and
;*					stopping the timer.
;*
;*	LZTimerCount:	Returns an unsigned long representing the timed count
;*					in microseconds. If more than an hour passed or
;*					midnight passed during the timing interval, LZTimerCount
;*					will return the value 0xFFFFFFFF (an invalid count).
;*
;*	Note:	If either more than an hour passes or midnight falls between
;*			calls to LZTimerOn and LZTimerOff, an error is reported. For
;*			timing code that takes more than a few minutes to execute,
;*			either the DOS TIME command in a batch file before and after
;*			execution of the code to time or the use of the DOS time-of-day
;*			function in place of the long-period Zen Timer is more than
;*			adequate.
;*
;*	Note:	The PS/2 version is assembled by setting the symbol PS2 to 1.
;*			PS2 must be set to 1 on PS/2 computers because the PS/2's timers
;*			are not compatible with an undocumented timer-stopping feature
;*			of the 8253; the alternative timing approach that must be used
;*			on PS/2 computers leaves a short window during which the timer 0
;*			count and the BIOS timer count may not be synchronised. You
;*			should also set the PS2 symbol to 1 if you're getting erratic
;*			or obviously incorrect results.
;*
;*	Note:	When PS2 is 0, the code relies on a undocumented feature of the
;*			8253 to get more reliable readings. It is possible that the
;*			8253 (or whatever chip is emulating the 8253) may be put into
;*			an undefined or incorrect state when this feature if used.
;*
;*		*****************************************************************
;*		* If your computer displays any hint of erratic behaviour		*
;*		* after the long-period Zen Timer is used, such as the floppy	*
;*		* drive failing to operate properly, reboot the system, set		*
;*		* PS2 to 1 and leave it that way!								*
;*		*****************************************************************
;*
;*	Note:	Each block of code being timed should ideally be run several
;*			times, with at least two similar readings required to
;*			establish a true measurement, in order to eliminate any
;*			variability caused by interrupts.
;*
;*	Note:	Interrupts must not be disabled for more than 54 ms at a
;*			stretch during the timing interval. Because interrupts are
;*			enabled, key, mice, and other devices that generate interrupts
;*			should not be used during the timing interval.
;*
;*	Note:	Any extra code running off the timer interrupt (such as
;*			some memory resident utilities) will increase the time
;*			measured by the Zen Timer.
;*
;*	Note:	These routines can introduce inaccuracies of up to a few
;*			tenths of a second into the system clock count for each
;*			code section being timed. Consequently, it's a good idea to
;*			reboot at the conclusion of timing sessions. (The
;*			battery-backed clock, if any, is not affected by the Zen
;*			timer.)
;*
;*  All registers and all flags are preserved by all routines.
;*
;* $Id: lztimer.asm 1.4 92/04/20 17:33:43 kjb release $
;*
;* Revision History:
;* -----------------
;*
;* $Log:	lztimer.asm $
;* Revision 1.4  92/04/20  17:33:43  kjb
;* Modified to allow timing across a midnight boundary
;* 
;* Revision 1.3  92/01/27  21:39:57  kjb
;* Converted to a memory model independant library, and released to the
;* public.,
;* 
;* Revision 1.2  91/11/16  17:11:33  kjb
;* Modified to return a long integer count rather than a string.
;*
;* Revision 1.1  91/11/14  17:16:28  kjb
;* Initial revision
;*
;****************************************************************************

		IDEAL

INCLUDE "model.mac"				; Memory model macros

header	lztimer					; Set up memory model

;****************************************************************************
;
; Equates used by long period Zen Timer
;
;****************************************************************************

; Set PS2 to 0 to assemble for use on a fully 8253 compatible system. Set
; it to 1 for PS/2 computers and partially compatible 8253 systems.

PS2				equ		1

; Base address of 8253 timer chip

BASE_8253		=		40h

; The address of the timer 0 count registers in the 8253

TIMER_0_8253	=		BASE_8253 + 0

; The address of the mode register in the 8253

MODE_8253		=		BASE_8253 + 3

; The address of the BIOS timer count variable in the BIOS data area.

TIMER_COUNT		=		46Ch

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

begcodeseg	lztimer				; Start of code segment

StartBIOSCountLow	dw	?		; BIOS count low word at the start of
								;  the timing period
StartBIOSCountHigh	dw	?		; BIOS count high word at the start of
								;  the timing period
EndBIOSCountLow		dw	?		; BIOS count low word at the end of
								;  the timing period
EndBIOSCountHigh	dw	?		; BIOS count high word at the end of
								;  the timing period
EndTimedCount		dw	?		; Timer 0 count at the end of
								;  the timing period
ReferenceCount		dw	?		; Number of counts required to execute timer
								;  overhead code

; String printed to report results.

label			OutputStr byte
				db		0dh, 0ah, 'Timed count: '
TimedCountStr	db		10 dup (?)
				db		' microseconds', 0ah, 0dh
				db		'$'

; Temporary storage for timed count as it's divided down by powers
; of ten when converting from doubleword binary to ASCII

CurrentCountLow		dw	?
CurrentCountHigh	dw	?

; Powers of ten table use to perform division by 10 when doing doubleword
; conversion from binary to ASCII.

label	PowersOfTen word
		dd		1
		dd		10
		dd		100
		dd		1000
		dd		10000
		dd		100000
		dd		1000000
		dd		10000000
		dd		100000000
		dd		1000000000
label	PowersOfTenEnd word

; String printed to report that the high word of the BISO count changed
; while timing (an hour elapsed or midnight was crossed),
; and so the count is invalid and the test needs to be rerun.

label	TurnOverStr byte
		db	0dh,0ah
		db	'****************************************************',0dh,0ah
		db	'* Either midnight passed or an hour or more passed *',0dh,0ah
		db	'* while timing was in progress. If the former was  *',0dh,0ah
		db	'* the case, please re-run the test; if the latter  *',0dh,0ah
		db	'* was the case, the test code takes too long to    *',0dh,0ah
		db	'* run to be timed by the long-period Zen Timer.    *',0dh,0ah
		db	'* Suggestions: Use the DOS TIME command, the DOS   *',0dh,0ah
		db	'* time function, or a watch!                       *',0dh,0ah
		db	'****************************************************',0dh,0ah
		db	'$'

;----------------------------------------------------------------------------
; void LZTimerOn(void);
;----------------------------------------------------------------------------
; Starts the Long period Zen timer counting.
;----------------------------------------------------------------------------
procfar		_LZTimerOn

; Save the context of the program being timed

		push	ax
		pushf

; Set the timer 0 of the 8253 to mode 2 (divide-by-N), to cause
; linear counting rather than count-by-two counting. Also stops
; timer 0 until the timer count is loaded, except on PS/2 computers.

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

; In case interrupts are disabled, enable interrupts briefly to allow the
; interrupt generated when switching from mode 3 to mode 2 to be recognised.
; Interrupts must be enabled for at least 210 ns to allow time for that
; interrupt to occur. Here, 10 jumps are used for the delay to ensure that
; the delay time will be more than enough even on a very fast PC.

		pushf
		sti
		rept	10
		jmp		$+2
		endm
		MPOPF

; Store the timing start BIOS count.
; (Since the timer count was just set to 0, the BIOS count will stay the
; same for the next 54 ms, so we don't need to disable interrupts in order
; to avoid getting a half-changed count.)

		push	ds
		sub		ax,ax
		mov		ds,ax
		mov		ax,[ds:TIMER_COUNT+2]
		mov		[StartBIOSCountHigh],ax
		mov		ax,[ds:TIMER_COUNT]
		mov		[StartBIOSCountLow],ax
		pop		ds

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

procend		_LZTimerOn

;----------------------------------------------------------------------------
; void LZTimerOff(void);
;----------------------------------------------------------------------------
; Stops the long period Zen timer and saves count.
;----------------------------------------------------------------------------
procfar		_LZTimerOff

; Save the context of the program being timed

		pushf
		push	ax
		push	cx

; In case interrupts are disabled, enable interrupts briefly to allow
; any pending interrupts to be handled. Interrupts must be enabled for at
; leas 210 ns to allow time for that interrupt to occur. Here, 10 jumps
; are used for the delay to ensure that the delay will be more than long
; enough even on a very fast PC.

		sti
		rept	10
		jmp		$+2
		endm

; Latch the timer count.

if PS2

		mov		al,00000000b		; latch timer 0
		out		MODE_8253,al

; This is where a one instruction long window exists on the PS/2. The timer
; count and the BIOS count can lose synchronization; since the timer keeps
; counting after it's latched, it can turn over right after it's latched
; and cause the BIOS count to turn over before interrupts are disabled,
; leaving us with a timer count from before the timer turned over coupled
; with a BIOS count from after the timer turned over. The result is a count
; that's 54 ms too long.

else

; Set timer 0 to mode 2 (divide-by-N), waiting for a 2-byte count load,
; which stops timer 0 until the count is loaded. (Only works on fully
; 8253 compatible chips).

		mov		al,00110100b		; Mode 2
		out		MODE_8253,al
		DELAY
		mov		al,00000000b		; Latch timer 0 count
		out		MODE_8253,al

endif

		cli							; Stop the BIOS count

; Read the BIOS count. (Since interrupts are disabled, the BIOS
; count won't change).

		push	ds
		sub		ax,ax
		mov		ds,ax
		mov		ax,[ds:TIMER_COUNT+2]
		mov		[EndBIOSCountHigh],ax
		mov		ax,[ds:TIMER_COUNT]
		mov		[EndBIOSCountLow],ax
		pop		ds

; Read out the count we latched earlier.

		in		al,TIMER_0_8253		; least significant byte
		DELAY
		mov		ah,al
		in		al,TIMER_0_8253		; most significant byte
		xchg	ah,al
		neg		ax					; Convert from countdown remaining
									;  to elapsed count
		mov		[EndTimedCount],ax

; Restart timer 0, which is still waiting for an initial count
; to be loaded.

ife	PS2

		DELAY
		mov		al,00110100b		; mode 2, waiting to load a 2 byte count
		out		MODE_8253,al
		DELAY
		sub		al,al
		out		TIMER_0_8253,al		; lsb
		DELAY
		mov		al,ah
		out		TIMER_0_8253,al		; msb

endif

		sti							; Let the BIOS count continue

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

; Restore the context of the program being timed and return to it.

		pop		cx
		pop		ax
		MPOPF
		ret

procend		_LZTimerOff

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
proc		ReferenceTimerOff far

; Save the context of the program being timed

		pushf
		push	ax
		push	cx

; Match the interrupt window delay in LZTimerOff

		sti
		rept	10
		jmp		$+2
		endm

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

		pop		cx
		pop		ax
		MPOPF
		ret

procend		ReferenceTimerOff

;----------------------------------------------------------------------------
; void LZTimerReport(void);
;----------------------------------------------------------------------------
; Report timing results found.
;----------------------------------------------------------------------------
procfar		_LZTimerReport

		pushf
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	ds

		push	cs					; DOS functions require that DS point
		pop		ds					;  to text to be displayed on the screen

if codesize
		ASSUME	ds:lztimer_TEXT
else
		ASSUME	ds:_TEXT
endif

; See if a midnight boundary has passed and adjust the finishing BIOS
; count by the number of ticks in 24 hours. We wont be able to detect
; more than 24 hours, but at least we can time across a midnight
; boundary

		mov		ax,[EndBIOSCountHigh]	; Is end < start?
		cmp		ax,[StartBIOSCountHigh]
		ja		@@CheckForHour			; No, check for hour passing
		jb		@@Adjust				; Yes, adjust ending time

		mov		ax,[EndBIOSCountLow]	; Maybe, check low order words
		cmp		ax,[StartBIOSCountLow]
		jae		@@CheckForHour			; No, check for hour passing

; Adjust the finishing time by adding the number of ticks in 24 hours
; (1573040).

@@Adjust:
		add		[EndBIOSCountLow],00B0h
		adc		[EndBIOSCountHigh],18h

; See if more than an hour passed during timing. If so, notify the user.

@@CheckForHour:
		mov		ax,[StartBIOSCountHigh]
		cmp		ax,[EndBIOSCountHigh]
		jz		@@CalcBIOSTime		; Hour count didn't change, so
									;  everything is fine

		inc		ax
		cmp		ax,[EndBIOSCountHigh]
		jnz		@@TestTooLong		; Two hour boundaries passed, so the
									;  results are no good
		mov 	ax,[EndBIOSCountLow]
		cmp		ax,[StartBIOSCountLow]
		jb		@@CalcBIOSTime		; a single hour boundary passed. That's
									; OK, so long as the total time wasn't
									; more than an hour.

; Over an hour elapsed passed during timing, which renders
; the results invalid. Notify the user. This misses the case where a
; multiple of 24 hours has passed, but we'll rely on the perspicacity of
; the user to detect that case :-).

@@TestTooLong:
		mov		ah,9
		mov		dx,offset TurnOverStr
		int		21h
		jmp		short @@Done

; Convert the BIOS time to microseconds

@@CalcBIOSTime:
		mov		ax,[EndBIOSCountLow]
		sub		ax,[StartBIOSCountLow]
		mov		dx,54925			; Number of microseconds each
									;  BIOS count represents.
		mul		dx
		mov		bx,ax				; set aside BIOS count in
		mov		cx,dx				;  microseconds

; Convert timer count to microseconds

		mov		ax,[EndTimedCount]
		mov		si,8381
		mul		si
		mov		si,10000
		div		si					; * 0.8381 = * 8381 / 10000

; Add the timer and BIOS counts together to get an overall time in
; microseconds.

		add		bx,ax
		adc		cx,0

; Subtract the timer overhead and save the result

		mov		ax,[ReferenceCount]
		mov		si,8381
		mul		si
		mov		si,10000
		div		si					; * 0.8381 = * 8381 / 10000
		sub		bx,ax
		sbb		cx,0
		mov		[CurrentCountLow],bx
		mov		[CurrentCountHigh],cx

; Convert the result to an ASCII string by trial subtractions of
; powers of 10.

		mov		di,(offset PowersOfTenEnd - offset PowersOfTen) - 4
		mov		si,offset TimedCountStr

@@CTSNextDigit:
		mov		bl,'0'

@@CTSLoop:
		mov		ax,[CurrentCountLow]
		mov		dx,[CurrentCountHigh]
		sub		ax,[PowersOfTen+di]
		sbb		dx,[PowersOfTen+di+2]
		jc		@@CTSNextPowerDown
		inc		bl
		mov		[CurrentCountLow],ax
		mov		[CurrentCountHigh],dx
		jmp		@@CTSLoop

@@CTSNextPowerDown:
		mov		[si],bl
		inc		si
		sub		di,4
		jns		@@CTSNextDigit

; Print the results.

		mov		ah,9
		mov		dx,offset OutputStr
		int		21h

@@Done:
		pop		ds
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		MPOPF
		ret

		ASSUME	ds:DGROUP

procend		_LZTimerReport

;----------------------------------------------------------------------------
; unsigned long LZTimerCount(void);
;----------------------------------------------------------------------------
; Returns an unsigned long representing the net time in microseconds.
;
; If either and hour has passed, or midnight passed while timing, we
; return 0xFFFFFFFF as the count (which is not a possible count in itself).
;----------------------------------------------------------------------------
procfar		_LZTimerCount

		setupDS

; See if a midnight boundary has passed and adjust the finishing BIOS
; count by the number of ticks in 24 hours. We wont be able to detect
; more than 24 hours, but at least we can time across a midnight
; boundary

		mov		ax,[EndBIOSCountHigh]	; Is end < start?
		cmp		ax,[StartBIOSCountHigh]
		ja		@@CheckForHour			; No, check for hour passing
		jb		@@Adjust				; Yes, adjust ending time

		mov		ax,[EndBIOSCountLow]	; Maybe, check low order words
		cmp		ax,[StartBIOSCountLow]
		jae		@@CheckForHour			; No, check for hour passing

; Adjust the finishing time by adding the number of ticks in 24 hours
; (1573040).

@@Adjust:
		add		[EndBIOSCountLow],00B0h
		adc		[EndBIOSCountHigh],18h

; See if more than an hour passed during timing. If so, notify the user.

@@CheckForHour:
		mov		ax,[StartBIOSCountHigh]
		cmp		ax,[EndBIOSCountHigh]
		jz		@@CalcBIOSTime		; Hour count didn't change, so
									;  everything is fine

		inc		ax
		cmp		ax,[EndBIOSCountHigh]
		jnz		@@TestTooLong		; Two hour boundaries passed, so the
									;  results are no good
		mov 	ax,[EndBIOSCountLow]
		cmp		ax,[StartBIOSCountLow]
		jb		@@CalcBIOSTime		; a single hour boundary passed. That's
									; OK, so long as the total time wasn't
									; more than an hour.

; Over an hour elapsed passed during timing, which renders
; the results invalid. Notify the user. This misses the case where a
; multiple of 24 hours has passed, but we'll rely on the perspicacity of
; the user to detect that case :-).

@@TestTooLong:
		mov		ax,0FFFFh
		mov		dx,0FFFFh
		jmp		short @@Done

; Convert the BIOS time to microseconds

@@CalcBIOSTime:
		mov		ax,[EndBIOSCountLow]
		sub		ax,[StartBIOSCountLow]
		mov		dx,54925			; Number of microseconds each
									;  BIOS count represents.
		mul		dx
		mov		bx,ax				; set aside BIOS count in
		mov		cx,dx				;  microseconds

; Convert timer count to microseconds

		mov		ax,[EndTimedCount]
		mov		si,8381
		mul		si
		mov		si,10000
		div		si					; * 0.8381 = * 8381 / 10000

; Add the timer and BIOS counts together to get an overall time in
; microseconds.

		add		bx,ax
		adc		cx,0

; Subtract the timer overhead and save the result

		mov		ax,[ReferenceCount]
		mov		si,8381
		mul		si
		mov		si,10000
		div		si					; * 0.8381 = * 8381 / 10000
		sub		bx,ax
		sbb		cx,0
		mov		ax,bx
		mov		dx,cx

@@Done:
		restoreDS

		ret

procend		_LZTimerCount

endcodeseg	lztimer

		END						; End of module
