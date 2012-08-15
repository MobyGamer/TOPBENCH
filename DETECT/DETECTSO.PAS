Unit DetectSoftware;

Interface

Function Version4Dos         : String;
Function Shell4Dos           : Byte;
Function PSPSegment4Dos      : Word;

Function VersionNDos         : String;
Function ShellNDos           : Byte;
Function PSPSegmentNDos      : Word;

Function IsDesqView          : Boolean;
Function DesqViewVersion     : String;
Function DesqViewWnNo        : Byte;
Function DesqViewTrueVid     : Byte;
Function DesqViewWidth       : Byte;
Function DesqViewHeight      : Byte;
Function DesqViewCoMemAvail  : Word;
Function DesqViewCoMemLarge  : Word;
Function DesqViewCoMemTotal  : Word;
Function DesqViewCnMemAvail  : Word;
Function DesqViewCnMemLarge  : Word;
Function DesqViewCnMemTotal  : Word;
Function DesqViewExMemAvail  : Word;
Function DesqViewExMemLarge  : Word;
Function DesqViewExMemTotal  : Word;

Function TaskMaxVersion      : Word;
Function TaskMaxMaxTasks     : Word;
Function TaskMaxActTasks     : Word;

Function IsTBScanX           : Boolean;
Function TBScanXVersion      : String;
Function TBScanXStatus       : String;

Function N_CacheStatus       : String;
Function N_DiskReetStatus    : String;
Function N_DiskReetRes       : Word;
Function N_DiskMonStatus     : String;
Function N_DiskMonRes        : Word;
Function N_FileSavRes        : Word;

Function IsPcAnywhere        : Boolean;
Function PcAnywhereStatus    : String;
Function PcAnywherePort      : Byte;
Function PcAnywhereBaud      : Word;

Function IsDiskSpoolII       : Boolean;
Function DiskSpoolSegment    : Word;
Function DiskSpoolSpoolSt    : String;
Function DiskSpoolDeSpSt     : String;

Function IsWindows           : Boolean;
Function WindowsMode         : Byte;
Function WinEnhVersion       : String;
Function WinEnhVirtMashID    : Word;
Function WinEnhOldAp         : Boolean;
Function WinEnhOldApVer      : String;
Function WinEnhDriverVer     : String;
Function WinEnhDeviceType    : String;
Function WinEnhPixelWidth    : Word;
Function WinEnhPixelHeight   : Word;
Function WinEnhColors        : Word;
Function WinEnhBits_Pixel    : Word;
Function WinEnhBit_Planes    : Word;
Function WinEnhXAspect       : Word;
Function WinEnhYAspect       : Word;
Function WinEnhBrushes       : Word;
Function WinEnhPens          : Word;
Function WinEnhMarkers       : Word;
Function WinEnhFonts         : Word;

Function IsSmartDrive        : Byte;
Function SMDeviceVer         : String;
Function SMDeviceSizeNow     : Word;
Function SMDeviceMinSize     : Word;
Function SMDeviceEleSize     : Word;
Function SMDeviceCacheHits   : Word;
Function SMDeviceCacheMisses : Word;

Function SMDeviceRCache (Drive : Char)    : Byte;
Function SMDeviceWCache (Drive : Char)    : Byte;
Function SMDeviceDblBuffer (Drive : Char) : Byte;

Function SMIOCTLVer          : String;
Function SMIOCTLSize         : Word;
Function SMIOCTLMaxSize      : Word;
Function SMIOCTLMinSize      : Word;
Function SMIOCTLEnabled      : Boolean;
Function SMIOCTLLockedTracks : Boolean;
Function SMIOCTLWriteThrough : Boolean;
Function SMIOCTLWriteBuffer  : Boolean;
Function SMIOCTLHitRate      : Word;   { % }
Function SMIOCTLDMABuffering : String;
Function SMIOCTLMemoryType   : String;
Function SMIOCTLFlushReboot  : Boolean;
Function SMIOCTLTracksTotal  : Word;
Function SMIOCTLTracksUsed   : Word;
Function SMIOCTLTracksLocked : Word;
Function SMIOCTLTracksDirty  : Word;

Function IsIbmCache                        : Boolean;
Function IBMCTotalRRequests (Drive : Char) : LongInt;
Function IBMCTotalHits      (Drive : Char) : LongInt;
Function IBMCPhysicalDReads (Drive : Char) : LongInt;
Function IBMCTotalSecReqDR  (Drive : Char) : LongInt;
Function IBMCIsExtUsed                     : Boolean;
Function IBMCVersion                       : String;
Function IBMCSize                          : Word;
Function IBMCSectorsPage                   : Word;

Function IsPC_TCP            : Boolean;
Function PC_TCP_Interrupt    : Byte;

Function IsFossil            : Boolean;
Function FossilType          : String;
Function FossilSpecLevel     : Byte;
Function FossilRevision      : Byte;
Function FossilIDString      : String;

Function IsVidFossil         : Boolean;
Function VidFossilVer        : Word;
Function VidFossilRev        : Word;
Function VidFossilHFn        : Word;

Function IsNetWork           : Boolean;
Function NetType             : String;

Function AppendStatus        : String;
Function AppendPath          : String;

Function SetverList                     : Pointer;
Function SetverCount                    : Word;
Function SetverText (TextNumber : Word) : String;

Function AvaLevelSupp        : Word;
Function AvaDriverType       : String;

Function TesPort             : Word;

Function IsIBMYaleESIO (PortNumber : Word) : Boolean;

Function SRDiskSuppDrives    : Byte;
Function SRDiskMemType       : String;
Function SRDiskVersion       : String;
Function SRDiskConfVersion   : Byte;

Function PCT5DeskHotkey (Key : Byte)     : Word;
Function PCT7DeskColorSheme              : String;
Function PCT6DeskVersion                 : String;
Function PCT5DeskIsResident              : Boolean;
Function PCT6CacheIsDrive (Drive : Char) : Boolean;

Function MDPIsForeGround     : Boolean;
Function MDPIsMultiTasking   : Boolean;

Function IsPCAnyWhereIV   : Boolean;
Function PCAnyWhereIVApi  : Pointer;
Function PCAnyWhereIVVer  : String;
Function PCAnyWhereIVStat : String;

Function IsQuickCacheII                          : Boolean;
Function QuickCacheIIVer                         : String;
Function GetQuickCacheIIInfo (InfoNumber : Byte) : Pointer;

Function EnvSeg  : Word;
Function EnvLen  : Word;
Function EnvUsed : Word;

