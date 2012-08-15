; -----------------------------------------------------------------------------
; CPUSPD2.ASM   CPU speed measurement routine for TMi0SDGL 2      Version 2.15
;
; Too-Much-In-One-So-Don't-Get-Lost(tm) Revision 2 CPU/FPU Detection Library
; Copyright(c) 1996-2000 by B-coolWare.  Written by Bobby Z.
; -----------------------------------------------------------------------------
; This file contains Speed routine that plays part in CPU clock frequency
; calculation.

; This file implements method suggested my Vladimir S. Lokhov. This method
; presumably works under Linux's DOSemu.
; Regrettably, I found that it produces incorrect results under Windows 95
; and Windows NT (but does not hang up :).

; 20111114, trixter, took out windows code as it borks early versions of DOS.

        INCLUDE HEADER.ASH

        PUBLIC  Speed

; ------ Speed routine implementation

Speed   PROC  DIST
IFNDEF  __32bit__
LOCAL   Stage : Word            ; local variable to differ test stages
ENDIF
IFDEF   __32bit__
USES    ebx, esi, edi
ELSE
USES    si, di
ENDIF
        mov     cx,2
IFNDEF  __32bit__
        mov     Stage,0
ENDIF
@@1:
        mov     speedShift,cx   ; initialize speedShift
IFNDEF  __32bit__
        push    Stage
ELSE
        push    0
ENDIF
        call    speedTest       ; do a code section 101 times
        cmp     ax,1000h
        jnb     @@2
        mov     cx,speedShift
IFDEF   __32bit__
        shl     cx,3
ELSE
        shl     cx,1            ; repeat test with increasing values until
        shl     cx,1            ; we get reasonable time value worth working
        shl     cx,1            ; with
ENDIF
        jmp     @@1
@@2:
        push    ax
        mov     cx,speedShift   ; no do the same code section 100 times less
IFNDEF  __32bit__
        mov     Stage,1
        push    Stage
ELSE
        push    1
ENDIF
        call    speedTest
        pop     dx
        sub     dx,ax           ; now we got time how long 100*shift instructions
        xchg    ax,dx           ; were performed - knowing number of ticks it
        ret                     ; takes for each CPU type we can compute the
        ENDP                    ; CPU clock frequency.

speedTest       PROC    NEAR
ARG     Stage : Word

        push    si di
        clr     dx
        mov     si,0AAAAh
        mov     bx,05555h

        cli               ; initialize hardware timer
        mov     al,32h
        out     43h,al
        REPT    3
        jmp     $+2
        ENDM
        clr     ax
        out     40h,al
        REPT    3
        jmp     $+2
        ENDM
        out     40h,al
        sti
        clr     al
        out     43h,al
        jmp     $+2
        in      al,40h
        mov     ah,al
        jmp     $+2
        in      al,40h
        xchg    al,ah
        mov     di,ax

        cmp     Stage,0
        jnz     @@2
@@1:
;        cli
@@3:
        REPT    101
        mov     ax,si
        div     bx
        ENDM
        dec     cx
        jz      @@4
        jmp     @@3
@@2:
;        cli
@@5:
        mov     ax,si
        div     bx
        dec     cx
        jz      @@4
        jmp     @@5

@@4:
        clr     al              ; shutdown timer and process results
        out     43h,al
        jmp     $+2
        in      al,40h
        mov     ah,al
        jmp     $+2
        in      al,40h
        sti
        xchg    al,ah
        xchg    ax,di
        sub     ax,di
        push    ax
        cli
        mov     al,36h
        out     43h,al
        REPT    3
        jmp     $+2
        ENDM
        clr     ax
        out     40h,al
        REPT    3
        jmp     $+2
        ENDM
        out     40h,al
        sti
        pop     ax
        pop     di si
        ret
        ret
        ENDP

        END
