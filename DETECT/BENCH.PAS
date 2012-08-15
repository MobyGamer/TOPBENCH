{$N+,E+} { FÅr die Double-Benchmarks }
Unit Bench;

{ Diese Unit gehîrt zu der Detecting Unit fÅr Pascal, wurde aber aus
  PlatzgrÅnden (Datensegment) in eine eigene Unit verlagert, sie hat auch
  ein eigenes Beispielprogramm (BENCHEX.PAS). }

Interface

Function DhryStones      : Double;       { DhryStones / Sec                 }
Function WhetStones      : Double;       { Double-Precision WhetStones /sec }
Function MFLOPS          : Double;       { Double-Precision MFLOPS          }
Function DhryStonesXT    : Double;       { das X-Fache vom XT               }
Function WhetStonesXT    : Double;       { das X-Fache vom XT               }
Function MFLOPSXT        : Double;       { Double-Precision LLL MFLOPS /sec }
Function TransFormMFLOPS : Double;       { Double-Prec Transform-FLOPS /sec }
Function TransFormMFLOPSIIT : Double;    { IIT-Double Transform-FLOPS /sec  }
Function PeakMFLOPS      : Double;       { Peak Double-Prec MFLOPS /sec     }

Implementation

Uses DetectWhet, DetectDhry, DetectLLL, DetectGlobal, Dos, DetectSystem,
     DetectTransformMFLOPS, DetectPeakFlop;

Type Processor = (NA, i88, i86, iC88, iC86, V20, V30, i188, i186, i286, i386,
                  i386sx, ct386, ct386sx, c486dlc, c486slc, rapidcad, i486,
                  i486sx, Pentium, Cx486__, Cx486_, Cx486x2, Cx486S,
                  Cx486S2, Cx486DX, Cx486DX2);

Const
   AAM_Time : ARRAY [i88 .. Cx486DX2] OF INTEGER =
              (77, 77, 77, 77, 15, 15, 19, 19, 16, 17, 17, 16, 16,
              17, 17, 15, 15, 15, 18, 17, 17, 17, 17, 17, 17, 17);


Var MoveBuffer     : POINTER;
    ScreenAddr     : Pointer;
    EMS_BASE       : Word;
    ExpandedMem    : Word;
    ExtendedMem    : Word;
    ProcessorType  : STRING [15];
    CPU            : Processor;

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
    End;

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

Function Dhrystones;

Const
   MoveTime:    ARRAY [i88 .. Cx486DX2] OF INTEGER =
                (25, 17, 25, 17, 8, 16, 8, 16, 4, 4, 8, 4, 8,
                4, 4, 5, 3, 3, 1, 4, 4, 4, 4, 4, 4, 4);
   LFaktor:     ARRAY [i88 .. Cx486DX2] OF REAL =
                (1, 1.45, 1, 1.45, 1.15, 1.78, 1.15, 1.78, 3.3, 4.1, 3.4,
                 4.5, 3.7, 5.0, 6.0, 6.5, 8.5, 8.5, 17, 6.0, 6.0, 6.0,
                 6.0, 6.0, 6.0, 6.0);

Var Dhrys : Double;
    Index : Double;

Begin
  PreSpeedTest;
  GetMem (MoveBuffer, 20000);

  SpeedTest (Word (1) { BildSchirm }, Word(ExtendedMem), Word(ExpandedMem),
             MoveBuffer, Ptr (EMS_Base, 0), ScreenAddr, Result);

  CPU := Processor(Result.CPUType);

  TempFreq := 200 * AAM_Time [CPU] * ClockFreq / Result.AAMTime;
  Index    := LFaktor[CPU] * TempFreq / 4.7e6 * (MoveTime [CPU] / (Result.MoveBTime * TempFreq / (ClockFreq * 5000)));

  Dhrys := DetectDhry.DhryStones (Index);
  DhryStones := Dhrys;
  FreeMem (MoveBuffer, 20000);
End;


Function DhryStonesXT;

Begin
  DhryStonesXT := Dhrystones/3.6464E+2;
End;


Function Whetstones;

