{$M 16384, 16384, 655360} { 16k Stack, 16k min. Heap, 640K max. Heap }

{$X+}    { Erweiterte Syntax     }
{$I-}    { Keine I/O-PrÅfung     }
{$R-}    { Kein Range-Check      }
{$S-}    { Keine StackprÅfung    }
{$Q-}    { Keine öberlaufprÅfung }
{$G-}
{$A+}    { Word-Datenausrichtung }

Program ExampleDetect;

Uses Crt, Dos, Detect, DetectGlobal, DetectConstants, Example2,
     ExampleGlobal;

Var OldAu : Byte;

Procedure SoftwareWindowF1; Forward;

Function Menu (x1,y1,x2,y2,v,h,a : Byte; MenuA : Array Of String18) : Byte;

Var New      : Byte;
    Old      : Byte;

  Procedure Draw (v, h : Byte);

  Var Count   : Byte;
      Ausgang : Byte;
      Lines   : Byte;

  Begin
    Lines := y2-y1-1;
    Ausgang := OldAu;

    For Count := 1 To 50 Do
      Begin
        If New > OldAu + Lines Then
          Begin
            OldAu := OldAu + 1;
          End;
        If New < OldAu Then
          Begin
            OldAu := OldAu - 1;
          End;
      End;

    Ausgang := OldAu;

    GotoXY (1,1);

    For Count := Ausgang To Ausgang + Lines Do
      If Count = New Then
        Begin
          TextColor (h);
          TextBackGround (v);
          WriteLn (MenuA[Count]);
          TextColor (v);
          TextBackGround (h);
        End
      Else
        WriteLn (MenuA[Count]);

    Old := New;
    OldAu := Ausgang;
  End;

Var I : Byte;
    EndBoolean : Boolean;
    ReadChar : Char;

Begin
  New := A;
  EndBoolean := False;
  Window (x1,y1,x2,y2);
  TextColor (v);
  TextBackGround (h);
  Draw (v,h);
  Repeat
    Draw (v,h);
    Repeat
    Until KeyPressed;
    ReadChar := ReadKey;
    Case UpCase(ReadChar) Of
      #0 : Case ReadKey Of
             'H' : If New > 0 Then
                     Begin
                       New := New - 1;
                     End;
             'P' : If New < High (MenuA) Then
                      Begin
                        New := New + 1;
                      End;
             'I' : If (New - (y2-y1-1)) > 1 Then
                     Begin
                       New := New - (y2-y1-1);
                     End
                   Else
                     New := 0;
             'Q' : If (New + (y2-y1-1)) < High (MenuA) Then
                     Begin
                       New := New + (y2-y1-1);
                     End
                   Else
                     New := High (MenuA);
             'G' : New := 0;
             'O' : New := High (MenuA);
           End;
      Chr(13) : EndBoolean := True;
    End;
  Until EndBoolean;
  Menu := Old;
  Window (1,1,80,25);
End;


Procedure C; { Check fÅr die Bildschirmma·e ... }

Const MaxLines = 19;

Begin
  If WhereY = MaxLines Then
    Begin
      WaitKey;
      ClrScr;
    End;
End;


Procedure SoftwareWindow;

