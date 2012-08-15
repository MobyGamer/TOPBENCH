Unit DetectDos;

Interface

Uses DetectGlobal;

Function GetDosVersion       : String64;
Function DosMemory           : LongInt;
Function FreeDOSMemory       : LongInt;

Function IsDosInHMA          : Boolean;
Function IsDosInRom          : Boolean;
Function GetDosOEMNumber     : Byte;
Function GetDosSwitchChar    : Char;
Function IsDEVPrefix         : Boolean;
Function GetDosBusyFlag      : Pointer;
Function GetPrtScrStatus     : String64;
Function GetMemAllocMethod   : String128;
Function DosBuffers          : Word;
Function DosFilesPointer     : Pointer;
Function DosFilesCount       : Word;
Function DosFilesUsed        : Word;
Function DosFCBCount         : Word;
Function DosStacksCount      : Word;
Function DosStacksSize       : Word;

Function CountryCode              : Word;
Function CountryString            : String64;
Function DosActiveGlobalCodePage  : Word;
Function DosDefaultGlobalCodePage : Word;
Function DosThousandSeparator     : Char;
Function DosDecimalSeparator      : Char;
Function DosDatalistSeparator     : Char;
Function DosDateFormat            : String32;
Function DosTimeFormat            : String32;
Function DosTimeSeparator         : Char;
Function DosCurrencyFormat        : String32;
Function DosCaseMapCallAddress    : Pointer;

Function NumberHandleTables                                 : Byte;
Function OpenHandlesTable (Number : Byte)                   : Pointer;
Function OpenHandleTableSize (Number : Byte)                : Byte;
Function UsedTableEntrys (Number : Byte)                    : Byte;
Function GetOpenFileStatus (TableNumber, FileNumber : Byte) : pOpenInfo;

Implementation

Uses Dos, DetectConstants;

Var Country : Array [0..33] Of Byte;

Function GetDosVersion;
var
  xstring,xstring2:string8;
Begin
  GetDosVersion := 'unbekannt';
  EndString := '';

  xByte := 0;
  xByte2 := 0;

  Regs.AX := $3000;
  Intr($21, Regs);
  xByte := Regs.AL;
  xByte2 := Regs.AH;
  xByte3 := Regs.BH;
  If xByte = 0 Then xByte:=1;

  Case xByte3 Of
    $00 : EndString := 'IBM DOS';
    $01 : EndString := 'Compaq DOS';
    $02 : EndString := 'MS-DOS';
    $04 : EndString := 'AT&T DOS';
    $05 : EndString := 'Zenith DOS';
    $06 : EndString := 'HP-DOS';
    $07 : EndString := 'ZDS (Group Bull)';
    $0D : EndString := 'Packard-Bell DOS';
    $16 : EndString := 'DEC DOS';
    $23 : EndString := 'Olivetti DOS';
    $29 : EndString := 'Toshiba DOS';
    $33 : EndString := 'Novell Netware';
    $34 : EndString := 'MS Multimedia Systems';
    $35 : EndString := 'MS Multimedia Systems';
    $4D : EndString := 'HP-DOS';
    $5E : EndString := 'RxDOS';
    $66 : EndString := 'PTS-DOS';
    $99 : EndString := 'GS Embedded DOS';
    $CD : EndString := 'PTS-DOS';
    $EE : EndString := 'DR DOS';
    $EF : EndString := 'Novell DOS';
    $FF : EndString := 'MS-DOS';
  Else
    EndString := 'Unbekanntes DOS';
  End;

  xBool := False;
  xWord := Regs.AX;
  Regs.BX := $0000;
  Regs.AX := $3306;
  Intr ($21, Regs);
  If Regs.BX <> $0000 Then xWord := Regs.BX;

  If (xByte3 = $FF) And (xWord = 4) Then xWord := $1004 Else
    If xWord = $1F03 Then
      Begin
        Regs.AX := $4452;
        Regs.DX := 0;
        Regs.Flags := FCarry;
        Intr ($21, Regs);
        If (Regs.Flags And FCarry) = 0 Then
          Begin
            EndString:='DR DOS';
            Case Regs.AX Of
              $1063 : xWord := $2903;
              $1065 : xWord := $0005;    { DR-DOS 5.0 }
              $1067 : xWord := $0006;    { DR-DOS 6.0 }
              $1071 : xWord := $0106;    { DR-DOS 6.0 Business Update }
              $1072 : xWord := $0007;
            End;
            Str (Lo (xWord), xString);
            xString2 := Zeropad (Hi(xWord));
            GetDosVersion := EndString + ' ' + xString + '.' + xString2;
            xBool := True;
          End;
      End
    Else If (xWord = $0006) And (xBool = False) Then
      Begin
        Regs.AX := $4452;
        Regs.Flags := Regs.Flags And FCarry;
        Intr ($21, Regs);
        If Regs.Flags And FCarry <> FCarry Then
          Begin
            EndString := 'Novell DOS';
            xWord := $0007;
            Str (Lo (xWord), xString);
            xString2 := Zeropad (Hi (xWord));
            GetDosVersion := EndString + ' ' + xString + '.' + xString2;
            xBool := True;
          End;
      End
    Else If xByte >= 10 Then
      Begin
        Case xByte Of
          10 : GetDosVersion := 'OS/2 V1.' + StrFnByte(xByte2);
          20 : Case xByte2 Of
                10..20 : GetDosVersion := 'OS/2 V2.' + StrFnByte (xByte2);
                30     : GetDosVersion := 'OS/2 Warp V' + StrFnByte (xByte2 Div 10) + '.' + StrFnByte (xByte2 Mod 10);
               End;
        End;
        xBool:=True;
      End
    Else If ((xByte = 5) And (xByte2 = 50)) Or ((Lo (Dos.DosVersion) = 5)
         And (Hi (Dos.DosVersion) = 50)) Then
      Begin
        GetDosVersion := 'Windows NT';
        xBool := True;
      End
    Else If xBool = False Then
      Begin
        Str (xByte, xString);
        xString2 := ZeroPad (xByte2);
        S := EndString + ' ' + xString + '.' + xString2;
        If S = 'MS-DOS 7.00' Then S := 'Windows 95/MS-DOS 7.0';
        Regs.AX := $3306;
        MsDos (Regs);
        S := S + ' Revision ' + Chr ((Regs.DL And 7) + Ord ('A'));
        GetDosVersion := S;
      End
    Else
      GetDosVersion := 'unbekannt';
