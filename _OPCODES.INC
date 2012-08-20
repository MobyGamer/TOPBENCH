Function testCPUOpcodes:longint;
begin

{
Exercises almost every single 8086 opcode, in roughly opcode order.
Exceptions are anything that would interrupt the timing of the code, any non-
8086 instruction, and all floating-point instructions.  (This code must run on
all processors.)  Instructions explicitly not exercised are:

  Instructions skipped          Because:
  ~~~~~~~~~~~~~~~~~~~~          ~~~~~~~
  HLT                           It would delay by a random amount
  IN, OUT                       Port accesses vary highly from machine
                                to machine, and are not really what this
                                benchmark was built to test
  AAD/AAM with custom operand   Intel only
  WAIT, ESC                     These require optional/external hardware
  LOCK                          Kills the OS on multi-CPU machines (verified!)
  INT3 (trap to debugger)       Not used during normal program execution
  INTO (int4, overflow handler) Not used during normal program execution
  SALC (set AL on carry)        Undocumented (D6h); Intel only
  POP CS                        Undocumented and only works on Intel 808x
  POP SP                        PUSH SP is broken on 808x so we avoid POP SP
}

  asm
    pushf; cli; call _PZTimerOn; popf

    mov     ax,foow
    mov     dx,$5678
    (*lea     bx,scratchspace {init some vars}*)

    {Start exercising opcodes in roughly order of encoding.
    NOTE:  All opcode encodings are not represented with these sections;
    however, all mod r/m sections are represented in the effective addressing
    tests in the _ea.bod file.  (For MOV only, anyway.)}
    add     ax,foow     {accum, imm16}
    add     dx,foow     {reg,   imm16}
    add     al,foob     {accum, imm8}
    add     dl,foob     {reg,   imm8}
    add     [w],ax      {mem16, accum}
    add     [w],dx      {mem16, reg}
    add     [b],al      {mem8,  accum}
    add     [b],dl      {mem8,  reg}
    add     al,[b]      {accum, mem8}
    add     dl,[b]      {reg,   mem8}
    add     ax,[w]      {accum, mem16}
    add     dx,[w]      {reg,   mem16}
    add     ax,dx       {accum, reg}
    add     dx,ax       {reg,   accum}
    add     al,dl       {accum, reg}
    add     dl,al       {reg,   accum}

    push    es
    pop     es

    or      ax,foow     {accum, imm16}
    or      dx,foow     {reg,   imm16}
    or      al,foob     {accum, imm8}
    or      dl,foob     {reg,   imm8}
    or      w,ax        {mem16, accum}
    or      w,dx        {mem16, reg}
    or      b,al        {mem8,  accum}
    or      b,dl        {mem8,  reg}
    or      al,b        {accum, mem8}
    or      dl,b        {reg,   mem8}
    or      ax,w        {accum, mem16}
    or      dx,w        {reg,   mem16}
    or      ax,dx       {accum, reg}
    or      dx,ax       {reg,   accum}
    or      al,dl       {accum, reg}
    or      dl,al       {reg,   accum}

    push    cs
    pop     es          {POP CS is an undocumented opcode that actually works
                        on 8088/8086 but we're not going to use it -- it means
                        something completely different on later processors}

    adc     ax,foow     {accum, imm16}
    adc     dx,foow     {reg,   imm16}
    adc     al,foob     {accum, imm8}
    adc     dl,foob     {reg,   imm8}
    adc     w,ax        {mem16, accum}
    adc     w,dx        {mem16, reg}
    adc     b,al        {mem8,  accum}
    adc     b,dl        {mem8,  reg}
    adc     al,b        {accum, mem8}
    adc     dl,b        {reg,   mem8}
    adc     ax,w        {accum, mem16}
    adc     dx,w        {reg,   mem16}
    adc     ax,dx       {accum, reg}
    adc     dx,ax       {reg,   accum}
    adc     al,dl       {accum, reg}
    adc     dl,al       {reg,   accum}

    push    ax
    mov     ax,sp
    push    ss
    pop     ss          {halts all interrupts including NMI for next instr.}
    mov     sp,ax
    pop     ax

    sbb     ax,foow     {accum, imm16}
    sbb     dx,foow     {reg,   imm16}
    sbb     al,foob     {accum, imm8}
    sbb     dl,foob     {reg,   imm8}
    sbb     w,ax        {mem16, accum}
    sbb     w,dx        {mem16, reg}
    sbb     b,al        {mem8,  accum}
    sbb     b,dl        {mem8,  reg}
    sbb     al,b        {accum, mem8}
    sbb     dl,b        {reg,   mem8}
    sbb     ax,w        {accum, mem16}
    sbb     dx,w        {reg,   mem16}
    sbb     ax,dx       {accum, reg}
    sbb     dx,ax       {reg,   accum}
    sbb     al,dl       {accum, reg}
    sbb     dl,al       {reg,   accum}

    push    ds
    pop     ds

    and     ax,foow     {accum, imm16}
    and     dx,foow     {reg,   imm16}
    and     al,foob     {accum, imm8}
    and     dl,foob     {reg,   imm8}
    and     w,ax        {mem16, accum}
    and     w,dx        {mem16, reg}
    and     b,al        {mem8,  accum}
    and     b,dl        {mem8,  reg}
    and     al,b        {accum, mem8}
    and     dl,b        {reg,   mem8}
    and     ax,w        {accum, mem16}
    and     dx,w        {reg,   mem16}
    and     ax,dx       {accum, reg}
    and     dx,ax       {reg,   accum}
    and     al,dl       {accum, reg}
    and     dl,al       {reg,   accum}

    seges mov ax,[bx]   {segment override ES is opcode 26h}

    daa

    sub     ax,foow     {accum, imm16}
    sub     dx,foow     {reg,   imm16}
    sub     al,foob     {accum, imm8}
    sub     dl,foob     {reg,   imm8}
    sub     w,ax        {mem16, accum}
    sub     w,dx        {mem16, reg}
    sub     b,al        {mem8,  accum}
    sub     b,dl        {mem8,  reg}
    sub     al,b        {accum, mem8}
    sub     dl,b        {reg,   mem8}
    sub     ax,w        {accum, mem16}
    sub     dx,w        {reg,   mem16}
    sub     ax,dx       {accum, reg}
    sub     dx,ax       {reg,   accum}
    sub     al,dl       {accum, reg}
    sub     dl,al       {reg,   accum}

    segcs mov ax,[bx]   {segment override CS is opcode 2Eh}

    das

    xor     ax,foow     {accum, imm16}
    xor     dx,foow     {reg,   imm16}
    xor     al,foob     {accum, imm8}
    xor     dl,foob     {reg,   imm8}
    xor     w,ax        {mem16, accum}
    xor     w,dx        {mem16, reg}
    xor     b,al        {mem8,  accum}
    xor     b,dl        {mem8,  reg}
    xor     al,b        {accum, mem8}
    xor     dl,b        {reg,   mem8}
    xor     ax,w        {accum, mem16}
    xor     dx,w        {reg,   mem16}
    xor     ax,dx       {accum, reg}
    xor     dx,ax       {reg,   accum}
    xor     al,dl       {accum, reg}
    xor     dl,al       {reg,   accum}

    segss mov ax,[bx]   {segment override SS is opcode 36h}

    aaa

    cmp     ax,foow     {accum, imm16}
    cmp     dx,foow     {reg,   imm16}
    cmp     al,foob     {accum, imm8}
    cmp     dl,foob     {reg,   imm8}
    cmp     w,ax        {mem16, accum}
    cmp     w,dx        {mem16, reg}
    cmp     b,al        {mem8,  accum}
    cmp     b,dl        {mem8,  reg}
    cmp     al,b        {accum, mem8}
    cmp     dl,b        {reg,   mem8}
    cmp     ax,w        {accum, mem16}
    cmp     dx,w        {reg,   mem16}
    cmp     ax,dx       {accum, reg}
    cmp     dx,ax       {reg,   accum}
    cmp     al,dl       {accum, reg}
    cmp     dl,al       {reg,   accum}

    segds lodsw         {segment override DS is opcode 3Eh}

    aas

    inc     ax
    inc     cx
    inc     dx
    inc     bx
    inc     si
    inc     di
    dec     ax
    dec     cx
    dec     dx
    dec     bx
    dec     si
    dec     di
    {ensure we can do this next part without borking the machine}
    pushf
    cli
    inc     sp
    inc     bp
    dec     sp
    dec     bp
    popf

    push    ax
    push    cx
    push    dx
    push    bx
    push    bp
    push    si
    push    di
    pop     di
    pop     si
    pop     bp
    pop     bx
    pop     dx
    pop     cx
    pop     ax

    {Jcc and JMP tests -- timings are identical for most forms so we will
    only test a few.  jcxz is the only one with different timings so it is
    explicitly tested as well.}
    xor     cx,cx       {zero out cx}
    dec     cx          {cx := -1}
    stc                 {set carry flag}
    jc      @L1         {jump if carry - yes}
    nop