Begin
  Rahmen (22,4,79,25,' Informationen Åber Residente Programme ');
  Window (23,5,77,23);
  WriteLn ('In diesem Fenster werden alle vom Programm erkannten,');
  WriteLn ('Åber den Multiplex-Interrupt oder andere Mechanismen');
  WriteLn ('erreichbar, in einer Liste angezeigt. Insgesamt');
  WriteLn ('kînnen ca. 180 Programme erkannt werden ...');
  WriteLn;

  If IsInstalled (Assign) Then WriteLn (' - Assign'); C;
  If IsInstalled (DriverSys) Then WriteLn (' - DRIVER.SYS'); C;
  If IsInstalled (Share) Then WriteLn (' - Share'); C;
  If IsInstalled (RedIfs) Then WriteLn (' - Redirector/Ifs'); C;
  If IsInstalled (MultiDos) Then
    Begin
      WriteLn (' - MultiDos'); C;
      WriteLn ('   - Im Vordergrund                 : ', Cross (MDPIsForeGround)); C;
      WriteLn ('   - Ist MultiTasking eingeschaltet : ', Cross (MDPIsMultitasking)); C;
    End;
  If IsInstalled (NlsFunc) Then WriteLn (' - NlsFunc'); C;
  If IsInstalled (Win386) Then WriteLn (' - Windows/386'); C;
  If IsInstalled (DosShell) Then WriteLn (' - Dos-Shell'); C;
  If IsInstalled (AnsiSys) Then WriteLn (' - ANSI.SYS'); C;
  If IsInstalled (XMA2EMSSys) Then WriteLn (' - XMA2EMS.SYS'); C;
  If IsInstalled (Arnakey) Then WriteLn (' - Arnakey'); C;
  If IsInstalled (TaskSwitch5) Then
    Begin
      WriteLn (' - Dos 5 Task Switcher'); C;
      xPointer := WhichAddress (TaskSwitch5);
      WriteLn ('   - Entry Point : ', Hex (PtrRec(xPointer).Seg, 4), ':', Hex (PtrRec(xPointer).Ofs, 4)); C;
    End;
  If IsInstalled (DrDosTskMx) Then
    Begin
      WriteLn (' - DR Dos Task Max'); C;
      WriteLn ('   - Version                   : ', TaskMaxVersion); C;
      WriteLn ('   - Maximale Anzahl von Tasks : ', TaskMaxMaxTasks); C;
      WriteLn ('   - Aktuelle Anzahl von Tasks : ', TaskMaxActTasks); C;
    End;
  If IsInstalled (Himem) Then WriteLn (' - Himem-Treiber'); C;
  If IsInstalled (NNIPX) Then WriteLn (' - Novell Netware IPX-Protokoll'); C;
  If IsInstalled (Display) Then WriteLn (' - DISPLAY.SYS'); C;
  If IsInstalled (DICExt) Then WriteLn (' - Dos Installable Command Extender'); C;
  If IsInstalled (IBM3270) Then WriteLn (' - IBM 3270 Emulation'); C;
  If IsInstalled (Append) Then
    Begin
      WriteLn (' - Append'); C;
      WriteLn ('   - Status und Optionen : ', AppendStatus); C;
      WriteLn ('   - Pfad                : ', AppendPath); C;
    End;
  If IsInstalled (Lan) Then WriteLn (' - LAN'); C;
  If IsInstalled (LanRec) Then WriteLn (' - LAN RECEIVER.COM'); C;
  If IsInstalled (LanRedir) Then WriteLn (' - LAN REDIRIFS.EXE'); C;
  If IsInstalled (WildUnix) Then WriteLn (' - WildUnix'); C;
  If IsInstalled (FluShot) Then WriteLn (' - Flu-Shot+'); C;
  If IsInstalled (HyperDisk) Then WriteLn (' - HyperDisk'); C;
  If IsInstalled (MSLanTastic) Then WriteLn (' - MS LanTastic'); C;
  If IsInstalled (_4Dos) Then
    Begin
      WriteLn (' - JP Software 4Dos'); C;
      WriteLn ('   - Version     : ', Version4Dos ); C;
      WriteLn ('   - ShellNummer : ', Shell4Dos ); C;
      Writeln ('   - PSP-Segment : ', Hex (PSPSegment4Dos,4)); C;
    End;
  If IsInstalled (KStack) Then WriteLn (' - JP Software KSTack'); C;
  If IsInstalled (NDos) Then
    Begin
      WriteLn (' - Norton NDos'); C;
      WriteLn ('   - Version     : ', VersionNDos ); C;
      WriteLn ('   - ShellNummer : ', ShellNDos ); C;
      Writeln ('   - PSP-Segment : ', Hex (PSPSegmentNDos,4)); C;
    End;
  If IsInstalled (FPFLock) Then WriteLn (' - F-Prot F-Lock'); C;
  If IsInstalled (FPFXChk) Then WriteLn (' - F-Prot F-XChk'); C;
  If IsInstalled (FPFPopUp) Then WriteLn (' - F-Prot F-PopUp'); C;
  If IsInstalled (FPFDLock) Then WriteLn (' - F-Prot F-DLock'); C;
  If IsInstalled (N_Cache_F) Then WriteLn (' - Norton Cache-F'); C;
  If IsInstalled (N_Cache_S) Then WriteLn (' - Norton Cache-S'); C;
  If IsInstalled (N_Cache_F) Or IsInstalled (N_Cache_F) Then WriteLn ('   - Status : ', N_CacheStatus); C;
  If IsInstalled (N_DiskReet) Then
    Begin
      WriteLn (' - Norton DiskReet'); C;
      WriteLn ('   - Status  : ', N_DiskReetStatus); C;
      WriteLn ('   - Segment : ', Hex(N_DiskReetRes,4));
    End;
  If IsInstalled (N_DiskMon) Then
    Begin
      WriteLn (' - Norton DiskMon'); C;
      WriteLn ('   - Status  : ', N_DiskMonStatus); C;
      WriteLn ('   - Segment : ', Hex(N_DiskMonRes,4)); C;
    End;
  If IsInstalled (N_FileSav) Then
    Begin
      WriteLn (' - Norton FileSave'); C;
      WriteLn ('   - Segment : ', Hex(N_FileSav,4)); C;
    End;
  If IsInstalled (TopwNetOs) Then WriteLn (' - Topware NET-OS'); C;
  If IsInstalled (Inset) Then WriteLn (' - Inset'); C;
  If IsInstalled (Dos_16M) Then WriteLn (' - DOS/16M'); C;
  If IsInstalled (Phar_Lap) Then
    Begin
      WriteLn (' - Phar Lap Dos Extender'); C;
      WriteLn ('   - Typ und Version : ', WhichVersion (Phar_Lap)); C;
    End;
  If IsInstalled (EGASys) Then WriteLn (' - EGA.SYS'); C;
  If IsInstalled (Print) Then WriteLn (' - Print'); C;
  If IsInstalled (NETBiosApp) Then WriteLn (' - NETBIOS Append'); C;
  If IsInstalled (NETBiosNetW) Then WriteLn (' - NETBIOS Network'); C;
  If IsInstalled (ShellB) Then WriteLn (' - ShellB'); C;
  If IsInstalled (GraphicsCom) Then WriteLn (' - GRAPHICS.COM'); C;
  If IsInstalled (DosKey) Then WriteLn (' - Doskey'); C;
  If IsInstalled (GrafTable40) Then WriteLn (' - Graftable 4.0-'); C;
  If IsInstalled (GrafTable50) Then WriteLn (' - Graftable 5.0+'); C;
  If IsInstalled (AutoParkCOM) Then WriteLn (' - AUTOPARK.COM'); C;
  If IsInstalled (AutoBraille) Then WriteLn (' - AutoBraille'); C;
  If IsInstalled (Jot_It) Then WriteLn (' - Jot-It !'); C;
  If IsInstalled (RedView) Then WriteLn (' - RedView'); C;
  If IsInstalled (Explosiv) Then WriteLn (' - Explosiv'); C;
  If IsInstalled (IntelImg) Then WriteLn (' - Intel Image Processing Interface'); C;
  If IsInstalled (SwellExe) Then WriteLn (' - SWELL.EXE'); C;
  If IsInstalled (ZWMouse) Then
    Begin
      WriteLn (' - ZWMouse'); C;
      xPointer := WhichAddress (ZWMouse);
      WriteLn ('   - Residenter Teil : ', Hex(PtrRec(xPointer).Seg, 4), ':', Hex (PtrRec(xPointer).Ofs, 4)); C;
    End;
  If IsInstalled (HeartCom) Then WriteLn (' - HEART.COM'); C;
  If IsInstalled (GridLocExe) Then WriteLn (' - GRIDLOCK.EXE'); C;
  If IsInstalled (_4Map) Then WriteLn (' - 4Map'); C;
  If IsInstalled (MinMem) Then WriteLn (' - MinMem'); C;
  If IsInstalled (METZTSRCom) Then WriteLn (' - METZTSR.COM'); C;
  If IsInstalled (VidLockCom) Then WriteLn (' - VIDLOVK.COM'); C;
  If IsInstalled (BTrieveMU) Then WriteLn (' - BTrieve Multi-User'); C;
  If IsInstalled (PC3270Emu3) Then WriteLn (' - PC 3270 Emulator V3'); C;
  If IsInstalled (EasyNet) Then WriteLn (' - EasyNet'); C;
  If IsInstalled (TurboNetSer) Then
    Begin
      WriteLn (' - Turbonet-Server'); C;
      xPointer := WhichAddress (TurboNetSer);
      WriteLn ('   - Code Segment : ', Hex(PtrRec(xPointer).Seg, 4), ':', Hex (PtrRec(xPointer).Ofs, 4)); C;
    End;
  If IsInstalled (FaxBiosInt) Then WriteLn (' - FaxBios Interface'); C;
  If IsInstalled (ResPlay) Then WriteLn (' - ResPlay'); C;
  If IsInstalled (WhoaCom) Then WriteLn (' - WHOA.COM'); C;
  If IsInstalled (RAid) Then WriteLn (' - Resident Aid'); C;
  If IsInstalled (InnerMission) Then
    Begin
      WriteLn (' - Inner Mission'); C;
      xPointer := WhichAddress (ZWMouse);
      WriteLn ('   - Residenter Teil : ', Hex(PtrRec(xPointer).Seg, 4), ':', Hex (PtrRec(xPointer).Ofs, 4)); C;
    End;
  If IsInstalled (PCT7DataMon) Then
    Begin
      WriteLn (' - PC Tools 7 Data Monitor'); C;
      xPointer := WhichAddress (PCT7DataMon);
      WriteLn ('   - Residenter Teil : ', Hex(PtrRec(xPointer).Seg, 4), ':', Hex (PtrRec(xPointer).Ofs, 4)); C;
    End;
  If IsInstalled (SCRNSAV2Com) Then WriteLn (' - SCRNSAV.COM'); C;
  If IsInstalled (_3ComBApiSIO) Then WriteLn (' - 3com BAPI SI/O'); C;
  If IsInstalled (Asap) Then
    Begin
      WriteLn (' - Asap'); C;
      xPointer := WhichAddress (Asap);
      WriteLn ('   - Residenter Teil : ', Hex(PtrRec(xPointer).Seg, 4), ':', Hex (PtrRec(xPointer).Ofs, 4)); C;
    End;
  If IsInstalled (CouriersCom) Then WriteLn (' - COURIERS.COM'); C;
  If IsInstalled (QCache) Then WriteLn (' - QCache'); C;
  If IsInstalled (ScroLockCom) Then WriteLn (' - SCROLOCK.COM'); C;
  If IsInstalled (FastBuffCom) Then
    Begin
      WriteLn (' - FASTBUFF.COM'); C;
      xPointer := WhichAddress (FastBuffCom);
      WriteLn ('   - Residenter Teil : ', Hex(PtrRec(xPointer).Seg, 4), ':', Hex (PtrRec(xPointer).Ofs, 4)); C;
    End;
  If IsInstalled (ATIWonSupSw) Then WriteLn (' - ATI VGA Wonder Superswitch'); C;
  If IsInstalled (KWTsrWin) Then
    Begin
      WriteLn (' - Kingswood TsrWin'); C;
      xPointer := WhichAddress (KWTsrWin);
      WriteLn ('   - TSR-Modul Segment : ', Hex(PtrRec(xPointer).Seg, 4), 'h'); C;
    End;
  If IsInstalled (KWNoBusy) Then
    Begin
      WriteLn (' - Kingswood NoBusy'); C;
      xPointer := WhichAddress (KWNoBusy);
      WriteLn ('   - TSR-Modul Segment : ', Hex(PtrRec(xPointer).Seg, 4), 'h'); C;
    End;
  If IsInstalled (KWCDStack) Then
    Begin
      WriteLn (' - Kingswood CDStack'); C;
      xPointer := WhichAddress (KWCdStack);
      WriteLn ('   - TSR-Modul Segment : ', Hex(PtrRec(xPointer).Seg, 4), 'h'); C;
    End;
  If IsInstalled (KWDiskWatch) Then
    Begin
      WriteLn (' - Kingswood DiskWatch'); C;
      xPointer := WhichAddress (KWDiskWatch);
      WriteLn ('   - TSR-Modul Segment : ', Hex(PtrRec(xPointer).Seg, 4), 'h'); C;
    End;
  If IsInstalled (KWPushBP) Then
    Begin
      WriteLn (' - Kingswood PushBP'); C;
      xPointer := WhichAddress (KWPushBP);
      WriteLn ('   - TSR-Modul Segment : ', Hex(PtrRec(xPointer).Seg, 4), 'h'); C;
    End;
  If IsInstalled (KWAlias) Then
    Begin
      WriteLn (' - Kingswood Alias'); C;
      xPointer := WhichAddress (KWAlias);
      WriteLn ('   - TSR-Modul Segment : ', Hex(PtrRec(xPointer).Seg, 4), 'h'); C;
    End;
  If IsInstalled (KWKeyMacro) Then
    Begin
      WriteLn (' - Kingswood KeyMacro'); C;
      xPointer := WhichAddress (KWKeyMacro);
      WriteLn ('   - TSR-Modul Segment : ', Hex(PtrRec(xPointer).Seg, 4), 'h'); C;
    End;
  If IsInstalled (KWSlowDown) Then
    Begin
      WriteLn (' - Kingswood SlowDown'); C;
      xPointer := WhichAddress (KWSlowDown);
      WriteLn ('   - TSR-Modul Segment : ', Hex(PtrRec(xPointer).Seg, 4), 'h'); C;
    End;
  If IsInstalled (KWAnsiGrab) Then
    Begin
      WriteLn (' - Kingswood AnsiGrab'); C;
      xPointer := WhichAddress (KWAnsiGrab);
      WriteLn ('   - TSR-Modul Segment : ', Hex(PtrRec(xPointer).Seg, 4), 'h'); C;
    End;
  If IsInstalled (KWTee) Then
    Begin
      WriteLn (' - Kingswood Tee'); C;
      xPointer := WhichAddress (KWTee);
      WriteLn ('   - TSR-Modul Segment : ', Hex(PtrRec(xPointer).Seg, 4), 'h'); C;
    End;
  If IsInstalled (KWFastMous) Then
    Begin
      WriteLn (' - Kingswood FastMouse'); C;
      xPointer := WhichAddress (KWFastMous);
      WriteLn ('   - TSR-Modul Segment : ', Hex(PtrRec(xPointer).Seg, 4), 'h'); C;
    End;
  If IsInstalled (KWExtWild) Then
    Begin
      WriteLn (' - Kingswood ExtWild'); C;
      xPointer := WhichAddress (KWExtWild);
      WriteLn ('   - TSR-Modul Segment : ', Hex(PtrRec(xPointer).Seg, 4), 'h'); C;
    End;
  If IsInstalled (KWBreakOut) Then
    Begin
      WriteLn (' - Kingswood BreakOut'); C;
      xPointer := WhichAddress (KWBreakOut);
      WriteLn ('   - TSR-Modul Segment : ', Hex(PtrRec(xPointer).Seg, 4), 'h'); C;
    End;
  If IsInstalled (KWStopDisk) Then
    Begin
      WriteLn (' - Kingswood StopDisk'); C;
      xPointer := WhichAddress (KWStopDisk);
      WriteLn ('   - TSR-Modul Segment : ', Hex(PtrRec(xPointer).Seg, 4), 'h'); C;
    End;
  If IsInstalled (Tame) Then
    Begin
      WriteLn (' - Tame'); C;
      xPointer := WhichAddress (Tame);
      WriteLn ('   - Data Area : ', Hex (PtrRec(xPointer).Seg, 4), ':', Hex (PtrRec(xPointer).Ofs, 4)); C;
    End;
  If IsInstalled (VUImgDrv) Then WriteLn (' - VUImage Driver'); C;
  If IsInstalled (Fast) Then WriteLn (' - Fast'); C;
  If IsInstalled (TinyTalk) Then WriteLn (' - TinyTalk'); C;
  If IsInstalled (ERGOOS2_386) Then WriteLn (' - ERGO OS 286/386 Dos Extender'); C;
  If IsInstalled (ERGOHuming) Then WriteLn (' - ERGO Huming Dos Extender'); C;
  If IsInstalled (Back_Forth) Then WriteLn (' - Back&Forth'); C;
  If IsInstalled (DVQExt) Then WriteLn (' - DesqView QEXT.SYS'); C;
  If IsInstalled (TextCapCom) Then WriteLn (' - TEXTCAP.COM'); C;
  If IsInstalled (FakeyCom) Then WriteLn (' - FAKEY.COM'); C;
  If IsInstalled (WatchCom) Then WriteLn (' - WATCH.COM'); C;
  If IsInstalled (PushDirCom) Then WriteLn (' - PUSHDIR.COM'); C;
  If IsInstalled (MakeyCom) Then WriteLn (' - MAKEY.COM'); C;
  If IsInstalled (Scout) Then WriteLn (' - Scout'); C;
  If IsInstalled (EGAPalCom) Then WriteLn (' - EGAPAL.COM'); C;
  If IsInstalled (VGAPalCom) Then WriteLn (' - VGAPAL.COM'); C;
  If IsInstalled (LPTx4) Then
    Begin
      WriteLn (' - LPTx4'); C;
      xPointer := WhichAddress (LPTx4);
      WriteLn ('   - Codesegment : ', Hex(PtrRec(xPointer).Seg, 4)); C;
    End;
  If IsInstalled (LPTx5) Then
    Begin
      WriteLn (' - LPTx5'); C;
      xPointer := WhichAddress (LPTx5);
      WriteLn ('   - Codesegment : ', Hex(PtrRec(xPointer).Seg, 4)); C;
    End;
  If IsInstalled (LPTx6) Then
    Begin
      WriteLn (' - LPTx6'); C;
      xPointer := WhichAddress (LPTx6);
      WriteLn ('   - Codesegment : ', Hex(PtrRec(xPointer).Seg, 4)); C;
    End;
  If IsInstalled (LPTx7) Then
    Begin
      WriteLn (' - LPTx7'); C;
      xPointer := WhichAddress (LPTx7);
      WriteLn ('   - Codesegment : ', Hex(PtrRec(xPointer).Seg, 4)); C;
    End;
  If IsInstalled (FlashUpCom) Then WriteLn (' - FLASHUP.COM'); C;
  If IsInstalled (SpeedScrCom) Then WriteLn (' - SPEEDSCR.COM'); C;
  If IsInstalled (Stackey) Then
    Begin
      WriteLn (' - Stackey'); C;
      xPointer := WhichAddress (Stackey);
      WriteLn ('   - Residenter Teil : ', Hex(PtrRec(xPointer).Seg, 4), ':', Hex (PtrRec(xPointer).Ofs, 4)); C;
      WriteLn ('   - Version         : ', WhichVersion (Stackey)); C;
    End;
  If IsInstalled (PCT7CpShDesk) Then
    Begin
      WriteLn (' - PC Tools 7+ Central Point Shedule/Desktop'); C;
      xPointer := WhichAddress (PCT7CpShDesk);
      WriteLn ('   - Residenter Teil : ', Hex(PtrRec(xPointer).Seg, 4), ':', Hex (PtrRec(xPointer).Ofs, 4)); C;
      WriteLn ('   - Farbenschema    : ', PCT7DeskColorSheme); C;
    End;
  If IsInstalled (PCT6Run) Then WriteLn (' - PC Tools 6+ Run'); C;
  If IsInstalled (PCT6Cache) Then
    Begin
      WriteLn (' - PC Tools 6+ Cache'); C;
      WriteLn ('…ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕ—ÕÕÕ—ÕÕÕ—ÕÕÕ—ÕÕÕ—ÕÕÕ—ÕÕÕ—ÕÕÕª'); C;
      WriteLn ('∫ Getestet auf    ∫ A ≥ B ≥ C ≥ D ≥ E ≥ F ≥ G ≥ H ∫'); C;
      WriteLn ('ÃÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕŒÕÕÕÿÕÕÕÿÕÕÕÿÕÕÕÿÕÕÕÿÕÕÕÿÕÕÕÿÕÕÕπ'); C;
      WriteLn ('∫ PC-Cache        ∫ ',CrossE(PCT6CacheIsDrive ('A')),' ≥ ',CrossE(PCT6CacheIsDrive ('B')),' ≥ ',
                CrossE(PCT6CacheIsDrive('C')),' ≥ '+ CrossE(PCT6CacheIsDrive('D')),' ≥ ',CrossE(PCT6CacheIsDrive ('E')), ' ≥ ',
                CrossE(PCT6CacheIsDrive('F')),' ≥ ',CrossE(PCT6CacheIsDrive('G')),' ≥ '+CrossE(PCT6CacheIsDrive('H')),' ∫'); C;
      WriteLn ('»ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕœÕÕÕœÕÕÕœÕÕÕœÕÕÕœÕÕÕœÕÕÕœÕÕÕº'); C;
    End;
  If IsInstalled (PCT5Shell) Then WriteLn (' - PC Tools 5+ PC Shell'); C;
  If IsInstalled (PCT5BackTalk) Then
    Begin
      WriteLn (' - PC Tools 5+ BackTalk'); C;
      xPointer := WhichAddress (PCT5BackTalk);
      WriteLn ('   - Residenter Teil : ', Hex(PtrRec(xPointer).Seg, 4), ':', Hex (PtrRec(xPointer).Ofs, 4)); C;
    End;
  If IsInstalled (PCT5Desktop) Then
    Begin
      WriteLn (' - PC Tools 5+ Desktop'); C;
      xPointer := WhichAddress (PCT5DeskTop);
      WriteLn ('   - Residenter Teil             : ', Hex(PtrRec(xPointer).Seg, 4), ':', Hex (PtrRec(xPointer).Ofs, 4)); C;
      WriteLn ('   - Desktop Hotkey-Scancode     : ', Hex (Hi (PCT5DeskHotKey (dpcDesktopHotkey)),2),'h');  C;
      WriteLn ('   - Desktop Hotkey-Shift-State  : ', Hex (Lo (PCT5DeskHotKey (dpcDesktopHotkey)),2),'h');  C;
      WriteLn ('   - Paste Hotkey-Scancode       : ', Hex (Hi (PCT5DeskHotKey (dpcClipBoardPasteKey)),2),'h'); C;
      WriteLn ('   - Paste Hotkey-Shift-State    : ', Hex (Lo (PCT5DeskHotKey (dpcClipBoardPasteKey)),2),'h'); C;
      WriteLn ('   - Copy Hotkey-Scancode        : ', Hex (Hi (PCT5DeskHotKey (dpcClipBoardCopyKey)),2),'h'); C;
      WriteLn ('   - Copy Hotkey-Shift-State     : ', Hex (Lo (PCT5DeskHotKey (dpcClipBoardCopyKey)),2),'h'); C;
      WriteLn ('   - AudoDial Hotkey-Scancode    : ', Hex (Hi (PCT5DeskHotKey (dpcScreenAutoDialKey)),2),'h'); C;
      WriteLn ('   - AutoDial Hotkey-Shift-State : ', Hex (Lo (PCT5DeskHotKey (dpcScreenAutoDialKey)),2),'h'); C;
      WriteLn ('   - Ist resident                : ', Cross (PCT5DeskIsResident)); C;
      WriteLn ('   - Version (Ab Version 6)      : ', PCT6DeskVersion); C;
    End;
  If IsInstalled (PCT5Cache) Then WriteLn (' - PC Tools 5 Cache'); C;
  If IsInstalled (ElRes) Then WriteLn (' - Elres'); C;
  If IsInstalled (Ansk) Then WriteLn (' - Ansk'); C;
  If IsInstalled (DecNetDCT) Then WriteLn (' - DECNet DCT'); C;
  If IsInstalled (ZipKey) Then
    Begin
      WriteLn (' - Zipkey'); C;
      WriteLn ('   - Version : ', WhichVersion (ZipKey)); C;
    End;
  If IsInstalled (ConcDos) Then WriteLn (' - Concurrent Dos'); C;
  If IsInstalled (DietOvr) Then WriteLn (' - Diet Overlay'); C;
  If IsInstalled (DosEdcom) Then WriteLn (' - DOSED.COM'); C;
  If IsInstalled (DOS4_G) Then WriteLn (' - DOS/4G'); C;
  If IsInstalled (CuckooCom) Then WriteLn (' - CUCKOO.COM'); C;
  If IsInstalled (CTask) Then WriteLn (' - CTask'); C;
  If IsInstalled (ScreenR) Then
    Begin
      WriteLn (' - ScreenR'); C;
      WriteLn ('   - Version : ', WhichVersion (ScreenR)); C;
    End;
  If IsInstalled (BWLPD) Then WriteLn (' - Beam&Whiteside LPD'); C;
  If IsInstalled (BWCom14) Then WriteLn (' - Beam&WhiteSide Com14'); C;
  If IsInstalled (ScanBoot) Then
    Begin
      WriteLn (' - ScanBoot'); C;
      WriteLn ('   - Version : ', WhichVersion (ScanBoot)); C;
    End;
  If IsInstalled (TelAPI) Then WriteLn (' - TelAPI'); C;
  If IsInstalled (ObjectKernel) Then
    Begin
      WriteLn (' - Object Kernel fÅr Dos'); C;
      P := WhichAddress (ObjectKernel);
      WriteLn ('   - Speicheradresse : ', Hex (PtrRec(P).Seg, 4), 'h:', Hex (PtrRec(P).Ofs, 4), 'h');
    End;
  If IsInstalled (UltraVision) Then
    Begin
      WriteLn (' - UltraVision'); C;
      WriteLn ('   - Version : ', WhichVersion (UltraVision)); C;
    End;
  If IsInstalled (UltraFont) Then
    Begin
      WriteLn (' - UltraFont'); C;
      WriteLn ('   - Version : ', WhichVersion (UltraFont)); C;
    End;
  If IsInstalled (CAMSCSI) Then WriteLn (' - Common Access Method SCSI'); C;
  If IsInstalled (CMCISCSIDrv) Then WriteLn (' - CMC International SCSI Driver'); C;
  If IsInstalled (Stacker) Then
    Begin
      WriteLn (' - Stacker'); C;
      WriteLn ('   - Version : ', WhichVersion (Stacker)); C;
    End;
  If IsPcAnyWhere Then
    Begin
      WriteLn (' - PC Anywhere'); C;
      WriteLn ('   - Status   : ', PcAnywhereStatus); C;
      WriteLn ('   - Port     : ', PcAnywherePort); C;
      WriteLn ('   - Baudrate : ', PcAnywhereBaud); C;
    End;
  If IsDiskSpoolII Then
    Begin
      WriteLn (' - DiskSpool II'); C;
      WriteLn ('   - Segment          :' , DiskSpoolSegment); C;
      WriteLn ('   - Spooler Status   : ', DiskSpoolSpoolSt); C;
      WriteLn ('   - Despooler Status : ', DiskSpoolDeSpSt); C;
    End;
  If IsInstalled (SWBiosC) Then WriteLn (' - SWBios auf C:'); C;
  If IsInstalled (SWBiosD) Then WriteLn (' - SWBios auf D:'); C;
  If IsInstalled (AvatarSys) Then
    Begin
      WriteLn (' - AVATAR-Treiber'); C;
      WriteLn ('   - AVATAR-Level       : ', AvaLevelSupp); C;
      WriteLn ('   - AVATAR-Treiber-Typ : ', AvaDriverType); C;
    End;
  If IsInstalled (Tes) Then
    Begin
      WriteLn (' - Tes'); C;
      WriteLn ('   - Port : ', Hex (TesPort,4)); C;
    End;
  If IsInstalled (SRDisk) Then
    Begin
      WriteLn (' - SRDisk'); C;
      WriteLn ('   - Anzahl unterstÅtzter Drives  : ', SRDiskSuppDrives); C;
      WriteLn ('   - Memory-Typ                   : ', SRDiskMemType); C;
      WriteLn ('   - Version                      : ', SRDiskVersion); C;
      WriteLn ('   - Configuration Format Version : ', SRDiskConfVersion); C;
    End;
  If (IsIBMYaleESIO (0)) Then WriteLn (' - IBM Yale EBIOS Serial I/O auf Port 0');
  If (IsIBMYaleESIO (1)) Then WriteLn (' - IBM Yale EBIOS Serial I/O auf Port 1');
  If (IsIBMYaleESIO (2)) Then WriteLn (' - IBM Yale EBIOS Serial I/O auf Port 2');
  If (IsIBMYaleESIO (3)) Then WriteLn (' - IBM Yale EBIOS Serial I/O auf Port 3');
  If IsInstalled (CompaqAdapt) Then
    Begin
      WriteLn (' - Compaq ADAPT.COM');
      WriteLn ('   - Version : ', WhichVersion (CompaqAdapt));
    End;
  If IsDesqView Then
    Begin
      WriteLn (' - DesqView'); C;
      WriteLn ('   - Version                       : ', DesqViewVersion); C;
      WriteLn ('   - Aktuelle Fensternummer        : ', DesqViewWnNo); C;
      WriteLn ('   - Wahrer Video Modus            : ', DesqViewTrueVid); C;
      WriteLn ('     - Zeilen                      : ', DesqViewWidth); C;
      WriteLn ('     - Spalten                     : ', DesqViewHeight); C;
      WriteLn ('   - Common Memory Frei            : ', DesqViewCoMemAvail); C;
      WriteLn ('   - Common Memory freier Block    : ', DesqViewCoMemLarge); C;
      WriteLn ('   - Common Memory Total           : ', DesqViewCoMemTotal); C;
      WriteLn ('   - Conventional Memory Frei      : ', DesqViewCnMemAvail); C;
      WriteLn ('   - Conventional Memory gr. Block : ', DesqViewCnMemLarge); C;
      WriteLn ('   - Conventional Memory Total     : ', DesqViewCnMemTotal); C;
      WriteLn ('   - Expanded Memory Frei          : ', DesqViewExMemAvail); C;
      WriteLn ('   - Expanded Memory Freier Block  : ', DesqViewExMemLarge); C;
      WriteLn ('   - Expanded Memory Total         : ', DesqViewExMemTotal); C;
    End;

  If IsWindows Then
    Begin
      WriteLn (' - Windows'); C;
      Write   ('   - Mode                  : ');

      Case WindowsMode Of
        dwiNothing            : WriteLn ('Fehler');
        dwi386_2_X            : WriteLn ('WIN/386 2.X');
        dwi3_0_Real_Standard  : WriteLn ('Win 3.0 Real/Standard');
        dwiEnhanced           : WriteLn ('386 erweitert');
      End;
      C;

      If WindowsMode = dwiEnhanced Then
        Begin
          WriteLn ('   - Version               : ', WinEnhVersion); C;
          WriteLn ('   - Virtual Mashine Id    : ', WinEnhVirtMashId); C;
          Write   ('   - OLDAP-Support         : ', Cross(WinEnhOldAp));
          If WinEnhOldAp Then
            WriteLn (', Ver : ', WinEnhOldApVer)
          Else
            WriteLn;
          C;
          WriteLn ('   - Driver-Version        : ', WinEnhDriverVer); C;
          WriteLn ('   - Device-Type           : ', WinEnhDeviceType); C;
          WriteLn ('   - Screen-Grî·e          : ', WinEnhPixelWidth,
                   'x', WinEnhPixelHeight); C;
          WriteLn ('   - Anzahl der Farben     : ', WinEnhColors); C;
          WriteLn ('   - Anzahl der Bits/Pixel : ', WinEnhBits_Pixel); C;
          WriteLn ('   - Anzahl der Bit-Planes : ', WinEnhBit_Planes); C;
          WriteLn ('   - X Aspekt Ratio        : ', WinEnhXASpect); C;
          WriteLn ('   - Y Aspekt Ratio        : ', WinEnhYASpect); C;
          WriteLn ('   - Anzahl der Brushes    : ', WinEnhBrushes); C;
          WriteLn ('   - Anzahl der Pens       : ', WinEnhPens); C;
          WriteLn ('   - Anzahl der Marker     : ', WinEnhMarkers); C;
          WriteLn ('   - Anzahl der Fonts      : ', WinEnhFonts); C;
        End;
    End;
  If IsTBScanX Then
    Begin
      WriteLn (' - Thunderbyte ScanX'); C;
      WriteLn ('  Version : ', TbScanXVersion); C;
      WriteLn ('  Status  : ', TbScanXStatus); C;
    End;
  xPointer := SetverList;
  If Not (PtrRec (xPointer).Seg = 0) Then
    Begin
      WriteLn (' - Setver'); C;
      WriteLn ('   - Setver-Liste bei    : ', Hex (PtrRec(xPointer).Seg, 4),
               ':', Hex (PtrRec(xPointer).Ofs, 4)); C;
      WriteLn ('   - Anzahl der EintrÑge : ', SetverCount); C;
      For Count := 1 To SetverCount - 1 Do
        Begin
          WriteLn ('     - Eintrag Nummer ', Count:3,  ' : ', SetverText (Count)); C;
        End;
    End;
  SoftwareWindowF1;
