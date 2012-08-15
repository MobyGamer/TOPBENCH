Unit DetectATA_PI;

Interface

Function IDEType                                         : Byte;
Function ATA_PIIsDrive (Drive : Char)                    : Boolean;
Function ATA_PIStrings (Drive : Char; InfoNumber : Byte) : String;
Function ATA_PIBools (Drive : Char; InfoNumber : Byte)   : Boolean;
Function ATA_PIWords (Drive : Char; InfoNumber : Byte)   : Word;

Implementation

Uses Dos, Detectconstants, DetectGlobal;

Type pIdeRecord = ^tIdeRecord;
     tIdeRecord = Record                                        { ATA/ATAPI }
       Konfiguration  : Word;                                   { X/X }
         { ATA : 15 = Mode Bit
                   0 = ATA-Mode
                   1 = ATAPI Mode
                 14 = Geschwindigkeits-ToleranzlÅcke beim Formatieren
                   0 = nicht erforderlich
                   1 = erforderlich
                 13 = Spurversatzoption
                   0 = nicht vorhanden
                   1 = vorhanden
                 12 = Datentakt Offset Option
                   0 = nicht vorhanden
                   1 = vorhanden
                 11 = Drehzahltoleranz
                   0 = kleiner als 0,5 %
                   1 = grî·er als 0,5 %
                 10-8 = Datenrate
                   100 = Grî·er als 10 MBit/s
                   010 = 5 MBit/s .. 10 MBit/s
                   001 = kleiner oder gleich 5 MBit/s
                 7-6 = Plattentyp
                   10 = Wechselplatte
                   01 = Festplatte
                 5 = Spindelmotor Steuerung
                   0 = nicht implementiert
                   1 = implementiert
                 4 = Kopfumschaltzeit
                   0 = kleiner oder gleich 15 Ês
                   1 = grî·er als 15 Ês
                 3 = Kodierung
                   0 = MFM
                   1 = andere
                 2 = 1 = Laufwerk ist softsektoriert
                 1 = 1 = Laufwerk ist hardsektoriert
                 0 = reserviert

           ATAPI : 15-14 = Protokoll Typ
                     0x = ATA
                     10 = ATAPI
                     11 = reserviert
                   13-8 = GerÑtetyp
                     00h = Direct Access Device, meistens Festplatte
                     01h-04h = reserviert
                     05h = CD-ROM
                     06h = reserviert
                     07h = optische Laufwerke wie MOD's
                     08h-1Eh = reserviert
                     1Fh = unbekannter oder kein GerÑtetyp
                   7 = 1 = Wechselmedium
                   6-2 = reserviert fÅr Erweiterungen
                   1-0 = Kommandopaketgrî·e
                     00 = 12 Byte
                     01 = 16 Byte
                     1x = reserviert fÅr Erweiterungen }
       Zylinder       : Word; { Anzahl der Zylinder }           { X/- }
       HrsZylinder    : Word; { Anzahl der herausnehmbaren Z.}  { -/- }
       Koepfe         : Word; { Anzahl der Kîpfe }              { X/- }
       BytesSpurUnf   : Word; { Anzahl der Bytes/Spur unform. } { X/- }
       BytesSekUnf    : Word; { Anzahl der Sekt/Spur unform. }  { X/- }
       SekSpur        : Word; { Anzahl der Sektoren pro Spur }  { X/- }
       InterSectorGap : Word; { Anzahl/Bytes Intersector-Gap }  { X/- }
       SyncFeld       : Word; { Anzahl der Bytes im Sync-Feld } { X/- }
       HerstellerStat : Word; { Anzahl der Words im Hrst-Stat.} { X/- }
       SerienNummer   : Array [1..20] Of Char;                  { X/X }
       PufferTyp      : Word;                                   { X/X }
         { 0000 = nicht spezifiziert
           0001 = single ported sector buffer
           0002 = dual ported multi-sector buffer
           0003 = dual ported multi-sector buffer with read caching
           .... = reserviert }
       PufferGrSek    : Word; { Puffergrî·e in Sektoren }       { X/X }
       ECCBytesRWLong : Word; { Anzahl der ECC-Bytes bei RWL }  { X/- }
       FirmwareRev    : Array [1..8] Of Char;                   { X/X }
       ModellNummer   : Array [1..40] Of Char;                  { X/X }
       MultipleSector : Word;                                   { X/- }
         { Bit 15-8 = Herstellerspezifisch
               7-0  = 00h = Multisector R/W nicht unterstÅtzt
                    = xxh = maximale Anzahl der Sektoren in einem
                            Multisector Read bzw. Write }
       DWordIO        : Word;                                   { X/X }
         { 0000h = GerÑt unterstÅtzt nur 8-Bit-Transfers
           0001h = GerÑt unterstÅtzt 8- und 16-Bit-Transfers }
       Faehigkeiten   : Word;                                   { X/X }
         { Bit 15 = reserviert
           Bit 14-12 = reserviert fÅr zukÅnftige ATAPI-Standards
           Bit 11 = IORDY-Protokoll wird unterstÅtzt
           Bit 10 = IORDY-Protokoll ist abschaltbar
           Bit 9 = LBA-Mode wird unterstÅtzt
           Bit 8 = DMA-Mode wird unterstÅtzt
           Bit 7-0 = herstellerspezifisch }
       Reserved       : Word; { reserviert }                    { X/X }
       TimingModePIO  : Word; { Timingmode bei PIO Datentrans.} { X/X }
         { Bit 15-8 = PIO-Mode
                 00h = PIO Mode 0 (600 ns Zykluszeit)
                 01h = PIO Mode 1 (383 ns Zykluszeit)
                 02h = PIO Mode 2 (240 ns Zykluszeit)
           Bit 7-0 = Reserviert }
       TimingModeDMA  : Word; { Timingmode bei DMA-Datentrans.} { X/X }
         { Bit 15-8 = DMA Mode
                 00h = DMA-Mode 0 (960 ns Zykluszeit)
                 01h = DMA-Mode 1 (480 ns Zykluszeit)
                 02h = DMA-Mode 2 (240 ns Zykluszeit)
           Bit 7-0 = reserviert }
       Ist54_58       : Word; { GÅltigkeitsangabe }             { X/- }
         { Bit 15-1 = reserviert
           Bit 0 = 0 = die Daten in den Words 54-58 sind gÅltig
                   1 = die Daten in den Words 54-58 sind evntl. gÅltig }
       DMZylinder     : Word; { Drive Mapping : Zylinder }      { X/- }
       DMKoepfe       : Word; { Drive Mapping : Kîpfe }         { X/- }
       DMSektorenSpur : Word; { Drive Mapping : Sektoren/Spur } { X/- }
       KapaInSekt1    : Word; { KapazitÑt in Sektoren LoWord }  { X/- }
       KapaInSekt2    : Word; { KapazitÑt in Sektoren HiWord }  { X/- }
       MultipleStatus : Word; { Multiple Sector R/W Status }    { X/- }
         { Bit 15-9 = reserviert
           Bit 8 = 0 = Multiple Sector Einstellung ungÅltig
                   1 = Multiple Sector Einstellung gÅltig
           Bit 7-0 = aktuelle Anzahl der Sektoren, die pro Interrupt
                     Åbertragen werden. }
       LBASektoren1   : Word; { Adr-bare Sektoren in LBA-Mode } { X/- }
       LBASektoren2   : Word; { Adr-bare Sektoren in LBA-Mode } { X/- }
       SingleDMAWord  : Word; { Single-Word DMA-Mode }          { X/X }
         { Bit 15-8 = Derzeit aktiver Einzelword-DMA-Mode
           Bit 7-0 = unterstÅtzte Einzelword-DMA-Modi }
       MultplDMAWord  : Word; { Multi-Word DMA-Mode }           { X/X }
         { Bit 15-8 = Derzeit aktiver Multiword-DMA-Mode
           Bit 7-0 = unterstÅtzte Multiword-DMA-Modi }
       EnhPioMode     : Word; { Enhanced PIO Mode }             { -/X }
         { Bit 15-8 = reserviert
           Bit 7-0 = unterstÅtzte Enhanced PIO Mode
                 $00 = PIO Mode 3
                 $01-$FF = reserviert fÅr zukÅnftige Erweiterungen. }
       MinZykMWDMA    : Word;                                   { -/X }
         { Minimale Zykluszeit fÅr Multiword-DMA in ns, mindestens 150 }
       EmpfZykMWDMA   : Word;                                   { -/X }
         { Empfohlene Zykluszeit fÅr Multiword-DMA in ns }
       MinZykPIOOIORDY: Word;                                   { -/X }
         { Minimale Zykluszeit fÅr PIO ohne IORDY in ns, mindestens 180 }
       MinZykPIOMIORDY: Word;                                   { -/X }
         { Minimale Zykluszeit fÅr PIO mit IORDY in ns, mindestens 180 }
       ReservedPIO4_5 : Array [1..2] Of Word;                   { -/X }
         { Reserviert fÅr Advanced PIO Mode 4&5 }
       Reserved2      : Array [1..56] Of Word;                  { X/X }
       HerstellerSpez : Array [1..31] Of Word;                  { X/X }
       Reserved3      : Array [1..95] Of Word;                  { X/X }
     End;

