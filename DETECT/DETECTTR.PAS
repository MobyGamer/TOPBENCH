{ Dieser Code stammt aus Norbert Juffas "EVERYTHING YOU ALWAYS WANTED TO
  KNOW ABOUT MATH COPROCESSORS" und wurde leicht verÑndert (fÅr eine Unit). }

{$N+,E+}
Unit DetectTransformMFLOPS;

Interface

Function TransformMFlops : Double;
Function TransformMFlopsIIT : Double;

Implementation

USES DetectTime;

CONST VectorLen = 8190;

TYPE  Vector    = ARRAY [0..VectorLen] OF DOUBLE;
      VectorPtr = ^Vector;
      Mat4      = ARRAY [1..4, 1..4] OF DOUBLE;

VAR   X       : VectorPtr;
      Y       : VectorPtr;
      Z       : VectorPtr;
      W       : VectorPtr;
      T       : Mat4;
      K       : INTEGER;
      L       : INTEGER;
      First   : INTEGER;
      Last    : INTEGER;
      Start   : LONGINT;
      Elapsed : LONGINT;

{$L DETECTGL.OBJ}

PROCEDURE MUL_4X4     (X, Y, Z, W: VectorPtr;
                       VAR T: Mat4; First, Last: INTEGER); EXTERNAL;
PROCEDURE IIT_MUL_4X4 (X, Y, Z, W: VectorPtr;
                       VAR T: Mat4; First, Last: INTEGER); EXTERNAL;

Function TransFormMFLOPS;

Begin
  GetMem (X, SizeOf (X^));
  GetMem (Y, SizeOf (Y^));
  GetMem (Z, SizeOf (Z^));
  GetMem (W, SizeOf (W^));

  FOR L := 1 TO VectorLen DO
    BEGIN
      X^ [L] := Random;
      Y^ [L] := Random;
      Z^ [L] := Random;
      W^ [L] := Random;
    END;

  X^ [0] := 1;
  Y^ [0] := 1;
  Z^ [0] := 1;
  W^ [0] := 1;

  FOR K := 1 TO 4 DO
    BEGIN
       FOR L := 1 TO 4 DO
         BEGIN
           T [K, L] := (K-1)*4 + L;
         END;
    END;

  First := 0;
  Last  := 8190;
  Start := Clock;
  MUL_4X4 (X, Y, Z, W, T, First, Last);
  Elapsed := Clock - Start;
  TransFormMFLOPS := (28.0*(Last-First+1)/1e6)/ (Elapsed*1e-3);

  FreeMem (X, SizeOf (X^));
  FreeMem (Y, SizeOf (Y^));
  FreeMem (Z, SizeOf (Z^));
  FreeMem (W, SizeOf (W^));
End;


Function TransFormMFLOPSIIT;

Begin
  GetMem (X, SizeOf (X^));
  GetMem (Y, SizeOf (Y^));
  GetMem (Z, SizeOf (Z^));
  GetMem (W, SizeOf (W^));

  FOR L := 1 TO VectorLen DO
    BEGIN
      X^ [L] := Random;
      Y^ [L] := Random;
      Z^ [L] := Random;
      W^ [L] := Random;
    END;

  X^ [0] := 1;
  Y^ [0] := 1;
  Z^ [0] := 1;
  W^ [0] := 1;

  FOR K := 1 TO 4 DO
    BEGIN
       FOR L := 1 TO 4 DO
         BEGIN
           T [K, L] := (K-1)*4 + L;
         END;
    END;

  First := 0;
  Last  := 8190;
  Start := Clock;
  IIT_MUL_4X4 (X, Y, Z, W, T, First, Last);
  Elapsed := Clock - Start;
  TransFormMFLOPSIIT := (28.0*(Last-First+1)/1e6)/ (Elapsed*1e-3);

  FreeMem (X, SizeOf (X^));
  FreeMem (Y, SizeOf (Y^));
  FreeMem (Z, SizeOf (Z^));
  FreeMem (W, SizeOf (W^));
End;


BEGIN
END.
