{$O+,F+,E-,N-}
{
Detection routines that return a descriptive string of what was detected.
This unit contains both original code as well as wraps around preexisting
detection libraries.

Updates to this library, and all TOPBENCH code, are recorded in WHATSNEW.TXT.

20080810 - Trixter, first revision
20111017 - added more video adapter detection code
20111105 - added some helper functions
20111119 - switched to putting updates in WHATSNEW.TXT, look there instead.
20150707 - Code refactoring; additional HP LX detection

todo:
- verif AT&T/Compaq 400-line CGA graphics detection code

Graphics detections routines are from Richard Wilton, Frost/EJF, and others.
CPU detection by the TMi0SDGL library.
BIOS and graphics detection routines are from a modified version of Eike
Frost/EJF's DETECT units, which themselves
borrow quite liberally from a bazillion sources including Andrew Rossmann's
INFOPLUS program, which itself borrowed from Steve Grant's SYSID program.
Where Steve borrowed from, I have no idea.
}

{$I TOPBCONF.INC}

unit topb_detect;

interface

uses
  topb_constants;

var
  WhatBIOSCRC16:word;

{Function WhatBIOSCRC16:word; moved to a global var}
Function WhatMachineType:string64;
{Returns an educated guess at what the system actually is, ie. "IBM PCjr"}
Function WhatCPU:string64;
{Returns a string describing the installed CPU}
Function WhatMHz:string16;
{Returns a string with a normalized MHz rating (ie. integer where possible)}
Function WhatMHzReal:real;
Function WhatMHzRealNormalized:real;
{Returns a real number with MHz}
Function WhatVideoSubsystem:string8; {PRIMARY only}
{Returns a string with the video subsystem: CGA, MDA, EGA, MCGA, or VGA}
Function WhatVideoAdapter:string80;  {PRIMARY only}
{Returns a string with a guess at the video adapter model}
Function WhatBIOS:string;
{Returns the BIOS copyright string}
Function WhatBIOSDate:string8;
{Returns the BIOS date string}
Function WhatBIOSDateNormalized:longint;
{Returns a normalized version of the date in YYYYMMDD format}
Function WhatModelWord:word;
{Returns the model word to assist in future machine detection}
Function WhatMachineUID:string32; {simple method of making a unique machine ID}
{Builds simple unique ID for the system from BIOS CRC + current second}
Function WhatBIOSRevision:byte;
{Returns BIOS revision}

implementation

uses
  {strings,}
  dos,
  {detectconstants,
  detectglobal,}
  detectgraphics,
  {detectsystem,}
  cputype,
  vadapter,
  crc16,
  support;

var
  v:tVideoSubsystem;
  uchars:array[0..255] of byte; {for uppercase translation, must be in DS}

Function WhatMachineType;
Const
  dells:Array [2..$11] Of String[5] = (
    '200', '300', '?', '220', '310', '325', '?', '310A', '316', '220E',
    '210', '316SX', '316LT','320LX', '?', '425E'
    );

  dellnums:set of 0..$FF = [2, 3, 5..7, 9..$0F, $11];

Var
  RomInfoSeg : Word;
  RomInfoOfs : Word;
  datefoo:string[8];
  machStr,s:string;
  idWord:word;
  idByte:byte;
  regs:registers;

