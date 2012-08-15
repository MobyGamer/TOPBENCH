Unit DetectPorts;

Interface

Function GetParDevParams (Number : Byte) : Byte;
Function GetParDevTimeOut (Number : Byte) : Byte;

Function GetSerDevUART (Number : Byte) : String;
Function GetSerDevBaudRate (Number : Byte) : LongInt;
Function GetSerDevDataBits (Number : Byte) : Byte;
Function GetSerDevParity (Number : Byte) : String;
Function GetSerDevStopBits (Number : Byte) : Real;
Function GetSerDevBreak (Number : Byte) : Boolean;
Function GetSerDevFlags (Number : Byte) : Byte;

Function IsEPP (Port : Byte)    : Boolean;

Implementation

Uses Dos, DetectGlobal, DetectConstants, DetectBios;

Var NumberLPTs : Byte;
    NumberCOMs : Byte;
    p : pBiosRecord;


Procedure PrepareProcedure;

Begin
  p := GetBiosRecord;
  NumberLPTs := P^.Equipment And $C000 Shr 14;
  NumberCOMs := P^.Equipment And $0E00 Shr 9;
  If NumberComs > 4 Then NumberComs := 4;
  EndString := '';
End;


Function GetParDevParams (Number : Byte) : Byte;

Begin
  PrepareProcedure;
  If (NumberLPTs >= Number) And Not (Number = 0) Then
    Begin
      Regs.AH := $02;
      Regs.DX := Number;
      Intr ($17, Regs);
      GetParDevParams := Regs.AH;
    End
  Else
    GetParDevParams := 0;
End;


Function GetParDevTimeOut (Number : Byte) : Byte;

Begin
  PrepareProcedure;
  If (NumberLPTs >= Number) And Not (Number = 0) Then
    Begin
      GetParDevTimeOut := p^.LPTTimeOut [Number];
    End
  Else
    GetParDevTimeOut := 0;
End;


Function GetSerDevUART (Number : Byte) : String;

Begin
  PrepareProcedure;
  If (NumberCOMs >= Number) And Not (Number = 0) Then
    Begin
      xByte := Port[P^.Com[Number] + 7];

      Port [P^.Com[Number] + 7] := $5A;
      If Port [P^.Com[Number] + 7] <> $5A Then EndString := '8250' Else
        Begin
          Port [P^.Com[Number] + 7] := $A5;
          If Port [P^.Com[Number] + 7] <> $A5 Then
            EndString := '8250'
          Else
            Begin
              Port[P^.Com[Number] + 7] := xByte;
              xByte := Port [P^.Com[Number] + 2];
              Port [P^.Com[Number] + 2] := 1;
              xbyte2 := Port[P^.Com[Number] + 2];
              If xbyte2 And $C0 = $C0 Then
                EndString := '16550A'
              Else
                If xByte2 And $80 = $80 Then
                  EndString := '16550'
                Else
                  EndString := '16450';
            End;
        End;
      Port [P^.Com[Number] + 2] := 0;
    End
  Else
    EndString := 'N/A';

  GetSerDevUART := EndString;
End;


Function GetSerDevBaudRate (Number : Byte) : LongInt;

Const Tick = 115200;

Begin
  PrepareProcedure;
  If (NumberCOMs >= Number) And Not (Number = 0) Then
    Begin
      xByte := Port [P^.Com[Number] + 3];
      Port [P^.Com[Number] + 3] := xByte Or $80;
      xWord2 := Port[P^.Com[Number]] + (Port[P^.Com[Number] + 1] Shl 8);
      If xWord2 = 0 Then
        GetSerDevBaudRate := 0
      Else
        GetSerDevBaudRate := Tick DIV xWord2;
    End
  Else
    GetSerDevBaudRate := 0;
End;


Function GetSerDevDataBits (Number : Byte) : Byte;

Begin
  PrepareProcedure;
  If (NumberCOMs >= Number) And Not (Number = 0) Then
    Begin
      xByte := Port [P^.Com[Number] + 3];
      GetSerDevDataBits := (xByte And $03) + 5;
    End
  Else
    GetSerDevDataBits := 0;
End;


Function GetSerDevParity (Number : Byte) : String;

Begin
  PrepareProcedure;
  If (NumberCOMs >= Number) And Not (Number = 0) Then
    Begin
      xByte := Port [P^.Com[Number] + 3];
      Case xByte And $38 Of
        $00, $10, $20, $30 : GetSerDevParity := 'keine';
        $08                : GetSerDevParity := 'odd';
        $18                : GetSerDevParity := 'even';
        $28                : GetSerDevParity := 'mark';
        $38                : GetSerDevParity := 'space';
      End;
    End
  Else
    GetSerDevParity := 'N/A';
End;


Function GetSerDevStopBits (Number : Byte) : Real;

Begin
  PrepareProcedure;
  If (NumberCOMs >= Number) And Not (Number = 0) Then
    Begin
      xByte := Port [P^.Com[Number] + 3];
      Case xByte And $07 Of
        $00..$03 : GetSerDevStopBits := 1.0;
        $04      : GetSerDevStopBits := 1.5;
        $05..$07 : GetSerDevStopBits := 2.0;
      End;
    End
  Else
    GetSerDevStopBits := 0.0;
End;


Function GetSerDevBreak (Number : Byte) : Boolean;

Begin
  PrepareProcedure;
  If (NumberCOMs >= Number) And Not (Number = 0) Then
    Begin
      xByte := Port [P^.Com[Number] + 3];
      GetSerDevBreak := (xByte And $40 = $40);
    End
  Else
    GetSerDevBreak := False;
End;


Function GetSerDevFlags (Number : Byte) : Byte;

Begin
  PrepareProcedure;
  If (NumberCOMs >= Number) And Not (Number = 0) Then
    Begin
      Regs.AH := $03;
      Regs.DX := Number - 1;
      Intr ($14, Regs);
      GetSerDevFlags := Regs.AL;
    End
  Else
    GetSerDevFlags := 0;
End;


Function IsEPP (Port : Byte) : Boolean;

Begin
  Regs.AX := $0200;
  Regs.BX := $5050;
  Regs.CH := $45;
  Regs.DX := Port;
  Intr ($17, Regs);
  IsEPP := ((Regs.AH=0) Or (Regs.AH=3));
End;

Begin
End.