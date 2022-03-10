rem binobj introscn.txt introscn.obj introtext

tpc -Tc:\bp\bin -L -GD -B -$A+ -$G- -$R- -$S- -$O- -DSTARTUP_MSGS detect\detectgr
tpc -Tc:\bp\bin -L -GD -B -$A+ -$G- -$R- -$S- -$O- -DSTARTUP_MSGS topbench
\pasutils\lastlook\lastlook \compiled\topbench.exe
pause
pklite d:\compiled\topbench.exe

del c:\temp\topbv40c.zip
pkzip -ex c:\temp\topbv40c.zip d:\compiled\topbench.exe database.ini topbench.txt
copy c:\temp\topbv40c.zip .
copy c:\temp\topbv40c.zip s:\temp\tmp