Const Re : Array [0..1] Of Boolean = (False,False);

Var IdeRecord : pIdeRecord;
    R         : Array [0..255] Of Word;
    DriveN    : Byte;
    UseByType : Char;

Function Read (Drive : Char) : Boolean;

{ Diese Routine liest die Daten in das Array R ein und weist dem
  IDE-Record die Adresse zu. }

  Procedure Translate;

  { Die Words werden von der Platte nicht im Intel-Format (LSB first)
    sondern im Motorola-Format (MSB first) zurÅckgegeben, weshalb man
    bei jedem Word die Bytes vertauschen mu·. Dies erledigt diese
    Routine mit dem Array R. }

  Begin
    For xWord := 10 To 19 Do
      R[xWord] := (Lo(R[xWord]) Shl 8) + Hi(R[xWord]);
    For xWord := 23 To 46 Do
      R[xWord] := (Lo(R[xWord]) Shl 8) + Hi(R[xWord]);
  End;

Var DrivePort  : Word;
    StatusPort : Word;
    DataPort   : Word;
    Ret        : Byte;

Begin
  Case UpCase (Drive) Of
    'C' : Ret := 0;
    'D' : Ret := 1;
  Else
    Ret := 0;
  End;

  If Re[Ret] = False Then
    Begin
      Case UpCase (Drive) Of
        'C' : Begin
                DrivePort  := $1F6;
                StatusPort := $1F7;
                DataPort   := $1F0;
              End;
        'D' : Begin
                DrivePort  := $176;
                StatusPort := $177;
                DataPort   := $170;
              End;
      Else
        Begin
          DrivePort  := $1F6;
          StatusPort := $1F7;
          DataPort   := $1F0;
        End;
      End;

      xBool := False;
      Port[DrivePort]  := $A0;
      Port[StatusPort] := $EC;


      For xWord := 1 To 65000 Do Begin End;

      For xWord := 1 To 65000 Do
        Begin
          If (Port [StatusPort] And $08 = $08) Then xBool := True;
        End;

      If xBool Then
        Begin
          For xWord := 0 To 255 Do
            R[xWord] := PortW [DataPort];
          IdeRecord := @R;
          Translate;
          Read := True;
        End
      Else
        Read := False;
      Port [DrivePort] := $A0;

      Case Ret Of
        0 : Begin Re[0] := True;  Re[1] := False End;
        1 : Begin Re[0] := False; Re[1] := True End;
      End;
    End
  Else
    Read := True;
