Unit DetectMM;

Interface

Function Is386Max            : Boolean;
Function _386MaxVersion      : String;
Function _386MaxSegment      : Word;
Function _386MaxEMSActive    : Boolean;
Function _386MaxWin3Supp     : Boolean;

Function IsMICEMM            : Boolean;
Function MICEMMCS            : Word;

Function IsEmm386            : Boolean;
Function Emm386Api           : Pointer;
Function Emm386Status        : String;
Function Emm386Weitek        : String;

Function IsQEMM              : Boolean;
Function QEMMApi             : Pointer;
Function QEMMVersion         : String;
Function QEMMStatus          : String;
Function QEMMIsHiRam         : Boolean;
Function QEMMHiRamMCB        : Word;
Function QEMMStealthStatus   : String;
Function QEMMStealthRom      : Word;
Function QEMMInitConv        : LongInt;
Function QEMMInitExt         : LongInt;
Function QEMMInitExp         : LongInt;
Function QEMMInitExtra       : LongInt;
Function QEMMInitTotal       : LongInt;
Function QEMMCurrConv        : LongInt;
Function QEMMCurrExt         : LongInt;
Function QEMMCurrEMSXMS      : LongInt;
Function QEMMCurrHiRam       : LongInt;
Function QEMMCurrMapped      : LongInt;
Function QEMMCurrDMAB        : LongInt;
Function QEMMCurrDMATasks    : LongInt;
Function QEMMCurrDMAMap      : LongInt;
Function QEMMCurrCode        : LongInt;
Function QEMMCurrData        : LongInt;
Function QEMMCurrTotal       : LongInt;
Function QEMMUnAvailConv     : LongInt;
Function QEMMUnAvailExt      : LongInt;
Function QEMMUnAvailExp      : LongInt;
Function QEMMUnAvailShdwTop  : LongInt;
Function QEMMMemType (Adr : Byte) : String;
Function QEMMAccess (Adr : Byte)  : String;
Function QEMMStealth (Adr : Byte) : String;
Function IsQManifest         : Boolean;
Function IsQVidRam           : Boolean;
Function VidRamCS            : Word;


Implementation

Uses Dos, DetectConstants, DetectGlobal, DetectMemory;

Type T386maxbuf = record
       version     : byte;
       signature   : array[1..6] of char;
       verstr      : array[1..4] of char;
       lowseg      : word;
       unkw1       : word;
       unkw2       : word;
       flags1      : word;
       unk1        : array [1..16] of byte;
       int15port   : word;
       int67port   : word;
       unkw3       : word;
       unkw4       : word;
       unkd1       : longint;
       unkd2       : longint;
       sysconfig   : word;
       unk2        : array [1..8] of byte;
       flags2      : word;
       flags3      : word;
       flags4      : word;
       unkw5       : word;
       extfree     : word;
       unkd3       : longint;
       unkw6       : word;
       unkd4       : longint;
       flags5      : word;
       oldint21ofs : word;
       oldint21seg : word;
       emsofs      : word;
       emsseg      : word;
       extra       : byte;
     end;

      TStatRec = record
                   ExtraMemType: byte;
                   InitConvMem: longint;
                   InitExtMem: longint;
                   InitExpMem: longint;
                   InitExtraMem: longint;
                   UnAvailConv: longint;
                   UnAvailExt: longint;
                   UnAvailExp: longint;
                   UnAvailExtra1: longint;
                   CodeSize: longint;
                   DataSize: longint;
                   TaskSize: longint;
                   DMASize: longint;
                   MAPSize: longint;
                   HiRAMSize: longint;
                   MappedROMSize: longint;
                   ConvMemSize: longint;
                   ExtMemSize: longint;
                   EMSXMSMemSize: longint;
                   UnAvailExtra2: longint;
                   ConvOverhead: longint;
                 end;

