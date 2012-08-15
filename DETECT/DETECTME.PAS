Unit DetectMemory;

Interface

Function IsExistEms       : Boolean;
Function GetEMSVersion    : String;
Function AllEMSPages      : Word;
Function FreeEMSPages     : Word;
Function GetEMSAddress    : Pointer;
Function GetNumberHandles : Word;
Function GetEMSHandleSize (Handle : Word) : LongInt;
Function GetEMSHandleName (Handle : Word) : String;

Function IsVCPI         : Boolean;
Function VCPIVersion    : String;

Function IsExtMemBIOS   : Boolean;
Function BiosFreeEXT    : LongInt;

Function IsExtMemDriv   : Boolean;
Function XMSVersion     : String;
Function XMMVersion     : String;
Function XMSMemory      : Word;
Function XMSFreeMemory  : Word;
Function A20Status      : Byte;

Function IsUMB          : Boolean;
Function UMBLargestBl   : LongInt;

Function IsHma          : Boolean;
Function HmaStatus      : String;
Function HmaUsedByDos5  : Boolean;
Function HmaFreeDos5    : Word;
Function HmaAddressDos5 : Pointer;

Function IsDPMI         : Boolean;
Function DPMIVersion    : String;
Function DPMICPU        : String;
Function DPMIModeEntry  : Pointer;

Function CMOSBaseMemory : Word;
Function CMOSExtMemory  : Word;
Function CMOSTotalMem   : Word;

Function IsVDS              : Boolean;
Function VDSVersion         : String;
Function VDSProduct         : String;
Function VDSMaxDMABSize     : Word;
Function VDSTransfersOk     : String;
Function VDSIsBuffer1Meg    : Boolean;
Function VDSIsAutoRemap     : Boolean;
Function VDSIsContiguousMem : Boolean;
Function VDSIsBiosBit       : Boolean;

Function GetNumberMCBs                    : Byte;
Function GetMCBSeg (Number : Byte)        : Word;
Function GetMCBPSP (Number : Byte)        : Word;
Function GetMCBParent (Number : Byte)     : Word;
Function GetMCBSize (Number : Byte)       : LongInt;
Function GetMCBOwner (Number : Byte)      : String;
Function GetMCBInterrupts (Number : Byte) : String;

Implementation

Uses Dos, DetectGlobal, DetectConstants, DetectDos;

Type PtrRec = record
       seg : Word;
       ofs : Word;
     End;

Var Regs     : Registers;
    EMMArray : Array [$000..$3FF] Of Word;

Function IsExistEms;

Var EMM_Name : String [8];

Begin
  EMM_Name := '        ';
  Regs.AH := $35;
  Regs.AL := $67;
  Intr ($21, Regs);
  Move (Mem [Regs.ES:$0A], EMM_Name[1], 8);
  IsExistEMS := (EMM_Name = 'EMMXXXX0');
End;


Function AllEMSPages;

Begin
  If IsExistEMS Then
    Begin
      Regs.AH := $42;
      Intr ($67, Regs);
      AllEmsPages := Regs.DX;
    End
  Else
    AllEMSPages := 0;
End;


Function FreeEMSPages;

Begin
  If IsExistEms Then
    Begin
      Regs.AH := $42;
      Intr ($67, Regs);
      FreeEMSPages := Regs.BX;
    End
  Else
    FreeEMSPages := 0;
End;


Function GetEMSVersion;

Var
    Temp  : Real;
    Temp2 : String;
    Temp3 : Integer;

Begin
  If IsExistEMS Then
    Begin
      Regs.AH := $46;
      Intr ($67, Regs);
      Temp3 := (Regs.AL and 15) + (Regs.AL shr 4) * 10;

      Temp := Temp3 / 10;
      Str (Temp:1:1, Temp2);
      GetEMSVersion := Temp2;
    End
  Else
    GetEMSVersion := 'Kein EMS vorhanden';
End;


Function GETEmsAddress;

Var Temp : Pointer;

