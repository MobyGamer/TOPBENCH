{ -------------------------------------------------------------------------- }
{ CPUDET16.PAS  TMi0SDGL(tm) Revision 2 16-bit DLL import unit  Version 2.15 }
{                                                                            }
{ Too-Much-in-0ne-So-Don't-Get-Lost(tm) Revision 2 CPU/FPU Detection Library }
{ Copyright(c) 1996-2000 by B-coolWare.  Written by Bobby Z.                 }
{ -------------------------------------------------------------------------- }
{ This unit can be compiled with either Borland Pascal 7.0x or Delphi 1.0x   }
{ With Borland Pascal 7 target can be either Windows or DOS Protected Mode   }

unit CPUDet16;

interface

const

{ CPU type constants }

        i8088           = 00;
        i8086           = 01;
        i80C88          = 02;
        i80C86          = 03;
        i80188          = 04;
        i80186          = 05;
        necV20          = 06;
        necV30          = 07;
        i80286          = 08;
        i80386sx        = 09;
        i80386dx        = 10;
        i386sl          = 11;
        ibm386slc       = 12;
        am386sx         = 13;
        am386dx         = 14;
        ct38600         = 15;
        ct38600SX       = 16;
        RapidCAD        = 17;
        i486sx          = 18;
        i486dx          = 19;
        ibm486slc       = 20;
        ibm486slc2      = 21;
        ibm486bl3       = 22;
        Cx486           = 23;
        umcU5S          = 24;
        umcU5D          = 25;
        am486           = 26;
        iPentium        = 27;
        iP54C           = 28;
        CxM1            = 29;
        amdK5           = 30;
        Nx586           = 31;
        iPentiumPro     = 32;
        amdK6           = 33;
        iP7             = 34;
        iP8             = 35;
        CxM2            = 36;
        Am486DX         = 37;
        amdK5_2         = 38;
        WinChipC6       = 39;
        i486sl          = 40;
        AmdK7           = 41;
        WinChip2        = 42;
        Rise_mP6        = 43;
        i376            = 44;
        WinChip3        = 45;

{ FPU type constants }

        fpuInternal     = 100;
        fpuNone         = 0;
        i8087           = 1;
        i80287          = 2;
        i80287xl        = 3;
        i80387          = 4;
        rCAD            = 5;
        cx287           = 6;
        cx387           = 7;
        cx487           = 8;
        cxEMC87         = 9;
        iit287          = 10;
        iit387          = 11;
        iit487          = 12;
        ct387           = 13;
        ulsi387         = 14;
        ulsi487         = 15;
        i487sx          = 16;
        Nx587           = 17;
        iit487DLC       = 18;
        i387SLMobile    = 19;

{ misc constants }

        efHasFPUonChip  = $0001;
        efWeitekPresent = $0002;
        efCPUIDSupport  = $0004;
        efDXType        = efCPUIDSupport+efHasFPUOnChip;
        efEmulatedFPU   = $0008;

function cpu_Type : PChar;

function fpu_Type : PChar;

function cpu_Speed : Integer;

function ncpu_Speed : Integer;

function fcpu_Speed : Double;

procedure CxCPUIDEnable;

procedure getCPUID(Level : LongInt; Result : Pointer);

function getCPU : Byte;

function getFPU : Byte;

function getVendorString : PChar;

function getSteppingInfo : LongInt;

function getCPUFeatures : LongInt;

function getExtraFlags : Word;

function getVersion : Word;

function getCPUSerialNumber : PChar;

implementation

function cpu_Type; external 'CPUDET16';
function fpu_Type; external 'CPUDET16';
function cpu_Speed; external 'CPUDET16';
function ncpu_Speed; external 'CPUDET16';
function fcpu_Speed; external 'CPUDET16';
procedure CxCPUIDEnable; external 'CPUDET16';
procedure getCPUID; external 'CPUDET16';
function getCPU; external 'CPUDET16';
function getFPU; external 'CPUDET16';
function getVendorString; external 'CPUDET16';
function getSteppingInfo; external 'CPUDET16';
function getCPUFeatures; external 'CPUDET16';
function getExtraFlags; external 'CPUDET16';
function getVersion; external 'CPUDET16';
function getCPUSerialNumber; external 'CPUDET16';

end.
