Function test3DGames:longint;
begin
  {point buf1 at the start of scratchspace}
  buf1:=@scratchspace;
  {make sure buf2 is one bufchunk past buf1, word-aligned}
  buf2:=@scratchspace; inc(word(buf2),(bufsize AND $FFFFFFFE)+2);


{
3-D Games benchmark suite

Most benchmark suites are (rightly) accused of not being very true to how real
programs are built and executed; they run blocks of code that the programmer
thought was a decent way to test a machine, and I am slightly guilty of it as
well.  So while block memory reads/writes and a complete opcode exercise are
exhaustive and useful, they are not very practical.

This test suite attempts to rectify that by mimicing the opcode execution
frequency of a 1990-era 3-D game, the type of program that most users of this
benchmark would be concerned with.  The code in this suite may look completely
nonsensical and arbitrary, but it consists of the actual instruction
frequncy/distribution as a typical 3-D game of 1990.  (The order of the
instructions is of course not the same as the actual code of any program, but
some instructions were relocated to a more typical position; for example, all
the MULs are not in the same place, etc.)

How was this block constructed?  Using DOSBOX's debugger, in-game execution
for several games was logged and sections of the main calculation loop (the
part that calculates the 3-D and then rasterizes the polygons) were
identified.  The log was then run through a filter that changed each
instruction to its base form (ie. "ADD AL,BL" was changed to "ADD
accum8,reg8", "MOV DX,[BX+SI+1432]" was changed to "MOV reg16,[BX+SI+disp16]",
etc.) so that each unique encoding/form could be tallied into buckets.
Finally, all buckets were averaged, and then divided by a constant to produce
the instruction categories and frequencies in this code block.  The target for
this code block was roughly 400 instructions.  (The division was necessary
because reproducing them verbatim would have resulted in a benchmark block
that would take over a second to execute on a slow machine, and the target for
all blocks is roughly 2ms.)

The games that were analyzed were:

Title              Year Engine Developer  Speed(1) Instructions(2)
~~~~~              ~~~~ ~~~~~~~~~~~~~~~~  ~~~~~    ~~~~~~~~~~~~
Interphase         1990 Image Works       fast     96645
Indianapolis 500   1989 Electronic Arts   fast     175069
Stellar 7          1990 Dynamix           moderate 124692
Stunt Driver       1990 Spectrum Holobyte moderate 165974
Killing Cloud      1991 Vektor Grafix     moderate 180249
LHX Attack Chopper 1990 Electronic Arts   moderate 225797
Flight Simulator 4 1990 Sublogic          moderate 309737
Battle Command     1991 Realtime          moderate 420442
Blue Angels        1990 Artech            slow     413359

(1) This is my subjective visual feel for the framerate of a game at a given 
machine speed.

(2) This is the actual 3-D game instruction count for one calculation block.
Lower numbers usually translate to more efficient code and a faster game.

The above games were chosen because:

- They all had filled polygons in scenes of non-simple detail
- Had impressive framerates for slow computers of their era
- Supported CGA
- Could run on slow machines (8088) but scaled appropriately to faster ones
  (386+)
- Were developed as far apart from each other as possible (ie. all of the
above game engines were made by a different team.).  This also explains why
there are no "duplicates"; for example, LHX Attack Chopper is present but IL-
Stormuvick or Chuck Yeager's Air Combat are not, because all three use the
same engine written by Brent Iverson and it would have skewed the
distribution.  This also explains why Vette! is absent (because Stunt Driver
was chosen), why UFO or Jet are absent (because Flight Simulator 4 was
chosen), etc.

CGA was chosen as a requirement so that the "update screen" routine could be
easily identified (memory moves to ES=B800, no INs or OUTs involving EGA/VGA
hardware).  The analyzed code was identified as the code that executes
*between* these moves, ie. included everything except the actual buffer-to-
screen copy.

I made some interesting observations when looking at the execution history:

- I used to think that the difference between a fast and slow 3-D game was due 
to optimization of MULs or something, but all of the above games performed the 
same 9 MULs per rotation.  Only Stunt Driver was different; it calculated only 
6 MULs when the car was driving, probably because it only needed to account 
for 2 axis at a time due to the nature of the simulation.

- Indianapolis 500 performs nearly double the amount of calculations as
Interphase, yet I marked it as "fast", and it is suitably impressive on an
808x machine.  Why?  Because the game's viewport is only half the screen
(roughly a 320x100 area instead of the full 320x200).  But that's okay,
because it's a driving game on an oval track; you don't need a lot of vision 
up or down.

- The games varied wildly with their math representations; many used what
appeared to be 16.16 fixed point, but I believe I saw a few others, such as
8.16 (Interphase) and 8.24 (Flight Simluator). I could be wrong however, and
encourage you to do your own research/disassembly/logging.  All my data is
available upon request if you'd like to study it (but I warn you, the 
sed/awk/shell scripts I wrote to process it will likely disgust you).

}
  asm
    call _PZTimerOn


    {Init so we have a consistent starting point}
    mov  ax,$0101
    mov  bx,ax
    mov  cx,ax
    mov  dx,ax
    mov  [w],ax
    mov  [b],al
    les  di,buf1

    {actual suite begins:}
    adc  DX,[W]
    adc  DX,[W]
    adc  DX,$0101
    adc  DX,DX
    adc  DX,DX
    adc  DX,DX
    adc  DX,DX
    mul  ax
    add  [W],DX
    add  AX,[W]
    add  AX,$0101
    add  AX,$0101
    add  AX,DX
    add  AX,DX
    add  DX,[W]
    add  DX,[W]
    add  DX,AX
    add  DX,AX
    add  DX,AX
    add  DX,$0101
    add  DX,$0101
    add  DX,$0101
    add  DX,$0101
    add  DX,$0101
    mul  BX
    add  DX,DX
    add  DX,DX
    add  DX,DX
    add  [W],$0101
    and  AL,DL
    and  AL,DL
    and  DX,$0101
    and  DX,$0101
    and  DL,BL
    and  CL,BL
    and  DL,ES:[di]
    call doNothingNear
    call doNothingNear
    call doNothingNear
    call doNothingFar
    call doNothingNear
    call doNothingNear
    call doNothingNear
    call doNothingNear
    cmp  DX,[bp+$0101]
    cmp  DX,[bx+$0101]
    cmp  DX,[si+$0101]
    cmp  DX,[si+$0101]
    cmp  DX,[si+$0101]
    cmp  DX,DX
    cmp  DX,DX
    cmp  DX,DX
    cwd
    cwd
    cwd
    dec  byte [W]
    mul  DX
    dec  DX
    dec  DX
    dec  DX
    dec  DX
    dec  DL
    imul DX
    cmp  DX,$0101
    cmp  DX,DX
    xor  dx,dx
    idiv BX
    add  DX,AX
    add  DX,$0101
    imul DX
    add  DX,AX
    add  DX,$0101
    imul DX
    {lea  bx,[buf1]}
    {imul word ptr [bx+$0101]}
    cmp  DX,$0101
    cmp  DX,DX
    imul [W]

    {Most of these jumps branch}

    stc
    jc   @L2
    nop
