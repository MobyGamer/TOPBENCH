Unit DetectChipsets;
{ Diese Teilunit befasst sich mit den Chipsatzfamilien (Sis, Opti, Cyrix,
  Intel, ...). }

Interface

Function WhichChipset : Byte;

Implementation

Uses DetectSystem, DetectConstants, DetectGlobal, DetectBus,
     DetectProcessors;


Function WhichChipset;

  Function TestCyrixCPU : Byte;
  { Bei Cyrix haben die Prozessoren ihr eigenes Chipset. Das dÅrfte einfach
    mit WhatCPU zu erkennen sein ... }

  Begin
    If WhatCPU In [dcpVarCyrix] Then
      Case GetCyrixReg (dreDIR0) Of
        0..3   : TestCyrixCPU := dchCyrix486lc;
        4..$81 : TestCyrixCPU := dchCyrix486dx;
      Else
        If (((GetCyrixReg (dreDIR0) And Not(15)) Shr 4) = 1) Or (((GetCyrixReg (dreDIR0) And Not(15)) Shr 4) = 2) Then
          TestCyrixCPU := dchCyrix5_6x86;
      End
    Else
      TestCyrixCPU := dchUnknown;
  End;

  Function TestPCIChipset : Byte;
  { Ueber das PCI-Register kann man bequem den Chipsatz auslesen ...
    Natuerlich nur auf PCI-Rechnern :-( }

  Var PCIData : PCIHeader;

  Begin
    TestPCIChipset := dchUnknown;
    If BusType = dbuPCI Then
      Begin
        xByte2 := 0;
        Repeat
          If IsPCIDevice (xByte3, 0) Then GetPCIConfig (xByte3, 0, PCIData);
          If PCIData.VendorId = $8086 Then { Intel-Chipsaetze }
            Begin
              Case PCIData.DeviceId Of
                $0483 : Begin
                          TestPCIChipset := dchIntelSaturn;
                          xBool := True;
                        End;
                $0486 : Begin
                          TestPCIChipset := dchIntelPCISet;
                          xBool := True;
                        End;
                $04A3 : Begin
                          PortW[$CF8] := 8;
                          xByte3 := Port[$CFC];
                          Case xByte3 And $10 Of
                            0 : TestPCIChipset := dchIntelMercury;
                            1 : TestPCIChipset := dchIntelNeptun;
                          End;
                          xBool := True;
                        End;
                $122D : Begin
                          TestPCIChipset := dchIntelTriton;
                          xBool := True;
                        End;
                $1250 : Begin
                          TestPCIChipset := dchIntelTXC;
                          xBool := True;
                        End;
              End;
            End;

          If PCIData.VendorId = $1060 Then  { UMC-Chipsaetze }
            Begin
              Case PCIData.DeviceId Of
                $0881 : Begin
                          TestPCIChipset := dchUMC82C881HB4;
                          xBool := True;
                        End;
                $0891 : Begin
                          TestPCIChipset := dchUMC82C891;
                          xBool := True;
                        End;
                $0001, $8881 : Begin
                                 TestPCIChipset := dchUMC82C881;
                                 xBool := True;
                               End;
                $8891 : Begin
                          TestPCIChipset := dchUMC82C8891;
                          xBool := True;
                        End;
              End;
            End;

          If PCIData.VendorId = $1039 Then  { SiS-Chipsaetze }
            Begin
              Case PCIData.DeviceId Of
                 $0406 : Begin
                           TestPCIChipset := dchSis501;
                           xBool := True;
                         End;
                 $5511 : Begin
                           TestPCIChipset := dchSis5511;
                           xBool := True;
                         End;
              End;
            End;

          If PCIData.VendorId = $102A Then  { LSI Logic-Chipsaetze }
            Begin
              Case PCIData.DeviceId Of
                $0000 : Begin
                          TestPCIChipset := dchLSIHYDRA;
                          xBool := True;
                        End;
                $0010 : Begin
                          TestPCIChipset := dchLSIASPEN;
                          xBool := True;
                        End;
              End;
            End;

          If PCIData.VendorId = $1074 Then  { NexGen-ChipsÑtze }
            Begin
              Case PCIData.DeviceId Of
                $4E78 : Begin
                          TestPCIChipset := dchNexGenVL82C500;
                          xBool := True;
                        End;
              End;
            End;

          If (PCIData.VendorId = $10B9) Or (PCIData.VendorId = $1025) Then { Acer-ChipsÑtze }
            Begin
              Case PCIData.DeviceId Of
                $1451 : Begin
                          TestPCIChipset := dchAcerALIM1451;
                          xBool := True;
                        End;
                $1461 : Begin
                          TestPCIChipset := dchAcerALIM1461;
                          xBool := True;
                        End;
              End;
            End;

          If PCIData.VendorId = $10E0 Then  { IMS-ChipsÑtze }
            Begin
              Case PCIData.DeviceId Of
                $5026 : Begin
                          TestPCIChipset := dchIMSDiamond;
                          xBool := True;
                        End;
              End;
            End;

          If PCIData.VendorId = $1106 Then  { VIA-ChipsÑtze }
            Begin
              Case PCIData.DeviceId Of
                $0576, $1000 : Begin
                                 TestPCIChipset := dchVIAApollo;
                                 xBool := True;
                               End;
              End;
            End;

          Inc (xByte2);
        Until (xByte2 = $F) Or xBool;
      End;
  End;


  Function TestUMCChipset : Byte;
  { Der UMC-Chipsatz hat einen eigenen Adressraum ... }

  Begin
    TestUMCChipset := dchUnknown;
    Port [$22] := $90;
    xByte := Port [$24];
    Port [$22] := $98;
    xByte2 := Port [$24];
    If (xByte <> 0) And (xByte2 <> 0) Then  { Ja, es ist ein UMC ... }
      Begin
        Case xByte Shr 1 Of
          $01 : TestUMCChipSet := dchUM82C481A;
          $02 : TestUMCChipSet := dchUM82C391A;
        Else
        End;
      End;
  End;

Begin
  If TestCyrixCPU <> dchUnknown Then WhichChipSet := TestCyrixCPU Else
    If TestPCIChipset <> dchUnknown Then WhichChipSet := TestPCIChipset Else
      If TestUMCChipset <> dchUnknown Then WhichChipSet := TestUMCChipset Else
      WhichChipset := dchUnknown;
End;


Begin
End.