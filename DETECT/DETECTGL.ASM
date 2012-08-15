;--------------------------------------------------------------------
;
;       DETECTGL.ASM
;
;       Assembler-File
;
;
;               MISC            - Verschiedene Routinen
;               DISKREAD        - reads absolute sectors from disk
;               ATIINFO         - for accessing ATI VGAWonder cards
;               ALTINTR         - calls interrupts with a true INT call
;               ALTMSDOS        - calls DOS with a true INT call
;               TSENGCK         - Tseng VGA check
;               ZYMOSCK         - ZyMOS VGA check
;               POPADBUGTST     - Test fÅr den 386 POPAD Bug
;               MULBUGTST       - Test fÅr alten 386 Multiplikations-fehler
;               FDIVBUGTST      - Test fÅr den FDIV-Bug im Pentium
;               SPEEDTEST       - Verschiedene Tests
;               TESTCACHE       - Cache-Test
;               TESTCACH286     - " auf 286'ern
;               APPLE87         - FÅr die Peak-MFLOPS
;               MUL_M4X4        - FÅr die Transformation MFLOPS
;               IIT_MUL_M4X4    - FÅr die Transformation MFLOPS (IIT)
;               TESTFOREFLAG21  - Testet ab, ob CPUID vorhanden ist ...
;               MSRREADER       - Zum Auslesen der MSR's
;
;       Original der ersten 8 Funktionen von:
;       Steve Grant
;       Long Beach, CA
;       13. Januar 1989
;
;--------------------------------------------------------------------
; Assemblieren mit :
;   TASM DETECTGL.ASM

; Die CPU-Erkennungsroutinen basieren auf denen aus Norbert Juffa's CompTest.
; Sie wurden aber an vielen Stellen vîllig umgeschrieben und ergÑnzt.
; An diese Datei ist die Assembler-Datei aus CTest eingebunden. (CacheTest)
; Die Transformation und Peak MFlops kommen aus Norbert Juffa's Koprozessor-
; beschreibung 1.5
; Diese Datei selber kommt aus Infoplus, es wurden aber nur 6 Funktionsnamen,
; der Header und ca. 200 Zeilen Code Åbernommen.

PAGE ,120

.286P
.8087

        public  MISC, DISKREAD, ATIINFO, ALTINTR, ALTMSDOS
        public  TSENGCK, ZYMOSCK, POPADBUGTST, APPLE87, MUL_4x4
        public  IIT_MUL_4x4, MULBUGTST, FDIVBUGTST,  SPEEDTEST1
        public  TESTCACHE, TESTCACH286, CPURESET, TESTFOREFLAG21
        public  MSRREADER


JMPS        EQU     <JMP SHORT>          ; declare jumps as short
JES         EQU     <JE  SHORT>          ;  since near jumps (+/- 32K)
JBS         EQU     <JB  SHORT>          ;   are default in 386 mode
JNZS        EQU     <JNZ SHORT>          ;    and these cannot execute
JCS         EQU     <JC  SHORT>          ;     on the older CPUs
JZS         EQU     <JZ  SHORT>
JNES        EQU     <JNE SHORT>
JAES        EQU     <JAE SHORT>
JBES        EQU     <JBE SHORT>
JAS         EQU     <JA  SHORT>
RDTSC       equ     db 0Fh, 31h
RDMSR       equ     db 0Fh, 32h
RDPMC       equ     db 0Fh, 33h

cpu_i8088     EQU     1
cpu_i8086     EQU     2
cpu_i80C88    EQU     3
cpu_i80C86    EQU     4
cpu_V20       EQU     5
cpu_V30       EQU     6
cpu_i188      EQU     7
cpu_i186      EQU     8
cpu_i286      EQU     9
cpu_i386      EQU     10
cpu_i386sx    EQU     11
cpu_ct38600   EQU     12
cpu_ct38600sx EQU     13
cpu_486dlc    EQU     14
cpu_486slc    EQU     15
cpu_RapidCAD  EQU     16
cpu_i486      EQU     17
cpu_i486SX    EQU     18
cpu_pentium   EQU     19
cpu_NexGen    EQU     20
cpu_Cyrix     EQU     21

ndp_NoCopro EQU     0
ndp_Emul    EQU     1
ndp_i8087   EQU     2
ndp_i80C187 EQU     3
ndp_i80287  EQU     4
ndp_i287XL  EQU     5
ndp_i387    EQU     6
ndp_i387sx  EQU     7
ndp_2C87    EQU     8
ndp_3C87    EQU    10
ndp_3C87sx  EQU    11
ndp_82S87   EQU    12
ndp_83D87   EQU    14
ndp_83S87   EQU    15
ndp_83C87   EQU    16
ndp_83C87s  EQU    17
ndp_38700   EQU    18
ndp_38700sx EQU    19
ndp_i387DX  EQU    20
ndp_RapidCAD EQU   21
ndp_i486    EQU    22
ndp_82S87p  EQU    23
ndp_387plus EQU    25
ndp_83S87p  EQU    26
ndp_emc87   EQU    27
ndp_pentium EQU    28


STRT_TIM    MACRO
            MOV     AL, 0B4h             ; timer 2 is
            OUT     43h, AL              ;  programmed as a rate generator
            XOR     AL, AL               ; load zero
            OUT     42h, AL              ; reset
            OUT     42h, AL              ;  timer 2
            ENDM

STOP_TIM    MACRO
            MOV     AL, 80h              ; timer 2
            OUT     43h, AL              ;  immediately latched
            IN      AL, 42h              ; read LSB
            MOV     BL, AL               ; save LSB
            IN      AL, 42h              ; read MSB
            MOV     BH, AL               ; save MSB
            NEG     BX                   ; negate for timer count
            ENDM

CODE    segment byte use16 public 'CODE'

assume CS:Code


;    Wo es mîglich war wurden Short-Jumps benutzt, um den assemblierten
;    Code mîglichst gering zu halten.
;    Fast alle Routinen sind Englisch kommentiert. Wenn ich einige
;    Funktionen geÑndert habe und die Kommentierungen dabei abÑnderte,
;    sind diese in Deutsch (keine Lust zum Åbersetzen)

;--------------------------------------------------------------------

MISC  proc    far

assume  cs:CODE, ds:DATA, es:nothing, ss:nothing

;       On entry:
;
;               BP
;       SP =>   near return address
;               offset  of a cpu_info_t record
;               segment "  "     "        "
;
;       Im TestByte sollte ein 'W' fÅr Weitek stehen,
;                          ein 'T' fÅr IDT, GDT und MSW
;                          ein 'N' fÅr Koprozessorroutinen
;
;       On exit, the cpu_info_t record has been filled in as follows:
;
;               word    = Machine Status Word
;               6 bytes = Global Descriptor Table
;               6 bytes = Interrupt Descriptor Table
;               boolean = segment register change/interrupt flag
;               word    = NDP control word
;               byte    = Weitek presence
;               byte    = test type (C, N, or W)

cpu_info        equ     [bp + 6]

mMSW    equ     word ptr [bx]
mGDT    equ     [bx + 2]
mIDT    equ     [bx + 8]
mchkint equ     byte ptr [bx + 14]
mNDPCW  equ     word ptr [bx + 15]
mWeitek equ     byte ptr [bx + 17]
mtest   equ     byte ptr [bx + 18]

false   equ     0
true    equ     1

        push    bp
        mov     bp,sp
        push    ds
        lds     bx,cpu_info

        cmp     mtest, 'W'
        jnz     skipWeitek
        call    Weitek
        call    chkint
skipWeitek:
        cmp     mtest, 'T'
        jnz     skipTable
        call    TableOf
skipTable:
        cmp     mtest, 'N'
        jnz     skipNDP
        call    NDP
skipNDP:
        pop     ds
        pop     bp
        ret     4
MISC   endp

;--------------------------------------------------------------------

TableOf   Proc    Near
   smsw    mMSW
   sgdt    mGDT
   sidt    mIDT
TableOf EndP


;--------------------------------------------------------------------

chkint  proc    near

; save old INT 01H vector

        push    bx
        mov     ax,3501H
        int     21H
        mov     old_int01_ofs,bx
        mov     old_int01_seg,es
        pop     bx

; redirect INT 01H vector

        push    ds
        mov     ax,2501H
        mov     dx,seg new_int01
        mov     ds,dx
        mov     dx,offset new_int01
        int     21H
        pop     ds

; set TF and change SS -- did we trap on following instruction?

        pushf
        pop     ax
        or      ah,01H                  ; set TF
        push    ax
        popf
        push    ss                      ; CPU may wait one
                                        ; instruction before
                                        ; recognizing single step
                                        ; interrupt
        pop     ss
chkint_01:                              ; shouldn't ever trap here

; restore old INT 01H vector

        push    ds
        mov     ax,2501H
        lds     dx,old_int01
        int     21H
        pop     ds
        ret
chkint  endp

;--------------------------------------------------------------------

new_int01       proc    near

;       INT 01H handler (single step)
;
;       On entry:
;
;       SP =>   IP
;               CS
;               flags

        sti
        pop     ax                      ; IP
        cmp     ax,offset chkint_01
        jb      short new_int01_03
        je      short new_int01_01
        mov     mchkint,false
        jmp     short new_int01_02
new_int01_01:
        mov     mchkint,true
new_int01_02:
        pop     cx                      ; CS
        pop     dx                      ; flags
        and     dh,0FEH                 ; turn off TF
        push    dx                      ; flags
        push    cx                      ; CS
new_int01_03:
        push    ax                      ; IP
        iret
new_int01       endp
;--------------------------------------------------------------------

ndp     proc    near

; Hier wird einfach nur der Status in die Variable eingetragen

.8087
        fstcw   mNDPCW          ;save status
        ret
ndp     endp

;------------------------------------------------------------------------------
; This checks to see if the BIOS reports a Weitek math coprocessor. This should
; only be called if a 386 or 486 is found.
; NOTE!! This may not work with all computers!!

fnoWeitek       equ     0
fWeitek         equ     1
fWeitek_real    equ     81h

weitek  proc    near
.386
        xor     eax,eax                 ;zero everything
        int     11h                     ;do equipment check
        test    eax,01000000h           ;check bit 24, set if Weitek present
        je      no_weitek
        mov     mWeitek,fWeitek
        test    eax,0800000h            ;check bit 23, set if Weitek can be
        je      weitek_done             ; addressed in real mode
        mov     mWeitek,fWeitek_real
        jmp     short weitek_done
no_weitek:
        mov     mWeitek,fnoWeitek
weitek_done:
        ret
.286
weitek  endp



;--------------------------------------------------------------------

DISKREAD        proc    far

assume cs:CODE, ds:DATA, es:nothing

