; -----------------------------------------------------------------------------
; HEADER.ASH - TMi0SDGL Revision 2 Assembler Header               Version 2.15
;
; Too-Much-in-0ne-So-Don't-Get-Lost(tm) Revision 2 CPU/FPU Detection Library
; Copyright(c) 1996-2000 by B-coolWare. Written by Bobby Z.
; -----------------------------------------------------------------------------
; This file is INCLUDEd in all assembler modules of the library.
;
; defines that affect compilation:
;
; __32bit__     type: define
;               default: not defined
;               purpose: to compile code and data as USE32 segments as well
;                        as use 32-bit version of DPMICODE.ASM.
; should not be defined with Borland Pascal 7 - it does not support 32-bit
; protected mode program generation.
;
; __Windows__   type: define
;               default: not defined
;               purpose: to force TASM to add Windows entry/exit code to
;                        public routines (for use in DLL).
;
; __Use_MSR_TSC__  type: define
;                  default: not defined
;                  purpose: to force _RDTSC macro to use RDMSR instruction
;                           for obtaining TSC value instead of RDTSC.
;                           Primarily to workaround an EMM386 bug(?) that
;                           generates a crash on RDTSC instruction.


; Global conditional defines
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
; __32bit__             equ     1
; __Windows__           equ     1
; __Use_MSR_TSC__       equ     1


IF ??version LT 300h
 .out This code requires Turbo Assembler Version 3.x or later
 .err
ENDIF

IFDEF   __32bit__
        .386
IFDEF   __Windows__
        MODEL   FLAT, WINDOWS STDCALL
ELSE
        MODEL   FLAT, PASCAL
ENDIF
        DIST    equ   <>        ; use default distance
ELSE

        ; set memory model and calling convention

IFNDEF  __Windows__

IFNDEF __HUGE__
 IFNDEF __LARGE__
  IFNDEF __MEDIUM__
   IFNDEF __COMPACT__
    IFNDEF __SMALL__
     IFNDEF __TINY__
        %out Must define a memory model
        .err
     ELSE
      MODEL TINY, PASCAL
      DIST  EQU  <NEAR>
     ENDIF
    ELSE
     MODEL SMALL, PASCAL
     DIST  EQU   <NEAR>
    ENDIF
   ELSE
    MODEL COMPACT, PASCAL
    DIST   EQU   <NEAR>
   ENDIF
  ELSE
   MODEL MEDIUM, PASCAL
   DIST    EQU   <FAR>
  ENDIF
 ELSE
  MODEL LARGE, PASCAL
  DIST     EQU   <FAR>
 ENDIF
ELSE
 MODEL HUGE, PASCAL
 DIST      EQU   <FAR>
ENDIF

ELSE

IFNDEF __HUGE__
 IFNDEF __LARGE__
  IFNDEF __MEDIUM__
   IFNDEF __COMPACT__
    IFNDEF __SMALL__
     IFNDEF __TINY__
        %out Must define a memory model
        .err
     ELSE
      MODEL TINY, WINDOWS PASCAL
      DIST  EQU  <NEAR>
     ENDIF
    ELSE
     MODEL SMALL, WINDOWS PASCAL
     DIST  EQU   <NEAR>
    ENDIF
   ELSE
    MODEL COMPACT, WINDOWS PASCAL
    DIST   EQU   <NEAR>
   ENDIF
  ELSE
   MODEL MEDIUM, WINDOWS PASCAL
   DIST    EQU   <FAR>
  ENDIF
 ELSE
  MODEL LARGE, WINDOWS PASCAL
  DIST     EQU   <FAR>
 ENDIF
ELSE
 MODEL HUGE, WINDOWS PASCAL
 DIST      EQU   <FAR>
ENDIF

ENDIF   ; __Windows__

ENDIF   ; __32bit__

INCLUDE TMI0SDGL.INC            ; Include TMi0SDL-specific defines

        LOCALS  @@              ; enable local symbols
        JUMPS                   ; enable jump optimization