End;


Procedure SoftwareWindowF1;

Begin
  Case IsSmartDrive Of
    dsmNo              : ;
    dsmDevice          : WriteLn (' - SmartDrive (Device-Typ)');
    dsmIOCTL           : WriteLn (' - SmartDrive (IOCTL-Typ)');
    dsmIOCTLNSupport   : WriteLn (' - SmartDrive ? (kein IOCTL Support)');
    dsmIOCTLReadError  : WriteLn (' - SmartDrive ? (IOCTL Lesefehler)');
  End;
  C;

  If IsSmartDrive = dsmDevice Then
    Begin
      WriteLn ('   - Version          : ', SMDeviceVer); C;
      WriteLn ('   - aktuelle Grî·e   : ', SMDeviceSizeNow, ' kb'); C;
      WriteLn ('   - minimale Grî·e   : ', SMDeviceMinSize, ' kb'); C;
      WriteLn ('   - elementare Grî·e : ', SMDeviceEleSize, ' kb'); C;
      WriteLn ('   - Cache-Erfolge    : ', SMDeviceCacheHits); C;
      WriteLn ('   - Cache-Mi·erfolge : ', SMDeviceCacheMisses); C;

      WriteLn (' …ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕ—ÕÕÕ—ÕÕÕ—ÕÕÕ—ÕÕÕ—ÕÕÕ—ÕÕÕ—ÕÕÕª'); C;
      WriteLn (' ∫ Getestet auf    ∫ A ≥ B ≥ C ≥ D ≥ E ≥ F ≥ G ≥ H ∫'); C;
      WriteLn (' ÃÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕŒÕÕÕÿÕÕÕÿÕÕÕÿÕÕÕÿÕÕÕÿÕÕÕÿÕÕÕÿÕÕÕπ'); C;
      WriteLn (' ∫ Read-Cache ?    ∫ ',CrossES(SMDeviceRCache ('A')),' ≥ ',CrossES(SMDeviceRCache ('B')),' ≥ ',
                CrossES(SMDeviceRCache ('C')),' ≥ '+ CrossES(SMDeviceRCache ('D')),' ≥ ',CrossES(SMDeviceRCache ('E')),
                ' ≥ ',CrossES(SMDeviceRCache ('F')),' ≥ ', CrossES(SMDeviceRCache ('G')),' ≥ '+
                CrossES(SMDeviceRCache ('H')),' ∫'); C;
      WriteLn (' ∫ Write-Cache ?   ∫ ',CrossES(SMDeviceWCache ('A')),' ≥ ',CrossES(SMDeviceWCache ('B')),' ≥ ',
                CrossES(SMDeviceWCache ('C')),' ≥ '+ CrossES(SMDeviceWCache ('D')),' ≥ ',CrossES(SMDeviceWCache ('E')),
                ' ≥ ',CrossES(SMDeviceWCache ('F')),' ≥ ', CrossES(SMDeviceWCache ('G')),' ≥ '+
                CrossES(SMDeviceWCache ('H')),' ∫'); C;
      WriteLn (' ∫ Double-Buffered ∫ ',CrossES(SMDeviceDblBuffer ('A')),' ≥ ',CrossES(SMDeviceDblBuffer ('B')),' ≥ ',
                CrossES(SMDeviceDblBuffer ('C')),' ≥ ', CrossES(SMDeviceDblBuffer ('D')),' ≥ ',
                CrossES(SMDeviceDblBuffer ('E')),' ≥ ',CrossES(SMDeviceDblBuffer ('F')),' ≥ ',
                CrossES(SMDeviceDblBuffer ('G')),' ≥ '+CrossES(SMDeviceDblBuffer ('H')),' ∫'); C;
      WriteLn (' »ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕœÕÕÕœÕÕÕœÕÕÕœÕÕÕœÕÕÕœÕÕÕœÕÕÕº'); C;
    End
  Else
    If IsSmartDrive = dsmIOCTL Then
      Begin
        WriteLn ('   - Version                      : ', SMIOCTLVer); C;
        WriteLn ('   - Grî·e                        : ', SMIOCTLSize); C;
        WriteLn ('   - maximale Grî·e               : ', SMIOCTLMaxSize); C;
        WriteLn ('   - minimale Grî·e               : ', SMIOCTLMinSize); C;
        WriteLn ('   - Cache aktiv                  : ', CrossE (SMIOCTLEnabled)); C;
        Write   ('     - Sind gesperrte Tracks vorh : ', CrossE (SMIOCTLLockedTracks)); C;
        If SMIOCTLLockedTracks Then
          WriteLn (', ', SMIOCTLTracksLocked)
        Else
          WriteLn;
        C;
        WriteLn ('   - Write-Through                : ', CrossE (SMIOCTLWriteThrough)); C;
        WriteLn ('   - Write-Buffer                 : ', CrossE (SMIOCTLWriteBuffer)); C;
        WriteLn ('   - Hit-Rate                     : ', SMIOCTLHitRate, '%'); C;
        WriteLn ('   - DMA-Buffering                : ', SMIOCTLDMABuffering); C;
        WriteLn ('   - Memory-Typ                   : ', SMIOCTLMemoryType); C;
        WriteLn ('   - ZurÅckschreiben bei ReBoot   : ', Cross (SMIOCTLFlushReBoot)); C;
        WriteLn ('   - Tracks insgesamt             : ', SMIOCTLTracksTotal); C;
        WriteLn ('     - benutzt                    : ', SMIOCTLTracksUsed); C;
        WriteLn ('     - unbrauchbar                : ', SMIOCTLTracksDirty); C;
      End;
  If IsIBMCache Then
    Begin
      WriteLn (' - IBMCache');
      WriteLn ('   - Version                     : ', IBMCVersion); C;
      WriteLn ('   - Wird Ext. Mem benutzt       : ', Cross(IBMCIsExtUsed)); C;
      WriteLn ('   - Grî·e in KB                 : ', IBMCSize, ' kb'); C;
      WriteLn ('   - Sektoren pro Seite          : ', IBMCSectorsPage); C;
      WriteLn ('   - Total Read Requests (A,B)   : ', IBMCTotalRRequests ('A'):10,' ',
                                                   IBMCTotalRRequests ('B'):10); C;
      WriteLn ('   - Total Read Requests (C,D)   : ', IBMCTotalRRequests ('C'):10,' ',
                                                   IBMCTotalRRequests ('D'):10); C;
      WriteLn ('   - Total Hits (A,B)            : ', IBMCTotalHits ('A'):10,' ',
                                                   IBMCTotalHits ('B'):10); C;
      WriteLn ('   - Total Hits (C,D)            : ', IBMCTotalHits ('C'):10,' ',
                                                   IBMCTotalHits ('D'):10); C;
      WriteLn ('   - Physical Disk Reads (A,B)   : ', IBMCPhysicalDReads ('A'):10,' ',
                                                   IBMCPhysicalDReads ('B'):10); C;
      WriteLn ('   - Physical Disk Reads (C,D)   : ', IBMCPhysicalDReads ('C'):10,' ',
                                                   IBMCPhysicalDReads ('D'):10); C;
      WriteLn ('   - Disk Sectors requested (A,B): ', IBMCTotalSecReqDR ('A'):10,' ',
                                                   IBMCTotalSecReqDR ('B'):10); C;
      WriteLn ('   - Disk Sectors requested (C,D): ', IBMCTotalSecReqDR ('C'):10,' ',
                                                   IBMCTotalSecReqDR ('D'):10); C;
    End;
  If IsInstalled (NWCDEX) Then WriteLn (' - NW CD Extensions (NWCDEX)'); C;
  If IsInstalled (DoubleSpace) Then WriteLn (' - DoubleSpace'); C;
  If IsInstalled (SuperstorPro) Then WriteLn (' - SuperStor Pro'); C;
  If IsInstalled (K5) Then WriteLn (' - Tastaturtreiber K5'); C;
  If IsInstalled (SoftwCarous) Then WriteLn (' - Taskswitcher Software Carousel'); C;
  If IsInstalled (FastFlip) Then WriteLn (' - Taskswitcher FastFlip'); C;
