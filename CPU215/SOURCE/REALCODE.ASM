; ----------------------------------------------------------------------------
; REALCODE.ASM - Real Mode Code for TMi0SDGL 2                    Version 2.15
;
; Too-Much-in-0ne-So-Don't-Get-Lost(tm) Revision 2 CPU/FPU Detection Library
; Copyright(c) 1996-2000 by B-coolWare. Written by Bobby Z.
; ----------------------------------------------------------------------------
; This file contains low-level routines used in TMi0SDGL 2.
;
; global vars/procs/includes section -----------------------------------------
;
        INCLUDE HEADER.ASH

;__debug__       = 1

        PUBLIC  getCPUType              ; returns CPU index
        PUBLIC  getFPUType              ; returns FPU index
        PUBLIC  getCyrixModel           ; returns Cx486 model index
        PUBLIC  CxCPUIDEnable           ; enables CPUID on Cyrix 5x86
                                        ; and 6x86
        PUBLIC  getL2CacheDesc          ; returns L2 cache descriptor for
                                        ; Pentium Pro and Pentium II
        PUBLIC  getCPUID                ; get CPUID values for specified lvl
        PUBLIC  isV86                   ; returns True if in V86 mode, False
                                        ; otherwise
;        PUBLIC  checkEMM386             ; detect if M$ EMM386 is present

;
; code section ---------------------------------------------------------------
;

IFDEF   __debug__
printDebug      proc near
        push    ax
        mov     ah,09h
        int     21h
        pop     ax
        ret
        endp

        .DATA

CyrixMsg  db      'Checking for Cyrix...',13,10,'$'
x86SLMsg  db      'Checking for x86SL...',13,10,'$'
MSRsMsg   db      'Checking for IBM MSRS...',13,10,'$'
BIOSMsg   db      'Checking for BIOS Extensions...',13,10,'$'
CPUIDMsg  db      'Checking for CPUID...',13,10,'$'
CxCPUID   db      'Enabling CPUID on Cyrix...',13,10,'$'
BXWAS     db      'Entering Cyrix-on-440BX workaround...',13,10,'$'
BXWAE     db      'Leaving Cyrix-on-440BX workaround...',13,10,'$'

        .CODE
ENDIF

getCPUType      proc    DIST
;
; here's where all the low-level work done
;
        mov     cpu,i8088       ; assume 8088
        call    _np check80286
        jc      @@18x           ; not a 286+ - continue with 8x/18x/NEC
        mov     cpu,i80286
        call    _np check386
        jc      @@Q             ; a 286 - stop
        mov     cpu,i80386sx

@@chkCT386:
        call    _np checkCT38600
        jc      @@386clones     ; AMD/Intel 386 POPAD bug detected - no need
                                ; to check for 486+...
        mov     cpu,ct38600

@@chk486:
        call    _np check486
        jc      @@386clones     ; not a 486+ - check for other 386 clones
        mov     cpu,i486sx

@@cyrix:
        call    checkCyrix      ; check if running on Cyrix CPU
        jc      @@checkCPUID
        mov     cpu,Cx486       ; assume Cx486
;       call    CxCPUIDEnable   ; enable CPUID on Cx5x86 and 6x86, it's
                                ; disabled by default. This is a bit dangerous
                                ; but should not affect Cx486's
        jmp     @@checkCPUID    ; try override this detection with CPUID

        .386
@@checkCPUID:
IFDEF   __debug__
        push    dx
        lea     dx, CPUIDMsg
        call    printDebug
        pop     dx