@L1:
    clc                 {clear carry flag}
    jc      @L1         {jump if carry - no}
    inc     cx
    jcxz    @L1         {jump if cx=0 - yes 1st pass, no 2nd}
    sub     cx,2
    jmp     @L3
@L2:
    inc     cx
    clc
@L3:
    jbe     @L2         {jump if cf=1 or zf=1}
    mov     cx,2
@loopfun:
    nop
    loop    @loopfun
@endofJMPtests:

    {test has optimized forms for accumulator}
    test    ax,foow     {accum, imm16}
    test    dx,foow     {reg,   imm16}
    test    al,foob     {accum, imm8}
    test    dl,foob     {reg,   imm8}
    test    w,ax        {mem16, accum}
    test    w,dx        {mem16, reg}
    test    b,al        {mem8,  accum}
    test    b,dl        {mem8,  reg}
    test    al,b        {accum, mem8}
    test    dl,b        {reg,   mem8}
    test    ax,w        {accum, mem16}
    test    dx,w        {reg,   mem16}
    test    ax,dx       {accum, reg}
    test    dx,ax       {reg,   accum}
    test    al,dl       {accum, reg}
    test    dl,al       {reg,   accum}

    lea     ax,[w]

{8e mov     segreg,rmw}
    mov     es,[bx+si+1234h]

    lea     bx,scratchspace

    nop

    xchg    w,ax        {mem16, accum}
    xchg    w,dx        {mem16, reg}
    xchg    b,al        {mem8,  accum}
    xchg    b,dl        {mem8,  reg}
    xchg    al,b        {accum, mem8}
    xchg    dl,b        {reg,   mem8}
    xchg    ax,w        {accum, mem16}
    xchg    dx,w        {reg,   mem16}
    xchg    ax,dx       {accum, reg}
    xchg    dx,ax       {reg,   accum}
    xchg    al,dl       {accum, reg}
    xchg    dl,al       {reg,   accum}

    cbw

    {both near and far calls explicitly included so they can be measured}
    call    doNothingNear
    call    doNothingFar

    pushf
    cli
    lahf
    sahf
    popf

    push    ds
    pop     es
    mov     di,si       {es:di should now equal ds:si}
    movsb
    movsw
    movsb
    movsw
    lodsb
    stosb
    lodsw
    stosw
    lodsb
    stosb
    lodsw
    stosw               {tests both aligned and unaligned moves}

    cmpsb
    cmpsw
    cmpsb
    cmpsw               {aligned and unaligned}
    scasb
    scasw
    scasb
    scasw               {aligned and unaligned}


    mov     al,foob
    mov     cl,foob
    mov     dl,foob
    mov     bl,foob
    mov     ah,foob
    mov     ch,foob
    mov     dh,foob
    mov     bh,foob
    mov     ax,foow
    mov     cx,foow
    mov     dx,foow
    mov     bx,foow
    {A lot of hassle just to test the mov encodings of sp and bp :-P }
    pushf
    cli
    mov     dx,sp
    mov     sp,foow
    mov     sp,dx
    mov     dx,bp
    mov     bp,foow
    mov     bp,dx
    popf
    mov     si,foow
    mov     di,foow

    les     bx,[foow]
    pushf
    cli
    push    ds
    lds     si,[foow]
    pop     ds
    popf

    mov     bx,$FFFF
    rol     bl,1
    rol     [b],1
    ror     bl,1
    ror     [b],1
    rcl     bl,1
    rcl     [b],1
    rcr     bl,1
    rcr     [b],1
    shl     bl,1
    shl     [b],1
    shr     bl,1
    shr     [b],1
    sal     bl,1
    sal     [b],1
    sar     bl,1
    sar     [b],1
    rol     bx,1
    rol     [w],1
    ror     bx,1
    ror     [w],1
    rcl     bx,1
    rcl     [w],1
    rcr     bx,1
    rcr     [w],1
    shl     bx,1
    shl     [w],1
    shr     bx,1
    shr     [w],1
    sal     bx,1
    sal     [w],1
    sar     bx,1
    sar     [w],1

    {Nybble work is common, so let's choose 4.  Higher values could be used,
    but can be optimized out (ie. rol al,5 = ror al,3) so we'll avoid them.}
    mov     cl,4
    rol     bl,cl
    rol     [b],cl
    ror     bl,cl
    ror     [b],cl
    rcl     bl,cl
    rcl     [b],cl
    rcr     bl,cl
    rcr     [b],cl
    shl     bl,cl
    shl     [b],cl
    shr     bl,cl
    shr     [b],cl
    sal     bl,cl
    sal     [b],cl
    sar     bl,cl
    sar     [b],cl
    rol     bx,cl
    rol     [w],cl
    ror     bx,cl
    ror     [w],cl
    rcl     bx,cl
    rcl     [w],cl
    rcr     bx,cl
    rcr     [w],cl
    shl     bx,cl
    shl     [w],cl
    shr     bx,cl
    shr     [w],cl
    sal     bx,cl
    sal     [w],cl
    sar     bx,cl
    sar     [w],cl

    aad
    aam
    xlat

    mov     ax,foow
    mov     dx,$5678    {get non-zeros in registers again}

    cmc

    not     dl
    not     ax
    neg     dl
    neg     ax

    {mul/div tests.  Values inspired by "PIT ticks to usec" conversion}
    mov     dx,8381
    mul     dx
    mov     bx,10000
    div     bx
    imul    dx
    idiv    bx

    clc
    stc
    cli
    sti

    std
    cld {reversed from opcode encoding to ensure we don't bork future moves}

{Call a BIOS do-nothing interrupt to test INT.  Dummy interrupt in this case
is 1C, the user hook interrupt, which we haven't hooked so it should just do
an iret.  If a TSR is loaded that DOES hook it, it's going to skew things, so
remember to remind the user to test on a clean boot if possible.}
    int     1Ch
    (* old do-nothing interrupt test was READ CURSOR POSITION
    {returns data from BIOS DATA AREA, shouldn't actually touch hardware}
    push    ax
    push    bx
    push    cx
    push    dx
    mov     ah,3
    mov     bh,0
    int     10h
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    *)

    pushf
    call    doNothingInterrupt; {...to force an IRET in memory to be measured.
Previous test also calls an IRET but the IRET is usually located in the BIOS
ROM if 1c hasn't been hooked.}

    (*this completely crashed a virtual session -- it turns out that,
    unless you're writing a multi-CPU operating system, you shouldn't
    use LOCK indiscriminantly :-D
    lock    xor dx,foow {LOCK prefix takes 2 cycles on 8086}*)

    {Although the effective addressing test exercises this massively,
    we should do a little something here.}
    mov     ax,foow     {accum, imm16}
    mov     dx,foow     {reg,   imm16}
    mov     al,foob     {accum, imm8}
    mov     dl,foob     {reg,   imm8}
    mov     w,ax        {mem16, accum}
    mov     w,dx        {mem16, reg}
    mov     b,al        {mem8,  accum}
    mov     b,dl        {mem8,  reg}
    mov     al,b        {accum, mem8}
    mov     dl,b        {reg,   mem8}
    mov     ax,w        {accum, mem16}
    mov     dx,w        {reg,   mem16}
    mov     ax,dx       {accum, reg}
    mov     dx,ax       {reg,   accum}
    mov     al,dl       {accum, reg}
    mov     dl,al       {reg,   accum}
    {don't forget some segment overrides:}
    mov     dx,cs:[bx]
    mov     dx,ss:[bp]
    mov     dx,es:[si]
    mov     dx,ds:[di]

    lea     bx,scratchspace
    {stupid pascal in-line assembler won't recognize push rmw!}
    {push   [bx]} DB $FF,$37
    {pop    [bx]} DB $8F,$07

    pushf; cli; call _PZTimerOff; popf
  end;
  testCPUOpcodes:=_PZTimerCount;
end;
