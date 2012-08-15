{ -------------------------------------------------------------------------- }
{ CPUDET32.PAS  TMi0SDGL(tm) Revision 2 32-bit DLL import unit  Version 2.15 }
{                                                                            }
{ Too-Much-in-0ne-So-Don't-Get-Lost(tm) Revision 2 CPU/FPU Detection Library }
{ Copyright(c) 1996-2000 by B-coolWare.  Written by Bobby Z.                 }
{ -------------------------------------------------------------------------- }
{ This unit can be compiled with Delphi 2.0x and up or Virtual Pascal only!  }

unit CPUDet32;

interface

{ * the following conditional define is required for this unit to be   * }
{ * compiled with Virtual Pascal. Thanks to Dwayne Heaton for figuring * }
{ * out how to make it work.                                           * }
{$IFDEF VIRTUALPASCAL}
{$IFDEF OS2}
This unit cannot be compiled for OS/2...
{$ENDIF}
{&OrgName-} { DLL functions should be explicitly named or indexed (?) }
{$ENDIF}

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


function cpu_Type : PChar; stdcall;

function fpu_Type : PChar; stdcall;

function cpu_Speed : Integer; stdcall;

function ncpu_Speed : Integer; stdcall;

function fcpu_Speed : Double; stdcall;

procedure CxCPUIDEnable; stdcall;

procedure getCPUID(Level : LongInt; Result : Pointer); stdcall;

function getCPU : Byte; stdcall;

function getFPU : Byte; stdcall;

function getVendorString : PChar; stdcall;

function getSteppingInfo : Integer; stdcall;

function getCPUFeatures : Integer; stdcall;

function getExtraFlags : Word; stdcall;

function getVersion : Word; stdcall;

function getCPUSerialNumber : PChar; stdcall;

implementation

function cpu_Type; external 'cpudet32.dll' name 'cpu_Type';
function fpu_Type; external 'cpudet32.dll' name 'fpu_Type';
function cpu_Speed; external 'cpudet32.dll' name 'cpu_Speed';
function ncpu_Speed; external 'cpudet32.dll' name 'ncpu_Speed';
function fcpu_Speed; external 'cpudet32.dll' name 'fcpu_Speed';
procedure CxCPUIDEnable; external 'cpudet32.dll' name 'CxCPUIDEnable';
procedure getCPUID; external 'cpudet32.dll' name 'getCPUID';
function getCPU; external 'cpudet32.dll' name 'getCPU';
function getFPU; external 'cpudet32.dll' name 'getFPU';
function getVendorString; external 'cpudet32.dll' name 'getVendorString';
function getSteppingInfo; external 'cpudet32.dll' name 'getSteppingInfo';
function getCPUFeatures; external 'cpudet32.dll' name 'getCPUFeatures';
function getExtraFlags; external 'cpudet32.dll' name 'getExtraFlags';
function getVersion; external 'cpudet32.dll' index 1;
function getCPUSerialNumber; external 'cpudet32.dll' name 'getCPUSerialNumber';

end.