ENDIF
        pushfd                  ; check if CPUID instruction is supported
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
        jz      @@noCPUID            ; the bit was not flipped - no CPUID
        or      extFlags,efCPUIDSupport
        mov     eax,0C0000000h
        _cpuid
        cmp     eax,0C0000000h
        jnz     @@notIDT
        or      extFlags,efCentaurLevel ; this CPUID level only supported
                                        ; by Centaur's WinChip
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
        mov     cpuBrand,ebx
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
        and     ax,0F00h        ; map out CPU family field
        cmp     ah,4            ; family is 4 - 486?
        jz      @@Q
        mov     cpu,iPentium
        cmp     ah,5            ; family is 5 - pentium?
        jz      @@Q
        mov     cpu,iPentiumPro
        cmp     ah,6            ; family is 6 - pentium pro?
        jz      @@Q
        mov     cpu,iP7
        cmp     ah,7
        jz      @@Q
        mov     cpu,iP8
        jmp     @@Q
@@18x:
        call    _np check8018x     ; check for shift counter wrap
        jc      @@2
        mov     cpu,i80188
        jmp     @@2_buf
@@2:
        call    _np checkNEC       ; check for true 808x rep es: lodsb bug
        jc      @@2_buf
        mov     cpu,necV20
        ; this can be NEC or Intel CMOS-tech CPU, continue testing
        call    _np check80C8x     ; check for AAD 16 undocumented opcode
        jc      @@2_buf
        mov     cpu,i80c88

@@2_buf:
        call    _np checkQueueSize ; detect CPU prefetch queue size to
        jcxz    @@Q                ; distinguish 88 from 86
        inc     cpu
        jmp     @@Q

@@386clones:
        call    _np checkAm386
        jc      @@chkNexGen
        ;mov     cpu,am386sx       ; This test is not foolproof, so just
        mov     cpu,i80386sx       ; assume Intel part
        jmp     @@386sx

@@chkNexGen:
        call    _np checkNexGen
        jc      @@tryBIOS
        mov     cpu,Nx586
        jmp     @@Q

@@tryBIOS:
        call    _np check_byBIOS  ; this routine will update cpu by itself
        jnc     @@Q               ; and make terminal decision

@@386SL:
        mov     dh,3            ; check for 386SL
        call    _np check_x86SL
        jc      @@tryMSRs
        mov     cpu,i386sl      ; 386SL - stop
        jmp     @@Q

@@tryMSRs:
        call    _np checkIBMmsrs  ; this routine will update cpu by itself
        jc      @@Q               ; unlike others, this routine sets CF on
                                  ; successful detect
@@386sx:
        call    _np check386sx    ; distinguish SX/DX
        jc      @@Q
        inc     cpu
        jmp     @@Q

@@noCPUID:
        cmp     cpu,Cx486
        jz      @@Q

        call    _np check_byBIOS  ; this routine will update cpu by itself
        jnc     @@Q               ; and make terminal decision

@@486SL:
        mov     dh,4
        call    check_x86SL
        jc      @@MSRs3
        mov     cpu,i486SL

@@MSRs3:
        call    checkIBMmsrs3     ; unlike others, this routine sets CF on
        jc      @@Q               ; successful detect

@@486sx:
        call    check486sx
        jc      @@Q
        cmp     cpu,am486
        jnz     @@1
        mov     cpu,am486dx
        jmp     @@Q
@@1:
        inc     cpu
@@Q:
        ret
        endp

        .8086

        db      13,10
        db      'TMi0SDGL Revision 2 CPU/FPU Detection Library  Version 2.15',13,10
        db      'Copyright(c) 1996-2000 by B-coolWare.   Written by Bobby Z.',13,10
        db      13,10
        db      'Simply the best...',13,10

checkQueueSize:
; tests prefetch queue size on 88, 86, C88, C86, 188, 186, V20 and V30
; returns cx = 0 -> x88, cx = 1 -> x86
        push    es di
        mov     _bp cs:[@@0],41h        ; to make this routine reentrant
        std
        push    cs
        pop     es
        ldi     @@2
        mov     al,_bp cs:[@@1]
        mov     cx,3
        cli
        rep     stosb
        cld             ; 1
        nop             ; 2
        nop             ; 3
        nop             ; 4     <- 80x88 will cut here and inc cx instruction
@@0:    inc     cx      ; 5        will be overwritten by sti, else we'll get
@@1:                    ;          cx = 1, which indicates 80x86
        sti             ; 6
