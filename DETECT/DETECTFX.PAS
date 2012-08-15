Unit DetectFX;

{$X+}

Interface

Function IsSB          : Boolean;
Function WhatSBPort    : Word;
Function WhatSBVersion : String;
Function WhatSBType    : Byte;
Function IsAdlib       : Boolean;
Function IsAdlibDriver : Boolean;
Function AdlibDrvVer   : String;
Function AdlibDrvAdr   : Pointer;
Function IsMPU401      : Boolean;
Function IsGUS         : Boolean;
Function GUS_Port      : Word;
Function GUS_Memory    : Word;

Function IsVBEAI                      : Boolean;
Function VBEAIVersion                 : String;
Function VBEAILDevice (Device : Word) : Word;
Function VBEAIGetInfo (Handle : Word; Data : Byte; Var L : LongInt) : Pointer;

Type pVBEAIWave = ^VBEAIWave;
     VBEAIWave = Record
       StrucName   : Array [1..4] Of Char; { 'GENI' fr GeneralDeviceClass  }
       StrucLength : LongInt; { Wie lang ist dieser Record ?                }
       DeviceType  : Word; { Hierbei wohl 1 = Wave (2 wrde MIDI bedeuten)  }
       BCDVersion  : Word; { Versionsnummer des Treibers im BCD-Format      }
       { Hier f„ng die Wave-Struktur an }
       WavStrucName   : Array [1..4] Of Char; { 'WAVI' fr Wave Interface   }
       WavStrucLength : LongInt; { Sollte eigentlich 0000007Eh sein.        }
       WavDrivVersion : LongInt; { z.Zt 00000003h                           }
       VendorName     : Array [1..32] Of Char; { Der Herstellername ...     }
       ProductName    : Array [1..32] Of Char; { Der Produktname ...        }
       ChipDescript   : Array [1..32] Of Char; { Produkt/Chip-Beschreibung  }
       BoardNumber    : Byte; { Nummer des Boards (?!?)                     }
       Unused         : Array [1..3] Of Byte; { Noch nicht benutzt          }
       Features       : LongInt; { FeatureDWord :                           }
         { Bit   Feature
          0      8000hz Mono Playback
          1      8000hz Mono Record
          2      8000hz Stereo Record
          3      8000hz Stereo Playback
          4      8000hz Full Duplex Play/Record
          5      11025hz Mono Playback
          6      11025hz Mono Record
          7      11025hz Stereo Record
          8      11025hz Stereo Playback
          9      11025hz Full Duplex Play/Record
          10     22050hz Mono Playback
          11     22050hz Mono Record
          12     22050hz Stereo Record
          13     22050hz Stereo Playback
          14     22050hz Full Duplex Play/Record
          15     44100hz Mono Playback
          16     44100hz Mono Record
          17     44100hz Stereo Record
          18     44100hz Stereo Playback
          19     44100hz Full Duplex Play/Record
          20-26  reserviert (0)
          27     Driver muá die Daten vor Ausgabe noch behandeln
          28     Variable Sample mono   playback
          29     Variable Sample stereo playback
          30     Variable Sample mono   record
          31     Variable Sample stereo record }
       PrefField      : Word; { Vom User definiertes Preference-Feld (?!?)  }
       MemRequired    : Word; { Memory-Verbrauch beim Benutzen des Treibers }
       Ticks          : Word; { Wieviele Timer-Tick-Callbacks pro Sekunde ? }
       Channels       : Word; { Kan„le (1 = Mono, 2 = Stereo)               }
       MaxSampleSizes : Word; { Maximale Samplegr”áe :                      }
         { Wert     Gr”áe
           01h      8bit play
           02h      16bit play
           10h      8bit record
           20h      16bit record }
     End;

     pVBEAIMidi = ^VBEAIMidi;
     VBEAIMidi = Record
       StrucName   : Array [1..4] Of Char; { 'GENI' fr GeneralDeviceClass  }
       StrucLength : LongInt; { Wie lang ist dieser Record ?                }
       DeviceType  : Word; { Hierbei wohl 2 = Midi (1 wrde Wave bedeuten)  }
       BCDVersion  : Word; { Versionsnummer des Treibers im BCD-Format      }
       { Hier f„ng die Wave-Struktur an }
       MidiStrucName   : Array [1..4] Of Char; { 'MIDI' fr Midi-Interface  }
       MidiStrucLength : LongInt; { L„nge dieses Records                    }
       MidiDrivVersion : LongInt; { z.Zt. 00000003h                         }
       VendorName     : Array [1..32] Of Char; { Der Herstellername ...     }
       ProductName    : Array [1..32] Of Char; { Der Produktname ...        }
       ChipDescript   : Array [1..32] Of Char; { Produkt/Chip-Beschreibung  }
       BoardNumber    : Byte; { Nummer des Boards (?!?)                     }
       Unused         : Array [1..3] Of Byte; { Noch nicht benutzt          }
       PatchLib       : Array [1..14] Of Char; { Filename des Patch-Libs.   }
       Features       : LongInt; { FeatureDWord :                           }
       { Bit      Feature
         0-3      reserviert for General Midi-Erweiterungen
         4        nur Transmitter/Receiver
         5        Patches vorgeladen
         6        MIDI-Empfang arbeitet mit Time-Stamp
         8        MIDI Interruptgesteuerte Eingabe m”glich
         9        MIDI Poll-Input untersttzt
         10       MIDI Remote-patches untersttzt }
       PrefField      : Word; { Vom User definiertes Preference-Feld (?!?)  }
       MemRequired    : Word; { Memory-Verbrauch beim Benutzen des Treibers }
       Ticks          : Word; { Wieviele Timer-Tick-Callbacks pro Sekunde ? }
       Tones          : Word; { Maximale Anzahl der T”ne (voices/partials)  }
     End;

     pVBEAIVolInfo = ^VBEAIVolInfo;
     VBEAIVolInfo = Record
       StrucName    : Array [1..4] Of Char; { 'VOLI' fr Volume Information }
       StrucLength  : LongInt; { L„nge dieses Records (z.Zt. 00000092h)     }
       DrivVersion  : LongInt; { Treiber-Version (z.Zt. 00000001h)          }
       VendorName   : Array [1..32] Of Char; { Der Herstellername ...       }
       ProductName  : Array [1..32] Of Char; { Der Produktname ...          }
       ChipDescript : Array [1..32] Of Char; { Produkt/Chip-Beschreibung    }
       BoardNumber  : Byte; { Nummer des Boards (?!?)                       }
       Unused       : Array [1..3] Of Byte; { (noch) unbenutzt              }
       MixerText    : Array [1..24] Of Char; { Textname des Mixerchannels   }
       Features     : LongInt; { FeatureDWord :                             }
         { Bit     Feature
           0       Stereo Volume Control verfgbar
           2       Low Pass Filter ist verfgbar
           3       High Pass Filter ist verfgbar
           4       Parametric Tone Control ist verfgbar
           5       Selektierbaer Output-Pfade untersttzt
           8       Azimuth Field Positioning untersttzt
           9       Phi Field Positioning untersttzt
           10-30   nicht benutzt ?!??
           31      Master Volume device }
       MinVol       : Word; { Minimales Volume-Setting                      }
       MaxVol       : Word; { Maximales Volume-Setting                      }
       GainCrossov  : Word; { Attenuation/Gain Crossover                    }
     End;

