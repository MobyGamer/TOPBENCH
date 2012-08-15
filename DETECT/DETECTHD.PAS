Unit DetectHD;

{$I Detect.inc}
{ Hierin kann angegeben werden, ob beim Start tats„chlich die
  Festplattentestes durchgefhrt werden sollen. }

Interface

Function HDCylinders (HD : Byte)   : Word;
Function HDHeads (HD : Byte)       : Word;
Function HDSectors (HD : Byte)     : Word;
Function HDCapacity (HD : Byte)    : LongInt;
Function HDTrackSeek (HD : Byte)   : Real;
Function HDAverageSeek (HD : Byte) : Real;
Function HDMaximumSeek (HD : Byte) : Real;

Function HDTransferRead (Block, Times : Word; F : String) : Real;
Function HDTransferWrite (Block, Times : Word;  F : String) : Real;

Implementation

Uses Dos, DetectTime, DetectGlobal;

CONST
   MaxBufSize= 65500;

Type
   IOPuffer  = ARRAY [1..MaxBufSize] OF BYTE;
   PufferZgr = ^IOPuffer;

Var
    DummyPtr      : PufferZgr;
    BufPtr        : PufferZgr;
    Heads         : ARRAY [$80..$83] OF WORD;
    Sectors       : ARRAY [$80..$83] OF WORD;
    DOSCylinders  : ARRAY [$80..$83] OF WORD;
    Tracks        : ARRAY [$80..$83] OF WORD;
    Cylinders     : ARRAY [$80..$83] OF WORD;
    Capacity      : ARRAY [$80..$83] OF LONGINT;
    CylSize       : ARRAY [$80..$83] OF LONGINT;
    Valid         : ARRAY [$80..$83] OF BOOLEAN;
    MaximumAccess : ARRAY [$80..$83] OF REAL;
    AverageAccess : ARRAY [$80..$83] OF REAL;
    TrackToTrack  : ARRAY [$80..$83] OF REAL;
    SPC           : Word;
    FillSize      : Word;
    L             : Word;


Function HDTransferRead;

Var I         : File;
    Buffer    : Pointer;
    Result    : Word;
    Start     : LongInt;
    EndTimer  : LongInt;
    Redundant : LongInt;

Begin
  GetMem (Buffer, Block+1);
  Assign (I, F);
  Rewrite (I, Block);
  BlockWrite (I, Buffer, 1, Result);
  Close (I);

  Reset (I, Block);
  Start := Clock;
  For xWord := 1 To Times Do
    Begin
      Seek (I, 0);
    End;
  Redundant := Clock-Start;
  Close (I);
  Reset (I, Block);
  Start := Clock;
  For xWord := 1 To Times Do
    Begin
      Seek (I, 0);
      BlockRead (I, Buffer, 1, Result);
    End;
  EndTimer := Clock-Start-Redundant;
  Close (I);
  Erase (I);
  HDTransferRead := Times * LongInt (Block)/1024/(EndTimer/1000);
  FreeMem (Buffer, Block+1);
End;


Function HDTransferWrite;

Var I         : File;
    Buffer    : Pointer;
    Result    : Word;
    Start     : LongInt;
    EndTimer  : LongInt;
    Redundant : LongInt;

Begin
  GetMem (Buffer, Block+1);
  Assign (I, F);

  ReWrite (I, Block);
  Start := Clock;
  For xWord := 1 To Times Do
    Begin
      Seek (I, 0);
    End;
  Redundant := Clock-Start;
  Close (I);

  ReWrite (I, Block);
  Start := Clock;
  For xWord := 1 To Times Do
    Begin
      Seek (I, 0);
      BlockWrite (I, Buffer, 1, Result);
    End;
  EndTimer := Clock-Start-Redundant;
  Close (I);

  Erase (I);
  HDTransferWrite := Times * LongInt (Block)/1024/(EndTimer/1000);
  FreeMem (Buffer, Block+1);
End;


Function DriveUnit (Drive : Char) : Byte;

Begin
  DriveUnit := Byte (UpCase(Drive)) + 61;
End;


Function ReserveMem : Boolean;

Type LongWord = Array [1..2] of Word;

