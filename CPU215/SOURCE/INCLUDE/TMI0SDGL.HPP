///////////////////////////////////////////////////////////////////////////////
// TMi0SDGL.HPP - CPU and FPU classes interface, TMi0SDGL 2     Version 2.15 //
//                                                                           //
// Too-Much-in-0ne-So-Don't-Get-Lost(tm) Revision 2 CPU/FPU Detection Library//
// Copyright(c) 1996-2000 by B-coolWare.  Written by Bobby Z.                //
///////////////////////////////////////////////////////////////////////////////

#ifndef __TMi0SDGL_HPP  // avoid reinclusion of this file
#define __TMi0SDGL_HPP

#ifndef __STRING_H
#include <string.h>
#endif
#ifdef __Win32__
#ifndef __CONSTREA_H
#include <constrea.h>
#endif
#else
#ifndef __IOSTREAM_H
#include <iostream.h>
#endif
#endif
#include "tmi0sdgl.h"

class cCPU {
       public:
        char *Name;
        unsigned int MHz;
        char *SerialNumber;
#ifndef __Win32__
        unsigned int CacheSize;
#endif
       cCPU(){
              Name = new char[strlen(cpu_Type())+1];
              SerialNumber = new char[strlen(getCPUSerialNumber()) + 1];
              strcpy(Name,cpu_Type());
              strcpy(SerialNumber, getCPUSerialNumber());
              MHz = ncpu_Speed();
#ifndef __Win32__
              if (cpu >= i486SX)
               CacheSize = getCacheSize();
              else
               CacheSize = 0;
#endif
            }
       ~cCPU() {
                 delete Name;
                 delete SerialNumber;
                }
      };

ostream& operator << ( ostream& s, const cCPU& c )
 {
  return s << "Processor: " << c.Name << ", " << c.MHz << "MHz\n";
 }

class cFPU {
       public:
        char *Name;
        cFPU(){
               Name = new char[strlen(fpu_Type())+1];
               strcpy(Name,fpu_Type());
             }
        ~cFPU() { delete Name; }
       };

static char * Weitek[2] = {""," and Weitek coprocessor"};

int wCheck( void );

int wCheck( void )
 {
  if((extFlags & efWeitekPresent) == efWeitekPresent)
   return 1;
  else
   return 0;
 }

ostream& operator << ( ostream& s, const cFPU& f )
 {
  return s << "Math unit: " << f.Name << Weitek[wCheck()] << "\n";
 }

#endif // __TMi0SDGL_HPP