Var
  { Die folgende Tabelle wird durch Is386Max gefÅllt und wird fÅr alle
    _386Max??? Routinen benîtigt.                                        }
  V386MaxBuf : T386MaxBuf;
  { Die folgenden Variablen werden fÅr die QEMM-Funktionen gebraucht     }
  QEMMId   : Byte;
  QEMMStat : TStatRec;
  Buffer   : Array [0..255] Of Byte;
  Temp1    : Byte;


Function Is386Max;

Var S      : String;
    xByte  : Word;

Begin
  S := '386MAX$$'#0;
  Regs.AX:=$3D00;
  Regs.DS:=Seg(s);
  Regs.DX:=Ofs(s) + 1;
  MsDos(regs);
  If Not Regs.Flags And FCarry = 1 Then
    Begin
      Xbyte:=Regs.AX;
      Regs.AX:=$4402;
      Regs.BX:=xbyte;
      Regs.CX:=$5A;
      Regs.DS:=Seg(V386Maxbuf);
      Regs.DX:=Ofs(V386Maxbuf);
      V386Maxbuf.version:=3;
      MsDos(regs);
      If Regs.Flags And FCarry = 1 then
        Is386Max := False
      Else
        If V386MaxBuf.Signature <> '386MAX' then
          Is386Max := False
        Else
          Is386Max := True;
      Regs.AH := $3E;
      Regs.BX := Xbyte;
      MsDos(Regs);
    End
  Else
    Is386Max := False;
End;


Function _386MaxVersion;

Begin
  If Is386Max Then
    Begin
      _386MaxVersion := V386MaxBuf.verstr[1] + '.' + V386MaxBuf.verstr[3] +
        V386MaxBuf.verstr[4];
    End
  Else
    _386MaxVersion := 'nicht vorhanden';
End;


Function _386MaxSegment;

Begin
  If Is386Max Then
    Begin
      _386MaxSegment := V386MaxBuf.lowSeg;
    End
  Else
    _386MaxSegment := 0;
End;


Function _386MaxEMSActive;

Begin
  If Is386Max Then
    Begin
      _386MaxEMSActive := (V386MaxBuf.flags1 and $0080 = $0080);
    End
  Else
    _386MaxEMSActive := False;
End;


Function _386MaxWin3Supp;

Begin
  If Is386Max Then
    Begin
      _386MaxWin3Supp := (V386MaxBuf.flags4 and 1 = 1);
    End
  Else
    _386MaxWin3Supp := False;
End;


Function IsMICEMM;

Begin
  If Not IsExistEMS Then
    IsMICEMM := False
  Else
    With Regs Do
      Begin
        Regs.AX:=$58F0;
        Intr($67, Regs);
        If Regs.AH <> 0 then
          IsMICEMM := False
        Else
          IsMICEMM := True;
      End;
End;


Function MICEMMCS;

Begin
  If IsMICEMM Then
    Begin
      Regs.AX:=$58F0;
      Intr($67, Regs);
      MICEMMCS := Regs.BX;
    End
  Else
    MICEMMCS := 0;
End;


Function IsEmm386;

Begin
  If Not IsExistEMS Then
    IsEmm386 :=False
  Else
    With Regs do
      Begin
       AX:=$FFA5;
       Intr($67, Regs);
       If AX <> $845A Then
         IsEmm386 := False
       Else
         IsEmm386 := True;
      End;
End;


Function Emm386API;

Begin
  If IsEmm386 Then
    with Regs do
      begin
        AX:=$FFA5;
        Intr($67, Regs);
        Emm386API := Ptr (BX, CX);
      End
  Else
    Emm386Api := Ptr (0, 0);
End;


Function Emm386Status;

Var Temp : Pointer;
    Temp2 : Byte;

Begin
  If IsEmm386 Then
    with Regs do
      begin
        AX:=$FFA5;
        Intr($67, Regs);

        Temp := Emm386Api;
        Asm
          Mov Ah, 0
          Call Temp
          Mov Temp2, AL
        End;

        If temp2 and 1 = 1 then
          Emm386Status := 'aktiv'
        else
          Emm386Status := 'inaktiv';
      End
  Else
    Emm386Status := 'nicht vorhanden';
End;


Function Emm386Weitek;