End;

Procedure SoftwareWindow1;

Begin
  Rahmen (22,4,79,25,' EMS-Treiber Informationen ');
  Window (23,5,77,24);

  WriteLn ('Ist 386Max aktiv           : ', Cross (Is386Max));
  If Is386Max Then
    Begin
      WriteLn ('386 Max Version            : ', _386MaxVersion);
      WriteLn ('386 Max Segment            : ', Hex(_386MaxSegment,4));
      WriteLn ('386 Max ist EMS aktiv      : ', Cross(_386MaxEMSactive));
      WriteLn ('386 Max Win 3 Support      : ', Cross(_386MaxWin3Supp));
    End;

 WriteLn ('MICEMM                     : ', Cross (IsMICEMM));
 If IsMICEMM Then
   Begin
     WriteLn ('MICEMM Code Segment        : ', Hex (MICEMMCS,4));
   End;


 WriteLn ('Ist Emm386 aktiv           : ', Cross (IsEmm386));
 If IsEmm386 Then
   Begin
     xPointer := Emm386Api;
     WriteLn ('  EMM386 API               : ', Hex (PtrRec(xPointer).Seg, 4),
              ':', Hex (PtrRec(xPointer).Ofs, 4));
     WriteLn ('  EMM386 Status            : ', Emm386Status);
     WriteLn ('  EMM386 Weitek Status     : ', Emm386Weitek);
   End;

 WriteLn ('Ist QEMM aktiv             : ', Cross (IsQEMM));
 If IsQEMM Then
   Begin
     WriteLn ('Weitere Informationen kînnen Åber die beiden QEMM-');
     WriteLn ('Fenster abgerufen werden)');
   End;
