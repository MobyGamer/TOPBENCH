{ Dieser Code stammt aus Norbert Juffas "EVERYTHING YOU ALWAYS WANTED TO
  KNOW ABOUT MATH COPROCESSORS" und wurde leicht verÑndert (fÅr die Unit). }

{$A+,B-,R-,I-,V-,N+,E+}
Unit DetectPeakFlop;

Interface

Function PeakMFlops : Double;

Implementation

USES DetectTime;

TYPE ParamRec = RECORD
                   MaxIter, MaxRad, YMax, XMax: WORD;
                   Qmax, Qmin, Pmax, Pmin: DOUBLE;
                   FastMod: WORD;
                   PlotFkt: POINTER;
                   FLOPS:LONGINT;
                END;

VAR Param: ParamRec;
    Start: LONGINT;


{$L DETECTGL.OBJ}

PROCEDURE Apple87 (VAR Param: ParamRec);     EXTERNAL;


Function PeakMFLOPS;

BEGIN
  WITH Param DO BEGIN
    MaxIter:= 50;
    MaxRad := 30;
    YMax   := 30;
    XMax   := 30;
    Pmin   :=-2.1;
    Pmax   := 1.1;
    Qmin   :=-1.2;
    Qmax   := 1.2;
    FastMod:= Word (FALSE);
    PlotFkt:= NIL;
    Flops  := 0;
  END;

  Start := Clock;
  Apple87 (Param);         { executes 104002 FLOPs }
  Start := Clock - Start;  { elapsed time in milliseconds }
  PeakMFLOPS := 104.002 / Start;
END;

Begin
End.
