/*****************************************************************************
 * CPUTYPE.C    C/C++ TMi0SDGL main module                       Version 2.15
 *
 * Too-Much-in-0ne-So-Don't-Get-Lost(tm) CPU/FPU detection library.
 * Copyright(c) 1996-2000 by B-coolWare.  Written by Bobby Z.
 *****************************************************************************
 * This file contains high-level detection routines                          */

#define __LIB__         /* we're compiling with library version of header */
#include "tmi0sdgl.h"
#include <stdio.h>
#ifdef __Win32__
 #include <windows.h>
#else
 #include <stdlib.h>
 #include <string.h>
#endif

byte lo(word value)
{
 return value & 0x00FF; /* clear high byte, just to be sure */
}

byte hi(word value)
{
 return value >> 8;
}

#ifdef __Win32__
int __cdecl _sprintf( char _FAR *, const char _FAR *, ...);
#endif

int compare12( char * s )
{
 int register i;
 for (i = 0; i < 12; i++)
  if ((char)cpuid0[i] != s[i])
   return 1;
 return 0;
}

char * CyrixModel( void )
/* distinguishes Cyrix CPU model based on DIR0/DIR1 contents */
{
 byte Family;
 byte DIR0 = lo(getCyrixModel());
 byte DIR1 = hi(getCyrixModel());
 byte isTI = ((DIR1 & 0x80) != 0);
 if(extFlags & efCPUIDSupport)
  Family= (cpuid1 & 0x0F00) >> 8;
 switch(DIR0) {
  case 0:    return("Cyrix Cx486SLC");
  case 1:    return("Cyrix Cx486DLC");
  case 2:    return("Cyrix Cx486SLC2");
  case 3:    return("Cyrix Cx486DLC2");
  case 4:    return("Cyrix Cx486SRx");
  case 5:    return("Cyrix Cx486DRx");
  case 6:    return("Cyrix Cx486SRx2");
  case 7:    return("Cyrix Cx486DRx2");
  case 8:    return("Cyrix Cx486SRu");
  case 9:    return("Cyrix Cx486DRu");
  case 0x0A: return("Cyrix Cx486SRu2");
  case 0x0B: return("Cyrix Cx486DRu2");
  case 0x10: return("Cyrix Cx486S");
  case 0x11: return("Cyrix Cx486S2");
  case 0x12:
  case 0x14:
  case 0x16: return("Cyrix Cx486Se");
  case 0x13:
  case 0x15:
  case 0x17: return("Cyrix Cx486S2e");
  case 0x1A:
             extFlags |= efHasFPUonChip;
             if(isTI)
              return("Texas Instruments Ti486DX");
             return("Cyrix Cx486DX");
  case 0x1B:
             extFlags |= efHasFPUonChip;
             if(isTI || (DIR1 == 0xB2))
               return("Texas Instruments Ti486DX2");
             return("Cyrix Cx486DX2");
  case 0x1F:
             extFlags |= efHasFPUonChip;
             if(isTI)
              return("Texas Instruments Ti486DX4");
             return("Cyrix Cx486DX4");
  case 0x28:
             cpu = CxM1;
             extFlags |= efHasFPUonChip;
             return("Cyrix 5x86-S (clock x1 mode)");
  case 0x29:
             cpu = CxM1;
             extFlags |= efHasFPUonChip;
             return("Cyrix 5x86-S (clock x2 mode)");
  case 0x2A:
             cpu = CxM1;
             extFlags |= efHasFPUonChip;
             return("Cyrix 5x86-P (clock x1 mode)");
  case 0x2B:
             cpu = CxM1;
             extFlags |= efHasFPUonChip;
             return("Cyrix 5x86-P (clock x2 mode)");
  case 0x2C:
             cpu = CxM1;
             extFlags |= efHasFPUonChip;
             return("Cyrix 5x86-S (clock x4 mode)");
  case 0x2D:
             cpu = CxM1;
             extFlags |= efHasFPUonChip;
             return("Cyrix 5x86-S (clock x3 mode)");
  case 0x2E:
             cpu = CxM1;
             extFlags |= efHasFPUonChip;
             return("Cyrix 5x86-P (clock x4 mode)");
  case 0x2F:
             cpu = CxM1;
             extFlags |= efHasFPUonChip;
             return("Cyrix 5x86-P (clock x3 mode)");
  case 0x20:
  case 0x21:
  case 0x22:
  case 0x23:
  case 0x24:
  case 0x25:
  case 0x26:
  case 0x27:
             cpu = CxM1;
             extFlags |= efHasFPUonChip;
             return("Cyrix 5x86 (M1sc)");
  case 0x30:
             cpu = CxM1;
             extFlags |= efHasFPUonChip;
             if(DIR1 <= 0x21)
              return("Cyrix 6x86-S (clock x1 mode)");
             else
              return("Cyrix 6x86L-S (clock x1 mode)");
  case 0x31:
             cpu = CxM1;
             extFlags |= efHasFPUonChip;
             if(DIR1 <= 0x21)
              return("Cyrix 6x86-S (clock x2 mode)");
             else
              return("Cyrix 6x86L-S (clock x2 mode)");
  case 0x32:
             cpu = CxM1;
             extFlags |= efHasFPUonChip;
             if(DIR1 <= 0x21)
              return("Cyrix 6x86-P (clock x1 mode)");
             else
              return("Cyrix 6x86L-P (clock x1 mode)");
  case 0x33:
             cpu = CxM1;
             extFlags |= efHasFPUonChip;
             if(DIR1 <= 0x21)
              return("Cyrix 6x86-P (clock x2 mode)");
             else
              return("Cyrix 6x86L-P (clock x2 mode)");
  case 0x34:
             cpu = CxM1;
             extFlags |= efHasFPUonChip;
             if(DIR1 <= 0x21)
              return("Cyrix 6x86-S (clock x4 mode)");
             else
              return("Cyrix 6x86L-S (clock x4 mode)");
  case 0x35:
             cpu = CxM1;
             extFlags |= efHasFPUonChip;
             if(DIR1 <= 0x21)
              return("Cyrix 6x86-S (clock x3 mode)");
             else
              return("Cyrix 6x86L-S (clock x3 mode)");
  case 0x36:
             cpu = CxM1;
             extFlags |= efHasFPUonChip;
             if(DIR1 <= 0x21)
              return("Cyrix 6x86-P (clock x4 mode)");
             else
              return("Cyrix 6x86L-P (clock x4 mode)");
  case 0x37:
             cpu = CxM1;
             extFlags |= efHasFPUonChip;
             if(DIR1 <= 0x21)
              return("Cyrix 6x86-P (clock x3 mode)");
             else
              return("Cyrix 6x86L-P (clock x3 mode)");
  case 0x38:
  case 0x39:
  case 0x3A:
  case 0x3B:
  case 0x3C:
  case 0x3D:
  case 0x3E:
  case 0x3F:
             cpu = CxM1;
             extFlags |= efHasFPUonChip;
             return("Cyrix 6x86 (M1)");
  case 0x40:
  case 0x41:
  case 0x42:
  case 0x43:
  case 0x44:
  case 0x45:
  case 0x46:
  case 0x47:
            switch(Family) {
            case 4:
                   switch(DIR0) {
                    case 0x41:
                              cpu = CxM1;
                              extFlags |= efHasFPUonChip;
                              return("Cyrix MediaGX (clock x3 mode)");
                    case 0x45:
                    case 0x47:
                              cpu = CxM1;
                              extFlags |= efHasFPUonChip;
                              return("Cyrix MediaGX (clock x3 mode)");
                    case 0x44:
                    case 0x46:
                              cpu = CxM1;
                              extFlags |= efHasFPUonChip;
                              return("Cyrix MediaGX (clock x4 mode)");
                    default:
                              cpu = CxM1;
                              extFlags |= efHasFPUonChip;
                              return("Cyrix MediaGX");
                   }
            case 5:
                   switch(DIR0) {
                    case 0x40:
                    case 0x42:
                              cpu = CxM1;
                              extFlags |= efHasFPUonChip;
                              return("Cyrix GXm (clock x4 mode)");
                    case 0x41:
                    case 0x43:
                              cpu = CxM1;
                              extFlags |= efHasFPUonChip;
                              return("Cyrix GXm (clock x6 mode)");
                    case 0x44:
                    case 0x46:
                              cpu = CxM1;
                              extFlags |= efHasFPUonChip;
                              return("Cyrix GXm (clock x7 mode)");
                    case 0x45:
                              cpu = CxM1;
                              extFlags |= efHasFPUonChip;
                              return("Cyrix GXm (clock x5 mode)");
                    case 0x47:
                              cpu = CxM1;
                              extFlags |= efHasFPUonChip;
                              return("Cyrix GXm (clock x8 mode)");
                    default:
                              cpu = CxM1;
                              extFlags |= efHasFPUonChip;
                              return("Cyrix GXm");
                   }
            }
  case 0x50:
             cpu = CxM2;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix 6x86MX-S (clock x1.5 mode)");
  case 0x51:
             cpu = CxM2;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix 6x86MX-S (clock x2.0 mode)");
  case 0x52:
             cpu = CxM2;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix 6x86MX-S (clock x2.5 mode)");
  case 0x53:
             cpu = CxM2;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix 6x86MX-S (clock x3.0 mode)");
  case 0x54:
             cpu = CxM2;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix 6x86MX-S (clock x3.5 mode)");
  case 0x55:
             cpu = CxM2;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix 6x86MX-S (clock x4.0 mode)");
  case 0x56:
             cpu = CxM2;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix 6x86MX-S (clock x4.5 mode)");
  case 0x57:
             cpu = CxM2;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix 6x86MX-S (clock x5.0 mode)");
  case 0x58:
             cpu = CxM2;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix 6x86MX-P (clock x1.5 mode)");
  case 0x59:
             cpu = CxM2;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix 6x86MX-P (clock x2.0 mode)");
  case 0x5A:
             cpu = CxM2;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix 6x86MX-P (clock x2.5 mode)");
  case 0x5B:
             cpu = CxM2;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix 6x86MX-P (clock x3.0 mode)");
  case 0x5C:
             cpu = CxM2;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix 6x86MX-P (clock x3.5 mode)");
  case 0x5D:
             cpu = CxM2;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix 6x86MX-P (clock x4.0 mode)");
  case 0x5E:
             cpu = CxM2;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix 6x86MX-P (clock x4.5 mode)");
  case 0x5F:
             cpu = CxM2;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix 6x86MX-P (clock x5.0 mode)");
  case 0x80:
             cpu = CxIII;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix III");
  case 0x81:
             cpu = CxIII;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix III (clock x3.0 mode)");
  case 0x82:
             cpu = CxIII;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix III (clock x4.0 mode)");
  case 0x83:
             cpu = CxIII;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix III (clock x5.0 mode)");
  case 0x84:
             cpu = CxIII;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix III (clock x6.0 mode)");
  case 0x85:
             cpu = CxIII;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix III (clock x3.5 mode)");
  case 0x86:
             cpu = CxIII;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix III (clock x4.5 mode)");
  case 0x87:
             cpu = CxIII;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix III (clock x5.5 mode)");
  case 0x88:
             cpu = CxIII;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix III (clock x6.0 mode)");
  case 0x89:
             cpu = CxIII;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix III (clock x7.0 mode)");
  case 0x8A:
             cpu = CxIII;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix III (clock x6.5 mode)");
  case 0x8B:
             cpu = CxIII;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix III (clock x7.5 mode)");
  case 0x8C:
  case 0x8D:
  case 0x8E:
  case 0x8F:
             cpu = CxIII;
             extFlags |= efHasFPUonChip;
             return("VIA Cyrix III");
  case 0xEF: return("Cyrix Cx486S_a"); /* this id is software-generated */
  case 0xFD:
             extFlags |= efHasFPUonChip;
             return("Cyrix OverDrive");
  case 0xFE: return("Texas Instruments Ti486SXL");
  default:   return("Cyrix/TI 486-class processor");
 }
}