@@2:
        sti
        pop     di es
        retn
        endp

; -------------------------------

check80286:
; check for 286+
        push    sp
        pop     ax
        cmp     ax,sp           ; push sp == {sp-=2, [sp]=sp} on < 80286
        jnz     Nope            ; push sp == {[sp-2]=sp, sp-=2} on 80286+
Yes:
        clc
        retn
Nope:
        stc
        retn

; -------------------------------

check8018x:
; check for 8018x
        mov     cl,33
        clr     ax
        dec     ax
        shl     ax,cl
        jnz     Yes             ; 8018x chips shift only (cl mod 32) bits
        jmp     Nope

; -------------------------------

checkNEC:
; check for NEC V20/V30
        sti
        mov     cx,0ffffh       ; test if following instruction will be
                                ; repeated for the full iteration
        db      0F3h,26h,0ACh   ; rep es: lodsb
        jcxz    Yes             ; intel non-CMOS chips don't resume this
        jmp     Nope            ; after interrupt, but NEC and
                                ; CMOS-tech ones does.

; -------------------------------

check80C8x:
; derived from code provided by Alex Bachin
        mov     ax,0102h
        db      0D5h,10h        ; AAD 16 opcode - intel only, undocumented
        cmp     al,12h          ; did it work?
        jnz     Nope            ; nope - probably a NEC chip
        jmp     Yes

; -------------------------------

check386:
; check for 386+, technique is blessed by Intel
        mov     ax,7000h
        pushf
        push    ax
        popf
        pushf
        pop     ax
        popf
        and     ah,70h          ; check for flags - only 386+ has them
        jz      Nope            ; if ah=0 than this is 286
        jmp     Yes


check_byBIOS:
IFDEF   __debug__
        push    dx
        lea     dx, BIOSMsg
        call    printDebug
        pop     dx
ENDIF
        mov     ax,0C910h       ; PS/2 and some other BIOSes CPUID call
        int     15h
        jc      Nope            ; call not supported
        cmp     ch,04
        jz      @@a486
        cmp     ch,33h
        jz      @@i376
        cmp     ch,43h
        jz      @@i386SL
        cmp     ch,0A3h
        jz      @@ibm386SL
        cmp     ch,0A4h
        jz      @@ibm486SLC
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
        test    cl,0F0h         ; 1,2 and 3 models are SLC2 and 0 is SLC
        jnz     @@ibm486SLC2
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


; -------------------------------

check_x86SL:
IFDEF   __debug__
        push    dx
        lea     dx, x86SLMsg
        call    printDebug
        pop     dx
ENDIF

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

; -------------------------------

checkAm386:
; this routine was checked by Vasiliy Sorokin. It uses UMOV
; instruction present in Am386 chips but not found in other x86s.
        call    checkCyrix      ; don't check on Cyrix/UMC chips
        jnc     Nope
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
        jnz     Nope            ; the bit was flipped - CPUID supported
        pusha
        push    ds es
        mov     ax,3506h
        int     21h
        push    es bx
        mov     ax,2506h
        ldx     @@Int06
        push    cs
        pop     ds
        int     21h
        mov     dl,[bx+si]
        db      0Fh
        adc     al,cl
        add     [bx+si],al
; we get here only if UMOV succeed
        mov     [bx+si],dl
        pop     dx ds
        mov     ax,2506h
        int     21h
        pop     es ds
        popa
        jmp     Yes
@@Int06:
        add     sp,4    ; clear the fault address from stack
        popf
        mov     [bx+si],dl
        pop     dx ds
        mov     ax,2506h
        int     21h
        pop     es ds
        popa
        jmp     Nope

; -------------------------------

checkCT38600:
; check for C&T 38600
        mov     esi,32          ; give it 32 tries
        mov     eax,12345678h   ; load a value
        mov     ebx,eax         ; save it for reference
        sub     edx,edx         ; set edx+edi to point to DS:0
        sub     edi,edi