End;


Function DosMemory;

Begin
  Intr ($12, Regs);
  DosMemory := Longint (Regs.AX) Shl 10;
End;


Function FreeDosMemory;

Begin
  FreeDosMemory := DosMemory - (Longint (PrefixSeg) Shl 4);
End;


Function IsDosInHMA : Boolean;

Begin
  Regs.AX := $3306;
  MsDos (Regs);
  IsDosInHMA := (Regs.DH And $10 = $10);
End;


Function IsDosInRom : Boolean;

Begin
  Regs.AX := $3306;
  MsDos (Regs);
  IsDosInROM := (Regs.DH And 8 = 8);
End;


Function GetDosOEMNumber : Byte;

Begin
  Regs.AX := $3000;
  Regs.BX := 0;
  MsDos (Regs);
  GetDosOemNumber := Regs.BH;
End;


Function GetDosSwitchChar : Char;

Begin
  Regs.AX := $3700;
  MsDos (Regs);
  GetDosSwitchChar := (Chr (Regs.DL))
End;


Function IsDEVPrefix : Boolean;

Begin
  Regs.AX := $3702;
  MsDos (Regs);
  IsDEVPrefix := (Regs.DL = $00);
End;


Function GetDosBusyFlag : Pointer;

Begin
  Regs.AX := $5D06;
  MsDos (Regs);
  GetDosBusyFlag := Ptr (Regs.DS, Regs.SI);
End;


Function GetPrtScrStatus;

Begin
  xByte := Mem [$0040:$0100];
  Case xbyte of
    $00 : GetPrtScrStatus := 'bereit';
    $01 : GetPrtScrStatus := 'beschaeftigt';
    $FF : GetPrtScrStatus := 'Fehler beim letzten PrintScreen'
  Else
    GetPrtScrStatus := 'unbekannter Status : ' + Hex (xByte, 2) + 'h';
 End;
End;


Function GetMemAllocMethod;

