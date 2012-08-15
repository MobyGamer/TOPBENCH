Unit DetectMultiplex;

{ Unterunit zu DETECT.PAS. Diese Unit ist nicht rein fÅr den Multiplex-
  Interrupt gedacht, sie ist aber Åberwiegend mit diesen Aufgaben belastet.
                                                                           }
Interface

Function IsInstalled (SoftwareNumber : Byte) : Boolean;
Function WhichAddress (SoftwareNumber : Byte) : Pointer;
Function WhichVersion (SoftwareNumber : Byte) : String;

Implementation

Uses Dos, DetectConstants, DetectGlobal;

Type
  tStackerbuf = record
                  signature : word;
                  unknown   : word;
                  ddofs     : word;
                  ddseg     : word
                end;

Var Regs       : Registers;
    StackerBuf : tStackerBuf;

Function IsInstalled;

Type String10 = Array [0..9] Of Char;
     String8 = Array [0..7] Of Char;
     String6 = Array [0..5] Of Char;
     String4 = Array [0..3] Of Char;

     pBuffer = ^tBuffer;
     tBuffer = Record
       Unk1 : Array [0..3] Of Char;
       Unk2 : Array [0..$FB] Of Byte;
     End;

     PtrRec = Record
       Seg : Word;
       Ofs : Word;
     End;

Const Sig1 : Array [0..18] Of Char = 'PUSHDIR VERSION 1.0';

Var EndIt    : Boolean;
    Count    : Byte;
    PtrStr10 : ^String10;
    PtrStr8  : ^String8;
    PtrStr6  : ^String6;
    PtrStr4  : ^String4;
    S        : String[8];
    B        : pBuffer;
    xPointer : Pointer;
    Fil      : File;

