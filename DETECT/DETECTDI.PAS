Unit DetectDisks;

Interface

Function IsDevice (Drive : Char)     : Boolean;
Function DeviceType (Drive : Char)   : Byte;
Function DeviceRemove (Drive : Char) : Boolean;
Function DeviceMethod (Drive : Char) : Byte;
Function Firstfloppy                 : Char;
Function DiskDevices                 : Byte;
Function Bootdrive                   : Char;
Function LastDrive                   : Char;
Function NumberDrives                : Byte;
Function IsVerify                    : Boolean;

Implementation

Uses Dos, DetectGlobal, DetectConstants;

Var Regs          : Registers;

{$L DETECTGL.OBJ}

Function DriveNumber (Drive : Char) : Byte;

Begin
  DriveNumber := Ord (UpCase (Drive)) - 64;
End;


Function NumberDrive (Drive : Byte) : Char;

Begin
  Numberdrive := Char (Drive + 64);
End;


Function NumberDrives;

Var Temp : Byte;

Begin
  Port [$70] := $14;
  Temp := Port[$71];
  If Temp And $40 = $40 Then NumberDrives := 2 Else NumberDrives := 1;
End;


Function FirstFloppy;

Begin
  If Mem[$0050:0004] = 0 Then FirstFloppy := 'A' Else FirstFloppy := 'B';
End;


Function DiskDevices;

Var Temp : Byte;
    XChar : Char;
    CurrDrv : Byte;

Begin
  Temp := 0;
  Regs.AH := $19;
  MsDos (Regs);
  Currdrv := Regs.AL;

  For xChar := 'A' To 'Z' Do
    Begin
      Regs.AH := $0E;
      Regs.DL := Ord (xChar) - Ord ('A');
      MsDos (Regs);
      Regs.AH := $19;
      MsDos (Regs);
      If Regs.AL = Regs.DL Then Inc (Temp);
      Regs.AH := $0E;
      Regs.DL := Currdrv;
      MsDos (Regs)
    End;

  DiskDevices := Temp;
End;


Function Bootdrive;

Begin
  Regs.AH := $33;
  Regs.AL := $05;
  MsDos (Regs);
  BootDrive := NumberDrive (Regs.DL);
End;


Function LastDrive;

Begin
  Regs.AH := $52;
  MSDOS (Regs);
  LastDrive := NumberDrive (Mem[Regs.ES:Regs.BX + $0021]);
End;


Function IsVerify;

Begin
  Regs.AH := $54;
  MsDos (Regs);
  IsVerify := Boolean (Regs.AL);
End;


Function IsDevice;

Begin
  Regs.AX := $4409;
  Regs.BL := DriveNumber (Drive);
  MsDos (Regs);
  IsDevice := Not (Regs.Flags And FCarry = FCarry);
End;


Function DeviceType;

Var Regs2 : Registers;

  Function IsCDRomDrive (DriveCode : Word) : Boolean;

  Begin
    IsCDROMDrive := False;
    Regs.AX := $1500;
    Regs.BX := 0;
    Regs.CX := 0;
    Intr ($2F, Regs);

    If (Regs.AX <> $FFFF) And (Regs.BX <> 0) Then
      Begin
        Regs.AX := $1500;
        Regs.BX := 0;
        Regs.CX:= 0;
        Intr ($2F, Regs);
        If (Regs.AX <> $FFFF) And (Regs.BX <> 0) Then
          IsCDRomDrive := (Pred (DriveCode) - Regs.CX) In [0..Pred (Regs.BX)];
      End;
  End;


  Function IsNovellDrive (DriveCode : Word) : Boolean;

  Type
    NovellTable = Array [1..32] Of Byte;

  Var
    NTP : ^NovellTable;

  Begin
    IsNovellDrive := False;
    Regs.AX := $EF01;
    Regs.ES := 0;
    Regs.SI := 0;
    MsDos (Regs);
    NTP := Ptr (Regs.ES, Regs.SI);
    IsNovellDrive := (NTP <> nil) And ((NTP^ [DriveCode] And 3) <> 0);
  End;


  Function IsInterlinkDrive (DriveCode: Word): Boolean;

  Begin
    Regs2.AX := $5601;
    Regs2.DX := $FFFF;
    Regs2.BL := 0;
    Regs2.BH := DriveCode-1;
    Intr ($2F, Regs2);
    IsInterlinkDrive := (Regs2.AL = $FF);
  End;

Var DriveCode : Byte;

Begin
  DriveCode := DriveNumber (Drive);
  Regs.AX := $4409;
  Regs.BL := DriveCode;
  MsDos (Regs);

  If (Regs.Flags And FCarry) = 0 Then
    Begin
      If IsCDRomDrive (DriveCode) Then DeviceType := ddiCDRom Else
        If IsInterlinkDrive (DriveCode) Then DeviceType := ddiInterlnk Else
          If (Regs.DX And $8000) <> 0 Then DeviceType := ddiSubst Else
            If (Regs.DX And $1000) = 0 Then
              Begin
                If DeviceRemove (NumberDrive (DriveCode)) Then
                  Begin
                    If DriveCode <= 2 Then DeviceType := ddiFloppy Else
                      DeviceType := ddiMOD;
                  End
                Else
                  DeviceType := ddiHard;
              End
            Else
              DeviceType:= ddiNet;
    End
  Else
    DeviceType := ddiNoDrive;
End;

Function DeviceRemove;

Begin
  If IsDevice (Drive) Then
    Begin
      Regs.AX := $4408;
      Regs.BL := DriveNumber (Drive);
      MsDos (Regs);
      DeviceRemove := (Regs.AX = 0);
    End
  Else
    DeviceRemove := False;
End;


Function DeviceMethod;

Begin
  If IsDevice (Drive) Then
    Begin
      Regs.AX := $4408;
      Regs.BL := DriveNumber (Drive);
      MsDos (Regs);
      DeviceMethod := (Regs.DH And $10) Shr 4;
      Regs.AX := $4408;
      Regs.BL := DriveNumber (Drive);
      MsDos (Regs);
      If Regs.DH And 2 = 2 Then DeviceMethod := 2;
    End
  Else
    DeviceMethod := dalError;
End;


Begin
End.