Begin
  Regs.AX := $5800;
  MsDos (Regs);
  Case Regs.AL Of
    $00 : GetMemAllocMethod := 'Erstes passende';
    $01 : GetMemAllocMethod := 'Am besten passende';
    2..$3F, $43..$7F, $83..$FF : GetMemAllocMethod := 'Letzter passende';
    $40 : GetMemAllocMethod := 'Highmem erste passende';
    $41 : GetMemAllocMethod := 'Highmem beste passende';
    $42 : GetMemAllocMethod := 'Highmem letzte passende';
    $80 : GetMemAllocMethod := 'Erste passende, wenn Highmen dann in norm. Mem';
    $81 : GetMemAllocMethod := 'Beste passende, wenn Highmen dann in norm. Mem';
    $82 : GetMemAllocMethod := 'Letzte passende, wenn Highmen dann in norm. Mem';
  Else
    GetMemAllocMethod := 'unbekannt : ' + Hex (Regs.AL, 2) + 'h';
  End;
End;


Function DosBuffers : Word;

  Function ShowBufs (A : Word) : Word;

  Const
    BufsMax = 99;

  Var
    I : 0..BufsMax + 1;

  Begin
    If (Lo (DosVersion) < 4) Or (Lo (DosVersion) >= 10) Then
      Begin
        I := 0;
        Regs.AH := $34;
        MsDos (Regs);
        xWord1 := MemW[Regs.ES : A];
        xWord2 := MemW[Regs.ES : A + 2];
        xBool  := False;
        Repeat
          If I <= BufsMax Then
            Begin
              If xWord1 < $FFFF Then
                Begin
                  Inc (I);
                  xWord3 := xWord1;
                  xWord1 := MemW[xWord2 : xWord3];
                  xWord2 := MemW[xWord2 : xWord3 + 2]
                End
              Else
                Begin
                  xBool := True;
                  ShowBufs := I;
                End
            End
          Else
            Begin
              xBool := True;
              ShowBufs := 0;
            End
        Until xBool
      End
    Else
      Begin
        Regs.AX := $5200;
        MsDos (Regs);
        ShowBufs := MemW[Regs.ES : Regs.BX + $3F];
      End;
  End;

Begin
  Case Lo (DosVersion) Of
    3 : Case Hi (DosVersion) Div 10 Of
          0    : DosBuffers := ShowBufs ($013F);
          1..3 : DosBuffers := ShowBufs ($0038)
        Else
          DosBuffers := 0;
        End;
    4, 5, 6, 7 : DosBuffers := ShowBufs (0)
  Else
    DosBuffers := 0;
  End;
End;


Function DosFilesPointer : Pointer;

Begin
  xWord1 := MemW[PrefixSeg : $0036];
  xWord2 := MemW[PrefixSeg : $0034];
  DosFilesPointer := Ptr (xWord2, xWord1);
End;


Function DosFilesCount : Word;

Begin
  Regs.AX := $5200;
  MsDos (Regs);

  xWord2 := MemW[Regs.ES : Regs.BX + 4];
  xWord1 := MemW[Regs.ES : Regs.BX + 6];
  xBool := False;
  xWord5 := 0;

  If (xWord1 = $FFFF) And (xWord2 = $FFFF) Then
    xWord5 := MemW[PrefixSeg : $32]
  Else
    Repeat
      xWord4 := MemW[xWord1 : xWord2];
      xWord3 := MemW[xWord1 : xWord2 + 2];
      xWord5 := xWord5 + MemW[xWord1 : xWord2 + 4];
      If xWord4 = $FFFF Then xBool := True Else
        Begin
          xWord1 := xWord3;
          xWord2 := xWord4
        End
    Until xBool;

  DosFilesCount := xWord5;
End;


Function DosFilesUsed : Word;

Begin
  xWord5 := 0;
  xWord1 := MemW[PrefixSeg : $36];
  xWord2 := MemW[PrefixSeg : $34];
  While Mem[xWord1 : xWord2] < $FF Do
    Begin
      Inc (xWord5);
      Inc (xWord2)
    End;
  DosFilesUsed := xWord5;
End;


Function DosFCBCount : Word;

Begin
  Regs.AX := $5200;
  MsDos (Regs);

  If Lo (DosVersion) >= 10 Then
    DosFCBCount := 0
  Else
    Begin
      If (Lo (DosVersion) >= 4) Or ((Lo (DosVersion) = 3) And (Hi (DosVersion) > 0)) Then
        Begin
          xWord2 := MemW[Regs.ES : Regs.BX + $1A];
          xWord1 := MemW[Regs.ES : Regs.BX + $1C]
        End
      Else
        Begin
          xWord2 := MemW[Regs.ES : Regs.BX + $22];
          xWord1 := MemW[Regs.ES : Regs.BX + $24]
        End;
      DosFCBCount := MemW[xWord1 : xWord2 + 4];
    End;
