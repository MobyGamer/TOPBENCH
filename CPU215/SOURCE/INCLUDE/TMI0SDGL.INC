; -----------------------------------------------------------------------------
; TMI0SDGL.INC - Common TMi0SDGL 2 macros and defines             Version 2.15
;
; Too-Much-in-0ne-So-Don't-Get-Lost(tm) Revision 2 CPU/FPU Detection Library
; Copyright(c) 1996-2000 by B-coolWare. Written by Bobby Z.
; -----------------------------------------------------------------------------
;

; CPU codes

        i8088           equ     0       ; direct detect
        i8086           equ     1       ; direct detect
        i80C88          equ     2       ; direct detect
        i80C86          equ     3       ; direct detect
        i80188          equ     4       ; direct detect
        i80186          equ     5       ; direct detect
        necV20          equ     6       ; direct detect
        necV30          equ     7       ; direct detect
        i80286          equ     8       ; direct detect
        i80386sx        equ     9       ; direct detect
        i80386dx        equ     10      ; direct detect
        i386sl          equ     11      ; direct detect
        ibm386slc       equ     12      ; direct detect (real mode only)
        am386sx         equ     13      ; direct detect
        am386dx         equ     14      ; direct detect
        ct38600         equ     15      ; direct detect
        ct38600sx       equ     16      ; direct detect
        RapidCAD        equ     17      ; direct detect
        i486sx          equ     18      ; direct detect (models distinguished..)
        i486dx          equ     19      ; direct detect (..sometimes)
        ibm486slc       equ     20      ; direct detect (real mode only)
        ibm486slc2      equ     21      ; direct detect (real mode only)
        ibm486bl3       equ     22      ; direct detect (real mode only)
        Cx486           equ     23      ; direct detect (models distinguished)
        umcU5S          equ     24      ; direct detect (CPUID)
        umcU5D          equ     25      ; direct detect (CPUID)
        am486           equ     26      ; direct detect (CPUID)
        iPentium        equ     27      ; direct detect (models distinguished)
        iP54C           equ     28      ; direct detect (CPUID)
        CxM1            equ     29      ; direct detect (CPUID)
        amdK5           equ     30      ; direct detect (CPUID)
        Nx586           equ     31      ; direct detect
        iPentiumPro     equ     32      ; direct detect (models distinguished)
        amdK6           equ     33      ; direct detect (CPUID)
        iP7             equ     34      ; direct detect (CPUID)
        iP8             equ     35      ; direct detect (CPUID)
        CxM2            equ     36      ; direct detect (CPUID)
        am486dx         equ     37      ; direct detect
        amdK5_2         equ     38      ; direct detect (CPUID)
        WinChipC6       equ     39      ; direct detect (CPUID)
        i486sl          equ     40      ; direct detect
        AmdK7           equ     41      ; direct detect (CPUID)
        WinChip2        equ     42      ; direct detect (CPUID)
        Rise_mP6        equ     43      ; direct detect (CPUID)
        i376            equ     44      ; direct detect
        WinChip3        equ     45      ; direct detect
        CxIII           equ     46      ; direct detect

; FPU codes

        fpuInternal     equ     100
        fpuNone         equ     0
        i8087           equ     1
        i80287          equ     2
        i80287xl        equ     3
        i80387          equ     4
        rCAD            equ     5
        cx287           equ     6
        cx387           equ     7
        cx487           equ     8
        cxEMC87         equ     9
        iit287          equ     10
        iit387          equ     11
        iit487          equ     12
        ct387           equ     13
        ulsi387         equ     14
        ulsi487         equ     15
        i487sx          equ     16      ; this is actually a 486DX
        Nx587           equ     17
        iit487DLC       equ     18
        i387SLMobile    equ     19

; flags

        EF_AC   equ     00040000h       ; AC bit of EFLAGS
        EF_ID   equ     00200000h       ; ID bit of EFLAGS
        MSW_ET  equ     00000010h       ; ET bit of MSW
        MSW_NE  equ     00000020h       ; NE bit of MSW

        efHasFPUonChip  equ     0001h
        efWeitekPresent equ     0002h
        efCPUIDSupport  equ     0004h
        efDXType        equ     efCPUIDSupport+efHasFPUonChip
        efEmulatedFPU   equ     0008h
        efCentaurLevel  equ     0010h
        efTSCSupport    equ     0020h

; macros

