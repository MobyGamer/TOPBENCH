{$N+,E+}
Program BenchmarkExample;

Uses Bench, ExampleGlobal, crt, DetectSystem;

Var F : Text;

Begin
  If Not ((ParamCount = 2) And (ParamStr (1) = 'P')) Then
    Begin
      Rahmen (1,1,80,25,' Benchmarks (...der Detecting Unit fÅr Pascal 1.17-· BETA) ');
      Window (2,2,79,24);
      WriteLn ('Berechne Integer Dhrystones ...');
      GotoXY (WhereX, WhereY-1);
      WriteLn ('Integer-DhryStones : ', DhryStones:0:1, ' (', DhryStonesXT:0:1,'-faches vom XT)');
      WriteLn ('Berechne Double Whetstones ...');
      GotoXY (WhereX, WhereY-1);
      WriteLn ('Double-Precision WhetStones : ', WhetStones:0:1, ' (', WhetStonesXT:0:1,'-faches vom XT)');
      WriteLn ('Berechne Double LLL MFlops ...');
      GotoXY (WhereX, WhereY-1);
      WriteLn ('Double-Precision LLL MFLOPS : ', MFLOPS:0:3, ' (', WhetStonesXT:0:1,'-faches vom XT)');
      WriteLn ('Berechne Double Peak MFlops ...');
      GotoXY (WhereX, WhereY-1);
      WriteLn ('Double-Precision Peak MFLOPS : ', PeakMFLOPS:0:3);
      WriteLn ('Berechne Double Transformation MFlops ...');
      GotoXY (WhereX, WhereY-1);
      WriteLn ('Double-Precision Transformation MFLOPS : ', TransFormMFLOPS:0:4);

      If (WhatCoPro = 9) Or (WhatCopro = 10) Then
        Begin
          { Spezielles Transform Benchmark fÅr die IIT-Prozessoren (neuer
            Befehl) }
          Write ('Double-Precision Transformation MFLOPS/IIT : ', TransFormMFLOPSIIT:0:4);
        End;
      WaitKey;
    End
  Else
    Begin
      System.Assign (F, ParamStr(2));
      System.Append (F);

      WriteLn (F);
      WriteLn (F);
      WriteLn (F, '-     -    -  - - -- Benchmarks -- - -  -   -     -');
      WriteLn (F);

      Write (F, 'Integer-DhryStones                       : ');
      WriteLn (F, DhryStones:0:1, ' (', DhryStonesXT:0:1,'-faches vom XT)');
      Write (F, 'Double-Precision WhetStones              : ');
      WriteLn (F, WhetStones:0:1, ' (', WhetStonesXT:0:1,'-faches vom XT)');
      Write (F, 'Double-Precision LLL MFLOPS              : ');
      WriteLn (F, MFLOPS:0:3, ' (', WhetStonesXT:0:1,'-faches vom XT)');
      WriteLn (F, 'Double-Precision Peak MFLOPS             : ', PeakMFLOPS:0:3);
      WriteLn (F, 'Double-Precision Transformation MFLOPS   : ', TransFormMFLOPS:0:4);

      If (WhatCoPro = 9) Or (WhatCopro = 10) Then
        Begin
          { Spezielles Transform Benchmark fÅr die IIT-Prozessoren (neuer
            Befehl) }
          Write (F, 'Double-Precision Transformation MFLOPS/IIT   : ', TransFormMFLOPSIIT:0:4);
        End;

      System.Close (F);
    End;
  Window (1,1,80,25);
  ClrScr;
End.