;       On entry:
;
;               BP
;       SP =>   near return address
;               offset  of disk buffer
;               segment "   "     "
;               number of sectors to read
;               starting logical sector number
;               drive number (0=A, 1=B, etc.)
;
;       On exit:
;
;               AX      = function result
;                       00      - function successful
;                       01..FF  - DOS INT 25H error result

        drive                   equ     [bp + 16]
        starting_sector         equ     [bp + 12]
        number_of_sectors       equ     [bp + 10]
        buffer                  equ     [bp + 6]

        push    bp
        mov     bp,sp
        mov     ax,3000h                ;get DOS version
        int     21h
        cmp     al,4                    ;DOS 4?
        jge     read4                   ;We have 4 or newer, so use extended
        cmp     ax,1d04h                ;use old for anything less than 3.30
        jle     read3
;
;Check bit 1 of the device attributes bit. If it's set, then the driver
;supports use of the extended access method
;
        push    es                      ;save regs
        push    ds
        mov     dl,drive                ;get drive number (0=A,1=B,etc)
        inc     dl                      ;func uses 0=dflt, 1=A, etc..
        mov     ah,32h                  ;get driver parameter block
        int     21h
        push    ds                      ;move ds to es
        pop     es
        pop     ds                      ;restore original ds
        les     bx,[es:bx + 12h]        ;point ES:BX to device driver
        test    word ptr [es:bx + 4], 2 ;test device attributes
        pop     es
        jz      read3                   ;wasn't, so use old method

read4:
        mov     al,drive
        mov     bx,starting_sector      ;copy info into parameter block
        mov     extd_starting_sector_lo,bx
        mov     bx,starting_sector + 2
        mov     extd_starting_sector_hi,bx
        mov     bx,number_of_sectors
        mov     extd_number_of_sectors,bx
        les     bx,buffer               ;get seg:ofs of buffer in ES:BX
        mov     extd_bufofs,bx          ;put into block
        mov     extd_bufseg,es
        mov     bx,offset dos4_block    ;DS:BX points to block
        mov     cx,-1                   ;-1 means extended read
        push    ds                      ;save DS (not really needed, but lets
                                        ;me share code with DOS 3 read.)
        jmp     short readit

read3:  mov     al,drive
        mov     dx,starting_sector
        mov     cx,number_of_sectors
        push    ds
        lds     bx,buffer               ;get seg:ofs of buffer in DS:BX
readit: int     25H
        inc     sp                      ; fix broken stack
        inc     sp
        pop     ds
        jc      short diskread_01
        xor     ax,ax
diskread_01:

        pop     bp
        ret     10

DISKREAD        endp

;
; ATIINFO is used in the Video identification routine to get special
; information from ATI VGA Wonder cards.
;
; Pascal format: function ATIinfo(data_in: byte; register: word): byte;
;
ATIinfo         proc    far
        assume  cs:CODE, ds:DATA, es:NOTHING

data_in         equ     [bp+8]
register        equ     [bp+6]

        push    bp
        mov     bp,sp
        mov     dx,register             ;get register
        mov     ax,data_in              ;get command word (actually byte)
        cli                             ;no interrupts
        out     dx,al
        inc     dx                      ;next port
        in      al,dx                   ;get result
        sti                             ;restore interrupts
        mov     sp,bp
        pop     bp
        ret     4

ATIinfo endp

; AltIntr is an alternative to the Intr function. The standard Intr function
; does not do a true Interrupt!! Instead, it gets the address of the interrupt
; from the interrupt table, loads all the registers, and then does a RETF!!!
; The address of a return routine has been pushed on the stack so that it
; returns to TP and unloads the registers. This was probably done because
; Intel saw to it that all interrupt numbers must be immediate, and Borland
; didn't want to use self-modifying code.
;   NOTE: The MsDos routine is ALSO affected by this problem. It just stuffs
; a 21h into the stack, and calls Intr!!! So you can use ALTMSDOS instead!
;   Now, normally, the above procedure works perfectly fine, except under 1
; condition. When the CPU is under protected or Virtual 86 mode. When in those
; modes, a program with higher privileges can trap an interrupt and act on it.
; I found this out the hard way by going nuts wondering why I couldn't detect
; DPMI drivers or Windows!! My alternative Interrupt functions identically to
; Borlands, but uses self-modifying code to generate a true interrupt. To
; prevent possible problems with CPU pipelining, the entry point is near the
; end of the code, and then jumps back to continue.
;
; Pascal format: procedure AltIntr(intno: byte; regs: registers); external;

ALTINTRP        proc    far
        assume  cs:CODE, ds:DATA, es:NOTHING

regaddr equ     [bp + 6]
intno   equ     [bp + 10]


altcont:
        lds     si,regaddr              ;point DS:SI to regs
        mov     cs:save_ds,ds           ;save pointer for return
        mov     cs:save_si,si
        cld                             ;go forward
        lodsw                           ;load AX and hold it
        push    ax
        lodsw                           ;load BX
        mov     bx,ax
        lodsw                           ;load CX
        mov     cx,ax
        lodsw                           ;load DX
        mov     dx,ax
        lodsw                           ;load BP
        mov     bp,ax
        lodsw                           ;load SI and hold it
        push    ax
        lodsw                           ;load DI
        mov     di,ax
        lodsw                           ;load DS and hold it
        push    ax
        lodsw                           ;load ES
        mov     es,ax
        lodsw                           ;load Flags
        and     ax,008D5h               ;mask out non-standard bits
        push    bx                      ;I need a register!
        mov     bx,ax
        pushf                           ;get current flags in AX
        pop     ax
        and     ax,0F72Ah               ;mask out normal bits
        or      ax,bx                   ;set needed flags
        push    ax
        popf
        pop     bx
        pop     ds                      ;get rest of regs
        pop     si
        pop     ax
        db      0cdh                    ;Int opcode
intrpt  db      ?                       ;loaded with real interrupt
        pushf                           ;save flags and modified regs
        push    es
        push    di
        mov     es,cs:save_ds           ;get regs pointer into ES:DI
        mov     di,cs:save_si
        cld                             ;go forward
        stosw                           ;save AX
        mov     ax,bx
        stosw                           ;save BX
        mov     ax,cx
        stosw                           ;save CX
        mov     ax,dx
        stosw                           ;save DX
        mov     ax,bp
        stosw                           ;save BP
        mov     ax,si
        stosw                           ;save SI
        pop     ax
        stosw                           ;save DI
        mov     ax,ds
        stosw                           ;save DS
        pop     ax
        stosw                           ;save ES
        pop     ax
        stosw                           ;save Flags
        pop     ds                      ;restore regs
        pop     bp
        ret     6

altintr:
        push    bp
        mov     bp,sp
        push    ds                      ;save DS, because we screw it up
        mov     al,intno                ;get interrupt number to use
        mov     cs:intrpt,al            ;and modify our code
        jmp     altcont                 ;continue with rest of code

;local storage

save_ds dw      ?
save_si dw      ?

ALTINTRP        endp
;
; Pascal format: procedure AltMsDos(var regs: registers); external;
;
ALTMSDOS        proc    far
        assume  cs:CODE, ds:DATA, es:NOTHING

        pop     si              ;back track a bit so we can stuff
        pop     dx              ;interrupt number in
        pop     cx
        pop     bx
        mov     al,21h          ;push interrupt number
        push    ax
        push    bx
        push    cx              ;restore other info
        push    dx
        push    si
        jmp     ALTINTR         ;do interrupt call

ALTMSDOS        endp


TSENGCK proc    far
        assume  cs:CODE, ds:DATA, es:nothing;

;Tseng VGA detection from 'Advanced Programmer's Guide to Super VGAs'

        mov     dx,3cdh         ;page select reg
        in      al,dx
        mov     ah,al           ;save
        and     al,0c0h         ;save some bits
        or      al,55h          ;test value one
        out     dx,al           ;write it
        in      al,dx
        cmp     al,55h          ;same?
        jne     nottseng
        mov     al,0aah         ;test value two
        out     dx,al
        in      al,dx
        cmp     al,0aah         ;same
        jne     nottseng
        mov     al,ah           ;restore original settings
        out     dx,al
        mov     al,1
        jmp     short end_tsengck
nottseng:
        mov     al,0
end_tsengck:
        ret

TSENGCK endp

ZYMOSCK proc    far
        assume  cs:CODE, ds:DATA, es:nothing;

;ZyMOS VGA detection from 'Advanced Programmer's Guide to Super VGAs'

        mov     dx,3c4h         ;extended reg bank
        mov     al,0bh          ;version reg
        out     dx,al
        inc     dx
        in      al,dx           ;get version
        and     al,0fh
        cmp     al,2
        je      end_zymosck
        mov     al,0
end_zymosck:
        ret
ZYMOSCK endp

POPADBUGTST  proc    far
;
; BUGTST.ASM - By: John Lauro
;              Based on bug found by Jeff Prothero
;               Mod. by Andrew Rossmann, 7/20/91.

        ASSUME  CS:CODE,DS:DATA,ES:nothing
.386
        mov     eax,12345678
        mov     edx, 0
        mov     edi, 0
        pushad
        popad

; The instruction immediately following popad is the critical
; instruction.  Simple fix, insert a NOP after popad.

        mov     ecx, [edx+edi]

        cmp     eax, 12345678
.286
        mov     al,0
        je      end_bugtst
        mov     al,1
end_bugtst:
        ret

POPADBUGTST  endp


MULBUGTST  proc    far
       ASSUME  CS:CODE,DS:DATA,ES:nothing
.386
; Bug-Test Routine aus Norbert Juffa's CTest-Programm
;
       MOV     AL, 0                ; davon ausgehen,  da· kein Bug vorh.

       MOV     EAX, 0417A000h       ; test if early 80386
       MOV     ECX, 00000081h       ;  processor with 32 multiplication bug
       MUL     ECX
       CMP     EDX, 00000002h
       JNZ     SHORT $mul_err
       CMP     EAX, 0FE7A000h
       JNZ     SHORT $mul_err
       JMP     SHORT EndMul
$Mul_Err:
       MOV     AL, 1
EndMul:
.286
       RET
MULBUGTST  endp


FDIVBUGTST  proc    far
        ASSUME  CS:CODE,DS:DATA,ES:nothing

.287
        finit
        fld x
        fld st
        fld y               ; 0 = y; 1 & 2 = x
        fdiv    st(2), st   ; 0 = y; 1 = x; 2 = x/y
        fmulp   st(2), st   ; 0 = x, 1 = (x/y)*y
        fsubp   st(1), st   ; 0 = (x/y)*y-x => should be zero
        fldz                ; 0 = 0; 1 = (x/y)*y-x
        fcomp   st(1)       ; Is it zero
        fstsw   ax          ; get control word
        ffree   st(1)
        ffree   st
        sahf                ; load flag register
        MOV     AL, 0
        jz      EQUAL       ; If C3 not set, result = 0
        MOV     AL, 1
EQUAL:
.286
        RET
FDIVBUGTST  endp

.386p
.387
Assume CS:Code, DS:Data, ES:nothing
                                         ; declare parameters

Options_Flag EQU     [BP+24]             ; <> 0, if debugging output desired
                                         ; nur optional angegeben,
                                         ; signifikanter Code wurde
                                         ; gelîscht.