static char s[50];

char * _call cpu_Type ( void )
 {
  cpuid1Layout cpuid1_;

  if(cpu==0xFF)
   getCPUType();
  switch(cpu) {
   case i80386SX: if(cpu_Speed() > 35)
                   cpu=Am386SX;
                  break;
   case i80386DX: if(cpu_Speed() > 35)
                   cpu=Am386DX;
  } /* switch */
  if(extFlags & efCPUIDSupport)
   {
    cpuid1_.Extra = (cpuid1 & 0xF000) >> 12;
    cpuid1_.Family= (cpuid1 & 0x0F00) >> 8;
    cpuid1_.Model = (cpuid1 & 0x00F0) >> 4;
    cpuid1_.Step  = (cpuid1 & 0x000F);
    switch(cpuid1_.Family) {
     case 4:
            if(!compare12("UMC UMC UMC ")) /* UMC U5-x 486s */
             switch(cpuid1_.Model) {
              case 1:
                     cpu=umcU5S;
                     break;
              case 2:
                     cpu=umcU5D;
                     break;
              case 3:
                     cpu=umcU5D;
                     return("UMC U486DX2");
              case 5:
                     cpu=umcU5S;
                     return("UMC U486SX2");
              default:
                     cpu=umcU5S;
                     return("Undistinguished UMC U486");
              } /* switch */
             else
             if(!compare12("GenuineIntel")) /* Intel i486s */
              {
              if(extFlags & efHasFPUonChip)
               cpu = i486DX;
              switch(cpuid1_.Model) {
               case 0: return("Intel i486DX");
               case 1: return("Intel i486DX50");
               case 2: if(i486DX == cpu)
                        return("Intel i486DX2");
                       else
                        return("Intel i486SX");
               case 3: if ((cpuid1_.Extra & 3) == 1)
                        return("Intel i486DX OverDrive");
                       else
                        return("Intel i486DX");
               case 4: return("Intel i486SL");
               case 5: return("Intel i486SX2");
               case 7: return("Intel i486DX2WB");
               case 8: return("Intel i486DX4");
               case 9: return("Intel i486DX4WB");
               default: if((cpuid1_.Extra & 3) == 1)
                         return("Intel i486 OverDrive");
                        else
                         return("Intel i486 (undistinguished model)");
               } /* switch */
              }
             else
             if(!compare12("AuthenticAMD")) /* AMD Enhanced Am486s */
              {
              cpu = Am486;
              if (extFlags & efHasFPUonChip)
               cpu = Am486DX;
              switch(cpuid1_.Model) {
               case 3: return("AMD Enhanced Am486DX2");
               case 7: return("AMD Enhanced Am486DX2+");
               case 8: return("AMD Enhanced Am486DX4");
               case 9: return("AMD Enhanced Am486DX4+");
               case 0x0A: if ((extFlags & efHasFPUonChip) == 0)
                           return("AMD Elan SC400 Microcontroller");
                          else
                           return("AMD Enhanced Am486DX (undistinguished model)");
               case 0x0E: return("AMD X5 (Am5x86)");
               case 0x0F: return("AMD X5+ (Am5x86+)");
               default: return("AMD Enhanced Am486DX (undistinguished model)");
               }
              }
             else
              {
              #ifdef __Win32__
               _sprintf(s,"Unknown 486-class processor (Make: %s)",cpuid0);
              #else
               sprintf(s,"Unknown 486-class processor (Make: %s)",cpuid0);
              #endif
               return s;
              }
             break;
     case 5:
             if(!compare12("RiseRiseRise"))
             {
              cpu = Rise_mP6;
              switch(cpuid1_.Model)
              {
                case 0: return("Rise iDragon(tm) mP6(tm)");
                case 2: return("Rise iDragon(tm) mP6(tm) Tiger (0.18u)");
                case 8: return("Rise iDragon(tm) mP6(tm) II");
                case 9: return("Rise iDragon(tm) mP6(tm) II Tiger (0.18u)");
               default: return("Rise iDragon(tm) mP6(tm) (undistinguished)");
              }
             }
             else
             if(!compare12("CyrixInstead"))
              return(CyrixModel());
             else
             if((!compare12("CentaurHauls")) || (extFlags & efCentaurLevel))
              {
               cpu = WinChipC6;
               switch(cpuid1_.Model) {
                case 4 : return("IDT/Centaur Tech. WinChip C6'");
                case 8 : cpu = WinChip2;
                         switch(cpuid1_.Step) {
                          case 7:
                          case 8:
                          case 9: return("IDT/Centaur Tech. WinChip 2A");
                          default:
                                  return("IDT/Centaur Tech. WinChip 2");
                         }
                case 9 : cpu = WinChip3;
                         return("IDT/Centaur Tech. WinChip 3");
                default: return("IDT/Centaur Tech. WinChip (unknown model)");
               }
              }
             else
             if(!compare12("GenuineIntel"))
              {
              cpu = iP54C;
              switch(cpuid1_.Model) {
               case 0: cpu = iPentium;
                       return("Intel Pentium (A-Step)");
               case 1: cpu = iPentium;
                       return("Intel Pentium");
               case 2: if (cpuFeatures & 0x00800000)
                        return("Intel Pentium with MMX");
                       return("Intel Pentium");
               case 3: return("Intel Pentium OverDrive");
               case 4: if ((cpuid1_.Extra & 3) == 1)
                        return("Intel Pentium OverDrive for Pentium 3.3v");
                       else
                        return("Intel Pentium with MMX");
               case 5: return("Intel Pentium OverDrive for i486DX4");
               case 6: return("Intel Pentium OverDrive for Pentium 5v");
               case 7: if (cpuFeatures & 0x00800000)
                        return("Intel Pentium with MMX");
                       return("Intel Pentium (> 133MHz)");
               case 8: return("SL28x Mobile Pentium with MMX");
               default:
                       if ((cpuid1_.Extra & 3) == 1)
                        return("Intel Pentium OverDrive");
                       else
                       if ((cpuid1_.Extra & 3) == 2)
                        return("Auxiliary Intel Pentium (SMP)");
                       else
                        return("Intel Pentium");
               } /* switch */
              } /* if */
             else
             if(!compare12("NexGenDriven")) /* NexGen is now part of AMD family */
              {
              cpu = Nx586;
              switch(cpuid1_.Model) {
               case 0: return("NexGen Nx586 or Nx586FPU");
               default: return("NexGen 586-class processor (undistinguished)");
               }
              }
             else
             if(!compare12("AuthenticAMD"))
              {
              cpu = AmdK5;
              switch(cpuid1_.Model) {
               case 0: return("AMD SSA/5 (K5)");
               case 1: return("AMD 5k86 (K5)");
               case 2:
               case 3: cpu = AmdK5_2;
                       return("AMD 5k86 (K5)");
               case 6:
               case 7:
                       cpu = AmdK6;
                       break;
               case 8:
                       cpu = AmdK6;
                       return("AMD K6-2");
               case 9:
                       cpu = AmdK6;
                       return("AMD K6-III");
               case 0xD:
                       cpu = AmdK6;
                       return("AMD K6-III (0.18u)");
               default: return("AMD 586-class processor (undistinguished)");
               }
              }
             else
              {
              #ifdef __Win32__
               _sprintf(s,"Unknown 586-class processor (Make: %s)",cpuid0);
              #else
               sprintf(s,"Unknown 586-class processor (Make: %s)",cpuid0);
              #endif
               return s;
              }
     case 6:
             if(!compare12("GenuineIntel"))
             {
             cpu = iPentiumPro;
             switch(cpuid1_.Model) {
              case 0 : return("Intel Pentium Pro (P6) A-Step");
              case 1 : return("Intel Pentium Pro (P6)");
              case 3 : if(cpuid1_.Extra == 1)
                        return("Intel Pentium Pro OverDrive");
                       else
                        return("Intel Pentium II");
              case 4 : return("Intel iP55CT (OverDrive for iP54C socket)");
              case 5 : switch( getL2CacheDesc() )
                       {
                        case cdNoCache:
                        case cd128k   : return("Intel Celeron");
                        case cd256k   : return("Intel Pentium IIe");
                        case cd512k   : if (3 == cpuBrand)
                                         return("Intel Pentium II Xeon");
                                        else
                                         return("Intel Pentium II");

                        case cd1M     :
                        case cd2M     : return("Intel Pentium II Xeon");
                        default       : if (3 == cpuBrand)
                                         return("Intel Pentium II Xeon");
                                        else
                                         return("Intel Pentium II");
                       }
              case 6 : switch( getL2CacheDesc() )
                       {
                        case cdNoCache:
                        case cd128k   : return("Intel CeleronA");
                        case cd256k   : return("Intel Pentium IIe");
                        default       : return("Intel Pentium II");
                       }
              case 7 : if (!cpuBrand)
                        switch( getL2CacheDesc() )
                        {
                         case cd128k   : return("Intel Celeron");
                         case cd512k   : return("Intel Pentium III");
                         case cd1M     :
                         case cd2M     : return("Intel Pentium III Xeon");
                         default       : return("Intel Pentium III");
                        }
                       else
                        switch( cpuBrand )
                        {
                         case 1  : return("Intel Celeron");
                         case 2  : return("Intel Pentium III");
                         case 3  : return("Intel Pentium III Xeon");
                         default : return("Intel Pentium III");
                        }
              case 8 : if (!cpuBrand)
                        switch( getL2CacheDesc() )
                        {
                         case cd128k   : return("Intel Celeron");
                         case cd512k   : return("Intel Pentium III E");
                         case cd1M     :
                         case cd2M     : return("Intel Pentium III Xeon E");
                         default       : return("Intel Pentium III E");
                        }
                       else
                        switch( cpuBrand )
                        {
                         case 1  : return("Intel Celeron");
                         case 2  : return("Intel Pentium III E");
                         case 3  : return("Intel Pentium III Xeon E");
                         default : return("Intel Pentium III E");
                        }
              case 0x0A:
                        return("Intel Pentium III Xeon");
              default:
                        return("Intel Pentium Pro (undistinguished)");
              } /* switch */
             }
             else
             if(!compare12("CyrixInstead"))
             {
              switch( cpuid1_.Model )
               {
                case 0  :cpu = CxM2;
                         return(CyrixModel());
                case 5  :cpu = CxIII;
                         return(CyrixModel());
                default :cpu = CxM2;
                         return(CyrixModel());
               }
             }
             else
             if(!compare12("AuthenticAMD"))
             {
              cpu = AmdK7;
              switch(cpuid1_.Model) {
               case 1  : return("AMD Athlon(tm)");
               case 2  : return("AMD Athlon(tm) (0.18u)");
               case 3  : return("AMD Duron(tm)");
               case 4  : return("AMD Athlon(tm) (Thunderbird)");
               default : return("AMD Athlon(tm) (undistinguished model)");
              }

             }
             else
              {
              #ifdef __Win32__
               _sprintf(s,"Unknown 686-class processor (Make: %s)",cpuid0);
              #else
               sprintf(s,"Unknown 686-class processor (Make: %s)",cpuid0);
              #endif
               return s;
              }
     case 7:
             if (!compare12("GenuineIntel"))
             {
              cpu = iP7;
              break;
             }
             else
              {
              #ifdef __Win32__
               _sprintf(s,"Unknown 786-class processor (Make: %s)",cpuid0);
              #else
               sprintf(s,"Unknown 786-class processor (Make: %s)",cpuid0);
              #endif
               return s;
              }
     case 8:
             cpu = iP8;
             break;
     } /* switch */
   }
  switch(cpu) {
#ifndef __DPMI__
 #ifndef __Windows__
  #ifndef __Win32__
 /* Under DPMI host or Windows it is not necessary to check for CPUs lower than
    80286 - neither of them works on these CPUs. */
   case i8088      : return("Intel 8088");
   case i8086      : return("Intel 8086");
   case i80C88     : return("Intel 80C88");
   case i80C86     : return("Intel 80C86");
   case i80188     : return("Intel 80188");
   case i80186     : return("Intel 80186");
   case necV20     : return("NEC V20");
   case necV30     : return("NEC V30");
  #endif
 #endif
#endif
   case i80286     : return("Intel 80286");
   case i80386SX   : return("Intel 80386SX");
   case i80386DX   : return("Intel 80386DX");
   case i386SL     : return("Intel i386SL");
   case i376       : return("Intel i376");
   case ibm386SLC  : return("IBM 386SLC");
   case Am386SX    : return("AMD Am386SX");
   case Am386DX    : return("AMD Am386DX");
   case CT38600    : return("C&T 38600");
   case CT38600SX  : return("C&T 38600SX");
   case RapidCAD   : return("Intel RapidCAD");
   case i486SX     : return("Intel i486SX");
   case i486DX     : return("Intel i486DX or i487SX");
   case i486SL     : return("Intel i486SL");
   case ibm486SLC  : return("IBM 486SLC");
   case ibm486SLC2 : return("IBM 486SLC2");
   case ibm486BL3  : return("IBM 486BLX3 (Blue Lightning)");
   case Cx486      : return(CyrixModel());
   case umcU5S     : return("UMC U5S-Super33");
   case umcU5D     : return("UMC U5SD");
   case Am486      : return("AMD Am486SX");
   case Am486DX    : return("AMD Am486DX");
   case CxM1       :
   case CxM2       : return(CyrixModel());
   case AmdK5      :
   case AmdK5_2    : return("AMD K5");
   case AmdK6      : return("AMD K6");
   case Nx586      : return("NexGen Nx586");
   case iPentiumPro: return("Intel Pentium Pro");
   case iP7        : return("Intel Itanium");
   case iP8        : return("Intel P8");
   case AmdK7      : return("AMD Athlon(tm)");
   case WinChipC6  : return("IDT/Centaur WinChip C6");
   case WinChip2   : return("IDT/Centaur WinChip 2");
   case WinChip3   : return("IDT/Centaur WinChip 3");
   case Rise_mP6   : return("Rise mP6");
   default         : return("Unknown CPU");
   } /* switch */
 }

