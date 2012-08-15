{ Diese Unit kommt aus Norbert Juffas CompTest }

{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,R-,S-,V+,X-}
{$M 4096,0,655360}
Unit DetectCaches;

{ Caches tries to determine the size of a first and a second level cache, if
  either is present. This is done by having the external function TestCache
  (or TestCache2 if the CPU is a 286 processor) perform block moves on the
  the same memory block *twice*. Block size starts with 512 bytes and is doubled
  in every iteration until block size is 512 kB. If the memory thruput drops
  sharply after a increase in block size, it is safe to assume that the
  previous block still fit into the cache, while the current block was to
  large to fit into the cache. }

Interface

Procedure CacheSize (Debug, I386: Boolean; Var FirstLevel, SecondLevel: Word;
                     Var CacheThru, Cache2Thru, MemThru: Real);

Implementation

Uses DetectGlobal;

Procedure CacheSize (Debug, I386: Boolean; Var FirstLevel, SecondLevel: Word;
                     Var CacheThru, Cache2Thru, MemThru: Real);


Var LongInfo: Array [0..10] Of LongInt;
    Info: CacheInfoPtr;
    NrValues, L, MemSize: Word;

Begin
   IF I386 THEN BEGIN
      NrValues := 10;
      Info := TestCache;
      END
   ELSE BEGIN
      NrValues := 7;
      Info := TestCach286;
      END;
   MemSize := 1;
   FOR L := 1 TO NrValues DO BEGIN
      LongInfo [L] := Info^[L];
      WHILE (L <> 1) AND (LongInfo [L] < ((19 * LongInfo [L-1]) DIV 10)) DO
         Inc (LongInfo [L], 65536);
      MemSize := MemSize * 2;
   END;
   LongInfo [0]:= LongInfo [1];
   FirstLevel  := 0;
   SecondLevel := 0;
   MemSize     := 1;
   FOR L := 1 TO NrValues DO BEGIN
      IF LongInfo [L] > ((22 * LongInfo [L-1]) DIV 10) THEN BEGIN
         IF FirstLevel = 0 THEN BEGIN
            CacheThru  := 0.5 * MemSize / (LongInfo [L-1] / ClockFreq);
            FirstLevel := MemSize DIV 2
            END
         ELSE IF SecondLevel = 0 THEN BEGIN
            Cache2Thru  := 0.5 * MemSize / (LongInfo [L-1] / ClockFreq);
            SecondLevel := MemSize DIV 2;
            END;
         END;
      IF L = NrValues THEN BEGIN
         MemThru := 1.0 * MemSize / (LongInfo [L] / ClockFreq);
         END;
      Inc (MemSize, MemSize);
   END;
END;

Begin
End.
