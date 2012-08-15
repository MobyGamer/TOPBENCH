{ --------------------------------------------------------------------------- }
{ P5INFOP.PAS   CPU Information Retriever                       Version 2.15  }
{                                                                             }
{ This program is part of TMi0SDGL Revision 2 x86 CPU/FPU Detection Library   }
{ Copyright(c) 1996-2000 by B-coolWare.  Written by Bobby Z.                  }
{ --------------------------------------------------------------------------- }

{$X+}
{ Allow Borland Pascal eXtended syntax }

program P5InfoP;

uses
  CPUType;


procedure printBullet( Flag : LongInt; Message : String );
 begin
  if (cpuFeatures and Flag) = Flag then
   WriteLn(' û '+Message)
  else
   WriteLn(' ú '+Message);
 end;

var
    A : customCpuid;

procedure printExtBullet( Flag : LongInt; Message : String );
 begin
  if (A.edx and Flag) = Flag then
   WriteLn(' û '+Message)
  else
   WriteLn(' ú '+Message);
 end;

var S  : String[12];
    N  : String[48];
    SN : String;

procedure getCPUPartNameEx;
{ This routine only works on new AMD and Cyrix chips. It retrieves data }
{ provided by Extended CPUID levels ( starting at $80000000 )           }
begin
  getCPUID($80000000,@A);
  if Lo(A.eax) < 4 then { no CPU name embedded }
   begin
    N[0] := #0;
    exit;
   end;
  getCPUID($80000002,@A);
  Move(A,N[1],16);
  getCPUID($80000003,@A);
  Move(A,N[17],16);
  getCPUID($80000004,@A);
  Move(A,N[33],16);
  N[0] := #48;
  while N[Length(N)] = #0 do { clear useless NULL characters at the end of string }
   Dec(Byte(N[0]));
end;

