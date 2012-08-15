Unit DetectBus;
{ In dieser Unit stehen alle Routinen drin, die man zum Erkennen der
  verschiedenen Bus-Typen (ISA/EISA/MCA/PCI) braucht. }

Interface

Uses DetectGlobal;

Type PCIHeader = Record
       VendorId   : Word;    { Hersteller-ID                             }
       DeviceId   : Word;    { Device-ID                                 }
       Commands   : Word;    { Befehlsregister                           }
         { Bit     Bedeutung
           0       I/O Zugriff erlaubt
           1       Mem Zugriff erlaubt
           2       Alles erlaubt
           3       Spezielle Zyklus-Erkennung eingeschaltet
           4       Mem-Schreiben und 'Invalidate' erlaubt
           5       VGA-Palettensnoop aktiviert
           6       ParitÑtsfehlerantwort aktiv
           7       Wartezyklen aktiv
           8       Systemfehler (SERR# Leitung) aktiv
           9       Schneller 'back-to-back' Transaktionen erlaubt
           10-15   reserviert }
       Status     : Word;    { Statusregister                            }
         { Bit     Bedeutung
           0-4     Reserviert
           5       kann bei 66 Mhz laufen
           6       UDF unterstÅtzt
           7       FÑhig fÅr schnellen 'back-to-back' Transaktionen
           8       Data-Parity-Fehler wird gemeldet
           10-9    Device-Select-Timing
                   00 = schnell
                   01 = mittel
                   10 = langsam
                   11 = reserviert
           11      Zielabbruch signalisiert
           12      Zielabbruch empfangen
           13      VollstÑndiger Abbruch empfangen
           14      Systemfehler (SERR# Leitung) signalisiert
           15      Parity-Fehler ist aufgetreten }
       Revision   : Byte;    { Revisions-ID                              }
       Class3     : Byte;    { Classcode Level 3 : Programming Interface }
       Class2     : Byte;    { Classcode Level 2 : Sub-Class             }
       Class1     : Byte;    { Classcode Level 1 : Class                 }

         { Class 1 + 2 : $01     = Storage
                           $0100 = SCSI bus controller
                           $0101 = IDE controller
                           $0102 = Floppy controller
                           $0103 = IPI bus controller
                           $0180 = other mass storage controller
                         $02     = Network
                           $0200 = Ethernet controller
                           $0201 = Token ring controller
                           $0202 = FDDI controller
                           $0280 = other network controller
                         $03     = Display
                           $0300 = VGA display controller
                           $0301 = XGA display controller
                           $0380 = other display controller
                         $04     = Multimedia
                           $0400 = Video device
                           $0401 = Audio device
                           $0480 = other multimedia device
                         $05     = Memory
                           $0500 = RAM controller
                           $0501 = Flash controller
                           $0580 = other Memory controller
                         $06     = Bridge
                           $0600 = Host bridge
                           $0601 = ISA bridge
                           $0602 = EISA bridge
                           $0603 = MCA bridge
                           $0604 = PCI to PCI bridge
                           $0605 = PCMCIA bridge
                           $0680 = other bridge device
                         $07     = Communication
                           $0700 = serial controller
                           $0701 = parallel controller
                           $0780 = other communication controller
                         $08     = system
                           $0800 = PIC
                           $0801 = DMA controller
                           $0802 = timer
                           $0803 = RTC
                           $0880 = other system peripheral
                         $09     = input
                           $0900 = Keyboard controller
                           $0901 = Digitizer Pen
                           $0902 = Mouse controller
                           $0980 = other input device controller
                         $0A     = Docking
                           $0A00 = Generic Docking Station
                           $0A80 = other
                         $0B     = Processor
                           $0B00 = 386
                           $0B01 = 486
                           $0B02 = Pentium
                           $0B10 = Alpha
                           $0B20 = PowerPC
                           $0B40 = Co-Processor
                         $0C     = Serial
                           $0C00 = FireWire (IEEE 1394)
                           $0C01 = Access Bus
                           $0C02 = SSA
                           $0C03 = USB
                           $0C04 = Fiber Channel
                         $FF     = andere }

       CacheLS    : Byte;    { Cache-Line Size                           }
       Latency    : Byte;    { Latency Timer                             }
       Header     : Byte;    { Header-Typ (fÅr den spÑteren Verlauf)     }
         { Bits 6-0
             00h = andere
             01h = PCI-to-PCI bridge
           Bit 7
             Mehrfunktions-Device }
       SelfResult : Byte;    { Sebsttest-Ergebnis                        }
         { Bit(s)  Bedeutung
           3-0     Arbeit fertig (0000 = erfolgreich)
           5-4     reserviert
           6       Start BIST
           7       BIST wird unterstÅtzt }
       Base0      : LongInt; { Base-Adresse 0                            }
       Base1      : LongInt; { Base-Adresse 1                            }
       HeaderSpec : Array [0..150] Of Byte; { Je nach Header-Typ         }
     End;

     PCIHeader0 = Record
       Base2      : LongInt; { Base-Adresse 2                            }
       Base3      : LongInt; { Base-Adresse 3                            }
       Base4      : LongInt; { Base-Adresse 4                            }
       Base5      : LongInt; { Base-Adresse 5                            }
       CardBusCIS : LongInt; { CardBus CIS-Pointer                       }
       SubVendor  : Word;    { SubSystem Vendor-Id                       }
       SubSystem  : Word;    { SubSystem-Id                              }
       ExpROMBase : LongInt; { Expansion-ROM Base Adresse                }
       Reserved   : Array[1..2] Of LongInt;
       IntLine    : Byte;    { Interrup Line                             }
         { 0 = keine, 1 = IRQ1, 2=IRQ2, ..., F=IRQ15 }
       IntPin     : Byte;    { Interrupt Pin                             }
         { 0 = keiner, ansonsten INTA# bis INTD# }
       MTBNPBO    : Byte;    { Minimum time bus Master needs PCI bus
                               ownership (Sorry wegen englisch ...)      }
       MaxLatency : Byte;    { Hîchste Latency-Zeit in 250 ns Abschnitten
                               (nur Busmaster)                           }
     End;

     PCIHeader1 = Record
       PrimaryBus   : Byte;      { Erste Busnummer                       }
       SecondaryBus : Byte;      { Zweite Busnummer                      }
       SubOrdBus    : Byte;      { 'Subordinate' Busnummer               }
       SecondLat    : Byte;      { Zweiter Latency-Timer                 }
       IOBase       : Byte;      { I/O BAse Adresse                      }
       IOLimit      : Byte;      { Hîchste I/O Adresse                   }
       SecondStat   : Word;      { Zweiter Status                        }
       MemBase      : Word;      { Memory-Base Adresse                   }
       MemLimit     : Word;      { Hîchste Memory-Adresse                }
       PrefMemBase  : Word;      { 'Prefetchable' Memory-Base Adresse    }
       PrefMemLimit : Word;      { Hîchste 'Prefetchable' Memory Adresse }
       PrefMemB32   : LongInt;   { Obere 32 Bits von PrefMemBase         }
       PrefMemL32   : LongInt;   { Obere 32 Bits von PrefMemLimit        }
       IOBase16     : Word;      { Obere 16 Bits von IOBase              }
       IOLimit16    : Word;      { Obere 16 Bits von IOLimit             }
       Reserved     : LongInt;
       ExpROMBase   : LongInt;   { Expansion-ROM Base Adresse            }
       IntLine      : Byte;      { Interrup Line                         }
         { 0 = keine, 1 = IRQ1, 2=IRQ2, ..., F=IRQ15 }
       IntPin       : Byte;      { Interrupt Pin                         }
         { 0 = keiner, ansonsten INTA# bis INTD# }
       BridgeCtrl   : Word;      { 'Bridge'-Kontrolle                    }
     End;

Function BusType                                : Byte;

Function EISAIsID (SlotNumber : Byte)           : Byte;
Function EISASlotType (SlotNumber : Byte)       : String;
Function EISAConfigVersion (SlotNumber : Byte)  : String;
Function EISAConfigCheckSum (SlotNumber : Byte) : Word;
Function EISANumDevFunc (SlotNumber : Byte)     : Byte;
Function EISAId (SlotNumber : Byte)             : String;

Function  IsPCIDevice (Device, Bus : Byte)  : Boolean;
Function  GetPCIVendor (VendorId : Word) : String;
Function  IdentifyPCIDevice (VendorID, DeviceID : Word; Revision : Byte) : String;
Function  IdentifyPCIClass (ClassId : Byte) : String;
Function  IdentifyPCISubClass (ClassId, SubClassId : Byte) : String;
Procedure GetPCIConfig (Device, Bus : Byte; Var Data : PCIHeader);

Implementation

Uses DetectConstants, Dos;

Const
   EISAErrs : Array [$80 .. $87] Of String = ('Kein Slot', '',
             'EISA CMOS kaputt', 'Freier Slot', '', '', 'BIOS-Fehler',
             'Falsche Systemkonfiguration');

Var
  PCITemp : Array [0..106] Of Word;

Function BusType;

  Function IsPCI : Boolean;

  Begin
    Regs.AX := $B101;
    Regs.Flags := Regs.Flags And FCarry;
    Intr ($1A, Regs);
    IsPCI := ((Regs.AH = 0) And (Regs.Flags And FCarry = 0) And
      (Regs.DX = $4350));
  End;


  Function IsVL : Boolean;

  Const
    VLBStrings : Array [1 .. 4] Of String[15] = ('VLB','VL-BUS','LOCAL','VL');

  Var
    InfoStr1, InfoStr2 : String[255];
    VZaehl             : Word;
    Vi                 : Byte;

  Begin
    InfoStr1 := '';
    InfoStr2 := '';
    IsVL := False;
    For VZaehl := $0000 To $00F8 Do
      InfoStr1 := InfoStr1 + Char (Mem[$C000:VZaehl]);
    For VZaehl := $00F8 To $01F0 Do
      InfoStr2 := InfoStr2 + Char (Mem[$C000:VZaehl]);
    For Vi := 1 To 4 Do
      Begin
        If (Pos (UpCaseString (VLBStrings[vi]), UpCaseString (InfoStr1)) > 0) Or
           (Pos (UpCaseString (VLBStrings[vi]), UpCaseString (InfoStr2)) > 0) Then
             IsVL := True;
      End;
  End;


  Function IsMicroChannel : Boolean;

  Begin
    Regs.AH := $C0;
    Regs.ES := 0;
    Regs.BX := 0;
    Regs.Flags := Regs.Flags and FCarry;
    Intr ($15, regs);
    xByte := Mem[Regs.ES:Regs.BX + 5];
    IsMicroChannel := (xbyte And $02 = $02);
  End;


  Function IsEISA : Boolean;

  Begin
    For xWord := 0 To $FF Do
      Begin
        xBool := False;
        Regs.AX := $D800;
        Regs.BX := $0000;
        Regs.CL := xWord;
        Regs.Flags := Regs.Flags And FCarry;
        Intr ($15, Regs);
        If (((Regs.Flags And FCarry) = 0) And (Regs.AH = $00) And
           (Regs.BX <> $0000)) Then xBool := True;
      End;
    IsEISA := xBool;
  End;


  Function IsISA : Boolean;

  Begin
    IsISA := True; { Dummy }
  End;

Begin
  If IsPCI Then BusType := dbuPCI Else
    If IsVL Then BusType := dbuVL Else
      If IsMicroChannel Then BusType := dbuMCA Else
        If IsEISA Then BusType := dbuEISA Else
          If IsISA Then BusType := dbuISA Else
            BusType := dbuUnknown;
End;


Function EISAIsID;

Begin
  If BusType = dbuEISA Then
    Begin
      Regs.AX := $D800;
      Regs.CL := SlotNumber;
      Regs.Flags := Regs.Flags And FCarry;
      Intr ($15, Regs);
      If ((Regs.Flags And FCarry) = 0) Then
        Begin
          If ((Regs.AL And $40) = 1) Then EisaIsId := deiYes Else EisaIsId :=
            deiNo;
        End
      Else
        Begin
          Case Regs.AH Of
            $80 : EISAIsId := deiErrInvalidSlot;
            $82 : EISAIsId := deiErrEISACMOSCorrupt;
            $83 : EISAIsId := deiErrEmptySlot;
            $86 : EISAIsId := dalError;
            $87 : EISAIsId := deiErrInvalidSysConfig;
          Else
            EISAIsId := dalError;
          End;
        End;
    End
  Else
    EISAIsId := dalError;
End;


Function EISASlotType;

Begin
  If BusType = dbuEISA Then
    Begin
      Regs.AX := $D800;
      Regs.CL := SlotNumber;
      Regs.Flags := Regs.Flags And FCarry;
      Intr ($15, Regs);
      If ((Regs.Flags And FCarry) = 0) Then
        Begin
          If (((Regs.AL And $10) = 0) And ((Regs.AL And $20) = 0)) Then
            EISASlotType := 'Expansion Slot' Else
              If (((Regs.AL And $10) = 0) And ((Regs.AL And $20) = 1)) Then
                EISASlotType := 'Embedded Slot' Else
                  If (((Regs.AL And $10) = 1) And ((Regs.AL And $20) = 0)) Then
                    EISASlotType := 'Virtual Device' Else
                      EISASlotType := 'Unbekannt';
        End
      Else
        Begin
          EisaSlotType := EISAErrs[Regs.AH];
        End;
    End
  Else
    EISASlotType := NA;
End;


Function EISAConfigVersion;

Begin
  If BusType = dbuEISA Then
    Begin
      Regs.AX := $D800;
      Regs.CL := SlotNumber;
      Regs.Flags := Regs.Flags And FCarry;
      Intr ($15, Regs);
      If ((Regs.Flags And FCarry) = 0) Then
        Begin
          EisaConfigVersion := StrFnByte (Regs.BH) + '.' + ZeroPad (Regs.BL);
        End
      Else
        Begin
          EisaConfigVersion := EISAErrs[Regs.AH];
        End;
    End
  Else
    EISAConfigVersion := NA;
End;


Function EISAConfigCheckSum;

Begin
  If BusType = dbuEISA Then
    Begin
      Regs.AX := $D800;
      Regs.CL := SlotNumber;
      Regs.Flags := Regs.Flags And FCarry;
      Intr ($15, Regs);
      If ((Regs.Flags And FCarry) = 0) Then
        Begin
          EisaConfigCheckSum := Regs.CX;
        End
      Else
        Begin
          EisaConfigCheckSum := 0;
        End;
    End
  Else
    EISAConfigCheckSum := 0;
End;


Function EISANumDevFunc;

Begin
  If BusType = dbuEISA Then
    Begin
      Regs.AX := $D800;
      Regs.CL := SlotNumber;
      Regs.Flags := Regs.Flags And FCarry;
      Intr ($15, Regs);
      If ((Regs.Flags And FCarry) = 0) Then
        Begin
          EisaNumDevFunc := Regs.DH;
        End
      Else
        Begin
          EisaNumDevFunc := 0;
        End;
    End
  Else
    EISANumDevFunc := 0;
End;


Function EISAId;

Begin
  If BusType = dbuEISA Then
    Begin
      Regs.AX := $D800;
      Regs.CL := SlotNumber;
      Regs.Flags := Regs.Flags And FCarry;
      Intr ($15, Regs);
      If ((Regs.Flags And FCarry) = 0) Then
        Begin
          EisaId := Hex (Regs.DI, 4) + Hex (Regs.SI, 4) + 'h';
        End
      Else
        Begin
          EisaId := EISAErrs[Regs.AH];
        End;
    End
  Else
    EISAId := NA;
End;


Function GetPCIVendor (VendorId : Word) : String;

Begin
  Case VendorId Of
    $003D : GetPCIVendor := 'Martin-Marietta Corporation';
    $0E11 : GetPCIVendor := 'Compaq';
    $1000 : GetPCIVendor := 'NCR';
    $1002 : GetPCIVendor := 'ATI';
    $1003 : GetPCIVendor := 'ULSI Systems';
    $1004 : GetPCIVendor := 'VLSI Technologies';
    $1005 : GetPCIVendor := 'Avance Logics (ADL)';
    $1006 : GetPCIVendor := 'Reply Group';
    $1007 : GetPCIVendor := 'Netframe Systems Inc.';
    $1008 : GetPCIVendor := 'Epson';
    $100A : GetPCIVendor := 'Phoenix Technologies';
    $100B : GetPCIVendor := 'National Semiconductor';
    $100C : GetPCIVendor := 'Tseng Labs';
    $100D : GetPCIVendor := 'AST Research';
    $100E : GetPCIVendor := 'Weitek';
    $1010 : GetPCIVendor := 'Video Logic Ltd';
    $1011 : GetPCIVendor := 'DEC';
    $1012 : GetPCIVendor := 'Micronics Computers';
    $1013 : GetPCIVendor := 'Cirrus Logic';
    $1014 : GetPCIVendor := 'IBM';
    $1015 : GetPCIVendor := 'LSI Logic Corporation of Canada';
    $1016 : GetPCIVendor := 'ICL Personal Systems';
    $1017 : GetPCIVendor := 'SPEA Software AG';
    $1018 : GetPCIVendor := 'Unisys';
    $1019 : GetPCIVendor := 'EliteGroup Computer Sys';
    $101A : GetPCIVendor := 'NCR';
    $101B : GetPCIVendor := 'Vitesse';
    $101C : GetPCIVendor := 'Western Digital';
    $101E : GetPCIVendor := 'AMI';
    $101F : GetPCIVendor := 'Picturetel';
    $1020 : GetPCIVendor := 'Hitachi';
    $1021 : GetPCIVendor := 'Oki';
    $1022 : GetPCIVendor := 'Advanced Micro Devices';
    $1023 : GetPCIVendor := 'Trident';
    $1024 : GetPCIVendor := 'Zenith Data Systems';
    $1025 : GetPCIVendor := 'Acer';
    $1028 : GetPCIVendor := 'Dell';
    $1029 : GetPCIVendor := 'Siemens Nixdorf';
    $102A : GetPCIVendor := 'LSI Logic';
    $102B : GetPCIVendor := 'Matrox';
    $102C : GetPCIVendor := 'Chips & Technologies';
    $102D : GetPCIVendor := 'Wyse';
    $102E : GetPCIVendor := 'Olivetti';
    $102F : GetPCIVendor := 'Toshiba';
    $1030 : GetPCIVendor := 'TMC';
    $1031 : GetPCIVendor := 'Miro';
    $1032 : GetPCIVendor := 'Compaq';
    $1033 : GetPCIVendor := 'NEC';
    $1034 : GetPCIVendor := 'Burndy';
    $1035 : GetPCIVendor := 'Computers and Communications Research Lab';
    $1036 : GetPCIVendor := 'Future Domain';
    $1037 : GetPCIVendor := 'Hitachi Micro Systems';
    $1038 : GetPCIVendor := 'AMP';
    $1039 : GetPCIVendor := 'SiS';
    $103A : GetPCIVendor := 'Seiko Epson';
    $103B : GetPCIVendor := 'Tatung';
    $103C : GetPCIVendor := 'Hewlett-Packard';
    $103E : GetPCIVendor := 'Solliday';
    $103F : GetPCIVendor := 'Logic Modeling';
    $1040 : GetPCIVendor := 'Kubota Pacific';
    $1041 : GetPCIVendor := 'Computrend';
    $1042 : GetPCIVendor := 'PC Technology';
    $1043 : GetPCIVendor := 'Asustek';
    $1044 : GetPCIVendor := 'Distributed Processing Technology (DPT)';
    $1045 : GetPCIVendor := 'OPTi';
    $1046 : GetPCIVendor := 'IPC Corporation, Ltd.';
    $1047 : GetPCIVendor := 'Genoa';
    $1048 : GetPCIVendor := 'Elsa';
    $1049 : GetPCIVendor := 'Fountain';
    $104A : GetPCIVendor := 'SGS Thomson';
    $104B : GetPCIVendor := 'BusLogic';
    $104C : GetPCIVendor := 'Texas Instruments';
    $104D : GetPCIVendor := 'Sony';
    $104E : GetPCIVendor := 'Oak';
    $104F : GetPCIVendor := 'Co-Time';
    $1050 : GetPCIVendor := 'Winbond';
    $1051 : GetPCIVendor := 'Anigma';
    $1052 : GetPCIVendor := 'Young';
    $1054 : GetPCIVendor := 'Hitachi, Ltd.';
    $1055 : GetPCIVendor := 'EFAR Microsystems';
    $1056 : GetPCIVendor := 'ICL';
    $1057 : GetPCIVendor := 'Motorola';
    $1058 : GetPCIVendor := 'Electronics and Telec. RSH';
    $1059 : GetPCIVendor := 'Teknor';
    $105A : GetPCIVendor := 'Promise';
    $105B : GetPCIVendor := 'Foxconn';
    $105C : GetPCIVendor := 'Wipro';
    $105D : GetPCIVendor := 'Number9';
    $105E : GetPCIVendor := 'VTech';
    $105F : GetPCIVendor := 'Infotronic';
    $1060 : GetPCIVendor := 'UMC';
    $1061 : GetPCIVendor := 'X Tech';
    $1062 : GetPCIVendor := 'Maspar';
    $1063 : GetPCIVendor := 'Ocean';
    $1064 : GetPCIVendor := 'Alcatel';
    $1065 : GetPCIVendor := 'Texas Micro';
    $1066 : GetPCIVendor := 'PicoPower';
    $1067 : GetPCIVendor := 'Mitsubishi';
    $1068 : GetPCIVendor := 'Diversified';
    $1069 : GetPCIVendor := 'Mylex';
    $106A : GetPCIVendor := 'Aten';
    $106B : GetPCIVendor := 'Apple';
    $106C : GetPCIVendor := 'Hyundai';
    $106D : GetPCIVendor := 'Sequent';
    $106E : GetPCIVendor := 'DFI';
    $106F : GetPCIVendor := 'City Gate';
    $1070 : GetPCIVendor := 'Daewoo';
    $1071 : GetPCIVendor := 'Mitac';
    $1072 : GetPCIVendor := 'GIT';
    $1073 : GetPCIVendor := 'Yamaha';
    $1074 : GetPCIVendor := 'NexGen';
    $1075 : GetPCIVendor := 'Advanced Integration';
    $1076 : GetPCIVendor := 'Chaintech';
    $1077 : GetPCIVendor := 'Q Logic';
    $1078 : GetPCIVendor := 'Cyrix';
    $1079 : GetPCIVendor := 'I-Bus';
    $107A : GetPCIVendor := 'Networth';
    $107B : GetPCIVendor := 'Gateway 2000';
    $107C : GetPCIVendor := 'Goldstar';
    $107D : GetPCIVendor := 'Leadtek';
    $107E : GetPCIVendor := 'Interphase';
    $107F : GetPCIVendor := 'DTC';
    $1080 : GetPCIVendor := 'Contaq';
    $1081 : GetPCIVendor := 'Supermac';
    $1082 : GetPCIVendor := 'EFA';
    $1083 : GetPCIVendor := 'Forex';
    $1084 : GetPCIVendor := 'Parador';
    $1085 : GetPCIVendor := 'Tulip';
    $1086 : GetPCIVendor := 'J. Bond';
    $1087 : GetPCIVendor := 'Cache';
    $1088 : GetPCIVendor := 'Microcomputer Systems';
    $1089 : GetPCIVendor := 'Data General';
    $108A : GetPCIVendor := 'Bit3';
    $108C : GetPCIVendor := 'lonex';
    $108D : GetPCIVendor := 'Olicom';
    $108E : GetPCIVendor := 'Sun Micro Systems';
    $108F : GetPCIVendor := 'Systemsoft';
    $1090 : GetPCIVendor := 'Encore';
    $1091 : GetPCIVendor := 'Intergraph';
    $1092 : GetPCIVendor := 'Diamond';
    $1093 : GetPCIVendor := 'National Instruments';
    $1094 : GetPCIVendor := 'FIC';
    $1095 : GetPCIVendor := 'CMD Technology';
    $1096 : GetPCIVendor := 'Alacron';
    $1097 : GetPCIVendor := 'Appian';
    $1098 : GetPCIVendor := 'Vision';
    $1099 : GetPCIVendor := 'Samsung';
    $109A : GetPCIVendor := 'Packard Bell';
    $109B : GetPCIVendor := 'Gemlight';
    $109C : GetPCIVendor := 'Megachips';
    $109D : GetPCIVendor := 'Zida';
    $109E : GetPCIVendor := 'Brooktree';
    $109F : GetPCIVendor := 'Trigem';
    $10A0 : GetPCIVendor := 'Meidensha';
    $10A1 : GetPCIVendor := 'Juko';
    $10A2 : GetPCIVendor := 'Quantum';
    $10A3 : GetPCIVendor := 'Everex';
    $10A4 : GetPCIVendor := 'Globe';
    $10A5 : GetPCIVendor := 'Racal Interlan';
    $10A6 : GetPCIVendor := 'Informtech';
    $10A7 : GetPCIVendor := 'Benchmarq';
    $10A8 : GetPCIVendor := 'Sierra';
    $10A9 : GetPCIVendor := 'Silicon Graphics';
    $10AA : GetPCIVendor := 'ACC';
    $10AB : GetPCIVendor := 'Digicom';
    $10AC : GetPCIVendor := 'Honeywell';
    $10AD : GetPCIVendor := 'Symphony';
    $10AE : GetPCIVendor := 'Cornerstone';
    $10AF : GetPCIVendor := 'Microcomputer Systems';
    $10B0 : GetPCIVendor := 'CardExpert';
    $10B1 : GetPCIVendor := 'Cabletron';
    $10B2 : GetPCIVendor := 'Raytheon';
    $10B3 : GetPCIVendor := 'Databook';
    $10B4 : GetPCIVendor := 'STB';
    $10B5 : GetPCIVendor := 'PLX Technology';
    $10B6 : GetPCIVendor := 'Madge Networks';
    $10B7 : GetPCIVendor := '3com';
    $10B8 : GetPCIVendor := 'Standard Microsystems Corporation (SMC)';
    $10B9 : GetPCIVendor := 'Acer Labs';
    $10BA : GetPCIVendor := 'Mitsubishi';
    $10BB : GetPCIVendor := 'Dapha';
    $10BC : GetPCIVendor := 'ALR';
    $10BD : GetPCIVendor := 'Surecom';
    $10BE : GetPCIVendor := 'Tseng Labs';
    $10BF : GetPCIVendor := 'Most Inc.';
    $10C0 : GetPCIVendor := 'Boca Research';
    $10C1 : GetPCIVendor := 'ICM';
    $10C2 : GetPCIVendor := 'Auspex';
    $10C3 : GetPCIVendor := 'Samsung';
    $10C4 : GetPCIVendor := 'Award';
    $10C5 : GetPCIVendor := 'Xerox';
    $10C6 : GetPCIVendor := 'Rambus';
    $10C7 : GetPCIVendor := 'Media Vision';
    $10C8 : GetPCIVendor := 'Neomagic';
    $10C9 : GetPCIVendor := 'DataExpert';
    $10CA : GetPCIVendor := 'Fujitsu';
    $10CB : GetPCIVendor := 'Omron';
    $10CC : GetPCIVendor := 'Mentor';
    $10CD : GetPCIVendor := 'Advanced System Products';
    $10CE : GetPCIVendor := 'Radius';
    $10CF : GetPCIVendor := 'Citicorp';
    $10D0 : GetPCIVendor := 'Fujitsu';
    $10D1 : GetPCIVendor := 'Future+';
    $10D2 : GetPCIVendor := 'Molex';
    $10D3 : GetPCIVendor := 'Jabil';
    $10D4 : GetPCIVendor := 'Hualon';
    $10D5 : GetPCIVendor := 'Autologic';
    $10D6 : GetPCIVendor := 'Cetia';
    $10D7 : GetPCIVendor := 'BCM';
    $10D8 : GetPCIVendor := 'Advanced Peripherals';
    $10D9 : GetPCIVendor := 'Macronix';
    $10DA : GetPCIVendor := 'Thomas-Conrad';
    $10DB : GetPCIVendor := 'Rohm';
    $10DC : GetPCIVendor := 'CERN/ECP/EDU';
    $10DD : GetPCIVendor := 'Evans & Sutherland';
    $10DE : GetPCIVendor := 'NVidia';
    $10DF : GetPCIVendor := 'Emulex';
    $10E0 : GetPCIVendor := 'IMS';
    $10E1 : GetPCIVendor := 'TekRAM';
    $10E2 : GetPCIVendor := 'Aptix';
    $10E3 : GetPCIVendor := 'Newbridge';
    $10E4 : GetPCIVendor := 'Tandem';
    $10E5 : GetPCIVendor := 'Micro Industries';
    $10E6 : GetPCIVendor := 'Gainbery';
    $10E7 : GetPCIVendor := 'Vadem';
    $10E8 : GetPCIVendor := 'Applied Micro';
    $10E9 : GetPCIVendor := 'ALPS';
    $10EA : GetPCIVendor := 'Integraphics';
    $10EB : GetPCIVendor := 'Artists';
    $10EC : GetPCIVendor := 'Realtek';
    $10ED : GetPCIVendor := 'ASCII Corporation';
    $10EE : GetPCIVendor := 'Xilinx';
    $10EF : GetPCIVendor := 'Racore';
    $10F0 : GetPCIVendor := 'Peritek';
    $10F1 : GetPCIVendor := 'Tyan';
    $10F2 : GetPCIVendor := 'Achme';
    $10F3 : GetPCIVendor := 'Alaris';
    $10F4 : GetPCIVendor := 'S-MOS Systems';
    $10F5 : GetPCIVendor := 'NKK';
    $10F6 : GetPCIVendor := 'Creative Electronic';
    $10F7 : GetPCIVendor := 'Matsushita';
    $10F8 : GetPCIVendor := 'Altos';
    $10F9 : GetPCIVendor := 'PC Direct';
    $10FA : GetPCIVendor := 'Truevision';
    $10FB : GetPCIVendor := 'Thesys';
    $10FC : GetPCIVendor := 'I/O Data Devices';
    $10FD : GetPCIVendor := 'Soyo';
    $10FE : GetPCIVendor := 'Fast';
    $10FF : GetPCIVendor := 'N-Cube';
    $1100 : GetPCIVendor := 'Jazz';
    $1101 : GetPCIVendor := 'Initio';
    $1102 : GetPCIVendor := 'Creative Labs';
    $1103 : GetPCIVendor := 'Triones';
    $1104 : GetPCIVendor := 'Rasterops';
    $1105 : GetPCIVendor := 'Sigma';
    $1106 : GetPCIVendor := 'VIA';
    $1107 : GetPCIVendor := 'Stratus';
    $1108 : GetPCIVendor := 'Proteon';
    $1109 : GetPCIVendor := 'Cogent Data Technologies';
    $110A : GetPCIVendor := 'Siemens Nixdorf Informationssysteme';
    $110B : GetPCIVendor := 'Xenon';
    $110C : GetPCIVendor := 'Mini-Max';
    $110D : GetPCIVendor := 'ZNyX';
    $110E : GetPCIVendor := 'CPU Tech';
    $110F : GetPCIVendor := 'Ross';
    $1110 : GetPCIVendor := 'Powerhouse';
    $1111 : GetPCIVendor := 'S.C.O.';
    $1112 : GetPCIVendor := 'Rockwell';
    $1113 : GetPCIVendor := 'Accton';
    $1114 : GetPCIVendor := 'Atmel';
    $1115 : GetPCIVendor := 'DuPont';
    $1116 : GetPCIVendor := 'Data Translation';
    $1117 : GetPCIVendor := 'Datacube';
    $1118 : GetPCIVendor := 'Berg';
    $1119 : GetPCIVendor := 'Vortex';
    $111A : GetPCIVendor := 'Efficient Networks, Inc.';
    $111B : GetPCIVendor := 'Teledyne';
    $111C : GetPCIVendor := 'Tricord Systems, Inc.';
    $111D : GetPCIVendor := 'Integrated Device Tech';
    $111E : GetPCIVendor := 'Eldec Corporation';
    $111F : GetPCIVendor := 'Precision Digital Images';
    $1120 : GetPCIVendor := 'Emc Corporation';
    $1121 : GetPCIVendor := 'Zilog';
    $1122 : GetPCIVendor := 'Multi-tech Systems, Inc.';
    $1124 : GetPCIVendor := 'Leutron Vision AG';
    $1125 : GetPCIVendor := 'Eurocore';
    $1126 : GetPCIVendor := 'Vigra';
    $1127 : GetPCIVendor := 'FORE Systems';
    $1129 : GetPCIVendor := 'Firmworks';
    $112A : GetPCIVendor := 'Hermes Electronics Co.';
    $112B : GetPCIVendor := 'Linotype - Hell AG';
    $112D : GetPCIVendor := 'Ravicad';
    $112E : GetPCIVendor := 'Infomedia MicroElectronics Inc';
    $112F : GetPCIVendor := 'Imaging Technology';
    $1130 : GetPCIVendor := 'Computervision';
    $1131 : GetPCIVendor := 'Philips Semiconductors';
    $1132 : GetPCIVendor := 'Mitel Corp';
    $1133 : GetPCIVendor := 'Eicon Technology Corporation';
    $1134 : GetPCIVendor := 'Mercury Computer Systems Inc';
    $1135 : GetPCIVendor := 'Fuji Xerox Co Ltd';
    $1136 : GetPCIVendor := 'Momentum Data Systems';
    $1137 : GetPCIVendor := 'Cisco Systems Inc';
    $1138 : GetPCIVendor := 'Ziatech Corporation';
    $1139 : GetPCIVendor := 'Dynamic Pictures Inc';
    $113A : GetPCIVendor := 'FWB Inc';
    $113C : GetPCIVendor := 'Cyclone Micro';
    $113D : GetPCIVendor := 'Leading Edge Products Inc';
    $113E : GetPCIVendor := 'Sanyo Electric Co';
    $113F : GetPCIVendor := 'Equinox Systems';
    $1140 : GetPCIVendor := 'Intervoice Inc';
    $1141 : GetPCIVendor := 'Crest Microsystem Inc';
    $1142 : GetPCIVendor := 'Alliance Semiconductor Corp';
    $1143 : GetPCIVendor := 'Netpower, Inc.';
    $1144 : GetPCIVendor := 'Cincinnati Milacron';
    $1145 : GetPCIVendor := 'Workbit Corp';
    $1146 : GetPCIVendor := 'Force Computers';
    $1147 : GetPCIVendor := 'Interface Corp.';
    $1148 : GetPCIVendor := 'Schneider & Koch Co.';
    $1149 : GetPCIVendor := 'Win System Corporation';
    $114A : GetPCIVendor := 'Vmic';
    $114B : GetPCIVendor := 'Canopus Co.';
    $114C : GetPCIVendor := 'Annabooks';
    $114D : GetPCIVendor := 'IC Corporation';
    $114E : GetPCIVendor := 'Nikon Systems Inc';
    $114F : GetPCIVendor := 'Digi International';
    $1150 : GetPCIVendor := 'Thinking Machines Corp.';
    $1151 : GetPCIVendor := 'JAE Electronics Inc.';
    $1152 : GetPCIVendor := 'Megatek';
    $1153 : GetPCIVendor := 'Land Win Electronic Corp.';
    $1154 : GetPCIVendor := 'Melco Inc.';
    $1155 : GetPCIVendor := 'Pine Technology Ltd.';
    $1156 : GetPCIVendor := 'Periscope Engineering';
    $1157 : GetPCIVendor := 'Avsys Corporation';
    $1158 : GetPCIVendor := 'Voarx R&D Inc.';
    $1159 : GetPCIVendor := 'MuTech';
    $115A : GetPCIVendor := 'Harlequin Ltd.';
    $115B : GetPCIVendor := 'Parallax Graphics';
    $115D : GetPCIVendor := 'Xircom';
    $115E : GetPCIVendor := 'Peer Protocols Inc.';
    $1160 : GetPCIVendor := 'Megasoft Inc.';
    $1161 : GetPCIVendor := 'PFU Ltd.';
    $1162 : GetPCIVendor := 'OA Laboratory Co. Ltd.';
    $1164 : GetPCIVendor := 'Advanced Peripherals Tech';
    $1165 : GetPCIVendor := 'Imgraph Corporation';
    $1166 : GetPCIVendor := 'Pequr Technology Inc.';
    $1167 : GetPCIVendor := 'Mutoh Industries Inc.';
    $1168 : GetPCIVendor := 'Thine Electronics Inc.';
    $116A : GetPCIVendor := 'Polaris Communications';
    $116B : GetPCIVendor := 'Connectware Inc.';
    $116F : GetPCIVendor := 'Workstation Technology';
    $1170 : GetPCIVendor := 'Inventec Corporation';
    $1171 : GetPCIVendor := 'Loughborough Sound Images';
    $1172 : GetPCIVendor := 'Altera Corporation';
    $1173 : GetPCIVendor := 'Adobe Systems';
    $1174 : GetPCIVendor := 'Bridgeport Machines';
    $1175 : GetPCIVendor := 'Mitron Computer Inc.';
    $1176 : GetPCIVendor := 'SBE';
    $1177 : GetPCIVendor := 'Silicon Engineering';
    $1178 : GetPCIVendor := 'Alfa Inc.';
    $1179 : GetPCIVendor := 'Toshiba America Info Systems';
    $117A : GetPCIVendor := 'A-Trend Technology';
    $117C : GetPCIVendor := 'Atto Technology';
    $117E : GetPCIVendor := 'T/R Systems';
    $1180 : GetPCIVendor := 'Ricoh Co. Ltd.';
    $1181 : GetPCIVendor := 'Telematics International';
    $1183 : GetPCIVendor := 'Fujikura Ltd.';
    $1184 : GetPCIVendor := 'Forks Inc.';
    $1185 : GetPCIVendor := 'Dataworld';
    $1186 : GetPCIVendor := 'D-Link System Inc.';
    $1187 : GetPCIVendor := 'Advanced Technology Laboratories';
    $1188 : GetPCIVendor := 'Shima Seiki Manufacturing Ltd.';
    $1189 : GetPCIVendor := 'Matsushita Electronics';
    $118A : GetPCIVendor := 'Hilevel Technology';
    $118C : GetPCIVendor := 'Corollary Inc.';
    $118D : GetPCIVendor := 'Bitflow Inc.';
    $118E : GetPCIVendor := 'Hermstedt GmbH';
    $1191 : GetPCIVendor := 'Artop Electric';
    $1192 : GetPCIVendor := 'Densan C. Ltd.';
    $1193 : GetPCIVendor := 'Zeinet';
    $1194 : GetPCIVendor := 'Toucan Technology';
    $1195 : GetPCIVendor := 'Ratoc Systems Inc.';
    $1196 : GetPCIVendor := 'Hytec electronics Ltd.';
    $1197 : GetPCIVendor := 'Gage Applied Sciences Inc.';
    $1198 : GetPCIVendor := 'Lambda Systems Inc.';
    $1199 : GetPCIVendor := 'Digital Communications Associates Inc.';
    $119A : GetPCIVendor := 'Mind Share Inc.';
    $119B : GetPCIVendor := 'Omega Micro Inc.';
    $119C : GetPCIVendor := 'Information Technology Institute';
    $119D : GetPCIVendor := 'Bug Sapporo Japan';
    $119E : GetPCIVendor := 'Fujitsu';
    $119F : GetPCIVendor := 'Bull Hn Information Systems';
    $11A0 : GetPCIVendor := 'Convex Computer Corporation';
    $11A1 : GetPCIVendor := 'Hamatsu Photonics K. K.';
    $11A2 : GetPCIVendor := 'Sierra Research and Technology';
    $11A4 : GetPCIVendor := 'Barco';
    $11A5 : GetPCIVendor := 'MicroUnity Systems Engineering Inc.';
    $11A6 : GetPCIVendor := 'Pure Data';
    $11A7 : GetPCIVendor := 'Power Computing Corporation';
    $11A9 : GetPCIVendor := 'InnoSys Inc.';
    $11AA : GetPCIVendor := 'Actel';
    $11AB : GetPCIVendor := 'Galileo Technology Ltd.';
    $11AC : GetPCIVendor := 'Canon Information Systems';
    $11AD : GetPCIVendor := 'Lite-On Communications Inc.';
    $11AE : GetPCIVendor := 'Scitex Corporation Ltd.';
    $11AF : GetPCIVendor := 'Pro-Log Corporation';
    $11B0 : GetPCIVendor := 'V3 Semiconductor Inc.';
    $11B1 : GetPCIVendor := 'Apricot Computers';
    $11B2 : GetPCIVendor := 'Estman Kodak';
    $11B3 : GetPCIVendor := 'Barr Systems Inc.';
    $11B4 : GetPCIVendor := 'Leitch Technology International';
    $11B5 : GetPCIVendor := 'Radstone Technology Plc';
    $11B6 : GetPCIVendor := 'United Video Corporation';
    $11B7 : GetPCIVendor := 'Motorola';
    $11B8 : GetPCIVendor := 'Xpoint Technologies Inc.';
    $11B9 : GetPCIVendor := 'Pathlight Technology Inc.';
    $11BA : GetPCIVendor := 'Videotron Corporation';
    $11BB : GetPCIVendor := 'Pyramid Technology';
    $11BC : GetPCIVendor := 'Network Peripherals Inc.';
    $11BD : GetPCIVendor := 'Pinnacle Systems Inc.';
    $11BE : GetPCIVendor := 'International Microcircuits Inc.';
    $11C3 : GetPCIVendor := 'NEC Corporation';
    $11C4 : GetPCIVendor := 'Document Technologies Inc.';
    $11C5 : GetPCIVendor := 'Chiva Corporation';
    $11C7 : GetPCIVendor := 'D.C.M. Data Systems';
    $11C8 : GetPCIVendor := 'Dolphin Interconnect';
    $11C9 : GetPCIVendor := 'MAGMA';
    $11CA : GetPCIVendor := 'LSI Systems Inc.';
    $11CB : GetPCIVendor := 'Specialix Research Ltd.';
    $11CC : GetPCIVendor := 'Michels & Kleberhoff Computer GmbH';
    $11CD : GetPCIVendor := 'HAL Computer Systems Inc.';
    $11F5 : GetPCIVendor := 'Computer Devices International';
    $11F8 : GetPCIVendor := 'PMC-Sierra Inc.';
    $120E : GetPCIVendor := ' Cyclades Corporation';
    $1220 : GetPCIVendor := 'Ariel Corporation';
    $122D : GetPCIVendor := 'Aztech Systems Ltd.';
    $1C1C : GetPCIVendor := 'Forex Computer Corporation';
    $1DE1 : GetPCIVendor := 'Tekram Technology Corporation LTD';
    $120E : GetPCIVendor := 'Cyclades';
    $1C1C : GetPCIVendor := 'Symphony';
    $1DE1 : GetPCIVendor := 'TekRAM';
    $3D3D : GetPCIVendor := '3DLabs';
    $4005 : GetPCIVendor := 'Avance Logics Inc.';
    $4B10 : GetPCIVendor := 'Buslogic Inc. (???)';
    $5333 : GetPCIVendor := 'S3';
    $5700 : GetPCIVendor := 'Netpower';
    $6374 : GetPCIVendor := 'c''t Magazin fÅr Computertechnik';
    $8086 : GetPCIVendor := 'Intel';
    $8800 : GetPCIVendor := 'Reigem Computer';
    $8E0E : GetPCIVendor := 'Computone Corporation';
    $9004 : GetPCIVendor := 'Adaptec';
    $907F : GetPCIVendor := 'Atronics';
    $EDD8 : GetPCIVendor := 'Ark Logic Inc';
    $FFFF : GetPCIVendor := 'Buslogic ! incompatible mode !';
  Else
    GetPCIVendor := 'unbekannt (' + Hex (VendorId, 4) + 'h)';
  End;
End;


Function IsPCIDevice (Device, Bus : Byte) : Boolean;

Begin
  If BusType = dbuPCI Then
    Begin
      Regs.AX := $B109;
      Regs.BL := Device Shl 3;
      Regs.BH := Bus;
      Regs.DI := 0;
      Intr ($1A, Regs);
      IsPCIDevice := (Regs.CX <> $FFFF);
    End
  Else
    IsPCIDevice := False;
End;


Procedure GetPCIConfig;

Type pWord = ^Word;

Var PCITemp : Array [0..106] Of Word;

Begin
  If BusType = dbuPCI Then
    Begin
      xByte := 0;
      xWord := 0;
      xPointer := @Data;

      Repeat
        Regs.AX := $B109;
        Regs.BL := Device Shl 3;
        Regs.BH := Bus;
        Regs.DI := xByte;
        Intr ($1A, Regs);

        PCITemp[xWord] := Regs.CX;

        Inc (xByte, 2);
        Inc (xWord, 1)
      Until xByte = 212;
      Move (PCITemp, Data, SizeOf (Data));
    End;
End;


Function IdentifyPCIDevice (VendorID, DeviceID : Word; Revision : Byte) : String;

Begin
  IdentifyPCIDevice := 'unbekannt';
  Case VendorId Of
    $0E11 : Case DeviceId Of
               $0001 : IdentifyPCIDevice := 'PCI-to-EISA Bridge';
               $0002 : IdentifyPCIDevice := 'PCI-to-ISA Bridge';
               $1000 : IdentifyPCIDevice := 'Triflex/Pentium Bridge, Modell 1000';
               $2000 : IdentifyPCIDevice := 'Triflex/Pentium Bridge, Modell 2000';
               $3032 : IdentifyPCIDevice := 'Compaq QVision GUI Accelerator Rev. 0';
               $3033 : IdentifyPCIDevice := 'Compaq QVision GUI Accelerator Rev. 1';
               $3034 : IdentifyPCIDevice := 'Compaq QVision GUI Accelerator Rev. 2';
               $4000 : IdentifyPCIDevice := 'Triflex/PCI CPU Bridge';
             End;
    $1000 : Case DeviceId Of
              $0001 : IdentifyPCIDevice := '53C810 PCI-SCSI I/O Processor (FAST-SCSI)';
              $0002 : IdentifyPCIDevice := '53C820 PCI-SCSI I/O Processor (FAST-WIDE-SCSI)';
              $0003 : Case Revision Of
                        $00..$0F : IdentifyPCIDevice := '53C825 PCI-SCSI I/O Processor (FAST-WIDE-SCSI)';
                        $10..$1F : IdentifyPCIDevice := '53C825A PCI-SCSI I/O Processor (ULTRA-WIDE-SCSI)';
                        $20..$FF : IdentifyPCIDevice := '53C825?? PCI-SCSI I/O Processor';
                      End;
              $0004 : IdentifyPCIDevice := '53C815 PCI-SCSI I/O Processor (FAST-SCSI)';
              $0005 : Case Revision Of
                        $00..$0F : IdentifyPCIDevice := '53C875 PCI-SCSI I/O Processor (ULTRA-WIDE-SCSI)';
                        $10..$FF : IdentifyPCIDevice := '53C875?? PCI-SCSI I/O Processor';
                      End;
              $0006 : Case Revision Of
                        $00..$0F : IdentifyPCIDevice := '53C860 PCI-SCSI I/O Processor (ULTRA-SCSI)';
                        $10..$FF : IdentifyPCIDevice := '??? PCI-SCSI I/O Processor';
                      End;
              $000F : Case Revision Of
                        $00..$0F : IdentifyPCIDevice := '53C875 PCI-SCSI I/O Processor (ULTRA-WIDE-SCSI)';
                        $10..$FF : IdentifyPCIDevice := '53C875?? PCI-SCSI I/O Processor';
                      End;
              $1000 : IdentifyPCIDevice := '53C815 PCI-SCSI I/O Processor (FAST-SCSI)';
            End;
    $1002 : Case DeviceId Of
              $4158 : IdentifyPCIDevice := 'ATI68800AX 32-Bit GUI Accelerator';
              $4354 : IdentifyPCIDevice := 'mach64 (215CT222) GUI Accelerator';
              $4358 : IdentifyPCIDevice := 'mach64 (210888CX) GUI Accelerator';
              $4758 : IdentifyPCIDevice := 'mach64 (210888GX) GUI Accelerator';
            End;
    $1003 : Case DeviceId Of
              $0201 : IdentifyPCIDevice := 'US201 GUI Accelerator';
            End;
    $1004 : Case DeviceId Of
              $0005 : IdentifyPCIDevice := '82C591/2 Pentium (P54C) Host Bridge';
              $0006 : IdentifyPCIDevice := '82C593 PCI to ISA Bridge';
              $0007 : IdentifyPCIDevice := '82C594 Wildcat System Controller';
              $0008 : IdentifyPCIDevice := '82C596/7 Wildcat PCI to ISA Bridge';
              $000C : IdentifyPCIDevice := '82C541';
              $000D : IdentifyPCIDevice := '82C543';
              $0101 : IdentifyPCIDevice := '82C532';
              $0102 : IdentifyPCIDevice := '82C534';
              $0104 : IdentifyPCIDevice := '82C535';
              $0105 : IdentifyPCIDevice := '82C147';
              $0200 : IdentifyPCIDevice := '82C975 RISC GUI Accelerator';
              $0280 : IdentifyPCIDevice := '82C925 RISC GUI Accelerator';
            End;
    $1005 : Case DeviceId Of
              $2301 : IdentifyPCIDevice := 'AVL2301 GUI Accelerator';
              $2302 : IdentifyPCIDevice := 'ALG2302 GUI Accelerator';
            End;
    $100B : Case DeviceId Of
              $D001 : IdentifyPCIDevice := 'PC87410 PCI Enhanced IDE Controller';
            End;
    $100C : Case DeviceId Of
              $3202 : IdentifyPCIDevice := 'ET4000W32P 32-Bit GUI Accelerator Rev A (Old Type)';
              $3205 : IdentifyPCIDevice := 'ET4000W32P 32-Bit GUI Accelerator Rev B (Old Type)';
              $3206 : IdentifyPCIDevice := 'ET4000W32P 32-Bit GUI Accelerator Rev C (Old Type)';
              $3207 : IdentifyPCIDevice := 'ET4000W32P 32-Bit GUI Accelerator Rev D';
            End;
    $100E : Case DeviceId Of
              $9001 : IdentifyPCIDevice := 'Power 9001 32-Bit GUI Accelerator';
              $9100 : IdentifyPCIDevice := 'Power 9100 32-Bit GUI Accelerator';
            End;
    $1011 : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'DECchip 21050-AA PCI to PCI Bridge';
              $0002 : IdentifyPCIDevice := 'DECchip 21040-AA Ethernet-Adapter';
              $0009 : IdentifyPCIDevice := 'DECchip 21140 Fast-Ethernet-Adapter';
              $000F : IdentifyPCIDevice := 'DECchip FDDI-Chip "DEFPA"';
              $0014 : IdentifyPCIDevice := 'DECchip 21041 Ethernet-Adapter';
              $0016 : IdentifyPCIDevice := 'DECchip ATM-Controller "DGLPB"';
            End;
    $1013 : Case DeviceId Of
              $00A0 : IdentifyPCIDevice := 'CL-GD5430 GUI Accelerator';
              $00A4 : IdentifyPCIDevice := 'CL-GD5434 GUI Accelerator';
              $00A8 : IdentifyPCIDevice := 'CL-GD5434-HC-B GUI Accelerator';
              $1100 : IdentifyPCIDevice := 'CL-CL6729 PCI-to-PCMCIA-Bridge';
              $1200 : IdentifyPCIDevice := 'CL-GD7542 GUI Accelerator';
              $1202 : IdentifyPCIDevice := 'CL-GD7543 GUI Accelerator';
              $1204 : IdentifyPCIDevice := 'CL-GD7541 Nordic-lite VGA Controller';
            End;
    $1014 : Case DeviceId Of
              $0002 : IdentifyPCIDevice := 'PCI-to-MCA Bridge';
              $0005 : IdentifyPCIDevice := 'Alta Lite CPU Bridge';
              $0007 : IdentifyPCIDevice := 'Alta MP CPU Bridge';
              $000A : IdentifyPCIDevice := 'PCI-to-ISA Bridge with Plug&Play Port';
              $0017 : IdentifyPCIDevice := 'CPU Bridge';
              $0018 : IdentifyPCIDevice := 'Auto LANStreamer';
              $001B : IdentifyPCIDevice := 'GXT-150P GUI Accelerator';
              $0020 : IdentifyPCIDevice := 'PCI-to-MCA Bridge';
              $0036 : IdentifyPCIDevice := 'Miami/PCI 32-bit LocalBus Bridge';
            End;
    $101C : Case DeviceId Of
              $0193 : IdentifyPCIDevice := 'WD33C193A PCI SCSI Bridge';
              $0196 : IdentifyPCIDevice := 'WD33C196A PCI SCSI Bridge';
              $0197 : IdentifyPCIDevice := 'WD33C197A PCI Wide SCSI Bridge';
              $0296 : IdentifyPCIDevice := 'WD33C296A PCI Wide SCSI Bridge';
              $3193 : IdentifyPCIDevice := 'WD7193 PCI Fast SCSI II Hostadapter';
              $3197 : IdentifyPCIDevice := 'WD7197 PCI Fast Wide SCSI II Hostadapter';
              $3296 : IdentifyPCIDevice := 'WD7296 PCI Fast Wide SCSI II Hostadapter';
              $4296 : IdentifyPCIDevice := 'WD34C294 Wide Fast-20 SCSI Hostadapter';
              $C24A : IdentifyPCIDevice := '90C ??';
            End;
    $101E : Case DeviceId Of
              $9010 : IdentifyPCIDevice := 'MegaRAID PCI Fast Wide SCSI RAID-Adapter';
              $9030 : IdentifyPCIDevice := 'PCI EIDE Controller';
              $9031 : IdentifyPCIDevice := 'PCI EIDE Controller';
              $9032 : IdentifyPCIDevice := 'PCI EIDE & SCSI Controller';
              $9033 : IdentifyPCIDevice := 'PCI SCSI Controller';
              $9040 : IdentifyPCIDevice := 'Multimedia card';
            End;
    $1022 : Case DeviceId Of
              $2000 : IdentifyPCIDevice := 'AM79C970 PCI Ethernet Adapter';
              $2020 : IdentifyPCIDevice := 'AM53C974 PCI SCSI Bridge';
              $2040 : IdentifyPCIDevice := 'AM79C974 PCI Ethernet & SCSI Bridge';
            End;
    $1023 : Case DeviceId Of
              $9320 : IdentifyPCIDevice := 'GUI Accelerator';
              $9350 : IdentifyPCIDevice := 'GUI Accelerator';
              $9360 : IdentifyPCIDevice := 'Flat panel GUI Accelerator';
              $9420 : IdentifyPCIDevice := 'TGUI9420 DGi GUI Accelerator';
              $9440 : IdentifyPCIDevice := 'TGUI9440 DGi GUI Accelerator';
              $9460 : IdentifyPCIDevice := 'GUI Accelerator';
              $9660 : IdentifyPCIDevice := '9660 ??';
              $9682 : IdentifyPCIDevice := 'Multimedia Accelerator';
            End;
    { 1025 = 10B9 }
    $102A : Case DeviceId Of
              $0000 : IdentifyPCIDevice := 'HYDRA Pentium PCI Chipset (MPI)';
              $0010 : IdentifyPCIDevice := 'ASPEN 486 PCI Chipset';
            End;
    $102B : Case DeviceId Of
              $0518 : IdentifyPCIDevice := 'MGA Atlas PX2085 GUI Accelerator';
              $0519 : IdentifyPCIDevice := 'MGA-2064W Millenium GUI Accelerator';
              $0D10 : IdentifyPCIDevice := 'MGA Impression GUI Accelerator';
            End;
    $102C : Case DeviceId Of
              $00B8 : IdentifyPCIDevice := 'C&T 64310 GUI Accelerator';
              $00D0 : IdentifyPCIDevice := 'C&T 65545 Flat panel GUI Accelerator';
              $00D8 : IdentifyPCIDevice := 'C&T 65545 GUI Accelerator';
              $00DC : IdentifyPCIDevice := 'C&T 65548 GUI Accelerator';
            End;
    $102F : Case DeviceId Of
              $0009 : IdentifyPCIDevice := 'r4x00 CPU Bridge';
            End;
    $1031 : Case DeviceId Of
              $5601 : IdentifyPCIDevice := 'miroVIDEO DC20 Video in/out & JPEG';
              $5607 : IdentifyPCIDevice := 'Video in/out & motion JPEG compressor';
            End;
    $1033 : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'PCI to 486-like bus Bridge';
              $0002 : IdentifyPCIDevice := 'PCI to V198 Bridge';
              $0003 : IdentifyPCIDevice := 'ATM Controller';
              $0004 : IdentifyPCIDevice := 'R4000 PCI Bridge';
              $0005 : IdentifyPCIDevice := 'PCI to 486-like bus Bridge';
              $0006 : IdentifyPCIDevice := 'GUI Accelerator';
              $0007 : IdentifyPCIDevice := 'PCI to UX-Bus Bridge';
              $0008 : IdentifyPCIDevice := 'GUI Accelerator';
              $0009 : IdentifyPCIDevice := 'GUI Accelerator for 98';
            End;
    $1036 : Case DeviceId Of
              $0000 : IdentifyPCIDevice := 'TMC-3260 PCI SCSI-2 Controller (36C70)';
            End;
    $1039 : Case DeviceId Of
              $0001 : IdentifyPCIDevice := '86C201 True-Color Graphics Accelerator';
              $0002 : IdentifyPCIDevice := 'GUI Accelerator';
              $0006 : IdentifyPCIDevice := '85C501/2 Pentium PCI Chipset';
              $0008 : IdentifyPCIDevice := '85C503/5513 PCI to ISA Bridge';
              $0205 : IdentifyPCIDevice := '6205 GUI Accelerator with RAM-DAC, UMA-Support';
              $0406 : IdentifyPCIDevice := '85C501/2 Pentium PCI Chipset';
              $0496 : IdentifyPCIDevice := '85C496/497 486 PCI Chipset';
              $0596 : IdentifyPCIDevice := 'Pentium PCI Chipset with IDE';
              $0601 : IdentifyPCIDevice := '83C601 PCI Enhanced IDE Controller';
              $3602 : IdentifyPCIDevice := '83C602 PCI Enhanced IDE Controller';
              $5401 : IdentifyPCIDevice := '486 PCI Chipset';
              $5511 : IdentifyPCIDevice := 'SiS5511/5512 Pentium PCI Chipset';
              $5513 : IdentifyPCIDevice := 'SiS5513 Funktion 1: EIDE Controller';
              $5581 : IdentifyPCIDevice := 'Pentium Chipset';
              $5582 : IdentifyPCIDevice := 'PCI-to-ISA Bridge';
              $5596 : IdentifyPCIDevice := 'Pentium Chipset';
              $6204 : IdentifyPCIDevice := 'Video decoder & MPEG interface';
            End;
    $103C : Case DeviceId Of
              $1030 : IdentifyPCIDevice := 'J2585A ?';
              $2910 : IdentifyPCIDevice := 'E2910A PCI Bus Exerciser';
            End;
    $1042 : Case DeviceId Of
              $1000 : IdentifyPCIDevice := 'RZ1000 PCI Enhanced IDE Adapter';
              $1001 : IdentifyPCIDevice := '37C922 ??';
            End;
    $1044 : Case DeviceId Of
              $A400 : IdentifyPCIDevice := 'DPT 2124A/9X SmartCache III SCSI-Cache-Adapter';
            End;
    $1045 : Case DeviceId Of
              $C178 : IdentifyPCIDevice := '92C178 GUI Accelerator (LCD)';
              $C557 : Case Revision Of
                        $00..$0F : IdentifyPCIDevice := '82C557 Pentium Bridge (Viper)';
                        $10..$FF : IdentifyPCIDevice := '82C557 Pentium Bridge (Viper M with EDO-Supp.)';
                      End;
              $C558 : IdentifyPCIDevice := '82C558 PCI-to-ISA Bridge with Plug&Play Port';
              $C621 : Case Revision Of
                        $00..$0F : IdentifyPCIDevice := '82C621 PCI EIDE Controller';
                        $10..$FF : IdentifyPCIDevice := '82C558 integrated PCI EIDE Controller';
                      End;
              $C822 : IdentifyPCIDevice := '82C822 PCI Enhanced IDE Adapter';
            End;
    $10B4 : Case DeviceId Of
              $0140 : IdentifyPCIDevice := 'BT-946C SCSI-II PCI Hostadapter (old)';
              $1040 : IdentifyPCIDevice := 'BA80C30 PCI-SCSI Interface-Chip';
              $8130 : IdentifyPCIDevice := 'FlashPoint LT PCI-Hostadapter (Ultra-SCSI)';
            End;
    $104C : Case DeviceId Of
              $0500 : IdentifyPCIDevice := '100 MBit LAN Controller';
              $0508 : IdentifyPCIDevice := 'TMS380C2X Compressor Interface';
              $1000 : IdentifyPCIDevice := 'PCI Eagle i/f AS';
              $A001 : IdentifyPCIDevice := 'TDC1570 64-Bit PCI ATM Interface';
              $A100 : IdentifyPCIDevice := 'TDC1561 32-Bit PCI ATM Interface';
              $AC10 : IdentifyPCIDevice := 'PCI1050 PC card controller';
              $AC11 : IdentifyPCIDevice := 'PCI1053 PC card controller';
              $AC12 : IdentifyPCIDevice := 'PCI1130 PC card CardBus controller';
            End;
    $104E : Case DeviceId Of
              $0107 : IdentifyPCIDevice := 'OTI107, Spitfire VGA Accelerator';
            End;
    $1050 : Case DeviceId Of
              $0000 : IdentifyPCIDevice := 'Ethernet Controller';
              $0001 : IdentifyPCIDevice := 'W83769F';
            End;
    $1054 : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'PCI Bridge';
              $0002 : IdentifyPCIDevice := 'PCI Bus Controller';
            End;
    $1055 : Case DeviceId Of
              $0810 : IdentifyPCIDevice := '486 Host Bridge';
              $0922 : IdentifyPCIDevice := 'Pentium Host Bridge';
              $0926 : IdentifyPCIDevice := 'PCI-to-ISA Bridge';
            End;
    $1057 : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'MPC105 PowerPC Chipset';
            End;
    $105A : Case DeviceId Of
              $5300 : IdentifyPCIDevice := 'DC5030';
            End;
    $105D : Case DeviceId Of
              $2309 : IdentifyPCIDevice := 'Imagine 128 GUI Accelerator';
            End;
    $1060 : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'UM82C881 486 PCI Chipset';
              $0002 : IdentifyPCIDevice := 'UM82C886 PCI to ISA Bridge';
              $0101 : IdentifyPCIDevice := 'UM8673F PCI Enhanced IDE Controller';
              $0881 : IdentifyPCIDevice := 'UM8881 HB4 486 PCI Chipset';
              $0886 : IdentifyPCIDevice := 'UM8886 PCI to ISA Bridge';
              $0891 : IdentifyPCIDevice := 'UM82C891 Pentium Chipset';
              $1001 : IdentifyPCIDevice := 'UM886A PCI dual Enhanced IDE Controller';
              $673A : IdentifyPCIDevice := 'UM8886 Funktion 1: EIDE Controller';
              $8710 : IdentifyPCIDevice := 'UM8710 GUI Accelerator';
              $886A : IdentifyPCIDevice := 'UM8886 PCI to ISA Bridge with EIDE';
              $8881 : IdentifyPCIDevice := 'UM8881 HB4 486 PCI Chipset';
              $8886 : IdentifyPCIDevice := 'UM8886 PCI to ISA Bridge';
              $8891 : IdentifyPCIDevice := 'UM8891 586 PCI Chipset';
              $9017 : IdentifyPCIDevice := 'UM9017F ??';
              $E881 : IdentifyPCIDevice := 'UM8881 486 Chipset (Notebook)';
              $E886 : IdentifyPCIDevice := 'UM8886 PCI-to-ISA Bridge with EIDE (Notebook)';
              $E891 : IdentifyPCIDevice := 'UM8891 Pentium Chipset (Notebook)';
            End;
    $1061 : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'AGX013 GUI Accelerator';
              $0002 : IdentifyPCIDevice := 'IIT3204/3501 MPEG Decoder';
            End;
    $1066 : Case DeviceId Of
              $0000 : IdentifyPCIDevice := 'PT80C826 VL Bridge';
            End;
    $1069 : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'DAC960P Wide-SCSI Hostadapter with RAID';
            End;
    $1073 : Case DeviceId Of
              $0001 : IdentifyPCIDevice := '3D GUI Accelerator';
            End;
    $1074 : Case DeviceId Of
              $4E78 : IdentifyPCIDevice := 'VL82C500 Nx586 Chipset';
            End;
    $1077 : Case DeviceId Of
              $1020 : IdentifyPCIDevice := 'ISP1020A PCI Fast/Wide SCSI Chip';
              $1022 : IdentifyPCIDevice := 'ISP1022A PCI Fast/Wide SCSI Chip';
            End;
    $107D : Case DeviceId Of
              $0000 : IdentifyPCIDevice := 'P86C850 Graphic GLU-Logic';
            End;
    $107E : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'ATM interface card';
              $0002 : IdentifyPCIDevice := '100 VG anylan Controller';
            End;
    $107F : Case DeviceId Of
              $0802 : IdentifyPCIDevice := 'SL82C105 PCI Enhanced IDE Controller';
            End;
    $1080 : Case DeviceId Of
              $0600 : IdentifyPCIDevice := '82C599 VL to PCI Bridge';
            End;
    $1083 : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'FR710 PCI Enhanced IDE Adapter';
              $0613 : IdentifyPCIDevice := 'Host Bridge ??';
            End;
    $108A : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'VME Bridge';
            End;
    $108D : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'PCI Ethernet Adapter';
            End;
    $1091 : Case DeviceId Of
              $0020 : IdentifyPCIDevice := '3D Graphics Processor';
              $0021 : IdentifyPCIDevice := '3D Graphics Processor w/Texturing';
              $0040 : IdentifyPCIDevice := '3D Graphics Frame Buffer';
              $0041 : IdentifyPCIDevice := '3D Graphics Frame Buffer';
              $0060 : IdentifyPCIDevice := 'Proprietary Bus Bridge';
              $0720 : IdentifyPCIDevice := 'Motion JPEG Codec';
            End;
    $1095 : Case DeviceId Of
              $0640 : IdentifyPCIDevice := 'PCI0640A PCI Enhanced IDE Adapter';
              $0642 : IdentifyPCIDevice := 'PCI Enhanced IDE Adapter with RAID 1';
              $0646 : IdentifyPCIDevice := 'PCI0646 PCI Enhanced IDE Adapter';
              $0650 : IdentifyPCIDevice := 'PBC0650A PCI Fast SCSI II Hostadapter';
            End;
    $1097 : Case DeviceId Of
              $0038 : IdentifyPCIDevice := 'PCI Enhanced IDE Controller';
            End;
    $1098 : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'QD-8500';
              $0002 : IdentifyPCIDevice := 'QD-8580';
            End;
    $109E : Case DeviceId Of
              $2115 : IdentifyPCIDevice := 'BtV 2115 BtV Mediastream Controller';
              $2125 : IdentifyPCIDevice := 'BtV 2125 BtV Mediastream Controller';
            End;
    $10A8 : Case DeviceId Of
              $0000 : IdentifyPCIDevice := '64-Bit GUI Accelerator';
            End;
    $10AA : Case DeviceId Of
              $0000 : IdentifyPCIDevice := 'ACCM 2188 VL-to-PCI Bridge';
            End;
    $10AD : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'W83769F PCI Enhanced IDE Controller';
              $0103 : IdentifyPCIDevice := 'S182C103 PCI Enhanced IDE Controller (Mode 4/5)';
              $0105 : IdentifyPCIDevice := 'SL82C105 PCI Dual Enhanced IDE Controller';
            End;
    $10B5 : Case DeviceId Of
              $9036 : IdentifyPCIDevice := 'PCI9036 PCI Interface Chip';
              $9060 : IdentifyPCIDevice := 'PCI9060xx PCI Bus Interface Chip';
            End;
    $10B6 : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'Smart 16/4 PCI Ringnode';
              $1000 : IdentifyPCIDevice := 'Collage 25 ATM adapter';
              $1001 : IdentifyPCIDevice := 'Collage 155 ATM adapter';
            End;
    $10B7 : Case DeviceId Of
              $5900 : IdentifyPCIDevice := '3C590 PCI Ethernet Adapter 10bT';
              $5950 : IdentifyPCIDevice := '3C595 PCI Ethernet Adapter 100bTX';
              $5951 : IdentifyPCIDevice := '3C595 PCI Ethernet Adapter 100bT4';
              $5952 : IdentifyPCIDevice := '3C595 PCI Ethernet Adapter 100b-MII';
            End;
    $10B8 : Case DeviceId Of
              $1000 : IdentifyPCIDevice := 'FDC 37C665';
              $1001 : IdentifyPCIDevice := 'FDC 37C922';
            End;
    $10B9, $1025 : Case DeviceId Of
              $1435 : IdentifyPCIDevice := 'ALI M1435 VL to PCI Bridge';
              $1445 : IdentifyPCIDevice := 'ALI M1445 VL to PCI Bridge & Enhanced IDE Adapter';
              $1449 : IdentifyPCIDevice := 'ALI M1449 PCI to ISA Bridge';
              $1451 : IdentifyPCIDevice := 'ALI M1451 Pentium Chipset';
              $1461 : IdentifyPCIDevice := 'ALI M1461 P54C Chipset';
              $3141 : IdentifyPCIDevice := 'ALI M3141 GUI Accelerator, 2 MB Video-RAM';
              $3143 : IdentifyPCIDevice := 'ALI M3143 GUI Accelerator, 2 MB Video-RAM with DAC';
              $3145 : IdentifyPCIDevice := 'ALI M3145 GUI Accelerator, 2 MB Video-RAM';
              $3147 : IdentifyPCIDevice := 'ALI M3147 GUI Accelerator, 2 MB Video-RAM with DAC';
              $3149 : IdentifyPCIDevice := 'ALI M3149 GUI Accelerator, 4 MB Video-RAM';
              $3151 : IdentifyPCIDevice := 'ALI M3151 GUI Accelerator, 8 MB Video-RAM';
              $5215 : IdentifyPCIDevice := 'ALI M4803 PCI Enhanced IDE Controller';
              $5217 : IdentifyPCIDevice := 'ALI M5217 I/O ??';
              $5219 : IdentifyPCIDevice := 'ALI M5219 I/O ??';
              $5235 : IdentifyPCIDevice := 'ALI M5235 I/O ??';
            End;
    $10BD : Case DeviceId Of
              $5240 : IdentifyPCIDevice := 'PCI Enhanced IDE Controller';
              $5241 : IdentifyPCIDevice := 'PCMCIA Bridge';
              $5242 : IdentifyPCIDevice := 'General Purpose Controller';
              $5243 : IdentifyPCIDevice := 'Bus Controller';
              $5244 : IdentifyPCIDevice := 'FCD Controller';
            End;
    $10C8 : Case DeviceId Of
              $0000 : IdentifyPCIDevice := 'Graphics Controller';
            End;
    $10CD : Case DeviceId Of
              $1100 : IdentifyPCIDevice := 'ASC1100 PCI SCSI Hostadapter';
              $1200 : IdentifyPCIDevice := 'ASC1200 PCI SCSI Hostadapter (Fast SCSI II)';
              $1300 : IdentifyPCIDevice := 'ASC1300 PCI SCSI Hostadapter (Fast Wide SCSI II)';
            End;
    $10CF : Case DeviceId Of
              $2001 : IdentifyPCIDevice := 'MB86605 PCI SCSI Hostadapter (Fast Wide SCSI II)';
            End;
    $10DD : Case DeviceId Of
              $0001 : IdentifyPCIDevice := '3D Graphics Processor';
            End;
    $10DF : Case DeviceId Of
              $1AE5 : IdentifyPCIDevice := 'Fibre Channel Hostadapter';
            End;
    $10E0 : Case DeviceId Of
              $5026 : IdentifyPCIDevice := 'IMS5026/27/28 P54C PCI-Chipset "Diamond"';
              $5028 : IdentifyPCIDevice := 'IMS5028 ISA Bridge';
              $8849 : IdentifyPCIDevice := 'IMS8849/8848 3-/486 PCI Chipset';
              $8849 : IdentifyPCIDevice := 'IMS8853 ATM Network Adapter';
              $9128 : IdentifyPCIDevice := 'IMS9129 Twin Turbo 128 GUI Accelerator';
            End;
    $10E3 : Case DeviceId Of
              $0000 : IdentifyPCIDevice := 'CA91C042 VMEbus bridge';
            End;
    $10E8 : Case DeviceId Of
              $4750 : IdentifyPCIDevice := 'S5930 "Matchmaker" PCI Controller';
              $8043 : IdentifyPCIDevice := 'LANai 4.x Myrinet LANai interface chip';
            End;
    $10EB : Case DeviceId Of
              $0101 : IdentifyPCIDevice := '3GA 64 bit GUI Accelerator';
            End;
    $10EC : Case DeviceId Of
              $8029 : IdentifyPCIDevice := '8029';
            End;
    $10ED : Case DeviceId Of
              $7310 : IdentifyPCIDevice := 'V7310 VGA Video Overlay Adapter';
            End;
    $10F5 : Case DeviceId Of
              $A001 : IdentifyPCIDevice := 'NDR4000 NR4600 Bridge';
            End;
    $10FA : Case DeviceId Of
              $0000..$0009, $0010..$0015 : IdentifyPCIDevice := 'GUI Accelerator';
            End;
    $1101 : Case DeviceId Of
              $9100 : IdentifyPCIDevice := 'PCI Fast SCSI Controller';
              $9400 : IdentifyPCIDevice := 'PCI Fast Wide SCSI Controller';
              $9700 : IdentifyPCIDevice := 'PCI Fast Wide SCSI Controller';
            End;
    $1106 : Case DeviceId Of
              $0505 : IdentifyPCIDevice := 'VT82C505 VL to PCI Bridge';
              $0561 : IdentifyPCIDevice := 'VT82C570MV Apollo Chipset, IDE-Bridge';
              $0571 : IdentifyPCIDevice := 'Apollo Master ISA-Bridge, Funktion 1: IDE-Bridge';
              $0576 : IdentifyPCIDevice := 'VT82C570MV Apollo Chipset, (P54), System/PCI Ctrl.';
              $0585 : IdentifyPCIDevice := 'VT82C585VP Apollo Master Chipset, System/PCI Ctrl.';
              $0586 : IdentifyPCIDevice := 'VT82C586 Apollo Master Chipset, ISA/IDE-Bus Ctrl.';
              $1000 : IdentifyPCIDevice := 'VT82C570MV Apollo Chipset (P54), System/PCI Ctrl.';
              $1106 : IdentifyPCIDevice := 'VT82C570MV Apollo Chipset, ISA/IDE-Bus Controller';
            End;
    $1108 : Case DeviceId Of
              $0100 : IdentifyPCIDevice := 'P169Plus-AA Single Port Token Ring Adapter';
              $0101 : IdentifyPCIDevice := 'P169Plus-AB Dual Port Token Ring Adapter';
            End;
    $110A : Case DeviceId Of
              $0002 : IdentifyPCIDevice := 'Piranha PCI-EIDE-Adapter (2 Port)';
            End;
    $1112 : Case DeviceId Of
              $2200 : IdentifyPCIDevice := 'FDDI Adapter';
              $2300 : IdentifyPCIDevice := 'Fast Ethernet Adapter';
              $2400 : IdentifyPCIDevice := 'ATM Adapter';
            End;
    $1117 : Case DeviceId Of
              $9500 : IdentifyPCIDevice := 'Max-1C SVGA card';
              $9501 : IdentifyPCIDevice := 'Max-1C image processing';
            End;
    $1119 : Case DeviceId Of
              $0000 : IdentifyPCIDevice := 'GDT6000/6020/6050 PCI SCSI RAID-Controller';
              $0001 : IdentifyPCIDevice := 'GDT6000B/6010 PCI 1-Channel SCSI RAID-Controller';
              $0002 : IdentifyPCIDevice := 'GDT6110/6510 PCI 1-Channel SCSI RAID-Controller';
              $0003 : IdentifyPCIDevice := 'GDT6120/6520 PCI 2-Channel SCSI RAID-Controller';
              $0004 : IdentifyPCIDevice := 'GDT6530 PCI 3-Channel SCSI RAID-Controller';
              $0005 : IdentifyPCIDevice := 'GDT6550 PCI 5-Channel SCSI RAID-Controller';
            End;
    $111A : Case DeviceId Of
              $0000 : IdentifyPCIDevice := '155p-MF1';
            End;
    $111C : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'Powerbis Bridge';
            End;
    $111F : Case DeviceId Of
              $5243 : IdentifyPCIDevice := 'Frame Capture Bus Interface';
            End;
    $112E : Case DeviceId Of
              $0000 : IdentifyPCIDevice := 'PCI Enhanced IDE Controller';
              $000B : IdentifyPCIDevice := 'PCI Enhanced IDE Controller';
            End;
    $112F : Case DeviceId Of
              $0000 : IdentifyPCIDevice := 'MVC IC-PCI (source Linux)';
              $0001 : IdentifyPCIDevice := 'Video Frame Grabber / Processor';
            End;
    $1134 : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'Raceway Bridge';
            End;
    $1135 : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'Printer Controller';
            End;
    $1138 : Case DeviceId Of
              $8905 : IdentifyPCIDevice := 'STD 32 Bridge';
            End;
    $1139 : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'VGA Compatible 3D Graphics';
            End;
    $113C : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'PCI9060 i960 PCI Bus Interface Chip';
            End;
    $1141 : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'PCI Enhanced IDE Controller';
            End;
    $1142 : Case DeviceId Of
              $3210 : IdentifyPCIDevice := 'ProMotion 3210 VGA and AVI Playback Accelerator';
              $6410 : IdentifyPCIDevice := 'GUI Accelerator';
              $6412 : IdentifyPCIDevice := 'GUI Accelerator';
              $6420 : IdentifyPCIDevice := 'GUI Accelerator';
              $6422 : IdentifyPCIDevice := 'ProVideo ??';
              $6424 : IdentifyPCIDevice := 'GUI Accelerator';
              $6426 : IdentifyPCIDevice := 'GUI Accelerator';
            End;
    $1144 : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'Noservo Controller';
            End;
    $1148 : Case DeviceId Of
              $4000 : IdentifyPCIDevice := 'FDDI Adapter';
            End;
    $1158 : Case DeviceId Of
              $3011 : IdentifyPCIDevice := 'Tokenet/vg 1001/10m anylan';
              $9051 : IdentifyPCIDevice := 'Lanfleet/Truevalue';
            End;
    $1159 : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'MV-1000';
            End;
    $1161 : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'Host Bridge';
            End;
    $1165 : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'Motion TPEG Recorder/Player with Audio';
            End;
    $1178 : Case DeviceId Of
              $AFA1 : IdentifyPCIDevice := 'Fast Ethernet Adapter';
            End;
    $1179 : Case DeviceId Of
              $0601 : IdentifyPCIDevice := 'Pentium Host Bridge for Notebooks';
              $0602 : IdentifyPCIDevice := 'PCI-to-ISA-Bridge for Notebooks';
              $0603 : IdentifyPCIDevice := 'PCI-to-CardBus-Bridge for Notebooks';
              $0604 : IdentifyPCIDevice := 'PCI-to-PCI-Bridge for Notebooks';
            End;
    $1191 : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'PCI EIDE Adapter';
              $0002 : IdentifyPCIDevice := 'PCI EIDE Adapter';
              $0003 : IdentifyPCIDevice := 'PCI SCSI Cache Hostadapter';
              $8001 : IdentifyPCIDevice := 'PCI SCSI Cache Hostadapter';
              $8002 : IdentifyPCIDevice := 'PCI SCSI Hostadapter';
            End;
    $1193 : Case DeviceId Of
              $0001 : IdentifyPCIDevice := '1221-Chip';
            End;
    $11A9 : Case DeviceId Of
              $4240 : IdentifyPCIDevice := 'AMCC S933Q Intelligent serial card';
            End;
    $11B0 : Case DeviceId Of
              $0292 : IdentifyPCIDevice := 'V292PBC Am29030/40 PCI Bridge';
              $0960 : IdentifyPCIDevice := 'i960 Bridge';
              $C960 : IdentifyPCIDevice := 'i960 Dual PCI Bridge';
            End;
    $11B9 : Case DeviceId Of
              $C0ED : IdentifyPCIDevice := 'SSA Controller';
            End;
    $11CB : Case DeviceId Of
              $4000 : IdentifyPCIDevice := 'SUPI-1 ??';
              $8000 : IdentifyPCIDevice := 'T225 Bridge';
            End;
    $11F8 : Case DeviceId Of
              $7375 : IdentifyPCIDevice := 'PM7375 LASAR-155 ATM SAR';
            End;
    $120E : Case DeviceId Of
              $0100 : IdentifyPCIDevice := 'Cyclom-Y Multiport serial card';
              $0200 : IdentifyPCIDevice := 'Cyclom-Z Intelligent Multiport serial card';
            End;
    $1220 : Case DeviceId Of
              $1220 : IdentifyPCIDevice := 'AMCC 5933 TMS320C80 DSP/Imaging Board';
            End;
    $1C1C : Case DeviceId Of
              $0001 : IdentifyPCIDevice := 'FR710 PCI Enhanced IDE Adapter';
            End;
    $1DE1 : Case DeviceId Of
              $DC29 : IdentifyPCIDevice := 'TRM290 PCI Enhanced IDE Controller';
            End;
    $3D3D : Case DeviceId Of
              $0004 : IdentifyPCIDevice := '3C0SX GUI Accelerator';
            End;
    $4005 : Case DeviceId Of
              $2301 : IdentifyPCIDevice := 'AVL2301 GUI Accelerator';
              $2302 : IdentifyPCIDevice := 'ALG2302 GUI Accelerator';
            End;
    $4B10 : Case DeviceId Of
              $3080 : IdentifyPCIDevice := 'PCI SCSI Hostadapter';
              $4010 : IdentifyPCIDevice := 'PCI Wide SCSI Hostadapter';
            End;
    $5333 : Case DeviceId Of
              $8800 : IdentifyPCIDevice := '86C866 Vision 866 GUI Accelerator';
              $8801 : IdentifyPCIDevice := '86C964 Vision 964 GUI Accelerator';
              $8810 : IdentifyPCIDevice := '86C764 TRIO32 PCI GUI Accelerator, Rev. 00';
              $8811 : IdentifyPCIDevice := '86C764 TRIO32/64 PCI GUI Accelerator, Rev. 01';
              $8812 : IdentifyPCIDevice := '86C764 TRIO32/64 PCI GUI Accelerator, Rev. 02';
              $8813 : IdentifyPCIDevice := '86C764 TRIO32/64 PCI GUI Accelerator, Rev. 03';
              $8880 : IdentifyPCIDevice := '86C868 PCI GUI Accelerator VRAM, Rev. 00';
              $8881 : IdentifyPCIDevice := '86C868 PCI GUI Accelerator VRAM, Rev. 01';
              $8882 : IdentifyPCIDevice := '86C868 PCI GUI Accelerator VRAM, Rev. 02';
              $8883 : IdentifyPCIDevice := '86C868 PCI GUI Accelerator VRAM, Rev. 03';
              $88B0 : IdentifyPCIDevice := '86C928 PCI GUI Accelerator VRAM, Rev. 00';
              $88B1 : IdentifyPCIDevice := '86C928 PCI GUI Accelerator VRAM, Rev. 01';
              $88B2 : IdentifyPCIDevice := '86C928 PCI GUI Accelerator VRAM, Rev. 02';
              $88B3 : IdentifyPCIDevice := '86C928 PCI GUI Accelerator VRAM, Rev. 03';
              $88C0 : IdentifyPCIDevice := '86C864 PCI GUI Accelerator DRAM, Rev. 00';
              $88C1 : IdentifyPCIDevice := '86C864 PCI GUI Accelerator DRAM, Rev. 01';
              $88C2 : IdentifyPCIDevice := '86C864 PCI GUI Accelerator DRAM, Rev. 02';
              $88C3 : IdentifyPCIDevice := '86C864 PCI GUI Accelerator DRAM, Rev. 03';
              $88D0 : IdentifyPCIDevice := '86C964 PCI GUI Accelerator VRAM, Rev. 00';
              $88D1 : IdentifyPCIDevice := '86C964 PCI GUI Accelerator VRAM, Rev. 01';
              $88D2 : IdentifyPCIDevice := '86C964 PCI GUI Accelerator VRAM, Rev. 02';
              $88D3 : IdentifyPCIDevice := '86C964 PCI GUI Accelerator VRAM, Rev. 03';
              $88F0 : IdentifyPCIDevice := '86C968 PCI GUI Accelerator VRAM, Rev. 00';
              $88F1 : IdentifyPCIDevice := '86C968 PCI GUI Accelerator VRAM, Rev. 01';
              $88F2 : IdentifyPCIDevice := '86C968 PCI GUI Accelerator VRAM, Rev. 02';
              $88F3 : IdentifyPCIDevice := '86C968 PCI GUI Accelerator VRAM, Rev. 03';
            End;
    $6374 : Case DeviceId Of
              $6773 : IdentifyPCIDevice := 'CT-GPPCI c''t General Purpose PCI Interface';
            End;
    $8086 : Case DeviceId Of
              $0482 : IdentifyPCIDevice := '82375EB PCI to EISA Bridge, System Component (ESC)';
              $0483 : Case Revision Of
                        $00..$03 : IdentifyPCIDevice := '82424TX Saturn Chipset, Cache/DRAM Controller (CDC)';
                        $04..$FF : IdentifyPCIDevice := '82424ZX Saturn Chipset, Cache/DRAM Controller (CDC)';
                      End;
              $0484 : Case Revision Of
                        $00..$0F : IdentifyPCIDevice := '82378IB PCI to ISA Bridge, System I/O (SIO)';
                        $10..$7F : IdentifyPCIDevice := '82378ZB PCI to ISA Bridge, System I/O (SIO)';
                        $80..$FF : IdentifyPCIDevice := '82379AB PCI to ISA Bridge, System I/O (SIO)';
                      End;
              $0486 : IdentifyPCIDevice := '82420EX PCIset (486), System Ctrl, ISA Bridge & EIDE';
              $04A3 : Case Revision Of
                        $00..$0F : IdentifyPCIDevice := '82434LX Mercury Chipset (P5), Cache/DRAM Ctrl. (PCMC)';
                        $10..$FF : IdentifyPCIDevice := '82434NX Neptun Chipset (P54), Cache/DRAM Ctrl. (PCMC)';
                      End;
              $1221 : IdentifyPCIDevice := '82092AA PCI to PCMCIA Bridge (PPEC)';
              $1222 : IdentifyPCIDevice := '82092AA Enhanced IDE Adapter (PPEC)';
              $1223 : IdentifyPCIDevice := 'SAA7116';
              $1227 : IdentifyPCIDevice := '82865 PCI Ethernet Adapter';
              $122D : IdentifyPCIDevice := '82437FX Triton Chipset (P54), Cache/DRAM Ctrl. (TSC)';
              $122E : IdentifyPCIDevice := '82371FB PCI to ISA Bridge (PIIX), Funktion 0';
              $1230 : IdentifyPCIDevice := '82371FB PIIX Funktion 1: EIDE Controller';
              $1239 : IdentifyPCIDevice := '82371FB PIIX Funktion 1: EIDE Controller, unexpected ID';
              $1250 : IdentifyPCIDevice := '82439HX TXC Chipset (P54), Cache/DRAM Controller';
              $7000 : IdentifyPCIDevice := '82371SB PIIX3 Funktion 0: ISA Bridge';
              $7010 : IdentifyPCIDevice := '82371SB PIIX3 Funktion 1: EIDE Controller';
              $7020 : IdentifyPCIDevice := 'PIIX3 Funktion 2: Universal Serial Bus (USB) Controller';
              $84C4 : IdentifyPCIDevice := '82450KX Orion Chipset (P6), PCI Bridge (OPB)';
              $84C5 : IdentifyPCIDevice := '82450KX Orion Chipset (P6), Cache/DRAM Ctrl. (OMC)';
              $FFFF : IdentifyPCIDevice := '82450KX Orion Chipset (P6), Cache/DRAM Ctrl. (OMC)';
            End;
    $9004 : Case DeviceId Of
              $1078 : IdentifyPCIDevice := 'AIC-7810C RAID-Coprozessor';
              $5078 : IdentifyPCIDevice := 'AIC-7850P PCI Fast/Wide SCSI II Chip';
              $5575 : IdentifyPCIDevice := 'AVA-2930P PCI SCSI Hostadapter';
              $7078 : IdentifyPCIDevice := 'AIC-7870P PCI Fast/Wide SCSI II Chip';
              $7178 : IdentifyPCIDevice := 'AHA-2940 Fast/Wide SCSI Hostadapter';
              $7278 : IdentifyPCIDevice := 'AHA-3940 Dual-Channel FAST/Wide SCSI Hostadapter';
              $7378 : IdentifyPCIDevice := 'AHA-3985 4 Channel RAID SCSI Hostadapter';
              $7478 : IdentifyPCIDevice := 'AHA-2944 PCI SCSI Hostadapter';
              $7810 : IdentifyPCIDevice := 'AIC-7810 Memory Control IC';
              $7850 : IdentifyPCIDevice := 'AIC-7850 PCI Fast/Wide SCSI II Chip';
              $7855 : IdentifyPCIDevice := 'AHA-2930 PCI SCSI Hostadapter';
              $7870 : IdentifyPCIDevice := 'AIC-7870 PCI Fast/Wide SCSI II Chip';
              $7871 : IdentifyPCIDevice := 'AHA-2940 Fast/Wide SCSI Hostadapter';
              $7872 : IdentifyPCIDevice := 'AHA-3940 Dual-Channel FAST/Wide SCSI Hostadapter';
              $7873 : IdentifyPCIDevice := 'AHA-3985 4 Channel RAID SCSI Hostadapter';
              $7874 : IdentifyPCIDevice := 'AHA-2944 PCI SCSI Hostadapter';
              $7880 : IdentifyPCIDevice := 'AIC-7880P PCI Ultra/Ultra Wide SCSI Chip';
              $8078 : IdentifyPCIDevice := 'AIC-7880P PCI Ultra/Ultra Wide SCSI Chip';
              $8178 : IdentifyPCIDevice := 'AHA-2940 Ultra/Ultra Wide SCSI Hostadapter';
              $8278 : IdentifyPCIDevice := 'AHA-3940 Dual Ultra/Ultra Wide SCSI Hostadapter';
            End;
    $907F : Case DeviceId Of
              $2015 : IdentifyPCIDevice := 'IDE-2015PL PCI EIDE Interface';
            End;
    $EDD8 : Case DeviceId Of
              $A091 : IdentifyPCIDevice := 'Stingray ARC1000PV GUI Accelerator';
              $A099 : IdentifyPCIDevice := 'Stingray ARK2000PV GUI Accelerator';
              $A0A1 : IdentifyPCIDevice := 'ARC2000MT 64-Bit GUI Accelerator w/DCI Playback';
            End;
    $FFFF : Case DeviceId Of
              $0140 : IdentifyPCIDevice := 'BT-946C SCSI-II PCI Hostadapter';
            End;
  End;
End;


Function IdentifyPCIClass (ClassId : Byte) : String;

Begin
  Case ClassId Of
    $01 : IdentifyPCIClass := 'Storage';
    $02 : IdentifyPCIClass := 'Network';
    $03 : IdentifyPCIClass := 'Display';
    $04 : IdentifyPCIClass := 'Multimedia';
    $05 : IdentifyPCIClass := 'Memory';
    $06 : IdentifyPCIClass := 'Bridge';
    $07 : IdentifyPCIClass := 'Communication';
    $08 : IdentifyPCIClass := 'System';
    $09 : IdentifyPCIClass := 'Input';
    $0A : IdentifyPCIClass := 'Docking';
    $0B : IdentifyPCIClass := 'Processor';
    $0C : IdentifyPCIClass := 'Serial';
  Else
    IdentifyPCIClass := 'unbekannte Class-ID (' + StrFnByte (ClassId) + ')';
  End;
End;


Function IdentifyPCISubClass (ClassId, SubClassId : Byte) : String;

Begin
  Case ClassId Of
    $01 : Case SubClassId Of
            $00 : IdentifyPCISubClass := 'SCSI-Bus Controller';
            $01 : IdentifyPCISubClass := 'IDE-Controller';
            $02 : IdentifyPCISubClass := 'Floppy-Controller';
            $03 : IdentifyPCISubClass := 'IPI-Bus Controller';
            $04 : IdentifyPCISubClass := 'RAID Controller';
            $80 : IdentifyPCISubClass := 'undefinierter Medien-Controller';
          Else
            IdentifyPCISubClass := 'unbekannte SubClass-ID (' + StrFnByte (SubclassId)+ ')';
          End;
    $02 : Case SubClassId Of
            $00 : IdentifyPCISubClass := 'Ethernet Controller';
            $01 : IdentifyPCISubClass := 'Token ring Controller';
            $02 : IdentifyPCISubClass := 'FDDI Controller';
            $03 : IdentifyPCISubClass := 'ATM-Controller';
            $80 : IdentifyPCISubClass := 'undefinierter Netzwerk-Controller';
          Else
            IdentifyPCISubClass := 'unbekannte SubClass-ID (' + StrFnByte (SubclassId)+ ')';
          End;
    $03 : Case SubClassId Of
            $00 : IdentifyPCISubClass := 'VGA Display-Controller';
            $01 : IdentifyPCISubClass := 'SuperVGA Display-Controller';
            $02 : IdentifyPCISubClass := 'XGA Display-Controller';
            $80 : IdentifyPCISubClass := 'undefinierter Display-Controller';
          Else
            IdentifyPCISubClass := 'unbekannte SubClass-ID (' + StrFnByte (SubclassId)+ ')';
          End;
    $04 : Case SubClassId Of
            $00 : IdentifyPCISubClass := 'Video-Device';
            $01 : IdentifyPCISubClass := 'Audio-Device';
            $80 : IdentifyPCISubClass := 'undefiniertes Multimedia Device';
          Else
            IdentifyPCISubClass := 'unbekannte SubClass-ID (' + StrFnByte (SubclassId)+ ')';
          End;
    $05 : Case SubClassId Of
            $00 : IdentifyPCISubClass := 'RAM Controller';
            $01 : IdentifyPCISubClass := 'Flash Controller';
            $80 : IdentifyPCISubClass := 'undefinierter Memory-Controller';
          Else
            IdentifyPCISubClass := 'unbekannte SubClass-ID (' + StrFnByte (SubclassId)+ ')';
          End;
    $06 : Case SubClassId Of
            $00 : IdentifyPCISubClass := 'Host Bridge';
            $01 : IdentifyPCISubClass := 'ISA Bridge';
            $02 : IdentifyPCISubClass := 'EISA Bridge';
            $03 : IdentifyPCISubClass := 'MCA Bridge';
            $04 : IdentifyPCISubClass := 'PCI to PCI Bridge';
            $05 : IdentifyPCISubClass := 'PCMCIA Bridge';
            $06 : IdentifyPCISubClass := 'NuBus Bridge';
            $07 : IdentifyPCISubClass := 'CardBus Brige';
            $80 : IdentifyPCISubClass := 'undefiniertes Bridge-Device';
          Else
            IdentifyPCISubClass := 'unbekannte SubClass-ID (' + StrFnByte (SubclassId)+ ')';
          End;
    $07 : Case SubClassId Of
            $00 : IdentifyPCISubClass := 'Serieller Controller';
            $01 : IdentifyPCISubClass := 'Paralleler Controller';
            $80 : IdentifyPCISubClass := 'undefinierter Kommunikationscontroller';
          Else
            IdentifyPCISubClass := 'unbekannte SubClass-ID (' + StrFnByte (SubclassId)+ ')';
          End;
    $08 : Case SubClassId Of
            $00 : IdentifyPCISubClass := 'PIC';
            $01 : IdentifyPCISubClass := 'DMA Controller';
            $02 : IdentifyPCISubClass := 'Timer';
            $03 : IdentifyPCISubClass := 'RTC';
            $80 : IdentifyPCISubClass := 'undefinierte System-Peripherie';
          Else
            IdentifyPCISubClass := 'unbekannte SubClass-ID (' + StrFnByte (SubclassId)+ ')';
          End;
    $09 : Case SubClassId Of
            $00 : IdentifyPCISubClass := 'Keyboard Controller';
            $01 : IdentifyPCISubClass := 'Digitizer Pen';
            $02 : IdentifyPCISubClass := 'Mouse Controller';
            $80 : IdentifyPCISubClass := 'undefiniertes Input-Device';
          Else
            IdentifyPCISubClass := 'unbekannte SubClass-ID (' + StrFnByte (SubclassId)+ ')';
          End;
    $0A : Case SubClassId Of
            $00 : IdentifyPCISubClass := 'Generic Docking Station';
            $80 : IdentifyPCISubClass := 'undefiniertes Docking-Geraet';
          Else
            IdentifyPCISubClass := 'unbekannte SubClass-ID (' + StrFnByte (SubclassId)+ ')';
          End;
    $0B : Case SubClassId Of
            $00 : IdentifyPCISubClass := '386';
            $01 : IdentifyPCISubClass := '486';
            $02 : IdentifyPCISubClass := 'Pentium';
            $10 : IdentifyPCISubClass := 'Alpha';
            $20 : IdentifyPCISubClass := 'PowerPC';
            $40 : IdentifyPCISubClass := 'Coprocessor';
          Else
            IdentifyPCISubClass := 'unbekannte SubClass-ID (' + StrFnByte (SubclassId)+ ')';
          End;
    $0C : Case SubClassId Of
            $00 : IdentifyPCISubClass := 'FireWire (IEEE 1394)';
            $01 : IdentifyPCISubClass := 'Access Bus';
            $02 : IdentifyPCISubClass := 'SSA';
            $03 : IdentifyPCISubClass := 'USB';
            $04 : IdentifyPCISubClass := 'Fiber Channel';
          Else
            IdentifyPCISubClass := 'unbekannte SubClass-ID (' + StrFnByte (SubclassId)+ ')';
          End;
  Else
    IdentifyPCISubClass := 'unbekannte SubClass-ID (' + StrFnByte (SubclassId)+ ')';
  End;
End;


Begin
End.