End;


Function IsBit (Bit : Byte; VarWord : Word) : Boolean;

Const WordTable : Array [0..15]  Of Word = (1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32738);

Begin
  IsBit := ((VarWord And WordTable[Bit]) = 1);
End;


Function IDEType;

Begin
  If Read (UseByType) Then
    Case IsBit (15, IdeRecord^.Konfiguration) Of
      False : IdeType := datATA;
      True : IdeType := datATAPI;
    End
  Else
    IDEType := dalError;
End;


Function ATA_PIIsDrive;

Begin
  If Read (Drive) Then
    Begin
      ATA_PIIsDrive := ((IdeRecord^.Zylinder <> 65535) And (IdeRecord^.Koepfe <> 65535));
    End
  Else
    ATA_PIIsDrive := False;
End;


Function Ata_PiStrings;

Begin
  UseByType := Drive;
  If Read (Drive) Then
    Begin
      If IdeType = datATA Then
        Case InfoNumber Of
          datSerienNummer  : Ata_PiStrings := IdeRecord^.SerienNummer;
          datFirmRev       : Ata_PiStrings := IdeRecord^.FirmwareRev;
          datModellNummer  : Ata_PiStrings := IdeRecord^.ModellNummer;
          datDatenRate     : Begin
                               xWord := IdeRecord^.Konfiguration;
                               If (IsBit (10, xWord) And (Not IsBit (9, xWord)) And
                                  (Not IsBit (8, xWord))) Then Ata_PiStrings :=
                                    'Grî·er als 10 MBit/s' Else
                               If (Not IsBit (10, xWord) And (IsBit (9, xWord)) And
                                  (Not IsBit (8, xWord))) Then Ata_PiStrings :=
                                    '5-10 MBit/s' Else
                               If (Not IsBit (10, xWord) And (Not IsBit (9, xWord)) And
                                  (IsBit (8, xWord))) Then Ata_PiStrings :=
                                    'kleiner oder Gleich 5 MBit/s' Else
                                  Ata_PiStrings := 'unbekannt';
                             End;
          datPIOTiming     : Case Hi(IdeRecord^.TimingModePIO) Of
                               $00 : Ata_PiStrings := 'PIO Mode 0 (600 ns Cycle Time)';
                               $01 : Ata_PiStrings := 'PIO Mode 1 (383 ns Cycle Time)';
                               $02 : Ata_PiStrings := 'PIO Mode 2 (240 ns Cycle Time)';
                             End;
          datDMATiming     : Case Hi(IdeRecord^.TimingModeDMA) Of
                               $00 : Ata_PiStrings := 'DMA Mode 0 (960 ns Cycle Time)';
                               $01 : Ata_PiStrings := 'DMA Mode 1 (480 ns Cycle Time)';
                               $02 : Ata_PiStrings := 'DMA Mode 2 (240 ns Cycle Time)';
                             End;
          datBuffertype    : Case IdeRecord^.Puffertyp Of
                               $0000 : Ata_PiStrings := 'nicht angegeben';
                               $0001 : Ata_PiStrings := 'Single Ported Sector Buffer';
                               $0002 : Ata_PiStrings := 'Dual Ported Multi-Sector Buffer';
                               $0003 : Ata_PiStrings := 'Dual Ported Multi-Sector Buffer mit Read caching';
                             Else
                               Ata_PiStrings := 'unbekannter Typ';
                             End;
          datKapaInSekt    : Ata_PiStrings := Hex (IDERecord^.KapaInSekt2, 4) + Hex (IDERecord^.KapaInSekt1, 4) + 'h';
          datLBASektoren   : Ata_PiStrings := Hex (IDERecord^.LBASektoren2, 4) + Hex (IDERecord^.LBASektoren1, 4) + 'h';
        Else
          Ata_PiStrings := 'falscher Typ'
        End
      Else
        Case InfoNumber Of
          datSerienNummer  : Ata_PiStrings := IdeRecord^.SerienNummer;
          datFirmRev       : Ata_PiStrings := IdeRecord^.FirmwareRev;
          datModellNummer  : Ata_PiStrings := IdeRecord^.ModellNummer;
          datWhatDevice    : Begin
                               { Erst mal die restlichen Bits rausschieben }
                               xByte := IdeRecord^.Konfiguration Shr 8;
                               xByte := xByte Shl 3;
                               xByte := xByte Shr 3;
                               Case xByte Of
                                 $00 : Ata_PiStrings := 'Festplatte';
                                 $05 : Ata_PiStrings := 'CD-ROM';
                                 $07 : Ata_PiStrings := 'Magneto optisch';
                                 $1F : Ata_PiStrings := 'unbekannt oder keins';
                               Else
                                 Ata_PiStrings := 'Unbekannt';
                               End;
                             End;
          datPIOTiming     : Case Hi(IdeRecord^.TimingModePIO) Of
                               $00 : Ata_PiStrings := 'PIO Mode 0 (600 ns Cycle Time)';
                               $01 : Ata_PiStrings := 'PIO Mode 1 (383 ns Cycle Time)';
                               $02 : Ata_PiStrings := 'PIO Mode 2 (240 ns Cycle Time)';
                            End;
          datDMATiming     : Case Hi(IdeRecord^.TimingModeDMA) Of
                               $00 : Ata_PiStrings := 'DMA Mode 0 (960 ns Cycle Time)';
                               $01 : Ata_PiStrings := 'DMA Mode 1 (480 ns Cycle Time)';
                               $02 : Ata_PiStrings := 'DMA Mode 2 (240 ns Cycle Time)';
                             End;
          datEnhPIO        : Case Lo (IdeRecord^.EnhPIOMode) Of
                               $00 : Ata_PiStrings := 'PIO Mode 3';
                               $01 : Ata_PiStrings := 'PIO Mode 4';
                             Else
                               Ata_PiStrings := 'nicht bekannt';
                             End;
          datBuffertype    : Case IdeRecord^.Puffertyp Of
                               $0000 : Ata_PiStrings := 'nicht angegeben';
                               $0001 : Ata_PiStrings := 'Single Ported Sector Buffer';
                               $0002 : Ata_PiStrings := 'Dual Ported Multi-Sector Buffer';
                               $0003 : Ata_PiStrings := 'Dual Ported Multi-Sector Buffer mit Read caching';
                             Else
                               Ata_PiStrings := 'unbekannter Typ';
                             End;
        Else
          Ata_PiStrings := 'falscher Typ';
        End;
    End
  Else
    Ata_PiStrings := 'nicht vorhanden';