@@ct_loop:
        pushad                  ; push all registers
        popad                   ; pop all registers
        mov     ecx,[edx+edi]   ; and do a memory access
        cmp     eax,ebx         ; did eax changed?
        jnz     Nope            ; YES! this is an Intel/AMD 386 - they have
        dec     esi             ; POPAD bug: mem access after popad changes
        jnz     @@ct_loop       ; eax contents
        jmp     Yes             ; all 32 tries passed - should be C&T38600

; -------------------------------

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

; -------------------------------

        .386p

check386sx:
; check for SX version
        mov     eax,cr0
        mov     ecx,eax
        xor     eax,MSW_ET      ; flipping ET bit
        mov     cr0,eax
        mov     eax,cr0
        mov     cr0,ecx         ; restoring previous value of CR0
        xor     eax,ecx         ; did it flip ok?
        jz      Nope            ; SX chips do not allow to change bus width
        jmp     Yes

; -------------------------------

        .8087
check486sx:
; check for SX version
        mov     eax,cr0
        mov     ecx,eax
        xor     eax,MSW_NE      ; flipping NE bit
        mov     cr0,eax
        mov     eax,cr0
        mov     cr0,ecx         ; restoring previous value of CR0
        xor     eax,ecx         ; did it flip ok?
        jnz     Yes             ; SX chips do not allow to change NE bit
                                ; but some SX'es pass this test as DXes...

        mov     _wp fpuWord,5A5Ah   ; ... so we'll do some more tests
        fninit
        fnstcw  _wp fpuWord
        mov     ax,fpuWord
        test    al,al
        jnz     Nope
        jmp     Yes

; -------------------------------

checkIBMmsrs:
IFDEF   __debug__
        push    dx
        lea     dx, MSRsMsg
        call    printDebug
        pop     dx
ENDIF

; the following three checkIBMmsrsX routines attempt to read IBM-specific
; MSRs #1000, #1002 and #1004. Because RDMSR with invalid index will cause
; exception 13 and rdmsr itself may cause exception 6 on CPU that do not
; support it, we should be able to intercept both exceptions, thus the code
; should run either in real mode or on CPL0.
        smsw    ax
        test    al,1            ; we can only do this nasty code in real mode...
        jnz     @@Qs1
        push    ds
        mov     ax,350Dh
        int     21h
        push    es
        push    bx
        push    cs
        pop     ds
        ldx     @@trap06
        mov     ax,250Dh        ; intercept GPF exception
        int     21h
        mov     ax,3506h
        int     21h
        push    es
        push    bx
        ldx     @@trap06
        mov     ax,2506h        ; and Invalid Instruction exception
        int     21h
        _rdmsr  1000h
                                ; We'll get Exception 13 if this MSR is not
        stc                     ; valid or Exception 06 if this is not IBM386.
        mov     cpu,ibm386slc   ; IBM 386SLC
        jmp     @@Qs
@@trap06:                       ; similar action is taken on both exceptions,
        add     sp,4            ; so we don't need to setup different handlers
        popf                    ; for each exception.
        clc
@@Qs:
        pop     dx
        pop     ds
        pushf
        mov     ax,2506h
        int     21h
        popf
        pop     dx
        pop     ds
        pushf
        mov     ax,250Dh
        int     21h
        popf
        pop     ds
@@Qs1:
        ret
        endp

; -------------------------------

checkIBMmsrs2:
        call    _np checkIBMmsrs ; first check if this is IBM 486SLC chip
        jnc     @@Qi
        push    ds
        mov     ax,350Dh        ; we don't need to intercept Exception #6 here,
        int     21h             ; for it is proved that RDMSR instruction is
        push    es              ; valid for current CPU. But the register we're
        push    bx              ; trying to read may be invalid...
        push    cs
        pop     ds
        ldx     @@trap0D2
        mov     ax,250Dh
        int     21h
        _rdmsr  1002h           ; try to read 486SLC2 specific MSR
        mov     cpu,ibm486slc2  ; IBM 486SLC2
        jmp     @@Qi2