Implementation

Uses Dos, DetectGlobal, DetectConstants;

Const Dsp_Adr : Word = $220;
      SbRegDetected : Boolean = False;
      MixerDetected : Boolean = False;

Var
  GusFound  : boolean;
  GusPort   : word;
  GusMemory : Word;

Procedure Wr_dsp(v : byte);

Begin;
  While Port[dsp_adr+$c] >= 128 Do;
  Port[dsp_adr+$c] := V;
End;


Function SbReadByte : Byte;

Begin;
  While Port[dsp_adr+$a] = $AA Do;
    SbReadByte := Port[dsp_adr+$a];
End;


Procedure SBreset;

Var bt   : Byte;
    ct   : Byte;
    stat : Byte;

Begin;
  Port[dsp_adr+$6] := 1;
  For ct := 1 To 100 Do;
  Port[dsp_adr+$6] := 0;
  bt := 0;
  Repeat
    ct := 0;
    Repeat
      stat := Port[dsp_adr + $E];
    Until (ct > 8000) Or (stat >= 128);
    inc(bt);
  Until (bt > 100) Or (Port[dsp_adr + $A] = $AA);
End;


Function Reset_SBCard : Boolean;

Const  ready = $AA;

Var ct   : Byte;
    stat : Byte;

Begin
  Port[dsp_adr+$6] := 1;
  For ct := 1 To 100 Do;
  Port[dsp_adr+$6] := 0;
  stat := 0;
  ct   := 0;
  While (stat <> ready) And (ct < 100) Do
    Begin { Der Vergleich ct < 100, da die Initialisierung ca. 100ms dauert }
      stat := PORT[dsp_adr+$E];
      stat := PORT[dsp_adr+$a];
      INC(ct);
    End;
  Reset_SBCard := (stat = ready);
End;


Function Detect_SBReg : Boolean;

