/*****************************************************************************
 * CPU.C        TMi0SDGL Release 2 Demonstration program        Version 2.15
 *
 * Too-Much-in-0ne-So-Don't-Get-Lost(tm) Revision 2 CPU/FPU Detection Library
 * Copyright(c) 1996-2000 by B-coolWare. Written by Bobby Z.
 *****************************************************************************/

#include <stdio.h>
#include "tmi0sdgl.h"

char * Weitek[2] = {"","and Weitek coprocessor"};

int wCheck( void );

int wCheck()
{
 if ((extFlags & efWeitekPresent) == efWeitekPresent)
  return 1;
 else
  return 0;
}

int cdecl main( void )
{
 puts("CPU Type Identifier/C  Version 2.15  Copyright(c) 1996-2000 by B-coolWare.");
#ifdef BetaBuild
 puts("*** BETA Build, do not distribute ***");
#endif
 printf("Processor: %s, %dMHz\nMath unit: %s %s\n",cpu_Type(),ncpu_Speed(),fpu_Type(),Weitek[wCheck()]);
 return cpu;
}
