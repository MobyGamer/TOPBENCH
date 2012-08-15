///////////////////////////////////////////////////////////////////////////////
// CPUDET32.HPP  C++ Header File, 32-bit DLL version            Version 2.15 //
//                                                                           //
// Too-Much-in-0ne-So-Don't-Get-Lost(tm) Revision 2 CPU/FPU Detection Library//
// Copyright(c) 1996-2000 by B-coolWare.  Written by Bobby Z.                //
///////////////////////////////////////////////////////////////////////////////

#ifdef  __CPUDET16_HPP__
 You can only include 16-bit or 32-bit header file in your application,
 not both...
#endif

#ifndef __CPUDET32_HPP__
#define __CPUDET32_HPP__

#ifndef __STRING_H
#include <string.h>
#endif
#ifndef __IOSTREAM_H
#include <iostream.h>
#endif
#include "cpudet32.h"   // import 32-bit DLL definitions

class cCPU {
       public:
        char *Name;
        int MHz;
        byte cpu;
        char *Vendor;
        char *SerialNumber;
       cCPU(){
              cpu = getCPU();
              Name = new char[strlen(cpu_Type())+1];
              Vendor = new char[13];
              SerialNumber = new char[strlen(getCPUSerialNumber())+1];
              strcpy(Name,cpu_Type());
              strcpy(Vendor, getVendorString());
              strcpy(SerialNumber, getCPUSerialNumber());
              MHz = ncpu_Speed();
             }
       ~cCPU() { delete Name;
                 delete Vendor;
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
        byte fpu;
        cFPU(){
               fpu = getFPU();
               Name = new char[strlen(fpu_Type())+1];
               strcpy(Name,fpu_Type());
             }
        ~cFPU() { delete Name; }
       };

static char * Weitek[2] = {""," and Weitek coprocessor"};

int wCheck( void );

int wCheck()
{
 if((getExtraFlags() & efWeitekPresent) == efWeitekPresent)
  return 1;
 else
  return 0;
}

ostream& operator << ( ostream& s, const cFPU& f )
 {
  return s << "Math unit: " << f.Name << Weitek[wCheck()] <<"\n";
 }


#endif  //__CPUDET32_HPP__
