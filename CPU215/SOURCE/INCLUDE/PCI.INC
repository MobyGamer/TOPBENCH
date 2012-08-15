; Cyrix detection on 440BX chipset workaround code
; uses PCI BIOS 2.0c+ calls to detect 440BX and apply workaround if found

BX_Cyrix_Workaround_Start       proc near
LOCAL   dev : Word
        .386
IFDEF   __debug__
        push    dx
        lea     dx, BXWAS
        call    printDebug
        pop     dx
ENDIF
        mov     ax,0B101h       ; get PCI BIOS version
        clr     edi
        int     1Ah
        test    ah,ah           ; ah is set to 0 if PCI BIOS present
        jnz     @@noPCI
        mov     ax,0B102h       ; find PCI device
        mov     cx,7190h        ; 82443BX id #1
        mov     dx,8086h        ; Intel
        clr     si              ; device 0
        int     1Ah
        jnc     @@Configure
        mov     ax,0B102h       ; find PCI device
        mov     cx,7192h        ; 82443BX id #2 (only one of these may present)
        mov     dx,8086h        ; Intel
        clr     si              ; device 0
        int     1Ah
        jc      @@noPCI
@@Configure:
        mov     dev,bx          ; save bus/device/function
        mov     ax,0B108h       ; read configuration byte
        mov     di,7Ah          ; PMSR index in configuration space
        int     1Ah
        jc      @@noPCI         ; error occured
        test    cl,40h          ; bit 6 set?
        jz      @@noPCI         ; not set, no need to reprogram
        mov     al,cl
        mov     ah,1            ; data read ok
        push    ax
        and     cl, (not 40h)   ; reset bit 6 of PMSR
                                ; I/O port 22h data forwarded to PCI bus
        mov     bx,dev
        mov     ax,0B10Bh       ; write configuration byte
        mov     di,7Ah          ; PMSR index in configuration space
        int     1Ah
        pop     ax              ; ah set to 1 if data read from 440BX
                                ; al then contains original PMSR state
        jmp     @@Q
@@noPCI:
        clr     ax
@@Q:
        ret
        endp

BX_Cyrix_Workaround_End         proc near
LOCAL   PMSR : Byte
IFDEF   __debug__
        push    dx
        lea     dx, BXWAE
        call    printDebug
        pop     dx
ENDIF
        test    ah,ah           ; on entry ah = 0|1, al = PMSR if ah = 1
        jz      @@Q
        mov     PMSR,al
        mov     ax,0B102h
        mov     cx,7190h        ; 82443BX id #1
        mov     dx,8086h        ; Intel
        clr     si              ; device 0
        int     1Ah
        jnc     @@Configure
        mov     ax,0B102h       ; find PCI device
        mov     cx,7192h        ; 82443BX id #2 (only one of these may present)
        mov     dx,8086h        ; Intel
        clr     si              ; device 0
        int     1Ah
        jc      @@Q
@@Configure:
        mov     ax,0B10Bh       ; restore configuration
                                ; bx already has bus/device/function
        mov     cl,PMSR
        mov     di,7Ah          ; PMSR index in configuration space
        int     1Ah
@@Q:
        ret
        endp
