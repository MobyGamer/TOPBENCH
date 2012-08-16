{$O+,F+}
Unit DetectBios;
{ In dieser Unit steht praktisch nur ein Record, der die Bios-Data-Area
  beschreibt. �ber einen Pointer zur BIOS-DATA-AREA kann er dann angesprochen
  werden.
 }

Interface

Type pBiosRecord = ^tBiosRecord;
     tBiosRecord = Record
        Com            : ARRAY [1..4] OF Word; { Die Com-Port Adressen }
        Lpt            : ARRAY [1..4] OF Word; { Die LPT-Port Adressen }
        Equipment      : Word; { �7�6�5�4�3�2�1�0� 40:10 (Wert wird auch mit INT 11 Register AL zur�ckgegeben)
                                  � � � � � � � ��� IPL diskette installiert
                                  � � � � � � ����� Koprozessor
                                  � � � � ��������� (Altes PC System) OnBoard RAM < 256K
                                  � � � � � ������� "Zeiger-Device" installiert (PS/2)
                                  � � � � ��������� reserviert
                                  � � ������������� Startvideomodus
                                  ����������������� Wieviele Diskettenlaufwerke ?
                                 �7�6�5�4�3�2�1�0� 40:11  (Wert wird auch mit INT 11 Register AL zur�ckgegeben)
                                  � � � � � � � ��� 0 wenn DMA installiert
                                  � � � � ��������� Anzahl der seriellen Schnittstellen
                                  � � � ����������� Gameport ja/nein
                                  � � ������������� nicht benutzt, internes modem auf dem PS/2
                                  ����������������� Anzahl der parallelen Ports }
        PCjr_ErrorCNT  : Byte;
        MemorySize     : Word;
        Reserved1      : Byte;
        PS2BiosFlag    : Byte;
        KeyboardFlag   : ARRAY [1..2] OF Byte;
                               { �7�6�5�4�3�2�1�0� keyboard flag byte 1
                                  � � � � � � � ��� rechte Shift-Taste gedr�ckt
                                  � � � � � � ����� linke Shift-Taste gedr�ckt
                                  � � � � � ������� CTRL-Taste gedr�ckt
                                  � � � � ��������� ALT-Taste gedr�ckt
                                  � � � ����������� Scroll-lock ist aktiv
                                  � � ������������� Num-lock ist aktiv
                                  � ��������������� Caps-Lock ist aktiv
                                  ����������������� Insert ist aktiv
                                 �7�6�5�4�3�2�1�0� keyboard flag byte
                                  � � � � � � � ��� Linke CTRL-Taste gedr�ckt
                                  � � � � � � ����� Linke ALT-Taste gedr�ckt
                                  � � � � � ������� System-Taste gedr�ckt und gehalten
                                  � � � � ��������� Pause-Taste ist umgestellt
                                  � � � ����������� Scroll Lock-Taste gedr�ckt
                                  � � ������������� Num-lock-Taste gedr�ckt
                                  � ��������������� Caps-lock-Taste gedr�ckt
                                  ����������������� Insert-Taste gedr�ckt }
        AlternatePad   : Byte;
        KeybufHead     : Word;
        KeybufTail     : Word;
        Keybuf         : ARRAY [1..32] OF Byte;
        SeekState      : Byte; { �7�6�5�4�3�2�1�0� Laufwerkrekalibrationsstatus
                                  � � � � � � � ��� 1=Rekalibration von Laufwerk 0
                                  � � � � � � ����� 1=Rekalibration von Laufwerk 1
                                  � � � � � ������� 1=Rekalibration von Laufwerk 2
                                  � � � � ��������� 1=Rekalibration von Laufwerk 3
                                  � ��������������� unbenutzt
                                  ����������������� 1=Wird gerade ein LW benutzt ? }
        DiskState      : Byte; { �7�6�5�4�3�2�1�0� diskette motor status
                                  � � � � � � � ��� 1=drive 0 motor on
                                  � � � � � � ����� 1=drive 1 motor on
                                  � � � � � ������� 1=drive 2 motor on
                                  � � � � ��������� 1=drive 3 motor on
                                  � ��������������� unused
                                  ����������������� 1=write operation }
        MotorTimeout   : Byte;
        DiskOpState    : Byte; { �7�6�5�4�3�2�1�0� status of last diskette operation
                                  � � � � � � � ��� invalid diskette command
                                  � � � � � � ����� diskette address mark not found
                                  � � � � � ������� sector not found
                                  � � � � ��������� diskette DMA error
                                  � � � ����������� CRC check / data error
                                  � � ������������� diskette controller failure
                                  � ��������������� seek to track failed
                                  ����������������� diskette time-out    }
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
		                 �7�6�5�4�3�2�1�0� Video mode options (EGA+)
                                  � � � � � � � ��� 1=alphanumeric cursor emulation enabled
                                  � � � � � � ����� 1=video subsystem attached to monochrome
                                  � � � � � ������� reserved
                                  � � � � ��������� 1=video subsystem is inactive
                                  � � � ����������� reserved
                                  � ��������������� video RAM  00-64K  10-192K  01-128K  11-256K
                                  ����������������� video mode number passed to INT 10, function 0 }
        EGASwitches    : Byte; { EGA+, PCjr: third keyboard status byte
                                 �7�6�5�4�3�2�1�0� EGA feature bit switches (EGA+)
                                  � � � � � � � ��� EGA SW1 config (1=off)
                                  � � � � � � ����� EGA SW2 config (1=off)
                                  � � � � � ������� EGA SW3 config (1=off)
                                  � � � � ��������� EGA SW4 config (1=off)
                                  � � � ����������� Input FEAT0 (ISR0 bit 5) after output on FCR0
                                  � � ������������� Input FEAT0 (ISR0 bit 6) after output on FCR0
                                  � ��������������� Input FEAT1 (ISR0 bit 5) after output on FCR1
                                  ����������������� Input FEAT1 (ISR0 bit 6) after output on FCR1 }
        VideoDataArea  : Byte; { MCGA and VGA
                                 �7�6�5�4�3�2�1�0� Video display data area (MCGA and VGA)
                                  � � � � � � � ��� 1=VGA is active
                                  � � � � � � ����� 1=gray scale is enabled
                                  � � � � � ������� 1=using monochrome monitor
                                  � � � � ��������� 1=default palette loading is disabled
                                  � � � ����������� see table below
                                  � � ������������� reserved
                                  � ���������������  1=display switching enabled
                                  ����������������� alphanumeric scan lines (see table below)

                                  Bit7    Bit4    Scan Lines
                                   0       0      350 line mode
                                   0       1      400 line mode
                                   1       0      200 line mode
                                   1       1      reserved     }
        EGADCC_Index   : Byte; { Display Combination Code (DCC) table index (EGA+) }
        DiskDataRate   : Byte; { �7�6�5�4�3�2�1�0� last diskette data rate selected
                                  � � � � ��������� reserved
                                  � � ������������� last floppy drive step rate selected
                                  ����������������� last floppy data rate selected

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
                               { �7�6�5�4�3�2�1�0� drive media state (4 copies)
                                  � � � � � ������� drive/media state (see below)
                                  � � � � ��������� reserved
                                  � � � ����������� 1=media/drive established
                                  � � ������������� double stepping required
                                  ����������������� data rate:	00=500K bps    01=300K bps
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
        KeyboardMode   : Byte; { �7�6�5�4�3�2�1�0� Keyboard mode/type
                                  � � � � � � � ���� last code was the E1 hidden code
                                  � � � � � � ������ last code was the E0 hidden code
                                  � � � � � �������� right CTRL key depressed
                                  � � � � ���������� right ALT key depressed
                                  � � � ������������ 101/102 enhanced keyboard installed
                                  � � �������������� force num-lock if Rd ID & KBX
                                  � ���������������� last char was first ID char
                                  ������������������ read ID in process }
        KeyboardLeds   : Byte; { �7�6�5�4�3�2�1�0� Keyboard LED flags
                                  � � � � � � � ��� scroll lock indicator
                                  � � � � � � ����� num-lock indicator
                                  � � � � � ������� caps-lock indicator
                                  � � � � ��������� circus system indicator
                                  � � � ����������� ACK received
                                  � � ������������� re-send received flag
                                  � ��������������� mode indicator update
                                  ����������������� keyboard transmit error flag }
        UserWaitFlag  : Pointer;
        UserWaitTOut  : LongInt; { unsigned ! in microseconds }
        RTCWaitFlag   : Byte; { �7�6�5�4�3�2�1�0� RTC wait function flag
                                 � � � � � � � ���� 1= wait pending
                                 � ���������������� not used
                                 ������������������ 1=INT 15,86 wait time elapsed }
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