End;


Procedure SoftwareWindow2;

Begin
   Rahmen (22,4,79,25,' Software Informationen - QEMM ');
   Window (23,5,77,23);

   Write ('Ist QEMM aktiv  : ', Cross (IsQEMM));
   If IsQEMM Then
     Begin
       xPointer := QEMMApi;
       WriteLn (', API : ', Hex (PtrRec(xPointer).Seg, 4),
              ':', Hex (PtrRec(xPointer).Ofs, 4));
       WriteLn ('  Version                  : ', QEMMVersion, ', ', QEMMStatus);
       Write ('  Wird HiRam unterst.      : ', Cross(QEMMIsHiRam));
       If QemmIsHiram Then
         WriteLn (', ', Hex (QEMMHiRamMCB, 4))
       Else
         WriteLn;

       Write ('  Stealth-Status           : ', QEMMStealthStatus);
       If (QEMMStealthStatus = 'Frame') Or (QEMMStealthStatus = 'Map') Then
         WriteLn (', ', QEMMStealthRom,' Rom''s')
       Else
         WriteLn;

       WriteLn ('  Ist Manifest installiert : ', Cross (IsQManifest));
       Write ('  Ist VidRam installiert   : ', Cross (IsQVidRam));
       If IsQVidRam Then
         WriteLn (' CS : ', Hex (VidRamCS,4))
       Else
         WriteLn;

       WriteLn ('Initial Settings');
       WriteLn ('Conv      Extended  Expanded  Extra     Total    ');
       WriteLn ((QEMMInitConv DIV 1024) : 5,'k    ', (QEMMInitExt DIV 1024) : 5,'k    ',
                 (QEMMInitExp DIV 1024) : 5,'k    ',(QEMMInitExtra DIV 1024) : 5,'k    ',
                 (QEMMInitTotal DIV 1024) : 5,'k    ');

       WriteLn ('Current Settings');
       WriteLn ('Conv      Extended  EMS/XMS   HiRam     Mapped   ');
       WriteLn ((QEMMCurrConv DIV 1024) : 5,'k    ', (QEMMCurrExt DIV 1024) : 5,'k    ',
                 (QEMMCurrEMSXMS DIV 1024) : 5,'k    ',(QEMMCurrHiRam DIV 1024) : 5,'k    ',
                 (QEMMCurrMapped DIV 1024) : 5,'k    ');
       WriteLn ('DMABuffer DMA Tasks DMA Map   Code      Data     ');
       WriteLn ((QEMMCurrDMAB DIV 1024) : 5,'k    ', (QEMMCurrDMATasks DIV 1024) : 5,'k    ',
                 (QEMMCurrDMAMap DIV 1024) : 5,'k    ',(QEMMCurrCode DIV 1024) : 5,'k    ',
                 (QEMMCurrData DIV 1024) : 5,'k    ');
       WriteLn ('Current Settings Total : ', QEMMCurrTotal , 'b');

       WriteLn ('Unavaiable Settings');
       WriteLn ('Conv      Extended  Expanded  Shadow/Top         ');
       WriteLn ((QEMMUnAvailConv DIV 1024) : 5,'k    ', (QEMMUnAvailExt DIV 1024) : 5,'k    ',
                (QEMMUnAvailExp DIV 1024) : 5,'k    ', (QEMMUnAvailShdwTop DIV 1024) : 5,'k    ');

     End
   Else
     WriteLn;
End;


Procedure SoftwareWindow3;

Begin
  Window (1,1,80,25);
  Rahmen (1,1,80,25, ' QEMM Page Informationen - Gro·es Fenster ');
  Window (2,2,76,23);
  ClrScr;
  If IsQEMM Then
    Begin
      For Count := 0 to $0F do
        Begin
          GotoXY(1, 17 - Count);
          Write (Hex (Count, 1), 'x00');
        End;
      GotoXY(1, 18);
      Writeln('      0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F');
      Writeln ('m=mappable RAM, M=Mapped ROM, H=High RAM, X=eXcluded, V=Video, R=ROM');
      Writeln ('A=Adapter ROM, s=split ROM, F=EMS Page Frame, r=RAMmable, C=Conventional');
      WriteLn ('-=nicht benutzt, +=gelesen, *=geschrieben, !=Gel./Geschr., S=Stealth ROM');
      For Count := 0 To 255 Do
        Begin
          xString := '';
          xString := xString + QEMMMemType (Count);
          xString := xString + QEMMAccess  (Count);
          xString := xString + QEMMStealth (Count);
          GotoXY (5 + (4 * (Count mod 16) + 1), 16 - (Count Div 16) + 1);
          Write (xString);
        End;
    End
  Else
    WriteLn ('QEMM nicht vorhanden');

  GotoXY (1,22);
  Waitkey;
  Window (1,1,80,25);
  ClrScr;
  CursorOff;
  Rahmen (1,1,79,4,'');
  GotoXY (2,2);
  WriteLn (Title);
  Rahmen (1,4,21,19,' MenÅ ');
  Copyright (1,19);
  SoftWareWindow2;
End;


Procedure NetWorkWindow;

Begin
 Rahmen (22,4,79,25,' Informationen Åber Netzwerk, DFö, Fossil ');
 Window (23,5,77,23);

 WriteLn ('Ist ein Netzerk aktiv                    : ', Cross (IsNetWork));
 If IsNetWork Then
    Begin
      WriteLn ('  Aufgabe dieses Rechners  : ', NetType);
    End;

 WriteLn ('Ist der PC-TCP Packet Driver installiert : ', Cross (IsPC_TCP));
 If IsPC_TCP Then
   WriteLn ('  Interrupt                              : ', PC_TCP_Interrupt);

 WriteLn ('Ist ein Fossil-Treiber installiert       : ', Cross (IsFossil));
 If IsFossil Then
   Begin
     WriteLn ('  Typ                                    : ', FossilType);
     WriteLn ('  Revision                               : ', FossilRevision);
     WriteLn ('  ID-String                              : ', FossilIdString);
     WriteLn ('  Spezifikationsniveau                   : ', FossilSpecLevel);
   End;

 WriteLn ('Ist ein Video-Fossil-Treiber installiert : ', Cross (IsVidFossil));
 If IsVidFossil Then
   Begin
     WriteLn ('  Version                                : ', VidFossilVer);
     WriteLn ('  Revision                               : ', VidFossilRev);
     WriteLn ('  Hîchste Funktion                       : ', VidFossilHfn);
   End;
