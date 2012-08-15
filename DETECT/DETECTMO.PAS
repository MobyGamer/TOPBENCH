Unit DetectMouse;

Interface

Function IsMouse          : Boolean;
Function MouseVersion     : String;
Function MouseVersionWord : Word;
Function MouseVendor      : String;
Function MouseType        : String;
Function MouseIRQ         : Byte;
Function MouseLanguage    : String;
Function MouseButtons     : Byte;
Function DoubleClickSpeed : Word;
Function MouseMickeysVert : Word;
Function MouseMickeysHori : Word;
Function MouseDisplayPage : Byte;
Function EGARegisterSupp  : Boolean;
Function EGARegisterVers  : String;
Function SaveStateBuffer  : Word;

Function IsMouseSystemsDrv : Boolean;
Function MouseSystemsVer   : String;

Function IsLogitechDrv     : Boolean;
Function LogiCompPara      : String;
Function LogiSerBaudRate   : Word;
Function LogiSerReportRate : Word;
Function LogiSerFirmRev    : Word;
Function LogiSerPort       : Word;

Function IsZNixMouseDrv    : Boolean;
Function IsTrueDOXMouseDrv : Boolean;
Function IsHPMouseDrv      : Boolean;

Function MouseDriverType     : String;  { Ab ver 7.0 }
Function MouseCursorType     : String;  { Ab ver 7.0 }
Function MouseIntrRate       : String;  { Ab ver 7.0 }
Function MouseAccellProf     : Word;    { Ab ver 7.0 }
Function MouseBallpoint      : Boolean; { Ab ver 7.4 }
Function MouseIniPath        : String;  { Ab ver 8.0 }
Function MousePointerStyle   : String;  { Ab ver 8.10 }
Function MousePointerSize    : String;  { Ab ver 8.10 }
Function MousePointerSChange : Boolean; { Ab ver 8.10 }

Implementation

Uses Dos, DetectGlobal;

Type pLogitech = ^tLogitech;
     tLogitech = Record
       BaudRate     : Word; { nur serielle Maus }
       Emulation    : Word; { nur serielle Maus }
       ReportRate   : Word; { nur serielle Maus }
       FirmwareRev  : Word; { nur serielle Maus }
       Nothing      : Word; { nur serielle Maus }
       Port         : Word; { nur serielle Maus }
       PhsclButtons : Word;
       LogclButtons : Word;
     End;

Var Regs      : Registers;
    Logitech  : pLogitech;
    MSVersion : Word;


Function IsMouse;

Begin
  Regs.AX:=$0021;
  Intr($33, regs);
  If Regs.AX = $FFFF Then
    Begin
      IsMouse := True;
      Regs.AX := $0024;
      Intr ($33, Regs);
      MSVersion := Regs.BX;
    End
  Else
    IsMouse := False;
End;


Function MouseVersion;

Begin
  If IsMouse Then
    Begin
      Regs.AX := $24;
      Intr ($33, Regs);
      MouseVersion  := BcdWordToString (Regs.BX);
    End
  Else
    MouseVersion := 'N/A';
End;


Function MouseVersionWord;

Begin
  If IsMouse Then
    Begin
      Regs.AX := $24;
      Intr ($33, Regs);
      MouseVersionWord  := Regs.BX;
    End
  Else
    MouseVersionWord := 0;
End;


Function MouseVendor;

Begin
  If IsMouse Then
    Begin
      GetIntVec ($33, P);
      xWord1 := Seg (p^);
      xWord2 := Ofs (p^);

      Case MemW [xWord1:xWord2-4] Of
        $2EFF : MouseVendor := 'Reis-Ware';
        $594B : MouseVendor := 'Genius';
        $0C46 : MouseVendor := 'Unitron';
        $2A20 : MouseVendor := 'Microsoft';
        $5B5A : MouseVendor := 'Logitech';
        $2020 : MouseVendor := 'Sicos';
        $28CC : MouseVendor := 'Ultima';
        $FCE3 : MouseVendor := 'OS/2 intern';
        $0D0A, $003C : MouseVendor := 'SuperMouse';
      Else
        MouseVendor := 'unbekannt (' + Hex (MemW[xWord1:xWord2-4], 4) + ')';
      End;
    End;