Var Temp : Pointer;
    Temp2 : Byte;

Begin
  If IsEmm386 Then
    With Regs do
      Begin
        AX:=$FFA5;
        Intr($67, Regs);

        Temp := Emm386Api;
        Asm
          Mov AH, 2
          Mov AL, 0
          Call Temp
          Mov Temp2, Al
        End;

        if Temp2 and 1 = 1 then
          begin
            Emm386Weitek := 'vorhanden ';
            if Temp2 and 2 = 2 then
              Emm386Weitek := Emm386Weitek + 'und genutzt'
            else
              Emm386Weitek := Emm386Weitek + 'aber nicht benutzt';
          end
        else
          Emm386Weitek := 'nicht vorhanden';
      End;
End;


Function IsQEMM;

Var FoundIt : Boolean;

Begin
  with regs do
    begin
      QEMMid:=$D2;
      foundit:=false;
      repeat
        AH:=QEMMId;
        AL:=0;
        BX:=$5144; {'QD'}
        CX:=$4D45; {'ME'}
        DX:=$4D30; {'M0'}
        Intr($2F, regs);
        if (AL = $FF) and (BX = $4D45) and (CX = $4D44) and (DX = $5652) then
          foundit:=true
        else
          begin
          if QEMMid < $FF then
            Inc(QEMMid)
          else
            QEMMid:=$C0;
          end;
      until foundit or (QEMMid = $D2);

      if not foundit then
        IsQEMM := False
      else
        begin
          AH:=QEMMid;
          AL:=1;
          BX:=$5145; {'QE'}
          CX:=$4D4D; {'MM'}
          DX:=$3432; {'42'}
          Intr($2F, regs);
          if BX = $4F4B {'OK'} then
            IsQEMM := True
          else
            IsQEMM := False
        End;
    End;
End;


Function QEMMApi;

Begin
  { IsQEMM wird dazu verwendet, die QEMM ID ins ID-Byte zu schreiben        }
  If IsQEMM Then
    Begin
      Regs.AH:=QEMMid;
      Regs.AL:=1;
      Regs.BX:=$5145; {'QE'}
      Regs.CX:=$4D4D; {'MM'}
      Regs.DX:=$3432; {'42'}
      Intr($2F, regs);
      QEMMApi := Ptr (Regs.ES, Regs.DI);
    End
  Else
    QEMMApi := Ptr (0,0);
End;


Function QEMMVersion;

Var Temp : Byte;
    Temp2 : Pointer;
    Temp3 : Word;

Begin
  { IsQEMM wird dazu verwendet, die QEMM ID ins ID-Byte zu schreiben        }
  If IsQEMM Then
    Begin
      Temp2 := QEMMApi;
      Asm
        Mov Ah,3
        Call Temp2
        Mov Temp,0
        jnc @2
      @1:
        Mov Temp,1
      @2:
        Mov Temp3, BX
     End;

      if Temp = 1 Then
        QEMMVersion := 'Fehler'
      else
        QEMMVersion := StrFnByte(unBCD(Hi(Temp3))) + '.' + ZeroPad (unBCD(Lo(Temp3)));
    End
  Else
    QEMMVersion := 'nicht vorhanden';
End;


Function QEMMStatus;

Var Temp  : Byte;
    Temp2 : Pointer;
    Temp3 : Byte;

Begin
  { IsQEMM wird dazu verwendet, die QEMM ID ins ID-Byte zu schreiben        }
  If IsQEMM Then
    Begin
      Temp2 := QEMMApi;
      Asm
        Mov Ah,0
        Call Temp2
        Mov Temp,0
        jnc @2
      @1:
        Mov Temp,1
      @2:
        Mov Temp3, AL
     End;

     if Temp = 1  then
        QEMMStatus := 'Fehler'
     else
        if Temp3 and 1 = 1 then
          QEMMStatus := 'Aus'
        else
          if Temp3 and 2 = 2 then
             QEMMStatus := 'Auto'
          else
             QEMMStatus := 'An';
    End
  Else
    QEMMStatus := 'nicht vorhanden';
