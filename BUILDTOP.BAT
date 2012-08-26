binobj introscn.txt introscn.obj introtext

tpc -Tc:\bp\bin -L -GD -B -$A+ -$G- -$R- -$S- -$O- detect\detectgr
tpc -Tc:\bp\bin -L -GD -B -$A+ -$G- -$R- -$S- -$O- topbench
\pasutils\lastlook\lastlook \compiled\topbench.exe
pause
pklite d:\compiled\topbench.exe

del c:\temp\topbv35.zip
pkzip -ex c:\temp\topbv35.zip d:\compiled\topbench.exe database.ini
copy c:\temp\topbv35.zip s:\temp\tmp