End;


Function DosStacksCount : Word;

Begin
  Regs.AH := $52;
  MsDos (Regs);

  If (Lo (DosVersion) = 3) Or (Lo (DosVersion) >= 10) Then
    DosStacksCount := 0
  Else
    Begin
      xWord1 := MemW [Regs.ES : Regs.BX - 2];
      xWord4 := 0; { Anzahl der Stacks }
      xWord5 := 0; { Deren Groesse     }

      If (Mem[xWord1:0] <> $4D) Or (MemW[xword1:1] <> 8) Then
        DosStacksCount := 0
      Else
        Begin
          xWord3 := xWord1 + MemW[xWord1:3] + 1;
          xWord2 := xWord1 + 1;
          xBool  := False;

          Repeat
            xChar := Chr (Mem[xWord2 : 0]);
            If xChar = 'S' Then
              Begin
                xWord4 := MemW[xWord2 + 1:2];
                xWord5 := MemW[xWord2 + 1:6];
                xBool  := True;
              End;
            If (xChar = 'M') Or (xChar = 'Z') Then xBool := True;
            xWord2 := xWord2 + MemW[xWord2:3] + 1;
            If xWord2 >= xWord3 Then xBool := True;
          Until xBool;
          DosStacksCount := xword4;
        End
    End;
End;


Function DosStacksSize : Word;

Begin
  Regs.AH := $52;
  MsDos (Regs);

  If (Lo (DosVersion) = 3) Or (Lo (DosVersion) >= 10) Then
    DosStacksSize := 0
  Else
    Begin
      xWord1 := MemW [Regs.ES : Regs.BX - 2];
      xWord4 := 0; { Anzahl der Stacks }
      xWord5 := 0; { Deren Groesse     }

      If (Mem[xWord1:0] <> $4D) Or (MemW[xword1:1] <> 8) Then
        DosStacksSize := 0
      Else
        Begin
          xWord3 := xWord1 + MemW[xWord1:3] + 1;
          xWord2 := xWord1 + 1;
          xBool  := False;

          Repeat
            xChar := Chr (Mem[xWord2 : 0]);
            If xChar = 'S' Then
              Begin
                xWord4 := MemW[xWord2 + 1:2];
                xWord5 := MemW[xWord2 + 1:6];
                xBool  := True;
              End;
            If (xChar = 'M') Or (xChar = 'Z') Then xBool := True;
            xWord2 := xWord2 + MemW[xWord2:3] + 1;
            If xWord2 >= xWord3 Then xBool := True;
          Until xBool;
          DosStacksSize := xWord5;
        End
    End;
End;


Function CountryCode;

Begin
  Regs.AX := $3800;
  Regs.DS := Seg (Country);
  Regs.DX := Ofs (Country);
  MsDos (Regs);
  CountryCode := Regs.BX;
End;


Function Countrystring;

Begin
  Case Countrycode Of
    1    : Countrystring := 'USA';
    2    : Countrystring := 'Kanada(Franzîsisch)';
    3    : Countrystring := 'Lateinamerika';
    31   : Countrystring := 'Niederlande';
    32   : Countrystring := 'Belgien';
    33   : Countrystring := 'Frankreich';
    34   : Countrystring := 'Spanien';
    36   : Countrystring := 'Ungarn';
    38   : Countrystring := 'Jugoslawien';
    39   : Countrystring := 'Italien';
    41   : Countrystring := 'Schweiz';
    42   : Countrystring := 'Tschechoslowakei';
    43   : CountryString := 'Australien';
    44   : Countrystring := 'Gro·britannien';
    45   : Countrystring := 'DÑnemark';
    46   : Countrystring := 'Schweden';
    47   : Countrystring := 'Norwegen';
    48   : Countrystring := 'Polen';
    49   : Countrystring := 'Deutschland';
    55   : Countrystring := 'Brasilien';
    61   : Countrystring := 'England (International)';
    81   : Countrystring := 'Japan';
    82   : Countrystring := 'Korea';
    86   : Countrystring := 'China';
    90   : Countrystring := 'TÅrkei';
    351  : Countrystring := 'Portugal';
    354  : Countrystring := 'Island';
    358  : Countrystring := 'Finnland';
    785  : CountryString := 'Mittlerer Westen/Saudi Arabien';
    972  : CountryString := 'Israel';
  End;