End;


Function QEMMIsHiRam;

Var Temp  : Byte;
    Temp2 : Pointer;
    Temp3 : Word;

Begin
  { IsQEMM wird dazu verwendet, die QEMM ID ins ID-Byte zu schreiben        }
  If IsQEMM Then
    Begin
      Temp2 := QEMMApi;
      Asm
        Mov Ah, 12h
        Call Temp2
        Mov Temp,0
        jnc @2
      @1:
        Mov Temp,1
      @2:
        Mov Temp3, BX
     End;

     if Temp = 1 then
       QEMMIsHiRam := False
     else
       QEMMIsHiRam := (Temp3 <> 0);
    End
  Else
    QEMMIsHiRam := False;
End;


Function QEMMHiRamMCB;

Var Temp  : Byte;
    Temp2 : Pointer;
    Temp3 : Word;

Begin
  { IsQEMM wird dazu verwendet, die QEMM ID ins ID-Byte zu schreiben        }
  If IsQEMM Then
    If QEMMIsHiRam Then
      Begin
        Temp2 := QEMMApi;
        Asm
          Mov Ah, 12h
          Call Temp2
          Mov Temp,0
          jnc @2
        @1:
          Mov Temp,1
        @2:
          Mov Temp3, BX
       End;

       if Temp = 1 then
         QEMMHiRamMCB := 0
       else
         QEMMHiRamMCB := Temp3;
      End
    Else
      QEMMHiRamMCB := 0;
End;


Function QEMMStealthStatus;

Var Temp  : Byte;
    Temp2 : Pointer;
    Temp3 : Byte;
    Temp4 : Word;

Begin
  { IsQEMM wird dazu verwendet, die QEMM ID ins ID-Byte zu schreiben        }
  If IsQEMM Then
    Begin
      Temp2 := QEMMApi;
      Asm
        Mov Ah,3
        Call Temp2
        Mov Temp,0
        jnc @2
      @1:
        Mov Temp,1
      @2:
        Mov Temp4, BX
      End;

      if Hi(Temp4) >= 6 then
        begin
          Asm
            Mov AX, 1E00h
            Call Temp2
            Mov Temp,0
            jnc @2
          @1:
            Mov Temp,1
          @2:
            Mov Temp3, CL
          End;

          if Temp = 1 then
            QEMMStealthStatus := 'Fehler'
          else
            begin
              case Temp3 of
                  0: QEMMStealthStatus := 'Aus';
                $46: QEMMStealthStatus := 'Frame';
                $4D: QEMMStealthStatus := 'Map'
              else
                QEMMStealthStatus := '????';
              end;
            End;
        End
      Else
        QEMMStealthStatus := 'zu alte Version';
    End
  Else
    QEMMStealthStatus := 'nicht vorhanden';
End;


Function QEMMStealthRom;

Var Temp  : Byte;
    Temp2 : Pointer;
    Temp3 : Byte;
    temp4 : Word;

Begin
  { IsQEMM wird dazu verwendet, die QEMM ID ins ID-Byte zu schreiben        }
  If IsQEMM Then
    Begin
      Temp2 := QEMMApi;
      Asm
        Mov Ah,3
        Call Temp2
        Mov Temp,0
        jnc @2
      @1:
        Mov Temp,1
      @2:
        Mov Temp4, BX
      End;

      if Hi(Temp4) >= 6 then
        begin
          Asm
            Mov AX, 1E00h
            Call Temp2
            Mov Temp,0
            jnc @2
          @1:
            Mov Temp,1
          @2:
            Mov Temp3, CL
          End;

          If (Temp3 = $46) Or (Temp3 = $4D) Then
            Begin
              Asm
                Mov AX, 1E01h
                Call Temp2
                Mov Temp,0
                jnc @2
              @1:
                Mov Temp,1
              @2:
                Mov Temp4, BX
              End;

              if Temp = 1 then
                QEMMStealthRom := 0
              else
                QEMMStealthRom := Temp4;
            End
          Else
            QEMMStealthRom := 0;
        End
      Else
        QEMMStealthRom := 0;
    End
  Else
    QEMMStealthRom := 0;