@L2:
    jc   @L3
    nop
@L3:

    xor  CX,CX
    jcxz @L4
    nop
@L4:

    cmp  DX,DX
    je   @l5
    nop
@L5:
    cmp  [B],$FF
    je   @l6
    nop
@L6:
    cmp  cx,cx
    je   @l7
    nop
@L7:
    je   @l8
    nop
@L8:
    je   @l9
    nop
@L9:
    je   @la
    nop
@La:
    je   @lb
    nop
@Lb:
    je   @lc
    nop
@Lc:
    je   @ld
    nop
@Ld:
    je   @le
    nop
@Le:
    je   @lf
    nop
@Lf:
    je   @lg
    nop
@Lg:
    je   @lh
    nop
@Lh:

    mov  cl,$ff
    cmp  CL,$01

    jg   @g1
    nop
@g1:
    jg   @g2
    nop
@g2:
    jg   @g3
    nop
@g3:
    jg   @g4
    nop
@g4:
    jg   @g5
    nop
@g5:
    jge  @g6
    nop
@g6:
    jge  @g7
    nop
@g7:
    jge  @g8
    nop
@g8:
    jge  @g9
    nop
@g9:
    jge  @ga
    nop
@ga:
    jge  @gb
    nop
@gb:

    or   DX,AX
    xor  cx,cx
    cmp  DX,CX {cx should still be 0, DX should be non-zero}

    jl   @q1
    nop