End;


Function MouseType;

Begin
  If IsMouse Then
    Begin
      Regs.AX :=$24;
      Intr ($33, Regs);
      Case Regs.CH Of
        1 : MouseType := 'Bus-Maus';
        2 : MouseType := 'Serielle Maus';
        3 : MouseType := 'Inport-Maus';
        4 : MouseType := 'PS/2 Maus';
        5 : MouseType := 'Hewlett Packard Maus';
      End;
    End
  Else
    MouseType := 'Keine Maus';
End;


Function MouseIRQ;

Begin
  If IsMouse Then
    Begin
      Regs.AX := $24;
      Intr ($33, Regs);
      MouseIRQ := Regs.CL;
    End
  Else
    MouseIRQ := 0;
End;


Function MouseLanguage;
Const MouseLang : Array [0..8] Of String [13] = ('Englisch', 'Franz”sisch',
                  'D„nisch', 'Deutch', 'Schwedisch', 'Finnisch', 'Spanisch',
                  'Portugiesisch', 'Italienisch');

Begin
  If IsMouse Then
    Begin
      Regs.AX:=$0023;
      Intr($33, Regs);
      If Regs.AX < $FFFF Then
        Begin
          If Regs.BX < 9 Then
            MouseLanguage := MouseLang[Regs.BX]
          Else
            MouseLanguage := 'Nicht bekannt';
        End
      Else
        MouseLanguage := 'nicht vorhanden';
    End
  Else
    MouseLanguage := 'Maus nicht vorhanden';
End;


Function MouseButtons;

Begin
  If IsMouse Then
    Begin
      Regs.AX := $0021;
      Intr($33, Regs);
      If Regs.BX = $FFFF then Regs.BX := 2;
      MouseButtons := Regs.BX;
    End
  Else
    MouseButtons := 0;
End;


Function DoubleClickSpeed;

Begin
  If IsMouse Then
    Begin
      Regs.AX := $001B;
      Intr ($33, Regs);
      DoubleClickSpeed := Regs.DX;
    End
  Else
    DoubleClickSpeed := 0;
End;


Function MouseMickeysVert;

Begin
  If IsMouse Then
    Begin
      Regs.AX := $001B;
      Intr ($33, Regs);
      MouseMickeysVert := Regs.CX;
    End
  Else
    MouseMickeysVert := 0;
End;


Function MouseMickeysHori;

Begin
  If IsMouse Then
    Begin
      Regs.AX := $001B;
      Intr($33, Regs);
      MouseMickeysHori := Regs.BX;
    End
  Else
    MouseMickeysHori := 0;
End;


Function MouseDisplayPage;

Begin
  If IsMouse Then
    Begin
      Regs.AX := $001E;
      Intr ($33, Regs);
      MouseDisplayPage := Regs.BX;
    End
  Else
    MouseDisplayPage := 0;
End;


Function EGARegisterSupp;

Begin
  If IsMouse Then
    Begin
      Regs.AH := $FA;
      Regs.BX := 0;
      Intr ($10, Regs);
      If Regs.BX <> 0 Then EGARegisterSupp := True
        Else EGARegisterSupp := False;
    End
  Else
    EGARegisterSupp := False;
End;


Function EGARegisterVers;

Begin
  If IsMouse Then
    Begin
      If EGARegisterSupp Then
        Begin
          Regs.AH:=$FA;
          Regs.BX:=0;
          Intr($10, Regs);
          EGARegisterVers := StrFnWord (Unbcd(Mem[Regs.ES:Regs.BX])) +
            '.'+ StrFnWord (Unbcd(Mem[Regs.ES:Regs.BX+1]));
        End
      Else
        EGARegisterVers := 'nicht vorhanden';
    End
  Else
    EGARegisterVers := 'N/A';
