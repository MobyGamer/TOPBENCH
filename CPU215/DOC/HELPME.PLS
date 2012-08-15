 Dear TMi0SDGL user!

 Please help me to improve the TMi0SDGL - your feedback is very appreciated.

 I want you to check this:

 1) A new utility called CHECKTSD.COM is added (in DOC directory). I had
    numerous reports that my new TSC-based speed detection code causes system
    crashes and hangs on various systems. If this happens on your system,
    please do the following:

    a) find out your chipset name if you can
    b) merge contents of your CONFIG.SYS and AUTOEXEC.BAT into a text file
       (copy c:\config.sys + c:\autoexec.bat sysconf.txt)
    c) run CHECKTSD.COM in problem environment and redirect its output to
       a file (checktsd >problem.ext)
    d) run it in clean DOS (without any CONFIG/AUTOEXEC, Windows 9x calls
       this Safe Mode Command Prompt Only) and redirect to another file
       (checktsd >clean.txt)
    e) run it in Command Prompt Only config (CONFIG/AUTOEXEC executed but
       no Windows loaded and redirect to third file (checktsd >command.txt).
    f) email resulting files and your CONFIG+AUTOEXEC text file to me for
       analysis. Please describe for which config each result file is (or use
       suggested file names).

 2) Cyrix/IBM/TI/SGS-Thomson CPU owners, please run GETDIRS.EXE program once
    on your system and mail me file it will generate to
     bobby_z@cyberdude.com
    This program tries to retrieve Cyrix architecture-specific DIRx registers
    content, which is used for chip model identification of these CPUs.
    NOTE, that this program will not produce meaningful results on Intel/AMD
    chips, so do not run it if you have such CPU. Running it on Intel/AMD
    will not crash system though :)
    Of course, do this only if your processor is misidentified by TMi0SDGL.

    Please note, that if you have a Cyrix PXXX+ CPU (XXX is a number), and
    TMi0SDGL identifies it as Cyrix 6x86, this is ok, the chip IS a 6x86,
    PXXX+ is just it's commercial name intended to tell about its
    productivity compared to Intel Pentium with clock speed of XXX.

 3) If TMi0SDGL incorrectly detects particular chip clock speed, please mail
    me a bug report, because this is a bug. Please specify chip's vendor
    and exact model as well as its real and detected clock speed. Many of
    modern chips simply were not available to me at the date of release of
    the TMi0SDGL and I was unable to adjust their timings to get correct
    clock speed. I will try to fix this as soon as possible, but without your
    feedback it will not be really soon...

 4) I had reports that TMi0SDGL crashes system on some 386SX-based machines.
    If you have the same troubles, please try to disable 386SL detection code
    by inserting a RET instruction right at the entry point to the detection
    routine (check386SL) and recompile the library. I suppose that this code
    may cause problems on some systems because it plays with CPU system
    registers available via I/O ports 20h-21h, which are also used on many
    386 system boards for interoperation with their chipsets. If elimination
    of this code helps to solve the problem, then report me back and I'll
    disable it in future releases. Anyway, this code was not tested on real
    386SL and I still do not know if it works at all...

 5) Those DLLs I added in release 2.02 were not tested thoroughly, so please
    take some time and test them in all possible configurations and report
    any problems you encountered with them.

    Note, that 32-bit DLL should not be used under Windows NT. Currently
    NT-only version of the library is being developed. Please wait until
    it is officially announced.
    Also, this DLL is not compatible with Rational DOS/4G DOS Extender,
    because it makes some Win32 API calls not supported by DOS/4G. Do not try
    to use it with your WATCOM C++ Extended DOS applications - it won't work.


 Thank you,
           Bobby Z.
