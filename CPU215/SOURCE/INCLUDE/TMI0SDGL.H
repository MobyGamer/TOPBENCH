/*****************************************************************************
 * TMi0SDGL.H   TMi0SDGL 2 C/C++ Header File                    Version 2.15
 *
 * Too-Much-in-0ne-So-Don't-Get-Lost(tm) Revision 2 CPU/FPU detection library
 * Copyright(c) 1996-2000 by B-coolWare.  Written by Bobby Z.
 *****************************************************************************
 * defines that affect compilation:

__need_fp_cpu_Speed__   enables compilation of floating point version of
                        cpu_Speed routine. Disabled by default, for this
                        version links in too much code.
__DPMI__                specifies that this code is compiled to run under
                        DPMI
__Windows__             specifies that this code is compiled to run under
                        Windows. Effectively the same as __DPMI__
__Win32__               specifies that this code in compiled to run under
                        Win32.
*/

/* uncomment this if you want floating point version of cpu_Speed to be
   compiled.
#define __need_fp_cpu_Speed__
*/

#ifndef __TMi0SDGL_H
#define __TMi0SDGL_H

typedef unsigned char byte;
#ifdef __Win32__
typedef unsigned short int word;
typedef unsigned int dword;
typedef void * pointer;
#else
typedef unsigned int word;
typedef unsigned long dword;
typedef void far * pointer;
#endif

#ifdef __Win32__
#define _call __stdcall
#define _dist
#else
#define _call pascal
#endif

/* extra flags */

#define efHasFPUonChip  0x0001
#define efWeitekPresent 0x0002
#define efCPUIDSupport  0x0004
#define efDXType        efCPUIDSupport+efHasFPUonChip
#define efEmulatedFPU   0x0008
#define efCentaurLevel  0x0010
#define efTSCSupport    0x0020

/* CPU type constants */

#define i8088           0
#define i8086           1
#define i80C88          2
#define i80C86          3
#define i80188          4
#define i80186          5
#define necV20          6
#define necV30          7
#define i80286          8
#define i80386SX        9
#define i80386DX        10
#define i386SL          11
#define ibm386SLC       12
#define Am386SX         13
#define Am386DX         14
#define CT38600         15
#define CT38600SX       16
#define RapidCAD        17
#define i486SX          18
#define i486DX          19
#define ibm486SLC       20
#define ibm486SLC2      21
#define ibm486BL3       22
#define Cx486           23
#define umcU5S          24
#define umcU5D          25
#define Am486           26
#define iPentium        27
#define iP54C           28
#define CxM1            29
#define AmdK5           30
#define Nx586           31
#define iPentiumPro     32
#define AmdK6           33
#define iP7             34
#define iP8             35
#define CxM2            36
#define Am486DX         37
#define AmdK5_2         38
#define WinChipC6       39
#define i486SL          40
#define AmdK7           41
#define WinChip2        42
#define Rise_mP6        43
#define i376            44
#define WinChip3        45
#define CxIII           46
#define MaxCPU          CxIII

/* FPU type constants */

#define fpuInternal     100
#define fpuNone         0
#define i8087           1
#define i80287          2
#define i80287XL        3
#define i80387          4
#define rCAD            5
#define cx287           6
#define cx387           7
#define cx487           8
#define cxEMC87         9
#define iit287          10
#define iit387          11
#define iit487          12
#define ct387           13
#define ulsi387         14
#define ulsi487         15
#define i487sx          16
#define Nx587           17
#define iit487DLC       18
#define i387SLMobile    19


/* L2 cache size descriptors (CPUID level 2, lower nibble of descriptor) */
#define cdNoCache       0
#define cd128k          1
#define cd256k          2
#define cd512k          3
#define cd1M            4
#define cd2M            5
#define cd4M            6

/* Intel feature bits */
#define ifbFPU          0x00000001
#define ifbVME          0x00000002
#define ifbDE           0x00000004
#define ifbPSE          0x00000008
#define ifbTSC          0x00000010
#define ifbMSR          0x00000020
#define ifbPAE          0x00000040
#define ifbMCE          0x00000080
#define ifbCX8          0x00000100
#define ifbAPIC         0x00000200
#define ifbSEP          0x00000800
#define ifbMTRR         0x00001000
#define ifbPGE          0x00002000
#define ifbMCA          0x00004000
#define ifbCMOV         0x00008000
#define ifbPAT          0x00010000
#define ifbPSE36        0x00020000
#define ifbPSN          0x00040000
#define ifbCLFLSH       0x00080000
#define ifbDTES         0x00200000
#define ifbACPI         0x00400000
#define ifbMMX          0x00800000
#define ifbFXSR         0x01000000
#define ifbSSE          0x02000000
#define ifbSSE2         0x04000000
#define ifbSSNP         0x08000000
#define ifbIA64         0x40000000

typedef struct { dword eax;
                 dword ebx;
                 dword ecx;
                 dword edx; } customCpuid;


#ifdef  __LIB__

typedef struct { byte Extra;
                 byte Family;
                 byte Model;
                 byte Step; } cpuid1Layout;

#ifdef __cplusplus
 extern "C" {
#endif
 extern byte _dist _call getCPUType( void ); /* sets cpu variable to CPU code */
 extern byte _dist _call getFPUType( void ); /* sets fpu variable to FPU code */
 extern word _dist _call getCyrixModel( void );
 extern word _dist _call Speed( void );
 extern word _dist _call getPentiumSpeed( void );
 extern byte _dist _call TSCDisabled( void );
 extern word _dist _call getCacheSize( void );
 extern void _dist _call CxCPUIDEnable( void );
 extern byte _dist _call getL2CacheDesc( void );
 extern void _dist _call getCPUID( dword Level, pointer Result );
#ifndef __DPMI__
 #ifndef __Windows__
  #ifndef __Win32__
   extern byte _dist pascal isV86( void );
   /* extern byte _dist pascal checkEMM386( void ); */
  #endif
 #endif
#endif
#ifdef __cplusplus
 }