End;


Procedure FillQEMMTable;

Var Temp : Byte;
    Temp2 : Pointer;
    SegQEMMStat : Word;
    OfsQEMMStat : Word;

Begin
  If IsQEMM Then
    Begin
      SegQEMMStat := Seg(QEMMStat);
      OfsQEMMStat := Ofs(QEMMStat);
      QEMMStat.ConvOverHead := 0;
      Temp2 := QEMMApi;
      Asm
          Mov AH,17h
          Mov ES, SegQEMMStat
          Mov DI, OfsQEMMStat
          Call Temp2
          Mov Temp,0
          jnc @2
        @1:
          Mov Temp,1
        @2:
       End;
       Temp1 := Temp;
    End;
End;


Function QEMMInitConv;

Begin
  If IsQEMM Then
    Begin
     FillQEMMTable;

     If Temp1 = 1 Then
       Begin
         { Vielleicht erst ab Version 5 abrufbar, kann Memory-Statistiken
           nicht ermitteln ... }
         QEMMInitConv := 0;
       End
     Else
       Begin
         QEMMInitConv := QEMMStat.InitConvMem;
       End
    End
  Else
    QEMMInitConv := 0;
End;


Function QEMMInitExt;

Begin
  If IsQEMM Then
    Begin
     FillQEMMTable;
     If Temp1 = 1 Then
       Begin
         { Vielleicht erst ab Version 5 abrufbar, kann Memory-Statistiken
           nicht ermitteln ... }
         QEMMInitExt := 0;
       End
     Else
       Begin
         QEMMInitExt := QEMMStat.InitExtMem;
       End
    End
  Else
    QEMMInitEXT := 0;
End;


Function QEMMInitExp;

Begin
  If IsQEMM Then
    Begin
     FillQEMMTable;
     If Temp1 = 1 Then
       Begin
         { Vielleicht erst ab Version 5 abrufbar, kann Memory-Statistiken
           nicht ermitteln ... }
         QEMMInitExp := 0;
       End
     Else
       Begin
         QEMMInitExp := QEMMStat.InitExpMem;
       End
    End
  Else
    QEMMInitEXp := 0;
End;


Function QEMMInitExtra;

Begin
  If IsQEMM Then
    Begin
     FillQEMMTable;
     If Temp1 = 1 Then
       Begin
         { Vielleicht erst ab Version 5 abrufbar, kann Memory-Statistiken
           nicht ermitteln ... }
         QEMMInitExtra := 0;
       End
     Else
       Begin
         QEMMInitExtra := QEMMStat.InitExtraMem;
       End
    End
  Else
    QEMMInitEXTra := 0;
End;


Function QEMMInitTotal;

Begin
  If IsQEMM Then
    Begin
      QEMMInitTotal := QEMMInitConv + QEMMInitExt + QEMMInitExp + QEMMInitExtra;
    End
  Else
    QEMMInitTotal := 0;
End;


Function QEMMCurrConv;

Begin
  If IsQEMM Then
    Begin
     FillQEMMTable;
     If Temp1 = 1 Then
       Begin
         { Vielleicht erst ab Version 5 abrufbar, kann Memory-Statistiken
           nicht ermitteln ... }
         QEMMCurrConv := 0;
       End
     Else
       Begin
         QEMMCurrConv := QEMMStat.ConvMemSize;
       End
    End
  Else
    QEMMCurrConv := 0;
End;


Function QEMMCurrExt;

Begin
  If IsQEMM Then
    Begin
     FillQEMMTable;
     If Temp1 = 1 Then
       Begin
         { Vielleicht erst ab Version 5 abrufbar, kann Memory-Statistiken
           nicht ermitteln ... }
         QEMMCurrExt := 0;
       End
     Else
       Begin
         QEMMCurrExt := QEMMStat.ExtMemSize;
       End;
    End
  Else
    QEMMCurrExt := 0;
End;


Function QEMMCurrEMSXMS;

