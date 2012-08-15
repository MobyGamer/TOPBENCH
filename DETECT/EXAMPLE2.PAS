Unit Example2;

{$I DETECT.INC} { Damit das ganze auch richtig kompiliert wird ... }

Interface

Procedure BiosWindow4;
Procedure ChipWindow;
Procedure ChipWindow2;
Procedure ChipWindow3;
Procedure BusWindow;
Procedure ChipsetWindow;
Procedure KeyboardWindow;
Procedure DevicesWindow;
Procedure HDWindow;
Procedure IDEWindow (D : Char);
Procedure DosWindow;
Procedure EnvironmentWindow;
Procedure MCBWindow;
Procedure DosDevicesWindow;
Procedure MemoryWindow;
Procedure MemoryWindow2;
Procedure MemoryWindow3;
Procedure MemoryWindow4;
Procedure SoundWindow;
Procedure ParaWindow;
Procedure SerialWindow;

Implementation

Uses Dos, Detect, DetectConstants, DetectGlobal, Crt, ExampleGlobal,
     DetectBios, DetectBus;

Var P : pBiosRecord;

Procedure ChipWindow;

Begin
  Rahmen (22,4,79,25,' Chip Informationen ');
  Window (23,5,77,24);

  Write ('CPU   : ');
  Case WhatCPU Of
    dcpUnknown     : xString := 'Unbekannt';
    dcpIn8088      : xString := 'Intel 8088';
    dcpIn8086      : xString := 'Intel 8086';
    dcpIn80C88     : xString := 'Intel 80C88 (CMOS-Ver)';
    dcpIn80C86     : xString := 'Intel 80C86 (CMOS-Ver)';
    dcpNECV20      : xString := 'NEC V20';
    dcpNECV30      : xString := 'NEC V30';
    dcpIn80188     : xString := 'Intel 80188';
    dcpIn80186     : xString := 'Intel 80186';
    dcpIn80286     : xString := 'Intel 80286';
    dcpIn80386     : Begin
                       If Is386PopAdBug Then xString := 'Intel 80386DX mit POPAD-Bug' Else
                         xString := 'Intel 80386DX ohne POPAD-Bug';
                       If Is386MulBug Then xString := xString + ', mit MUL-Bug' Else
                         xString := xString + ', ohne MUL-Bug'
                     End;
    dcpIn80386SX   : Begin
                       If Is386PopAdBug Then xString := 'Intel 80386SX mit POPAD-Bug' Else
                                    xString := 'Intel 80386SX ohne POPAD-Bug';
                       If Is386MulBug Then xString := xString + ', mit MUL-Bug' Else
                         xString := xString + ', ohne MUL-Bug'
                     End;
    dcpC_T38600DX  : Begin
                       If Is386PopAdBug Then xString := 'C&T 80386DX mit POPAD-Bug' Else
                                    xString := 'C&T 80386DX ohne POPAD-Bug';
                       If Is386MulBug Then xString := xString + ', mit MUL-Bug' Else
                         xString := xString + ', ohne MUL-Bug'
                     End;
    dcpC_T38600SX  : Begin
                       If Is386PopAdBug Then xString := 'C&T 80386SX mit POPAD-Bug' Else
                                    xString := 'C&T 80386SX ohne POPAD-Bug';
                       If Is386MulBug Then xString := xString + ', mit MUL-Bug' Else
                         xString := xString + ', ohne MUL-Bug'
                     End;
    dcp486DLC      : xString := '486DLC';
    dcp486SLC      : xString := '486SLC';
    dcpInRapidCAD  : xString := 'Intel RapidCad';
    dcpIn80486     : xString := 'Intel 80486DX';
    dcpIn80486SX   : xString := 'Intel 80486SX';
    dcpInPentium   : If IsP5FDivBug Then xString := 'Intel Pentium mit FDIV-Bug'
                          Else xString := 'Intel Pentium ohne FDIV-Bug';
    dcpNexGen      : xString := 'Nexgen';
    dcpVarCyrix    : xString := CyrixID;
  End;
  WriteLn (xString);

  Write ('Kopro : ');
  Case WhatCoPro of
      dndNone         : xString := 'kein Koprozessor';
      dndEmulViaInt7  : xString := 'Emuliert via Int 7';
      dndIn8087       : xString := 'Intel 8087';
      dndIn80C187     : xString := 'Intel 80C187';
      dndIn80287      : xString := 'Intel 80287';
      dndIn80287XL    : xString := 'Intel 80287XL';
      dndIn80387      : xString := 'Intel 80387';
      dndIn80387sx    : xString := 'Intel 80387sx';
      dndIIT2C87      : xString := 'IIT 2C87';
      dndIIT3C87      : xString := 'IIT 3C87';
      dndIIT3C87sx    : xString := 'IIT 3C87sx';
      dndCyr82S87Old  : xString := 'Cyrix 82S87 (alte Ver.)';
      dndCyr34D87     : xString := 'Cyrix 34D87';
      dndCyr83S87Old  : xString := 'Cyrix 83S87 (alte Ver.)';
      dndULSI83C87    : xString := 'ULSI 83C87';
      dndULSI83S87    : xString := 'ULSI 83S87';
      dndC_T38700DX   : xString := 'C&T 38700dx';
      dndC_T38700SX   : xString := 'C&T 38700sx';
      dndIn80387dx    : xString := 'Intel 387dx';
      dndInRapidCAD   : xString := 'Intel RapidCad';
      dndIn486        : xString := 'Intel 486 Built-In';
      dndCyr82S87new  : xString := 'Cyrix 82S87 (neue Ver.)';
      dndCyr387pl     : xString := 'Cyrix 387+';
      dndCyr83S87new  : xString := 'Cyrix 83S87 (neue Ver.)';
      dndCyrEMC87     : xString := 'Cyrix EMC87';
      dndInPentium    : If IsP5FDivBug Then xString := 'Intel Pentium FPU mit FDIV-Bug'
                          Else xString := 'Intel Pentium FPU ohne FDIV-Bug';
      dndUnknown      : xString := 'unbekannt';
  Else
    xString := 'unbekannt'
  End;
  WriteLn (xString);



  If WhatCoPro > 0 Then
    Begin
      WriteLn ('  Koprozessor-Rundung   : ', CoProRounding);
      WriteLn ('  Koprozessor-PrÑzision : ', CoProPrecision,' Bits (0 = reserviert)');
    End;

  WriteLn ('Koprozessorflag (Bios)     : ', Cross(Lo(pBios^.Equipment) And 2 = 2));
  Write ('Weitek                     : ');

  If WhatCPU > dcpIn80286 Then           { erst ab 386 }
    Case WhatWeitek of
      dwtnoWeitek    : xString := 'Nein';
      dwtWeitek      : xString := 'Ja, normaler Weitek';
      dwtWeitek_real : xString := 'Ja, Real-Weitek';
    End
  Else
    xString := 'nicht mîglich';
  WriteLn (xString);

  Write ('CPU-Reset-Id               : ');
  If WhatCPU > dcpIn80386 Then
    If Not IsMSWProtMode Then
      Begin
        WriteLn (Hex (CPUReset,4),'h');
      End
    Else
      WriteLn ('Nur im Realmode')
  Else
    WriteLn ('Erst ab 386');

  Write ('CPU-Reset-Id-String        : ');
  If WhatCPU > dcpIn80386 Then
    If Not IsMSWProtMode Then
      Begin
        WriteLn (CPUResetStr);
      End
    Else
      WriteLn ('Nur im Realmode')
  Else
    WriteLn ('Erst ab 386');

  WriteLn ('CPU-Frequenz               : ', (CPUFreq DIV 100), '.', (CPUFreq MOD 100), ' Mhz');
(*  If WhatCopro > 1 Then
    WriteLn ('Koprozessor-Frequenz       : ', CoProFreq:0:0,' Mhz');*)
  WriteLn ('Effektive RAM-WaitStates   : ', WaitStates:0:1);
  WriteLn ('Bus-Breite                 : ', BusWidth, ' Bit');

  WriteLn ('Ist ein CPU-Cache vorh.    : ', Cross(IsCPUCache));
  If IsCPUCache Then
    Begin
      WriteLn ('  Level                    : ', CPUCacheLevel);
      WriteLn ('  First Level KB           : ', CPUCacheKBFirst);
      WriteLn ('  First Level öbertragung  : ', CPUcacheThruFirst:0:1, 'KB/s');
      If CPUCacheLevel = 2 Then
        Begin
          WriteLn ('  Second Level KB          : ', CPUCacheKBSecond);
          WriteLn ('  Second Level öbertragung : ', CPUCacheThruSecond:0:1, 'KB/s');
        End;
    End;
End;


Procedure ChipWindow2;

Type pByteArray = ^tByteArray;
     tByteArray = Array [1 .. 6] Of Byte;

Var TempReal: Real;
    p : Pointer;
    pBA : pByteArray;

Begin
  Rahmen (22,4,79,25,' Chip Informationen Fenster 2 ');
  Window (23,5,77,24);

  WriteLn ('Computertyp                : ', MashineType);
  WriteLn ('Wird DMA Channel 3 benutzt : ', Cross (IsDMAChannel3));
  WriteLn ('Ist Slave 8259 eingebaut   : ', Cross (IsSlave8259));
  WriteLn ('Ist (CMOS) eingebaut       : ', Cross (IsRealClock));
  If WhatCPU > 5 { erst ab 80286 } Then
    Begin
      WriteLn ('Mashine Status Word        : ',hex(WhatMSW,4),'h');
      WriteLn (' Protected Mode Bit        : ',Cross(IsMSWProtMode));
      WriteLn (' Monitor Koprozessor Bit   : ',Cross(IsMSWMonCoPro));
      WriteLn (' Koprozessor-Emulation Bit : ',Cross(IsMSWEmuCoPro));
      TempReal := WhatGDT;
      p := @TempReal;
      pBA := p;
      WriteLn ('GDT                        : ',hex(pBA^[1],2),' ',
               hex(pBA^[2],2),' ',hex(pBA^[3],2),' ',hex(pBA^[4],2),' ',
               hex(pBA^[5],2),' ',hex(pBA^[6],2));

      TempReal := WhatIDT;
      p := @TempReal;
      pBA := p;
      WriteLn ('IDT                        : ',hex(pBA^[1],2),' ',
               hex(pBA^[2],2),' ',hex(pBA^[3],2),' ',hex(pBA^[4],2),' ',
               hex(pBA^[5],2),' ',hex(pBA^[6],2));
    End
  Else
    Writeln ('Prozessortyp zu klein um MSW, IDT und GDT auszulesen !');
End;


