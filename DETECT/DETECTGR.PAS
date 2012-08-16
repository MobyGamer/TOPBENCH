{$O+,F+,E-,N-}
Unit DetectGraphics;
{
20111012, trixter@oldskool.org: Cirrus Logic detection was false-positiving
so I moved it to be the last block tested.
20111015, trixter: DetectGraph detection is bloated and nearly useless;
added source compile directive "SVGAONLY" to restrict detection to SVGA only
for those of us who have better detection routines.
"
}

{$DEFINE SVGAONLY}
{{$DEFINE SVGADEBUG}

Interface

{$IFNDEF SVGAONLY}
Function WhatGCard                       : String;
{$ELSE}
Function WhatSVGACard                    : String;
{$ENDIF}
Function WhatGCardNumber                 : Byte;
Function VesaInf (InfoNumber : Byte)     : String;
Function VESAIsVidMode (Mode : Word)     : Boolean;
Function VESAVidModeString (Mode : Word; Z : Byte) : String;
Function GraInf (InfoNumber : Byte)      : String;
Function WhatRamDac                      : String;

Function ScanLinesChar                : Word;
Function ScanLinesCursor              : String;
Function GetFontAddress (FontNumber : Byte) : Pointer;
Function GetPaletteRegister (Color : Byte) : Byte;

Function VideoWaits                   : Word;
Function BiosSpeed                    : Real;
Function DosSpeed                     : Real;

Function TestVertHz                   : Word;
Function TestHorizHz                  : Real;

Function IsDGIS                       : Boolean;

Implementation

Uses
  Dos,
  {$IFNDEF SVGAONLY}
  Graph,
  {$ENDIF}
  DetectGlobal,
  DetectConstants,
  DetectBios,
  DetectTime;

Type { Die folgenden 2 Records werden fÅr die VESA-Funktionen gebraucht. }

     VESAitype = record
       signature    : array[0..3] of char;
       version      : word;
       OEMnameOfs   : word;
       OEMnameSeg   : word;
       capabilities : array[0..3] of byte;
       modesOfs     : word;
       modesSeg     : word;
       Mem64k       : Word;
       reserved     : array[0..235] of byte;
     end;

     VESAmtype = record
       modeattr   : word;
       winaattr   : byte; { Window A attributes }
       winbattr   : byte; { Window B attributes }
       wingran    : word; { Window Granularity }
       winsize    : word; { Window Size }
       winaseg    : word; { Window A segment }
       winbseg    : word; { Window B segment }
       posOfs     : word; { Offset of Far call to positioning function }
       posSeg     : word; { Segment .. }
       scansize   : word; { Bytes per scan line }
       { Die folgenden Daten sind optional fÅr VESA-Modes, vorausgesetzt
        bei OEM-Modes }
       pixwidth   : word;
       pixheight  : word;
       charwidth  : byte;
       charheight : byte;
       memplanes  : byte;
       pixelbits  : byte;
       banks      : byte;
       memmodel   : byte;
       banksize   : byte;
       imagepages : byte;
       reserved   : array[0..225] of byte;
     end;


Const CardNumber : Word = 0;

Var ScreenAddr     : Pointer;
    EMS_BASE       : Word;
    ExpandedMem    : Boolean;
    ExtendedMem    : Boolean;
    VESAinfo       : VESAitype;
    VESAmode       : VESAmtype;
    DAC_RS2        : Word;
    DAC_RS3        : Word;

    C              : char;

{ Die folgende Funktion ist nur fÅr die VESA-Informationen relevant. }

Procedure LoadVESARecords;

Begin
  Regs.AX:=$4F00;
  Regs.ES:=Seg(VESAinfo);
  Regs.DI:=Ofs(VESAinfo);
  Intr($10, regs);
  Regs.AX:=$4F01;
  Regs.CX:=xword1;
  Regs.ES:=Seg(VESAmode);
  Regs.DI:=Ofs(VESAmode);
  Intr($10, regs);
End;


{$IFDEF SVGAONLY}
Function WhatSVGACard;
{$ELSE}
Function WhatGCard;
{$ENDIF}

  {$IFDEF SVGADEBUG}
  Function IntToStr(i:integer):string;
  Var
    S:string[12];
  Begin
    Str(I,S);
    IntToStr:=S;
  End;

  procedure DebugStatus(s:string);
  begin
    writeln('Debug: ',s);
  end;
  {$ENDIF}

  Function readROM (seg, ofs: word; length: byte) : string;

  Var x : word;

  Begin
    s:='';
    For x := ofs to ofs + (length - 1) do
      s := s + Chr(Mem[seg:x]);
    readROM:=s
  End;


  Procedure cli;
    Inline($FA);


  Procedure sti;
    Inline($FB);


  function testinx2(pt,rg,msk:word):boolean;   {Gibt True zurÅck, wenn die
                                                Bits in MSK Les/Schreibbar
                                                sind. }
  var old,nw1,nw2:word;

  begin
    Port[Pt] := Rg;
    old:=Port[pt+1];

    Port[Pt] := Rg;
    Port[Pt+1] := Old And Not Msk;

    Port[Pt] := Rg;
    nw1:=Port[Pt+1] and msk;

    Port[Pt] := Rg;
    Port[Pt+1] := Old Or Msk;

    Port[Pt] := Rg;
    nw2:=Port[Pt+1] and msk;

    Port[Pt] := Rg;
    Port[Pt+1] := Old;

    testinx2:=(nw1=0) and (nw2=msk);
  end;


  function testreg (pt,msk : word) : boolean;   {Gibt True zurÅck, wenn die
                                                Bits in MSK Les/Schreibbar
                                                sind. }
  var old,nw1,nw2:word;

  begin
    old:=Port[pt];
    Port[Pt] := Old And Not Msk;
    nw1:=Port[Pt] and msk;
    Port[Pt] := Old Or Msk;
    nw2:=Port[Pt] and msk;
    Port[Pt] := Old;
    testreg:=(nw1=0) and (nw2=msk);
  end;


  function rdinx(pt,inx:word):word;       {Liest Register PT with Index INX}
  var
    x:word;
  begin
    {$IFDEF SVGADEBUG}debugstatus('rdinx pt:'+hex(pt,4)+' inx:'+inttostr(inx));{$ENDIF}
    if pt=$3C0
      then x:=Port[$3D0+6];    {If Attribute Register then reset Flip-Flop}
    Port[pt]:=inx;
    rdinx:=Port[pt+1];
  end;

  procedure wrinx(pt,inx,val:word);  {Schreibt Val with Index INX auf Register PT}
  var
    x:word;
  begin
    {$IFDEF SVGADEBUG}debugstatus('wrinx pt:'+hex(pt,4)+' inx:'+inttostr(inx)+' val: '+inttostr(val));{$ENDIF}
    if pt=$3C0 then begin
      x:=Port[$3D0+6];
      Port[pt] := inx;
      Port[pt+1] := val;
    end else begin
      Port[pt] := inx;
      Port[pt+1] := val;
    end;
  end;


  procedure setinx(pt,inx,val:word);

  var x : word;

  begin
    x := rdinx (pt, inx);
    wrinx (pt, inx, x or val);
  end;

  procedure modinx(pt,inx,mask,nwv:word);  {In register PT index INX sets
                                            the bits in MASK as in NWV
                                            the other are left unchanged}
  var temp : word;

  begin
    temp := (rdinx (pt, inx) and (not mask)) + (nwv and mask);
    wrinx (pt, inx, temp);
  end;


  Function IsXGA: word;

  Var
    POSport, cardID, tmpw       : word;
    tmp, tmp1, tmp2, tmp3, tmp4 : byte;
    slot                        : byte;
    foundit                     : boolean;

  begin
    isXGA:=0;
    foundit:=false;
    with regs do
      begin
        DX:=$FFFF;
        AX:=$C400;
        Intr($15, regs);
        if (not (Regs.Flags And FCarry=0)) or (DX = -1) then
          Exit;
        posport:=DX;
        slot:=0;
        repeat
          cli;
          if slot = 0 then
            Port[$94]:=$DF
          else
            begin
              AX:=$C401;
              BX:=slot;
              Intr($15, regs)
            end;
          cardID:=PortW[POSport];
          tmp1:=Port[POSport + 2];
          tmp2:=Port[POSport + 3];
          tmp3:=Port[POSport + 4];
          tmp4:=Port[POSport + 5];
          if slot = 0 then
            Port[$94]:=$FF
          else
            begin
              AX:=$C402;
              BX:=slot;
              Intr($15, regs);
            end;
          cli;
          if (cardID >= $8FD8) and (cardID <= $8FDB) then
            begin
              tmpw:=tmp1 and $E;
              POSport:=(tmpw shl 3) + $2100;
              Port[POSport + $A]:=$52;
              tmp:=Port[POSport + $B] and $F;
              if (tmp <> 0) and (tmp <> $F) then
                foundit:=true
              else
                Inc(slot);
            end
          else
            Inc(slot);
        until foundit or (slot > 9);
      end;
    if foundit then
      IsXGA:=POSport;
  End;

  procedure isport2(var regs: registers; var foundit: boolean);

  var
    savebx, saveax: word;
    tmp: byte;

  begin
    with regs do
      begin
        savebx := BX;
        BX := AX;
        Port[DX] := AL;
        AH := AL;
        AL := Port[DX + 1];
        tmp := AH;
        AH := AL;
        AL := tmp;
        saveax := AX;
        AX := BX;
        PortW[DX] := AX;
        Port[DX] := AL;
        AH := AL;
        AL := Port[DX + 1];
        AL := AL and BH;
        foundit := (AL = BH);
        if AL = BH then
          begin
            AL := AH;
            AH := 0;
            Port[DX] := AX;
            Port[DX] := AL;
            AH := AL;
            AL := Port[DX + 1];
            AL := AL and BH;
            foundit := (AL = 0);
          end;
        AX := saveax;
        PortW[DX] := AX;
        BX := savebx;
      end;
  end;



Type cardtype = (none, vesa, standard, paradise, video7, ati, ahead,
                 avance, cirrus, cti, compaq, genoa, s3, trident, tseng,
                 zymos, hualon, mxic, ncr, oak, p2000, realtek, umc,
                 weitek, yamaha);
Const
  trividmons: array[0..7] of string[17] =
               ('MDA', 'CGA', 'EGA', 'Digital multisync', 'VGA', '8514',
                'SuperVGA', 'Analog multisync');

  memnames: array[0..3] of string[4] = ('64K', '128K', '192K', '256K');


Var VGAbuf      : array[$00..$10] of byte;
    paralock1   : Byte;
    paralock2   : byte;
    vgacard     : cardtype;
    vidmem      : word;
    c           : char;
    i           : Word;
    saveattr    : byte;
    savex       : byte;
    savey       : byte;
    foundone    : Boolean;
    foundit     : boolean;
    GraphDriver : Integer;
    GraphMode   : Integer;
    old         : Byte;
    old2        : Byte;
    SubVers     : Word;
    tempword,
    tempword2:word;

Begin
  vgacard:=none;
  vidmem:=0;
  EndString := 'n/a';
  DAC_RS2 := 0;
  DAC_RS3 := 0;

  {$IFNDEF SVGAONLY}
  DetectGraph(GraphDriver, GraphMode);
  Case graphdriver of
    CGA : Begin
            EndString := 'CGA';
            CardNumber := 1;
          End;
    MCGA : Begin
             EndString := 'MCGA';
             CardNumber := 2;
           End;
    EGA :  Begin
             EndString := 'EGA color';
             Regs.AH:=$12;
             Regs.BL:=$10;
             intr($10, regs);
             If Regs.BL < 4 then
             EndString := EndString + memnames[Regs.BL] + ' (BIOS)';
             CardNumber := 3;
           End;
    EGAmono : Begin
                EndString := 'EGA mono';
                Regs.AH:=$12;
                Regs.BL:=$10;
                Intr($10, regs);
                If Regs.BL < 4 then
                EndString := EndString + memnames[Regs.BL] + ' (BIOS)';
                CardNumber := 3;
              End;
    (* This method is untested and possibly flawed
    hercmono : begin
                 {test for Hercules by seeing if there is more than 4K of
                 RAM on the adapter by writing junk and seeing if it sticks.
                 MDA doesn't properly decode addresses (it wraps around every
                 4K) so we write different bytes to offset 0 and offset 4000
                 and see what we get back.}
                 {Save original values}
                 tempword :=memw[$b000:$0000];
                 tempword2:=memw[$b000:$1000];
                 {write different values to different locations}
                 memw[$b000:$0000]:=$1234;
                 memw[$b000:$1000]:=$5678;
                 {if offset 0 has the value written to $1000 then it wrapped
                 around and we have an MDA}
                 if memw[$b000:$0000]=$5678
                   then EndString := 'MDA'
                   else EndString := 'Hercules';
                 CardNumber := 4;
                 {put back original values to be nice}
                 memw[$b000:$0000]:=tempword;
                 memw[$b000:$1000]:=tempword2;
               end;
    *)
    IBM8514 : begin
                EndString := 'IBM 8514';
                CardNumber := 5;
              end;
