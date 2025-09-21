# Direct paths for the combined file and compiled regex
$combinedFile = Join-Path ([System.Environment]::GetFolderPath('Desktop')) 'PcCheckLogs.md'

# compiled regex for suspicious exe names (case-insensitive)
$regex = [regex]'(?i)^(?:[a-zA-Z0-9]{10}|gc(?:\s\(\d+\))*|SKREECHWARE(?:\s\(\d+\))*|loader)\.exe$'
# names to exclude (also case-insensitive)
$excludeRegex = [regex]'(?i)jrunscript|jwebserver|policytool|servertool|downloader'

if (-not (Test-Path $combinedFile)) {
    Write-Host "[!] Combined log file does not exist." -ForegroundColor Red
    return
}

Write-Host "[*] Scanning for suspicious .exe files under $env:UserProfile." -ForegroundColor DarkYellow

# Enumerate only .exe files (provider-level filter) and suppress access errors
$exeFiles = Get-ChildItem -Path $env:UserProfile -Recurse -File -Filter '*.exe' -ErrorAction SilentlyContinue

# Ensure result is always an array so .Count is reliable
$susFiles = @(
    $exeFiles | Where-Object {
        $regex.IsMatch($_.Name) -and -not ($excludeRegex.IsMatch($_.Name))
    }
)

# Search the combined markdown for suspicious lines (also as an array)
$filteredLines = @(
    Select-String -Path $combinedFile -Pattern $regex.ToString() -ErrorAction SilentlyContinue
)

# If anything found, append sections to the combined file
if ($susFiles.Count -gt 0 -or $filteredLines.Count -gt 0) {
    Write-Host "[!] Found suspicious files. Appending to the combined log." -ForegroundColor Red

    "## Suspicious Files Found`n" | Out-File -Append -FilePath $combinedFile -Encoding utf8

    if ($susFiles.Count -gt 0) {
        "### On disk:`n" | Out-File -Append -FilePath $combinedFile -Encoding utf8
        foreach ($f in $susFiles) {
            "- $($f.FullName)" | Out-File -Append -FilePath $combinedFile -Encoding utf8
        }
        "" | Out-File -Append -FilePath $combinedFile -Encoding utf8
    }

    if ($filteredLines.Count -gt 0) {
        "### In logs:`n" | Out-File -Append -FilePath $combinedFile -Encoding utf8
        foreach ($m in $filteredLines) {
            # Select-String returns MatchInfo; .Line holds the matched line
            "- $($m.Line)" | Out-File -Append -FilePath $combinedFile -Encoding utf8
        }
        "" | Out-File -Append -FilePath $combinedFile -Encoding utf8
    }

    Write-Host "[-] Appended $($susFiles.Count) on-disk hits and $($filteredLines.Count) log matches." -ForegroundColor DarkYellow
}
else {
    Write-Host "[+] No suspicious files found." -ForegroundColor Green
}