Ext_Flag    EQU     [BP+22]              ; zero, if no extended memory
EMS_Flag    EQU     [BP+20]              ; zero, if no expanded memory
BufferPtr   EQU     [BP+16]              ; buffer for EMS u. EXT test
EMS_Base    EQU     [BP+12]              ; address of EMS-frame
ScreenPtr   EQU     [BP+8]               ; start address of video memory
ResultPtr   EQU     [BP+4]               ; pointer to result struct


                                         ; declare local variables

Stat        EQU     [BP-2]               ; mem for 80x87 status word
Ctrl        EQU     [BP-4]               ; mem for 80x87 control word
GDT         EQU     [BP-52]              ; mem for global descriptor table
SystemStat  EQU     [BP-53]              ; mem for system status
SaveCtrl    EQU     [BP-55]              ; original 80x87 control word


                                         ; declare result record
CPU_NDP_TYP EQU     [SI]
AAMTime     EQU     [SI+2]
MovEvenTime EQU     [SI+6]
BIOSWrTime  EQU     [SI+8]
MovByteTime EQU     [SI+10]
MovEMSTime  EQU     [SI+12]
MovExtTime  EQU     [SI+14]
ScrFillTime EQU     [SI+16]
Dummy2      EQU     [SI+18]
i87Time     EQU     [SI+20]
i287Time    EQU     [SI+22]
MovDblTime  EQU     [SI+24]

SpeedTest1  PROC    Near
            PUSH    BP                   ; save caller's frame pointer
            MOV     BP, SP               ; make new frame pointer
            SUB     SP, 55               ; alloc mem for local variables
            PUSH    DS                   ; save Turbo Pascal's data segment
            PUSHF                        ; save original flag setting

$inittimer: CLI                          ; disable interrupts
            CLD                          ; auto increment for string operations
            IN      AL, 61h              ; port B - system control
            MOV     [SystemStat], AL     ; save system status
            AND     AL, 11111101b        ; clear speaker bit (disable speaker)
            OR      AL, 1                ; turn on bit for timer 2 (enable it)
            CMP     AL, [SystemStat]     ; system already configured correctly ?
            JES     $aam                 ; no need to configure it
            OUT     61h, AL              ; reconfigure system (tmr 2 on,spk off)

$aam:       STRT_TIM                     ; start timer 2
            REPT    200
            AAM                          ; execute 200 AAMs
            ENDM
            STOP_TIM                     ; elapsed time of timer 2 in BX
            LDS     SI, ResultPtr        ; pointer to result struct
            MOV     [AAMTime], BX        ; save time for AAMs

$begin_test:JMPS    $cpu_ndptst          ; nope

$cpu_ndptst:LDS     SI, ResultPtr        ; pointer to result struct
            FNSTCW  [SaveCtrl]           ; save original NDP ctrl word
            PUSH    SP                   ; test updating
            POP     AX                   ;  of stackpointer
            CMP     AX, SP               ; stackpointer updated before push ?
            JES     $286_386             ; no, must be 286, 386 or 486
            MOV     AX, 1                ; try to shift
            MOV     CL, 33               ;  accu 33 times
            SHL     AX, CL               ; shift count masked off ?
            JNZS    $186_188             ; yes, must be 186 or 188
            PUSHA                        ; PUSHA executed on 88/86 as JMP $+2
            STC                          ; carry set if V20 or V30
            JCS     $V20_V30             ; yes, must be V20 or V30
            PUSHF                        ; save flags
            POP     AX                   ; pop flags into AX
            AND     AH, 00FH             ; clear bits 12-15 of flag register
            PUSH    AX                   ; put new flags in stack
            POPF                         ; pop into flag register
            PUSHF                        ; put flags on stack
            POP     AX                   ; get flags
            AND     AH, 0F0H             ; test if all bits
            CMP     AH, 0F0H             ;  in highest nibble set
            JES     $88_86               ; all bits in highest nibble set
            XOR     DL, DL               ; failed all tests, unknown CPU
            JMPS    $copro_test          ; go and test NDP
$88_86:     MOV     DL, cpu_i8088        ; else it's an 88 or 86

; Hier habe ich den 80C86/88 Test aus WHATCHIP.ASM eingebaut. Er
; unterscheidet zwischen der normalen (8086/88) und der CMOS (80C86/C88)
; Version.                                                            - EJF

            push BX
            push SI
            push ES
            xor   bx,bx                 ; Start by assuming an 8088
            push  si                    ; Preserve SI register
            sti                         ; Enable timer interrupt
            mov   cx,0FFFFh             ; This loop takes approx
            rep   lods byte ptr es:[si] ;    100ms on an 8MHz 80C86
            pop   si                    ; Restore SI
            or    cx,cx                 ; Did loop complete?
            jne   $End_CMTest           ; Must be an original 8088/86
            mov   dl,cpu_i80C88         ; Otherwise its a CMOS version
$End_CMTest:
            pop ES
            pop SI
            pop BX

            JMPS    $queue_test          ; decide wether 88 or 86
$V20_V30:   POPA                         ; remove pushed bytes
            MOV     DL, cpu_V20          ; it's an V20 or V30
            JMPS    $queue_test          ; decide wether V20 or V30
$186_188:   MOV     DL, cpu_i188         ; 188/186
$queue_test:LEA     BX, [$patch]         ; load patch address into BX
            MOV     BYTE PTR CS:[BX], 42h; preset with opcode for INC DX
            MOV     AL, 90H              ; patch in a NOP (opcode 90h)
            MOV     CL, 31               ; rotate register 31 times to use up
            ROL     AH, CL               ;  time so prefetch queue can be filled
            MOV     BYTE PTR CS:[BX], AL ; insert NOP at label $patch
            NOP                          ; fill
            NOP                          ;  prefetch
            NOP                          ;   queue
            NOP                          ;    with NOPs
$patch:     INC     DX                   ; patched to NOP on i(C)88, i188 and V20
$copro_test:JMP     $ndp_test            ; check for coprocessor
$286_386:   MOV     DL, cpu_i286         ; 286, 386 or 486
            PUSH    7000h                ;  try to set
            POPF                         ;   IOPL and NT fields
            PUSHF                        ;    in bit 12-14
            POP     AX                   ;     of flag register
            TEST    AX, 7000h            ; bits cannot be set in 286 real mode
            JZS     $copro_test          ; bits not set --> 286
            INC     DX                   ; CPU is an 386 (DL = 8) or 486
$NexGen:    CLC                          ; Der Nexgen Prozessor setzt
            MOV AX, 5555h                ; nach einer Division das
            XOR DX, DX                   ; Zero-Flag. Dieser 'Fehler'
            MOV CX, 2h                   ; ist sonst nur bei einigen
            DIV CX                       ; Cyrix-Chips beobachtet,
            JNZS $End_NexGen             ; weshalb das Flag AC auch
            PUSHF                        ; ÅberprÅft wird, um sicher zu
            POP AX                       ; gehen, da· es kein Cyrix-
            AND AL, 1                    ; Chip sein kann.
            XOR AL, 1
            CMP AL, 0
            JE $End_NexGen
            MOV DL, cpu_Nexgen
            JMP $ndp_test
$End_NexGen:

            MOV     EBX, ESP             ; save current stackpointer to align it
            AND     ESP, 0FFFFFFFCh      ; align stack to avoid AC fault
            PUSHFD                       ; save EFLAGS
            POP     EAX                  ; get EFLAGS from stack
            MOV     ECX, EAX             ; original value of EFLAGS
            XOR     EAX, 40000H          ; toggle AC bit in EFLAGS
            PUSH    EAX                  ; copy new value
            POPFD                        ;  to EFLAGS
            PUSHFD                       ; get new EFLAGS value
            POP     EAX                  ; put into EAX
            XOR     EAX, ECX             ; test if AC bit could be changed
            PUSH    ECX                  ; restore original
            POPFD                        ;  value of EFLAGS
            MOV     ESP, EBX             ; restore original stack pointer
            OR      EAX, EAX             ; EAX = 0 on 386, 40000h on 486
            JNZS    $CyrixIntel          ; if <> 0, must be 486/486dlc/486slc
$chk_38600: PUSH    DX                   ; save CPU code
            MOV     ESI, 32              ; 32 trials to check for POPAD bug
            MOV     EAX, 12345678        ; load some value
$trial_loop:MOV     EBX, EAX             ; save value for comparison
            MOV     EDX, 0               ; prepare index and
            MOV     EDI, 0               ;  base register to point to DS:0
            PUSHAD                       ; push all 32-bit registers
            POPAD                        ; pop all 32-bit registers
            MOV     ECX, [EDX+EDI]       ; mem access changes EAX (POPAD bug!)
            CMP     EAX, EBX             ; EAX changed ?
            JNZS    $changed             ; EAX changed -> bug in AMD/Intel 386
            ROL     EAX, 1               ; try next number
            DEC     ESI                  ; decrement trial counter
            JNZS    $trial_loop          ; until 32 trials thru, exits with Z=1
$changed:   POP     DX                   ; restore CPU code
            JNZ     $copro_test          ; EAX changed, must be Intel/AMD 386
            MOV     DL, cpu_ct38600      ; C&T 38600 doesn't have that bug
            JMP     $copro_test          ; now test for coprocessor
$CyrixIntel:
            MOV    AX,0
            CMP    AX,AX
            PUSHF
            POP    AX
            MOV    fVor,AX
            MOV    AX,0FFFFh
            MOV    DX,0
            MOV    BX,4
            DIV    BX
            PUSHF
            POP    AX
            MOV    fNach,AX
            MOV    AX, fVor
            MOV    BX, fNach
            AND    AX, 08D5h
            AND    BX, 08D5h
            CMP    AX, BX
            MOV    DL, cpu_Cyrix
            JE     $ndp_test
$486_486dlc:MOV     AX, 0FFFFh           ; load initial multiplicand
            MOV     BX, 0FFFFh           ; load multiplicator
            STRT_TIM                     ; start timer 2
            REPT    30                   ; 486: MUL takes 26, AAM 15 clocks
            MUL     BX                   ; execute 30 MULs
            ENDM                         ; 486DLC: MUL takes 3, AAM 17 clocks
            STOP_TIM                     ; elapsed time of timer 2 in BX
            SHL     BX, 3                ; time for 240 MULs
            CMP     BX, [AAMTime]        ; time for 240 MULs>time for 200 AAMs ?
            MOV     DL, cpu_i486         ; default: it's a 486 (CPU = 15)
            JA      $test486             ; yes, 486 has slow MUL
            ADD     BX, BX               ; time for 480 MULs
            CMP     BX, [AAMTime]        ; time for 480 MULs>time for 200 AAMs ?
            JAS     $pentium             ; yes, Pentium MUL takes 11 clocks
            MOV     DL, cpu_486dlc       ; no, fast MUL -> 486DLC/486SLC
