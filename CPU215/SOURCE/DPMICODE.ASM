; -----------------------------------------------------------------------------
; DPMICODE.ASM - DPMI-compliant Code for TMi0SDGL 2               Version 2.15
;
; Too-Much-in-0ne-So-Don't-Get-Lost(tm) Revision 2 CPU/FPU Detection Library
; Copyright(c) 1996-2000 by B-coolWare. Written by Bobby Z.
; -----------------------------------------------------------------------------
; This file contains low-level routines used in TMi0SDGL 2.
;
; defines that affect compilation:
;
; __32bit__     type : define
;               default: not defined
;               purpose: selects either 32-bit or 16-bit code
; this define should only be used with C/C++ compilers and Delphi 2+,
; Borland Pascal 7 and Delphi 1.x do not support 32-bit protected mode
; program generation.
;

; global vars/procs/includes section ------------------------------------------
;
        INCLUDE HEADER.ASH      ; TMi0SDGL header file
        INCLUDE DPMI.ASH        ; DPMI interface file

        PUBLIC  getCPUType              ; returns CPU index
        PUBLIC  getFPUType              ; returns FPU index
        PUBLIC  getCyrixModel           ; returns Cx486 model index
        PUBLIC  CxCPUIDEnable           ; enables CPUID on Cyrix 5x86
                                        ; and 6x86
        PUBLIC  getL2CacheDesc          ; returns L2 cache descriptor for
                                        ; Pentium Pro and Pentium II
        PUBLIC  getCPUID                ; get CPUID values for specified lvl

;
; code section ----------------------------------------------------------------
;

getCPUType      proc    DIST
IFDEF  __32bit__
USES   ebx, esi, edi
ENDIF
;
; here's where all the low-level work done
;
IFNDEF  __32bit__
        mov     cpu,i80286              ; we start with 80286 - the first CPU
                                        ; with protected mode, others simply
                                        ; can't execute this code :)
        call    _np check386
        jc      @@Q
ENDIF
        mov     cpu,i80386sx

@@chkCT386:
        call    _np checkCT38600
        jc      @@386clones     ; AMD/Intel 386 POPAD bug detected - no need to
                                ; check for 486+...
        mov     cpu,ct38600
@@chk486:
        call    _np check486
        jc      @@386clones
        mov     cpu,i486sx

@@cyrix:
        call    checkCyrix      ; check if running on Cyrix CPU
        jc      @@checkCPUID
        mov     cpu,Cx486       ; assume Cx486
;       call    CxCPUIDEnable   ; enable CPUID on Cx5x86 and 6x86, it's
                                ; disabled by default.
        jmp     @@checkCPUID    ; try override this detection with CPUID

IFNDEF  __32bit__
        .386
ENDIF
@@checkCPUID:
        pushfd                  ; check if CPUID instruction is supported
        pushfd
        pop     eax
        mov     ebx,eax
        xor     eax,EF_ID       ; try flipping ID bit in EFLAGS...
        push    eax
        popfd
        pushfd
        pop     eax
        popfd
        cmp     eax,ebx
        jz      @@noCPUID       ; bit was not flipped - no CPUID
        or      extFlags,efCPUIDSupport
        mov     eax,0C0000000h
        _cpuid
        cmp     eax,0C0000000h
        jnz     @@notIDT
        or      extFlags,efCentaurLevel ; this CPUID level only supported
                                        ; by Centaur's WinChip C6
@@notIDT:
        clr     eax
        _cpuid                   ; get detailed CPU info via CPUID
        push    eax
        and     eax,0FFFFFF00h
        cmp     eax,000000500h   ; pre-B0 step Pentium workaround
        pop     eax
        jnz     @@okCPUID
        mov     cpuid1,eax              ; simulate normal CPUID output
        mov     _dp cpuid0,756E6547h    ; put GenuineIntel signature
        mov     _dp cpuid0[4],49656E69h ; where it is expected to be
        mov     _dp cpuid0[8],6C65746Eh
        mov     _dp cpuBrand,0
        clr     eax
        inc     al                      ; and get feature flags
        _cpuid
        jmp     @@B0CPUID               ; then go on as usual
@@okCPUID:
        mov     _dp cpuid0,ebx
        mov     _dp cpuid0[4],edx
        mov     _dp cpuid0[8],ecx
        clr     eax     ; this code assumes that every CPU implements CPUID
        inc     al      ; at least to level 1...
        _cpuid
        mov     cpuid1,eax
        and     ebx,0FFh
        mov     _dp cpuBrand,ebx
@@B0CPUID:
        mov     cpuFeatures,edx
        test    dl,1
        jz      @@10
        or      extFlags,efHasFPUonChip
@@10:
        test    dl,10h
        jz      @@101
        or      extFlags,efTSCSupport
@@101:
        and     ax,0F00h
        cmp     ah,4
        jz      @@Q
        mov     cpu,iPentium
        cmp     ah,5
        jz      @@Q
        mov     cpu,iPentiumPro
        cmp     ah,6
        jz      @@Q
        mov     cpu,iP7
        cmp     ah,7
        jz      @@Q
        mov     cpu,iP8
        jmp     @@Q

@@386clones:
        call    _np checkAm386  ; check for Am386 UMOV instruction
        jc      @@chkNexGen
        mov     cpu,am386sx     ; possibly an Am386 detected
        jmp     @@386sx