Begin
   Regs.AH := $41;
   Intr ($67, Regs);
   PtrRec (Temp).seg := Regs.BX;
   PtrRec (Temp).ofs := 0;
   GetEmsAddress := Pointer (Temp);
End;


Function GetNumberHandles : Word;

Begin
  If IsExistEMS Then
    Begin
      Regs.AX := $4D00;
      Regs.ES := Seg (EMMArray);
      Regs.DI := Ofs (EMMArray);
      Intr ($67, Regs);
      If Regs.AH = 0 Then GetNumberHandles := Regs.BX
    End
  Else
    GetNumberHandles := 0;
End;


Function GetEMSHandleSize (Handle : Word) : LongInt;

Begin
  If IsExistEMS And (Handle <= GetNumberHandles) Then
    Begin
      Regs.AX := $4D00;
      Regs.ES := Seg (EMMArray);
      Regs.DI := Ofs (EMMArray);
      Intr ($67, Regs);
      For xWord := 1 To Regs.BX Do
        Begin
          If xWord = Handle Then
            Begin
              xLong := LongInt (16) * EMMArray [2 * xWord - 1];
              If xLong > 0 then
                GetEMSHandleSize := xLong;
            End;
        End;
    End
  Else
    GetEMSHandleSize := 0;
End;


Function GetEMSHandleName (Handle : Word) : String;

Var EMMVer  : Byte;
    S       : String;
    EMMName : Array [1..8] Of Char;

Begin
  S := '';
  If IsExistEMS And (Handle <= GetNumberHandles) Then
    Begin
      Regs.AH := $46;
      Intr ($67, Regs);
      EMMver := Regs.AL Shr 4;
      Regs.AX := $4D00;
      Regs.ES := Seg (EMMArray);
      Regs.DI := Ofs (EMMArray);
      Intr ($67, Regs);
      For xWord := 1 To Regs.BX Do
        Begin
          If xWord = Handle Then
            Begin
              xLong := LongInt (16) * EMMArray [2 * xWord - 1];
              If xLong > 0 then
                if EMMver >= 4 then
                  begin
                    Regs.AX := $5300;
                    Regs.DX := EMMArray[2 * xWord - 2];
                    Regs.ES := Seg (EMMname);
                    Regs.DI := Ofs (EMMname);
                    Intr ($67, Regs);
                    If Regs.AH = 0 Then
                      For xWord2 := 1 To 8 Do
                        If EMMName [xWord2] <> #0 Then
                          S := S + EMMname[xWord2];
                  end;
            End;
        End;

    End
  Else
    S := 'falsch';
  GetEMSHandleName := S;
End;


Function IsVCPI;

Var XWord1 : Word;

Begin
  { Erst ab EMS 4.00 }
  Regs.AH:=$43;
  Regs.BX:=1;
  Intr($67, regs);
  If Regs.AH <> 0 then
    IsVCPI := False { keine 16k EMS frei }
  Else
    Begin
      xword1:=Regs.DX; { EMS-Handle }
      Regs.AX:=$DE00;
      Intr($67, regs);
      If Regs.AH <> 0 then
        IsVCPI := False
      Else
        IsVCPI := True;
      Regs.AH:=$45; { Handle lîschen }
      Regs.DX:=xword1;
      Intr($67, regs)
    End;
End;


Function VCPIVersion;

Var xWord1 : Word;

Begin
  If IsVCPI Then
    Begin
      Regs.AH:=$43;
      Regs.BX:=1;
      Intr($67, regs);
      If Regs.AH <> 0 then
         VCPIVersion := 'Brauche min. 16kb freien EMS-Speicher'
      Else
        Begin
          xword1:=Regs.DX; { Handle holen }
          Regs.AX:=$DE00;
          Intr($67, regs);
          If Regs.AH <> 0 then
             VCPIVersion := 'nicht vorhanden'
          Else
            Begin
              VCPIVersion := StrFnByte (Regs.BH) + '.'+ StrFnByte (Regs.BL);
            End;
          Regs.AH:=$45; { Handle lîschen }
          Regs.DX:=xword1;
          Intr($67, regs)
        End;
    End
  Else
    VCPIVersion := 'nicht vorhanden';