Var
  Port, Lst : WORD;

Begin
 Detect_SBReg := SbRegDetected;
 If SbRegDetected Then Exit;            { Exit, wenn initialisiert   }
 Port := $210;                     { M”gliche SB-Adressen zwi-  }
 Lst  := $280;                       { schen $210 und $280 !      }
 While (Not SbRegDetected) And (Port <= Lst) Do
   Begin
     dsp_adr := Port;
     SbRegDetected := Reset_SBCard;
     If Not SbRegDetected Then Inc(Port, $10);
   End;
 Detect_SBReg := SbRegDetected;
End;


Function Detect_Mixer_sb16 : Boolean;

Var SaveReg : Word;
    NewReg  : Word;

Begin
  Detect_SBReg;
  Detect_Mixer_Sb16 := MixerDetected;
  If (Not SbRegDetected) Or MixerDetected Then EXIT;
          { Abbruch, wenn keine Soundblaster-Karte vorhanden oder Mixer-Chip
            schon initialisiert }
  Asm
    mov dx,dsp_adr+$4  { \                                                 }
    mov al,0           {   \                                               }
    out dx,al          {     \                                             }
    mov cx,50          {       \ Mixer-Reset Mixer-Reset Mixer-Reset       }
  @loop:               {       / Mixer-Reset Mixer-Reset Mixer-Reset       }
    loop @loop         {     /                                             }
    inc dx             {   /                                               }
    out dx,al          { /                                                 }
  End;

  Port[dsp_adr+$4] := $22;              { Register sichern           }
  SaveReg := Port[dsp_adr+$5];
  Port[dsp_adr+$4] := $22;              { Wenn der geschriebene Wert }
  Port[dsp_adr+$5] := 243;              { mit dem zurckgelesenen    }
  Port[dsp_adr+$4] := $22;              { bereinstimmt, so ist ein  }
  NewReg := Port[dsp_adr+$5];           { Zugriff m”glich und somit  }
                                        { ein Mixer vorhanden        }
  If NewReg = 243 Then MixerDetected := TRUE;

  Port[dsp_adr+$4] := $22;              { Altes Register zurck      }
  Port[dsp_adr+$5] := SaveReg;

  Detect_Mixer_sb16 := MixerDetected;
END;


Function IsSb;

Var xByte1 : Byte;
    xByte2 : Byte;
    xByte3 : Byte;
    xWord1 : Word;
    xWord2 : Word;
    sbFound : Boolean;
    sbPort : Word;
    PortOk : Boolean;

Begin
  xByte1:=1;
  sbFound := False;
  While (xbyte1 < 7) And (Not sbfound) Do
    Begin
      sbport:=$200 + ($10 * xbyte1);
      xword1:=0;
      portok:=false;
      xword2:=sbport + $0C;
      While (xword1 < $201) And (Not portok) Do
        Begin
          If (Port[xword2] And $80) = 0 Then
            portok:=true;
          Inc(xword1)
        End;
      If portok Then
        Begin
          xByte3:=Port[xword2];
          Port[xword2]:=$D3;
          For xword2:=1 To $1000 Do {nothing};
          xWord2:=sbport + 6;
          Port[xword2]:=1;
          xbyte2:=Port[xword2];
          xbyte2:=Port[xword2];
          xbyte2:=Port[xword2];
          xbyte2:=Port[xword2];
          Port[xword2]:=0;
          xword2:=sbport + $0E;
          xbyte2:=0;
          Repeat
            xword1:=0;
            portok:=false;
            While (xword1 < $201) And (Not portok) Do
              Begin
                If (Port[xword2] And $80) = $80 Then
                  PortOk:=True;
                Inc(xword1)
              End;
            If portok Then
            If Port[sbport + $0A] = $AA Then
              Sbfound:=true;
            Inc(xbyte2);
          Until (xbyte2 = $10) Or (portok);
          Port[xword2]:=xbyte3;
        End;
      If sbfound then
        IsSb := True
      Else
        Inc(xbyte1);
    End;
  If sbfound then IsSb := True Else IsSB := False;
End;


Function WhatSBPort;

Begin
  Detect_SBReg;
  If SbRegDetected Then WhatSBPort := Dsp_Adr Else WhatSBPort := 0;
End;


Function WhatSBVersion;

Var EndString : String[5];
    E : Byte;

Begin
  If SbRegDetected Then
    Begin
      Wr_dsp($E1);
      EndString := StrFnByte (SbReadByte) + '.';
      E := SbReadByte;
      If E > 9 Then
        EndString := EndString + StrFnByte (E)
      Else
        EndString := EndString + '0' + StrFnByte (E);
    End
  Else WhatSBVersion := 'nicht vorhanden';
  WhatSBVersion := EndString;