End;


Procedure GrafikWindow;

Begin
  Rahmen (22,4,79,25,' Grafikkarten Informationen ');
  Window (23,5,77,24);

  WriteLn ('Grafikarte : ');
  Window (1,1,80,25);
  Window (36,5,77,8);
  WriteLn (WhatGCard);
  Window (23,5,77,23);
  GotoXY (1,5);

  WriteLn ('Grî·e des VideoBuffers  : ', pBios^.ScreenBufSize);
  WriteLn ('DisplayPort             : ', Hex (pBios^.CRTBase,3),'h');
  WriteLn ('Crt Mode Register       : ', Hex (pBios^.CrtMode,2),'h');
  WriteLn ('Anzahl der Zeilen       : ', pBios^.Rows);
  WriteLn ('Anzahl der Spalten      : ', pBios^.Columns);
  WriteLn ('Aktuelle Videopage      : ', pBios^.ScreenPage);
  WriteLn ('Scanlines / Zeichen     : ', ScanLinesChar);
  WriteLn ('ScanLines / Cursor      : ', ScanLinesCursor);
  WriteLn ('Video-RAM Waitstates    : ', T.VideoWaits);
  WriteLn ('BIOS-ScreenWrite (cps)  : ', T.BiosSpeed:0:0);
  WriteLn ('DOS-ScreenWrite (cps)   : ', T.DosSpeed:0:0);
  WriteLn ('Spezieller RAMDAC       : ', WhatRamDac);
  WriteLn ('Direct Graphics Interface             : ', Cross (IsDGIS));

  WriteLn;
  WaitKey;
  ClrScr;

  WriteLn ('…ÕÕÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª');
  WriteLn ('∫ Name         ≥ Adresse     ∫');
  WriteLn ('«ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒ∂');
  xPointer := GetFontAddress (1);
  WriteLn ('∫ INT 1Fh      ≥ ', Hex (PtrRec(xPointer).Seg,4),'h:', Hex (PtrRec(xPointer).Ofs,4), 'h ∫');
  xPointer := GetFontAddress (2);
  WriteLn ('∫ INT 43h      ≥ ', Hex (PtrRec(xPointer).Seg,4),'h:', Hex (PtrRec(xPointer).Ofs,4), 'h ∫');
  xPointer := GetFontAddress (3);
  WriteLn ('∫ ROM 8x14     ≥ ', Hex (PtrRec(xPointer).Seg,4),'h:', Hex (PtrRec(xPointer).Ofs,4), 'h ∫');
  xPointer := GetFontAddress (4);
  WriteLn ('∫ ROM 8x8 (lo) ≥ ', Hex (PtrRec(xPointer).Seg,4),'h:', Hex (PtrRec(xPointer).Ofs,4), 'h ∫');
  xPointer := GetFontAddress (5);
  WriteLn ('∫ ROM 8x8 (hi) ≥ ', Hex (PtrRec(xPointer).Seg,4),'h:', Hex (PtrRec(xPointer).Ofs,4), 'h ∫');
  xPointer := GetFontAddress (6);
  WriteLn ('∫ ROM 9x14     ≥ ', Hex (PtrRec(xPointer).Seg,4),'h:', Hex (PtrRec(xPointer).Ofs,4), 'h ∫');
  xPointer := GetFontAddress (7);
  WriteLn ('∫ ROM 9x16     ≥ ', Hex (PtrRec(xPointer).Seg,4),'h:', Hex (PtrRec(xPointer).Ofs,4), 'h ∫');
  WriteLn ('»ÕÕÕÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕº');
  WriteLn;
  WriteLn ('16 Farben DAC Register : ', Hex (GetPaletteRegister (0),2), ', ', Hex (GetPaletteRegister (1),2), ', ', Hex
    (GetPaletteRegister (2),2), ', ',  Hex (GetPaletteRegister (3),2), ', ', Hex (GetPaletteRegister (4),2), ', ',  Hex
    (GetPaletteRegister (5),2),  ', ');
  WriteLn ('                         ', Hex (GetPaletteRegister (6),2),  ', ', Hex (GetPaletteRegister (7),2), ', ',
    Hex (GetPaletteRegister (8),2), ', ', Hex (GetPaletteRegister (9),2), ', ', Hex (GetPaletteRegister (10),2),', ',
    Hex (GetPaletteRegister (11),2), ', ');
  WriteLn ('                         ', Hex (GetPaletteRegister (12),2), ', ',
    Hex (GetPaletteRegister (13),2), ', ', Hex (GetPaletteRegister (14),2), ', ', Hex (GetPaletteRegister (15),2));
  WriteLn;
  WriteLn ('Berechne Vertikale Zeilenfrequenz ...');
  GotoXY (WhereX, WhereY-1);
  WriteLn ('Vertikale Zeilenfrequenz im Modus 3   : ', TestVertHz, ' hz');
  WriteLn ('Berechne Horizontale Zeilenfrequenz ...');
  GotoXY (WhereX, WhereY-1);
  WriteLn ('Horizontale Zeilenfrequenz im Modus 3 : ', TestHorizHz:3:2, ' Khz');
End;


Procedure GrafikWindow2;

Var LineCount : Byte;

  Procedure TestLines;

  Begin
    If LineCount > 15 Then
      Begin
        WriteLn;
        WaitKey;
        Clrscr;
        LineCount := 0;
      End;
  End;