Procedure ChipWindow3;

  Function ChangeStr (S : String) : String;

  Begin
    ChangeStr[1] := S[4];
    ChangeStr[2] := S[3];
    ChangeStr[3] := S[2];
    ChangeStr[4] := S[1];
    ChangeStr[0] := #4;
  End;


  Function CacheType (B : Byte) : String;

  Begin
    Case B Of
      $00 : CacheType := 'kein Cache';
      $01 : CacheType := 'Instruction TLB, 4k Pages, 4fach assoziativ, 64 EintrÑge';
      $02 : CacheType := 'Instruction TLB, 4m Pages, 4fach assoziativ, 4 EintrÑge';
      $03 : CacheType := 'Data TLB, 4k Pages, 4fach assoziativ, 64 EintrÑge';
      $04 : CacheType := 'Data TLB, 4m Pages, 4fach assoziativ, 8 EintrÑge';
      $06 : CacheType := 'Instruction Cache, 8k, 44fach assoziativ, 32Byte Line Size';
      $0A : CacheType := 'Data Cache, 8k, 2fach assoziativ, 32Byte Line Size';
      $41 : CacheType := 'Unified Cache, 32 Byte Cache Line, 4fach assoziativ, 128k';
      $42 : CacheType := 'Unified Cache, 32 Byte Cache Line, 4fach assoziativ, 256k';
      $43 : CacheType := 'Unified Cache, 32 Byte Cache Line, 4fach assoziativ, 512k';
    Else
      CacheType := 'unbekannt (' + StrFnByte (B) + ')';
    End;
  End;

Var CPUId          : pCPUId;
    ShowDualSystem : Boolean;

Begin
  Rahmen (22,4,79,25,' CPUId Informationen ');
  Window (23,5,77,23);

  ShowDualSystem := True;

  If IsCPUID Then
    Begin
      CPUId := TestCPUId;
      WriteLn ('Hersteller  : ', CPUId^.CopyRight);
      WriteLn ('  VendorId  : ', CPUId^.VendorID);
      Write ('Familie     : ', CPUId^.Family, ' (');
      Case CPUId^.Family Of
        4 : Begin
              WriteLn ('486''er)');
              If CPUId^.VendorId = 'GenuineIntel' Then
                Case CPUId^.Model Of
                  0 : EndString := 'Intel 80486 DX';
                  1 : EndString := 'Intel 80486 DX50';
                  2 : EndString := 'Intel 80486 SX';
                  3 : EndString := 'Intel 80486 DX2';
                  4 : EndString := 'Intel 80486 SL';
                  5 : EndString := 'Intel 80486 SX2';
                  7 : EndString := 'Intel 80486 DX2WB';
                  8 : EndString := 'Intel 80486 DX4';
                  9 : EndString := 'Intel 80486 DX4WB';
                Else
                  EndString := 'unbekannter Intel 80486';
                End
              Else If CPUId^.VendorId = 'UMC UMC UMC ' Then
                Case CPUId^.Model Of
                  1 : EndString := 'UMC U5D';
                  2 : EndString := 'UMC U5S';
                Else
                  EndString := 'unbekannter UMC 486';
                End
              Else If CPUID^.VendorId = 'AuthenticAMD' Then
                Case CPUId^.Model Of
                  3  : EndString := 'AMD 486DX2';
                  7  : EndString := 'AMD 486DX2WB';
                  8  : EndString := 'AMD 486DX4';
                  9  : EndString := 'AMD 486DX4WB';
                 $0E : EndString := 'AMD 5x86 (WT)';
                 $0F : EndString := 'AMD 5x86 (WB)';
                Else
                  EndString := 'unbekannter AMD 486';
                End
              Else If CPUID^.VendorId = 'CyrixInstead' Then
                Case CPUId^.Model Of
                  9   : EndString := 'Cyrix Cx5x86';
                  $1F : EndString := 'Cyrix Cx486DX4';
                  $2D : EndString := 'Cyrix Cx5x86';
                  $81 : EndString := 'Texas Instruments TI486DX4';
                Else
                  EndString := 'Unbekannter Cyrix'
                End;
              WriteLn ('  Prozessor : ', EndString);
            End;
        5 : Begin
              WriteLn ('Pentium)');

              If CPUId^.VendorId = 'GenuineIntel' Then
                Begin
                  EndString := 'Pentium ';
                  Case CPUId^.Model Of
                    0 : EndString := EndString + '60/66 Mhz 5V A-Step';
                    1 : Begin
                          EndString := EndString + '60/66 Mhz 5V';
                          Case CPUID^.Stepping Of
                            3 : EndString := EndString + ' (B1-Maske)';
                            5 : EndString := EndString + ' (C1-Maske)';
                            7 : EndString := EndString + ' (B1-Maske)';
                          End;
                        End;
                    2 : Case CPUId^.Stepping Of
                          1  : EndString := EndString + '75-100 Mhz (B1-Maske)';
                          2  : EndString := EndString + '75-100 Mhz (B3-Maske)';
                          4  : EndString := EndString + '75-120 Mhz (B5-Maske)';
                          5  : EndString := EndString + '75-133 Mhz (C2-Maske)';
                          11 : EndString := EndString + '120-133 Mhz';
                          12 : EndString := EndString + '150/166 Mhz (cC0-Maske)';
                        Else
                          EndString := EndString + '75-166 Mhz';
                        End;
                    3 : Case CPUId^.Stepping Of
                          1 : EndString := EndString + ' Overdrive P24T 63';
                          2 : EndString := EndString + ' Overdrive P24T 83';
                        End;
                    4 : EndString := EndString + 'Overdrive fÅr 3.3V (P54T)';
                    5 : EndString := EndString + 'Overdrive fÅr 80486DX4';
                    6 : EndString := EndString + 'Overdrive fÅr 5V (P5T)';
                  Else
                    EndString := 'unbekannter Intel Pentium';
                  End;
                  WriteLn ('  Prozessor : ', EndString);
                  WriteLn ('  Stepping  : ', CPUId^.Stepping, ' (auch als ', Chr (64+CPUId^.Stepping),'-Maske bekannt)');
                  Write ('  Typ       : ');
                  Case CPUId^.Typ Of
                    0 : WriteLn ('Original OEM Prozessor');
                    1 : WriteLn ('Pentium Overdrive');
                    2 : WriteLn ('Dual Pentium CPU (90 oder 100 MHz)');
                    3 : WriteLn ('Reserviert');
                  End;
                End
              Else If CPUId^.VendorId = 'AuthenticAMD' Then
                Begin
                  EndString := 'AMD ';
                  Case CPUId^.Model Of
                    0 : EndString := EndString + ' 5k86 SSA/5';
                    1 : EndString := EndString + ' 5k86';
                    6 : EndString := EndString + ' 6k86'
                  Else
                    EndString := EndString + ' (unbekannter Typ)';
                  End;
                  WriteLn ('Prozessor : ', EndString);
                End
              Else If CPUId^.VendorId = 'NexGenDriven' Then
                Begin
                  EndString := 'NexGen Nx5x86';
                  Case CPUId^.Model Of
                    0 : If CPUId^.Stepping = 4 Then EndString := EndString +
                        ' 100' Else If CPUId^.Stepping = 6 Then EndString :=
                        EndString + ' 120 (E2/C0 Maske)';
                  Else
                    EndString := ' (unbekannter Typ)';
                  End;
                  WriteLn ('Prozessor : ', EndString);
                End
              Else If CPUId^.VendorId = 'CyrixInstead' Then
                Begin
                  Case CPUId^.Model Of
                    2, 3 : EndString := 'Cyrix Cx6x86';
                  Else
                    EndString := 'Cyrix Cx6x86 (unbekannter Typ)';
                  End;
                  WriteLn ('Prozessor : ', EndString);
                End;
            End;
        6 : Begin
              WriteLn ('PentiumPro)');
              EndString := 'PentiumPro ';
              Case CPUId^.Model Of
                0 : EndString := EndString + 'A-Step';
                1 : Case CPUId^.Stepping Of
                      0 : EndString := EndString + ' 133';
                      1 : EndString := EndString + ' 150 (B0-Maske)';
                      2 : EndString := EndString + ' 150 (C0-Maske)';
                      6 : EndString := EndString + ' 166-200 (sA0 Maske)';
                      7 : EndString := EndString + ' 166-200 (sA1 Maske)';
                    Else
                      EndString := EndString + ' (unbekannt)';
                    End;
                4 : EndString := EndString + 'P55CT iP54C Socket Overdrive';
              Else
                EndString := 'Unbekannter Intel PentiumPro';
              End;
              WriteLn ('  Prozessor : ', EndString);
              WriteLn ('  Stepping  : ', CPUId^.Stepping);
              Write ('  Typ       : ');
              Case CPUId^.Typ Of
                0 : WriteLn ('Original OEM Prozessor');
                1 : WriteLn ('PPro Overdrive');
                2 : WriteLn ('2. Dual PPro CPU (90 oder 100 MHz)');
                3 : WriteLn ('Reserviert');
              End;
              If CPUId^.Cache1[3] = 1 Then
                Begin
                  WriteLn ('Caches : ');
                  If CPUId^.Cache1[0] <> 0 Then WriteLn (' ', CacheType (CPUId^.Cache1[0]));
                  If CPUId^.Cache1[1] <> 0 Then WriteLn (' ', CacheType (CPUId^.Cache1[1]));
                  If CPUId^.Cache1[2] <> 0 Then WriteLn (' ', CacheType (CPUId^.Cache1[2]));
                  If CPUId^.Cache2[0] <> 0 Then WriteLn (' ', CacheType (CPUId^.Cache2[0]));
                  If CPUId^.Cache2[1] <> 0 Then WriteLn (' ', CacheType (CPUId^.Cache2[1]));
                  If CPUId^.Cache2[2] <> 0 Then WriteLn (' ', CacheType (CPUId^.Cache2[2]));
                  If CPUId^.Cache2[3] <> 0 Then WriteLn (' ', CacheType (CPUId^.Cache2[3]));
                  If CPUId^.Cache3[0] <> 0 Then WriteLn (' ', CacheType (CPUId^.Cache3[0]));
                  If CPUId^.Cache3[1] <> 0 Then WriteLn (' ', CacheType (CPUId^.Cache3[1]));
                  If CPUId^.Cache3[2] <> 0 Then WriteLn (' ', CacheType (CPUId^.Cache3[2]));
                  If CPUId^.Cache3[3] <> 0 Then WriteLn (' ', CacheType (CPUId^.Cache3[3]));
                  If CPUId^.Cache4[0] <> 0 Then WriteLn (' ', CacheType (CPUId^.Cache4[0]));
                  If CPUId^.Cache4[1] <> 0 Then WriteLn (' ', CacheType (CPUId^.Cache4[1]));
                  If CPUId^.Cache4[2] <> 0 Then WriteLn (' ', CacheType (CPUId^.Cache4[2]));
                  If CPUId^.Cache4[3] <> 0 Then WriteLn (' ', CacheType (CPUId^.Cache4[3]));
                End;
            End;
      End;

      WriteLn;
      WaitKey;
      ClrScr;

      WriteLn ('Flags       : ');
      WriteLn ('  CMPXCHG8B unterstÅtzt          : ', Cross (CPUId^.Features And dcuCMPXCHG8b = dcuCMPXCHG8B));
      WriteLn ('  Mashine Exception unterstÅtzt  : ', Cross (CPUId^.Features And dcuMException = dcuMException));
      WriteLn ('  Pentium-MSR''s unterstÅtzt      : ', Cross (CPUId^.Features And dcuPentiumMSR = dcuPentiumMSR));
      WriteLn ('  Addressing Exetensions         : ', Cross (CPUId^.Features And dcuAddressingExt = dcuAddressingExt));
      WriteLn ('  Time Stamp Counter unterstÅtzt : ', Cross (CPUId^.Features And dcuTSCSupp = dcuTSCSupp));
      WriteLn ('  Page Extensions unterstÅtzt    : ', Cross (CPUId^.Features And dcuPageExt = dcuPageExt));
      WriteLn ('  I/O Breakpoints unterstÅtzt    : ', Cross (CPUId^.Features And dcuIOBreaks = dcuIOBreaks));
      WriteLn ('  Enhanced V86 Mode unterstÅtzt  : ', Cross (CPUId^.Features And dcuEnhV86Mode = dcuEnhV86Mode));
      WriteLn ('  Lokaler APIC vorhanden         : ', Cross (CPUId^.Features And dcuLocalAPIC = dcuLocalApic));
      WriteLn ('  Mem-Type Range Register vorh.  : ', Cross (CPUId^.Features And dcuMemTypeRangeReg = dcuMemTypeRangeReg));
      WriteLn ('  Page Global Enable erlaubt     : ', Cross (CPUId^.Features And dcuPageGlobalEn = dcuPageGlobalEn));
      WriteLn ('  Mashine-Check Funktion vorh.   : ', Cross (CPUId^.Features And dcuMashineCheck = dcuMashineCheck));
      WriteLn ('  Befehl CMOVcc vorhanden        : ', Cross (CPUId^.Features And dcuCMOVcc = dcuCMOVcc));
      WriteLn ('  IA MMX-Funktionen unterstÅtzt  : ', Cross (CPUId^.Features And dcuIAMMXSupp = dcuIAMMXSupp));

      If (CPUId^.VendorId = 'AuthenticAMD') And (CPUId^.Model > 1) And (CPUId^.Ext8000_0000EAX <> 0) Then
        Begin
          WriteLn;
          WaitKey;
          ClrScr;
          With CPUID^ Do
            Begin
              xString := ChangeStr (AMDProcName1) + ChangeStr (AMDProcName2) + ChangeStr (AMDProcName3) + ChangeStr
                         (AMDProcName4) + ChangeStr (AMDProcName5) + ChangeStr (AMDProcName6) + ChangeStr
                         (AMDProcName7) + ChangeStr (AMDProcName8) + ChangeStr (AMDProcName9) + ChangeStr
                         (AMDProcName10) + ChangeStr (AMDProcName11) + ChangeStr (AMDProcName12);
            End;
          WriteLn ('AMD-Prozessor Name : ', xString);
          WriteLn ('  Stepping         : ', Hex (CPUId^.Ext8000_0001EAX And $F, 2), 'h');
          WriteLn ('  Model            : ', Hex ((CPUId^.Ext8000_0001EAX Shr 4) And $F, 2), 'h');
          WriteLn ('  Familie/Generat. : ', Hex ((CPUId^.Ext8000_0001EAX Shr 8) And $F, 2), 'h');
          WriteLn ('AMD-Extended-Flags : ');
          WriteLn ('  FPU integriert                 : ', Cross (CPUId^.Ext8000_0001EDX And dcuAmFPU = dcuAmFPU));
          WriteLn ('  Virtual 86 Mode Extensions     : ', Cross (CPUId^.Ext8000_0001EDX And dcuAmVModeExt = dcuAmVModeExt));
          WriteLn ('  Debugging Extensions           : ', Cross (CPUId^.Ext8000_0001EDX And dcuAmDebExt = dcuAmDebExt));
          WriteLn ('  Page Size Extensions           : ', Cross (CPUId^.Ext8000_0001EDX And dcuAmPageExt = dcuAmPageExt));
          WriteLn ('  Time Stamp Counter             : ', Cross (CPUId^.Ext8000_0001EDX And dcuAmTSCSupp = dcuAmTSCSupp));
          WriteLn ('  K86-spezifische MSR''s          : ', Cross (CPUId^.Ext8000_0001EDX And dcuAmK86MSR = dcuAmK86MSR));
          WriteLn ('  Machine Check Exception        : ', Cross (CPUId^.Ext8000_0001EDX And dcuAmMException =
                                                                 dcuAmMException));
          WriteLn ('  CMPXCHG8B                      : ', Cross (CPUId^.Ext8000_0001EDX And dcuAmCMPXCHG8B = dcuAmCMPXCHG8B));
          WriteLn ('  SysCall/SysRet Extensions      : ', Cross (CPUId^.Ext8000_0001EDX And dcuAmSysCallSysRet =
                                                                 dcuAmSysCallSysRet));
          WriteLn ('  Global Paging Extensions       : ', Cross (CPUId^.Ext8000_0001EDX And dcuAmGlobalPagExt =
                                                                 dcuAmGlobalPagExt));
          WriteLn ('  Integer Conditional Move       : ', Cross (CPUId^.Ext8000_0001EDX And dcuAmIntCondMove =
                                                                 dcuAmIntCondMove));
          WriteLn ('  Floating Point Cond. Move      : ', Cross (CPUId^.Ext8000_0001EDX And dcuAmFloatCondMove =
                                                                 dcuAmFloatCondMove));
          WriteLn ('  Multimedia Extensions (MMX)    : ', Cross (CPUId^.Ext8000_0001EDX And dcuAmIAMMXSupp = dcuAmIAMMXSupp));
          WriteLn;
          WaitKey;
          ClrScr;
          WriteLn ('AMD-Caches : ');
          WriteLn ('  Data TLB AssoziativitÑt             : ', CpuId^.AMDCache1[3]);
          WriteLn ('  Data TLB EintrÑge                   : ', CpuId^.AMDCache1[2]);
          WriteLn ('  Instruction TLB AssoziativitÑt      : ', CpuId^.AMDCache1[1]);
          WriteLn ('  Instruction TLB EintrÑge            : ', CpuId^.AMDCache1[0]);
          WriteLn ('  Level 1 Data Grîsse                 : ', CpuId^.AMDCache2[3], 'kb');
          WriteLn ('  Level 1 Data AssoziativitÑt         : ', CpuId^.AMDCache2[2]);
          WriteLn ('  Level 1 Data Lines per Tag          : ', CpuId^.AMDCache2[1]);
          WriteLn ('  Level 1 Data Lines Size             : ', CpuId^.AMDCache2[0], 'b');
          WriteLn ('  Level 1 Instruction Grîsse          : ', CpuId^.AMDCache2[3], 'kb');
          WriteLn ('  Level 1 Instruction AssoziativitÑt  : ', CpuId^.AMDCache2[2]);
          WriteLn ('  Level 1 Instruction Lines per Tag   : ', CpuId^.AMDCache2[1]);
          WriteLn ('  Level 1 Instruction Data Lines Size : ', CpuId^.AMDCache2[0], 'b');
        End;
      FreeMem (CPUId, SizeOf (CPUID^));
    End
  Else
    WriteLn ('CPU-Id Befehl auf diesem Rechner nicht ausfÅhrbar.');
