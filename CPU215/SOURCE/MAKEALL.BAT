@echo off
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: MAKEALL.BAT ::::::
:: TMi0SDGL Revision 2 Version 2.15 Build Batch Script                       ::
::...........................................................................::
:: Makes all demo targets and moves them to proper directories. This batch   ::
:: assumes that it is ran from SOURCE directory and ..\EXE and ..\LIB        ::
:: directories exist. This is the default directory tree for TMi0SDGL.       ::
::...........................................................................::
:: Copyright(c) 1996-2000 by B-coolWare.  Written by Bobby Z.                ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo TMi0SDGL Revision 2 MakeAll Batch  Version 2.15
echo Making all targets and moving to proper directories, please wait...
: save this .EXE because it is not rebuilt (no source code)
copy ..\exe\getdirs.exe ..\exe\getdirs.sav
: remove all libraries and executables already built
del ..\exe\*.exe
del ..\exe\*.com
del ..\lib\*.lib
del ..\lib\*.tp?
del ..\lib\*.dcu
: make Pascal demos
make -fmakefile._p cpupas cpupm p5infop cpupas32
copy *.exe ..\exe
del *.exe
copy *.tp? ..\lib
del *.tp?
copy *.dcu ..\lib
del *.dcu
: cleanup after make
make -fmakefile._p clean
: make .EXE version of C demo
make -fmakefile._c -DMODEL=__LARGE__ cpuc p5c clean
copy *.exe ..\exe
del *.exe
make -fmakefile._c -DMODEL=__TINY__ cpuc.com clean
copy *.com ..\exe
del *.com
: make all memory model libraries
make -fmakefile._c -DMODEL=__SMALL__ library clean
make -fmakefile._c -DMODEL=__MEDIUM__ library clean
make -fmakefile._c -DMODEL=__COMPACT__ library clean
make -fmakefile._c -DMODEL=__HUGE__ library clean
make -fmakefile._c -DMODEL=__X32__ cputype3.lib clean
copy *.lib ..\lib
del *.lib
: make C++ version of demo
make -fmakefile._cp -DMODEL=__LARGE__ cpucpp clean
del *.lib
copy *.exe ..\exe
del *.exe
copy ..\exe\getdirs.sav ..\exe\getdirs.exe
del ..\exe\*.sav
: check for makefile and make DLLs if the source code installed for them
if exist makefile._dl make -fmakefile._dl cpudet16.dll cpudet32.dll cpudet32.w95 clean
echo Done!