char * _call fpu_Type( void )
 {
  if(fpu==0xFF)
   {
    cpu_Type();
    getFPUType();
   }
  if(extFlags & efHasFPUonChip)
   fpu = fpuInternal;
  switch(fpu) {
  case fpuInternal: return("Internal");
  case fpuNone:     return("None");
  case i8087:       return("Intel 8087");
  case i80287:      return("Intel 80287");
  case i80287XL:    return("Intel 80287XL");
  case i80387:      return("Intel 80387");
  case rCAD:        return("Intel RapidCAD");
  case cx287:       return("Cyrix 82x87");
  case cx387:       return("Cyrix 83x87");
  case cx487:       return("Cyrix 84x87");
  case cxEMC87:     return("Cyrix EMC87");
  case iit287:      return("IIT 2C87");
  case iit387:      return("IIT 3C87");
  case iit487:      return("IIT 4C87");
  case iit487DLC:   return("IIT 4C87DLC");
  case ct387:       return("C&T 38700");
  case ulsi387:     return("ULSI 83x87");
  case ulsi487:     return("ULSI 84x87");
  case i487sx:      return("Intel i487SX (integrated)");
  case Nx587:       return("NexGen Nx587");
  case i387SLMobile:return("Intel i387SL Mobile");
  default:          return("Unknown FPU");
  }
 }