Begin
  Regs.AL := $0;

  Case SoftwareNumber Of
    Assign       : Begin
                     Regs.AH := $06;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    DriverSys    : Begin
                     Regs.AH := $08;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    Share        : Begin
                     Regs.AH := $10;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    Redifs       : Begin
                     { Redirector / IFS }
                     Regs.AH := $11;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    Multidos     : Begin
                     Regs.AH := $12;
                     Intr ($2f, Regs);
                     If (Regs.AL = $FF) Then
                       Begin
                         Regs.AH := $01; { Get Semaphore Funktion }
                         Regs.AL := $60; { Nummer (diese ist nicht zulÑssig) }
                         Intr ($15, Regs);
                         IsInstalled := (Regs.AH = $02); { Error Code ... }
                       End
                     Else
                       IsInstalled := False;
                   End;
    NlsFunc      : Begin
                     Regs.AH := $14;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    Win386       : Begin
                     Regs.AH := $16;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    DosShell     : Begin
                     Regs.AH := $17;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    AnsiSys      : Begin
                     Regs.AH := $1A;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    Xma2EmsSys   : Begin
                     Regs.AH := $1B;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    Himem        : Begin
                     Regs.AH := $43;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $80)
                   End;
    NNIPX        : Begin
                     {Novell Netware IPX}
                     Regs.AH := $7A;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    Display      : Begin
                     Regs.AH := $AD;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    DICExt       : Begin
                     {Dos installable Command Extender}
                     Regs.AH := $AE;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    IBM3270      : Begin
                     Regs.AH := $B4;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    Append       : Begin
                     Regs.AH := $B7;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    LAN          : Begin
                     Regs.AH := $B8;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    LANREC       : Begin
                     { LAN Receiver.COM }
                     Regs.AH := $B9;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    LANREDIR     : Begin
                     { LAN Redirector.EXE }
                     Regs.AH := $BF;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    GrafTable40  : Begin
                     Regs.AH := $B0;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    GrafTable50  : Begin
                     Regs.AX:=$2300;
                     Regs.BX:=0;
                     Regs.CX:=0;
                     Regs.DX:=0;
                     Intr($2F, regs);
                     IsInstalled := (Regs.AH = $FF);
                   End;
    MSCDExt      : Begin
                     { MS CD Extensions }
                     asm
                       Mov ax,$DADA
                       push ax
                       mov ax,$1100
                       int $15
                       mov xbyte,al
                       pop ax
                       mov xword1,bx
                     end;
                     IsInstalled := Not ((xbyte <> $FF) or (xWord1 <> $ADAD));
                   End;
    _4Dos        : Begin
                     Regs.AH := $D4;
                     Regs.AL := $4D;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AX = $44DD);
                   End;
    NDos         : Begin
                     Regs.AH := $E4;
                     Regs.AL := $4D;
                     Intr ($2f, Regs);
                     IsInstalled :=  (Regs.AX = $44EE);
                   End;
    KStack       : Begin
                     Regs.AH := $D4;
                     Regs.AL := $4F;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AX = $44DD);
                   End;
    WildUnix     : Begin
                     Regs.AH := $4E;
                     Regs.DS := 0;
                     Regs.DX := 0;
                     MsDos (Regs);
                     IsInstalled :=  (Regs.AL = $99);
                   End;
    Arnakey      : Begin
                     Regs.AH := $E3;
                     Regs.AL := $00;
                     Intr ($2f, Regs);
                     IsInstalled := ((Regs.AL = $FF) Or (Regs.AL = $FE));
                   End;
    TaskSwitch5  : Begin
                     { Dos 5 Task Switcher }
                     Regs.AX := $4B02;
                     Regs.BX:=0;
                     Regs.ES:=0;
                     Regs.DI:=0;
                     Intr ($2f, Regs);
                     IsInstalled := (((FCarry And Regs.Flags) = 0) And
                       (Regs.AX = 0) And (Regs.BX = 0));
                   End;
    DrDosTskMx   : Begin
                     Regs.AX:=$2700;
                     Regs.BX:=0;
                     Regs.CX:=0;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    FPFLock      : Begin
                     Regs.AX:=$4653;
                     Regs.BX:=0;
                     Regs.CX:=2;
                     Intr($2F, Regs);
                     IsInstalled := (Regs.AX = $FFFF);
                   End;
    FPFXChk      : Begin
                     Regs.AX:=$4653;
                     Regs.BX:=0;
                     Regs.CX:=3;
                     Intr($2F, Regs);
                     IsInstalled := (Regs.AX = $FFFF);
                   End;
    FPFPopUp     : Begin
                     Regs.AX:=$4653;
                     Regs.BX:=0;
                     Regs.CX:=4;
                     Intr($2F, Regs);
                     IsInstalled := (Regs.AX = $FFFF);
                   End;
    FPFDLock     : Begin
                     Regs.AX:=$4653;
                     Regs.BX:=0;
                     Regs.CX:=5;
                     Intr($2F, Regs);
                     IsInstalled := (Regs.AX = $FFFF);
                   End;
    FluShot      : Begin
                     Regs.AX:=$FF0F;
                     MsDos (Regs);
                     IsInstalled := (Regs.AX = $0101);
                   End;
    HyperDisk    : Begin
                     Regs.AX:=$DF00;
                     Regs.BX:=$4448; {DH}
                     Intr($2F, regs);
                     IsInstalled := ((Regs.AL = $FF) and (Regs.CX = $5948 {YH}));
                   End;
    MSLanTastic  : Begin
                     Regs.AH:=0;
                     Intr($2A, regs);
                     IsInstalled := (Regs.AH <> 0);
                   End;
    Inset        : Begin
                     Regs.AH := 2;
                     Regs.DX := 0;
                     Regs.CX := $07C3; {1987}
                     Intr($17, regs);
                     IsInstalled := (Regs.CX = $07C2 {1986});
                   End;
    Dos_16M      : Begin
                     Regs.AX:=$BF02;
                     Regs.DX:=0;
                     Intr ($15, Regs);
                     IsInstalled := (Regs.DX <> 0);
                   End;
    Phar_Lap     : Begin
                     Regs.AX:=$ED00;
                     Regs.BL:=1;
                     Intr($2F, Regs);
                     IsInstalled := ((Regs.AL = $FF) And (Regs.SI = $5048 {PH})
                       And (Regs.DI = $4152 {AR}));
                   End;
    N_Cache_F    : Begin
                     { NCache-F/N-Cache V6+ }
                     Regs.AX:=$FE00;
                     Regs.BX:=0;
                     Regs.CX:=0;
                     Regs.DX:=0;
                     Regs.DI:=$4E55; {NU}
                     Regs.SI:=$4346; {CF}
                     Intr($2F, regs);
                     IsInstalled := (Regs.SI = $6366 {cf});
                   End;
    N_Cache_S    : Begin
                     Regs.AX:=$FE00;
                     Regs.BX:=0;
                     Regs.CX:=0;
                     Regs.DX:=0;
                     Regs.DI:=$4E55; {NU}
                     Regs.SI:=$4353; {CS}
                     Intr($2F, regs);
                     IsInstalled :=  (Regs.SI = $6373 {cs});
                   End;
    N_DiskReet   : Begin
                     Regs.AX:=$FE00;
                     Regs.BX:=0;
                     Regs.CX:=0;
                     Regs.DX:=0;
                     Regs.DI:=$4E55; {NU}
                     Regs.SI:=$4443; {DC}
                     Intr($2F, regs);
                     IsInstalled :=  (Regs.SI = $6463 {dc});
                   End;
    N_DiskMon    : Begin
                     Regs.AX:=$FE00;
                     Regs.BX:=0;
                     Regs.CX:=0;
                     Regs.DX:=0;
                     Regs.DI:=$4E55; {NU}
                     Regs.SI:=$444D; {DM}
                     Intr($2F, regs);
                     IsInstalled := (Regs.SI = $646D {dm})
                   End;
    N_FileSav    : Begin
                     Regs.AX:=$FE00;
                     Regs.BX:=0;
                     Regs.CX:=0;
                     Regs.DX:=0;
                     Regs.DI:=$4E55; {NU}
                     Regs.SI:=$4653; {FS}
                     Intr($2F, regs);
                     IsInstalled := (Regs.SI = $6673 {fs});
                   End;
    EGASys       : Begin
                     Regs.AH := $BC;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    Print        : Begin
                     Regs.AH := $01;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    NETBiosApp   : Begin
                     Regs.AH := $87;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    NETBiosNetW  : Begin
                     Regs.AH := $88;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    ShellB       : Begin
                     Regs.AH := $19;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    GraphicsCom  : Begin
                     Regs.AH := $15;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    DosKey       : Begin
                     Regs.AH := $48;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    TopwNetOS    : Begin
                     Regs.AX := $FF00;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    AutoParkCom  : Begin
                     Regs.AX := $F700;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    AutoBraille  : Begin
                     Regs.AX := $FB00;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AX = $00FF);
                   End;
    Jot_It       : Begin
                     Regs.AX := $FB00;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AX = $FFFF);
                   End;
    RedView      : Begin
                     Regs.AX := $BE00;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    Explosiv     : Begin
                     Regs.AX := $C050;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $51);
                    End;
    IntelImg     : Begin
                     Regs.AX := $CD00;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $51);
                    End;
    SwellExe     : Begin
                     Regs.AX := $CD00;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AX = $00FF);
                    End;
    ZWMouse      : Begin
                     Regs.AX := $D000;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AX = $5A57);
                    End;
    HeartCom     : Begin
                     Regs.AX := $D600;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AX = $0303);
                   End;
    GridLocExe   : Begin
                     Regs.AX := $EE00;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    _4MAp        : Begin
                     Regs.AX := $F000;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    MinMem       : Begin
                     Regs.AX := $F100;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $F1);
                   End;
    METZTSRCom   : Begin
                     Regs.AX := $A900;
                     Regs.Flags := Regs.Flags And FCarry;
                     Intr ($2f, Regs);
                     IsInstalled := ((Regs.AX = $97FF) And (Regs.Flags And FCarry = 0));
                   End;
    VidLockCom   : Begin
                     Regs.AX := $AA00;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    BTrieveMU    : Begin
                     Regs.AX := $AB00;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $4D);
                   End;
    PC3270Emu3   : Begin
                     Regs.AX := $B400;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    EasyNet      : Begin
                     Regs.AX := $8000;
                     Regs.BX := $0000;
                     Regs.CX := $0000;
                     Intr ($2f, Regs);
                     IsInstalled := ((Regs.AL = $FF) And ((Regs.BX = 0) And
                       (Regs.CX = 0)));
                   End;
    TurboNetSer  : Begin
                     Regs.AX := $8000;
                     Regs.BX := $0000;
                     Regs.CX := $0000;
                     Intr ($2f, Regs);
                     IsInstalled := ((Regs.AL = $FF) And ((Regs.BX <> 0)
                       Or (Regs.CX <> 0)));
                   End;
    FAXBiosInt   : Begin
                     IsInstalled := False;
                     For Count := $80 To $FF Do
                       Begin
                         If EndIt = False Then
                           Begin
                             Regs.AH := Count;
                             Regs.DX := $0000;
                             Regs.DI := $0000;
                             Intr ($2f, Regs);
                             PtrStr10 := Ptr (Regs.DX, Regs.DI);
                             If (Regs.AL = $FF) And (PtrStr10^ = 'FaxBiosjpc')
                               Then
                                 Begin
                                   IsInstalled := True;
                                   EndIt := True;
                                 End
                               Else
                                 IsInstalled := False;
                           End;
                       End;
                   End;
    ResPlay      : Begin
                     Regs.AX := $8201;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AX = $7746);
                   End;
    WhoaCom      : Begin
                     Regs.AX := $8900;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    Raid         : Begin
                     Regs.AX := $9000;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    InnerMission : Begin
                     Regs.AX := $9300;
                     Regs.BX := $9300;
                     Regs.CX := $9300;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    ScrnSav2Com  : Begin
                     Regs.AX := $6400;
                     Intr ($2f, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    _3ComBApiSIO : Begin
                     Regs.AX := $AF00;
                     Regs.BX := $AAAA;
                     Intr ($14, Regs);
                     IsInstalled := (Regs.AX = $AF01);
                   End;
    Asap         : Begin
                     Regs.AX := $F0F1;
                     Regs.DX := $0000;
                     Intr ($14, Regs);
                     IsInstalled := (Regs.DX <> $0000);
                   End;
    CouriersCom  : Begin
                     Regs.AX := $8000;
                     Intr ($14, Regs);
                     IsInstalled := (Regs.AH = $E8);
                   End;
    QCache       : Begin
                     Regs.AX := $2700;
                     Regs.BX := $0000;
                     Intr ($13, Regs);
                     IsInstalled := (Regs.BX <> 0);
                   End;
    ScroLockCom  : Begin
                     Regs.AX := $5000;
                     Intr ($10, Regs);
                     IsInstalled := (Regs.BX = $1954);
                   End;
    FastBuffCom  : Begin
                     Regs.AX := $FA00;
                     Intr ($10, Regs);
                     IsInstalled := (Regs.AX = $00FA);
                   End;
    ATIWonSupSw  : Begin
                     Regs.AX := $5555;
                     Intr ($10, Regs);
                     IsInstalled := (Regs.AX = $AAAA);
                   End;
    KWTsrWin     : Begin
                     Regs.AH := $39;
                     Regs.BL := $00;
                     Regs.AL := $01;
                     Intr ($2F, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    KWNoBusy     : Begin
                     Regs.AH := $39;
                     Regs.BL := $00;
                     Regs.AL := $02;
                     Intr ($2F, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    KWCDStack    : Begin
                     Regs.AH := $39;
                     Regs.BL := $00;
                     Regs.AL := $03;
                     Intr ($2F, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    KWDiskWatch  : Begin
                     Regs.AH := $39;
                     Regs.BL := $00;
                     Regs.AL := $04;
                     Intr ($2F, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    KWPushBP     : Begin
                     Regs.AH := $39;
                     Regs.BL := $00;
                     Regs.AL := $05;
                     Intr ($2F, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    KWAlias      : Begin
                     Regs.AH := $39;
                     Regs.BL := $00;
                     Regs.AL := $06;
                     Intr ($2F, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    KWKeyMacro   : Begin
                     Regs.AH := $39;
                     Regs.BL := $00;
                     Regs.AL := $07;
                     Intr ($2F, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    KWSlowDown   : Begin
                     Regs.AH := $39;
                     Regs.BL := $00;
                     Regs.AL := $08;
                     Intr ($2F, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    KWAnsigrab   : Begin
                     Regs.AH := $39;
                     Regs.BL := $00;
                     Regs.AL := $09;
                     Intr ($2F, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    KWTee        : Begin
                     Regs.AH := $39;
                     Regs.BL := $00;
                     Regs.AL := $0A;
                     Intr ($2F, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    KWFastMous   : Begin
                     Regs.AH := $39;
                     Regs.BL := $00;
                     Regs.AL := $0B;
                     Intr ($2F, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    KWExtWild    : Begin
                     Regs.AH := $39;
                     Regs.BL := $00;
                     Regs.AL := $0C;
                     Intr ($2F, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    KWBreakOut   : Begin
                     Regs.AH := $39;
                     Regs.BL := $00;
                     Regs.AL := $0D;
                     Intr ($2F, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    KWStopDisk  :  Begin
                     Regs.AH := $39;
                     Regs.BL := $00;
                     Regs.AL := $0E;
                     Intr ($2F, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    Tame        :  Begin
                     Regs.AX := $2B01;
                     Regs.CX := $5441;
                     Regs.DX := $4D45;
                     MsDos(regs);
                     IsInstalled := Not (Regs.AL <> 2);
                   End;
    CAMSCSI     :  Begin
                    Regs.AX := $354F;
                    MsDos (Regs);
                    If (Regs.ES <> 0) And (Regs.BX <> 0) Then
                      Begin
                        Regs.AX := $8200;
                        Regs.CX := $8765;
                        Regs.DX := $CBA9;
                        Intr ($4F, Regs);
                        If (Regs.CX = $9ABC) And (Regs.DX = $5678) Then
                          Begin
                            S := '';
                            For Count := Regs.DI To Regs.DI + 7 Do
                              S := S + Chr (Mem[Regs.ES:Count]);
                            IsInstalled := (S = 'SCSI_CAM');
                          End
                        Else
                         IsInstalled := False
                      End;
                  End;
    CMCISCSIDrv : Begin
                    Regs.AX := $3578;
                    MsDos (Regs);
                    S := '';
                    For Count := Regs.BX + 3 To Regs.BX + 6 Do
                      S := S + Chr(Mem[Regs.ES:Count]);
                    IsInstalled := (S = 'SCSI');
                  End;
    VUIMGDrv    : Begin
                    Regs.AX := $0F56;
                    Regs.BX := $4756;
                    Regs.CX := $4944;
                    Regs.DL := $01;
                    Intr ($10, Regs);
                    IsInstalled := ((Regs.AX = $5649) And (Regs.BX = $4443)
                      And (Regs.CX = $5647) And (Regs.DH = $01));
                  End;
    TinyTalk    : Begin
                    Regs.AH := $38;
                    Intr ($10, Regs);
                    PtrStr8 := Ptr (Regs.ES, Regs.DI);
                    IsInstalled := (PtrStr8^ = 'TTCONFIG');
                  End;
    Fast        : Begin
                    GetMem (B, SizeOf (B^));
                    Regs.AH := $80;
                    Regs.AL := $06;
                    Regs.CX := $6572;
                    Regs.DX := $1970;
                    Regs.ES := PtrRec(B).Seg;
                    Regs.BX := PtrRec(B).Ofs;
                    Intr ($13, Regs);
                    IsInstalled := (Regs.AX = $1965);
                    FreeMem (B, SizeOf (B^));
                  End;
    SWBiosC     : Begin
                    Regs.AH := $19;
                    Regs.DL := $80;
                    Regs.Flags := Regs.Flags And FCarry;
                    Intr ($13, Regs);
                    IsInstalled := ((Regs.Flags And FCarry) = 0);
                  End;
    SWBiosD     : Begin
                    Regs.AH := $19;
                    Regs.DL := $81;
                    Regs.Flags := Regs.Flags And FCarry;
                    Intr ($13, Regs);
                    IsInstalled := ((Regs.Flags And FCarry) = 0);
                  End;
    ErgoOS2_386 : Begin
                    GetMem (B, SizeOf (B^));
                    Regs.AH := $A1;
                    Regs.BX := $0081;
                    Regs.AL := $FE;
                    Regs.ES := PtrRec(B).Seg;
                    Regs.DI := PtrRec(B).Ofs;
                    Intr ($2F, Regs);
                    IsInstalled := (B^.Unk1 = 'IABH') ;
                    FreeMem (B, SizeOf (B^));
                  End;
    ErgoHuming  : Begin
                    GetMem (B, SizeOf (B^));
                    Regs.AH := $A1;
                    Regs.BX := $0081;
                    Regs.AL := $FF;
                    Regs.ES := PtrRec(B).Seg;
                    Regs.DI := PtrRec(B).Ofs;
                    Intr ($2F, Regs);
                    IsInstalled := (B^.Unk1 = 'IABH') ;
                    FreeMem (B, SizeOf (B^));
                  End;
    Back_Forth  : Begin
                    { Dieser Test mu· einmal auf Interrupt 11h (1.61-) und
                      einmal auf Interrupt 12h (1.62+) ausgefÅhrt werden.  }
                    Regs.AX := $FFFE;
                    Regs.CX := $FFFE;
                    Regs.BX := $0000;
                    Intr ($11, Regs);
                    If Not ((Regs.AX = $0001) Or (Regs.AX = $0003)) Then
                      Begin
                        Regs.AX := $FFFE;
                        Regs.CX := $FFFE;
                        Regs.BX := $0000;
                        Intr ($12, Regs);
                        IsInstalled := (Regs.AX = $0001);
                      End
                    Else
                      IsInstalled := True;
                  End;
    Tes         : Begin
                    Regs.AH := $A0;
                    Regs.CX := $FFFF;
                    Regs.Flags := Regs.Flags And FCarry;
                    Intr ($14, Regs);
                    IsInstalled := (((Regs.Flags And FCarry) = 0) And
                      (Regs.AX = $5445) And (Regs.CX <> $FFFF));
                  End;
    AvatarSys   : Begin
                    Regs.AX := $1A00;
                    Regs.BX := $4156;
                    Regs.CX := $4154;
                    Regs.DX := $4152;
                    Regs.Flags := Regs.Flags And FCarry;
                    Intr ($2F, Regs);
                    IsInstalled := (((Regs.Flags And FCarry) = 0) And
                      (Regs.AL = $FF) And (Regs.DX = $0016));
                  End;
    SBSpeechDrv : Begin
                    Regs.AX := $FBFB;
                    Regs.ES := $0000;
                    Intr ($2F, Regs);
                    IsInstalled := (Regs.ES <> 0);
                  End;
    SRDisk      : Begin
                    Regs.AX := $7200;
                    Regs.ES := $0000;
                    Intr ($2F, Regs);
                    IsInstalled := ((Regs.AL = $FF) And (Regs.ES <> 0));
                  End;
    DVQExt      : Begin
                    Regs.AX := $11DE;
                    Regs.Flags := Regs.Flags And FCarry;
                    Intr ($15, Regs);
                    IsInstalled := (((Regs.Flags And FCarry) = 0));
                  End;
    TextCapCom  : Begin
                    Regs.AX := $4252;
                    Intr ($16, Regs);
                    IsInstalled := (Regs.Flags = $5242);
                  End;
    FakeyCom    : Begin
                    Regs.AH := $70;
                    Intr ($16, Regs);
                    IsInstalled := (Regs.AX = $1954);
                  End;
    MakeyCom    : Begin
                    Regs.AH := $80;
                    Intr ($16, Regs);
                    IsInstalled := (Regs.AX = $1954);
                  End;
    WatchCom    : Begin
                    Regs.AX := $7761;
                    Intr ($16, Regs);
                    IsInstalled := (Regs.AX = $5741);
                  End;
    PushDirCom  : Begin
                    Regs.AX := $7788;
                    Regs.BX := $7789;
                    Regs.ES := Seg (Sig1);
                    Regs.SI := Ofs (Sig1);
                    Intr ($16, Regs);
                    IsInstalled := ((Regs.AX = $7789) And (Regs.BX = $7788));
                  End;
    Scout       : Begin
                    Regs.AH := $9E;
                    Intr ($16, Regs);
                    IsInstalled := (Regs.AX = $ABCD);
                  End;
    EGAPalCom   : Begin
                    Regs.AX := $CA00;
                    Regs.BX := $6570;
                    Regs.CX := $6570;
                    Intr ($16, Regs);
                    IsInstalled := (Regs.AX = $CAFF);
                  End;
    VGAPalCom   : Begin
                    Regs.AX := $CA00;
                    Regs.BX := $7670;
                    Regs.CX := $7670;
                    Intr ($16, Regs);
                    IsInstalled := (Regs.AX = $CAFF);
                  End;
    LPTx4       : Begin
                   Regs.DX := $0F5F;
                   Intr ($17, Regs);
                   IsInstalled := ((Regs.AX = $AAAA) And (Regs.DX = $F555));
                  End;
    LPTx5       : Begin
                   Regs.DX := $0ABC;
                   Intr ($17, Regs);
                   IsInstalled := ((Regs.AX = $AAAA) And (Regs.DX = $BAAA));
                  End;
    LPTx6       : Begin
                   Regs.DX := $0B90;
                   Intr ($17, Regs);
                   IsInstalled := (Regs.DX = $ABBB);
                  End;
    LPTx7       : Begin
                   Regs.DX := $0B91;
                   Intr ($17, Regs);
                   IsInstalled := (Regs.DX = $ABCB);
                  End;
    FlashUpCom  : Begin
                    Regs.AH := $60;
                    Intr ($17, Regs);
                    IsInstalled := (Regs.AL = $60);
                  End;
    SpeedScrCom : Begin
                    Regs.AH := $61;
                    Intr ($17, Regs);
                    IsInstalled := (Regs.AL = $61);
                  End;
    Stackey     : Begin
                    Regs.AH := $CA;
                    Regs.BX := $736B;
                    Regs.CX := $736B;
                    Regs.AL := $00;
                    Intr ($16, Regs);
                    IsInstalled := (Regs.AX = $CAFF);
                  End;
    PCT7DataMon  : Begin
                     Regs.AX := $6284;
                     Regs.BX := $0000;
                     Regs.CX := $0000;
                     Intr ($2f, Regs);
                     IsInstalled := ((Regs.BX = $5555) And (Regs.CX = $5555));
                   End;
    PCT5BackTalk : Begin
                     Regs.AX := $6969;
                     Regs.BX := $6969;
                     Regs.DX := $0000;
                     Intr ($16, Regs);
                     IsInstalled := (Regs.DX <> 0);
                   End;
    PCT7CpShDesk : Begin
                     Regs.AX := $FEEF;
                     Regs.CX := $0000;
                     Intr ($16, Regs);
                     IsInstalled := (Regs.CX = $ABCD);
                   End;
    PCT5Shell    : Begin
                     Regs.AX := $FFDD;
                     Regs.BX := $0000;
                     Intr ($16, Regs);
                     IsInstalled := (Regs.CX = $5555);
                   End;
    PCT5ShellRes : Begin
                     Regs.AX := $FFDD;
                     Regs.BX := $0000;
                     Intr ($16, Regs);
                     IsInstalled := (Regs.DX = $5555);
                   End;
    PCT6Run      : Begin
                     Regs.AX := $FFDD;
                     Regs.BX := $000A;
                     Intr ($16, Regs);
                     IsInstalled := (Regs.DX = $5555);
                   End;
    PCT5Desktop  : Begin
                     Regs.AX := $FFEF;
                     Regs.CX := $0000;
                     Intr ($16, Regs);
                     IsInstalled := (Regs.CX = $ABCD);
                   End;
    PCT6Cache    : Begin
                     Regs.AX := $FFA5;
                     Regs.CX := $1111;
                     Intr ($16, Regs);
                     IsInstalled := (Regs.CH = $00);
                   End;
    PCT5Cache    : Begin
                     Regs.AH := $2B;
                     Regs.CX := $4358;
                     MsDos (Regs);
                     IsInstalled := ((Regs.AL = $00) And (Regs.CX = $6378));
                   End;
    ElRes        : Begin
                     Regs.AH := $2B;
                     Regs.CX := $454C;
                     Regs.DX := $5253;
                     MsDos (Regs);
                     IsInstalled := (Regs.DX = $DABE);
                   End;
    ConcDos      : Begin
                     Regs.AX := $4451;
                     Regs.Flags := Regs.Flags And FCarry;
                     MsDos (Regs);
                     IsInstalled := (((Regs.Flags And FCarry) = 0) And (Regs.AH = $14));
                   End;
    DietOvr      : Begin
                     Regs.AX := $4BF0;
                     Regs.Flags := Regs.Flags And FCarry;
                     MsDos (Regs);
                     IsInstalled := (((Regs.Flags And FCarry) = 0) And (Regs.AX = $899D));
                   End;
    DosEdCom     : Begin
                     GetMem(PtrStr8, SizeOf (PtrStr8^));
                     PtrStr8^ := 'DOSED'#0#0#0;
                     Regs.AH := $FF;
                     Regs.DS := PtrRec(PtrStr8).Seg;
                     Regs.SI := PtrRec(PtrStr8).Ofs;
                     Regs.ES := $0000;
                     MsDos (Regs);
                     FreeMem(PtrStr8, SizeOf (PtrStr8^));
                     PtrStr8 := Ptr (Regs.ES, Regs.SI);
                     IsInstalled := ((PtrStr8^[0] = 'D') And (PtrStr8^[1] = 'O') And
                                      (PtrStr8^[2] = 'S') And (PtrStr8^[3] = 'E') And
                                      (PtrStr8^[4] = 'D'));                                     ;
                   End;
    Dos4_G       : Begin
                     Regs.AX := $FF00;
                     Regs.DX := $0078;
                     MsDos (Regs);
                     IsInstalled := (Regs.AL <> $00);
                   End;
    CuckooCom    : Begin
                     xBool := False;
                     For xWord := $0 To $7 Do
                       Begin
                         GetIntVec ($60 + xWord, xPointer);
                         PtrStr8 := xPointer;
                         xBool := ((PtrStr8^[0] = 'C') And (PtrStr8^[1] = 'L') And
                                   (PtrStr8^[2] = 'O') And (PtrStr8^[3] = 'K'));
                         If xBool Then Exit;
                       End;
                     IsInstalled := xBool;
                   End;
    DecNetDCT    : Begin
                     Regs.AX := $0100;
                     Intr ($69, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    ANSK         : Begin
                     IsInstalled := ((Chr(Mem[$F000:$0000]) = 'A') And (Chr(Mem[$F000:$0001]) = 'N') And
                                     (Chr(Mem[$F000:$0002]) = 'S') And (Chr(Mem[$F000:$0003]) = 'K'));
                   End;
    CTask        : Begin
                     GetMem (PtrStr8, SizeOf (PtrStr8));
                     Regs.AX := $3000;
                     Regs.BX := $1234;
                     Regs.DS := PtrRec(PtrStr8).Seg;
                     Regs.DX := PtrRec(PtrStr8).Ofs;
                     PtrStr8^ := 'CTask21'#0;
                     MsDos (Regs);
                     FreeMem (PtrStr8, SizeOf (PtrStr8));
                     PtrStr8 := Ptr (Regs.BX, Regs.CX);
                     IsInstalled := PtrStr8^ = 'CTask21'#0;
                   End;
    ZipKey       : Begin
                     GetIntVec ($B3, xPointer);
                     PtrStr6 := xPointer;
                     Inc (PtrRec(PtrStr6).Ofs, $75);
                     IsInstalled := PtrStr6^ = 'ZIPKEY';
                   End;
    CompaqAdapt  : Begin
                     Regs.AX := $BFA0;
                     Regs.BX := $ADAD;
                     Intr ($10, Regs);
                     IsInstalled := (Regs.AX = $BDBD)
                   End;
    Unchain      : Begin
                     Regs.AX := $CBFF;
                     Intr ($10, Regs);
                     IsInstalled := (Regs.AX = $CCBB)
                   End;
    BlankIt      : Begin
                     Regs.AX := $0225;
                     Regs.BX := $6900;
                     Intr ($11, Regs);
                     PtrStr6 := Ptr (Regs.ES, Regs.DI);
                     IsInstalled := ((Regs.BL = $23) And (PtrStr6^ = 'BLNKIT'));
                   End;
    Parker       : Begin
                     Regs.CX := $1807;
                     Intr ($12, Regs);
                     IsInstalled := (Regs.CX = $1961);
                   End;
    ScreenR      : Begin
                     Regs.AX := $5049;
                     Regs.BX := 0;
                     Intr ($10, Regs);
                     IsInstalled := (Regs.AX = 0);
                   End;
    Stacker      : Begin
                     xWord1 := Seg(StackerBuf);
                     xWord2 := Ofs(StackerBuf);

                     Asm
                       mov  ax,$CDCD       { signature entry }
                       mov  cx,1
                       mov  dx,0
                       push ds             { need to preserve these }
                       push bp
                       mov  ds,xword1      { pointer to address buffer }
                       mov  bx,xword2
                       int  $25            { DOS absolute read sectors }
                       pop  cx             { remove old flags }
                       pop  bp             { restore important regs }
                       pop  ds
                       mov  xword1,ax      { save return code }
                     End;

                     IsInstalled := ((xWord1 = $CDCD) And (MemW[stackerbuf.ddseg:stackerbuf.ddofs] = $A55A))
                   End;
    ScreenR      : Begin
                     Regs.AX := $5049;
                     Regs.BX := 0;
                     Intr ($10, Regs);
                     IsInstalled := (Regs.AX = 0);
                   End;
    BWLPD        : Begin
                     Regs.AX := $4257;
                     Regs.DX := $1234;
                     Intr ($13, Regs);
                     IsInstalled := (Regs.BX = $414C);
                   End;
    ScanBoot     : Begin
                     Regs.AX := $5342;
                     Regs.CX := 1;
                     Regs.DX := 0;
                     Regs.Flags := Regs.Flags And FCarry;
                     Intr ($13, Regs);
                     IsInstalled := ((Regs.Flags And FCarry = 0) And (Regs.AX = 0));
                   End;
    BWCom14      : Begin
                     Regs.AH := $56;
                     Intr ($14, Regs);
                     IsInstalled := (Regs.CX = 1);
                   End;
    TelApi       : Begin
                     Regs.AX := $FF00;
                     Intr ($14, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    ObjectKernel : Begin
                     Regs.AX := $3000;
                     Intr ($15, Regs);
                     PtrStr4 := Ptr (Regs.AX, Regs.BX);
                     IsInstalled := (PtrStr4^ = 'OBJ!')
                   End;
    UltraVision  : Begin
                     Regs.AX := $CC00;
                     Regs.SI := 0;
                     Intr ($10, Regs);
                     IsInstalled := (Regs.CX = $ABCD);
                   End;
    UltraFont    : Begin
                     Regs.AX := $CC00;
                     Regs.SI := 0;
                     Intr ($10, Regs);
                     IsInstalled := (Regs.CX = $5546);
                   End;
    NWCDEX       : Begin
                     System.Assign (Fil, 'NWCDEX');
                     {$I-}
                     Reset (Fil);
                     {$I+}
                     IsInstalled := (IOResult=0);
                   End;
    DoubleSpace  : Begin
                     Regs.AX := $4A11;
                     Regs.BX := $0000;
                     Intr ($2F, Regs);
                     IsInstalled := ((Regs.AX = $0000) And (Regs.BX = $444D));
                   End;
    SuperStorPro : Begin
                     Regs.AX := $F800;
                     Regs.CX := $4455;
                     Regs.DL := $45;
                     Intr ($2F, Regs);
                     IsInstalled := (Regs.AL = $FF);
                   End;
    K5           : Begin
                     Regs.AX := $5D58;
                     Intr ($2F, Regs);
                     IsInstalled := ((Regs.AX = $0000) And (Regs.BX = $9999));
                   End;
    SoftwCarous  : Begin
                     Regs.AX := $DF00;
                     Regs.DX := $534C;
                     Regs.DI := $534C;
                     Intr ($21, Regs);
                     IsInstalled := (Regs.AX = $00FF);
                   End;
    FastFlip     : Begin
                     Regs.AX := $C2D2;
                     Regs.DL := 0;
                     Intr ($2F, Regs);
                     IsInstalled := (Regs.AX=$FF);
                   End;
  Else
    IsInstalled := False;
  End;
End;


Function WhichAddress (SoftwareNumber : Byte) : Pointer;

Begin
  Case SoftwareNumber Of
    KWTsrWin     : If IsInstalled (KWTsrWin) Then
                     Begin
                       { Pointer zum TSR-Modul }
                       Regs.AH := $39;
                       Regs.BL := $00;
                       Regs.AL := $01;
                       Intr ($2F, Regs);
                       WhichAddress := Ptr (Regs.DX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    KWNoBusy     : If IsInstalled (KWNoBusy) Then
                     Begin
                       { Pointer zum TSR-Modul }
                       Regs.AH := $39;
                       Regs.BL := $00;
                       Regs.AL := $02;
                       Intr ($2F, Regs);
                       WhichAddress := Ptr (Regs.DX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    KWCdStack    : If IsInstalled (KWCdStack) Then
                     Begin
                       { Pointer zum TSR-Modul }
                       Regs.AH := $39;
                       Regs.BL := $00;
                       Regs.AL := $03;
                       Intr ($2F, Regs);
                       WhichAddress := Ptr (Regs.DX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    KWDiskWatch  : If IsInstalled (KWDiskWatch) Then
                     Begin
                       { Pointer zum TSR-Modul }
                       Regs.AH := $39;
                       Regs.BL := $00;
                       Regs.AL := $04;
                       Intr ($2F, Regs);
                       WhichAddress := Ptr (Regs.DX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    KWPushBP     : If IsInstalled (KWPushBp) Then
                     Begin
                       { Pointer zum TSR-Modul }
                       Regs.AH := $39;
                       Regs.BL := $00;
                       Regs.AL := $05;
                       Intr ($2F, Regs);
                       WhichAddress := Ptr (Regs.DX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    KWAlias      : If IsInstalled (KWalias) Then
                     Begin
                       { Pointer zum TSR-Modul }
                       Regs.AH := $39;
                       Regs.BL := $00;
                       Regs.AL := $06;
                       Intr ($2F, Regs);
                       WhichAddress := Ptr (Regs.DX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    KWKeyMacro   : If IsInstalled (KWKeyMacro) Then
                     Begin
                       { Pointer zum TSR-Modul }
                       Regs.AH := $39;
                       Regs.BL := $00;
                       Regs.AL := $07;
                       Intr ($2F, Regs);
                       WhichAddress := Ptr (Regs.DX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    KWSlowDown   : If IsInstalled (KWSlowDown) Then
                     Begin
                       { Pointer zum TSR-Modul }
                       Regs.AH := $39;
                       Regs.BL := $00;
                       Regs.AL := $08;
                       Intr ($2F, Regs);
                       WhichAddress := Ptr (Regs.DX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    KWAnsiGrab   : If IsInstalled (KWAnsiGrab) Then
                     Begin
                       { Pointer zum TSR-Modul }
                       Regs.AH := $39;
                       Regs.BL := $00;
                       Regs.AL := $09;
                       Intr ($2F, Regs);
                       WhichAddress := Ptr (Regs.DX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    KWTee        : If IsInstalled (KWTee) Then
                     Begin
                       { Pointer zum TSR-Modul }
                       Regs.AH := $39;
                       Regs.BL := $00;
                       Regs.AL := $0A;
                       Intr ($2F, Regs);
                       WhichAddress := Ptr (Regs.DX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    KWfastMous   : If IsInstalled (KWFastMous) Then
                     Begin
                       { Pointer zum TSR-Modul }
                       Regs.AH := $39;
                       Regs.BL := $00;
                       Regs.AL := $0B;
                       Intr ($2F, Regs);
                       WhichAddress := Ptr (Regs.DX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    KWExtWild    : If IsInstalled (KWExtWild) Then
                     Begin
                       { Pointer zum TSR-Modul }
                       Regs.AH := $39;
                       Regs.BL := $00;
                       Regs.AL := $0C;
                       Intr ($2F, Regs);
                       WhichAddress := Ptr (Regs.DX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    KWBreakOut   : If IsInstalled (KWBreakOut) Then
                     Begin
                       { Pointer zum TSR-Modul }
                       Regs.AH := $39;
                       Regs.BL := $00;
                       Regs.AL := $0D;
                       Intr ($2F, Regs);
                       WhichAddress := Ptr (Regs.DX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    KWStopDisk   : If IsInstalled (KWStopDisk) Then
                     Begin
                       { Pointer zum TSR-Modul }
                       Regs.AH := $39;
                       Regs.BL := $00;
                       Regs.AL := $0E;
                       Intr ($2F, Regs);
                       WhichAddress := Ptr (Regs.DX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    TaskSwitch5  : If IsInstalled (TaskSwitch5) Then
                     Begin
                       { Dos 5 Task Switcher Entry Point }
                       Regs.AX:=$4B02;
                       Regs.BX:=0;
                       Regs.ES:=0;
                       Regs.DI:=0;
                       Intr($2F, regs);
                       if (regs.Flags And FCarry = 0) and (Regs.AX = 0)
                         and (Regs.BX = 0) then
                           begin
                             WhichAddress := Ptr (Regs.ES, Regs.DI);
                           end
                         else
                           WhichAddress := Ptr (0,0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    Tame         : If IsInstalled (Tame) Then
                     Begin
                       { Tame Data Area }
                       Regs.AX:=$2B01;
                       Regs.CX:=$5441;
                       Regs.DX:=$4D45;
                       MsDos(regs);
                       WhichAddress := Ptr (Regs.ES, Regs.DX);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    ZWMouse      : If IsInstalled (ZWMouse) Then
                     Begin
                       { Segment vom residenten Code }
                       Regs.AX := $D000;
                       Intr ($2F, Regs);
                       WhichAddress := Ptr (Regs.BX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    TurbonetSer : If IsInstalled (TurboNetSer) Then
                     Begin
                       { CS des Turbonet Server's }
                       Regs.AX := $8000;
                       Intr ($2F, Regs);
                       WhichAddress := Ptr (Regs.BX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    InnerMission: If IsInstalled (InnerMission) Then
                     Begin
                       { Segment vom residenten Code }
                       Regs.AX := $9300;
                       Regs.BX := $9300;
                       Regs.CX := $9300;
                       Intr ($2F, Regs);
                       WhichAddress := Ptr (Regs.BX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    PCT7DataMon  : If IsInstalled (PCT7DataMon) Then
                     Begin
                       { Segment vom residenten Code }
                       Regs.AX := $6284;
                       Regs.BX := $0000;
                       Regs.CX := $0000;
                       Intr ($2F, Regs);
                       WhichAddress := Ptr (Regs.AX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    Asap         : If IsInstalled (Asap) Then
                     Begin
                       { Segment vom residenten Code }
                       Regs.AX := $F0F1;
                       Regs.DX := $0000;
                       Intr ($2F, Regs);
                       WhichAddress := Ptr (Regs.DX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    FastBuffCom : If IsInstalled (FastBuffCom) Then
                     Begin
                       { Segment vom residenten Code }
                       Regs.AX := $FA00;
                       Intr ($2F, Regs);
                        WhichAddress := Ptr (Regs.ES, 0);
                      End
                    Else
                      WhichAddress := Ptr (0,0);
    Dos3         : If IsInstalled (Dos3) Then
                     Begin
                       { Dos 3+ Datensegment IBMDOS.COM/MSDOS.SYS }
                       Regs.AX := $1203;
                       Intr ($2F, Regs);
                       WhichAddress := Ptr (Regs.DS, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    SBSpeechDrv  : If IsInstalled (SBSpeechDrv) Then
                     Begin
                       { Soundblaster Speech Driver Entry Point }
                       Regs.AX := $FBFB;
                       Regs.ES := $0000;
                       Intr ($2F, Regs);
                       WhichAddress := Ptr (MemW[Regs.ES:Regs.BX+5],
                         MemW[Regs.ES:Regs.BX+7]);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    DVQExt       : If IsInstalled (DVQExt) Then
                     Begin
                       { In welchem Segment ist QEXT.SYS aktiv }
                       Regs.AX := $11DE;
                       Intr ($15, Regs);
                       WhichAddress := Ptr (Regs.AX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    EGAPalCom    : If IsInstalled (EGAPalCom) Then
                     Begin
                       { Segment des residenten Code's }
                       Regs.AX := $CA00;
                       Regs.BX := $6570;
                       Regs.CX := $6570;
                       Intr ($16, Regs);
                       WhichAddress := Ptr (Regs.BX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    VGAPalCom    : If IsInstalled (VGAPalCom) Then
                     Begin
                       { Segment des residenten Code's }
                       Regs.AX := $CA00;
                       Regs.BX := $7670;
                       Regs.CX := $7670;
                       Intr ($16, Regs);
                       WhichAddress := Ptr (Regs.BX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    LPTx4        : If IsInstalled (LPTx4) Then
                     Begin
                       { Code Segment des TSR's }
                       Regs.AX := $0F5F;
                       Intr ($17, Regs);
                       WhichAddress := Ptr (Regs.ES, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    LPTx5        : If IsInstalled (LPTx5) Then
                     Begin
                       { Code Segment des TSR's }
                       Regs.AX := $0ABC;
                       Intr ($17, Regs);
                       WhichAddress := Ptr (Regs.ES, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    LPTx6        : If IsInstalled (LPTx6) Then
                     Begin
                       { Code Segment des TSR's }
                       Regs.AX := $0B90;
                       Intr ($17, Regs);
                       WhichAddress := Ptr (Regs.ES, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    LPTx7        : If IsInstalled (LPTx7) Then
                     Begin
                       { Code Segment des TSR's }
                       Regs.AX := $0B91;
                       Intr ($17, Regs);
                       WhichAddress := Ptr (Regs.ES, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    FlashUpCom   : If IsInstalled (FlashUpCom) Then
                     Begin
                       { Code Segment des TSR's }
                       Regs.AH := $60;
                       Intr ($17, Regs);
                       WhichAddress := Ptr (Regs.DX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    SpeedScrCom  : If IsInstalled (SpeedScrCom) Then
                     Begin
                       { Code Segment des TSR's }
                       Regs.AH := $61;
                       Intr ($17, Regs);
                       WhichAddress := Ptr (Regs.DX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    Stackey      : If IsInstalled (Stackey) Then
                     Begin
                       { Segment des residenten Code's }
                       Regs.AH := $CA;
                       Regs.BX := $736B;
                       Regs.CX := $736B;
                       Regs.AL := $00;
                       Intr ($16, Regs);
                       WhichAddress := Ptr (Regs.BX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    PCT5BackTalk : If IsInstalled (PCT5BackTalk) Then
                     Begin
                       { Code Segment des TSR }
                       Regs.AX := $6969;
                       Regs.BX := $6969;
                       Regs.DX := $0000;
                       Intr ($16, Regs);
                       WhichAddress := Ptr (Regs.BX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    PCT7CpShDesk : If IsInstalled (PCT7CpShDesk) Then
                     Begin
                       { Segment des residenten Teils von von CPShedule/Desktop }
                       Regs.AX := $FEEF;
                       Regs.CX := $0000;
                       Intr ($16, Regs);
                       WhichAddress := Ptr (Regs.BX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
    PCT5Desktop  : If IsInstalled (PCT7CpShDesk) Then
                     Begin
                       { Segment des residenten Teils von PCTools 5.1+ Desktop }
                       Regs.AX := $FFEF;
                       Regs.CX := $0000;
                       Intr ($16, Regs);
                       WhichAddress := Ptr (Regs.BX, 0);
                     End
                   Else
                      WhichAddress := Ptr (0,0);
    ObjectKernel : If IsInstalled (ObjectKernel) Then
                     Begin
                       { Residentes Segment }
                       Regs.AX := $3000;
                       Intr ($15, Regs);
                       WhichAddress := Ptr (Regs.CX, 0);
                     End
                   Else
                     WhichAddress := Ptr (0,0);
  Else
    WhichAddress := Ptr (0,0)
  End;
End;


Function WhichVersion (SoftwareNumber : Byte) : String;

Const NA = '[-]';

Begin
  Case SoftwareNumber Of
    Stacker     : If IsInstalled (Stacker) Then
                    Begin
                      { Um den Stacker-Buffer zu fÅllen wird die Funktion
                        IsInstalled herangezogen. }
                      WhichVersion := BcdWordToString (MemW [StackerBuf.ddseg : StackerBuf.ddofs + 2]);
                    End
                  Else
                    WhichVersion := NA;
    Stackey     : If IsInstalled (Stackey) Then
                    Begin
                      Regs.AH := $CA;
                      Regs.AL := $00; { Installation Check }
                      Regs.BX := $736B;
                      Regs.CX := $736B;
                      Intr ($16, Regs);
                      WhichVersion := StrFnByte (Regs.CH) + '.' + ZeroPad (Regs.CL);
                    End
                  Else
                    WhichVersion := NA;
    MSCDExt     : If IsInstalled (MSCDExt) Then
                    Begin
                      Regs.AX := $15C0;
                      Intr ($2F, Regs);
                      If Regs.BX = 0 Then WhichVersion := '<2.00' Else
                        WhichVersion := StrFnByte (Regs.BH) + ZeroPad (Regs.BL);
                    End
                  Else
                    WhichVersion := NA;
    SwellEXE    : If IsInstalled (SwellEXE) Then
                    Begin
                      Regs.AX := $CD00;
                      Intr ($2F, Regs);
                      WhichVersion := StrFnByte (Regs.BH) + ZeroPad (Regs.BL);
                    End
                  Else
                    WhichVersion := NA;
    Phar_Lap    : If IsInstalled (Phar_Lap) Then
                    Begin
                      xBool := False;
                      xByte  := 1;
                      With Regs Do
                        Repeat
                          AX := $ED00;
                          BL := xByte;
                          Intr ($2F, Regs);
                          If (AL = $FF) And (SI = $5048 {PH}) And (DI = $4152 {AR}) Then
                            Begin
                              xBool := True;
                              Case xByte Of
                                1 : EndString := '286dosx v1.3+ SDK';
                                2 : EndString := '286dosx v1.3+ RTK';
                                3 : EndString := '386dosx v4.0+ SDK';
                                4 : EndString := '386dosx v4.0+ RTK'
                              End;

                              If CL < 10 Then EndString := '0' + StrFnByte (CL) Else
                                EndString := StrFnByte (CL);
                              EndString := EndString + StrFnByte (CH) + '.' + EndString;
                            End;
                          Inc(xbyte);
                        Until xbyte > 4;

                      If Not xBool Then EndString := NA;
                      WhichVersion := EndString;
                    End
                  Else
                    WhichVersion := NA;
    Zipkey      : If IsInstalled (Zipkey) Then
                    Begin
                      Regs.AH := $70;
                      Intr ($B3, Regs);
                      WhichVersion := StrFnByte (Regs.AH) + '.' + StrFnByte
                        (Regs.AL) + ', ' + StrFnByte (Regs.DL) + '/' +
                        StrFnWord (Regs.DH+1900) +  ', ' + StrFnByte
                        (Regs.CL) + ' Staaten';
                    End
                  Else
                    WhichVersion := NA;
    CompaqAdapt : If IsInstalled (CompaqAdapt) Then
                    Begin
                      Regs.AX := $BFA0;
                      Regs.BX := $ADAD;
                      Intr ($10, Regs);
                      WhichVersion := BCDWordToString (Regs.BX);
                    End
                  Else
                    WhichVersion := NA;
    ScreenR     : If IsInstalled (ScreenR) Then
                    Begin
                      Regs.AX := $5049;
                      Regs.BX := $0000;
                      Intr ($10, Regs);
                      WhichVersion := StrFnByte (Regs.BH) + '.' + StrFnByte (Regs.BL);
                    End
                  Else
                    WhichVersion := NA;
    ScanBoot    : If IsInstalled (ScanBoot) Then
                    Begin
                      Regs.AX := $5342;
                      Regs.CX := 1;
                      Regs.DX := 0;
                      Intr ($13, Regs);
                      WhichVersion := StrFnByte (Regs.DH) + '.' + StrFnByte (Regs.DL);
                    End
                  Else
                    WhichVersion := NA;
    UltraVision : If IsInstalled (UltraVision) Then
                    Begin
                      Regs.AX := $CC00;
                      Regs.SI := 0;
                      Intr ($10, Regs);
                      WhichVersion := StrFnByte (Hi (Regs.SI)) + '.' + StrFnByte (Lo (Regs.SI));
                    End
                  Else
                    WhichVersion := NA;
    UltraFont   : If IsInstalled (UltraFont) Then
                    Begin
                      Regs.AX := $CC00;
                      Regs.SI := 0;
                      Intr ($10, Regs);
                      WhichVersion := StrFnByte (Hi (Regs.SI)) + '.' + StrFnByte (Lo (Regs.SI));
                    End
                  Else
                    WhichVersion := NA;
  Else
    WhichVersion := 'unbekannte Funktionsnummer';
  End;
End;


Begin
End.