{$O-,R-,S-,A+,E-,N-,G-,Q-}
unit btsuites;
{
TOPBENCH test suites.  Each suite contains a particular exercise
of the system.  Most of the tests are CPU exercises meant to
aid emulator authors; a few others are memory block read/write
tests, and one test is a memory write speed to the primary video card.

Each suite returns the number of microseconds (æsecs) it took to run
as an aid to emulator authors, with the
exception of TOPScore which returns the number of times the complete
suite ran in a 50ms period, which is the actual synthetic benchmark score.

The code in these suites is actually duplicated twice -- once with
precise timer measurement, and a second time without.  The reason for this
is because the act of precisely measuring using the timer requires a few
IN instructions, which themselves take a variable amount of time from
machine to machine; the full suite should not include this overhead, so
additional non-measuring blocks are defined. (Duplication of code is
wasteful but was necessary to get around the limitations of Turbo Pascal's
inline assembler.  I spent two days trying to get self-modifying code
working (NOP'ing out the calls to _PZTimerOn/_PZTimerOff)
with Turbo Assembler while simultaneously linking it against Turbo Pascal
and failed.  Code duplication is me cutting my losses.  If you are a better
programmer than me, please make it
happen and give your changes to me so I can release a less-embarrasing
product.)
}

{{$DEFINE DEBUG}
{Enable DEBUG if you wish to single-step debug through the code.  Otherwise,
the full timer handling/measuring/etc. code is in effect.}

{{$DEFINE DEBUGINT}
{Attempt to single-step through the debug handling.  BTW these DEBUG options
are not supported by me so don't complain if you compile with them and
things don't work correctly.  In fact, I guarantee things won't work!}

{{$DEFINE DEBUGRUNALL}

interface

const
  screenseg:pointer=ptr($b800,0);

{For descriptions of these test suites, please check all the _*.bod files
in the source directory, which include a comment describing the test,
and assembler source code that actually executes it.}
Function testMemoryBlockOps:longint;
{Function testEmptyNOPs:longint;}
Function testCPUOpcodes:longint;
Function testVideoAdapterWrites:longint;
Function testMemEA:longint;
{Function testUnrolledLoop:longint;}
Function test3DGames:longint;

Function measureAllSuites:longint;
{Runs all tests in succession (timings exposed to the user)}

{$IFDEF DEBUGRUNALL}
Procedure runAllSuites;
{Runs all tests in succession -- no timer measurements attempted.
This is what TOPScore uses to report the synthetic benchmark.}
{$ENDIF}

Function TOPScore:longint;
{Returns the number of times testAllSuites ran in a 50ms period}

Function TOPScoreFingerprint:longint;
{Same as TOPScore but averaged over a 2000ms period to compensate for jitter}

implementation

uses
  {$IFNDEF DEBUG}
  ztimer,
  {$ENDIF}
  {$IFDEF DEBUGINT}
  support,
  {$ENDIF}
  tinterrupts;

const
  bufsize=257; {size of buffer used in memory block tests, deliberately odd}
  screenarea=320; {single line of pixels in MCGA mode, or 4 lines in CGA}
  foow=$1234; foob=$12; {dummy seed constants for the routines}
  disp16=$0101; disp8=$01; {dummy offsets to use with EA tests}

var
  {reserve some space in the global data/DS segment for our tests}
  b:byte; w:word;
  scratchspace:array[0..((bufsize+screenarea+disp16)*2)] of byte;
  intCounter:byte; {counter incremented by the 50ms interrupt handler}
  buf1,buf2:pointer; {used for tests}

{$IFDEF DEBUG}
{Stub measuring procedures if we are single-step debugging}
Procedure _PZTimerOn; begin end;
Procedure _PZTimerOff; begin end;
Function _PZTimerCount:longint;
begin
  _PZTimerCount:=1234;
end;
{$ENDIF}

{=-=-= Begin support procedures that the tests need           =-=-=}

{$F+}
Procedure doNothinginterrupt; assembler;
{used to ensure an IRET gets benchmarked.  Interrupts are always FAR calls.}
asm
  iret
  {retf is generated here by Turbo Pascal but will never get called}
end;
{$F-}

Procedure doNothingnear; near; assembler;
{used to exercise the CALL opcode}
asm
  {nop} {don't actually waste time with a NOP, just return}
end;

Procedure doNothingfar; far; assembler;
{used to exercise the CALL FAR opcode}
asm
  {nop} {don't actually waste time with a NOP, just return}
end;

{=-=-= Begin test suites that are measured with the Zen timer =-=-=}

{$I _mblock.inc}
{{$I _nops.inc}
{$I _opcodes.inc}
{$I _vidmem.inc}
{$I _ea.inc}
{{$I _unroll.inc}
{$I _3dgames.inc}

{=-=-= Begin test suites that are UNmeasured, no INs or overhead =-=-=}

Function measureAllSuites:longint;
{Runs all tests in succession.}
var
  l:longint;
begin
  l:=0;
  inc(l,testMemoryBlockOps);
{  inc(l,testEmptyNOPs);}
  inc(l,testCPUOpcodes);
  inc(l,testVideoAdapterWrites);
  inc(l,testMemEA);
{  inc(l,testUnrolledLoop);}
  inc(l,test3DGames);
  measureAllSuites:=l;
end;

{$I _runall.inc}

var
  HandlerCounter:word;

{$F+}
procedure CountHandler; Interrupt;
{
Interrupt handler that increments a word counter in the global DATA segment.
NO handling is done to maintain a perfectly-accurate int8 firing -- we just
chain to it. 55ms vs. 50ms isn't going to throw it off that much, especially
since we're not going to be active for more than a few iterations.
}

begin
  inc(HandlerCounter);
  asm pushf end; {simulate an interrupt by pushing flags, then CALLing handler}
  BIOSTimerHandler; {this will acknowledge the interrupt}
end;
{$F-}


Function TOPScore:longint;
{Returns the number of times testAll runs in a 50ms period.
This is the realtime score displayed continuously onscreen.
This routine works by reprogramming the irq0/int8 timer to a 50ms interval
which updates a counter every time it fires.  We spinlock waiting for the
counter to change, then run our tests and watch for it to change again.
This method was chosen over reading the timer values directly,
because doing so involves IN statements reading
from the timer ports, which introduces variable slowdown.}
const
  _50usecsInTicks=trunc(14.31818/12*1000000/20); {should be 59659}
var
  lcounter:longint;

begin
  SetTimerHz(@CountHandler, 20); {set to fire at 20Hz / 50ms}
  {$IFDEF DEBUGINT}
  repeat write(#13,HandlerCounter) until keypressed; while keypressed do readkeychar;
  {$ENDIF}
  lcounter:=0;
  {synchronize start of benchmark with timer firing}
  asm
    xor     ax,ax
    hlt                            {wait until the next interrupt fires}
    mov     word ptr [HandlerCounter],ax {reset interrupt counter}
@spinlock:
    hlt                            {wait until the next interrupt fires}
    cmp     [HandlerCounter],ax    {was it our counting interrupt?}
    je      @spinlock              {if not and counter still 0, keep waiting}
    {start the benchmark}
    {$IFDEF DEBUGINT}
    jmp @timeelapsed
    {$ENDIF}
    mov     word ptr [HandlerCounter],ax {reset interrupt counter}
@benchit:
    call    runAllSuites;          {run all suites without timer wrapper,
                                   heap manipulation, etc.}
    cmp     [HandlerCounter],0     {compare handler counter to 0}
    jne     @ranoutoftime          {if not 0 any more, we ran out of time}
    add     word ptr [lcounter],1  {otherwise, record successful run and try again}
    adc     word ptr [lcounter+2],0
    jmp     @benchit
@ranoutoftime:
  end;
  CleanUpTimer; {set timer back to normal}
  TOPScore:=lcounter;
end;

Function TOPScoreFingerprint:longint;
{Returns the 50ms TOPScore averaged over a 2000ms period.
This is the number that gets recorded into the database.}
const
  _50usecsInTicks=trunc(14.31818/12*1000000/20); {should be 59659}
  maxiterations=2000 div 50;
var
  lcounter:longint;

begin
  SetTimerHz(@CountHandler, 20); {set to fire at 20Hz / 50ms}
  {$IFDEF DEBUGINT}
  repeat write(#13,HandlerCounter) until keypressed; while keypressed do readkeychar;
  {$ENDIF}
  lcounter:=0;
  {synchronize start of benchmark with timer firing}
  asm
    xor     ax,ax
    hlt                            {wait until the next interrupt fires}
    mov     word ptr [HandlerCounter],ax {reset interrupt counter}
@spinlock:
    hlt                            {wait for an interrupt to fire}
    cmp     [HandlerCounter],ax    {was it our counting interrupt?}
    je      @spinlock              {if not, this will still be 0; keep waiting}
    {start the benchmark}
    mov     word ptr [HandlerCounter],ax {reset interrupt counter}
@benchit:
    call    runAllSuites;          {run all suites without timer wrapper,
                                   heap manipulation, etc.}
    cmp     [HandlerCounter],maxiterations {compare handler counter to max iterations}
    jge     @ranoutoftime          {if over our limit, we ran out of time}
    add     word ptr [lcounter],1  {otherwise, record successful run and try again}
    adc     word ptr [lcounter+2],0
    jmp     @benchit
@ranoutoftime:
  end;
  CleanUpTimer; {set timer back to normal}
  TOPScoreFingerprint:=round(lcounter / maxiterations);
end;

begin
  {In case no sophisticated detection routines are used to set this, we will
  perform a cheating half-assed way of determining if we're using CGA or MDA.}
  If Mem[$0000:$0449]=7
    then screenseg:=ptr($b000,0)
    else screenseg:=ptr($b800,0);
end.