End;


Function IsExtMemBIOS;

Begin
  Regs.AH:=$88;
  Regs.Flags:=Regs.Flags and FCarry;
  Intr($15, Regs);
  If (FCarry And Regs.Flags) = 0 then
    If LongInt (Regs.AX) Shl 10 = 0 Then IsExtMemBIOS := False
      Else IsExtMemBios := True
  Else
    IsExtMemBIOS := False;
End;


Function BiosFreeEXT;

Begin
  Regs.AH:=$88;
  Regs.Flags:=Regs.Flags and FCarry;
  Intr($15, Regs);
  If (FCarry And Regs.Flags) = 0 then
    BiosFreeExt := Longint(Regs.AX) Shl 10
  Else
    BiosFreeExt := 0;
End;

{ Die folgende Prozedur ist intern und wird fÅr diverse XMS-Zugriffe be-
  nîtigt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! }

Function XMSManagerAddress : Pointer;

Begin
  Regs.AX:=$4310;
  Intr($2F, Regs);
  XMSManagerAddress:= Ptr (Regs.ES, Regs.BX);
End;


Function IsExtMemDriv;

Begin
  Regs.AH := $43;
  Regs.AL := $00;
  Intr ($2f, Regs);
  If Regs.AL = $80 Then IsExtMemDriv := True Else
    IsExtMemDriv := False;
End;


Function XMSVersion;

Var Temp1 : Word;
    Temp2 : Pointer;

Begin
  If Not IsExtMemDriv Then
    Begin
      XMSVersion := 'nicht vorhanden';
      Exit;
    End;
  Regs.AX := 0;

  Temp1 := Regs.AX;
  Temp2 := XMSManagerAddress;
  Asm
    Mov AX, Temp1
    Call Temp2
    Mov Temp1,AX
  End;
  Regs.AX := Temp1;


  if Regs.AX <> 0 then
    Begin
      XMSVersion := BcdWordToString(Regs.AX);
    End
  Else
    XMSVersion := 'Fehler';
End;


Function XMMVersion;

Var Temp1 : Word;
    Temp2 : Pointer;

Begin
  If Not IsExtMemDriv Then
    Begin
      XMMVersion := 'nicht vorhanden';
    End;

  If Not IsExtMemDriv Then Exit;

  Regs.AX := 0;
  Temp1 := Regs.AX;
  Temp2 := XMSManagerAddress;

  Asm
    Mov AX, Temp1
    Call Temp2
    Mov Temp1, BX
  End;
  Regs.BX := Temp1;


  if Regs.BX <> 0 then
    Begin
      XMMVersion := BcdWordToString(Regs.BX);
    End
  Else
    XMMVersion := 'Fehler';
End;


Function XMSMemory;

Var Temp1 : Word;
    Temp2 : Pointer;
    Temp3 : Word;
    Temp4 : Word;

Begin

  Temp2 := XMSManagerAddress;
  Asm
    Mov AX,0800h
    Call Temp2
    Mov Temp1,AX
    Mov Temp3,BX
    Mov Temp4,DX
  End;
  Regs.AX := Temp1;
  Regs.BX := Temp3;
  Regs.BH := Hi(Temp3);
  Regs.BL := Lo(Temp3);
  Regs.DX := Temp4;


  If (Regs.AX <> 0) or ((Regs.AX = 0) and ((REGS.BL = 0) or (Regs.BL = $A0))) then
    Begin
      XMSMemory := Regs.DX;
    End
  Else
    XMSMemory := 0;
End;


Function XMSFreeMemory;

Var Temp1 : Word;
    Temp2 : Pointer;
    Temp3 : Word;