End;


Procedure BusWindow;

Var Slot    : Byte;
    PCIData : PCIHeader;

Begin
  Rahmen (22,4,79,25,' Bus Informationen ');
  Window (23,5,77,23);

  Write ('BUS-Typ                    : ');
  Case BusType Of
    dbuISA     : xString := 'ISA';
    dbuEISA    : xString := 'Extended ISA (EISA)';
    dbuMCA     : xString := 'MicroChannel (MCA)';
    dbuVL      : xString := 'Vesa Local (VL)';
    dbuPCI     : xString := 'PCI';
    dbuUnknown : xString := 'Unbekannt';
  Else
    xString := '???';
  End;
  WriteLn (xString);

  If BusType = dbuEISA Then
    Begin
      WriteLn ('Extrainformationen zu Extended ISA');
      WriteLn ('Diese Funktionen kînnen fÅr jeden Slot abgerufen');
      WriteLn ('werden, sofern die Karte es unterstÅtzt');
      EndIt := False;
      For Count := 0 To $FF Do
        Begin
          If (EISAIsId (Count) = deiYes) Or (EISAIsId (Count) = deiNo) Then
            Begin
              Slot  := Count;
              WriteLn ('Hier wird Slot ', Hex (Count, 4), 'h benutzt.');
              EndIt := True;
            End;
        End;
      If EndIt = False Then
        Begin
          WriteLn ('Leider kein Slot abrufbar');
        End
      Else
        Begin
          Write ('Ist eine ID lesbar       : ');
          Case EISAIsId (Slot) Of
            deiYes : WriteLn ('[X]');
            deiNo  : WriteLn ('[-]');
          End;
          WriteLn ('Slot-Typ                 : ', EISASlotType (Slot));
          WriteLn ('Configuration-Version    : ', EISAConfigVersion (Slot));
          WriteLn ('Configuration-Checksumme : ', EISAConfigCheckSum (Slot));
          WriteLn ('Anzahl der Device Func''s : ', EISANumDevFunc (Slot));
          WriteLn ('Identifikationsnummer    : ', EISAId (Slot));
        End;
    End;

  If BusType = dbuPCI Then
    Begin
      WriteLn;
      WriteLn ('Nummer Hersteller                   Device-ID Revision');
      For xByte2 := 0 To $F Do
        If IsPCIDevice (xByte2, 0) Then
          Begin
            GetPCIConfig (xByte2, 0, PCIData);
            Write (Hex (xByte2,2), 'h    ', GetPCIVendor (PCIData.VendorId));
            GotoXY (37, WhereY);
            Write (Hex (PCIData.DeviceId, 4),'h');
            GotoXY (47, WhereY);
            WriteLn (PCIData.Revision);
          End;

      WriteLn;
      WriteLn ('Device-Klassen : ');
      WriteLn;
      WriteLn ('Nummer Klasse       Sub-Klasse');
      For xByte2 := 0 To $F Do
        If IsPCIDevice (xByte2, 0) Then
          Begin
            GetPCIConfig (xByte2, 0, PCIData);
            Write (' ', Hex (xByte2, 2), 'h : ', IdentifyPCIClass (PCIData.Class1));
            GotoXY (21, WhereY);
            WriteLn (IdentifyPCISubClass  (PCIData.Class1, PCIData.Class2));
          End;
      WriteLn;

      WaitKey;
      ClrScr;

      WriteLn ('Karten-Bezeichnungen : ');
      For xByte2 := 0 To $F Do
        If IsPCIDevice (xByte2, 0) Then
          Begin
            GetPCIConfig (xByte2, 0, PCIData);
            WriteLn ('  ', Hex (xByte2, 2), 'h : ', IdentifyPCIDevice (PCIData.VendorId,
              PCIData.DeviceId, PCIData.Revision));
          End;
    End;
End;


Procedure ChipsetWindow;