$test486:   pushfd                       ; EF holen
            pop     EAX                  ; EF nach EAX
            mov     ECX,EAX              ; EAX in ECX sichern
            xor     EAX,000200000h       ; ID Flag toggeln
            push    EAX                  ; EAX auf den Stack
            popfd                        ; EF zurueckschreiben
            pushfd                       ; EF wieder auslesen
            pop     EAX                  ; EF nach EAX holen
            push    ECX                  ; ECX auf den Stack
            popfd                        ; altes EF restore
            xor     EAX,ECX              ; Bit veraendert worden? Z=1
            jz      $ndp_test            ; ja Z=1 = 486
            mov     EAX,1                ; CPUID Level 1
            db 0fh, 0a2h                 ; CPUID
            ror     EAX,8                ; Family prÅfen
            and     EAX,0000Fh           ; maske
            cmp     AL,4
            je      $ndp_Test
$pentium:   MOV     DL, cpu_pentium      ; speed of Pentium between 486DLC..486

$ndp_test:  XOR     DH, DH               ; assume no coprocessor
            XOR     AX, AX               ; clear register
            OUT     0F0h, AL             ; clear error signal of coprocessor
            FNINIT                       ; initialize coprocessor
            MOV     [Ctrl], AX           ; clear status variable
            NOT     AX                   ; load all 1's
            MOV     [Stat], AX           ; initialize status variable to all 1's
            FNSTCW  [Ctrl]               ; store NDP control word
            MOV     AX, [Ctrl]           ; get control word
            AND     AX, 0F3Fh            ; extract RC, PC and exception masks
            CMP     AX, 033Fh            ; RC=0, PC=3, masks=3F ?
            JNES    $chk_486sx           ; no -> no coprocessor present
            FNSTSW  [Stat]               ; store NDP status
            TEST    WORD PTR [Stat],383Fh; stack top & exceptions must be clear
            JNZS    $chk_486sx           ; ST & exceptions not clear -> no NDP
            MOV     DH, ndp_Emul         ; coprocessor is at least emulator (=1)
            CMP     DL, cpu_i286         ; is CPU 80286 or higher ?
            JBS     $no_emulat           ; no, emulation impossible
            SMSW    AX                   ; get machine status word
            TEST    AL, 4                ; test if EM bit of MSW set
            JZS     $no_emulat           ; not set -> no NDP emulation
$chk_486sx: CMP     DL, cpu_i486         ; CPU = Intel 486 and no/emulated copro ?
            SBB     DL, -1               ; yes, CPU is 486sx (increment DL)
            JMP     $ndp_exit            ; no further NDP checking
$no_emulat: MOV     DH, ndp_i8087        ; coprocessor is at least 8087 (=2)
            FLD1                         ; load 1.0
            WAIT                         ; needed for 8087
            FLDZ                         ; load 0.0
            WAIT                         ; needed for 8087
            FDIV                         ; 1.0 / 0.0 = +infinity
            WAIT                         ; needed for 8087
            FLD     ST(0)                ; duplicate +infinity
            WAIT                         ; needed for 8087
            FCHS                         ; generate -infinity
            WAIT                         ; needed for 8087
            FCOMPP                       ; compare infinities and clear NDP stk
            WAIT                         ; needed for 8087
            FSTSW   WORD PTR [Stat]      ; save condition codes
            MOV     AX, [Stat]           ; load condition codes
            SAHF                         ; transfer into CPU flags
            JNES    $187_387             ; 187, C287 or 387 if numbers not equal
            CMP     DL, cpu_i286         ; is CPU >= 286 ?
            JBS     $ndp_exit1           ; no, coprocessor is 8087
            MOV     DH, ndp_i80287       ; coprocessor is 287
            JMPS    $chk_iit             ; check for IIT coprocessors
$187_387:   CMP     DL, cpu_i286         ; is CPU >= 286 ?
            JAES    $C287_387            ; yes, NDP is either C287, 287XL or 387
            MOV     DH, ndp_i80C187      ; coprocessor is 187
            JMPS    $ndp_exit1           ; store CPU and NDP code
$C287_387:  CMP     DL, cpu_i386         ; is CPU >= 386 ?
            JAES    $387_486             ; yes, NDP is 387 or 387sx, 486
            MOV     DH, ndp_i287XL       ; coprocessor is C287
            JMPS    $chk_iit             ; check for IIT coprocessors
$387_486:   CMP     DL, cpu_i486         ; is CPU >= 486 ?
            JAES    $i486                ; yes, NDP is 486 / 487
            MOV     DH, ndp_i387         ; coprocessor is 387 or 387sx
            JMPS    $chk_iit             ; check for IIT coprocessors
$i486:      CMP     DL, cpu_pentium      ; is CPU Intel Pentium ?
            JES     $ipentium            ; yes, FPU is also Pentium
            MOV     DH, ndp_i486         ; NDP = 486 / 487
            JMP     $ndp_exit            ; done with FPU detection
$ipentium:  MOV     DH, ndp_pentium      ; set FPU type = Pentium
$ndp_exit1: JMP     $ndp_exit            ; no further tests required
$chk_iit:   FNINIT                       ; initialize coprocessor
            FLD     CS:[$denormal]       ; load denormal number
            FADD    ST(0), ST            ; result is zero on IIT
            FNSTSW  AX                   ; get status of NDP into AX
            TEST    AL, 02h              ; test if denormal exception flag set
            JNZS    $chk_ulsi            ; Intel NDPs signal denormal exception
            ADD     DH,ndp_2c87-ndp_i80287;set IIT coprocessor types
            JMPS    $ndp_exit1           ; coprocessor type found
$chk_ulsi:  CMP     DL, cpu_i386         ; CPU >= 386 ?
            JBS     $chk_cyrix1          ; no, can not be ULSI
            FNINIT                       ; initialize coprocessor
            FLDCW   CS:[$53bit_prec]     ; PC => 53 bits (ULSI ignores PC)
            FLD     TBYTE PTR CS:[$op1]  ; load 2-epsilon
            FLD1                         ; load 1
            FADDP   ST(1), ST            ; result should be 3 and PE raised
            FSTP    TBYTE PTR [GDT]      ; store result, clear NDP stack
            FNSTSW  AX                   ; get coprocessor status word
            TEST    AL, 20h              ; precision exception ?
            JNZS    $chk_cyrix1          ; ULSI computes 64 bit result, no PE!
            FWAIT                        ; make sure result is stored
            CMP     BYTE PTR [GDT], 0F8h ; check least significant mantissa bits
            JNES    $chk_cyrix1          ; not expected result for ULSI
            CMP     BYTE PTR [GDT+9], 40h; check exponent hi-byte
            JNES    $chk_cyrix1          ; not expected result for ULSI
            ADD     DH,ndp_83C87-ndp_i387; set ULSI types
            JMPS    $ndp_exit1           ; done
$chk_cyrix1:FNINIT                       ; initialize coprocessor
            FLD     TBYTE PTR CS:[$nan]  ; load positive NaN
            FLD     ST(0)                ; duplicate NaN
            FCHS                         ; make negative NaN
            FPATAN                       ; ATAN (-NaN, +NaN) should return +NaN
            FSTP    TBYTE PTR [GDT]      ; store result, clear NDP stack
            FWAIT                        ; wait until result is stored
            CMP     BYTE PTR [GDT+9], 7Fh; Cyrix ret. +NAN (7F),Intel -NAN (FF)
            JNES    $chk_ct              ; Intel coprocessor
$chk_emc87: FNSTCW  [Ctrl]               ; store control word
            OR      BYTE PTR [Ctrl+1],80h; set msb of control word
            FLDCW   [Ctrl]               ; and load back into coprocessor
            FSTCW   [Ctrl]               ; store control word again
            FWAIT                        ; wait until stored
            TEST    BYTE PTR [Ctrl+1],80h; could msb be set ?
            JZS     $no_emc              ; no -> no EMC87
            MOV     DH, ndp_emc87        ; set NDP type to EMC87
            JMPS    $ndp_exit            ; done
$no_emc:    ADD     DH,ndp_82S87-ndp_i80287; set old Cyrix types
            FLD1                         ; load 1.0
            FLD     ST(0)                ; load another 1.0
            FYL2XP1                      ; compute 1.0*ld(2.0)
            FLD1                         ; compare result with 1.0
            FCOMPP                       ; new Cyrix copros have correct result
            FNSTSW  AX                   ; store coprocessor condition bits
            SAHF                         ; transfer to CPU flags
            JNES    $ndp_exit            ; if incorrect result, not new Cyrix
            ADD     DH,ndp_82S87p-ndp_82S87; set NDP-type to new Cyrix types
            JMPS    $ndp_exit            ; done
$chk_ct:    CMP     DL, cpu_i386         ; CPU >= 386 ?
            JBS     $chk_387DX           ; no, can not be C&T
            FNINIT                       ; initialize coprocessor
            FLDPI                        ; load pi
            F2XM1                        ; 2**(pi)-1=pi/2, argument out of range
            FLD1                         ; load 1.0
            FCHS                         ; -1.0
            FLDPI                        ; load pi
            FSCALE                       ; pi/2
            FSTP    ST(1)                ; pi/2
            FCOMPP                       ; 2**(pi)-1=pi/2 ?
            FSTSW   AX                   ; save condition codes
            SAHF                         ; transfer to CPU flags
            JNES    $chk_387DX           ; not equal, not C&T
            ADD     DH,ndp_38700-ndp_i387; set C&T types
            JMPS    $ndp_exit            ; done
$chk_387DX: CMP     DH, ndp_i387         ; Intel 387 ?
            JNES    $ndp_exit            ; no, done. Only want to check i387
            FNINIT                       ; initialize coprocessor
            FLD1                         ; load 1.0
            FCHS                         ; -1.0
            FXTRACT                      ; split into mantissa and exponent(0)
            FSTP    ST(0)                ; pop mantissa
            FXAM                         ; look at sign of exponent
            FNSTSW  AX                   ; store status word
            AND     AH, 2                ; C1 set (negative) on old 387
            FSTP    ST(0)                ; clear coprocessor stack
            JNZS    $ndp_exit            ; C1 set, no 387DX
            MOV     DH, ndp_i387DX       ; set NDP-type to 387DX
            FNINIT                       ; initialize coprocessor
            FBSTP   TBYTE PTR [GDT]      ; store BCD indefinite
            CMP     BYTE PTR [GDT+7],0C0h; RapidCAD stores C0h, 387DX stores 80h
            JNES    $ndp_exit            ; no RapidCAD
            MOV     DX, ndp_RapidCAD*100H+cpu_RapidCAD; RapidCAD (NDP=21,CPU=14)
$ndp_exit:  LDS     SI, ResultPtr        ; pointer to result record
            MOV     [SI], DX             ; save CPU and NDP types
            JMPS    $moveeven            ; skip over test data for NDP check

$denormal   DT      1
$nan        DB      0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 07Fh
$op1        DB      0F0h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 03Fh
$53bit_prec DW      027Fh


