$prefetchPath = "C:\Windows\Prefetch"
$logDir = "C:/temp/pccheck/logs"

# Ensure the 'logs' directory exists (silent creation)
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

# Set the markdown header for Prefetch
$pfFilesHeader = "## Prefetch Files`n"

if (Test-Path $prefetchPath) {
    Write-Host "[*] Scanning Prefetch folder." -ForegroundColor DarkYellow
    $pfFiles = Get-ChildItem -Path $prefetchPath -Filter *.pf -File
    if ($pfFiles.Count -gt 5) {
        Write-Host "    [+] Found $($pfFiles.Count) .pf files in the Prefetch folder." -ForegroundColor Green
        # Log the header for the section
        $pfFilesHeader | Out-File -Append -FilePath "$logDir/PrefetchFiles.md"

        # Log each .pf file into markdown format
        foreach ($file in $pfFiles) {
            $logEntry = "{0} | {1}" -f $file.Name, $file.LastWriteTime
            "- $logEntry" | Out-File -Append -FilePath "$logDir/PrefetchFiles.md"
        }
    }
    else {
        Write-Host "    [!!!] No files found in Prefetch." -ForegroundColor Red
        # Log message for no files found
        "### [!!!] No .pf files found in the Prefetch folder." | Out-File -Append -FilePath "$logDir/PrefetchFiles.md"
    }
}
else {
    Write-Host "    [!!!] Prefetch folder not found." -ForegroundColor Red
    # Log message for missing Prefetch folder
    "### [!!!] Prefetch folder not found." | Out-File -Append -FilePath "$logDir/PrefetchFiles.md"
}