Begin
  Rahmen (22,4,79,25,' Chipsatz Informationen ');
  Window (23,5,77,24);

  Case WhichChipset Of
    dchCyrix486dx     : xString := 'Cyrix 486''er Chipsatz';
    dchCyrix486lc     : xString := 'Cyrix 486S/DLC Chipsatz';
    dchCyrix5_6x86    : xString := 'Cyrix M1SC/M1 Chipsatz';
    dchIntelTriton    : xString := 'Intel Triton Chipsatz';
    dchIntelSaturn    : xString := 'Intel Saturn Chipsatz';
    dchIntelMercury   : xString := 'Intel Mercury 82434LX Chipsatz';
    dchIntelNeptun    : xString := 'Intel Neptun 82434NX Chipsatz';
    dchIntelTXC       : xString := 'Intel TXC 82439HX Chipsatz';
    dchIntelPCISet    : xString := 'Intel PCISet 82420EX Chipsatz';
    dchUM82C481A      : xString := 'UMC 82C481A Chipsatz';
    dchUM82C391A      : xString := 'UMC 82C391A Chipsatz';
    dchUMC82C881      : xString := 'UMC 82C881 Chipsatz';
    dchUMC82C881HB4   : xString := 'UMC 82C8881 HB4 Chipsatz';
    dchUMC82C891      : xString := 'UMC 82C891 Chipsatz';
    dchUMC82C8891     : xString := 'UMC 82C8891 Chipsatz';
    dchSiS501         : xString := 'SiS 501/502/503 Chipsatz';
    dchSiS5511        : xString := 'SiS 5511/5512 Chipsatz';
    dchLSIHYDRA       : xString := 'LSI Logic HYDRA Chipsatz (MPI)';
    dchLSIASPEN       : xString := 'LSI Logic ASPEN Chipsatz';
    dchNexGenVL82C500 : xString := 'NexGen VL82C500 Chipsatz';
    dchAcerALIM1451   : xString := 'Acer ALI M1451 Chipsatz';
    dchAcerALIM1461   : xString := 'Acer ALI M1461 Chipsatz';
    dchIMSDiamond     : xString := 'IMS Diamond 5026/5027/5028 Chipsatz';
    dchVIAApollo      : xString := 'VIA Apollo VT82C570MV Chipsatz';
    dchUnknown        : xString := 'Unbekannter Chipsatz';
  End;
  WriteLn ('Chipsatz : ', xString);
End;


Procedure KeyboardWindow;

Begin
  Rahmen (22,4,79,25,' Keyboard Informationen ');
  Window (23,5,77,24);


  Write ('Keyboardtyp                   : ');
  Case KeyboardType of
    dkbXT       : WriteLn ('XT-Tastatur');
    dkbEnhanced : WriteLn ('Erweiterte AT-Tastatur');
  End;

  WriteLn ('Extended Keyboard Support            : ', Cross(ExtKeyboardSupp));
  WriteLn ('Key-Buffer-Start                     : ', '0040h:', Hex(pBios^.KeyBufBegin,4), 'h');
  WriteLn ('Key-Buffer-Ende                      : ', '0040h:', Hex(pBios^.KeyBufEnd,4), 'h');
  WriteLn ('Key-BufferLÑnge (Keystrokes)         : ', KeyBufferLength);

  WriteLn ('Ist Keyboard Intercept verfÅgbar     : ', Cross(IsKeybIntercept));
  WriteLn ('Wird Keyboard Int 16h, Fn 9 unterst. : ', Cross(IsKeyb16_9));
  WriteLn ('Keyboard-Id-Word                     : ', Hex (KeyboardId, 4));
  WriteLn ('Keyboard-Controller                  : ', KeyboardController);
End;


Procedure DevicesWindow;

Var I : Byte;

Begin
  Rahmen (22,4,79,25,' Laufwerksinformationen ');
  Window (23,5,77,24);

  WriteLn ('Diskettenlaufwerke     : ', NumberDrives);
  WriteLn ('Virtuelle Laufwerke    : ', DiskDevices);
  WriteLn ('Erstes Laufwerk        : ', FirstFloppy,':');
  WriteLn ('Aktuelles Bootlaufwerk : ', BootDrive, ':');
  WriteLn ('Verify-Flag            : ', Cross(IsVerify));

  WriteLn;
  WriteLn ('Laufwerk Typ       Entnehmbar Zugriff    ');
  WriteLn ('-----------------------------------------');
  For I := 1 To 26 Do
    Begin
      If IsDevice (Chr (64+I)) Then
        Begin
          Write (Chr (64+I),':       ');
          Case DeviceType (Chr (64+I)) Of
            ddiNoDrive  : Write ('???       ');
            ddiFloppy   : Write ('Floppy    ');
            ddiHard     : Write ('HD        ');
            ddiSubst    : Write ('Subst     ');
            ddiCDRom    : Write ('CD-Rom    ');
            ddiInterLnk : Write ('Interlink ');
            ddiMod      : Write ('MOD       ');
            ddiNet      : Write ('Netzwerk  ');
          End;
          Write (Cross (DeviceRemove (Chr (64+I))),'        ');
          Case DeviceMethod (Chr (64+I)) Of
            ddiLocal  : Write ('Local  ');
            ddiRemote : Write ('Remote ');
            ddiShare  : Write ('Share  ');
          End;
          WriteLn;
        End;
    End;

  WriteLn;
  Write ('MS CD Extension Version (wenn inst.) : ');
  If IsInstalled (MSCDExt) Then WriteLn (WhichVersion (MSCDExt)) Else WriteLn ('[-]');
End;


Procedure HDWindow;

Begin
  Rahmen (22,4,79,25,' Hard Disk Informationen ');
  Window (23,5,77,24);

{$IfnDef NoHd}
  WriteLn ('Cylyinder (BIOS)         : ', HDCylinders (1));
  WriteLn ('Heads (BIOS)             : ', HDHeads (1));
  WriteLn ('Sectors (BIOS)           : ', HDSectors (1));
  WriteLn ('Capacity (BIOS)          : ', HDCapacity (1), ' (',HDCapacity (1) DIV 1048576, ' MB)');
  WriteLn ('Track-Track Zugriffszeit : ', HDTrackSeek(1):6:2, ' ms');
  WriteLn ('Mittlere Zugriffszeit    : ', HDAverageSeek (1):6:2, ' ms');
  WriteLn ('Maximale Zugriffszeit    : ', HDMaximumSeek (1):6:2, ' ms');
{$Else}
  WriteLn ('Wenn sie die Zugriffszeiten- und BIOS-Informationen ');
  WriteLn ('sehen wollen, bitte die Kompilier-Definition NoHd ');
  WriteLn ('entfernen ...');
{$EndIf}
  WriteLn;
  WriteLn ('Transferraten');
  WriteLn ('BlockGrî·e        Read         Write');
  WriteLn ('Geschwindigkeit bei 1 KB Blockgrî·e wird getestet');
  GotoXY (WhereX, WhereY-1);
  WriteLn ('1KB              ', HDTransferRead (1024, 300, 'EXAMPLE$.$$$'):6:0, ' kb/s   ', HDTransferWrite (1024, 300,
    'EXAMPLE$.$$$'):6:0, ' kb/s       ');
  WriteLn ('Geschwindigkeit bei 4 KB Blockgrî·e wird getestet');
  GotoXY (WhereX, WhereY-1);
  WriteLn ('4KB              ', HDTransferRead (4096, 200, 'EXAMPLE$.$$$'):6:0, ' kb/s   ', HDTransferWrite (4096, 200,
    'EXAMPLE$.$$$'):6:0, ' kb/s       ');
  WriteLn ('Geschwindigkeit bei 16 KB Blockgrî·e wird getestet');
  GotoXY (WhereX, WhereY-1);
  WriteLn ('16KB             ', HDTransferRead (16384, 150, 'EXAMPLE$.$$$'):6:0, ' kb/s   ', HDTransferWrite (16384, 150,
    'EXAMPLE$.$$$'):6:0, ' kb/s        ');
  If MaxAvail > 32768 Then
    Begin
      WriteLn ('Geschwindigkeit bei 32 KB Blockgrî·e wird getestet');
      GotoXY (WhereX, WhereY-1);
      WriteLn ('32KB             ', HDTransferRead (32768, 125, 'EXAMPLE$.$$$'):6:0, ' kb/s   ', HDTransferWrite (32768, 125,
        'EXAMPLE$.$$$'):6:0, ' kb/s        ');
    End
  Else
    WriteLn ('Der Heap ist fÅr die 32KB-Messung zu klein.');

  If MaxAvail > 65535 Then
    Begin
      WriteLn ('Geschwindigkeit bei 64 KB Blockgrî·e wird getestet');
      GotoXY (WhereX, WhereY-1);
      WriteLn ('64KB             ', HDTransferRead (65535, 50, 'EXAMPLE$.$$$'):6:0, ' kb/s   ', HDTransferWrite (65535, 50,
        'EXAMPLE$.$$$'):6:0, ' kb/s        ');
    End
  Else
    WriteLn ('Der Heap ist fÅr die 64KB-Messung zu klein.');
End;


Procedure IDEWindow;

  Procedure NewPage;

  Begin
    WriteLn;
    WaitKey;
    ClrScr;
  End;