#endif  /* __cplusplus */

char * _call cpu_Type( void );
 /* returns cpu name */
char * _call fpu_Type( void );
 /* returns fpu name */
int _call cpu_Speed( void );
 /* returns current CPU's clock speed in MHz */
char * _call getCPUSerialNumber( void );
 /* returns CPU Serial Number if present or empty string otherwise */
#ifdef __need_fp_cpu_Speed__
float _call fcpu_Speed( void );
 /* returns current CPU's clock speed in MHz, floating point value */
#endif
word _call getVersion( void );


/* variables and constants */

byte pascal cpu = 0xFF; /* initialize cpu and fpu as 0xFF, so they will be */
byte pascal fpu = 0xFF; /* detected just once.                             */
word pascal extFlags = 0;
byte pascal cpuid0[12] = {0,0,0,0,0,0,0,0,0,0,0,0};
byte pascal zeroByte = 0; /* this is to make cpuid0 a valid C string so that
                             we can use strncmp() on it */
dword pascal cpuid1 = 0L;
dword pascal cpuBrand = 0L;
dword pascal cpuFeatures = 0L;

/* following constants should not be accessed from client code, they are for */
/* internal purposes only and should not be changed.                         */
byte pascal fpuDenormal[10] = {1,0,0,0,0,0,0,0,0,0};
byte pascal fpuOp1[10] = {0xF0,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x3F};
word pascal fpu_53bit_prec = 0x02F7;
word pascal speedShift = 0;
dword pascal speedTable[MaxCPU+1] =
                       {
                        0x0002AD26, /* i8088 */
                        0x0002AD26, /* i8086 */
                        0x0002AD26, /* i80C88 */
                        0x0002AD26, /* i80C86 */
                        0x0000BA6F, /* i80188 */
                        0x0000BA6F, /* i80186 */
                        0x00008C38, /* necV20 */
                        0x0000912C, /* necV30 */
                        0x00006FDC, /* i80286 */
                        0x00007480, /* i80386SX */
                        0x00007480, /* i80386DX */
                        0x00007480, /* i386SL */
                        0x00007480, /* ibm386slc */
                        0x00007415, /* Am386SX */
                        0x00007415, /* Am386DX */
                        0x00007480, /* CT38600 */
                        0x00007480, /* CT38600SX */
                        0x00007415, /* RapidCAD */
                        0x00007480, /* i486SX */
                        0x00007480, /* i486DX */
                        0x00007486, /* ibm486slc */
                        0x00007486, /* ibm486slc2 */
                        0x00007486, /* ibm486bl3 */
                        0x0000668A, /* Cx486 */
                        0x00003C90, /* umcU5S */
                        0x00003C90, /* umcU5D */
                        0x00007480, /* Am486 */
                        0x00007850, /* Pentium */
                        0x00007900, /* P54C */
                        0x00004800, /* CxM1 */
                        0x000061D0, /* AmdK5 */
                        0x0000792E, /* Nx586      !!! needs adjustment */
                        0x00006BCD, /* Pentium Pro */
                        0x00003CD2, /* AmdK6 */
                        0x00003079, /* P7         !!! needs adjustment */
                        0x00003079, /* P8         !!! needs adjustment */
                        0x0000D688, /* CxM2       !!! needs adjustment */
                        0x00007480, /* Am486DX */
                        0x00008AC6, /* AMD K5 models 2 & 3 */
                        0x00003900, /* WinChip C6 !!! needs adjustment */
                        0x00007480, /* i486SL */
                        0x00006EC0, /* AMD K7       !!! needs adjustment */
                        0x00003CD2, /* WinChip2     !!! needs adjustment */
                        0x00003CD2, /* Rise mP6(tm) !!! needs adjustment */
                        0x00007480, /* i376 */
                        0x00003CD2, /* WinChip3     !!! needs adjustment */
                        0x0000D688  /* Cyrix III    !!! needs adjustment */
                       };

#else   /* !__LIB__ */

#ifdef __cplusplus
 extern "C" {
#endif
 /* define interface with library functions... */
 extern char * _call cpu_Type( void );
 extern char * _call fpu_Type( void );
 extern int _call cpu_Speed( void );
 extern int _call ncpu_Speed( void );
 extern char * _call getCPUSerialNumber( void );
#ifdef __need_fp_cpu_Speed__
 extern float _call fcpu_Speed( void );
#endif
 extern word _call getVersion( void );
 extern word _dist _call getCacheSize( void );
 extern void _dist _call CxCPUIDEnable( void );
 extern void _dist _call getCPUID( dword Level, pointer Result );
#ifndef __DPMI__
 #ifndef __Windows__
  #ifndef __Win32__
   extern byte _dist pascal isV86( void );
   /* extern byte _dist pascal checkEMM386( void ); */
  #endif
 #endif
#endif

 /* ...and variables */
 extern byte pascal cpu;
 extern byte pascal fpu;
 extern word pascal extFlags;
 extern byte pascal cpuid0[12];
 extern dword pascal cpuid1;
 extern dword pascal cpuBrand;
 extern dword pascal cpuFeatures;

#ifdef __cplusplus
 }
#endif

#endif  /* __LIB__ */

#endif  /* __TMi0SDGL_H */