Begin
  If IsQEMM Then
    Begin
     FillQEMMTable;
     If Temp1 = 1 Then
       Begin
         { Vielleicht erst ab Version 5 abrufbar, kann Memory-Statistiken
           nicht ermitteln ... }
         QEMMCurrEMSXMS := 0;
       End
     Else
       Begin
         QEMMCurrEMSXMS := QEMMStat.EMSXMSMemSize;
       End;
    End
  Else
    QEMMCurrEMSXMS := 0;
End;


Function QEMMCurrHiRam;

Begin
  If IsQEMM Then
    Begin
     FillQEMMTable;
     If Temp1 = 1 Then
       Begin
         { Vielleicht erst ab Version 5 abrufbar, kann Memory-Statistiken
           nicht ermitteln ... }
         QEMMCurrHiram := 0;
       End
     Else
       Begin
         QEMMCurrHiram := QEMMStat.HiRamSize;
       End;
    End
  Else
    QEMMCurrHiram := 0;
End;


Function QEMMCurrMapped;

Begin
  If IsQEMM Then
    Begin
     FillQEMMTable;
     If Temp1 = 1 Then
       Begin
         { Vielleicht erst ab Version 5 abrufbar, kann Memory-Statistiken
           nicht ermitteln ... }
         QEMMCurrMapped := 0;
       End
     Else
       Begin
         QEMMCurrMapped := QEMMStat.MappedRomSize;
       End;
    End
  Else
    QEMMCurrMapped := 0;
End;


Function QEMMCurrDMAB;

Begin
  If IsQEMM Then
    Begin
     FillQEMMTable;
     If Temp1 = 1 Then
       Begin
         { Vielleicht erst ab Version 5 abrufbar, kann Memory-Statistiken
           nicht ermitteln ... }
         QEMMCurrDMAB := 0;
       End
     Else
       Begin
         QEMMCurrDMAB := QEMMStat.DMASize;
       End;
    End
  Else
    QEMMCurrDMAB := 0;
End;


Function QEMMCurrDMATasks;

Begin
  If IsQEMM Then
    Begin
     FillQEMMTable;
     If Temp1 = 1 Then
       Begin
         { Vielleicht erst ab Version 5 abrufbar, kann Memory-Statistiken
           nicht ermitteln ... }
         QEMMCurrDMATasks := 0;
       End
     Else
       Begin
         QEMMCurrDMATasks := QEMMStat.TaskSize;
       End;
    End
  Else
    QEMMCurrDMATasks := 0;
End;


Function QEMMCurrDMAMap;

Begin
  If IsQEMM Then
    Begin
     FillQEMMTable;
     If Temp1 = 1 Then
       Begin
         { Vielleicht erst ab Version 5 abrufbar, kann Memory-Statistiken
           nicht ermitteln ... }
         QEMMCurrDMAMap := 0;
       End
     Else
       Begin
         QEMMCurrDMAMap := QEMMStat.MapSize;
       End;
    End
  Else
    QEMMCurrDMAMap := 0;
End;


Function QEMMCurrCode;

Begin
  If IsQEMM Then
    Begin
     FillQEMMTable;
     If Temp1 = 1 Then
       Begin
         { Vielleicht erst ab Version 5 abrufbar, kann Memory-Statistiken
           nicht ermitteln ... }
         QEMMCurrCode := 0;
       End
     Else
       Begin
         QEMMCurrCode := QEMMStat.CodeSize;
       End;
    End
  Else
    QEMMCurrCode := 0;
End;


Function QEMMCurrData;

Begin
  If IsQEMM Then
    Begin
     FillQEMMTable;
     If Temp1 = 1 Then
       Begin
         { Vielleicht erst ab Version 5 abrufbar, kann Memory-Statistiken
           nicht ermitteln ... }
         QEMMCurrData := 0;
       End
     Else
       Begin
         QEMMCurrData := QEMMStat.DataSize;
       End;
    End
  Else
    QEMMCurrData := 0;
End;


Function QEMMCurrTotal;

