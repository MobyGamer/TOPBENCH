{$O+,F+}
Unit DetectGlobal;

Interface

Uses Dos;

{an attempt to cut down on stack size}
type
  string8=string[8];
  string16=string[16];
  string32=string[32];
  string64=string[64];
  string128=string[128];

Type
  Cpu_Info_T = Record
    MSW       : Word;
    GDT       : Array [1..6] Of Byte;
    IDT       : Array [1..6] Of Byte;
    Intflag   : Boolean;
    Ndp_Cw    : Word;
    Weitek    : Byte;
    Test_Type : Char
  End;

  ResultRec = Record
    CPUType: Byte;
    NDPType: Byte;
    AAMTime: Integer;
    Dummy1:  Integer;
    MoveWTime, BIOSWriteTime, MoveBTime, EMS_Time,
    Ext_Time, ScreenFillTime, Dummy2, Speed87,
    Speed287, MoveDTime, DosWriteTime : Integer;
  End;

  PtrRec = Record
    Seg : Word;
    Ofs : Word;
  End;

  CacheInfo    = ARRAY [1..10] OF WORD;
  CacheInfoPtr = ^CacheInfo;

  tBiosInfo = Record
    IsThere   : Boolean;
    Segment   : Word;
    Size      : Word;
    Copyright : String[100];
  End;

  pBiosCopyright = ^tBiosCopyright;
  tBiosCopyright = Record
    BiosInfo : Array [0..94] Of tBiosInfo;
  End;

  tProgInfo = Record
    IsThere    : Boolean;
    Segment    : Word;
    Size       : LongInt;
    Owner      : String[20];
    CMDLine    : String[20];
    Interrupts : Array [0..$FF] Of Boolean;
  End;

  pMemory = ^tMemory;
  tMemory = Record
    ProgInfo : Array [0..128] Of tProgInfo;
  End;

  Chr4  = Array [0..3] Of Char;
  Byte4 = Array [0..3] Of Byte;

  pCPUId = ^tCPUId;
  tCPUId = Record
    Copyright       : String[20];
    VendorId        : String[12];
    Stepping        : Byte;
    Family          : Byte;
    Model           : Byte;
    Typ             : Byte;
    Features        : LongInt;
    Cache1          : Byte4;
    Cache2          : Byte4;
    Cache3          : Byte4;
    Cache4          : Byte4;
    Ext8000_0000EAX : LongInt;
    Ext8000_0001EAX : LongInt;
    Ext8000_0001EDX : LongInt;
    AMDProcName1    : Chr4;
    AMDProcName2    : Chr4;
    AMDProcName3    : Chr4;
    AMDProcName4    : Chr4;
    AMDProcName5    : Chr4;
    AMDProcName6    : Chr4;
    AMDProcName7    : Chr4;
    AMDProcName8    : Chr4;
    AMDProcName9    : Chr4;
    AMDProcName10   : Chr4;
    AMDProcName11   : Chr4;
    AMDProcName12   : Chr4;
    Ext8000_0005EAX : Byte4;
    AMDCache1       : Byte4;
    AMDCache2       : Byte4;
    AMDCache3       : Byte4;
  End;

  pWord = ^Word;

  pOpenInfo = ^tOpenInfo;
  tOpenInfo = Record
    Name        : String[20];
    OpenMode    : String[15];
    SharingMode : String[20];
    Inherit     : Boolean;
    Attribut    : Byte;
      { Bit 0 = nur-lesen
            1 = versteckt
            2 = system
            3 = volume label
            4 = Verzeichnis
            5 = Archiv       }
    Remote      : Boolean;
    Date        : String[12];
    Time        : String[12];
    Size        : LongInt;
    FileType    : String;
    OwnerPSP    : Word;
  End;

Const ClockFreq   = 1.193182e6;
      NA          = 'n/a';

Var Regs      : Registers;
    CPU_Info  : CPU_Info_T;
    AltPtr    : PtrRec;
    TempFreq  : Real;
    pReal     : ^Real;
    pByte     : ^Byte;
    p         : Pointer;
    xByte     : Byte;
    xByte1    : Byte;
    xbyte2    : Byte;
    xbyte3    : byte;
    xByte4    : Byte;
    xbyte5    : Byte;
    xbyte6    : byte;
    xbyte7    : byte;
    xBool     : Boolean;
    xBool2    : Boolean;
    xChar     : Char;
    xWord     : Word;
    xWord1    : Word;
    xword2    : word;
    xword3    : word;
    xword4    : word;
    xword5    : word;
    xword6    : word;
    xword7    : word;
    xword8    : word;
    xLong     : LongInt;
    xLong2    : LongInt;
    xLong3    : LongInt;
    {xString   : String;
    xString1  : String;
    xString2  : String;}
    S         : String;
    EndString : String;
    Result    : ResultRec;
    xPointer  : Pointer;