End;


Function WhatSBType;

  Function Versmaj : Byte;

  Begin
    Wr_dsp($E1);
    VersMaj := SBReadByte;
    SBReadByte;
  End;


Begin
  Detect_SBReg;
  If Not SbRegDetected Then WhatSBType := dsbNone;
  If SbRegDetected Then WhatSBType := dsbNormal;
  If SbRegDetected And Detect_Mixer_sb16 Then WhatSBType := dSbPro;
  If SbRegDetected And Detect_Mixer_sb16 And (VersMaj > 4) Then WhatSBType := dSb16ASP;
  If WhatSBVersion = '12.12' Then WhatSBType := dsb16;
End;


Function IsAdlib;

Var xByte1 : Byte;
    xByte2 : Byte;
    xByte3 : Byte;
    xByte4 : Byte;

Begin
  xbyte2:=Port[$388];
  Port[$388]:=$BD;
  xbyte1:=Port[$388];
  xbyte1:=Port[$388];
  xbyte1:=Port[$388];
  xbyte1:=Port[$388];
  xbyte3:=Port[$389];
  Port[$389]:=0;
  For xbyte4:=1 To 36 Do
    xbyte1:=Port[$388];
  xbyte1:=xbyte1 And 7;
  Port[$388]:=xbyte2;
  Port[$389]:=xbyte3;
  If xByte1 = 6 Then IsAdlib := True Else IsAdlib := False;
End;


Function IsAdlibDriver;

Var s : String;
    xWord : Word;

Begin
  If IsAdlib Then
    Begin
      Regs.AX:=$3565;
      MsDos(regs);
      s:='';
      For xWord:=(Regs.BX - $16) To (Regs.BX - 4) Do
        s:=s + Chr(Mem[Regs.ES:xword]);
      if s = 'SOUND-DRIVER-AD-LIB' then IsAdlibDriver := True Else
        IsAdlibDriver := False;

    End
  Else
    IsAdlibDriver := False;
End;


Function AdlibDrvVer;

Begin
  If IsAdlibDriver Then
    AdlibDrvVer := Hex(unBCD(Mem[Regs.ES:Regs.BX - $17]),2)+ '.'+ Hex(unBCD(Mem[Regs.ES:Regs.BX - $18]),2)
  Else
    AdlibDrvVer := 'nicht vorhanden';
End;


Function AdlibDrvAdr;

Begin
  If IsAdlibDriver Then
    Begin
      AdlibDrvAdr := Ptr (Regs.ES, Regs.BX);
    End
  Else
    AdlibDrvAdr := Ptr (0,0);
End;


Function IsMPU401;

Begin
  IsMPU401  := False;
  xBool     := False;
  xbyte1    := 0;

  Repeat
    If (Port[$331] And $40) = 0 then
      xBool := true;
    Inc (xByte1);
  Until (xByte1 = 255) or xBool;

  If xBool Then
    Begin
      Inline ($FA); {CLI}
      xByte2 := Port[$331];
      Port [$331] := $FF;
      xBool := false;
      xbyte1 := 0;
      Repeat
        If (Port[$331] And $80) = 0 Then
          xBool := True;
        Inc (xbyte1);
      Until (xbyte1 = 255) or xBool;

      xbyte1:=Port[$330];
      inline($FB); {STI}

      if xBool and (xbyte1 = $FE) then
        IsMPU401 := true
      else
        Port[$331]:=xbyte2;
    end
  Else
    IsMPU401 := False;
End;


Procedure GusDelay;

Begin
  Asm
    mov dx,$300
    in al,dx
    in al,dx
    in al,dx
    in al,dx
    in al,dx
    in al,dx
    in al,dx
  End;
End;


Procedure GusPoke (high: byte; low: word; value: byte);

Begin
  Port[GusPort + $103]  := $43;
  PortW[GusPort + $104] := low;
  Port[GusPort + $103]  := $44;
  Port[GusPort + $105]  := high;
  Port[GusPort + $107]  := value;
End;


Function GusPeek (high: byte; low: word) : byte;

Begin
  Port[GusPort + $103]  :=$43;
  PortW[GusPort + $104] :=low;
  Port[GusPort + $103]  :=$44;
  Port[GusPort + $105]  :=high;
  GusPeek:=Port[GusPort + $107];
End;


Function IsGUS;