End;


Function SaveStateBuffer;

Begin
  If IsMouse Then
    Begin
      Regs.AX := $0015;
      Intr ($33, Regs);
      SaveStateBuffer := Regs.BX;
    End
  Else
    SaveStateBuffer := 0;
End;


Function IsMouseSystemsDrv;

Begin
  If IsMouse Then
    Begin
      Regs.AX := $0070;
      Regs.BX := $ABCD;
      Intr ($33, Regs);
      IsMouseSystemsDrv := ((Regs.AX = $ABCD) And (MemW[Regs.BX:Regs.CX] = $ABCD)
        And (MemW[Regs.BX:Regs.CX + 8] = $ABCD));
    End
  Else
    IsMouseSystemsDrv := False;
End;


Function MouseSystemsVer;

Begin
  If IsMouseSystemsDrv Then
    Begin
      Regs.AX := $0070;
      Regs.BX := $ABCD;
      MouseSystemsVer := StrFnByte (Mem[MemW[Regs.BX:Regs.CX + 2]:MemW[Regs.BX:Regs.CX + 4] + 0]) + '.' +
        ZeroPad (Mem[MemW[Regs.BX:Regs.CX + 2]:MemW[Regs.BX:Regs.CX + 4] + 1]);

      { Nur zum Verst„ndnis : BX:CX ist der Pointer zur Datenstruktur. In
        der Datenstruktur befindet sich an Offset 2 ein Pointer zur Info-
        struktur. In der Infostruktur ist Byte 0 die Major und Byte 1 die
        Minorversion. Um das eintippen von Tabellen zu ersparen habe ich
        das ganze mit Mem und MemW geregelt. }

    End
  Else
    MouseSystemsVer := 'nicht vorhanden';
End;


Function IsLogitechDrv;

Begin
  If IsMouse Then
    Begin
      GetMem (Logitech, SizeOf (Logitech^));
      Regs.AX := $246C;
      Regs.ES := PtrRec(Logitech).Seg;
      Regs.DX := PtrRec(Logitech).Ofs;
      Intr ($33, Regs);
      IsLogitechDrv := (Regs.AX = $FFFF);
      FreeMem (Logitech, SizeOf (Logitech^));
    End
  Else
    IsLogitechDrv := False;
End;


Function LogiCompPara;

Begin
  If IsLogitechDrv Then
    Begin
      Regs.AX := $1D6D;
      Intr ($33, Regs);
      Case Regs.BX Of
        0 : LogiCompPara := 'Norden';
        1 : LogiCompPara := 'Sden';
        2 : LogiCompPara := 'Osten';
        3 : LogiCompPara := 'Westen';
      Else
        LogiCompPara := 'unbekannt';
      End;
    End
  Else
    LogiCompPara := 'nicht vorhanden';
End;


Function LogiSerBaudRate;

Begin
  If IsLogitechDrv Then
    Begin
      GetMem (Logitech, SizeOf (Logitech^));
      Regs.AX := $246C;
      Regs.ES := PtrRec(Logitech).Seg;
      Regs.DX := PtrRec(Logitech).Seg;
      Intr ($33, Regs);
      If Regs.AX = $FFFF Then
        LogiSerBaudRate := Logitech^.BaudRate
      Else
        LogiSerBaudRate := 0;
      FreeMem (Logitech, SizeOf (Logitech^));
    End
  Else
    LogiSerBaudRate := 0;
End;


Function LogiSerReportRate;

