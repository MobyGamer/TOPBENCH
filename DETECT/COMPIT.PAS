Program CompIt;

Uses Detect, DetectConstants, DetectGlobal, DetectBios, Bench,
     ExampleGlobal, Example2;

{$I DETECT.INC}

Begin
  { Dies ist nur ein Dummy-Programm, womit man den gesamten Code der Unit(s)
    kompilieren kann. Wenn man jetzt noch die Programme EXAMPLE.PAS und
    BENCH.PAS Åbersetzt, hat man alle .TPU und .EXE Dateien. Beachten sie
    bitte, da· diese Unit nicht in den DPMI-Protected Mode Åbersetzt werden
    kann (Es wird einfach zu viel auf REALMode-Basis gemacht ...).

    Um diese Unit öbersetzen zu kînnen, bracuchen sie : Borland Pascal 7.0,
    das ObjectFile DETECTGL.OBJ oder TASM um den Source zu assemblieren,
    die Unit GRAPH und die Standard-Units Dos und Crt. Es werden keine
    .BGI-Files benîtigt. }
End.