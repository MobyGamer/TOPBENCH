Attribute VB_Name = "TMi0SDGL"
' CPUDET32.BAS - TMi0SDGL R2 library import module for Visual Basic 5.0
'
' Copyright(c) 1997 by Jeff Miko, used with permission

Public Declare Function getCpuType Lib "cpudet32.dll" Alias "cpu_Type" () As String
' returns descriptive CPU identifier string
Public Declare Function getFpuType Lib "cpudet32.dll" Alias "fpu_Type" () As String
' returns descriptive FPU identifier string
Public Declare Function getCpuSpeed Lib "cpudet32.dll" Alias "cpu_Speed" () As Integer
' returns raw CPU clock speed
Public Declare Function getNormCpuSpeed Lib "cpudet32.dll" Alias "ncpu_Speed" () As Integer
' returns normalized CPU clock speed
Public Declare Function getFpuSpeed Lib "cpudet32.dll" Alias "fcpu_Speed" () As Double
' returns raw CPU clock speed
Public Declare Function getVendorString Lib "cpudet32.dll" () As String
' returns CPU vendor string where applicable (486s, Pentium, etc.)
Public Declare Function getCPUFeatures Lib "cpudet32.dll" () As Integer
' returns processor feature flags from CPUID output
Public Declare Function getExtraFlags Lib "cpudet32.dll" () As Integer
' returns processor "extra" flags (library-defined)
Public Declare Function getCPUSerialNumber Lib "cpudet32.dll" () As String
' returns processor serial number or empty string if this feature is
' not supported
Public Declare Function getVersion Lib "cpudet32.dll" () As Integer
' returns library version in BCD