@@chkNexGen:
        call    _np checkNexGen
        jc      @@tryBIOS
        mov     cpu,Nx586
        jmp     @@Q

@@tryBIOS:
IFNDEF  __32bit__                       ; this routine doesn't work under NT
        call    _np check_byBIOS; this routine will update cpu by itself
        jnc     @@Q             ; and make terminal decision
@@386SL:
        mov     dh,3
        call    _np check_x86SL
        jc      @@tryMSRs
        mov     cpu,i386sl
        jmp     @@Q
ENDIF
@@tryMSRs:
        call    _np checkIBMmsrs; this routine will update cpu by itself
        jc      @@Q             ; unlike others, this routine sets CF on
                                ; successful detect
@@386sx:
        call    _np check386sx
        jc      @@Q
        inc     cpu
        jmp     @@Q
@@noCPUID:
        cmp     cpu,Cx486
        jz      @@Q
IFNDEF  __32bit__
        call    _np check_byBIOS
        jnc     @@Q
@@486SL:
        mov     dh,4
        call    _np check_x86SL
        jc      @@MSRs3
        mov     cpu,i486sl
ENDIF
@@MSRs3:
        call    _np checkIBMmsrs3  ; unlike others, this routine sets CF on
        jc      @@Q                ; successful detect
@@486sx:
        call    _np check486sx
        jc      @@Q
        cmp     cpu,am486
        jnz     @@1
        mov     cpu,am486dx
@@1:
        inc     cpu
@@Q:
        ret
        endp

IFNDEF  __32bit__
        .8086
ENDIF

        db      13,10
        db      'TMi0SDGL Revision 2 CPU/FPU Detection Library  Version 2.15',13,10
        db      'Copyright(c) 1996-2000 by B-coolWare.   Written by Bobby Z.',13,10
        db      13,10
        db      'Simply the best...',13,10

check386:
        mov     ax,7000h
        pushf
        push    ax
        popf
        pushf
        pop     ax
        popf
        and     ah,70h          ; check for flags - only 386+ has them
        jz      Nope            ; if ah=0 than this is 286
Yes:
        clc
        ret
Nope:
        stc
        ret

IFNDEF __32bit__        ; can't be called under Win32
check_byBIOS:
        mov     ax,0C910h
        int     15h
        jc      Nope
        cmp     ch,04
        jz      @@a486
        cmp     ch,33h
        jz      @@i376
        cmp     ch,43h
        jz      @@i386SL
        cmp     ch,0A3h
        jz      @@ibm386SL
        cmp     ch,0A4h
        jz      @@ibm486SLC2
        cmp     ch,84h
        jz      @@bl3
        jmp     Nope            ; detect as usual
@@i376:
        mov     cpu,i376
        jmp     Yes
@@i386SL:
        mov     cpu,i386sl
        jmp     Yes
@@ibm386SL:
        mov     cpu,ibm386slc
        jmp     Yes
@@ibm486SLC:
        mov     cpu,ibm486slc
        jmp     Yes
@@ibm486SLC2:
        mov     cpu,ibm486slc2
        jmp     Yes
@@bl3:
        mov     cpu,ibm486bl3
        jmp     Yes
@@a486:
        cmp     cl,02           ; Am486DX2
        jnz     Nope
        mov     cpu,am486
        jmp     Yes
ENDIF

check_x86SL:
; On entry: DH contains CPU family code (3 for 386, 4 for 486)
;
; Copyright(c) by Robert Collins
; Adapted for TMi0SDGL by Bobby Z. Original code flow and comments preserved.
;-----------------------------------------------------------------------------
; The Intel386 SL and Intel486 SL have a register which allows reading the
; CPUID.  This register is called the signature register, and lies in the On-
; board Memory Control Unit (OMCU) at register 0x30E.  To read the signature
; register, first we must unlock access to the OMCU, read the signature,
; and relock access.
;-----------------------------------------------------------------------------
; To unlock access to the CPUPWRMODE register, we need to execute the
; following code sequence:
;       write 00h to port(23h)
;       write 80h to port(22h)
;       write 0080h to port(22h)        ; word write
        cli
        in      ax,22h                  ; get CPUPWRMODE register
        xor     ax,0ffffh               ; all bits set?
        jz      Nope                    ; yes, go split
        in      ax,22h                  ; get CPUPWRMODE register
        test    al,1                    ; CPUPWRMODE unlocked?
        jz      @EnaPWRMODE             ; nope, don't try and lock it.

;-----------------------------------------------------------------------------
; The safest way to determine whether or not this is a 386 SL is to attempt
; to lock and unlock the CPUPWRMODE register.  If the register can be locked
; and unlocked as per 386 SL specifications, then there's a good chance that
; this isn't some chipset that amazingly supports the same enable/disable
; protocol.  So if we can enable and disable the CPUPWRMODE register, then
; we'll proceed with reading the CPUID signature register.
;-----------------------------------------------------------------------------
; Lock the CPUPWRMODE register
        mov     al,00                   ;
        out     23h,al                  ;
        mov     ax,180h                 ; will lock CPUPWRMODE register
        out     22h,al
        out     22h,ax                  ; now CPUPWRMODE register should be
                                        ;  locked.
        in      ax,22h                  ; get CPUPWRMODE register
        test    al,1                    ; CPUPWRMODE unlocked?
        jnz     Nope                    ; yes, go try and unlock it

