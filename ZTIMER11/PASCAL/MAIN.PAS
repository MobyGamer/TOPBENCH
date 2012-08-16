program main;

{ Test of Zen Timer.  Timer by Michael Abrash, test by Kendall Bennett. }
{ Translation of main.c into Turbo Pascal by Duncan Murdoch. }

uses
  ztimer;

const
  looplen=2000;

procedure ReportTime(count:longint);
begin
  writeln('Time taken: ',count/1000000:12:6);
end;

var
  i,j : integer; { NON register variables! }
  count : longint;
begin
  asm
    mov ax,03
    int 10h
  end;
  count:=0;

  { test the latency of the timer code itself}
  for i := 0 to looplen-1 do begin
    _LZTimerOn;
    asm {junk instructions to take up time}
(*      mov    dx,5678h
      nop
      mov    ax,1234h
      nop
      xchg   ax,bx
      nop
      xchg   bx,cx
      nop
      add    dx,ax
      nop
      mov    cl,14
      shl    dx,cl
      shr    ax,cl
      add    bx,bx
      adc    cx,bx
*)

(* what's the fastest way to lodsb to AH instead of AL?  let's find out: *)

      mov ah,[si]; inc si
      mov ah,[si]; inc si
      mov ah,[si]; inc si
      mov ah,[si]; inc si
      mov ah,[si]; inc si
      mov ah,[si]; inc si
      mov ah,[si]; inc si
      mov ah,[si]; inc si
      mov ah,[si]; inc si
      mov ah,[si]; inc si
(*      the above avgs 39*)

(*
      lodsb; mov ah,al
      lodsb; mov ah,al
      lodsb; mov ah,al
      lodsb; mov ah,al
      lodsb; mov ah,al
      lodsb; mov ah,al
      lodsb; mov ah,al
      lodsb; mov ah,al
      lodsb; mov ah,al
      lodsb; mov ah,al
      the above avgs 41.66
*)
(*
      lodsb; xchg ah,al
      lodsb; xchg ah,al
      lodsb; xchg ah,al
      lodsb; xchg ah,al
      lodsb; xchg ah,al
      lodsb; xchg ah,al
      lodsb; xchg ah,al
      lodsb; xchg ah,al
      lodsb; xchg ah,al
      lodsb; xchg ah,al
      avg was 41.66
      *)

    end;
    _LZTimerOff;
    inc(count,_LZTimerCount);
    if (i and $FF)=0 then write(#13,count);
  end;
  writeln(#13#10'Average time of sample instruction set was: ',count/looplen:2:2,' microseconds -- last one was:');
  _LZTimerReport;

  { Test the precision timer routine }

  _PZTimerOn;
  for i := 0 to 100 do i := i;

  _PZTimerOff;
  _PZTimerReport;
  count := _PZTimerCount;
  writeln('Count returned: ',count);

  { Test the precision timer routine for overflow }

  _PZTimerOn;
  for j := 1 to 20 do
          for i := 0 to 10000 do
                  i := i;
  _PZTimerOff;
  _PZTimerReport;
  count := _PZTimerCount;
  writeln('Count returned: ',count);

  { Test the long period Zen Timer (we don't check for overflow coz
    it would take tooooo long!)
  }

  {_PZTimerOn;}
  asm
    mov cx,$ffff {loop count}
    mov dx,$201 {joystick port}
    mov ah,$10 {joystick button a}
    call _LZtimeron
  @loop:
    in al,dx
    test al,ah
    loopnz @loop
  end;
{        for i := 0 to 100 do
          i := i;}
  {
  _LZTimerOn;
  for j := 1 to 20 do
          for i := 0 to 10000 do
                  i := i;}
  _LZTimerOff;
  _LZTimerReport;
  ReportTime(_LZTimerCount);
end.