Begin
  machStr:='';
  {Check for Dell systems}
  If UpCase(Chr(Mem[$F000:$E076]))='D' then Begin
    S:='';
    For idWord:=$E077 To $E079 Do S:=S + UpCase(Chr(Mem[$F000:idWord]));
    If S='ELL' Then Begin
      machStr:='Dell ';
      idByte:=Mem[$F000:$E845];
      If idByte In DellNums
        Then machStr:=machStr+Dells[idByte]+' '
        Else machStr:=machStr+'unknown; ID is'+hex (idByte)+' ';
      machStr:=machStr+'/';
    End
  End;

  {Check for HP Vectra systems}
  Regs.AX:=$6F00;
  Regs.BX:=0;
  Regs.Flags:=Regs.Flags and FCarry;
  Intr($16, Regs);
  If ((FCarry And Regs.Flags)=0) And (Regs.BX=$4850) then machStr:='HP Vectra Series ';

  (*
  INT 15 - HP 95LX/100LX/200LX - INSTALLATION CHECK
          AX = 4DD4h
  Return: BX = 4850h ("HP") if HP 95LX/100LX/200LX
          CX = model
          0101h HP 95LX
          0102h HP 100LX/200LX
          DH = ???
          02h HP 200LX 2MB BIOS 1.01 A D german
          DL = ???
          00h HP 95LX
          01h HP 200LX 2MB BIOS 1.01 A D german
  *)
  Regs.AX:=$4DD4;
  Intr ($15, Regs);
  If Regs.BX=$4850
    Then If Regs.CX=$0101
      Then machStr:='HP 95LX'
      Else machStr:='HP 100LX/200LX';

  {$IFNDEF STUB}
  {Only newer systems are going to honor int15 extended info, so if building
  the stub, don't bother}

  {Perform INT15-compilant model check}
  Regs.AH:=$C0;
  Regs.ES:=0;
  Regs.BX:=0;
  Regs.Flags:=Regs.Flags and FCarry;
  Intr($15, regs);
  If ((regs.Flags AND FCarry)=0) and (Regs.AH=0) then Begin
    RomInfoSeg:=Regs.ES;
    RomInfoOfs:=Regs.BX;
    idWord:=MemW[Regs.ES:Regs.BX + 2]; {model byte + secondary model byte}
    idByte:=Mem[Regs.ES:Regs.BX + 4]; {BIOS revision, zero-based}
    Case idWord Of
      $0000:begin
              {Assume 6300/M24 at first}
              machStr:='AT&T 6300/Olivetti M24';
              if WhatBIOSDate='07/03/87' then machStr:='Applied Engineering PC Transporter';
              if WhatBIOSDate='12/26-87' then machStr:='Toshiba T1200';
            end;
      $00F8:If WhatBiosDate='03/30/87'
              Then machStr:='PS/2 Model 80 386-16'
              Else machStr:='PS/2 Model 75 486-33';
      $00F9:machStr:='PC Convertible';
      $00FA:Case idByte Of
              $00:machStr:='PS/2 Model 30 (8MHz 8086)';
              $01:machStr:='PS/2 Model 30';
              $02:machStr:='PS/2 Model 30';
            End;
      $00FB:Case idByte Of
              $01:If WhatBiosDate='01/10/86'
                    Then machStr:='PC/XT (enhanced)'
                    Else If WhatBiosDate='05/13/94'
                      Then machStr:='HP 200LX Bios V1.01 AD (Deutsch)';
              $02:machStr:='PC/XT';
              $04:machStr:='HP 100LX Bios V1.04 A';
            End;
      $00FC:begin
              If idByte=1
                then machStr:='PC-AT 2x9, 6MHz'
                Else machStr:='Industrial AT 7531/2';
              if WhatBIOSDate='06/23/99' then machStr:='VirtualBox VM';
            end;
      $00FF:machStr:='Tandy 1000 SL';
      $01F8:machStr:='PS/2 Model 80 20MHz 386';
      $01FA:machStr:='PS/2 Model 25/25L';
      $01FB:machStr:='PC/XT-2';
      $01FC:Case idByte Of
              $00:begin
                    if WhatBiosDate='11/15/85' then machStr:='PC-AT 319 or 339, 8MHz'
                    else if WhatBiosDate='01/15&88' then machStr:='Toshiba T5200/100'
                    else if WhatBiosDate='12/26*89' then machStr:='Toshiba T1200/XE'
                    else if WhatBiosDate='07/24&90' then machStr:='Toshiba T5200/200'
                    else if WhatBiosDate='09/17/87' then machStr:='Tandy 3000'
                    else if WhatBiosDate='11/14/88' then machStr:='Compaq Portable III'
                    else machStr:='AT clone';
                  end;
              $30:machStr:='Tandy 3000NL'
            else
              machStr:='Compaq 286/386 or clone';
            end;
      $01FF:machStr:='Tandy 1000 TL';
      $02F8:machStr:='PS/2 Model 55-5571';
      $02FC:If WhatBiosDate='04/21/86' Then machStr:='PC/XT-286'
              Else If WhatBiosDate='08/05/93' Then machStr:='Compaq Contura 486'
              Else If WhatBiosDate='08/11/88' Then machStr:='SoftWindows 1.0.1 (PowerMac)'
              Else machStr:='Compaq LTE Lite';
      $04F8:If idByte=$00
                Then machStr:='PS/2 Model 70 386-20'
                Else machStr:='PS/2 Model 70 386-20, Typ 2';
      $04FC:Case idByte Of
                $00,
                $01:machStr:='PS/2 Model 50 286-10';
                $02:If WhatBiosDate='01/28/88'
                        Then machStr:='PS/2 Model 50Z 286-10'
                        Else machStr:='PS/2 Model 50';
                $03:machStr:='PS/2 Model 50Z 286-10';
                $04:machStr:='PS/2 Model 50Z';
              Else
                machStr:='PS/2 50?';
              End;
      $05F8:machStr:='IBM PC 7568';
      $05FC:machStr:='PS/2 Model 60 10MHz 286';
      $06F8:machStr:='PS/2 Model 55-5571';
      $06FC:If idByte=$00
                then machStr:='7552-140 "Gearbox"'
                Else If idByte=$01
                  Then machStr:='7552-540 "Gearbox"';
      $07F8:Case idByte Of
                $00,$02:machStr:='IBM PC 7561/2';
                $01,$03:machStr:='PS/2 Model 55-5551';
              End;
      $08FC:If idByte=$00 Then
                machStr:='PS/2 Model 25/286'
              Else
                machStr:='Epson, unknown model';
      $09F8:Case idByte Of
                $00:machStr:='PS/2 Model 70 386DX-16, Typ 1';
                $02,
                $03:machStr:='PS/2 Model 70';
                $04:machStr:='PS/2 Model 70 386-16, Typ 33';
              End;
      $09FC:If idByte=$00 Then Begin
              If WhatBIOSDate='08/25/88'
                Then machStr:='PS/2 Model 30 286-10'
                Else machStr:='PS/2 Model 25 286-10';
            End
            Else If idByte=$02
              Then machStr:='PS/2 Model 25 or 30';
      $0BF8:Case idByte Of
              $00:machStr:='PS/2 Model P70 (8573-121), Typ 2';
              $02:machStr:='PS/2 Model P70?';
            End;
      $0BFC:If WhatBIOSDate='12/01/89'
              Then machStr:='PS/1 Typ 44'
              Else If WhatBIOSDate='02/16/90'
                Then machStr:='PS/1 Model 2011 286-10';
      $0CF8:machStr:='PS/2 Model 55SX 16MHz 386SX';
      $0DF8:Case idByte Of
              $00,
              $01:machStr:='PS/2 Model 70 386-25, Typ 3';
            Else
              machStr:='PS/2 Model 70 486-25, Typ 3';
            End;
      $0EF8:machStr:='PS/1 486SX';
      $0FF8:machStr:='PS/1 486DX';
      $10F8:machStr:='PS/2 Model 55-5551';
      $11F8:machStr:='PS/2 Model 90 25MHz 386';
      $12F8:machStr:='PS/2 Model 95 XP';
      $13F8:machStr:='PS/2 Model 90 33MHz 386';
      $14F8:machStr:='PS/2 Model 90-AK9 25MHz 486';
      $15F8:machStr:='PS/2 Model 90 XP';
      $16F8:machStr:='PS/2 Model 90-AKD 33MHz 486';
      $17F8:machStr:='PS/2 Model 90 XP';
      $19F8:Case idByte Of
              $05:If WhatBIOSDate<>'03/15/91'
                    Then machStr:='PS/2 Model 35/35LS/40 386SX-20';
              $06:machStr:='PS/2 Model 35 SX / 40 SX, Typ 37';
            End;
      $1AF8:machStr:='PS/2 Model 95 XP';
      $1BF8:If WhatBIOSDate='09/29/89'
              Then machStr:='PS/2 Model 70 386DX-25'
              Else machStr:='PS/2 Model 70 486-25';
      $1CF8:machStr:='PS/2 Model 65-121 16MHz 386SX';
      $1EF8:machStr:='PS/2 Model 55LS 16MHz 386SX';
      $20FC:machStr:='Compaq ProLinea';
      $23F8:machStr:='PS/2 Model L40 20MHz 386SX';
      $25F8:Case idByte Of
              $00:machStr:='PS/2 Model 57 SLC';
              $06:machStr:='PS/2 Model M57 386SLC-20';
            End;
      $26F8:Case idByte Of
              $00:machStr:='PS/2 Model 57 SX';
              $01:machStr:='PS/2 Model 57 386SX-20';
              $02:machStr:='PS/2 Model 57 386SX-20, SCSI';
            End;
      $28F8:machStr:='PS/2 Model 95 XP';
      $29F8:machStr:='PS/2 Model 90 XP';
      $2AF8:machStr:='PS/2 Model 95 50MHz 486';
      $2BF8:machStr:='PS/2 Model 90 50MHz 486';
      $2CF8:Case idByte Of
              $00:machStr:='PS/2 Model 95 XP';
              $01:machStr:='PS/2 Model 95 486SX-20';
            End;
      $2D00:machStr:='Compaq PC (4.77 MHz Original)';
      $2DF8:machStr:='PS/2 Model 90 20MHz 486SX';
      $2EF8:Case idByte Of
              $00:machStr:='PS/2 Model 95XP 486SX-20';
              $01:machStr:='PS/2 Model 95 486SX-20+487SX';
            End;
      $2FF8:machStr:='PS/2 Model 90 20MHz 486SX+487SX';
      $30F8:machStr:='PS/1 Model 2121 16MHz 386SX';
      $30FA:machStr:='IBM Restaurant Terminal';
      $30FC,
      $31FC,
      $33FC:machStr:='Epson, unknown model';
      $33F8:machStr:='PS/2 Model 30-386';
      $34F8:machStr:='PS/2 Model 25-286';
      $36F8:machStr:='PS/2 Model 95 XP';
      $37F8:machStr:='PS/2 Model 90 XP';
      $38F8:machStr:='PS/2 Model 57';
      $39F8:machStr:='PS/2 Model 95 XP';
      $3FF8:machStr:='PS/2 Model 90 XP';
      $40F8:machStr:='PS/2 Model 95-XP';
      $41F8:machStr:='PS/2 Model 77';
      $42FC:machStr:='Olivetti M280';
      $43FE:machStr:='Olivetti M240';
      $45F8:machStr:='PS/2 Model 90 XP (Pentium)';
      $45FC:machStr:='Olivetti M380 (XP1, 3, or 5)';
      $46F8:machStr:='PS/2 Model 95 XP (Pentium)';
      $46FF:machStr:='Olivetti M15';
      $47F8:machStr:='PS/2 Model 90/95 E (Pentium)';
      $48F8:machStr:='PS/2 Model 85';
      $48FC:machStr:='Olivetti M290';
      $49F8:machStr:='PS/ValuePoint 325T';
      $4AF8:machStr:='PS/ValuePoint 425SX';
      $4BF8:machStr:='PS/ValuePoint 433DX';
      $4CFB:machStr:='Olivetti M200';
      $4EF8:machStr:='PS/2 Model 295';
      $4EFA:machStr:='Olivetti M111';
      $4FFC:machStr:='Olivetti M250';
      $50F8:Case idByte Of
              $00:machStr:='PS/2 Model P70 (8573) 386-16';
              $01:machStr:='PS/2 Model P70 (8570-031)';
            End;
      $50FC:machStr:='Olivetti M380 (XP7)';
      $51FC:machStr:='Olivetti PCS286';
      $52F8:machStr:='PS/2 Model P75 33MHz 486';
      $52FC:machStr:='Olivetti M300';
      $56F8:machStr:='PS/2 Model CL57 SX';
      $57F8:machStr:='PS/2 Model 90 XP';
      $58F8:machStr:='PS/2 Model 95 XP';
      $59F8:machStr:='PS/2 Model 90 XP';
      $5AF8:machStr:='PS/2 Model 95 XP';
      $5BF8:machStr:='PS/2 Model 90 XP';
      $5CF8:machStr:='PS/2 Model 95 XP';
      $5DF8:machStr:='PS/2 Model N51 SLC';
      $5EF8:machStr:='IBM ThinkPad 700';
      $61F8:machStr:='Olivetti P500';
      $62F8:machStr:='Olivetti P800';
      $80F8:Case idByte Of
             $00:machStr:='PS/2 Model 80 386-25';
             $01:machStr:='PS/2 Model 80-A21 386-25';
           End;
      $81F8:machStr:='PS/2 Model 55-5502';
      $81FC:If WhatBIOSDate='01/15/88'
              Then machStr:='Phoenix 386 V1.10 10a'
              Else machStr:='"OEM Rechner"';
      $82FC:machStr:='"OEM Rechner"';
      $87F8:machStr:='PS/2 Model N33SX';
      $88F8:machStr:='PS/2 Model 55-5530T';
      $94FC:machStr:='Zenith 386';
      $97F8:machStr:='PS/2 Model 55 Note N23SX';
      $99F8:machStr:='PS/2 Model N51 SX';
      $9A00:machStr:='Compaq Plus (XT compatible)';
      $A6FE:machStr:='Quadram Quad386';
      $F2F8:machStr:='Reply Model 32';
      $F6F8:machStr:='Memorex Telex';
      $F800:begin
              datefoo:=WhatBIOSDate;
              If (datefoo[7]='8') And (datefoo[8]='7') Then machStr:='PS/2 Model 80'
                Else If WhatBIOSDate='03/30/87' Then machStr:='PS/2 Model 80-041 16 MHz'
                Else If WhatBIOSDate='08/27/87' Then machStr:='PS/2 Model 80-071 16 MHz';
            end;
      $F801:If WhatBiosRevision=1 Then machStr:='PS/2 Model 80-111 20 MHz';
      $F804:machStr:='PS/2 Model 70-121';
      $F809:If WhatBiosRevision=2 Then machStr:='PS/2 Model 70 Desktop';
      $F80B:machStr:='PS/2 Model 70 Portable';
      $F80D:machStr:='PS/2 Model 70-A21';
      $F900:machStr:='PC-Kompatibler';
      $FA00:machStr:='PS/2 Model 30';
      $FB00:Case WhatBiosRevision Of
              0:machStr:='XT-2 (frÅherer)';
              1:machStr:='XT Model 089';
            End;
      $FB01:machStr:='XT-2 (spÑterer)';
      $FC00:Case WhatBiosRevision Of
              0:machStr:='AT Model 099 (Original)/7531/2 Industrial AT';
              1:machStr:='AT Model 239 6MHz (6.6 max governor)';
            End;
      $FC01:Case WhatBiosRevision Of
              00:If WhatBIOSDate='11/15/85' Then machStr:='AT Model 339, 339 8MHz (8.6 max governor)'
                 Else If WhatBIOSDate='01/24/90' Then machStr:='Compaq DeskPro 80386/25e'
                 Else machStr:='Compaq 386/16';
              03:machStr:='? with Phoenix 386 BIOS';
              81:machStr:='? with Phoenix 386 BIOS';
            End;
      $FC02:If WhatBIOSDate='10/02/89' Then machStr:='Compaq Deskpro 386s/386SX 16 MHz'
            Else If WhatBIOSDate='04/21/86' Then machStr:='XT/286';
      $FC05:machStr:='PS/2 Model 60';
      $FD00:machStr:='PCjr';
      $FDF8:machStr:='IBM Processor Complex (with VPD)';
      $FE00:machStr:='XT, Portable PC, XT/370, 3270PC';
      $FEFA:machStr:='IBM PCradio 9075';
      $FF00:If WhatBIOSDate='04/24/81' Then machStr:='PC-0 (16k Motherboard)'
            Else If WhatBIOSDate='10/19/81' Then machStr:='PC-1 (64k Motherboard)'
            Else If (WhatBIOSDate='08/16/82') or (WhatBIOSDate='10/27/82')
              Then machStr:='PC, XT/XT-370 (256k Motherboard)';
      $FFF9:machStr:='PC-Compatible';
    end;
  end;

  {$ENDIF}

  {int 15/c0 came up short, so we look at the machine ID byte in desperation}
  {T1000 info credit to John Eliott @ seasip.info/VintagePC/t1000.html}
  if machStr='' then Case Mem[$FFFF:$000E] Of
    $FF:if mem[$f000:$c000]=$21
          then machStr:='Tandy 1000'
          else machStr:='PC';
    $FE:case mem[$f000:$fffa] of
          $2c{,$44}:machStr:='Toshiba T1000';
          $43:machStr:='Toshiba T1600';
          $45:machStr:='Toshiba T1200';
          $46:machStr:='Toshiba T1100+';
          $47:machStr:='Toshiba T5200C';
        else
          machStr:='PC/XT';
        end;
    $FD:machStr:='PCjr';
    $FC:machStr:='PC/AT';
    $FB:machStr:='PC/XT';
    $FA:machStr:='PS/2 Model 25/30';
    $F9:machStr:='PS/2 Convertible';
    $F8:machStr:='PS/2 Model 70/80';
    $B6:machStr:='HP 110';
    $9A:machStr:='Compaq XT or Compaq Plus';
    $2D:machStr:='Compaq PC or Compaq Deskpro';
    $30:machStr:='Sperry PC';
    $E9:machStr:='Peacock XT';
    $00:machStr:='AT&T 6300/Olivetti M24';
  Else
    machStr:='unknown, ID: ' + HexWord(idWord);
  End;

  if machStr='' then machStr:='error!'; {we should never get here}
  WhatMachineType:=machStr;
end;

Function WhatCPU;
begin
  WhatCPU:=cpu_Type;
end;

function WhatMHz;
var
  w:word;
  s:string8;
begin
  w:=ncpu_speed;
  case w of
    5:s:='4.77';
    7:s:='7.16';
    {10:s:='9.54';}
  else
    s:=inttostr(w);
  end;
  WhatMHz:=s+' MHz';
  {WhatMHz:=inttostr(ncpu_speed)+' MHz';} {integer rounding, not acceptable!}
end;

function WhatMHzRealNormalized;
var
  w:word;
begin
  w:=ncpu_speed;
  case w of
    5:WhatMHZRealNormalized:=4.77;
    7:WhatMHZRealNormalized:=7.16;
  else
    WhatMHZRealNormalized:=w;
  end;
end;

function WhatMHzReal;
begin
  WhatMHzReal:=fcpu_speed;
end;

Function WhatVideoAdapter;
{
Uses Wilton/Knight/Leonard code to detect most video systems
Uses Frost's DETECT unit for SVGA
}

var
  s:string64;
  result:byte;

begin
  s:=v.PrimaryName;
  {If building the stub, don't bother doing an extended VGA check, as there
  is no system supporting VGA that came with only 128KB.}
  {$IFNDEF STUB}
  if v.PrimaryType='VGA' then s:=WhatSVGACard;
  {$ENDIF}
  if v.PrimaryType='CGA' then begin
    {Key kids, let's do all sorts of extended CGA adapter detection!
    Tandy, PCjr, AT&T 6300, Compaq Portable III, you name it!}

    {First, the PCjr/Tandy family, as they have relocatable video ram.}
    {PCjr, Tandy, Tandy SL/TL code inspired by Jason Knight}
    asm
	    mov  ax,$FFFF
	    mov  es,ax
	    mov  di,$000E     { second to last byte PCjr/Tandy BIOS info area }
	    cmp  byte ptr es:[di],$FD  { ends up $FD only on the Jr. }
	    jne  @notJr
	    mov  result,1 {videoCard_pcJr}
	    jmp  @done
    @notJr:             { not junior, test for tandy }
	    cmp  byte ptr es:[di],$FF  { all tandys have $FF here }
	    jne  @notTandy
	    mov  ax,$FC00
	    mov  es,ax
	    xor  di,di
	    mov  al,$21
	    cmp  byte ptr es:[di],$21
	    jne  @notTandy
	    mov  ah,$C0
	    int  $15          { Get System Environment }
	    jnc  @tandySLTL   { early Tandys error out, TL/SL does not }
	    mov  result,2 {tandy1000}
	    jmp @done
    @tandySLTL:
	    mov  result,3 {tandySLTL}
	    jmp @done
    @notTandy:
	    mov  result,0 {all other cards eliminated, must be CGA}
    @done:
    end;

    case result of
      1:s:='IBM PCjr';
      2:s:='Tandy 1000';
      3:s:='Tandy 1000 SL/TL';
    end;

    {Now check for specific adapters based on various criteria.
    This was really tough for me; I tried all sorts of ideas to detect
    these adapters and modes, but in the end, such bit-banging is not
    safe.  A true "universal" 640x400 detector is just not possible without
    the possibility of crashing unknown hardware.}

    asm
      {First, check for AT&T/Olivetti using the model byte, which they
      have been so kind as to implement broken (returns 0000)}
      mov     ah,$C0
      int     15h          {6300 has NO 15h support in BIOS }
      jc      @ATTFound    {if CF=1, error; try to detect 6300 some other way}
      mov     ax,es:[bx+2] {grab model word}
      cmp     ax,$01FC     {See if we're on the Compaq 400-line adapter/plasma}
      je      @CompaqFound
      jmp     @error
    @CompaqFound:
      {We think we are on a Compaq Portable III.  Let's see if we can detect
      the internal plasma monitor.}
      mov     dx,1BC6h
      in      al,dx
      mov     cl,4
      shr     al,cl
      mov     result,al       {If this is plasma, result=4 if 400-line}
      jmp     @done
    @ATTFound:
      {Let's try a second check for the 6300/M24.
      Run a 6300/M24-specific BIOS INT.  If it returns info, we are SURE
      we are on a 6300/M24 and try to grab monitor ID bits from 3dah.
      ;Int 1A/AH=FEh
      ;AT&T 6300 - READ TIME AND DATE
      ;AH = FEh
      ;Return:
      ;BX = day count (0 = Jan 1, 1984)
      ;CH = hour
      ;CL = minute
      ;DH = second
      ;DL = hundredths}

      xor     cx,cx
      mov     dx,cx
      mov     ax,0fe00h
      int     1ah
      or      cx,dx            {if any bits are set anywhere, we have 6300/M24}
      jcxz    @error           {no bits?  No 6300/M24!}
      mov     dx,03dah         {a monitor ID in bits 4-5 (2=colour, 3=mono}
      in      al,dx            {If a DEB is present, bits 6 and 7 will be 0}
      mov     cl,4
      shr     al,cl            {discard regular status bits}
      test    al,00000010b     {if 2 or 3, bit 1 will be set and we have AT&T}
      jz      @error
      mov     result,al
      and     result,00000011b {mask off DEB bits}
      test    al,00001100b     {if these are unset, we have a DEB}
      jnz     @done
      or      result,10000000b {set bit 7 if DEB present}
      jmp     @done
    @error:
      mov     result,0         {must have made a mistake...?}
    @done:
    end;

    {check our results and set the string}
    case (result and $7F) of
      2:s:='AT&T/Olivetti (Color Monitor)';
      3:s:='AT&T/Olivetti (Monochrome Monitor)';
      4:s:='Compaq Portable III (Internal Plasma)';
    end;
    if (result AND $80)=$80 then s:=s+' + DEB';
  end;
  WhatVideoAdapter:=s;
end;

Function WhatVideoSubsystem;
{Uses Richard Wilton's code to determine the basic vidcard type}

begin
  WhatVideoSubsystem:=v.PrimaryType;
end;

Function WhatBIOSDate; assembler;
asm
  push    ds
  cld
  les     di,@Result     {es:di = result string}
  mov     ax,0ffffh
  mov     ds,ax
  mov     si,0005h       {ds:si = ffff:0005}
  mov     al,8
  stosb                  {result string[0]=8 which is the length of our return}
  movsw
  movsw
  movsw
  movsw                  {result = 4 words = 8 bytes from 0005-000c}
  pop     ds
end;

Function WhatBIOSRevision:byte; assembler;
{INT 15,C0 - Return System Configuration Parameters (PS/2 only)}
asm
  mov     ah,$C0
  int     15h
  jc      @error       {if CF=1, there was an error}
  mov     al,es:[bx+4]
  jmp     @done
@error:
  xor     al,al        {"revision 0" if error, b/c model is zero-based}
@done:
end;

Function WhatBIOS;
{returns as useful a BIOS copyright string as possible}
Const
  printables=[' '..'~'];
  BIOSseg=$F000;
  BIOSstartofs=$E000;
  BIOSendofs=$FFFF;
  maxCopyStrings=5;
  CopyNotices:array[1..maxCopyStrings] of string[9] =
    ('(C)', 'COPR.', 'COPYRIGHT', 'ORACLE', 'TOSHIBA'); {Must be upper-case}

var
  s:string;
  b:byte;
  pbufc,pstrc:^char; {buffer and string character pointers}
  foundpos:word;

  function SearchNoCase(s:string; startpos:pointer; buflen:word):word;
  {performs a case-insensitive search}
  begin
    asm
      mov     bx,offset uchars  {bx = loc of upcase translation table}
      lea     si,s
      xor     dx,dx
      mov     dl,ss:[si]        {dx = length of string}
      inc     si                {ds:si = loc of source string}
      les     di,startpos       {es:di = buffer}
      mov     cx,buflen         {cx=length of buffer}
      push    bp                {bp will be our working position in the match}
      xor     bp,bp
      mov     ah,ss:[si]        {load first char from already upcased string}
    @search:
      mov     al,es:[di]        {load char from buffer}
      xlat                      {upcase it}
                                {ah = upcase(string[pos]), al = upcase(bufferpos)}
      cmp     al,ah             {are they equal?}
      je      @keeptrying       {if so, try to see how much string matches buf}
      inc     di                {otherwise, increase buffer pos...}
      loop    @search           {...and try again}
      mov     ax,$FFFF          {if here, we never matched; set error result}
      jmp     @done
    @keeptrying:
      inc     bp                {advance match counter/index}
      dec     dx                {countdown the string length}
      jz      @matched          {if we have no more string to match, we win}
      mov     ah,ss:[bp+si]     {load next char from string}
      mov     al,es:[bp+di]     {load next char from buffer}
      xlat                      {upcase it}
                                {ah = upcase(string[pos]), al = upcase(bufferpos)}
      cmp     al,ah             {are they equal again?}
      je      @keeptrying       {if so, keep trying}
      mov     dl,ss:[si-1]      {otherwise, restore string length...}
      xor     bp,bp             {reset bp...}
      mov     ah,ss:[si]        {load first char from already upcased string}
      inc     di                {increase buffer pos...}
      loop    @search           {...and try again}
    @matched:
      mov     ax,di
    @done:
      pop     bp
      mov     @result,ax
    end;
  end;

begin
  {build upcase array}
  for b:=0 to 255 do uchars[b]:=b;
  for b:=ord('a') to ord('z') do uchars[b]:=b-32;

  s:='';
  {First, try to find the location of one of the copyright notices}
  for b:=1 to maxCopyStrings do begin
    foundpos:=SearchNoCase(CopyNotices[b],ptr(BIOSseg,BIOSstartofs),BIOSendofs-BIOSstartofs);
    if foundpos<>$FFFF then break
  end;
  if foundpos=$FFFF then begin
    WhatBIOS:='unknown';
    exit;
  end;
  {work backwards until you find the first non-printing character}
  pbufc:=ptr(BIOSseg,foundpos);
  while pbufc^ in printables do
    dec(word(pbufc));
  inc(word(pbufc));
  {then build a string from that position until the next non-printing char}
  while pbufc^ in printables do begin
    s:=s+pbufc^;
    inc(word(pbufc));
  end;
  WhatBIOS:=s+' ('+WhatBIOSDate+', rev. '+inttostr(WhatBIOSRevision)+')';
end;

Function WhatBIOSDateNormalized;
{turns mm/dd/yy into yyyymmdd}
var
  s:string8;
  b:byte;
  l:longint;
begin
  l:=0;
  s:=WhatBIOSDate;
  b:=StrToInt(copy(s,7,2));
  if b>70 then l:=1900+b else l:=2000+b; l:=l*10000;
  b:=StrToInt(copy(s,1,2)); if (b=0) or (b>12) then b:=1; l:=l+(b*100);
  b:=StrToInt(copy(s,4,2)); if (b=0) or (b>31) then b:=1; l:=l+(b);
  WhatBIOSDateNormalized:=l;
end;

Function CalcBIOSCRC16:word;
var
  BIOSInitVector:pointer ABSOLUTE $FFFF:0001;
begin
  CalcBIOSCRC16:=CRC16Buf(BIOSInitVector,$ffff-word(BIOSinitVector),0); {buf, len, seed}
end;

Function WhatMachineUID;
begin
  WhatMachineUID:='UID'+hex(WhatBIOSCRC16)+hex(TicksSinceMidnight);
end;

function WhatModelWord;assembler;
asm
  mov     ah,$C0
  int     15h
  jc      @error       {if CF=1, there was an error}
  mov     ax,es:[bx+2]
  jmp     @done
@error:
  xor     ax,ax
@done:
end;

begin
  {$IFDEF STARTUP_MSGS} writeln('TOPBENCH small detection unit starting...'); {$ENDIF}
  {init wilton detect code}
  v.init;
  {find the BIOS CRC for use later}
  WhatBIOSCRC16:=CalcBIOSCRC16;
end.