Var HeapPointer : LongInt;
    xBool1 : Boolean;

Begin
   xBool1 := True;
   ReserveMem := True;
   BufPtr := NIL;

   IF CylSize [L] > LongInt (MaxBufSize) THEN BEGIN
      SPC := MaxBufSize DIV 512;
      CylSize [L] := SPC * 512;
      END;

   HeapPointer := LONGINT (LongWord(HeapPtr)[2]) * 16 + LongWord(HeapPtr)[1];
   FillSize := $10000 - HeapPointer MOD $10000;

   GetMem (DummyPtr, FillSize);
   IF DummyPtr = NIL THEN BEGIN
      xBool1 := False;
      ReserveMem := False;
   END;

   GetMem (BufPtr, Word (CylSize[L]+16));
   IF BufPtr = NIL THEN BEGIN
      If xBool1 = True Then FreeMem (DummyPtr, FillSize);
      ReserveMem := False;
   END;
END;


Function HDCylinders;

Begin
  If Valid [$7F+HD] Then HDCylinders := Cylinders [$7F+HD] Else
    HDCylinders := 0;
End;


Function HDHeads;

Begin
  If Valid [$7F+HD] Then HDHeads := Heads [$7F+HD] Else HDHeads := 0;
End;


Function HDSectors;

Begin
  If Valid [$7F+HD] Then HDSectors := Sectors [$7F+HD] Else HDSectors := 0;
End;


Function HDCapacity;

Begin
  If Valid [$7F+HD] Then HDCapacity := Capacity [$7F+HD] Else HDCapacity := 0;
End;


Function HDTrackSeek;

Begin
  If Valid [$7F+HD] Then HDTrackSeek := TrackToTrack [$7F+HD] Else HDTrackSeek := 0.0;
End;


Function HDAverageSeek;

Begin
  If Valid [$7F+HD] Then HDAverageSeek := AverageAccess [$7F+HD] Else HDAverageSeek := 0.0;
End;


Function HDMaximumSeek;

Begin
  If Valid [$7F+HD] Then HDMaximumSeek := MaximumAccess [$7F+HD] Else HDMaximumSeek := 0.0;
End;

Var NrOfHardDisks : Byte;
    BufOff        : Word;
    BufSeg        : Word;
    Start         : LongInt;
    ErrByte       : Byte;
    Durchsatz     : Real;
    Dummy         : Word;
    Track         : Word;
    Head1         : Byte;
    Regs          : Registers;

