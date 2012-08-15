/****************************************************************************
 CPUDET16.H  TMi0SDGL R2 16-bit DLL import header file           Version 2.15

 Too-Much-in-0ne-So-Don't-Get-Lost(tm) Revision 2 CPU/FPU Detection Library
 Copyright(c) 1996-2000 by B-coolWare.  Written by Bobby Z.
 ****************************************************************************
 To use CPUDET16.DLL in your Windows application, add this header file and
 CPUDET16.LIB Import Library to your project. If you do not have an import
 library or it is not in format, compatible with your compiler/linker, then
 you can create one by typing magic words "IMPLIB CPUDET16.LIB CPUDET16.DLL"
 at the command prompt in the directory where CPUDET16.DLL resides.
*/

/* defines that affect compilation:

   __need_fp_cpu_Speed__      type: define
                           default: not defined
                           purpose: whether to link fcpu_Speed()
                                    if defined, compiler will link in extra
                                    code for floating point error control,
                                    etc.
*/

#ifdef  __CPUDET32_H__
 You can only use 16-bit or 32-bit version of the DLL in your application,
 not both...
#endif

#ifndef __CPUDET16_H__ /* avoid subsequent inclusion of this file */
#define __CPUDET16_H__

typedef unsigned char byte;
typedef unsigned int word;
typedef unsigned long dword;
typedef void far * pointer;

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


typedef struct { dword eax;
                 dword ebx;
                 dword ecx;
                 dword edx; } customCpuid;

/* imported functions */
#ifdef __cplusplus
 extern "C" {
#endif
extern char* pascal cpu_Type();
extern char* pascal fpu_Type();
extern int   pascal cpu_Speed();
extern int   pascal ncpu_Speed();
#ifdef __need_fp_cpu_Speed__
extern double pascal fcpu_Speed();
#endif
extern void  pascal CxCPUIDEnable();
extern void  pascal getCPUID( dword Level, customCpuid * Result );
extern byte  pascal getCPU();
extern byte  pascal getFPU();
extern char* pascal getVendorString();
extern dword pascal getSteppingInfo();
extern dword pascal getCPUFeatures();
extern word  pascal getExtraFlags();
extern char* pascal getCPUSerialNumber();
extern word  pascal getVersion();
#ifdef __cplusplus
 }
#endif

#endif /* __CPUDET16_H__ */
