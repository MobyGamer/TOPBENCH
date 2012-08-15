{ Dies ist die unmodifizierte Whet-Stone Routine von AJH Sale und der
  British Standards Institution, Version vom 24.02.1988. Diese Unit kommt
  aus Norbert Juffas CompTest.                                            }

{$A+,B-,D-,E+,F-,G-,I-,L-,N+,O-,R-,S-,V-,X-}
{$M 4096,0,655360}

UNIT DetectWhet;

INTERFACE

Uses DetectTime;

FUNCTION WhetStone (Emu: BOOLEAN; Index: DOUBLE): DOUBLE;

IMPLEMENTATION

{ (C) Copyright, A H J Sale and British Standards Institution, 1982 }
{TEST 1.2-1, CLASS=QUALITY}

{: This program is a general check on execution speed. }
{  For details, see Computer Journal article, 'A Synthetic
   Benchmark', Jan 1976  pp43-49. }
{V3.0: New test. }
{V5.1: Modified to introduce validation checks, 88-02-24}

{ The validation checks added have been made to avoid printing
values out which have no obvious purpose. In conversion to other
languages, the printing may cause timing problems. Merely
removing the printing statements is inadequate since then an
optimizing compiler could remove many of the modules completely. }

{ For details of checks and changes to avoid some problems,
  see NPL report DITC 107/88. }

type
    real = double;
    rlarray = array [ 1 .. 4 ] of real;

const
    t = 0.499975;
    t1 = 0.50025;
    t2 = 2.0;


var
    start, stop: integer;
    wt: integer;  { Determines length of execution }
    x, y, z, norm, t3, estimate: real;
    xx: record
        one, two, three, four: real
        end;
    e1: rlarray;
    i, jj, kk, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11: integer;
    ij, ik, il: 1 .. 4;
    fail: boolean;



    procedure pa(var e: rlarray);
        label 1;
        var j: integer;
        begin
        j := 0;
      1 :
        e[1] := (e[1] + e[2] + e[3] - e[4]) * t;
        e[2] := (e[1] + e[2] - e[3] + e[4]) * t;
        e[3] := (e[1] - e[2] + e[3] + e[4]) * t;
        e[4] := ( - e[1] + e[2] + e[3] + e[4]) / t3; {changed from t2}
        j := j + 1;
        if j < 6 then
            goto 1
        end; {pa}

    procedure p0;
        begin
        e1[ij] := e1[ik];
        e1[ik] := e1[il];
        e1[il] := e1[ij];
        end; {p0}

    procedure p3(x, y: real; var z: real);
        begin
        x := t * (z + x);
        y := t * (x + y);
        z := (x + y) / t2
        end; {p3}

    procedure Check(ModuleNo: integer; Condition: Boolean);
        begin
        if not Condition then
           begin
           writeln('Module ', ModuleNo:1, ' has not produced the expected',
                   ' results');
           writeln('Check listing and compare with Pascal version');
           fail := true
           end
        end;

FUNCTION WhetStone (Emu: BOOLEAN; Index: DOUBLE): DOUBLE;

BEGIN
    IF Emu THEN
       wt := 1
    ELSE
       wt := Round (index / 3 + 1); { 10 corresponds to one million Whetstone
                 instructions
                 value shouldbe read to avoid the loop counters being
                 taken as constant. }
    fail := false;
(*    Check( 0, (wt >= 1) and (wt <= 100) );*)
    n1 := 2 * wt;
    n2 := 10 * wt;
    n3 := 14 * wt;
    n4 := 345 * wt;
    n5 := 0;
    n6 := 95 * wt;
    n7 := 32 * wt;
    n8 := 800 * wt;
    n9 := 616 * wt;
    n10 := 0;
    n11 := 93 * wt;

    start := clock;

    { module 1: simple identifiers}
    xx.one := 1.0;
    xx.two := -1.0;  xx.three := -1.0;  xx.four := -1.0;
    for i := 1 to n1 do
        begin
        xx.one := (xx.one + xx.two + xx.three - xx.four) * t;
        xx.two := (xx.one + xx.two - xx.three + xx.four) * t;
        xx.three := (xx.one - xx.two + xx.three + xx.four) * t;
        xx.four := ( - xx.one + xx.two + xx.three + xx.four) * t
        end; {module 1}
    with xx do
        norm := sqrt(sqr(one)+sqr(two)+sqr(three)+sqr(four));
(*    Check(1, abs(norm - exp(0.35735-n1*6.1e-5))/norm <= 0.1 );*)

    { module 2: array elements}
    e1[1] := 1.0;
    e1[2] := -1.0;  e1[3] := - 1.0;  e1[4] := - 1.0;
    for i := 1 to n2 do
        begin
        e1[1] := (e1[1] + e1[2] + e1[3] - e1[4]) * t;
        e1[2] := (e1[1] + e1[2] - e1[3] + e1[4]) * t;
        e1[3] := (e1[1] - e1[2] + e1[3] + e1[4]) * t;
        e1[4] := ( - e1[1] + e1[2] + e1[3] + e1[4]) * t
        end; {module 2}
(*    norm := sqrt(sqr(e1[1])+sqr(e1[2])+sqr(e1[3])+sqr(e1[4]));*)
(*    Check(2, abs(norm - exp(0.35735-n2*6.1e-5))/norm <= 0.1);*)

    { module 3: array as parameter}
    t3 := 1.0/t;
    for i := 1 to n3 do
        pa(e1);
(*    norm := sqrt(sqr(e1[1])+sqr(e1[2])+sqr(e1[3])+sqr(e1[4]));*)
(*    Check(3, abs(norm - exp(0.35735-(n3*5+n2)*6.1e-5))/norm <= 0.1 );*)

    { module 4: conditional jumps}
    jj := 1;
    for i:= 1 to n4 do
        begin
        if jj = 1 then
            jj := 2
        else
            jj := 3;
        if jj > 2 then
            jj := 0
        else
            jj := 1;
        if jj < 1 then
            jj := 1
        else
            jj := 0
        end; {module 4}
(*    Check( 4, jj = ord(not odd(wt) ) );*)

    { module 5: omitted}

    { module 6: integer arithmetic}
    ij := 1;
    ik := 2;
    il := 3;
    for i := 1 to n6 do
        begin
        ij := ij * (ik - ij) * (il - ik);
        ik := il * ik - (il - ij) * ik;
        il := (il - ik) * (ik + ij);
        e1[il - 1] := ij + ik + il;
        e1[ik - 1] := ij * ik * il
        end; {module 6}
(*    Check( 6, (ij=1) and (ik=2) and (il=3) );*)

    {module 7: trig. functions) }
    x := 0.5;  y := 0.5;
    for i := 1 to n7 do
        begin
        x := t * arctan(t2 * sin(x) * cos(x) /
                        (cos(x + y) + cos (x - y) - 1.0));
        y := t * arctan(t2 * sin(y) * cos(y) /
                        (cos(x + y) + cos (x - y) - 1.0))
        end; {module 7}