End;


Function Ata_PiBools;

Begin
  UseByType := Drive;
  If Read (Drive) Then
    Begin
      If IdeType = datATA Then
        Case InfoNumber Of
          datGeschw      : Ata_PiBools := IsBit (14, IdeRecord^.Konfiguration);
          datSpurVersatz : Ata_PiBools := IsBit (13, IdeRecord^.Konfiguration);
          datDatentakt   : Ata_PiBools := IsBit (12, IdeRecord^.Konfiguration);
          datDrehzahltol : Ata_PiBools := IsBit (11, IdeRecord^.Konfiguration);
          datFestplatte  : Ata_PiBools := ((Not IsBit (7, IdeRecord^.Konfiguration))
                                            And IsBit (6, IdeRecord^.Konfiguration));
          datSpindel     : Ata_PiBools := IsBit (5, IdeRecord^.Konfiguration);
          datKopfUmsch   : Ata_PiBools := IsBit (4, IdeRecord^.Konfiguration);
          datMFM         : Ata_PiBools := IsBit (3, IdeRecord^.Konfiguration);
          datSoftSekt    : Ata_PiBools := IsBit (2, IdeRecord^.Konfiguration);
          datHardSekt    : Ata_PiBools := IsBit (1, IdeRecord^.Konfiguration);
          datMultisekt   : Ata_PiBools := Not (Lo(IdeRecord^.MultipleSector) = 0);
          dat16BitIO     : Ata_PiBools := IsBit (0, IdeRecord^.DWordIo);
          datISIORDY     : Ata_PiBools := IsBit (11, IdeRecord^.Faehigkeiten);
          datIsDisIORDY  : Ata_PiBools := IsBit (10, IdeRecord^.Faehigkeiten);
          datIsLBA       : Ata_PiBools := IsBit (9, IdeRecord^.Faehigkeiten);
          datIsDMA       : Ata_PiBools := IsBit (8, IdeRecord^.Faehigkeiten);
          datIsInf       : Ata_PiBools := IsBit (0, IdeRecord^.Ist54_58);
        Else
          Ata_PiBools := False;
        End
      Else
        Case InfoNumber Of
          datWechselMed : Ata_PiBools := IsBit (7, IdeRecord^.Konfiguration);
          dat16BitIO     : Ata_PiBools := IsBit (0, IdeRecord^.DWordIo);
          datISIORDY     : Ata_PiBools := IsBit (11, IdeRecord^.Faehigkeiten);
          datIsDisIORDY  : Ata_PiBools := IsBit (10, IdeRecord^.Faehigkeiten);
          datIsLBA       : Ata_PiBools := IsBit (9, IdeRecord^.Faehigkeiten);
          datIsDMA       : Ata_PiBools := IsBit (8, IdeRecord^.Faehigkeiten);
        Else
          Ata_PiBools := False;
        End;
    End
  Else
    Ata_PiBools := False;