int UnderNT( void )
{
#ifdef __Win32__
 OSVERSIONINFO vi;
 vi.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
 GetVersionEx(&vi);
 return (vi.dwPlatformId == VER_PLATFORM_WIN32_NT);

#else
 return (!strcmp(getenv("OS"),"Windows_NT"));
#endif
}


#define EOA 0

#define Tolerance 4

static int Clone486Norm[] = { 33, 40, 50, 66, 80, 75, 100, 120, 150, 166, 188, 200, 233, EOA };
static int CloneP5Norm[]  = { 75, 90, 100, 120, 133, 150, 166, 185, 200, 233, 266, 300,
                              333, 350, 366, 380, 400, 450, 500, 533, EOA };
static int CloneP6Norm[]  = { 300, 333, 350, 366, 380, 400, 450, 500, 550, 600, 650,
                              700, 750, 800, 833, 866, 933, 966, 1000, EOA};
static int CyrixNorm[]    = { 80, 100, 110, 120, 125, 133, 150, 166, 185, 200,
                              225, 233, 250, 300, 333, 350, 366, 400, 433, 466,
                              500, 533, EOA };
static int i486Norm[]     = { 25, 33, 40, 50, 66, 75, 80, 100, EOA };
static int iP5Norm[]      = { 60, 66, 75, 90, 100, 120, 133, 150, 166, 185,
                              200, 233, 266, 300, EOA };