Begin
  Temp2 := XMSManagerAddress;
  Asm
    Mov AX, 0800h
    Call Temp2
    Mov Temp1,AX
    Mov Temp3,BX
  End;
  Regs.AX := Temp1;
  Regs.BX := Temp3;


  If (Regs.AX <> 0) or ((Regs.AX = 0) and ((Regs.BL = 0) or (Regs.BL = $A0))) then
    Begin
      XMSFreeMemory := Regs.AX;
    End
  Else
    XMSFreeMemory := 0;
End;


Function A20Status;

Var Temp1 : Word;
    Temp2 : Pointer;
    Temp3 : Word;

Begin

  Temp2 := XMSManagerAddress;
  Asm
    Mov AX, 0700h
    Call Temp2
    Mov Temp1,AX
    Mov Temp3,BX
  End;
  Regs.AX := Temp1;
  Regs.BX := Temp3;


  If (Regs.AX <> 0) Or ((Regs.AX = 0) And (Regs.BL = 0)) Then
    Case Regs.AX of
      0: A20Status := da2Disabled;
      1: A20Status := da2Enabled;
    Else
      A20Status := da2Unknown;
    End
  Else
    A20Status := dalError;
End;


Function IsUMB;

Var Temp1 : Word;
    Temp2 : Pointer;
    Temp3 : Word;

Begin
  Temp2 := XMSManagerAddress;
  Asm
    Mov AX, 1000h
    Mov DX, 1
    Call Temp2
    Mov Temp1,AX
    Mov Temp3,BX
  End;
  Regs.AX := Temp1;
  Regs.BX := Temp3;

  If (Regs.AX = 0) and (Regs.BL <> $B1) then
    IsUMB := False
  Else
    If (Regs.AX = 0) and (Regs.BL = $B1) then
      IsUmb := False { Support ja, verfÅgbar nein }
    Else
      IsUmb := True;
End;


Function UMBLargestBl;

Var Temp1 : Word;
    Temp2 : Pointer;

Begin
  Temp2 := XMSManagerAddress;
  Asm
    Mov AX, 1000h
    Mov DX, 1
    Call Temp2
    Mov AX, 1100h
    Mov DX, BX
    Call Temp2
    Mov AX, 1000h
    Mov DX, 0FFFFh
    Call Temp2
    Mov Temp1, DX
  End;
  Regs.DX := Temp1;


  UmbLargestBl := Regs.DX * Longint(16);
End;


Function IsHMA;

Var Temp1 : Word;
    Temp2 : Pointer;

Begin
  If Not IsExtMemDriv Then
    Begin
      IsHma := False;
    End;

  If Not IsExtMemDriv Then Exit;

  Regs.AX := 0;
  Temp1 := Regs.AX;
  Temp2 := XMSManagerAddress;

  Asm
    Mov AX, Temp1
    Call Temp2
    Mov Temp1, DX
  End;
  Regs.DX := Temp1;

  If Regs.BX = 0 Then IsHma := False Else IsHma := True;
End;


Function HMAStatus;

Var Temp : Pointer;
    Temp2 : Word;
    Temp3 : Word;

Begin
  Regs.AX:=$0100;
  Regs.DX:=$FFFF;


  Temp := XMSManagerAddress;
  Temp2 := Regs.AX;
  Temp3 := Regs.DX;


  Asm
    Mov AX, Temp2
    Mov DX, Temp3
    Call Temp
    Mov Temp2, AX
  End;
  Regs.AX := Temp2;


  If Regs.AX = 0 Then
    HMAStatus := 'benutzt'
  Else
    HMAStatus := 'frei';
End;


Function HMAUsedByDos5;

Begin
  Regs.AH := $30;
  MsDos (Regs);

  if Regs.AL >= 5 then
    begin
      Regs.AX:=$4A01;
      Intr($2F, regs);
      If Regs.BX <> 0 Then HMAUsedByDos5 := True Else HMAUsedByDos5 := False;
    end;
End;


Function HMAFreeDos5;

Begin
  If HMAUsedByDos5 then
    Begin
      Regs.AX:=$4A01;
      Intr($2F, regs);
      HMAFreeDos5 := Regs.BX;
    End;
