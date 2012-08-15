@echo off
rem == Simple batch file that builds all of the include files necessary
rem == for the benchmark.  This was done so that the bulk of the
rem == assembler code used in the test was in its own file, which was
rem == necessary because it needs to be sucked into the main program
rem == twice -- once as part of exact measuring, and again as part
rem == of a NON-measured block that makes up the synthetic test score.
rem == (Yes, it's wasteful, but it's accurate.)
echo Making test suite blocks...
copy _mblock.inc _mblock.bak
rem copy _nops.inc _nops.bak
copy _ea.inc _ea.bak
copy _opcodes.inc _opcodes.bak
copy _3dgames.inc _3dgames.bak
rem copy _unroll.inc _unroll.bak
copy _vidmem.inc _vidmem.bak

copy _mblock.hea + _mblock.bod + _mblock.tai _mblock.inc
rem copy _nops.hea + _nops.bod + _nops.tai _nops.inc
copy _ea.hea + _ea.bod + _ea.tai _ea.inc
copy _opcodes.hea + _opcodes.bod + _opcodes.tai _opcodes.inc
copy _3dgames.hea + _3dgames.bod + _3dgames.tai _3dgames.inc
rem copy _unroll.hea + _unroll.bod + _unroll.tai _unroll.inc
copy _vidmem.hea + _vidmem.bod + _vidmem.tai _vidmem.inc

rem == Building the "runall" procedure requires us to combine all of
rem == the individual tests together without their CALLs to _PZTimerOn/Off.
echo Combining test into runall body...
copy _mblock.bod + _ea.bod + _opcodes.bod + _3dgames.bod + _vidmem.bod _runall.tmp
echo Stripping Zen Timer calls from runall body...
xgrep -v _PZTimer _runall.tmp > _runall.bod
echo Building runall procedure...
copy _runall.hea + _runall.bod + _runall.tai _runall.inc
del _runall.tmp
echo Done building pascal include files for TOPBENCH.
