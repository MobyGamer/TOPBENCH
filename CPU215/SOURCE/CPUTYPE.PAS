{ --------------------------------------------------------------------------- }
{ CPUTYPE.PAS   Turbo Pascal TMi0SDGL 2 interface unit.         Version 2.15  }
{                                                                             }
{ Too-Much-in-0ne-So-Don't-Get-Lost(tm) Revision 2 CPU/FPU detection library. }
{ Copyright(c) 1996-2000 by B-coolWare.  Written by Bobby Z.                  }
{ --------------------------------------------------------------------------- }

{$IFDEF FPC}
{$DEFINE _32bit}
{$ASMMODE Intel}
{$ENDIF}

{$IFNDEF FPC}
{$A+,B-,D+,E-,F-,G-,I-,L+,N-,O-,P+,Q+,R+,S-,T-,V-,X+}
{$ELSE}
{D+,E-,I-,L+,P+,Q+,R+,S-,T-,V-,X+}
{$ENDIF}

{$IFDEF Win32}
{$H-}
{$DEFINE _32bit}
{$ENDIF}

{8088 specific optimizations:}
{$O+,F+,N-}

unit CPUType;

interface

type
        cpuid1Layout = record
                        Extra : Byte;
                        Family: Byte;
                        Model : Byte;
                        Step  : Byte;
                       end;

        customCpuid = record
                        eax,
                        ebx,
                        ecx,
                        edx   : {$IFDEF WIN32} Integer {$ELSE} LongInt {$ENDIF};
                      end;

const

        cpu         : Byte = $FF;
        fpu         : Byte = $FF;
        extFlags    : Word = 0;
        cpuid0      : array[0..11] of Char = #0#0#0#0#0#0#0#0#0#0#0#0;
        cpuid1      : {$IFDEF WIN32} Integer {$ELSE} LongInt {$ENDIF}= 0;
        cpuBrand    : {$IFDEF WIN32} Integer {$ELSE} LongInt {$ENDIF}= 0;
        cpuFeatures : {$IFDEF WIN32} Integer {$ELSE} LongInt {$ENDIF}= 0;

{ CPU type constants }

        i8088           = 00;
        i8086           = 01;
        i80C88          = 02;
        i80C86          = 03;
        i80188          = 04;
        i80186          = 05;
        necV20          = 06;
        necV30          = 07;
        i80286          = 08;
        i80386sx        = 09;
        i80386dx        = 10;
        i386sl          = 11;
        ibm386slc       = 12;
        am386sx         = 13;
        am386dx         = 14;
        ct38600         = 15;
        ct38600SX       = 16;
        RapidCAD        = 17;
        i486sx          = 18;
        i486dx          = 19;
        ibm486slc       = 20;
        ibm486slc2      = 21;
        ibm486bl3       = 22;
        Cx486           = 23;
        umcU5S          = 24;
        umcU5D          = 25;
        am486           = 26;
        iPentium        = 27;
        iP54C           = 28;
        CxM1            = 29;
        AmdK5           = 30;
        Nx586           = 31;
        iPentiumPro     = 32;
        AmdK6           = 33;
        iP7             = 34;
        iP8             = 35;
        CxM2            = 36;
        Am486DX         = 37;
        AmdK5_2         = 38;
        WinChipC6       = 39;
        i486sl          = 40;
        AmdK7           = 41;
        WinChip2        = 42;
        Rise_mP6        = 43;
        i376            = 44;
        WinChip3        = 45;
        CxIII           = 46;
        MaxCPU          = CxIII;

{ FPU type constants }

        fpuInternal     = 100;
        fpuNone         = 0;
        i8087           = 1;
        i80287          = 2;
        i80287xl        = 3;
        i80387          = 4;
        rCAD            = 5;
        cx287           = 6;
        cx387           = 7;
        cx487           = 8;
        cxEMC87         = 9;
        iit287          = 10;
        iit387          = 11;
        iit487          = 12;
        ct387           = 13;
        ulsi387         = 14;
        ulsi487         = 15;
        i487sx          = 16;
        Nx587           = 17;
        iit487DLC       = 18;
        i387SLMobile    = 19;

{ misc constants }

        efHasFPUonChip  = $0001;
        efWeitekPresent = $0002;
        efCPUIDSupport  = $0004;
        efDXType        = efCPUIDSupport+efHasFPUOnChip;
        efEmulatedFPU   = $0008;
        efCentaurLevel  = $0010;
        efTSCSupport    = $0020;


{ L2 cache size (CPUID level 2 lower nibble of descriptor) }

        cdNoCache       = 0;
        cd128k          = 1;
        cd256k          = 2;
        cd512k          = 3;
        cd1M            = 4;
        cd2M            = 5;
        cd4M            = 6;

{ Intel processors feature bits }
        ifbFPU          = $00000001; { FPU on chip }
        ifbVME          = $00000002; { Virtual mode extensions }
        ifbDE           = $00000004;
        ifbPSE          = $00000008;
        ifbTSC          = $00000010;
        ifbMSR          = $00000020;
        ifbPAE          = $00000040;
        ifbMCE          = $00000080;
        ifbCX8          = $00000100;
        ifbAPIC         = $00000200;
        ifbSEP          = $00000800;
        ifbMTRR         = $00001000;
        ifbPGE          = $00002000;
        ifbMCA          = $00004000;
        ifbCMOV         = $00008000;
        ifbPAT          = $00010000;
        ifbPSE36        = $00020000;
        ifbPSN          = $00040000;
        ifbCLFLSH       = $00080000;
        ifbDTES         = $00200000;
        ifbACPI         = $00400000;
        ifbMMX          = $00800000;
        ifbFXSR         = $01000000;
        ifbSSE          = $02000000;
        ifbSSE2         = $04000000;
        ifbSSNP         = $08000000;
        ifbIA64         = $40000000;

function getVersion : Word; {$IFDEF _DLL}export;{$ENDIF}

function cpu_Type : {$IFDEF Win32} ShortString;{$ELSE} String; {$ENDIF} { returns CPU name }

function fpu_Type : {$IFDEF Win32} ShortString;{$ELSE} String; {$ENDIF} { returns FPU name }

function cpu_Speed : Word;  { returns raw CPU clock in MHz }

function ncpu_Speed : Word;  { returns normalized CPU clock in MHz }

function fcpu_Speed : Real; { returns floating point CPU clock freq }

{$IFNDEF FPC}
 {$IFNDEF Win32}
function getCacheSize : Word; {$IFNDEF VER60}far;{$ENDIF} { returns L1 cache size in Kb }
(*
  {$IFNDEF DPMI}
   {$IFNDEF Windows}
function checkEMM386 : Boolean; {$IFNDEF VER60}far;{$ENDIF}
   {$ENDIF}
  {$ENDIF}
*)
 {$ENDIF}
{$ENDIF}

procedure CxCPUIDEnable; {$IFDEF Windows} export; {$ELSE}
                          {$IFDEF Win32} export; {$ELSE}
                           {$IFNDEF VER60}{$IFNDEF FPC} far; {$ENDIF}{$ENDIF}
                          {$ENDIF}
                         {$ENDIF}

procedure getCPUID(Level : LongInt; Result : Pointer); {$IFDEF Windows}
                                                        export;
                                                       {$ELSE}
                                                        {$IFNDEF VER60}
                                                         {$IFNDEF FPC}
                                                          far;
                                                         {$ENDIF}
                                                        {$ENDIF}
                                                       {$ENDIF}

function getCPUSerialNumber : {$IFDEF Win32} ShortString;{$ELSE} String; {$ENDIF}
                              {$IFDEF Windows} export; {$ELSE}
                               {$IFNDEF Win32}
                                {$IFNDEF VER60}{$IFNDEF FPC} far; {$ENDIF}{$ENDIF}
                               {$ENDIF}
                              {$ENDIF}

{$IFDEF Win32}
function UnderNT : Boolean;
{$ENDIF}
{$IFNDEF FPC}
{$IFNDEF Win32}
{$IFNDEF Ver80}
{$IFDEF Ver70}
{$IFNDEF DPMI}
 {$IFNDEF Windows}
function isV86 : Boolean; {$IFNDEF VER60}far;{$ENDIF}
 { this routine is useful for real mode only }
 {$ENDIF} { Windows }
{$ENDIF} { DPMI }
{$ELSE} { not Ver70, no protected mode or windows }
function isV86 : Boolean; {$IFNDEF VER60}far;{$ENDIF}
{$ENDIF} { Ver70 }
{$ENDIF} { Ver80 }
{$ENDIF} { Win32 }
{$ENDIF} { FPC }

implementation

{$IFDEF Win32}
uses Windows, SysUtils;
{$ELSE}
 {$IFDEF Windows}
 uses WinDos, Strings;
 {$ELSE}
 uses Dos,support; {added by Trixter to add waiting for floppy support}
 {$ENDIF}
{$ENDIF}

{ do not change following constants! }
const
        fpuDenormal   : array [0..9] of Byte = (1,0,0,0,0,0,0,0,0,0);
        fpuOp1        : array [0..9] of Byte = ($F0,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$3F);
        fpu_53bit_Prec: word = $02F7;
        speedShift    : word = 0;
        speedTable    : array[i8088..MaxCPU] of {$IFDEF Win32} Integer {$ELSE} LongInt {$ENDIF} =
                        (
                         $0002AD26, { i8088 }
                         $0002AD26, { i8086 }
                         $0002AD26, { i80C88 }
                         $0002AD26, { i80C86 }
                         $0000BA6F, { i80188 }
                         $0000BA6F, { i80186 }
                         $00008C38, { necV20 }
                         $0000912C, { necV30 }
                         $00006FDC, { i80286 }
                         $00007480, { i80386SX }
                         $00007480, { i80386DX }
                         $00007480, { i386sl }
                         $00007480, { ibm386slc }
                         $00007415, { Am386SX }
                         $00007415, { Am386DX }
                         $00007480, { CT38600 }
                         $00007480, { CT38600SX }
                         $00007415, { RapidCAD }
                         $00007480, { i486SX }
                         $00007480, { i486DX }
                         $00007486, { ibm486slc }
                         $00007486, { ibm486slc2 }
                         $00007486, { ibm486bl3 }
                         $0000668A, { Cx486 }
                         $00003C90, { umcU5S }
                         $00003C90, { umcU5D }
                         $00007480, { Am486 }
                         $00007900, { Pentium }
                         $00007950, { P54C }
                         $00004800, { CxM1 }
                         $000061D0, { amdK5 }
                         $0000792E, { Nx586       !!! needs adjustment }
                         $00006BCD, { iPentiumPro }
                         $00003CD2, { amdK6 }
                         $00003079, { P7          !!! needs adjustment }
                         $00003079, { P8          !!! needs adjustment }
                         $0000D688, { CxM2        !!! needs adjustment }
                         $00007480, { Am486DX }
                         $00008AC6, { AMD K5 models 2 and 3 }
                         $00003900, { WinChip C6  !!! needs adjustment }
                         $00007480, { i486SL }
                         $00006EC0, { AMD K7     !!! needs adjustment }
                         $00003CD2, { WinChip 2  !!! needs adjustment }
                         $00003CD2, { Rise mP6   !!! needs adjustment }
                         $00007480, { i376 }
                         $00003CD2, { WinChip 3  !!! needs adjustment }
                         $0000D688  { Cyrix III  !!! needs adjustment }
                        );



{ external functions }
function getCPUType : Byte; {$IFNDEF Win32}{$IFNDEF VER60}{$IFNDEF FPC}far;{$ENDIF}{$ENDIF}{$ENDIF} external;

function getFPUType : Byte; {$IFNDEF Win32}{$IFNDEF VER60}{$IFNDEF FPC}far;{$ENDIF}{$ENDIF}{$ENDIF} external;

function getCyrixModel : Word; {$IFNDEF Win32}{$IFNDEF VER60}{$IFNDEF FPC}far;{$ENDIF}{$ENDIF}{$ENDIF} external;
{ hi byte = DIR1, lo byte = DIR0 }
{ DIR stands for Device Identification Register. They are found in Cyrix CPUs
  and their derivatives/compatibles from Texas Instruments, SGS Thompson and
  few other vendors. They are accessed via I/O ports 22h and 23h, address and
  data port respectively. DIR0 register index is 0FEh and DIR1 index is 0FFh.
  To read DIRx first out 22h, regindex, then in al,23h. DIR0 holds device
  model signature, DIR1 holds chip stepping information as well as some other
  flags. All known Cyrix chips except just a few ancient models have DIRs,
  even new 586-class ones.
  }


function Speed : Word; {$IFNDEF Win32}{$IFNDEF VER60}{$IFNDEF FPC}far;{$ENDIF}{$ENDIF}{$ENDIF} external;

function getPentiumSpeed : Word; {$IFNDEF Win32}{$IFNDEF VER60}{$IFNDEF FPC}far;{$ENDIF}{$ENDIF}{$ENDIF} external;

function TSCDisabled : Boolean; {$IFNDEF Win32}{$IFNDEF VER60}{$IFNDEF FPC}far;{$ENDIF}{$ENDIF}{$ENDIF} external;

{$IFNDEF FPC}
{$IFNDEF Win32}
function getCacheSize; external;
(*
  {$IFNDEF DPMI}
   {$IFNDEF Windows}
function checkEMM386; external;
   {$ENDIF}
  {$ENDIF}
*)
{$ENDIF}
{$ENDIF}

procedure CxCPUIDEnable; external;

procedure getCPUID(Level : LongInt; Result : Pointer); external;

{$IFNDEF FPC}
{$IFNDEF Win32}
{$IFNDEF Ver80}
{$IFDEF Ver70}
{$IFNDEF DPMI}
 {$IFNDEF Windows}
function isV86; external;
 {$ENDIF} { Windows }
{$ENDIF} { DPMI }
{$ELSE}
function isV86; external;
{$ENDIF} { Ver70 }
{$ENDIF} { Ver80 }
{$ENDIF} { Win32 }
{$ENDIF FPC }

{$IFDEF FPC}
 {$L DPMICODE.O32}
{$ELSE}
{$IFDEF Win32}
 {$L DPMICODE.O32}
{$ELSE}
{$IFDEF Ver80}
 {$L DPMICODE.OBP}
{$ELSE}
{$IFDEF Ver70}
{$IFNDEF DPMI}
 {$IFNDEF Windows} {Windows is DPMI-compliant too}
  {$L REALCODE.OBJ} { Link in real-mode code }
 {$ELSE}
  {$L DPMICODE.OBP} { Link in protected-mode code }
 {$ENDIF} { Windows }
{$ELSE}
 {$L DPMICODE.OBP}
{$ENDIF} { DPMI }
{$ELSE} { Version is lower than 7.0, no DPMI support }
 {$L REALCODE.OBJ}
{$ENDIF} { Ver70 }
{$ENDIF} { Ver80 }
{$ENDIF} { Win32 }
{$ENDIF} { FPC }

{$IFDEF FPC}
 {$L CPUSPEED.O32}
 {$L P5SPEED.O32}
{$ELSE}
{$IFDEF Win32}
 {$L CPUSPEED.O32}
 {$L P5SPEED.O32}
{$ELSE}
 {$L CPUSPEED.OBJ} { Speed routine doesn't care of mode of operation }
 {$L P5SPEED.OBJ}
{$ENDIF} { Win32 }
{$IFNDEF Win32}
 {$L CACHETST.OBJ}
{$ENDIF} { Win32 }
{$ENDIF} { FPC }

function CyrixModel : {$IFDEF Win32} ShortString;{$ELSE}String;{$ENDIF}
 var
    isTI : Boolean;
    DIR0,
    DIR1 : Byte;
    Family : Byte;
 begin
  if (extFlags and efCPUIDSupport) <> 0 then
   Family:= (cpuid1 and $0F00) shr 8
  else
   Family := 0; {to avoid getting Delphi 3 warning about this variable}
  DIR0 := Lo(getCyrixModel);
  DIR1 := Hi(getCyrixModel);
  isTI := (DIR1 and $80) <> 0;
  { new Texas Instruments 486DX-class chips have high bit of DIR1 set to 1,
    while Cyrix reserve this bit and set it to 0 }
  case DIR0 of
   0 : CyrixModel := 'Cyrix Cx486SLC';
   1 : CyrixModel := 'Cyrix Cx486DLC';
   2 : CyrixModel := 'Cyrix Cx486SLC2';
   3 : CyrixModel := 'Cyrix Cx486DLC2';
   4 : CyrixModel := 'Cyrix Cx486SRx';
   5 : CyrixModel := 'Cyrix Cx486DRx';
   6 : CyrixModel := 'Cyrix Cx486SRx2';
   7 : CyrixModel := 'Cyrix Cx486DRx2';
   8 : CyrixModel := 'Cyrix Cx486SRu';
   9 : CyrixModel := 'Cyrix Cx486DRu';
  $0A: CyrixModel := 'Cyrix Cx486SRu2';
  $0B: CyrixModel := 'Cyrix Cx486DRu2';
  $10: CyrixModel := 'Cyrix Cx486S';
  $11: CyrixModel := 'Cyrix Cx486S2';
  $12,
  $14,
  $16: CyrixModel := 'Cyrix Cx486Se';
  $13,
  $15,
  $17: CyrixModel := 'Cyrix Cx486S2e';
  $1A: begin
        if IsTI then
         CyrixModel := 'Texas Instruments Ti486DX'
        else
         CyrixModel := 'Cyrix Cx486DX';
        extFlags := extFlags or efHasFPUonChip;
       end;
  $1B: begin
        if IsTI or (DIR1 = $B2) then
         CyrixModel := 'Texas Instruments Ti486DX2'
        else
         CyrixModel := 'Cyrix Cx486DX2';
        extFlags := extFlags or efHasFPUonChip;
       end;
  $1F: begin
        if IsTI then
         CyrixModel := 'Texas Instruments Ti486DX4'
        else
         CyrixModel := 'Cyrix Cx486DX4';
        extFlags := extFlags or efHasFPUonChip;
       end;
  $20..$2F:
       begin
        cpu := CxM1;
        CyrixModel := 'Cyrix 5x86 (M1sc)';
        extFlags := extFlags or efHasFPUonChip;
        case DIR0 of
         $28: CyrixModel := 'Cyrix 5x86-S (clock x1 mode)';
         $29: CyrixModel := 'Cyrix 5x86-S (clock x2 mode)';
         $2D: CyrixModel := 'Cyrix 5x86-S (clock x3 mode)';
         $2C: CyrixModel := 'Cyrix 5x86-S (clock x4 mode)';
         $2A: CyrixModel := 'Cyrix 5x86-P (clock x1 mode)';
         $2B: CyrixModel := 'Cyrix 5x86-P (clock x2 mode)';
         $2F: CyrixModel := 'Cyrix 5x86-P (clock x3 mode)';
         $2E: CyrixModel := 'Cyrix 5x86-P (clock x4 mode)';
        end;
       end;
  $30..$3F:
       begin
        cpu := CxM1;
        CyrixModel := 'Cyrix 6x86 (M1)';
        extFlags := extFlags or efHasFPUonChip;
        case DIR0 of
         $30: if DIR1 <= $21 then
                CyrixModel := 'Cyrix 6x86-S (clock x1 mode)'
              else
                CyrixModel := 'Cyrix 6x86L-S (clock x1 mode)';
         $31: if DIR1 <= $21 then
               CyrixModel := 'Cyrix 6x86-S (clock x2 mode)'
              else
                CyrixModel := 'Cyrix 6x86L-S (clock x2 mode)';
         $35: if DIR1 <= $21 then
               CyrixModel := 'Cyrix 6x86-S (clock x3 mode)'
              else
               CyrixModel := 'Cyrix 6x86L-S (clock x3 mode)';
         $34: if DIR1 <= $21 then
               CyrixModel := 'Cyrix 6x86-S (clock x4 mode)'
              else
               CyrixModel := 'Cyrix 6x86L-S (clock x4 mode)';
         $32: if DIR1 <= $21 then
               CyrixModel := 'Cyrix 6x86-P (clock x1 mode)'
              else
               CyrixModel := 'Cyrix 6x86L-P (clock x1 mode)';
         $33: if DIR1 <= $21 then
               CyrixModel := 'Cyrix 6x86-P (clock x2 mode)'
              else
               CyrixModel := 'Cyrix 6x86L-P (clock x2 mode)';
         $37: if DIR1 <= $21 then
               CyrixModel := 'Cyrix 6x86-P (clock x3 mode)'
              else
               CyrixModel := 'Cyrix 6x86L-P (clock x3 mode)';
         $36: if DIR1 <= $21 then
               CyrixModel := 'Cyrix 6x86-P (clock x4 mode)'
              else
               CyrixModel := 'Cyrix 6x86L-P (clock x4 mode)';
        end;
       end;
  $40..$47:
       begin
        cpu := CxM1;
        extFlags := extFlags or efHasFPUonChip;
        CyrixModel := 'Cyrix MediaGX';
        case Family of
         4 : case DIR0 of
              $41    : CyrixModel := 'Cyrix MediaGX (clock x3 mode)';
              $45,$47: CyrixModel := 'Cyrix MediaGX (clock x3 mode)';
              $44,$46: CyrixModel := 'Cyrix MediaGX (clock x4 mode)';
             end; { case }
         5 : case DIR0 of
              $40,$42: CyrixModel := 'Cyrix GXm (clock x4 mode)';
              $41,$43: CyrixModel := 'Cyrix GXm (clock x6 mode)';
              $44,$46: CyrixModel := 'Cyrix GXm (clock x7 mode)';
              $45:     CyrixModel := 'Cyrix GXm (clock x8 mode)';
              $47:     CyrixModel := 'Cyrix GXm (clock x5 mode)';
             end; { inner case }
        end; { outer case }
       end;
  $50..$5F:
       begin
        cpu := CxM2;
        CyrixModel := 'VIA Cyrix 6x86MX (MII)';
        extFlags := extFlags or efHasFPUonChip;
        case DIR0 of
         $50: CyrixModel := 'VIA Cyrix 6x86MX-S (clock x1.5 mode)';
         $51: CyrixModel := 'VIA Cyrix 6x86MX-S (clock x2.0 mode)';
         $52: CyrixModel := 'VIA Cyrix 6x86MX-S (clock x2.5 mode)';
         $53: CyrixModel := 'VIA Cyrix 6x86MX-S (clock x3.0 mode)';
         $54: CyrixModel := 'VIA Cyrix 6x86MX-S (clock x3.5 mode)';
         $55: CyrixModel := 'VIA Cyrix 6x86MX-S (clock x4.0 mode)';
         $56: CyrixModel := 'VIA Cyrix 6x86MX-S (clock x4.5 mode)';
         $57: CyrixModel := 'VIA Cyrix 6x86MX-S (clock x5.0 mode)';
         $58: CyrixModel := 'VIA Cyrix 6x86MX-P (clock x1.5 mode)';
         $59: CyrixModel := 'VIA Cyrix 6x86MX-P (clock x2.0 mode)';
         $5A: CyrixModel := 'VIA Cyrix 6x86MX-P (clock x2.5 mode)';
         $5B: CyrixModel := 'VIA Cyrix 6x86MX-P (clock x3.0 mode)';
         $5C: CyrixModel := 'VIA Cyrix 6x86MX-P (clock x3.5 mode)';
         $5D: CyrixModel := 'VIA Cyrix 6x86MX-P (clock x4.0 mode)';
         $5E: CyrixModel := 'VIA Cyrix 6x86MX-P (clock x4.5 mode)';
         $5F: CyrixModel := 'VIA Cyrix 6x86MX-P (clock x5.0 mode)';
        end;
       end;
  $80..$8F:
       begin
        cpu := CxIII;
        CyrixModel := 'VIA Cyrix III';
        extFlags := extFlags or efHasFPUonChip;
        case DIR0 of
         $81: CyrixModel := 'VIA Cyrix III (clock x3.0 mode)';
         $82: CyrixModel := 'VIA Cyrix III (clock x4.0 mode)';
         $83: CyrixModel := 'VIA Cyrix III (clock x5.0 mode)';
         $84: CyrixModel := 'VIA Cyrix III (clock x6.0 mode)';
         $85: CyrixModel := 'VIA Cyrix III (clock x3.5 mode)';
         $86: CyrixModel := 'VIA Cyrix III (clock x4.5 mode)';
         $87: CyrixModel := 'VIA Cyrix III (clock x5.5 mode)';
         $88: CyrixModel := 'VIA Cyrix III (clock x6.0 mode)';
         $89: CyrixModel := 'VIA Cyrix III (clock x7.0 mode)';
         $8A: CyrixModel := 'VIA Cyrix III (clock x6.5 mode)';
         $8B: CyrixModel := 'VIA Cyrix III (clock x7.5 mode)';
        end;
       end;
  $EF: CyrixModel := 'Cyrix Cx486S_a';  { this id is software-generated }
  $FD: begin
        CyrixModel := 'Cyrix OverDrive';
        extFlags := extFlags or efHasFPUonChip;
       end;
  $FE: CyrixModel := 'Texas Instruments Ti486SXL (Potomac)';
  else
   CyrixModel := 'Cyrix/TI 486-class processor';
  end;
 end;

{$IFDEF VER60}
function Compare12( S : String ): Boolean; assembler;
{$ELSE}
function Compare12( S : PChar ): Boolean; assembler;
{$ENDIF}
{$IFNDEF _32bit}
asm
    push  es
    mov   si, offset cpuid0
    les   di, S
{$IFDEF VER60}
    inc   di            { advance past string length byte }
{$ENDIF}
    mov   cx, 6
    cld
    rep   cmpsw
    mov   al,1
    jcxz  @@Match
    dec   al
@@Match:
    pop   es
end;
{$ELSE}
asm
    push  esi
    push  edi
    push  es
    push  ds
    pop   es
    mov   esi, offset cpuid0
    mov   edi, S
    mov   ecx,3
    cld
    rep   cmpsd
    mov   al,1
    jecxz @@Match
    dec   al
@@Match:
    pop   es
    pop   edi
    pop   esi
end;
{$ENDIF} { _32bit }

function getL2CacheDesc : Byte; {$IFNDEF Win32}{$IFNDEF VER60}{$IFNDEF FPC}far;{$ENDIF}{$ENDIF}{$ENDIF} external;

function cpu_Type : {$IFDEF Win32} ShortString; {$ELSE} String; {$ENDIF}
 var
    cpuid1_ : cpuid1Layout;
 begin
  WaitFloppySpindown;
  if cpu = $FF then
   getCPUType;
  case cpu of
   i80386sx: if cpu_Speed > 35 then cpu := am386sx;
   i80386dx: if cpu_Speed > 35 then cpu := am386dx;
  end;
  if (extFlags and efCPUIDSupport) <> 0 then
   begin
   cpuid1_.Extra := (cpuid1 and $F000) shr 12;
   cpuid1_.Family:= (cpuid1 and $0F00) shr 8;
   cpuid1_.Model := (cpuid1 and $00F0) shr 4;
   cpuid1_.Step  := (cpuid1 and $000F);
   case cpuid1_.Family of
    4: { 486 }
       begin
        if Compare12('UMC UMC UMC ') then { UMC U5-x 486s }
         case cpuid1_.Model of
          1: cpu := umcU5D;
          2: cpu := umcU5S;
          3: begin
              cpu := umcU5D;
              cpu_Type := 'UMC U486DX2';
              exit;
             end;
          5: begin
              cpu := umcU5S;
              cpu_Type := 'UMC U486SX2';
              exit;
             end;
         else
          begin
           cpu := umcU5S;
           cpu_Type := 'Undistinguished UMC U486';
           exit;
          end;
         end { case }
        else
        if Compare12('GenuineIntel') then { Intel i486s }
         begin
          if (extFlags and efHasFPUonChip) <> 0 then
           cpu := i486DX; {override occasional 486SX on 486DX2 systems}
          case cpuid1_.Model of
           0 : cpu_Type := 'Intel i486DX';
           1 : cpu_Type := 'Intel i486DX50';
           2 : if cpu = i486DX then    {override 486SX on 486DX2 systems}
                cpu_Type := 'Intel i486DX2'
               else
                cpu_Type := 'Intel i486SX';
           3 : if (cpuid1_.Extra and 3) = 1 then
                cpu_Type := 'Intel i486DX OverDrive'
               else
                cpu_Type := 'Intel i486DX2';
           4 : cpu_Type := 'Intel i486SL';
           5 : cpu_Type := 'Intel i486SX2';
           7 : cpu_Type := 'Intel i486DX2WB';
           8 : cpu_Type := 'Intel i486DX4';
           9 : cpu_Type := 'Intel i486DX4WB';
          else
           cpu_Type := 'Intel i486 (undistinguished model)';
          end; { case }
          exit;
         end { begin }
        else
        if Compare12('AuthenticAMD') then { AMD Enhanced Am486s }
         begin
          cpu := Am486;
          if (extFlags and efHasFPUonChip) <> 0 then
           cpu := Am486DX;
          case cpuid1_.Model of
           3 : cpu_Type := 'AMD Enhanced Am486DX2';
           7 : cpu_Type := 'AMD Enhanced Am486DX2+';
           8 : cpu_Type := 'AMD Enhanced Am486DX4';
           9 : cpu_Type := 'AMD Enhanced Am486DX4+';
          $A : if (extFlags and efHasFPUonChip) = 0 then
                cpu_Type := 'AMD Elan SC400 Microcontroller'
               else
                cpu_Type := 'AMD Enhanced Am486DX (undistinguished model)';
          $E : cpu_Type := 'AMD X5 (Am5x86)';
          $F : cpu_Type := 'AMD X5+ (Am5x86+)';
          else
           cpu_Type := 'AMD Enhanced Am486DX (undistinguished model)';
          end; { case }
          exit;
         end { begin }
        else
         begin
          cpu_Type := 'Unknown 486-class CPU (Make : '+cpuid0+')';
          exit;
         end;
       end;
    5: { 586 }
       if Compare12('CentaurHauls') or
          ((extFlags and efCentaurLevel) = efCentaurLevel) then { IDT/Centaur Tech WinChip }
        begin
         cpu := WinChipC6;
         case cpuid1_.Model of
          4 : cpu_Type := 'IDT/Centaur Tech. WinChip C6';
          8 : begin
               if cpuid1_.Step in [7,8,9] then
                cpu_Type := 'IDT/Centaur Tech. WinChip 2A'
               else
                cpu_Type := 'IDT/Centaur Tech. WinChip 2';
               cpu := WinChip2;
              end;
          9 : begin
               cpu_Type := 'IDT/Centaur Tech. WinChip 3';
               cpu := WinChip3;
              end;
         else
          cpu_Type := 'IDT/Centaur Tech. WinChip (unknown model)';
         end;
         exit;
        end
       else
       if Compare12('CyrixInstead') then
        begin
         cpu_Type := CyrixModel;
         exit;
        end
       else
       if Compare12('NexGenDriven') then { NexGen is now part of AMD family }
        begin
         cpu := Nx586;
         case cpuid1_.Model of
          0: begin
              cpu_Type := 'NexGen Nx586 or Nx586FPU';
              exit;
             end;
         else
          begin
           cpu_Type := 'NexGen 586-class processor (undistinguished)';
           exit;
          end
         end
        end
       else
       if Compare12('AuthenticAMD') then
        begin
         cpu := amdK5;
         case cpuid1_.Model of
          0: begin
              cpu_Type := 'AMD SSA/5 (K5)';
              exit;
             end;
          1: begin
              cpu_Type := 'AMD 5k86 (K5)';
              exit;
             end;
        2,3: begin
              cpu := amdK5_2;
              cpu_Type := 'AMD 5k86 (K5)';
              exit;
             end;
       6..7: cpu := amdK6;
          8: begin
              cpu := amdK6;
              cpu_Type := 'AMD K6-2';
              exit;
             end;
          9: begin
              cpu := amdK6;
              cpu_Type := 'AMD K6-III';
              exit;
             end;
        $0D: begin
              cpu := amdK6;
              cpu_Type := 'AMD K6-III+ (0.18u)';
              exit;
             end;
         else
          begin
           cpu_Type := 'AMD 586-class processor (undistinguished)';
           exit;
          end
         end
        end
       else
       if Compare12('GenuineIntel') then
        begin
         cpu := iP54C;
         case cpuid1_.Model of
          0 : begin
               cpu_Type := 'Intel Pentium (A-step)';
               cpu := iPentium;
              end;
          1 : begin
               cpu_Type := 'Intel Pentium';
               cpu := iPentium;
              end;
          2 : begin
               cpu_Type := 'Intel Pentium';
               if (cpuFeatures and $00800000) = $00800000 then
                cpu_Type := 'Intel Pentium with MMX';
              end;
          3 : cpu_Type := 'Intel Pentium OverDrive for 486';
          4 : if (cpuid1_.Extra and 3) = 1 then
               cpu_Type := 'Intel Pentium OverDrive for Pentium 3.3v'
              else
               cpu_Type := 'Intel Pentium with MMX';
          5 : cpu_Type := 'Intel OverDrive for i486DX4';
          6 : cpu_Type := 'Intel OverDrive for Pentium 5v';
          7 : begin
               cpu_Type := 'Intel Pentium (> 133MHz)';
               if (cpuFeatures and $00800000) = $00800000 then
                cpu_Type := 'Intel Pentium with MMX';
              end;
          8 : cpu_Type := 'SL28x Mobile Pentium with MMX';
         else
          if (cpuid1_.Extra and 3) = 1 then
           cpu_Type := 'Intel Pentium OverDrive'
          else
          if (cpuid1_.Extra and 3) = 2 then
           cpu_Type := 'Auxiliary Pentium (SMP)'
          else
           cpu_Type := 'Intel Pentium';
         end; { case }
         exit;
        end { begin }
       else
       if Compare12('RiseRiseRise') then
        begin
         cpu := Rise_mP6;
         case cpuid1_.Model of
          0 : cpu_Type := 'Rise iDragon(tm) mP6(tm)';
          2 : cpu_Type := 'Rise iDragon(tm) mP6(tm) Tiger (0.18u)';
          8 : cpu_Type := 'Rise iDragon(tm) mP6(tm) II';
          9 : cpu_Type := 'Rise iDragon(tm) mP6(tm) II Tiger (0.18u)';
         else
          cpu_Type := 'Rise iDragon(tm) mP6(tm) (undistinguished)';
         end;
         exit;
        end
       else
        begin
         cpu_Type := 'Unknown 586-class CPU (Make : '+cpuid0+')';
         exit;
        end;
    6: { P6 }
       if Compare12('GenuineIntel') then
        begin
        cpu := iPentiumPro;
        case cpuid1_.Model of
         0 :
             begin
              cpu_Type := 'Intel Pentium Pro (P6) A-Step';
              exit;
             end;
         1 : begin
              cpu_Type := 'Intel Pentium Pro (P6)';
              exit;
             end;
         3 : begin
              if (cpuid1_.Extra and 3) = 1 then
               cpu_Type := 'Intel Pentium Pro OverDrive'
              else
               cpu_Type := 'Intel Pentium II';
              exit;
             end;
         4 : begin
              cpu_Type := 'Intel iP55CT (OverDrive for iP54C socket)';
              exit;
             end;
         5 : begin
              case getL2CacheDesc of
               cdNoCache,
               cd128k    : cpu_Type := 'Intel Celeron';
               cd256k    : cpu_Type := 'Intel Pentium IIe';
               cd512k    : cpu_Type := 'Intel Pentium II';
               cd1M,
               cd2M      : cpu_Type := 'Intel Pentium II Xeon';
              else
               cpu_Type := 'Intel Pentium II';
              end;
              if cpuBrand <> 0 then
               case cpuBrand of
                2 : cpu_Type := 'Intel Pentium II';
                3 : cpu_Type := 'Intel Pentium II Xeon';
               end;
              exit;
             end;
         6 : begin
              case getL2CacheDesc of
               cdNoCache,
               cd128k    : cpu_Type := 'Intel CeleronA';
               cd256k    : cpu_Type := 'Intel Pentium IIe';
               cd512k    : cpu_Type := 'Intel Pentium II';
              else
               cpu_Type := 'Intel Pentium II';
              end;
              exit;
             end;
         7 : begin
              if cpuBrand = 0 then
               case getL2CacheDesc of
                cd128k    : cpu_Type := 'Intel Celeron';
                cd512k    : cpu_Type := 'Intel Pentium III';
                cd1M,
                cd2M      : cpu_Type := 'Intel Pentium III Xeon';
               else
                cpu_Type := 'Intel Pentium III';
               end
              else
               case cpuBrand of
                1 : cpu_Type := 'Intel Celeron';
                2 : cpu_Type := 'Intel Pentium III';
                3 : cpu_Type := 'Intel Pentium III Xeon';
               else
                cpu_Type := 'Intel Pentium III';
               end;
              exit;
             end;
         8 : begin
              if cpuBrand = 0 then
               case getL2CacheDesc of
                cd128k    : cpu_Type := 'Intel Celeron';
                cd512k    : cpu_Type := 'Intel Pentium III E';
                cd1M,
                cd2M      : cpu_Type := 'Intel Pentium III Xeon E';
               else
                cpu_Type := 'Intel Pentium III E';
               end
              else
               case cpuBrand of
                1 : cpu_Type := 'Intel Celeron';
                2 : cpu_Type := 'Intel Pentium III E';
                3 : cpu_Type := 'Intel Pentium III Xeon E';
               else
                cpu_Type := 'Intel Pentium III E';
               end;
              exit;
             end;
         $A: begin
              cpu_Type := 'Intel Pentium III Xeon';
              exit;
             end;
         else
          begin
           cpu_Type := 'Intel Pentium Pro (undistinguished)';
           exit;
          end;
        end; { case }
       end
      else
       if Compare12('CyrixInstead') then
        case cpuid1_.Model of
         0 : begin
              cpu := CxM2;
              cpu_Type := CyrixModel;
              exit;
             end;
         5 : begin
              cpu := CxIII;
              cpu_Type := CyrixModel;
              exit;
             end;
        else
         begin
          cpu_Type := CyrixModel;
          cpu := CxM2;
          exit;
         end;
        end
       else
       if Compare12('AuthenticAMD') then
        begin
         cpu := AmdK7;
         case cpuid1_.Model of
          1 :  cpu_Type := 'AMD Athlon(tm)';
          2 :  cpu_Type := 'AMD Athlon(tm) (0.18u)';
          3 :  cpu_Type := 'AMD Duron(tm)';
          4 :  cpu_Type := 'AMD Athlon(tm) (Thunderbird)';
         else
          cpu_Type := 'AMD Athlon(tm) (undistinguished model)';
         end;
         exit;
        end
       else
        begin
         cpu_Type := 'Unknown 686-class CPU (Make : '+cpuid0+')';
         exit;
        end;
    7: { P7 }
       if Compare12('GenuineIntel') then
        cpu := iP7
       else
        begin
         cpu_Type := 'Unknown 786-class CPU (Make : '+cpuid0+')';
         exit;
        end;
    8:
       begin
        cpu := iP8;
       end;
   end; { case }
   end; { if }

{ if we get to this point then no previous distinguishing code worked... }
  case cpu of
{$IFNDEF FPC}
{$IFNDEF DPMI}
 {$IFNDEF WINDOWS}
  { Under Windows or DPMI it is not necessary to check for CPUs below 80286 -
    neither of them work on these CPUs. }
   i8088 :      cpu_Type := 'Intel 8088';
   i8086 :      cpu_Type := 'Intel 8086';
   i80C88:      cpu_Type := 'Intel 80C88';
   i80C86:      cpu_Type := 'Intel 80C86';
   i80188:      cpu_Type := 'Intel 80188';
   i80186:      cpu_Type := 'Intel 80186';
   necV20:      cpu_Type := 'NEC V20';
   necV30:      cpu_Type := 'NEC V30';
 {$ENDIF}
{$ENDIF}
{$IFNDEF Win32} { Win32 cannot execute on 80286 }
   i80286:      cpu_Type := 'Intel 80286';
{$ENDIF}
{$ENDIF} {FPC} {no need for these under FPC either}
   i80386sx:    cpu_Type := 'Intel 80386SX';
   i80386dx:    cpu_Type := 'Intel 80386DX';
   i386sl:      cpu_Type := 'Intel i386SL';
   i376:        cpu_Type := 'Intel i376';
   ibm386slc:   cpu_Type := 'IBM 386SLC';
   am386sx:     cpu_Type := 'AMD Am386SX';
   am386dx:     cpu_Type := 'AMD Am386DX';
   ct38600:     cpu_Type := 'C&T 38600';
   ct38600SX:   cpu_Type := 'C&T 38600SX';
   RapidCAD:    cpu_Type := 'Intel RapidCAD';
   i486sx:      cpu_Type := 'Intel i486SX';
   i486dx:      cpu_Type := 'Intel i486DX or i487SX';
   i486sl:      cpu_Type := 'Intel i486SL';
   ibm486slc:   cpu_Type := 'IBM 486SLC';
   ibm486slc2:  cpu_Type := 'IBM 486SLC2';
   ibm486bl3:   cpu_Type := 'IBM 486BLX3 (Blue Lightning)';
   Cx486:       cpu_Type := CyrixModel;
   umcU5S:      cpu_Type := 'UMC U5S-Super33';
   umcU5D:      cpu_Type := 'UMC U5SD';
   am486:       cpu_Type := 'AMD Am486SX';
   Am486DX:     cpu_Type := 'AMD Am486DX';
   CxM1,
   CxM2:        cpu_Type := CyrixModel;
   amdK5,
   amdK5_2:     cpu_Type := 'AMD K5';
   amdK6:       cpu_Type := 'AMD K6';
   Nx586:       cpu_Type := 'NexGen Nx586';
   iPentiumPro: cpu_Type := 'Intel Pentium Pro';
   WinChipC6:   cpu_Type := 'IDT/Centaur WinChip C6';
   AmdK7:       cpu_Type := 'AMD Athlon(tm)';
   WinChip2:    cpu_Type := 'IDT/Centaur WinChip 2';
   WinChip3:    cpu_Type := 'IDT/Centaur WinChip 3';
   Rise_mP6:    cpu_Type := 'Rise mP6';
   iP7:         cpu_Type := 'Intel Itanium';
   iP8:         cpu_Type := 'Intel P8';
  else
   cpu_Type := 'Unknown CPU';
  end;

 end;

function fpu_Type : {$IFDEF Win32} ShortString; {$ELSE} String; {$ENDIF}
 begin
  if fpu = $FF then
   begin
    cpu_Type;
    getFPUType;
   end;
  if (extFlags and efHasFPUonChip) <> 0 then
   fpu := fpuInternal;
  if (extFlags and efEmulatedFPU) <> 0 then
   begin
    fpu_Type := 'Emulated (386+)';
    exit;
   end;
  case fpu of
   fpuInternal: fpu_Type := 'Internal';
   fpuNone:     fpu_Type := 'None';
   i8087:       fpu_Type := 'Intel 8087';
   i80287:      fpu_Type := 'Intel 80287';
   i80287xl:    fpu_Type := 'Intel 80287XL';
   i80387:      fpu_Type := 'Intel 80387';
   rCAD:        fpu_Type := 'Intel RapidCAD';
   cx287:       fpu_Type := 'Cyrix 82x87';
   cx387:       fpu_Type := 'Cyrix 83x87';
   cx487:       fpu_Type := 'Cyrix 84x87';
   cxEMC87:     fpu_Type := 'Cyrix EMC87';
   iit287:      fpu_Type := 'IIT 2C87';
   iit387:      fpu_Type := 'IIT 3C87';
   iit487:      fpu_Type := 'IIT 4C87';
   iit487DLC:   fpu_Type := 'IIT 4C87DLC';
   ct387:       fpu_Type := 'C&T 38700';
   ulsi387:     fpu_Type := 'ULSI 83x87';
   ulsi487:     fpu_Type := 'ULSI 84x87';
   i487sx:      fpu_Type := 'Intel i487sx (integrated)';
   Nx587:       fpu_Type := 'NexGen Nx587';
   i387SLMobile:fpu_Type := 'Intel i387SL Mobile';
  else
   fpu_Type := 'Unknown FPU';
  end;
 end;

const
      MaxFTEntries = 27;

type
      fArray       = array [0..MaxFTEntries] of Integer;

const
      Clone486Norm : fArray = (33, 40, 50, 66, 75, 80, 100, 120, 150, 166, 188,
                               200, 233, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                               0, 0);
      CloneP5Norm  : fArray = (75, 90, 100, 120, 133, 150, 166, 185, 200, 233,
                               266, 300, 333, 350, 366, 380, 400, 450, 500, 533,
                               0, 0, 0, 0, 0, 0, 0, 0);
      CloneP6Norm  : fArray = (300, 333, 350, 366, 380, 400, 450, 500, 550, 600,
                               650, 700, 750, 800, 833, 866, 933, 966, 1000, 0, 0,
                               0, 0, 0, 0, 0, 0, 0);
      CyrixNorm    : fArray = (80, 100, 110, 120, 125, 133, 150, 166, 185, 200, 225,
                               233, 250, 300, 333, 350, 366, 400, 433, 466, 500, 533,
                               0, 0, 0, 0, 0, 0);
      i486Norm     : fArray = (25, 33, 40, 50, 66, 75, 80, 100, 0, 0, 0, 0, 0, 0,
                               0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
      iP5Norm      : fArray = (60, 66, 75, 90, 100, 120, 133, 150, 166, 185, 200,
                               233, 266, 300, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                               0, 0, 0);
      iP6Norm      : fArray = (133, 150, 167, 185, 200, 220, 240, 266, 300, 333,
                               350, 366, 400, 433, 450, 500, 550, 600, 667, 700,
                               733, 750, 800, 833, 866, 933, 966, 1000);
      WinChipNorm  : fArray = (180, 200, 225, 233, 240, 250, 266, 300, 333, 350,
                               366, 380, 400, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                               0, 0, 0, 0);
      RiseNorm     : fArray = (266, 300, 333, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                               0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

      Clone486Entries = 13;
      CloneP5Entries  = 20;
      CloneP6Entries  = 19;
      CyrixEntries    = 22;
      i486Entries     = 8;
      iP5Entries      = 14;
      {iP6Entries      = 28; trixter: Wrong! Only 27 entries in table!}
      iP6Entries      = 27;
      WinChipEntries  = 13;
      RiseEntries     = 3;

const
      Tolerance    = 4;  { allowed deviation of raw frequency in MHz }


function NormFreq(freq : Word; fTable : fArray; Count : Byte) : Word;
 var i : Byte;
 begin
  for i := 0 to Count do
   { find first value in table that is greater or equal to input }
   if fTable[i] + Tolerance >= freq then
    begin
     if (i > 0) and ((fTable[i] - freq) > 10) then
      NormFreq := fTable[i-1]
     else
      NormFreq := fTable[i];
     exit;
    end;
   { ran through all possible speeds, found nothing -> return input value }
   NormFreq := freq;
 end;

function UnderNT : Boolean;
{$IFDEF Win32}
 begin
  UnderNT := (Win32Platform = VER_PLATFORM_WIN32_NT);
 end;
{$ELSE}
{$IFDEF Windows}
 begin
  if GetEnvVar('OS') <> nil then
   UnderNT := (StrComp(GetEnvVar('OS'),'Windows_NT') = 0)
  else
   UnderNT := False;
 end;
{$ELSE}
 begin
  UnderNT := (GetEnv('OS') = 'Windows_NT');
 end;
{$ENDIF}
{$ENDIF}

function ncpu_Speed : Word;
var
   spd : Word;
begin
  WaitFloppySpindown;
 if cpu = $FF then
  cpu_Type;
 spd := cpu_Speed;
 case cpu of
  i486sx, i486dx,
  i486sl             : ncpu_Speed := NormFreq(spd, i486Norm, i486Entries);
  ibm486slc..Am486,
  Am486DX            : ncpu_Speed := NormFreq(spd, Clone486Norm, Clone486Entries);
  iPentium, iP54C    : ncpu_Speed := NormFreq(spd, iP5Norm, iP5Entries);
  CxM1, CxM2, CxIII  : ncpu_Speed := NormFreq(spd, CyrixNorm, CyrixEntries);
  AmdK5, AmdK5_2,
  AmdK6              : ncpu_Speed := NormFreq(spd, CloneP5Norm, CloneP5Entries);
  AmdK7              : ncpu_Speed := NormFreq(spd, CloneP6Norm, CloneP6Entries);
  iPentiumPro, iP7,
  iP8                : ncpu_Speed := NormFreq(spd, iP6Norm, iP6Entries);
  WinChipC6,
  WinChip2,
  WinChip3           : ncpu_Speed := NormFreq(spd, WinChipNorm, WinChipEntries);
  Rise_mP6           : ncpu_Speed := NormFreq(spd, RiseNorm, RiseEntries);
 else
  ncpu_Speed := spd;
 end;
end;

function cpu_Speed : Word;
{$IFDEF NewSpeedCalc}
 var
    ms, sps, i, j : Word;
{$ENDIF}
 var
    f1, f2, f3 : Word;
 begin
  if cpu = $FF then
   cpu_Type; { we need to call this routine instead of getCPUType because some
               distinguishing also occurs here and CPU timings are based on
               detected CPU type. }
  if ((extFlags and efTSCSupport) = efTSCSupport) and not UnderNT
     and not (cpu in [AmdK5, AmdK6, AmdK5_2, AmdK7])
(*
{$IFNDEF Win32}
 {$IFNDEF FPC}
  {$IFNDEF DPMI}
   {$IFNDEF Windows}
     and not checkEMM386
   {$ENDIF}
  {$ENDIF}
 {$ENDIF}
{$ENDIF}
*)
  then
   begin
{$IFDEF Win32}
    try                           { Catch possible AV exception and skip }
     f1 := getPentiumSpeed;       { to default speed detection if so     }
     f2 := getPentiumSpeed;
     f3 := getPentiumSpeed;
     cpu_Speed := (f1 + f2 + f3) div 3;
     exit;
    except
    end;
{$ELSE}
    if not TSCDisabled then
     begin
      f1 := getPentiumSpeed;
      f2 := getPentiumSpeed;
      f3 := getPentiumSpeed;
      cpu_Speed := (f1 + f2 + f3) div 3;
      exit;
     end;
{$ENDIF}
   end;
{$IFDEF NewSpeedCalc}
  ms := $FFFF;
  sps := 0;
  for i := 0 to 7 do
   begin
    j := Speed;
    if ( j < ms ) and ( speedShift >= sps ) then
     begin
      ms := j;
      sps := speedShift;
     end;
   end;
  cpu_Speed := ((speedTable[cpu]*{$IFDEF Win32}Integer{$ELSE}LongInt{$ENDIF}(sps)) div ms + 5) div 10;
{$ELSE}
  f1 := ((speedTable[cpu]*{$IFDEF Win32}Integer{$ELSE}LongInt{$ENDIF}(speedShift)) div Speed + 5) div 10;
  f2 := ((speedTable[cpu]*{$IFDEF Win32}Integer{$ELSE}LongInt{$ENDIF}(speedShift)) div Speed + 5) div 10;
  f3 := ((speedTable[cpu]*{$IFDEF Win32}Integer{$ELSE}LongInt{$ENDIF}(speedShift)) div Speed + 5) div 10;
  cpu_Speed := (f1 + f2 + f3) div 3;
{$ENDIF}
 end;

function fcpu_Speed : Real;
{ the same as cpu_Speed, but uses Real calculations }
{$IFDEF NewSpeedCalc}
 var
    ms, sps, i, j : Word;
{$ENDIF}
 begin
  if cpu = $FF then
   cpu_Type; { we need to call this routine instead of getCPUType because some
               distinguishing also occurs here and CPU timings are based on
               detected CPU type. }
{$IFDEF NewSpeedCalc}
  ms := $FFFF;
  sps := 0;
  for i := 0 to 7 do
   begin
    j := Speed;
    if ( j < ms ) and ( speedShift >= sps ) then
     begin
      ms := j;
      sps := speedShift;
     end;
   end;
  fcpu_Speed := ( ( speedTable[cpu] * {$IFDEF Win32}Integer{$ELSE}LongInt{$ENDIF}(sps) ) / ms + 5 ) / 10;
{$ELSE}
  fcpu_Speed := ( ( speedTable[cpu] * {$IFDEF Win32}Integer{$ELSE}LongInt{$ENDIF}(speedShift) ) / Speed + 5 ) / 10;
{$ENDIF}
 end;

const
     HD : array[0..$F] of Char = '0123456789ABCDEF';

type
     String2 = String[2];
     String4 = String[4];

function HexB(B : Byte) : String2;
 begin
  HexB := HD[B shr 4] + HD[B and $0F];
 end;

function HexW(W : Word) : String4;
 begin
  HexW := Concat(HexB(Hi(W)), HexB(Lo(W)));
 end;

function getCPUSerialNumber : {$IFDEF Win32} ShortString; {$ELSE} String; {$ENDIF}
 var
    A : customCpuid;
    S : String;
 begin
  getCPUSerialNumber := '';
  if (cpuFeatures and $00040000) = $00040000 then
   begin
    getCPUID(1,@A);
    S := Concat(HexW(A.eax shr 16), '-', HexW(A.eax and $FFFF), '-');
    getCPUID(3,@A);
    getCPUSerialNumber := Concat(S, HexW(A.edx shr 16), '-', HexW(A.edx and $FFFF), '-',
                              HexW(A.ecx shr 16), '-', HexW(A.ecx and $FFFF));
   end;
 end;

const
        libVersion  = $0215;

function getVersion : Word;
 begin
  getVersion := libVersion;
 end;

end.