End;


Function HmaAddressDos5;

Begin
  If HMAUsedByDos5 then
    Begin
      Regs.AX:=$4A01;
      Intr($2F, regs);
      HMAAddressDos5 := Ptr (Regs.ES, Regs.DI);
    End;
End;


Function IsDPMI;

Begin
  Regs.AX:=$1687;
  Intr($2F, regs);
  If Regs.AX <> 0 then
    IsDPMI := False
  Else
    IsDPMI := True;
End;


Function DPMIVersion;

Begin
  If IsDPMI Then
    Begin
      Regs.AX:=$1687;
      Intr($2F, regs);
      DPMIVersion := StrFnByte (Regs.DH) + '.' + StrFnByte(Regs.DL);
    End
  Else
    DPMIVersion := 'nicht vorhanden';
End;


Function DPMICPU;

Begin
  If IsDPMI Then
    Begin
      Regs.AX:=$1687;
      Intr($2F, regs);
      Case Regs.CL Of
        2: DPMICPU := '286';
        3: DPMICPU := '386';
        4: DPMICPU := '486';
        5: DPMICPU := 'Pentium';
      Else
        DPMICPU := '???'
      End;
    End
  Else
    DPMICPU := 'nicht vorhanden';
End;


Function DPMIModeEntry;

Begin
  If IsDPMI Then
    Begin
      Regs.AX:=$1687;
      Intr($2F, regs);
      DPMIModeEntry := Ptr (Regs.ES, Regs.DI);
     End
  Else
    DPMIModeEntry := Ptr (0,0);
End;


Function CmosBaseMemory;

Var xWord : Word;

Begin
  Port [$70] := $16;
  xWord := Port [$71] Shl 8;
  Port [$70] := $15;
  xWord := xWord + Port [$71];
  CmosBaseMemory := xWord;
End;


Function CmosExtMemory;

Var xWord : Word;

Begin
  Port [$70] := $18;
  xWord := Port [$71] Shl 8;
  Port [$70] := $17;
  xWord := xWord + Port [$71];
  CmosExtMemory := xWord;
End;


Function CmosTotalMem;

Begin
   CmosTotalMem := CmosBaseMemory + CmosExtMemory;
End;


Function IsVDS;

Begin
  Regs.AX := $354B;
  MsDos(regs);
  If (Regs.ES = 0) And (Regs.BX = 0) Then
    IsVDS := False
  Else
    Begin
      Regs.AX := $8102;
      Regs.SI := 0;
      Regs.DI := 0;
      Regs.DX := 0;
      Regs.Flags := Regs.Flags And FCarry;
      Intr ($4B, Regs);
      If ((Regs.Flags And FCarry) = 0) And (Regs.AX <> $8102) Then
        IsVDS := True Else IsVDS := False;
    End;
End;


Function VDSVersion;

Begin
  If IsVDS Then
    Begin
      Regs.AX := $8102;
      Regs.DX := 0;
      Regs.Flags := FCarry;
      Intr ($4B, Regs);
      VDSVersion := StrFnByte(Regs.AH) + '.' + hex(Regs.AL, 2) +
        ' Rev : ' + StrFnByte (Regs.CH) + '.' + hex (Regs.Cl, 2);
    End;
End;


Function VDSProduct;

Begin
  If IsVDS Then
    Begin
      Regs.AX := $8102;
      Regs.DX := 0;
      Regs.Flags := FCarry;
      Intr ($4B, Regs);
      Case Regs.BX Of
        $0000 : VDSProduct := 'QMAPS/HPMM';
        $0001 : VDSProduct := 'EMM386';
        $0003 : VDSProduct := 'Windows 3';
        $0300 : VDSProduct := 'OS/2';
        $0EDC : VDSProduct := 'Novell Dos EMM386';
        $4560 : VDSProduct := '386^Max';
        $4D53 : VDSProduct := 'Memory Commander';
        $5145 : VDSProduct := 'QEMM'
      Else
        VDSProduct := 'Unbekannt, Id ist '+ Hex(Regs.BX,4)+'h';
      End;
    End;