$moveeven:  MOV     AX, DS               ; set up segment registers
            MOV     ES, AX               ;  for memory move
            XOR     SI, SI               ; offset in both segments
            MOV     DI, SI               ;  is zero
            MOV     CX, 5000             ; move 5000
            REP     MOVSW                ;  words
            STRT_TIM                     ; start timer 2
            XOR     SI, SI               ; offset in both segments
            MOV     DI, SI               ;  is zero
            MOV     CX, 5000             ; move 5000
            REP     MOVSW                ;  words
            STOP_TIM                     ; elapsed time of timer 2 in BX
            LDS     SI, ResultPtr        ; pointer to result record
            MOV     [SI+6], BX           ; save MoveEvenTime

$movebyte:  MOV     AX, DS               ; set up segment registers
            MOV     ES, AX               ;  for memory move
            MOV     SI, 1                ; offset in source and destination
            MOV     DI, SI               ;  segment is odd
            STRT_TIM                     ; start timer 2
            MOV     CX, 5000             ; move 5000
            REP     MOVSB                ;  bytes
            STOP_TIM                     ; elapsed time of timer 2 in BX
            LDS     SI, ResultPtr        ; pointer to result struct
            MOV     [SI+10], BX          ; save MoveByteTime

$movedouble:LDS     SI, ResultPtr        ; pointer to result struct
            CMP     BYTE PTR [SI],cpu_i386; CPU = iAPX 386 or i486 ?
            JBS     $move_ems            ; no 386/486
            MOV     AX, DS               ; load segment registers
            MOV     ES, AX               ;  for memory move
            XOR     SI, SI               ; offset in source and destination
            MOV     DI, SI               ;  segment is 0
            MOV     CX, 5000             ; move 5000
            REP     MOVSD                ;  double words
            STRT_TIM                     ; start timer 2
            XOR     SI, SI               ; offset in source and destination
            MOV     DI, SI               ;  segment is 0
            MOV     CX, 5000             ; move 5000
            REP     MOVSD                ;  double words
            STOP_TIM                     ; elapsed time for 2 in BX
            LDS     SI, ResultPtr        ; pointer to result struct
            MOV     [SI+24], BX          ; save MoveDouble-Time

$chk_386sx: CMP     BYTE PTR [SI], cpu_i486 ; CPU >= i486 ?
            JAES    $move_ems            ; yes, no need to test for 386sx
            MOV     AX, [SI+6]           ; AX = MoveWord-Time

            XCHG    AX, BX               ; AX = MoveDouble-Time,BX=MoveWord-Time
            SUB     AX, BX               ; MoveDTime - MoveWTime
            ADD     AX, AX               ; 2 * (MoveDTime - MoveWTime)
            CWD                          ; compute
            XOR     AX, DX               ;  Abs (2 * (MoveDoubleTime -
            SUB     AX, DX               ;   MoveWordTime))
            CMP     BX, AX               ; Abs(2*(MoveDTime-MoveWTime))>MoveWTime ?
            ADC     WORD PTR [SI], 0     ; CPU type = 386sx if true
            CMP     BYTE PTR [SI],cpu_ct38600sx; CPU = C&T 38600sx ?
            JNES    $move_ems            ; no
            MOV     BYTE PTR [SI],cpu_i386sx; POPAD test unreliable for 386sx,
                                         ; reset to Intel 386 since more likely
$move_ems:  CMP     BYTE PTR EMS_Flag, 0 ; does EMS memory exist ?
            JES     $move_ext            ; no, skip this test
            MOV     AH, 43h              ; #43, allocate page
            MOV     BX, 1                ;  one page
            INT     67h                  ; call EMM-driver (handle in DX)
            MOV     AH, 47h              ; #47, save page map
            INT     67h                  ; call EMM-driver
            MOV     AH, 44h              ; #44, map page
            MOV     AL, 0                ; physical page 0
            MOV     BX, 0                ; logical page 0
            INT     67h                  ; call EMM-driver
            LES     DI, BufferPtr        ; pointer to buffer
            MOV     CX, 5000             ; 5000 words
            LDS     SI, ResultPtr        ; pointer to result struct
            STRT_TIM                     ; start timer 2
            CMP     BYTE PTR [SI], cpu_i386 ; processor 386 or higher?
            LDS     SI, EMS_Base         ; pointer to EMS page frame
            JAES    $is_386              ; is a 386/486
            REP     MOVSW                ; move words from page frame to buffer
            JMPS    $no_386              ; was no 386/486
$is_386:    MOV     CX, 4000             ; 4000 double words = 1 EMS page
            REP     MOVSD                ; move 4000 double words
$no_386:    STOP_TIM                     ; elapsed time of timer 2 in BX
            LDS     SI, ResultPtr        ; pointer to result struct
            MOV     [SI+12], BX          ; save MoveEMSTime
            MOV     AH, 48h              ; #48, restore map
            INT     67h                  ; call EMM-driver
            MOV     AH, 45h              ; #45, deallocate page
            INT     67h                  ; call EMM-driver

$move_ext: CMP     BYTE PTR Ext_Flag, 0 ; does extended memory exist ?
            JES     $screenfill          ; no, skip test
            STRT_TIM                     ; start timer 2
            XOR     AX, AX               ; load zero
            MOV     BX, SS               ; load
            MOV     ES, BX               ;  address
            LEA     DI, GDT              ;   of GDT
            MOV     CX, 30h              ; 30h bytes long
            REP     STOSB                ; init with 0
            LEA     SI, GDT              ; reload address of GDT
            MOV     WORD PTR GDT+10H,10000; number of bytes to move
            MOV     WORD PTR GDT+12H, 0  ; source:
            MOV     BYTE PTR GDT+14H, 10H;  100000H (start of extended memory)
            MOV     BYTE PTR GDT+15H, 93H; access rights (read/write)
            MOV     WORD PTR GDT+18H,10000; number of bytes to move
            LDS     DI, BufferPtr        ; load pointer to buffer
            MOV     AX, DS               ; load pointer into DX:AX
            XOR     DX, DX               ; linearize
            SHL     AX, 1                ;  address,
            RCL     DX, 1                ;   32 bit result
            SHL     AX, 1                ;    in
            RCL     DX, 1                ;     DX:AX
            SHL     AX, 1                ;
            RCL     DX, 1                ;
            SHL     AX, 1                ;
            RCL     DX, 1                ;
            ADD     AX, DI               ;
            ADC     DX, 0                ;
            MOV     WORD PTR GDT+1AH, AX ; destination:
            MOV     BYTE PTR GDT+1CH, DL ;  buffer
            MOV     BYTE PTR GDT+1DH, 93H; access rights (read/write)
            MOV     AH, 87h              ; move from extended memory
            MOV     CX, 5000             ; move 5000 words from ext to buffer
            INT     15H                  ; call AT-BIOS
            STOP_TIM                     ; elapsed time of timer 2 in BX
            LDS     SI, ResultPtr        ; pointer to result record
            MOV     [SI+14], BX          ; save MoveExtTime

$screenfill:CMP     WORD PTR Options_Flag,0 ; Wird Bildschirm-Test
                                            ; gewÅnscht ?
            JNZS    $Bios_Write             ; nein

$screenfil1:LES     DI, ScreenPtr        ; pointer to start of video memory
            STRT_TIM                     ; start timer 2
            MOV     CX, 5000             ; fill 5000 bytes
            REP     STOSB                ;  of video memory
            STOP_TIM                     ; elapsed time for timer 2 in BX
            LDS     SI, ResultPtr        ; pointer to result struct
            MOV     [SI+16], BX          ; save ScreenFillTime

$Bios_Write:CMP     WORD PTR Options_Flag,0 ; Wird Bildschirm-Test gewÅnscht ?
            JNZS    $Dos_Write             ; nein
$bios_writ1:STRT_TIM                     ; start timer 2
            MOV     SI, 20               ; write 20 characters
$out_loop:  MOV     AX, 0920h            ; #9, write char and attribute
            MOV     BX, 0                ; page 0, attribute = blank
            MOV     CX, 1                ; write one character at a time
            INT     10H                  ; call video-BIOS
            DEC     SI                   ; loop over number of chars
            JNZS    $out_loop            ; until all 20 chars output
            STOP_TIM                     ; elapsed time of timer 2 in BX
            LDS     SI, ResultPtr        ; pointer to result struct
            MOV     [SI+8], BX           ; save BIOS-WriteTime

$Dos_Write: CMP     WORD PTR Options_Flag,0 ; Wird Bildschirm-Test gewnsht ?
            JNZS    $No_Screen            ; nein
$Dos_Writ1: STRT_TIM
            MOV	CX, 20
$out_loop2: MOV	AH, 02
            MOV	BH, 00
            MOV	DH, 1Ah
            MOV	DL, 01
            INT	10
            MOV	AH,09
            MOV	DX, Offset DosTestStr
            INT	21
            LOOP $Out_Loop2
            STOP_TIM
            LDS     SI, ResultPtr        ; pointer to result struct
            MOV     [SI+26], BX          ; save Dos-Screen-Write-Time
$No_Screen:

$speed87:   LDS     SI, ResultPtr        ; pointer to result struct
            CMP     BYTE PTR [SI+1], 1   ; real coprocessor present ?
            JAS     $cont_87             ; yes, do coprocessor tests
            JMP     $no_fpu              ; no, done
$cont_87:   WAIT                         ; for 8087
            FNINIT                       ; initialize coprocessor
            WAIT                         ; for 8087
            FLD1                         ; load 1
            STRT_TIM                     ; start timer 2
            REPT    40                   ; do following 40 times:
            WAIT                         ;  needed on 8087
            FSQRT                        ;  compute Sqrt(1)
            ENDM
            FWAIT                        ; wait until coprocessor done
            STOP_TIM                     ; time for 40 sqrt computations on BX
            LDS     SI, ResultPtr        ; pointer to result struct
            MOV     [SI+20], BX          ; save 87-Time

$speed287:  FNINIT                       ; initialize coprocessor
            FLD1                         ; load 1
            STRT_TIM                     ; start timer 2
            REPT    40                   ; do following 40 times:
            NOP                          ;  needed on 8087
            FSQRT                        ;  compute Sqrt(1)
            ENDM
            STOP_TIM                     ; time for 40 sqrt computations in BX
            LDS     SI, ResultPtr        ; pointer to result struct
            MOV     [i287Time], BX       ; save 287-Time
            MOV     CX, [SI]             ; get CPU (CL) and NDP (CH)
$chk_387sx: CMP     CL, cpu_i386sx       ; CPU = 80386sx ?
            JES     $has_387sx           ; is SX
            CMP     CL, cpu_ct38600sx    ; CPU = 38600sx ?
            JES     $has_387sx           ; is SX
            CMP     CL, cpu_486slc       ; CPU = 486SLC ?
            JNES    $no_387sx            ; no SX
