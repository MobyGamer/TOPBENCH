{ Diese Unit kommt aus Norbert Juffas CompTest und ermittelt die MFLOPS
  (Million FLoating Point Operations per Second).                       }

{$A+,B-,D-,E+,F-,G-,I-,L-,N+,O-,R-,S-,V-,X-}
{$M 4096,0,655360}

Unit Detectlll;

{    LAWRENCE LIVERMORE LOOPS (LLL)


     PORTED TO TURBO-PASCAL 5.0 AND ENHANCED TO ALLOW FOR VARIABLE
     LOOPING 89-05-27 BY N.J.

***********************************************************************

     PROGRAM ANALYSIS EVALUATES EXECUTION RATES OF PASCAL FOR-LOOPS.
     THROUGH-PUT IS MEASURED IN UNITS OF MILLIONS OF FLOATING-POINT
     OPERATIONS PER SECOND, CALLED MFLOPS.


***********************************************************************

***********************************************************************}

interface

FUNCTION MFlops (Emu: BOOLEAN; Index: DOUBLE): DOUBLE;

implementation

USES DetectTime;


VAR
REPS: WORD;
NT,IR,IX,IZ13,IZ14,IP,
I1,J1,I2,J2,NL1,NL2,
I,J,K,L,M,K1,KX,KY,LW,
IT1:                     LONGINT;
S,RI,XI,DU1,DU2,DU3,
Q,R,T,A11,A12,A13,
SIG,A21,A22,A23,A31,
A32,A33,BM28,BM27,
AR,BR,CR,BM26,BM25,BM24,
BM23,BM22,C0,FLX,RX1:    DOUBLE;
IDT,MOPS:                ARRAY [1..20] OF LONGINT;
RT,RPM:                  ARRAY [1..20] OF DOUBLE;
X,Y,Z,U:                 ARRAY [1..1000] OF DOUBLE;
PX,CX:                   ARRAY [1..15,1..100] OF DOUBLE ABSOLUTE Z;
U1,U2,U3:                ARRAY [1..22,1..5,1..2] OF DOUBLE;
B,C,H:                   ARRAY [1..64,1..8] OF DOUBLE;
BNK1,BNK2,BNK3,BNK4,BNK5:ARRAY [1..5] OF DOUBLE;
P:                       ARRAY [1..4,1..512] OF DOUBLE ABSOLUTE X;
E,F:                     ARRAY [1..192] OF LONGINT;
EX,RH,DEX:               ARRAY [1..67] OF DOUBLE;
VX,XX:                   ARRAY [1..150] OF DOUBLE;

CONST

NROPS: ARRAY [1..20] OF LONGINT =
       (5,10,2,3,2,2,16,36,17,9,1,1,7,11,0,0,0,0,0,0);
LOOPS: ARRAY [1..20] OF LONGINT =
       (400,200,1000,343,996,996,120,40,100,100,999,999,128,150,0,0,0,0,0,0);


{***********************************************************************}
FUNCTION MFlops (Emu: BOOLEAN; Index: DOUBLE): DOUBLE;

BEGIN

   IF Emu THEN
      Reps := 1
   ELSE
      Reps := Round (Index / 3 + 1);

   FOR K := 1 TO 1000 DO BEGIN
      U[K] := 0.00025;
      X[K] := 1.11;
      Y[K] := 1.123;
      Z[K] := 0.321;
   END;

   FOR J := 1 TO 22 DO BEGIN
      FOR K := 1 TO 5 DO BEGIN
         FOR L := 1 TO 2 DO BEGIN
            U1[J,K,L] := K;
            U2[J,K,L] := K + K;
            U3[J,K,L] := K + K + K;
         END;
      END;
   END;


   FOR J := 1 TO 64 DO BEGIN
      FOR K := 1 TO 8 DO BEGIN
         B[J,K] := 1.00025;
         C[J,K] := 1.00025;
         H[J,K] := 1.00025;
      END;
   END;

   FOR J := 1 TO 5 DO BEGIN
      BNK1[J] := J*100;
      BNK2[J] := J*110;
      BNK3[J] := J*120;
      BNK4[J] := J*130;
      BNK5[J] := J*140;
   END;

   FOR J := 1 TO 192 DO BEGIN
      E[J] := 1;
      F[J] := 1;
   END;


   FOR J := 1 TO 67 DO BEGIN
      EX[J] := J;
      RH[J] := J;
      DEX[J]:= J;
   END;

   FOR J := 1 TO 150 DO BEGIN
      VX[J] := 0.001;
      XX[J] := 0.001;
   END;

   R := 4.86;
   T := 276.0;
   A11 := 0.5;
   A12 := 0.33;
   A13 := 0.25;
   SIG := 0.8;
   A21 := 0.20;
   A22 := 0.167;
   A23 := 0.141;
   A31 := 0.125;
   A32 := 0.111;
   A33 := 0.10;
   BM28 := 0.1;
   BM27 := 0.2;
   BM26 := 0.3;
   BM25 := 0.4;
   BM24 := 0.5;
   BM23 := 0.6;
   BM22 := 0.7;
   C0 := 0.8;
   FLX := 4.689;
   RX1 := 64.0;

