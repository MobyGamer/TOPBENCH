Unit DetectProcessors;

Interface

Uses DetectGlobal;

Function IsCPUId     : Boolean;
Function TestCPUId   : pCPUId;

Function CPUReset    : Word; Far;
Function CPUResetStr : String;

Function GetCyrixReg (Register : Byte) : Byte;
Function CyrixId     : String;

Procedure ReadMSR (MSR : Word; Var EAX, EDX : LongInt);

Implementation

Uses DetectSystem, DetectConstants;

Var EAX : LongInt;
    EBX : LongInt;
    EDX : LongInt;
    ECX : LongInt;

Const Unknown : Boolean = False;

{$L DETECTGL.OBJ}
Function CPUReset; External;
Function TestForEFlag21 : Boolean; Far; External;

Procedure CPUID;

Begin
  Inline ($66/$A1/EAX/
          $0F/$A2/          { CPUID }
          $66/$A3/EAX/      { MOV [EAX],EAX }
          $66/$89/$1E/EBX/  { MOV [EBX],EBX }
          $66/$89/$0E/ECX/  { MOV [ECX],ECX }
          $66/$89/$16/EDX); { MOV [EDX],EDX }
End;


Function IsCPUId;

Begin
  xByte := 0;

  Asm
    db 66h, 9ch                     { pushfd           EFlags auf den Stack }
    db 66h, 58h                     { pop  eax         nach EAX holen }
    db 66h, 8bh, 0c8h               { mov  ecx,eax     in ECX merken }
    db 66h, 35h, 00h, 00h, 20h, 00h { xor  eax,200000h Bit 21 umdrehen }
    db 66h, 50h                     { push eax         das Ganze auf den Stack }
    db 66h, 9dh                     { popfd            ins EFLAG-Registerholen }
    db 66h, 9ch                     { pushfd           von da wieder auf denStack }
    db 66h, 58h                     { pop  eax         und als EAX zurueck }
    db 66h, 33h, 0c1h               { xor  eax,ecx     Bit 21 testen }
    je @weiter
    mov xByte, 1
  @weiter:
  End;
  IsCPUID := (xByte <> 0);
End;


Function TestCPUID : pCPUId;

Var
  CrStr    : Array [1..12] Of Char Absolute EBX;
  Copyr    : String;
  Stepping : Byte;
  Model    : Byte;
  Family   : Byte;
  Features : LongInt;
  vCPUId   : pCPUId;