; _CPUID - a combination macro for TASM 3.x and TASM 4.x or later
; first don't support CPUID, second does.

_cpuid   macro
IF ??version LT 400h
        db      0Fh,0A2h
ELSE
        .586
        cpuid
ENDIF
        endm

; read MSR and write MSR macros

IF ??version LT 400h

_rdmsr  macro   Reg                     ; new 486 and Pentium instruction
        .386
        mov     ecx,Reg                 ; read MSR #ECX into EDX:EAX
        db      0Fh,32h
        endm
_wrmsr  macro   Reg                     ; new 486 and Pentium instruction
        .386
        mov     ecx,Reg                 ; write MSR #ECX from EDX:EAX
        db      0Fh,30h
        endm
ELSE

_rdmsr  macro   Reg
        .586p
        mov     ecx,Reg
        rdmsr
        endm

_wrmsr  macro   Reg
        .586p
        mov     ecx,Reg
        wrmsr
        endm

ENDIF

; read TSC (time stamp counter) macro

_rdtsc  macro
IFDEF   __Use_MSR_TSC__
        push    ecx
        _rdmsr  10h
        pop     ecx
ELSE
 IF ??version LT 500h   ; this istruction is supported in TASM 5.0 and later
        db 0Fh,31h
 ELSE
        .686p
        rdtsc
 ENDIF
ENDIF
        endm

_getcr4 macro
IF ??version LT 400h
        .386
        db      0Fh,20h,0E0h
ELSE
        .586p
        mov     eax,cr4
ENDIF
        endm

; my PDP-like command macros :)

clr     macro   reg
        sub     reg,reg
        endm

ldx     macro   value
        mov     dx,offset value
        endm

ldi     macro   value
        mov     di,offset value
        endm

lsi     macro   value
        mov     si,offset value
        endm

lbx     macro   value
        mov     bx,offset value
        endm


; equivalents

_bp     equ     <byte ptr>      ; byte ref       (8)
_wp     equ     <word ptr>      ; word ref       (16)
_dp     equ     <dword ptr>     ; doubleword ref (32 or 16:16)
_qp     equ     <qword ptr>     ; quadraword ref (32:32)
_tp     equ     <tbyte ptr>     ; terabyte ref   (10 bytes)
_np     equ     <near ptr>      ; near ref       (16 or 32)
_fp     equ     <far ptr>       ; far ref        (16:16)
_fpp    equ     <fword ptr>     ; far pm ref     (16:32)


        .DATA                   ; data segment

IFDEF   __32bit__
 IFDEF __Windows__
  IFNDEF __D32__
  __Win32__ = 1
  ENDIF
 ENDIF
ENDIF

IFDEF __Win32__
GLOBAL  CPU : BYTE
GLOBAL  FPU : BYTE
; many suggestions are made based on following variables
GLOBAL  EXTFLAGS : WORD         ; some extra flags (see efXXXX constants)
GLOBAL  CPUID0  : BYTE : 12     ; Maker Id
GLOBAL  CPUID1  : DWORD         ; CPU Submodel/Family/Model/Step
GLOBAL  CPUBRAND : DWORD        ; CPU brand (Xeon, etc.)
GLOBAL  CPUFEATURES : DWORD     ; CPU features

; do not change following variables from your program.

GLOBAL  FPUDENORMAL : TBYTE     ; is a constant
GLOBAL  FPUOP1  : TBYTE         ; is a constant
GLOBAL  FPU_53BIT_PREC : WORD   ; is a constant
GLOBAL  SPEEDSHIFT : WORD       ; is a variable

ELSE

GLOBAL  cpu : BYTE
GLOBAL  fpu : BYTE
; many suggestions are made based on following variables
GLOBAL  extFlags : WORD         ; some extra flags (see efXXXX constants)
GLOBAL  cpuid0  : BYTE : 12     ; Maker Id
GLOBAL  cpuid1  : DWORD         ; CPU Submodel/Family/Model/Step
GLOBAL  cpuBrand : DWORD        ; CPU brand (Xeon, etc.)
GLOBAL  cpuFeatures : DWORD     ; CPU features

; do not change following variables from your program.

GLOBAL  fpuDenormal : TBYTE     ; is a constant
GLOBAL  fpuOp1  : TBYTE         ; is a constant
GLOBAL  fpu_53bit_prec : WORD   ; is a constant
GLOBAL  speedShift : WORD       ; is a variable
ENDIF

        .CODE                   ; code follows