Begin
  GusFound := False;
  xbyte1 := 1;
  While (xbyte1 < 7) And (Not GusFound) Do
    begin
      GusPort:=$200 + ($10 * xbyte1);
      xbyte3:=Port[GusPort + $103];
      xbyte4:=Port[GusPort + $104];
      xbyte5:=Port[GusPort + $105];
      xbyte6:=Port[GusPort + $106];
      xbyte7:=Port[GusPort + $107];
      Port[GusPort + $103]:=$4C;
      Port[GusPort + $105]:=0;
      GusDelay;
      GusDelay;
      Port[GusPort + $103]:=$4C;
      Port[GusPort + $105]:=1;
      GusPoke(0, 0, $AA);
      GusPoke(1, 0, $55);
      xbyte2:=GusPeek(0, 0);
      GusPoke(0, 0, 0);
      Port[GusPort + $103]:=$4C;
      Port[GusPort + $105]:=0;

      If xbyte2 = $AA then
        Begin
          GusFound := True;
          xbyte3:=0;
          xBool := false;
          while (xbyte3 <= 4) and (not xBool) do
            begin
              if xbyte3 <> 4 then
                begin
                  GusPoke(xbyte3 * 4, 0, $AA);
                  xbyte2:=GusPeek(xbyte3 * 4, 0);
                end
              else
                begin
                  GusPoke($F, $FFFF, $AA);
                  xbyte2:=GusPeek($F, $FFFF);
                end;
              if xbyte2 <> $AA then
                begin
                  xBool := True;
                  GusMemory := xbyte3 * 256;
                end;
            end;
        end
      else
        begin
          Port[GusPort + $103]:=xbyte3;
          Port[GusPort + $104]:=xbyte4;
          Port[GusPort + $105]:=xbyte5;
          Port[GusPort + $106]:=xbyte6;
          Port[GusPort + $107]:=xbyte7;
          Inc(xbyte1);
        end;
    end;

  IsGUS := GusFound;
End;


Function GUS_Port;

Begin
  If IsGUS Then
    Begin
      Gus_Port := GusPort;
    End
  Else
    Gus_Port := 0;
End;


Function GUS_Memory;

Begin
  If IsGUS Then
    Begin
      Gus_Memory := GusMemory;
    End
  Else
    Gus_Memory := 0;
End;


Function IsVBEAI       : Boolean;

Begin
  Regs.AX := $4F13;
  Regs.BX := $0000;
  Intr ($10, Regs);
  IsVBEAI := (Regs.AL = $4F);
End;


Function VBEAIVersion  : String;

Begin
  If IsVBEAI Then
    Begin
      Regs.AX := $4F13;
      Regs.BX := $0000;
      Intr ($10, Regs);
      If (Regs.AH = 0) And (Regs.BX = $0010) Then VBEAIVersion := '1.00' Else
        VBEAIVersion := 'unbekannt';
    End
  Else
    VBEAIVersion := NA;
End;



Function VBEAILDevice (Device : Word) : Word;

Begin
  If IsVBEAI Then
    Begin
      Regs.AX := $4F13;
      Regs.BX := 1;
      Regs.CX := 0;
      Regs.DX := Device;
      Intr ($10, Regs);
      If (Regs.AL = $4F) And (Regs.AH = 0) Then VBEAILDevice := Regs.CX;
    End
  Else
    VBEAILDevice := 0;
End;


Function VBEAIGetInfo (Handle : Word; Data : Byte; Var L : LongInt) : Pointer;

Var EndPointer : Pointer;

Begin
  VBEAIGetInfo := Ptr (0,0);
  If IsVBEAI Then
    Begin
      Regs.AX := $4F13;
      Regs.BX := 2;
      Regs.CX := Handle;
      Case Data Of
        daiGENI : Regs.DX := 1;
        daiVOLI : If Handle = VBEAILDevice (daiVolume) Then Regs.DX := 3 Else Exit;
      End;
      Intr ($10, Regs);
      If (Regs.AL = $4F) And (Regs.AH = 0) Then
        Begin
          L := LongInt (Regs.SI) Shl 16 + Regs.DI;
        End
      Else
        Exit;

      GetMem (EndPointer, L);
      Regs.AX := $4F13;
      Regs.BX := 2;
      Regs.CX := Handle;
      Case Data Of
        daiGENI : Regs.DX := 2;
        daiVOLI : If Handle = VBEAILDevice (daiVolume) Then Regs.DX := 4 Else Exit;
      End;
      Regs.SI := PtrRec(EndPointer).Seg;
      Regs.DI := PtrRec(EndPointer).Ofs;
      Intr ($10, Regs);
      If (Regs.AL = $4F) And (Regs.AH = 0) Then VBEAIGetInfo := EndPointer Else
        FreeMem (EndPointer, L);
    End;
End;

Begin
End.