Begin
  Rahmen (22,4,79,25,' (Extended) IDE Informationen Laufwerk ' + D + ': ');
  Window (23,5,77,23);
  If ATA_PIIsDrive (D) Then
    Begin
      WriteLn ('Informationen fÅr ATA und ATAPI : ');

      WriteLn ('Seriennummer      : ');
      Window (1,1,80,25);
      Window (43,6,77,8);
      WriteLn(TrimString(ATA_PIStrings (D, datSerienNummer)));
      Window (23,5,77,23);
      GotoXY (1,4);

      WriteLn ('Modellnummer      : ');
      Window (1,1,80,25);
      Window (43,8,77,10);
      WriteLn (TrimString(ATA_PIStrings (D, datModellNummer)));
      Window (23,5,77,23);
      GotoXY (1,6);

      WriteLn ('Firmware-Revision : ', TrimString (ATA_PIStrings (D, datFirmRev)));
      WriteLn ('PIO Timing Mode   : ', ATA_PIStrings (D, datPIOTiming));

      WriteLn ('Puffertyp         : ');
      Window (1,1,80,25);
      Window (43,12,77,14);
      WriteLn (ATA_PIStrings (D, datBuffertype));
      Window (23,5,77,23);
      GotoXY (1,10);

      WriteLn ('16-Bit I/O        : ', Cross (ATA_PIBools (D, dat16BitIO)));
      WriteLn ('IORDY-Protokoll   : ', Cross (ATA_PIBools (D, datIsIORDY)));
      WriteLn ('IORDY abschaltbar : ', Cross (ATA_PIBools (D, datIsDisIORDY)));
      WriteLn ('LBA-Protokoll     : ', Cross (ATA_PIBools (D, datIsLBA)));
      WriteLn ('DMA-Zugriff       : ', Cross (ATA_PIBools (D, datIsDMA)));
      WriteLn ('Puffergr/Sektoren : ', ATA_PIWords (D, datPufferGrSek));
      NewPage;

      If ATA_PIBools (D, datIsDMA) Then
        Begin
          WriteLn ('DMA Timing Mode   : ', ATA_PIStrings (D, datDMATiming));
          WriteLn ('Akt SWord DMAMode : ', ATA_PIWords (D, datAktSWDMAM));
          WriteLn ('Unt SWord DMAMode : ', ATA_PIWords (D, datUntSWDMAM));
          WriteLn ('Akt MWord DMAMode : ', ATA_PIWords (D, datAktMWDMAM));
          WriteLn ('Unt MWord DMAMode : ', ATA_PIWords (D, datUntMWDMAM));
        End;

      Case IDEType Of
        datATA   : Begin
                     WriteLn ('ATA-Informationen : ');

                     WriteLn ('Datenrate          : ', ATA_PIStrings (D, datDatenRate));
                     If ATA_PIBools (D, datIsInf) Then
                       WriteLn ('KapazitÑt/Sektoren : ', ATA_PIStrings (D, datKapaInSekt));
                     If ATA_PIBools (D, datIsLBA) Then
                       WriteLn ('Anz. LBA Sektoren  : ', ATA_PIStrings (D, datLBASektoren));
                     WriteLn ('Geschw.Toleranzl.  : ', Cross (ATA_PIBools (D, datGeschw)));
                     WriteLn ('Spurversatz-Option : ', Cross (ATA_PIBools (D, datSpurVersatz)));
                     WriteLn ('DatenT-Ofs-Option  : ', Cross (ATA_PIBools (D, datDatenTakt)));
                     Writeln ('DrTol > 0,5 %      : ', Cross (ATA_PIBools (D, datDrehZahlTol)));
                     Writeln ('FestPlatte         : ', Cross (ATA_PIBools (D, datFestplatte)));
                     WriteLn ('SpindelmotorStrg   : ', Cross (ATA_PIBools (D, datSpindel)));

                     If ATA_PIBools (D, datIsDMA) Then NewPage;

                     WriteLn ('KopfUmsch > 15 Ês  : ', Cross (ATA_PIBools (D, datKopfUmsch)));
                     WriteLn ('MFM-Kodierung      : ', Cross (ATA_PIBools (D, datMFM)));
                     WriteLn ('Soft-sektoriert    : ', Cross (ATA_PIBools (D, datSoftSekt)));
                     WriteLn ('Hard-sektoriert    : ', Cross (ATA_PIBools (D, datHardSekt)));
                     WriteLn ('MultiSektor R/W    : ', Cross (ATA_PIBools (D, datMultiSekt)));

                     If Not ATA_PIBools (D, datIsDMA) Then NewPage;

                     WriteLn ('Zylinder           : ', ATA_PIWords (D, datZylinder));
                     WriteLn ('Herausn. Zylinder  : ', ATA_PIWords (D, datHrsZylinder));
                     WriteLn ('R/W Kîpfe          : ', ATA_PIWords (D, datKoepfe));
                     WriteLn ('Bytes/Spur unform. : ', ATA_PIWords (D, datBytesSpurUnf));
                     WriteLn ('Bytes/Sektor unf.  : ', ATA_PIWords (D, datBytesSekUnf));
                     WriteLn ('Sektoren/Spur      : ', ATA_PIWords (D, datSekSpur));
                     WriteLn ('Max. Multisektor   : ', ATA_PIWords (D, datMultipleSekt));
                     If ATA_PIBools (D, datIsInf) Then
                       Begin
                         WriteLn ('Drive Map : Zyl.   : ', ATA_PIWords (D, datDMZylinder));
                         WriteLn ('Drive Map : Kîpfe  : ', ATA_PIWords (D, datDMKoepfe));
                         WriteLn ('Drive Map : SekSp. : ', ATA_PIWords (D, datDMSektorenSpur));
                       End;
                   End;
        datATAPI : Begin
                     WriteLn ('ATAPI-Informationen : ');

                     WriteLn ('Device-Typ         : ', ATA_PIStrings (D, datWhatDevice));
                     WriteLn ('Enh PIO Mode       : ', ATA_PIStrings (D, datEnhPIO));
                     WriteLn ('Wechselmedium      : ', Cross (ATA_PIBools (D, datWechselMed)));
                     If ATA_PIBools (D, datIsDMA) Then
                       Begin
                         WriteLn ('Min Zyklus MW-DMA  : ', ATA_PIWords (D, datMinZykMWDMA), ' ns');
                         WriteLn ('Empf Zyklus MW-DMA : ', ATA_PIWords (D, datEmpfZykMWDMA), ' ns');
                       End;
                     WriteLn ('MinZyk PIO o IORDY : ', ATA_PIWords (D, datMinZykPIOOIORDY), ' ns');
                     WriteLn ('MinZyk PIO m IORDY : ', ATA_PIWords (D, datMinZykPIOMIORDY), ' ns');
                   End;
      End;
    End
  Else
    WriteLn ('Laufwerk ',D,': antwortet nicht.');
End;


Procedure DOSWindow;
  Function Dow (A : Word) : String;

  Begin
    Case A Of
      0 : Dow := 'Sonntag';
      1 : Dow := 'Montag';
      2 : Dow := 'Dienstag';
      3 : Dow := 'Mittwoch';
      4 : Dow := 'Donnerstag';
      5 : Dow := 'Freitag';
      6 : Dow := 'Samstag';
    End;
  End;

Begin
  Rahmen (22,4,79,25,' DOS-Informationen ');
  Window (23,5,77,23);

  WriteLn ('Dos-Version               : ', GetDosVersion);
  WriteLn ('OEM-Nummer                : ', Hex (GetDosOEMNumber, 2), 'h');
  WriteLn ('Dos in HMA                : ', Cross (IsDosInHMA), ', im ROM ', Cross (IsDosInRom));
  WriteLn ('Unterer Arbeitsspeicher   : ', DosMemory, ' (', DosMemory DIV 1024, 'kb)');
  Write ('Dos 3+ Datensegment       : ');
  xPointer := WhichAddress (Dos3);
  If Not (PtrRec(xPointer).Seg = 0) Then
    WriteLn (Hex(PtrRec(xPointer).Seg, 4), ':', Hex (PtrRec(xPointer).Ofs, 4))
  Else
    WriteLn ('[-]');
  WriteLn ('Parameter-Switch-Char     : ', GetDosSwitchChar);
  WriteLn ('/DEV/ Prefix erforderlich : ', Cross (IsDEVPrefix));
  WriteLn ('Adresse des DOS-Busy-Flag : ', PointerStr (GetDosBusyFlag));
  WriteLn ('Print-Screen Status       : ', GetPrtScrStatus);
  WriteLn ('Memory-Allocation-Methode : ', GetMemAllocMethod);
  WriteLn ('Buffers                   : ', DosBuffers);
  WriteLn ('Files                     : ', DosFilesCount, ', benutzt : ', DosFilesUsed);
  WriteLn ('  Erstes Handle           : ', PointerStr (DosFilesPointer));
  WriteLn ('  FCB''s                   : ', DosFCBCount);
  WriteLn ('  Stacks                  : ', DosStacksCount, ',', DosStacksSize);

  WriteLn;
  WaitKey;
  ClrScr;

  WriteLn;
  WriteLn;
  WriteLn ('Aktueller Country-Code    : ', CountryCode);
  WriteLn ('Aktueller Country-String  : ', Countrystring);
  WriteLn ('Aktive/Default Codepage   : ', DosActiveGlobalCodePage, '/', DosDefaultGlobalCodePage);
  WriteLn ('Tausendertrenner          : ', DosThousandSeparator);
  WriteLn ('Dezimialzahlen-Trenner    : ', DosDecimalSeparator);
  WriteLn ('Datumsformat              : ', DosDateFormat);
  WriteLn ('Zeitformat                : ', DosTimeFormat);
  WriteLn ('Zeit-Trenner              : ', DosTimeSeparator);
  WriteLn ('Waehrungsformat           : ', DosCurrencyFormat);
  WriteLn ('Case-Map Aufrufsadresse   : ', PointerStr (DosCaseMapCallAddress));

  Repeat
    GotoXY (1, 1);
    GetDate (xWord1, xWord2, xWord3, xWord4);
    xString := Dow (xWord4) + ', der ' + ZeroPad (xWord3) + '.' + ZeroPad (xWord2) + '.' + StrFnWord (xWord1);
    WriteLn ('Dos-Datum                 : ', xString);
    GetTime (xWord1, xWord2, xWord3, xWord4);
    xString := ZeroPad (xWord1) + ':' + ZeroPad (xWord2) + ':' + ZeroPad (xWord3) + ',' + ZeroPad (xWord4);
    WriteLn ('Dos-Zeit                  : ', xString);
  Until Keypressed;
End;


Procedure EnvironmentWindow;

Begin
  Rahmen (22,4,79,25,' Environment-Informationen ');
  Window (23,5,77,23);

  WriteLn ('Environment-Segment : ', Hex (EnvSeg, 4), 'h');
  WriteLn ('Laenge              : ', EnvLen);
  WriteLn ('Benutzt             : ', EnvUsed);
  WriteLn ('Frei                : ', EnvLen-EnvUsed);
  WriteLn;
  WriteLn ('EintrÑge : ');


  For xByte := 1 To Dos.EnvCount Do
    Begin
      Writeln (Dos.Envstr (xByte));
      If WhereY = 18 Then
        Begin
          WaitKey;
          ClrScr;
        End;
    End;
End;

Procedure MCBWindow;

Type String35 = String[35];

Var String1 : String35;

Begin
  Rahmen (22,4,79,25,' MCB-Liste ');
  Window (23,5,77,23);

  xByte4 := 0;

  WriteLn ('…ÕÕÕÕÕÕÕ—ÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª');
  WriteLn ('∫ Segm. ≥ PSP  ≥ Parent ≥ Groe·e ≥ Owner             ∫');
  WriteLn ('ÃÕÕÕÕÕÕÕÿÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ');
  Repeat
    Inc (xByte4);
    WriteLn ('∫ ', Hex (GetMCBSeg (xByte4), 4), '  ≥ ', Hex (GetMCBPSP (xByte4), 4), ' ≥ ', Hex (GetMCBParent (xByte4), 4),
             '   ≥ ', GetMCBSize (xByte4):6, ' ≥ ', GetMCBOwner (xByte4):17, ' ∫');
    If WhereY = 18 Then
      Begin
        WriteLn (':       |      |        |        |                   :');
        WaitKey;
        ClrScr;
        WriteLn (':       |      |        |        |                   :');
      End;
  Until xByte4 = GetNumberMCBs;
  WriteLn ('»ÕÕÕÕÕÕÕœÕÕÕÕÕÕœÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº');

  WriteLn;
  WriteLn ('Folgende Programme trappen Interrupts : ');
  xByte4 := 0;
  Repeat
    Inc (xByte4);
    If GetMCBInterrupts (xByte4) <> '' Then
      Begin
        String1 := GetMCBInterrupts (xByte4);
        xString := GetMCBOwner (xByte4);
        If xString = '' Then xString := '?';
        If Length (GetMCBInterrupts (xByte4)) > 35 Then
          WriteLn (xString:13, ' : ', String1, '...')
        Else
          WriteLn (xString:13, ' : ', String1)
      End;
    If WhereY >= 18 Then
      Begin
        WriteLn;
        WaitKey;
        ClrScr;
      End;
  Until xByte4 = GetNumberMCBs;