End;


Function VDSMaxDMABSize;

Begin
  If IsVDS Then
    Begin
      Regs.AX := $8102;
      Regs.DX := 0;
      Regs.Flags := FCarry;
      Intr ($4B, Regs);
      VDSMaxDMABSize := (Longint(Regs.SI) * 65536 + Regs.DI) DIV 1024;
    End;
End;


Function VDSTransfersOk;

Begin
  If IsVDS Then
    Begin
      Regs.AX := $8102;
      Regs.DX := 0;
      Regs.Flags := FCarry;
      Intr ($4B, Regs);
      If Regs.DX And 1 = 1 Then
        VDSTransfersOk := 'Nur erster MB'
      Else
        VDSTransfersOk := 'jede Adresse';
    End;
End;


Function VDSIsBuffer1Meg;

Begin
  If IsVDS Then
    Begin
      Regs.AX := $8102;
      Regs.DX := 0;
      Regs.Flags := FCarry;
      Intr ($4B, Regs);
      VDSIsBuffer1Meg := Regs.DX and 2 = 2;
    End;
End;


Function VDSIsAutoRemap;

Begin
  If IsVDS Then
    Begin
      Regs.AX := $8102;
      Regs.DX := 0;
      Regs.Flags := FCarry;
      Intr ($4B, Regs);
      VDSIsAutoRemap := Regs.DX and 4 = 4;
    End;
End;


Function VDSIsContiguousMem;

Begin
  If IsVDS Then
    Begin
      Regs.AX := $8102;
      Regs.DX := 0;
      Regs.Flags := FCarry;
      Intr ($4B, Regs);
      VDSIsContiguousMem := Regs.DX and 8 = 8;
    End;
End;


Function VDSIsBIOSBit;

Begin
  If IsVDS Then
    Begin
      Regs.AX := $8102;
      Regs.DX := 0;
      Regs.Flags := FCarry;
      Intr ($4B, Regs);
      VDSIsBiosBit := Mem[$40:$7B] and $20 = $20;
    End;
End;


Function GetNumberMCBs;

Begin
  Regs.AH := $52;
  MsDos (Regs);

  xWord1 := MemW [Regs.ES : Regs.BX - $0002];
  xBool  := False;
  xByte2 := 0;

  Repeat
    xByte := Mem [xWord1 : $0000];
    Inc (xByte2);

    Case xByte Of
      $4D : Begin
              xWord4 := MemW [xword1 : $0003];
              Inc (xWord1, 1 + xWord4);
            End;
      $5A : xBool := True;
    Else
      xBool := true
    End
  Until xBool;

  GetNumberMCBs := xByte2;
End;


Function GetMCBSeg;

Begin
  If (Not (Number = 0)) Or (Not (GetNumberMCBs < Number)) Then
    Begin
      Regs.AH := $52;
      MsDos (Regs);

      xWord1 := MemW [Regs.ES : Regs.BX - $0002];
      xBool  := False;
      xByte2 := 0;

      Repeat
        xByte := Mem [xWord1 : $0000];
        Inc (xByte2);

        Case xByte Of
          $4D : Begin
                  xWord4 := MemW [xword1 : $0003];
                  If Number = xByte2 Then
                    Begin
                      GetMCBSeg := xWord1;
                      xBool := True;
                    End;
                  Inc (xWord1, 1 + xWord4);
                End;
          $5A : Begin
                  If Number = xByte2 Then
                    GetMCBSeg := xWord1;
                  xBool := True;
                End;
        Else
          xBool := true
        End
      Until xBool;
    End;
End;


Function GetMCBPSP;

