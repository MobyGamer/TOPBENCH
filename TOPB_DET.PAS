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
  foos:string[8];
  Endstring,s:string;
  xword1:word;
  xbool:boolean;
  xbyte:byte;
  regs:registers;

Begin
  EndString := '';
  If UpCase(Chr(Mem[$F000:$E076])) = 'D' then Begin
    S := '';
    For xWord1 := $E077 To $E079 Do S := S + UpCase(Chr(Mem[$F000:xword1]));
    If S = 'ELL' Then Begin
      EndString := 'Dell ';
      xBool := True;
      xByte := Mem[$F000:$E845];
      If xByte In DellNums Then EndString := Concat (EndString, Dells[xByte], ' ')
      Else Begin
        EndString := ConCat (EndString, 'unknown; ID is', hex (xbyte),' ');
        xBool := False;
      End;
      EndString := ConCat (EndString, '/');
    End
  End;

  Regs.AX := $6F00;
  Regs.BX := 0;
  Regs.Flags := Regs.Flags and FCarry;
  Intr($16, Regs);
  If ((FCarry And Regs.Flags) = 0) And (Regs.BX = $4850) then EndString := 'HP Vectra Series ';

  Regs.AX := $4DD4;
  Intr ($15, Regs);
  If Regs.BX = $4850 Then EndString := 'HP 95 LX ';

  Regs.AH := $C0;
  Regs.ES := 0;
  Regs.BX := 0;
  Regs.Flags:=Regs.Flags and FCarry;
  Intr($15, regs);
  If ((regs.Flags AND FCarry) = 0) and (Regs.AH = 0) then Begin
    RomInfoSeg := Regs.ES;
    RomInfoOfs := Regs.BX;
    xWord1 := MemW[Regs.ES:Regs.BX + 2]; {model byte + secondary model byte}
    xByte := Mem[Regs.ES:Regs.BX + 4]; {BIOS revision, zero-based}
    Case xWord1 Of
      $0000 : begin
                {Assume 6300/M24 at first}
                EndString := ConCat (EndString, 'AT&T 6300/Olivetti M24');
                if WhatBIOSDate='07/03/87' then EndString:='Applied Engineering PC Transporter';
                if WhatBIOSDate='12/26-87' then EndString:='Toshiba T1200';
              end;
      $00F8 : If WhatBiosDate = '03/30/87'
                Then EndString := ConCat (EndString, 'PS/2 Model 80 386-16')
                Else EndString := ConCat (EndString, 'PS/2 Model 75 486-33');
      $00F9 : EndString := ConCat (EndString, 'PC Convertible');
      $00FA : Case xByte Of
                $00 : EndString := ConCat (EndString, 'PS/2 Model 30 (8MHz 8086)');
                $01 : EndString := ConCat (EndString, 'PS/2 Model 30');
                $02 : EndString := ConCat (EndString, 'PS/2 Model 30');
              End;
      $00FB : Case xByte Of
                $01 : If WhatBiosDate = '01/10/86'
                        Then EndString := ConCat (EndString, 'PC/XT (enhanced)')
                        Else If WhatBiosDate = '05/13/94'
                          Then EndString := ConCat (EndString, 'HP 200LX Bios V1.01 AD (Deutsch)');
                $02 : EndString := ConCat (EndString, 'PC/XT');
                $04 : EndString := ConCat (EndString, 'HP 100LX Bios V1.04 A');
              End;
      $00FC : begin
                If xByte = 1
                  then EndString := ConCat (EndString, 'PC-AT 2x9, 6MHz')
                  Else EndString := ConCat (EndString, 'Industrial AT 7531/2');
                if WhatBIOSDate='06/23/99' then EndString:='VirtualBox VM';
              end;
      $00FF : EndString := Concat (EndString, 'Tandy 1000 SL');
      $01F8 : EndString := ConCat (EndString, 'PS/2 Model 80 20MHz 386');
      $01FA : EndString := ConCat (EndString, 'PS/2 Model 25/25L');
      $01FB : EndString := ConCat (EndString, 'PC/XT-2');
      $01FC : Case xByte Of
                $00:begin
                      if WhatBiosDate = '11/15/85' then EndString := ConCat (EndString, 'PC-AT 319 or 339, 8MHz')
                      else if WhatBiosDate = '01/15&88' then EndString := ConCat (EndString, 'Toshiba T5200/100')
                      else if WhatBiosDate = '12/26*89' then EndString := ConCat (EndString, 'Toshiba T1200/XE')
                      else if WhatBiosDate = '07/24&90' then EndString := ConCat (EndString, 'Toshiba T5200/200')
                      else if WhatBiosDate = '09/17/87' then EndString := ConCat (EndString, 'Tandy 3000')
                      else if WhatBiosDate = '11/14/88' then EndString := ConCat (EndString, 'Compaq Portable III')
                      else EndString := ConCat (EndString, 'AT clone');
                    end;
                $30:EndString := ConCat (EndString, 'Tandy 3000NL')
              else
                EndString := ConCat (EndString, 'Compaq 286/386 or clone');
              end;
      $01FF : EndString := Concat (EndString, 'Tandy 1000 TL');
      $02F8 : EndString := ConCat (EndString, 'PS/2 Model 55-5571');
      $02FC : If WhatBiosDate = '04/21/86' Then EndString := ConCat (EndString, 'PC/XT-286')
              Else If WhatBiosDate = '08/05/93' Then EndString := ConCat (EndString, 'Compaq Contura 486')
              Else If WhatBiosDate = '08/11/88' Then EndString := ConCat (EndString, 'SoftWindows 1.0.1 (PowerMac)')
              Else EndString := ConCat (EndString, 'Compaq LTE Lite');
      $04F8 : If xByte=$00
                Then EndString := ConCat (EndString, 'PS/2 Model 70 386-20')
                Else EndString := ConCat (EndString, 'PS/2 Model 70 386-20, Typ 2');
      $04FC : Case xByte Of
                $00,
                $01 : EndString := ConCat (EndString, 'PS/2 Model 50 286-10');
                $02 : If WhatBiosDate = '01/28/88'
                        Then EndString := ConCat (EndString, 'PS/2 Model 50Z 286-10')
                        Else EndString := ConCat (EndString, 'PS/2 Model 50');
                $03 : EndString := ConCat (EndString, 'PS/2 Model 50Z 286-10');
                $04 : EndString := ConCat (EndString, 'PS/2 Model 50Z');
              Else
                EndString := ConCat (EndString, 'PS/2 50?');
              End;
      $05F8 : EndString := ConCat (EndString, 'IBM PC 7568');
      $05FC : EndString := ConCat (EndString, 'PS/2 Model 60 10MHz 286');
      $06F8 : EndString := ConCat (EndString, 'PS/2 Model 55-5571');
      $06FC : If xByte = $00
                then EndString := ConCat (EndString, '7552-140 "Gearbox"')
                Else If xByte = $01
                  Then EndString := ConCat (EndString, '7552-540 "Gearbox"');
      $07F8 : Case xByte Of
                $00,
                $02 : EndString := ConCat (EndString, 'IBM PC 7561/2');
                $01,
                $03 : EndString := ConCat (EndString, 'PS/2 Model 55-5551');
              End;
      $08FC : If xByte = $00 Then
                EndString := ConCat (EndString, 'PS/2 Model 25/286')
              Else
                EndString := ConCat (EndString, 'Epson, unknown model');
      $09F8 : Case xByte Of
                $00 : EndString := ConCat (EndString, 'PS/2 Model 70 386DX-16, Typ 1');
                $02,
                $03 : EndString := ConCat (EndString, 'PS/2 Model 70');
                $04 : EndString := ConCat (EndString, 'PS/2 Model 70 386-16, Typ 33');
              End;
      $09FC : If xByte=$00 Then Begin
                If WhatBIOSDate = '08/25/88'
                  Then EndString := ConCat (EndString, 'PS/2 Model 30 286-10')
                  Else EndString := ConCat (EndString, 'PS/2 Model 25 286-10');
              End Else If xByte = $02
                Then EndString := ConCat (EndString, 'PS/2 Model 25 or 30');
      $0BF8 : Case xByte Of
                $00 : EndString := ConCat (EndString, 'PS/2 Model P70 (8573-121), Typ 2');
                $02 : EndString := ConCat (EndString, 'PS/2 Model P70?');
              End;
      $0BFC : If WhatBIOSDate = '12/01/89'
                Then EndString := ConCat (EndString, 'PS/1 Typ 44')
                Else If WhatBIOSDate = '02/16/90'
                  Then EndString := ConCat (EndString, 'PS/1 Model 2011 286-10');
      $0CF8 : EndString := ConCat (EndString, 'PS/2 Model 55SX 16MHz 386SX');
      $0DF8 : Case xByte Of
                $00,
                $01 : EndString := ConCat (EndString, 'PS/2 Model 70 386-25, Typ 3');
              Else
                EndString := ConCat (EndString, 'PS/2 Model 70 486-25, Typ 3');
              End;
      $0EF8 : EndString := ConCat (EndString, 'PS/1 486SX');
      $0FF8 : EndString := ConCat (EndString, 'PS/1 486DX');
      $10F8 : EndString := ConCat (EndString, 'PS/2 Model 55-5551');
      $11F8 : EndString := ConCat (EndString, 'PS/2 Model 90 25MHz 386');
      $12F8 : EndString := ConCat (EndString, 'PS/2 Model 95 XP');
      $13F8 : EndString := ConCat (EndString, 'PS/2 Model 90 33MHz 386');
      $14F8 : EndString := ConCat (EndString, 'PS/2 Model 90-AK9 25MHz 486');
      $15F8 : EndString := ConCat (EndString, 'PS/2 Model 90 XP');
      $16F8 : EndString := ConCat (EndString, 'PS/2 Model 90-AKD 33MHz 486');
      $17F8 : EndString := ConCat (EndString, 'PS/2 Model 90 XP');
      $19F8 : Case xByte Of
                $05 : If WhatBIOSDate = '03/15/91' Then
                        EndString := ConCat (EndString, '')
                      Else
                        EndString := ConCat (EndString, 'PS/2 Model 35/35LS/40 386SX-20');
                $06 : EndString := ConCat (EndString, 'PS/2 Model 35 SX / 40 SX, Typ 37');
              End;
      $1AF8 : EndString := ConCat (EndString, 'PS/2 Model 95 XP');
      $1BF8 : If WhatBIOSDate = '09/29/89' Then
                EndString := ConCat (EndString, 'PS/2 Model 70 386DX-25')
              Else
                EndString := ConCat (EndString, 'PS/2 Model 70 486-25');
      $1CF8 : EndString := ConCat (EndString, 'PS/2 Model 65-121 16MHz 386SX');
      $1EF8 : EndString := ConCat (EndString, 'PS/2 Model 55LS 16MHz 386SX');
      $20FC : EndString := ConCat (EndString, 'Compaq ProLinea');
      $23F8 : EndString := ConCat (EndString, 'PS/2 Model L40 20MHz 386SX');
      $25F8 : Case xByte Of
                $00 : EndString := ConCat (EndString, 'PS/2 Model 57 SLC');
                $06 : EndString := ConCat (EndString, 'PS/2 Model M57 386SLC-20');
              End;
      $26F8 : Case xByte Of
                $00 : EndString := ConCat (EndString, 'PS/2 Model 57 SX');
                $01 : EndString := ConCat (EndString, 'PS/2 Model 57 386SX-20');
                $02 : EndString := ConCat (EndString, 'PS/2 Model 57 386SX-20, SCSI');
              End;
      $28F8 : EndString := ConCat (EndString, 'PS/2 Model 95 XP');
      $29F8 : EndString := ConCat (EndString, 'PS/2 Model 90 XP');
      $2AF8 : EndString := ConCat (EndString, 'PS/2 Model 95 50MHz 486');
      $2BF8 : EndString := ConCat (EndString, 'PS/2 Model 90 50MHz 486');
      $2CF8 : Case xByte Of
                $00 : EndString := ConCat (EndString, 'PS/2 Model 95 XP');
                $01 : EndString := ConCat (EndString, 'PS/2 Model 95 486SX-20');
              End;
      $2D00 : EndString := ConCat (EndString, 'Compaq PC (4.77 mHz Original)');
      $2DF8 : EndString := ConCat (EndString, 'PS/2 Model 90 20MHz 486SX');
      $2EF8 : Case xByte Of
                $00 : EndString := ConCat (EndString, 'PS/2 Model 95XP 486SX-20');
                $01 : EndString := ConCat (EndString, 'PS/2 Model 95 486SX-20+487SX');
              End;
      $2FF8 : EndString := ConCat (EndString, 'PS/2 Model 90 20MHz 486SX+487SX');
      $30F8 : EndString := ConCat (EndString, 'PS/1 Model 2121 16MHz 386SX');
      $30FA: EndString := ConCat (EndString, 'IBM Restaurant Terminal');
      $30FC,
      $31FC,
      $33FC : EndString := ConCat (EndString, 'Epson, unknown model');
      $33F8 : EndString := ConCat (EndString, 'PS/2 Model 30-386');
      $34F8 : EndString := ConCat (EndString, 'PS/2 Model 25-286');
      $36F8 : EndString := ConCat (EndString, 'PS/2 Model 95 XP');
      $37F8 : EndString := ConCat (EndString, 'PS/2 Model 90 XP');
      $38F8 : EndString := ConCat (EndString, 'PS/2 Model 57');
      $39F8 : EndString := ConCat (EndString, 'PS/2 Model 95 XP');
      $3FF8 : EndString := ConCat (EndString, 'PS/2 Model 90 XP');
      $40F8 : EndString := ConCat (EndString, 'PS/2 Model 95-XP');
      $41F8 : EndString := ConCat (EndString, 'PS/2 Model 77');
      $42FC : EndString := ConCat (EndString, 'Olivetti M280');
      $43FE : EndString := ConCat (EndString, 'Olivetti M240');
      $45F8 : EndString := ConCat (EndString, 'PS/2 Model 90 XP (Pentium)');
      $45FC : EndString := ConCat (EndString, 'Olivetti M380 (XP1, 3, or 5)');
      $46F8 : EndString := ConCat (EndString, 'PS/2 Model 95 XP (Pentium)');
      $46FF : EndString := ConCat (EndString, 'Olivetti M15');
      $47F8 : EndString := ConCat (EndString, 'PS/2 Model 90/95 E (Pentium)');
      $48F8 : EndString := ConCat (EndString, 'PS/2 Model 85');
      $48FC : EndString := ConCat (EndString, 'Olivetti M290');
      $49F8 : EndString := ConCat (EndString, 'PS/ValuePoint 325T');
      $4AF8 : EndString := ConCat (EndString, 'PS/ValuePoint 425SX');
      $4BF8 : EndString := ConCat (EndString, 'PS/ValuePoint 433DX');
      $4CFB : EndString := ConCat (EndString, 'Olivetti M200');
      $4EF8 : EndString := ConCat (EndString, 'PS/2 Model 295');
      $4EFA : EndString := ConCat (EndString, 'Olivetti M111');
      $4FFC : EndString := ConCat (EndString, 'Olivetti M250');
      $50F8 : Case xByte Of
                $00 : EndString := ConCat (EndString, 'PS/2 Model P70 (8573) 386-16');
                $01 : EndString := ConCat (EndString, 'PS/2 Model P70 (8570-031)');
              End;
      $50FC : EndString := ConCat (EndString, 'Olivetti M380 (XP7)');
      $51FC : EndString := ConCat (EndString, 'Olivetti PCS286');
      $52F8 : EndString := ConCat (EndString, 'PS/2 Model P75 33MHz 486');
      $52FC : EndString := ConCat (EndString, 'Olivetti M300');
      $56F8 : EndString := ConCat (EndString, 'PS/2 Model CL57 SX');
      $57F8 : EndString := ConCat (EndString, 'PS/2 Model 90 XP');
      $58F8 : EndString := ConCat (EndString, 'PS/2 Model 95 XP');
      $59F8 : EndString := ConCat (EndString, 'PS/2 Model 90 XP');
      $5AF8 : EndString := ConCat (EndString, 'PS/2 Model 95 XP');
      $5BF8 : EndString := ConCat (EndString, 'PS/2 Model 90 XP');
      $5CF8 : EndString := ConCat (EndString, 'PS/2 Model 95 XP');
      $5DF8 : EndString := ConCat (EndString, 'PS/2 Model N51 SLC');
      $5EF8 : EndString := ConCat (EndString, 'IBM ThinkPad 700');
      $61F8 : EndString := ConCat (EndString, 'Olivetti P500');
      $62F8 : EndString := ConCat (EndString, 'Olivetti P800');
      $80F8 : Case xByte Of
               $00 : EndString := ConCat (EndString, 'PS/2 Model 80 386-25');
               $01 : EndString := ConCat (EndString, 'PS/2 Model 80-A21 386-25');
             End;
      $81F8 : EndString := ConCat (EndString, 'PS/2 Model 55-5502');
      $81FC : If WhatBIOSDate = '01/15/88' Then
                EndString := ConCat (EndString, 'Phoenix 386 V1.10 10a')
              Else
                EndString := ConCat (EndString, '"OEM Rechner"');
      $82FC : EndString := ConCat (EndString, '"OEM Rechner"');
      $87F8 : EndString := ConCat (EndString, 'PS/2 Model N33SX');
      $88F8 : EndString := ConCat (EndString, 'PS/2 Model 55-5530T');
      $94FC : EndString := ConCat (EndString, 'Zenith 386');
      $97F8 : EndString := ConCat (EndString, 'PS/2 Model 55 Note N23SX');
      $99F8 : EndString := ConCat (EndString, 'PS/2 Model N51 SX');
      $9A00 : EndString := ConCat (EndString, 'Compaq Plus (XT compatible)');
      $A6FE : EndString := ConCat (EndString, 'Quadram Quad386');
      $F2F8 : EndString := ConCat (EndString, 'Reply Model 32');
      $F6F8 : EndString := ConCat (EndString, 'Memorex Telex');
      $F800 : begin
                foos:=WhatBIOSDate;
                If (foos[7] = '8') And (foos[8] = '7')
                Then EndString := ConCat (EndString, 'PS/2 Model 80')
                Else If WhatBIOSDate = '03/30/87'
                  Then EndString := ConCat (EndString, 'PS/2 Model 80-041 16 mHz')
                  Else If WhatBIOSDate = '08/27/87'
                    Then EndString := ConCat (EndString, 'PS/2 Model 80-071 16 mHz');
              end;
      $F801 : If WhatBiosRevision = 1 Then
                      EndString := ConCat (EndString, 'PS/2 Model 80-111 20 mHz');
      $F804 : EndString := ConCat (EndString, 'PS/2 Model 70-121');
      $F809 : If WhatBiosRevision = 2 Then
                      EndString := ConCat (EndString, 'PS/2 Model 70 Desktop');
      $F80B : EndString := ConCat (EndString, 'PS/2 Model 70 Portable');
      $F80D : EndString := ConCat (EndString, 'PS/2 Model 70-A21');
      $F900 : EndString := ConCat (EndString, 'PC-Kompatibler');
      $FA00 : EndString := ConCat (EndString, 'PS/2 Model 30');
      $FB00 : Case WhatBiosRevision Of
                      0 : EndString := ConCat (EndString, 'XT-2 (frÅherer)');
                      1 : EndString := ConCat (EndString, 'XT Model 089');
                    End;
      $FB01 : EndString := ConCat (EndString, 'XT-2 (spÑterer)');
      $FC00 : Case WhatBiosRevision Of
                      0 : EndString := ConCat (EndString, 'AT Model 099 (Original)/7531/2 Industrial AT');
                      1 : EndString := ConCat (EndString, 'AT Model 239 6mHz (6.6 max governor)');
                    End;
      $FC01 : Case WhatBiosRevision Of
                      00 : If WhatBIOSDate = '11/15/85' Then
                             EndString := ConCat (EndString, 'AT Model 339, 339 8mHz (8.6 max governor)')
                           Else
                             If WhatBIOSDate = '01/24/90' Then
                               EndString := ConCat (EndString, 'Compaq DeskPro 80386/25e')
                             Else
                               EndString := ConCat (EndString, 'Compaq 386/16');
                      03 : EndString := ConCat (EndString, '? with Phoenix 386 BIOS');
                      81 : EndString := ConCat (EndString, '? with Phoenix 386 BIOS');
                    End;
      $FC02 : If WhatBIOSDate = '10/02/89'
                Then EndString := ConCat (EndString, 'Compaq Deskpro 386s/386SX 16 mHz')
                Else If WhatBIOSDate = '04/21/86'
                  Then EndString := ConCat (EndString, 'XT/286');
      $FC05 : EndString := ConCat (EndString, 'PS/2 Model 60');
      $FD00 : EndString := ConCat (EndString, 'PCjr');
      $FDF8 : EndString := ConCat (EndString, 'IBM Processor Complex (with VPD)');
      $FE00 : EndString := ConCat (EndString, 'XT, Portable PC, XT/370, 3270PC');
      $FEFA : EndString := ConCat (EndString, 'IBM PCradio 9075');
      $FF00 : If WhatBIOSDate = '04/24/81'
                Then EndString := ConCat (EndString, 'PC-0 (16k Motherboard)')
                Else If WhatBIOSDate = '10/19/81'
                  Then EndString := ConCat (EndString, 'PC-1 (64k Motherboard)')
                  Else If (WhatBIOSDate = '08/16/82') or (WhatBIOSDate = '10/27/82')
                    Then EndString := ConCat (EndString, 'PC, XT/XT-370 (256k Motherboard)');
      $FFF9 : EndString := ConCat (EndString, 'PC-Compatible');
    end;
  end;

  {int 15/c0 came up short, so we look at the machine ID byte in desperation}
  if Endstring='' then Case Mem[$FFFF:$000E] Of
    $FF : if mem[$f000:$c000]=$21
            then EndString := ConCat (EndString, 'Tandy 1000')
            else EndString := ConCat (EndString, 'PC');
    $FE,
    $FB : EndString := ConCat (EndString, 'PC/XT');
    $FD : EndString := ConCat (EndString, 'PCjr');
    $FC : EndString := ConCat (EndString, 'PC/AT');
    $FA : EndString := ConCat (EndString, 'PS/2 Model 30');
    $F9 : EndString := ConCat (EndString, 'PS/2 Convertible');
    $F8 : EndString := ConCat (EndString, 'PS/2 Model 90/95?');
    $9A : EndString := ConCat (EndString, 'Compaq XT or Compaq Plus');
    $2D : EndString := ConCat (EndString, 'Compaq PC or Compaq Deskpro');
    $30 : EndString := ConCat (EndString, 'Sperry PC');
    $E9 : EndString := ConCat (EndString, 'Peacock XT');
    $00 : EndString := ConCat (EndString, 'AT&T 6300/Olivetti M24');
  Else
    EndString := 'unknown, ID : ' + Hexword(xWord1);
  End;

  if EndString='' then EndString:='error!'; {we should never get here}
  WhatMachineType := EndString;
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
  if v.PrimaryType='VGA' then s:=WhatSVGACard;
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
  for b:=0 to ord('a')-1 do uchars[b]:=b;
  for b:=ord('a') to ord('z') do uchars[b]:=b-32;
  for b:=ord('z')+1 to 255 do uchars[b]:=b;

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
  {init wilton detect code}
  v.init;
  {find the BIOS CRC for use later}
  WhatBIOSCRC16:=CalcBIOSCRC16;
end.
