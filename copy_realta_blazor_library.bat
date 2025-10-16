@echo off
REM =============================================================================
REM Copy RealtaBlazorLibrary to System folder with correct structure
REM This script copies from .library/net-core-library/RealtaBlazorLibrary to 
REM net6/RSF/BIMASAKTI_11/1.00/PROGRAM/SYSTEM/ with proper DLL references
REM =============================================================================

echo Starting RealtaBlazorLibrary copy operation...
echo.

REM Set source and destination paths
set "SOURCE_PATH=.library\net-core-library\RealtaBlazorLibrary"
set "DEST_PATH=net6\RSF\BIMASAKTI_11\1.00\PROGRAM\SYSTEM"

REM Check if source path exists
if not exist "%SOURCE_PATH%" (
    echo ERROR: Source path "%SOURCE_PATH%" does not exist!
    echo Please make sure you're running this script from the correct directory.
    pause
    exit /b 1
)

REM Check if destination path exists
if not exist "%DEST_PATH%" (
    echo ERROR: Destination path "%DEST_PATH%" does not exist!
    echo Please make sure you're running this script from the correct directory.
    pause
    exit /b 1
)

echo Source: %SOURCE_PATH%
echo Destination: %DEST_PATH%
echo.

REM Create backup of existing BlazorMenu project if it exists
set "BLAZOR_MENU_DEST=%DEST_PATH%\SOURCE\Menu\BlazorMenu"
if exist "%BLAZOR_MENU_DEST%" (
    echo Creating backup of existing BlazorMenu project...
    set "BACKUP_PATH=%DEST_PATH%\SOURCE\Menu\BlazorMenu_backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
    set "BACKUP_PATH=%BACKUP_PATH: =0%"
    xcopy "%BLAZOR_MENU_DEST%" "%BACKUP_PATH%\" /E /I /H /Y >nul
    echo Backup created at: %BACKUP_PATH%
    echo.
)

REM Backup existing BlazorMenu files before copying new ones
echo Backing up existing BlazorMenu files...
set "EXISTING_PROJECT_FILE=%BLAZOR_MENU_DEST%\BlazorMenu.csproj"
set "EXISTING_APP_RAZOR_FILE=%BLAZOR_MENU_DEST%\App.razor"
set "BACKUP_PROJECT_FILE=%BLAZOR_MENU_DEST%\BlazorMenu.csproj.backup"
set "BACKUP_APP_RAZOR_FILE=%BLAZOR_MENU_DEST%\App.razor.backup"

if exist "%EXISTING_PROJECT_FILE%" (
    copy "%EXISTING_PROJECT_FILE%" "%BACKUP_PROJECT_FILE%" >nul
    echo Project file backed up for preservation
)
if exist "%EXISTING_APP_RAZOR_FILE%" (
    copy "%EXISTING_APP_RAZOR_FILE%" "%BACKUP_APP_RAZOR_FILE%" >nul
    echo App.razor file backed up for preservation
)

REM Copy BlazorMenu project files
echo Copying BlazorMenu project files...
if exist "%SOURCE_PATH%\BlazorMenu" (
    xcopy "%SOURCE_PATH%\BlazorMenu" "%BLAZOR_MENU_DEST%\" /E /I /H /Y
    echo BlazorMenu project copied successfully.
) else (
    echo WARNING: BlazorMenu source directory not found!
)

REM Copy DLL directories to LIBRARY folder
echo.
echo Copying DLL directories to LIBRARY folder...

REM Copy Dll Back to LIBRARY\Back
if exist "%SOURCE_PATH%\Dll Back" (
    echo Copying Dll Back...
    xcopy "%SOURCE_PATH%\Dll Back" "%DEST_PATH%\SOURCE\LIBRARY\Back\" /E /I /H /Y
    echo Dll Back copied successfully.
)

REM Copy Dll Engine to LIBRARY\Engine
if exist "%SOURCE_PATH%\Dll Engine" (
    echo Copying Dll Engine...
    xcopy "%SOURCE_PATH%\Dll Engine" "%DEST_PATH%\SOURCE\LIBRARY\Engine\" /E /I /H /Y
    echo Dll Engine copied successfully.
)

REM Copy Dll Front to LIBRARY\Front
if exist "%SOURCE_PATH%\Dll Front" (
    echo Copying Dll Front...
    xcopy "%SOURCE_PATH%\Dll Front" "%DEST_PATH%\SOURCE\LIBRARY\Front\" /E /I /H /Y
    echo Dll Front copied successfully.
)

REM Copy Dll Menu to LIBRARY\Menu
if exist "%SOURCE_PATH%\Dll Menu" (
    echo Copying Dll Menu...
    xcopy "%SOURCE_PATH%\Dll Menu" "%DEST_PATH%\SOURCE\LIBRARY\Menu\" /E /I /H /Y
    echo Dll Menu copied successfully.
)

