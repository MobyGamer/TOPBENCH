program topbench;

{{$DEFINE DEBUG}
{{$DEFINE USEOVERLAYS}

uses
  objects,
  {$IFDEF USEOVERLAYS}
  bstubov,
  {$ENDIF}

  totLOOK, totSYS, totFAST, totWIN, totMSG,
  totIO1, totIO2, totIO3, totINPUT, totMENU,

  m6845ctl,
  m320_640,
  strings,
  dos,crt,
  topb_constants,
  topb_datastructures,
  topb_detect,
  btsuites,
  cmdlin,
  inifiles,
  support;

{$IFDEF USEOVERLAYS}
  {Note: documentation discourages overlaying TOTSYS, TOTINPUT, and TOTFAST}
  {$O totLOOK}
  {$O totREAL}
  {$O totWIN}
  {$O totMSG}
  {$O totLINK}
  {{$O totLIST}
  {{$O totDIR}
  {$O totIO1}
  {$O totIO2}
  {$O totIO3}
  {$O totMENU}
  {$O totSTR}
  {$O totDATE}
  {$O totMISC}
  {$O totINPUT}

  {$O topb_detect}
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
{$ENDIF}

type
  messageType=(info,warning,error,fatal);

  {Object for logging messages to a file}
  PLog=^TLog;
  TLog=object(TObject)
    logname:string128;
    Constructor Init(name:string128);
    Destructor Done; virtual;

    Procedure Commit(msg:string);

    private
    loghandle:text;
  end;

  {Message console object.  Messages are tagged with info, warning, or error
  and show up on a virtual screen in different colors.  All messages except
  info are also logged atomically to the application logfile.  If verboselog
  is set, then info messages are logged as well.}
  PMConsole=^TMConsole;
  TMConsole=object(Tobject)
    verboseLog:boolean; {if true, "info" messages get written to log}
    ConScreen,savescreen:PScreenOBJ;
    {colors for the console.  Default values work for both color and MDA.}
    _cnormal,_creverse,_chigh,_cunderline,_cblink:byte;

    Constructor Init;
    Destructor Done; virtual;

    Procedure Show;
    Procedure Hide;
    Procedure LogMsg(m:messageType;msg:string);

    private
    fileLog:PLog;
  end;

const
  DBdirty:boolean=false; {if dirty, DB needs to be written to disk}
  DBreadonly:boolean=false; {if DB gets partially loaded to due low ram, don't save it back out again}
  INIBufSize=18*512*2; {enough to hold an entire 1.44MB track}
  minramfree=80*50*2;
  {default colors that work with both MDA and CGA}
  cnormal:byte=$07;
  creverse:byte=$70;
  chigh:byte=$0f;
  cunderline:byte=$01;
  cblink:byte=$8c;
  {user preferences flags:}
  _sound:boolean=true;
  _skiptests:boolean=false;
  _searchdistance:byte=2; {fine-tune results n-_sd to n+_sd}

var
  Systems:PSystems;
  SystemsByName:PSystemsByName;
  mematstart:longint;
  MainMenu:PMenuOBJ;
  BenchMenu,DBMenu:MenuOBJ; {must be static objects due to TOT broken design}
  MsgConsole:PMConsole;
  FStatus:PWinOBJ;


Constructor TLog.Init;
begin
  Inherited Init;

  logname:=name;
  assign(loghandle,logname);
  rewrite(loghandle);
  close(loghandle);
end;

Destructor TLog.Done;
begin
  Inherited Done;
end;

Procedure TLog.commit(msg:string);
begin
  append(loghandle);
  writeln(loghandle,msg);
  close(loghandle);
end;


Constructor TMConsole.Init;

begin
  Inherited Init;

  _cnormal:=$07;
  _creverse:=$70;
  _chigh:=$0f;
  _cunderline:=$01;
  _cblink:=$8c;

  new(fileLog,init(logfilename));
  verboseLog:=false;

  new(ConScreen,init);
  ConScreen^.create(Monitor^.Width,Monitor^.Depth,TLightGray);
  ConScreen^.writeCenter(1,_creverse,'Debug message console.  Only recent entries displayed.  Press a key to dismiss. ');
end;

Destructor TMConsole.Done;
begin
  dispose(ConScreen,done);
  dispose(fileLog,done);

  Inherited Done;
end;

Procedure TMConsole.Show;
begin
  new(savescreen,init);
  savescreen^.save;
  ConScreen^.Display;
end;

Procedure TMConsole.Hide;
begin
  savescreen^.display;
  dispose(savescreen,done);
end;

Procedure TMConsole.LogMsg;
var
  color:byte;
begin
  {first, make sure it gets into the log file if it is important}
  case m of
    info:if verboseLog then fileLog^.Commit(msg);
    warning:fileLog^.Commit('Warning: '+msg);
    error  :fileLog^.Commit('=ERROR=  '+msg);
    fatal  :fileLog^.Commit('=FATAL=  '+msg);
  end;
  {then, insert it into the message console}
  ConScreen^.Scroll(up,1,2,Monitor^.Width,Monitor^.Depth);
  case m of
    info:color:=_cnormal;
    warning:color:=_chigh;
    error,
    fatal:color:=_cblink;
  end;
  ConScreen^.WriteAt(1,Monitor^.Depth,color,msg);
  {if we have a fatal error,
  MAYDAY MAYDAY TOPBENCH IS BUDDY-SPIKED ABORT ABORT ABORT}
  if m=fatal then begin
    screen.resetwindow;
    if screenseg=ptr($b000,0)
      then asm mov ax,0007; int 10h; end
      else asm mov ax,0003; int 10h; end;
    asm
      les di,screenseg
      mov ax,0720h
      mov cx,1000h
      rep stosw
    end;
    system.writeln('FATAL ERROR: '+msg);
    system.writeln('It might be prudent to check '+fileLog^.logname+' for clues.');
    halt(1);
  end;
end;

procedure PrepFWindow(title:string80);
begin
  {pop-up window so user can see file ops taking place}
  new(fStatus,init);
  with fStatus^ do begin
    SetSize(4,4,Monitor^.width-4,monitor^.depth-4,1);
    SetTitle(title);
    SetClose(false);
    draw;
    Screen.Clear(tlightgray,' ');
  end;
end;


Procedure PopUserMessage(class:messagetype;s:string80);
var
  foomsg:PMessageObj;
  loop:byte;
  ts:string[12];
begin
  case class of
    info   :ts:='Information';
    warning:ts:='Warning:';
    error  :ts:='Error!';
  end;
  new(foomsg,init(2,ts));
  with foomsg^ do begin
    addline(s);
    addline(' ');
    show;
    MsgConsole^.LogMsg(class,s);
  end;
  dispose(foomsg,done);
end;

Procedure PopAbout;
var
  foomsg:PMessageObj;
  loop:byte;
begin
  new(foomsg,init(2,strpas(mainmenuLookup[mAbout].blurb)));
  with foomsg^ do begin
    for loop:=0 to 15 do AddLine(strpas(AboutText[loop]));
    if Systems^.Count>0
      then addline(' Systems loaded: '+inttostr(Systems^.Count)
             +' (RAM holds roughly ~'+inttostr(Systems^.Count+(memavail div (Systems^.getsize div Systems^.Count)))+')');
    addline('    Memory free: '+inttostr(memavail div 1024)+' KB (largest: '+inttostr(maxavail div 1024)+' KB)');
    addline(' ');
    show;
  end;
  dispose(foomsg,done);
end;

procedure introtext; external;
{$L introscn.obj}

Procedure PopIntro;
const
  x1=3;
  y1=4;
  margin=72;
  curx:byte=x1;
  cury:byte=y1;
var
  c:^char;
  col:byte;
begin
  curx:=x1;
  cury:=y1;
  screen.TitledBox(1,1,Monitor^.Width,Monitor^.Depth,
    LookTOT^.vmenuborder,LookTOT^.vmenutitle,LookTOT^.vmenuborder,
    6,'Introduction to TOPBENCH');
  c:=@introtext;
  col:=LookTOT^.vmenulonorm;
  while c^ <> '$' do begin
    case c^ of
      #13:curx:=x1;
      #10:inc(cury);
      '~':if col=LookTOT^.vmenulonorm then col:=LookTOT^.vmenulohot else col:=LookTOT^.vmenulonorm;
      '$':break;
      else begin
        screen.writeat(curx,cury,col,c^);
        inc(curx);
        if (c^=#32) and (curx>margin) then begin
          curx:=x1;
          inc(cury);
        end;
      end;
    end;
    inc(word(c)); {advance pointer}
  end;
  screen.writecenter(monitor^.depth,LookTOT^.vmenulohot,'Press any key to dismiss');
  Key.getkey;
end;

function PromptYN(msg:string80):boolean;
var
  PromptWin:PPromptOBJ;
  result:tAction;
begin
  new(promptwin,Init(1,''));
  with PromptWin^ do begin
    AddLine(msg);
    AddLine(' ');
    SetOption(1,'  ~Y~es  ',89,Finished);
    SetOption(2,'  ~N~o  ',78,Escaped);
    Result := Show;
  end;
  PromptYN:=(Result = Finished);
  dispose(promptwin,done);
end;


Function PromptForFilename(blurb:string80):string128;
const
  wid=77;
var
  PromptWin:PWinOBJ;
  fname:PLateralIOOBJ;
begin
  new(PromptWin,init);
  with PromptWin^ do begin
    SetSize(4,2,wid,4,1);
    SetTitle(blurb);
    SetClose(false);
    draw;
    screen.writeplain(1,1,'Filename: ');
  end;
  new(fname,init(10,1,wid-10,127));
  with fname^ do begin
    SetLabel('Filename: ');
    Activate;
    PromptForFilename:=GetValue;
  end;
  dispose(fname,done);
  dispose(PromptWin,done);
end;

Procedure CommitSystem(var NewSystem:PSystem);
{Commits a new system object to the collection.  Duplicates are logged
and destroyed.  No error checking is performed on the source object
(it is assumed that checking is done prior to calling this procedure).}
var
  oldcount:word;
begin
  if NewSystem=NIL then begin
    MsgConsole^.LogMsg(error,'Attempted commit of NIL object!');
    exit;
  end;
  oldcount:=Systems^.Count;
  {insert into collection}
  Systems^.Insert(NewSystem);
  {If the count did NOT increase, it's because it's a dupe.}
  if oldcount=Systems^.Count then begin
    MsgConsole^.LogMsg(warning,NewSystem^.UID^+' rejected as a duplicate or redundant entry.');
    dispose(NewSystem,done);
    {some evidence of this not happening, so we will ensure it:}
    NewSystem:=nil;
  end else begin
    {Commit was successful; mark database as dirty}
    DBDirty:=true;
  end;
end;

Procedure MakeNewSystem(var NewSystem:PSystem);
{inits a new object with default/empty parameters}
begin
  NewSystem:=new(PSystem,init('UID0',0,0,0,0,0,0,'','',0,unset,'','',DefaultDate,0,'',''));
  {NewSystem:=new(PSystem,init('UID0',0,0,0,0,0,0,#0,#0,0,unset,#0,#0,DefaultDate,0,#0,#0));}
end;

Procedure DetectSystem(var NewSys:PSystem);
{Fills a system object with autodetect results}
var
  vs:videosystems;
  s:string8;
begin
  PrepFWindow('Detecting System');
  Screen.writeln('Getting microsecond timings...');
  newsys^.usecMemTest:=testmemoryblockops;
  newsys^.usecMemEA  :=testmemEA;
  newsys^.usecOpcodes:=testCPUOpcodes;
  newsys^.usecVidMem :=testVideoAdapterWrites;
  newsys^.usec3DGames:=test3DGames;
  Screen.writeln('Getting TOPSCORE fingerprint...');
  newsys^.score:=topscorefingerprint;
  Screen.writeln('Detecting: ');

  if not _skiptests then begin
    screen.writeln('CPU... ');
    newsys^.SetCPU(WhatCPU);

    screen.writeln('CPU speed... ');
    {newsys^.MHz:=WhatMHzReal;} {too touchy}
    newsys^.MHz:=WhatMHzRealNormalized;
  end;

  Screen.writeln('BIOS... ');
  NewSys^.setbios(WhatBIOS);

  Screen.writeln('BIOS Date... ');
  NewSys^.biosdatenormalized:=(WhatBIOSDateNormalized);

  Screen.writeln('CRC...');
  NewSys^.BIOSCRC16:=WhatBIOSCRC16;

  Screen.writeln('Video subsystem...');
  s:=WhatVideoSubsystem;
  for vs:=MDA to VGA do
    if upstring(s)=VidSysLabels[vs]
      then newsys^.VideoSubsystem:=vs;

  if not _skiptests then begin
    Screen.writeln('Video adapter...');
    newsys^.setvideoadapter(WhatVideoAdapter);
  end;
  Screen.writeln('Machine type...');
  NewSys^.setname(WhatMachineType);

  NewSys^.SetUID(WhatMachineUID);

  Screen.writeln('Done!');
  dispose(fStatus,done);
end;

Procedure ImportSystemFile(s:string128);
{Imports one or more entries from an ini-style database file}
const
  usecThreshold=10000;

var
  ini:PINIfile;
  iniresult:PINIResultType;
  tmpsys:PSystem;
  foundflags:byte;
  foos:string;
  vs:VideoSystems;

  Procedure AttemptCommit;
  {if this fails, object is wiped out (by design) so don't call this
  unless you are REALLY sure it's time to commit the object.}
  var
    foomsg:string80;
  begin
    mouse.hide;
    Screen.writeln(tmpsys^.Name^);
    {mouse.show;}
    if (foundflags=RequiredFeatures) and (memavail>minramfree)
      then CommitSystem(tmpsys)
      else begin
        foomsg:='Commit of '+tmpsys^.UID^+' rejected due to lack of ';
        if foundflags<>requiredfeatures
          then MsgConsole^.LogMsg(warning,foomsg+'required entries');
        if memavail<=minramfree then begin
          MsgConsole^.LogMsg(error,foomsg+'available RAM');
          DBreadonly:=true;
        end;
        dispose(tmpsys,done);
      end;

    foundflags:=0;
  end;

begin
  ini:=new(PINIFile,init(s,readfile,INIBufSize));
  if ini=NIL then begin
    MsgConsole^.LogMsg(error,'Couldn''t open INI file: '+s);
    exit;
  end;

  PrepFWindow('Importing '+s);
  {init our temp object}
  MakeNewSystem(tmpsys);
  foundflags:=0;
  {read entire ini file, inserting systems into the collection as we go}
  {do the first read to prep the first object}
  INIResult:=ini^.ReadNextItem;
  tmpsys^.SetUID(INIResult^.section);
  {acknowledge that we've begun a new section and can continue}
  if ini^.newSection then ini^.ACKSection;
  {read loop:}
  while (INIResult<>nil) do begin
    INIResult:=ini^.ReadNextItem;
    {end of INI file reached?  Invalid return?}
    if INIResult=nil then break;
    {new section? Commit what we have, then set up for next object}
    if ini^.newSection then begin
      {attempt to commit the object we've been building all these iterations}
      AttemptCommit;
      {begin collecting info for new object}
      MakeNewSystem(tmpsys);
      {set the new found UID}
      tmpsys^.SetUID(INIResult^.section);
      {Acknowledge to the INI reader that we have processed the new section}
      ini^.ACKSection;
      MsgConsole^.LogMsg(info,'Found new section header: '+INIResult^.section);
    end;
    {process all key/value pairs we're interested in}
    if INIResult^.key<>'' then begin
      with INIResult^ do begin
        {message(info,'Found new key/value pair: '+key+':'+value);}

        {I apologize for the inelegance of this section -- this should
        really be a pchar-based record array and a simple loop.  Once
        TOPBENCH is fully operational, I may go back through the code
        and clean stuff like this up.  Until then, avert your eyes!}

        if upstring(key)=upstring(LTestMem) then begin
          tmpsys^.usecMemTest:=strToInt(value);
          if tmpsys^.usecMemTest < usecThreshold
            then foundflags:=foundflags OR LTestMemF
            else MsgConsole^.LogMsg(error,'Invalid usecMemTest value');
        end;
        if upstring(key)=upstring(LTestMemEA) then begin
          tmpsys^.usecMemEA:=strToInt(value);
          if tmpsys^.usecMemEA < usecThreshold
            then foundflags:=foundflags OR LTestMemEAF
            else MsgConsole^.LogMsg(error,'Invalid usecMemEA value');
        end;
        if upstring(key)=upstring(LTestOpcodes) then begin
          tmpsys^.usecOpcodes:=strToInt(value);
          if tmpsys^.usecOpcodes < usecThreshold
            then foundflags:=foundflags OR LTestOpcodesF
            else MsgConsole^.LogMsg(error,'Invalid usecOpcodes value');
        end;
        if upstring(key)=upstring(LTestVidMem) then begin
          tmpsys^.usecVidMem:=strToInt(value);
          if tmpsys^.usecVidMem < usecThreshold
            then foundflags:=foundflags OR LTestVidMemF
            else MsgConsole^.LogMsg(error,'Invalid usecVidMem value');
        end;
        if upstring(key)=upstring(LTest3DGames) then begin
          tmpsys^.usec3DGames:=strToInt(value);
          if tmpsys^.usec3DGames < usecThreshold
            then foundflags:=foundflags OR LTest3DGamesF
            else MsgConsole^.LogMsg(error,'Invalid usec3DGames value');
        end;
        if upstring(key)=upstring(Lbioscrc16) then begin
          tmpsys^.BIOSCRC16:=hexStrToLong(value);
          foundflags:=foundflags OR Lbioscrc16F;
        end;
        if upstring(key)=upstring(LScore) then begin
          tmpsys^.Score:=strToInt(value);
          foundflags:=foundflags OR LScoreF;
        end;
        if upstring(key)=upstring(LName) then begin
          tmpsys^.SetName(value);
          foundflags:=foundflags OR LNameF;
        end;
        if upstring(key)=upstring(Lcpu)
          then tmpsys^.SetCPU(value);
        if upstring(key)=upstring(Lcpuspeed) then begin
          foos:=value;
          {strip the MHz off the end}
          delete(foos,pos(#32,foos),length(foos));
          tmpsys^.MHz:=StrToReal(foos);
        end;
        if upstring(key)=upstring(Lvidsystem)
          then for vs:=MDA to VGA do
            if upstring(value)=VidSysLabels[vs]
              then tmpsys^.VideoSubsystem:=vs;
        if upstring(key)=upstring(Lvidadapter)
          then tmpsys^.SetVideoAdapter(value);
        if upstring(key)=upstring(LBIOSInfo)
          then tmpsys^.SetBIOS(value);
        if upstring(key)=upstring(Lbiosdate)
          then tmpsys^.BIOSDateNormalized:=strToInt(value);
        if upstring(key)=upstring(LDescription)
          then tmpsys^.SetDescription(value);
        if upstring(key)=upstring(LSubmitter)
          then tmpsys^.SetSubmitter(value);
      end;
    end;
  end;
  {end of inifile reached? Commit object}
  AttemptCommit;

  dispose(ini,done);
  dispose(fStatus,done);
end;

(*
Procedure PrintSystemList(s:PSystems);

  procedure CallPrint(machine:PSystem); far;
  begin
    with machine^ do
      writeln(UID^,',',name^,',',score);
    {machine^.print;}
  end;

begin { Print }
  Writeln('Systems printout:');
  s^.ForEach(@CallPrint);
end;
*)

Procedure SaveDatabase(s:PSystems;fn:string128);

var
  i:PINIFile;

  procedure CallWrite(machine:PSystem); far;
  begin
    with machine^ do begin
      mouse.hide;
      Screen.writeln(UID^+':'+name^);
      {mouse.show;}
      MsgConsole^.LogMsg(info,'Writing '+UID^+':'+name^+':'+inttostr(score));
      {Required fields:}
      i^.StartNewSection(UID^,Name^);
      i^.WriteKeyValue(LTestMem,inttostr(usecMemTest));
      i^.WriteKeyValue(LTestOpcodes,inttostr(usecOpcodes));
      i^.WriteKeyValue(LTestVidMem,inttostr(usecVidmem));
      i^.WriteKeyValue(LTestMemEA,inttostr(usecMemEA));
      i^.WriteKeyValue(LTest3DGames,inttostr(usec3DGames));
      i^.WriteKeyValue(LScore,inttostr(score));
      {Optional fields:}
      if CPU<>NIL then i^.WriteKeyValue(LCPU,CPU^);
      if MHz<>0 then i^.WriteKeyValue(LCpuSpeed,support.RealToStr(MHz)+mhzlabel);
      if BIOS<>NIL then i^.WriteKeyValue(LBIOSInfo,BIOS^);
      if BIOSDateNormalized<>DefaultDate then i^.WriteKeyValue(LBIOSDate,IntToStr(BIOSDateNormalized));
      if BIOSCRC16<>0 then i^.WriteKeyValue(LBIOSCRC16,hexword(BIOSCRC16));
      if VideoSubsystem in [MDA..VGA] then i^.WriteKeyValue(LVidSystem,VidSysLabels[VideoSubsystem]);
      if VideoAdapter<>NIL then i^.WriteKeyValue(LVidAdapter,VideoAdapter^);
      if Name<>NIL then i^.WriteKeyValue(LName,Name^);
      if Description<>NIL then i^.WriteKeyValue(LDescription,description^);
      if submitter<>NIL then i^.WriteKeyValue(LSubmitter,submitter^);
    end;
  end;

begin
  PrepFWindow('Saving to '+fn);

  {write('Save to what file? '); readln(ts); ts:=DBFilename;}

  new(PINIFile(i),init(fn,newfile,INIBufSize));
  if i <> NIL then begin
    i^.WriteComment('This file contains fingerprinting information about various computers for');
    i^.WriteComment('the TOPBENCH benchmark.  Hand-edit at your peril!');
    s^.ForEach(@CallWrite);
    dispose(i,Done);
  end else begin
    MsgConsole^.LogMsg(error,fn+' creation failed');
  end;

  dispose(fStatus,done);
end;

Procedure SaveDatabaseCSV(s:PSystems;fn:string128);

var
  ts:string;
  f:text;

  procedure CallWriteCSV(machine:PSystem); far;
  var
    tmps:string;

    procedure addbit(var tmps,newbit:string);
    begin
      tmps:=tmps+','+newbit;
    end;

  begin
    {again, with much, much terrible apologies about how crude this next
    section is.  When I have time to add polish, I'll rewrite how data
    passing is handled.}
    with machine^ do begin
      mouse.hide;
      Screen.writeln(Name^);
      {mouse.show;}
      tmps:=UID^;
      tmps:=tmps+','+'"'+Name^+'"';
      tmps:=tmps+','+inttostr(score);
      tmps:=tmps+','+inttostr(usecMemTest);
      tmps:=tmps+','+inttostr(usecOpcodes);
      tmps:=tmps+','+inttostr(usecVidmem);
      tmps:=tmps+','+inttostr(usecMemEA);
      tmps:=tmps+','+inttostr(usec3DGames);
      tmps:=tmps+','; if CPU<>NIL then tmps:=tmps+CPU^;
      tmps:=tmps+','; if MHz<>0 then tmps:=tmps+support.RealToStr(MHz);
      tmps:=tmps+','; if BIOS<>NIL then tmps:=tmps+'"'+BIOS^+'"';
      tmps:=tmps+','+IntToStr(BIOSDateNormalized);
      tmps:=tmps+','+hexword(BIOSCRC16);
      tmps:=tmps+','+VidSysLabels[VideoSubsystem];
      {we run the risk of exceeding 255 bytes here, so flush and continue}
      write(f,tmps);
      tmps:=','; if VideoAdapter<>NIL then tmps:=tmps+'"'+VideoAdapter^+'"';
      write(f,tmps);
      tmps:=','; if description<>NIL then tmps:=tmps+'"'+description^+'"';
      write(f,tmps);
      tmps:=','; if submitter<>NIL then tmps:=tmps+'"'+submitter^+'"';
      write(f,tmps);
    end;
    writeln(f);
  end;

begin
  PrepFWindow('Exporting to '+fn);
  assign(f,fn);
  rewrite(f);
  {write the column headers}
  ts:='UID,Name,Score,usecMemTest,usecOpcodes,usecVidMem,usecMemEA,usec3DGames,';
  ts:=ts+'CPU,MHz,BIOS Info,BIOS Date,BIOS CRC16,Video Subsystem,Video Adapter,Description,Submitter';
  writeln(f,ts);
  s^.ForEach(@CallWriteCSV);
  close(f);
  dispose(fStatus,done);
end;

Procedure repaintSysList(x1,y1,x2,y2,style:byte;centered:boolean;opttitle:string80;SysList:PSystems;curitem:word);
var
  startlist,endlist:integer;
  h:byte;
  w:word;
  mid:byte;
  tmpsys:PSystem;
  tmpScreen:PScreenOBJ;
  bf:byte;
begin
  h:=(y2-y1-2) {AND $FE};
  mid:=(h) div 2;
  startlist:=curitem;
  dec(startlist,mid); {this bit of idiocy is required to get around range check error}
  endlist:=curitem+mid;
  if endlist>SysList^.Count-1 then endlist:=SysList^.Count-1;
  if startlist+h>endlist
    then startlist:=endlist-h;
  if startlist<0 then startlist:=0;

  new(tmpScreen,init);
  with tmpScreen^ do begin
    save;
    {screen.resetwindow;}
    if opttitle='' then opttitle:='System List';
    TitledBox(x1,y1,x2,y2,
              LookTOT^.vmenuborder,LookTOT^.vmenutitle,LookTOT^.vmenuborder,
              style,opttitle);
    setwindow(x1+1,y1+1,x2-1,y2-1);
    for w:=0 to h do begin
      if w+startlist>SysList^.Count-1 then break; {protection from crash if not enough entries to print}
      tmpsys:=SysList^.At(w+startlist);
      if w+startlist=curitem
        then bf:=LookTOT^.vmenuhinorm
        else bf:=LookTOT^.vmenulonorm;
      if centered
        then WriteCenter(w+1,bf,tmpsys^.Name^)
        else WriteAt(1,w+1,bf,tmpsys^.Name^);
    end;
    resetwindow;
    display;
  end;
  dispose(tmpScreen,done);
end;

Procedure repaintSysInfo(x1,y1,x2,y2,style:byte;opttitle:string80;SysList:PSystems;curitem:word);
var
  tmpsys:PSystem;
  b:byte;
  lastrow:byte;
  tmpScreen:PScreenOBJ;

  procedure writewrap(x1,y1,width:byte;s:string);
  {there are several ways to skin this cat.  This particular way minimizes
  screen writes by advancing the current string position one width's worth,
  then going backwards looking for a space.  Once found, the string from
  the last found position to just before the space is written.}
  var
    lastcurpos,curpos,cury:word;
    b:byte;
    temps:string;
  begin
    if length(s)<width
      {if string width is under wrap threshold, just write it and exit}
      then tmpscreen^.writeplain(x1,y1,s)
      else begin
        curpos:=1; cury:=y1; lastcurpos:=1;
        while curpos<length(s) do begin
          inc(curpos,width);
          {if our next estimate blows past the length of the string,
          this is the last line to print}
          if curpos>length(s)
            then begin
              dec(curpos,width);
              temps:=copy(s,curpos+1,length(s)-curpos);
              tmpscreen^.writeplain(x1,cury,temps);
              break;
            end else begin
              {find the space and write curpos to it}
              for b:=curpos downto lastcurpos+1 do begin
                if s[b]=#32 then begin
                  curpos:=b;
                  {copy up to right before the space}
                  temps:=copy(s,lastcurpos,curpos-lastcurpos);
                  tmpscreen^.writeplain(x1,cury,temps);
                  lastcurpos:=curpos+1; {+1 skips the found space}
                  inc(cury);
                  break;
                end;
              end;
              {did we ever find a space?  if lastcurpos<>curpos+1, then no}
              if lastcurpos<>curpos+1 then begin
                {copy what we have anyway}
                temps:=copy(s,lastcurpos,curpos-1-lastcurpos);
                tmpscreen^.writeplain(x1,cury,temps);
                lastcurpos:=curpos;
                inc(cury);
                break;
              end;
            end;
        end;
      end;
  end;

const
  sm=11;
  us=14;

  function pad(s:string80):string80;
  var
    b:byte;
  begin
    for b:=length(s) to x2-x1-2 do s:=s+#32;
    pad:=s;
  end;

begin
  tmpsys:=SysList^.At(curitem);
  new(tmpscreen,init);
  with tmpScreen^ do begin
    save;
    gotoxy(1,1);
    {resetwindow;}
    TitledBox(x1,y1,x2,y2,
              LookTOT^.vmenuborder,LookTOT^.vmenutitle,LookTOT^.vmenuborder,
              style,opttitle);
    setwindow(x1+1,y1+1,x2-1,y2-1);
    lastrow:=y2-y1-1;
    {for debugging and layout:}
(*    for b:=1 to lastrow do writecenter(b,cnormal,inttostr(b));
    for b:=1 to x2-2 do begin
      writeat(b,lastrow-4,cnormal,inttostr(b mod 10));
      writeat(b,lastrow,cnormal,inttostr(b mod 10));
    end;*)

    writeat(1,1,LookTOT^.vmenutitle,'SCORE:');
    writeplain(8,1,inttostr(tmpsys^.score));

       writeat(us+(0*sm),1,LookTOT^.vmenutitle,'MemTest: ');
    writeplain(us+(0*sm),2,inttostr(tmpsys^.usecMemtest)+' æsec');
       writeat(us+(1*sm),1,LookTOT^.vmenutitle,'MemEA:   ');
    writeplain(us+(1*sm),2,inttostr(tmpsys^.usecMemEA)+' æsec');
       writeat(us+(2*sm),1,LookTOT^.vmenutitle,'Opcodes: ');
    writeplain(us+(2*sm),2,inttostr(tmpsys^.usecOpcodes)+' æsec');
       writeat(us+(3*sm),1,LookTOT^.vmenutitle,'VidMem:  ');
    writeplain(us+(3*sm),2,inttostr(tmpsys^.usecVidmem)+' æsec');
       writeat(us+(4*sm),1,LookTOT^.vmenutitle,'3DGames: ');
    writeplain(us+(4*sm),2,inttostr(tmpsys^.usec3DGames)+' æsec');
       writeat(us+(5*sm),1,LookTOT^.vmenutitle,'Total:   ');
    with tmpsys^ do
    writeplain(us+(5*sm),2,inttostr(
         usecMemtest+usecMemEA+usecOpcodes+usecVidmem+usec3DGames
         )+' æsec');

    writeat(1,3,LookTOT^.vmenutitle,'CPU:');
    writeplain(6,3,tmpsys^.CPU^);
    if tmpsys^.MHz<>0
      then writeplain(6+length(tmpsys^.CPU^),3,' @ '+realtostr(tmpsys^.MHz)+MHzLabel);

    writeat(1,4,LookTOT^.vmenutitle,'Video Adapter:');
    writeplain(16,4,vidsyslabels[tmpsys^.videosubsystem]);
    if length(tmpsys^.videoadapter^)>1
      then writeplain(16+length(vidsyslabels[tmpsys^.videosubsystem]),4,' ('+tmpsys^.videoadapter^+')');

    writeat(1,lastrow-8,LookTOT^.vmenutitle,'Submitter:');
    if length(tmpsys^.Submitter^)>1
      then begin
        writeplain(12,lastrow-8,tmpsys^.Submitter^);
      end;

    writeat(1,lastrow-7,LookTOT^.vmenuhihot,pad('BIOS Info:'));
    if length(tmpsys^.BIOS^)>1
      then begin
        writewrap(1,lastrow-6,x2-x1-1,tmpsys^.BIOS^);
      end;

    writeat(1,lastrow-4,LookTOT^.vmenuhihot,pad('Description:'));
    if length(tmpsys^.Description^)>1
      then begin
        writewrap(1,lastrow-3,x2-x1-1,tmpsys^.Description^);
      end;

    resetwindow;
    display;
  end;
  dispose(tmpscreen,done);
end;

Procedure repaintSysLine(y:byte;system:PSystem);
var
  b:byte;
  x1,y1,x2,y2:byte;
  lastrow:byte;
  tmpScreen:PScreenOBJ;

const
  sm=11;
  us=14;

begin
  new(tmpScreen,init);
  with tmpScreen^ do begin
    save;
    gotoxy(1,1);
    {resetwindow;}
    x1:=1;
    y1:=y;
    x2:=Monitor^.Width;
    y2:=y+3;
    TitledBox(x1,y1,x2,y2,
              LookTOT^.vmenuborder,LookTOT^.vmenutitle,LookTOT^.vmenuborder,
              0,'The current system...');
    setwindow(x1+1,y1+1,x2-1,y2-1);

    writeat(1,1,LookTOT^.vmenutitle,'SCORE:');
    writeplain(8,1,inttostr(system^.score));
       writeat(us+(0*sm),1,LookTOT^.vmenutitle,'MemTest: ');
    writeplain(us+(0*sm),2,inttostr(system^.usecMemtest)+' æsec');
       writeat(us+(1*sm),1,LookTOT^.vmenutitle,'MemEA:   ');
    writeplain(us+(1*sm),2,inttostr(system^.usecMemEA)+' æsec');
       writeat(us+(2*sm),1,LookTOT^.vmenutitle,'Opcodes: ');
    writeplain(us+(2*sm),2,inttostr(system^.usecOpcodes)+' æsec');
       writeat(us+(3*sm),1,LookTOT^.vmenutitle,'VidMem:  ');
    writeplain(us+(3*sm),2,inttostr(system^.usecVidmem)+' æsec');
       writeat(us+(4*sm),1,LookTOT^.vmenutitle,'3DGames: ');
    writeplain(us+(4*sm),2,inttostr(system^.usec3DGames)+' æsec');
       writeat(us+(5*sm),1,LookTOT^.vmenutitle,'Total:   ');
    with system^ do
    writeplain(us+(5*sm),2,inttostr(
         usecMemtest+usecMemEA+usecOpcodes+usecVidmem+usec3DGames
         )+' æsec');
    resetwindow;
    display;
  end;
  dispose(tmpScreen,done);
end;

Procedure repaintSysTimings(x1,y1,x2,y2,style:byte;hiflags:word;SysList:PSystems;curitem:word);
{like repaintSysInfo but only displays Score and each timing}
var
  tmpsys:PSystem;
  b:byte;
  lastrow:byte;
  tmpScreen:PScreenOBJ;
  col,labelcol,normcol,wincol:byte;

const
  sm=10;
  us=1;

begin
  tmpsys:=SysList^.At(curitem);
  new(tmpScreen,init);
  with tmpScreen^ do begin
    save;
    gotoxy(1,1);
    {resetwindow;}
    TitledBox(x1,y1,x2,y2,
              LookTOT^.vmenuborder,LookTOT^.vmenutitle,LookTOT^.vmenuborder,
              style,'System Details:');
    setwindow(x1+1,y1+1,x2-1,y2-1);
    lastrow:=y2-y1-1;
    {for debugging and layout:}
    (*for b:=1 to lastrow do writecenter(b,cnormal,inttostr(b));
    for b:=1 to x2-2 do begin
      writeat(b,lastrow-4,cnormal,inttostr(b mod 10));
      writeat(b,lastrow,cnormal,inttostr(b mod 10));
    end;*)
    labelcol:=LookTOT^.vmenulonorm;
    wincol:=LookTOT^.vmenulohot;
    normcol:=labelcol;
    col:=normcol;

    writeat(1,1,labelcol,'SCORE:');
    if hiflags AND $01=1 then col:=wincol else col:=normcol; hiflags:=hiflags SHR 1;
    writeat(sm,1,col,inttostr(tmpsys^.score)); col:=normcol;

    writeat(1,2,labelcol,'MemTest: ');
    if hiflags AND $01=1 then col:=wincol else col:=normcol; hiflags:=hiflags SHR 1;
    writeat(sm,2,col,inttostr(tmpsys^.usecMemtest)+' æsec'); col:=normcol;

    writeat(1,3,labelcol,'MemEA:   ');
    if hiflags AND $01=1 then col:=wincol else col:=normcol; hiflags:=hiflags SHR 1;
    writeat(sm,3,col,inttostr(tmpsys^.usecMemEA)+' æsec'); col:=normcol;

    writeat(1,4,labelcol,'Opcodes: ');
    if hiflags AND $01=1 then col:=wincol else col:=normcol; hiflags:=hiflags SHR 1;
    writeat(sm,4,col,inttostr(tmpsys^.usecOpcodes)+' æsec'); col:=normcol;

    writeat(1,5,labelcol,'VidMem:  ');
    if hiflags AND $01=1 then col:=wincol else col:=normcol; hiflags:=hiflags SHR 1;
    writeat(sm,5,col,inttostr(tmpsys^.usecVidmem)+' æsec'); col:=normcol;

    writeat(1,6,labelcol,'3DGames: ');
    if hiflags AND $01=1 then col:=wincol else col:=normcol; hiflags:=hiflags SHR 1;
    writeat(sm,6,col,inttostr(tmpsys^.usec3DGames)+' æsec'); col:=normcol;

    writeat(1,7,labelcol,'Total:   ');
    if hiflags AND $01=1 then col:=wincol else col:=normcol; hiflags:=hiflags SHR 1;
    with tmpsys^ do
    writeat(sm,7,col,inttostr(
         usecMemtest+usecMemEA+usecOpcodes+usecVidmem+usec3DGames
         )+' æsec'); col:=normcol;

    writeat(1,8,labelcol,'CPU:');
    writeat(6,8,col,tmpsys^.CPU^);
    if tmpsys^.MHz<>0
      then writeat(6+length(tmpsys^.CPU^),8,col,' @ '+realtostr(tmpsys^.MHz)+MHzLabel);

    writeat(1,9,labelcol,'Video Adapter:');
    writeat(16,9,col,vidsyslabels[tmpsys^.videosubsystem]);
    if length(tmpsys^.videoadapter^)>1
      then writeat(16+length(vidsyslabels[tmpsys^.videosubsystem]),9,col,' ('+tmpsys^.videoadapter^+')');
    (*
    writeat(1,lastrow-8,LookTOT^.vmenutitle,'Submitter:');
    if length(tmpsys^.Submitter^)>1
      then begin
        writeplain(12,lastrow-8,tmpsys^.Submitter^);
      end;
    *)
    resetwindow;
    display;
  end;
  dispose(tmpScreen,done);
end;

Function EditSystem(whichlist:PSystems;whichsys:word;cancelallowed:boolean):boolean;
{pop up a form with the system fully populated and allow user to edit}
var
  x1,y1,x2,y2:byte;

  editwin:{Move}PWinOBJ;
  tmpsys:psystem;
  k:word;x,y:byte;
  {field objects:}
  fName:LateralIOOBJ;
  fCPU:LateralIOOBJ;
  fMHz:RealIOOBJ;
  fVideoSubsystem:RadioIOOBJ;
  fVideoAdapter:LateralIOOBJ;
  fBIOS:LateralIOOBJ;
  fDescription:LateralIOOBJ;
  fSubmitter:StringIOOBJ;
  fKeys:ControlkeysIOOBJ;
  fOK,fCancel:Strip3dIOOBJ;

  manager:FormOBJ;
  result:tAction;
  vsys:videosystems;

const
  fwidth=70;
  fheight=16;
  fstart=5;
  ftab:byte=16+5;
  maxs=254;
  fhtab:byte=3;
  mtab:byte=5;

begin
  x1:=(monitor^.width div 2)-(fwidth div 2);
  y1:=(monitor^.depth div 2)-(fheight div 2);
  x2:=(monitor^.width div 2)+(fwidth div 2);
  y2:=(monitor^.depth div 2)+(fheight div 2);

  mtab:=x1;
  ftab:=mtab+16;
  fhtab:=y1;

  tmpsys:=whichlist^.at(whichsys);
  fKeys.init;
  with fName do begin
    init(ftab,fhtab+1,fwidth-ftab+4,128);
    SetLabel('System');
    SetMessage(mtab+1,fhtab+fheight-1,'Enter system name');
    if length(tmpsys^.Name^)>1 then SetValue(tmpsys^.Name^);
    SetIns(true);
  end;
  with fCPU do begin
    init(ftab,fhtab+2,28,60);
    SetLabel('CPU');
    SetMessage(mtab+1,fhtab+fheight-1,'Enter CPU');
    if length(tmpsys^.CPU^)>1 then SetValue(tmpsys^.CPU^);
    SetIns(true);
  end;
  with fMHZ do begin
    init(ftab+31,fhtab+2,8);
    SetLabel('@');
    SetMessage(mtab+1,fhtab+fheight-1,'Enter CPU speed in MHz (fractional ok, like 4.77)');
    SetValue(tmpsys^.MHz);
  end;
  with fBIOS do begin
    init(ftab,fhtab+3,fwidth-ftab+4,maxs);
    SetLabel('BIOS');
    SetMessage(mtab+1,fhtab+fheight-1,'You can correct mangled BIOS copyright guesses here');
    if length(tmpsys^.BIOS^)>1 then SetValue(tmpsys^.BIOS^);
    SetIns(true);
  end;
  with fDescription do begin
    init(ftab,fhtab+4,fwidth-ftab+4,maxs);
    SetLabel('Description');
    SetMessage(mtab+1,fhtab+fheight-1,'(Optional) Enter a short description of the system');
    if length(tmpsys^.Description^)>1 then SetValue(tmpsys^.Description^);
    SetIns(true);
  end;
  with fSubmitter do begin
    init(ftab,fhtab+5,fwidth-ftab+4);
    SetLabel('Submitter');
    SetMessage(mtab+1,fhtab+fheight-1,'(Optional) Enter the person/handle/email who contributed this entry');
    if length(tmpsys^.Submitter^)>1 then SetValue(tmpsys^.Submitter^);
    SetIns(true);
  end;
  with fVideoSubsystem do begin
    init(mtab+2,fhtab+8,12,5,'Video System');
    SetMessage(mtab+1,fhtab+fheight-1,'Pick the basic video subsystem from the list');
    for vsys := mda to vga do
      additem(Vidsyslabels[vsys],0,(tmpsys^.videosubsystem=vsys));
  end;
  with fVideoAdapter do begin
    init(ftab,fhtab+7,fwidth-ftab+4,maxs);
    SetLabel('Video Adapter');
    SetMessage(mtab+1,fhtab+fheight-1,'Enter the exact video adapter');
    if length(tmpsys^.VideoAdapter^)>1 then SetValue(tmpsys^.VideoAdapter^);
    SetIns(true);
  end;

  fok.Init(fwidth-15,fhtab+fheight-4-2,    '   ~O~K   ',Finished);
  fok.SetHotKey(280); {Alt-O}
  fcancel.Init(fwidth-15,fhtab+fheight-2-2,' ~C~ancel ',Escaped);
  fcancel.SetHotKey(302); {Alt-C}
  new(editwin,init);
  with editwin^ do begin
    SetSize(
      (monitor^.width div 2)-(fwidth div 2),(monitor^.depth div 2)-(fheight div 2),
      (monitor^.width div 2)+(fwidth div 2),(monitor^.depth div 2)+(fheight div 2),1
    );
    setTitle('Editing System '+tmpsys^.UID^);
    draw;
    with manager do begin
      init;
      additem(fKeys);
      additem(fName);
      additem(fCPU);
      additem(fMHz);
      additem(fBIOS);
      additem(fDescription);
      additem(fSubmitter);
      additem(fVideoAdapter);
      additem(fVideoSubsystem);
      additem(fok);
      if cancelallowed then additem(fcancel);
      screen.resetwindow;
      screen.writeat(60,fhtab+2,LookTOT^.vwintitle,MHzLabel);
      {mouse support makes sense for this section, so we'll turn it on}
      Mouse.SetForceOff(false);
      mouse.show;
      {do the form}
      Result:=go;
      {turn mouse support back off}
      mouse.hide;
      Mouse.SetForceOff(true);
      case result of
        Finished:begin
          with tmpsys^ do begin
            {update object with fields}
            setname(fName.getvalue);
            setsubmitter(fsubmitter.getvalue);
            setdescription(fdescription.getvalue);
            setCPU(fCPU.getvalue);
            setBIOS(fBIOS.getvalue);
            setvideoadapter(fvideoadapter.getvalue);
            videosubsystem:=videosystems(fvideosubsystem.getvalue);
            MHz:=fMHz.getvalue;
            DBDirty:=true;
          end;
          MsgConsole^.logmsg(info,'User committed changes to '+tmpsys^.UID^);
          EditSystem:=true;
        end;
        Escaped:begin
          MsgConsole^.logmsg(info,'User aborted changes to '+tmpsys^.UID^);
          EditSystem:=false;
        end;
      end;
      done;
    end;
  end;
  dispose(editwin,done);
  {moronic form manager does NOT call added objects' done method!
  must do it ourselves!}
  fKeys.done;
  fName.done;
  fCPU.done;
  fMHz.done;
  fBIOS.done;
  fDescription.done;
  fSubmitter.done;
  fVideoAdapter.done;
  fVideoSubsystem.done;
  fok.done;
  if cancelallowed then fcancel.done;
end;

Procedure RealtimeCompare;
{
Performs a realtime topscore and compares the result to what's in the
database.  A binary search is done to get "close", then a distance calc
is performed to get closer.  No smoothing is performed.
}
const
  {windows heights and sizes}
  bstart=1+4;
  istart:byte=25;
  bheight:byte=10;
  iheight=13;
  ch:char=#0;

var
  closest:integer;
  tmpsys,trysys:PSystem;
  found:boolean;
  mindist,oldmindist:longint;
  startidx,endidx,idx,minidx:integer;

  function SysDistance(sys1,sys2:PSystem):longint;
  {
  Very simple euclidean distance function (I never took statistics, hope
  that's right!) that outputs the "distance" in microsecond timings
  between two systems.  This function is simple, but it does the job.
  }
  var
    a,b:integer; {change to :word and the bug described below also surfaces}
    l:longint;
    {these variables and inefficient process below is because I discovered
    a bug in Turbo Pascal developing this program, where TP was incorrectly
    typcasting a signed longint result into various places.  Uncomment
    the last block of this function if you want to see the bug in action.
    The bug is probably related to TP's 386 longint routines, but not sure.}
  begin
    l:=0;
    a:=sys1^.usecMemTest; b:=sys2^.usecMemTest; inc(l,abs(a-b));
    a:=sys1^.usecMemEA;   b:=sys2^.usecMemEA;   inc(l,abs(a-b));
    a:=sys1^.usecOpcodes; b:=sys2^.usecOpcodes; inc(l,abs(a-b));
    a:=sys1^.usecVidMem;  b:=sys2^.usecVidMem;  inc(l,abs(a-b));
    a:=sys1^.usec3DGames; b:=sys2^.usec3DGames; inc(l,abs(a-b));
    SysDistance:=l;

    (*SysDistance:=(
      abs(sys1^.usecMemTest - sys2^.usecMemTest)+
      abs(sys1^.usecMemEA   - sys2^.usecMemEA)+
      abs(sys1^.usecOpcodes - sys2^.usecOpcodes)+
      abs(sys1^.usecVidMem  - sys2^.usecVidMem)+
      abs(sys1^.usec3DGames - sys2^.usec3DGames)
    );*)
  end;

  Procedure RepaintRealtime;
  begin
    repaintSysLine(1,tmpsys);
    repaintSysList(1,bstart,Monitor^.Width,bheight,
                   0,true,' ...matches the following entry in the database: ',Systems,closest);
    repaintSysInfo(1,istart-1,Monitor^.Width,istart+iheight,2,' Matched system detail: ',Systems,closest);
  end;

begin
  istart:=Monitor^.Depth-iheight-1;
  bheight:=istart-2;
  closest:=1;
  {curSys:=SystemList^.Count-1;}
  MakeNewSystem(tmpsys);
  {$IFNDEF DEBUG}
  Screen.WriteAT(1,monitor^.depth,chigh,'Adjust your machine or emulator to see the results change realtime.  ESC exits.');
  {$ENDIF}
  repeat
    if _sound then sound(14000);
    tmpsys^.usecMemTest:=testmemoryblockops;
    tmpsys^.usecMemEA  :=testmemEA;
    tmpsys^.usecOpcodes:=testCPUOpcodes;
    tmpsys^.usecVidMem :=testVideoAdapterWrites;
    tmpsys^.usec3DGames:=test3DGames;
    if _sound then nosound;
    tmpsys^.score:=topscore;
    tmpsys^.BIOSCRC16:=WhatBIOSCRC16;
    {Perform binary search to see if we have an exact match in the database}
    found:=Systems^.search(tmpsys,closest);
    {$IFDEF DEBUG}
    if closest<Systems^.Count
      then screen.writeat(36,25,$07,'Bins. at idx '+inttostr(closest)
        +' score '+inttostr(PSystem(Systems^.at(closest))^.Score)
        +' (this: '+inttostr(tmpsys^.Score)+'   ');
    {$ENDIF}
    {If we didn't find it, we'll use the closest system to fine-tune the
    results.  Euclidean distance is used against each metric component.}
    if not found then begin
      {set up search range and vars}
      startidx:=closest-_searchdistance; if startidx<1 then startidx:=1;
      endidx:=closest+_searchdistance; if endidx>=Systems^.Count then endidx:=Systems^.Count-1;
      oldmindist:=$ffff*5; minidx:=closest;
      {for each system in the range, find the minimum distance}
      for idx:=startidx to endidx do begin
        trysys:=Systems^.at(idx);
        mindist:=SysDistance(tmpsys,trysys);
        if mindist<oldmindist then begin
          minidx:=idx;
          oldmindist:=mindist;
        end;
      end;
      {reset list index to closest one}
      closest:=minidx;
    end;
    repaintRealtime;
    {$IFDEF DEBUG}
    if found
      then screen.writeat(1,25,$07,'Exact match at idx '+inttostr(closest)
             +' score '+inttostr(PSystem(Systems^.at(closest))^.Score)+'  ')
      else screen.writeat(1,25,$07,'Dist. match at idx '+inttostr(closest)
             +' score '+inttostr(PSystem(Systems^.at(closest))^.Score)+'  ');
    {$ENDIF}
    if support.keypressed then ch:=readkeychar;
  until ch=#27;
  ch:=#0;
  dispose(tmpsys,done);
end;

Procedure DeleteSystem(whichlist:PSystems;whichsys:word);
{deletes a system.  Must be very careful to delete from both lists,
first the sorted one which doesn't delete anything, then from the main
one which does.}
var
  tmpsys:PSystem;
  sysindex:word;
begin
  if whichlist^.Count<2 then begin
    MsgConsole^.LogMsg(error,'Delete aborted (must have at least one system in the database)');
    exit;
  end;
  {mark database as dirty.  If we get an error trying to delete an object,
  mark it back as clean because we don't want the user overwriting their
  database on disk with a mangled version!}
  DBDirty:=true;
  {get the object we need to remove}
  tmpsys:=whichlist^.at(whichsys);
  {remove from sortedbyname collection}
  sysindex:=SystemsByName^.IndexOf(tmpsys);
  if sysindex<>-1
    then begin
      SystemsByName^.atDelete(sysindex);
      MsgConsole^.LogMsg(info,tmpsys^.UID^+' removed from ByName');
    end
    else begin
      MsgConsole^.LogMsg(error,tmpsys^.UID^+' not found in ByName?');
      {forcably mark database as "clean" so that user isn't tricked into
      writing mangled data back to disk}
      DBDirty:=false;
      exit; {get out of here, we already had a fatal error}
    end;
  {remove from system collection and then destroy object}
  sysindex:=Systems^.IndexOf(tmpsys);
  if sysindex<>-1
    then begin
      MsgConsole^.LogMsg(info,'Destroying '+tmpsys^.UID^+' from Systems...');
      Systems^.atFree(sysindex);
      {MsgConsole^.LogMsg(info,'Done.');}
    end
    else MsgConsole^.LogMsg(error,tmpsys^.UID^+' not found in Systems?');
end;



Procedure SystemBrowser(SystemList:PSystems);
{
The system browser.  Intended functionality is a list of systems up top,
with a viewable window below.  User should be able to hit a key for editing
a system and DEL for deleting a system.

A collection of systems sorted by name is created for this section and
disposed of when we leave.
}
const
  {windows heights and sizes}
  bstart=1;
  istart:byte=25;
  bheight:byte=10;
  iheight=13;

var
  w:word;
  oldcur,cursys:integer;

  Procedure RepaintBoth;
  begin
    repaintSysList(1,bstart,Monitor^.Width,bheight,1,false,'',SystemList,curSys);
    repaintSysInfo(1,istart-1,Monitor^.Width,istart+iheight,2,'System Details:',SystemList,curSys);
  end;

begin
  istart:=Monitor^.Depth-iheight-1;
  bheight:=istart-2;
  curSys:=0;
  {curSys:=SystemList^.Count-1;}
  Screen.WriteAT(1,monitor^.depth,chigh,'Browse the list using movement keys; DEL to delete or ENTER to edit a system');
  repaintBoth;
  repeat
    oldcur:=cursys;
    case Key.Getkey of
    {del}339:begin
      DeleteSystem(SystemList,cursys);
      if cursys=SystemList^.Count
        then dec(cursys);
    end;
    {ent} 13:begin
      EditSystem(SystemList,cursys,true);
      {if user hit ESC to abort editing, absorb the key so it doesn't get passed to the system viewer}
      if Key.lastkey=27 then inc(key.vlastkey);
    end;
    {up} 328:dec(cursys);
    {dwn}336:inc(cursys);
    {pgu}329:dec(cursys,bheight-2);
    {pgd}337:inc(cursys,bheight-2);
    {hom}327:cursys:=0;
    {end}335:cursys:=Systems^.Count-1;
    end;
    {if user moved:}
    If oldcur<>cursys then begin
      {enforce bounds checking on current list position}
      if cursys>SystemList^.Count-1 then cursys:=SystemList^.Count-1;
      if cursys<0 then cursys:=0;
    end;
    {repaint screen}
    repaintBoth;
  until Key.Lastkey=27;
end;

Procedure CompareSystems(SystemList:PSystems);
{
Allows the user to choose any two systems and see them compared by speed.
"Winners" of the comparison are highlighted (score and timing numbers)
}
const
  {windows heights and sizes}
  bheight:byte=11;

var
  w:word;
  cursys:array[0..1] of integer;
  active:byte;
  compresult:integer;
  s:string80;

  Procedure RepaintQuadrants;
  var
    hflags:array[0..1] of word;
    tmpsys:array[0..1] of PSystem;
    tusec:array[0..1] of word;
    b:byte;
  const
    fscore  =$01;
    fMemTest=$02;
    fMemEA  =$04;
    fOpcodes=$08;
    fVidMem =$10;
    f3DGames=$20;
    fTotal  =$40;

  begin
    bheight:=(Monitor^.Depth - 3) div 2;
    for b:=0 to 1 do begin
      hflags[b]:=0; tusec[b]:=0;
    end;
    for b:=0 to 1 do tmpsys[b]:=SystemList^.at(cursys[b]);
    compresult:=Systems^.Compare(tmpsys[0],tmpsys[1]);
    case compresult of
      -1:begin
        s:=#32#32#25#25#25#25#25#25#25#25#25#25' Faster '#25#25#25#25#25#25#25#25#25#25#32#32;
      end;
      0:begin
        s:='  ÄÄÄÄÄÄÄÄÄÄ  Same  ÄÄÄÄÄÄÄÄÄÄ  ';
      end;
      1:begin
        s:=#32#32#24#24#24#24#24#24#24#24#24#24' Faster '#24#24#24#24#24#24#24#24#24#24#32#32;
      end;
    end;

    {build total usecs}
    for b:=0 to 1 do with tmpsys[b]^ do tusec[b]:=usecmemtest+usecmemea+usecopcodes+usecvidmem+usec3dgames;
    for b:=0 to 1 do begin
      if tmpsys[b]^.score       > tmpsys[b xor 1]^.score       then hflags[b]:=hflags[b] OR fscore;
      if tmpsys[b]^.usecmemtest < tmpsys[b xor 1]^.usecmemtest then hflags[b]:=hflags[b] OR fmemtest;
      if tmpsys[b]^.usecmemea   < tmpsys[b xor 1]^.usecmemea   then hflags[b]:=hflags[b] OR fmemea;
      if tmpsys[b]^.usecopcodes < tmpsys[b xor 1]^.usecopcodes then hflags[b]:=hflags[b] OR fopcodes;
      if tmpsys[b]^.usecvidmem  < tmpsys[b xor 1]^.usecvidmem  then hflags[b]:=hflags[b] OR fvidmem;
      if tmpsys[b]^.usec3dgames < tmpsys[b xor 1]^.usec3dgames then hflags[b]:=hflags[b] OR f3dgames;
      if  tusec[b]              <  tusec[b xor 1]              then hflags[b]:=hflags[b] OR ftotal;
    end;

    repaintSysList(1,1,(Monitor^.Width div 2),bheight,
      (active xor 1)+1,false,'',SystemList,curSys[0]);
    repaintSystimings((Monitor^.Width div 2)+1,1,Monitor^.Width,bheight,
      (active xor 1)+1,hflags[0],SystemList,curSys[0]);

    repaintSysList(1,Monitor^.Depth-1-bheight,(Monitor^.Width div 2),Monitor^.Depth-1,
      active+1,false,'',SystemList,curSys[1]);
    repaintSystimings((Monitor^.Width div 2)+1,Monitor^.Depth-1-bheight,Monitor^.Width,Monitor^.depth-1,
      active+1,hflags[1],SystemList,curSys[1]);

    {Place WINNER bar onscreen}
    screen.writecenter(Monitor^.Depth div 2,LookTOT^.vmenutitle,s);
  end;

begin
  for active:=1 downto 0 do cursys[active]:=0;
  {curSys:=SystemList^.Count-1;}
  screen.clear($07,#32);
  Screen.WriteAT(1,monitor^.depth,chigh,
  'Use TAB to switch between system lists. Browse either list using movement keys.');

  repeat
    {repaint screen}
    repaintQuadrants;
    case Key.Getkey of
    {tab}  9:active:=active xor 1;
    {up} 328:dec(cursys[active]);
    {dwn}336:inc(cursys[active]);
    {pgu}329:dec(cursys[active],bheight-2);
    {pgd}337:inc(cursys[active],bheight-2);
    {hom}327:cursys[active]:=0;
    {end}335:cursys[active]:=Systems^.Count-1;
    end;
    {enforce bounds checking on current list position}
    if cursys[active]>SystemList^.Count-1 then cursys[active]:=SystemList^.Count-1;
    if cursys[active]<0 then cursys[active]:=0;
  until Key.Lastkey=27;
end;

Procedure initTOPB;
var
  fname:string128;
  actloop:userActions;
  w:word;

begin
  writeln(FullBanner);
  {if upstring(paramstr(1))='STARBENCH' then StarBench;}
  if is_param('?') or is_param('h') then begin
    writeln('Command-line options:');
    writeln('  -?,-h    This help message');
    writeln('  -c       Attempt setting "condensed" mode on VGA and EGA systems');
    writeln('  -q       Turn off sound in the realtime benchmarking section');
    writeln('  -s       Skip some of the more volatile detection tests');
    writeln('  -d#      Specify realtime benchmark search distance (default: '+inttostr(_searchdistance)+')');
    writeln('  -i       Profile this machine, print Score, then immediately exit');
    halt(10);
  end;
  if is_param('c') then begin
    Monitor^.SetCondensed;
    {reset mouse so that it picks up new dimensions}
    mouse.done;
    mouse.init;
  end;
  if is_param('q') then _sound:=false;
  if is_param('s') then _skiptests:=true;
  if is_param('i') then begin
    writeln('TOPBENCH Score of this machine: ',TopScore);
    halt(4);
  end;
  if param_int('d')<>0 then _searchdistance:=param_int('d');

  {I don't want any mouse support for majority of program -- it's slightly
  buggy and adds nothing}
  {Key.SetMouseMethod(0);}
  Mouse.SetForceOff(true);
  {actually, we'll have mouse support but only for form editing}

  {init message console}
  new(MsgConsole,init);

  {grab amount of mem for memory leak detection}
  mematstart:=memavail;

  new(MainMenu,init);
  with MainMenu^ do begin
    SetStyleTitle(6,'The Oldskool PC Benchmark');
    SetMessageXY(1,Monitor^.Depth);
    for actloop:=mIntro to mAbout do begin
      with mainmenuLookup[actLoop] do begin
        case actLoop of
          mBenchMenu:AddFullItem(strpas(title),ord(id),mhk,strpas(blurb),@BenchMenu);
          mDBMenu:AddFullItem(strpas(title),ord(id),mhk,strpas(blurb),@DBMenu);
        else
          AddFullItem(strpas(title),ord(id),mhk,strpas(blurb),nil);
        end;
      end;
    end;
  end;

  with BenchMenu do begin
    init;
    SetStyleTitle(3,'Benchmarking');
    SetMessageXY(1,Monitor^.Depth);
    for actloop:=mRealtime to mCompare do with BenchMenuLookup[actLoop] do
      AddFullItem(strpas(title),ord(id),mhk,strpas(blurb),nil);
  end;

  with DBMenu do begin
    init;
    SetStyleTitle(3,'Database Ops');
    SetMessageXY(1,Monitor^.Depth);
    for actloop:=mAdd to mExport do with DBMenuLookup[actLoop] do
      AddFullItem(strpas(title),ord(id),mhk,strpas(blurb),nil);
    SetStatus(ord(mSave),false);
  end;

  Screen.Clear(tWhite,'°'); {paint the screen}
  Screen.PartClear(1,Monitor^.Depth,Monitor^.Width,Monitor^.Depth,TWhite,' '); {prepare status line}

  Systems:=New(PSystems, Init(256, 16));
  {load the existing database}
  fname:=DBFilename;
  MsgConsole^.LogMsg(info,'Attempting to import: '+fname);
  if not fileexists(fname)
    then MsgConsole^.LogMsg(error,'Database file '+fname+' not found.')
    else ImportSystemFile(fname);
end;

Procedure doTOPB;
var
  MenuChoice:byte;
  SaveScreen:PScreenOBJ;
  menuaction,loop:userActions;
  Result:tAction;
  temps:string;
  lastslash:byte;
  DirInfo:SearchRec;
  dir:string128;
  tmpsys:PSystem;
  oldDBDirty:boolean;

  Procedure BuildAlternateSorts;
  var
    w:word;
  begin
    {build up sorted by name collection}
    New(SystemsByName, Init(256, 16));
    SystemsByName^.Duplicates:=true;
    for w:=0 to Systems^.Count-1 do
      SystemsByName^.Insert(Systems^.at(w));
  end;

  Procedure DestroyAlternateSorts;
  begin
    Dispose(SystemsByName,done);
  end;

begin
  DBDirty:=false; {after first import, DB is clean}
  repeat
    {DBMenu.SetStatus(ord(mSave),DBDirty);} {only works with pulldown menus}
    MenuChoice:=MainMenu^.Activate;
    new(SaveScreen,init);
    SaveScreen^.save; {save current screen}
    Screen.resetwindow;

    case userActions(MenuChoice) of
      mnull:begin end; {user hit escape or something}
      mBrowseName:begin
        if Systems^.Count>0 then begin
          BuildAlternateSorts;
          SystemBrowser(SystemsByName);
          DestroyAlternateSorts;
        end else PopUserMessage(warning,'Cannot browse an empty database!  Add a system first?');
      end;
      mBrowseSpeed:begin
        if Systems^.Count>0 then begin
          BuildAlternateSorts;
          SystemBrowser(Systems);
          DestroyAlternateSorts;
        end else PopUserMessage(warning,'Cannot browse an empty database!  Add a system first?');
      end;
      mRealTime:if Systems^.Count>1
        then RealtimeCompare
        else PopUserMessage(warning,'Need more than one database entry for this to be useful.');
      mCompare:begin
        if Systems^.Count>1 then begin
          BuildAlternateSorts;
          CompareSystems(SystemsByName);
          DestroyAlternateSorts;
        end
        else PopUserMessage(warning,'Need more than one database entry for this to be useful.');
      end;
      mAbout:PopAbout;
      mConsole:begin
        MsgConsole^.show;
        readkeychar;
        MsgConsole^.hide;
      end;
      mImport:begin
        temps:=PromptForFilename('Enter the path+file to import.  Wildcards ok.');
        if temps<>'' then begin
          if pos('*',temps)<>0 then begin
            {wildcard!  Loop through it!}
            for lastslash:=length(temps) downto 1 do
              if temps[lastslash]='\' then break;
            dir:=copy(temps,1,lastslash);
            FindFirst(temps, Archive, DirInfo);
            while DosError = 0 do begin
              ImportSystemFile(dir+DirInfo.Name);
              FindNext(DirInfo);
            end;
          end else ImportSystemFile(temps);
        end;
      end;
      mSave:begin
        if not DBreadonly then begin
          if Systems^.Count>0 then begin
            SaveDatabase(Systems,DBFileName);
            DBDirty:=false;
          end
          else
            PopUserMessage(warning,'Cannot save an empty database.  Add a system first?');
        end
        else
          PopUserMessage(warning,'Database read-only; only partially loaded due to lack of RAM.');
      end;
      mSetup:PopUserMessage(info,' User settings are controlled via command-line switches. Use -? for help. ');
      mExport:begin
        if Systems^.Count>0 then begin
          temps:=PromptForFilename('Enter the path+file to export to a .CSV file.');
          SaveDatabaseCSV(Systems,temps)
        end else PopUserMessage(warning,'Cannot export an empty database.  Add a system first?');
      end;
      mIntro:PopIntro;
      mAdd:begin
        oldDBDirty:=DBDirty;
        MakeNewSystem(tmpsys);
        DetectSystem(tmpsys);
        CommitSystem(tmpsys);
        if tmpsys=nil
          then PopUserMessage(warning,'System commit was rejected; is it already in the database?')
          else begin
            buildAlternateSorts;
            if not EditSystem(Systems,Systems^.IndexOf(tmpsys),true)
              then begin
                deletesystem(Systems,Systems^.IndexOf(tmpsys));
                {User aborted their new system edit, so restore whatever
                dirty state existed before they started}
                DBDirty:=oldDBDirty;
              end;
            destroyAlternateSorts;
          end;
      end;
    else
      PopUserMessage(warning,'Somehow you managed to find non-implemented menu #'+inttostr(menuChoice)+'!');
    end; {case}

    SaveScreen^.Display;
    dispose(SaveScreen,done);
  until MenuChoice=0;
  LookTOT^.SetDefaults;
  if DBDirty and not DBreadonly
    then if PromptYN(' Database has been changed; save it? ')
      then SaveDatabase(Systems,DBFileName);
end;

Procedure doneTOPB;
begin
  dispose(MainMenu,done);
  BenchMenu.done;
  DBMenu.done;
  Screen.Clear(TLightGray,' ');

  Dispose(Systems,done);

  if memavail<>mematstart
    then MsgConsole^.LogMsg(warning,'Memory leak of '+inttostr(mematstart-memavail)+' bytes at exit.');
  Dispose(MsgConsole,done);
end;

begin
  initTOPB;
  doTOPB;
  doneTOPB;
end.