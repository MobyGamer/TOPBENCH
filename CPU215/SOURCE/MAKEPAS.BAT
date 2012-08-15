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
: make Pascal demos
make -fmakefile._p cpupas cpupm p5infop cpupas32
rem copy *.exe ..\exe
copy *.tp? ..\lib
rem copy *.dcu ..\lib