Const
   MoveTime:    ARRAY [i88 .. Cx486DX2] OF INTEGER =
                (25, 17, 25, 17, 8, 16, 8, 16, 4, 4, 8, 4, 8,
                4, 4, 5, 3, 3, 1, 4, 4, 4, 4, 4, 4, 4);
   LFaktor:     ARRAY [i88 .. Cx486DX2] OF REAL =
                (1, 1.45, 1, 1.45, 1.15, 1.78, 1.15, 1.78, 3.3, 4.1, 3.4,
                 4.5, 3.7, 5.0, 6.0, 6.5, 8.5, 8.5, 17, 6.0, 6.0, 6.0,
                 6.0, 6.0, 6.0, 6.0);

Var Whets : Double;
    Index : Double;

Begin
  PreSpeedTest;
  GetMem (MoveBuffer, 20000);

  SpeedTest (Word (1) { BildSchirm }, Word(ExtendedMem), Word(ExpandedMem),
             MoveBuffer, Ptr (EMS_Base, 0), ScreenAddr, Result);

  CPU := Processor(Result.CPUType);

  TempFreq := 200 * AAM_Time [CPU] * ClockFreq / Result.AAMTime;
  Index    := LFaktor[CPU] * TempFreq / 4.7e6 * (MoveTime [CPU] / (Result.MoveBTime * TempFreq / (ClockFreq * 5000)));

  Whets := Detectwhet.WhetStone (Result.NDPType < 2, Index);
  WhetStones := Whets;
  FreeMem (MoveBuffer, 20000);
End;


Function WhetStonesXT;

Begin
  PreSpeedTest;
  GetMem (MoveBuffer, 20000);

  SpeedTest (Word (1) { BildSchirm }, Word(ExtendedMem), Word(ExpandedMem),
             MoveBuffer, Ptr (EMS_Base, 0), ScreenAddr, Result);
  FreeMem (MoveBuffer, 20000);

   IF Result.NDPType < 2 THEN
      WhetStonesXT := Whetstones / 4.9169E+0
   ELSE
      WhetStonesXT := Whetstones / 9.9087E+1;
End;


Function MFLOPS;

Const
   MoveTime:    ARRAY [i88 .. pentium] OF INTEGER =
                (25, 17, 8, 25, 17, 16, 8, 16, 4, 4, 8, 4, 8,
                4, 4, 5, 3, 3, 1);
   LFaktor:     ARRAY [i88 .. pentium] OF REAL =
                (1, 1.45, 1, 1.45, 1.15, 1.78, 1.15, 1.78, 3.3, 4.1, 3.4,
                 4.5, 3.7, 5.0, 6.0, 6.5, 8.5, 8.5, 17);

Var MegaFlops : Double;
    Index : Double;

Begin
  PreSpeedTest;
  GetMem (MoveBuffer, 20000);

  SpeedTest (Word (1) { BildSchirm }, Word(ExtendedMem), Word(ExpandedMem),
             MoveBuffer, Ptr (EMS_Base, 0), ScreenAddr, Result);
  CPU := Processor(Result.CPUType);
  TempFreq := 200 * AAM_Time [CPU] * ClockFreq / Result.AAMTime;
  Index    := LFaktor[CPU] * TempFreq / 4.7e6 * (MoveTime [CPU] / (Result.MoveBTime * TempFreq / (ClockFreq * 5000)));

  MegaFLOPS := DetectLLL.MFLOPS (Result.NDPType < 2, Index);
  MFLOPS := MegaFlops;
  FreeMem (MoveBuffer, 20000);
End;


Function MFLOPSXT;

Begin
  PreSpeedTest;
  GetMem (MoveBuffer, 20000);

  SpeedTest (Word (1) { BildSchirm }, Word(ExtendedMem), Word(ExpandedMem),
             MoveBuffer, Ptr (EMS_Base, 0), ScreenAddr, Result);
  FreeMem (MoveBuffer, 20000);

  IF Result.NDPType < 2 THEN
     MFLOPSXT := MFlops / 6.5242E-4
  ELSE
     MFLOPSXT := MFlops / 1.2446E-2;
End;


Function TransFormMFLOPS; Begin TransFormMFLOPS := DetectTransformMFLOPS.TransformMFLOPS End;
Function TransFormMFLOPSIIT; Begin TransFormMFLOPSIIT := DetectTransformMFLOPS.TransformMFLOPSIIT End;
Function PeakMFLOPS; Begin PeakMFLOPS := DetectPeakFLOP.PeakMFLOPS End;


Begin
End.