Begin
  If IsLogitechDrv Then
    Begin
      GetMem (Logitech, SizeOf (Logitech^));
      Regs.AX := $246C;
      Regs.ES := PtrRec(Logitech).Seg;
      Regs.DX := PtrRec(Logitech).Seg;
      Intr ($33, Regs);
      If Regs.AX = $FFFF Then
        LogiSerReportRate := Logitech^.Reportrate
      Else
        LogiSerReportRate := 0;
      FreeMem (Logitech, SizeOf (Logitech^));
    End
  Else
    LogiSerReportRate := 0;
End;


Function LogiSerFirmRev;

Begin
  If IsLogitechDrv Then
    Begin
      GetMem (Logitech, SizeOf (Logitech^));
      Regs.AX := $246C;
      Regs.ES := PtrRec(Logitech).Seg;
      Regs.DX := PtrRec(Logitech).Seg;
      Intr ($33, Regs);
      If Regs.AX = $FFFF Then
        LogiSerFirmRev := Logitech^.FirmwareRev
      Else
        LogiSerFirmRev := 0;
      FreeMem (Logitech, SizeOf (Logitech^));
    End
  Else
    LogiSerFirmRev := 0;
End;


Function LogiSerPort;

Begin
  If IsLogitechDrv Then
    Begin
      GetMem (Logitech, SizeOf (Logitech^));
      Regs.AX := $246C;
      Regs.ES := PtrRec(Logitech).Seg;
      Regs.DX := PtrRec(Logitech).Seg;
      Intr ($33, Regs);
      If Regs.AX = $FFFF Then
        LogiSerPort := Logitech^.Port
      Else
        LogiSerPort := 0;
      FreeMem (Logitech, SizeOf (Logitech^));
    End
  Else
    LogiSerPort := 0;
End;


Function MouseDriverType : String;

Begin
  If IsMouse And (Hi(MSVersion) >=7) And (Not IsMouseSystemsDrv) Then
    Begin
      Regs.AX := $25;
      Intr ($33, Regs);
      If (Regs.AX and $8000) = $8000 then
        MouseDriverType := 'Device driver'
      Else
        MouseDriverType := 'TSR';
    End
  Else
    MouseDriverType := 'N/A';
End;


Function MouseCursorType : String;

Begin
  If IsMouse And (Hi(MSVersion) >=7) And (Not IsMouseSystemsDrv) Then
    Begin
      Regs.AX := $25;
      Intr ($33, Regs);
      Case (Regs.AX And $3000) Shr 12 Of
        0   : MouseCursorType := 'Software';
        1   : MouseCursorType := 'Hardware';
        2,3 : MouseCursorType := 'Grafik'
      End;
    End
  Else
    MouseCursorType := 'N/A';
End;


Function MouseIntrRate : String;

Begin
  If IsMouse And (Hi(MSVersion) >=7) And (Not IsMouseSystemsDrv) Then
    Begin
      Regs.AX := $25;
      Intr ($33, Regs);
      Case (Regs.AX And $0F00) Shr 8 Of
        0 : MouseIntrRate := 'keine';
        1 : MouseIntrRate := '30Hz';
        2 : MouseIntrRate := '50Hz';
        3 : MouseIntrRate := '100Hz';
        4 : MouseIntrRate := '200Hz'
      Else
        MouseIntrRate := '?';
      End;
    End
  Else
    MouseIntrRate := 'N/A';
End;


Function MouseAccellProf : Word;

Begin
  If IsMouse And (Hi(MSVersion) >=7) And (Not IsMouseSystemsDrv) Then
    Begin
      Regs.AX := $2C;
      Intr ($33, Regs);
      MouseAccellProf := Regs.BX
    End
  Else
    MouseAccellProf := 0;
End;


Function MouseBallpoint : Boolean;

Begin
  If IsMouse And ((Hi(MSVersion) > 7) Or ((Hi(MSVersion) = 7) And
    (Lo(MSVersion) >= 4))) And (Not IsMouseSystemsDrv) Then
      Begin
        Regs.AX := $30;
        Regs.CX := 0;
        Intr ($33, Regs);
        MouseBallPoint := (Regs.AX <> $FFFF);
      End
  Else
    MouseBallPoint := False;