@@trap0D2:
        add     sp,4
        popf
        stc
        mov     cpu,ibm486slc   ; IBM 486SLC
@@Qi2:
        pop     dx
        pop     ds
        pushf
        mov     ax,250Dh
        int     21h
        popf
@@Qi:
        ret
        endp

; -------------------------------

checkIBMmsrs3:
        call    _np checkIBMmsrs2
        jnc     @@Qi4
        push    ds
        mov     ax,350Dh        ; we don't need to intercept Exception #6 here,
        int     21h             ; for it is proved that RDMSR instruction is
        push    es              ; valid for current CPU. But the register we're
        push    bx              ; trying to read may be invalid...
        push    cs
        pop     ds
        ldx     @@trap0D3
        mov     ax,250Dh
        int     21h
        _rdmsr  1004h           ; try to read 486BL3 specific MSR
        mov     cpu,ibm486bl3
        jmp     @@Qi3
@@trap0D3:
        add     sp,4
        popf
        stc
@@Qi3:
        pop     dx
        pop     ds
        pushf
        mov     ax,250Dh
        int     21h
        popf
@@Qi4:
        ret
        endp

; -------------------------------

checkCyrix:                     ; this code provided by Cyrix Corp.
IFDEF   __debug__
        push    dx
        lea     dx, CyrixMsg
        call    printDebug
        pop     dx
ENDIF
        clr     ax
        sahf                    ; load flags, bit 1 always = 1
        mov     ax,5
        mov     bx,2
        div     bl              ; do an operation that does not change flags
        lahf                    ; get flags
        cmp     ah,2            ; did flags changed?
        jne     Nope            ; yes, they did - not a Cyrix CPU
        jmp     Yes             ; didn't - Cyrix CPU

; -------------------------------

checkNexGen:                    ; this code provided by NexGen Corp.
        mov     ax,5555h
        xor     dx,dx
        mov     cx,2
        div     cx
        jnz     Nope            ; Nx586 doesn't change ZF on division while
        jmp     Yes             ; others do

; ----------------------------------------------------------------------------
; checkWeitek routine follows

checkWeitek     proc near
; check for Weitek coprocessor presence, just checking if BIOS feature flag
; for Weitek FPU is set.
        cmp     cpu,i80386sx
        jb      @@1
        .386
        clr     eax
        int     11h
        test    eax,1000000h
        .8086
        jz      @@1
        or      extFlags,efWeitekPresent        ; Weitek FPU present
        jmp     @@2
@@1:
        and     extFlags,not efWeitekPresent
@@2:
        ret
        endp

; ----------------------------------------------------------------------------
; checkEmulator routine follows

checkEmulator   proc near
; returns CF = 1 if FPU emulator detected, CF = 0 otherwise
        and     extFlags,not efEmulatedFPU    ; assume no emulator
        cmp     cpu,i80386sx   ; check for 386+ to assure that FPU emulation is
        jb      @@2            ; possible, avoid check if not 386 or higher.
        .286p
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

        .8086

; ----------------------------------------------------------------------------
; getFPUType routine follows

fnstdw  equ     db 0DFh,0E1h    ; i387SL Mobile Store Device Word
                                ; instruction
frinear equ     db 0DFh,0FCh    ; Cyrix/IIT undocumented FRINEAR instruction


getFPUType      proc    DIST
LOCAL   fpuDWord : DWORD, fpuTera : TBYTE, fpuEnv : BYTE : 14, fpuWord : WORD

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
        .286p
        .287
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
comment |
; check for Intel i387SL Mobile
; install invalid opcode trap handler
        push    bx dx ds es
        mov     ax,3506h
        int     21h
        push    es bx
        mov     ax,2506h
        ldx     @@trap06
        push    cs
        pop     ds
        int     21h
        mov     ax,-1
        fninit
        fnstdw                  ; request to store device word into ax
