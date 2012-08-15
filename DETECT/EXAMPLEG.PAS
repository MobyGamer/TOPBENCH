Unit ExampleGlobal;

Interface

Uses DetectBios, DetectConstants, DetectGlobal;

Type PtrRec = Record
       seg : Word;
       Ofs : Word;
     End;

     tT = Record
       VideoWaits : Word;
       BiosSpeed  : Real;
       DosSpeed   : Real;
     End;

     String18 = String [18];


Const Title = 'Die Detecting Unit fÅr Pascal/EJF - Version ' + UnitVersion + ' - EXAMPLE';

Var xPointer : Pointer;
    xString  : String;
    EndIt    : Boolean;
    Count    : Byte;
    T        : tT;
    pBios    : pBiosRecord;

Procedure CursorOff;
Procedure CursorOn;

Function Cross (X : Boolean)  : String;
Function CrossE (X : Boolean) : String;
Function CrossES (X : Byte)   : String;

Function TrimString (S : String) : String;

Procedure WaitKey;
Procedure Rahmen (x1,y1,x2,y2 : Byte; Title : String);

Procedure Copyright (x,y : Byte);

Function PointerStr (P : Pointer) : String;
Function FillUp (A : Byte; S : String) : String;

Function Bin4 (A : Byte) : String;
Function Bin8 (A : Byte; B : Char) : String;
Function Bin16 (A : Word; B : Char) : String;

Implementation

Uses Crt;

Procedure CursorOff; Assembler;

Asm
    Mov  DX,03dah
  @@WaitRetrace:
    In   AL,DX
    Test AL,8
    Jz   @@WaitRetrace
  @@WaitNoRetrace:
    In   AL,DX
    Test AL,8
    Jnz  @@WaitNoRetrace
    Mov  AH,1
    Mov  CX,2000h
    Int  10h
End;


Procedure CursorOn; Assembler;

Asm
  Mov   AH,1
  Mov   CX,0607h
  Int   10h
End;


Function Cross (X : Boolean) : String;

Begin
  Case X Of
    True  : Cross := '[X]';
    False : Cross := '[-]';
  Else
    Cross := '[?]';
  End
End;


Function CrossE (X : Boolean) : String;

Begin
  Case X Of
    True  : CrossE := 'X';
    False : CrossE := '-';
  Else
    CrossE := '?';
  End
End;


Function CrossES (X : Byte) : String;

Begin
  Case X Of
    dsmdTrue  : CrossES := 'X';
    dsmdFalse : CrossES := '-';
    dsmdNo    : CrossES := '-';
    dalError  : CrossES := 'F';
  Else
    CrossES := '?';
  End
End;


Procedure Waitkey;

Var Counter : Byte;
    xString : String;
    x,y     : Byte;

Begin
  Write ('Bitte eine Taste drÅcken ... ');
  x := WhereX;
  y := WhereY;
  Counter := 0;
  Repeat
    Case Counter of
      0 : Begin xString := '|'; Inc(Counter) End;
      1 : Begin xString := '/'; Inc(Counter) End;
      2 : Begin xString := '-'; Inc(Counter) End;
      3 : Begin xString := '\'; Counter := 0 End;
    End;
    GotoXY (x,y);
    Write (xString);
    Delay (75);
  Until Keypressed;
  ReadKey;
End;

Procedure Rahmen (x1,y1,x2,y2 : Byte; Title : String);

Var Fenster  : array [1 .. 25] of String;
    Breite   : Word;
    Hoehe    : Word;
    Zaehler  : Word;
    BrString : String;
    Temp     : Word;

Begin
  Temp := 0;
  GotoXy (X1,Y1);
  Breite:= X2-X1;
  Hoehe:= Y2-Y1;
  BrString:='';
  For Zaehler:=1 To 25 Do Fenster[Zaehler]:='';
  For Zaehler := 1 To Breite - 2 Do BrString := BrString + ' ';

  Fenster[1] := '⁄';
  For Zaehler := 1 To Breite - 2 Do Fenster[1]:=Fenster[1]+'ƒ';
  Fenster[1] := Fenster[1]+ 'ø';

  For Zaehler := 2 To Hoehe-1 Do Fenster[Zaehler]:='≥'+BrString+'≥';

  Fenster[Hoehe] := '¿';
  For Zaehler := 1 To Breite - 2 Do Fenster[Hoehe]:=Fenster[Hoehe]+'ƒ';
  Fenster[Hoehe] := Fenster[Hoehe]+'Ÿ';

  Delete(Fenster[1],4,Length(Title));
  System.Insert (Title,Fenster[1],4);

  For Zaehler:= Y1 To Y2 Do
    Begin
      Inc (Temp);
      GotoXy (X1,Zaehler);
      Write(Fenster[Temp]);
    End;
End;


Procedure Copyright (x,y : Byte);

Begin
  Rahmen (x,y,x+20,y+6,' Copyright ');
  GotoXY (2,y+1);
  WriteLn ('  Copyright (C)  ');
  GotoXY (2,y+2);
  WriteLn ('  fÅr Demo und   ');
  GotoXY (2,y+3);
  WriteLn ('      Unit       ');
  GotoXY (2,y+4);
  WriteLn (' 1995/1996 by EJF');
End;


Function TrimString;

Var x : Word;

Begin
   For x := 1 To 255 Do
     If (S[1] = #$00) Or (S[1] = #$20) Or (S[1] = #$FF) Then Delete (S,1,1);
   TrimString := S;
End;


Function PointerStr;

Begin
  PointerStr := Hex (PtrRec(P).Seg, 4) + 'h:' + Hex (PtrRec(P).Ofs, 4) + 'h';
End;


Function FillUp (A : Byte; S : String) : String;

Var ES : String;
    Co : Byte;

Begin
  ES := '';
  For Co := 1 To A Do ES := ES + ' ';
  FillUp := ES;
End;


Function Bin4 (A : Byte) : String;

Const
  Digit : Array [0..1] Of Char = '01';

Var
  xString : String;
  I       : Byte;

begin
  xString:='';
  For I := 3 DownTo 0 Do
    Begin
      Insert (Digit [A Mod 2], xString, 1);
      A := A Shr 1
    End;
  Bin4 := xString
end;


Function Bin8 (A : Byte; B : Char) : String;

Begin
  Bin8 := Bin4 (A Shr 4) + B + Bin4 (A And $0F)
End;


Function Bin16 (A : Word; B : Char) : String;

Begin
  Bin16 := Bin8 (Hi (A), B) + B + Bin8 (Lo (A), B)
End;


Begin
End.