@q1:
    jl   @q2
    nop
@q2:
    jl   @q3
    nop
@q3:
    jl   @q4
    nop
@q4:
    jl   @q5
    nop
@q5:
    jle  @q6
    nop
@q6:
    jle  @q7
    nop
@q7:
    jle  @q8
    nop
@q8:
    jle  @q9
    nop
@q9:
    jle  @qa
    nop
@qa:
    jle  @qb
    nop
@qb:

    jmp  @s1
    nop
@s1:
    jmp  @s2
    nop
@s2:
    jmp  @s3
    nop
@s3:
    jmp  @s4
    nop
@s4:
    jmp  @s5
    nop
@s5:
    jmp  @s6
    nop
@s6:

    clc
    jnc  @c1
    nop
@c1:
    jnc  @c2
    nop
@c2:
    jnc  @c3
    nop
@c3:

    mov  AX,$0101
    mov  DX,AX
    mov  [W],DX
    dec  DX

    cmp  DX,[W]
    jne  @n1
    nop
@n1:
    cmp  DX,[W]
    jne  @n2
    nop
@n2:
    cmp  DX,[W]
    jne  @n3
    nop
@n3:
    cmp  DX,[W]
    jne  @n4
    nop
@n4:
    cmp  DX,AX
    jne  @n5
    nop
@n5:
    cmp  DX,$0101
    jne  @n6
    nop
@n6:
    cmp  DX,DX
    jne  @n7
    nop
@n7:
    cmp  DX,$0101
    jne  @n8
    nop
@n8:
    cmp  DX,DX
    jne  @n9
    nop
@n9:


    mov  DX,$0002
    mov  cx,dx
@lp1:
    lodsb
    loop @lp1

    mov  cx,dx
@lp3:
    lodsb
    loop @lp3

    mov  cx,dx
@lp5:
    lodsw
    loop @lp5

    mov  cx,dx