$has_387sx: INC     CH                   ; set SX versions of 387 coprocessors
$no_387sx:
$store_type:MOV     [SI], CX             ; save CPU and NDP type
            CMP     CL, cpu_i286         ; CPU higher than 286 ?
            JBES    $no_weitek           ; no, Weitek only available for 386/486
            PUSH    SI                   ; save pointer
            PUSH    DS                   ;  to result struct
            XOR     EAX, EAX             ; zero everything in result register
            INT     11h                  ; do equipment check
            TEST    EAX, 01000000h       ; check bit 24, set if Weitek present
            POP     DS                   ; restore pointer
            POP     SI                   ;  to result struct
            JES     $no_weitek           ; bit not set, no Weitek
            OR      BYTE PTR [SI+1], 80h ; set Weitek flag in coprocessor type
$no_weitek: FNINIT                       ; reprogram
            FLDCW   [SaveCtrl]           ;  original NDP control word

$no_fpu:    MOV     AL, [SystemStat]     ; get original system status
            OUT     61h, AL              ;  and restore it

$ende:      POPF                         ; restore original flag settings
            POP     DS                   ; restore Turbo Pascal's data segment
            MOV     SP, BP               ; discard local variables
            POP     BP                   ; restore caller's frame pointer
            RET     24                   ; return, pop parameters

SpeedTest1  ENDP


TEST64K_D   PROC    Near
            MOV     ES, AX
            MOV     DS, AX
            XOR     BX, BX
            MOV     SI, BX
            MOV     DI, BX
            MOV     CX, DX
            REP     MOVSD
            MOV     SI, BX
            MOV     DI, BX
            MOV     CX, DX
            STRT_TIM
            REP     MOVSD
            STOP_TIM
            RET
TEST64K_D   ENDP


TEST64K_W   PROC    Near
            MOV     ES, AX
            MOV     DS, AX
            XOR     BX, BX
            MOV     SI, BX
            MOV     DI, BX
            MOV     CX, DX
            REP     MOVSW
            MOV     SI, BX
            MOV     DI, BX
            MOV     CX, DX
            STRT_TIM
            REP     MOVSW
            STOP_TIM
            RET
TEST64K_W   ENDP


TEST128K_D  PROC    NEAR
            MOV     DX, AX
            MOV     ES, AX
            MOV     DS, AX
            XOR     BX, BX
            MOV     SI, BX
            MOV     DI, BX
            MOV     CX, 16384
            REP     MOVSD
            MOV     AX, DX
            ADD     AX, 1000h
            MOV     ES, AX
            MOV     DS, AX
            MOV     CX, 16384
            REP     MOVSD
            MOV     ES, DX
            MOV     DS, DX
            MOV     CX, 16384
            STRT_TIM
            REP     MOVSD
            MOV     AX, DX
            ADD     AX, 1000h
            MOV     ES, AX
            MOV     DS, AX
            MOV     CX, 16384
            REP     MOVSD
            STOP_TIM
            RET
TEST128K_D  ENDP


TEST256K_D  PROC    NEAR
            MOV     DX, AX
            MOV     ES, AX
            MOV     DS, AX
            XOR     BX, BX
            MOV     SI, BX
            MOV     DI, BX
            MOV     CX, 16384
            REP     MOVSD
            MOV     AX, DX
            ADD     AX, 1000h
            MOV     ES, AX
            MOV     DS, AX
            MOV     CX, 16384
            REP     MOVSD
            MOV     AX, DX
            ADD     AX, 2000h
            MOV     ES, AX
            MOV     DS, AX
            MOV     CX, 16384
            REP     MOVSD
            MOV     AX, DX
            ADD     AX, 3000h
            MOV     ES, AX
            MOV     DS, AX
            MOV     CX, 16384
            REP     MOVSD
            MOV     ES, DX
            MOV     DS, DX
            MOV     CX, 16384
            STRT_TIM
            REP     MOVSD
            MOV     AX, DX
            ADD     AX, 1000h
            MOV     ES, AX
            MOV     DS, AX
            MOV     CX, 16384
            REP     MOVSD
            MOV     AX, DX
            ADD     AX, 2000h
            MOV     ES, AX
            MOV     DS, AX
            MOV     CX, 16384
            REP     MOVSD
            MOV     AX, DX
            ADD     AX, 3000h
            MOV     ES, AX
            MOV     DS, AX
            MOV     CX, 16384
            REP     MOVSD
            STOP_TIM
            RET
TEST256K_D  ENDP


TEST512K_D  PROC    NEAR
            MOV     DX, AX
            MOV     ES, AX
            MOV     DS, AX
            XOR     BX, BX
            MOV     SI, BX
            MOV     DI, BX
            MOV     CX, 16384
            REP     MOVSD
            MOV     AX, DX
            ADD     AX, 1000h
            MOV     ES, AX
            MOV     DS, AX
            MOV     CX, 16384
            REP     MOVSD
            MOV     AX, DX
            ADD     AX, 2000h
            MOV     ES, AX
            MOV     DS, AX
            MOV     CX, 16384
            REP     MOVSD
            MOV     AX, DX
            ADD     AX, 3000h
            MOV     ES, AX
            MOV     DS, AX
            MOV     CX, 16384
            REP     MOVSD
            MOV     AX, DX
            ADD     AX, 4000h
            MOV     ES, AX
            MOV     DS, AX
            MOV     CX, 16384
            REP     MOVSD
            MOV     AX, DX
            ADD     AX, 5000h
            MOV     ES, AX
            MOV     DS, AX
            MOV     CX, 16384
            REP     MOVSD
            MOV     AX, DX
            ADD     AX, 6000h
            MOV     ES, AX
            MOV     DS, AX
            MOV     CX, 16384
            REP     MOVSD
            MOV     AX, DX
            ADD     AX, 7000h
            MOV     ES, AX
            MOV     DS, AX
            MOV     CX, 16384
            REP     MOVSD
            MOV     ES, DX
            MOV     DS, DX
            MOV     CX, 16384
            STRT_TIM
            REP     MOVSD
            MOV     AX, DX
            ADD     AX, 1000h
            MOV     ES, AX
            MOV     DS, AX
            MOV     CX, 16384
            REP     MOVSD
            MOV     AX, DX
            ADD     AX, 2000h
            MOV     ES, AX
            MOV     DS, AX
            MOV     CX, 16384
            REP     MOVSD
            MOV     AX, DX
            ADD     AX, 3000h
            MOV     ES, AX
            MOV     DS, AX
            MOV     CX, 16384
            REP     MOVSD
            MOV     AX, DX
            ADD     AX, 4000h
            MOV     ES, AX
            MOV     DS, AX
            MOV     CX, 16384
            REP     MOVSD
            MOV     AX, DX
            ADD     AX, 5000h
            MOV     ES, AX
            MOV     DS, AX
            MOV     CX, 16384
            REP     MOVSD
            MOV     AX, DX
            ADD     AX, 6000h
            MOV     ES, AX
            MOV     DS, AX
            MOV     CX, 16384
            REP     MOVSD
            MOV     AX, DX
            ADD     AX, 7000h
            MOV     ES, AX
            MOV     DS, AX
            MOV     CX, 16384
            REP     MOVSD
            STOP_TIM
            RET
TEST512K_D  ENDP

TestCache   PROC    FAR
            PUSHF
            PUSH    DS
            CLI
            CLD
            IN      AL, 61h              ; Port B - System Control
            AND     AL, 11111101b        ; Lautsprecher-Bit ausschalten
            OR      AL, 1                ; Bit fÅr Clock 2 anschalten
            OUT     61h, AL              ; und auf Port zurÅckschreiben
            MOV     AX, 1000h
            MOV     DX, 256
            CALL    TEST64K_D
            MOV     CS:[Time1K], BX
            MOV     AX, 1000h
            MOV     DX, 512
            CALL    TEST64K_D
            MOV     CS:[Time2K], BX
            MOV     AX, 1000h
            MOV     DX, 1024
            CALL    TEST64K_D
            MOV     CS:[Time4K], BX
            MOV     AX, 1000h
            MOV     DX, 2048
            CALL    TEST64K_D
            MOV     CS:[Time8K], BX
            MOV     AX, 1000h
            MOV     DX, 4096
            CALL    TEST64K_D
            MOV     CS:[Time16K], BX
            MOV     AX, 1000h
            MOV     DX, 8192
            CALL    TEST64K_D
            MOV     CS:[Time32K], BX
            MOV     AX, 1000h
            MOV     DX, 16384
            CALL    TEST64K_D
            MOV     CS:[Time64K], BX
            MOV     AX, 1000h
            CALL    TEST128K_D
            MOV     CS:[Time128K], BX
            MOV     AX, 1000h
            CALL    TEST256K_D
            MOV     CS:[Time256K], BX
            MOV     AX, 1000h
            CALL    TEST512K_D
            MOV     CS:[Time512K], BX
            MOV     DX, CS
            MOV     AX, OFFSET [Time1K]
            POP     DS
            POPF
            RET


TestCach286 PROC    FAR
            PUSHF
            PUSH    DS
            CLI
            CLD
            MOV     AX, 1000h
            IN      AL, 61h              ; Port B - System Control
            AND     AL, 11111101b        ; Lautsprecher-Bit ausschalten
            OR      AL, 1                ; Bit fÅr Clock 2 anschalten
            OUT     61h, AL              ; und auf Port zurÅckschreiben
            MOV     DX, 512
            CALL    TEST64K_W
            MOV     CS:[Time1K], BX
            MOV     AX, 1000h
            MOV     DX, 1024
            CALL    TEST64K_W
            MOV     CS:[Time2K], BX
            MOV     AX, 1000h
            MOV     DX, 2048
            CALL    TEST64K_W
            MOV     CS:[Time4K], BX
            MOV     AX, 1000h
            MOV     DX, 4096
            CALL    TEST64K_W
            MOV     CS:[Time8K], BX
            MOV     AX, 1000h
            MOV     DX, 8192
            CALL    TEST64K_W
            MOV     CS:[Time16K], BX
            MOV     AX, 1000h
            MOV     DX, 16384
            CALL    TEST64K_W
            MOV     CS:[Time32K], BX
            MOV     AX, 1000h
            MOV     DX, 32768
            CALL    TEST64K_W
            MOV     CS:[Time64K], BX
            MOV     DX, CS
            MOV     AX, OFFSET [Time1K]
            POP     DS
            POPF
            RET
TestCach286 ENDP

Time1K      DW      ?
Time2K      DW      ?
Time4K      DW      ?
Time8K      DW      ?
Time16K     DW      ?
Time32K     DW      ?
Time64K     DW      ?
Time128K    DW      ?
Time256K    DW      ?
Time512K    DW      ?

TestCache   ENDP

.286
.8087

; Original Assemblercode fÅr die Peak-MFLOPS

; FILE: APFELM4.ASM

