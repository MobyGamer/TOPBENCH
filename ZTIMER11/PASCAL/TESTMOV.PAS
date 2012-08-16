{ test to see how many bytes we can move to screen with calcs }
{ needs to be 16ms or less, although 10ms would be mighty comfortable }

uses
  ztimer;

const
  loopcount=8;

var
  i:longint;

procedure ReportTime(count:longint);
begin
  writeln('Time in microsecs: ',count:12);
  writeln('Timer ticks taken: ',count/0.8381:12:6);
  writeln('~# of 8088 cycles: ',count/0.8381*4:12:6);
  writeln('~#cycles in block: ',count/0.8381*4/loopcount:12:6);
end;

var
  sourcebuf,destbuf:^byte;
  w:word;
  count:word;

const
  linewidth=160 div 8; {20}
  numlines=50;

begin
  destbuf:=ptr($b800,0000);
  sourcebuf:=ptr($1234,$5678);
  _PZTimerOn;
  {simulate 50 lines?}
  for count:=0 to numlines-1 do begin
    {simulate some calcs}
    w:=sourcebuf^;
    if w > 1
      then w:=w+(w*2)
      else w:=w+(w div 2);
    {do the move we care about}
    move(sourcebuf^,destbuf^,linewidth); {160 pixels across in 640x200 mode, 50 lines makes effective "80x50"}
    inc(longint(destbuf),80-linewidth); {move to next simulated scanline}
  end;
  _PZTimerOff;

  _PZTimerReport;

  count := _PZTimerCount;
  reporttime(count);
end.