;-----------------------------------------------------------------------------
; Unlock the CPUPWRMODE register
@EnaPWRMODE:
        mov     al,00                   ;
        out     23h,al                  ;
        mov     ax,80h                  ; will unlock CPUPWRMODE register
        out     22h,al
        out     22h,ax                  ; now CPUPWRMODE register should be
                                        ;  unlocked.
        in      ax,22h                  ; get CPUPWRMODE register
        test    al,1                    ; CPUPWRMODE unlocked?
        jz      Nope                    ; yes, go try and unlock it

;-----------------------------------------------------------------------------
; Enable the On-board Memory Configuration Unit (OMCU).  If this is an
; Intel486 SL, then bits [4-2] are the unit configuration select bits.  If
; this is an Intel386 SL, then bits [3-2] are the unit configuration select
; bits.
        and     al,not 1100b            ; clear configuration unit bits
        and     dh,0fh                  ; only keep processor family bits
        cmp     dh,4                    ; 486 SL?
        jne     @@1                     ; nope
        and     al,not 11100b           ; clear configuration unit bits
@@1:    or      al,10b                  ; set unit enable bit
        out     22h,ax                  ; now unit should be enabled

;-----------------------------------------------------------------------------
; Now read the CPUID signature register
        mov     dx,030Eh                ; signature register
        in      ax,dx                   ; get CPUID signature
        mov     dx,ax                   ; make a copy

;-----------------------------------------------------------------------------
; Now as one final test, let's relock the CPUPWRMODE register and make sure
; it really gets locked.  Otherwise, we'll ignore the value we just read.
        mov     al,00                   ;
        out     23h,al                  ;
        mov     ax,180h                 ; will lock CPUPWRMODE register
        out     22h,al
        out     22h,ax                  ; now CPUPWRMODE register should be
                                        ;  locked.
        in      ax,22h                  ; get CPUPWRMODE register
        test    al,1                    ; CPUPWRMODE unlocked?
        jnz     Nope                    ; yes, go try and unlock it

;-----------------------------------------------------------------------------
; OK, must be 80386 SL, and we have CPUID in BX.
        mov     ax,dx                   ; restore copy of CPUID
        ror     ah,4                    ; swap nibble locations
        shr     ax,4                    ; convert to standard CPUID format
        jmp     Yes

        .386

IFNDEF  __32bit__
_retIP          equ     <word ptr [bp+02]>
_retCS          equ     <word ptr [bp+04]>
_errCode        equ     <word ptr [bp+06]>
_ip             equ     <word ptr [bp+08]>
_cs             equ     <word ptr [bp+10]>
_flags          equ     <word ptr [bp+12]>
_sp             equ     <word ptr [bp+14]>
_ss             equ     <word ptr [bp+16]>

ELSE

_retEIP         equ     <dword ptr [ebp+04]>
_retCS          equ     <word ptr [ebp+08]>
_errCode        equ     <dword ptr [ebp+12]>
_eip            equ     <dword ptr [ebp+16]>
_cs             equ     <word ptr [ebp+20]>
_eflags         equ     <dword ptr [ebp+24]>
_esp            equ     <dword ptr [ebp+28]>
_ss             equ     <word ptr [ebp+32]>

ENDIF

checkAm386      proc near
; this method is donated by Vasiliy Sorokin. It uses some undocumented
; instructions present in Am386/486 chips but not found in other x86s.
IFDEF __32bit__
LOCAL   oldSelector06 : WORD, oldOffset06 : DWORD
ELSE
LOCAL   oldSelector06 : WORD, oldOffset06 : WORD
ENDIF
        call    checkCyrix      ; don't check on Cyrix/UMC chips
        jnc     __done2
        pushfd                  ; neither check if CPUID is supported
        pushfd
        pop     eax
        mov     ebx,eax
        xor     eax,EF_ID       ; try flipping ID bit of EFLAGS
        push    eax
        popfd
        pushfd
        pop     eax
        popfd
        cmp     eax,ebx
        jnz     __done2         ; the bit was flipped - CPUID supported
IFDEF   __32bit__
        pushad
ELSE
        pusha
ENDIF
        push    ds es
IFNDEF  __32bit__
        mov     bl,06
        dpmiCall dpmiGetExceptionHnd
        mov     oldSelector06,cx
        mov     oldOffset06,dx
        mov     bl,06
        mov     cx,cs
        mov     dx,offset exHandler
        dpmiCall dpmiSetExceptionHnd
ELSE
        mov     bl,06
        dpmiCall dpmiGetExceptionHnd
        mov     oldSelector06,cx
        mov     oldOffset06,edx
        mov     bl,06
        mov     cx,cs
        mov     edx,offset exHandler
        dpmiCall dpmiSetExceptionHnd
ENDIF
        mov     dl,[bx+si]
        db      0Fh
        adc     al,cl
        add     [bx+si],al
; if we get to this point, the code is executed on Am386
        mov     [bx+si],dl
IFNDEF  __32bit__
        mov     cx,oldSelector06
        mov     dx,oldOffset06
        mov     bl,06
        dpmiCall dpmiSetExceptionHnd
