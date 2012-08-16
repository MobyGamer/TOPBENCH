unit ZTimer;

{ Zen Timer unit.  Interface to assembler code by Michael Abrash and Kendall
  Bennett; TP interface written by Duncan Murdoch }

{ Requires TP 6.0 or later; earlier versions will not link the .OBJ files. }

interface

procedure _PZTimerOn;
procedure _PZTimerOff;
procedure _PZTimerReport;
function  _PZTimerCount : longint;

procedure _LZTimerOn;
procedure _LZTimerOff;
procedure _LZTimerReport;
function  _LZTimerCount : longint;

implementation

{$L d:\ztimer11\pascal\PZTimer.obj}

procedure _PZTimerOn;              external;
procedure _PZTimerOff;             external;
procedure _PZTimerReport;          external;
function  _PZTimerCount : longint; external;

{$l d:\ztimer11\pascal\lztimer.obj}

procedure _LZTimerOn;              external;
procedure _LZTimerOff;             external;
procedure _LZTimerReport;          external;
function  _LZTimerCount : longint; external;

end.
