; Cyrix detection on 440BX chipset workaround code - protected mode


        .386

int1Ah  proc near
; uses DPMI Simulate Real Mode Interrupt service to call INT 1Ah
LOCAL   r: dpmiCallStruc
        mov     r.dc_eax,eax
        mov     r.dc_ebx,ebx
        mov     r.dc_ecx,ecx
        mov     r.dc_edx,edx
        mov     r.dc_edi,edi
        mov     r.dc_esi,esi
        pushf
        pop     ax
        mov     r.dc_flg,ax

        mov     bx,68      ; 1088 bytes
        dpmiCall dpmiAllocDOSBlock
        mov     r.dc_ss,ax
        mov     r.dc_sp,1088 ; provide our own stack for this call because
                             ; it can use up to 1024 bytes of stack and
                             ; RM stack provided by DPMI host is rather
                             ; small (about 30 words)
        push    ss
        pop     es

IFDEF   __32bit__
        lea     edi,r
ELSE
        lea     di,r
ENDIF

        mov     r.dc_cs,0    ; these doesn't matter because we call an ISR
        mov     r.dc_ip,0

        mov     bx,1Ah
        clr     cx
        push    dx         ; save RM stack selector (just in case...)

        dpmiCall dpmiSimulateRMInt

        pop     dx
        dpmiCall dpmiFreeDOSBlock       ; free RM stack block

IFDEF   __32bit__
        mov     ax,es:r[edi].dc_flg
        push    ax
        popf
        mov     eax,es:r[edi].dc_eax
        mov     ebx,es:r[edi].dc_ebx
        mov     ecx,es:r[edi].dc_ecx
        mov     edx,es:r[edi].dc_edx
        mov     esi,es:r[edi].dc_esi
        mov     edi.es:r[edi].dc_edi
ELSE
        mov     ax,es:r[di].dc_flg
        push    ax
        popf
        mov     eax,es:r[di].dc_eax
        mov     ebx,es:r[di].dc_ebx
        mov     ecx,es:r[di].dc_ecx
        mov     edx,es:r[di].dc_edx
        mov     esi,es:r[di].dc_esi
        mov     edi,es:r[di].dc_edi
ENDIF
        ret
        endp


BX_Cyrix_Workaround_Start       proc near
LOCAL   dev : Word
        mov     ax,0B101h
        clr     edi
        call    int1Ah
        test    ah,ah
        jnz     @@noPCI
        mov     ax,0B102h       ; find PCI device
        mov     cx,7190h        ; 82443BX id #1
        mov     dx,8086h        ; Intel
        clr     si              ; device 0
        call    int1Ah
        jnc     @@Configure
        mov     ax,0B102h       ; find PCI device
        mov     cx,7192h        ; 82443BX id #2 (only one of these may present)
        mov     dx,8086h        ; Intel
        clr     si              ; device 0
        call    int1Ah
        jc      @@noPCI
@@Configure:
        mov     dev,bx          ; save bus/device/function
        mov     ax,0B108h       ; read configuration byte
        mov     di,7Ah          ; PMSR register
        call    int1Ah
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
        mov     di,7Ah
        call    int1Ah
        pop     ax
        jmp     @@Q
@@noPCI:
        clr     ax
@@Q:
        ret
        endp

BX_Cyrix_Workaround_End         proc near
LOCAL   PMSR : Byte
        test    ah,ah
        jz      @@Q
        mov     PMSR,al
        mov     ax,0B102h
        mov     cx,7190h        ; 82443BX id #1
        mov     dx,8086h        ; Intel
        clr     si              ; device 0
        call    int1Ah
        jnc     @@Configure
        mov     ax,0B102h       ; find PCI device
        mov     cx,7192h        ; 82443BX id #2 (only one of these may present)
        mov     dx,8086h        ; Intel
        clr     si              ; device 0
        call    int1Ah
        jc      @@Q
@@Configure:
        mov     ax,0B10Bh       ; restore configuration
                                ; bx already has bus/device/function
        mov     cl,PMSR
        mov     di,7Ah
        call    int1Ah
@@Q:
        ret
        endp