ELSE
        mov     cx,oldSelector06
        mov     edx,oldOffset06
        mov     bl,06
        dpmiCall dpmiSetExceptionHnd
ENDIF
        pop     es ds
IFDEF   __32bit__
        popad
ELSE
        popa
ENDIF
        clc
        jmp     __done
__Cont:
        mov     [bx+si],dl
IFNDEF  __32bit__
        mov     cx,oldSelector06
        mov     dx,oldOffset06
        mov     bl,06
        dpmiCall dpmiSetExceptionHnd
ELSE
        mov     cx,oldSelector06
        mov     edx,oldOffset06
        mov     bl,06
        dpmiCall dpmiSetExceptionHnd
ENDIF
        pop     es ds
IFDEF   __32bit__
        popad
ELSE
        popa
ENDIF
__done2:
        stc
__done:
        ret
        endp

exHandler:
; this is the Exception 06 handler used in Am386 detection. This handler
; redirects execution to @@Cont, which means that Am386 was not detected -
; the instruction was trapped.
IFNDEF  __32bit__
        push    bp
        mov     bp,sp
        mov     _ip, offset __Cont
        pop     bp
        retf
ELSE
        push    ebp
        mov     ebp,esp
        mov     _eip, offset __Cont
        pop     ebp
        retf
ENDIF

checkCT38600:
        mov     esi,32          ; give it 32 tries
        mov     eax,12345678h   ; load a value
        mov     ebx,eax         ; save it for reference
IFDEF   __32bit__
        sub     edx,edx         ; set edx+edi to point to DS:cpu (can access)
        mov     edi,offset cpu
ELSE
        sub     edx,edx         ; set edx+edi to point to DS:0
        sub     edi,edi
ENDIF
@@ct_loop:
        pushad                  ; push all registers
        popad                   ; pop all registers
        mov     ecx,[edx+edi]   ; and do a memory access
        cmp     eax,ebx         ; did eax changed?
        jnz     Nope            ; YES! this is an Intel/AMD 386 - they have
        dec     esi             ; POPAD bug: mem access after popad changes
        jnz     @@ct_loop       ; eax contents
        jmp     Yes             ; all 32 tries passed - should be C&T38600

check486:                       ; this code is blessed by Intel, donated to
                                ; public domain by CompaQ.
        mov     ax,sp
        and     sp,0FFFCh       ;round down to a dword boundary
        pushfd
        pushfd
        pop     edx
        mov     ecx,edx
        xor     edx,EF_AC       ;toggle AC bit
        and     ecx,EF_AC
        push    edx
        popfd
        pushfd
        pop     edx
        popfd                   ;restore original flags
        mov     sp,ax           ;restore original stack pointer
        and     edx,EF_AC

        cmp     edx,ecx
        jnz     Yes             ;it's a 486
        jmp     Nope

        .386p

check386sx:
; following code can cause GPF traps under poorly written V86 monitors...
        mov     eax,cr0
        mov     ecx,eax
        xor     eax,MSW_ET      ; flipping ET bit
        mov     cr0,eax
        mov     eax,cr0
        mov     cr0,ecx         ; restoring previous value of CR0
        xor     eax,ecx         ; did it flip ok?
        jz      Nope            ; SX chips do not allow to change bus width
        jmp     Yes

        .8087
check486sx:
; following code can cause GPF traps under poorly written V86 monitors...
        mov     eax,cr0
        mov     ecx,eax
        xor     eax,MSW_NE      ; flipping NE bit
        mov     cr0,eax
        mov     eax,cr0
        mov     cr0,ecx         ; restoring previous value of CR0
        xor     eax,ecx         ; did it flip ok?
        jnz     Yes             ; SX chips do not allow to change NE bit

        mov     _wp fpuWord,5A5Ah   ; more tests
        fninit
        fnstcw   _wp fpuWord
        mov      ax,fpuWord
        test     al,al
        jnz     Nope
        jmp     Yes

checkCyrix:                     ; this code provided by Cyrix Corp.
        clr     ax,ax
        sahf                    ; clear flags, bit 1 always =1
        mov     ax,5
        mov     bx,2
        div     bl              ; do an operation that does not change flags
        lahf                    ; get flags
        cmp     ah,2            ; did flags changed?
        jne     Nope            ; yes, they did - not a Cyrix CPU
        jmp     Yes             ; didn't - Cyrix CPU

checkNexGen:                    ; this code provided by NexGen Corp.
        mov     ax,5555h
        xor     dx,dx
        mov     cx,2
        div     cx
        jnz     Nope            ; Nx586 doesn't change ZF on division while
        jmp     Yes             ; others do


; -----------------------------------------------------------------------------
; IBM 386SLC, 486SLC, 486SLC2 and 486BL3 chips detection code follows

; following is protected mode exception handler used to trap Exception 06
; (Invalid Opcode) and Exception 0D (General Protection Violation).

IFDEF  __32bit__
        .386
ENDIF

exceptionHandler:
; we know exactly the length of faulty instruction, so we'll just set IP to
; point past it, set the error flag (carry flag is used) and return back.
; The same action is taken on both exception 06 and 0D because the origin is
; the same instruction. This handler is not universal, it is used to handle
; traps from RDMSR only.