begin
 WriteLn('CPU Information Retriever  Version 2.15/P Copyright(c) 1996-2000 by B-coolWare.');
 WriteLn;
 WriteLn('Detected Processor: ',cpu_Type);
 WriteLn;
 if (extFlags and efCPUIDSupport) = 0 then
  begin
   WriteLn('Sorry, this CPU does not support CPUID instruction. Information is unavailable.');
   Halt;
  end;
 if (cpu <> amdK6) { AMD K6 }
    and not ((cpu = amdK5) and ((cpuid1 and $00F0) shr 4 <> 0)) { AMD 5k86 }
    and (cpu <> CxM2) and (cpu <> CxIII) then   { Cyrix Cx6x86MX or Cyrix III}
  begin
   S := cpuid0;
   WriteLn('Make: ',S);
   WriteLn('Family: ',(cpuid1 and $0F00) shr 8,' Model: ',(cpuid1 and $00F0) shr 4,' Step: ',cpuid1 and $000F);
   if N <> '' then
    WriteLn('* Embedded CPU Part Name: ',N);
   SN := getCPUSerialNumber;
   if SN <> '' then
    WriteLn('Processor serial number: ',SN);
   WriteLn;
   {Write('Press any key to see processor features...'#13);
   ReadKey;}
   WriteLn('This CPU has following features (û = present/enabled):');
   printBullet(ifbFPU,   'FPU on chip');
   printBullet(ifbVME,   'Enhanced V86 (VME)');
   printBullet(ifbDE,    'Debugging Extensions');
   printBullet(ifbPSE,   'Page Size Extensions');
   printBullet(ifbTSC,   'Time Stamp Counter');
   printBullet(ifbMSR,   'Pentium-style MSRs');
   printBullet(ifbPAE,   'Physical Address Extension');
   printBullet(ifbMCE,   'Machine Check Exception');
   printBullet(ifbCX8,   'CMPXCHG8B Instruction');
   if cpu = amdK5 then { AMD SSA/5 }
    printBullet($00000200,'Page Global Extensions')
   else
    printBullet(ifbAPIC, 'CPU contains enabled APIC on chip');
   printBullet(ifbSEP,   'SYSENTER/SYSEXIT instructions');
   printBullet(ifbMTRR,  'Memory Type Range Registers');
   if cpu <> amdK5 then
    printBullet(ifbPGE,  'Page Global Extensions');
   printBullet(ifbMCA,   'Machine Check Architecture');
   printBullet(ifbCMOV,  'CMOVcc (FCMOVcc and FCOMI) instructions');
   printBullet(ifbPAT,   'Page Attribute Table');
   printBullet(ifbPSE36, '36-bit Page Size Extension');
   printBullet(ifbPSN,   'PSN (Processor Serial Number)');
   printBullet(ifbMMX,   'MMX (MultiMedia eXtension) instructions');
   printBullet(ifbFXSR,  'FXSAVE/FXRSTOR instructions');
   printBullet(ifbSSE,   'SSE (Streaming SIMD Extensions) instructions ');
   printBullet(ifbCLFLSH,'Cache Line Flush Instruction (CLFLSH)');
   printBullet(ifbDTES,  'Debug Trace and EMON Store (DTES)');
   printBullet(ifbACPI,  'Processor Duty Cycle Control (ACPI)');
   printBullet(ifbSSE2,  'SSE-2 instructions');
   printBullet(ifbSSNP,  'Self-Snoop');
   printBullet(ifbIA64,  'IA-64 instructions');
  end
 else {AMD K6 and Cyrix M2 have extended CPUID levels and information }
  begin
   getCPUPartNameEx;
   WriteLn('--- Non-Intel Processor Extended Info. ---');
   WriteLn('Embedded CPU Part Name: ',N);
   getCPUID($80000000,@A);
   if Lo(A.eax) >= 5 then { maximum extended cpuid levels supported >= 5 }
    begin
     getCPUID($80000005,@A);
     WriteLn('Code Cache size: ',Byte(A.edx shr 24),'Kb, Data Cache size: ',Byte(A.ecx shr 24),'Kb.');
     WriteLn('--- End of Extended Info. ---');
    end;
   getCPUID($80000001,@A);
   WriteLn('This CPU has following features (û = present/enabled):');
   printExtBullet($00000001,'FPU on chip');
   printExtBullet($00000002,'Virtual Mode Extensions');
   printExtBullet($00000004,'Debugging Extension');
   printExtBullet($00000008,'Page Size Extension');
   printExtBullet($00000010,'Time Stamp Counter');
   printExtBullet($00000020,'Model Specific Registers');
   printExtBullet($00000080,'Machine Check Exception');
   printExtBullet($00000100,'CMPXCHG8B instruction');
  if (cpu=amdK6) and (((cpuid1 and $00F0) shr 4) > 6) then { K6 model 7 and up }
   printExtBullet($00000800,'SYSCALL/SYSRET extensions')
  else
   printExtBullet($00000400,'SYSCALL/SYSRET extensions');
   printExtBullet($00001000,'Memory Type Range Registers');
   printExtBullet($00002000,'Page Global Extensions');
   printExtBullet($00004000,'Machine Check Architecture');
   printExtBullet($00008000,'CMOVcc instructions');
  if cpu = AmdK7 then
   printExtBullet($00010000,'Page Attribute Table')
  else
   printExtBullet($00010000,'FCMOVcc/F(U)COMI(P) instructions');
   printExtBullet($00020000,'36-bit Page Size Extension');
  if cpu = AmdK7 then
   printExtBullet($00400000,'SSE-MMX/MMX-MEM (AMD MMX Extensions)');
   printExtBullet($00800000,'MMX (MultiMedia eXtension) instructions');
  if (cpu = CxM2) or (cpu=CxIII) then
   printExtBullet($01000000,'Extended MMX instructions')
  else
  if cpu = AmdK7 then
   printExtBullet($01000000,'FXSAVE/FXRSTOR instructions');
   printExtBullet($40000000,'AMD 3DNow! Plus instructions');
   printExtBullet($80000000,'AMD 3DNow! instructions');
  end;
end.
