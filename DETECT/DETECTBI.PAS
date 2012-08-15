{$O+,F+}
Unit DetectBios;
{ In dieser Unit steht praktisch nur ein Record, der die Bios-Data-Area
  beschreibt. šber einen Pointer zur BIOS-DATA-AREA kann er dann angesprochen
  werden.
 }

Interface

Type pBiosRecord = ^tBiosRecord;
     tBiosRecord = Record
        Com            : ARRAY [1..4] OF Word; { Die Com-Port Adressen }
        Lpt            : ARRAY [1..4] OF Word; { Die LPT-Port Adressen }
        Equipment      : Word; { ³7³6³5³4³3³2³1³0³ 40:10 (Wert wird auch mit INT 11 Register AL zurckgegeben)
                                  ³ ³ ³ ³ ³ ³ ³ ÀÄÄ IPL diskette installiert
                                  ³ ³ ³ ³ ³ ³ ÀÄÄÄÄ Koprozessor
                                  ³ ³ ³ ³ ÃÄÅÄÄÄÄÄÄ (Altes PC System) OnBoard RAM < 256K
                                  ³ ³ ³ ³ ³ ÀÄÄÄÄÄÄ "Zeiger-Device" installiert (PS/2)
                                  ³ ³ ³ ³ ÀÄÄÄÄÄÄÄÄ reserviert
                                  ³ ³ ÀÄÁÄÄÄÄÄÄÄÄÄÄ Startvideomodus
                                  ÀÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Wieviele Diskettenlaufwerke ?
                                 ³7³6³5³4³3³2³1³0³ 40:11  (Wert wird auch mit INT 11 Register AL zurckgegeben)
                                  ³ ³ ³ ³ ³ ³ ³ ÀÄÄ 0 wenn DMA installiert
                                  ³ ³ ³ ³ ÀÄÁÄÁÄÄÄÄ Anzahl der seriellen Schnittstellen
                                  ³ ³ ³ ÀÄÄÄÄÄÄÄÄÄÄ Gameport ja/nein
                                  ³ ³ ÀÄÄÄÄÄÄÄÄÄÄÄÄ nicht benutzt, internes modem auf dem PS/2
                                  ÀÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Anzahl der parallelen Ports }
        PCjr_ErrorCNT  : Byte;
        MemorySize     : Word;
        Reserved1      : Byte;
        PS2BiosFlag    : Byte;
        KeyboardFlag   : ARRAY [1..2] OF Byte;
                               { ³7³6³5³4³3³2³1³0³ keyboard flag byte 1
                                  ³ ³ ³ ³ ³ ³ ³ ÀÄÄ rechte Shift-Taste gedrckt
                                  ³ ³ ³ ³ ³ ³ ÀÄÄÄÄ linke Shift-Taste gedrckt
                                  ³ ³ ³ ³ ³ ÀÄÄÄÄÄÄ CTRL-Taste gedrckt
                                  ³ ³ ³ ³ ÀÄÄÄÄÄÄÄÄ ALT-Taste gedrckt
                                  ³ ³ ³ ÀÄÄÄÄÄÄÄÄÄÄ Scroll-lock ist aktiv
                                  ³ ³ ÀÄÄÄÄÄÄÄÄÄÄÄÄ Num-lock ist aktiv
                                  ³ ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Caps-Lock ist aktiv
                                  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Insert ist aktiv
                                 ³7³6³5³4³3³2³1³0³ keyboard flag byte
                                  ³ ³ ³ ³ ³ ³ ³ ÀÄÄ Linke CTRL-Taste gedrckt
                                  ³ ³ ³ ³ ³ ³ ÀÄÄÄÄ Linke ALT-Taste gedrckt
                                  ³ ³ ³ ³ ³ ÀÄÄÄÄÄÄ System-Taste gedrckt und gehalten
                                  ³ ³ ³ ³ ÀÄÄÄÄÄÄÄÄ Pause-Taste ist umgestellt
                                  ³ ³ ³ ÀÄÄÄÄÄÄÄÄÄÄ Scroll Lock-Taste gedrckt
                                  ³ ³ ÀÄÄÄÄÄÄÄÄÄÄÄÄ Num-lock-Taste gedrckt
                                  ³ ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Caps-lock-Taste gedrckt
                                  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Insert-Taste gedrckt }
        AlternatePad   : Byte;
        KeybufHead     : Word;
        KeybufTail     : Word;
        Keybuf         : ARRAY [1..32] OF Byte;
        SeekState      : Byte; { ³7³6³5³4³3³2³1³0³ Laufwerkrekalibrationsstatus
                                  ³ ³ ³ ³ ³ ³ ³ ÀÄÄ 1=Rekalibration von Laufwerk 0
                                  ³ ³ ³ ³ ³ ³ ÀÄÄÄÄ 1=Rekalibration von Laufwerk 1
                                  ³ ³ ³ ³ ³ ÀÄÄÄÄÄÄ 1=Rekalibration von Laufwerk 2
                                  ³ ³ ³ ³ ÀÄÄÄÄÄÄÄÄ 1=Rekalibration von Laufwerk 3
                                  ³ ÀÄÁÄÁÄÄÄÄÄÄÄÄÄÄ unbenutzt
                                  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ 1=Wird gerade ein LW benutzt ? }
        DiskState      : Byte; { ³7³6³5³4³3³2³1³0³ diskette motor status
                                  ³ ³ ³ ³ ³ ³ ³ ÀÄÄ 1=drive 0 motor on
                                  ³ ³ ³ ³ ³ ³ ÀÄÄÄÄ 1=drive 1 motor on
                                  ³ ³ ³ ³ ³ ÀÄÄÄÄÄÄ 1=drive 2 motor on
                                  ³ ³ ³ ³ ÀÄÄÄÄÄÄÄÄ 1=drive 3 motor on
                                  ³ ÀÄÁÄÁÄÄÄÄÄÄÄÄÄÄ unused
                                  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ 1=write operation }
        MotorTimeout   : Byte;
        DiskOpState    : Byte; { ³7³6³5³4³3³2³1³0³ status of last diskette operation
                                  ³ ³ ³ ³ ³ ³ ³ ÀÄÄ invalid diskette command
                                  ³ ³ ³ ³ ³ ³ ÀÄÄÄÄ diskette address mark not found
                                  ³ ³ ³ ³ ³ ÀÄÄÄÄÄÄ sector not found
                                  ³ ³ ³ ³ ÀÄÄÄÄÄÄÄÄ diskette DMA error
                                  ³ ³ ³ ÀÄÄÄÄÄÄÄÄÄÄ CRC check / data error
                                  ³ ³ ÀÄÄÄÄÄÄÄÄÄÄÄÄ diskette controller failure
                                  ³ ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄ seek to track failed
                                  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ diskette time-out    }
        NECController  : ARRAY [1..7] OF Byte;
        VideoMode      : Byte;
        Columns        : Word;
        ScreenBufSize  : Word;
        ScreenPageOfs  : Word;
        Cursorpos      : ARRAY [0..7] OF Word;
        LowScan,UpScan : Byte;
        ScreenPage     : Byte;
        CRTBase        : Word;
        CRTMode        : Byte;
        Palettemask    : Byte;
        Dummy1         : ARRAY [1..5] OF Byte;
                               { Fuer verschiedene Dinge benutzt }
        Timer          : ARRAY [1..2] OF Word;
        MidnightFlag   : Byte;
        BiosBreak      : Byte;  { Bit 7 set, when CTRL-Break *ever* hit }
        SoftReset      : Word;  { 0000 Kaltstart            }
                                { 1234
                                  1200
                                  EDCB Warmstart            }
                                { 4321 Speicher vorbereiten }
                                { 5678 System Suspend       }
                                { 9ABC Hersteller-Test      }
                                { ABCD Conv. Post-Loop      }
                                {   64 BurnIn - Modus       }
        FixedState     : Byte;  {   00 no error
                                    01 bad command passed to driver
                                    02 address mark not found or bad sector
                                    03 diskette write protect error
                                    04 sector not found
                                    05 fixed disk reset failed
                                    06 diskette changed or removed
                                    07 bad fixed disk parameter table
                                    08 DMA overrun
                                    09 DMA access across 64k boundary
                                    0A bad fixed disk sector flag
                                    0B bad fixed disk cylinder
                                    0C unsupported track/invalid media
                                    0D invalid number of sectors on fixed disk format
                                    0E fixed disk controlled data address mark detected
                                    0F fixed disk DMA arbitration level out of range
                                    10 ECC/CRC error on disk read
                                    11 recoverable fixed disk data error, data fixed by ECC
                                    20 controller error (NEC for floppies)
                                    40 seek failure
                                    80 time out, drive not ready
                                    AA fixed disk drive not ready
                                    BB fixed disk undefined error
                                    CC fixed disk write fault on selected drive
                                    E0 fixed disk status error/Error reg = 0
                                    FF sense operation failed }
        NumberFixed    : Byte;
        XTFixedControl : Byte;
        FixedAdapter   : Byte;
        LPTTimeout     : ARRAY [1..4] OF Byte;
        COMTimeout     : ARRAY [1..4] OF Byte;
        KeyBufbegin    : Word; { BIOS 10-27-82 }
        KeyBufend      : Word;
        Rows           : Byte;
        CharHeight     : Word; { EGA+,
	                 Byte    PCjr: character to be repeated if the typematic
			         repeat key takes effect
                         Byte    PCjr: initial delay before repeat key action begins }
        VideoOptions   : Byte; { EGA+, PCjr: current Fn function key number
		                 ³7³6³5³4³3³2³1³0³ Video mode options (EGA+)
                                  ³ ³ ³ ³ ³ ³ ³ ÀÄÄ 1=alphanumeric cursor emulation enabled
                                  ³ ³ ³ ³ ³ ³ ÀÄÄÄÄ 1=video subsystem attached to monochrome
                                  ³ ³ ³ ³ ³ ÀÄÄÄÄÄÄ reserved
                                  ³ ³ ³ ³ ÀÄÄÄÄÄÄÄÄ 1=video subsystem is inactive
                                  ³ ³ ³ ÀÄÄÄÄÄÄÄÄÄÄ reserved
                                  ³ ÀÄÁÄÄÄÄÄÄÄÄÄÄÄÄ video RAM  00-64K  10-192K  01-128K  11-256K
                                  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ video mode number passed to INT 10, function 0 }
        EGASwitches    : Byte; { EGA+, PCjr: third keyboard status byte
                                 ³7³6³5³4³3³2³1³0³ EGA feature bit switches (EGA+)
                                  ³ ³ ³ ³ ³ ³ ³ ÀÄÄ EGA SW1 config (1=off)
                                  ³ ³ ³ ³ ³ ³ ÀÄÄÄÄ EGA SW2 config (1=off)
                                  ³ ³ ³ ³ ³ ÀÄÄÄÄÄÄ EGA SW3 config (1=off)
                                  ³ ³ ³ ³ ÀÄÄÄÄÄÄÄÄ EGA SW4 config (1=off)
                                  ³ ³ ³ ÀÄÄÄÄÄÄÄÄÄÄ Input FEAT0 (ISR0 bit 5) after output on FCR0
                                  ³ ³ ÀÄÄÄÄÄÄÄÄÄÄÄÄ Input FEAT0 (ISR0 bit 6) after output on FCR0
                                  ³ ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Input FEAT1 (ISR0 bit 5) after output on FCR1
                                  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Input FEAT1 (ISR0 bit 6) after output on FCR1 }
        VideoDataArea  : Byte; { MCGA and VGA
                                 ³7³6³5³4³3³2³1³0³ Video display data area (MCGA and VGA)
                                  ³ ³ ³ ³ ³ ³ ³ ÀÄÄ 1=VGA is active
                                  ³ ³ ³ ³ ³ ³ ÀÄÄÄÄ 1=gray scale is enabled
                                  ³ ³ ³ ³ ³ ÀÄÄÄÄÄÄ 1=using monochrome monitor
                                  ³ ³ ³ ³ ÀÄÄÄÄÄÄÄÄ 1=default palette loading is disabled
                                  ³ ³ ³ ÀÄÄÄÄÄÄÄÄÄÄ see table below
                                  ³ ³ ÀÄÄÄÄÄÄÄÄÄÄÄÄ reserved
                                  ³ ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  1=display switching enabled
                                  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ alphanumeric scan lines (see table below)

                                  Bit7    Bit4    Scan Lines
                                   0       0      350 line mode
                                   0       1      400 line mode
                                   1       0      200 line mode
                                   1       1      reserved     }
        EGADCC_Index   : Byte; { Display Combination Code (DCC) table index (EGA+) }
        DiskDataRate   : Byte; { ³7³6³5³4³3³2³1³0³ last diskette data rate selected
                                  ³ ³ ³ ³ ÀÄÁÄÁÄÁÄÄ reserved
                                  ³ ³ ÀÄÁÄÄÄÄÄÄÄÄÄÄ last floppy drive step rate selected
                                  ÀÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ last floppy data rate selected

                                  Data Rate      Step Rate
                                  00  500K bps   00  step rate time of 0C
                                  01  300K bps   01  step rate time of 0D
                                  10  250K bps   10  step rate time of 0A
                                  11  reserved   11  reserved }
        HDCtrlState    : Byte;
        HDCtrlError    : Byte;
        HDIntFlag      : Byte; { bit 7 set }
        HD_FD_Combicard: Byte; { bit 0 set }
        DriveMediaState: ARRAY [0..3] OF Byte;
                               { ³7³6³5³4³3³2³1³0³ drive media state (4 copies)
                                  ³ ³ ³ ³ ³ ÀÄÁÄÁÄÄ drive/media state (see below)
                                  ³ ³ ³ ³ ÀÄÄÄÄÄÄÄÄ reserved
                                  ³ ³ ³ ÀÄÄÄÄÄÄÄÄÄÄ 1=media/drive established
                                  ³ ³ ÀÄÄÄÄÄÄÄÄÄÄÄÄ double stepping required
                                  ÀÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ data rate:	00=500K bps    01=300K bps
                                                                10=250K bps    11=reserved
                                 Bits
                                 210  Drive Media State
                                 000  360Kb diskette/360Kb drive not established
                                 001  360Kb diskette/1.2Mb drive not established
                                 010  1.2Mb diskette/1.2Mb drive not established
                                 011  360Kb diskette/360Kb drive established
                                 100  360Kb diskette/1.2Mb drive established
                                 101  1.2Mb diskette/1.2Mb drive established
                                 110  Reserved
                                 111  None of the above }
        Drive0Track    : Byte;
        Drive1Track    : Byte;
        KeyboardMode   : Byte; { ³7³6³5³4³3³2³1³0³ Keyboard mode/type
                                  ³ ³ ³ ³ ³ ³ ³ ÀÄÄÄ last code was the E1 hidden code
                                  ³ ³ ³ ³ ³ ³ ÀÄÄÄÄÄ last code was the E0 hidden code
                                  ³ ³ ³ ³ ³ ÀÄÄÄÄÄÄÄ right CTRL key depressed
                                  ³ ³ ³ ³ ÀÄÄÄÄÄÄÄÄÄ right ALT key depressed
                                  ³ ³ ³ ÀÄÄÄÄÄÄÄÄÄÄÄ 101/102 enhanced keyboard installed
                                  ³ ³ ÀÄÄÄÄÄÄÄÄÄÄÄÄÄ force num-lock if Rd ID & KBX
                                  ³ ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ last char was first ID char
                                  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ read ID in process }
        KeyboardLeds   : Byte; { ³7³6³5³4³3³2³1³0³ Keyboard LED flags
                                  ³ ³ ³ ³ ³ ³ ³ ÀÄÄ scroll lock indicator
                                  ³ ³ ³ ³ ³ ³ ÀÄÄÄÄ num-lock indicator
                                  ³ ³ ³ ³ ³ ÀÄÄÄÄÄÄ caps-lock indicator
                                  ³ ³ ³ ³ ÀÄÄÄÄÄÄÄÄ circus system indicator
                                  ³ ³ ³ ÀÄÄÄÄÄÄÄÄÄÄ ACK received
                                  ³ ³ ÀÄÄÄÄÄÄÄÄÄÄÄÄ re-send received flag
                                  ³ ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄ mode indicator update
                                  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ keyboard transmit error flag }
        UserWaitFlag  : Pointer;
        UserWaitTOut  : LongInt; { unsigned ! in microseconds }
        RTCWaitFlag   : Byte; { ³7³6³5³4³3³2³1³0³ RTC wait function flag
                                 ³ ³ ³ ³ ³ ³ ³ ÀÄÄÄ 1= wait pending
                                 ³ ÀÄÁÄÁÄÁÄÁÄÁÄÄÄÄÄ not used
                                 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ 1=INT 15,86 wait time elapsed }
        LANA_DMAFlags : Byte;
        LANA_States   : ARRAY [0..1] OF BYTE;
        HDIntVector   : Pointer;
        VideoTable    : Pointer;
        Reserved      : ARRAY [1..8] OF Byte;
        KBD_NMIFlags  : Byte;
        KBD_BreakFlags: ARRAY [1..2] OF Word;
        Port60Queue   : Byte;
        LastScancode  : Byte;
        NMI_BufHead   : Byte;
        NMI_BufTail   : Byte;
        NMI_Buffer    : ARRAY [1..16] OF Byte;
        Dummy2        : Byte;
        DayCounter    : Word;
     End;



Function GetBiosRecord : pBiosRecord;

Implementation


Function GetBiosRecord;
Begin
  GetBiosRecord := Ptr ($0040,$0000);
End;

End.