End;


Function Ata_PiWords;

Begin
  UseByType := Drive;
  If Read (Drive) Then
    Begin
      If IdeType = datATA Then
        Case InfoNumber Of
          datZylinder       : Ata_PiWords := IdeRecord^.Zylinder;
          datHrsZylinder    : Ata_PiWords := IdeRecord^.HrsZylinder;
          datKoepfe         : Ata_PiWords := IdeRecord^.Koepfe;
          datBytesSpurUnf   : Ata_PiWords := IdeRecord^.BytesSpurUnf;
          datBytesSekUnf    : Ata_PiWords := IdeRecord^.BytesSekUnf;
          datSekSpur        : Ata_PiWords := IdeRecord^.SekSpur;
          datPufferGrSek    : Ata_PiWords := IdeRecord^.PufferGrSek;
          datMultipleSekt   : Ata_PiWords := Lo (IdeRecord^.MultipleSector);
          datDMZylinder     : Ata_PiWords := IdeRecord^.DMZylinder;
          datDMKoepfe       : Ata_PiWords := IdeRecord^.DMKoepfe;
          datDMSektorenSpur : Ata_PiWords := IdeRecord^.DMSektorenSpur;
          datAktSWDMAM      : Ata_PiWords := Hi (IdeRecord^.SingleDMAWord);
          datUntSWDMAM      : Ata_PiWords := Lo (IdeRecord^.SingleDMAWord);
          datAktMWDMAM      : Ata_PiWords := Hi (IdeRecord^.MultplDMAWord);
          datUntMWDMAM      : Ata_PiWords := Lo (IdeRecord^.MultplDMAWord);
        Else
          Ata_PiWords := 0;
        End
      Else
        Case InfoNumber Of
          datPufferGrSek     : Ata_PiWords := IdeRecord^.PufferGrSek;
          datAktSWDMAM       : Ata_PiWords := Hi (IdeRecord^.SingleDMAWord);
          datUntSWDMAM       : Ata_PiWords := Lo (IdeRecord^.SingleDMAWord);
          datAktMWDMAM       : Ata_PiWords := Hi (IdeRecord^.MultplDMAWord);
          datUntMWDMAM       : Ata_PiWords := Lo (IdeRecord^.MultplDMAWord);
          datMinZykMWDMA     : Ata_PiWords := IdeRecord^.MinZykMWDMA;
          datEmpfZykMWDMA    : Ata_PiWords := IdeRecord^.EmpfZykMWDMA;
          datMinZykPIOOIORDY : Ata_PiWords := IdeRecord^.MinZykPIOOIORDY;
          datMinZykPIOMIORDY : Ata_PiWords := IdeRecord^.MinZykPIOMIORDY;
        Else
          Ata_PiWords := 0;
        End;
    End
  Else
    Ata_PiWords := 0;
End;


Begin
End.
