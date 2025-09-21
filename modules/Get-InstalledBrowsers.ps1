$browsers = @()
$registryPath = "HKLM:\SOFTWARE\Clients\StartMenuInternet"
$logDir = "C:/temp/pccheck/logs"

if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

$browserKeys = Get-ChildItem -Path $registryPath | Where-Object { $_.PSChildName -match "^[A-Za-z0-9]" }

foreach ($key in $browserKeys) {
    $browserName = $key.PSChildName
    $rawName = (Get-ItemProperty -Path $key.PSPath -Name "LocalizedString" -ErrorAction SilentlyContinue).LocalizedString

    # If the display name is blank or looks like a resource string, just use the key name
    if (-not $rawName -or $rawName -match '^@') {
        $browserDisplayName = $browserName
    }
    else {
        $browserDisplayName = $rawName
    }

    # Strip Gecko profile IDs from end of names (e.g. Firefox-XXXXXXXXXXXXXXX → Firefox)
    $browserDisplayName = $browserDisplayName -replace '(-[0-9A-F]{8,})$', ''

    $browsers += $browserDisplayName
}

$mdFile = "$logDir/InstalledBrowsers.md"
"## Installed Browsers`n" | Out-File -FilePath $mdFile -Encoding utf8

if ($browsers.Count -gt 0) {
    Write-Host "[+] Installed Browsers:" -ForegroundColor Green
    foreach ($b in $browsers) {
        Write-Host "    $b"
        "- $b" | Out-File -Append -FilePath $mdFile -Encoding utf8
    }
}
else {
    Write-Host "[-] No installed browsers detected." -ForegroundColor Red
    "No installed browsers detected." | Out-File -Append -FilePath $mdFile -Encoding utf8
}
