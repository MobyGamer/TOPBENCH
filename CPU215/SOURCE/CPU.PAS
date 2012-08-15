{ --------------------------------------------------------------------------- }
{ CPU.PAS       TMi0SDGL Release 2 Demonstration program        Version 2.15  }
{                                                                             }
{ Too-Much-in-0ne-So-Don't-Get-Lost(tm) Revision 2 CPU/FPU Detection Library. }
{ Copyright(c) 1996-2000 by B-coolWare. Written by Bobby Z.                   }
{ --------------------------------------------------------------------------- }
{$I-,S-,X+}

{$IFDEF Win32}
{$APPTYPE CONSOLE} {Make 32-bit console application}
{$ENDIF}

program CPUIdentifierExample;

uses CPUType;

const
     Weitek : array[Boolean] of String = ('',' and Weitek coprocessor');

begin
 WriteLn('CPU Type Identifier/Pas  Version 2.15  Copyright(c) 1996-2000 by B-coolWare.');
{$IFDEF BetaBuild}
 WriteLn('*** BETA Build, do not distribute. ***');
{$ENDIF}
{$IFDEF Win32}
 if UnderNT then
  WriteLn('This program does not work well under Windows NT, so expect it to crash...');
{$ENDIF}
 WriteLn('Processor: ',cpu_Type,', ',ncpu_Speed,'MHz');
 WriteLn('Math unit: ',fpu_Type, Weitek[(extFlags and efWeitekPresent)<>0]);
 Halt(cpu);
end.