End;


Procedure DosDevicesWindow;

Begin
  Rahmen (22,4,79,25,' Logische Dos GerÑte/Devices ');
  Window (23,5,77,23);

  { DevStrategy wird hier nicht verwendet, da schlicht und einfach kein Platz
    mehr im Fenster war. }

  WriteLn ('Name     Header      Attribute           Interrupt');
  WriteLn;

  For xByte2 := 1 To DevCount Do
    Begin
      WriteLn (DevName (xByte2) + FillUp (8 - Length (DevName (xByte2)), ' '), ' ', PointerStr (DevHeader (xByte2)), ' ',
               Bin16 (DevAttributes (xByte2), '-'), ' ', PointerStr (DevInterrupt (xByte2)));
      If WhereY = 18 Then
        Begin
          WriteLn;
          WaitKey;
          ClrScr;
          WriteLn ('Name     Header      Attribute           Interrupt');
          WriteLn;
        End;
    End;
End;


Procedure MemoryWindow;

Begin
  Rahmen (22,4,79,25,' Memory Informationen EMS, XMS, XMM ');
  Window (23,5,77,23);

  WriteLn ('Ist EMS verfÅgbar ?      : ',Cross(IsExistEMS));
  If IsExistEMS Then
    Begin
      WriteLn ('  EMS-Version            : ',GetEMSVersion);
      WriteLn ('  EMS-Seiten Insgesamt   : ',AllEmsPages,' (',AllEmsPages * 16,'kb)');
      WriteLn ('  EMS-Seiten Frei        : ',FreeEmsPages,' (',FreeEmsPages * 16,'kb)');
      xPointer := GetEMSAddress;
      WriteLn ('  EMS-Paging Adresse     : ',Hex(PtrRec(xPointer).Seg,4),':',Hex(PtrRec(xPointer).Ofs,4));
      WriteLn ('  Ist VCPI vorhanden     : ', Cross(IsVCPI) );
      If IsVCPI Then
        WriteLn ('    Version              : ', VCPIVersion );
    End;
  WriteLn ('Ist XMS (laut Bios)      : ',Cross(IsExtMemBIOS));
  If IsExtMemBIOS Then
    Begin
      WriteLn ('  Wieviel                : ', BIOSFreeExt);
    End;
  WriteLn ('Ist XMM installiert      : ',Cross(IsExtMemDriv));
  If IsExtMemDriv Then
    Begin
      WriteLn ('  XMS-Version            : ', XMSVersion);
      WriteLn ('  XMM-Version            : ', XMMVersion);
      WriteLn ('  XMS-Speicher           : ', XMSMemory,'kb');
      WriteLn ('  Freier XMS-Speicher    : ', XMSFreeMemory,'kb');
      WriteLn ('  Sind UMB''s vorhanden   : ', Cross(IsUMB));
      If IsUMB Then
        WriteLn ('    Grî·ter freier Block : ', UMBLargestBl);
    End;
End;


Procedure MemoryWindow2;

Begin
  Rahmen (22,4,79,25,' Memory Informationen CMOS, HMA, DPMI ');
  Window (23,5,77,23);

  WriteLn ('Base Memory (CMOS)       : ', CmosBaseMemory,'kb');
  WriteLn ('Extended Memory (CMOS)   : ', CmosExtMemory,'kb');
  WriteLn ('Gesamter Memory (CMOS)   : ', CmosTotalMem,'kb');

  WriteLn;

  WriteLn ('HMA (nur wenn XMM installiert ist)');
  If IsExtMemDriv Then
    If IsHMA Then
      Begin
        WriteLn ('HMA                  : ', Cross(IsHMA));
        WriteLn ('  HMA-Status         : ', HMAStatus);
        WriteLn ('  Bei Dos 5+ genutzt : ', Cross(HMAUsedByDos5));
        If HMAUsedByDos5 Then
          Begin
          WriteLn ('    Frei             : ', HMAFreeDos5,' Byte');
          xPointer := HMAAddressDos5;
          WriteLn ('    Adresse          : ', Hex (PtrRec(xPointer).Seg, 4),
            ':', Hex (PtrRec(xPointer).Ofs, 4));
          End;
      End;

  WriteLn;

  WriteLn ('Ist DPMI vorhanden           : ', Cross (IsDPMI));
  If IsDPMI Then
    Begin
      WriteLn ('  DPMI-Version               : ', DPMIVersion);
      WriteLn ('  DPMI-CPU                   : ', DPMICPU);
      xPointer := DPMIModeEntry;
      WriteLn ('  DPMI-Switch-Mode Entry     : ', Hex (PtrRec(xPointer).Seg, 4),
               ':', Hex (PtrRec(xPointer).Ofs, 4));
    End;
End;


Procedure MemoryWindow3;

Begin
  Rahmen (22,4,79,25,' Speicher/Memory Info''s VDS, öbertragungsraten ');
  Window (23,5,77,23);

  WriteLn ('Wird VDS (Virtual DMA Specification) unterstÅtzt : ', Cross (IsVDS));
  If IsVDS Then
    Begin
      WriteLn ('  Version                           : ', VdsVersion);
      WriteLn ('  Produkt                           : ', VdsProduct);
      WriteLn ('  Maximale Grî·e des DMA-Buffers    : ', VdsMaxDMABSize, 'kb');
      WriteLn ('  Transfere Ok in(m)                : ', VdsTransfersOk);
      WriteLn ('  Befindet sich der Buffer im 1. MB : ', Cross(VDSIsBuffer1Meg));
      WriteLn ('  Ist Auto-Remap Funktion aktiv     : ', Cross(VDSIsAutoRemap));
      WriteLn ('  Ist Contiguous Memory Opt. aktiv  : ', Cross(VDSIsContiguousMem));
      WriteLn ('  Ist Bios-Bit fÅr VDS gesetzt      : ', Cross(VDSIsBiosBit));
    End;

  WriteLn ('Maximaler Datendurchsatz im Memory  : ', MemThru:0:0, ' KB/s');
  Write   ('Datendurchsatz Extended Mem (BIOS)  : ');
  If IsExtMemBios Then WriteLn (BiosExtThru:0:0, ' KB/s') Else WriteLn ('nicht inst.');
  Write   ('Datendurchsatz im EMS               : ');
  If IsExistEMS Then WriteLn (EMSThru:0:0, ' KB/s') Else WriteLn ('nicht inst.');
End;


Procedure MemoryWindow4;

Var I : Byte;

Begin
  Rahmen (22,4,79,25,' Speicher/Memory Informationen / EMS Handles ');
  Window (23,5,77,23);

  If Not IsExistEMS Then
    WriteLn ('Kein EMS installiert')
  Else
    Begin
      WriteLn (' Nummer  Grî·e   Name');
      For I := 1 To GetNumberHandles Do
        Begin
          WriteLn (' ', Hex (I, 4), 'h    ', GetEMSHandleSize(I):4, 'KB ', GetEMSHandleName (I));

        End;

    End;
End;


Procedure SoundWindow;

Begin
  Rahmen (22,4,79,25,' Soundkarten Informationen ');
  Window (23,5,77,24);

  WriteLn ('SoundBlaster ?         : ', Cross(IsSB));
  If IsSB Then
    Begin
      Case WhatSB Of
        dsbNormal : WriteLn ('  Typ                  : Normal (Mono)');
        dsbPro    : WriteLn ('  Typ                  : Pro (Stereo)');
        dsb16     : WriteLn ('  Typ                  : 16 (Stereo)');
        dsb16ASP  : WriteLn ('  Typ                  : 16 ASP (Stereo)');
      End;
      WriteLn ('  Port                 : ', Hex(WhatSBPort,3),'h');
      WriteLn ('  Version              : ', WhatSBVersion);
      WriteLn ('  Speech Driver        : ', Cross(IsInstalled (SBSpeechDrv)));
      If IsInstalled (SBSpeechDrv) Then
        Begin
          xPointer := WhichAddress (SBSpeechDrv);
          WriteLn ('    API-Entry-Point    : ', Hex (PtrRec(xPointer).seg, 4),
                                          ':',Hex (PtrRec(xPointer).ofs, 4));
        End
    End;
  WriteLn ('Adlib ?                : ',Cross(IsAdlib));
  If IsAdlib Then
    Begin
      WriteLn ('  Driver ?             : ',Cross(IsAdlibDriver));
      If IsAdlibDriver Then
        Begin
          WriteLn ('    Version            : ',AdlibDrvVer);
          xPointer := AdlibDrvAdr;
          WriteLn ('    Adresse            : ',Hex (PtrRec(xPointer).seg, 4),
                                          ':',Hex (PtrRec(xPointer).ofs, 4));
        End;
    End;

  WriteLn ('Roland MPU 401         : ', Cross (IsMPU401));

  WriteLn ('Gravis Ultrasound      : ', Cross (IsGUS));
  If IsGUS Then
    Begin
      WriteLn ('  Port                 : ', Hex(GUS_Port,3),'h');
      WriteLn ('  Memory               : ', GUS_Memory);
    End;

  WriteLn ('Vesa Audio Interface   : ', Cross (IsVBEAI));
  If IsVBEAI Then
    Begin
      WriteLn ('  Version              : ', VBEAIVersion);
      WriteLn ('  Wave-Handle          : ', VBEAILDevice (daiWave));
      WriteLn ('  Midi-Handle          : ', VBEAILDevice (daiMidi));
      WriteLn ('  Volume-Handle        : ', VBEAILDevice (daiVolume));
      WriteLn ('  Weitere Informationen kînnen hier aus PlatzgrÅnden');
      WriteLn ('  nicht gemacht werden (Pro Handle wÑren das 10');
      WriteLn ('  Bildschirmseiten ... ');
    End;
End;


Procedure ParaWindow;

Var Anz : Byte;