Begin
  LineCount := 0;
  Rahmen (22,4,79,25,' Grafikkarten - Spezielle Informationen ');
  Window (23,5,77,23);
  If WhatGCardNumber = 7 Then
    Begin
      WriteLn ('PC 3270 : X-Aspekt Radius   : ', GraInf (73));
      WriteLn ('PC 3270 : Y-Aspekt Radius   : ', GraInf (74));
      WriteLn ('PC 3270 : Monitor Typ       : ', GraInf (75));
      WriteLn ('PC 3270 : Adapter Id        : ', GraInf (76));
      WriteLn ('PC 3270 : UnterstÅtzte Modi : ', GraInf (77));

      WriteLn ('0 = nichts; 1 = 720*350 8 Farben; 2 = 360*350 4 Farben');
      WriteLn ('3 = 720*350 2 Farben; 4 = CGA-Farbgrafik; 5 = Farbiger Text,');
      WriteLn ('4 Seiten; 6 = Farbiger Text, 1 Seite; 7 = Mono Text, 1 Seite');

      WriteLn ('PC 3270 : GPI Grafik        : ', GraInf (78));
      WriteLn ('PC 3270 : Kontrollprogramm Version : ', GraInf (79));
      WriteLn ('PC 3270 : Kontrollprogramm ID      : ', GraInf (80));
    End;

  If (WhatGCardNumber = 3) Or (WhatGCardNumber >= 8) Then
    Begin
      WriteLn ('EGA : Buffersicherung bei Modewechsel : ', GraInf (2));
      WriteLn ('EGA : aktiv                           : ', GraInf (3));
      WriteLn ('EGA : Wartet auf Bildschirmzugriff    : ', GraInf (4));
      WriteLn ('EGA : CGA Cursor Emulation            : ', GraInf (5));
      WriteLn ('EGA : Save Area                       : ', GraInf (6));
      WriteLn ('EGA : Video Parameter Table           : ', GraInf (7));
      WriteLn ('EGA : Dynamic Save Area               : ', GraInf (8));
      WriteLn ('EGA : Auxiliary character generator   : ', GraInf (9));
      WriteLn ('EGA : Graphics mode auxiliary table   : ', GraInf (10));
      LineCount := LineCount + 9;
    End;

  If WhatGCardNumber >= 8 Then
    Begin
      WriteLn ('VGA : Color Page  : ', GraInf (43));
      WriteLn ('VGA : Paging Mode : ', GraInf (44));
      LineCount := LineCount + 2;
    End;

  If ((WhatGCardNumber = 2 ) Or (WhatGCardNumber >= 8)) And (Length (GraInf(45)) > 3) Then
    Begin
      WriteLn ('VGA/MCGA : Video Mode                  : ', GraInf (45));
      WriteLn ('VGA/MCGA : LÑnge/Regenerate Buffer     : ', GraInf (46));
      WriteLn ('VGA/MCGA : StartAdr./Regenerate Buffer : ', GraInf (47));
      WriteLn ('VGA/MCGA : Cursor Position auf Seite 0 : ', GraInf (48));
      WriteLn ('VGA/MCGA : Cursor Position auf Seite 1 : ', GraInf (49));

      LineCount := LineCount + 5;
      TestLines;

      WriteLn ('VGA/MCGA : Cursor Position auf Seite 2 : ', GraInf (50));
      WriteLn ('VGA/MCGA : Cursor Position auf Seite 3 : ', GraInf (51));
      WriteLn ('VGA/MCGA : Cursor Position auf Seite 4 : ', GraInf (52));
      WriteLn ('VGA/MCGA : Cursor Position auf Seite 5 : ', GraInf (53));
      WriteLn ('VGA/MCGA : Cursor Position auf Seite 6 : ', GraInf (54));
      WriteLn ('VGA/MCGA : Cursor Position auf Seite 7 : ', GraInf (55));
      WriteLn ('VGA/MCGA : Cursor Typ                  : ', GraInf (56));
      WriteLn ('VGA/MCGA : Aktive Bildschirmseite      : ', GraInf (57));
      WriteLn ('VGA/MCGA : Bytes pro Zeichen           : ', GraInf (58));

      LineCount := LineCount + 9;
      TestLines;

      WriteLn ('VGA/MCGA : Kombinationscode            : ', GraInf (59));
      WriteLn ('VGA/MCGA : Aktuelle Anzahl der Farben  : ', GraInf (60));
      WriteLn ('VGA/MCGA : Aktuelle Anzahl der Seiten  : ', GraInf (61));
      WriteLn ('VGA/MCGA : Akt. Anzahl der Scanlines   : ', GraInf (62));
      WriteLn ('VGA/MCGA : Laden der Palette abgesch.  : ', GraInf (63));
      WriteLn ('VGA/MCGA : Cursor Emulation eingesch.  : ', GraInf (64));
      WriteLn ('VGA/MCGA : Plasma-Display aktiv        : ', GraInf (65));
      WriteLn ('VGA/MCGA : Modi 0-13h  : ', GraInf (66));
      WriteLn ('VGA/MCGA : Char-Font-Loading-Function  : ', GraInf (67));
      WriteLn ('VGA/MCGA : Absch. d. Ladens der Pal.   : ', GraInf (68));
      WriteLn ('VGA/MCGA : Cursor-Emulation-Funktion   : ', GraInf (69));
      WriteLn ('VGA/MCGA : Color-Paging-Function       : ', GraInf (70));
      WriteLn ('VGA/MCGA : Light-Pen unterstÅtzt       : ', GraInf (71));
      WriteLn ('VGA/MCGA : 512 Char Set unterstÅtzt    : ', GraInf (72));
      LineCount := 16;
      TestLines;
    End
  Else
    Begin
      WriteLn ('VGA : Der State Buffer vom PS/1/2 ist nicht vorhanden');
      Linecount := LineCount + 1;
    End;

  Case WhatGCardNumber Of
   { Video 7 }
   9  : Begin
          WriteLn ('VIDEO 7 : Memory                : ', GraInf (11));
          WriteLn ('VIDEO 7 : Input/Output 8/16 Bit : ', GraInf (12));
          WriteLn ('VIDEO 7 : BIOS 8/16 Bit         : ', GraInf (13));
          WriteLn ('VIDEO 7 : Fast Write 8/16 Bit   : ', GraInf (14));
          WriteLn ('VIDEO 7 : Clock Select          : ', GraInf (102));
          Inc(LineCount, 5);
          TestLines;
          WriteLn ('VIDEO 7 : Clock Source          : ', GraInf (103));
          Inc(LineCount);
        End;
   { Genoa ???? }
   10..11 :
        Begin
          WriteLn ('GENOA : BUS                       : ', GraInf (15));
          WriteLn ('GENOA : Video-Bandbreite          : ', GraInf (16));
          WriteLn ('GENOA : BIOS 8/16 Bit             : ', GraInf (17));
          WriteLn ('GENOA : Input/Output Grundadresse : ', GraInf (18));
          WriteLn ('GENOA : BIOS Grî·e (24K/30K/32K)  : ', GraInf (19));
          Inc (LineCount, 5);
          TestLines;
          WriteLn ('GENOA : Monitor Typ               : ', GraInf (20));
          WriteLn ('GENOA : Chipset auf               : ', GraInf (21));
          WriteLn ('GENOA : Fast Scroll               : ', GraInf (22));
          WriteLn ('GENOA : Fast Address              : ', GraInf (23));
          WriteLn ('GENOA : Fast Write                : ', GraInf (24));
          WriteLn ('GENOA : 70 Hertz Vertikaler Retr. : ', GraInf (25));
          WriteLn ('GENOA : Interlaced                : ', GraInf (26));
          Inc (LineCount, 7);
        End;
   12 : Begin
          WriteLn ('CIRRUS : Ist ein Cirrus BIOS inst. : ', GraInf (94));
          Inc (LineCount);
          If GraInf (94) = '[X]' Then
            Begin
              WriteLn ('CIRRUS BIOS : Version      : ', GraInf (95));
              WriteLn ('CIRRUS BIOS : Video Memory : ', GraInf (96));
              WriteLn ('CIRRUS BIOS : Monitor Typ  : ', GraInf (97));
              Inc (LineCount,3)
            End;
        End;
   15..16 :
        Begin
          WriteLn ('TRIDENT 8900 : BIOS 8/16 Bit  : ', GraInf (27));
          WriteLn ('TRIDENT 8900 : Interlaced     : ', GraInf (28));
          Inc (LineCount,2);
          If WhatGCardNumber = 16 Then
            Begin
              WriteLn ('EVEREX : BIOS Version         : ', GraInf (99));
            End;
        End;
   17..18 :
        Begin
          WriteLn ('TSENG ET 3/4000 : ROM 8/16 Bit   : ', GraInf (29));
          WriteLn ('TSENG ET 3/4000 : Video 8/16 Bit : ', GraInf (30));
          WriteLn ('TSENG ET 3/4000 : I/O 8/16 Bit   : ', GraInf (31));
          WriteLn ('TSENG ET 3/4000 : KompatiblitÑt  : ', GraInf (32));
          WriteLn ('TSENG ET 3/4000 : ROM Adresse    : ', GraInf (33));
          Inc (LineCount, 5);
        End;
   20..21, 26 :
        Begin
          WriteLn ('ATI : Mausport                     : ', GraInf (34));
          WriteLn ('ATI : Programmierbarer Video-Timer : ', GraInf (35));
          WriteLn ('ATI : Monitor                      : ', GraInf (36));

          If (WhatGCardNumber = 21) Or (WhatGCardNumber = 26) Then
            Begin
              WriteLn ('ATI 18800+ : 70 Hertz non Interlaced  : ', GraInf (37));
              WriteLn ('ATI 18800+ : Koreanischer Zeichensatz : ', GraInf (38));
              LineCount := LineCount+5;
              TestLines;
              WriteLn ('ATI 18800+ : Memory-Timer             : ', GraInf (39));
              WriteLn ('ATI 18800+ : Zero Wait State          : ', GraInf (40));
              WriteLn ('ATI 18800+ : Paged ROM''S              : ', GraInf (41));
              WriteLn ('ATI 18800+ : 8514A Support            : ', GraInf (42));
              If WhatGCardNumber = 26 Then
                Begin
                  WriteLn ('ATI 28800+ : True-Color DAC           : ', GraInf (91));
                End;
            End;
        End;
   23..24 :
        Begin
          WriteLn ('S3 : Diamond Stealth DAC   : ', GraInf (81));
          WriteLn ('S3 : MEMC16 8- oder 16-Bit : ', GraInf (82));
          WriteLn ('S3 : Fast Write Buffer     : ', GraInf (83));
          WriteLn ('S3 : Zero Waitstate        : ', GraInf (84));
        End;
   25 : Begin
          WriteLn ('AHEAD : 8-Fonts Modus        : ', GraInf (85));
          WriteLn ('AHEAD : High Speed Sequencer : ', GraInf (86));
          WriteLn ('AHEAD : 16-Bit Memory-Mode   : ', GraInf (87));
          WriteLn ('AHEAD : Emulationsmodus      : ', GraInf (88));
          WriteLn ('AHEAD : 24/32 kb BIOS        : ', GraInf (89));
          WriteLn ('AHEAD : 8/16-Bit BIOS        : ', GraInf (90));
        End;
   27 : Begin
          WriteLn ('Avance Logic AL2101 : max. Horizontalfrequenz : ', GraInf (92));
          WriteLn ('Avance Logic AL2101 : Emulationsmodus fÅr     : ', GraInf (93));
        End;
   28 : Begin
          WriteLn ('Compaq : Monitortyp : ', GraInf (98));
        End;
   34 : Begin
          WriteLn ('Realtek : Emulationsmodus : ', GraInf (100));
        End;
   37 : Begin
          WriteLn ('YAMAHA : Clock Select          : ', GraInf (101));
        End;
  Else
    WriteLn;
  End;
End;


Procedure GrafikWindow3;

Var LineCount : Byte;

  Procedure TestLines;

  Begin
    If LineCount > 15 Then
      Begin
        WaitKey;
        Clrscr;
        LineCount := 0;
      End;
  End;

Begin
  LineCount := 0;
  Rahmen (22,4,79,25,' Grafikkarten - VESA ');
  Window (23,5,77,23);

  If (VesaInf (1) = 'ja') Then
    Begin
      WriteLn ('Version       : ', VesaInf (2));
      WriteLn ('OEM-Id        : ', VesaInf (3));
      WriteLn ('Video-Modes   : ');
      LineCount := 5;
      For xWord4 := $0100 To $0400 Do
        If VESAIsVidMode (xWord4) Then
          Begin
            WriteLn (Hex (xWord4, 4), 'h : ', VESAVidModeString(xWord4,46));
            WriteLn;
            Inc (LineCount, 4);
            TestLines;
          End;
    End
  Else
    WriteLn ('Die Grafikkarte hat kein VESA-Bios.');
End;


Procedure MouseWindow;

Begin
  Rahmen (22,4,79,25,' Maus Informationen ');
  Window (23,5,77,23);

  WriteLn ('Steht eine Maus zur VerfÅgung : ', Cross(IsMouse));
  If IsMouse Then
    Begin
      WriteLn ('  Maustreiberversion          : ', MouseVersion);
      WriteLn ('  Maustreiber-Hersteller      : ', MouseVendor);
      WriteLn ('  Maustyp                     : ', MouseType,'/IRQ #', MouseIRQ);
      WriteLn ('  Maussprache                 : ', MouseLanguage);
      WriteLn ('  Anzahl der Mausbuttons      : ', MouseButtons);
      WriteLn ('  Geschwindigkeit/D.K.        : ', DoubleClickSpeed);
      WriteLn ('  Mickeys/Pixel X/Y           : ', MouseMickeysVert, '/',MouseMickeysHori);
      WriteLn ('  Maus-Display-Page           : ', MouseDisplayPage);
      Write ('  EGA-Registerunterst.        : ', Cross(EgaRegisterSupp));
      If EGARegisterSupp Then
       WriteLn (' (Ver ',EgaRegisterVers,')') Else WriteLn;
      WriteLn ('  Grî·e/SaveStateBuffer       : ', SaveStateBuffer);
      If Hi (MouseVersionWord) >= 7 Then
        Begin
          WriteLn ('Maustreibertyp                : ', MouseDriverType);
          WriteLn ('Mauscursortyp                 : ', MouseCursorType);
          WriteLn ('Maus Interrupt Rate           : ', MouseIntrRate);

          WriteLn;
          WaitKey;
          ClrScr;

          WriteLn ('Maus Accelleration Profil     : ', MouseAccellProf);

          If (Lo (MouseVersionWord) >= 4) Or (Hi (MouseVersionWord) > 7) Then
            Begin
              WriteLn ('Maus Ballpoint                : ', Cross(MouseBallpoint));
              If Hi (MouseVersionWord) > 7 Then
                Begin
                  WriteLn ('Maus.INI Pfad                 : ', MouseIniPath);
                  If (Lo (MouseVersionWord) >= $10) Or (Hi (MouseVersionWord) > 8) Then
                    Begin
                      WriteLn ('Mauszeigergestalt             : ', MousePointerStyle);
                      WriteLn ('Mauszeiger Grî·enordnung      : ', MousePointerSize);
                      WriteLn ('Mauszeiger Grî·enverÑnderung  : ', Cross (MousePointerSChange));
                    End;
                End;
            End;
        End;

      If IsMouseSystemsDrv Then
        WriteLn (' MousSystems-Drv Version      : ', MouseSystemsVer);
      If IsLogitechDrv Then
        Begin
          WriteLn ('  Logitech-Drv Kompa·paramet. : ', LogiCompPara);
          If LogiSerBaudRate > 0 Then
            Begin
              WriteLn ('  Logitech-Drv Baud/Reprate   : ', LogiSerBaudrate,'/',LogiSerReportRate);
              WriteLn ('  Logitech-Drv Firmware-Rev   : ', LogiSerFirmRev);
              WriteLn ('  Logitech-Drv Port           : ', Hex(LogiSerPort,4),'h');
            End;
        End;
      If IsZNIXMouseDrv Then WriteLn (' ZNIX-Maustreiber             : [X]');
      If IsTrueDOXMouseDrv Then WriteLn (' TrueDox-Maustreiber          : [X]');
      If IsHPMouseDrv Then WriteLn (' HP-Maustreiber               : [X]');
    End;