Begin
{$IfnDef NoHd}
   Regs.AH := $08;                          { get drive parameters }
   Regs.DL := $80;                          { of first harddisk }
   Intr ($13, Regs);                        { BIOS disk interupt }

   IF (Regs.Flags AND FCarry) <> 0 THEN     { error indicates no harddisk }
      NrOfHardDisks := 0
   ELSE
      NrOfHardDisks := Regs.DL;             { else # of harddisk is returned }

   FOR L := 1 TO 4 DO BEGIN
      Regs.AH := $10;                       { test drive ready }
      Regs.DL := $7F + L;                   { of harddisk # L }
      Intr ($13, Regs);                     { BIOS disk interupt }
      IF ((Regs.Flags AND FCarry) <> 0) OR  { no error indicates drive exists }
         (NrOfHardDisks = 0) THEN
           Valid [$7F+L] := FALSE
      ELSE
        BEGIN
          Valid [$7F+L] := TRUE;
          Dec (NrOfHardDisks);
        END;
   END;

  FOR L := $80 TO $83 DO BEGIN
    IF Valid [L] THEN
      BEGIN

          Regs.AH := $08;
          Regs.DL := L;
          Intr ($13, Regs);
          Sectors [L]   := Regs.CL AND $3F;
          Cylinders [L] := Word (Regs.CL AND $C0) * 4 + Regs.CH + 1;
          Heads [L]     := Regs.DH + 1;
          CylSize [L]   := LongInt (Sectors [L]) * Heads [L] * 512;

          If Not ReserveMem Then Exit;

          BufOff := Ofs (BufPtr^);
          BufSeg := Seg (BufPtr^);

          Regs.CX := 1;
          Regs.DL := L;
          Regs.DH := 0;
          Regs.AX := $0201;
          Regs.ES := BufSeg;
          Regs.BX := BufOff;
          Intr ($13, Regs);

          DOSCylinders [L] := 0;
          Dummy := $1C5;
          WHILE (Dummy < $200) AND ((BufPtr^[$1FF] * 256 + BufPtr^[$200]) = $55AA) DO
            BEGIN
              IF ((BufPtr^[Dummy] AND $C0) * 4 + BufPtr^[Dummy+1] + 1) > DOSCylinders [L] THEN
                  DOSCylinders [L]:= (BufPtr^[Dummy] AND $C0) * 4 + BufPtr^[Dummy+1]+1;
              Inc (Dummy, $10);
            END;

          FreeMem (BufPtr, Word(CylSize [L]+16));
          FreeMem (DummyPtr, FillSize);

          IF DOSCylinders [L] > Cylinders [L] THEN
             Cylinders [L] := DOSCylinders [L];
          SPC         := Sectors [L] * Heads [L];
          CylSize [L] := LongInt (512) * SPC;
          Capacity [L]:= CylSize [L] * Cylinders [L];

          If Not ReserveMem Then Exit;

  {-------------------------------------------------------------------------
     determine track-to-track time
   --------------------------------------------------------------------------}

      {  track-to-track seek time: }
          Start := Clock;
          FOR Track := 0 TO Cylinders[L]-1 DO BEGIN
             Inline ($8b/$16/L/            { mov dx, Drive&Head }
                     $a1/Track/            { mov ax, Track }
                     $88/$c5/              { mov ch, al }
                     $25/$00/$03/          { and ax, $300 }
                     $d1/$e8/              { shr ax, 1 }
                     $d1/$e8/              { shr ax, 1 }
                     $0d/$01/$00/          { or  ax, Sector }
                     $88/$c1/              { mov cl, al }
                     $b4/$0c/              { mov ah, SeekFunc }
                     $cd/$13);             { int BIOS-DiskIO }
          END;
          TrackToTrack [L] := Int (((Clock-Start) / Cylinders[L]) * 10 + 0.5) / 10;

  {-------------------------------------------------------------------------
     determine average acces time
   --------------------------------------------------------------------------}

       { average seek time: }
          Dummy := 2 * Cylinders [L] DIV 3;
          Start := Clock;
          FOR Track := 1 TO 40 DO BEGIN
             Inline ($8b/$16/L/            { mov dx, Drive&Head }
                     $a1/Dummy/            { mov ax, Track }
                     $88/$c5/              { mov ch, al }
                     $25/$00/$03/          { and ax, $300 }
                     $d1/$e8/              { shr ax, 1 }
                     $d1/$e8/              { shr ax, 1 }
                     $0d/$01/$00/          { or  ax, Sector }
                     $88/$c1/              { mov cl, al }
                     $b4/$0c/              { mov ah, SeekFunc }
                     $cd/$13);             { int BIOS-DiskIO }
             Dummy := Cylinders [L] - Dummy;
          END;
          AverageAccess [L] := Int ((Clock - Start) * 0.25 + 0.5) / 10;

   {-------------------------------------------------------------------------
     maximum access time
   --------------------------------------------------------------------------}

         { maximum seek time: }
          Dummy := 0;
          Start := Clock;
          FOR Track := 1 TO 25 DO BEGIN
             Inline ($8b/$16/L/            { mov dx, Drive&Head }
                     $a1/Dummy/            { mov ax, Track }
                     $88/$c5/              { mov ch, al }
                     $25/$00/$03/          { and ax, $300 }
                     $d1/$e8/              { shr ax, 1 }
                     $d1/$e8/              { shr ax, 1 }
                     $0d/$01/$00/          { or  ax, Sector }
                     $88/$c1/              { mov cl, al }
                     $b4/$0c/              { mov ah, SeekFunc }
                     $cd/$13);             { int BIOS-DiskIO }
             Dummy := (Cylinders[L]-1) - Dummy;
          END;
          MaximumAccess [L]:= Int ((Clock-Start) * 0.04 + 0.5);
       End;
   End;
{$EndIf NoHd}
End.