IFNDEF  __32bit__
        push    bp
        mov     bp,sp
        add     _ip,2
        and     byte ptr _flags,not 1    ; set CF=0 on return.
        pop     bp
        retf
ELSE
        push    ebp
        mov     ebp,esp
        add     _eip,2
        and     byte ptr _eflags,not 1   ; set CF=0 on return.
        pop     ebp
        retf
ENDIF

checkIBMmsrs    proc near
IFDEF __32bit__
LOCAL   oldSelector06 : WORD, oldOffset06 : DWORD, oldSelector13 : WORD, oldOffset13 : DWORD
ELSE
LOCAL   oldSelector06 : WORD, oldOffset06 : WORD, oldSelector13 : WORD, oldOffset13 : WORD
ENDIF
; setup exception handlers
IFNDEF  __32bit__
        mov     bl,06
        dpmiCall dpmiGetExceptionHnd
        mov     oldSelector06,cx
        mov     oldOffset06,dx
        mov     bl,06
        mov     cx,cs
        mov     dx,offset exceptionHandler
        dpmiCall dpmiSetExceptionHnd
        mov     bl,13
        dpmiCall dpmiGetExceptionHnd
        mov     oldSelector13,cx
        mov     oldOffset13,dx
        mov     bl,13
        mov     cx,cs
        mov     dx,offset exceptionHandler
        dpmiCall dpmiSetExceptionHnd
ELSE
        mov     bl,06
        dpmiCall dpmiGetExceptionHnd
        mov     oldSelector06,cx
        mov     oldOffset06,edx
        mov     bl,06
        mov     cx,cs
        mov     edx,offset exceptionHandler
        dpmiCall dpmiSetExceptionHnd
        mov     bl,13
        dpmiCall dpmiGetExceptionHnd
        mov     oldSelector13,cx
        mov     oldOffset13,edx
        mov     bl,13
        mov     cx,cs
        mov     edx,offset exceptionHandler
        dpmiCall dpmiSetExceptionHnd
ENDIF
        stc
        _rdmsr  1000h
        jnc     @@done
        mov     cpu,ibm386slc   ; IBM 386SLC
@@done:
        pushf
; free exception handlers
IFNDEF  __32bit__
        mov     cx,oldSelector06
        mov     dx,oldOffset06
        mov     bl,06
        dpmiCall dpmiSetExceptionHnd
        mov     cx,oldSelector13
        mov     dx,oldOffset13
        mov     bl,13
        dpmiCall dpmiSetExceptionHnd
ELSE
        mov     cx,oldSelector06
        mov     edx,oldOffset06
        mov     bl,06
        dpmiCall dpmiSetExceptionHnd
        mov     cx,oldSelector13
        mov     edx,oldOffset13
        mov     bl,13
        dpmiCall dpmiSetExceptionHnd
ENDIF
        popf
        ret
        endp

checkIBMmsrs2   proc near
IFDEF   __32bit__
LOCAL   oldSelector13 : WORD, oldOffset13 : DWORD
ELSE
LOCAL   oldSelector13 : WORD, oldOffset13 : WORD
ENDIF
        call    _np checkIBMmsrs ; first check if this is IBM 486SLC chip
        jnc     @@done2
; setup exception handler
IFDEF   __32bit__
        mov     bl,13
        dpmiCall dpmiGetExceptionHnd
        mov     oldSelector13,cx
        mov     oldOffset13,edx
        mov     bl,13
        mov     cx,cs
        mov     edx,offset exceptionHandler
        dpmiCall dpmiSetExceptionHnd
ELSE
        mov     bl,13
        dpmiCall dpmiGetExceptionHnd
        mov     oldSelector13,cx
        mov     oldOffset13,dx
        mov     bl,13
        mov     cx,cs
        mov     dx,offset exceptionHandler
        dpmiCall dpmiSetExceptionHnd
ENDIF
        stc
        _rdmsr  1002h           ; try to read 486SLC2 specific MSR
        jnc     @@notSLC2
        mov     cpu,ibm486slc2  ; IBM 486SLC2
        jmp     @@done
@@notSLC2:
        stc
        mov     cpu,ibm486slc   ; IBM 486SLC
@@done:
        pushf
IFDEF   __32bit__
        mov     cx,oldSelector13
        mov     edx,oldOffset13
        mov     bl,13
        dpmiCall dpmiSetExceptionHnd
ELSE
        mov     cx,oldSelector13
        mov     dx,oldOffset13
        mov     bl,13
        dpmiCall dpmiSetExceptionHnd
ENDIF
        popf
@@done2:
        ret
        endp

checkIBMmsrs3   proc near
IFDEF   __32bit__
LOCAL   oldSelector13 : WORD, oldOffset13 : DWORD
ELSE
LOCAL   oldSelector13 : WORD, oldOffset13 : WORD
ENDIF
        call    _np checkIBMmsrs2
        jnc     @@done2
IFDEF   __32bit__
        mov     bl,13
        dpmiCall dpmiGetExceptionHnd
        mov     oldSelector13,cx
        mov     oldOffset13,edx
        mov     bl,13
        mov     cx,cs
        mov     edx,offset exceptionHandler
        dpmiCall dpmiSetExceptionHnd