Begin
  Rahmen (22,4,79,25,' Parallelport-Informationen ');
  Window (23,5,77,24);

  P := GetBiosRecord;
  Anz := P^.Equipment And $C000 Shr 14;

  WriteLn ('Anzahl der parallelen Ports : ', Anz);
  WriteLn;

  WriteLn ('…ÕÕÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕª');
  WriteLn ('∫              ≥ LPT 1 ≥ LPT 2 ≥ LPT 3 ≥ LPT 4 ∫');
  WriteLn ('«ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒ∂');
  WriteLn ('∫ Port         ≥ ', Hex(P^.LPT[1],4)+'h':5, ' ≥ ', Hex(P^.LPT[2],4)+'h':5, ' ≥ ', Hex(P^.LPT[3],4)+'h':5, ' ≥ ',
    Hex(P^.LPT[4],4)+'h':5, ' ∫');
  WriteLn ('∫ TimeOut      ≥ ', GetParDevTimeOut (1):3, '   ≥ ', GetParDevTimeOut (2):3, '   ≥ ', GetParDevTimeOut (3):3,
    '   ≥ ', GetParDevTimeOut (4):3, '   ∫');
  WriteLn ('∫ Busy         ≥  ', Cross ((GetParDevTimeOut (1) And dpdBusy = dpdBusy)), '  ≥  ', Cross ((GetParDevTimeOut (2)
    And dpdBusy = dpdBusy)), '  ≥  ', Cross ((GetParDevTimeOut (3) And dpdBusy = dpdBusy)), '  ≥  ', Cross ((GetParDevTimeOut
    (4) And dpdBusy = dpdBusy)), '  ∫');
  WriteLn ('∫ Acknowledged ≥  ', Cross ((GetParDevTimeOut (1) And dpdAck = dpdAck)), '  ≥  ', Cross ((GetParDevTimeOut (2)
    And dpdAck = dpdAck)), '  ≥  ', Cross ((GetParDevTimeOut (3) And dpdAck = dpdAck)), '  ≥  ', Cross ((GetParDevTimeOut
    (4) And dpdAck = dpdAck)), '  ∫');
  WriteLn ('∫ Papier Ende  ≥  ', Cross ((GetParDevTimeOut (1) And dpdPaperOut = dpdPaperOut)), '  ≥  ', Cross
    ((GetParDevTimeOut (2) And dpdPaperOut = dpdPaperOut)), '  ≥  ', Cross ((GetParDevTimeOut (3) And dpdPaperOut =
    dpdPaperOut)), '  ≥  ', Cross ((GetParDevTimeOut (4) And dpdPaperOut = dpdPaperOut)), '  ∫');
  WriteLn ('∫ Selected     ≥  ', Cross ((GetParDevTimeOut (1) And dpdSelected = dpdSelected)), '  ≥  ', Cross
    ((GetParDevTimeOut (2) And dpdSelected = dpdSelected)), '  ≥  ', Cross ((GetParDevTimeOut (3) And dpdSelected =
    dpdSelected)), '  ≥  ', Cross ((GetParDevTimeOut (4) And dpdSelected = dpdSelected)), '  ∫');
  WriteLn ('∫ I/O Fehler   ≥  ', Cross ((GetParDevTimeOut (1) And dpdIOError = dpdIOError)), '  ≥  ', Cross
    ((GetParDevTimeOut (2) And dpdIOError = dpdIOError)), '  ≥  ', Cross ((GetParDevTimeOut (3) And dpdIOError =
    dpdIOError)), '  ≥  ', Cross ((GetParDevTimeOut (4) And dpdIOError = dpdIOError)), '  ∫');
  WriteLn ('∫ Timed Out    ≥  ', Cross ((GetParDevTimeOut (1) And dpdTimedOut = dpdTimedOut)), '  ≥  ', Cross
    ((GetParDevTimeOut (2) And dpdTimedOut = dpdTimedOut)), '  ≥  ', Cross ((GetParDevTimeOut (3) And dpdTimedOut =
    dpdTimedOut)), '  ≥  ', Cross ((GetParDevTimeOut (4) And dpdTimedOut = dpdTimedOut)), '  ∫');
  WriteLn ('∫ EPP Bios     ≥  ', Cross (IsEPP (1)), '  ≥  ', Cross (IsEPP (2)), '  ≥  ', Cross (IsEPP (3)), '  ≥  ',
    Cross (IsEPP (4)), '  ∫');
  WriteLn ('»ÕÕÕÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕœÕÕÕÕÕÕÕœÕÕÕÕÕÕÕœÕÕÕÕÕÕÕº');
End;


Procedure SerialWindow;

Begin
  Rahmen (22,4,79,25,' Informationen Åber serielle Schnittstellen');
  Window (23,5,77,24);

  P := GetBiosRecord;
  WriteLn ('Anzahl der seriellen Ports : ', P^.Equipment And $0E00 Shr 9);
  WriteLn;

  WriteLn ('…ÕÕÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕª');
  WriteLn ('∫              ≥ COM 1  ≥ COM 2  ≥ COM 3  ≥ COM 4  ∫');
  WriteLn ('«ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ∂');
  WriteLn ('∫ Port         ≥ ', Hex(P^.COM[1],4)+'h':6, ' ≥ ', Hex(P^.COM[2],4)+'h':6, ' ≥ ', Hex(P^.COM[3],4)+'h':6, ' ≥ ',
    Hex(P^.COM[4],4)+'h':6, ' ∫');
  WriteLn ('∫ UART         ≥ ',GetSerDevUART (1):6,' ≥ ',GetSerDevUART (2):6,' ≥ ',GetSerDevUART (3):6,' ≥ ',GetSerDevUART
    (4):6,' ∫');
  WriteLn ('∫ BaudRate     ≥ ',GetSerDevBaudrate (1):6,' ≥ ',GetSerDevBaudrate (2):6,' ≥ ',GetSerDevBaudrate (3):6,' ≥ ',
    GetSerDevBaudrate (4):6,' ∫');
  WriteLn ('∫ Datenbits    ≥ ',GetSerDevDataBits (1):6,' ≥ ',GetSerDevDataBits (2):6,' ≥ ',GetSerDevDataBits (3):6,' ≥ ',
    GetSerDevDataBits (4):6,' ∫');
  WriteLn ('∫ ParitÑt      ≥ ',GetSerDevParity (1):6,' ≥ ',GetSerDevParity (2):6,' ≥ ',GetSerDevParity (3):6,' ≥ ',
    GetSerDevParity (4):6,' ∫');
  WriteLn ('∫ StopBits     ≥    ',GetSerDevStopBits (1):1:1,' ≥    ',GetSerDevStopBits (2):1:1,' ≥    ',GetSerDevStopBits
    (3):1:1, ' ≥    ', GetSerDevStopBits (4):1:1,' ∫');
  WriteLn ('∫ Break-Flag   ≥    ', Cross(GetSerDevBreak (1)),' ≥    ', Cross(GetSerDevBreak (2)),' ≥    ', Cross
    (GetSerDevBreak (3)), ' ≥    ', Cross(GetSerDevBreak (4)),' ∫');
  WriteLn ('∫ Time-Out     ≥ ', P^.COMTimeOut[1]:6, ' ≥ ', P^.COMTimeOut[2]:6, ' ≥ ', P^.COMTimeOut[3]:6, ' ≥ ',
    P^.COMTimeOut[4]:6, ' ∫');
  WriteLn ('∫ RLSD/dRLSD   ≥', Cross (GetSerDevFlags (1) And dpsRLSD = dpsRLSD),' ', Cross (GetSerDevFlags (1) And
    dpsdRLSD = dpsdRLSD), ' ≥', Cross (GetSerDevFlags (2) And dpsRLSD = dpsRLSD),' ', Cross (GetSerDevFlags (2) And
    dpsdRLSD = dpsdRLSD), ' ≥', Cross (GetSerDevFlags (3) And dpsRLSD = dpsRLSD),' ', Cross (GetSerDevFlags (3) And
    dpsdRLSD = dpsdRLSD), ' ≥', Cross (GetSerDevFlags (4) And dpsRLSD = dpsRLSD),' ', Cross (GetSerDevFlags (4) And
    dpsdRLSD = dpsdRLSD), ' ∫');
  WriteLn ('∫ RI/dRI       ≥', Cross (GetSerDevFlags (1) And dpsRI = dpsRI),' ', Cross (GetSerDevFlags (1) And
    dps_dRI = dps_dRI), ' ≥', Cross (GetSerDevFlags (2) And dpsRI = dpsRI),' ', Cross (GetSerDevFlags (2) And
    dps_dRI = dps_dRI), ' ≥', Cross (GetSerDevFlags (3) And dpsRI = dpsRI),' ', Cross (GetSerDevFlags (3) And
    dps_dRI = dps_dRI), ' ≥', Cross (GetSerDevFlags (4) And dpsRI = dpsRI),' ', Cross (GetSerDevFlags (4) And
    dps_dRI = dps_dRI), ' ∫');
  WriteLn ('∫ DSR/dDSR     ≥', Cross (GetSerDevFlags (1) And dpsDSR = dpsDSR),' ', Cross (GetSerDevFlags (1) And
    dpsdDSR = dpsdDSR), ' ≥', Cross (GetSerDevFlags (2) And dpsDSR = dpsDSR),' ', Cross (GetSerDevFlags (2) And
    dpsdDSR = dpsdDSR), ' ≥', Cross (GetSerDevFlags (3) And dpsDSR = dpsDSR),' ', Cross (GetSerDevFlags (3) And
    dpsdDSR = dpsdDSR), ' ≥', Cross (GetSerDevFlags (4) And dpsDSR = dpsDSR),' ', Cross (GetSerDevFlags (4) And
    dpsdDSR = dpsdDSR), ' ∫');
  WriteLn ('∫ CTS/dCTS     ≥', Cross (GetSerDevFlags (1) And dpsCTS = dpsCTS),' ', Cross (GetSerDevFlags (1) And
    dpsdCTS = dpsdCTS), ' ≥', Cross (GetSerDevFlags (2) And dpsCTS = dpsCTS),' ', Cross (GetSerDevFlags (2) And
    dpsdCTS = dpsdCTS), ' ≥', Cross (GetSerDevFlags (3) And dpsCTS = dpsCTS),' ', Cross (GetSerDevFlags (3) And
    dpsdCTS = dpsdCTS), ' ≥', Cross (GetSerDevFlags (4) And dpsCTS = dpsCTS),' ', Cross (GetSerDevFlags (4) And
    dpsdCTS = dpsdCTS), ' ∫');
  WriteLn ('»ÕÕÕÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕº');
End;


Procedure BiosWindow4;

Var Row        : Word;
    EndThat    : Boolean;
    C          : Char;
    FillString : String;
    Aktual     : Boolean;
    TempBool   : Boolean;

Const MaxRow = 58;

