{$O+,F+}
Unit DetectConstants;

Interface
{ Hier wir bei jeder neuen Sektion Const verwandt, um den Compiler dazu
  zu bringen, nur das zu kompilieren, was auch wirklich gebraucht wird. Das
  gibt bei kleinen Programmen wieder 'nen Platzvorteil im Datensegment. }

Const UnitVersion = '1.18d-· BETA';

Const
      { Allgemeine Konstanten }

      dalError          = 255;  { Allgemeiner Fehler }

      { Konstanten fÅr CPU-Typen }
Const
      dcpUnknown        = 0;  { Unbekannt          }
      dcpIn8088         = 1;  { Intel 8088         }
      dcpIn8086         = 2;  { Intel 8086         }
      dcpIn80C88        = 3;  { Intel 80C88        }
      dcpIn80C86        = 4;  { Intel 80C86        }
      dcpNECV20         = 5;  { NEC VC20           }
      dcpNECV30         = 6;  { NEC VC30           }
      dcpIn80188        = 7;  { Intel 80188        }
      dcpIn80186        = 8;  { Intel 80186        }
      dcpIn80286        = 9;  { Intel 80286        }
      dcpIn80386        = 10; { Intel 80386dx      }
      dcpIn80386SX      = 11; { Intel 80386sx      }
      dcpC_T38600DX     = 12; { C&T 38600dx        }
      dcpC_T38600SX     = 13; { C&T 38600sx        }
      dcp486DLC         = 14; { Cyrix 486 dlc      }
      dcp486SLC         = 15; { Cyrix 486 slc      }
      dcpInRapidCAD     = 16; { Intel RapidCad     }
      dcpIn80486        = 17; { Intel 80486dx      }
      dcpIn80486SX      = 18; { Intel 80486sx      }
      dcpInPentium      = 19; { Intel Pentium      }
      dcpNexGen         = 20; { Nexgen CPU         }
      dcpVarCyrix       = 21; { Cyrix-Prozessoren *}

      { Konstanten fÅr Coprocessor-Typen }
Const
      dndNone           = 0;    { kein Koprozessor                      }
      dndEmulViaInt7    = 1;    { Koprozessor via Interrupt 7h emuliert }
      dndIn8087         = 2;    { Intel 8087                            }
      dndIn80C187       = 3;    { Intel 80C187                          }
      dndIn80287        = 4;    { Intel 80287                           }
      dndIn80287XL      = 5;    { Intel 80287XL                         }
      dndIn80387        = 6;    { Intel 80387                           }
      dndIn80387sx      = 7;    { Intel 80387sx                         }
      dndIIT2C87        = 8;    { IIT 2C87                              }
      dndIIT3C87        = 9;    { IIT 3C87                              }
      dndIIT3C87sx      = 10;   { IIT 3C87sx                            }
      dndCyr82S87Old    = 11;   { Cyrix 82S87 (alte Version)            }
      dndCyr34D87       = 12;   { Cyrix 34D87                           }
      dndCyr83S87Old    = 13;   { Cyrix 83S87 (alte Version)            }
      dndULSI83C87      = 14;   { ULSI 83C87                            }
      dndULSI83S87      = 15;   { ULSI 83S87                            }
      dndC_T38700DX     = 16;   { C&T 38700dx                           }
      dndC_T38700SX     = 17;   { C&T 38700sx                           }
      dndIn80387dx      = 18;   { Intel 80387dx                         }
      dndInRapidCAD     = 19;   { Intel RapidCad                        }
      dndIn486          = 20;   { Intel 80486 FPU                       }
      dndCyr82S87new    = 21;   { Cyrix 82S87 (neue Version)            }
      dndCyr387pl       = 22;   { Cyrix 387+                            }
      dndCyr83S87new    = 23;   { Cyrix 83S87 (neue Version)            }
      dndCyrEMC87       = 24;   { Cyrix EMC87                           }
      dndInPentium      = 25;   { Intel Pentium FPU                     }
      dndUnknown        = $FF;  { Unbekannt                             }

      { Konstanten fÅr Weitek-Typen }
Const
      dwtnoWeitek       = 0;   { kein Weitek Prozessor }
      dwtWeitek         = 1;   { Weitek                }
      dwtWeitek_Real    = $81; { Real-Weitek           }

      { Konstanten fÅr CPUId / Alle Hersteller }
Const
      dcuIAMMXSupp       = $800000;    { Bit 23 }
      dcuCMOVcc          = $8000;      { Bit 15 }
      dcuMashineCheck    = $4000;      { Bit 14 }
      dcuPageGlobalEn    = $2000;      { Bit 13 }
      dcuMemTypeRangeReg = $1000;      { Bit 12 }
      dcuLocalAPIC       = $200;       { Bit 9  }
      dcuCMPXCHG8B       = $100;       { Bit 8  }
      dcuMException      = $80;        { Bit 7  }
      dcuAddressingExt   = $40;        { Bit 6  }
      dcuPentiumMSR      = $20;        { Bit 5  }
      dcuTSCSupp         = $10;        { Bit 4  }
      dcuPageExt         = 8;          { Bit 3  }
      dcuIOBreaks        = 4;          { Bit 2  }
      dcuEnhV86Mode      = 2;          { Bit 1  }
      dcuFPU             = 1;          { Bit 0  }


      { Konstanten fÅr CPUId / AMD }
Const
      dcuAmIAMMXSupp       = $800000;    { Bit 23 }
      dcuAmFloatCondMove   = $10000;     { Bit 16 }
      dcuAmIntCondMove     = $8000;      { Bit 15 }
      dcuAmGlobalPagExt    = $2000;      { Bit 13 }
      dcuAmSysCallSysRet   = $400;       { Bit 10 }
      dcuAmCMPXCHG8B       = $100;       { Bit 8  }
      dcuAmMException      = $80;        { Bit 7  }
      dcuAmK86MSR          = $20;        { Bit 5  }
      dcuAmTSCSupp         = $10;        { Bit 4  }
      dcuAmPageExt         = 8;          { Bit 3  }
      dcuAmDebExt          = 4;          { Bit 2  }
      dcuAmVModeExt        = 2;          { Bit 1  }
      dcuAmFPU             = 1;          { Bit 0  }

      { Konstanten fÅr Keyboardtypen }
Const
      dkbXT             = 1; { XT-Tastatur               }
      dkbEnhanced       = 2; { 101/102 Enhanced Tastatur }

      { Konstanten fÅrt A-20 Leitung }
Const
      da2Enabled        = 1; { A20 Line aktiv            }
      da2Disabled       = 2; { A20 Line inaktiv          }
      da2Unknown        = 3; { A20 Line Status unbekannt }

      { Konstanten fÅr Sound Blaster }
Const
      dsbNone           = 0; { Keine Soundkarte gef. }
      dsbNormal         = 1; { Sound Blaster Mono    }
      dsbPro            = 2; { Sound Blaster Stereo  }
      dsb16             = 3; { Sound Blaster 16      }
      dsb16ASP          = 4; { Sound Blaster 16 ASP  }

      { Konstanten fÅr Bus-Typen }
Const
      dbuISA            = 0;   { ISA Bus             }
      dbuEISA           = 1;   { Extended ISA Bus    }
      dbuMCA            = 2;   { Micro Channel Bus   }
      dbuVL             = 3;   { Vesa Local Bus      }
      dbuPCI            = 4;   { PCI Bus             }
      dbuUnknown        = $FF; { Unbekannter Bus-Typ }

      { Konstanten fÅr EISA-Funktionen }
Const
      deiErrInvalidSlot      = 0; { UngÅltige Slot-Nummer         }
      deiErrEISACMOSCorrupt  = 1; { EISA CMOS ungÅltig            }
      deiErrEmptySlot        = 2; { Slot ist leer                 }
      deiErrInvalidSysConfig = 3; { UngÅltige Systemkonfiguration }
      deiYes                 = 4; { Ja                            }
      deiNo                  = 5; { Nein                          }

      { Konstanten fÅr die IDE/EIDE ((Extended) Imbedded Drive Electronics)
        Schnittstelle }
Const
      datATA   = 1; { AT Atachement                  }
      datATAPI = 2; { AT Atachement Packed Interface }

      { Konstanten fÅr die ATA(PI) Konfigurationsabfrage. Die Werte, die
        nur auf ATAPI funktionieren sind mit ATAPI gekennzeichnet, welche
        auf beiden funktionieren mit ATA(PI) und welche nur auf ATA
        funktionieren gar nicht. }

      datSerienNummer  = 1; { Ermittelt die Seriennummer      (ATA(PI)) }
      datFirmRev       = 2; { Ermittelt die Firmware-Revision (ATA(PI)) }
      datModellNummer  = 3; { Ermittelt die Modellnummer      (ATA(PI)) }
      datPIOTiming     = 4; { Ermittelt den Timing-Mode des PIO.
                              (ATA(PI))                                 }
      datDMATiming     = 5; { Ermittelt den Timing Mode des DMA.
                              (ATA(PI))                                 }
      datWhatDevice    = 6; { Ermittelt, welches GerÑt an diese
                              Schnittstelle angeschlossen ist (ATAPI)   }
      datDatenrate     = 7; { Ermittelt die Datentransferrate in MBit/s }
      datEnhPIO        = 8; { Ermittetl die Enhanced PIO Version
                              (ATAPI)                                   }
      datBuffertype    = 9; { Ermittelt den Typ des Puffers des Devices.
                              (ATA(PI))                                 }
      datKapaInSekt    = 10; { Ermittelt die KapazitÑt der Platte in
                               Sektoren. }
      datLBASektoren   = 11; { Ermittelt die Anzahl der Sektoren, die mit
                               der LBA-Methode adressiert werden kînnen.}


      datGeschw        = 1;  { Ermittelt, ob eine Geschwindigkeits-
                               toleranzlÅcke beim Formatieren nîtig ist. }
      datSpurVersatz   = 2;  { Ermittelt, ob die Spurversatzoption
                               vorhanden ist.                            }
      datDatentakt     = 3;  { Ermittelt, ob eine Datentakt-Offset
                               Option vorhanden ist.                     }
      datDrehzahltol   = 4;  { Ermittelt, ob die Drehzahltoleranz grî·er
                               als 0,5 % ist.                            }
      datFestplatte    = 5;  { Ermittelt ob das Medium eine Fest- oder
                               Wechselplatte ist.                        }
      datSpindel       = 6;  { Ermittelt, ob eine Spindelmotorsteuerung
                               implementiert ist.                        }
      datKopfUmsch     = 7;  { Ermittelt, ob die Kopfumschaltzeit grî·er
                               als 15 Ês ist.                            }
      datMFM           = 8;  { Ermittelt, ob die MFM-Kodierung angewandt
                               wurde.                                    }
      datSoftSekt      = 9;  { Ermittelt, ob die Platte softsektoriert
                               ist.                                      }
      datHardSekt      = 10; { Ermittelt, ob die Platte hardsektoriert
                               ist.                                      }
      datWechselMed    = 11; { Ermittelt, ob das Device ein Wechselmedium
                               ist. (ATAPI)                              }
      datMultiSekt     = 12; { Ermittelt, ob die Platte Multisektor R/W
                               erlaubt. }
      dat16BitIO       = 13; { Ermittelt, ob auf dem Device 16-Bit
                               Datentransfers mîglich sind. (ATA(PI))    }
      datISIORDY       = 14; { Ermittelt, ob das IORDY-Protokoll unter-
                               stÅtzt wird. (ATA(PI))                    }
      datIsDisIORDY    = 15; { Ermittelt, ob man das IORDY-Protokoll de-
                               aktivieren kann. (ATA(PI))                }
      datIsLBA         = 16; { Ermittelt, ob das LBA-Protokoll unter-
                               stÅtzt wird. (ATA(PI))                    }
      datIsDMA         = 17; { Ermittelt, ob der DMA-Zugriff auf das
                               Device unterstÅtzt wird. (ATA(PI))        }
      datIsInf         = 18; { Ermittelt, ob datKapaInSekt und datDM???
                               gÅltig sind. }

      datZylinder        = 1; { Ermittelt die Anzahl der Zylinder auf der
                                Platte.                                   }
      datHrsZylinder     = 2; { Ermittelt die Anzahl der herausnehmbaren
                                Zylinder auf der Platte.                  }
      datKoepfe          = 3; { Ermittelt die Anzahl der R/W Koepfe       }
      datBytesSpurUnf    = 4; { Ermittelt Bytes pro Spur unformatiert     }
      datBytesSekUnf     = 5; { Ermittelt Bytes pro Sektor unformatiert   }
      datSekSpur         = 6; { Ermittelt die Sektoren pro Spur           }
      datPufferGrSek     = 7; { Ermittelt die Grî·e des Puffers in Sek-
                                toren. (ATA(PI))                          }
      datMultipleSekt    = 8; { Ermittelt die maximale Anzahl der Sek-
                                toren, die in einem Rutsch gelesen werden
                                kînnen.                                   }
      datDMZylinder      = 9; { Ermittelt Drive Mapping Zylinder          }
      datDMKoepfe        = 10; { Ermittelt Drive Mapping Koepfe           }
      datDMSektorenSpur  = 11; { Ermittelt Drive Mapping Sektoren/Spur    }
      datAktSWDMAM       = 12; { Aktuelle Single-Word DMA-Mode
                                 (ATA(PI))                                }
      datUntSWDMAM       = 13; { UnterstÅtzte Single-Word DMA-Modi
                                 (ATA(PI))                                }
      datAktMWDMAM       = 14; { Aktuelle Multi-Word DMA-Mode
                                 (ATA(PI))                                }
      datUntMWDMAM       = 15; { UnterstÅtzte Multi-Word DMA-Modi
                                 (ATA(PI))                                }
      datMinZykMWDMA     = 16; { Minimale Zykluszeit fÅr Multiword DMA,
                                 minimal 150 ns. (ATAPI)                  }
      datEmpfZykMWDMA    = 17; { Empfohlene Zykluszeit fÅr Multiword DMA
                                 (ATAPI)                                  }
      datMinZykPIOOIORDY = 18; { Minimale Zykluszeit fÅr PIO ohne IORDY-
                                 Protokoll, minimal 180 ns. (ATAPI)       }
      datMinZykPIOMIORDY = 19; { Minimale Zykluszeit fÅr PIO mit IORDY-
                                 Protokoll, minimal 180 ns. (ATAPI)       }

      { Konstanten fÅr Windows }
Const
      dwiNothing           = 0; { Kein Windows                     }
      dwi386_2_X           = 1; { WIN/386 2.X                      }
      dwi3_0_Real_Standard = 2; { WIN Real oder Standard Mode 3.0  }
      dwiEnhanced          = 3; { WIN/386 erweitert (Extra Info's) }

      { Konstanten fÅr SmartDriveTyp }
Const
      dsmNo              = 0; { Kein Smartdrive                     }
      dsmDevice          = 1; { Device-Smartdrive                   }
      dsmIOCTL           = 2; { IOCTL-Smartdrive                    }
      dsmIOCTLNSupport   = 3; { vielleicht, IOCTL nicht unterstÅtzt }
      dsmIOCTLReadError  = 4; { vielleicht, IOCTL Lesefehler        }

      { Konstanten fÅr SmartDrive-Laufwerksabfrage }
Const
      dsmdTrue           = 1; { Ja                }
      dsmdFalse          = 2; { Nein              }
      dsmdNo             = 3; { nicht installiert }

      { Konstanten fÅr PCTools }
Const
      dpcDesktopHotkey     = 1;
      dpcClipboardPasteKey = 2;
      dpcClipboardCopyKey  = 3;
      dpcScreenAutoDialKey = 4;

      { Konstanten fÅr LPT-Port Auslesung }
Const
      dpdBusy     = $80;
      dpdAck      = $40;
      dpdPaperOut = $20;
      dpdSelected = $10;
      dpdIOError  = $08;
      dpdTimedOut = $01;

      { Konstanten fÅr COM-Port Auslesung }
Const
      dpsRLSD  = $80;
      dpsRI    = $40;
      dpsDSR   = $20;
      dpsCTS   = $10;
      dpsdRLSD = 8;
      dps_dRI  = 4;
      dpsdDSR  = 2;
      dpsdCTS  = 1;

      { Konstanten fÅr Disk-Typen und Ñhnliches }
Const
      ddiLocal  = 0;
      ddiRemote = 1;
      ddiShare  = 2;

      ddiNoDrive  = $FF;
      ddiFloppy   = 0;
      ddiHard     = 1;
      ddiNet      = 2;
      ddiSubst    = 3;
      ddiCDRom    = 4;
      ddiInterlnk = 5;
      ddiMOD      = 6;

      { Konstanten fÅr das VESA Audio Interface }
Const daiWave   = 1;
      daiMidi   = 2;
      daiVolume = 3;

      daiGENI   = 1;
      daiVOLI   = 2;

      { Konstanten fÅr die Chipset-Erkennung }
Const dchCyrix486dx     = 0;
      dchCyrix486lc     = 1;
      dchCyrix5_6x86    = 2;
      dchIntelTriton    = 3;
      dchIntelSaturn    = 4;
      dchIntelMercury   = 5;
      dchIntelNeptun    = 6;
      dchIntelPCISet    = 7;
      dchIntelTXC       = 8;
      dchUM82C481A      = 9;
      dchUM82C391A      = 10;
      dchUMC82C881      = 11;
      dchUMC82C881HB4   = 12;
      dchUMC82C891      = 13;
      dchUMC82C8891     = 14;
      dchSis501         = 15;
      dchSis5511        = 16;
      dchLSIHYDRA       = 17;
      dchLSIASPEN       = 18;
      dchNexGenVL82C500 = 19;
      dchAcerALIM1451   = 20;
      dchAcerALIM1461   = 21;
      dchIMSDiamond     = 22;
      dchVIAApollo      = 23;
      dchUnknown        = $FF;

      { Konstanten fÅr die Cyrix/TI Prozessoren }
Const dreCCR0          = $C0;
      dreCCR1          = $C1;
      dreCCR2          = $C2;
      dreCCR3          = $C3;
      dreCCR4          = $E8;
      dreCCR5          = $E9;
      dreCR            = $F0;
      dreCDR           = $20;
      dreDIR0          = $FE;
      dreDIR1          = $FF;

      { Konstanten fÅr Software-Abfragen (bei einem + sind Extrainforma-
        tionen Åber WhichAddress verfÅgbar, bei einem - ist keine
        IsInstalled-Prozedur vorhanden) }
Const
      Assign       = 1;
      DriverSys    = 2;
      Share        = 3;
      Redifs       = 4;
      Multidos     = 5;
      NlsFunc      = 6;
      Win386       = 7;   { Siehe auch die anderen Windows Routinen }
      DosShell     = 8;
      AnsiSys      = 9;
      Xma2EmsSys   = 10;
      Himem        = 11;
      NNIPX        = 12;  { Novell Netware IPX }
      Display      = 13;  { DISPLAY.SYS }
      DICExt       = 14;  { Dos installable Command Extender }
      IBM3270      = 15;
      Append       = 16;
      LAN          = 17;
      LANREC       = 18;
      LANREDIR     = 19;
      GrafTable40  = 20;
      GrafTable50  = 44;
      MSCDExt      = 21;  { Microsoft CD Extensions }
      _4Dos        = 22;
      NDos         = 23;
      KStack       = 24;
      WildUnix     = 25;
      Arnakey      = 26;
      TaskSwitch5  = 27;  { DOS 5 Task Switcher }                                             {+}
      DrDosTskMx   = 28;  { DR Dos Task Max }
      FPFLock      = 29;  { F-Prot Antivirus F-Lock }
      FPFXChk      = 30;  { F-Prot Antivirus F-XChk }
      FPFPopUp     = 31;  { F-Prot Antivirus F-PopUp }
      FPFDLock     = 32;  { F-Prot Antivirus F-DLock }
      FluShot      = 33;  { Anti Virus Programm }
      HyperDisk    = 34;  { Shareware Cache Programm }
      MSLanTastic  = 35;  { Microsoft Lantastic }
      Inset        = 36;
      Dos_16M      = 37;  { DOS/16M Extender }
      Phar_Lap     = 38;  { Phar Lap Dos Extender }
      N_Cache_F    = 39;  { Norton Utilities N-Cache F }
      N_Cache_S    = 40;  { Norton Utilities N-Cache S }
      N_DiskReet   = 41;  { Norton Utilities N-DiskReet }
      N_DiskMon    = 42;  { Norton Utilities N-DiskMonitor }
      N_FileSav    = 43;  { Norton Utilities N-FileSav }
      EGASys       = 45;  { Bildschirmtreiber fÅr Dos }
      Print        = 46;  { PRINT.COM von Dos }
      NETBiosApp   = 47;  { NB-Append  }
      NETBiosNetW  = 48;  { NB-Network }
      ShellB       = 49;
      GraphicsCom  = 50;
      DosKey       = 51;
      TopWNetOs    = 52; { Topware Network Operating System }
      AutoParkCom  = 53; { AUTOPARK.COM ist ein residenter Hard-Disk-Parker
                           von Alan D. Jones }
      AutoBraille  = 54; { AutoBraille ist ein Shareware Text zu
                           Lautschrift Konverter von KANSYS, Inc. }
      Jot_It       = 55; { Jot-It }
      RedView      = 56; { RedView ist ein PD-Tsr von Alexandr Novy und
                           Petr Horak, welches den Text, welcher Åber
                           Standard Output ausgegebene Daten am
                           Bildschirm sichtbar macht }
      Explosiv     = 57; { Explosiv ist ein Dos- und Windows-Bildschirm-
                           schoner von Reidar Gresseth und Chris Hook. }
      IntelImg     = 58; { Intel Image Processing Interface }
      SwellExe     = 59; { SWELL.EXE verschiebt ein Programm auf die
                           Festplatte, wenn es einen EXEC-Befehl AusfÅhrt }
      ZwMouse      = 60; { ZWMouse Bringt vielen Nicht-Maus Programmen
                           MausfÑhigkeit, indem immer der Buchstabe unter
                           dem Mauscursor vom Programm eingegeben wird.  + }
      HeartCom     = 61; { Erkennt kritische Sektionen in einem Programm. }
      GridLocExe   = 62; { GRIDLOC.EXE ist ein Sicherheitsprogramm fÅr den
                           PC von Intelligent Security Systems, Inc. }
      _4MAp        = 63; { 4Dos Utility }
      MinMem       = 64; { Ein Shareware TSR Manager von Biologic, welcher
                           es erlaubt bis zu 24 TSR's in den Speicher zu
                           laden und sie auf Festplatte auszulagern. }
      METZTSRCom   = 65; { METZ-TSR's }
      VidLockCom   = 66; { Memory Residente Uhr von Thomas G. Hanlin III }
      BTrieveMU    = 67; { BTrieve Multi-User }
      PC3270Emu3   = 68; { IBM PC 3270 Emulator v3 }
      EasyNet      = 69; { Easy-Net is ein Shareware Zwei-Computer seriell-
                           Netzwerk. }
      TurboNetSer  = 70; { TurboNET ist ein auf NETBios basierender
                           Redirector und Server von Nanosoft, Inc. }  {+}
      FaxBiosInt   = 71; { kann mehrere Multiplex-Nummern nutzen. }
      ResPlay      = 72;
      WhoaCom      = 73; { WHOA!.COM ist ein Utility von Brad D Crandall,
                           mit dem man die Geschwindigkeit des Rechners
                           herunterstellen kann. }
      Raid         = 74; { Resident Aid ist ein Tsr, das grî·tenteils im
                           EMS fungiert. }
      InnerMission = 75;                                               {+}
      PCT7DataMon  = 76; { PcTools v7.x+ Data Monitor }                {+}
      ScrnSav2Com  = 77;
      _3ComBApiSIO = 78; { 3com BAPI SERIAL I/O }
      Asap         = 79; { Asap (Automatic Screen Access Program) ist ein
                           Shareware Screen-Shot Programm von MicroTalk +}
      CouriersCom  = 80; { COURIERS.COM ist ein Tsr vom PC Magazine }
      QCache       = 81;
      ScroLockCom  = 82; { SCROLOCK.COM ist ein mit den System Enhancements
                           Associates' ARC mitgeliefertes Utility. }
      FastBuffCom  = 83;                                               {+}
      ATIWonSupSw  = 84; { ATI EGA/VGA Wonder Super Switch (SMS.COM) ist
                           ein mit der ATI EGA Wonder mitgeliefertes
                           Utility, was Video-Modes umstellt.}
      KWTsrWin     = 85; { KingsWood TSR Windows }                     {+}
      KWNoBusy     = 86; { KingsWood NoBusy }                          {+}
      KWCDStack    = 87; { KingsWood CD-Stack }                        {+}
      KWDiskWatch  = 88; { KingsWood DiskWatch }                       {+}
      KWPushBP     = 89; { KingsWood PushBP }                          {+}
      KWAlias      = 90; { KingsWood Alias }                           {+}
      KWKeyMacro   = 91; { KingsWood KeyMacro }                        {+}
      KWSlowDown   = 92; { KingsWood SlowDown }                        {+}
      KWAnsiGrab   = 93; { KingsWood AnsiGrab }                        {+}
      KWTee        = 94; { KingsWood Tee }                             {+}
      KWFastMous   = 95; { KingsWood FastMouse }                       {+}
      KWExtWild    = 96; { KingsWood ExtWild }                         {+}
      KWBreakOut   = 97; { KingsWood BreakOut }                        {+}
      KWStopDisk   = 98; { KingsWood StopDisk }                        {+}
      Tame         = 99; { Tame }                                      {+}
      CAMSCSI      = 100; { Common Acces Method SCSI }
      CMCISCSIDrv  = 101; { CMC International SCSI Driver }
      VUImgDrv     = 102; { VUImage Display Driver (Version 2.20-)
                            VUImage ist ein Shareware GIF/TIFF Viewer
                            von Offe Enterprises. Der Displaydriver
                            wird ab Version 2.20 nicht mehr benîtigt. }
      TinyTalk     = 103; { TinyTalk ist ein Shareware Screen-Reader von
                            OMS Development/Eric Bohlman }
      Fast         = 104; { FAST! }
      SWBiosC      = 105; { SWBios auf Laufwerk C }
      SWBiosD      = 106; { SWBios auf Laufwerk D}
                          { SWBios ist ein TSR von Ontrack Computer Systems.
                            Der Diskmanager unterstÅtzt diese Calls auch ! }
      ErgoOS2_386  = 107; { Ergo Dos Extender OS286 oder OS386 }
      ErgoHuming   = 108; { Ergo Dos Extender HumingBoard }
      Dos3         = 109; { DOS 3.0 Datenseg. (IBMDOS.COM/MSDOS.SYS) } {-+}
      Back_Forth   = 110; { Back & Forth ist ein Dos-Task-Switcher }
      Tes          = 111; { Tes ist ein Netzwerk-Emulationsprogramm fÅr
                            die serielle Schnittstelle von Interconnections,
                            Inc. }
      AvatarSys    = 112; { AVATAR.SYS ist ein CON-Ersatz von George Adam
                            Stanislav, welches AVATAR-Kommandos wie ANSI.SYS
                            interpretiert. Es identifiziert sich auch als
                            ANSI.SYS. }
      SBSpeechDrv  = 113; { Sound Blaster speech Driver }               {+}
      SRDisk       = 114; { SRDisk ist eine in der Grî·e verÑnderbare
                            Freeware-Ramdisk von Marko Kohtala }
      DVQExt       = 115; { DesqView - QUARTERDECK EXTENDED MEMORY MANAGER
                            286 }                                       {+}
      TextCapCom   = 117; { TextCap 2.0 ist eine von Gisbert W. Selke stark
                            modifizierte Version vom PC Magazine Utility
                            CAPTURE, geschrieben von Tom Kihlken }
      FakeyCom     = 118; { Fakey ist ein Keystroke-Faking-Program von den
                            System Enhancements Associates }
      WatchCom     = 119; { Watch ist ein Teil von dem TSR-Paket von Kim
                            Kokkonen }
      PushDirCom   = 120; { PC Magazine PUSHDIR.COM }
      MakeyCom     = 121; { Makey ist ein Utility von den System
                            Enhancements Associates }
      Scout        = 122; { Scout ist ein speicherresidenter Dateimanager
                            von New-Ware }
      EGApalCom    = 123; { Ctrl-Alt Associates EGAPAL.COM ist ein mit
                            Stackey mitgeliefertes Utility, das die
                            EGA-Palette Åber verschiedene Modes hinweg
                            speichert. }                                {+}
      VGAPalCom    = 124; { Ctrl-Alt Associates VGAPAL.COM ist ein mit
                            Stackey mitgeliefertes Utility, das die
                            VGA-Palette Åber verschiedene Modes hinweg
                            speichert. }                                {+}
      LPTx4        = 125; { LPTx 4.x }                                  {+}
      LPTx5        = 126; { LPTx 5.x }                                  {+}
      LPTx6        = 127; { LPTx 6.x }                                  {+}
      LPTx7        = 128; { LPTx 7.x }                                  {+}
      FlashUpCom   = 129; { FlashUp ist ein Teil der Flash-Up Windows von
                            The Software Bottling Co. }
      SpeedScrCom  = 130; { SpeedScr ist ein Utility von The Software
                            Bottling Co. }
      Stackey      = 131; { CtrlAlt Associates STACKEY.COM ist ein Share-
                            ware Keyboard-Input-Faking Utility. }       {+}
      PCT5BackTalk = 132; { PCTools 5.1+ BackTalk }                     {+}
      PCT7CpShDesk = 133; { PCTools 7.0+ CPShedule/Desktop }            {+}
      PCT6Cache    = 134; { PCTools 6.0+ PC Cache }
      PCT5Shell    = 135; { PCTools 5.1+ PC Shell }
      PCT5ShellRes = 136; { PCTools 5.1+ PC Shell resident }
      PCT6Run      = 137; { PCTools 6.0+ PC Run }
      PCT5Desktop  = 138; { PCTools 5.1+ DESKTOP.EXE }                  {+}
      PCT5Cache    = 139; { PCTools 5.x+ PC Cache }
      ElRes        = 140;
      CompaqAdapt  = 141; { ADAPT.COM ist Compaq's Advanced Display Attribute
                            Programming Tool, optional kann es resident ge-
                            laden werden, was die Mîglichkeit gibt, die
                            Bildschirmfarben zu Ñndern und den Screen-Blanker
                            aufzurufen. }
      ConcDos      = 142; { Concurrent DOS }
      DietOvr      = 143; { DIET Overlay Mode (DIET ist ein .EXE-Kompres-
                            sionsprogramm. }
      DosEdCom     = 144; { DOSED.COM ist ein Freeware Kommandozeileneditor
                            mit History Option von SVerre H. }
      Dos4_G       = 145; { Rational Systems DOS/4G }
      CuckooCom    = 146; { Cuckoo ist eine Screen-Uhr mit einer Option
                            zum stÅndlichen piepen oder 'Kuckuck' von
                            einem unbekanntem Autor mit Revisionen von
                            Thomas A. Lundin. }
      DecNetDCT    = 147; { DECnet DOS CTERM }
      ANSK         = 148; { Alloys Netware Support Kit }
      CTask        = 149; { CTask 2.0+ ist ein Multitasking Kernel in fÅr
                            C, geschrieben von Thomas Wagner }
      ZipKey       = 150; { Zipkey ist eine residente amerikanische
                            Postleitzahlendatenbank von Eric Isaacson }
      Unchain      = 151; { UNCHAIN ist ein TSR von Colin Buckley, da· es
                            ermîglicht Borlands Entwicklertools auch ohne
                            zweiten Monitor mit Mode X einzusetzen. }
      BlankIt      = 152; { Blank-It ist ein residenter Bildschirmschoner von
                            Rhode Island Soft Systems, Inc. }
      Parker       = 153; { PARKER ist ein HD-Park Programm von Johan
                            Zwiekhorst, da· auch resident geladen werden
                            kann. }
      ScreenR      = 154; { SCREENR ist ein mit Patrick Ibbetson's SCREEN
                            display Utility geliefertes TSR. }
      Stacker      = 155; { Stacker ist ein Festplattenverdoppler. }
      BWLPD        = 156; { Beame&Whiteside LPD ist der Printer-Daemon der
                            BW-NFS Package }
      ScanBoot     = 157; { ScanBoot ist ein Anit-Virus TSR der Firma
                            PanSoft }
      BWCOM14      = 158; { BWCOM14 ist ein Serial-Port Emulator, der ein
                            Hayes-Modem vortÑuscht. Es ist Bestandteil der
                            BW-NFS Package. }
      TelAPI       = 159; { TelAPI }
      ObjectKernel = 160; { Der Object Kernel fÅr Dos ist ein Programm von
                            M.W. Pieters, das noch bei der Entwicklung ist. }
      UltraVision  = 161;
      UltraFont    = 161; { UltraFont ist eine vereinfachte Form von Ultra-
                            Vision fÅr den Toshiba. }
      NWCDEX       = 162; { NW CD Extensions }
      DoubleSpace  = 163; { Microsoft DoubleSpace }
      SuperStorPro = 164; { SuperStor Pro }
      K5           = 165; { Shareware Tastaturtreiber K5 }
      SoftwCarous  = 166; { Taskswitcher Software Carousel }
      Fastflip     = 167; { Taskswitcher Fastflip }

Implementation

End.