Begin
  If IsCPUID Then
    Begin
      GetMem (vCPUId, SizeOf (vCPUId^));

      EAX := 0;
      CPUID;
      Copyr := CrStr;
      EAX := 1;
      CPUID;

      vCPUId^.Stepping  := EAX And $F;
      vCPUId^.Model     := (EAX Shr 4) And $F;
      vCPUId^.Family    := (EAX Shr 8) And $F;
      vCPUId^.Typ       := (EAX Shr 12) And $F;
      vCPUId^.Features  := EDX;
      vCPUId^.VendorId  := CopyR;

      EAX := 0;
      CPUID;
      If EAX >= 2 Then
        Begin
          EAX := 2;
          CPUID;
          vCPUId^.Cache1 := Byte4 (EAX);
          vCPUId^.Cache2 := Byte4 (EBX);
          vCPUId^.Cache3 := Byte4 (ECX);
          vCPUId^.Cache4 := Byte4 (EDX);
        End;

      EAX := $80000000;
      CPUID;
      vCPUId^.Ext8000_0000EAX := EAX;
      EAX := $80000001;
      CPUID;
      vCPUId^.Ext8000_0001EAX := EAX;
      vCPUID^.Ext8000_0001EDX := EDX;
      EAX := $80000002;
      CPUID;
      vCPUId^.AMDProcName1  := Chr4 (EAX);
      vCPUId^.AMDProcName2  := Chr4 (EBX);
      vCPUId^.AMDProcName3  := Chr4 (ECX);
      vCPUId^.AMDProcName4  := Chr4 (EDX);
      EAX := $80000003;
      CPUID;
      vCPUId^.AMDProcName5  := Chr4 (EAX);
      vCPUId^.AMDProcName6  := Chr4 (EBX);
      vCPUId^.AMDProcName7  := Chr4 (ECX);
      vCPUId^.AMDProcName8  := Chr4 (EDX);
      EAX := $80000004;
      CPUID;
      vCPUId^.AMDProcName9  := Chr4 (EAX);
      vCPUId^.AMDProcName10 := Chr4 (EBX);
      vCPUId^.AMDProcName11 := Chr4 (ECX);
      vCPUId^.AMDProcName12 := Chr4 (EDX);
      EAX := $80000005;
      CPUID;
      vCPUId^.Ext8000_0005EAX := Byte4 (EAX);
      vCPUId^.AMDCache1 := Byte4 (EBX);
      vCPUId^.AMDCache2 := Byte4 (ECX);
      vCPUId^.AMDCache3 := Byte4 (EDX);


      If Copyr = 'UMC UMC UMC ' Then vCPUId^.CopyRight := 'UMC'
        Else If Copyr = 'CyrixInstead' Then vCPUId^.CopyRight := 'Cyrix'
          Else If Copyr = 'AuthenticAMD' Then vCPUId^.CopyRight := 'AMD'
            Else If Copyr = 'GenuineIntel' Then vCPUId^.CopyRight := 'Intel'
              Else If Copyr = 'NexGenDriven' Then vCPUId^.CopyRight := 'NexGen'
                Else vCPUId^.CopyRight := '';

       TestCPUId := vCPUId;
    End
  Else
    TestCPUID := Ptr (0,0);
End;


Function CPUResetStr;

