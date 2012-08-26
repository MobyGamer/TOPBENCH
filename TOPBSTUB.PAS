{$M 4096,0,655360}
program topbstub;

{
The Oldskool PC Benchmarking stub.  This runs all benchmarking suites and
write the information to a file that can be imported into
TOPBENCH's database.  This stub can run on system with as little as
128KB total RAM, provided the user uses a non-bloated DOS boot disk.
}

{{$DEFINE OVERLAYS}

uses
  {$IFDEF OVERLAYS}
  overlay, bstubov, {preserve this order or overlay system won't work}
  {$ENDIF}
  support,
  cmdlin,
  topb_detect,
  topb_constants,
  inifiles,
  btsuites;

  {$IFDEF OVERLAYS}
  {The following units are safe to overlay (only called once and/or far call model).}
  {$O topb_detect}
  {{$O inifiles} {to prevent floppy disk contention}
  {$O detectconstants}
  {$O detectglobal}
  {$O detectGraphics}
  {$O detectGlobal}
  {$O detectBIOS}
  {$O detectTime}
  {$O cputype}
  {$O crc16}
  {$O dos}
  {$O cmdlin}
  {{$O support} {to ensure waitfloppy doesn't wait for itself}
  {$ENDIF}

const
  {command-line params}
  fname:string[79]='output.ini';
  description:string='';
  skiptests:boolean=false;

var
  oldmem:longint;
  i:PINIfile;
  wrappos:byte;

{$IFNDEF OVERLAYS}
procedure __doswrite(s:string); assembler;
asm
  push    ds
  cld
  lds     si,s
  lodsb
  xor     ah,ah
  xchg    cx,ax           {cx=#0 of string which contains length}
  jcxz    @exit           {if string is length 0 then bail}
  mov     ah,2            {get ready for DOS func. INT 21,2 - Standard Output}
@L1:
  lodsb
  mov     dl,al           {ah=02, dl=character to output}
  int     21h             {do it}
  loop @L1
@exit:
  pop     ds
end;

procedure __doswriteln(s:string);
begin
  __doswrite(s+#13#10);
end;
{$ENDIF}

Procedure WriteWrap(s:string80);
{If string is only 1 char long, it's not a string; it's a column to reset
wrapping on.}
const
  endcol=79;
begin
  {if we have actual string to work with}
  if s[0]<>#1 then begin
    {if length of string will exceed rightmost column, tack a newline at front}
    if byte(s[0])+wrappos > endcol
      then begin
        s:=#13#10+s;
        wrappos:=0;
      end;
    {write it out}
    __DOSWrite(s);
    inc(wrappos,byte(s[0]));
  end else wrappos:=byte(s[1]);
end;

procedure stubtext; external;
{$L stubtext.obj}

procedure helptext; external;
{$L helptext.obj}

begin
  oldmem:=memavail;

  __DOSWrite(StubBanner+#13#10);

  {set command-line vars}
  if non_flag_count>0
    then fname:=non_flag_param(1);
  if is_param('d')
    then description:=param_text('d');
  if is_param('s')
    then skiptests:=true;
  if is_param('?') then begin
    {print out the helptext}
    asm
      mov     ah,09h
      mov     bx,seg helptext
      mov     dx,offset helptext
      push    ds
      mov     ds,bx
      int     21h
      pop     ds
    end;
    exit;
  end;

  {print out the stubtext}
  asm
    mov     ah,09h
    mov     bx,seg stubtext
    mov     dx,offset stubtext
    push    ds
    mov     ds,bx
    int     21h
    pop     ds
  end;

  new(i,init(fname,appendfile,1024));
  i^.WriteComment('Data collected by: '+StubBanner);
  i^.WriteComment('This file contains fingerprinting information about your computer.  Please');
  i^.WriteComment('email this file to trixter@oldskool.org with a subject line of "Benchmark" to');
  i^.WriteComment('help test these routines and seed the TOPBENCH database.');
  i^.StartNewSection(WhatMachineUID,'');

  __DOSWrite(#13#10#10'Waiting for floppy drive spindown... '); WaitFloppySpindown; __DOSWriteln('done.');
  writewrap(#0);
  writewrap('Benchmarking your system:  ');
  writewrap('Memory speed... ');
  i^.WriteKeyValue(LTestMem,inttostr(testMemoryBlockOps));
  writewrap('CPU opcode exercises... ');
  i^.WriteKeyValue(LTestOpcodes,inttostr(testCPUOpcodes));
  writewrap('video memory speed... ');
  i^.WriteKeyValue(LTestVidMem,inttostr(testVideoAdapterWrites));
  writewrap('effective addressing and instruction fetch... ');
  i^.WriteKeyValue(LTestMemEA,inttostr(testMemEA));
  writewrap('3-D game opcode distribution... ');
  i^.WriteKeyValue(LTest3DGames,inttostr(test3DGames));

  WaitFloppySpindown;
  writewrap('Calculating your system''s TOPBENCH score... '); i^.WriteKeyValue(LScore,inttostr(TOPScoreFingerprint));

  writewrap('Done.  Identifying your system:  ');
  if not skiptests then begin
    writewrap('CPU... ');
    i^.WriteKeyValue(LCPU,WhatCPU);
    writewrap('CPU speed... ');
    i^.WriteKeyValue(LCpuSpeed,WhatMHz);
  end;
  writewrap('BIOS... ');
  i^.WriteKeyValue(LBIOSInfo,WhatBIOS);
  writewrap('Machine Model... ');
  i^.WriteKeyValue(LMachineModel,hexword(WhatModelWord));
  writewrap('Date... ');
  i^.WriteKeyValue(LBIOSDate,IntToStr(WhatBIOSDateNormalized));
  writewrap('CRC... ');
  i^.WriteKeyValue(LBIOSCRC16,hexword(WhatBIOSCRC16));
  writewrap('Video subsystem... ');
  i^.WriteKeyValue(LVidSystem,WhatVideoSubsystem);
  if not skiptests then begin
    writewrap('Video adapter... ');
    i^.WriteKeyValue(LVidAdapter,WhatVideoAdapter);
  end;
  writewrap('Machine type... ');
  i^.WriteKeyValue(LName,WhatMachineType);
  if description<>'' then begin
    writewrap('System Description... ');
    i^.WriteKeyValue(LDescription,description);
  end;

  dispose(i,Done);
  writewrap('Finished.  Results written to '+fname+'.'#13#10);
  {FileToSTDOUT(fname);}

  {done, check for memory leaks:}
  if oldmem<>memavail
    then __DOSWriteln('Memory leak of '+inttostr(oldmem-memavail)+' bytes detected!');
end.
