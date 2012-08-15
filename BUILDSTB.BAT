del \compiled\topbstub.*
del \compiled\dstub.*
binobj stubtext.txt stubtext.obj stubtext
binobj helptext.txt helptext.obj helptext

tpc -Tc:\bp\bin -L -GD -B -$A+ -$G- -$R+ -$S+ -DSVGADEBUG detect\detectgr
tpc -Tc:\bp\bin -L -GD -B -$A+ -$G- -$R+ -$S+ -V -DSVGADEBUG topbstub

ren \compiled\topbstub.exe dstub.exe
ren \compiled\topbstub.map dstub.map
tpc -Tc:\bp\bin -L -GD -B -$A+ -$G- -$R- -$S- -DOVERLAYS detect\detectgr
tpc -Tc:\bp\bin -L -GD -B -$A+ -$G- -$R- -$S- -DOVERLAYS topbstub
rem pklite \compiled\topbstub.exe

del c:\temp\tstub097.zip
cd \compiled
pkzip -ex c:\temp\tstub097.zip dstub.exe dstub.map topbstub.exe topbstub.ovr
cd \topbench
pkzip -ex c:\temp\tstub097.zip whatsnew.txt readstub.txt

