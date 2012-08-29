rem binobj introscn.txt introscn.obj introtext

tpc -Tc:\bp\bin -L -GD -B -$A+ -$G- -$R- -$S- -$O- detect\detectgr
tpc -Tc:\bp\bin -L -GD -B -$A+ -$G- -$R- -$S- -$O- topbench
\pasutils\lastlook\lastlook \compiled\topbench.exe
pause
pklite d:\compiled\topbench.exe

del c:\temp\topbv36.zip
pkzip -ex c:\temp\topbv36.zip d:\compiled\topbench.exe database.ini topbench.txt
copy c:\temp\topbv36.zip s:\temp\tmp