static int iP6Norm[]      = { 133, 150, 167, 185, 200, 220, 240, 266, 300,
                              333, 350, 366, 400, 450, 500, 550, 600, 667,
                              700, 733, 750, 800, 833, 866, 933, 966, 1000,
                              EOA };
static int WinChipNorm[]  = { 180, 200, 225, 233, 240, 250, 266, 300, 333,
                              350, 366, 380, 400, EOA };
static int RiseNorm[]     = { 266, 300, 333, EOA };


int NormFreq( int freq, int fTable[] )
{
 int ptr = 0;
 while( EOA != fTable[ptr] )
  {
   if( fTable[ptr] + Tolerance >= freq )
    if( (0 < ptr) && (10 < (fTable[ptr] - freq)) )
     return( fTable[ptr-1] );
    else
     return( fTable[ptr] );
   ++ptr;
  }
 return freq;
}

int _call ncpu_Speed( void )
{
 word spd;
 if(cpu == 0xFF)
   cpu_Type();
 spd = cpu_Speed();
 switch (cpu) {
  case iPentium   :
  case iP54C      : return NormFreq(spd, iP5Norm);
  case iP7        :
  case iP8        :
  case iPentiumPro: return NormFreq(spd, iP6Norm);
  case i486SX     :
  case i486DX     :
  case i486SL     : return NormFreq(spd, i486Norm);
  case ibm486SLC  :
  case ibm486SLC2 :
  case ibm486BL3  :
  case Cx486      :
  case Am486      :
  case Am486DX    :
  case umcU5S     :
  case umcU5D     : return NormFreq(spd, Clone486Norm);
  case CxM1       :
  case CxM2       :
  case CxIII      : return NormFreq(spd, CyrixNorm);
  case AmdK5      :
  case AmdK5_2    :
  case AmdK6      : return NormFreq(spd, CloneP5Norm);
  case AmdK7      : return NormFreq(spd, CloneP6Norm);
  case WinChipC6  :
  case WinChip2   :
  case WinChip3   : return NormFreq(spd, WinChipNorm);
  case Rise_mP6   : return NormFreq(spd, RiseNorm);
  default         : return spd;
  }
}

