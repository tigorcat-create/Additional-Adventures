@ECHO off

:: Set those lines to fit your setup.
:: This is where mod_wlife.qsp will be copied. If you don't want to move it just comment (::) the line below.
:: set CP_TO=..\GL_ECV

:: This is the program used to open the QSPFILE. If you comment this line windows will launch the default app for the ".qsp" extension.
set QSPGUI=..\..\tools\Player-video\qspgui.exe
set QGEN=..\..\tools\QGen5\QGen.exe

:: The file that will be generated or open
set QSPFILE=public_WC.qsp
set TXTFILE=public_WC.txt
set QPROJFILE=public_WC.qproj

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:menu
cls
echo.
echo :: QSP Compiler and Launcher
echo.

if defined QGEN (
    if not exist "%QGEN%" (
        echo QGEN     : [ERROR] - %QGEN%  not found. Using DEFAULT application.
        set QGEN=
    ) else ( echo QGEN     : [OK] - "%QGEN%")
) else echo QGEN     : [NOT DEFINED] - Using DEFAULT application.

if defined QSPGUI (
    if not exist "%QSPGUI%" (
        echo QSP EXEC : [ERROR] - %QSPGUI% not found.
        set QSPGUI=
    ) else ( echo QSP EXEC : [OK] - "%QSPGUI%")
) else ( echo QSP EXEC : [NOT DEFINED] - Using Windows DEFAULT.)

if defined QSPFILE (
    if not exist "%QSPFILE%" (
        echo QSP FILE : [WARNING] - %QSPFILE% not found.
    ) else ( echo QSP FILE : [OK] - "%QSPFILE%")
) else ( echo QSP FILE : [NOT DEFINED] - ERROR: CAN'T CONTINUE.)

if defined CP_TO (
    if not exist "%CP_TO%" (
        echo COPY     : [ERROR] - Destination "%CP_TO%" not found. Copy DISABLED.
        set CP_TO=
    ) else ( echo COPY     : [OK] - "%CP_TO%")
) else (  echo COPY     : [DISABLED] )

if not exist "..\..\mod" (
    echo mod      : [ERROR] - Destination "..\..\mod" not found.
)

echo.

if defined NOT_FOUND (
    echo ERROR: Option '%action%' wasn't recognized. Is it lowercase?
    set NOT_FOUND=
)

echo.
echo ACTIONS: (B)uild  Build to (M)od  (R)un  (Q)Gen  (E)xit
echo.
set /p action=Choose an action:

if defined QSPFILE (
    if %action% == b goto build
    if %action% == B goto build
    if %action% == m goto build
    if %action% == M goto build
    if %action% == r goto run
    if %action% == R goto run
    if %action% == q goto qgen
    if %action% == Q goto qgen
)

if %action% == e goto exit
if %action% == E goto exit

set NOT_FOUND=1
goto menu

:build
echo.
echo Building ...
:: Start timer
set start=%time%
@ECHO ON
..\..\tools\qsp-cli.exe --compile  locations %QSPFILE% %QPROJFILE% --no-builddate
@ECHO OFF

echo.
if %action% == m ( echo Copying %QSPFILE% to "mod" ... & copy %QSPFILE% ..\..\mod\%QSPFILE% > nul )
if %action% == M ( echo Copying %QSPFILE% to "mod" ... & copy %QSPFILE% ..\..\mod\%QSPFILE% > nul )

echo.
if defined CP_TO ( echo Copying %QSPFILE% to "%CP_TO%" ... & copy %QSPFILE% %CP_TO%\%QSPFILE%  > nul )

echo.
echo Done.
:: End timer
set end=%time%

call :elapsedtime

pause
if %action% == f ( goto run ) else ( goto menu )

:qgen
echo.
echo Running ...
if defined CP_TO ( start %QGEN% %CP_TO%\%QSPFILE% ) else ( start %QGEN% %QSPFILE% )
goto exit

:run
echo.
echo Running ...

if defined CP_TO ( start %QSPGUI% %CP_TO%\%QSPFILE% ) else ( start %QSPGUI% %QSPFILE% )


:elapsedtime
setlocal enabledelayedexpansion

for /f "tokens=1-4 delims=:., " %%a in ("%start%") do (
    set /a start_h=%%a
    set /a start_m=100%%b %% 100
    set /a start_s=100%%c %% 100
    set /a start_ms=100%%d %% 100
)
for /f "tokens=1-4 delims=:., " %%a in ("%end%") do (
    set /a end_h=%%a
    set /a end_m=100%%b %% 100
    set /a end_s=100%%c %% 100
    set /a end_ms=100%%d %% 100
)

set /a ms=end_ms - start_ms
if !ms! lss 0 (
    set /a ms+=100
    set /a end_s-=1
)

set /a secs=end_s - start_s
if !secs! lss 0 (
    set /a secs+=60
    set /a end_m-=1
)

set /a mins=end_m - start_m
if !mins! lss 0 (
    set /a mins+=60
    set /a end_h-=1
)

set /a hours=end_h - start_h
if !hours! lss 0 (
    set /a hours+=24
)

if !ms! lss 10 set ms=0!ms!
if !secs! lss 10 set secs=0!secs!
if !mins! lss 10 set mins=0!mins!
if !hours! lss 10 set hours=0!hours!

if !hours! NEQ 00 (
    set elapsedtime=!hours!:!mins!:!secs!.!ms!
) else if !mins! NEQ 00 (
    set elapsedtime=!mins!:!secs!.!ms!
) else (
    set elapsedtime=!secs!.!ms!
)


echo Elapsed time: %elapsedtime%

endlocal & set elapsedtime=%elapsedtime%

:exit