ELSE
        mov     bl,13
        dpmiCall dpmiGetExceptionHnd
        mov     oldSelector13,cx
        mov     oldOffset13,dx
        mov     bl,13
        mov     cx,cs
        mov     dx,offset exceptionHandler
        dpmiCall dpmiSetExceptionHnd
ENDIF
        stc
        _rdmsr  1004h           ; try to read 486BL3 specific MSR
        jnc     @@done
        stc
        mov     cpu,ibm486bl3
        jmp     @@done
@@done:
        pushf
IFDEF   __32bit__
        mov     cx,oldSelector13
        mov     edx,oldOffset13
        mov     bl,13
        dpmiCall dpmiSetExceptionHnd
ELSE
        mov     cx,oldSelector13
        mov     dx,oldOffset13
        mov     bl,13
        dpmiCall dpmiSetExceptionHnd
ENDIF
        popf
@@done2:
        ret
        endp

; -----------------------------------------------------------------------------
; checkEmulator routine follows

checkEmulator   proc near
; returns CF = 1 if FPU emulator detected, CF = 0 otherwise
; no need to check for 286+ - we're in protected mode and thus at least on 286
IFNDEF    __32bit__
        .286p
ELSE
        .386p
ENDIF
        and     extFlags,not efEmulatedFPU
        cmp     cpu,i80386sx
        jb      @@2
        push    ax
        smsw    ax
        test    al,04           ; simply check fpu emulation bit in MSW
        jz      @@1
        or      extFlags,efEmulatedFPU
@@1:
        pop     ax
@@2:
        ret
        endp

IFNDEF  __32bit__
        .8086
ENDIF

; -----------------------------------------------------------------------------
; getFPUType routine follows
; this routine is just the same as in real mode because it does nothing
; prohibited for V86.

fnstdw  equ     db 0DFh,0E2h    ; i387SL Mobile Store Device Word
                                ; instruction
frinear equ     db 0DFh,0FCh    ; Cyrix/IIT undocumented FRINEAR instruction


getFPUType      proc DIST
IFDEF   __32bit__
LOCAL   fpuDWord : DWORD, fpuTera : TBYTE, fpuEnv : BYTE : 28, fpuWord : WORD
ELSE
LOCAL   fpuDWord : DWORD, fpuTera : TBYTE, fpuEnv : BYTE : 14, fpuWord : WORD
ENDIF
; cpu variable should already have valid CPU code on entry!

        mov     fpu,fpuNone     ; assume no FPU present
        fninit
        clr     cx
        jmp     $+2             ; just to make sure we have enough time for
                                ; FPU to initialize
        mov     _wp fpuWord,5A5Ah
        fnstsw  _wp fpuWord
        mov     ax,_wp fpuWord
        test    al,al
        jnz     @@L161          ; FPU wasn't initialized - no FPU at all
        fnstcw  _wp fpuWord     ; check the control word also
        mov     ax,_wp fpuWord
        and     ax,103Fh
        cmp     ax,3Fh
        jne     @@L161
        mov     fpu,i8087       ; assume 8087
        fstenv  fpuEnv
        and     _wp fpuWord,0FF7Fh
        fldcw   _wp fpuWord
        fdisi
        fstcw   _wp fpuWord
        wait
        test    _wp fpuWord,80h
        jnz     @@L161
IFNDEF  __32bit__
        .286p
        .287
ELSE
        .386p
        .387
ENDIF
        mov     fpu,i80287      ; assume 80287
        fninit                  ; checking if -Inf <> +Inf
        fld1                    ; 287 erroneously claim that they are equal
        fldz
        fdivp   st(1),st
        fld     st
        fchs
        fcompp
        fstsw   _wp fpuWord
        wait
        mov     ax,_wp fpuWord
        sahf
        jz      @@checkIIT      ; -Inf <> +Inf -> 287XL or 387 and up
        mov     fpu,i80387      ; assume 80387
        cmp     cpu,i80286      ; IIT x87's cannot work with CPUs prior to 286
        jb      @@L35           ; so we disable the test on them too.
; check for Intel i387SL Mobile FPU
comment |
        mov     ax,-1
        fninit
        fnstdw                  ; request to store device word into ax
; need to trap invalid opcode here...
        cmp     ax,-1           ; did ax change?
        jz      @@checkIIT
        mov     fpu,i387SLMobile
        jmp     @@restore       ; no other FPU does this, so we can finish
|
@@checkIIT:
        fninit
        fld     fpuDenormal
        fadd    st(0),st        ; IIT will produce zero result while all others
        fnstsw  ax              ; won't
        test    al,02h
        jnz     @@L35           ; not an IIT chip
        cmp     fpu,i80387      ; tested as 80387?
        jz      @@300
        mov     fpu,iit287      ; this is IIT 2C87
        jmp     @@L161
@@300:
        cmp     cpu,i486sx      ; it's a 486?
        jb      @@301
        mov     fpu,iit487      ; assume IIT 4C87
        jmp     @@chkDLC
@@301:
        mov     fpu,iit387      ; this is IIT 3C87
@@chkDLC:
        fninit
        mov     cx,0102h        ; check for 4C87DLC
        mov     ax,cx
        frinear                 ; chaining two FRINEARs on IIT 4C87DLC
        frinear                 ; corrupts AX
        cmp     ax,cx
        jnz     @@3011
        jmp     @@L161