{********************************************************************

     END OF INITIALIZATION--BEGIN TIMING

{********************************************************************}

{*** LOOP 1    HYDRO EXCERPT }

      IT1 := CLOCK;
      FOR K1 := 1 TO REPS DO BEGIN
         Q := 0.0;
         I := 10;
         FOR K := 1 TO 400 DO BEGIN
            X[K] := Q+Y[K]*(R*Z[K+I]+T*Z[K+I+1]);
         END;
      END;
      IDT[1] := CLOCK - IT1;

{*********************************************************************}

{*** LOOP2     MLR, INNER PRODUCT }

      IT1 := CLOCK;
      FOR K1 := 1 TO REPS DO BEGIN
         Q := 0.0;
         K := 1;
         WHILE K <= 996 DO BEGIN
            Q := Q+Z[K  ]*X[K  ]+Z[K+1]*X[K+1]
                  +Z[K+2]*X[K+2]+Z[K+3]*X[K+3]
                  +Z[K+4]*X[K+4];
            INC (K,5);
         END;
      END;
      IDT [2] := CLOCK - IT1;

{*********************************************************************}

{*** LOOP 3    INNER PROD }

      IT1 := CLOCK;
      FOR K1 := 1 TO REPS DO BEGIN
         Q := 0.0;
         FOR K := 1 TO 1000 DO BEGIN
            Q := Q+Z[K]*X[K];
         END;
      END;
      IDT[3] := CLOCK - IT1;

{*********************************************************************}

{*** LOOP 4    BANDED LINEAR EQUATIONS }

      IT1 := CLOCK;
      FOR K1 := 1 TO REPS DO BEGIN
         L := 7;
         WHILE L <= 107 DO BEGIN
            LW := L;
            J := 30;
            WHILE J <= 870 DO BEGIN
               X[L-1] := X[L-1] - X[LW]*Y[J];
               INC (J,5);
               INC (LW);
            END;
            X[L-1] := Y[5]*X[L-1];
            INC (L,50);
         END;
      END;
      IDT[4] := CLOCK - IT1;

{*********************************************************************}

{*** LOOP5 }

      IT1 := CLOCK;
      FOR K1 := 1 TO REPS DO BEGIN
         I := 2;
         WHILE I <= 997 DO BEGIN
            X[I  ] := Z[I  ]*(Y[I  ]-X[I-1]);
            X[I+1] := Z[I+1]*(Y[I+1]-X[I  ]);
            X[I+2] := Z[I+2]*(Y[I+2]-X[I+1]);
            INC (I,3);
         END;
      END;
      IDT[5] := CLOCK - IT1;

{*********************************************************************}

{*** LOOP6     TRI-DIAGONAL ELIMINATION, ABOVE DIAGONAL }

      IT1 := CLOCK;
      FOR K1 := 1 TO REPS DO BEGIN
         J := 3;
         WHILE J <= 997 DO BEGIN
            I := 1000-J;
            X[I  ] := X[I  ]-Z[I  ]*X[I+1];
            X[I-1] := X[I-1]-Z[I-1]*X[I  ];
            X[I-2] := X[I-2]-Z[I-2]*X[I-1];
            INC (J,3);
         END;

{ THE FOLLOWING LOOP HAS BEEN INSERTED AT THE UNIVERSITY
  OF COLOGNE, BECAUSE IN THE ORIGINAL VERSION LOOP 6 ABORTED
  WITH EXPONENT OVERFLOW ON IBM SYSTEMS. }
(*
         FOR J := 2 TO 997 DO BEGIN
            X[J]:=X[J]*0.6666;
         END;
*)
      END;

      IDT[6] := CLOCK - IT1;

{*********************************************************************}

{*** LOOP7     EQUATION OF STATE EXCERPT }

      IT1 := CLOCK;
      FOR K1 := 1 TO REPS DO BEGIN
         FOR M := 1 TO 120 DO BEGIN
            X[M] :=    U[M  ] + R*(Z[M  ] + R*Y[M  ])
                   +T*(U[M+3] + R*(U[M+2] + R*U[M+1])
                   +T*(U[M+6] + R*(U[M+5] + R*U[M+4])));
         END;
      END;
      IDT[7] := CLOCK - IT1;

{*********************************************************************}

{*** LOOP 8    P.D.E INTEGRATION }

      IT1 := CLOCK;
      NL1 := 1;
      NL2 := 2;
      FOR K1 := 1 TO REPS DO BEGIN
         FOR KX := 2 TO 3 DO BEGIN
            FOR KY := 2 TO 21 DO BEGIN
               DU1 := U1[KY+1,KX,NL1] - U1[KY-1,KX,NL1];
               DU2 := U2[KY+1,KX,NL1] - U2[KY-1,KX,NL1];
               DU3 := U3[KY+1,KX,NL1] - U3[KY-1,KX,NL1];
               U1[KY,KX,NL2] := U1[KY,KX,NL1] + A11*DU1+A12*DU2 + A13*DU3 +
                 SIG*(U1[KY,KX+1,NL1] - 2.*U1[KY,KX,NL1]+U1[KY,KX-1,NL1]);
               U2[KY,KX,NL2] := U2[KY,KX,NL1] + A21*DU1+A22*DU2 + A23*DU3 +
                 SIG*(U2[KY,KX+1,NL1] - 2.*U2[KY,KX,NL1]+U2[KY,KX-1,NL1]);
               U3[KY,KX,NL2] := U3[KY,KX,NL1] + A31*DU1+A32*DU2 + A33*DU3 +
                 SIG*(U3[KY,KX+1,NL1] - 2.*U3[KY,KX,NL1]+U3[KY,KX-1,NL1]);
            END;
         END;
      END;
      IDT[8] := CLOCK - IT1;

{*********************************************************************}

{*** LOOP 9    INTEGRATE PREDICTORS }

      FOR K := 1 TO 15 DO BEGIN
         FOR L := 1 TO 100 DO BEGIN
            PX[K,L] := L;
            CX[K,L] := L;
         END;
      END;

      IT1 := CLOCK;
      FOR K1 := 1 TO REPS DO BEGIN
         FOR I := 1 TO 100 DO BEGIN
            PX[1,I] := BM28*PX[13,I] + BM27*PX[12,I] + BM26*PX[11,I] +
                       BM25*PX[10,I] + BM24*PX[9,I] + BM23*PX[8,I] +
                       BM22*PX[7,I] + C0*(PX[5,I] + PX[6,I])+PX[3,I];
         END;
      END;
      IDT[9] := CLOCK - IT1;

{*********************************************************************}

{*** LOOP 10   DIFFERENCE PREDICTORS }

      IT1 := CLOCK;
      FOR K1 := 1 TO REPS DO BEGIN
         FOR I := 1 TO 100 DO BEGIN
            AR     :=      CX[5,I];
            BR     := AR - PX[5,I];
            PX[5,I]:= AR;
            CR     := BR - PX[6,I];
            PX[6,I]:= BR;
            AR     := CR - PX[7,I];
            PX[7,I]:= CR;
            BR     := AR - PX[8,I];
            PX[8,I]:= AR;
            CR     := BR - PX[9,I];
            PX[9,I]:= BR;
            AR     := CR - PX[10,I];
            PX[10,I]:=CR;
            BR     := AR - PX[11,I];
            PX[11,I]:=AR;
            CR     := BR - PX[12,I];
            PX[12,I]:=BR;
            PX[14,I]:=CR - PX[13,I];
            PX[13,I]:=CR;
         END;
      END;
      IDT[10] := CLOCK - IT1;

{*********************************************************************}

{*** LOOP 11   FIRST SUM }

      IT1 := CLOCK;
      FOR K1 := 1 TO REPS DO BEGIN
         X[1] := Y[1];
         FOR K := 2 TO 1000 DO BEGIN
            X[K] := X[K-1]+Y[K];
         END;
      END;
      IDT[11] := CLOCK - IT1;

{*********************************************************************}

{*** LOOP 12   FIRST DIFF. }

      IT1 := CLOCK;
      FOR K1 := 1 TO REPS DO BEGIN
         FOR K := 1 TO 999 DO BEGIN
            X[K] := Y[K+1]-Y[K];
         END;
      END;
      IDT[12] := CLOCK - IT1;

{*********************************************************************}

{*** LOOP 13   2-D PARTICLE PUSHER }

      IT1 := CLOCK;
      FOR K1 := 1 TO REPS DO BEGIN
         FOR J := 1 TO 4 DO BEGIN
            FOR K := 1 TO 512 DO BEGIN
               P[J,K] := 1.00025;
            END;
         END;
         FOR IP := 1 TO 128 DO BEGIN
            I1 := TRUNC (P[1,IP]);
            J1 := TRUNC (P[2,IP]);
            P[3,IP] := P[3,IP] + B[I1,J1];
            P[4,IP] := P[4,IP] + C[I1,J1];
            P[1,IP] := P[1,IP] + P[3,IP];
            P[2,IP] := P[2,IP] + P[4,IP];
            I2 := TRUNC (P[1,IP]);
            J2 := TRUNC (P[2,IP]);
            P[1,IP] := P[1,IP] + Y[I2+32];
            P[2,IP] := P[2,IP] + Z[J2+32];
            I2 := I2 + E[I2+32];
            J2 := J2 + F[J2+32];
            H[I2,J2] := H[I2,J2] + 1.0;
         END;
      END;
      IDT[13] := CLOCK;
      FOR K1 := 1 TO REPS DO BEGIN
         FOR J := 1 TO 4 DO BEGIN
            FOR K := 1 TO 512 DO BEGIN
               P[J,K] := 1.00025;
            END;
         END;
      END;
      IDT[20] := CLOCK;
      IZ13 := IDT[20] - IDT[13];
      IDT[13] := 2*IDT[13] - IT1 - IDT[20];

{*********************************************************************}

{*** LOOP 14   1-D PARTICLE PUSHER }

      IT1 := CLOCK;
      FOR K1 := 1 TO REPS DO BEGIN
         FOR J := 1 TO 150 DO BEGIN
            VX[J] := 0.001;
            XX[J] := 0.001;
         END;
         FOR K := 1 TO 150 DO BEGIN
            IX := 3+(K DIV 8);
            XI := IX;
            VX[K] := VX[K]+ EX[IX] + (XX[K]-XI) * DEX[IX];
            XX[K] := XX[K]+ VX[K] + FLX;
            IR := TRUNC(XX[K]);
            RI := IR;
            RX1:= XX[K]-RI;
            IR := ABS (IR) AND 63;
            XX[K]   := RI+RX1;
            RH[IR]  := RH[IR] + 1.0 - RX1;
            RH[IR+1]:= RH[IR+1] + RX1;
         END;
      END;
      IDT[14] := CLOCK;
      FOR K1 :=1 TO REPS DO BEGIN
         FOR J := 1 TO 150 DO BEGIN
            VX[J] := 0.001;
            XX[J] := 0.001;
         END;
      END;
      IDT[20] := CLOCK;
      IZ14 := IDT[20] - IDT[14];
      IDT[14] := 2*IDT[14] - IT1 - IDT[20];

{*********************************************************************}

{****TIME THE CLOCK CALL }
{****CLOCK ROUTINE ARGUMENT IS MILLISECONDS }

      IT1 := CLOCK;
      IDT[15] := CLOCK;
      IDT[15] := IDT[15] - IT1;
      NT := 14;
         T := 0.0;
         S := 0.0;
         U[1] := 0.0;
      FOR K := 1 TO NT DO BEGIN
         RT[K] := IDT[K] - IDT[15];
         T := T + RT[K];
         MOPS [K] := NROPS [K] * LOOPS[K];
         S := S + MOPS [K];
         RPM [K] := 0.0;
         IF RT[K] <> 0 THEN
            RPM[K] := REPS*MOPS[K]/RT[K]/1000.0;
         U[1] := U[1] + RPM[K];
      END;
      U[1] := U[1]/NT;
      S := S/T;

      MFlops := U [1];
   END;

Begin
END.