@lp7:
    lodsw
    loop @lp7

    mov  AX,[bp+$0101]
    mov  AX,[bx+$0101]
    mov  DX,[bx+$0101]
    mov  AX,[di+$0101]
    mov  DX,[di+$0101]
    mul  ax
    mov  [W],AX
    mov  [W],AX
    mov  [W],AX
    mov  [W],AX
    mov  [W],AX
    mov  [W],DX
    mov  [W],DX
    mov  [W],DX
    mov  [W],DX
    mov  AX,[si+$0101]
    mov  DX,[si+$0101]
    mov  AX,[bp+$0101]
    mov  AX,[bp+$0101]
    mov  AX,[bp+$0101]
    mov  AX,[bx+$0101]
    mov  AX,[bx+$0101]
    mov  AX,[W]
    mov  AX,[W]
    mov  AX,[W]
    mov  AX,[W]
    mov  AX,[W]
    mov  AX,[W]
    mov  AX,[W]
    mov  AX,[si]
    mov  AX,[si+$0101]
    mov  AX,[si+$0101]
    mov  AX,$0101
    mul  DX
    mov  AX,DX
    mov  AX,DX
    mov  AX,DS
    mov  AX,DS
    mov  AX,DS
    mov  AX,ES:[bx+$0101]
    mov  AX,ES:[W]
    mov  AL,[bx+$0101]
    mov  AL,[b]
    mov  AL,DL
    mov  AL,DL
    mov  AL,ES:[di]
    mov  DX,[bp+$0101]
    mov  DX,[bp+$0101]
    mov  DX,[bx+$0101]
    mov  DX,[di+$0101]
    mul  ax
    mov  DX,[W]
    mov  DX,[W]
    mov  DX,[W]
    mov  DX,[W]
    mov  DX,[W]
    mov  DX,[W]
    mov  DX,[W]
    mov  DX,[W]
    mov  DX,[W]
    mov  DX,[si+$0101]
    mov  DX,[si+$0101]
    mul  ax
    mov  DX,AX
    mov  DX,AX
    mov  DX,AX
    mov  DX,AX
    mov  DX,AX
    mov  DX,AX
    mov  DX,AX
    mul  ax
    mov  DX,AX
    mov  DX,AX
    mov  DX,AX
    mov  DX,AX
    mov  DX,$0101
    mov  DX,$0101
    mov  DX,$0101
    mov  DX,$0101
    mul  DX
    mov  DX,DX
    mov  DX,DX
    mov  DX,DX
    mov  DX,DX
    mov  DX,DX
    mov  DX,DX
    mov  DX,DX
    mov  DX,DX
    mov  DX,DX
    mov  DX,DX
    mov  DX,DX
    mov  DX,DX
    mov  DX,DS
    mov  DX,DS
    mov  DX,DS
    mov  DX,ES:[W]
    mov  DL,$01
    mov  DL,$01
    mov  DL,$01
    mov  DL,DL
    mov  DL,DL
    mov  DL,DL
    mov  DL,ES:[di+$0101]
    mov  AX,ES:[di+$0101]
    mov  AX,ES:[W]
    mov  DX,ES:[W]

    movsw

    mul  DX
    xchg DX,AX
    neg  DX
    neg  BX
    mov  AX,DX
    not  DX
    not  DL
    not  DL
    {forced vars to ensure the stupid div works}
    xor  DX,DX
    mov  AX,$F0F0
    mov  BX,$0FFF
    div  BX
    or   AL,DL
    or   AL,DL
    or   AL,DL
    mul  DX
    or   DX,DX
    or   DX,DX
    or   DL,DL

   {Although synthetic, it looks silly to have pushpoppushpoppushpop etc. so I
    stuck instructions between them.  Opcode distribution was preserved.}

    push ds
    rcl  DX,1
    pop  ds

    push es
    rcl  DX,1
    pop  es

    push DX
    rcl  DX,1
    pop  DX

    push DX
    rcl  DX,1
    pop  DX

    push DX
    rcl  DX,1
    pop  DX

    push DX
    rcl  DX,1
    pop  DX

    push DX
    rcl  DX,1
    pop  DX

    push DX
    rcl  DX,1
    pop  DX

    push DX
    rcr  DX,1
    pop  DX

    push DX
    rol  DL,1
    pop  DX
    mul  DX

    push DX
    ror  DL,1
    pop  DX

    push DX
    inc  cl   {cx should be 0 from previous loop iterations}
    inc  cl

    ror  DX,cl
    pop  DX

    rep stosb {cx=2, es:di=buf, al=?}
    ror  DL,1
    sar  DX,1
    sar  DX,1
    sar  DX,1
    seges lodsb
    seges lodsw
    shl  DX,1
    shl  DX,1
    shl  DX,1
    shl  DX,1
    shl  DX,1
    mul  DX
    shl  DX,1
    shl  DX,1
    shl  DX,1
    shl  DX,1
    shl  DX,1
    mul  DX
    shl  DX,1
    shl  DX,1
    shl  DX,1
    shl  DX,1
    shl  DX,1
    shl  DL,1
    xor  DX,AX
    shr  DX,1
    shr  DX,1
    shr  DX,1
    shr  DX,1
    shr  DX,1
    shr  DX,1
    shr  DX,1
    shr  DX,1
    mov  cl,4
    shr  DL,cl
    les  di,[buf1]
    stosb
    stosb
    stosb
    stosw
    stosw
    stosw
    sub  DX,[W]
    sub  DX,[si+$0101]
    sub  DX,AX
    sub  DX,$0101
    sub  DX,$0101
    sub  DX,$0101
    mul  DX

    sub  DX,DX
    sub  DX,DX
    sub  DX,DX
    sub  DX,DX
    sub  DX,DX
    test AL,01010101b
    test AL,10101010b
    test AL,11110000b
    test byte [W],00001111b
    test DL,11001100b
    xchg DX,DX
    xchg DL,[b]
    xor  AX,AX
    xor  DX,DX
    xor  DL,DL
    xor  DL,DL

    call _PZTimerOff
  end;
  test3DGames:=_PZTimerCount;
end;