Begin
  If WhatCPU > dcpIn80386 Then
    If Not IsMSWProtMode Then
      Begin
        Case CPUReset Of
          $0005 : CPUResetStr := 'Cyrix M5 (Cx486S/D)';
          $0006 : CPUResetStr := 'Cyrix M6 (Cx486DX)';
          $0007 : CPUResetStr := 'Cyrix M7 (Cx486DX2)';
          $0008 : CPUResetStr := 'Cyrix M8 (Cx486DX4)';
          $0300 : CPUResetStr := 'C&T 38600/5 S/DX';
          $0303 : CPUResetStr := 'Intel 80386DX B0-B10';
          $0305 : CPUResetStr := 'Intel 80386DX D0/AMD 80386DX A';
          $0308 : CPUResetStr := 'Intel/AMD 80386DX D1/E0/F0';
          $0340 : CPUResetStr := 'Intel RapidCad Step A';
          $0341 : CPUResetStr := 'Intel RapidCad Step B';
          $03D5 : CPUResetStr := 'NexGen Nx585-100';
          $0400 : CPUResetStr := 'Intel 80486 DX A1';
          $0401 : CPUResetStr := 'Intel 80486 DX Bx';
          $0402 : CPUResetStr := 'Intel 80486 DX C0/AMD 486DX2';
          $0403 : CPUResetStr := 'Intel 80486DX';
          $0404 : CPUResetStr := 'Intel 80486DX D0';
          $0405..$040F : CPUResetStr := 'Intel 80486DX-Familie';
          $0410 : CPUResetStr := 'Intel 80486DX cA?/Cyrix 486SLC/TI486DLC/SLC A';
          $0411 : CPUResetStr := 'Intel 80486DX cB?/TI486DLC/SLC B';
          $0412 : CPUResetStr := 'AMD 80486DX-33/40';
          $0413 : CPUResetStr := 'Intel 80486DX cC0';
          $0414 : CPUResetStr := 'Intel 80486DX aA0';
          $0415 : CPUResetStr := 'Intel 80486DX aB0';
          $0416..$041F : CPUResetStr := 'Intel 80486DX50-Familie';
          $0420 : CPUResetStr := 'Intel 80486SX A0/Cyrix 486DLC';
          $0421 : CPUResetStr := 'Intel 80487SX B0';
          $0422 : CPUResetStr := 'Intel 80486SX B0';
          $0423 : CPUResetStr := 'Intel 80486SX D/UMC U5S(D)';
          $0424 : CPUResetStr := 'Intel 80486SX gAX';
          $0427 : CPUResetStr := 'Intel 80486SX cA0';
          $0428 : CPUResetStr := 'Intel 80486SX cB0';
          $042A : CPUResetStr := 'Intel 80486SX aA0/aA1/E';
          $042B : CPUResetStr := 'Intel 80486SX aB0/aC0';
          $042D : CPUResetStr := 'Cyrix Cx5x86';
          $042C..$042F : CPUResetStr := 'Intel 80486SX-Familie';
          $0432 : CPUResetStr := 'Intel/AMD 80486DX2/Overdrive A0-A2';
          $0433 : CPUResetStr := 'Intel 80486DX2 B1';
          $0434 : CPUResetStr := 'Intel 80486DX2 aA0/aA1';
          $0435 : CPUResetStr := 'Intel 80486DX2 aB0/aC0';
          $0436 : CPUResetStr := 'Intel 80486DX2WB A';
          $0430..$0431, $0437..$043F : CPUResetStr := 'Intel 80486DX2-Familie';
          $0440 : CPUResetStr := 'Intel 80486SL A';
          $0441..$044F : CPUResetStr := 'Intel 80486SL-Familie';
          $0450..$045A, $045C..$045F : CPUResetStr := 'Intel 80486SX2-Familie';
          $045B : CPUResetStr := 'Intel 80486SX2 aC0';
          $0471..$047F : CPUResetStr := 'Intel 80486DX2WB-Familie';
          $0470 : CPUResetStr := 'Intel 80486DX2WT A';
          $0480..$0482, $0485..$048F : CPUResetStr := 'Intel 80486DX4-Familie';
          $0483 : CPUResetStr := 'Intel 80486DX4WT';
          $0484 : CPUResetStr := 'Intel 80486DX4/AMD 486DX4WT';
          $0490 : CPUResetStr := 'Cyrix 5x86/Intel 80486DX4WB';
          $0491..$0493, $0495..$049F : CPUResetStr := 'Intel 80486DX4WB-Familie';
          $0494 : CPUResetStr := 'AMD 486DX4WB';
          $04E0..$04EF : CPUResetStr := 'AMD Am5x86WT';
          $04F0..$04FF : CPUResetStr := 'AMD Am5x86WB';
          $0500..$050F : CPUResetStr := 'Intel Pentium P5 A?';
          $0513 : CPUResetStr := 'Intel Pentium (P5) B1';
          $0515 : CPUResetStr := 'Intel Pentium (P5) C1';
          $0517 : CPUResetStr := 'Intel Pentium (P5) D1';
          $0521 : CPUResetStr := 'Intel Pentium P54C B1';
          $0522 : CPUResetStr := 'Intel Pentium P54C B3';
          $0524 : CPUResetStr := 'Intel Pentium P54C B5';
          $0525 : CPUResetStr := 'Intel Pentium P54C C1/C2/mA1/P54CQS/P54LM';
          $052B : CPUResetStr := 'Intel Pentium P54C cB1/mcB1';
          $1480 : CPUResetStr := 'Intel 80486DX4ODPR';
          $1531 : CPUResetStr := 'Intel Pentium Overdrive P24T B1/B2';
          $1532 : CPUResetStr := 'Intel Pentium Overdrive P24T C0';
          $1520..$152F : CPUResetStr := 'Intel Pentium Overdrive P24CT';
          $1540..$154F : CPUResetStr := 'Intel Pentium Overdrive P54T';
          $15F9 : CPUResetStr := 'NexGen Nx585-120 E2/C0';
          $15FB : CPUResetStr := 'NexGen Nx585-100 D1/B0';
          $1630..$163F : CPUResetStr := 'Overdrive fuer Socket 8 (P6T)';
          $2304 : CPUResetStr := 'Intel 80386SX A0';
          $2305 : CPUResetStr := 'Intel 80386SX D0/AMD 386SX(L) A1';
          $2308 : CPUResetStr := 'Intel 80386SX D1/AMD 386SX(L) B ';
          $2309 : CPUResetStr := 'Intel 80386CXSA/CXSB/EX/SXSA';
          $2540..$254F : CPUResetStr := 'Intel Pentium Overdrive P54M';
          $3305 : CPUResetStr := 'Intel 376 A0';
          $3308 : CPUResetStr := 'Intel 376 B';
          $4300 : CPUResetStr := 'Intel 80386 SL A0-A1';
          $4301 : CPUResetStr := 'Intel 80386 SL A2';
          $4302 : CPUResetStr := 'Intel 80386 SL A3';
          $4303 : CPUResetStr := 'Intel 80386 SL';
          $4310 : CPUResetStr := 'Intel 80386 SL A0-A3';
          $4311 : CPUResetStr := 'Intel 80386 SL B0-B1';
          $A400..$A40F : CPUResetStr := 'IBM 486SLC';
          $A410..$A41F : CPUResetStr := 'IBM 486SLC2 A?';
          $A420..$A42F : CPUResetStr := 'IBM 486SLC2 B?';
          $A480 : If GetCyrixReg (dreDIR0) = $1B Then
                    CPUResetStr := 'Cyrix 486DX2-V'
                  Else
                    CPUResetStr := 'IBM 80486BLDX2';
        Else
          Case Hi (CPUReset) Of
            $00 : CPUResetStr := '386DX Step A';
            $03 : CPUResetStr := '386DX-Familie';
            $04 : CPUResetStr := '486-Familie';
            $05 : CPUResetStr := 'Pentium-Familie';
            $06 : CPUResetStr := 'PentiumPro-Familie';
            $15 : CPUResetStr := 'Nexgen Nx586-Familie';
            $23 : CPUResetStr := '386SX-Familie';
            $43 : CPUResetStr := '386SL-Familie';
            $84 : CPUResetStr := 'IBM486BLX3-Familie';
            $A3 : CPUResetStr := '386SLC-Familie';
         Else
            CPUResetStr := 'unbekannt (' + Hex (CPUReset,4) + 'h)';
          End;
        End;
      End
    Else
      CPUResetStr := 'nur im Realmode'
  Else
    CPUResetStr := 'erst ab 80386''ern';
