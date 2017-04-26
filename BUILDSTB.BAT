del \compiled\topbstub.*
del \compiled\dstub.*
binobj stubtext.txt stubtext.obj stubtext
del helptext.obj
rem binobj helptext.txt helptext.obj helptext

tpc -Tc:\bp\bin -L -GD -B -$A+ -$G- -$R+ -$S+ -DSVGADEBUG detect\detectgr
tpc -Tc:\bp\bin -L -GD -B -$A+ -$G- -$R+ -$S+ -V -DSVGADEBUG topbstub

ren \compiled\topbstub.exe dstub.exe
ren \compiled\topbstub.map dstub.map
REM tpc -Tc:\bp\bin -L -GD -B -$A+ -$G- -$R- -$S- -DOVERLAYS detect\detectgr
REM tpc -Tc:\bp\bin -L -GD -B -$A+ -$G- -$R- -$S- -DOVERLAYS topbstub
tpc -Tc:\bp\bin -L -GD -B -$A+ -$G- -$R- -$S- detect\detectgr
tpc -Tc:\bp\bin -L -GD -B -$A+ -$G- -$R- -$S- topbstub
rem pklite \compiled\topbstub.exe

del c:\temp\tstub97d.zip
cd \compiled
pkzip -ex c:\temp\tstub97d.zip dstub.exe dstub.map topbstub.exe topbstub.ovr
cd \topbench
pkzip -ex c:\temp\tstub97d.zip whatsnew.txt readstub.txt

copy c:\temp\tstub97d.zip s:\temp\tmp