Begin
  If IsQEMM Then
    Begin
      QEMMCurrTotal := QEMMCurrCode + QEMMCurrData + QEMMCurrDMATasks +
                       QEMMCurrDMAB + QEMMCurrDMAMap + QEMMCurrHiram +
                       QEMMCurrMapped + QEMMCurrConv + QEMMCurrExt +
                       QEMMCurrEMSXMS;
    End
  Else
    QEMMCurrTotal := 0;
End;


Function QEMMUnAvailConv;

Begin
  If IsQEMM Then
    Begin
     FillQEMMTable;
     If Temp1 = 1 Then
       Begin
         { Vielleicht erst ab Version 5 abrufbar, kann Memory-Statistiken
           nicht ermitteln ... }
         QEMMunAvailConv := 0;
       End
     Else
       Begin
         QEMMUnAvailConv := QEMMStat.UnAvailConv;
       End;
    End
  Else
    QEMMUnAvailConv := 0;
End;


Function QEMMUnAvailExt;

Begin
  If IsQEMM Then
    Begin
     FillQEMMTable;
     If Temp1 = 1 Then
       Begin
         { Vielleicht erst ab Version 5 abrufbar, kann Memory-Statistiken
           nicht ermitteln ... }
         QEMMunAvailExt := 0;
       End
     Else
       Begin
         QEMMUnAvailExt := QEMMStat.UnAvailExt;
       End;
    End
  Else
    QEMMUnAvailExt := 0;
End;


Function QEMMUnAvailExp;

Begin
  If IsQEMM Then
    Begin
     FillQEMMTable;
     If Temp1 = 1 Then
       Begin
         { Vielleicht erst ab Version 5 abrufbar, kann Memory-Statistiken
           nicht ermitteln ... }
         QEMMUnAvailExp := 0;
       End
     Else
       Begin
         QEMMUnAvailExp := QEMMStat.UnAvailExp;
       End;
    End
  Else
    QEMMUnAvailExp := 0;
End;


Function QEMMUnAvailShdwTop;

Begin
  If IsQEMM Then
    Begin
     FillQEMMTable;
     If Temp1 = 1 Then
       Begin
         { Vielleicht erst ab Version 5 abrufbar, kann Memory-Statistiken
           nicht ermitteln ... }
         QEMMunAvailShdwTop := 0;
       End
     Else
       Begin
         QEMMUnAvailShdwTop := QEMMStat.UnAvailExtra1 + QEMMStat.UnAvailExtra2;
       End;
    End
  Else
    QEMMUnAvailShdwTop := 0;
End;


Procedure QEMMPrepareBuffer (F : Word);

Var Temp   : Byte;
    Temp2  : Pointer;
    SegBuf : Word;
    OfsBuf : Word;
    Temp3  : Word;
    Temp4  : Word;

Begin
  If IsQEMM Then
    Begin
      SegBuf := Seg(Buffer);
      OfsBuf := Ofs(Buffer);
      Temp2 := QEMMApi;
      Temp3 := F;
      Asm
        Mov AX, Temp3
        Mov Es, SegBuf
        Mov Di, OfsBuf
        Call Temp2
        Mov Temp1,0
        jnc @2
        Mov Temp1,1
      @2:
        Mov Temp4, BX
     End;
       Regs.BX := Temp4; { Stealth Routine benîtigt das }
    End;
End;


Function QEMMMemType;

Const  QEMMMemTypeT: array[0..$B] of char = 'm?MHXVRAsFrC';

Var BufferPos : Word;

Begin
  If IsQEMM Then
    Begin
      QEMMPrepareBuffer ($1100);

      Regs.AH := $41;
      Intr($67, regs);
      If Regs.AH = 0 Then
        For BufferPos := Regs.BX DIV 256 To (Regs.BX DIV 256) + 15 Do
          Buffer [BufferPos] := 9;

      For BufferPos := 0 To 255 Do
        Begin
          If BufferPos = Adr Then
            Begin
              If Buffer[BufferPos] > $B then
                QEMMMemType := '?'
              Else
                QEMMMemType := QEMMMemTypeT[Buffer[BufferPos]];
            End;
        End;
    End
  Else
    QEMMMemType := '?';
