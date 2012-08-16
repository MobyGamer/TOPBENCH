; Sample code to measure the performance of 1000 loads of AL from
; memory. Use by renaming to TESTCODE, which is included in PZTEST.ASM.
; PZTIME.BAT does this, along with assembling and linking the code.

		jmp     Skip				; Jump around any defined data

MemVar  db      ?

Skip:

; Start timing

		call	ZTimerOn

		rept    1000
		mov		al,[MemVar]
		endm

; Stop timing

		call	ZTimerOff

