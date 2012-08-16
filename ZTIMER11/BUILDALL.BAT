@echo off
rem
rem Batch file to build all versions of the Zen Timer library
rem
make -B -Dsmall build
if errorlevel 1 goto errorend
make -B -Dmedium build
if errorlevel 1 goto errorend
make -B -Dcompact build
if errorlevel 1 goto errorend
make -B -Dlarge build
if errorlevel 1 goto errorend
make -B -Dhuge build
if errorlevel 1 goto errorend
make install_inc
make clean
echo Done!
goto end
:errorend
echo ****************************************************************
echo * An error occurred while building the Zen Timer library.      *
echo ****************************************************************
:end