@@3011:
        mov     fpu,iit487DLC
        jmp     @@L161
@@L35:
; checking for Cyrix FPUs
        fninit
        fldpi
        f2xm1
        fstp    fpuDWord
        wait
        cmp     _wp fpuDWord[2],3FC9h
        jne     @@L15
        cmp     cpu,i80286
        ja      @@L351
        mov     fpu,cx287       ; this is Cyrix ?C87
        jmp     @@L15
@@L351:
        cmp     cpu,i486sx
        jb      @@L352
        mov     fpu,cx487
        jmp     @@L15
@@L352:
        mov     fpu,cx387
@@L15:
; testing for ULSI FPUs
        fninit
        fldcw   fpu_53bit_prec
        fld     _tp fpuOp1
        fld1
        faddp   st(1),st
        fstp    fpuTera
        fnstsw  ax
        wait
        test    al,20h
        jnz     @@L16
        cmp     _bp fpuTera,0F8h
        jnz     @@L16
        cmp     _bp fpuTera[9],40h
        jnz     @@L16
        mov     fpu,ulsi387
        cmp     cpu,i486sx
        jb      @@L161
        mov     fpu,ulsi487
        jmp     @@L161
@@L16:
; testing for Cyrix EMC87
        fnstcw  _wp fpuWord
        or      _bp fpuWord[1],80h
        fldcw   _wp fpuWord
        fstcw   _wp fpuWord
        wait
        test    _bp fpuWord[1],80h
        jz      @@L162
        mov     fpu,cxEMC87
        jmp     @@L161
@@L162:
; testing for C&T 38700
        cmp     cpu,i80386sx
        jb      @@L161
        fninit
        fldpi
        f2xm1
        fld1
        fchs
        fldpi
        fscale
        fstp    st(1)
        fcompp
        fstsw   ax
        wait
        sahf
        jnz     @@L161
        mov     fpu,ct387
@@L161:
        cmp     cpu,i80286      ; 286...?
        jnz     @@30
        cmp     fpu,i80387      ; ...and FPU tested as 387...?
        jnz     @@30
        mov     fpu,i80287xl    ; then assume 80287XL - tricky
@@30:
        cmp     cpu,i486sx
        jae     @@302
        cmp     cpu,i80286
        jbe     @@302
        fninit                  ; this test is valid for 386 only
        fbstp   fpuTera
        cmp     _bp fpuTera[7],0C0h
        jnz     @@302
        mov     cpu,RapidCAD
        mov     fpu,rCAD
        jmp     @@restore
@@302:
        cmp     cpu,i486sx      ; i486sx ?
        jb      @@restore       ; we're done
        cmp     cpu,i486dx
        ja      @@31
        jz      @@Internal      ; already know this is 486DX
        cmp     fpu,i80387      ; 387?
        jnz     @@33
        mov     cpu,i486dx      ; assume 486DX or 487SX
@@Internal:
        mov     fpu,fpuInternal ; assume internal FPU
        or      extFlags,efHasFPUonChip
        jmp     @@restore
@@33:
        cmp     cpu,i486dx      ; 486DX with non-Intel FPU???
        jnz     @@31
        dec     cpu             ; then this is i486SX with non-Intel FPU.
        jmp     @@restore
@@31:
        cmp     cpu,Nx586       ; Nx586?
        jnz     @@restore
        cmp     fpu,i80387      ; there's an 386-compatible FPU?
        jnz     @@restore
        mov     fpu,Nx587       ; assume Nx587 - others shouldn't work
@@restore:
        cmp     fpu,fpuNone     ; any 87 present?
        jz      @@fin
        fldenv  fpuEnv          ; yes - restore x87 environment
@@fin:
IFNDEF  __32bit__
        .8086
ENDIF
        call    _np checkEmulator
        ret
        endp

; -----------------------------------------------------------------------------
; getCyrixModel routine follows
; the code provided by Cyrix

read_reg        macro reg
; macro for reading CPU hidden register reg
        pushf
        cli
        mov     al,reg
        out     22h,al
        in      al,23h
        popf
        endm

write_reg       macro reg
; macro for writing a value in AH to CPU hidden register reg
        pushf
        cli
        mov     al,reg
        out     22h,al
        xchg    al,ah
        out     23h,al
        popf
        endm

CCR0    equ     0C0h
CCR2    equ     0C2h
CCR3    equ     0C3h
CCR4    equ     0E8h
DIR0    equ     0FEh
DIR1    equ     0FFh
DIR2    equ     0FCh
DIR3    equ     0FDh

; Uncomment following include to enable Cyrix on 440BX workaround. You will
; also need to uncomment calls to workaround routines in code below as
; indicated.

;INCLUDE PCIP.INC

getCyrixModel   proc    DIST    ; this method provided by Cyrix.

; Following is a call to 440BX chipset workaround. This has NOT been tested,
; uncomment on your own risk! If you do, don't forget to uncomment also
; workaround ending sequence call (just before RET from this routine)!

; ---   440BX workaround code

;LOCAL   PMSR : Word

        push    bx

;        call    _np BX_Cyrix_Workaround_Start
;        mov     PMSR,ax

