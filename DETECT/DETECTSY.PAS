{$O+,F+,N-}
Unit DetectSystem;

Interface

Uses DetectGlobal;

Function WhatCPU            : Byte;
Function CPUFreq            : Word;
(* Function CoProFreq          : Real; disabling; see note below *)
Function WaitStates         : Real;
Function BusWidth           : Byte;

Function WhatCoPro          : Byte;
Function CoProRounding      : String32;
Function CoProPrecision     : Byte;
Function WhatWeitek         : Byte;

Function Is386PopAdBug      : Boolean;
Function Is386MulBug        : Boolean;
Function IsP5FDivBug        : Boolean;

Function HasCMOSPower       : Boolean;

Function MachineType        : String64;
Function IsDMAChannel3      : Boolean;
Function IsSlave8259        : Boolean;
Function IsRealClock        : Boolean;
Function IsWaitExtEvent     : Boolean;

Function WhatMSW            : Word;
Function IsMSWProtMode      : Boolean;
Function IsMSWMonCoPro      : Boolean;
Function IsMSWEmuCoPro      : Boolean;

Function WhatGDT            : Real;
Function WhatIDT            : Real;

Function SerialCount        : Byte;
Function ParrallelCount     : Byte;

Function BiosDate           : String8;
Function BiosRevision       : Byte;
Function BiosSource         : String;
Function BiosShort          : String16;
Function BiosVersion        : String16;
Function IsExtBiosSeg       : Word;
Procedure BiosExtensions (var P : pBiosCopyright);

Function ExtKeyboardSupp    : Boolean;
Function Keyboardtype       : Byte;
Function KeyBufferLength    : Byte;
Function IsKeybIntercept    : Boolean;
Function IsKeyb16_9         : Boolean;
Function KeyboardId         : Word;
Function KeyboardController : String16;

Function IsCPUCache         : Boolean;
Function CPUCacheLevel      : Byte;
Function CPUCacheKBFirst    : Word;
Function CPUCacheKBSecond   : Word;
Function CPUCacheThruFirst  : Real;
Function CPUCacheThruSecond : Real;

Function MemThru            : Real;
Function BiosExtThru        : Real;
Function EMSThru            : Real;

Function IsAPM              : Boolean;
Function APMVersion         : String16;
Function APMIs16Prot        : Boolean;
Function APMIs32Prot        : Boolean;
Function APMIsBIOSPowMngmnt : Boolean;
Function APMACLineStatus    : String16;
Function APMBatteryStatus   : String16;
Function APMBatteryLife     : Byte;

Function IsJetStream (PortNumber : Word) : Boolean;

Function IsOnBoardSCSI : Boolean;
Function IsIML         : Boolean;
Function IsIMLSCSISupp : Boolean;

Function DevCount                      : Byte;
Function DevName (Number : Byte)       : String32;
Function DevHeader (Number : Byte)     : Pointer;
Function DevAttributes (Number : Byte) : Word;
Function DevStrategy (Number : Byte)   : Pointer;
Function DevInterrupt (Number : Byte)  : Pointer;

Implementation

Uses Dos, DetectCaches, DetectConstants, DetectBios;

Type Processor = (NA, i88, i86, iC88, iC86, V20, V30, i188, i186, i286, i386,
                  i386sx, ct386, ct386sx, p486dlc, p486SLC, rapidcad, i486,
                  i486sx, Pentium, NexGen, Cyrix);


Const
   AAM_Time : Array [i88 .. Cyrix] Of Integer =
              (77, 77, 77, 77, 15, 15, 19, 19, 16, 17, 17, 16, 16, 16, 16,
               15, 15, 15, 18, 15, 15);
   HeaderMin = 0;
   HeaderMax = 17;


Var MoveBuffer     : POINTER;
    ScreenAddr     : Pointer;
    EMS_BASE       : Word;
    ExpandedMem    : Word;
    ExtendedMem    : Word;
    ProcessorType  : STRING [15];
    CPU            : Processor;
    Header         : Array [HeaderMin .. HeaderMax] Of Byte;


Function SerialCount;

Var Temp : Byte;

Begin
  Temp := 0;
  If MemW [$0040:$0000] <> 0 Then Temp := Temp+1;
  If MemW [$0040:$0002] <> 0 Then Temp := Temp+1;
  If MemW [$0040:$0004] <> 0 Then Temp := Temp+1;
  If MemW [$0040:$0006] <> 0 Then Temp := Temp+1;
  SerialCount := Temp;
End;


Function ParrallelCount;

Var Temp : Byte;

Begin
  Temp := 0;
  If MemW [$0040:$0008] <> 0 Then Temp := Temp+1;
  If MemW [$0040:$000A] <> 0 Then Temp := Temp+1;
  If MemW [$0040:$000C] <> 0 Then Temp := Temp+1;
  If MemW [$0040:$000E] <> 0 Then Temp := Temp+1;
  ParrallelCount := Temp;
End;

(*
Function BiosDate;
Begin
  BiosDate := Chr (MEM[$FFFF:$0005])+Chr(MEM[$FFFF:$0006])+
              Chr (MEM[$FFFF:$0007])+Chr(MEM[$FFFF:$0008])+
              Chr (MEM[$FFFF:$0009])+Chr(MEM[$FFFF:$000A])+
              Chr (MEM[$FFFF:$000B])+Chr(MEM[$FFFF:$000C]);
End;
*)

Function BIOSDate; assembler;
asm
  push    ds
  cld
  les     di,@Result     {es:di = result string}
  mov     ax,0ffffh
  mov     ds,ax
  mov     si,0005h       {ds:si = ffff:0005}
  mov     al,8
  stosb                  {result string[0]=8 which is the length of our return}
  movsw
  movsw
  movsw
  movsw                  {result = 4 words = 8 bytes from 0005-000c}
  pop     ds
end;


Function HasCMOSPower;

Begin
  Port[$0070] := $0D;
  HasCMOSPower := (Port[$0071] And $80 = $80);
End;


Function Keyboardtype;

Var Temp : Boolean;

Begin
  If Mem[$0040:$0096] And $10 = $10 Then KeyboardType := dkbEnhanced
    Else KeyBoardType := dkbXT;
End;


Function ExtKeyboardSupp;

Var TempByte : Byte;

Begin
  Regs.AH:=$02;
  Intr($16, Regs);
  Tempbyte:= Regs.AL;
  Regs.AX := $1200 + Tempbyte Xor $FF;
  Intr($16, Regs);
  ExtKeyboardSupp := (Regs.AL = Tempbyte)
End;


Function KeyBufferLength : Byte;

Var P : pBiosRecord;

Begin
  P := GetBiosRecord;
  KeyBufferLength := P^.KeybufBegin - P^.KeybufEnd;
End;


{ Die folgende Prozedur wird fÅr alle SpeedTest-Routinen benîtigt. }

Procedure PreSpeedTest;

Var MonochromMode : Boolean;
    EMM_Name      : String[8];
    Dummy         : Byte;
    Typ           : Byte;

Begin
  Regs.AH := $0F;                       { get screen status }
  Intr ($10, Regs);                     { BIOS video interupt }
  MonoChromMode := (Regs.AL = 7);
  IF MonoChromMode THEN
      ScreenAddr := Ptr ($B000,0000)
   ELSE
      ScreenAddr := Ptr ($B800,0000);

  EMM_Name := '        ';
  Regs.AH := $35;
  Regs.AL := $67;
  Intr ($21, Regs);
  Move (Mem [Regs.ES:$0A], EMM_Name[1], 8);
  If EMM_Name = 'EMMXXXX0' Then ExpandedMem := 1 Else ExpandedMem := 0;

  If ExpandedMem = 1 Then
    Begin
      EMS_Base := 0;
      Regs.AH := $41;
      Intr ($67, Regs);
      EMS_Base := Regs.BX;
    End
  Else
    EMS_Base := 0;

  Typ := Mem [$FFFF:$000E];
  Regs.AH := $88;
  Intr ($15, Regs);
  If ((Regs.Flags AND FCarry) = 0) AND (Regs.AX <> 0) Then ExtendedMem := 1
    Else ExtendedMem := 0;
  IF (ExtendedMem =1) THEN
    Begin
    End
  ELSE IF (Typ = $FC) OR ((Typ >= $F5) AND (Typ <= $F8)) THEN BEGIN
      Port [$70] := $30;
      Dummy := Port [$71];
      Port [$70] := $31;
      If (Port [$71] * 256 + Dummy) > 0 Then ExtendedMem := 1;
  END;
End;


Function WhatCPU;

