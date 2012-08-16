; Sample code to measure the performance of 200000 loads of AL from
; memory. Use by renaming to TESTCODE, which is included in LZTEST.ASM.
; LZTIME.BAT does this, along with assembling and linking the code. This
; piece of code WILL overflow the precision timer - even on my 486/33
; machine!

		jmp     Skip				; Jump around any defined data

MemVar  db      ?

Skip:

; Start timing

		call	ZTimerOn

		mov 	cx,2000
@@Loop:
		rept	10000
		mov		al,[MemVar]
		endm
		dec 	cx
		jz		@@Done
		jmp 	@@Loop

@@Done:

; Stop timing

		call	ZTimerOff