(*    ATT400 : begin {This is broken, the driver never autodetects for this mode}
               EndString := 'AT&T 400';
               CardNumber := 6;
             end;*)
    VGA :{$ENDIF} begin
            {$IFDEF SVGADEBUG}debugstatus('XGA');{$ENDIF}
            xword1:=isXGA;

            if xword1 > 0
              then if Port[xword1] and 1 = 1
                then EndString := 'XGA '
                else EndString := 'VGA, XGA'
              else EndString := 'VGA';

            vidmem:=0;
            CardNumber := 8;
            vgacard:=standard;

            if vgacard = standard then
              begin
                {$IFDEF SVGADEBUG}debugstatus('Video 7');{$ENDIF}
                {Video 7}
                if Port[$3CC] and 1 = 1 then
                  xword1:=$3D0
                else
                  xword1:=$3B0;
                Port[xword1 + 4]:=$C;
                i:=Port[xword1 + 5];
                Port[xword1 + 5]:=$55;
                xbyte:=Port[xword1 + 5];
                Port[xword1 + 4]:=$1F;
                xbyte2:=Port[xword1 + 5];
                Port[xword1 + 4]:=$C;
                Port[xword1 + 5]:=i;

                if xbyte2 = $55 xor $EA then
                  begin
                    vgacard:=video7;
                    CardNumber := 9;
                    EndString := EndString + ', Video 7, ';
                    port[$3C4]:=$8E;
                    xbyte:=Port[$3C5];
                    case xbyte of
                      $80..$FF: EndString := EndString + 'Vega VGA';
                      $70..$7F: with regs do
                              begin
                                AX:=$6F07;
                                Intr($10, regs);
                                if (AH and $80) = $80 then
                                  EndString := EndString + 'VRAM'
                                else
                                  EndString := EndString + 'FastWrite';
                              end;
                      $50..$59: EndString := EndString + 'VGA Version 5';
                      $40..$49: EndString := EndString + '1024i';
                    else
                      EndString := EndString + 'unknown';
                    end;

                    SubVers := (rdinx ($3C4, $8F) shl 8) + rdinx ($3C4, $8E);
                    case SubVers of
                      $8000..$FFFF : EndString := EndString + ', VEGA VGA Chipset';
                      $7000..$70FF : EndString := EndString + ', HT208 Version 1-3';
                      $7140..$714F : EndString := EndString + ', HT208 rev A';
                      $7151        : EndString := EndString + ', HT208 rev B';
                      $7152        : EndString := EndString + ', HT208 rev CD';
                      $7760        : EndString := EndString + ', HT216 rev BC';
                      $7763        : EndString := EndString + ', HT216 rev D';
                      $7764        : EndString := EndString + ', HT216 rev E';
                      $7765        : EndString := EndString + ', HT216 rev F';
                    End;

                    Port[$3C4]:=$FF;
                    xbyte:=Port[$3C5];
                    with Regs do
                      begin
                        AX:=$6F07;
                        Intr($10, regs);
                        if AL = $6F then
                          begin
                            Vidmem:=256 * (AH and $7F);
                            {Memory type};
                               if AH and $80 = $80 then
                                 EndString := EndString + 'VRAM'
                               else
                                 EndString := EndString + 'DRAM';
                           end
                        else
                           vidmem:=256;
                        end;
                      end;
                    end;

            if vgacard = standard then
              begin
                {$IFDEF SVGADEBUG}debugstatus('Ahead');{$ENDIF}
                {AHEAD};
                S := ReadROM($C000, $25, 5);
                If S = 'AHEAD' Then
                  Begin
                    VgaCard := Ahead;
                    CardNumber := 25;

                    Port [$3CE] := $F;
                    xByte := Port [$3CF];

                    Port [$3CE] := $F;
                    Port [$3CF] := 0;

                    If Not TestInx2 ($3CE,$C,$FB) Then
                      Begin
                        Port[$3CE] := $F;
                        Port[$3CF] := $20;

                        If TestInx2 ($3CE,$C,$FB) Then
                          Begin
                            Case Port[$3CF] And $F Of
                              0 : Begin
                                    EndString := EndString + ', Ahead A ';
                                  End;
                              1 : Begin
                                    EndString := EndString + ', Ahead B ';
                                  End;
                            End;
                          End;
                        Port[$3CE] := $F;
                        Port[$3CF] := xByte;

                        Port[$3CE] := $1F;
                        xByte := Port[$3CF];
                        If (xByte And 1 = 0) And (xByte And 2 = 0) Then VidMem := 256
                          Else If (xByte And 1 = 1) And (xByte And 2 = 2) Then VidMem := 1024;
                      End;
                  End;
              End;

            if vgacard = standard then
              begin
                {$IFDEF SVGADEBUG}debugstatus('Genoa');{$ENDIF}
                {Genoa};
                s:=readROM($C000, MemW[$C000:$37], 4);
                if (s[1] = #$77) and (Copy(s, 3, 2) = #$99#$66) then
                  begin
                    vgacard:=genoa;
                    CardNumber := 10;
                    EndString := Endstring + ', Genoa ';
                    Case Ord(s[2]) of
                      $33: EndString := Endstring + '5100/5200 (Tseng ET3000 Basis)';
                      $55: EndString := Endstring + '5300/5400 (Tseng ET3000 Basis)';
                      $22: EndString := Endstring + '6100';
                      $00: EndString := Endstring + '6200/6300';
                      $11: EndString := Endstring + '6400/6600';
                    Else
                      EndString := Endstring + 'unknown Chip';
                    End;

                    if (s[2] = #$33) or (s[2] = #$55) then
                      Begin
                        CardNumber := 11;
                      End;
                 end
              end;


            if vgacard = standard then
              begin
                {$IFDEF SVGADEBUG}debugstatus('CTI');{$ENDIF}
                { CTI };
                Port[$46E8]:=$1E;
                xbyte:=Port[$104];
                Port[$46E8]:=$E;
                if xbyte = $A5 then
                  with regs do
                    begin
                      AH:=$5F;
                      AL:=0;
                      Intr($10, regs);
                      If al = $5f Then
                        Begin
                          EndString:=EndString+'Chips&Technologies ';
                          Case bl SHR 4 Of
                            0 : EndString := EndString + '82c451';
                            1 : EndString := EndString + '82c452';
                            2 : EndString := EndString + '82c455';
                            3 : EndString := EndString + '82c453';
                            4 : EndString := EndString + '82c450';
                            5 : EndString := EndString + '82c456';
                            6 : EndString := EndString + '82c457';
                            7 : EndString := EndString + 'F65520';
                            8 : EndString := EndString + 'F65530';
                            9 : EndString := EndString + 'F65510';
                          End;
                          vgacard:=CTI;
                          CardNumber := 13;

                          case BH of
                            0: vidmem:=256;
                            1: vidmem:=512;
                            2: vidmem:=1024;
                          else
                            vidmem:=0;
                          end;

                          { Chip revision };
                          EndString := EndString + 'Rev : ' + StrFnByte(xbyte and $0F);

                          { micro-channel };
                          If (CX and 2) = 2 Then EndString := Endstring + ', MCA';

                          { DAC size };
                          if CX and 1 = 1 then
                            EndString := EndString + ', 8-Bit DAC'
                          else
                            EndString := EndString + ', 6-Bit DAC';
                        End;
                    end;
              end;

            if vgacard = standard then
              begin
                {$IFDEF SVGADEBUG}debugstatus('Trident');{$ENDIF}
                { Trident };

                wrinx ($3C4, $B, 0);    {Force old_mode_registers}
                SubVers := Port[$3C5];      {Read chip ID and switch to new_mode_registers}
                old := rdinx ($3C4, $E);
                Port[$3C5] := 0;
                xByte := Port[$3C5] And $F;
                Port [$3C5] := old;

                if xByte=2 then
                  begin
                    vgacard := trident;
                    cardnumber := 15;
                    Port[$3C5] := old xor 2;
                    EndString:=EndString+', Trident ';
                    case SubVers of
                      1       : Begin EndString := EndString + 'TR8800BR'; Dec(CardNumber) End;
                      2       : Begin EndString := EndString + 'TR8800CS'; Dec(CardNumber) End;
                      3       : EndString := EndString + 'TR8900';
                      4,$13   : EndString := EndString + 'TR8900C';
                      $23     : EndString := EndString + 'TR9000';
                      $33     : EndString := EndString + 'TR8900CL or D';
                      $43     : EndString := EndString + 'TR9000i';
                      $53     : EndString := EndString + 'TR8900CXr';
                      $63     : EndString := EndString + 'LCD9100B';
                      $83     : EndString := EndString + 'LX8200';
                      $93     : EndString := EndString + 'TVGA9200CXi';
                      $A3     : EndString := EndString + 'LCD9320';
                      $73,$F3 : EndString := EndString + 'GUI9420';
                    end;
                    case SubVers Of
                      1..4, $13, $23, $43 : Begin
                                              xByte2 := RdInx ($3d4, $1f);
                                              Case xByte And 3 Of
                                                0 : VidMem := 256;
                                                1 : VidMem := 512;
                                                2 : VidMem := 768;
                                                3 : VidMem := 1024;
                                              End;
                                            End;
                      $73, $F3, $33, $53 : Begin
                                             xByte2 := RdInx ($3d4, $1f);
                                             Case xByte And 7 Of
                                               0,4 : VidMem := 256;
                                               1,5 : VidMem := 512;
                                               2,6 : VidMem := 768;
                                               3   : VidMem := 1024;
                                               7   : VidMem := 2048;
                                             End;
                                           End;
                    End;
                  end
                else if (SubVers = 1) and testinx2 ($3C4, $E, 6) Then
                  Begin
                    vgacard := Trident;
                    CardNumber := 14;
                    EndString := EndString + 'Trident TVGA 8800BR';
                  End;

                IF vgacard = Trident Then
                  Begin
                    with regs do
                      begin
                        AX:=$7000;
                        BX:=0;
                        Intr($10, regs);
                        if AL = $70 then
                          begin
                            { Everex Card };
                            CardNumber := 16;
                            DX:=(DX and $FFF0) shr 4;
                            EndString:=EndString+', Everex ';
                            case DX of
                              $678: EndString := EndString + 'Viewpoint';
                              $236: EndString := EndString + 'Ultragraphics II';
                              $620: EndString := EndString + 'Vision VGA';
                              $673: EndString := EndString + 'EVGA'
                            Else
                              EndString := EndString + ', unknown Everex';
                            end; {case}
                            vidmem:=((CH shr 6) * 256) + 256;
                            {'Monitor' };
                            if CL < 8 then
                              EndString := EndString + ', Monitor '+ trividmons[CL]
                            else
                              EndString := EndString + 'Monitor unknown - ' + StrFnByte(CL);
                            end
                    End;
                  end;
              end;

            if vgacard = standard then
              begin
                {$IFDEF SVGADEBUG}debugstatus('Tseng');{$ENDIF}
                { Tseng };
                xbyte:=tsengCK;
                if xbyte = 1 then
                  begin
                    CardNumber := 17;
                    EndString := EndString + ', Tseng ET ';
                    if Port[$3CC] and 1 = 1 then
                      xword:=$3D0
                    else
                      xword:=$3B0;

                    Port[xword + 4]:=$33;
                    xbyte:=Port[xword + 5];
                    Port[xword + 5]:=xbyte xor $F;
                    xbyte2:=Port[xword + 5];
                    Port[xword + 5]:=xbyte;

                    Port[$3BF] := 3;
                    Port[$3D8] := $A0;
                    if testreg ($3CB, $33) then
                      case rdinx ($217A, $EC) shr 4 of
                        0 : Begin CardNumber := 18; EndString := EndString + '4000W32' End;
                        3 : Begin CardNumber := 18; EndString := EndString + '4000W32i' End;
                        2 : Begin CardNumber := 18; EndString := EndString + '4000W32p' End;
                      end
                    Else
                      if xbyte2 = xbyte xor $F then
                        begin
                          EndString := EndString + '4000';

                          CardNumber := 18;
                          Port[$3BF]:=3;
                          Port[$3D8]:=$A0;
                          with regs do
                            begin
                              AX:=$10F1;
                              BL:=0;
                              Intr($10, regs);
                              if BL <> 0 then
                                EndString := EndString + ' with HiColor RAMDAC';
                            end;
                          Port[xword + 4]:=$37;
                          xbyte:=Port[xword + 5];
                          if xbyte and 8 = 0 then
                            vidmem:=256
                          else
                            case xbyte and 3 of
                              0,1: vidmem:=256;
                              2: vidmem:=512;
                              3: vidmem:=1024;
                            end;
                        end
                      else
                        Begin
                          EndString := EndString + '3000';
                          cardnumber := 17;
                        End;

                Port[xword + 4]:=$36;
                xbyte:=Port[xword + 5];

                { Memory type };
                if xbyte and $80 = $80 then
                  EndString := EndString + ', VRAM'
                else
                  EndString := EndString + ', DRAM';

                Port[$3C4]:=7;
                xbyte:=Port[$3C5];
                End;
              end;

            if vgacard = standard then
              begin
                {$IFDEF SVGADEBUG}debugstatus('Zymos');{$ENDIF}
                { ZyMOS };
                if zymosCK = 2 then
                  begin
                    EndString := EndString + ', ZyMOS';
                    vgacard := zymos;
                    CardNumber := 19;
                  end;
              end;

            if vgacard = standard then
              begin
                {$IFDEF SVGADEBUG}debugstatus('Oak');{$ENDIF}
                { Oak }
                if testinx2 ($3DE, $D, $38) then
                  begin
                    vgacard := oak;
                    cardnumber := 32;

                    if testinx2 ($3DE, $23, $1F) then
                      Begin
                        if (rdinx ($3DE, 0) and 2) = 0 then EndString := EndString + 'OAK OTI-087'
                          else EndString := EndString + 'OAK OTI-083';

                        case rdinx ($3DE, 2) and 6 of
                          0 : vidmem := 256;
                          2 : vidmem := 512;
                          4 : vidmem := 1024;
                          6 : vidmem := 2048;
                        end;
                      End
                    Else
                      Begin
                        case Port[$3DE] div 32 of
                          0 : EndString := EndString + 'OAK OTI037C';
                          2 : EndString := EndString + 'OAK OTI-067';
                          5 : EndString := EndString + 'OAK OTI-077';
                          7 : EndString := EndString + 'OAK OTI-057';
                        Else
                          EndString := EndString + 'unknown OAK';
                        end;

                        case rdinx($3de,13) shr 6 of
                          2    : vidmem := 512;
                          1, 3 : vidmem := 1024;
                        end;
                      End;
                  end;
              end;

            if vgacard = standard then
              with regs do
                begin
                {$IFDEF SVGADEBUG}debugstatus('ATI');{$ENDIF}
                  { ATI }
                  s := readROM($C000, $31, 9);
                  if s = '761295520' then
                    begin
                      VgaCard := ati;
                      CardNumber := 20;
                      EndString := EndString + ', ATI ';
                      C := Chr(Mem[$C000:$43]);
                      case c of
                        '1' : Begin
                                CardNumber := 21;
                                EndString := EndString + '18800';
                              End;
                        '2' : Begin
                                CardNumber := 21;
                                EndString := EndString + '18800-1';
                              End;
                        '3' : Begin
                                CardNumber := 26;
                                EndString := EndString + '28800-2';
                              End;
                        '4' : Begin
                                CardNumber := 26;
                                EndString := EndString + '28800-4';
                              End;
                        '5' : Begin
                                CardNumber := 26;
                                EndString := EndString + '28800-5';
                              End;
                        '6' : Begin
                                CardNumber := 26;
                                EndString := EndString + '28800-6';
                              End;
                        'a' : Begin
                                CardNumber := 26;
                                EndString := EndString + '68800';
                              End;
                      end;

                      { Board }
                      s := ReadROM ($C000, $40, 2);
                      if s = '31' then
                        EndString := EndString + 'VGAWonder';
                      if s = '32' then
                        EndString := EndString + 'EGAWonder 800+';
                      if s = '22' then
                        EndString := EndString + 'EGAWonder';
                      s := ReadROM ($C000, $41, 1);
                      if s = '3' then
                        EndString := EndString + 'Basic-16';

                      { Revision }
                      EndString := EndString + 'Bios : ' + StrFnByte(Mem[$C000:$4C]) + '.' + StrFnByte (Mem[$C000:$4D]);
                    end;
                End;

            if vgacard = standard then
              begin
                {$IFDEF SVGADEBUG}debugstatus('Paradise');{$ENDIF}
                { Paradise }

                old := rdinx ($3CE, $F);
                setinx ($3CE,$F,$17);   {Lock registers}
                if not testinx2 ($3CE, 9, $7F) then
                  begin
                    modinx ($3CE, $F, $17, 5);      {Unlock again}
                    if testinx2 ($3CE, 9, $7F) then
                      begin
                        old2 := rdinx ($3D4, $29);
                        modinx ($3d4, $29, $8F, $85);  {Unlock WD90Cxx registers}
                        if not testinx2 ($3D0, $2B, $ff) then
                          Begin
                            EndString := EndString + ', Paradise PVGA1A';
                            vgacard := paradise;
                            cardnumber := 22;
                          End
                        else
                          begin
                            wrinx ($3C4, 6, $48);
                            if not testinx2 ($3C4, 7, $F0) then
                              Begin
                                EndString := EndString +  ', Western Digital WD90C00';
                                vgacard := paradise;
                                cardnumber := 22;
                              End
                            else if not testinx2 ($3C4, $10, $ff) then
                                begin
                                  vgacard := paradise;
                                  cardnumber := 22;
                                  if testinx2 ($3D0,$31,$68) then  EndString := EndString + ', Western Digital WD90C22'
                                    else if testinx2 ($3D0,$31,$90) then EndString := EndString + ', Western Digital WD90C20A'
                                      else EndString := EndString + ', Western Digital WD90C20';
                                  wrinx ($3d4, $34, $A6);
                                  if (rdinx ($3d4, $32) and $20) <> 0 then wrinx ($3d4, $34, 0);
                                end
                              else if testinx2 ($3C4, $14, $F) then
                                begin
                                  vgacard := paradise;
                                  cardnumber := 22;
                                  SubVers := (rdinx ($3D0, $36) shl 8) + rdinx ($3D0, $37);
                                  EndString:=EndString+', Western Digital ';
                                  case SubVers of
                                    $3234 : EndString := EndString + 'WD90C24';
                                    $3236 : EndString := EndString + 'WD90C26';
                                    $3330 : EndString := EndString + 'WD90C30';
                                    $3331 : EndString := EndString + 'WD90C31';
                                    $3333 : EndString := EndString + 'WD90C33';
                                  else
                                    EndString := EndString + ', unknown Paradise';
                                  end;
                                end
                              else if not testinx2 ($3C4, $10, 4) then
                                Begin
                                  EndString := EndString + ', Western Digital WD90C10';
                                  vgacard := paradise;
                                  cardnumber := 22;
                                End
                              else
                                Begin
                                  EndString := EndString + ', Western Digital WD90C11';
                                  vgacard := paradise;
                                  cardnumber := 22;
                                End;
                          end;
                        wrinx ($3d4, $29, old2);
                      end;
                    wrinx ($3CE, $F, old);
                  End;


                  if vgacard = paradise Then
                    Begin
                      Port[$3CE]:=$0B;
                      for xbyte:=1 to 2 do;
                      xbyte:=Port[$3CF];
                      vidmem:=word(64) * (xbyte shr 4);

                      { Video }
                      If (xbyte and 4) = 0 Then EndString := EndString +
                        ', 8-Bit-Video' Else EndString := EndString +
                        ', 16-Bit-Video';

                      { ROM };
                      If (xbyte and 2) = 0 Then EndString := EndString +
                        ', 8-Bit-ROM' Else EndString := EndString +
                        ', 16-Bit-ROM';

                      { Frequencies are };
                      Port[$3CE]:=$0F;
                      xbyte:=Port[$3CF];
                      if (xbyte and $80) = $80 then
                        EndString := Endstring + 'Multi-Sync'
                      Else
                        EndString := EndString + 'fixed-sync';
                      Port[xword + 4]:=$29;
                      Port[xword + 5]:=paralock2;
                      Port[$3CE]:=$F;
                      Port[$3CF]:=paralock1;
                    End;
              end;


            if vgacard = standard Then
              Begin
                {$IFDEF SVGADEBUG}debugstatus('Avance Logic');{$ENDIF}
                { Avance Logic }
                Port[$3D4] := $1A;
                xByte := Port[$3D5];

                {Disable Extensions}
                Port[$3D4] := $1A;
                If xByte And $10 = $10 Then Port[$3D5] := xByte Or $10
                  Else Port[$3D5] := xByte;

                if not testinx2 ($3d4, $19, $ff) then
                  begin
                    {Enable Extensions}
                    If xByte And $10 = $10 Then Port[$3D5] := xByte Else Port[$3D5] := xByte Or $10;

                    if testinx2($3d4, $19, $ff) and testinx2($3d4, $1A, $3F) then
                      Begin
                        vgacard := avance;
                        cardnumber := 27;
                        EndString := EndString + ', Avance Logic AL2101';
                        Port[$3D4] := $1E;
                        xByte2 := Port[$3D5];
                        If (xByte2 And 1 = 0) And (xByte2 And 2 = 0) Then VidMem := 256
                          Else If (xByte2 And 1 = 0) And (xByte2 And 2 = 2) Then VidMem := 512
                          Else If (xByte2 And 1 = 1) And (xByte2 And 2 = 0) Then VidMem := 1024
                          Else If (xByte2 And 1 = 1) And (xByte2 And 2 = 2) Then VidMem := 2048;
                      End;
                  end;
                Port[$3d4] := $1A;
                Port[$3D5] := xByte;
              End;

            if vgacard = standard then
              begin
                {$IFDEF SVGADEBUG}debugstatus('Compaq');{$ENDIF}
                { Compaq }
                old := rdinx ($3CE, $F);
                wrinx ($3CE, $F, 0);
                if not testinx2 ($3CE,$45, $ff) then
                  begin
                    wrinx ($3CE, $F, 5);
                    if testinx2 ($3CE,$45, $ff) then
                      begin
                        SubVers := rdinx ($3CE, $C) shr 3;
                        EndString:=EndString+', Compaq ';
                        case SubVers of
                          3   : EndString := EndString + 'IVGS';
                          5   : EndString := EndString + 'AVGA';
                          6   : EndString := EndString + 'QVision 1024';
                          $E  : if (rdinx($3CE,$56) and 4) > 0 then EndString := EndString + 'QVision 1280'
                                else EndString := EndString + 'QVision 1024';
                          $10 : EndString := EndString + 'AVPort';
                        else
                          EndString := EndString + ', unknown Compaq';
                        end;
                        if (rdinx ($3CE, $C) and $B8) = $30 then  {QVision}
                          begin
                            wrinx ($3CE, $F, $F);
                            case rdinx ($3CE, $54) of
                              0 : vidmem := 1024;  {QV1024 fix}
                              2 : vidmem := 512;
                              4 : vidmem := 1024;
                              8 : vidmem := 2048;
                            end;
                            DAC_RS2:=$8000;
                            DAC_RS3:=$1000;
                          end
                        else
                          begin
                            regs.ax := $BF03;
                            regs.bx := 0;
                            regs.cx := 0;

                            Intr($10, Regs);
                            if (regs.ch and 64) = 0 then vidmem := 512;
                          end;

                        CardNumber := 28;
                        vgacard := compaq;
                      end;
                  end;
                wrinx ($3CE, $F, old);
              End;

            if vgacard = standard Then
              Begin
                {$IFDEF SVGADEBUG}debugstatus('MXIC');{$ENDIF}
                { MXIC }
                old := rdinx ($3C4, $A7);
                wrinx ($3C4, $A7, 0);     {Disable extensions}
                if not testinx2 ($3C4, $C5, $ff) then
                  begin
                    wrinx ($3C4, $A7, $87);
                    if testinx2 ($3C4,$C5, $ff) then
                      Begin
                        vgacard := mxic;
                        cardnumber := 30;
                        if (rdinx ($3C4, $26) and 1) = 0 then EndString := EndString + ', MXIC MX86010'
                          else EndString := EndString + ', MXIC MX86000';
                      End;
                  end;
                wrinx ($3C4, $A7, old);
              End;


            if vgacard = standard Then
              Begin
                {$IFDEF SVGADEBUG}debugstatus('NCR');{$ENDIF}
                { NCR VGA }
                if testinx2 ($3C4, 5, 5) then
                  begin
                    wrinx ($3C4, 5, 0);   {Lock extensions}
                    if not testinx2 ($3C4, $10, $ff) then
                      begin
                        wrinx ($3C4, 5, 1);
                        if testinx2 ($3C4, $10, $ff) then
                          Begin
                            vgacard := ncr;
                            cardnumber := 31;
                            case rdinx ($3C4, 8) div 16 of
                              0     : EndString := EndString + ', NCR 77C22';
                              1     : EndString := EndString + ', NCR 77C21';
                              2     : EndString := EndString + ', NCR 77C22E';
                              8..15 : EndString := EndString + ', NCR 77C22E+';
                            end;
                          End;
                      end;
                  end;
              End;

            if vgacard = standard Then
              Begin
                {$IFDEF SVGADEBUG}debugstatus('Primus 2000');{$ENDIF}
                { Primus 2000 }
                if testinx2 ($3CE, $3D, $3F) and testreg ($3D6, $1F) and testreg ($3D7, $1F) then
                  Begin
                    vgacard := p2000;
                    cardnumber := 33;
                    EndString := EndString + ', Primus 2000';
                  End;
              End;


            if vgacard = standard Then
              Begin
                {$IFDEF SVGADEBUG}debugstatus('Realtek');{$ENDIF}
                { Realtek }
                if testinx2 ($3D0, $1F, $3F) And testreg ($3D6,$F) and testreg ($3D7,$F) then
                  Begin
                    vgacard := realtek;
                    cardnumber := 34;
                    case rdinx ($3D0, $1A) shr 6 of
                      0 : EndString := EndString + ', Realtek RT3103';
                      1 : EndString := EndString + ', Realtek RT31030/RT3105';
                      2 : EndString := EndString + ', Realtek RT3106';
                    end;
                    Regs.AX := $5F02;
                    Intr ($10, Regs);
                    If Regs.AH = 0 Then
                      Case Regs.AL Of
                        0 : VidMem := 256;
                        1 : VidMem := 512;
                        2 : VidMem := 768;
                        3 : VidMem := 1024;
                      End;
                  End;
              End;

            if vgacard = standard Then
              Begin
                {$IFDEF SVGADEBUG}debugstatus('UMC');{$ENDIF}
                { UMC 85c408 }
                old := Port[$3BF];
                Port[$3BF] := 3;
                if not testinx2 ($3C4, 6, $ff) then
                  begin
                    Port[$3BF] := $AC;
                    if testinx2 ($3C4, 6, $ff) then
                      Begin
                        vgacard := umc;
                        cardnumber := 35;
                        EndString := EndString + ', UMC 85c408';
                        Port[$3C4] := 7;
                        Case (Port[$3C5] And 192) Shr 6 Of
                          0    : VidMem := 256;
                          1    : VidMem := 512;
                          2..3 : VidMem := 1024;
                        End;
                      End
                  end;
                Port[$3BF] := old;
              End;

            if vgacard = standard Then
              Begin
                {$IFDEF SVGADEBUG}debugstatus('Weitek');{$ENDIF}
                { Weitek }

                old := rdinx ($3C4, $11);
                Port[$3C4+1] := old;
                Port[$3C4+1] := old;
                Port[$3C4+1] := Port[$3C4+1] or $20;
                if not testinx2 ($3C4, $12, $ff) then
                  begin
                    xByte := rdinx ($3C4, $11);
                    Port[$3C4+1] := old;
                    Port[$3C4+1] := old;
                    Port[$3C4+1] := Port[$3C4+1] and $DF;
                    if testinx2 ($3C4, $12, $ff) and testreg ($3CD, $FF) then
                      begin
                        EndString := EndString + ', Weitek';
                        vgacard := Weitek;
                        cardnumber := 36;
                      end;
                  end;
                wrinx ($3C4, $11, old);
              End;

            if vgacard = standard Then
              Begin
                {$IFDEF SVGADEBUG}debugstatus('Yamaha');{$ENDIF}
                { Yamaha 6388 }
                if testinx2 ($3d4,$7c,$7c) then
                  Begin
                    EndString := EndString + ', Yamaha 6388';
                    vgacard := yamaha;
                    cardnumber := 37;
                  End;
              End;

            if vgacard = standard Then
              Begin
                {$IFDEF SVGADEBUG}debugstatus('S3');{$ENDIF}
                { S3 }
                Port[$03D4] := $38; { disable extensions }
                Port[$03D5] := $00;

                if not testinx2 ($03D4,$35,$FF) then
                  begin
                    Port[$03D4] := $38;
                    Port[$03D5] := $48;
                    if testinx2($03D4,$35,$F) then
                      begin
                        { Es ist eine S3 }
                        CardNumber := 23;
                        EndString := EndString + ', S3 ';
                        vgacard := s3;

                        Port [$3D4] := $30;
                        xByte := Port [$3D5];
                        Case xByte Of
                          $81      : EndString := EndString + '86c911';
                          $82      : EndString := EndString + '86c911A or 86c924';
                          $90      : EndString := EndString + '86c928 C';
                          $91      : EndString := EndString + '86c928 D';
                          $94, $95 : EndString := EndString + '86c928 E';
                          $A0      : EndString := EndString + '86c801/5 A or B';
                          $A2..$A4 : EndString := EndString + '86c801/5 C';
                          $A5      : EndString := EndString + '86c801/5 D';
                          $B0      : EndString := EndString + '86c928 PCI';
                          $E1      : EndString := EndString + '86c868/86c968 PCI';
                        Else
                          EndString := EndString + 'unknown';
                        end;

                        If xByte > $90 Then CardNumber := 24;
                        If xByte > 4 Then
                          Begin
                            Port [$3D4] := $36;
                            xByte := Port[$3D5];
                            If(xByte And $20 = $20) Then VidMem := 512
                              Else If (xByte And Not $40 = $40) And
                              (xByte And Not $80 = $80) Then VidMem := 4096
                              Else If (xByte And Not $40 = $40) And
                              (xByte And $80 = $80) Then VidMem := 3072
                              Else If (xByte And $40 = $40) And
                              (xByte And Not $80 = $80) Then VidMem := 2048
                              Else If (xByte And $40 = $40) And
                              (xByte And $80 = $80) Then VidMem := 1024;
                          End
                        Else
                          Begin
                            Port [$3D4] := $36;
                            If Port[$3D5] And $20 = $20 Then VidMem := 512
                              Else VidMem := 1024;
                          End;
                      end;
                  end;
              End;

            if vgacard = standard Then
              Begin
                {$IFDEF SVGADEBUG}debugstatus('Hualon');{$ENDIF}
                { Hualon HM86304 }
                if testinx2 ($3C4,$E7,$ff) and testinx2($3C4,$EE,$ff) then
                  begin
                    CardNumber := 29;
                    vgacard := hualon;
                    EndString := EndString + ', Hualon HM86304';
                    If RdInx ($3C4, $E7) And $10 = $10 Then VidMem := 512
                      Else VidMem := 256;
                  end;
              End;

            if vgacard = standard then begin
              {$IFDEF SVGADEBUG}debugstatus('Cirrus stage 1');{$ENDIF}
              { Cirrus 1 };

              { Test for Cirrus 54xx }
              old := rdinx ($3C4, 6);
              wrinx ($3C4, 6, 0);
              if rdinx ($3C4, 6) = $F
                then begin
                  wrinx ($3c4, 6, $12);
                  if (rdinx ($3C4, 6) = $12) and testinx2 ($3C4, $1E, $3F)
                    then begin
                      SubVers := rdinx ($3d4, $27);
                      if testinx2 ($3CE,9, $ff)
                        then begin
                          EndString:=EndString+', Cirrus CL-GD';
                          case SubVers of
                            $88 : EndString := Endstring + '5402';
                            $89 : EndString := Endstring + '5402 r1';
                            $8A : EndString := Endstring + '5420';
                            $8B : EndString := Endstring + '5420 r1';
                            $8C..$8F : EndString := Endstring + '5422';
                            $90..$93 : EndString := Endstring + '5426';
                            $94..$97 : EndString := Endstring + '5424';
                            $98..$9B : EndString := Endstring + '5428';
                            $A4..$A7 : EndString := Endstring + '543x';
                          else
                            EndString := EndString + ', unknown Cirrus CL-GD54';
                          end;
                        end
                      else
                        if testinx2 ($3C4, $19, $ff)
                          then begin
                            EndString:=EndString+', Cirrus CL-GD';
                            case SubVers shr 6 of
                              0 : EndString := Endstring + '6205';
                              1 : EndString := Endstring + '6235';
                              2 : EndString := Endstring + '6215';
                              3 : EndString := Endstring + '6225';
                            end;
                          end
                          else
                            EndString := EndString + 'Cirrus AVGA2 (5402)';
                        vgacard := cirrus;
                        cardnumber := 12;
                    end;
                  end
                else
                  wrinx($3C4,6,old);
            End;


            if vgacard = standard then
              begin
                {$IFDEF SVGADEBUG}debugstatus('Cirrus stage 2');{$ENDIF}
                { Cirrus 2 }

                { Test fÅr 64xx }

                old := rdinx ($3CE, $A);
                wrinx ($3CE, $A, $CE);

                if rdinx ($3CE, $A) = 0 then
                  begin
                    wrinx ($3CE, $A, $EC);
                    if rdinx ($3CE, $A) = 1 then
                      begin
                        SubVers := rdinx ($3CE, $AA);
                        EndString:=EndString+', Cirrus CL-GD';
                        case SubVers shr 4 of
                          4 : EndString := EndString + '6440';
                          5 : EndString := EndString + '6412';
                          6 : EndString := EndString + '5410';
                          7 : EndString := EndString + '6420';
                          8 : EndString := EndString + '6410';
                        else
                          EndString := EndString +  ', unknown Cirrus CL-GD64'
                        end;
                        vgacard := cirrus;
                        cardnumber := 12;
                        xByte := rdinx ($3CE, $BB);
                        If (xByte And $40 = 0) And (xByte And $80 = 0) Then VidMem := 256
                          Else If (xByte And $40 = 0) And (xByte And $80 = $80) Then VidMem := 512
                          Else If (xByte And $40 = $40) And (xByte And $80 = 0) Then VidMem := 768
                          Else If (xByte And $40 = $40) And (xByte And $80 = $80) Then VidMem := 1024;
                      end;
                  end;
                wrinx($3CE,$A,old);
              End;

            if vgacard = standard then
              begin
                {$IFDEF SVGADEBUG}debugstatus('Cirrus stage 3');{$ENDIF}
                { Cirrus 3 }

                { Now test for 5/600 }

                xByte := rdinx ($3C4, 6);
                old := rdinx ($03D4, $C);
                Port[$03D4+1] := 0;
                SubVers := rdinx ($3d4, $1F);
                {wrinx ($3C4, 6, (SubVers shl 4) + (SubVers shr 4));}
                wrinx ($3C4, 6, byte((SubVers shl 4)+(SubVers shr 4)));
                if Port[$3C5] = 0 then
                  begin
                    Port[$3C5] := SubVers;
                    if Port [$3C5] = 1 then
                      case SubVers of
                        $EC : EndString := EndString + ', Cirrus 510/520';
                        $CA : EndString := EndString + ', Cirrus 610/620';
                        $EA : EndString := EndString + ', Cirrus Video7 OEM';
                      else
                        EndString := EndString + ', unknown Cirrus';
                      end;
                      vgacard := cirrus;
                      cardnumber := 12;
                  end;
                wrinx ($03D4, $C, old);
                wrinx ($3C4, 6, xByte);
              End;

            if vgacard = standard then
              begin
                EndString := Endstring + ', unknown Chipset';
              end;

            If VesaInf (1) = 'ja' Then EndString := EndString + ', VESA';

          end;
    {$IFNDEF SVGAONLY}
    PC3270 : begin
               EndString := '3270 PC';
               CardNumber := 7;
             end
  Else
    Begin
      EndString := 'unknown graphics card';
      CardNumber := 0;
    End;
  End; {case} {$ENDIF}

  If VidMem <> 0 Then EndString := EndString + ', ' + StrFnWord(VidMem) +
    'kb Video Memory';

  If (VidMem <> 0) And (VesaInf (1) = 'ja') Then
    Begin
      LoadVESARecords;
      EndString := EndString + ', ' + StrFnWord (VesaInfo.Mem64k * 64) + 'kb Video Memory (VESA)';
    End;

  If VidMem = 0 Then
    Begin
      Regs.AH := $12;
      Regs.BL := $10;
      Intr ($10, Regs);
      { Memory }
      If Regs.BL < 4 Then
        Case Regs.BL Of
          0   : VidMem := 64;
          1   : VidMem := 128;
          2   : VidMem := 192;
          3   : VidMem := 256;
        Else
          VidMem := 0;
        End;
      If VidMem <> 0 Then EndString := EndString + ', ' + StrFnWord(VidMem) +
        'kb Video Memory (BIOS)';
    End;

  {$IFNDEF SVGAONLY}
  WhatGCard := EndString;
  {$ELSE}
  WhatSVGACard := EndString;
  {$ENDIF}
End;


Function WhatGCardNumber;

Begin
  {$IFNDEF SVGAONLY}
  WhatGCard;
  {$ELSE}
  WhatSVGACard;
  {$ENDIF}
  WhatGCardNumber := CardNumber;
End;


Function VesaInf;

  Function IsVesa : Boolean;

  Begin
    Regs.AX:=$4F00;
    Regs.ES:=Seg(VESAinfo);
    Regs.DI:=Ofs(VESAinfo);
    Intr($10, regs);
    If (Regs.AL = $4F) and (Regs.AH = 0) and (VESAinfo.signature =
    'VESA') then IsVesa := True Else IsVesa := False;
  End;

Begin
  Case InfoNumber Of
    1 : Begin
          { ist installiert ? }
          If IsVesa = True Then VesaInf := 'ja' else VesaInf := 'nein';
        End;
    2 : Begin
          { Version }
          LoadVESARecords;
          VesaInf := StrFnWord (Hi(VesaInfo.Version))+'.'+StrFnWord (Lo(VesaInfo.Version));
        End;
    3 : Begin
          { OEM Id }
          LoadVESARecords;
          s := '';
          c := Chr(Mem[VesaInfo.OemNameSeg:VesaInfo.OemNameOfs]);
          xword2 := VesaInfo.OemNameOfs;
          While c <> #0 Do
            Begin
              s := s + c;
              Inc(Xword2);
              C:=Chr(Mem[VesaInfo.OemNameSeg:xword2])
            End;
          If s = '761295520' then
            VesaInf := 'ATI'
          Else
            VesaInf := s;
        End;
  End;
End;


Function VESAIsVidMode;

Begin
  If VesaInf (1) = 'ja' Then
    Begin
      LoadVESARecords;
      xword2:=VESAinfo.modesSeg;
      xword3:=VESAinfo.modesOfs;
      xBool := False;
      with VESAmode do
        while MemW[xword2:xword3] <> $FFFF do
          begin
            If (MemW[xword2:xword3] = Mode) Then xBool := True;
            Inc(xword3, 2);
           end;
      VESAIsVidMode := xBool;
    End
  Else
    VesaIsVidMode := False;
End;


Function VESAVidModeString;

Begin
  If VesaInf (1) = 'ja' Then
    Begin
      If VesaIsVidMode (Mode) Then
        Begin
          Regs.AX := $4F01;
          Regs.CX := Mode;
          Regs.ES := Seg(VESAmode);
          Regs.DI := Ofs(VESAmode);
          Intr ($10, Regs);
          If Not Regs.AL = $4F Then
            VesaVidModeString := 'VESA-Funktion nicht unterstÅtzt'
          Else
            Begin
              If Vesamode.ModeAttr And 1 = 1 Then
                Begin
                  S := '';
                  If Vesamode.ModeAttr And $10 = $10 Then S := S + 'Grafik, '
                    Else S := S + 'Text, ';

                  If Vesamode.ModeAttr And 8 = 8 Then S := S + 'Farbe, '
                    Else S := S + 'Monochrom, ';

                  If Vesamode.ModeAttr And 4 = 4 Then S := S + 'BIOS, '
                    Else S := S + 'k. BIOS, ';
                  S := S + 'Char : ' + StrFnWord (Vesamode.CharWidth) + 'x' + StrFnWord (Vesamode.CharHeight) + ', ';
                  If Z = 46 Then S := S + #13#10;
                  S := S + 'Auflîsung : ' + StrFnWord (Vesamode.PixWidth) + 'x' + StrFnWord (Vesamode.PixHeight) + ', ';
                  S := S + 'Planes : ' + StrFnWord (Vesamode.MemPlanes) + ', ';
                  S := S + 'Farbtiefe : ' + StrFnByte (Vesamode.Pixelbits) + ', ';
                  If Z = 46 Then S := S + #13#10;
                  S := S + 'Memory-Modell : ';
                  Case Vesamode.Memmodel Of
                    0 : S := S + 'Text';
                    1 : S := S + 'CGA Grafik';
                    2 : S := S + 'HGC Grafik';
                    3 : S := S + '16-Farben (EGA) Grafik';
                    4 : S := S + 'Packed Pixel Grafik';
                    5 : S := S + '"Sequ 256" (non-chain 4) Grafik';
                    6 : S := S + 'Direct color (HiColor, 24-bit color)';
                    7 : S := S + 'YUV bzw. YIQ (luminance-chrominance)';
                  End;

                  VesaVidModeString := S;
                End
              Else
                VesaVidModeString := 'VESA-Mode nicht unterstÅtzt';
            End;
        End
      Else
        VesaVidModeString := 'VESA-Mode nicht implementiert';
    End
  Else
    VesaVidModeString := 'VESA-Interface nicht vorhanden';
End;


Function WhatRamDac;

  Procedure cli;
    Inline($FA);

  Procedure sti;
    Inline($FB);

  procedure dac2comm;   {switches DAC to command register}

  var x : word;

  begin
    x := Port[$3C8];    {clear old state}
    x := Port[$3C6];
    x := Port[$3C6];
    x := Port[$3C6];    {Read $3C6 4 times.}
    x := Port[$3C6];
  end;


  procedure dac2pel;  {switches DAC back to normal mode}

  var x : word;

  begin
    x := Port[$3C8];
  end;

  function trigdac:word;  {Reads $3C6 4 times}

  var x : word;

  begin
    x := Port[$3c6];
    x := Port[$3c6];
    x := Port[$3c6];
    trigdac := Port[$3c6];
  end;



  function getdaccomm:word;

  begin
    if DAC_RS2 <> 0 then getdaccomm := Port[$3C6+DAC_RS2] else
      begin
        dac2comm;
        getdaccomm:= Port[$3C6];
        dac2pel;
      end;
  end;


  function testdac : string;

  var
    x          : word;
    y          : word;
    z          : word;
    v          : word;
    oldcomm    : word;
    oldpel     : word;
    dac8       : boolean;
    dac8now    : boolean;
    notcomm    : word;
    daccomm    : word;

  type
    pel = record
            index : byte;
            red   : byte;
            green : byte;
            blue  : byte;
          end;

    procedure readpelreg (index : word; var p : pel);

    begin
      p.index := index;
      cli;
      Port[$3C7] := index;
      p.red  := Port[$3C9];
      p.blue := Port[$3C9];
      p.green:= Port[$3C9];
      sti;
    end;


    procedure writepelreg (var p : pel);

    begin
      cli;
      Port[$3C8] := p.index;
      Port[$3C9] := p.red;
      Port[$3C9] := p.blue;
      Port[$3C9] := p.green;
      sti;
    end;


    function setcomm (cmd : word) : word;

    begin
      dac2comm;
      Port[$3c6] := cmd;
      dac2comm;
      setcomm := Port[$3c6];
    end;


    procedure waitforretrace;

    begin
      repeat until (Port[$3D4+6] and 8) = 0;
      repeat until (Port[$3D4+6] and 8) > 0;    {Wait until we're in retrace}
    end;


    function dacis8bit : boolean;

    var
      pel2 : word;
      x    : word;
      v    : word;
      pel1 : pel;

    begin
      pel2 := Port[$3C8];
      readpelreg (255, pel1);
      v := pel1.red;
      pel1.red := 255;
      writepelreg (pel1);
      readpelreg (255, pel1);
      x := pel1.red;
      pel1.red := v;
      writepelreg (pel1);
      Port[$3C8] := pel2;
      dacis8bit := (x = 255);
    End;


    function testdacbit (bit : word) : boolean;

    begin
      dac2pel;
      Port[$3C6] := oldpel and (bit xor $FF);
      dac2comm;
      cli;
      Port[$3C6] := oldcomm or bit;
      v := Port[$3C6];
      Port[$3C6] := v and (bit xor $FF);
      sti;
      testdacbit := (v and bit) <> 0;
    end;

  begin
    daccomm := getdaccomm;
    EndString := 'Normal';
    dac2comm;
    oldcomm := Port[$3C6];
    dac2pel;
    oldpel := Port[$3c6];

    dac2comm;
    Port[$3c6] := 0;
    dac8 := dacis8bit;
    dac2pel;

    notcomm := oldcomm xor 255;
    Port[$3c6] := notcomm;
    dac2comm;
    v := Port[$3c6];
    if v <> notcomm then
      if (setcomm ($E0) and $e0) <> $e0 then
        begin           {Bits 5-7 of command register NOT writable.}
          dac2pel;
          x := Port[$3C6];
          repeat
            y := x;         {wait for the same value twice}
            x := Port[$3C6];
          until (x = y);
          z := x;
          dac2comm;
          if daccomm <> $8E then
            begin                 {If command register=$8e, we've got an SS24}
              y := 8;
              repeat
                x := Port[$3C6];
                dec (y);
              until (x = $8E) or (y = 0);
            end
          else
            x := daccomm;
          if x = $8e then EndString := 'SS24'
            else EndString := 'Sierra SC11486';
          dac2pel;
        end
      else
        begin
          if (setcomm($60) and $E0) = 0 then
            begin
              if (setcomm (2) and 2) > 0 then EndString := 'AT&T 20c490'
                else EndString := 'AT&T 20c493';
            end
          else
            begin
              x := setcomm (oldcomm);
              if Port[$3c6] = notcomm then
                begin
                  if setcomm ($FF) <> $ff then EndString := 'Acumos ADAC1'
                    else
                      begin
                        dac8now := dacis8bit;
                        dac2comm;
                        Port[$3C6] := (oldcomm or 2) and $FE;
                        dac8now := dacis8bit;
                        if dac8now then
                          if dacis8bit then EndString := 'AT&T 20c491'
                            else EndString := 'Cirrus 24bit DAC'
                        else EndString := 'AT&T 20c492';
                      end;
                end
              else
                begin
                  if trigdac = notcomm then EndString := 'Cirrus 24bit DAC' else
                    begin
                      dac2pel;
                      Port[$3c6] := $FF;
                      case trigdac of
                        $44 : EndString := 'MUSIC ??';
                        $82 : EndString := 'MUSIC MU9C4910';
                        $8e : EndString := 'Diamond SS2410';
                      else
                        if testdacbit ($10) then EndString := 'Sierra 16m'
                          else if testdacbit (4) then EndString := 'Unknown DAC #9'
                            else EndString := 'Sierra 32k/64k';
                      end;
                    end;
            end;
        end;
      end;
      dac2comm;
      Port[$3c6] := oldcomm;

    dac2pel;
    Port[$3c6] := oldpel;

    if (EndString='Normal') and (DAC_RS2 <> 0) and (DAC_RS3 <> 0) then
      begin
        oldpel := Port[$3C6];
        oldcomm:= Port[$3C6+DAC_RS2];
        Port[$3C6+DAC_RS2] := oldpel xor $FF;
        if (Port[$3C6] = oldpel) and (Port[$3C6+DAC_RS2] = (oldpel xor $FF)) then
          EndString := 'Brooktree Bt484';

        Port[$3C6+DAC_RS2] := oldcomm;
        Port[$3C6] := oldpel;
      end;

    if EndString = 'Normal' then
      begin
        WaitforRetrace;
        Port[$3C8] := 222;
        Port[$3C9] := $43;
        Port[$3C9] := $45;
        Port[$3C9] := $47;    {Write 'CEGEDSUN' + mode to DAC index 222}
        Port[$3C8] := 222;
        Port[$3C9] := $45;
        Port[$3C9] := $44;
        Port[$3C9] := $53;
        Port[$3C8] := 222;
        Port[$3C9] := 55;
        Port[$3C9] := $4E;
        Port[$3C9] := 13;     {Should be in CEG mode now}
        Port[$3C6] := 255;
        x := (Port[$3c6] shr 4) and 7;
        if x < 7 then
          begin
            EndString := 'Edsun CEG rev. ' + chr (x + 48);
            WaitforRetrace;
            Port[$3C8] := 223;
            Port[$3C9] := 0;    {Back in normal dac mode}
          end;

        Regs.AX := $10F1;
        Intr ($10, Regs);
        If Regs.AL = $10 Then
          Begin
            Case Regs.BL Of
              0 : EndString := 'Normaler VGA-DAC';
              1 : EndString := 'Sierra SC1148x Hicolor DAC';
              2 : EndString := 'Sierra Mark2 (15 Bit) or Mark3 (15/16 Bit) DAC';
              3 : EndString := 'ATT20c490/1/2 (15/16/24 Bit)';
              4 : EndString := 'AcuMos ADAC1 (15/16/24 Bit)';
              5 : EndString := 'unknown 15/16/24 Bit DAC';
              6 : EndString := 'Interner Cirrus 15/16/24 Bit DAC';
              7 : EndString := 'Diamond SS2410 (15/24 Bit)';
              8 : EndString := 'unknown 15/16/24 Bit DAC';
              8 : EndString := 'unknown 15/16/24 Bit DAC';
            Else
              EndString := 'Hicolor DAC';
            End;
          End;


      TestDac := EndString;
      end;
    end;


Begin
  {$IFNDEF SVGAONLY}
  WhatGCard; { FÅr RS2 und RS3 }
  {$ELSE}
  WhatSVGACard; { FÅr RS2 und RS3 }
  {$ENDIF}
  WhatRamDac := TestDac;
End;


Function GraInf;

Type tStateBuff = Record
       StaticFunc     : Pointer;
       VidMode        : Byte;
       Columns        : Word;
       LengthRegenBuf : Word;
       StartAdrLRB    : Word; { Stard-Adresse Length Regen Buffer }
       CursorPos0     : Word;
       CursorPos1     : Word;
       CursorPos2     : Word;
       CursorPos3     : Word;
       CursorPos4     : Word;
       CursorPos5     : Word;
       CursorPos6     : Word;
       CursorPos7     : Word;
       CursorType     : Word;
       ActivePage     : Byte;
       CRTCPortAdr    : Word;
       CurSet3_8      : Byte;
       CurSet3_9      : Byte;
       Rows           : Byte;
       BytesChar      : Word;
       CombCode       : Byte;
       DCCAlternate   : Byte;
       ColorsCurMode  : Word;
       PagesCurMode   : Byte;
       ScanLines      : Byte; {1,2,3,4 = 200, 350, 400, 480}
       PrimCharBlok   : Byte;
       SecCharBlock   : Byte;
       MiscFlags      : Byte;
         { bit 0 all modes on all displays on
                    1 gray summing on
                    2 monochrome display attached
                    3 default palette loading disabled
                    4 cursor emulation enabled
                    5 0 = intensity; 1 = blinking
                    6 PS/2 P70 plasma display (without 9-dot wide font) active
                    7 reserved }
       Reserved       : Array [0..2] Of Byte;
       AvailVidMem    : Byte;
         { 00 = 64k
           01 = 128k
           02 = 192k
           03 = 256k }
       SPtrStateFlags : Byte;
         {Bit 0 512 character set active
              1 dynamic save area present
              2 alpha font override active
              3 graphics font override active
              4 palette override active
              5 DCC override active
              6 reserved
              7 reserved}
       Reserved2 : Array [0..12] Of Byte;
     End;


     pStaticFunc = ^tStaticFunc;
     tStaticFunc = Record
       ModesSupp1 : Byte; { Bit 0-7 reprÑsentieren Mode 0-7 }
       ModesSupp2 : Byte; { Bit 0-7 reprÑsentieren Mode 8-F }
       ModesSupp3 : Byte; { Bit 0-3 reprÑsentieren Mode 10-13 Rest reserv. }
       Reserved   : Array [0..3] Of Byte;
       ScanLSupp  : Byte; { Bit 0-2 reprÑsentieren Scan Lines 200,350,400 }
       AvailTBM   : Byte; { insgesamt verfÅgbare Zeichen in Text-Modes }
       MaxTBM     : Byte; { maximal vrfÅgbare aktive Zeichen in  T-Modes }
       MiscFlags1 : Byte;
         {bit 0 all modes on all displays function supported
              1 gray summing function supported
              2 character font loading function supported
              3 default palette loading enable/disable supported
              4 cursor emulation function supported
              5 EGA palette present
              6 color palette present
              7 color paging function supported}
       MiscFlags2 : Byte;
         {bit 0 light pen supported
              1 save/restore state function 1Ch supported
              2 intensity blinking function supported
              3 Display Combination Code supported
              4-7 reserved}
       Reserved2   : Word;
       SavePtrFl  : Byte;
         {bit 0 512 character set supported
              1 dynamic save area supported
              2 alpha font override supported
              3 graphics font override supported
              4 palette override supported
              5 DCC extension supported
              6 reserved
              7 reserved}
       Reserved3   : Byte;
     End;

     pConfig3270PC = ^tConfig3270PC;
     tConfig3270PC = Record
       XAspect   : Byte;
       YAspect   : Byte;
       MonType   : Byte;
         { 00h = 5151 (mono) or 5272 (color)
           01h = 3295
           02h = 5151 or 5272 with XGA (???) graphics adapter
           03h = 5279 with 3270PC G adapter
           04h = 5379 model C01 with 3270PC GX adapter
           05h = 5379 model M01 with 3270PC GX adapter
           07h = non-3270PC with 3270 Workstation Program
           FFh = 3270PC Control Program not loaded }
       Reserved1  : Byte;
       AdapterId  : Byte;
         { 00h = 5151/5272 adapter
           04h = 5151/5272 with XGA adapter
           30h = 3295 or 3270PC G/GX adapter }
       Reserved2  : Byte;
       FuncFlags1 : Byte;
         { bit 7: mono text, 1 page
               6: color text, 1 page
               5: color text, 4 pages
               4: CGA color graphics
               3: 720x350 two-color graphics
               2: 360x350 four-color graphics
               1: 720x350 eight-color graphics }
       FuncFlags2 : Byte;
         { Bit 6 : GPI graphics supported }
       SegCPL    : Word;
       Reserved3 : Array [0..9] Of Byte;
     End;

     pCPL3270PC = ^tCPL3270PC; { Control Program Level Table }
     tCPL3270PC = Record
       Version    : Word;
         { 02xxh = 3270PC Control Program v2.xx
           03xxh = 3270PC Control Program v3.xx
           04xxh = 3270 Workstation Program v1.xx }
       Id         : Byte;
       Descriptor : String[27]
     End;

Const NA       : String[3]  = 'n/a';
      PC3270NA : String[28] = 'Kontrollprogramm nicht aktiv';
      FG       : String[19] = 'Falsche Grafikkarte';
      Yes      : String[2]  = '[X]';
      No       : String[4]  = '[-]';

      atividmons: array[0..15] of string[25] =
               ('EGA', 'Analog monochrom', 'TTL monochrom', 'Analog Farbe',
                'RGB Farbe', 'Multisync or kompatibel', 'unknown',
                'PS/2 8514 or kompatibel', 'Seiko 1430', 'MultiSync 2A',
                'Tatung OmniScan', 'NEC 3D or kompatibel', 'TVM 3M',
                'NEC MultiSync XL/+/4D/5D', 'TVM 2A', 'TVM 3A');

Var StateBuff    : tStateBuff;
    StaticFunc   : pStaticFunc;
    Config3270PC : pConfig3270PC;
    CPL3270PC    : pCPL3270PC;
    String40     : String[40];

    Function d8or16bit (b: boolean) : Byte;

    Begin
      If b then
        d8or16Bit := 8
      Else
        d8or16Bit := 16;
    End;


    Function Byte2Bit (B : Byte) : String;

    Begin
      S := '';
      If B And 1 = 1 Then S := S + 'X' Else S := S + '-';
      If B And 2 = 1 Then S := S + 'X' Else S := S + '-';
      If B And 4 = 1 Then S := S + 'X' Else S := S + '-';
      If B And 8 = 1 Then S := S + 'X' Else S := S + '-';
      If B And $10 = 1 Then S := S + 'X' Else S := S + '-';
      If B And $20 = 1 Then S := S + 'X' Else S := S + '-';
      If B And $30 = 1 Then S := S + 'X' Else S := S + '-';
      If B And $40 = 1 Then S := S + 'X' Else S := S + '-';
    End;


    Function StateSupp : Boolean;

    Begin
      Regs.AH := $1B;
      Regs.BX := $0000;
      Regs.ES := Seg (StateBuff);
      Regs.DI := Ofs (StateBuff);
      If Regs.AL = $1B Then StateSupp := True Else StateSupp := False;
    End;


Begin
  {$IFNDEF SVGAONLY}
  WhatGCard;
  {$ELSE}
  WhatSVGACard;
  {$ENDIF}
  Case InfoNumber Of
    1   : If (CardNumber = 20) Or (CardNumber = 21) Then
             Begin
               { ATI-revision }
               GraInf := StrFnByte (Mem[$C000:$0043]);
             End
           Else
             GraInf := FG;

    2   : Begin
            { EGA Sicherung des Buffers bei Mode-Wechsel }
            If (CardNumber = 4) Or  (CardNumber >= 8) Then
              Begin
                xbyte:=mem[$0040 : $0087];
                If xbyte and $80 = $80 Then GraInf := Yes
                  Else GraInf := No;
              End
            Else
              GraInf := FG;
          End;
    3   : Begin
            { ist EGA aktiv ? };
            If (CardNumber = 4) Or  (CardNumber >= 8) Then
              Begin
                xbyte:=mem[$0040 : $0087];
                If xbyte and $08 = $00 Then GraInf := Yes
                  Else GraInf := No;
              End
            Else
              GraInf := FG;

          End;
    4   : Begin
            { EGA Warten auf Bildschirm-Zugriff ? };
            If (CardNumber = 4) Or  (CardNumber >= 8) Then
              Begin
                xbyte:=mem[$0040 : $0087];
                If xbyte and $04 = $04 Then GraInf := Yes
                  Else GraInf := No;
              End
            Else
              GraInf := FG;
          End;
    5   : Begin
            { EGA CGA-Cursor Emulation ? };
            If (CardNumber = 4) Or  (CardNumber >= 8) Then
              Begin
                xbyte:=mem[$0040 : $0087];
                If xbyte and $01 = $00 Then GraInf := Yes
                  Else GraInf := No;
              End
            Else
              GraInf := FG;
          End;
    6   : Begin
            { EGA Save area }
            If (CardNumber = 4) Or  (CardNumber >= 8) Then
              Begin
                xword1:=memw[$0040 : $00AA];
                xword2:=memw[$0040 : $00A8];
                GraInf := Hex (xword1, 4) + ':' + Hex (xword2, 4);
              End
            Else
              GraInf := FG;
          End;
    7   : Begin
            { EGA Video parameter table }
            If (CardNumber = 4) Or  (CardNumber >= 8) Then
              Begin
                GraInf := hex (memw[memw[$0040 : $00AA] :
                  memw[$0040 : $00A8] +  2],4) + ':' + hex
                    (memw[memw[$0040 : $00AA] : memw[$0040 : $00A8] ],4);
              End
            Else
              GraInf := FG;
          End;
    8   : Begin
            { EGA Dynamic save area }
            If (CardNumber = 4) Or  (CardNumber >= 8) Then
              Begin
                xword1:=memw[memw[$0040 : $00AA] : memw[$0040 : $00A8] + 6];
                xword2:=memw[memw[$0040 : $00AA] : memw[$0040 : $00A8] + 4];
                if (xword1 > $0000) or (xword2 > $0000) then
                  begin
                    GraInf := hex (xword1, 4) + ':' + hex (xword2, 4);
                  end
                else
                  GraInf := NA;
              End
            Else
              GraInf := FG;
          End;
    9   : Begin
            { EGA Auxiliary character generator }
            If (CardNumber = 4) Or  (CardNumber >= 8) Then
              Begin
                xword1:=memw[memw[$0040 : $00AA] : memw[$0040 : $00A8] + 10];
                xword2:=memw[memw[$0040 : $00AA] : memw[$0040 : $00A8] +  8];
                If (xword1 > $0000) or (xword2 > $0000 ) Then
                  Begin
                    GraInf := hex (xword1, 4) + ':' + hex (xword2,4);
                  End
                Else
                  Grainf := NA;
              End
            Else
              GraInf := FG;
          End;
    10  : Begin
            { EGA Graphics mode auxiliary table }
            If (CardNumber = 4) Or  (CardNumber >= 8) Then
              Begin
                xword1:=memw[memw[$0040 : $00AA] : memw[$0040 : $00A8] + 14];
                xword2:=memw[memw[$0040 : $00AA] : memw[$0040 : $00A8] + 12];
                if (xword1 > $0000) or (xword2 > $0000) then
                  Grainf := hex (xword1, 4) + ':' + hex (xword2, 4)
                else
                  GraInf := NA;
              End
            Else
              GraInf := FG;
          End;
    11  : Begin
            { Video 7 Memory }
            If CardNumber = 9 Then
              Begin
                Port[$3C4]:=$FF;
                xbyte:=Port[$3C5];
                GraInf := StrFnByte(d8or16bit((xbyte and 1) = 0));
              end
            Else
              GraInf := FG;
          End;
    12  : Begin
            { Video 7 I/O }
            If CardNumber = 9 Then
              Begin
                Port[$3C4]:=$FF;
                xbyte:=Port[$3C5];
                GraInf := StrFnByte(d8or16bit((xbyte and 2) = 0));
              end
            Else
              GraInf := FG;
          End;
    13  : Begin
            { Video 7 BIOS }
            If CardNumber = 9 Then
              Begin
                Port[$3C4]:=$FF;
                xbyte:=Port[$3C5];
                GraInf := StrFnByte(d8or16bit((xbyte and 8) = 0));
              end
            Else
              GraInf := FG;
          End;
    14  : Begin
            { Video 7 FastWrite }
            If CardNumber = 9 Then
              Begin
                Port[$3C4]:=$FF;
                xbyte:=Port[$3C5];
                GraInf := StrFnByte(d8or16bit((xbyte and 4) = 0));
              end
            Else
              GraInf := FG;
          End;
    15 : Begin
           {Genoa BUS}
           If CardNumber = 10 Then
             Begin
               Port[$3C4]:=5;
               xbyte:=Port[$3C5];
               if (xbyte and 1) = 1 then
                 GraInf := 'PC'
               else
                 GraInf := 'MCA';
             End
           Else
             GraInf := FG;
         End;
    16 : Begin
           {Genoa Video Width}
           If CardNumber = 10 Then
             Begin
               Port[$3C4]:=5;
               xbyte:=Port[$3C5];
               GraInf := StrFnByte(d8or16bit((xbyte and 2) = 2));
             End
           Else
             GraInf := FG;
         End;
    17 : Begin
           {Genoa BiosWidth}
           If CardNumber = 10 Then
             Begin
               Port[$3C4]:=5;
               xbyte:=Port[$3C5];
               Grainf := StrFnByte(d8or16bit((xbyte and 4) = 4));
             End
           Else
             GraInf := FG;
         End;
    18 : Begin
           {Genoa I/O Ports bei}
           If CardNumber = 10 Then
             Begin
               Port[$3C4]:=5;
               xbyte:=Port[$3C5];
               if (xbyte and $10) = $10 then
                 GraInf := '3xxh'
               else
                 GraInf := '2xxh';
             End
           Else
             GraInf := FG;
         End;
    19 : Begin
           {Genoa Bios Grî·e }
           If CardNumber = 10 Then
             Begin
               Port[$3C4]:=5;
               xbyte:=Port[$3C5];
               case (xbyte and $60) shr 5 of
                 0, 3: GraInf := '24K';
                 1: GraInf := '30K';
                 2: GraInf := '32K';
               end;
             End
           Else
             GraInf := FG;
         End;
    20 : Begin
           {Genoa Monitor-Typ}
           If CardNumber = 10 Then
             Begin
               Port[$3C4]:=7;
               xbyte:=Port[$3C5];
               if (xbyte and $20) = $20 then
                 GraInf := 'TTL Digital'
               else
                 GraInf := 'Analog';
             End
           Else
             GraInf := FG;
         End;
    21 : Begin
           {Genoa Chipset auf}
           If CardNumber = 10 Then
             Begin
               Port[$3C4]:=7;
               xbyte:=Port[$3C5];
               if (xbyte and 8) = 8 then
                 GraInf := 'Motherboard'
               else
                 GraInf := 'Adapter Karte';
             End
           Else
             GraInf := FG;
         End;
    22 : Begin
           {Genoa Fast-Scroll}
           If CardNumber = 10 Then
             Begin
               Port[$3C4]:=$10;
               xbyte:=Port[$3C5];
               If (xbyte and 1) = 1 Then GraInf := Yes Else GraInf := No;
             End
           Else
             GraInf := FG;
         End;
    23 : Begin
           {Genoa Fast-Address}
           If CardNumber = 10 Then
             Begin
               Port[$3C4]:=$10;
               xbyte:=Port[$3C5];
               If (xbyte and 2) = 2 Then GraInf := Yes Else GraInf := No;

             End
           Else
             GraInf := FG;
         End;
    24 : Begin
           {Genoa Fast-Write}
           If CardNumber = 10 Then
             Begin
               Port[$3C4]:=$10;
               xbyte:=Port[$3C5];
               If (xbyte and $40) = $40 Then GraInf := Yes Else GraInf := No;
             End
           Else
             GraInf := FG;
         End;
    25 : Begin
           {Genoa 70hz vertical Retrace}
           If CardNumber = 10 Then
             Begin
               Port[$3C4]:=8;
               xbyte:=Port[$3C5];
               If (xbyte and $10) = $10 Then GraInf := Yes Else GraInf := No;
             End
           Else
             GraInf := FG;
         End;
    26 : Begin
           {Interlaced}
           If CardNumber = 10 Then
             Begin
               xword1:=MemW[$40:$63];
               Port[xword1]:=$2F;
               xbyte:=Port[xword1 + 1];
               If (xbyte and 1) = 1 Then GraInf := Yes Else GraInf := No;
             End
           Else
             GraInf := FG;
         End;
    27 : Begin
           {Bios - Trident 8900/Everex}
           If (CardNumber = 15) Or (CardNumber = 16) Then
             Begin
               Port[$3C4]:=$F;
               xbyte:=Port[$3C5];
               If (xbyte and $80) = 0 Then GraInf := '8 Bit-Bios'
                 Else GraInf := '16 Bit-Bios';
             End
           Else
             GraInf := FG;
         End;
    28 : Begin
           {Interlaced - Trident 8900/Everex}
           If (CardNumber = 15) Or (CardNumber = 16) Then
             Begin
               Port[$3C4]:=$1E;
               xbyte:=Port[$3C5];
               If (xbyte and $20) = $20 Then GraInf := Yes Else
                 GraInf := No;
             End
           Else
             GraInf := FG;
         End;
    29 : Begin
           { Tseng ET ROM }
           If (CardNumber = 17) Or (CardNumber = 18) Then
             Begin
               Case CardNumber Of
                 17 : Begin
                        Port[xword + 4]:=$33;
                        xbyte:=Port[xword + 5];
                      End;
                 18 : Begin
                        Port[xword + 4]:=$37;
                        xbyte:=Port[xword + 5];
                      End;
               End;
               If (xbyte and $10) = 0 Then GraInf := '8 Bit ROM' Else
                 GraInf := '16 Bit ROM';
             End
           Else
             GraInf := FG;
         End;
    30 : Begin
           { Tseng ET Video 8/16 }
           If CardNumber = 17 Then
             Begin
               if Port[$3CC] and 1 = 1 then
                 xword:=$3D0
               else
                 xword:=$3B0;
               Port[xword + 4]:=$36;
               xbyte:=Port[xword + 5];
               If (xbyte and $40) = 0 Then GraInf := '8 Bit Video' Else
                 GraInf := '16 Bit Video';
             End
           Else
             GraInf := FG;
         End;
    31 : Begin
           { TSENG ET I/O }
           If CardNumber = 17 Then
             Begin
               if Port[$3CC] and 1 = 1 then
                 xword:=$3D0
               else
                 xword:=$3B0;
               Port[xword + 4]:=$36;
               xbyte:=Port[xword + 5];

               If (xbyte and $80) = 0 Then GraInf := '8 Bit I/O' Else
                 GraInf := '16 Bit I/O';
             End
           Else
             GraInf := FG;
         End;
    32 : Begin
           { TSENG ET Compatibility };
           If CardNumber = 17 Then
             Begin
               if Port[$3CC] and 1 = 1 then
                 xword:=$3D0
               else
                 xword:=$3B0;
               Port[xword + 4]:=$37;
               xbyte:=Port[xword + 5];

               If xbyte and $80 = $80 then
                 GraInf := 'VGA'
               else
                 GraInf := 'EGA';
             End
           Else
             GraInf := FG;
         End;
    33 : Begin
           { TSENG ET ROM address }
           If CardNumber = 17 Then
             Begin
               if Port[$3CC] and 1 = 1 then
                 xword:=$3D0
               else
                 xword:=$3B0;
               Port[xword + 4]:=$37;
               xbyte:=Port[xword + 5];

               if xbyte and $20 = 0 then
                 if xbyte and 8 = 0 then
                   GraInf := 'C000-C3FF'
                 else
                   GraInf := 'abgewÑhlt'
               else
                 if xbyte and 8 = 0 then
                   GraInf := 'C000-C5FF und C680 - C7FF'
                 else
                   GraInf := 'C000-C7FF';
             End
           Else
             GraInf := FG;
         End;

    34 : Begin
           { ATI mouse port }
           If (CardNumber = 20) Or (CardNumber = 21) Or (CardNumber = 26) Then
             Begin
               xbyte:=Mem[$C000:$42];
               If (xbyte and 2) = 2 Then GraInf := Yes Else GraInf := No;
             End
           Else
             GraInf := FG;
         End;
    35 : Begin
           { ATI programmable video clock }
           If (CardNumber = 20) Or (CardNumber = 21) Or (CardNumber = 26) Then
             Begin
               xbyte:=Mem[$C000:$42];
               If (xbyte and $10) = $10 Then GraInf := Yes Else GraInf := No;
             End
           Else
             GraInf := FG;
         End;
    36 : Begin
           { ATI monitor }
           If (CardNumber = 20) Or (CardNumber = 21) Or (CardNumber = 26) Then
             Begin
               xword1:=MemW[$C000:$10];
               xbyte:=ATIinfo($BB, xword1);
               GraInf := atividmons[xbyte and $0F];
             End
           Else
             GraInf := FG;
         End;
    37 : Begin
           { ATI 18800+ 70Hz non-interlace }
           If (CardNumber = 21) Or (CardNumber = 26) Then
             Begin
               xbyte:=Mem[$C000:$44];
               If (xbyte and 1) = 1 Then GraInf := Yes Else GraInf := No;
             End
           Else
             GraInf := FG;
         End;
    38 : Begin
           { ATI 18800+ Korean chars }
           If (CardNumber = 21) Or (CardNumber = 26) Then
             Begin
               xbyte:=Mem[$C000:$44];
               If (xbyte and 2) = 2 Then GraInf := Yes Else GraInf := No;
             End
           Else
             GraInf := FG;
         End;
    39 : Begin
           { ATI 18800+ Memory clock }
           If (CardNumber = 21) Or (CardNumber = 26) Then
             Begin
               xbyte:=Mem[$C000:$44];
               if (xbyte and 4 = 4) then
                 GraInf := '45MHz'
               else
                 GraInf := '40MHz';
             End
           Else
             GraInf := FG;
         End;
    40 : Begin
           { ATI 18800+ Zero wait state }
           If (CardNumber = 21) Or (CardNumber = 26) Then
             Begin
               xbyte:=Mem[$C000:$44];
               If (xbyte and 8) = 8 Then GraInf := Yes Else GraInf := No;
             End
           Else
             GraInf := FG;
        End;
   41 : Begin
           { ATI 18800+ Paged ROM's }
           If (CardNumber = 21) Or (CardNumber = 26) Then
             Begin
               xbyte:=Mem[$C000:$44];
               If (xbyte and $10) = $10 Then GraInf := Yes Else GraInf := No;
             End
           Else
             GraInf := FG;
        End;
   42 : Begin
           { ATI 18800+ 8514/A }
           If (CardNumber = 21) Or (CardNumber = 26) Then
             Begin
               xbyte:=Mem[$C000:$44];
               If (xbyte and $40) <> $40 Then GraInf := Yes Else GraInf := No;
             End
           Else
             GraInf := FG;
        End;
   43 : Begin
           { Standard VGA Color Page }
           If CardNumber >= 8 Then
             Begin
               Regs.AX:=$101A;
               Intr ($10, Regs);
               GraInf := hex(Regs.BH, 2) + 'h';
             End
           Else
             GraInf := FG;
        End;
   44 : Begin
           { Standard VGA Paging Mode }
           If CardNumber >= 8 Then
             Begin
               Regs.AX:=$101A;
               Intr ($10, Regs);
               Case Regs.BL Of
                 $00 : GraInf := '4 Seiten von 64 Registern';
                 $01 : GraInf := '16 Seiten von 16 Registern';
               Else
                 GraInf := 'unknown Modus' + Hex(Regs.BL, 2);
               End;
             End
           Else
             GraInf := FG;
        End;
   45 : Begin
          { MCGA/VGA Video Mode }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                  GraInf := StrFnByte (StateBuff.VidMode);
                End
              Else
                GraInf := NA;
            End
          Else
            GraInf := FG;
        End;
   46 : Begin
          { MCGA/VGA Length Regenerate Buffer }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                  GraInf := StrFnWord (StateBuff.LengthRegenBuf);
                End
              Else
                GraInf := NA;
            End
          Else
            GraInf := FG;
        End;
   47 : Begin
          { MCGA/VGA Start Address Regenerate Buffer }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                  GraInf := Hex (StateBuff.StartAdrLRB, 4);
                End
              Else
                GraInf := NA;
            End
          Else
            GraInf := FG;
        End;
   48 : Begin
          { MCGA/VGA Cursor Position Page 0 }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                  GraInf := StrFnWord (StateBuff.CursorPos0);
                End
              Else
                GraInf := NA;
            End
          Else
            GraInf := FG;
        End;
   49 : Begin
          { MCGA/VGA Cursor Position Page 1 }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                   GraInf := StrFnWord (StateBuff.CursorPos1);
                End
              Else
                GraInf := NA;
            End
          Else
            GraInf := FG;
        End;
   50 : Begin
          { MCGA/VGA Cursor Position Page 2 }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                   GraInf := StrFnWord (StateBuff.CursorPos2);
                End
              Else
                GraInf := NA;

            End
          Else
            GraInf := FG;
        End;
   51 : Begin
          { MCGA/VGA Cursor Position Page 3 }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                   GraInf := StrFnWord (StateBuff.CursorPos3);
                End
              Else
                GraInf := NA;

            End
          Else
            GraInf := FG;
        End;
   52 : Begin
          { MCGA/VGA Cursor Position Page 4 }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                   GraInf := StrFnWord (StateBuff.CursorPos4);
                End
              Else
                GraInf := NA;

            End
          Else
            GraInf := FG;
        End;
   53 : Begin
          { MCGA/VGA Cursor Position Page 5 }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                  GraInf := StrFnWord (StateBuff.CursorPos5);
                End
              Else
                GraInf := NA;

            End
          Else
            GraInf := FG;
        End;
   54 : Begin
          { MCGA/VGA Cursor Position Page 6 }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                  GraInf := StrFnWord (StateBuff.CursorPos6);
                End
              Else
                GraInf := NA;

            End
          Else
            GraInf := FG;
        End;
   55 : Begin
          { MCGA/VGA Cursor Position Page 7 }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                  GraInf := StrFnWord (StateBuff.CursorPos7);
                End
              Else
                GraInf := NA;
            End
          Else
            GraInf := FG;
        End;
   56 : Begin
          { MCGA/VGA CursorType }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                  GraInf := StrFnWord (StateBuff.CursorType);
                End
              Else
                GraInf := NA;
            End
          Else
            GraInf := FG;
        End;
   57 : Begin
          { MCGA/VGA Active Video Page }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                  GraInf := StrFnByte (StateBuff.ActivePage);
                End
              Else
                GraInf := NA;
            End
          Else
            GraInf := FG;
        End;
   58 : Begin
          { MCGA/VGA Bytes/Char }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                  GraInf := StrFnWord (StateBuff.BytesChar);
                End
              Else
                GraInf := NA;
            End
          Else
            GraInf := FG;
        End;
   59 : Begin
          { MCGA/VGA Combination Code }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                  GraInf := Hex (StateBuff.CombCode,2) + 'h';
                End
              Else
                GraInf := NA;
            End
          Else
            GraInf := FG;
        End;
   60 : Begin
          { MCGA/VGA Colors in Current Mode }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                  GraInf := StrFnWord (StateBuff.ColorsCurMode);
                End
              Else
                GraInf := NA;
            End
          Else
            GraInf := FG;
        End;
   61 : Begin
          { MCGA/VGA Pages in Current Mode }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                  GraInf := StrFnByte (StateBuff.PagesCurMode);
                End
              Else
                GraInf := NA;
            End
          Else
            GraInf := FG;
        End;
   62 : Begin
          { MCGA/VGA Scanlines }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                  Case StateBuff.ScanLines Of
                    1 : GraInf := '200';
                    2 : GraInf := '350';
                    3 : GraInf := '400';
                    4 : GraInf := '480';
                  End;
                End
              Else
                GraInf := NA;
            End
          Else
            GraInf := FG;
        End;
   63 : Begin
          { MCGA/VGA Default Palette Loading Disabled ? }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                  If (StateBuff.MiscFlags And 4) = 1 Then GraInf := Yes
                    Else GraInf := No;
                End
              Else
                GraInf := NA;
            End
          Else
            GraInf := FG;
        End;
   64 : Begin
          { MCGA/VGA Cursor Emulation Enabled ? }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                If (StateBuff.MiscFlags And 8) = 1 Then GraInf := Yes
                    Else GraInf := No;
                End
              Else
                GraInf := NA;
            End
          Else
            GraInf := FG;
        End;
   65 : Begin
          { MCGA/VGA PS/2 Plasma Display active ? }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                  If (StateBuff.MiscFlags And $20) = 1 Then GraInf := Yes
                      Else GraInf := No;
                End
              Else
                GraInf := NA;
            End
          Else
            GraInf := FG;
        End;
   66 : Begin
          { MCGA/VGA Welche Modi sind auf dieser Grafikkarte mîglich ? (9-13h) }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                  StaticFunc := StateBuff.StaticFunc;
                  GraInf := Byte2Bit (StaticFunc^.ModesSupp1) +
                    Byte2Bit (StaticFunc^.ModesSupp2) +
                      Byte2Bit (StaticFunc^.ModesSupp3);
                End
              Else
                GraInf := NA;
            End
          Else
            GraInf := FG;
        End;
   67 : Begin
          { MCGA/VGA Character Font Loading Function Supported }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                  StaticFunc := StateBuff.StaticFunc;
                  If (StaticFunc^.MiscFlags1 And 4) = 1 Then GraInf := Yes
                    Else GraInf := No;
                End
              Else
                GraInf := NA;
            End
          Else
            GraInf := FG;
        End;
   68 : Begin
          { MCGA/VGA Default Palette Loading Enable/Disable Supported }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                  StaticFunc := StateBuff.StaticFunc;
                  If (StaticFunc^.MiscFlags1 And 8) = 1 Then GraInf := Yes
                    Else GraInf := No;
                End
              Else
                GraInf := NA;
            End
          Else
            GraInf := FG;
        End;
   69 : Begin
          { MCGA/VGA Cursor Emulation Function Supported }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                  StaticFunc := StateBuff.StaticFunc;
                  If (StaticFunc^.MiscFlags1 And $10) = 1 Then GraInf := Yes
                    Else GraInf := No;
                End
              Else
                GraInf := NA;
            End
          Else
            GraInf := FG;
        End;
   70 : Begin
          { MCGA/VGA Color Paging Function supported }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                  StaticFunc := StateBuff.StaticFunc;
                  If (StaticFunc^.MiscFlags1 And $40) = 1 Then GraInf := Yes
                    Else GraInf := No;
                End
              Else
                GraInf := NA;
            End
          Else
            GraInf := FG;
        End;
   71 : Begin
          { MCGA/VGA Light Pen supported }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                  StaticFunc := StateBuff.StaticFunc;
                  If (StaticFunc^.MiscFlags2 And 1) = 1 Then GraInf := Yes
                    Else GraInf := No;
                End
              Else
                GraInf := NA;
            End
          Else
            GraInf := FG;
        End;
   72 : Begin
          { MCGA/VGA 512 Character Set supported }
          If (CardNumber = 2) Or (CardNumber >= 8) Then
            Begin
              If StateSupp Then
                Begin
                  StaticFunc := StateBuff.StaticFunc;
                  If (StaticFunc^.SavePtrFl And 1) = 1 Then GraInf := Yes
                    Else GraInf := No;
                End
              Else
                GraInf := NA;
            End
          Else
            GraInf := FG;
        End;
   73 : Begin
          { IBM 3270 PC X Aspect Ratio }
          If CardNumber = 7 Then
            Begin
              Regs.AX := $3000;
              Regs.CX := $0000;
              Regs.DX := $0000;
              Intr ($10, Regs);
              If (Regs.CX > 0) Or (Regs.DX > 0) Then
                Begin
                  Config3270PC := Ptr (Regs.CX, Regs.DX);
                  GraInf := StrFnByte (Config3270PC^.XAspect);
                End
              Else
                GraInf := 'Kontrollprogramm nicht aktiv';
            End
          Else
            GraInf := FG;
        End;
   74 : Begin
          { IBM 3270 PC Y Aspect Ratio }
          If CardNumber = 7 Then
            Begin
              Regs.AX := $3000;
              Regs.CX := $0000;
              Regs.DX := $0000;
              Intr ($10, Regs);
              If (Regs.CX > 0) Or (Regs.DX > 0) Then
                Begin
                  Config3270PC := Ptr (Regs.CX, Regs.DX);
                  GraInf := StrFnByte (Config3270PC^.YAspect) ;
                End
              Else
                GraInf := PC3270NA;
            End
          Else
            GraInf := FG;
        End;
   75 : Begin
          { IBM 3270 PC Monitor Typ }
          If CardNumber = 7 Then
            Begin
              Regs.AX := $3000;
              Regs.CX := $0000;
              Regs.DX := $0000;
              Intr ($10, Regs);
              If (Regs.CX > 0) Or (Regs.DX > 0) Then
                Begin
                  Config3270PC := Ptr (Regs.CX, Regs.DX);
                  Case Config3270PC^.MonType Of
                    $00 : GraInf := '5151 (mono) or 5272 (farbe)';
                    $01 : GraInf := '3295';
                    $02 : GraInf := '5151 or 5272 nit XGA Grafikkarte';
                    $03 : GraInf := '5279 with 3270PC G-Adapter';
                    $04 : GraInf := '5379 Mod. C01 with 3270PC GX-Adapter';
                    $05 : GraInf := '5379 Mod. M01 with 3270PC GX-Adapter';
                    $06 : GraInf := 'kein 3270PC with 3270 Workstation Programm';
                    $FF : GraInf := '3270PC Kontrollprogramm nicht geladen';
                  Else
                    GraInf := 'unknown Monitor';
                  End;
                End
              Else
                GraInf := PC3270NA;
            End
          Else
            GraInf := FG;
        End;
   76 : Begin
          { IBM 3270 PC Adapter ID }
          If CardNumber = 7 Then
            Begin
              Regs.AX := $3000;
              Regs.CX := $0000;
              Regs.DX := $0000;
              Intr ($10, Regs);
              If (Regs.CX > 0) Or (Regs.DX > 0) Then
                Begin
                  Config3270PC := Ptr (Regs.CX, Regs.DX);
                  Case Config3270PC^.AdapterId Of
                    $00 : GraInf := '5151/5272 Adapter';
                    $04 : GraInf := '5151/5272 with XGA Adapter';
                    $30 : GraInf := '3295 or 3270PC G/GX Adapter';
                  Else
                    GraInf := 'unknown Adapter';
                  End;
                End
              Else
                GraInf := PC3270NA;
            End
          Else
            GraInf := FG;
        End;
   77 : Begin
          { IBM 3270 PC unterstÅtzte Modi }
          If CardNumber = 7 Then
            Begin
              Regs.AX := $3000;
              Regs.CX := $0000;
              Regs.DX := $0000;
              Intr ($10, Regs);
              If (Regs.CX > 0) Or (Regs.DX > 0) Then
                Begin
                  Config3270PC := Ptr (Regs.CX, Regs.DX);
                  GraInf := Byte2Bit (Config3270PC^.FuncFlags1);
                End
              Else
                GraInf := PC3270NA;
            End
          Else
            GraInf := FG;
        End;
   78 : Begin
          { IBM 3270 PC GPI Graphics Support }
          If CardNumber = 7 Then
            Begin
              Regs.AX := $3000;
              Regs.CX := $0000;
              Regs.DX := $0000;
              Intr ($10, Regs);
              If (Regs.CX > 0) Or (Regs.DX > 0) Then
                Begin
                  Config3270PC := Ptr (Regs.CX, Regs.DX);
                  If (Config3270PC^.FuncFlags2 And $20) = 1 Then
                    GraInf := Yes Else GraInf := No;
                End
              Else
                GraInf := PC3270NA;
            End
          Else
            GraInf := FG;
        End;
   79 : Begin
          { IBM 3270 PC Kontrollprogramm-Version }
          If CardNumber = 7 Then
            Begin
              Regs.AX := $3000;
              Regs.CX := $0000;
              Regs.DX := $0000;
              Intr ($10, Regs);
              If (Regs.CX > 0) Or (Regs.DX > 0) Then
                Begin
                  Config3270PC := Ptr (Regs.CX, Regs.DX);
                  CPL3270PC := Ptr (Config3270PC^.SegCPL, 0);
                  Case Hi (CPL3270PC^.Version) Of
                    $01 : GraInf := '3270PC Control Program v1.' +
                                     ZeroPad (Lo (CPL3270PC^.Version));
                    $02 : GraInf := '3270PC Control Program v2.' +
                                     ZeroPad (Lo (CPL3270PC^.Version));
                    $03 : GraInf := '3270PC Control Program v3.' +
                                     ZeroPad (Lo (CPL3270PC^.Version));
                    $04 : GraInf := '3270PC Workstation Program v1.' +
                                     ZeroPad (Lo (CPL3270PC^.Version));
                  End;
                End
              Else
                GraInf := PC3270NA;
            End
          Else
            GraInf := FG;
        End;
   80 : Begin
          { IBM 3270 PC Control Program Id String }
          If CardNumber = 7 Then
            Begin
              Regs.AX := $3000;
              Regs.CX := $0000;
              Regs.DX := $0000;
              Intr ($10, Regs);
              If (Regs.CX > 0) Or (Regs.DX > 0) Then
                Begin
                  Config3270PC := Ptr (Regs.CX, Regs.DX);
                  CPL3270PC := Ptr (Config3270PC^.SegCPL, 0);
                  GraInf := CPL3270PC^.Descriptor;
                End
              Else
                GraInf := PC3270NA;
            End
          Else
            GraInf := FG;
        End;
   81 : Begin
          { S3 Diamond Stealth Check }
          If (CardNumber = 23) Or (CardNumber = 24) Then
            Begin
              Regs.AX := $1DAA;
              Regs.BX := $FDEC;
              Intr ($10, Regs);
              If Regs.AL = 1 Then
                Begin
                  EndString := 'Diamond Stealth VRAM with ';
                  Case Regs.AH Of
                    $00 : EndString := EndString + 'Standard VGA DAC';
                    $11 : EndString := EndString + 'Highcolor DAC';
                    $23 : EndString := EndString + 'SS2410 DAC';
                    $33 : EndString := EndString + 'HighColor DAC without RS2';
                    $43 : EndString := EndString + 'HighColor DAC with RS2';
                  Else
                    EndString := EndString + 'unknown DAC';
                  End;
                End
              Else If Regs.AL = 2 Then
                Begin
                  EndString := 'Diamond Stealth 24 with ';
                  Case Regs.AH Of
                    $00 : EndString := EndString + 'Standard VGA DAC';
                    $11 : EndString := EndString + 'Highcolor DAC';
                    $23 : EndString := EndString + 'SS2410 DAC';
                    $33 : EndString := EndString + 'HighColor DAC without RS2';
                    $43 : EndString := EndString + 'HighColor DAC with RS2';
                  Else
                    EndString := EndString + 'unknown DAC';
                  End;
                End
              Else
                GraInf := 'keine Diamond Stealth';
            End
          Else
            GraInf := FG;
        End;
   82 : Begin
          { S3 MEMCS16 8/16 }
          If (CardNumber = 24) Then
            Begin
              Port[$03D4] := $3A;
              If (Port[$03D5] And $80 = $80) Then GraInf := '16 - Bit MEMCS16'
                Else GraInf := '8 - Bit MEMCS16';
            End
          Else
            GraInf := FG;
        End;
   83 : Begin
          { S3 Fast Write Buffer }
          If (CardNumber = 24) Then
            Begin
              Port[$03D4] := $40;
              If (Port[$03D5] And 8 = 8) Then GraInf := 'Fast Write Buffer ist an'
                Else GraInf := 'Fast Write Buffer ist aus';
            End
          Else
            GraInf := FG;
        End;
   84 : Begin
          { S3 Zero Waitstate (EISA^) }
          If (CardNumber = 24) Then
            Begin
              Port[$03D4] := $40;
              If (Port[$03D5] And $40 = $40) Then GraInf := '[-]'
                Else GraInf := '[X]';
            End
          Else
            GraInf := FG;
        End;
   85 : Begin
          { AHEAD A/B 8 Fonts }
          If (CardNumber = 25) Then
            Begin
              Port [$3CE] := $C;
              xByte := Port[$3CF];
              If (xByte And 1 = 0) And (xByte And 2 = 2) Then GraInf := '[X]'
                Else GraInf := '[-]';
            End
          Else
            GraInf := FG;
        End;
   86 : Begin
          { AHEAD A/B High Speed Sequencer eingeschaltet }
          If (CardNumber = 25) Then
            Begin
              Port [$3CE] := $C;
              If Port[$3CF] And 8 = 8 Then GraInf := '[X]'
                Else GraInf := '[-]';
            End
          Else
            GraInf := FG;
        End;
   87 : Begin
          { AHEAD A/B 16 Bit Memory eingeshaltet }
          If (CardNumber = 25) Then
            Begin
              Port [$3CE] := $C;
              If Port[$3CF] And $10 = $10 Then GraInf := '[X]'
                Else GraInf := '[-]';
            End
          Else
            GraInf := FG;
        End;
   88 : Begin
          { AHEAD A/B Emulation Mode }
          If (CardNumber = 25) Then
            Begin
              Port [$3CE] := $C;
              xByte := Port[$3CF];
              If (xByte And $40 = 0) And (xByte And $40 = 0) Then GraInf := 'VGA'
                Else If (xByte And $40 = 0) And (xByte And $40 = $40) Then GraInf := 'EGA'
                Else If (xByte And $40 = $40) And (xByte And $40 = 0) Then GraInf := 'Hercules'
                Else If (xByte And $40 = $40) And (xByte And $40 = $40) Then GraInf := 'CGA';
            End
          Else
            GraInf := FG;
        End;
   89 : Begin
          { AHEAD A/B 24/32 KB BIOS }
          If (CardNumber = 25) Then
            Begin
              Port [$3CE] := $1F;
              If Port[$3CF] And 4 = 4 Then GraInf := '32k'
                Else GraInf := '24k';
            End
          Else
            GraInf := FG;
        End;
   90 : Begin
          { AHEAD A/B 8/16 Bit BIOS }
          If (CardNumber = 25) Then
            Begin
              Port [$3CE] := $1F;
              If Port[$3CF] And 8 = 8 Then GraInf := '16-Bit BIOS'
                Else GraInf := '8-Bit BIOS';
            End
          Else
            GraInf := FG;
        End;
   91 : Begin
          { ATI 28800+ True Color DAC Enabled }
          If (CardNumber = 26) Then
            Begin
              xWord := MemW[$C000:$0010];
              Port[xWord] := $A7;
              xByte := Port[xWord+1];
              If (xByte And 2 = 2) And (xByte And 8 = 8) Then GraInf := Yes
                Else GraInf := No;
            End
          Else
            GraInf := FG;
        End;
   92 : Begin
          { Avance Logic Al2101 MAximale horizontale Frequenz}
          If (CardNumber = 27) Then
            Begin
              Port[$3D4] := $1E;
              xByte := Port[$3D5];
              If (xByte And $40 = 0) And (xByte And $80 = 0) Then GraInf := '38 khz'
                Else If (xByte And $40 = 0) And (xByte And $80 = $80) Then GraInf := '48 khz'
                Else If (xByte And $40 = $40) And (xByte And $80 = 0) Then GraInf := '56 khz'
                Else If (xByte And $40 = $40) And (xByte And $80 = $80) Then GraInf := '64 khz';
            End
          Else
            GraInf := FG;
        End;
   93 : Begin
          { Avance Logic Al2101 Emulation }
          If (CardNumber = 27) Then
            Begin
              Port[$3D4] := $1F;
              xByte := Port[$3D5];
              If (xByte And 1 = 0) And (xByte And 2 = 0) Then GraInf := 'VGA'
                Else If (xByte And 1 = 0) And (xByte And 2 = 2) Then GraInf := 'EGA'
                Else If (xByte And 1 = 1) And (xByte And 2 = 0) Then GraInf := 'CGA'
                Else If (xByte And 1 = 1) And (xByte And 2 = 2) Then GraInf := 'MDA';

            End
          Else
            GraInf := FG;
        End;
   94 : Begin
          { Cirrus Ist ein Cirrus BIOS installiert ? }
          If (CardNumber = 12) Then
            Begin
              S := Chr(MEM[$C000:$0006]) + Chr (Mem[$C000:$0007]);
              If S = 'CL' Then GraInf := Yes Else GraInf := No;
            End
          Else
            GraInf := FG;
        End;
   95 : Begin
          { Cirrus BIOS / Version }
          If (CardNumber = 12) And (GraInf (94) = Yes) Then
            Begin
              Regs.AH := $12;
              Regs.BL := $81;
              Intr ($10, Regs);
              GraInf := StrFnByte (Regs.AH) + '.' + StrFnByte (Regs.AL);
            End
          Else
            GraInf := FG;
        End;
   96 : Begin
          { Cirrus BIOS / Memory }
          If (CardNumber = 12) And (GraInf (94) = Yes) Then
            Begin
              Regs.AH := $12;
              Regs.BL := $85;
              Intr ($10, Regs);
              GraInf := StrFnWord (Regs.AL*64) + 'kb';
            End
          Else
            GraInf := FG;
        End;
   97 : Begin
          { Cirrus BIOS / Monitortyp und ID vom 15Pin Connector }
          If (CardNumber = 12) And (GraInf (94) = Yes) Then
            Begin
              Regs.AH := $12;
              Regs.BL := $A1;
              Intr ($10, Regs);
              Case Regs.BH Of
                $00..$08 : GraInf := 'reserviert (' + StrFnByte (Regs.BH) + ')';
                $09 : GraInf := 'IBM 8604/8507';
                $0A : GraInf := 'IBM 8514';
                $0B : GraInf := 'IBM 8515';
                $0D : GraInf := 'IBM 8503';
                $0E : GraInf := 'IBM 8512/8513';
                $0F : GraInf := 'kein Monitor';
              Else
                GraInf := 'unknown (' + StrFnByte (Regs.BH) + ')';
              End;
            End
          Else
            GraInf := FG;
        End;
   98 : Begin
          { Compaq Monitortyp }
          If (CardNumber = 28) Then
            Begin
              Port [$3CE] := $50;
              xByte := Port[$3CF];
              Case (xByte Shr 1) Shl 4 Of
                $00 : GraInf := 'Compaq Interner Monitor';
                $02 : GraInf := 'Compaq 16" Advanced Graphics Farbmonitor';
                $03 : GraInf := 'Compaq 1024 Farbmonitor';
                $04 : GraInf := 'QVision 200 (20") Farbmonitor';
                $05 : GraInf := 'Compaq SVGA Color Monitor';
                $06 : GraInf := 'QVision 150 (15") or Compaq 151 FS Farbmonitor';
                $0E : GraInf := 'Compaq 14" VGA Monitor (31.5 kHz)';
              Else
                GraInf := 'unknown Monitor';
              End;
            End
          Else
            GraInf := FG;
        End;
   99 : Begin
          { Everex BIOS Version }
          If (CardNumber = 16) Then
            Begin
              Regs.AX := $7000;
              Regs.BX := $0000;
              Intr ($10, Regs);
              GraInf := BCDWordToString (Regs.DI);
            End
          Else
            GraInf := FG;
        End;
   100 : Begin
           { RealTek Emulationsmodus }
           If (CardNumber = 34) Then
             Begin
               Port[$3D4] := $1F;
               xByte := Port[$3D5];
               If (xByte And 1 = 0) And (xByte And 2 = 0) Then GraInf := 'VGA'
                 Else If (xByte And 1 = 0) And (xByte And 2 = 2) Then GraInf := 'EGA'
                 Else If (xByte And 1 = 1) And (xByte And 2 = 0) Then GraInf := 'CGA'
                 Else If (xByte And 1 = 1) And (xByte And 2 = 2) Then GraInf := 'MDA';

             End
           Else
             GraInf := FG;
         End;
   101 : Begin
           { Yamaha Clock-Set }
           If (CardNumber = 37) Then
             Begin
               xByte := Port[$3C2];
               Case (xByte And 12) Shr 2 Of
                 0 : GraInf := 'CLK0 (norm. 25.175 Mhz)';
                 1 : GraInf := 'CLK1 (norm. 28.322 Mhz)';
                 2 : GraInf := 'CLK2 (norm. extern)';
                 3 : GraInf := 'CLK3 (norm. panel Clock)';
               End;
             End
           Else
             GraInf := FG;
         End;
   102 : Begin
           { Video Clock-Set }
           If (CardNumber = 9) Then
             Begin
               Port[$3C4] := $A4;
               xByte := Port[$3C5];
               Case (xByte And 28) Shr 2 Of
                 0 : GraInf := '25.175 Mhz';
                 1 : GraInf := '28.322 Mhz';
                 2 : GraInf := '30.000 Mhz';
                 3 : GraInf := '32.514 Mhz';
                 4 : GraInf := '34.000 Mhz';
                 5 : GraInf := '36.000 Mhz';
                 6 : GraInf := '38.000 Mhz';
                 7 : GraInf := '40.000 Mhz';
               End;
             End
           Else
             GraInf := FG;
         End;
   103 : Begin
           { Video Clock-Source }
           If (CardNumber = 9) Then
             Begin
               Port[$3C4] := $F8;
               xByte := Port[$3C5];
               Case (xByte And 224) Shr 5 Of
                 0 : GraInf := '25.175 Mhz';
                 1 : GraInf := '28.322 Mhz';
                 2 : GraInf := '30.000 Mhz';
                 3 : GraInf := '32.514 Mhz';
                 4 : GraInf := '34.000 Mhz';
                 5 : GraInf := '36.000 Mhz';
                 6 : GraInf := '38.000 Mhz';
                 7 : GraInf := '40.000 Mhz';
               End;
             End
           Else
             GraInf := FG;
         End;
   104 : Begin
           { RealTek Bios-String }
           If (CardNumber = 34) Then
             Begin
               Regs.AX := $5F01;
               Regs.ES := Seg (String40);
               Regs.DI := Ofs (String40);
               For xByte2 := 1 To 40 Do String40[xByte2] := #0;
               Intr ($10, Regs);
               String40[0] := Chr(40);
               If Regs.AH = 0 Then
                 GraInf := Copy (String40,1,Pos(String40,#0))
               Else
                 GraInf := 'Vom Bios nicht unterstÅtzt';
             End
           Else
             GraInf := FG;
         End;
  Else
    GraInf := 'Informationsnummer nicht bekannt'
  End;
End;


Function ScanLinesChar;

Begin
  Regs.AX := $1130;
  Regs.BH := $00;
  Intr ($10, regs);
  ScanLinesChar := Regs.CX
End;


Function ScanLinesCursor;

Var S2 : String;
    P : pBiosRecord;

Begin
  P := GetBiosRecord;
  Regs.AH := $03;
  Regs.BH := P^.ScreenPage;
  Intr ($10, Regs);
  Str (Regs.Ch, S);
  Str (Regs.Cl, S2);
  ScanLinesCursor := S + '-' + S2;
End;


Function GetFontAddress (FontNumber : Byte) : Pointer;

Begin
  If FontNumber = 1 Then
    Begin
      GetFontAddress := Ptr (Longint (MemW [0:$1F*4]), Longint (MemW [0:$1F*4+2]));
    End
  Else
    Begin
      Regs.AX := $1130;
      Regs.BH := FontNumber;
      Intr ($10, Regs);
      GetFontAddress := Ptr (Regs.BP, Regs.ES);
    End;
End;


Function GetPaletteRegister;

Var VGABuf : Array [$00..$10] Of Byte;

Begin
  Regs.AX := $1009;
  Regs.ES := Seg (VGABuf);
  Regs.DX := Ofs (VGABuf);
  Intr ($10, Regs);
  For xByte := $00 To $0F Do
    If xByte = Color Then
      GetPaletteRegister := VGABuf [xByte];
End;


Procedure PreSpeedTest;

Var
    MonochromMode : Boolean;
    EMM_Name      : String[8];
    Dummy         : Byte;
    Typ           : Byte;

Begin
  Regs.AH := $0F;                       { get screen status }
  Intr ($10, Regs);                     { BIOS video interupt }
  MonoChromMode := (Regs.AL = 7);
  IF MonoChromMode THEN
      ScreenAddr := Ptr ($B000,0000)
   ELSE
      ScreenAddr := Ptr ($B800,0000);

  EMM_Name := '        ';
  Regs.AH := $35;
  Regs.AL := $67;
  Intr ($21, Regs);
  Move (Mem [Regs.ES:$0A], EMM_Name[1], 8);
  ExpandedMem := (EMM_Name = 'EMMXXXX0');

  If ExpandedMem Then
    Begin
      EMS_Base := 0;
      Regs.AH := $41;
      Intr ($67, Regs);
      EMS_Base := Regs.BX;
    End
  Else
    EMS_Base := 0;

  Typ := Mem [$FFFF:$000E];
  Regs.AH := $88;
  Intr ($15, Regs);
  ExtendedMem := (((Regs.Flags AND FCarry) = 0) AND (Regs.AX <> 0));
  IF ExtendedMem THEN
    Begin
    End
  ELSE IF (Typ = $FC) OR ((Typ >= $F5) AND (Typ <= $F8)) THEN BEGIN
      Port [$70] := $30;
      Dummy := Port [$71];
      Port [$70] := $31;
      ExtendedMem := (Port [$71] * 256 + Dummy) > 0;
  END;
End;


Function VideoWaits;

Type Processor = (NA, i88, i86, iC88, iC86, V20, V30, i188, i186, i286, i386,
                  i386sx, ct386, ct386sx, p486dlc, p486slc, rapidcad, i486,
                  i486sx, Pentium, NexGen, Cyrix);

Const
   AAM_Time : Array [i88 .. Cyrix] Of Integer =
              (77, 77, 77, 77, 15, 15, 19, 19, 16, 17, 17, 16, 16,
              17, 17, 15, 15, 15, 18, 18, 17);

   FillTime :   Array [i88 .. Cyrix] Of Integer =
                (10, 10, 10, 10, 4, 4, 9, 9, 3, 5, 5, 5, 5,
                4, 4, 4, 4, 4, 1, 1, 1);

Var MoveBuffer    : Pointer;
    ScreenWaits   : Word;
    FillTakte     : Real;
    CPU           : Processor;

Begin
  PreSpeedTest;
  GetMem (MoveBuffer, 20000);

  SpeedTest (Word (0) { BildSchirm }, Word(ExtendedMem), Word(ExpandedMem),
             MoveBuffer, Ptr (EMS_Base, 0), ScreenAddr, Result);

  CPU := Processor (Result.CPUType);
  TempFreq   := 200 * AAM_Time [CPU] * ClockFreq / Result.AAMTime;
  FillTakte  := Result.ScreenFillTime * TempFreq / (ClockFreq * 5000);
  ScreenWaits:= Trunc (FillTakte - FillTime [CPU] + 0.1);
  VideoWaits := ScreenWaits;

  FreeMem (MoveBuffer, 20000);
End;


Function BiosSpeed;

Var MoveBuffer  : Pointer;

Begin
  PreSpeedTest;
  GetMem (MoveBuffer, 20000);

  SpeedTest (Word (0) { BildSchirm }, Word(ExtendedMem), Word(ExpandedMem),
             MoveBuffer, Ptr (EMS_Base, 0), ScreenAddr, Result);

  BiosSpeed := 20 * ClockFreq / Result.BiosWriteTime;

  FreeMem (MoveBuffer, 20000);
End;


Function DosSpeed;

Var MoveBuffer  : Pointer;

Begin
  PreSpeedTest;
  GetMem (MoveBuffer, 20000);

  SpeedTest (Word (0) { BildSchirm }, Word(ExtendedMem), Word(ExpandedMem),
             MoveBuffer, Ptr (EMS_Base, 0), ScreenAddr, Result);

  DosSpeed := 20 * ClockFreq / Result.DosWriteTime;

  FreeMem (MoveBuffer, 20000);
End;


Function TestVertHz;

Var I         : Word;
    Start     : Word;
    EndTimer  : Word;
    Integ     : Integer;
    ConvStr   : String;

Begin
  Start := Clock;
  Asm
    mov cx, 0
    mov dx,3dah
  @1: in al,dx
    test al,8
    jz @1
  @2: in al,dx
    test al,8
    jnz @2
    inc cx
    cmp cx,150
    jnz @1
  End;
  EndTimer := Clock-Start;
  Str (1000/(EndTimer/150):3:0, ConvStr); { Mir viel einfach kein besserer }
  Val (ConvStr, EndTimer, Integ); { Weg ein, um einen 2stelligen Wert zu   }
  TestVertHz := EndTimer; { bekommen. (mit Nachkommastellen ist es ungenau)    }
End;


Function TestHorizHz;

Var I         : Word;
    Start     : Word;
    EndTimer  : Word;

Begin
  Start := Clock;
  Asm
    mov cx, 20000
    mov dx,3dah
  @1: in al,dx
    test al,1
    jz @1
  @2: in al,dx
    test al,1
    jnz @2
    loop @1
  End;
  EndTimer := Clock-Start;
  TestHorizHz := 1000/(EndTimer/20000)/1000;
End;


Function IsDGIS : Boolean;

Var A : ^String;

Begin
  GetMem (A, SizeOf (A^));
  Regs.AX := $6A00;
  Regs.BX := 0;
  Regs.CX := 0;
  Regs.DX := 200;
  Regs.ES := PtrRec(A).Seg;
  Regs.DI := PtrRec(A).Ofs;
  Intr ($10, Regs);
  ISDGIS := (Regs.CX <> 0);
  FreeMem (A, SizeOf (A^));
End;


End.