End;


Function MouseIniPath : String;

Var EndString : String;

Begin
  EndString := '';
  If IsMouse And (Hi(MSVersion) >=8) And (Not IsMouseSystemsDrv) Then
    Begin
      Regs.AX := $34;
      Intr ($33, Regs);

      While Mem[Regs.ES:Regs.DX] <> 0 do
        Begin
          EndString := EndString + Chr(Mem[Regs.ES:Regs.DX]);
          Inc (Regs.DX);
        End;
    End
  Else
    EndString := 'N/A';

  MouseIniPath := EndString;
End;


Function MousePointerStyle : String;

Begin
  EndString := '';
  If IsMouse And ((Hi(MSVersion) > 8) Or ((Hi(MSVersion) = 8) And
    (Lo(MSVersion) >= $10))) And (Not IsMouseSystemsDrv) Then
      Begin
        Regs.AX := $35;
        Regs.BX := $FFFF;
        Intr ($33, Regs);
        Case Regs.BH of
          0 : EndString := 'Normal';
          1 : EndString := 'Invertiert';
          2 : EndString := 'Transparent'
        else
          EndString := '?';
        end;
      End
  Else
    EndString := 'N/A';

  MousePointerStyle := EndString;
End;


Function MousePointerSize : String;

Begin
  EndString := '';
  If IsMouse And ((Hi(MSVersion) > 8) Or ((Hi(MSVersion) = 8) And
    (Lo(MSVersion) >= $10))) And (Not IsMouseSystemsDrv) Then
      Begin
        Regs.AX := $35;
        Regs.BX := $FFFF;
        Intr ($33, Regs);
        Case Regs.BL of
          0 : EndString := 'klein';
          1 : EndString := 'mittel';
          2 : EndString := 'groá'
        Else
          EndString := '?';
        End;
      End
  Else
    EndString := 'N/A';

  MousePointerSize := EndString;
End;


Function MousePointerSChange : Boolean;

Begin
  EndString := '';
  If IsMouse And ((Hi(MSVersion) > 8) Or ((Hi(MSVersion) = 8) And
    (Lo(MSVersion) >= $10))) And (Not IsMouseSystemsDrv) Then
      Begin
        Regs.AX := $35;
        Regs.BX := $FFFF;
        Intr ($33, Regs);
        MousePointerSChange := (Regs.CL = 1);
      End
  Else
    MousePointerSChange := False;
End;


Function IsZNixMouseDrv;

Type String65 = String[65];

Var pString65 : ^String65;

Begin
  If IsMouse Then
    Begin
      Regs.AX := $004B;
      Intr ($33, Regs);
      pString65 := Ptr (Regs.ES, Regs.DI-1);
      pString65^[0] := Chr (65);
      IsZNixMouseDrv := (pString65^ = 'Z-NIX;BUS,AUX,Serial 3-byte and 5-byte Mouse Driver;ZMOUSE;v7.04d');
    End
  Else
    IsZNIXMouseDrv := False;
End;


Function IsTrueDOXMouseDrv;

Type String50 = String[50];

Var pString50 : ^String50;

Begin
  If IsMouse Then
    Begin
      Regs.AX := $0666;
      Intr ($33, Regs);
      pString50 := Ptr (Regs.DX, Regs.AX-1);
      pString50^[0] := Chr (50);
      IsTrueDOXMouseDrv := (pString50^ = 'Copyright 1987-1992 TRUEDOX Technology Corporation');
    End
  Else
    IsTrueDOXMouseDrv := False;
End;


Function IsHPMouseDrv;

Begin
  If IsMouse Then
    Begin
      Regs.AX := $6F00;
      Regs.BX := $0000;
      Intr ($33, Regs);
      IsHPMouseDrv := (Regs.BX = $4850);
    End
  Else
    IsHPMouseDrv := False;
End;


Begin
End.