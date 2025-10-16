param(
    [string]$BackupFile,
    [string]$AppRazorFile
)

if (Test-Path $BackupFile) {
    $backupContent = Get-Content $BackupFile -Raw
    $currentContent = Get-Content $AppRazorFile -Raw
    
    # Extract lazyLoadedAssemblies list from backup
    if ($backupContent -match 'lazyLoadedAssemblies\s*=\s*new\(\)\s*\{[^}]*\}') {
        $programList = [regex]::Match($backupContent, 'lazyLoadedAssemblies\s*=\s*new\(\)\s*\{[^}]*\}', [System.Text.RegularExpressions.RegexOptions]::Singleline).Value
        
        # Replace the lazyLoadedAssemblies list in current file
        $currentContent = $currentContent -replace 'lazyLoadedAssemblies\s*=\s*new\(\)\s*\{[^}]*\}', $programList
        Set-Content $AppRazorFile -Value $currentContent -NoNewline
        Write-Host 'App.razor program list restored from backup'
    } else {
        Write-Host 'No lazyLoadedAssemblies list found in backup file'
    }
} else {
    Write-Host 'Backup file not found: ' $BackupFile
}