End;


Function GetCyrixReg;

Begin
  Port[$22] := Register;
  Asm
    Nop
    Nop
    Nop
  End;
  GetCyrixReg := Port[$23];
End;


Function CyrixId;

Begin
  If WhatCPU = dcpVarCyrix Then
    Begin
      Case GetCyrixReg (dreDIR0) Of
        $00 : CyrixId := 'Cx486SLC/e';
        $01 : CyrixId := 'Cx486DLC';
        $02 : CyrixId := 'Cx486SLC2';
        $03 : CyrixId := 'Cx486DLC2';
        $04 : CyrixId := 'Cx486SRx';
        $05 : CyrixId := 'Cx486DRx';
        $06 : CyrixId := 'Cx486SRx2';
        $07 : CyrixId := 'Cx486DRx2';
        $08 : CyrixId := 'Cx486SRu';
        $09 : CyrixId := 'Cx486DRu';
        $0A : CyrixId := 'Cx486SRu2';
        $0B : CyrixId := 'Cx486DRu2';
        $10 : CyrixId := 'Cx486S (B Step)';
        $11 : CyrixId := 'Cx486S2';
        $12 : CyrixId := 'Cx486S/e';
        $13 : CyrixId := 'Cx486S2/e';
        $14 : CyrixId := 'Cx486S/e';
        $15 : CyrixId := 'Cx486S2/e';
        $16 : CyrixId := 'Cx486S/e';
        $17 : CyrixId := 'Cx486S2/e';
        $1A : CyrixId := 'Cx486DX (M6)/BL486DX';
        $1B : CyrixId := 'Cx486DX2 (M7)/BL486DX2/ST486DX2/TI486DX2';
        $1F : CyrixId := 'Cx486DX4 (M9)';
        $20 : CyrixId := '„lterer Cx6x86-S (1x Clock-Mode)';
        $21 : CyrixId := '„lterer Cx6x86-S (2x Clock-Mode)';
        $22 : CyrixId := '„lterer Cx6x86-P (1x Clock-Mode)';
        $23 : CyrixId := '„lterer Cx6x86-P (2x Clock-Mode)';
        $24 : CyrixId := '„lterer Cx6x86-S (4x Clock-Mode)';
        $25 : CyrixId := '„lterer Cx6x86-S (3x Clock-Mode)';
        $26 : CyrixId := '„lterer Cx6x86-P (4x Clock-Mode)';
        $27 : CyrixId := '„lterer Cx6x86-P (3x Clock-Mode)';
        $28 : CyrixId := 'Cx5x86-S (1x Clock-Mode)';
        $29 : CyrixId := 'Cx5x86-S (2x Clock-Mode)';
        $2A : CyrixId := 'Cx5x86-P (1x Clock-Mode)';
        $2B : CyrixId := 'Cx5x86-P (2x Clock-Mode)';
        $2C : CyrixId := 'Cx5x86-S (4x Clock-Mode)';
        $2D : CyrixId := 'Cx5x86-S (3x Clock-Mode)';
        $2E : CyrixId := 'Cx5x86-P (4x Clock-Mode)';
        $2F : CyrixId := 'Cx5x86-P (3x Clock-Mode)';
        $30 : CyrixId := 'Cx6x86-S (1x Clock-Mode)';
        $31 : CyrixId := 'Cx6x86-S (2x Clock-Mode)';
        $32 : CyrixId := 'Cx6x86-P (1x Clock-Mode)';
        $33 : CyrixId := 'Cx6x86-P (2x Clock-Mode)';
        $34 : CyrixId := 'Cx6x86-S (4x Clock-Mode)';
        $35 : CyrixId := 'Cx6x86-S (3x Clock-Mode)';
        $36 : CyrixId := 'Cx6x86-P (4x Clock-Mode)';
        $37 : CyrixId := 'Cx6x86-P (3x Clock-Mode)';
        $81 : CyrixId := 'TI486DX4';
        $FD : CyrixId := 'Cyrix Overdrive';
        $FE : CyrixId := 'TI Potomac''s'
      Else
        If ((GetCyrixReg (dreDIR0) And Not(15)) Shr 4) = 1 Then CyrixId := 'Cx5x86 (M1SC)' Else
          If ((GetCyrixReg (dreDIR0) And Not(15)) Shr 4) = 2 Then CyrixId := 'Cx6x86 (M1)' Else
            CyrixId := 'unbekannter Cyrix/TI/ST/BL';
      End;
    End
  Else
    CyrixId := 'kein Cyrix-Chip';
End;


Procedure MSRReader (MSR : Word; var EAX, EDX : LongInt); Far; External;
{ Diese Routine noch NICHT benutzen !!! Sie ist weder dokumentiert, noch
  taucht sie in der Interface-Unit auf. Wenn man diese Funktion benutzt,
  kann es passieren, daá sich das System aufh„ngt !!! }
Procedure ReadMSR;

Begin
  If WhatCPU = dcpInPentium Then
    If Not IsMSWProtMode Then
      MSRReader (MSR, EAX, EDX)
  Else
    Begin
      EAX := 0;
      EDX := 0;
    End;
End;

Begin
End.