End;


Function DosActiveGlobalCodePage : Word;

Begin
  Regs.AX := $6601;
  MsDos (Regs);
  If Regs.AL = $01 Then
    DosActiveGlobalCodePage := Regs.BX
  Else
     DosActiveGlobalCodePage := 0
End;


Function DosDefaultGlobalCodePage : Word;

Begin
  Regs.AX := $6601;
  MsDos (Regs);
  If Regs.AL = $01 Then
    DosDefaultGlobalCodePage := Regs.DX
  Else
     DosDefaultGlobalCodePage := 0
End;


Function DosThousandSeparator : Char;

Begin
  CountryCode;
  DosThousandSeparator := Char (Country[7]);
End;


Function DosDecimalSeparator : Char;

Begin
  CountryCode;
  DosDecimalSeparator := Char (Country[9]);
End;


Function DosDatalistSeparator : Char;

Begin
  CountryCode;
  DosDatalistSeparator := Char (Country[22]);
End;


Function DosDateFormat;

Begin
  CountryCode;
  xWord1 := Word (Country[1]) Shl 8 + Country[0];
  xChar  := Char (Country[11]);

  Case xWord1 Of
    0 : DosDateFormat := 'USA (mm' + xChar + 'tt' + xChar + 'jj)';
    1 : DosDateFormat := 'Europa (tt' + xChar + 'mm' + xChar + 'jj)';
    2 : DosDateFormat := 'Japan (jj' + xChar + 'mm' + xChar + 'tt)';
  Else
    DosDateFormat := 'unbekannt (' + StrFnWord (xWord1) + ')';
  End;
End;


Function DosTimeFormat;

Begin
  CountryCode;

  If (Country[17] And $01) = $00 Then DosTimeFormat := '12 Stunden' Else DosTimeFormat := '24 Stunden';
End;


Function DosTimeSeparator : Char;

Begin
  CountryCode;

  DosTimeSeparator := Char (Country[13]);
End;


Function DosCurrencyFormat;

Var
  I:Byte;
  xstring,xstring2:string16;