Const
   CPU_Name:    ARRAY [i88 .. Cyrix] OF Byte =
                (dcpIn8088, dcpIn8086, dcpIn80C88, dcpIn80C86,
                 dcpNECV20, dcpNECV30, dcpIn80188, dcpIn80186,
                 dcpIn80286, dcpIn80386, dcpIn80386SX,
                 dcpC_T38600DX, dcpC_T38600SX, dcp486dlc, dcp486slc,
                 dcpInRapidCAD, dcpIn80486, dcpIn80486SX, dcpInPentium,
                 dcpNexGen, dcpVarCyrix);
Begin
  PreSpeedTest;
  GetMem (MoveBuffer, 20000);

  SpeedTest (Word (1) { kein Bildschirm-Test }, Word(ExtendedMem), Word(ExpandedMem),
             MoveBuffer, Ptr (EMS_Base, 0), ScreenAddr, Result);

  WhatCPU := Cpu_Name [Processor(Result.CPUType)];

  CPU := Processor(Result.CPUType);

  FreeMem (MoveBuffer, 20000);
End;


Function WhatCoPro;

Const
   CoProcessor: ARRAY [0 .. 28] OF Byte =
                ( dndNone, dndEmulViaInt7, dndIn8087,
                 dndIn80C187, dndIn80287, dndIn80287XL, dndIn80387,
                 dndIn80387sx, dndIIT2C87, dndIIT2C87, dndIIT3C87,
                 dndIIT3C87sx, dndCyr82S87Old, dndCyr82S87Old,
                 dndCyr34D87, dndCyr83S87Old, dndULSI83C87, dndULSI83S87,
                 dndC_T38700DX, dndC_T38700SX, dndIn80387dx, dndInRapidCAD,
                 dndIn486, dndCyr82S87new, dndCyr82S87new,
                 dndCyr387pl {Cyrix 387+}, dndCyr83S87new, dndCyrEMC87,
                 dndInPentium);
Begin
  PreSpeedTest;
  GetMem (MoveBuffer, 20000);

  SpeedTest (Word (1) { BildSchirm }, Word(ExtendedMem), Word(ExpandedMem),
             MoveBuffer, Ptr (EMS_Base, 0), ScreenAddr, Result);

  Result.NDPType := Result.NDPType AND $7F;     { clear Weitek flag }

  WhatCoPro := CoProcessor [Result.NdpType];
  FreeMem (MoveBuffer, 20000);
End;


Function WhatWeitek;

Begin
  Cpu_Info.Test_Type := 'W';
  MISC (CPU_Info);
  WhatWeitek := Cpu_Info.Weitek;
End;


Function CPUFreq;

Const
  Zykl = 838;           {ns/Zyklus}

Type
  BuffArray = Array [0..8100] Of Byte;

Var
  Buffer   : ^BuffArray;
  PuffSeg  : Word;
  PUffOfs  : Word;
  NullWert : Word;
  I        : Word;
  Z1       : LongInt;
  Takt     : Longint;
  OldI     : Pointer;

  Procedure StartTimer; Assembler;
  { Setzt Timer auf 65536 dieser wird nun alle 838ns um eins verringert}
  Asm
    CLI
    MOV AL,34h
    OUT 43h,AL
    XOR AL,AL
    OUT 40h,AL
    OUT 40h,AL
    STI
    INT 88h
  End;

  Function ReadTimer: Word;
    Begin
      Asm
        XOR AL,AL
        OUT 43h,AL
      End;
      ReadTimer := 65535 - Port[$40] Shl 8 - Port[$40];
      Asm
        STI
      End;
    End;

Begin
  WhatCPU;

  New (Buffer);
  PuffSeg := Seg (Buffer^);
  PuffOfs := Ofs (Buffer^);
  GetIntVec ($88, OldI);
  SetIntVec ($88, Buffer);                { Interrupt auf Puffer umbiegen }
  Mem [PuffSeg:PuffOfs] := $CF;                              { $CF = IRET }

  StartTimer;
  NullWert := ReadTimer;                          { Zeit fuer IRET messen }

  For i := 0 To 3999 Do
    MemW [PuffSeg:PuffOfs + i shl 1] := $AD4;  { Puffer mit $D40A fuellen }
  Mem  [PuffSeg:PuffOfs + i shl 1 + 2] := $CF;            { IRET ans Ende }

  StartTimer;
  Z1 := ReadTimer - NullWert;                  { reine Laufzeit bestimmen }

  Takt := AAM_time[CPU] * 100000 DIV (z1 * Zykl DIV 4000);   { Takt * 100 }
  If Takt Mod 100 = 98 Then Inc(Takt);                { ggf. etwas runden }
  If Takt Mod 100 = 99 Then Inc(takt);                { ggf. etwas runden }

  SetIntVec($88,OldI);                { alten Interrupt wieder herstellen }
  Dispose(Buffer);

  CpuFreq := Takt;
End;