APPLE87     PROC    NEAR
            PUSH    BP                  ; save caller's base pointer
            MOV     BP, SP              ; make new frame pointer
            PUSH    DS                  ; save caller's data segment
            PUSH    SI                  ; save register
            PUSH    DI                  ;  variables
            LDS     BX, [BP+04]         ; pointer to parameter record
            FINIT                       ; init 80x87          FSP->R0
            FILD   WORD  PTR [BX+02]    ; maxrad              FSP->R7
            FLD    QWORD PTR [BX+08]    ; qmax                FSP->R6
            FSUB   QWORD PTR [BX+16]    ; qmax-qmin           FSP->R6
            DEC    WORD  PTR [BX+04]    ; ymax-1
            FIDIV  WORD  PTR [BX+04]    ; (qmax-qmin)/(ymax-1)FSP->R6
            FSTP   QWORD PTR [BX+16]    ; save delta_q        FSP->R7
            FLD    QWORD PTR [BX+24]    ; pmax                FSP->R6
            FSUB   QWORD PTR [BX+32]    ; pmax-pmin           FSP->R6
            DEC    WORD  PTR [BX+06]    ; xmax-1
            FIDIV  WORD  PTR [BX+06]    ; delta_p             FSP->R6
            MOV    AX, [BX]             ; save maxiter,[BX] needed for
            MOV    [BX+2], AX           ;  80x87 status now
            XOR    BP, BP               ; y=0
            FLD    QWORD PTR [BX+08]    ; qmax                FSP->R5
            CMP    WORD  PTR [BX+40], 0 ; fast mode on 8087 desired ?
            JE     yloop                ; no, normal mode
            FSTCW  [BX]                 ; save NDP control word
            AND    WORD PTR [BX], 0FCFFh; set PCTRL = single-precision
            FLDCW  [BX]                 ; get back NDP control word
yloop:      XOR    DI, DI               ; x=0
            FLD    QWORD PTR [BX+32]    ; pmin                FSP->R4
xloop:      FLDZ                        ; j**2= 0             FSP->R3
            FLDZ                        ; 2ij = 0             FSP->R2
            FLDZ                        ; i**2= 0             FSP->R1
            MOV    CX, [BX+2]           ; maxiter
            MOV    DL, 41h              ; mask for C0 and C3 cond.bits
iteration:  FSUB   ST, ST(2)            ; i**2-j**2           FSP->R1
            FADD   ST, ST(3)            ; i**2-j**2+p = i     FSP->R1
            FLD    ST(0)                ; duplicate i         FSP->R0
            FMUL   ST(1), ST            ; i**2                FSP->R0
            FADD   ST, ST(0)            ; 2i                  FSP->R0
            FXCH   ST(2)                ; 2*i*j               FSP->R0
            FADD   ST, ST(5)            ; 2*i*j+q = j         FSP->R0
            FMUL   ST(2), ST            ; 2*i*j               FSP->R0
            FMUL   ST, ST(0)            ; j**2                FSP->R0
            FST    ST(3)                ; save j**2           FSP->R0
            FADD   ST, ST(1)            ; i**2+j**2           FSP->R0
            FCOMP  ST(7)                ; i**2+j**2 > maxrad? FSP->R1
            FSTSW  [BX]                 ; save 80x87 cond.codeFSP->R1
            TEST   BYTE PTR [BX+1], DL  ; test carry and zero flags
            LOOPNZ iteration            ; until maxiter if not diverg.
            MOV    DX, CX               ; number of loops executed
            NEG    CX                   ; carry set if CX <> 0
            ADC    DX, 0                ; adjust DX if no. of loops<>0

            ; plot point here (DI = X, BP = y, DX has the color)

            FSTP   ST(0)                ; pop i**2            FSP->R2
            FSTP   ST(0)                ; pop 2ij             FSP->R3
            FSTP   ST(0)                ; pop j**2            FSP->R4
            FADD   ST,ST(2)             ; p=p+delta_p         FSP->R4
            INC    DI                   ; x:=x+1
            CMP    DI, [BX+6]           ; x > xmax ?
            JBE    xloop                ; no, continue on same line
            FSTP   ST(0)                ; pop p               FSP->R5
            FSUB   QWORD PTR [BX+16]    ; q=q-delta_q         FSP->R5
            INC    BP                   ; y:=y+1
            CMP    BP, [BX+4]           ; y > ymax ?
            JBE    yloop                ; no, picture not done yet

groesser:   POP    DI                   ; restore
            POP    SI                   ;  register variables
            POP    DS                   ; restore caller's data segm.
            POP    BP                   ; save caller's base pointer
            RET    4                    ; pop parameters and return

APPLE87     ENDP


; Original Assemblercode fÅr die Transformation-MFLOPS
; FILE: M4X4.ASM

FSBP0     EQU     DB  0DBh, 0E8h        ; declare special IIT
FSBP1     EQU     DB  0DBh, 0EBh        ;  instructions
FSBP2     EQU     DB  0DBh, 0EAh
F4X4      EQU     DB  0DBh, 0F1h

;---------------------------------------------------------------------
;
; MUL_4x4 multiplicates a four-by-four matrix by an array of four
; dimensional vectors. This operation is needed for 3D transformations
; in graphics data processing. There are arrays for each component of
; a vector. Thus there is an ; array containing all the x components,
; another containing all the y components and so on. Each component is
; an 8 byte IEEE floating-point number. Two indices into the array of
; vectors are given. The first is the index of the vector that will be
; processed first, the second is the index of the vector processed
; last.
;
;---------------------------------------------------------------------

MUL_4x4   PROC    NEAR

            AddrX   EQU DWORD PTR [BP+24] ; address of X component array
            AddrY   EQU DWORD PTR [BP+20] ; address of Y component array
            AddrZ   EQU DWORD PTR [BP+16] ; address of Z component array
            AddrW   EQU DWORD PTR [BP+12] ; address of W component array
            AddrT   EQU DWORD PTR [BP+8]  ; addr. of 4x4 transform. mat.
            F       EQU WORD  PTR [BP+6]  ; first vector to process
            K       EQU WORD  PTR [BP+4]  ; last vector to process
            RetAddr EQU WORD  PTR [BP+2]  ; return address saved by call
            SavdBP  EQU WORD  PTR [BP+0]  ; saved frame pointer
            SavdDS  EQU WORD  PTR [BP-2]  ; caller's data segment

            PUSH    BP                    ; save TURBO-Pascal frame ptr
            MOV     BP, SP                ; new frame pointer
            PUSH    DS                    ; save TURBO-Pascal data segmnt

            MOV     CX, K                 ; final index
            SUB     CX, F                 ; final index - start index
            JNC     $ok                   ; must not
            JMP     $nothing              ;  be negative
  $ok:      INC     CX                    ; number of elements

            MOV     SI, F                 ; init offset into arrays
            SHL     SI, 1                 ; each
            SHL     SI, 1                 ;  element
            SHL     SI, 1                 ;   has 8 bytes

            LDS     DI, AddrT             ; addr. of transformation mat.
            FLD     QWORD PTR [DI]        ; load a[0,0]   = R7
            FLD     QWORD PTR [DI+8]      ; load a[0,1]   = R6

  $mat_mul: LES     BX, AddrX             ; addr. of x component array
            FLD     QWORD PTR ES:[BX+SI]  ; load x[a]     = R5
            LES     BX, AddrY             ; addr. of y component array
            FLD     QWORD PTR ES:[BX+SI]  ; load y[a]     = R4
            LES     BX, AddrZ             ; addr. of z component array
            FLD     QWORD PTR ES:[BX+SI]  ; load z[a]     = R3
            LES     BX, AddrW             ; addr. of w component array
            FLD     QWORD PTR ES:[BX+SI]  ; load w[a]     = R2

            FLD     ST(5)                 ; load a[0,0]   = R1
            FMUL    ST, ST(4)             ; a[0,0] * x[a] = R1
            FLD     ST(5)                 ; load a[0,1]   = R0
            FMUL    ST, ST(4)             ; a[0,1] * y[a] = R0
            FADDP   ST(1), ST             ; a[0,0]*x[a]+a[0,1]*y[a]=R1
            FLD     QWORD PTR [DI+16]     ; load a[0,2]   = R0
            FMUL    ST, ST(3)             ; a[0,2] * z[a] = R0
            FADDP   ST(1), ST             ; a[0,0]*x[a]...a[0,2]*z[a]=R1
            FLD     QWORD PTR [DI+24]     ; load a[0,3]   = R0
            FMUL    ST, ST(2)             ; a[0,3] * w[a] = R0
            FADDP   ST(1), ST             ; a[0,0]*x[a]...a[0,3]*w[a]=R1
            LES     BX, AddrX             ; get address of x vector
            FSTP    QWORD PTR ES:[BX+SI]  ; write new x[a]

            FLD     QWORD PTR [DI+32]     ; load a[1,0]   = R1
            FMUL    ST, ST(4)             ; a[1,0] * x[a] = R1
            FLD     QWORD PTR [DI+40]     ; load a[1,1]   = R0
            FMUL    ST, ST(4)             ; a[1,1] * y[a] = R0
            FADDP   ST(1), ST             ; a[1,0]*x[a]+a[1,1]*y[a]=R1
            FLD     QWORD PTR [DI+48]     ; load a[1,2]   = R0
            FMUL    ST, ST(3)             ; a[1,2] * z[a] = R0
            FADDP   ST(1), ST             ; a[1,0]*x[a]...a[1,2]*z[a]=R1
            FLD     QWORD PTR [DI+56]     ; load a[1,3]   = R0
            FMUL    ST, ST(2)             ; a[1,3] * w[a] = R0
            FADDP   ST(1), ST             ; a[1,0]*x[a]...a[1,3]*w[a]=R1
            LES     BX, AddrY             ; get address of y vector
            FSTP    QWORD PTR ES:[BX+SI]  ; write new y[a]

            FLD     QWORD PTR [DI+64]     ; load a[2,0]   = R1
            FMUL    ST, ST(4)             ; a[2,0] * x[a] = R1
            FLD     QWORD PTR [DI+72]     ; load a[2,1]   = R0
            FMUL    ST, ST(4)             ; a[2,1] * y[a] = R0
            FADDP   ST(1), ST             ; a[2,0]*x[a]+a[2,1]*y[a]=R1
            FLD     QWORD PTR [DI+80]     ; load a[2,2]   = R0
            FMUL    ST, ST(3)             ; a[2,2] * z[a] = R0
            FADDP   ST(1), ST             ; a[2,0]*x[a]...a[2,2]*z[a]=R1
            FLD     QWORD PTR [DI+88]     ; load a[2,3]   = R0
            FMUL    ST, ST(2)             ; a[2,3] * w[a] = R0
            FADDP   ST(1), ST             ; a[2,0]*x[a]...a[2,3]*w[a]=R1
            LES     BX, AddrZ             ; get address of z vector
            FSTP    QWORD PTR ES:[BX+SI]  ; write new z[a]

            FLD     QWORD PTR [DI+96]     ; load a[3,0]   = R1
            FMULP   ST(4), ST             ; a[3,0] * x[a] = R5
            FLD     QWORD PTR [DI+104]    ; load a[3,1]   = R1
            FMULP   ST(3), ST             ; a[3,1] * y[a] = R4
            FLD     QWORD PTR [DI+112]    ; load a[3,2]   = R1
            FMULP   ST(2), ST             ; a[3,2] * z[a] = R3
            FLD     QWORD PTR [DI+120]    ; load a[3,3]   = R1
            FMULP   ST(1), ST             ; a[3,3] * w[a] = R2
            FADDP   ST(1), ST             ; a[3,3]*w[a]+a[3,2]*z[a]=R3
            FADDP   ST(1), ST             ; a[3,3]*w[a]...a[3,1]*y[a]=R4
            FADDP   ST(1), ST             ; a[3,3]*w[a]...a[3,0]*x[a]=R5
            LES     BX, AddrW             ; get address of w vector
            FSTP    QWORD PTR ES:[BX+SI]  ; write new w[a]

            ADD     SI, 8                 ; new offset into arrays
            DEC     CX                    ; decrement element counter
            JZ      $done                 ; no elements left, done
            JMP     $mat_mul              ; transform next vector

  $done:    FSTP     ST(0)                ; clear
            FSTP     ST(0)                ;  FPU stack
  $nothing: POP      DS                   ; restore TP data segment
            POP      BP                   ; restore TP frame pointer
            RET      24                   ; pop parameters and return

  MUL_4X4   ENDP


