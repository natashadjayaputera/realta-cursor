@echo off
title Clean bin, obj, and packages folders
echo ============================================
echo Cleaning all bin, obj, and packages folders recursively
echo ============================================
echo.

REM Confirm the current directory
echo Current directory: %cd%
echo.

REM Pause for safety (optional - remove if you want it fully automatic)
set /p confirm=Are you sure you want to delete all bin, obj, and packages folders (Y/N)? 
if /I not "%confirm%"=="Y" (
    echo Operation cancelled.
    pause
    exit /b
)

REM Delete bin folders
echo.
echo Deleting bin folders...
for /d /r %%d in (bin) do (
    if exist "%%d" (
        echo Deleting: %%d
        rd /s /q "%%d"
    )
)

REM Delete obj folders
echo.
echo Deleting obj folders...
for /d /r %%d in (obj) do (
    if exist "%%d" (
        echo Deleting: %%d
        rd /s /q "%%d"
    )
)

REM Delete packages folders
echo.
echo Deleting packages folders...
for /d /r %%d in (packages) do (
    if exist "%%d" (
        echo Deleting: %%d
        rd /s /q "%%d"
    )
)

echo.
echo ============================================
echo All bin, obj, and packages folders have been deleted.
echo ============================================
pause