; if we get at this point it should be 387SL
        mov     bx,ax           ; save ax contents
        pop     dx ds           ; deinstall trap handler
        mov     ax,2506h
        int     21h
        pop     es ds dx bx
        cmp     bx,-1           ; did ax change?
        jz      @@checkIIT
        mov     fpu,i387SLMobile
        jmp     @@restore       ; no other FPU does this, so we can finish
@@trap06:
        add     sp,4            ; just deinstall handler and continue
        popf
        pop     dx ds
        mov     ax,2506h
        int     21h
        pop     es ds dx bx
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
        fninit                  ; check for 4C87DLC
        mov     cx,0102h
        mov     ax,cx
        frinear                 ; undocumented Cyrix FRINEAR instruction
        frinear                 ; chaining two FRINEARs on IIT 4C87DLC
        cmp     ax,cx           ; corrupts AX
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
        jne     @@L15           ; Cyrix FPUs are known to return this value
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
        cmp     _bp fpuTera[7],0C0h     ; RapidCAD stores C0, 387 - 80
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
        .8086
        call    _np checkWeitek  ; check for Weitek FPU presense
        call    _np checkEmulator; check for FPU emulation
        ret
        endp

; ----------------------------------------------------------------------------
; isV86 routine follows
;

isV86   proc    DIST
        .286p
        smsw    ax
        and     al,1    ; bit 1 is set if in Protected Mode, in DOS this
                        ; automatically means V86...
        ret
        endp

; ----------------------------------------------------------------------------
; getCyrixModel routine follows
; method provided by Cyrix


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
DIR2    equ     0FCh    ; these two DIRs exist on the latest Cyrix chips,
DIR3    equ     0FDh    ; but their purpose is not documented.


INCLUDE PCI.INC


getCyrixModel   proc    DIST    ; this method provided by Cyrix.
LOCAL   PMSR : Word
        call    BX_Cyrix_Workaround_Start
        mov     PMSR,ax

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
        push    ax
        mov     ax,PMSR
        call    BX_Cyrix_Workaround_End
        pop     ax
        ret
        endp

; -------------------------------
; CxCPUIDEnable routine follows

CxCPUIDEnable   proc    DIST
; enables EFLAGS bit 21 and CPUID instruction on Cyrix 5x86 and 6x86 CPUs
; this code does not affect Cx486's in any way
LOCAL   PMSR : Word
IFDEF   __debug__
        push    dx
        lea     dx, CxCPUID
        call    printDebug
        pop     dx
ENDIF
        call    BX_Cyrix_Workaround_Start
        mov     PMSR,ax

        read_reg CCR3
        mov     bl,al   ; save current CCR3 state
        and     al,0Fh
        or      al,10h
        mov     ah,al
        write_reg CCR3  ; MAPEN = 0001b
        read_reg  CCR4   ; read CCR4
        or      al,80h  ; set bit 7 = 1 -> CPUID enabled
        mov     ah,al
        write_reg CCR4  ; set new CCR4 value
        mov     ah,bl
        write_reg CCR3  ; restore CCR3

        mov     ax,PMSR
        call    BX_Cyrix_Workaround_End
        ret
        endp

; -------------------------------
; getCPUID routine follows

        .386
getCPUID      proc    DIST
; support routine to get CPUID extended info at specified level, used for
; AMD K6 extended information display. Cache info on Pentium Pro and K6 can
; also be retrieved using this routine with Level == 2.
ARG Level: DWORD, Result: DWORD
USES es, di
        mov     eax,Level
        _cpuid
        les     di,[Result]
        stosd
        xchg    eax,ebx
        stosd
        xchg    eax,ecx
        stosd
        xchg    eax,edx
        stosd
        ret
        endp

; -------------------------------

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

; -------------------------------

getL2CacheDesc  proc DIST
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

COMMENT |
checkEMM386     proc DIST
        mov     ax,0FFA5h
        int     67h
        clr     al
        cmp     ah,84h
        jnz     @@Nope
        inc     al
@@Nope:
        clr     ah
        ret
        endp
|       ; end COMMENT

; -----------------------------------------------------------------
; that's all, folks!

        END




