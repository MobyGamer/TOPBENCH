Function testMemoryBlockOps:longint;
begin
  {getmem(buf1,bufsize); getmem(buf2,bufsize);}
  {point buf1 at the start of scratchspace}
  buf1:=@scratchspace;
  {make sure buf2 is one bufchunk past buf1, word-aligned}
  buf2:=@scratchspace; inc(word(buf2),(bufsize AND $FFFFFFFE)+2);
{Exercises all of the string operations: STOS, MOVS, LODS, SCAS, CMPS.
REP LODSW is not used in real life but is included to measure mem read speed.
With the exception of REP LODSW, this suite simulates typical program
operations like searching/comparing for individual characters}
  asm
    pushf; cli; call _PZTimerOn; popf

    mov     dx,ds {we're not using dx at all in this test}

    {Basic test mostly simulates what real programs do:
    fill a buffer with stosw,
    then copy that buffer to system ram with a movsw+adc+movsb copy,
    then scan the entire buffer for a character with scasb,
    then compare both buffers looking for differences with cmpsb.
    Finally, unlike real programs, rep lodsw to test block memory read speed.}

    cld
    xor     ax,ax
    les     di,[buf1]
    mov     cx,bufsize
    shr     cx,1
    rep     stosw           {fill buf1 with 00h}
    adc     cx,0
    rep     stosb

    les     di,[buf2]
    lds     si,[buf1]
    mov     cx,bufsize
    shr     cx,1
    rep     movsw
    adc     cx,0
    rep     movsb           {typical copy routine that handles cx=odd number}

    sub     si,bufsize
    sub     di,bufsize      {reset buffer pointers}
    mov     byte ptr es:[di+bufsize-2],$ff
                            {put a target search byte "FF" at end of es:di buffer}
    mov     cx,bufsize
    mov     al,$ff
    repne   scasb           {should stop shortly before the end of the buffer}

    sub     di,bufsize-1    {reset buffer pointers}
    mov     cx,bufsize
    repe    cmpsb           {should stop one byte from the end of both buffers}

    sub     si,bufsize-1
    mov     cx,bufsize
    shr     cx,1
    rep     lodsw           {maximum transfer rate block memory read}

    mov     ds,dx           {restore ds or Pascal will freak out}

    pushf; cli; call _PZTimerOff; popf;
  end;
  {freemem(buf2,bufsize); freemem(buf1,bufsize);}
  testMemoryBlockOps:=_PZTimerCount;
end;