End;


Function QEMMAccess;

Const QEMMMemAccess: array[0..3] of char = '-+*!';

Var BufferPos : Word;

Begin
  If IsQEMM Then
    Begin
      QEMMPrepareBuffer ($1600);

      If Temp1 = 1 Then
        FillChar(Buffer, SizeOf(Buffer), #255);

      For BufferPos := 0 To 255 Do
        Begin
          If BufferPos = Adr Then
            If Buffer[BufferPos] > 3 then
              QEMMAccess := '?'
            Else
              QEMMAccess := QEMMMemAccess[Buffer[BufferPos]];
        End;
    End
  Else
    QEMMAccess := '?';
End;


Function QEMMStealth;

Type
  TStealthRec = Record
                  StartingSeg: word;
                  ParaSize: word;
                End;

Const QEMMStealthT : array[0..1] of char = ' S';

Var BufferPos    : Word;
    Temp2        : Pointer;
    Temp         : Byte;
    SegSBuf      : Word;
    OfsSBuf      : Word;
    Temp3        : Word;
    StealthCount : Word;
    StealthStart : Word;
    StealthSize  : Word;
    StealthSet   : Word;
    StealthBuf   : Array [1..64] Of TStealthRec;

Begin
  If IsQEMM Then
    Begin
      QEMMPrepareBuffer ($1E01);

      If (Regs.BX > 0) and (Regs.BX < 65) then
        Begin

          Asm
            Mov AX, 1E02h
            Mov Es, SegSBuf
            Mov Di, OfsSBuf
            Call Temp2
            Mov Temp1,0
            jnc @2
            Mov Temp1,1
          @2:
            Mov Temp3, BX
          End;

          FillChar (Buffer, SizeOf(Buffer), 0);

          If Temp1 = 0 Then
            For StealthCount := 1 to Temp3 Do
              begin
                StealthSize := StealthBuf[StealthCount].ParaSize div 256;
                StealthStart := StealthBuf[StealthCount].StartingSeg div 256;
                For StealthSet := StealthStart to StealthStart + StealthSize Do
                  Buffer [StealthSet] := 1;
                End;
          For BufferPos := 0 To 255 Do
            begin
              If BufferPos = Adr Then
                If Buffer[BufferPos] > 1 then
                  QEMMStealth := '?'
                Else
                  QEMMStealth := QEMMStealthT[Buffer[BufferPos]];
            End;
        End
      Else
        QEMMStealth := ' ';
    End
  Else
    QEMMStealth := '?';
End;


Function IsQManifest;

Begin
  If IsQEMM Then
    Begin
      Regs.AH:=QEMMid;
      Regs.AL:=1;
      Regs.BX:=$4D41; {'MA'}
      Regs.CX:=$4E49; {'NI'}
      Regs.DX:=$4645; {'FE'}
      Intr($2F, regs);
      IsQManifest := (Regs.BX = $5354 {'ST'});
    End
  Else
    IsQManifest := False;
End;


Function IsQVidRam;

Begin
  If IsQEMM Then
    Begin
      Regs.AH:=QEMMid;
      Regs.AL:=1;
      Regs.BX:=$5649; {'VI'}
      Regs.CX:=$4452; {'DR'}
      Regs.DX:=$414D; {'AM'}
      Intr($2F, regs);
      IsQVidRam := (Regs.BX = $4F4B {'OK'})
    End
  Else
    IsQVidRam := False;
End;


Function VidRamCS;

Begin
  If IsQEMM Then
    If IsQVidRam Then
      Begin
        Regs.AH:=QEMMid;
        Regs.AL:=1;
        Regs.BX:=$5649; {'VI'}
        Regs.CX:=$4452; {'DR'}
        Regs.DX:=$414D; {'AM'}
        Intr($2F, regs);
        VidRamCS := Regs.ES;
      End
  Else
    VidRamCS := 0;
End;


Begin
End.