; ---   conventional routine code follows

        clr     dx      ; dh = t1, dl = t2
        read_reg  CCR2
        mov     bl,al
        xor     al,4    ; flip bit 2 of CCR2
        mov     ah,al
        write_reg CCR2
        read_reg  CCR0  ; dummy read to set up bus
        read_reg  CCR2  ; get CCR2 value
        cmp     al,bl   ; did bit 2 flip?
        jz      @@1
        inc     dh
@@1:
        mov     ah,bl
        write_reg CCR2  ; restore previous CCR2 value

        read_reg  CCR3  ; read CCR3
        mov     bl,al
        xor     al,80h  ; flip bit 7 of CCR3
        write_reg CCR3
        read_reg  CCR0
        read_reg  CCR3
        cmp     bl,al   ; did bit 7 flip?
        jz      @@2
        inc     dl
@@2:
        mov     ah,bl
        write_reg CCR3  ; restore CCR3

        test    dl,dl   ; t2 = 0? -> DIRx not supported
        jz      @@noDIRx
; take additional steps for enabling DIRx access
        read_reg  CCR3  ; get currect CCR3 value
        mov     ah,al
        mov     cl,al   ; save CCR3 state
        and     ah,0Fh
        or      ah,10h  ; set MAPEN = 0001b -> enable DIRx access
        write_reg CCR3

        read_reg  DIR0
        mov     bl,al   ; bl = DIR0
        read_reg  DIR1
        mov     bh,al   ; bh = DIR1
        mov     ah,cl
        write_reg CCR3  ; restore CCR3
        jmp     @@done
@@noDIRx:
        test    dh,dh
        jz      @@unknown
        mov     bx,0EFh ; EF = Cx486S_a
        jmp     @@done
@@unknown:
        clr     bx      ; unknown Cyrix chip
        dec     bl      ; return 0FFh as result
@@done:
        mov     ax,bx

; ---   440BX workaround code

;        push    ax
;        mov     ax,PMSR
;        call    _np BX_Cyrix_Workaround_End
;        pop     ax

; ---   conventional routine code follows
        pop     bx
        ret
        endp

CxCPUIDEnable   proc    DIST
; enables EFLAGS bit 21 and CPUID instruction on Cyrix 5x86 and 6x86 CPUs
; this code does not affect Cx486's in any way

; Following is a call to 440BX chipset workaround. This has NOT been tested,
; uncomment on your own risk! If you do, don't forget to uncomment also
; workaround ending sequence call (just before RET from this routine)!

; ---   440BX workaround code

;LOCAL   PMSR : Word
;        call    _np BX_Cyrix_Workaround_Start
;        mov     PMSR,ax

; ---   conventional routine code follows

        read_reg CCR3
        mov     bl,al   ; save current CCR3 state
        and     al,0Fh
        or      al,10h
        mov     ah,al
        write_reg CCR3  ; MAPEN = 0001b
        read_reg  CCR4  ; read CCR4
        or      al,80h  ; set bit 7 = 1 -> CPUID enabled
        mov     ah,al
        write_reg CCR4  ; set new CCR4 value
        mov     ah,bl
        write_reg CCR3  ; restore CCR3

; ---   440BX workaround code

;        mov     ax,PMSR
;        call    _np BX_Cyrix_Workaround_End

; ---   conventional routine code follows

        ret
        endp

getCPUID      proc    DIST
; this routine is used to retrieve CPUID info at any given level (AMD K6
; support levels 80000000h-80000005h, for example).
ARG Level: DWORD, Result: DWORD
IFDEF __32bit__
USES es, ebx, ecx, edx, edi
ELSE
USES es,di
ENDIF
        .386
        mov     eax,Level
        _cpuid
IFDEF   __32bit__
        mov     edi,[Result]
        push    ds
        pop     es
ELSE
        les     di,[Result]
ENDIF
        stosd
        xchg    eax,ebx
        stosd
        xchg    eax,ecx
        stosd
        xchg    eax,edx
        stosd
        ret
        endp

checkL2Tag      proc near
        test    al,40h
        jnz     @@Yes
        xchg    ah,al
        test    al,40h
        jz      @@No
@@Yes:
        and     al,0Fh
        jmp     @@Q
@@No:
        mov     al,0FFh
@@Q:
        ret
        endp

getL2CacheDesc  proc DIST
        .386
USES    ebx
        clr     eax
        _cpuid
        cmp     al,1
        ja      @@ok
        mov     al,0FFh
        jmp     @@Q
@@ok:
        mov     eax,2
        _cpuid
        call    checkL2Tag
        cmp     al,0FFh
        jnz     @@Q
        shr     eax,16
        call    checkL2Tag
        cmp     al,0FFh
        jnz     @@Q
        mov     eax,ebx
        call    checkL2Tag
        cmp     al,0FFh
        jnz     @@Q
        shr     eax,16
        call    checkL2Tag
        cmp     al,0FFh
        jnz     @@Q
        mov     eax,ecx
        call    checkL2Tag
        cmp     al,0FFh
        jnz     @@Q
        shr     eax,16
        call    checkL2Tag
        cmp     al,0FFh
        jnz     @@Q
        mov     eax,edx
        call    checkL2Tag
        cmp     al,0FFh
        jnz     @@Q
        shr     eax,16
        call    checkL2Tag
@@Q:
        ret
        endp

; -----------------------------------------------------------------
; that's all, folks!

        END
