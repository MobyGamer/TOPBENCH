unit topb_datastructures;

{
Data structures used by TOPBENCH.  Main components are a System object
and a TSortedCollection to represent them.

On a 640K DOS machine, roughly 1000 system entries will be able to be stored
in memory.  If we are lucky enough to get past that number, the program
SHOULD gracefully degrade by stopping loading entries once there is
roughly 64K left free.  This will be useful to older machines because only
the oldest/slowest will be loaded due to the fact that the database is
maintained at all times sorted by system speed.  If this actually becomes
a problem, I will look into overhauling the memory structures to use
EMS or XMS streams or something, because the test suites will crash
protected mode (or worse, produce the wrong numbers!).
}

{$DEFINE DEBUG}

interface

uses
  topb_constants,
  Objects;

type
  {TOPBENCH main data structure/object}
  PSystem=^TSystem;
  TSystem=object(TObject)
    UID:pstring;                    {database entry unique string}
    usecMemTest:word;               {# of microseconds this test suite took}
    usecMemEA:word;                 {" "}
    usecOpcodes:word;               {" "}
    usecVidMem:word;                {" "}
    usec3DGames:word;               {" "}
    Score:longint;                  {TOPBENCH system score}
    Name:pstring;                   {in .ini files as MACHINE}
    CPU:pstring;                    {Intel 8088, 80386, Pentium Pro, etc.}
    MHz:real;                       {4.77, 33, 2600, etc.}
    VideoSubsystem:VideoSystems;    {one of five basic types of adapters}
    VideoAdapter:pstring;           {IBM CGA, ATI VGA Wonder 1024, etc.}
    BIOS:pstring;                   {COPR. IBM 1981,1983PS (06/01/83, rev. 71), etc.}
    BIOSDateNormalized:longint;     {20120722, YYYYMMDD}
    BIOSCRC16:word;                 {CRC of BIOS code for optional dupe protection}
    Description:pstring;            {Misc. notes about the system, added by user}
    Submitter:pstring;              {name and/or contact info added by user}

    Constructor Init(
      {required for DB to function at all}
      newUID:string;
      newusecMemTest,newusecMemEA,newusecOpcodes,newusecVidMem,newusec3DGames:word;
      newScore:longint;
      {required for TOPBENCH to be useful to anyone}
      newName:string;
      newCPU:string;
      newMHz:real;
      newVideoSubsystem:VideoSystems;
      newVideoAdapter:string;
      newBIOS:string;
      newBIOSDateNormalized:longint;
      newBIOSCRC16:word;
      newDescription:string;
      newSubmitter:string
    );
    Destructor Done; virtual;

    {Dynamic strings need special handling}
    Procedure setUID(newUID:string);
    Procedure setName(newName:string);
    Procedure setCPU(newCPU:string);
    Procedure setVideoAdapter(newVA:string);
    Procedure setBIOS(newBIOS:string);
    Procedure setDescription(newDesc:string);
    Procedure setSubmitter(newSub:string);
    {$IFDEF DEBUG}
    Procedure Print;
    {$ENDIF}
    Function getSize:longint;

    private

    Procedure ChangePString(var oldps:pstring;news:string);
  end;

  {Sorted collection of system objects, where the sort comparison
  ensures that the list will be ordered from slowest to fastest machine.}
  PSystems=^TSystems;
  TSystems=object(TSortedCollection)
    function Compare(Key1, Key2: Pointer): Integer; virtual;
    function GetSize:longint;
  end;

  {Sorted collection of system objects by name of system.
  This is a more user-friendly way of presenting the systems to a user.}
  PSystemsByName=^TSystemsByName;
  TSystemsByName=object(TSystems)
    {overridden destructor to empty the collection before calling done,
    so that done won't destroy all of the objects}
    Destructor Done; virtual;

    function Compare(Key1, Key2: Pointer): Integer; virtual;
  end;

var
  Systems:PSystems;
  SystemsByName:PSystemsByName;

implementation

Constructor TSystem.Init;
const
  emptyStr='(empty)';
begin
  Inherited Init;

  SetUID(newUID);
  usecMemTest:=newusecMemTest;
  usecMemEA:=newusecMemEA;
  usecOpcodes:=newusecOpcodes;
  usecVidMem:=newusecVidMem;
  usec3DGames:=newusec3DGames;
  Score:=newScore;
  SetName(newName);
  SetCPU(newCPU);
  MHz:=newMHz;
  VideoSubsystem:=newVideoSubsystem;
  SetVideoAdapter(newVideoAdapter);
  SetBIOS(newBIOS);
  BIOSDateNormalized:=newBIOSDateNormalized;
  BIOSCRC16:=newBIOSCRC16;
  SetDescription(newDescription);
  SetSubmitter(newSubmitter);
end;

Destructor TSystem.Done;
begin
  {Free up all pstrings}
  DisposeStr(UID);
  DisposeStr(Name);
  DisposeStr(CPU);
  DisposeStr(VideoAdapter);
  DisposeStr(BIOS);
  DisposeStr(Description);
  DisposeStr(Submitter);

  Inherited Done;
end;

Procedure TSystem.ChangePString(var oldps:pstring;news:string);
{this works regardless of state because DisposeStr checks for NIL}
begin
  DisposeStr(oldps);
  {dynamic strings cannot be empty, so make empty strings one space}
  if news=''
    then news:=#32;
  oldps:=NewStr(news);
end;

Procedure TSystem.setUID(newUID:string);
begin ChangePString(UID,newUID); end;

Procedure TSystem.setName(newName:string);
begin ChangePString(Name,newName); end;

Procedure TSystem.setCPU(newCPU:string);
begin ChangePString(CPU,newCPU); end;

Procedure TSystem.setVideoAdapter(newVA:string);
begin ChangePString(VideoAdapter,newVA); end;

Procedure TSystem.setBIOS(newBIOS:string);
begin ChangePString(BIOS,newBIOS); end;

Procedure TSystem.setDescription(newDesc:string);
begin ChangePString(Description,newDesc); end;

Procedure TSystem.setSubmitter(newSub:string);
begin ChangePString(Submitter,newSub); end;

Function TSystem.getSize;
{Pascal heap manager rounds every new or getmem to 8-byte boundary}
begin
  getSize:=sizeof(TSystem) +
  ((byte(UID^[0]) OR $07) + 1) +
  ((byte(Name^[0]) OR $07) + 1) +
  ((byte(CPU^[0]) OR $07) + 1) +
  ((byte(VideoAdapter^[0]) OR $07) + 1) +
  ((byte(BIOS^[0]) OR $07) + 1) +
  ((byte(Description^[0]) OR $07) + 1) +
  ((byte(Submitter^[0]) OR $07) + 1)
  + 7; {should be 8 for size of pointer to TSystem and roundup, but this
        seems to work better.  Good thing GetSize isn't critical for anything}
end;

{$IFDEF DEBUG}
Procedure TSystem.Print;
begin
  writeln('----');
  writeln('UID: ',UID^);
  writeln('usecMemTest: ',usecMemTest);
  writeln('usecMemEA: ',usecMemEA);
  writeln('usecOpcodes: ',usecOpcodes);
  writeln('usecVidMem: ',usecVidMem);
  writeln('usec3DGames: ',usec3DGames);
  writeln('Score: ',Score);
  writeln('Name: ',Name^);
  writeln('CPU: ',CPU^);
  writeln('MHz: ',MHz);
  writeln('VideoSubsystem: ',byte(VideoSubsystem));
  writeln('VideoAdapter: ',VideoAdapter^);
  writeln('BIOS: ',BIOS^);
  writeln('BIOSDateNormalized: ',BIOSDateNormalized);
  writeln('BIOSCRC16: ',BIOSCRC16);
  writeln('Description: ',Description^);
  writeln('Submitter: ',Submitter^);
end;
{$ENDIF}

Function TSystems.Compare;
{
If two systems have a Score that is greater or less than each other,
the comparison is obvious.  But what if two completely different systems
have an identical Score?  Then we add up all the microsecond timings
and use that as a secondary key.

Okay, but what if we happen to have completely identical timings, but we
KNOW that the systems are different?  We will resolve duplicates using the
BIOS CRC16.

No further comparisons should be necessary.  Seriously, if you are trying
to submit identical timings with identical BIOS code, it's a duplicate.
}

  Function usectotal(sys:PSystem):word;
  begin
    with sys^ do begin
      usectotal:=usecMemTest+usecMemEA+usecOpcodes+usecVidMem+usec3DGames;
    end;
  end;

begin
  {$IFDEF DEBUG}
  {writeln('TSystems.Compare called!');}
  {$ENDIF}
  if PSystem(Key1)^.score < PSystem(Key2)^.score
    then Compare := -1
    else if PSystem(Key1)^.score > PSystem(Key2)^.score
      then Compare := 1
      {Score is the same.  Second search key (larger numbers are worse:}
      else if usectotal(Key1) > usectotal(Key2)
        then Compare := -1
        else if usectotal(Key1) < usectotal(Key2)
          then Compare := 1
          {usec totals same.  Third search key:}
          else if PSystem(Key1)^.BIOSCRC16 < PSystem(Key2)^.BIOSCRC16
            then Compare := -1
            else if PSystem(Key1)^.BIOSCRC16 > PSystem(Key2)^.BIOSCRC16
              then Compare := 1
              else Compare := 0;
end;

Function TSystems.GetSize;
{Pascal heap manager rounds every new or getmem to 8-byte boundary}
var
  l:longint;

  Procedure addsize(machine:PSystem); far;
  begin
    inc(l,machine^.GetSize);
  end;

begin
  l:=0;
  ForEach(@addsize);
  GetSize:=l+sizeOf(TSystems)+(Limit*sizeof(pointer))+3;
  {yes, the +3 is a fudge, but it makes it accurate.  No idea where I'm
  missing 3 bytes in the calculation...!}
end;

Destructor TSystemsByName.Done;
{Empty the collection so that the inherited Done doesn't destroy all of
our objects!  We still need those!}
begin
  DeleteAll;
  Inherited Done;
end;

Function TSystemsByName.Compare;
{
For convenience to the user, this is a second collection that adds systems
sorted by their name.  This will be built shortly before using the system
browser, then disposed of afterwards. tcollection
}

begin
  if PSystem(Key1)^.name^ > PSystem(Key2)^.name^
    then Compare := 1
    else if PSystem(Key1)^.name^ < PSystem(Key2)^.name^
      then Compare := -1
      {names are same.  Now follow same rules as sorting by speed}
      else Compare:=TSystems.Compare(Key1,Key2);

end;

end.