Type
  pQuickCacheIISystemInfo = ^tQuickCacheIISystemInfo;
  tQuickCacheIISystemInfo = Record
    CacheOn        : Boolean; { Cache aktiv ?                     }
    BufferedWrites : Boolean; { Write-Back Puffer aktiv ?         }
    BufferedReads  : Boolean; { Read-Ahead Puffer aktiv ?         }
    Sounds         : Boolean; { Werden Souns ausgegeben ?         }
    AutoDismount   : Boolean; { Automatisches abmelden aktiv ?    }
    Reserved       : Byte;
    Reserved2      : Boolean;
    Reserved3      : Boolean;
    Em_Assigned    : Boolean; { Ist das 'em_assigned'-Flag ges. ? }
    EMSEmulated    : Boolean; { Ist der EMS-Speicher echt ?       }
    SingleSector   : Byte;    { 'Single Sector Bonus' (?!?)       }
    Sticky_Max     : Byte;    { 'Sticky_Max' (?!?)                }
    WriteSector    : Byte;    { 'Write Sector Bonus' (?!?)        }
    BonusThreshold : Byte;    { 'Bonus Threshold' (?!?)           }
    FlushInterval  : Word;    { Wie oft werden die Daten geflusht }
    FlushCount     : Word;    { Wie oft wurden die Daten geflusht }
    ReservePool    : Word;    { Grî·e des Reserve-Pools ...       }
    ReserveFree    : Word;    { Grî·ter freier Block im Reserve-" }
    ReqFreeMemory  : Word;    { Benîtigter freier Speicherplatz   }
    CacheAll       : Word;    { Cache-Sektoren insgesamt          }
    DirtyCach      : Word;    { 'Dirty'-Cache-Sektoren            }
    TraceBuffer    : Byte;    { Grî·e des Trace-Puffers           }
    Reserved4      : Byte;
  End;

  pQuickCacheIIDriveInfo = ^tQuickCacheIISystemInfo;
  tQuickCacheIIDriveInfo = Record
    DosDriveNumber  : Byte;  { Nummer des Laufwerks von DOS aus ...  }
    BiosDriveNumber : Byte;  { Nummer des Laufwerks vom BIOS aus ... }
    MaxSector       : Byte;  { Hîchste Sektornummer                  }
    MaxHead         : Byte;  { Hîchste Kopfnummer                    }
    ReadBufferSize  : Byte;  { Grî·e des Lesepuffers                 }
    WriteBufferSize : Byte;  { Grî·e des Schreibpuffers              }
    LastStatus      : Byte;  { Status der letzten Operation          }
    Enabled         : Boolean; { Ist der Cache aktiv ?               }
    WriteBuffer     : Boolean; { Ist der Write-Back Modus aktiv ?    }
    ReadBuffer      : Boolean; { Ist der Read-Ahead Modus aktiv ?    }
    InUse           : Boolean; { Dieser Block wird benutzt           }
    CylFlush        : Boolean; { 'Cylinder-Flush'                    }
    Reserved        : Byte;
    SecPerTrack     : Byte;  { Sektoren pro Track                    }
    SectorSize      : Word;  { Grî·e eines Sektors                   }
    SecAssigned     : Word;  { Anzahl assignter Sektoren             }
    SecDirty        : Word;  { Anzahl der Dirty-Sektoren             }
    SecReserved     : Word;  { reservierte Sektoren                  }
    ReadErrors      : Word;  { Anzahl der Lesefehler                 }
    WriteErrors     : Word;  { Anzahl der Schreibfehler              }
    Rio_Count       : LongInt;
    Cache_Misses    : LongInt; { Anzahl der Cache-Misses             }
    Wio_Count       : LongInt;
    Dio_Count       : LongInt;
  End;

Implementation

Uses Dos, DetectGlobal, DetectMemory, DetectMultiplex, DetectConstants;

Type
  tSmartDrv = record
                write_through     : byte;
                write_buffered    : byte;
                cache_enabled     : byte;
                drivertype        : byte;
                cticks            : word;
                locked            : byte;
                reboot_flush      : byte;
                full_track_write  : byte;
                buffering_type    : byte;
                origInt13ofs      : word;
                origInt13seg      : word;
                minorversion      : byte;
                majorversion      : byte;
                reserved          : word;
                secs_read         : word;
                secs_in_cache     : word;
                secs_in_trk_buf   : word;
                cache_hitrate     : byte;
                track_buf_hitrate : byte;
                total_tracks      : word;
                tracks_used       : word;
                locked_tracks     : word;
                dirty_tracks      : word;
                current_size      : word;
                original_size     : word;
                minimum_size      : word;
                lock_pointer_ofs  : word;
                lock_pointer_seg  : word;
              end;

  tFossilBuf = Record
                 FBufsize   : Word;   { Grî·e des Fossil-Puffers }
                 Spec       : Byte;   { Spezifikationsnummer     }
                 Rev        : Byte;   { Revisionsnummer          }
                 IdStrOfs   : Word;   { Id-String Offset         }
                 IdStrSeg   : Word;   { Id-String Segment        }
                 InBufSize  : Word;   { Grî·e des Input-Puffers  }
                 InFree     : Word;   { VerfÅgbarer Platz im "   }
                 OutBufSize : Word;   { Grî·e des Output-Buffers }
                 OutFree    : Word;   { VerfÅgbarer Platz im "   }
                 ScrWidth   : Byte;   { Bildschirmgrî·e in Sp.   }
                 ScrLen     : Byte;   { Bildschirmgrî·e in Zeil. }
                 Baudrate   : Byte;   { Aktuell eingestellte ~   }
                 Extra      : array[1..13] of byte; { Info's ... }
               End;

  tVFossilBuf = Record
                  FBufsize : Word; { Grî·e des VideoFossil-Puffers    }
                  Ver      : Word; { Versionsnummer des Vidoe-Fossils }
                  Rev      : Word; { Revisionsnummer des Video-"      }
                  HiFunc   : Word; { Hîchste unterstÅtzte Funktion    }
                End;

  pIBMCacheBuf = ^tIBMCacheBuf;
  tIBMCacheBuf = Record
                   TotalRRequests : LongInt; { Leseanforderungen insgesamt  }
                   TotalHits      : LongInt; { Treffer insgesamt            }
                   PhysicalDReads : LongInt; { Anzahl physikalischer Lesez. }
                   TotalSecReqDR  : LongInt; { Anzahl der angeford. Sekt.   }
                   Unknown1       : Array [0..5] Of Byte; { Unbekant '(     }
                   StartErrList   : Pointer; { Zeiger auf die Fehlerliste   }
                   EndErrList     : Pointer; { Ende der Fehlerliste         }
                   Unknown2       : Word; { Wieder 2 Bytes unbekannt ...    }
                   IsExtMem       : Byte; { Wird XMS benutzt ?              }
                   Unknown3       : Byte; { Noch ein Byte unbekannt         }
                   Version        : Array [0..3] Of Char; { Versionsstring  }
                   Size           : Word; { Grî·e des Puffer's              }
                   Sectors_Page   : Word; { Sektoren/Seite ...              }
                 End;

  pSrDiskHdr = ^tSRDiskHdr;
  tSRDiskHdr = Record
    NormalHdr     : Array [0..9] Of Byte;
    SuppDrives    : Byte;
    Signature     : Array [0..2] Of Char;
    MemString     : Array [0..3] Of Char;
    Version       : Array [0..3] Of Char;
    Dummy         : Byte;
    ConfVersion   : Byte;
    OffsetDrvConf : Word;
  End;

Const NA = '[-]';

Var Regs : Registers;
    { Die nÑchste Tabelle wird fÅr dei Fossil-Routinen gebraucht           }
    FossilBuf: tFossilBuf;
    { Diese Tabelle wird fÅr die Video-Fossil-Routinen gebraucht           }
    VFossilBuf: tVFossilBuf;
    { Zu guter letzt auch noch eine Tabelle fÅr die Smartdrive-Routinen    }
    SmartDrvBuf: tSmartDrv;


Function Version4Dos;

Begin
  If IsInstalled (_4Dos) Then
    Begin
      Regs.AX := $D44D;
      Regs.BX := 0;
      Regs.CX := 0;
      Regs.DX := 0;
      Intr ($2F, Regs);
      Version4Dos := StrFnByte (Regs.BL) + '.' + StrFnByte(Regs.BH);
    End
  Else
    Version4Dos := NA;
End;


Function Shell4Dos;

Begin
  If IsInstalled (_4Dos) Then
    Begin
      Regs.AX := $D44D;
      Regs.BX := 0;
      Regs.CX := 0;
      Regs.DX := 0;
      Intr ($2F, Regs);
      Shell4Dos := Regs.Dl;
    End
  Else
    Shell4Dos := 0;
End;


Function PSPSegment4Dos;

Begin
  If IsInstalled (_4Dos) Then
    Begin
      Regs.AX := $D44D;
      Regs.BX := 0;
      Regs.CX := 0;
      Regs.DX := 0;
      Intr ($2F, Regs);
      PSPSegment4Dos := Regs.CX;
    End
  Else
    PSPSegment4Dos := 0;
End;


Function VersionNDos;

Begin
  If IsInstalled (NDos) Then
    Begin
      Regs.AX := $E44D;
      Regs.BX := 0;
      Regs.CX := 0;
      Regs.DX := 0;
      Intr ($2F, Regs);
      VersionNDos := StrFnByte (Regs.BL) + '.' + StrFnByte(Regs.BH);
    End
  Else
    VersionNDos := NA;
End;


Function ShellNDos;

Begin
  If IsInstalled (NDos) Then
    Begin
      Regs.AX := $E44D;
      Regs.BX := 0;
      Regs.CX := 0;
      Regs.DX := 0;
      Intr ($2F, Regs);
      ShellNDos := Regs.Dl;
    End
  Else
    ShellNDos := 0;
End;


Function PSPSegmentNDos;

Begin
  If IsInstalled (NDos) Then
    Begin
      Regs.AX := $E44D;
      Regs.BX := 0;
      Regs.CX := 0;
      Regs.DX := 0;
      Intr ($2F, Regs);
      PSPSegmentNDos := Regs.CX;
    End
  Else
    PSPSegmentNDos := 0;
End;


Function IsDesqView;

Begin
  With Regs Do
    Begin
      AX:=$2B01;
      CX:=$4445; {DE}
      DX:=$5351; {SQ}
      MsDos(regs);
      If AL = $FF then
        IsDesqView := False
      else
        IsDesqView := True;
    End;
End;


Function DesqViewVersion;

Begin
  If IsDesqView Then
    With Regs Do
      Begin
        AX := $2B01;
        CX := $4445; {DE}
        DX := $5351; {SQ}
        MsDos(regs);
        If BX = $0002 then
          DesqViewVersion := '2.00'
        else
          begin
            DesqViewVersion := StrFnByte(BH) + '.' + ZeroPad(BL);
          end;
      End;
End;


Function DesqViewWnNo;

Begin
  If IsDesqView Then
    Begin
      Regs.AX := $DE07;
      Intr($15, regs);
      DesqViewWnNo := Regs.AX;
    End
  Else
    DesqViewWnNo := 0;
End;


Function DesqViewTrueVid;

Begin
  If IsDesqView Then
    Begin
      Regs.AX := $DE1E;
      Intr($15, regs);
      DesqViewTrueVid := Regs.BL;
    End
  Else
    DesqViewTrueVid := 0;
End;


Function DesqViewWidth;

Begin
  If IsDesqView Then
    Begin
      Regs.AX := $DE1E;
      Intr($15, regs);
      DesqViewWidth := Regs.CH;
    End
  Else
    DesqViewWidth := 0;
End;


Function DesqViewHeight;

Begin
  If IsDesqView Then
    Begin
      Regs.AX := $DE1E;
      Intr($15, regs);
      DesqViewHeight := Regs.CL;
    End
  Else
    DesqViewHeight := 0;
End;


Function DesqViewCoMemAvail;

Begin
  If IsDesqView Then
    Begin
      Regs.AX := $DE04;
      Intr($15, regs);
      DesqViewCoMemAvail := Regs.BX;
    End
  Else
    DesqViewCoMemAvail := 0;
End;


Function DesqViewCoMemLarge;

Begin
  If IsDesqView Then
    Begin
      Regs.AX := $DE04;
      Intr($15, regs);
      DesqViewCoMemLarge := Regs.CX;
    End
  Else
    DesqViewCoMemLarge := 0;
End;


Function DesqViewCoMemTotal;

Begin
  If IsDesqView Then
    Begin
      Regs.AX := $DE04;
      Intr($15, Regs);
      DesqViewCoMemTotal := Regs.DX;
    End
  Else
    DesqViewCoMemTotal := 0;
End;


Function DesqViewCnMemAvail;

Begin
  If IsDesqView Then
    Begin
      Regs.AX := $DE05;
      Intr($15, Regs);
      DesqViewCnMemAvail := Regs.BX;
    End
  Else
    DesqViewCnMemAvail := 0;
End;


Function DesqViewCnMemLarge;

Begin
  If IsDesqView Then
    Begin
      Regs.AX := $DE05;
      Intr($15, regs);
      DesqViewCnMemLarge := Regs.CX;
    End
  Else
    DesqViewCnMemLarge := 0;
End;


Function DesqViewCnMemTotal;

Begin
  If IsDesqView Then
    Begin
      Regs.AX := $DE05;
      Intr($15, regs);
      DesqViewCnMemTotal := Regs.DX;
    End
  Else
    DesqViewCnMemTotal := 0;
End;


Function DesqViewExMemAvail;

Begin
  If IsDesqView Then
    Begin
      Regs.AX := $DE06;
      Intr($15, regs);
      DesqViewExMemAvail := Regs.BX;
    End
  Else
    DesqViewExMemAvail := 0;
End;


Function DesqViewExMemLarge;

Begin
  If IsDesqView Then
    Begin
      Regs.AX := $DE06;
      Intr($15, regs);
      DesqViewExMemLarge := Regs.CX;
    End
  Else
    DesqViewExMemLarge := 0;
End;


Function DesqViewExMemTotal;

Begin
  If IsDesqView Then
    Begin
      Regs.AX := $DE06;
      Intr($15, regs);
      DesqViewExMemTotal := Regs.DX;
    End
  Else
    DesqViewExMemTotal := 0;
End;


Function TaskMaxVersion;

Begin
  If IsInstalled (DrDosTskMx) Then
    Begin
      Regs.AX := $2701;
      Intr($2F, regs);
      TaskMaxVersion := Regs.DX;
    End
  Else TaskMaxVersion := 0;
End;


Function TaskMaxMaxTasks;

Begin
  If IsInstalled (DrDosTskMx) Then
    Begin
      Regs.AX := $2701;
      Intr($2F, regs);
      TaskMaxMaxTasks := Regs.AX;
    End
  Else TaskMaxMaxTasks := 0;
End;


Function TaskMaxActTasks;

Begin
  If IsInstalled (DrDosTskMx) Then
    Begin
      Regs.AX := $2701;
      Intr($2F, regs);
      TaskMaxActTasks := Regs.CX;
    End
  Else TaskMaxActTasks := 0;
End;


Function IsTBScanX;

Begin
  With Regs Do
    Begin
      AX := $CA00;
      BX := $5442; {TB}
      Intr($2F, regs);
      if (AL <> $FF) or (BX <> $7462 {tb}) then
        IsTBScanX := False
      else
        IsTBScanX := True;
    End;
End;


Function TBScanXVersion;

Begin
  If IsTBScanX Then
    With Regs Do
      Begin
        AX := $CA01;
        Intr($2F, regs);
        If AH <> $CA then
          TbScanXVersion := StrFnByte (AH shr 4) + '.' + StrFnByte (AH and $F)
        else
          TbScanXVersion := '2.2-';
      End
  Else
    TbScanXVersion := NA;
End;


Function TBScanXStatus;

Begin
  If IsTBScanX Then
    With Regs Do
      Begin
        AX := $CA01;
        Intr($2F, regs);
        if AL = 0 then
          TBScanXStatus := 'inaktiv'
        else
          TBScanXStatus := 'aktiv';
      End
  Else
    TbScanXStatus := NA;
End;


{ Die folgende Funktion wird intern fÅr die N_??? Funktionen benîtigt      }

Function NortonStatus (B: Byte) : String;

Begin
  Case B of
    0 : NortonStatus := 'inaktiv';
    1 : NortonStatus := 'aktiv'
  else
    NortonStatus := 'unbekannt'
  end
End;


Function N_CacheStatus;

Begin
  If IsInstalled (N_Cache_F) Or IsInstalled (N_Cache_S) Then
    Begin
      Regs.AX := $FE00;
      Regs.BX := 0;
      Regs.CX := 0;
      Regs.DX := 0;
      Regs.DI := $4E55; {NU}
      Regs.SI := $4346; {CF}
      Intr ($2F, regs);
      N_CacheStatus := NortonStatus (Regs.AH);
    End
  Else
    N_CacheStatus := NA;
End;


Function N_DiskReetStatus;

Begin
  If IsInstalled (N_DiskReet) Then
    Begin
      Regs.AX := $FE00;
      Regs.BX := 0;
      Regs.CX := 0;
      Regs.DX := 0;
      Regs.DI := $4E55; {NU}
      Regs.SI := $4346; {CF}
      Intr($2F, regs);
      N_DiskReetStatus := NortonStatus (Regs.AH);
    End
  Else N_DiskReetStatus := NA;
End;


Function N_DiskReetRes;

Begin
  If IsInstalled (N_DiskReet) Then
    Begin
      Regs.AX := $FE00;
      Regs.BX := 0;
      Regs.CX := 0;
      Regs.DX := 0;
      Regs.DI := $4E55; {NU}
      Regs.SI := $4346; {CF}
      Intr ($2F, regs);
      N_DiskReetRes := Regs.CX;
    End
  Else N_DiskReetRes := 0;
End;



Function N_DiskMonStatus;

Begin
  If IsInstalled (N_DiskMon) Then
    Begin
      Regs.AX := $FE00;
      Regs.BX := 0;
      Regs.CX := 0;
      Regs.DX := 0;
      Regs.DI := $4E55; {NU}
      Regs.SI := $444D; {CF}
      Intr($2F, regs);
      N_DiskMonStatus := NortonStatus (Regs.AH);
    End
  Else N_DiskMonStatus := NA;
End;


Function N_DiskMonRes;

Begin
  If IsInstalled (N_DiskMon) Then
    Begin
      Regs.AX := $FE00;
      Regs.BX := 0;
      Regs.CX := 0;
      Regs.DX := 0;
      Regs.DI := $4E55; {NU}
      Regs.SI := $444D; {CF}
      Intr($2F, regs);
      N_DiskMonRes := Regs.CX;
    End
  Else N_DiskMonRes := 0;
End;


Function N_FileSavRes;

Begin
  If IsInstalled (N_FileSav) Then
    Begin
      Regs.AX := $FE00;
      Regs.BX := 0;
      Regs.CX := 0;
      Regs.DX := 0;
      Regs.DI := $4E55; {NU}
      Regs.SI := $4653; {CF}
      Intr($2F, regs);
      N_FileSavRes := Regs.CX;
    End
  Else N_FileSavRes := 0;
End;


Function IsPcAnyWhere;

Begin
  With regs Do
    Begin
      AH := $79;
      Intr($16, regs);
      If AX < $FFFC then
        IsPcAnyWhere := False
      Else
        IsPcAnyWhere := True;
    End;
End;


Function PcAnyWhereStatus;

Const pcAstatus: array[$FFFC..$FFFF] of string[30] = ('Resident und aktiv',
               'Resident und nicht aktiv', 'Memory Resident Mode',
               'Automatischer Mode');

Begin
  If IsPCAnyWhere Then
    Begin
      Regs.AH := $79;
      Intr($16, regs);
      PcAnyWhereStatus := pcAStatus [Regs.AX];
    End
  Else
    PcAnyWhereStatus := NA;
End;


Function PcAnyWherePort;

Begin
  If IsPcAnyWhere Then
    Begin
      Regs.AH := $7C;
      Intr($16, regs);
      PcAnyWherePort := Regs.AH;
    End
  Else
    PcAnyWherePort := 0;
End;


Function PcAnyWhereBaud;

Const
    pcAspd: array[0..$F] of word = (50, 75, 110, 134, 150, 300, 600, 1200, 1800,
            2000, 2400, 4800, 7200, 9600, 19200, 38400);
Begin
  If IsPcAnyWhere Then
    Begin
      Regs.AH := $7C;
      Intr($16, regs);
      PcAnyWhereBaud := pcAspd [Regs.AL];
    End
  Else
    PcAnyWhereBaud := 0;
End;


Function IsPCAnyWhereIV;

Begin
  Regs.AX := $2B44;
  Regs.BX := $4D41;
  Regs.CX := $7063;
  Regs.DX := $4157;
  MsDos (Regs);
  If (Regs.AX = $4F4B) Or (Regs.AX = $6F6B) Then IsPCAnywhereIV := True Else
    IsPCAnyWhereIV := False;
End;


Function PCAnyWhereIVApi;

Begin
  If IsPCAnyWhereIV Then
    Begin
      Regs.AX := $2B44;
      Regs.BX := $4D41;
      Regs.CX := $7063;
      Regs.DX := $4157;
      MsDos (Regs);
      PCAnyWhereIVApi := Ptr (Regs.CX, Regs.DX);
    End
  Else
    PcAnyWhereIVApi := Ptr (0,0);
End;


Function PCAnyWhereIVVer;

Var B : ^Byte;

Begin
  If IsPCAnyWhereIV Then
    Begin
      GetMem (B, 1);
      Regs.AX := $0000;
      Regs.DS := PtrRec(B).Seg;
      Regs.SI := PtrRec(B).Ofs;
      XPointer := PCAnyWhereIVAPI;
      xWord := Regs.AX;
      xWord2 := Regs.AX;
      xWord3 := Regs.AX;
      Asm
        Mov AX, xWord
        Mov DS, xWord2
        Mov SI, xWord3
        Call XPointer
        Mov xWord, AX
      End;
      Regs.AX := xWord;
      PCAnyWhereIVVer := 'Ver : ' + StrFnByte(Regs.AH) + ', Rev : ' +
        StrFnByte (Regs.AL);
      FreeMem (B, 1);
    End
  Else
    PCANyWhereIVVer := NA;
End;


Function PCAnyWhereIVStat;

Begin
  If IsPCAnyWhereIV Then
    Begin
      Regs.AX := $0002;
      XPointer := PCAnyWhereIVAPI;

      xWord := Regs.AX;
      Asm
        Mov AX, xWord
        Call XPointer
        Mov xWord, AX
      End;
      Regs.AX := xWord;

      Case Regs.AH Of
        00 : EndString := 'Warte auf Anruf';
        01 : EndString := 'Hotkey hat aktiviert';
        02 : EndString := 'Anruf hat aktiviert';
        03 : EndString := 'Initialisieren eines Anrufs';
      End;
      PcAnyWhereIVStat := EndString;
    End
  Else
    PCANyWhereIVStat := NA;
End;


Function IsDiskSpoolII;

Begin
  With regs do
    Begin
      AH := $A0;
      Intr($1A, regs);
      IsDiskSpoolII :=  (AH = $B0);
    End;
End;


Function DiskSpoolSegment;

Begin
  If IsDiskSpoolII Then
    Begin
      Regs.AH := $A0;
      Intr($1A, Regs);
      DiskSpoolSegment := Regs.ES;
    End
  Else
    DiskSpoolSegment := 0;
End;


Function DiskSpoolSpoolSt;

Var xByte : Byte;
    xChar : Char;

Begin
  If IsDiskSpoolII Then
    Begin
      Regs.AH := $A0;
      Intr($1A, Regs);
      Case Regs.CH Of
        $00 : DiskSpoolSpoolSt := 'inaktiv';
        $41 : Begin
                DiskSpoolSpoolSt := 'aktiv, File : ';

               xByte := 0;
               Repeat
                 xChar := Chr (Mem[Regs.ES:Regs.BX]);
                 If xChar <> #0 Then
                   DiskSpoolSpoolSt := DiskSpoolSpoolSt + xChar;
                 Inc (xByte);
                 Inc (Regs.BX);
               Until (xChar = #0) or (xByte >= 64);
               if xByte = 0 then
                 DiskSpoolSpoolSt := '(keine)';
             end;
      else
        DiskSpoolSpoolSt := '??';
      End;
    End
  Else
    DiskSpoolSpoolSt := NA;
End;


Function DiskSpoolDeSpSt;

Var xByte : Byte;
    xChar : Char;

Begin
  If IsDiskSpoolII Then
    Begin
      Regs.AH := $A0;
      Intr($1A, Regs);
      Case Regs.CL of
        $00: DiskSpoolDeSpSt := 'inaktiv';
        $41: begin
               DiskSpoolDeSpSt := 'aktiv und ';
               Case Regs.DL of
                 $00: DiskSpoolDeSpSt := DiskSpoolDeSpSt + 'am Drucken, File : ';
                 $41: DiskSpoolDeSpSt := DiskSpoolDeSpSt + 'wartet, File :';
               else
                 DiskSpoolDeSpSt := DiskSpoolDeSpSt + '?????, File : ';
               end;

               xbyte:=0;
               repeat
                 xchar:=Chr(Mem[Regs.ES:Regs.SI]);
                 if xchar <> #0 then
                   DiskSpoolDeSpSt := DiskSpoolDeSpSt + xchar;
                 Inc(xbyte);
                 Inc(Regs.SI);
               until (xchar = #0) or (xbyte >= 64);
               if xByte = 0 then
                 DiskSpoolDeSpSt := '(keine)';
             End;
      Else
        DiskSpoolDeSpSt := '????';
      end;
    End
  Else
    DiskSpoolDeSpSt := NA;
End;


{ Die folgende Funktion wird fÅr Windows-Enhanced Routinen benîtigt       }
Function WinDev (Device : Byte) : Word;

var
  SaveIt : Word;

Begin
  With Regs Do
    Begin
      AX := $1682;
      Intr ($2F, Regs);
      AX := $170A;
      DX := Device;
      Intr ($2F, Regs);
      WinDev := AX
    end
End;


Function IsWindows;

Begin
  with regs do
    begin
      AX:=$1600;
      Intr($2F, regs);
      case AL of
        $1..$7F, $81..$FE :
                 Begin
                   IsWindows := True;
                 End;
        $00,$80: Begin
                   Regs.AX:=$4680;
                   Intr($2F, regs);
                   If Regs.AX = 0 then
                     IsWindows := True
                   Else
                     IsWindows := False;
                 End;
      end;
    End;
End;


Function WindowsMode;

Begin
  If IsWindows Then
    Begin
      Regs.AX := $1600;
      Intr($2F, regs);
      Case Regs.AL of
        $01,$FF: Begin
                   WindowsMode := dwi386_2_X
                 End;
        $00,$80: begin
                   Regs.AX:=$4680;
                   Intr($2F, regs);
                   If Regs.AX = 0 Then
                     Begin
                       WindowsMode := dwi3_0_Real_Standard
                     End
                   Else
                     WindowsMode := dwiNothing;
                 end;
        $02..$7F,$81..$FE: Begin
                             WindowsMode := dwiEnhanced;
                           End;
      End; { Case }
    End
  Else
    WindowsMode := dwiNothing;
End;


Function WinEnhVersion;

Begin
  If IsWindows And (WindowsMode = dwiEnhanced) Then
    Begin
      Regs.AX:=$1600;
      Intr($2F, regs);
      WinEnhVersion := StrFnByte (Regs.AL) + '.' + StrFnByte (Regs.AH) +
        ' 386 erweitert';
    End;
End;


Function WinEnhVirtMashID;

Begin
  If IsWindows And (WindowsMode = dwiEnhanced) Then
    Begin
      Regs.AX := $1683;
      Intr ($2F, Regs);
      WinEnhVirtMashId := Regs.BX;
    End;
End;


Function WinEnhOldAp;

Begin
  If IsWindows And (WindowsMode = dwiEnhanced) Then
    Begin
      Regs.AX:=$1700;
      Intr ($2F, regs);
      If Regs.AX = $1700 then
        WinEnhOldAp := False
      Else
        WinEnhOldAp := True;
    End;
End;


Function WinEnhOldApVer;

Begin
  If WinEnhOldAp Then
    Begin
      Regs.AX := $1700;
      Intr ($2F, regs);
      WinEnhOldApVer := StrFnByte (Regs.AL) + '.' + StrFnByte (Regs.AH);
    End;
End;


Function WinEnhDriverVer;

Var xWord1 : Word;

Begin
  If IsWindows And (WindowsMode = dwiEnhanced) Then
    Begin
      xWord1 := WinDev (0);
      WinEnhDriverVer := StrFnByte (Hi(xWord1)) + '.' + StrFnByte (Lo(xWord1));
    End;
End;


Function WinEnhDeviceType;

Const Winclass : Array [0..6] of string[21] = ('Vektor Plotter', 'Raster Display',
              'Raster Drucker', 'Raster Kamera', 'Character-Flu·, PLP',
              'Metafile, VDM', 'Display-File');

Begin
  If IsWindows And (WindowsMode = dwiEnhanced) Then
    Begin
       WinEnhDeviceType := WinClass [Lo (WinDev (2))];
    End;
End;


Function WinEnhPixelWidth;


Begin
  If IsWindows And (WindowsMode = dwiEnhanced) Then
    Begin
       WinEnhPixelWidth := WinDev ( 8 );
    End;
End;


Function WinEnhPixelHeight;


Begin
  If IsWindows And (WindowsMode = dwiEnhanced) Then
    Begin
       WinEnhPixelHeight := WinDev ($A);
    End;
End;


Function WinEnhColors;


Begin
  If IsWindows And (WindowsMode = dwiEnhanced) Then
    Begin
       WinEnhColors := WinDev ( $18 );
    End;
End;


Function WinEnhBits_Pixel;


Begin
  If IsWindows And (WindowsMode = dwiEnhanced) Then
    Begin
       WinEnhBits_Pixel := WinDev ( $C );
    End;
End;


Function WinEnhBit_Planes;


Begin
  If IsWindows And (WindowsMode = dwiEnhanced) Then
    Begin
       WinEnhBit_Planes := WinDev ( $E );
    End;
End;


Function WinEnhXAspect;


Begin
  If IsWindows And (WindowsMode = dwiEnhanced) Then
    Begin
       WinEnhXAspect := WinDev ($28);
    End;
End;


Function WinEnhYAspect;


Begin
  If IsWindows And (WindowsMode = dwiEnhanced) Then
    Begin
       WinEnhYAspect := WinDev ($2A);
    End;
End;


Function WinEnhBrushes;


Begin
  If IsWindows And (WindowsMode = dwiEnhanced) Then
    Begin
       WinEnhBrushes := WinDev ( $10 );
    End;
End;


Function WinEnhPens;


Begin
  If IsWindows And (WindowsMode = dwiEnhanced) Then
    Begin
       WinEnhPens := WinDev ( $12 );
    End;
End;


Function WinEnhMarkers;


Begin
  If IsWindows And (WindowsMode = dwiEnhanced) Then
    Begin
       WinEnhMarkers := WinDev ( $14 );
    End;
End;


Function WinEnhFonts;


Begin
  If IsWindows And (WindowsMode = dwiEnhanced) Then
    Begin
       WinEnhFonts := WinDev ( $16 );
    End;
End;


Function IsSmartDrive;

Var S     : String;
    xWord : Word;

Begin
  With Regs Do
    Begin
      s  := 'SMARTAAR'#0;
      AX := $3D00;
      DS := Seg(s);
      DX := Ofs(s) + 1;
      MsDos (regs);
      If (regs.Flags And FCarry) = 1 then
        Begin
          AX := $4A10;
          BX := 0;
          CX := 0;
          DX := 0;
          Intr($2F, regs);
          If AX = $BABE Then
            Begin
              IsSmartDrive := dsmDevice;
            End
          Else
            IsSmartDrive := dsmNo;
        End
      Else
        Begin
          xWord := AX;
          AX := $4400;
          BX := xWord;
          MsDos (regs);
          If ((regs.Flags And FCarry) = 1) Or (DX and $4080 <> $4080) Then
            IsSmartDrive := dsmIOCTLNSupport
          Else
            Begin
              AX := $4402;
              BX := xWord;
              CX := SizeOf(smartdrvbuf);
              DS := Seg(smartdrvbuf);
              DX := Ofs(smartdrvbuf);
              MsDos (regs);
              If (regs.Flags And FCarry) = 1 Then
                IsSmartDrive := dsmIOCTLReadError
              Else
                IsSmartDrive := dsmIOCTL;
            end;
          AH := $3E;
          BX := xWord;
          MsDos (regs);
        End
    End;
End;


Function SMDeviceVer;

Begin
  If IsSmartDrive = dsmDevice Then
    Begin
      Regs.AX := $4A10;
      Regs.BX := 0;
      Regs.CX := 0;
      Regs.DX := 0;
      Intr ($2F, Regs);
      SMDeviceVer := StrFnByte (Hi(Regs.BP)) + '.' + ZeroPad (Lo(Regs.BP));
    End
  Else
    SMDeviceVer := NA;
End;


Function SMDeviceSizeNow;

Begin
  If IsSmartDrive = dsmDevice Then
    Begin
      Regs.AX := $4A10;
      Regs.BX := 4;
      Intr ($2F, Regs);
      SMDeviceSizeNow := (LongInt (Regs.CX) * Regs.BX) DIV 1024;
    End
  Else
    SMDeviceSizeNow := 0;
End;


Function SMDeviceMinSize;

Begin
  If IsSmartDrive = dsmDevice Then
    Begin
      Regs.AX := $4A10;
      Regs.BX := 4;
      Intr ($2F, Regs);
      SMDeviceMinSize := (LongInt (Regs.DX) * Regs.CX) DIV 1024;
    End
  Else
    SMDeviceMinSize := 0;
End;


Function SMDeviceEleSize;

Begin
  If IsSmartDrive = dsmDevice Then
    Begin
      Regs.AX := $4A10;
      Regs.BX := 4;
      Intr ($2F, Regs);
      SMDeviceEleSize := Regs.CX DIV 1024;
    End
  Else
    SMDeviceEleSize := 0;
End;


Function SMDeviceCacheHits;

Begin
  If IsSmartDrive = dsmDevice Then
    Begin
      Regs.AX:=$4A10;
      Regs.BX:=0;
      Intr ($2F, Regs);
      SMDeviceCacheHits := Longint(Regs.DX) Shl 16 + Regs.BX;
    End
  Else
    SMDeviceCacheHits := 0;
End;


Function SMDeviceCacheMisses;

Begin
  If IsSmartDrive = dsmDevice Then
    Begin
      Regs.AX:=$4A10;
      Regs.BX:=0;
      Intr ($2F, Regs);
      SMDeviceCacheMisses := LongInt (Regs.DI) Shl 16 + Regs.SI;
    End
  Else
    SMDeviceCacheMisses := 0;
End;


Function SMDNumber (Drive : Char) : Byte;

Begin
  SMDNumber := Ord (UpCase (Drive)) - 65;
End;


Function SMDeviceRCache (Drive : Char) : Byte;

Var D : Byte;

Begin
  If IsSmartDrive = dsmDevice Then
    Begin
      D := SMDNumber (Drive);
      Regs.AX := $4A10;
      Regs.BX := 3;
      Regs.BP := D;
      Regs.DX := 0;
      Intr($2F, regs);
      If Regs.DL <> $FF Then
        Begin
          If (Regs.DL and $80) <> $80 Then SMDeviceRCache := dsmdTrue Else
            SMDeviceRCache := dsmdFalse;
        End
      Else
        SMDeviceRCache := dsmdNo;
      Regs.AH := $3E;
      Regs.BX := D;
      MsDos(regs);
    End
  Else
    SMDeviceRCache := dalError;
End;


Function SMDeviceWCache (Drive : Char) : Byte;

Var D : Byte;

Begin
  If IsSmartDrive = dsmDevice Then
    Begin
      D := SMDNumber (Drive);
      Regs.AX := $4A10;
      Regs.BX := 3;
      Regs.BP := D;
      Regs.DX := 0;
      Intr($2F, regs);
      If Regs.DL <> $FF Then
        Begin
          If (Regs.DL and $40) <> $40 Then SMDeviceWCache := dsmdTrue Else
            SMDeviceWCache := dsmdFalse;
        End
      Else
        SMDeviceWCache := dsmdNo;
      Regs.AH := $3E;
      Regs.BX := D;
      MsDos(regs);
    End
  Else
    SMDeviceWCache := dalError;
End;


Function SMDeviceDblBuffer (Drive : Char) : Byte;

Var D : Byte;

Begin
  If IsSmartDrive = dsmDevice Then
    Begin
      D := SMDNumber (Drive);
      Regs.AX := $4A10;
      Regs.BX := 3;
      Regs.BP := D;
      Regs.DX := 0;
      if Regs.DL <> $FF then
       Begin
          Regs.AX := $4A10;
          Regs.BX := 5;
          Regs.BP := D;
          Intr ($2F, Regs);
          If Regs.AX = $BABE Then SMDeviceDblBuffer := dsmdTrue Else
            SMDeviceDblBuffer := dsmdFalse;
        End
      Else
        SMDeviceDblBuffer:= dsmdNo;
      Regs.AH := $3E;
      Regs.BX := D;
      MsDos(regs);
    End
  Else
    SMDeviceDblBuffer := dalError;
End;


Function SMIOCTLVer;

Begin

  { Die Funktion IsSmartDrive fÅllt die Variable SmartDrvBuf, welche hier
    benutzt wird.                                                         }

  If IsSmartDrive = dsmIOCTL Then
    Begin
      With SmartDrvBuf Do
        Begin
          SMIOCTLVer := StrFnByte (majorversion) + '.' +
            StrFnByte (minorversion);
        End;
    End
  Else
    SMIOCTLVer := NA;
End;

Function SMIOCTLSize;

Begin

  { Die Funktion IsSmartDrive fÅllt die Variable SmartDrvBuf, welche hier
    benutzt wird.                                                         }
  If IsSmartDrive = dsmIOCTL Then
    Begin
      With SmartDrvBuf Do
        Begin
          SMIOCTLSize := Current_Size * 16;
        End;
    End
  Else
    SMIOCTLSize := 0;
End;

Function SMIOCTLMaxSize;

Begin

  { Die Funktion IsSmartDrive fÅllt die Variable SmartDrvBuf, welche hier
    benutzt wird.                                                         }
  If IsSmartDrive = dsmIOCTL Then
    Begin
      With SmartDrvBuf Do
        Begin
          SMIOCTLMaxSize := Original_Size * 16;
        End;
    End
  Else
    SMIOCTLMaxSize := 0;
End;

Function SMIOCTLMinSize;

Begin

  { Die Funktion IsSmartDrive fÅllt die Variable SmartDrvBuf, welche hier
    benutzt wird.                                                         }
  If IsSmartDrive = dsmIOCTL Then
    Begin
      With SmartDrvBuf Do
        Begin
          SMIOCTLMinSize := Minimum_Size * 16;
        End;
    End
  Else
    SMIOCTLMinSize := 0;
End;


Function SMIOCTLEnabled;

Begin

  { Die Funktion IsSmartDrive fÅllt die Variable SmartDrvBuf, welche hier
    benutzt wird.                                                         }
  If IsSmartDrive = dsmIOCTL Then
    Begin
      With SmartDrvBuf Do
        Begin
          SMIOCTLEnabled := (Cache_Enabled = 1);
        End;
    End
  Else
    SMIOCTLEnabled := False;
End;


Function SMIOCTLLockedTracks;

Begin

  { Die Funktion IsSmartDrive fÅllt die Variable SmartDrvBuf, welche hier
    benutzt wird.                                                         }
  If IsSmartDrive = dsmIOCTL Then
    Begin
      With SmartDrvBuf Do
        Begin
          SMIOCTLLockedTracks := (Locked > 0);
        End;
    End
  Else
    SMIOCTLLockedTracks := False;
End;


Function SMIOCTLWriteThrough;

Begin

  { Die Funktion IsSmartDrive fÅllt die Variable SmartDrvBuf, welche hier
    benutzt wird.                                                         }
  If IsSmartDrive = dsmIOCTL Then
    Begin
      With SmartDrvBuf Do
        Begin
          SMIOCTLWriteThrough := (Write_Through = 1);
        End;
    End
  Else
    SMIOCTLWriteThrough := False;
End;


Function SMIOCTLWriteBuffer;

Begin

  { Die Funktion IsSmartDrive fÅllt die Variable SmartDrvBuf, welche hier
    benutzt wird.                                                         }
  If IsSmartDrive = dsmIOCTL Then
    Begin
      With SmartDrvBuf Do
        Begin
          SMIOCTLWriteBuffer := (Write_Buffered = 1);
        End;
    End
  Else
    SMIOCTLWriteBuffer := False;
End;


Function SMIOCTLHitRate;

Begin
  { Die Funktion IsSmartDrive fÅllt die Variable SmartDrvBuf, welche hier
    benutzt wird.                                                         }
  If IsSmartDrive = dsmIOCTL Then
    Begin
      With SmartDrvBuf Do
        Begin
          SMIOCTLHitRate := Cache_Hitrate;
        End;
    End
  Else
    SMIOCTLHitRate := 0;
End;


Function SMIOCTLDMABuffering;

Begin
  { Die Funktion IsSmartDrive fÅllt die Variable SmartDrvBuf, welche hier
    benutzt wird.                                                         }
  If IsSmartDrive = dsmIOCTL Then
    Begin
      With SmartDrvBuf Do
        Begin
          Case buffering_type of
            0: SMIOCTLDMABuffering := 'aus';
            1: SMIOCTLDMABuffering := 'an';
            2: SMIOCTLDMABuffering := 'dynamisch';
          Else
            SMIOCTLDMABuffering := '(unbekannt)';
          End; {case}
        End;
    End
  Else
    SMIOCTLDMABuffering := NA;
End;


Function SMIOCTLMemoryType;

Begin
  { Die Funktion IsSmartDrive fÅllt die Variable SmartDrvBuf, welche hier
    benutzt wird.                                                         }
  If IsSmartDrive = dsmIOCTL Then
    Begin
      With SmartDrvBuf Do
        Begin
          Case drivertype Of
            1: SMIOCTLMemoryType := 'XMS';
            2: SMIOCTLMemoryType := 'EMS'
          Else
            SMIOCTLMemoryType := 'unbekannt, Code : ' + StrFnByte (drivertype);
          End;
        End;
    End
  Else
    SMIOCTLMemoryType := NA;
End;


Function SMIOCTLFlushReboot;

Begin
  { Die Funktion IsSmartDrive fÅllt die Variable SmartDrvBuf, welche hier
    benutzt wird.                                                         }
  If IsSmartDrive = dsmIOCTL Then
    Begin
      With SmartDrvBuf Do
        Begin
          SMIOCTLFlushReBoot := (reboot_flush <> 0);
        End;
    End
  Else
    SMIOCTLFlushReBoot := False;
End;


Function SMIOCTLTracksTotal;

Begin
  { Die Funktion IsSmartDrive fÅllt die Variable SmartDrvBuf, welche hier
    benutzt wird.                                                         }
  If IsSmartDrive = dsmIOCTL Then
    Begin
      With SmartDrvBuf Do
        Begin
          SMIOCTLTracksTotal := Total_Tracks;
        End;
    End
  Else
    SMIOCTLTracksTotal := 0;
End;


Function SMIOCTLTracksUsed;

Begin
  { Die Funktion IsSmartDrive fÅllt die Variable SmartDrvBuf, welche hier
    benutzt wird.                                                         }
  If IsSmartDrive = dsmIOCTL Then
    Begin
      With SmartDrvBuf Do
        Begin
          SMIOCTLTracksUsed := Tracks_Used;
        End;
    End
  Else
    SMIOCTLTracksUsed := 0;
End;


Function SMIOCTLTracksLocked;

Begin
  { Die Funktion IsSmartDrive fÅllt die Variable SmartDrvBuf, welche hier
    benutzt wird.                                                         }
  If IsSmartDrive = dsmIOCTL Then
    Begin
      With SmartDrvBuf Do
        Begin
          SMIOCTLTracksLocked := Locked_Tracks;
        End;
    End
  Else
    SMIOCTLTracksLocked := 0;
End;


Function SMIOCTLTracksDirty;

Begin
  { Die Funktion IsSmartDrive fÅllt die Variable SmartDrvBuf, welche hier
    benutzt wird.                                                         }
  If IsSmartDrive = dsmIOCTL Then
    Begin
      With SmartDrvBuf Do
        Begin
          SMIOCTLTracksDirty := Dirty_Tracks;
        End;
    End
  Else
    SMIOCTLTracksDirty := 0;
End;


Function IsPC_TCP;

Var xByte   : Byte;
    FoundIt : Boolean;
    xWord1  : Word;
    S       : String;

Begin
  With Regs Do
    Begin
      xByte := $60;
      FoundIt := False;
      Repeat
        AH := $35;
        AL := xByte;
        MsDos (regs);
        S := '';
        For xWord1 := BX + 3 to BX + $A do
          s := s + Chr(Mem[ES:xWord1]);
        If S = 'PKT DRVR' Then
          FoundIt:=true;

        Inc(xByte);
      Until FoundIt Or (xbyte = $81);

      If FoundIt Then
        IsPC_TCP := True
      Else
        IsPC_TCP := False;
    end;
End;


Function PC_TCP_Interrupt;

Var xByte   : Byte;
    FoundIt : Boolean;
    xWord1  : Word;
    S       : String;

Begin
  With Regs Do
    Begin
      xByte := $60;
      FoundIt := False;
      Repeat
        AH := $35;
        AL := xbyte;
        MsDos (Regs);
        S := '';
        For xWord1 := BX + 3 to BX + $A do
          S := S + Chr(Mem[ES:xWord1]);
        If S = 'PKT DRVR' then
          FoundIt := True;

        Inc(xByte);
      Until FoundIt Or (xbyte = $81);

      If FoundIt Then
        PC_TCP_Interrupt := xByte
      Else
        PC_TCP_Interrupt := 0;
    End;
End;


Function IsFossil;

Begin
  With Regs Do
    Begin
      AX := $1B00;
      DX := $FF;
      CX := SizeOf(fossilbuf);
      ES := Seg(fossilbuf);
      DI := Ofs(fossilbuf);
      Intr ($14, regs);

      if AX <> $1B00 then
        IsFossil := True
      else
        IsFossil := False;
    End;
End;


Function FossilType;

Var xBool1 : Boolean;

Begin
  xBool1 := False;
  If IsFossil Then
    With Regs Do
      Begin
        AH := $BC;
        DX := $1954;
        Intr ($11, regs);
        If AX = $1954 then xBool1 := True;
        AX := $1B00;
        DX := $FF;
        CX := SizeOf (fossilbuf);
        ES := Seg (fossilbuf);
        DI := Ofs (fossilbuf);
        Intr($14, regs);
        If xBool1 Then
          FossilType := 'BNU'
        Else
          If (CX = $3058 {0X}) And (DX = $2030 { 0}) Then
            FossilType := 'X00'
          Else
            FossilType := '(unbekannt)';
      End
  Else
    FossilType := NA;
End;


Function FossilSpecLevel;

Begin
  If IsFossil Then
    With Regs Do
      Begin
        AX := $1B00;
        DX := $FF;
        CX := SizeOf (fossilbuf);
        ES := Seg (fossilbuf);
        DI := Ofs (fossilbuf);
        Intr($14, regs);
        FossilSpecLevel := FossilBuf.Spec;
      End
  Else
    FossilSpecLevel := 0;
End;


Function FossilRevision;

Begin
  If IsFossil Then
    With Regs Do
      Begin
        AX := $1B00;
        DX := $FF;
        CX := SizeOf (fossilbuf);
        ES := Seg (fossilbuf);
        DI := Ofs (fossilbuf);
        Intr($14, regs);
        FossilRevision := FossilBuf.Rev;
      End
  Else
    FossilRevision := 0;
End;


Function FossilIDString;

Begin
  FossilIdString := '';
  If IsFossil Then
    With Regs Do
      Begin
        AX := $1B00;
        DX := $FF;
        CX := SizeOf (fossilbuf);
        ES := Seg (fossilbuf);
        DI := Ofs (fossilbuf);
        Intr($14, regs);
        While Mem[FossilBuf.IDStrSeg:FossilBuf.IDStrOfs] <> 0 Do
          Begin
            FossilIdString := FossilIdString + Chr(Mem[FossilBuf.IdStrSeg:
              FossilBuf.IdStrOfs]);
            Inc(FossilBuf.idstrofs)
          End;
      End
  Else
    FossilIdString := '('+NA+')';
End;


Function IsVidFossil;

Begin
  With Regs Do
    Begin
      AX := $8100;
      ES := Seg (vfossilbuf);
      DI := Ofs (vfossilbuf);
      Intr($14, regs);
      If AX <> $1954 Then
        IsVidFossil := False
      Else
        IsVidFossil := True;
    End;
End;


Function VidFossilVer;

Begin
  If IsVidFossil Then
    With Regs Do
      Begin
        AX := $8100;
        ES := Seg(vfossilbuf);
        DI := Ofs(vfossilbuf);
        Intr($14, regs);
        VidFossilVer := VFossilBuf.Ver;
      End
  Else
    VidFossilVer := 0;
End;


Function VidFossilRev;

Begin
  If IsVidFossil Then
    With Regs Do
      Begin
        AX := $8100;
        ES := Seg(vfossilbuf);
        DI := Ofs(vfossilbuf);
        Intr($14, regs);
        VidFossilRev := VFossilBuf.Rev;
      End
  Else
    VidFossilRev := 0;
End;


Function VidFossilHFn;

Begin
  If IsVidFossil Then
    With Regs Do
      Begin
        AX := $8100;
        ES := Seg(vfossilbuf);
        DI := Ofs(vfossilbuf);
        Intr($14, regs);
        VidFossilHfn := VFossilBuf.HiFunc;
      End
  Else
    VidFossilHfn := 0;
End;


Function IsNetWork;

Begin
  Regs.AX:=$B800;
  Intr($2F, regs);
  IsNetWork := (Regs.AL <> 0)
End;


Function NetType;

Begin
  NetType := '';
  If IsNetWork Then
    Begin
      Regs.AX:=$B800;
      Intr($2F, regs);
      if Regs.BX and $0040 = $40 then
        NetType := 'Server'
      else
        if Regs.BX and $0004 = $4 then
          NetType := 'Messenger'
        else
          if Regs.BX and $0080 = $80 then
            NetType := 'Receiver'
          else
            if Regs.BX and $0008 = $8 then
              NetType := 'Redirector';
    End
  Else
    NetType := NA;
End;


Function AppendStatus;

Begin
  AppendStatus := '';
  If IsInstalled (Append) Then
    Begin
      Regs.AX:=$B706;
      Intr($2F, regs);
      if (Regs.BX and 1) = 1 then
        AppendStatus := AppendStatus + 'aktiv, ';
      if (Regs.BX and $2000) = $2000 then
        AppendStatus := AppendStatus + '/PATH ';
      if (Regs.BX and $4000) = $4000 then
        AppendStatus := AppendStatus + '/E ';
      if (Regs.BX and $8000) = $8000 then
        AppendStatus := AppendStatus + '/X';
    End
  Else
    AppendStatus := NA;
End;


Function AppendPath;

Begin
   AppendPath := '';
   If IsInstalled (Append) Then
     Begin
        Regs.AX:=$B704;
        Intr($2F, regs);
        While Mem [Regs.ES:Regs.DI] <> 0 Do
          Begin
            AppendPath := AppendPath + Chr(mem[Regs.ES:Regs.DI]);
            Inc(Regs.DI)
          End;
     End
   Else
     AppendPath := NA;
End;


Function SetverList;

Var devSeg : Word;
    devOfs : Word;

Begin
  Regs.AH := $30;
  MsDos (Regs);
  If Regs.AL >= 5 Then
    Begin
      Regs.AH:=$52;
      MSDOS (regs);
      devseg := Regs.ES;
      devofs := Regs.BX;
      SetverList := Ptr (MemW[devseg : devofs + $39], MemW [devseg : devofs + $37]);
    End
  Else
    SetverList := Ptr (0,0);
End;


Function SetverCount;

Var devSeg : Word;
    devOfs : Word;
    xWord1 : Word;
    xWord2 : Word;
    xByte  : Byte;
    Count  : Word;

Begin
  Count := 0;
  Regs.AH := $30;
  MsDos (Regs);
  If Regs.AL >= 5 Then
    Begin
      If LongInt (SetverList) <> 0 Then
        Begin
          Regs.AH:=$52;
          MSDOS (regs);
          devseg := Regs.ES;
          devofs := Regs.BX;
          xword1 := MemW [devseg : devofs + $39];
          xword2 := MemW [devseg : devofs + $37];
          while Mem[xword1:xword2] <> 0 do
            begin
              xByte:=Mem [xword1:xword2];
              Inc (xWord2);
              Inc (xWord2, xByte);
              Inc (xWord2, 2);
              Inc (Count, 1);
            End;
          SetverCount := Count;
        End
      Else
        SetverCount := 0;
    End
  Else
    SetverCount := 0;
End;


Function SetverText;

Var devSeg : Word;
    devOfs : Word;
    xWord1 : Word;
    xWord2 : Word;
    xByte  : Byte;
    Count  : Word;
    Count2 : Word;
    Count3 : Word;
    s      : String;
    s2     : String;

Begin
  SetverText := '';
  Count2 := 0;
  Regs.AH := $30;
  MsDos (Regs);
  If Regs.AL >= 5 Then
    Begin
      If LongInt (SetverList) <> 0 Then
        Begin
          Regs.AH:=$52;
          MSDOS (regs);
          devseg := Regs.ES;
          devofs := Regs.BX;
          xword1 := MemW [devseg : devofs + $39];
          xword2 := MemW [devseg : devofs + $37];
          while Mem[xword1:xword2] <> 0 do
            begin
              xbyte := Mem[xword1:xword2];
              Inc (xword2);
              s := '';
              For count := xword2 to xword2 + (xbyte - 1) do
                s := s + Chr (Mem[xword1 : count]);
              Inc (xword2, xbyte);

              S2 := '';
              For Count3 := Length (S) To 14 Do
                s2 := s2 + ' ';
              IF Count2 = TextNumber Then SetverText := s + s2 +
                StrFnByte (Mem[xword1:xword2]) + '.' +
                  ZeroPad (mem[xword1:xword2 + 1]);

              Inc(xword2, 2);
              Inc (Count2);
            End;
        End
      Else
        SetverText := NA;
    End
  Else
    SetverText := NA;
End;


Function IsIBMCache;

Var Count       : Byte;
    EndIt       : Boolean;
    IbmCacheBuf : pIBMCacheBuf;

Begin
  EndIt := False;
  GetMem (IBMCacheBuf, SizeOf (IBMCacheBuf^));

  For Count := $00 To $FF Do
    Begin
      IBMCacheBuf^.Version := 'EJF1';
      Regs.AH := $1D;
      Regs.AL := $01;
      Regs.DL := Count;
      Regs.ES := PtrRec(IBMCacheBuf).Seg;
      Regs.BX := PtrRec(IBMCacheBuf).Ofs;
      Intr ($13, Regs);
      If Not (IBMCacheBuf^.Version = 'EJF1') Then
        EndIt := True;
      If EndIt Then Exit;
    End;
  ISIBMCache := EndIt;
  FreeMem (IBMCacheBuf, SizeOf (IBMCacheBuf^));
End;


Function IBMCTotalRRequests;

Var D : Byte;
    IBMCacheBuf : pIBMCacheBuf;

Begin
  D := SMDNumber (Drive);

  GetMem (IBMCacheBuf, SizeOf (IBMCacheBuf^));

  If IsIBMCache Then
    Begin
      Regs.AH := $1D;
      Regs.AL := $01;
      Regs.DL := D;
      Regs.ES := PtrRec(IBMCacheBuf).Seg;
      Regs.BX := PtrRec(IBMCacheBuf).Ofs;
      Intr ($13, Regs);
      IBMCTotalRRequests := IBMCacheBuf^.TotalRRequests;
    End
  Else
    IBMCTotalRRequests := 0;

  FreeMem (IBMCacheBuf, SizeOf (IBMCacheBuf^));
End;


Function IBMCTotalHits;

Var D : Byte;
    IBMCacheBuf : pIBMCacheBuf;

Begin
  D := SMDNumber (Drive);

  GetMem (IBMCacheBuf, SizeOf (IBMCacheBuf^));

  If IsIBMCache Then
    Begin
      Regs.AH := $1D;
      Regs.AL := $01;
      Regs.DL := D;
      Regs.ES := PtrRec(IBMCacheBuf).Seg;
      Regs.BX := PtrRec(IBMCacheBuf).Ofs;
      Intr ($13, Regs);
      IBMCTotalHits := IBMCacheBuf^.TotalHits;
    End
  Else
    IBMCTotalHits := 0;

  FreeMem (IBMCacheBuf, SizeOf (IBMCacheBuf^));
End;


Function IBMCPhysicalDReads;

Var D : Byte;
    IBMCacheBuf : pIBMCacheBuf;

Begin
  D := SMDNumber (Drive);

  GetMem (IBMCacheBuf, SizeOf (IBMCacheBuf^));

  If IsIBMCache Then
    Begin
      Regs.AH := $1D;
      Regs.AL := $01;
      Regs.DL := D;
      Regs.ES := PtrRec(IBMCacheBuf).Seg;
      Regs.BX := PtrRec(IBMCacheBuf).Ofs;
      Intr ($13, Regs);
      IBMCPhysicalDReads := IBMCacheBuf^.PhysicalDReads;
    End
  Else
    IBMCPhysicalDReads := 0;

  FreeMem (IBMCacheBuf, SizeOf (IBMCacheBuf^));
End;


Function IBMCTotalSecReqDR;

Var D : Byte;
    IBMCacheBuf : pIBMCacheBuf;

Begin
  D := SMDNumber (Drive);

  GetMem (IBMCacheBuf, SizeOf (IBMCacheBuf^));

  If IsIBMCache Then
    Begin
      Regs.AH := $1D;
      Regs.AL := $01;
      Regs.DL := D;
      Regs.ES := PtrRec(IBMCacheBuf).Seg;
      Regs.BX := PtrRec(IBMCacheBuf).Ofs;
      Intr ($13, Regs);
      IBMCTotalSecReqDR := IBMCacheBuf^.TotalSecReqDR;
    End
  Else
    IBMCTotalSecReqDR := 0;

  FreeMem (IBMCacheBuf, SizeOf (IBMCacheBuf^));
End;


Function IBMCIsExtUsed;

Var D : Byte;
    IBMCacheBuf : pIBMCacheBuf;

Begin
  D := 0;

  GetMem (IBMCacheBuf, SizeOf (IBMCacheBuf^));

  If IsIBMCache Then
    Begin
      Regs.AH := $1D;
      Regs.AL := $01;
      Regs.DL := D;
      Regs.ES := PtrRec(IBMCacheBuf).Seg;
      Regs.BX := PtrRec(IBMCacheBuf).Ofs;
      Intr ($13, Regs);
      IBMCIsExtUsed := (IBMCacheBuf^.IsExtMem <> 0)
    End
  Else
    IBMCIsExtUsed := False;

  FreeMem (IBMCacheBuf, SizeOf (IBMCacheBuf^));
End;


Function IBMCVersion;

Var D : Byte;
    IBMCacheBuf : pIBMCacheBuf;

Begin
  D := 0;

  GetMem (IBMCacheBuf, SizeOf (IBMCacheBuf^));

  If IsIBMCache Then
    Begin
      Regs.AH := $1D;
      Regs.AL := $01;
      Regs.DL := D;
      Regs.ES := PtrRec(IBMCacheBuf).Seg;
      Regs.BX := PtrRec(IBMCacheBuf).Ofs;
      Intr ($13, Regs);
      IBMCVersion := IBMCacheBuf^.Version;
    End
  Else
    IBMCVersion := NA;

  FreeMem (IBMCacheBuf, SizeOf (IBMCacheBuf^));
End;


Function IBMCSize;

Var D : Byte;
    IBMCacheBuf : pIBMCacheBuf;

Begin
  D := 0;

  GetMem (IBMCacheBuf, SizeOf (IBMCacheBuf^));

  If IsIBMCache Then
    Begin
      Regs.AH := $1D;
      Regs.AL := $01;
      Regs.DL := D;
      Regs.ES := PtrRec(IBMCacheBuf).Seg;
      Regs.BX := PtrRec(IBMCacheBuf).Ofs;
      Intr ($13, Regs);
      IBMCSize := IBMCacheBuf^.Size;
    End
  Else
    IBMCSize := 0;

  FreeMem (IBMCacheBuf, SizeOf (IBMCacheBuf^));
End;


Function IBMCSectorsPage;

Var D : Byte;
    IBMCacheBuf : pIBMCacheBuf;

Begin
  D := 0;

  GetMem (IBMCacheBuf, SizeOf (IBMCacheBuf^));

  If IsIBMCache Then
    Begin
      Regs.AH := $1D;
      Regs.AL := $01;
      Regs.DL := D;
      Regs.ES := PtrRec(IBMCacheBuf).Seg;
      Regs.BX := PtrRec(IBMCacheBuf).Ofs;
      Intr ($13, Regs);
      IBMCSectorsPage := IBMCacheBuf^.Sectors_Page;
    End
  Else
    IBMCSectorsPage := 0;

  FreeMem (IBMCacheBuf, SizeOf (IBMCacheBuf^));
End;


Function AvaLevelSupp;

Begin
  If IsInstalled (AvatarSys) Then
    Begin
      Regs.AX := $1A00;
      Regs.BX := $4156;
      Regs.CX := $4154;
      Regs.DX := $4152;
      Intr ($2F, Regs);
      AvaLevelSupp := Regs.BX;
    End
  Else
    AvaLevelSupp := 0;
End;


Function AvaDriverType;

Begin
  If IsInstalled (AvatarSys) Then
    Begin
      Regs.AX := $1A00;
      Regs.BX := $4156;
      Regs.CX := $4154;
      Regs.DX := $4152;
      Intr ($2F, Regs);
      Case Regs.CX Of
        $0000 : AvaDriverType := 'AVATAR.SYS';
        $4456 : AvaDriverType := 'DVAVATAR.COM (DesqView)';
      End;
    End
  Else
    AvaDriverType := 'nicht installiert';
End;


Function TesPort;

Begin
  If IsInstalled (Tes) Then
    Begin
      Regs.AH := $A0;
      Regs.CX := $FFFF;
      Intr ($14, Regs);
      TesPort := Regs.DX;
    End
  Else
    TesPort := 0;
End;


Function IsIBMYaleESIO;

Begin
  Regs.AX := $F4FF;
  Regs.DX := PortNumber;
  Regs.Flags := Regs.Flags And FCarry;
  IsIBMYaleESIO := (((Regs.Flags And FCarry) = 0) And (Regs.AX = 0));
End;


Function SRDiskSuppDrives;

Var SrDiskHdr : pSrDiskHdr;

Begin
  If IsInstalled (SrDisk) Then
    Begin
      Regs.AX := $7200;
      Intr ($2F, Regs);
      SrDiskHdr := Ptr (Regs.ES, 0);
      SRDiskSuppDrives := SrDiskHdr^.SuppDrives;
    End
  Else
    SRDiskSuppDrives := 0;
End;


Function SRDiskMemType;

Var SrDiskHdr : pSrDiskHdr;

Begin
  If IsInstalled (SrDisk) Then
    Begin
      Regs.AX := $7200;
      Intr ($2F, Regs);
      SrDiskHdr := Ptr (Regs.ES, 0);
      SRDiskMemType := SrDiskHdr^.MemString;
    End
  Else
    SRDiskMemType := NA;
End;


Function SRDiskVersion;

Var SrDiskHdr : pSrDiskHdr;

Begin
  If IsInstalled (SrDisk) Then
    Begin
      Regs.AX := $7200;
      Intr ($2F, Regs);
      SrDiskHdr := Ptr (Regs.ES, 0);
      SRDiskVersion := SrDiskHdr^.Version;
    End
  Else
    SRDiskVersion := NA;
End;


Function SRDiskConfVersion;

Var SrDiskHdr : pSrDiskHdr;

Begin
  If IsInstalled (SrDisk) Then
    Begin
      Regs.AX := $7200;
      Intr ($2F, Regs);
      SrDiskHdr := Ptr (Regs.ES, 0);
      SRDiskConfVersion := SrDiskHdr^.ConfVersion;
    End
  Else
    SRDiskConfVersion := $FF;
End;


Function PCT5DeskHotkey;

Begin
  If IsInstalled (PCT5DeskTop) Then
    Begin
      Regs.AX := $FFFC;
      Intr ($16, Regs);
      Case Key Of
        dpcDesktopHotkey     : PCT5DeskHotkey := MemW [Regs.ES:Regs.BX + 0];
        dpcClipboardPasteKey : PCT5DeskHotkey := MemW [Regs.ES:Regs.BX + 2];
        dpcClipboardCopyKey  : PCT5DeskHotkey := MemW [Regs.ES:Regs.BX + 4];
        dpcScreenAutodialKey : PCT5DeskHotkey := MemW [Regs.ES:Regs.BX + 6];
      End;
    End
  Else
    PCT5DeskHotkey := 0;
End;


Function PCT7DeskColorSheme;

Begin
  If IsInstalled (PCT7CpShDesk) Then
    Begin
      EndString := '';
      Regs.AX := $FF9A;
      Intr ($16, Regs);
      For xWord := 0 To 255 Do
        Begin
          If Mem[Regs.ES:Regs.BX + xWord] <> 0 Then
            EndString := EndString + Char (Mem[Regs.ES:Regs.BX + xWord])
          Else
            Exit;
        End;
    End
  Else
    EndString := NA;
  PCT7DeskColorSheme := EndString;
End;


Function PCT6DeskVersion;

Begin
  If IsInstalled (PCT5Desktop) Then
    Begin
      Regs.AX := $FFA9;
      Regs.DS := $0000;
      Regs.SI := $0000;
      Intr ($16, Regs);
      If ((Regs.DS <> 0) And (Regs.SI <> 0)) Then
        Begin
          EndString := '';
          For xWord := 0 To 255 Do
            Begin
              If Mem[Regs.DS:Regs.SI + xWord] <> 0 Then
                EndString := EndString + Char (Mem[Regs.ES:Regs.BX + xWord])
              Else
                Exit;
            End;
        End
      Else
        EndString := 'falsche Version';
    End
  Else
    EndString := NA;

  PCT6DeskVersion := EndString;
End;


Function PCT5DeskIsResident;

Begin
  If IsInstalled (PCT5Desktop) Then
    Begin
      Regs.AX := $FFC5;
      Intr ($16, Regs);
      PCT5DeskIsResident := (Regs.BL <> 0);
    End
  Else
    PCT5DeskIsResident := False;
End;


Function PCT6CacheIsDrive (Drive : Char) : Boolean;

Begin
  If IsInstalled (PCT6Cache) Then
    Begin
      PCT6CacheIsDrive := False;
      Regs.AX := $FFA5;
      Regs.CX := $1111;
      Intr ($16, Regs);
      For xWord := $1C DownTo 0 Do
        If Upcase (Char (Mem [Regs.ES : Regs.DI + xWord])) = UpCase (Drive)
          Then PCT6CacheIsDrive := True;
    End
  Else
    PCT6CacheIsDrive := False;
End;


Function MDPIsForeGround;

Begin
  If IsInstalled (MultiDos) Then
    Begin
      Regs.AH := $14;
      Intr ($15, Regs);
      MDPIsForeGround := (Regs.AX = $0001);
    End
  Else
    MDPIsForeground := False;
End;


Function MDPIsMultiTasking;

Begin
  If IsInstalled (MultiDos) Then
    Begin
      Regs.AH := $20;
      Intr ($15, Regs);
      MDPIsMultiTasking := (Regs.AX = $0000);
    End
  Else
    MDPIsMultiTasking := False;
End;


Function IsQuickCacheII : Boolean;

Begin
  Regs.AX := $2700;
  Regs.BX := 0;
  Intr ($13, Regs);
  IsQuickCacheII := ((Regs.AX = 0) And (Regs.BX <> 0))
End;


Function QuickCacheIIVer : String;

Begin
  IF IsQuickCacheII Then
    Begin
      Regs.AX := $2700;
      Regs.BX := 0;
      Intr ($13, Regs);
      QuickCacheIIVer := StrFnByte (Regs.BH) + '.' + StrFnByte (Regs.BL);
    End
  Else
    QuickCacheIIVer := NA;
End;


Function GetQuickCacheIIInfo (InfoNumber : Byte) : Pointer;

Var P : Pointer;

Begin
  If IsQuickCacheII Then
    Begin
      Regs.AH := $30;
      Case InfoNumber Of
        1 : Begin
              Regs.AL := 0;
              GetMem (P, SizeOf (tQuickCacheIISystemInfo));
            End;
        2 : Begin
              Regs.AL := 1;
              GetMem (P, SizeOf (tQuickCacheIIDriveInfo));
            End;
      Else
        Begin
          Regs.Al := 0;
          GetMem (P, SizeOf (tQuickCacheIISystemInfo));
        End;
      End;
      Regs.DS := PtrRec(P).Seg;
      Regs.DX := PtrRec(P).Ofs;
      Intr ($13, Regs);
      If Not (Regs.AX = $8000) Then GetQuickCacheIIInfo := P Else
        Begin
          Case InfoNumber Of
            1 : FreeMem (P, SizeOf (tQuickCacheIISystemInfo));
            2 : FreeMem (P, SizeOf (tQuickCacheIIDriveInfo));
          Else
            FreeMem (P, SizeOf (tQuickCacheIISystemInfo));
          End;

          GetQuickCacheIIInfo := Ptr (0,0);
        End;
    End
  Else
    GetQuickCacheIIInfo := Ptr (0,0);
End;


Function EnvSeg : Word;

Begin
  xWord := MemW [PrefixSeg : $16];
  xBool := false;
  While Not xBool Do
    Begin
      xWord2 := MemW [xWord : $16];
      If (xWord2 = 0) Or (xWord2 = xWord) Then
        xBool := True
      Else
        xWord := xWord2;
    End;
  xWord := MemW [xWord : $2C];
  If (xWord = 0) Or ((Lo (Dos.DosVersion) > 19) And (Lo (Dos.DosVersion) < 30)) Then
    xWord := xWord + MemW [xWord - 1 : 3] + 1;
  EnvSeg := xWord;
End;


Function EnvLen : Word;

Begin
  EnvLen := MemW [EnvSeg - 1 : 3] * 16;
End;


Function EnvUsed : Word;

Begin
  xWord3 := 0;
  xBool2 := false;
  While Not xBool2 Do
    If MemW [EnvSeg : xWord3] = 0 Then
      xBool2 := True
    Else
      Inc (xWord3);
  Inc (xWord3, 2);
  EnvUsed := xWord3;
End;


Begin
End.