REM Copy Dll Menu Back to LIBRARY\MenuBack
if exist "%SOURCE_PATH%\Dll Menu Back" (
    echo Copying Dll Menu Back...
    xcopy "%SOURCE_PATH%\Dll Menu Back" "%DEST_PATH%\SOURCE\LIBRARY\MenuBack\" /E /I /H /Y
    echo Dll Menu Back copied successfully.
)

REM Copy Dll Report Server to LIBRARY\ReportServer
if exist "%SOURCE_PATH%\Dll Report Server" (
    echo Copying Dll Report Server...
    xcopy "%SOURCE_PATH%\Dll Report Server" "%DEST_PATH%\SOURCE\LIBRARY\ReportServer\" /E /I /H /Y
    echo Dll Report Server copied successfully.
)

REM Note: Solution file copying removed as requested

REM Update BlazorMenu.csproj file in the net6 folder with correct DLL references
echo.
echo Updating BlazorMenu.csproj file in net6 folder with correct DLL references...

set "PROJECT_FILE=%BLAZOR_MENU_DEST%\BlazorMenu.csproj"
if exist "%PROJECT_FILE%" (
    echo Updating project file: %PROJECT_FILE%
    
    REM Use PowerShell to update the project file with correct DLL paths
    powershell -Command "$content = Get-Content '%PROJECT_FILE%' -Raw; $content = $content -replace '\.\.\\Dll Menu\\', '..\..\LIBRARY\Menu\'; $content = $content -replace '\.\.\\Dll Front\\', '..\..\LIBRARY\Front\'; $content = $content -replace '\.\.\\Dll Back\\', '..\..\LIBRARY\Back\'; $content = $content -replace '\.\.\\Dll Engine\\', '..\..\LIBRARY\Engine\'; $content = $content -replace '\.\.\\Dll Menu Back\\', '..\..\LIBRARY\MenuBack\'; $content = $content -replace '\.\.\\Dll Report Server\\', '..\..\LIBRARY\ReportServer\'; Set-Content '%PROJECT_FILE%' -Value $content -NoNewline; Write-Host 'Project file updated with correct LIBRARY paths'"
    
    REM Restore ProjectReference ItemGroup from backup if it exists
    if exist "%BACKUP_PROJECT_FILE%" (
        echo Restoring ProjectReference ItemGroup from backup...
        powershell -ExecutionPolicy Bypass -File "restore_project_references.ps1" -BackupFile "%BACKUP_PROJECT_FILE%" -ProjectFile "%PROJECT_FILE%"
    ) else (
        echo No backup project file found - skipping ProjectReference restoration
    )
    
    echo Project file updated successfully.
) else (
    echo WARNING: BlazorMenu.csproj file not found at %PROJECT_FILE%
)

REM Preserve program list in App.razor
echo.
echo Preserving program list in App.razor...

set "APP_RAZOR_FILE=%BLAZOR_MENU_DEST%\App.razor"
if exist "%APP_RAZOR_FILE%" (
    echo App.razor file found.
    
    REM Restore program list from backup if it exists
    if exist "%BACKUP_APP_RAZOR_FILE%" (
        echo Restoring App.razor program list from backup...
        powershell -ExecutionPolicy Bypass -File "restore_app_razor_programs.ps1" -BackupFile "%BACKUP_APP_RAZOR_FILE%" -AppRazorFile "%APP_RAZOR_FILE%"
    ) else (
        echo No backup App.razor file found - skipping program list restoration
    )
    
    echo App.razor program list preserved successfully.
) else (
    echo WARNING: App.razor file not found at %APP_RAZOR_FILE%
)

REM Clean up backup files
if exist "%BACKUP_PROJECT_FILE%" del "%BACKUP_PROJECT_FILE%" >nul 2>&1
if exist "%BACKUP_APP_RAZOR_FILE%" del "%BACKUP_APP_RAZOR_FILE%" >nul 2>&1

REM Clean up any temporary files
if exist "%TEMP_FILE%" del "%TEMP_FILE%" >nul 2>&1

echo.
echo =============================================================================
echo Copy operation completed successfully!
echo.
echo Summary:
echo - BlazorMenu project copied to: %BLAZOR_MENU_DEST%
echo - DLL libraries copied to: %DEST_PATH%\SOURCE\LIBRARY\
echo - Project references updated to point to ..\..\LIBRARY\ paths
echo - ProjectReference ItemGroup automatically restored from existing files
echo - App.razor program list automatically restored from existing files
echo.
echo The BlazorMenu project should now reference DLLs from the correct LIBRARY paths
echo and maintain your existing ProjectReference ItemGroup and program assemblies.
echo =============================================================================

pause
