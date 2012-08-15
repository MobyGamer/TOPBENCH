/* ----------------------------------------------------------------------------
 * P5INFOC.C     CPU Information Retriever                       Version 2.15
 *
 * This program is part of TMi0SDGL Revision 2 x86 CPU/FPU Detection Library
 * Copyright(c) 1996-2000 by B-coolWare.  Written by Bobby Z.
 --------------------------------------------------------------------------- */

#include "tmi0sdgl.h"
#include <string.h>
#include <stdio.h>
#include <conio.h>


customCpuid A;
static char N[48];
static char SN[30];

void pascal printBullet( dword Flag, char * Message )
 {
  if (cpuFeatures & Flag) /* != 0 */
   printf(" û %s\n",Message);
  else
   printf(" ú %s\n",Message);
 }

void pascal printExtBullet( dword Flag, char * Message )
 {
  if (A.edx & Flag) /* != 0 */
   printf(" û %s\n",Message);
  else
   printf(" ú %s\n",Message);
 }


void pascal getCPUPartNameEx( void )
/* This routine only works on new AMD and Cyrix chips. It retrieves data */
/* provided by Extended CPUID levels ( starting at $80000000 )           */
{
  getCPUID(0x80000000,&A);
  if ((A.eax & 0x7FFFFFFF) < 4) /* no CPU name embedded */
   N[0] = 0;
  else
   {
    getCPUID(0x80000002,&A);
    memcpy(&N,&A,16);
    getCPUID(0x80000003,&A);
    memcpy(&N[16],&A,16);
    getCPUID(0x80000004,&A);
    memcpy(&N[32],&A,16);
   }
}

int cdecl main( void )
{
 printf("CPU Information Retriever  Version 2.15/C Copyright(c) 1996-2000 by B-coolWare.\n\nDetected Processor: %s\n\n", cpu_Type());
 if (!(extFlags & efCPUIDSupport))
  {
   puts("Sorry, this CPU does not support CPUID instruction. Information is unavailable.");
   return 0xFF;
  }
 if ( (AmdK6 != cpu) && /* AMD K6 */
      !((AmdK5 == cpu) && (0 != (cpuid1 & 0x00F0) >> 4 )) &&  /* AMD 5k86 */
      (CxM2 != cpu) && (CxIII != cpu)) /* Cyrix 6x86MX or Cyrix III*/
 {
  printf("Make: %s\nFamily: %u Model: %u Step: %u\n", cpuid0, (byte)((cpuid1 & 0x0F00) >> 8), (byte)((cpuid1 & 0x00F0) >> 4), (byte)(cpuid1 & 0x000F));
  strcpy(SN,getCPUSerialNumber());
  if(strlen(SN))
   printf("Processor serial number: %s\n",SN);
  printf("\nPress any key to see processor features...\r");
  getch(); /* wait for keypress */
  puts("This CPU has following features (û = present/enabled):");
  printBullet(ifbFPU,   "FPU on chip");
  printBullet(ifbVME,   "Enhanced V86 (VME)");
  printBullet(ifbDE,    "Debugging Extensions");
  printBullet(ifbPSE,   "Page Size Extensions");
  printBullet(ifbTSC,   "Time Stamp Counter");
  printBullet(ifbMSR,   "Pentium-style MSRs");
  printBullet(ifbPAE,   "Physical Address Extension");
  printBullet(ifbMCE,   "Machine Check Exception");
  printBullet(ifbCX8,   "CMPXCHG8B Instruction");
 if (AmdK5 == cpu) /* AMD SSA/5 */
  printBullet(0x00000200,"Page Global Extensions");
 else
  printBullet(ifbAPIC,  "CPU contains enabled APIC on chip");
  printBullet(ifbSEP,   "SYSENTER/SYSEXIT instructions");
  printBullet(ifbMTRR,  "Memory Type Range Registers");
 if (AmdK5 != cpu)
  printBullet(ifbPGE,   "Page Global Extensions");
  printBullet(ifbMCA,   "Machine Check Architecture");
  printBullet(ifbCMOV,  "CMOVcc (FCMOVcc and FCOMI) instructions");
  printBullet(ifbPAT,   "Page Attribute Table");
  printBullet(ifbPSE36, "36-bit Page Size Extension");
  printBullet(ifbPSN,   "PSN (Processor Serial Number)");
  printBullet(ifbMMX,   "MMX (MultiMedia eXtension) instructions");
  printBullet(ifbFXSR,  "FXSAVE/FXRSTOR instructions");
  printBullet(ifbSSE,   "SSE (Streaming SIMD Extensions)");
  printBullet(ifbCLFLSH,"Cache Line Flush Instruction (CLFLSH)");
  printBullet(ifbDTES,  "Debug Trace and EMON Store (DTES)");
  printBullet(ifbACPI,  "Processor Duty Cycle Control (ACPI)");
  printBullet(ifbSSE2,  "SSE-2 instructions");
  printBullet(ifbSSNP,  "Self-Snoop");
  printBullet(ifbIA64,  "IA-64 instructions");
 }
 else /* AMD K6 has extended CPUID levels and info */
 {
  getCPUPartNameEx();
  printf("--- Non-Intel Processor Extended Info. ---\n* Embedded CPU Part Name: %s\n",N);
  getCPUID(0x80000000,&A);
  if( (A.eax & 0x7FFFFFFF) >= 5) /* max supported levels >= 5 */
   {
    getCPUID(0x80000005,&A);
    printf("Code Cache size: %uKb, Data Cache size: %uKb.\n--- End of Extended Info. ---\n",(byte)(A.edx >> 24), (byte)(A.ecx >> 24));
   }
  puts("This CPU has following features (û = present/enabled):");
  getCPUID(0x80000001,&A);
  printExtBullet(0x00000001,"FPU on chip");
  printExtBullet(0x00000002,"Virtual Mode Extensions");
  printExtBullet(0x00000004,"Debugging Extension");
  printExtBullet(0x00000008,"Page Size Extension");
  printExtBullet(0x00000010,"Time Stamp Counter");
  printExtBullet(0x00000020,"Model Specific Registers");
  printExtBullet(0x00000080,"Machine Check Exception");
  printExtBullet(0x00000100,"CMPXCHG8B instruction");
  printExtBullet(0x00001000,"Memory Type Range Registers");
  printExtBullet(0x00002000,"Page Global Extensions");
  printExtBullet(0x00004000,"Machine Check Architecture");
  printExtBullet(0x00008000,"CMOVcc instructions");
 if (AmdK7 == cpu)
  printExtBullet(0x00010000,"Page Address Table");
 else
  printExtBullet(0x00010000,"FCMOVcc/F(U)COMI(P) instructions");
  printExtBullet(0x00020000,"36-bit Page Size Extension");
 if (AmdK7 == cpu)
  printExtBullet(0x00400000,"SSE-MMX/MMX-MEM (AMD MMX Extensions)");
  printExtBullet(0x00800000,"MMX (MultiMedia eXtension) instructions");
 if ((CxM2 == cpu) || (CxIII == cpu))
  printExtBullet(0x01000000,"Extended MMX instructions");
 else
 if (AmdK7 == cpu)
  printExtBullet(0x01000000,"FXSAVE/FXRSTOR instructions");
  printExtBullet(0x40000000,"AMD 3DNow! Plus instructions");
  printExtBullet(0x80000000,"AMD 3DNow! instructions");
 }
 return 0;
}