Begin
  CountryCode;

  xString := 'xxxx';

  Insert (Char (Country[7]), xString, 2);
  xString := xString + DosDecimalSeparator;
  For I := 1 To Country[16] Do xString := xString + 'y';
  xString2 := '';
  I := 2;
  xChar := Char (Country[I]);
  While (I <= 6) And (xChar > #0) Do
    Begin
      xString2 := xString2 + xChar;
      Inc (I);
      xChar := Char (Country[I])
    End;
  Case Country[15] And $03 Of
    $00 : xString := xString2 + xString;
    $01 : xString := xString + xString2;
    $02 : xString := xString2 + ' ' + xString;
    $03 : xString := xString + ' ' + xString2;
    $04 : Begin
            Delete (xString, 6, 1);
            Insert (xString2, xString, 6)
          End
  End;
  DosCurrencyFormat := xString;
End;


Function DosCaseMapCallAddress : Pointer;

Begin
 CountryCode;
 DosCaseMapCallAddress := Ptr (Word (Country[21]) Shl 8 + Country[20], Word (Country[19]) Shl 8 + Country[18]);
End;


Function NumberHandleTables : Byte;

Begin
  If Not (Lo (DosVersion) >= 10) Then
    Begin
      Regs.AH := $52;
      MsDos (Regs);

      xWord2 := MemW[Regs.ES : Regs.BX + 4];
      xWord1 := MemW[Regs.ES : Regs.BX + 6];
      xBool  := False;
      xByte2 := 0;

      Repeat
        Inc (xByte2);
        xWord4 := MemW[xWord1 : xWord2];
        xWord3 := MemW[xWord1 : xWord2 + 2];
        If xWord4 = $FFFF Then xBool := True;
        If Not xBool Then
          Begin
            xWord1 := xWord3;
            xWord2 := xWord4
          End;
      Until xBool;
      NumberHandleTables := xByte2;
    End
  Else
    NumberHandleTables := 0;
End;


Function OpenHandlesTable (Number : Byte) : Pointer;

Begin
  If Not (Lo (DosVersion) >= 10) Then
    Begin
      Regs.AH := $52;
      MsDos (Regs);

      xWord2 := MemW[Regs.ES : Regs.BX + 4];
      xWord1 := MemW[Regs.ES : Regs.BX + 6];
      xBool  := False;
      xByte2 := 0;

      Repeat
        Inc (xByte2);
        xWord4 := MemW[xWord1 : xWord2];
        xWord3 := MemW[xWord1 : xWord2 + 2];
        If xWord4 = $FFFF Then xBool := true;
        If xByte2 = Number Then OpenHandlesTable := Ptr (xWord2, xWord1);
        If Not xBool Then
          Begin
            xWord1 := xWord3;
            xWord2 := xWord4
          End;
      Until xBool;
    End
  Else
    OpenHandlesTable := Ptr (0, 0);
End;


Function OpenHandleTableSize (Number : Byte) : Byte;

Begin
  If Not (Lo (DosVersion) >= 10) Then
    Begin
      Regs.AH := $52;
      MsDos (Regs);

      xWord2 := MemW[Regs.ES : Regs.BX + 4];
      xWord1 := MemW[Regs.ES : Regs.BX + 6];
      xBool  := False;
      xByte2 := 0;

      Repeat
        Inc (xByte2);
        xWord4 := MemW[xWord1 : xWord2];
        xWord3 := MemW[xWord1 : xWord2 + 2];
        If xWord4 = $FFFF Then xBool := true;
        If xByte2 = Number Then OpenHandleTableSize := (MemW[xWord1 : xWord2 + 4]);

        If Not xBool Then
          Begin
            xWord1 := xWord3;
            xWord2 := xWord4
          End;
      Until xBool;
    End
  Else
    OpenHandleTableSize := 0;
End;


Function UsedTableEntrys (Number : Byte) : Byte;

Const FileCount : Word = 0;
      UsedFiles : Word = 0;
      RealFiles : Word = 0;
      TableSize : Word = 0;

Begin
  If Not (Lo (DosVersion) >= 10) Then
    Begin
      Regs.AH := $52;
      MsDos (Regs);

      xWord2 := MemW[Regs.ES : Regs.BX + 4];
      xWord1 := MemW[Regs.ES : Regs.BX + 6];
      xBool  := False;
      xByte2 := 0;

      Repeat
        Inc (xByte2);
        xWord4 := MemW[xWord1 : xWord2];
        xWord3 := MemW[xWord1 : xWord2 + 2];
        If xWord4 = $FFFF Then xBool := true;
        If Lo (DosVersion) = 3 Then Tablesize := $35 Else Tablesize := $3B;
        FileCount := MemW[xWord1 : xWord2 + 4];

        xWord2 := xWord2 + 6;
        If xByte2 = Number Then
          Begin
            Repeat
              If MemW[xWord1 : xWord2] <> 0 Then Inc (RealFiles);
              Inc (UsedFiles);
              xWord2 := xWord2 + TableSize;
            Until UsedFiles = FileCount;
            UsedTableEntrys := RealFiles;
          End;

        If Not xBool Then
          Begin
            xWord1 := xWord3;
            xWord2 := xWord4
          End;
      Until xBool;
    End
  Else
    UsedTableEntrys := 0;
End;


Function GetOpenFileStatus (TableNumber, FileNumber : Byte) : pOpenInfo;

Const FileCount : Word = 0;
      UsedFiles : Word = 0;
      RealFiles : Word = 0;
      TableSize : Word = 0;

Var TempInfo : pOpenInfo;
    DT       : DateTime;
    xstring,xstring1:string32;

Begin
  CountryCode;
  If Not (Lo (DosVersion) >= 10) Then
    Begin
      Regs.AH := $52;
      MsDos (Regs);

      xWord2 := MemW[Regs.ES : Regs.BX + 4];
      xWord1 := MemW[Regs.ES : Regs.BX + 6];
      xBool  := False;
      xByte2 := 0;

      Repeat
        Inc (xByte2);
        xWord4 := MemW[xWord1 : xWord2];
        xWord3 := MemW[xWord1 : xWord2 + 2];
        If xWord4 = $FFFF Then xBool := true;
        If Lo (DosVersion) = 3 Then Tablesize := $35 Else Tablesize := $3B;
        FileCount := MemW[xWord1 : xWord2 + 4];

        xWord2 := xWord2 + 6;
        If xByte2 = TableNumber Then
          Begin
            Repeat
              If MemW[xWord1 : xWord2] <> 0 Then Inc (RealFiles);
              Inc (UsedFiles);
              If RealFiles = FileNumber Then
                Begin
                  GetMem (TempInfo, SizeOf (TempInfo^));

                  xString1 := '';
                  For xWord8 := xWord2 + $20 To xWord2 + $2A Do
                    xString1 := xString1 + Chr (Mem [xWord1 : xWord8]);
                  If Copy (xString1, 9, 3) <> '   ' Then
                    Insert ('.', xString1, 9)
                  Else
                    Insert (' ', xString1, 9);
                  TempInfo^.Name := xstring1;

                  Case MemW [xWord1 : xWord2 + 2] And 7 Of
                    0    : TempInfo^.OpenMode := 'lesen';
                    1    : TempInfo^.OpenMode := 'schreiben';
                    2    : TempInfo^.OpenMode := 'lesen/schreiben';
                    3..7 : TempInfo^.OpenMode := 'unbekannt';
                  End;

                  Case (MemW[xWord1 : xword2 + 2] And $70) Shr 4 Of
                    0    : TempInfo^.SharingMode := 'kompatibel';
                    1    : TempInfo^.SharingMode := 'alle verbieten';
                    2    : TempInfo^.SharingMode := 'schreiben verbieten';
                    3    : TempInfo^.SharingMode := 'lesen verbieten';
                    4    : TempInfo^.SharingMode := 'nichts verbieten';
                    5..7 : TempInfo^.SharingMode := 'unbekannt';
                  End;

                  TempInfo^.Inherit := ((MemW[xWord1 : xWord2 + 2] And $80) = $80);
                  TempInfo^.Attribut := Mem[xWord1 : xWord2 + 4];
                  TempInfo^.Remote := ((MemW[xWord1 : xWord2 + 5] and $8000) = $8000);
                  UnPackTime (MemL[xWord1 : xWord2 + $D], DT);
                  xWord5 := Word (Country[1]) Shl 8 + Country [0];
                  xChar := Chr (Country[11]);
                  Case xword5 Of
                    $0001 : TempInfo^.Date := ZeroPad (dt.day) + xChar +
                            ZeroPad(dt.month) + xChar + StrFnWord (dt.year);
                    $0002 : TempInfo^.Date := StrFnWord (dt.year) + xChar +
                            ZeroPad (dt.month) + xChar + ZeroPad (dt.day);
                  Else
                    TempInfo^.Date := ZeroPad (dt.month) + xChar + ZeroPad
                                     (dt.day) + xchar + StrFnWord (dt.year);
                  End;

                  If Country[17] And 1 = 0 Then
                    Case dt.hour Of
                      0      : TempInfo^.Time := '12';
                      1..12  : TempInfo^.Time := ZeroPad (dt.hour);
                      13..23 : TempInfo^.Time := ZeroPad (dt.hour - 12);
                    End
                  Else
                    TempInfo^.Time := ZeroPad (dt.hour);

                  TempInfo^.Time := TempInfo^.Time + (Chr (Country[13]) +
                                    ZeroPad (dt.min) + Chr (Country[13]) +
                                    ZeroPad (dt.sec));
                  If Country[17] And 1 = 0 Then
                    If dt.hour > 11 Then
                      TempInfo^.Time := TempInfo^.Time + ' pm'
                    Else
                      TempInfo^.Time := TempInfo^.Time + ' am';

                  TempInfo^.Size := (MemL[xWord1 : xWord2 + $11]);

                  If (xString1 <> 'AUX         ') And (xString1 <> 'CON         ') And
                     (xString1 <> 'PRN         ') Then
                    Begin
                      TempInfo^.OwnerPSP := MemW[xWord1 : xWord2 + $31];
                    End
                  Else
                    TempInfo^.FileType := 'DOS device';

                  GetOpenFileStatus := TempInfo;
                End;
              xWord2 := xWord2 + TableSize;
            Until UsedFiles = FileCount;
          End;

        If Not xBool Then
          Begin
            xWord1 := xWord3;
            xWord2 := xWord4
          End;
      Until xBool;
    End
  Else
    GetOpenFileStatus := nil;
End;

Begin
End.