;---------------------------------------------------------------------
;
; IIT_MUL_4x4 multiplicates a four-by-four matrix by an array of four
; dimensional vectors. This operation is needed for 3D transformations
; in graphics data processing. There are arrays for each component of
; a vector.  Thus there is an array containing all the x components,
; another containing all the y components and so on. Each component is
; an 8 byte IEEE floating-point number. Two indices into the array of
; vectors are given. The first is the index of the vector that will be
; processed first, the second is the index of the vector processed
; last. This subroutine uses the special instructions only available
; on IIT coprocessors to provide fast matrix multiply capabilities.
; So make sure to use it only on IIT coprocessors.
;
;---------------------------------------------------------------------

IIT_MUL_4x4   PROC    NEAR

            AddrX   EQU DWORD PTR [BP+24] ; address of X component array
            AddrY   EQU DWORD PTR [BP+20] ; address of Y component array
            AddrZ   EQU DWORD PTR [BP+16] ; address of Z component array
            AddrW   EQU DWORD PTR [BP+12] ; address of W component array
            AddrT   EQU DWORD PTR [BP+8]  ; addr. of 4x4 transf. matrix
            F       EQU WORD  PTR [BP+6]  ; first vector to process
            K       EQU WORD  PTR [BP+4]  ; last vector to process
            RetAddr EQU WORD  PTR [BP+2]  ; return address saved by call
            SavdBP  EQU WORD  PTR [BP+0]  ; saved frame pointer
            SavdDS  EQU WORD  PTR [BP-2]  ; caller's data segment
            Ctrl87  EQU WORD  PTR [BP-4]  ; caller's 80x87 control word

            PUSH    BP                    ; save TURBO-Pascal frame ptr
            MOV     BP, SP                ; new frame pointer
            PUSH    DS                    ; save TURBO-Pascal data seg.
            SUB     SP, 2                 ; make local variabe
            FSTCW   [Ctrl87]              ; save 80x87 ctrl word
            LES     SI, AddrT             ; ptr to transformation matrix
            FINIT                         ; initialize coprocessor
            FSBP2                         ; set register bank 2
            FLD     QWORD PTR ES:[SI]     ; load a[0,0]
            FLD     QWORD PTR ES:[SI+32]  ; load a[1,0]
            FLD     QWORD PTR ES:[SI+64]  ; load a[2,0]
            FLD     QWORD PTR ES:[SI+96]  ; load a[3,0]
            FLD     QWORD PTR ES:[SI+8]   ; load a[0,1]
            FLD     QWORD PTR ES:[SI+40]  ; load a[1,1]
            FLD     QWORD PTR ES:[SI+72]  ; load a[2,1]
            FLD     QWORD PTR ES:[SI+104] ; load a[3,1]
            FINIT                         ; initialize coprocessor
            FSBP1                         ; set register bank 1
            FLD     QWORD PTR ES:[SI+16]  ; load a[0,2]
            FLD     QWORD PTR ES:[SI+48]  ; load a[1,2]
            FLD     QWORD PTR ES:[SI+80]  ; load a[2,2]
            FLD     QWORD PTR ES:[SI+112] ; load a[3,2]
            FLD     QWORD PTR ES:[SI+24]  ; load a[0,3]
            FLD     QWORD PTR ES:[SI+56]  ; load a[1,3]
            FLD     QWORD PTR ES:[SI+88]  ; load a[2,3]
            FLD     QWORD PTR ES:[SI+120] ; load a[3,3]

                                          ; transformation matrix loaded

            MOV     AX, F                 ; index of first vector
            MOV     DX, K                 ; index of last vector

            MOV     BX, AX                ; index 1st vector to process
            MOV     CL, 3                 ; component has 8 (2**3) bytes
            SHL     BX, CL                ; compute offset into arrays

            FINIT                         ; initialize coprocessor
            FSBP0                         ; set register bank 0

  $mat_loop:LES     SI, AddrW             ; addr. of W component array
            FLD     QWORD PTR ES:[SI+BX]  ; W component current vector
            LES     SI, AddrZ             ; addr. of Z component array
            FLD     QWORD PTR ES:[SI+BX]  ; Z component current vector
            LES     SI, AddrY             ; addr. of Y component array
            FLD     QWORD PTR ES:[SI+BX]  ; Y component current vector
            LES     SI, AddrX             ; addr. of X component array
            FLD     QWORD PTR ES:[SI+BX]  ; X component current vector
            F4X4                          ; mul 4x4 matrix by 4x1 vector
            INC     AX                    ; next vector
            MOV     DI, AX                ; next vector
            SHL     DI, CL                ; offset of vector into arrays

            FSTP    QWORD PTR ES:[SI+BX]  ; store X comp. of curr. vect.
            LES     SI, AddrY             ; address of Y component array
            FSTP    QWORD PTR ES:[SI+BX]  ; store Y comp. of curr. vect.
            LES     SI, AddrZ             ; address of Z component array
            FSTP    QWORD PTR ES:[SI+BX]  ; store Z comp. of curr. vect.
            LES     SI, AddrW             ; address of W component array
            FSTP    QWORD PTR ES:[SI+BX]  ; store W comp. of curr. vect.

            MOV     BX, DI                ; ofs nxt vect. in comp. arrays
            CMP     AX, DX                ; nxt vector past upper bound?
            JLE     $mat_loop             ; no, transform next vector
            FLDCW   [Ctrl87]              ; restore orig 80x87 ctrl word

            ADD      SP, 2                ; get rid of local variable
            POP      DS                   ; restore TP data segment
            POP      BP                   ; restore TP frame pointer
            RET      24                   ; pop parameters and return
IIT_MUL_4x4   ENDP

.286p
CPUReset   PROC    Far
        push    bp
        mov     bp,sp
        push    ds
        smsw    ax              ; get machine status
        test    ax,1            ; test if protected mode
        jz      ok              ; jump if not
        xor     ax, ax          ; leeren
        jmps EndProc
ok:
        cli                     ;no interrupts
        mov     cs:_sp,sp       ;save sp
        mov     cs:_ss,ss       ;save ss
        mov     cs:_bp,bp
        mov     cs:_ds,ds       ;save ds
        sti                     ;enable interrupts
        mov     al,8fh          ;CMOS addr 0fh ; disable NMI (bit 7 set)
        out     70h,al          ;CMOS addr select
        jmp     $+2             ;delay for io
        jmp     $+2
        jmp     $+2
        mov     al,0ah          ;shutdown value (0ah)
        out     71h,al          ;write CMOS
        mov     ax,40h          ;BIOS data segment
        mov     es,ax           ;set es
        mov     word ptr es:[67h],offset hopp ;set shutdown offset
        mov     word ptr es:[69h],cs          ;set shutdown segment
        mov     al,0feh         ;value for keyb.controller
        out     64h,al          ;pulse cpu reset

        ;should never reach this far.
        jmps EndProc

hopp:   cli                     ;shutdown entry addr
        mov     ds,cs:_ds       ;load ds
        mov     sp,cs:_sp       ;load sp
        mov     ss,cs:_ss       ;load ss
        mov     bp,cs:_bp
        mov     ax,dx           ;get cpu MaskNumber (stored in dx after reset)
        sti                     ;enable interrupts
EndProc:
        mov ah, 0Dh             ; Irgendetwas mu· man hier anscheinend
        int 21h                 ; machen. Ich hab'den Disk-Reset genommen.
        mov     ax,dx           ;get cpu MaskNumber (stored in dx after reset)
        pop     ds
        pop     bp
        retf

_ds     dw      0               ;
_sp     dw      0               ;
_bp     dw      0               ;
_ss     dw      0               ;
CPUReset EndP


TestForEFlag21  proc    far
.486
        push    bp
        mov     bp,sp
        push    ds

        pushfd
        pop ecx
        mov eax, ecx
        xor eax, 200000h
        push eax
        popfd
        pushfd
        pop eax
        xor eax, ecx
        mov al, 0
        je NoCPUID
        mov al, 1
     NoCPUID:
        pop     ds
        pop     bp
        ret     4
.286
TestForEFlag21  endp


MSRReader  proc    far

; Diese Prcedure noch NICHT benutzen !!! Sie ist noch im Test/Erweiterungs-
; stadium !!!

v_MSR   equ     [bp + 6]
v_EAX   equ     [bp + 8]
v_EDX   equ     [bp + 12]

        push    bp
        mov     bp,sp
        push    ds
.486
        mov ECX, dword ptr [v_MSR]
        rdmsr
        mov dword ptr [v_EAX], EAX
        mov dword ptr [v_EDX], EDX
.286
        pop     ds
        pop     bp
        ret     4
MSRReader   endp


code    ends

;--------------------------------------------------------------------

DATA    segment byte

; redirected INT 01H vector

old_int01       label   dword
old_int01_ofs   dw      ?
old_int01_seg   dw      ?

; storage for DISKREAD
; DOS 4.0 extended read parameter block
dos4_block                      label   byte
extd_starting_sector_lo         dw      ?
extd_starting_sector_hi         dw      ?
extd_number_of_sectors          dw      ?
extd_bufofs                     dw      ?
extd_bufseg                     dw      ?

; Einige Variablen fÅr den FDIV-Test
x   dd      4195835
y   dd      3145727

; Dos-Test-String

DosTestStr db ' $'

; FÅr den Cyrix-Test :
fVor  dw ?
fNach dw ?

; FÅr die Disk-Funktionen
curdrive        db      0
; default to not exist, fixed, local, hard drive

DATA    ends

        end