(* Disabling this because it forces the program to require a mathco.  If you
want the full DETECT library, install it fresh from the archive file.

Function CoProFreq;

Const
   ClockFreq = 1.193182e6;
   MoveTime:    ARRAY [i88 .. Cyrix] OF INTEGER =
                (25, 17, 25, 17, 8, 16, 8, 16, 4, 4, 8, 4, 8, 4, 4,
                 5, 3, 3, 1, 1, 4);
   LFaktor:     ARRAY [i88 .. Cyrix] OF REAL =
                (1, 1.45, 1, 1.45, 1.15, 1.78, 1.15, 1.78, 3.3, 4.1, 3.4,
                 4.5, 3.7, 5.0, 6.0, 6.5, 8.5, 8.5, 17, 17, 5.0);

Var Frequency87 : Real;
    Index       : Double;

Begin
  PreSpeedTest;
  WhatCPU;
  GetMem (MoveBuffer, 20000);

  SpeedTest (Word (1) { BildSchirm }, Word(ExtendedMem), Word(ExpandedMem),
             MoveBuffer, Ptr (EMS_Base, 0), ScreenAddr, Result);

  TempFreq := 200 * AAM_Time [CPU] * ClockFreq / Result.AAMTime;
  Index    := LFaktor[CPU] * TempFreq / 4.7e6 * (MoveTime [CPU] / (Result.MoveBTime * TempFreq / (ClockFreq * 5000)));

   CASE Result.NDPType OF             { 40 * # of clock cycles for FSQRT }
     {Pentium}  28: Frequency87 := 1600 * ClockFreq / Result.Speed287;  {~40 clocks }
     {EMC87}    27: Frequency87 := 1470 * ClockFreq / Result.Speed287;  { 36 clocks }
     {83S87}    26: Frequency87 := 3040 * ClockFreq / Result.Speed287;  { 76 clocks magazine}
     {387+}     25: Frequency87 := 2880 * ClockFreq / Result.Speed287;  { 76 clocks magazine}
     {82S87}    24: Frequency87 := 3040 * ClockFreq / Result.Speed287;  { 76 clocks magazine}
     {82S87}    23: Frequency87 := 3040 * ClockFreq / Result.Speed287;  { 72 clocks meas.}
     {486}      22: Frequency87 := 3320 * ClockFreq / Result.Speed287;  { 83 clocks meas. }
     {RapidCAD} 21: Frequency87 := 3320 * ClockFreq / Result.Speed287;  { 83 clocks }
     {387DX}    20: Frequency87 := 4480 * ClockFreq / Result.Speed287;  { 112 clocks meas.}
     {38700sx}  19: Frequency87 := 2200 * ClockFreq / Result.Speed287;  { 55 clocks }
     {38700DX}  18: Frequency87 := 2040 * ClockFreq / Result.Speed287;  { 52 clocks }
     {83C87sx}  17: Frequency87 := 3640 * ClockFreq / Result.Speed287;  { 91 clocks magazine}
     {83C87}    16: Frequency87 := 3440 * ClockFreq / Result.Speed287;  { 86 clocks meas.}
     {83S87}    15: Frequency87 := 1880 * ClockFreq / Result.Speed287;  { 47 clocks meas.}
     {83D87}    14: Frequency87 := 1470 * ClockFreq / Result.Speed287;  { 36 clocks meas.}
     {82S87}    13: Frequency87 := 1880 * ClockFreq / Result.Speed287;  { 47 clocks }
     {82S87}    12: Frequency87 := 1880 * ClockFreq / Result.Speed287;  { 47 clocks }
     {3C87sx}   11: Frequency87 := 2280 * ClockFreq / Result.Speed287;  { 57 clocks DataSheet }
     {3C87}     10: Frequency87 := 2240 * ClockFreq / Result.Speed287;  { 57 clocks meas.}
     {2C87}    8,9: Frequency87 := (1970 * ClockFreq / Result.Speed287) * (0.928 + Index/65.0);  { 49 Takte }
     {387sx}     7: Frequency87 := 5160 * ClockFreq / Result.Speed287;  { 129 clocks }
     {387}       6: Frequency87 := 5120 * ClockFreq / Result.Speed287;  { 128 clocks meas. }
     {287XL}     5: Frequency87 := 5440 * ClockFreq / Result.Speed287;  { 136 clocks}
     {287}       4: Frequency87 := (7690 * ClockFreq / Result.Speed287) * (0.928 + Index/65.0);  {183 clocks meas.}
     {80C187}    3: Frequency87 := 5440 * ClockFreq / Result.Speed87;   { 136 clocks }
     {8087}      2: Frequency87 := 7440 * ClockFreq / Result.Speed87;   { 186 clocks meas.}
   END;

   { Correction for faster execution of coprocessor instructions with 486DLC }

   If (Cpu = p486dlc) Then
      Frequency87 := Frequency87 / 1.055;
   CoProFreq := Frequency87 / 1e6;
   If Result.NDPType = 1 Then CoProFreq := 0.0;

  FreeMem (MoveBuffer, 20000);
End;
*)


Function WaitStates;

Const
   MoveTime:    ARRAY [i88 .. Cyrix] OF INTEGER =
                (25, 17, 25, 17, 8, 16, 8, 16, 4, 4, 8, 4, 8, 4, 4,
                5, 3, 3, 1, 1, 4);

Var DataWidth   : Byte;
    FirstLevel  : Word;
    SecondLevel : Word;
    CacheThru   : Real;
    Cache2Thru  : Real;
    MemThru     : Real;

Begin
  PreSpeedTest;
  WhatCPU;

  GetMem (MoveBuffer, 20000);
  IF CPU >= i386 THEN
    DataWidth := 32
  ELSE
    DataWidth:= 16;

  SpeedTest (Word (1) { BildSchirm }, Word(ExtendedMem), Word(ExpandedMem),
             MoveBuffer, Ptr (EMS_Base, 0), ScreenAddr, Result);

  TempFreq := 200 * AAM_Time [CPU] * ClockFreq / Result.AAMTime;

  CacheSize (False, CPU > i286, FirstLevel, SecondLevel, CacheThru, Cache2Thru, MemThru);

  WaitStates := (((((DataWidth DIV 8) * TempFreq / (MoveTime [CPU] * 1024)) / MemThru)
                * MoveTime [CPU] - MoveTime [CPU]) * 0.5);
  FreeMem (MoveBuffer, 20000);
End;


Function IsCPUCache;

Var
  FirstLevel  : Word;
  SecondLevel : Word;
  CacheThru   : Real;
  Cache2Thru  : Real;
  MemThru     : Real;

Begin
  WhatCPU;
  CacheSize (False, CPU > i286, FirstLevel, SecondLevel, CacheThru, Cache2Thru, MemThru);
  If (FirstLevel <> 0) Or (SecondLevel <> 0) Then IsCPUCache := True Else
    IsCPUCache := False;
End;


Function CPUCacheLevel;

Var
  FirstLevel  : Word;
  SecondLevel : Word;
  CacheThru   : Real;
  Cache2Thru  : Real;
  MemThru     : Real;

Begin
  WhatCPU;
  CacheSize (False, CPU > i286, FirstLevel, SecondLevel, CacheThru, Cache2Thru, MemThru);
  If FirstLevel <> 0 Then CPUCacheLevel := 1;
  If SecondLevel <> 0 Then CPUCacheLevel := 2;
End;


Function CPUCacheKBFirst;

Var
  FirstLevel  : Word;
  SecondLevel : Word;
  CacheThru   : Real;
  Cache2Thru  : Real;
  MemThru     : Real;

Begin
  WhatCPU;
  CacheSize (False, CPU > i286, FirstLevel, SecondLevel, CacheThru, Cache2Thru, MemThru);
  CPUCacheKBFirst := FirstLevel;
End;


Function CPUCacheKBSecond;

Var
  FirstLevel  : Word;
  SecondLevel : Word;
  CacheThru   : Real;
  Cache2Thru  : Real;
  MemThru     : Real;

Begin
  WhatCPU;
  CacheSize (False, CPU > i286, FirstLevel, SecondLevel, CacheThru, Cache2Thru, MemThru);
  CPUCacheKBSecond := SecondLevel;
End;


Function CPUCacheThruFirst;

Var
  FirstLevel  : Word;
  SecondLevel : Word;
  CacheThru   : Real;
  Cache2Thru  : Real;
  MemThru     : Real;

Begin
  WhatCPU;
  CacheSize (False, CPU > i286, FirstLevel, SecondLevel, CacheThru, Cache2Thru, MemThru);
  CPUCacheThruFirst := CacheThru;
End;


Function CPUCacheThruSecond;

Var
  FirstLevel  : Word;
  SecondLevel : Word;
  CacheThru   : Real;
  Cache2Thru  : Real;
  MemThru     : Real;

Begin
  WhatCPU;
  CacheSize (False, CPU > i286, FirstLevel, SecondLevel, CacheThru, Cache2Thru, MemThru);
  CPUCacheThruSecond := Cache2Thru;
End;


Function MemThru;

Var
  FirstLevel  : Word;
  SecondLevel : Word;
  CacheThru   : Real;
  Cache2Thru  : Real;
  MemThruTemp : Real;

Begin
  WhatCPU;
  CacheSize (False, CPU > i286, FirstLevel, SecondLevel, CacheThru, Cache2Thru, MemThruTemp);
  MemThru := MemThruTemp;
End;


Function BIOSExtThru;

Begin
  PreSpeedTest;
  GetMem (MoveBuffer, 20000);

  SpeedTest (Word (1) { BildSchirm }, Word(1), Word(ExpandedMem),
             MoveBuffer, Ptr (EMS_Base, 0), ScreenAddr, Result);

  BiosExtThru := (ClockFreq * 10000 / Result.Ext_Time) / 1024;

  FreeMem (MoveBuffer, 20000);
End;


Function EMSThru;

Begin
  WhatCPU;
  PreSpeedTest;
  GetMem (MoveBuffer, 20000);

  SpeedTest (Word (1) { BildSchirm }, Word(ExtendedMem), Word(ExpandedMem),
             MoveBuffer, Ptr (EMS_Base, 0), ScreenAddr, Result);

  FreeMem (MoveBuffer, 20000);

  IF CPU >= i386 THEN
     EMSThru := (ClockFreq * 16000 / Result.EMS_Time) / 1024
  ELSE
     EMSThru := (ClockFreq * 10000 / Result.EMS_Time) / 1024;
End;


Function BUSWidth;

Const
   BusWidthTable:    ARRAY [i88 .. Cyrix] OF BYTE =
                (8, 16, 8, 16, 8, 16, 8, 16, 16, 32, 16, 32, 32, 16, 32, 32,
                32, 32, 32, 32, 32);
Begin
   WhatCPU;
   BusWidth := BusWidthTable[CPU];
End;


Function BiosRevision;

{Var W : Word;}

Begin
  Regs.AH := $C0;
  Regs.ES := 0;
  Regs.BX := 0;
  Regs.Flags := Regs.Flags and FCarry;
  Intr ($15, regs);
  BiosRevision := Mem[Regs.ES:Regs.BX + 4];
End;

Function MachineType;

Const dells: Array [2..$11] Of String[5] = ('200', '300', '?', '220', '310',
             '325', '?', '310A', '316', '220E', '210', '316SX', '316LT',
             '320LX', '?', '425E');

      dellnums: set of 0..$FF = [2, 3, 5..7, 9..$0F, $11];

Var RomInfoSeg : Word;
    RomInfoOfs : Word;
    foos:string[8];

Begin
  EndString := '';
  If UpCase(Chr(Mem[$F000:$E076])) = 'D' then Begin
    S := '';
    For xWord1 := $E077 To $E079 Do S := S + UpCase(Chr(Mem[$F000:xword1]));
    If S = 'ELL' Then Begin
      EndString := 'Dell ';
      xBool := True;
      xByte := Mem[$F000:$E845];
      If xByte In DellNums
        Then EndString := Concat (EndString, Dells[xByte], ' ')
        Else Begin
          EndString := ConCat (EndString, 'unknown; ID is', hex (xbyte, 2),' ');
          xBool := False;
        End;
      EndString := ConCat (EndString, '/');
    End
  End;

  Regs.AX := $6F00;
  Regs.BX := 0;
  Regs.Flags := Regs.Flags and FCarry;
  Intr($16, Regs);
  If ((FCarry And Regs.Flags) = 0) And (Regs.BX = $4850) then EndString := 'HP Vectra Series ';

  Regs.AX := $4DD4;
  Intr ($15, Regs);
  If Regs.BX = $4850 Then EndString := 'HP 95 LX ';

  Regs.AH := $C0;
  Regs.ES := 0;
  Regs.BX := 0;
  Regs.Flags:=Regs.Flags and FCarry;
  Intr($15, regs);
  If ((regs.Flags AND FCarry) = 0) and (Regs.AH = 0) then Begin
    RomInfoSeg := Regs.ES;
    RomInfoOfs := Regs.BX;
    xWord1 := MemW[Regs.ES:Regs.BX + 2]; {model byte + secondary model byte}
    xByte := Mem[Regs.ES:Regs.BX + 4]; {BIOS revision, zero-based}
    Case xWord1 Of
      $0000 : EndString := ConCat (EndString, 'AT&T 6300/Olivetti M24');
      $00F8 : If BiosDate = '03/30/87'
                Then EndString := ConCat (EndString, 'PS/2 Model 80 386-16')
                Else EndString := ConCat (EndString, 'PS/2 Model 75 486-33');
      $00F9 : EndString := ConCat (EndString, 'PC Convertible');
      $00FA : Case xByte Of
                $00 : EndString := ConCat (EndString, 'PS/2 Model 30 (8MHz 8086)');
                $01 : EndString := ConCat (EndString, 'PS/2 Model 30');
                $02 : EndString := ConCat (EndString, 'PS/2 Model 30');
              End;
      $00FB : Case xByte Of
                $01 : If BiosDate = '01/10/86'
                        Then EndString := ConCat (EndString, 'PC/XT (enhanced)')
                        Else If BiosDate = '05/13/94'
                          Then EndString := ConCat (EndString, 'HP 200LX Bios V1.01 AD (Deutsch)');
                $02 : EndString := ConCat (EndString, 'PC/XT');
                $04 : EndString := ConCat (EndString, 'HP 100LX Bios V1.04 A');
              End;
      $00FC : If xByte = 1
                then EndString := ConCat (EndString, 'PC-AT 2x9, 6MHz')
                Else EndString := ConCat (EndString, 'Industrial AT 7531/2');
      $00FF : EndString := Concat (EndString, 'Tandy 1000 SL');
      $01F8 : EndString := ConCat (EndString, 'PS/2 Model 80 20MHz 386');
      $01FA : EndString := ConCat (EndString, 'PS/2 Model 25/25L');
      $01FB : EndString := ConCat (EndString, 'PC/XT-2');
      $01FC : Case xByte Of
                $00:begin
                      if BiosDate = '11/15/85' then EndString := ConCat (EndString, 'PC-AT 319 or 339, 8MHz')
                      else if BiosDate = '01/15&88' then EndString := ConCat (EndString, 'Toshiba T5200/100')
                      else if BiosDate = '12/26*89' then EndString := ConCat (EndString, 'Toshiba T1200/XE')
                      else if BiosDate = '07/24&90' then EndString := ConCat (EndString, 'Toshiba T5200/200')
                      else if BiosDate = '09/17/87' then EndString := ConCat (EndString, 'Tandy 3000')
                      else if BiosDate = '11/14/88' then EndString := ConCat (EndString, 'Compaq Portable III')
                      else EndString := ConCat (EndString, 'AT clone');
                    end;
                $30:EndString := ConCat (EndString, 'Tandy 3000NL')
              else
                EndString := ConCat (EndString, 'Compaq 286/386 or clone');
              end;
      $01FF : EndString := Concat (EndString, 'Tandy 1000 TL');
      $02F8 : EndString := ConCat (EndString, 'PS/2 Model 55-5571');
      $02FC : If BiosDate = '04/21/86' Then EndString := ConCat (EndString, 'PC/XT-286')
              Else If BiosDate = '08/05/93' Then EndString := ConCat (EndString, 'Compaq Contura 486')
              Else If BiosDate = '08/11/88' Then EndString := ConCat (EndString, 'SoftWindows 1.0.1 (PowerMac)')
              Else EndString := ConCat (EndString, 'Compaq LTE Lite');
      $04F8 : If xByte=$00
                Then EndString := ConCat (EndString, 'PS/2 Model 70 386-20')
                Else EndString := ConCat (EndString, 'PS/2 Model 70 386-20, Typ 2');
      $04FC : Case xByte Of
                $00,
                $01 : EndString := ConCat (EndString, 'PS/2 Model 50 286-10');
                $02 : If BiosDate = '01/28/88'
                        Then EndString := ConCat (EndString, 'PS/2 Model 50Z 286-10')
                        Else EndString := ConCat (EndString, 'PS/2 Model 50');
                $03 : EndString := ConCat (EndString, 'PS/2 Model 50Z 286-10');
                $04 : EndString := ConCat (EndString, 'PS/2 Model 50Z');
              Else
                EndString := ConCat (EndString, 'PS/2 50?');
              End;
      $05F8 : EndString := ConCat (EndString, 'IBM PC 7568');
      $05FC : EndString := ConCat (EndString, 'PS/2 Model 60 10MHz 286');
      $06F8 : EndString := ConCat (EndString, 'PS/2 Model 55-5571');
      $06FC : If xByte = $00
                then EndString := ConCat (EndString, '7552-140 "Gearbox"')
                Else If xByte = $01
                  Then EndString := ConCat (EndString, '7552-540 "Gearbox"');
      $07F8 : Case xByte Of
                $00,
                $02 : EndString := ConCat (EndString, 'IBM PC 7561/2');
                $01,
                $03 : EndString := ConCat (EndString, 'PS/2 Model 55-5551');
              End;
      $08FC : If xByte = $00 Then
                EndString := ConCat (EndString, 'PS/2 Model 25/286')
              Else
                EndString := ConCat (EndString, 'Epson, unknown model');
      $09F8 : Case xByte Of
                $00 : EndString := ConCat (EndString, 'PS/2 Model 70 386DX-16, Typ 1');
                $02,
                $03 : EndString := ConCat (EndString, 'PS/2 Model 70');
                $04 : EndString := ConCat (EndString, 'PS/2 Model 70 386-16, Typ 33');
              End;
      $09FC : If xByte=$00 Then Begin
                If BiosDate = '08/25/88'
                  Then EndString := ConCat (EndString, 'PS/2 Model 30 286-10')
                  Else EndString := ConCat (EndString, 'PS/2 Model 25 286-10');
              End Else If xByte = $02
                Then EndString := ConCat (EndString, 'PS/2 Model 25 or 30');
      $0BF8 : Case xByte Of
                $00 : EndString := ConCat (EndString, 'PS/2 Model P70 (8573-121), Typ 2');
                $02 : EndString := ConCat (EndString, 'PS/2 Model P70?');
              End;
      $0BFC : If BiosDate = '12/01/89'
                Then EndString := ConCat (EndString, 'PS/1 Typ 44')
                Else If BiosDate = '02/16/90'
                  Then EndString := ConCat (EndString, 'PS/1 Model 2011 286-10');
      $0CF8 : EndString := ConCat (EndString, 'PS/2 Model 55SX 16MHz 386SX');
      $0DF8 : Case xByte Of
                $00,
                $01 : EndString := ConCat (EndString, 'PS/2 Model 70 386-25, Typ 3');
              Else
                EndString := ConCat (EndString, 'PS/2 Model 70 486-25, Typ 3');
              End;
      $0EF8 : EndString := ConCat (EndString, 'PS/1 486SX');
      $0FF8 : EndString := ConCat (EndString, 'PS/1 486DX');
      $10F8 : EndString := ConCat (EndString, 'PS/2 Model 55-5551');
      $11F8 : EndString := ConCat (EndString, 'PS/2 Model 90 25MHz 386');
      $12F8 : EndString := ConCat (EndString, 'PS/2 Model 95 XP');
      $13F8 : EndString := ConCat (EndString, 'PS/2 Model 90 33MHz 386');
      $14F8 : EndString := ConCat (EndString, 'PS/2 Model 90-AK9 25MHz 486');
      $15F8 : EndString := ConCat (EndString, 'PS/2 Model 90 XP');
      $16F8 : EndString := ConCat (EndString, 'PS/2 Model 90-AKD 33MHz 486');
      $17F8 : EndString := ConCat (EndString, 'PS/2 Model 90 XP');
      $19F8 : Case xByte Of
                $05 : If BiosDate = '03/15/91' Then
                        EndString := ConCat (EndString, '')
                      Else
                        EndString := ConCat (EndString, 'PS/2 Model 35/35LS/40 386SX-20');
                $06 : EndString := ConCat (EndString, 'PS/2 Model 35 SX / 40 SX, Typ 37');
              End;
      $1AF8 : EndString := ConCat (EndString, 'PS/2 Model 95 XP');
      $1BF8 : If BiosDate = '09/29/89' Then
                EndString := ConCat (EndString, 'PS/2 Model 70 386DX-25')
              Else
                EndString := ConCat (EndString, 'PS/2 Model 70 486-25');
      $1CF8 : EndString := ConCat (EndString, 'PS/2 Model 65-121 16MHz 386SX');
      $1EF8 : EndString := ConCat (EndString, 'PS/2 Model 55LS 16MHz 386SX');
      $20FC : EndString := ConCat (EndString, 'Compaq ProLinea');
      $23F8 : EndString := ConCat (EndString, 'PS/2 Model L40 20MHz 386SX');
      $25F8 : Case xByte Of
                $00 : EndString := ConCat (EndString, 'PS/2 Model 57 SLC');
                $06 : EndString := ConCat (EndString, 'PS/2 Model M57 386SLC-20');
              End;
      $26F8 : Case xByte Of
                $00 : EndString := ConCat (EndString, 'PS/2 Model 57 SX');
                $01 : EndString := ConCat (EndString, 'PS/2 Model 57 386SX-20');
                $02 : EndString := ConCat (EndString, 'PS/2 Model 57 386SX-20, SCSI');
              End;
      $28F8 : EndString := ConCat (EndString, 'PS/2 Model 95 XP');
      $29F8 : EndString := ConCat (EndString, 'PS/2 Model 90 XP');
      $2AF8 : EndString := ConCat (EndString, 'PS/2 Model 95 50MHz 486');
      $2BF8 : EndString := ConCat (EndString, 'PS/2 Model 90 50MHz 486');
      $2CF8 : Case xByte Of
                $00 : EndString := ConCat (EndString, 'PS/2 Model 95 XP');
                $01 : EndString := ConCat (EndString, 'PS/2 Model 95 486SX-20');
              End;
      $2D00 : EndString := ConCat (EndString, 'Compaq PC (4.77 mHz Original)');
      $2DF8 : EndString := ConCat (EndString, 'PS/2 Model 90 20MHz 486SX');
      $2EF8 : Case xByte Of
                $00 : EndString := ConCat (EndString, 'PS/2 Model 95XP 486SX-20');
                $01 : EndString := ConCat (EndString, 'PS/2 Model 95 486SX-20+487SX');
              End;
      $2FF8 : EndString := ConCat (EndString, 'PS/2 Model 90 20MHz 486SX+487SX');
      $30F8 : EndString := ConCat (EndString, 'PS/1 Model 2121 16MHz 386SX');
      $30FA: EndString := ConCat (EndString, 'IBM Restaurant Terminal');
      $30FC,
      $31FC,
      $33FC : EndString := ConCat (EndString, 'Epson, unknown model');
      $33F8 : EndString := ConCat (EndString, 'PS/2 Model 30-386');
      $34F8 : EndString := ConCat (EndString, 'PS/2 Model 25-286');
      $36F8 : EndString := ConCat (EndString, 'PS/2 Model 95 XP');
      $37F8 : EndString := ConCat (EndString, 'PS/2 Model 90 XP');
      $38F8 : EndString := ConCat (EndString, 'PS/2 Model 57');
      $39F8 : EndString := ConCat (EndString, 'PS/2 Model 95 XP');
      $3FF8 : EndString := ConCat (EndString, 'PS/2 Model 90 XP');
      $40F8 : EndString := ConCat (EndString, 'PS/2 Model 95-XP');
      $41F8 : EndString := ConCat (EndString, 'PS/2 Model 77');
      $42FC : EndString := ConCat (EndString, 'Olivetti M280');
      $43FE : EndString := ConCat (EndString, 'Olivetti M240');
      $45F8 : EndString := ConCat (EndString, 'PS/2 Model 90 XP (Pentium)');
      $45FC : EndString := ConCat (EndString, 'Olivetti M380 (XP1, 3, or 5)');
      $46F8 : EndString := ConCat (EndString, 'PS/2 Model 95 XP (Pentium)');
      $46FF : EndString := ConCat (EndString, 'Olivetti M15');
      $47F8 : EndString := ConCat (EndString, 'PS/2 Model 90/95 E (Pentium)');
      $48F8 : EndString := ConCat (EndString, 'PS/2 Model 85');
      $48FC : EndString := ConCat (EndString, 'Olivetti M290');
      $49F8 : EndString := ConCat (EndString, 'PS/ValuePoint 325T');
      $4AF8 : EndString := ConCat (EndString, 'PS/ValuePoint 425SX');
      $4BF8 : EndString := ConCat (EndString, 'PS/ValuePoint 433DX');
      $4CFB : EndString := ConCat (EndString, 'Olivetti M200');
      $4EF8 : EndString := ConCat (EndString, 'PS/2 Model 295');
      $4EFA : EndString := ConCat (EndString, 'Olivetti M111');
      $4FFC : EndString := ConCat (EndString, 'Olivetti M250');
      $50F8 : Case xByte Of
                $00 : EndString := ConCat (EndString, 'PS/2 Model P70 (8573) 386-16');
                $01 : EndString := ConCat (EndString, 'PS/2 Model P70 (8570-031)');
              End;
      $50FC : EndString := ConCat (EndString, 'Olivetti M380 (XP7)');
      $51FC : EndString := ConCat (EndString, 'Olivetti PCS286');
      $52F8 : EndString := ConCat (EndString, 'PS/2 Model P75 33MHz 486');
      $52FC : EndString := ConCat (EndString, 'Olivetti M300');
      $56F8 : EndString := ConCat (EndString, 'PS/2 Model CL57 SX');
      $57F8 : EndString := ConCat (EndString, 'PS/2 Model 90 XP');
      $58F8 : EndString := ConCat (EndString, 'PS/2 Model 95 XP');
      $59F8 : EndString := ConCat (EndString, 'PS/2 Model 90 XP');
      $5AF8 : EndString := ConCat (EndString, 'PS/2 Model 95 XP');
      $5BF8 : EndString := ConCat (EndString, 'PS/2 Model 90 XP');
      $5CF8 : EndString := ConCat (EndString, 'PS/2 Model 95 XP');
      $5DF8 : EndString := ConCat (EndString, 'PS/2 Model N51 SLC');
      $5EF8 : EndString := ConCat (EndString, 'IBM ThinkPad 700');
      $61F8 : EndString := ConCat (EndString, 'Olivetti P500');
      $62F8 : EndString := ConCat (EndString, 'Olivetti P800');
      $80F8 : Case xByte Of
               $00 : EndString := ConCat (EndString, 'PS/2 Model 80 386-25');
               $01 : EndString := ConCat (EndString, 'PS/2 Model 80-A21 386-25');
             End;
      $81F8 : EndString := ConCat (EndString, 'PS/2 Model 55-5502');
      $81FC : If BiosDate = '01/15/88' Then
                EndString := ConCat (EndString, 'Phoenix 386 V1.10 10a')
              Else
                EndString := ConCat (EndString, '"OEM Rechner"');
      $82FC : EndString := ConCat (EndString, '"OEM Rechner"');
      $87F8 : EndString := ConCat (EndString, 'PS/2 Model N33SX');
      $88F8 : EndString := ConCat (EndString, 'PS/2 Model 55-5530T');
      $94FC : EndString := ConCat (EndString, 'Zenith 386');
      $97F8 : EndString := ConCat (EndString, 'PS/2 Model 55 Note N23SX');
      $99F8 : EndString := ConCat (EndString, 'PS/2 Model N51 SX');
      $9A00 : EndString := ConCat (EndString, 'Compaq Plus (XT compatible)');
      $A6FE : EndString := ConCat (EndString, 'Quadram Quad386');
      $F2F8 : EndString := ConCat (EndString, 'Reply Model 32');
      $F6F8 : EndString := ConCat (EndString, 'Memorex Telex');
      $F800 : begin
                foos:=BiosDate;
                If (foos[7] = '8') And (foos[8] = '7')
                Then EndString := ConCat (EndString, 'PS/2 Model 80')
                Else If BiosDate = '03/30/87'
                  Then EndString := ConCat (EndString, 'PS/2 Model 80-041 16 mHz')
                  Else If BiosDate = '08/27/87'
                    Then EndString := ConCat (EndString, 'PS/2 Model 80-071 16 mHz');
              end;
      $F801 : If BiosRevision = 1 Then
                      EndString := ConCat (EndString, 'PS/2 Model 80-111 20 mHz');
      $F804 : EndString := ConCat (EndString, 'PS/2 Model 70-121');
      $F809 : If BiosRevision = 2 Then
                      EndString := ConCat (EndString, 'PS/2 Model 70 Desktop');
      $F80B : EndString := ConCat (EndString, 'PS/2 Model 70 Portable');
      $F80D : EndString := ConCat (EndString, 'PS/2 Model 70-A21');
      $F900 : EndString := ConCat (EndString, 'PC-Kompatibler');
      $FA00 : EndString := ConCat (EndString, 'PS/2 Model 30');
      $FB00 : Case BiosRevision Of
                      0 : EndString := ConCat (EndString, 'XT-2 (frÅherer)');
                      1 : EndString := ConCat (EndString, 'XT Model 089');
                    End;
      $FB01 : EndString := ConCat (EndString, 'XT-2 (spÑterer)');
      $FC00 : Case BiosRevision Of
                      0 : EndString := ConCat (EndString, 'AT Model 099 (Original)/7531/2 Industrial AT');
                      1 : EndString := ConCat (EndString, 'AT Model 239 6mHz (6.6 max governor)');
                    End;
      $FC01 : Case BiosRevision Of
                      00 : If BiosDate = '11/15/85' Then
                             EndString := ConCat (EndString, 'AT Model 339, 339 8mHz (8.6 max governor)')
                           Else
                             If BiosDate = '01/24/90' Then
                               EndString := ConCat (EndString, 'Compaq DeskPro 80386/25e')
                             Else
                               EndString := ConCat (EndString, 'Compaq 386/16');
                      03 : EndString := ConCat (EndString, '? with Phoenix 386 BIOS');
                      81 : EndString := ConCat (EndString, '? with Phoenix 386 BIOS');
                    End;
      $FC02 : If BiosDate = '10/02/89'
                Then EndString := ConCat (EndString, 'Compaq Deskpro 386s/386SX 16 mHz')
                Else If BiosDate = '04/21/86'
                  Then EndString := ConCat (EndString, 'XT/286');
      $FC05 : EndString := ConCat (EndString, 'PS/2 Model 60');
      $FD00 : EndString := ConCat (EndString, 'PCjr');
      $FDF8 : EndString := ConCat (EndString, 'IBM Processor Complex (with VPD)');
      $FE00 : EndString := ConCat (EndString, 'XT, Portable PC, XT/370, 3270PC');
      $FEFA : EndString := ConCat (EndString, 'IBM PCradio 9075');
      $FF00 : If BiosDate = '04/24/81'
                Then EndString := ConCat (EndString, 'PC-0 (16k Motherboard)')
                Else If BiosDate = '10/19/81'
                  Then EndString := ConCat (EndString, 'PC-1 (64k Motherboard)')
                  Else If (BiosDate = '08/16/82') or (BiosDate = '10/27/82')
                    Then EndString := ConCat (EndString, 'PC, XT/XT-370 (256k Motherboard)');
      $FFF9 : EndString := ConCat (EndString, 'PC-Compatible');
    end;
  end;

  {int 15/c0 came up short, so we look at the machine ID byte in desperation}
  if Endstring='' then Case Mem[$FFFF:$000E] Of
    $FF : if mem[$f000:$c000]=$21
            then EndString := ConCat (EndString, 'Tandy 1000')
            else EndString := ConCat (EndString, 'PC');
    $FE,
    $FB : EndString := ConCat (EndString, 'PC/XT');
    $FD : EndString := ConCat (EndString, 'PCjr');
    $FC : EndString := ConCat (EndString, 'PC/AT');
    $FA : EndString := ConCat (EndString, 'PS/2 Model 30');
    $F9 : EndString := ConCat (EndString, 'PS/2 Convertible');
    $F8 : EndString := ConCat (EndString, 'PS/2 Model 90/95?');
    $9A : EndString := ConCat (EndString, 'Compaq XT or Compaq Plus');
    $2D : EndString := ConCat (EndString, 'Compaq PC or Compaq Deskpro');
    $30 : EndString := ConCat (EndString, 'Sperry PC');
    $E9 : EndString := ConCat (EndString, 'Peacock XT');
  Else
    EndString := 'unknown, ID : ' + Hex (xWord1, 4);
  End;

  if EndString='' then EndString:='error!'; {we should never get here}
  MachineType := EndString;
End;

Function IsDMAChannel3;

Begin
  Regs.AH := $C0;
  Regs.ES := 0;
  Regs.BX := 0;
  Regs.Flags := Regs.Flags and FCarry;
  Intr ($15, regs);
  xByte := Mem[Regs.ES:Regs.BX + 5];
  IsDMAChannel3 := (xByte And $80 = $80);
End;


Function IsSlave8259;

Begin
  Regs.AH := $C0;
  Regs.ES := 0;
  Regs.BX := 0;
  Regs.Flags := Regs.Flags and FCarry;
  Intr ($15, regs);
  xByte := Mem[Regs.ES:Regs.BX + 5];
  IsSlave8259 := (xByte And $40 = $40);
End;


Function IsRealClock;

Begin
  Regs.AH := $C0;
  Regs.ES := 0;
  Regs.BX := 0;
  Regs.Flags := Regs.Flags and FCarry;
  Intr ($15, regs);
  xByte := Mem[Regs.ES:Regs.BX + 5];
  IsRealClock :=  (xByte And $20 = $20);
End;


Function IsKeybIntercept;

Begin
  Regs.AH := $C0;
  Regs.ES := 0;
  Regs.BX := 0;
  Regs.Flags := Regs.Flags and FCarry;
  Intr ($15, Regs);
  xByte := Mem[Regs.ES:Regs.BX + 5];
  IsKeybIntercept := (xbyte And $10 = $10);
End;


Function IsWaitExtEvent;

Begin
  Regs.AH := $C0;
  Regs.ES := 0;
  Regs.BX := 0;
  Regs.Flags := Regs.Flags and FCarry;
  Intr ($15, regs);
  xbyte := Mem[Regs.ES:Regs.BX + 5];
  IsWaitExtEvent := (xbyte And $08 = $08);
End;


Function IsExtBiosSeg;

Begin
  Regs.AH := $C0;
  Regs.ES := 0;
  Regs.BX := 0;
  Regs.Flags := Regs.Flags and FCarry;
  Intr ($15, regs);
  xByte := Mem[Regs.ES:Regs.BX + 5];
  If (xByte And $04 = $04) Then
    Begin
      Regs.AH:=$C1;
      Intr($15, regs);
      If (Regs.Flags And FCarry) = 0 Then
        IsExtBiosSeg := Regs.ES
      Else
        IsExtBiosSeg := 0;
    End
  Else
    IsExtBiosSeg := 0;
End;


Function IsKeyb16_9;

Begin
  Regs.AH := $C0;
  Regs.ES := 0;
  Regs.BX := 0;
  Regs.Flags := Regs.Flags and FCarry;
  Intr ($15, regs);
  IsKeyb16_9 := (Mem[Regs.ES:Regs.BX + 6] And $40 = $40);
End;


Function KeyboardId;

Begin
  Regs.AH := $C0;
  Regs.Flags := Regs.Flags And FCarry;
  Intr ($15, Regs);
  If ((Regs.Flags And FCarry) = 0) Then
    If ((Mem[Regs.ES:Regs.BX + 7] And $30) = 1) Then { Wird die Funktion unterstÅtzt ? }
      Begin
        Regs.AH := $09;
        Intr ($16, Regs);
        If ((Regs.AL And $10) = 1 )Then { Werden diese Funktion unterstÅtzt ? }
          Begin
            Regs.AH := $0A;
            Intr ($16, Regs);
            KeyBoardId := Regs.BX;
          End
        Else
          KeyboardId := 0;
      End
    Else
      KeyboardId := 0;
End;


Function KeyboardController;

Begin
  Regs.AH := $C0;
  Regs.ES := 0;
  Regs.BX := 0;
  Regs.Flags := Regs.Flags and FCarry;
  Intr ($15, Regs);
  if (Regs.Flags And FCarry = 0) and (Regs.AH = 0) then
    begin
      xbyte := Mem [Regs.ES:Regs.BX + 6];
      If xByte And 4 = 4 then
        KeyboardController := 'kein-8042'
      Else
        KeyboardController := '8042';
    End
  Else
    KeyboardController := '???';
End;


Function BIOSscan(searchseg,startofs,endofs:word; var foundofs:word):boolean;

  function scan(var targetstring:string; _seg, c, d: word; var e: word): boolean;
  var
    i      : Longint;
    index  : Byte;
    xbool1 : Boolean;
    xbool2 : Boolean;
  begin
    i := c;
    xbool1 := False;
    Repeat
      if i <= longint(d) - length(targetstring) + 1 then
        begin
          index:=0;
          xbool2:=false;
          repeat
            if index < length(targetstring) then
              if UpCase(Chr(Mem[_seg : i + index])) = targetstring[1+index] then
                Inc(index)
              else
                begin
                  xbool2:=true;
                  Inc(i)
                end
              else
                begin
                  xbool2:=true;
                  xbool1:=true;
                  e:=i;
                  scan:=true
                end
          until xbool2
        end
      else
        begin
          xbool1:=true;
          scan:=false
        end
    until xbool1
  End; { Scan }

Const
  max   = 3;
  notice : array[1..max] of string[10] = ('(C)', 'COPR.', 'COPYRIGHT');
  pchar = [' '..'~'];
var
  loop   : 1..max;
  target : string;
  xlong  : longint;
  foundCopyright:boolean;
begin
  xlong := endofs;
  foundCopyright := false;

  for loop:=1 to max do begin
    target:=notice[loop];
    if foundCopyright
      then xlong:=longint(xword) - 2 + Length(target);
    if (xlong >= startofs) and (xlong <= endofs)
    and (scan(target, searchseg, startofs, xlong, xword))
      then foundCopyright:=true;
  end;

  if foundCopyright then begin
    while (xword > startofs) and (chr(mem[searchseg:xword - 1]) in pchar) do
      Dec(xword);
    foundofs:=xword;
  end;
  BIOSscan:=foundCopyright;
End;


Function ShowBIOS (_seg, _ofs: word) : String;
{builds a string starting at _seg:_ofs until a non-printing char is hit}
var
  c:char;
Const
  printchars = [' '..'~'];
begin
  EndString := '';
  Repeat
    c:=Chr(Mem[_seg : _ofs]);
    if c in printchars
      then EndString := EndString + c
      else break;
    Inc(_ofs);
  until _ofs=$FFFF;
  ShowBios := EndString;
End;

Function BiosSource;
Begin
  If BIOSscan($F000, $C000, $FFFF, xword1)
    Then BiosSource := ShowBIOS ($F000, xword1)
    Else BiosSource := 'unknown';
End;


Function BiosShort;

  Function CheckAmiHiFlexBios : Boolean;

  Begin
    S := '';
    For xByte := 0 To 15 Do S := S + Chr (Mem[$F000:$8000+xByte]);
    CheckAmiHiFlexBios := (S = '(AAMMIIBBIIOOSS)');
  End;


  Function CheckAMIFlashBios: Boolean;

  Begin
    Regs.AX := $DA01;
    Regs.CL := $02;
    Intr ($15, Regs);
    CheckAMIFlashBios := (Regs.Flags And FCarry <> FCarry);
  End;


  Function CheckAmiBios : Boolean; { SpÑtes AMI 286er Bios / Triple Inc. }
  var
    xstring:string32;
  Begin
    xString := '';
    For xByte := 0 To 31 Do
      xString := xString + Chr (Mem[$F000:$8000 + xByte]);
    CheckAmiBios := (xString = 'XXXX88886666----0123AAAAMMMMIIII');
  End;

Begin
  EndString := BiosSource;
  If (Pos ('American Megatrends Inc.', EndString) <> 0) Or (Pos ('AMI', EndString) <> 0) Then
    Begin
      BiosShort := 'AMI';
      If CheckAmiHiFlexBios Then BiosShort := 'AMI Hiflex';
      If CheckAmiFlashBios Then BiosShort := 'AMI Flash';
    End
  Else
    If CheckAmiBios Then BiosShort := 'AMI' Else
      If Pos ('Phoenix', EndString) <> 0 Then BiosShort := 'Phoenix' Else
        If Pos ('Award', EndString) <> 0 Then BiosShort := 'Award' Else
          If Pos ('IBM', EndString) <> 0 Then BiosShort := 'IBM' Else
            If Pos ('Commodore', EndString) <> 0 Then BiosShort := 'Commodore' Else
              If Pos ('Toshiba', EndString) <> 0 Then BiosShort := 'Toshiba' Else
                BiosShort := 'unknown';
End;


Function BiosVersion;

Var rominfoofs : Word;
    rominfoseg : Word;

Begin
  S := '';
  Regs.AH := $C0;
  Regs.ES := 0;
  Regs.BX := 0;
  Regs.Flags := Regs.Flags and FCarry;
  Intr ($15, regs);
  If ((Regs.Flags And FCarry) = 0) and (Regs.AH = 0) then
    Begin
      rominfoseg:=Regs.ES;
      rominfoofs:=Regs.BX;
    End
  Else
    BiosVersion := 'unknown';

  for xword1 := rominfoofs + $0D to rominfoofs + $0F do
    s := s + Chr(Mem[rominfoseg: xword1]);
  if (s = 'PTL') And (BiosVersion <> 'unknown') Then
    begin
      BiosVersion := StrFnByte(unbcd(Mem[rominfoseg:rominfoofs + $B])) + '.' +
                     StrFnByte(unbcd(Mem[rominfoseg:rominfoofs + $C]));
    end
  Else
    BiosVersion := 'unknown';
End;


Function Is386PopAdBug;

Begin
  If PopAdBugTst = 1 Then Is386PopAdBug := True Else Is386PopADBug := False;
End;


Function Is386MulBug;

Begin
  If MulBugTst = 1 Then Is386MulBug := True Else Is386MulBug := False;
End;


Function IsP5FDivBug;

Begin
  If FDivBugTst = 1 Then IsP5FDivBug := True Else IsP5FDivBug := False;
End;


Function WhatMSW;

Begin
  Cpu_Info.Test_Type := 'T';
  Misc (Cpu_Info);
  WhatMSW := Cpu_Info.MSW
End;


Function IsMSWProtMode;

Begin
  Cpu_Info.Test_Type := 'T';
  Misc (Cpu_Info);
  IsMSWProtMode := (Cpu_Info.MSW And 1 = 1)
End;


Function IsMSWMonCoPro;

Begin
  Cpu_Info.Test_Type := 'T';
  Misc (Cpu_Info);
  IsMSWMonCoPro := (Cpu_Info.MSW And 2 = 2)
End;


Function IsMSWEmuCoPro;

Begin
  Cpu_Info.Test_Type := 'T';
  Misc (Cpu_Info);
  IsMSWEmuCoPro := (Cpu_Info.MSW And 4 = 4)
End;


Function WhatGDT;

Begin
  Cpu_Info.Test_Type := 'T';
  Misc (Cpu_Info);
  p := @Cpu_Info.GDT[1];
  pReal := p;
  WhatGDT := pReal^;
End;


Function WhatIDT;

Begin
  Cpu_Info.Test_Type := 'T';
  Misc (Cpu_Info);
  p := @Cpu_Info.IDT[1];
  pReal := p;
  WhatIDT := pReal^;
End;


Function CoProRounding;

Begin
  Cpu_Info.test_type:='N';
  Misc (Cpu_info);
  Case Cpu_Info.ndp_Cw And $0C00 Of
    $0000 : CoProRounding := 'NÑchster oder Gleicher Wert';
    $0400 : CoProRounding := 'Abrundung';
    $0800 : CoProRounding := 'Aufrundung';
    $0C00 : CoProRounding := 'Abschneiden';
  End;
End;


Function CoProPrecision;

Begin
  Cpu_Info.test_type:='N';
  Misc(cpu_info);
  Case Cpu_Info.ndp_Cw And $0300 Of
    $0000 : CoProPrecision := 24;
    $0100 : CoProPrecision := 0 {reserved};
    $0200 : CoProPrecision := 53;
    $0300 : CoProPrecision := 64;
  End
End;


Function IsAPM;

Begin
  Regs.AX := $5300;
  Regs.BX := $0000;
  Regs.Flags := Regs.Flags And Fcarry;
  Intr ($15, Regs);
  IsAPM := (((Regs.Flags And FCarry) = 0) And (Regs.BX = $504D));
End;


Function APMVersion;

Begin
  If IsAPM Then
    Begin
       Regs.AX := $5300;
       Regs.BX := $0000;
       Intr ($15, Regs);
       APMVersion := BCDWordToString (Regs.AX);
    End
  Else
    APMVersion := 'nicht vorhanden';
End;


Function APMIs16Prot;

Begin
  If IsAPM Then
    Begin
       Regs.AX := $5300;
       Regs.BX := $0000;
       Intr ($15, Regs);
       APMIs16Prot := ((Regs.CX And 1) = 1);
    End
  Else
    APMIs16Prot := False;
End;


Function APMIs32Prot;

Begin
  If IsAPM Then
    Begin
       Regs.AX := $5300;
       Regs.BX := $0000;
       Intr ($15, Regs);
       APMIs32Prot := ((Regs.CX And 2) = 1);
    End
  Else
    APMIs32Prot := False;
End;


Function APMIsBIOSPowMngmnt;

Begin
  If IsAPM Then
    Begin
       Regs.AX := $5300;
       Regs.BX := $0000;
       Intr ($15, Regs);
       APMIsBIOSPowMngmnt := ((Regs.CX And 8) = 1);
    End
  Else
    APMIsBIOSPowMngmnt := False;
End;


Function APMACLineStatus;

Begin
  If IsAPM Then
    Begin
       Regs.AX := $53A0;
       Regs.BX := $0001;
       Intr ($15, Regs);
       Case Regs.BH Of
         $00 : APMACLineStatus := 'Off-Line';
         $01 : APMACLineStatus := 'On-Line';
         $FF : APMACLineStatus := 'unknown';
       Else
         APMACLineStatus := '???';
       End;
    End
  Else
    APMACLineStatus := 'nicht vorhanden';
End;


Function APMBatteryStatus;

Begin
  If IsAPM Then
    Begin
       Regs.AX := $53A0;
       Regs.BX := $0001;
       Intr ($15, Regs);
       Case Regs.BH Of
         $00 : APMBatteryStatus := 'Aufgeladen';
         $01 : APMBatteryStatus := 'Wenig Aufgeladen';
         $02 : APMBatteryStatus := 'Kritisch';
         $03 : APMBatteryStatus := 'Leer';
         $FF : APMBatteryStatus := 'unknown';
       Else
         APMBatteryStatus := '???';
       End;
    End
  Else
    APMBatteryStatus := 'nicht vorhanden';
End;


Function APMBatteryLife;

Begin
  If IsAPM Then
    Begin
       Regs.AX := $53A0;
       Regs.BX := $0001;
       Intr ($15, Regs);
       If Regs.CL <> $FF Then APMBatteryLife := Regs.CL Else
         APMBatteryLife := 0;
    End
  Else
    APMBatteryLife := 0;
End;


Function IsJetStream;

Begin
  Regs.AH := $F0;
  Regs.DX := PortNumber;
  Intr ($17, Regs);
  IsJetStream := (Regs.AX = $0001);
End;


Function IsOnBoardSCSI : Boolean;

Begin
  Regs.AH := $C0;
  Regs.ES := 0;
  Regs.BX := 0;
  Regs.Flags := Regs.Flags and FCarry;
  Intr($15, Regs);
  if (Regs.Flags And FCarry = 0) And (Regs.AH = 0) then
    begin
      xbyte := Mem [Regs.ES:Regs.BX + 7];
      IsOnBoardSCSI := (Mem[Regs.ES:Regs.BX + 7] And 8 = 8)
    end
  Else
    IsOnBoardSCSI := False;
End;


Function IsIML;

Begin
  Regs.AH := $C0;
  Regs.ES := 0;
  Regs.BX := 0;
  Regs.Flags := Regs.Flags and FCarry;
  Intr ($15, Regs);
  if (Regs.Flags And FCarry = 0) And (Regs.AH = 0) Then
    Begin
      IsIML := (Mem[Regs.ES:Regs.BX + 7] And 2 = 2);
    End
  Else
    IsIML := False;
End;


Function IsIMLSCSISupp;

Begin
  Regs.AH := $C0;
  Regs.ES := 0;
  Regs.BX := 0;
  Regs.Flags := Regs.Flags and FCarry;
  Intr ($15, Regs);
  If (Regs.Flags And FCarry = 0) And (Regs.AH = 0) then
    Begin
      IsIMLSCSISupp := (Mem[Regs.ES:Regs.BX + 7] And 1 = 1);
    End
  Else
    IsIMLSCSISupp := False;
End;


Procedure BiosExtensions (var P : pBiosCopyright);

Begin
  xword1 := $C000;
  xbool := false;
  for xByte3 := 0 to 94 do
    begin
      if (MemW[xword1 : 0] = $AA55) then
        begin
          P^.BiosInfo[xByte3].IsThere := True;
          P^.BiosInfo[xByte3].Segment := xword1;
          P^.BiosInfo[xByte3].Size    := ((longint(512) * Mem[xword1: 2]) div 1024);
          If BIOSscan(xword1, $0000, $1FFF, xword2) then
            P^.BiosInfo[xByte3].Copyright := showBIOS(xword1, xword2)
          Else
            P^.BiosInfo[xByte3].Copyright := '(unknown)';
        end
      Else
        P^.BiosInfo[xByte3].IsThere := False;
      Inc(xword1, $0080)
    end;
End;


Function DevCount                      : Byte;

Begin
  Regs.AH := $52;
  MsDos (Regs);

  xWord1 := Regs.ES;
  xWord2 := Regs.BX + $0022;
  xWord3 := 0;
  While xWord2 < $FFFF Do
    Begin
      Inc (xWord3);
      For xByte := 0 To 17 Do Header [xByte] := Mem [xWord1 : xWord2 + xByte];
      xWord1 := Word (Header[3]) Shl 8 + Header[2];
      xword2 := Word (Header[1]) Shl 8 + Header[0];
    End;
  DevCount := xWord3;
End;


Function DevName;

Begin
  If Number <= DevCount Then
    Begin
      EndString := '';
      DevName := '';
      Regs.AH := $52;
      MsDos (Regs);

      xWord1 := Regs.ES;
      xWord2 := Regs.BX + $0022;
      xWord3 := 0;
      While xWord2 < $FFFF Do
        Begin
          Inc (xWord3);

          For xByte := 0 To 17 Do Header [xByte] := Mem [xWord1 : xWord2 + xByte];

          If xWord3 = Number Then
            Begin
              If Header[5] And $80 = $00 Then DevName := StrFnByte (Header[10]) Else
                For xByte := 10 To 17 Do
                  Begin
                    If Not (Header[xByte] = 32) Then
                      EndString := EndString + Chr(Header[xByte])
                    Else
                      DevName := EndString;
                    If xByte = 17 Then DevName := EndString;
                  End;
            End;
          xWord1 := Word (Header[3]) Shl 8 + Header[2];
          xword2 := Word (Header[1]) Shl 8 + Header[0];
        End;
    End
  Else
    DevName := 'nicht vorhanden';
End;


Function DevHeader (Number : Byte) : Pointer;

Begin
  If Number <= DevCount Then
    Begin
      Regs.AH := $52;
      MsDos (Regs);

      xWord1 := Regs.ES;
      xWord2 := Regs.BX + $0022;
      xWord3 := 0;
      While xWord2 < $FFFF Do
        Begin
          Inc (xWord3);

          For xByte := 0 To 17 Do Header [xByte] := Mem [xWord1 : xWord2 + xByte];

          If xWord3 = Number Then DevHeader := Ptr (xWord1, xWord2);
          xWord1 := Word (Header[3]) Shl 8 + Header[2];
          xword2 := Word (Header[1]) Shl 8 + Header[0];
        End;
    End
  Else
    DevHeader := Ptr (0,0);
End;


Function DevAttributes (Number : Byte) : Word;

Begin
  If Number <= DevCount Then
    Begin
      Regs.AH := $52;
      MsDos (Regs);

      xWord1 := Regs.ES;
      xWord2 := Regs.BX + $0022;
      xWord3 := 0;
      While xWord2 < $FFFF Do
        Begin
          Inc (xWord3);

          For xByte := 0 To 17 Do Header [xByte] := Mem [xWord1 : xWord2 + xByte];

          If xWord3 = Number Then DevAttributes := Word (Header[5] Shl 8 + Header[4]);
          xWord1 := Word (Header[3]) Shl 8 + Header[2];
          xword2 := Word (Header[1]) Shl 8 + Header[0];
        End;
    End
  Else
    DevAttributes := 0;
End;


Function DevStrategy (Number : Byte) : Pointer;

Begin
  If Number <= DevCount Then
    Begin
      Regs.AH := $52;
      MsDos (Regs);

      xWord1 := Regs.ES;
      xWord2 := Regs.BX + $0022;
      xWord3 := 0;
      While xWord2 < $FFFF Do
        Begin
          Inc (xWord3);

          For xByte := 0 To 17 Do Header [xByte] := Mem [xWord1 : xWord2 + xByte];

          If xWord3 = Number Then DevStrategy := Ptr (xWord1, (Header[7] Shl 8 + Header[6]));
          xWord1 := Word (Header[3]) Shl 8 + Header[2];
          xword2 := Word (Header[1]) Shl 8 + Header[0];
        End;
    End
  Else
    DevStrategy := Ptr (0, 0);
End;


Function DevInterrupt (Number : Byte) : Pointer;

Begin
  If Number <= DevCount Then
    Begin
      Regs.AH := $52;
      MsDos (Regs);

      xWord1 := Regs.ES;
      xWord2 := Regs.BX + $0022;
      xWord3 := 0;
      While xWord2 < $FFFF Do
        Begin
          Inc (xWord3);

          For xByte := 0 To 17 Do Header [xByte] := Mem [xWord1 : xWord2 + xByte];

          If xWord3 = Number Then DevInterrupt := Ptr (xWord1, (Header[9] Shl 8 + Header[8]));
          xWord1 := Word (Header[3]) Shl 8 + Header[2];
          xword2 := Word (Header[1]) Shl 8 + Header[0];
        End;
    End
  Else
    DevInterrupt := Ptr (0, 0);
End;


End.
