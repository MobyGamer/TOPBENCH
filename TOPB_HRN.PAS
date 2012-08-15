{topbench memory structures test harness.  (and other routines)}

(*
For reference:

[UID9485166A30]
memory_test=3774
opcode_test=1753
vidram_test=2652
mem_ea_test=1935
3dgame_test=1851
score=4
machine=PC/XT (enhanced)
cpu=Intel 8088
cpuspeed=4.77 MHz
biosinfo=62X0851 COPR. IBM 1986 (01/10/86, rev. 1)
biosdate=19860110
bioscrc16=9485
videosystem=CGA
videoadapter=CGA

      newUID:string;
      newusecMemTest,newusecMemEA,newusecOpcodes,newusecVidMem,newusec3DGames:word;
      newScore:longint;
      {required for TOPBENCH to be useful to anyone}
      newName:string;
      newCPU:string;
      newMHz:real;
      newVideoSubsystem:videoSystemType;
      newVideoAdapter:string;
      newBIOS:string;
      newBIOSDateNormalized:longint;
      newBIOSCRC16:word;
      newDescription:string;
      newSubmitter:string


*)

program topb_hrn;

uses
  objects,
  support,
  inifiles,
  topb_constants,
  topb_datastructures;

var
  testsystem1:PSystem;
  systemstest:PSystems;
  startmem,endmem:longint;
  w:word;
  oldcount:word;

  testini:pinifile;

const
  testmaxelements=512;

procedure PrintAll(s: PSystems);

  procedure CallPrint(machine : PSystem); far;
  begin
    with machine^ do
      writeln(UID^,' ',name^,' ',score);
    {machine^.print;}
  end;

begin { Print }
  Writeln('Systems printout:');
  s^.ForEach(@CallPrint);
end;


procedure SearchUID(s:PSystems; UIDToFind: String);

  function UIDMatch(System: PSystem): Boolean; far;
  begin
    UIDMatch := (system^.UID^ = UIDToFind);
  end;

var
  SystemFound:PSystem;

begin
  Writeln;
  SystemFound := s^.FirstThat(@UIDMatch);
  if SystemFound=nil
    then Writeln('Could not find search criteria')
    else SystemFound^.Print;
end;

var
  INIResult:PINIResultType;

begin
  writeln('================start================');

  {test ini file routines}
  startmem:=memavail;

  new(testini,init('test.ini',readfile,1024));
  repeat
    INIResult:=testini^.ReadNextItem;
    if INIResult=nil
      then break;
    if testini^.newSection then begin
      writeln('Found new section header: ',INIResult^.section);
      testini^.ACKSection;
    end;
    if INIResult^.key<>''
      then writeln('Found new key/value pair: ',INIResult^.key,':',INIResult^.value);
  until (INIResult=nil);
  dispose(testini,done);

  endmem:=memavail;
  if startmem<>endmem
    then writeln('MEMORY LEAK: ',startmem-endmem)
    else writeln('No memory leaks detected');
  readln;

  randomize;
  {test individual object routines}
  startmem:=memavail;
  writeln('================start================');
  writeln(startmem);
  testsystem1:=new(PSystem,init('UID2EC168B0A',1111,2222,3333,4444,5555,5,
    'name','cpu',4.77,CGA,'IBM CGA','BIOSCOPY',20120706,$14f3,
    'Sample test entry for the data structures test harness.  These can go a bit long.',
    'trixter@oldskool.org'));

  writeln('Mem used by single typical object: ',startmem-memavail);
  writeln('Object reports its size as ',testsystem1^.GetSize);
  writeln('changing some fields...');

  with testsystem1^ do begin
    setName('VirtualBox VM');
    setCPU('Intel Pentium III Xeon');
    setVideoAdapter('VGA, Yamaha 6388, VESA, 256kb Video Memory (BIOS)');
    setBIOS('Oracle VM VirtualBox BIOS (06/23/99, rev. 1)');
    setSubmitter('trixter@oldskool.org');
  end;

  writeln('Mem used by single typical object: ',startmem-memavail);
  writeln('Object reports its size as ',testsystem1^.GetSize);
  writeln(memavail);
  writeln(testsystem1^.Name^);
  testsystem1^.setName('Test System 333');
  writeln(testsystem1^.Name^);
  dispose(testsystem1,done);
  endmem:=memavail;
  if startmem<>endmem
    then writeln('MEMORY LEAK: ',startmem-endmem)
    else writeln('No memory leaks detected');

  {test entire sorted collection}
  writeln('================start collections test================');
  startmem:=memavail;
  systemstest := New(PSystems, Init(640, 16)); {"640 ought to be enough for anybody..." ;-}
  writeln('Memory taken up by empty collection: ',startmem-memavail);

  {Okay, this is slightly bullshitty:  If Duplicates is set in a TSortedCollection,
  it is SILENTLY REJECTED.  We want no duplicates, but we don't want memory
  leaks either, so we have to do our own dupe checking.  Geezus.}
  with systemstest^ do begin
    for w:=0 to testmaxelements-1 do begin
      {make new object}
      testsystem1:=New(PSystem, init('UID'+inttostr(w),1111,2222,3333,4444,5555,random(testmaxelements)+2,
      'name'+inttostr(w),'cpu',4.77,CGA,'IBM CGA','BIOSCOPYrightstring all rights reserved',20120706,
      random(testmaxelements div 8),
      'Sample test entry for the data structures test harness.  These can go a bit long sometimes, so this line will be too.',
      'trixter@oldskool.org'));
      {insert into collection}
      oldcount:=Count;
      Insert(testsystem1);
      {If the count did NOT increase, it's because it's a dupe.
      Dispose the object we just created.}
      if oldcount=Count
        then begin
          writeln('Dupe found with score ',testsystem1^.score,' and BIOS16CRC of ',testsystem1^.bioscrc16);
          dispose(testsystem1,done);
        end;
      if (count AND 7)=7 then write(#13,inttostr(count));
    end;
  end;
  writeln;

  writeln('Memory taken up by collection with ',systemstest^.Count,' entries: ',startmem-memavail);
  writeln('Collection itself reports ',systemstest^.Getsize,' bytes used.');
  writeln('Average element size: ',systemstest^.GetSize div systemstest^.Count);
  readln;

  { Use ForEach iterator to print all }
  PrintAll(systemstest);

  {Find element 2 and element maxelements-2 and print them, also look for }
  SearchUID(systemstest,'UID'+inttostr(2)); readln;

  writeln('Element 2 is: ',PSystem(systemstest^.at(2))^.UID^);
  writeln(memavail);
  writeln('Deleting element 2, showing new element 2:');
  systemstest^.AtFree(2);
  writeln('Element 2 is: ',PSystem(systemstest^.at(2))^.UID^);
  writeln(memavail);
  readln;

  SearchUID(systemstest,'UID'+inttostr(testmaxelements-2)); writeln ('now non-existent element:'); readln;
  SearchUID(systemstest,'UID'+inttostr(testmaxelements+2)); readln;
  writeln('Midpoint of collection: ');
  testsystem1:=systemstest^.at(testmaxelements div 2);
  if testsystem1 <> NIL then testsystem1^.Print;
  readln;

  writeln('Disposing collection...');
  dispose(systemstest,done);
  endmem:=memavail;
  if startmem<>endmem
    then writeln('MEMORY LEAK: ',startmem-endmem)
    else writeln('No memory leaks detected');

end.