/*
int AmdCPU( void )
{
 return ( (AmdK5 == cpu) || (AmdK6 == cpu) || (AmdK5_2 == cpu) || (AmdK7 == cpu) );
}
*/

int _call cpu_Speed( void )
 {
#ifdef __NewSpeedCalc__
 unsigned int ms = 0xFFFF, sps = 0, i, j;
#endif
 int f1, f2, f3;

 if(cpu == 0xFF)
   cpu_Type();

 if((extFlags & efTSCSupport)
     && !TSCDisabled()
     && !UnderNT()
/*
#ifndef __Win32__
 #ifndef __Windows__
  #ifndef __DPMI__
     && !checkEMM386()
  #endif
 #endif
#endif
*/
   )
  {
   f1 = getPentiumSpeed();
   f2 = getPentiumSpeed();
   f3 = getPentiumSpeed();
   return ((f1 + f2 + f3) / 3);
  }
#ifdef __NewSpeedCalc__
 for (i = 0; i<=7; i++ )
  {
   j = Speed();
   if ( ( j < ms ) && ( speedShift >= sps ) )
    {
     ms = j;
     sps = speedShift;
    }
  }
  return ( ( ( speedTable[cpu] * (long)sps ) / ms + 5 ) / 10 );
#else
  f1 = ( ( speedTable[cpu] * (long)speedShift ) / Speed() + 5 ) / 10;
  f2 = ( ( speedTable[cpu] * (long)speedShift ) / Speed() + 5 ) / 10;
  f3 = ( ( speedTable[cpu] * (long)speedShift ) / Speed() + 5 ) / 10;
  return ((f1 + f2 + f3) / 3);
#endif
 }

