Function testVideoAdapterWrites:longint;

begin
  {getmem(buf1,screenarea);}
  buf1:=@scratchspace;
  If Mem[$0000:$0449]=7 then screenseg:=ptr($b000,0);

  asm
{Performs common memory write operations to video cards.
REP STOS is not performed because it would cause unacceptable visible
disruption to the screen while the realtime updates are in progress.
Also, size of block move is not a full 80x25 screen because otherwise
it would be a major slowdown to the tests.}
    pushf; cli; call _PZTimerOn; popf
    mov     dx,ds

    les     di,[buf1]
    (*lds     si,[screenseg]*)
    lds     si,[screenseg]
    mov     cx,screenarea
    shr     cx,1
    cld
    rep     movsw           {copy screen ram to buffer}
    mov     ds,dx
    les     di,[screenseg]
    lds     si,buf1
    lodsb                   {simulate writing a single character+attr to the}
    stosw                   {screen from an ascii text buffer}
    lodsb                   {again, from odd address}
    stosw
    sub     si,2
    sub     di,4            {reset buffer pointers}
    mov     cx,screenarea
    shr     cx,1
    rep     movsw           {simulate restoring an entire saved text screen}

    mov     ds,dx

    pushf; cli; call _PZTimerOff; popf
  end;

  {freemem(buf1,screenarea);}
  testVideoAdapterWrites:=_PZTimerCount;
end;