End;


Procedure BiosWindow;

Begin
  Rahmen (22,4,79,25,' BIOS Informationen ');
  Window (23,5,77,24);

  WriteLn ('Bios-Datum           : ', Biosdate);
  WriteLn ('Bios-Version         : ', BiosVersion);
  WriteLn ('Bios-Revisionslevel  : ', BiosRevision);

  WriteLn ('Bios-Source          : ');
  Window (1,1,80,25);
  Window (46,8,77,12);
  WriteLn(TrimString(BiosSource));
  Window (23,5,77,23);
  GotoXY (1,8);

  WriteLn ('Hersteller           : ', BiosShort);
  WriteLn;
  WriteLn ('Serielle Schnittstellen                  : ' ,SerialCount);
  WriteLn ('Parralele Schnitstellen                  : ' ,ParrallelCount);
  WriteLn ('Hat CMOS noch Energie                    : ' ,Cross(HasCMOSPower));
  WriteLn ('Ist CMOS eingebaut                       : ' ,Cross(IsRealClock));
  WriteLn ('Wird DMA Channel 3 benutzt               : ' ,Cross(IsDMAChannel3));
  WriteLn ('Ist Slave 8259 eingebaut                 : ' ,Cross(IsSlave8259));
End;


Procedure BiosWindow2;

Begin
  Rahmen (22,4,79,25,' BIOS Informationen - Fenster 2 ');
  Window (23,5,77,24);

  Write ('Extended Bios Datensegment   : ');
  If Not (IsExtBiosSeg = 0) Then
    Begin
      WriteLn (Hex(IsExtBiosSeg,4), 'h');
    End
  Else
    WriteLn ('[-]');

  WriteLn ('Wird das Advanced Power Management unterstÅtzt : ', Cross (IsAPM));
  If IsAPM Then
    Begin
      WriteLn ('  Version                    : ', APMVersion);
      WriteLn ('  16-Bit Protected Mode Int. : ', Cross (APMIs16Prot));
      WriteLn ('  32-Bit Protected Mose Int. : ', Cross (APMIs32Prot));
      WriteLn ('  BIOS-Power-Management      : ', Cross (APMIsBIOSPowMngmnt));
      WriteLn ('  AC-Line Status             : ', APMACLineStatus);
      WriteLn ('  Batterie-Status            : ', APMBatteryStatus);
      WriteLn ('  Teil der urspr. Qual.      : ', APMBatteryLife, '%');
    End;

  WriteLn ('JetStream auf LPT1 : ', Cross(IsJetStream (0)));
  WriteLn ('JetStream auf LPT2 : ', Cross(IsJetStream (1)));
  WriteLn ('JetStream auf LPT3 : ', Cross(IsJetStream (2)));
  WriteLn ('JetStream auf LPT4 : ', Cross(IsJetStream (3)));

  WriteLn ('OnBoard-SCSI Adapter : ', Cross (IsOnBoardSCSI));
  WriteLn ('IML-System           : ', Cross (IsIML));
  If IsIML Then
    WriteLn ('IML-SCSI Support     : ', Cross (IsIMLSCSISupp));
End;


Procedure BiosWindow3;

var P : pBiosCopyright;

Begin
  Rahmen (22,4,79,25,' BIOS Extensions ');
  Window (23,5,77,24);

  WriteLn ('Segment Grî·e Copyright-String');
  GetMem (P, SizeOf (P^));
  BiosExtensions (P);
  For xByte := 0 To 94 Do
    Begin
      If P^.BiosInfo[xByte].IsThere Then
        Begin

          WriteLn (Hex(P^.BiosInfo[xByte].Segment, 4), 'h   ',
                   P^.BiosInfo[xByte].Size:3, 'K  ',
                   P^.BiosInfo[xByte].Copyright);
        End;
    End;
  FreeMem (P, SizeOf (P^));
End;


Function TestArgs : Boolean;

Begin
  If ParamCount > 0 Then
    Begin
      If (ParamStr (1) = '/r') Or (ParamStr(1) = '/R') Then
        TestArgs := True Else TestArgs := False;
    End
  Else
    Testargs := False;
End;


Function Testmemory (Size : LongInt) : Boolean;

Begin
  GetMem (xPointer, Size);
  TestMemory := True;
  If xPointer = nil Then TestMemory := False Else FreeMem (xPointer, 20000);
End;


Var Ergebnis   : Byte;
    EndBoolean : Boolean;
    MenuA      : Array [0..35] Of String18;

Begin
  ClrScr;
  If TestMemory (40000) = False Then
    Begin
      WriteLn ('Nicht genug Speicher zum ausfÅhren vom Demo-Programm');
      Halt (1);
    End;

  If IsWindows Then
    Begin
      WriteLn ('Sie haben dieses Programm mit Windows im Hintergrund gestartet.');
      WriteLn ('Die Geschwindigkeitsmessungen (HD, Mhz, Grafikausgabe, ...)');
      WriteLn ('Errechnen hier schlicht und einfach Mist, die eine Funktion');
      WriteLn ('mehr, dia andere weniger. Am Besten startet man dieses Programm');
      WriteLn ('auf einem blanken System (keine Treiber im Speicher), wenn man');
      WriteLn ('Geschwindigkeitstest durchfÅhren mîchte. ');
      WriteLn;
      WriteLn ('Wollen sie das Programm wirklich starten ? (J/N) ');

      xBool := False;
      While xBool = False Do
        Begin
          Case UpCase (ReadKey) Of
            'J' : xBool := True;
            'N' : Begin
                    ClrScr;
                    WriteLn ('EJF''s Detecting Unit fÅr Pascal (ALPHA) ');
                    WriteLn;
                    WriteLn ('Good Bye');
                    Halt (2);
                  End;
          End;
        End;
    End;

  pBios := GetBiosRecord;

  MenuA [0] :=  ' Chip            ';
  MenuA [1] :=  ' Chip (Teil 2)   ';
  MenuA [2] :=  ' CPUId-Befehl    ';
  MenuA [3] :=  ' Bus-Info''s      ';
  MenuA [4] :=  ' Chipsatz        ';
  MenuA [5] :=  ' Keyboard        ';
  MenuA [6] :=  ' Laufwerke       ';
  MenuA [7] :=  ' HD''s            ';
  MenuA [8] :=  ' IDE Daten C:    ';
  MenuA [9] :=  ' IDE Daten D:    ';
  MenuA [10] := ' DOS             ';
  MenuA [11] := ' Environment     ';
  MenuA [12] := ' MCB-Liste       ';
  MenuA [13] := ' Logische GerÑt. ';
  MenuA [14] := ' Mem EMS,XMS,XMM ';
  MenuA [15] := '   CMOS,HMA,DPMI ';
  MenuA [16] := '   VDS, ThruPut  ';
  MenuA [17] := '   EMS Handles   ';
  MenuA [18] := ' Grafikkarten    ';
  MenuA [19] := '   Extra Info''s  ';
  MenuA [20] := '   VESA Info''s   ';
  MenuA [21] := ' Inst. Software  ';
  MenuA [22] := ' EMS-Treiber     ';
  MenuA [23] := ' QEMM            ';
  MenuA [24] := ' QEMM Pages      ';
  MenuA [25] := ' Netzwerk, DFö   ';
  MenuA [26] := ' Maus            ';
  MenuA [27] := ' BIOS            ';
  MenuA [28] := ' BIOS 2          ';
  MenuA [29] := ' BIOS Extensions ';
  MenuA [30] := ' Bios Data-Area  ';
  MenuA [31] := ' Parallelport(s) ';
  MenuA [32] := ' Serielle Ports  ';
  MenuA [33] := ' Soundkarten     ';
  MenuA [34] := ' ClearScreen     ';
  MenuA [35] := ' Ende            ';

  t.VideoWaits := VideoWaits;
  t.BiosSpeed := BiosSpeed;
  t.DosSpeed := DosSpeed;

  ClrScr;
  CursorOff;
  Rahmen (1,1,79,4,'');
  GotoXY (2,2);
  WriteLn (Title);
  Rahmen (1,4,21,19,' MenÅ ');
  Copyright (1,19);

  OldAu := 0;
  Ergebnis := 0;
  EndBoolean := False;
  Repeat
    Ergebnis := Menu (2, 5, 20, 18, 7, 0, Ergebnis, MenuA);
    Case Ergebnis Of
      0  : ChipWindow;
      1  : ChipWindow2;
      2  : ChipWindow3;
      3  : BusWindow;
      4  : ChipsetWindow;
      5  : KeyboardWindow;
      6  : DevicesWindow;
      7  : HDWindow;
      8  : IDEWindow ('C');
      9  : IDEWindow ('D');
      10 : DosWindow;
      11 : EnvironmentWindow;
      12 : MCBWindow;
      13 : DosDevicesWindow;
      14 : MemoryWindow;
      15 : MemoryWindow2;
      16 : MemoryWindow3;
      17 : MemoryWindow4;
      18 : GrafikWindow;
      19 : GrafikWindow2;
      20 : GrafikWindow3;
      21 : SoftwareWindow;
      22 : SoftwareWindow1;
      23 : SoftwareWindow2;
      24 : SoftwareWindow3;
      25 : NetworkWindow;
      26 : MouseWindow;
      27 : BiosWindow;
      28 : BiosWindow2;
      29 : BiosWindow3;
      30 : BiosWindow4;
      31 : ParaWindow;
      32 : SerialWindow;
      33 : SoundWindow;
      34 : Begin
             Window (22,4,79,25);
             ClrScr;
             Window (1,1,80,25);
           End;
      35 : EndBoolean := True;
    End;
  Until EndBoolean;

  TextColor (7);
  TextBackGround (0);
  CursorOn;

  ClrScr;
  WriteLn ('EJF''s Detecting Unit fÅr Pascal ' + UnitVersion);
  WriteLn;
  WriteLn ('Good Bye');
End.