#ifdef __need_fp_cpu_Speed__ /* this code links in too much and disables
                                TINY model programs to be converted to .COM */

float _call fcpu_Speed( void )
/* exactly the same as cpu_Speed, but returns floating point result */
 {
#ifdef __NewSpeedCalc__
 unsigned int ms = 0xFFFF, sps = 0, i, j;
#endif
 float f1, f2, f3;
 if(cpu == 0xFF)
   cpu_Type();
 if((extFlags & efTSCSupport)
     && !TSCDisabled()
     && !UnderNT()
/*
#ifndef __Win32__
 #ifndef __Windows__
  #ifndef __DPMI__
     && !checkEMM386()
  #endif
 #endif
#endif
*/
   )
  {
   f1 = getPentiumSpeed();
   f2 = getPentiumSpeed();
   f3 = getPentiumSpeed();
   return ((f1 + f2 + f3) / 3);
  }
#ifdef __NewSpeedCalc__
 for (i = 0; i<=7; i++ )
  {
   j = Speed();
   if ( ( j < ms ) && ( speedShift >= sps ) )
    {
     ms = j;
     sps = speedShift;
    }
  }
  res = ( ( speedTable[cpu] * (long)sps ) / ms + 5 ) / 10;
#else
  f1 = ( ( speedTable[cpu] * (long)speedShift ) / Speed() + 5 ) / 10;
  f2 = ( ( speedTable[cpu] * (long)speedShift ) / Speed() + 5 ) / 10;
  f3 = ( ( speedTable[cpu] * (long)speedShift ) / Speed() + 5 ) / 10;
#endif
  return ((f1 + f2 + f3)/3);
 }

