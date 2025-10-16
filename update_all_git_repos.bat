@echo off
title Update all nested Git repositories
echo ============================================
echo Updating all nested Git repositories recursively
echo ============================================
echo.

REM Confirm current directory
echo Root directory: %cd%
echo.

REM Pause for safety
set /p confirm=This will stage all changes, checkout master, fetch, and pull in ALL NESTED repos. Continue (Y/N)? 
if /I not "%confirm%"=="Y" (
    echo Operation cancelled.
    pause
    exit /b
)

echo.
echo Searching for nested Git repositories...
echo.

REM Get full path of root .git folder if it exists
set "rootgit=%cd%\.git"

for /r /d %%d in (.git) do (
    if exist "%%d" (
        REM Skip the root .git folder
        if /I not "%%~fd"=="%rootgit%" (
            pushd "%%~dpd"
            echo --------------------------------------------
            echo Repository found: %%~dpd
            echo --------------------------------------------
            call :UpdateRepo
            popd
            echo.
        )
    )
)

echo ============================================
echo All nested repositories processed.
echo ============================================
pause
exit /b


:UpdateRepo
REM Make sure git is available
where git >nul 2>nul
if errorlevel 1 (
    echo Git is not installed or not in PATH!
    exit /b
)

REM Stage any uncommitted changes first
echo Staging all changes...
git add -A >nul 2>&1
if errorlevel 1 (
    echo Failed to stage changes.
) else (
    echo Changes staged successfully.
)

REM Optionally commit staged changes (uncomment if you want automatic commit)
REM echo Committing staged changes...
REM git commit -m "Auto commit before pull" >nul 2>&1

REM Checkout to master, fetch, and pull
echo Checking out master...
git checkout master >nul 2>&1
if errorlevel 1 (
    echo Failed to checkout master.
) else (
    echo Fetching latest changes...
    git fetch --all --prune
    echo Pulling latest changes...
    git pull
)
exit /b