Begin
  If (Not (Number = 0)) Or (Not (GetNumberMCBs < Number)) Then
    Begin
      Regs.AH := $52;
      MsDos (Regs);

      xWord1 := MemW [Regs.ES : Regs.BX - $0002];
      xBool  := False;
      xByte2 := 0;

      Repeat
        xByte := Mem [xWord1 : $0000];
        xword2 := MemW [xword1 : $0001];

        Inc (xByte2);

        Case xByte Of
          $4D : Begin
                  xWord4 := MemW [xword1 : $0003];
                  If Number = xByte2 Then
                    Begin
                      GetMCBPSP := xWord2;
                      xBool := True;
                    End;
                  Inc (xWord1, 1 + xWord4);
                End;
          $5A : Begin
                  If Number = xByte2 Then
                    GetMCBPSP := xWord2;
                  xBool := True;
                End;
        Else
          xBool := true
        End
      Until xBool;
    End;
End;


Function GetMCBParent;

Begin
  If (Not (Number = 0)) Or (Not (GetNumberMCBs < Number)) Then
    Begin
      Regs.AH := $52;
      MsDos (Regs);

      xWord1 := MemW [Regs.ES : Regs.BX - $0002];
      xBool  := False;
      xByte2 := 0;

      Repeat
        xByte := Mem [xWord1 : $0000];
        xword2 := MemW [xWord1 : $0001];
        xword3 := MemW [xWord2 : $0016];

        Inc (xByte2);

        Case xByte Of
          $4D : Begin
                  xWord4 := MemW [xword1 : $0003];
                  If Number = xByte2 Then
                    Begin
                      GetMCBParent := xWord3;
                      xBool := True;
                    End;
                  Inc (xWord1, 1 + xWord4);
                End;
          $5A : Begin
                  If Number = xByte2 Then
                    GetMCBParent := xWord3;
                  xBool := True;
                End;
        Else
          xBool := true
        End
      Until xBool;
    End;
End;


Function GetMCBSize;

Begin
  If (Not (Number = 0)) Or (Not (GetNumberMCBs < Number)) Then
    Begin
      Regs.AH := $52;
      MsDos (Regs);

      xWord1 := MemW [Regs.ES : Regs.BX - $0002];
      xBool  := False;
      xByte2 := 0;

      Repeat
        xByte  := Mem  [xWord1 : $0000];
        xword2 := MemW [xWord1 : $0001];
        xword3 := MemW [xWord2 : $0016];

        Inc (xByte2);

        Case xByte Of
          $4D : Begin
                  xWord4 := MemW [xword1 : $0003];
                  If Number = xByte2 Then
                    Begin
                      GetMCBSize := LongInt(xWord4) Shl 4;
                      xBool := True;
                    End;
                  Inc (xWord1, 1 + xWord4);
                End;
          $5A : Begin
                  Intr ($12, Regs);
                  xWord4 := (LongInt (Regs.AX) Shl 10) Shr 4 - xWord1 - 1;
                  If Number = xByte2 Then
                    GetMCBSize := LongInt (xWord4) Shl 4;
                  xBool := True;
                End;
        Else
          xBool := true
        End
      Until xBool;
    End;
End;