#endif /* __need_fp_cpu_Speed__ */

#pragma warn -aus

static char SN[30];

char * _call getCPUSerialNumber( void )
{
 customCpuid A;
 char T[10];
 word tmp = 0;   /* temporary storage for word-sized parts of PSN */
 if(!(cpuFeatures & 0x00040000))
  return("");
 else
  {
   getCPUID(1,&A);
#ifdef __Win32__
   _sprintf(T,"%04X-%04X",(tmp = A.eax >> 16),
                          (tmp = A.eax & 0xFFFF));
#else
   sprintf(T,"%04X-%04X",(tmp = A.eax >> 16),
                         (tmp = A.eax & 0xFFFF));
#endif
   getCPUID(3,&A);
#ifdef __Win32__
   _sprintf(SN,"%s-%04X-%04X-%04X-%04X",T ,(tmp = A.edx >> 16),
                                           (tmp = A.edx & 0xFFFF),
                                           (tmp = A.ecx >> 16),
                                           (tmp = A.ecx & 0xFFFF));
#else
   sprintf(SN,"%s-%04X-%04X-%04X-%04X",T ,(tmp = A.edx >> 16),
                                          (tmp = A.edx & 0xFFFF),
                                          (tmp = A.ecx >> 16),
                                          (tmp = A.ecx & 0xFFFF));
#endif
   return SN;
  }
}
#pragma warn .aus

#define libVersion 0x0215

word _call getVersion( void )
{
  return libVersion;
}