Function StrFnWord   (Number : Word)              : String;
Function StrFnByte   (Number : Byte)              : String;
Function Hex         (A : LongInt; B : Byte)      : String;
Function UnBCD       (B: Byte)                    : Byte;
Function BCDWordToString (X: word)                : String;
Function ZeroPad     (N : Byte)                   : String;
Function UpCaseString (S : String)                : String;

Function PopAdbugtst                               : Byte;
Function MulBugTst                                 : Byte;
Function FDivBugTst                                : Byte;
Function ATIinfo (Data_In : Byte; Register : Word) : Byte;
Function TsengCK                                   : Byte;
Function ZyMOSCK                                   : Byte;
Function TestCache                                 : CacheInfoPtr; Far;
Function TestCach286                               : CacheInfoPtr; Far;

Procedure SpeedTest (Debg, Ext_Flag, EMS_Flag: WORD; EPtr, Bptr,
                     Sptr: POINTER; VAR Results: ResultRec);

Procedure Misc (Var A : Cpu_Info_T);

Procedure AltIntr (IntNo : Byte; Var Regs : Registers);
Procedure AltMsDos (Var Regs : Registers);


Implementation

{$L DETECTGL.OBJ}

{$F+}

Function UpCaseString (S : String): String;

Var
  WorkStr  : String;
  Schleife : Byte;

Begin
  WorkStr := S;
  For Schleife := 1 To Length (S) Do Begin
    WorkStr [Schleife] := Upcase (WorkStr [Schleife]);
    Case WorkStr [Schleife] Of
      'Ñ': WorkStr [Schleife] := 'é';
      'î': WorkStr [Schleife] := 'ô';
      'Å': WorkStr [Schleife] := 'ö';
    End;
  End;
  UpCaseString := WorkStr;
End;

Function StrFnWord;

Var Temp1 : String[5];

Begin
  Str (Number, Temp1);
  StrFnWord := Temp1;
End;


Function StrFnByte;

Var Temp1 : String[3];

Begin
  Str (Number, Temp1);
  StrFnByte := Temp1;
End;


Function Hex;

Const
  Digit : Array [$0..$F] Of Char = '0123456789ABCDEF';

Var
  I       : Byte;
  xstring : string[8];

Begin
  xstring := '';
  For I := 1 To B Do
    Begin
      Insert (Digit [A And $000F], xstring, 1);
      A := A Shr 4
    End;
  Hex:=xstring
End;


Function UnBCD(B: Byte): Byte;

Begin
  UnBCD:=(B And $0F) + ((B Shr 4) * 10)
End;


Function BCDWordToString(x: word) : String;

Var
  c: char;

Begin
  c:=Chr((x shr 12) + 48);
  If c <> '0' then
     BCDWordToString := C;
  BCDWordToString := Chr(((x and $0F00) shr 8) + 48)+ '.'+
    Chr(((x and $00F0) shr 4) + 48) + Chr((x and $000F) + 48)
End;


Function ZeroPad;

Begin
  If N > 9 Then ZeroPad := StrFnByte(N) Else
    ZeroPad := '0' + StrFnByte(N);
End;

Procedure Misc (Var A : Cpu_Info_T); External;

Procedure AltIntr (IntNo : Byte; Var Regs : Registers); External;
Procedure AltMsDos (Var Regs : Registers); External;

Function ATIinfo (Data_In : Byte; Register : Word) : Byte; External;
Function TsengCK                                   : Byte; External;
Function ZyMOSCK                                   : Byte; External;
Function PopAdbugtst                               : Byte; External;
Function MulBugTst                                 : Byte; External;
Function FDivBugTst                                : Byte; External;

Procedure SpeedTest1 (Debg, Ext_Flag, EMS_Flag: WORD; EPtr, Bptr,
                     Sptr: POINTER; Var Results: ResultRec); Near; External;

Procedure SpeedTest;

Begin
  SpeedTest1 (Debg, Ext_Flag, EMS_Flag, EPtr, Bptr, Sptr, Results);
End;

Function TestCache:   CacheInfoPtr; external;
Function TestCach286: CacheInfoPtr; external;


End.