Function GetMCBOwner;

  Function MCBOwner : String;
  var
    xstring:string64;
  Begin
    xWord := MemW [xWord2:$002C];
    EndString := '?';

    xString := GetDosVersion;
    If xWord2 = $0008 Then
      If xString[1] = '5' Then
        If MemW [xWord1:8] = $4353 Then
          EndString := 'DOS Code'
        Else
          If MemW [xWord1:8] = $4453 Then
            EndString := 'DOS Daten'
          Else
            EndString := 'DOS'
      Else
        EndString := 'DOS'
    Else
      If xWord2 = $0006 Then
        EndString := 'DRDOS UMB'
      Else
        If xWord2 = $0007 Then
          xString := 'DRDOS UMB-Loch'
    Else
      If xWord2 = xWord3 Then
        Begin
          Regs.AX := $D44D;
          Regs.BX := 0;
          Intr ($2F, Regs);
          If Regs.AX = $44DD Then
            EndString := '4DOS.COM'
          Else
            Begin
              Regs.AX := $E44D;
              Regs.BX := 0;
              Intr ($2F, Regs);
              If Regs.AX = $44EE Then
                EndString := 'NDOS.COM'
              Else
                EndString := 'COMMAND.COM';
              End
            End
      Else
        If (xWord2 = $0000) Then
          EndString := 'freier Speicher'
        Else
          Begin
            xWord5 := 0;
            While MemW [xWord:xWord5] > $0000 Do Inc (xWord5);
            Inc(xWord5, 4);
            EndString := '';
            xBool2 := False;

            Repeat
              xChar := Chr(Mem[xWord:xWord5]);
              If xChar In [' '..'~'] Then
                Begin
                  If xChar In ['\','/'] Then
                    EndString := ''
                  Else
                    EndString := EndString + xChar;
                  Inc(xWord5)
                End
              Else
                Begin
                  xBool2 := True;
                  If xChar > #0 Then EndString := ''
                End
            Until xBool2;
          End;
    MCBOwner := EndString;
  End;

Begin
  If (Not (Number = 0)) Or (Not (GetNumberMCBs < Number)) Then
    Begin
      Regs.AH := $52;
      MsDos (Regs);

      xWord1 := MemW [Regs.ES : Regs.BX - $0002];
      xBool  := False;
      xByte2 := 0;

      Repeat
        xByte  := Mem  [xWord1 : $0000];
        xword2 := MemW [xWord1 : $0001];
        xword3 := MemW [xWord2 : $0016];

        Inc (xByte2);

        Case xByte Of
          $4D : Begin
                  xWord4 := MemW [xword1 : $0003];
                  If Number = xByte2 Then
                    Begin
                      GetMCBOwner := MCBOwner;
                      xBool := True;
                    End;

                  Inc (xWord1, 1 + xWord4);
                End;
          $5A : Begin
                  Intr ($12, Regs);
                  xWord4 := (LongInt (Regs.AX) Shl 10) Shr 4 - xWord1 - 1;
                  If Number = xByte2 Then GetMCBOwner := MCBOwner;
                  xBool := True;
                End;
        Else
          xBool := true
        End
      Until xBool;
    End;
End;


Function GetMCBInterrupts;

  Function MCBInterrupts : String;

  Begin
    EndString := '';
    xLong := Longint (xWord4) Shl 4;
    If xWord1 + 1 = xWord2 Then
      Begin
        xLong2 := LongInt (xWord2) Shl 4;
        For xByte3 := $00 To $FF Do
          Begin
            GetIntVec (xByte3, xPointer);
            xLong3 := LongInt (xPointer) And $FFFF0000 Shr 12 +
                      LongInt (xPointer) And $0000FFFF;
            If (xLong2 <= xLong3) And (xLong3 <= xLong2 + xLong) Then
              EndString := EndString + Hex (xByte3, 2) + 'h ';
          End
      End;
    MCBInterrupts := EndString;
  End;

Begin
  If (Not (Number = 0)) Or (Not (GetNumberMCBs < Number)) Then
    Begin
      Regs.AH := $52;
      MsDos (Regs);

      xWord1 := MemW [Regs.ES : Regs.BX - $0002];
      xBool  := False;
      xByte2 := 0;

      Repeat
        xByte  := Mem  [xWord1 : $0000];
        xword2 := MemW [xWord1 : $0001];
        xword3 := MemW [xWord2 : $0016];

        Inc (xByte2);

        Case xByte Of
          $4D : Begin
                  xWord4 := MemW [xword1 : $0003];
                  If Number = xByte2 Then
                    Begin
                      GetMCBInterrupts := MCBInterrupts;
                      xBool := True;
                    End;
                  Inc (xWord1, 1 + xWord4);
                End;
          $5A : Begin
                  Intr ($12, Regs);
                  xWord4 := (LongInt (Regs.AX) Shl 10) Shr 4 - xWord1 - 1;
                  If Number = xByte2 Then GetMCBInterrupts := MCBInterrupts;
                  xBool := True;
                End;
        Else
          xBool := true
        End
      Until xBool;
    End;
End;


Begin
End.