(*    Check(7, (t - wt* 0.0015 <= x) and
             (x <= t - wt* 0.0004) and
             (t - wt* 0.0015 <= y) and
             (y <= t - wt* 0.0004) );*)

    {module 8: procedure calls}
    x := 1.0;  y := 1.0; z := 1.0;
    for i := 1 to n8 do
        p3(y * i, y + z, z);
(*    Check(8, abs(z - (0.99983352*n8 - 0.999555651)) <= n8*1.0e-6);*)

    (* module 9: array references*)
    ij := 1;
    ik := 2;
    il := 3;
    e1[1] := 1.0;
    e1[2] := 2.0;
    e1[3] := 3.0;
    for i := 1 to n9 do
        p0;
(*    Check(9, (e1[1] = 3.0) and (e1[2] = 2.0) and (e1[3] = 3.0) );*)

    { module 10: integer arithmetic}
    jj := 2;
    kk := 3;
    for i := 1 to n10 do
        begin
        jj := jj + kk;
        kk := jj + kk;
        jj := kk - jj;
        kk := kk - jj - jj;
        end; {module 10}
(*    Check(10, (jj=2) and (kk=3) );*)

    { module 11: standard functions}
    x := 0.75;
    for i := 1 to n11 do
        x := sqrt (exp(ln(x) / t1));
(*    estimate := 1.0 - exp(-0.0447*wt + ln(0.26));*)
(*    Check( 11, (abs(estimate-x)/estimate
                  <= 0.0006 + 0.065/(5+wt) ));*)

    stop := clock - start;
    WhetStone := (100*wt/(stop*1e-3));
end;

Begin
END. { Whet }




