///////////////////////////////////////////////////////////////////////////////
// CPU.CPP - Sample program demonstrating usage of TMi0SDGL 2   Version 2.15 //
//                                                                           //
// Too-Much-in-0ne-So-Don't-Get-Lost(tm) Revision 2 CPU/FPU Detection Library//
// Copyright(c) 1996-2000 by B-coolWare.  Written by Bobby Z.                //
///////////////////////////////////////////////////////////////////////////////
// 32-bit version compiles with:
//
// bcc32 -RT- -x- -D__Win32__ -L..\LIB -IINCLUDE -ecpucpp32.exe cpucpp.cpp cputype3.lib
//        ^    ^no exceptions                                              ^lib name
//        ^no RTTI code
// This will make a Win32 console application cpucpp32.exe.
// Doesn't work with BCPP 5.02 :( You'll have to create a console project in
// IDE, this way it compiles ok.

#ifdef __Win32__
#include <constrea.h>   // console I/O streams, for Win32 console apps
#else
#include <iostream.h>
#endif
#include "tmi0sdgl.hpp"

int cdecl main( void )
{
 cCPU CPU;
 cFPU FPU;
 cout << "CPU Type Identifier/C++  Version 2.15  Copyright(c) 1996-2000 by B-coolWare\n"
#ifdef BetaBuild
      << "*** BETA Build, do not distribute ***\n"
#endif
      << CPU << FPU;
 return cpu;
}