Begin
  P := GetBiosRecord;
  Rahmen (22,4,79,25,' Bios Data-Area Informationen ');
  Window (1,1,80,25);
  GotoXY (79,5);
  Write (#24);
  GotoXY (79,23);
  Write (#25);
  Window (24,5,77,24);

  FillChar (FillString, 250, #$20);

  Row := 1;
  EndThat := False;
  Aktual := False;
  TempBool := False;

  Repeat
    Window (79,14,79,18);
    Write (Row,' ');
    If Row = 1 Then
      Begin
        Window (1,1,80,25);
        GotoXY (79,5);
        Write (#$20);
        GotoXY (79,23);
        Write (#25);
        Window (24,5,77,24);
      End;
    If Row = Maxrow Then
      Begin
        Window (1,1,80,25);
        GotoXY (79,5);
        Write (#24);
        GotoXY (79,23);
        Write (#$20);
        Window (24,5,77,24);
      End;
    If (Row > 1) And (Row < MaxRow) Then
      Begin
        Window (1,1,80,25);
        GotoXY (79,5);
        Write (#24);
        GotoXY (79,23);
        Write (#25);
        Window (24,5,77,24);
      End;

    GotoXY (1,1);
    For xByte3 := Row To Row+18 Do
      Begin
        Case xByte3 Of
          1 : Write ('COM-Portadressen            : ', Hex(P^.Com[1],3),'h, ',Hex(P^.Com[2],3),'h, ',Hex(P^.Com[3],3),'h, ',
            Hex(P^.Com[4],3),'h');
          2 : Write ('LPT-Portadressen            : ', Hex(P^.Lpt[1],3),'h, ',Hex(P^.Lpt[2],3),'h, ',Hex(P^.Lpt[3],3),'h, ',
            Hex(P^.Lpt[4],3),'h');
          3 : Write ('Equipment / IPL installiert : ', Cross (Lo(P^.Equipment) And 1 = 1));
          4 : Write ('Equipment / Koprozessor     : ', Cross (Lo(P^.Equipment) And 2 = 2));
          5 : Write ('Equipment / Laufwerke       : ', Byte (Lo (P^.Equipment) And $80 = $80) + 1);
          6 : Write ('Equipment / DMA installiert : ', Cross (Not (Hi (P^.Equipment) And 1 = 1)));
          7 : Write ('Equipment / Game Port       : ', Cross ((Hi (P^.Equipment) And $10 = $10)));
          8 : Write ('Grundmemory                 : ', P^.MemorySize, ' kb');
          9 : Write ('Keyboard / Rechtes Shift    : ', Cross (P^.KeyboardFlag[1] And 1 = 1));
          10 : Write ('Keyboard / Linkes Shift     : ', Cross (P^.KeyboardFlag[1] And 2 = 2));
          11 : Write ('Keyboard / CTRL losgelassen : ', Cross (P^.KeyboardFlag[1] And 4 = 4));
          12 : Write ('Keyboard / ALT losgelassen  : ', Cross (P^.KeyboardFlag[1] And 8 = 8));
          13 : Write ('Keyboard / Scroll Lock      : ', Cross (P^.KeyboardFlag[1] And $10 = $10));
          14 : Write ('Keyboard / Num Lock         : ', Cross (P^.KeyboardFlag[1] And $20 = $20));
          15 : Write ('Keyboard / Caps Lock        : ', Cross (P^.KeyboardFlag[1] And $40 = $40));
          16 : Write ('Keyboard / Insert           : ', Cross (P^.KeyboardFlag[1] And $80 = $80));
          17 : Write ('Keyboard / CTRL Links       : ', Cross (P^.KeyboardFlag[2] And 1 = 1));
          18 : Write ('Keyboard / ALT Links        : ', Cross (P^.KeyboardFlag[2] And 2 = 2));
          19 : Write ('Keyboard / Tastencode Start : 0040h:', Hex (P^.KeyBufHead, 4));
          20 : Write ('Keyboard / Tastencode Ende  : 0040h:', Hex (P^.KeyBufTail, 4));
          21 : Write ('Keyboard / Keybuffer Ende   : 0040h:', Hex (P^.KeyBufBegin, 4));
          22 : Write ('Keyboard / Keybuffer Ende   : 0040h:', Hex (P^.KeyBufEnd, 4));
          23 : Write ('Disk / Rekalibrat. Drive 0  : ', Cross (P^.SeekState And 1 = 1));
          24 : Write ('Disk / Rekalibrat. Drive 1  : ', Cross (P^.SeekState And 2 = 2));
          25 : Write ('Disk / Rekalibrat. Drive 2  : ', Cross (P^.SeekState And 4 = 4));
          26 : Write ('Disk / Rekalibrat. Drive 3  : ', Cross (P^.SeekState And 8 = 8));
          27 : Write ('Disk / Interrupt Flag       : ', Cross (P^.SeekState And $80 = $80));
          28 : Write ('Disk / Drive 0 Motor an     : ', Cross (P^.DiskState And 1 = 1));
          29 : Write ('Disk / Drive 1 Motor an     : ', Cross (P^.DiskState And 2 = 2));
          30 : Write ('Disk / Drive 2 Motor an     : ', Cross (P^.DiskState And 4 = 4));
          31 : Write ('Disk / Drive 3 Motor an     : ', Cross (P^.DiskState And 8 = 8));
          32 : Write ('Disk / Schreiboperation     : ', Cross (P^.DiskState And $80 = $80));
          33 : Write ('Disk / Motortimeout         : ', P^.MotorTimeOut);
          34 : Write ('Disk / LZ ungÅltiger Befehl : ', Cross (P^.DiskOpState And 1 = 1));
          35 : Write ('Disk / LZ Adresse nicht gef.: ', Cross (P^.DiskOpState And 2 = 2));
          36 : Write ('Disk / LZ Sektor nicht gef. : ', Cross (P^.DiskOpState And 4 = 4));
          37 : Write ('Disk / LZ DMA Fehler        : ', Cross (P^.DiskOpState And 8 = 8));
          38 : Write ('Disk / LZ CRC/Daten Fehler  : ', Cross (P^.DiskOpState And $10 = $10));
          39 : Write ('Disk / LZ Controllerfehler  : ', Cross (P^.DiskOpState And $20 = $20));
          40 : Write ('Disk / LZ Zugriff verweig.  : ', Cross (P^.DiskOpState And $40 = $40));
          41 : Write ('Disk / LZ TimeOut           : ', Cross (P^.DiskOpState And $80 = $80));
          42 : Write ('Videomode                   : ', P^.Videomode);
          43 : Write ('Screen-Buffer Grî·e         : ', P^.ScreenBufSize);
          44 : Write ('Bildschirmseite Offset      : ', Hex (P^.ScreenPageOfs, 4), 'h');
          45 : Write ('Bildschirmseite             : ', P^.ScreenPage);
          46 : Write ('CRT-Base Register           : ', Hex (P^.CRTBase, 3), 'h');
          47 : Write ('CRT-Mode                    : ', P^.CRTMode);
          48 : Write ('Timer                       : ', Hex (P^.Timer[2], 4), Hex (P^.Timer[1],4), 'h');
          49 : Write ('CTRL-Break Flag             : ', Cross (P^.BiosBreak And $80 = $80));
          50 : Begin
                 Write ('Reset-Nummer                : ', Hex (P^.SoftReset, 4),'h (');
                 Case P^.SoftReset Of
                   $0000 : Write ('Kaltstart');
                   $1234, $1200, $EDCB : Write ('Warmstart');
                   $4321 : Write ('Speicher vorbereiten');
                   $5678 : Write ('System Suspend');
                   $9ABC : Write ('Hersteller-Test');
                   $ABCD : Write ('Conv. Post-Loop');
                   $0064 : Write ('BurnIn - Modus');
                 End;
                 Write (')');
               End;

          51 : Write ('LPT 1 Timeout               : ', P^.LPTTimeOut[1]);
          52 : Write ('LPT 2 Timeout               : ', P^.LPTTimeOut[2]);
          53 : Write ('LPT 3 Timeout               : ', P^.LPTTimeOut[3]);
          54 : Write ('LPT 4 Timeout               : ', P^.LPTTimeOut[4]);
          55 : Write ('COM 1 Timeout               : ', P^.COMTimeOut[1]);
          56 : Write ('COM 2 Timeout               : ', P^.COMTimeOut[2]);
          57 : Write ('COM 3 Timeout               : ', P^.COMTimeOut[3]);
          58 : Write ('COM 4 Timeout               : ', P^.COMTimeOut[4]);
          59 : Write ('Grafik / Char-Grî·e         : ', P^.CharHeight);
          60 : Write ('Grafik / Alphanumeric Emul. : ', Cross (P^.VideoOptions And 1 = 1));
          61 : Write ('Grafik / Monochrom-System   : ', Cross (P^.VideoOptions And 2 = 2));
          62 : Write ('Grafik / Video Ram          : ', ((P^.VideoOptions And 1+2+4+8+16+128) Shr 5) * 64, ' kb');
          63 : Write ('Grafik / VGA aktiv          : ', Cross (P^.VideoDataArea And 1 = 1));
          64 : Write ('Grafik / Graustufen aktiv   : ', Cross (P^.VideoDataArea And 2 = 2));
          65 : Write ('Grafik / Monochrommonitor   : ', Cross (P^.VideoDataArea And 4 = 4));
          66 : Write ('Grafik / Display Switching  : ', Cross (P^.VideoDataArea And $40 = $40));
          67 : Begin
                 Write ('Disk / Floppy Step Rate     : ');
                 Case (P^.DiskDataRate And $10+$20) Shr 4 Of
                   0 : Write ('0Ch');
                   1 : Write ('0Dh');
                   2 : Write ('0Ah');
                   3 : Write ('reserviert');
                 End;
               End;
          68 : Begin
                 Write ('Disk / Floppy Data Rate     : ');
                 Case (P^.DiskDataRate And $40+$80) Shr 6 Of
                   0 : Write ('500 kbps');
                   1 : Write ('300 kbps');
                   2 : Write ('250 kbps');
                   3 : Write ('reserviert');
                 End;
               End;
          69 : Write ('HD Interrupt Flag           : ', Cross (P^.HDIntFlag And $80 = $80));
          70 : Write ('HD/FD Kombikarte            : ', Cross (P^.HD_FD_CombiCard And 1 = 1));
          71 : Write ('Keyb. / 101/102er Tastatur  : ', Cross (P^.KeyboardMode And $10 = $10));
          72 : Write ('Keyb. / Scroll Lock Indik.  : ', Cross (P^.KeyboardLeds And 1 = 1));
          73 : Write ('Keyb. / Num Lock Indikator  : ', Cross (P^.KeyboardLeds And 2 = 2));
          74 : Write ('Keyb. / Caps Lock Indikator : ', Cross (P^.KeyboardLeds And 4 = 4));
          75 : Write ('Keyb. / Circus System Indik.: ', Cross (P^.KeyboardLeds And 8 = 8));
          76 : Write ('Keyb. / Acknowledgement empf: ', Cross (P^.KeyboardLeds And $10 = $10));
        Else
        End;
        FillString[0] := Chr (54-WhereX);
        WriteLn (FillString);
      End;

    C := #0;
    If KeyPressed Then TempBool := True;
    If TempBool Then C := ReadKey;
    If UpCase (C) = #27 Then EndThat := True;
    If UpCase (C) = 'A' Then Aktual := True;
    If TempBool Then
      If (Not Aktual) Or (Endthat) Then
        Case ReadKey Of
          'H' : Begin
                  Row := Row - 1;
                  If Row = 0 Then Row := 1;
                End;
          'P' : Begin
                  Row := Row + 1;
                  If Row > MaxRow Then Row := MaxRow;
                End;
          'I' : Begin
                  If (Row-18 = 0) Or (Row-18 > Row) Then Row := 1
                    Else Row := Row - 18;
                End;
          'Q' : Begin
                  Row := Row + 18;
                  If Row > MaxRow Then Row := MaxRow;
                End;
          'G' : Row := 1;
          'O' : Row := MaxRow;
        Else
          EndThat := True;
        End;
    If Aktual Then Aktual := False;
    TempBool := False;
  Until EndThat;
  Window (1,1,80,25);
  GotoXY (79,5);
  Write (#$20);
  GotoXY (79,23);
  Write (#$20);
  Window (79,14,79,18);
  Write ('  ');
End;


Begin
End.