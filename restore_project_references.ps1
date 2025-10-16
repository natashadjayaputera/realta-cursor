param(
    [string]$BackupFile,
    [string]$ProjectFile
)

if (Test-Path $BackupFile) {
    $backupContent = Get-Content $BackupFile -Raw
    $currentContent = Get-Content $ProjectFile -Raw
    
    # Extract ProjectReference ItemGroup from backup using regex with Singleline option
    $match = [regex]::Match($backupContent, '<ItemGroup>\s*<ProjectReference.*?</ItemGroup>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if ($match.Success) {
        $projectRefs = $match.Value
        
        # Add ProjectReference ItemGroup before the closing </Project> tag
        $currentContent = $currentContent -replace '</Project>', ($projectRefs + [Environment]::NewLine + '</Project>')
        Set-Content $ProjectFile -Value $currentContent -NoNewline
        Write-Host 'ProjectReference ItemGroup restored from backup'
    } else {
        Write-Host 'No ProjectReference ItemGroup found in backup file'
    }
} else {
    Write-Host 'Backup file not found: ' $BackupFile
}
