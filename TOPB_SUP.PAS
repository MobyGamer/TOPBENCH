{$O+,F+}
unit topb_support;
{Various TOPBENCH support routines and classes, such as the debug message
log, various user pop-up alerts, etc.  Done in an effort to get more
non-critical stuff thrown into the overlay system so I have more RAM
to debug in.}

interface

uses
  objects,

  topb_constants,
  topb_detect,
  topb_datastructures,

  totfast,
  totsys,
  totmsg,
  totWIN,
  totIO1,
  totIO2,

  strings,
  m6845ctl,
  m320_640,
  ztimer,
  support,
  btsuites;

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

var
  MsgConsole:PMConsole;
  FStatus:PWinOBJ;
  tmpScreen:PScreenOBJ; {used for all the repaint* procedures}

Procedure Starbench;
Procedure PopUserMessage(class:messagetype;s:string80);
Procedure PopSetupMessage;
Procedure PopAbout;
Function PromptYN(msg:string80):boolean;
Function PromptForFilename(blurb:string80):string128;
Procedure PrepFWindow(title:string80);

implementation

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

Procedure StarBench;
{
A silly idea I had two decades ago that would make a nice easter egg.
ScreenX = ScreenDist * Xpos / Zpos
ScreenY = ScreenDist * Ypos / Zpos
  screendist=256;
}
type
  startype=record
    x,y,z,scnx,scny,oldscnx,oldscny,speed:integer;
  end;
const
  maxfound:word=3;
  maxram=(64*1024) - 16;
  maximum=maxram div sizeof(startype);
  maxdist=(4*256)-1;
  maxspeed=5;
  scnwidth=640;
  scnheight=200;
  maxx=scnwidth-1;
  maxy=scnheight-1;
  midx=(scnwidth div 2)-1;
  midy=(scnheight div 2)-1;
  cols:array[0..3] of byte=(3,3,1,2);
  foundmax:boolean=false;
  fps=60;
type
  PStarray=^TStarray;
  TStarray=array[0..maximum-1] of startype;
var
  stars:PStarray;
  w:word;
  ch:char;

begin
  if WhatVideoSubsystem='MDA' then begin
    writeln('Sorry, but starbenching requires CGA or higher.');
    halt(2);
  end;
  writeln('Initializing universe...');
  if maxavail<sizeof(TStarray) then begin
    writeln('Not enough memory!');
    halt(2);
  end;
  getmem(stars,sizeof(TStarray));
  RandSeed:=1;
  for w:=0 to maximum-1 do with stars^[w] do begin
    repeat
      z:=maxspeed+random(maxdist);
      x:=random(scnwidth);
      y:=random(scnheight)*2;
      speed:=1+random(maxspeed);
      {calc new star screen position}
      scnx:=midx+ ((x shl 8) div z);
      scny:=midy+(((y shl 8) div z) div 2);
      until (z > maxspeed)
    and (scnx > 0) and (scnx < maxx) and (scny > 0) and (scny < maxy);
    if (w and $7f) = $7f then write(#13,(maximum-1)-w,' ');
  end;

  asm
    mov ax,0006
    int 10h
  end;

  {Determine maximum # of stars a system can produce at 60fps}
  repeat
    if not foundmax then begin
      asm pushf; cli end;
      _PZTimerON;
      asm popf end;
    end;
    for w:=0 to maxfound do with stars^[w] do begin
      {calc new star screen position}
      dec(z,speed);
      oldscnx:=scnx;
      oldscny:=scny;
      asm
        les di,stars
        mov ax,w
        shl ax,1
        shl ax,1
        shl ax,1
        shl ax,1 {our struct is 16 bytes}

        {scnx:=midx+ ((x shl 8) div z);}
        add di,ax
        mov ax,es:[di].startype.x
        mov ah,al {mov cl,8; shl ax,cl}
        xor al,al
        cwd
        mov bx,es:[di].startype.z
        idiv bx
        add ax,midx
        mov es:[di].startype.scnx,ax

        {scny:=midy+(((y shl 8) div z) div 2);}
        mov ax,es:[di].startype.y
        mov ah,al
        xor al,al
        cwd
        idiv bx
        sar ax,1
        add ax,midy
        mov es:[di].startype.scny,ax
      end;
      {if star is off the screen, reset star}
      if (z<maxspeed+1)
      or (scnx < 0) or (scnx > maxx)
      or (scny < 0) or (scny > maxy)
        then begin
          z:=maxdist;
          speed:=1+random(maxspeed);
          x:=random(scnwidth);
          y:=random(scnheight)*2;

          if not foundmax and (maxfound < maximum-1)
            then inc(maxfound);
          {calc new star screen position}
          asm
            les di,stars
            mov ax,w
            shl ax,1
            shl ax,1
            shl ax,1
            shl ax,1 {our struct is 16 bytes}
            add di,ax
            mov ax,es:[di].startype.x
            mov ah,al {mov cl,8; shl ax,cl}
            xor al,al
            cwd
            mov bx,es:[di].startype.z
            idiv bx
            add ax,midx
            mov es:[di].startype.scnx,ax

            mov ax,es:[di].startype.y
            mov ah,al
            xor al,al
            cwd
            idiv bx
            sar ax,1
            add ax,midy
            mov es:[di].startype.scny,ax
          end;
        end;
      {draw new star}
      if (oldscnx <> scnx)
      or (oldscny <> scny)
      then begin
        mode6_setpixel_direct(oldscnx,oldscny,0);
        mode6_setpixel_direct(scnx,scny,1{cols[z div 256]});
      end;
    end;
    if not foundmax then begin
      asm pushf; cli end;
      _PZTimerOff;
      asm popf; end;
      if _PZTimerCount > (1000000 div fps)
        then foundmax:=true;
    end;
  until keypressed;
  freemem(stars,sizeof(TStarray));
  asm
    mov ax,0003
    int 10h
  end;
  write('StarBench: ',maxfound);
  if maxfound>=maximum-1 then write(' (maximum!)');
  writeln;
  halt(3);
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
  avgobjsize:word;
begin
  new(foomsg,init(2,strpas(mainmenuLookup[mAbout].blurb)));
  with foomsg^ do begin
    for loop:=0 to numAboutLines-1 do AddLine(strpas(AboutText[loop]));
    if Systems^.Count>0 then begin
      avgobjsize:=Systems^.getsize div Systems^.Count;
      addline(' Systems loaded: '+inttostr(Systems^.Count)
         +' (RAM holds ~'+inttostr(Systems^.Count+(memavail div avgObjSize))
         +', room for ~'+inttostr(memavail div avgobjsize)+' more)');
    end;
    addline('    Memory free: '+inttostr(memavail div 1024)+' KB (largest: '+inttostr(maxavail div 1024)+' KB)');
    addline(' ');
    show;
  end;
  dispose(foomsg,done);
end;

Procedure PopSetupMessage;
var
  foomsg:PMessageObj;
  loop:byte;
begin
  new(foomsg,init(2,' Controlling TOPBENCH Behavior '));
  with foomsg^ do begin
    addline('User settings are controlled via command-line switches.');
    for loop:=0 to numHelpLines-1 do AddLine(strpas(CommandLineHelp[loop]));
    addline(' ');
    show;
  end;
  dispose(foomsg,done);
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

end.