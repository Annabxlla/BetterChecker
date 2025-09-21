try {
    # Ensure the 'logs' directory exists (silent creation)
    $logDir = "C:/temp/pccheck/logs"
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir | Out-Null
    }

    # Grab all Wi-Fi adapters
    $wifiAdapters = @(Get-NetAdapter -Name * -Physical -IncludeHidden |
        Where-Object { $_.InterfaceDescription -match "Wi-Fi" })
    Start-Sleep -Seconds 1

    # Log header
    "## Wi-Fi Support`n" | Out-File -Append -FilePath "$logDir/WifiSupport.md"

    if ($wifiAdapters.Count -eq 0) {
        Write-Host "[-] No Wi-Fi adapters detected." -ForegroundColor DarkYellow
        "No Wi-Fi adapters detected." | Out-File -Append -FilePath "$logDir/WifiSupport.md"
    }
    elseif ($wifiAdapters.Count -gt 1) {
        Write-Host "[-] Multiple Wi-Fi adapters detected ($($wifiAdapters.Count))." -ForegroundColor Red
        "Multiple Wi-Fi adapters detected ($($wifiAdapters.Count))." | Out-File -Append -FilePath "$logDir/WifiSupport.md"
        $wifiAdapters | ForEach-Object {
            Write-Host "    Adapter: $($_.InterfaceDescription) - Status: $($_.Status)"
            "    Adapter: $($_.InterfaceDescription) - Status: $($_.Status)" | Out-File -Append -FilePath "$logDir/WifiSupport.md"
        }
    }
    else {
        Write-Host "[+] Wi-Fi Support Detected." -ForegroundColor Green
        "Wi-Fi Support Detected." | Out-File -Append -FilePath "$logDir/WifiSupport.md"
        $wifiAdapters | ForEach-Object {
            Write-Host "    Adapter: $($_.InterfaceDescription) - Status: $($_.Status)"
            "    Adapter: $($_.InterfaceDescription) - Status: $($_.Status)" | Out-File -Append -FilePath "$logDir/WifiSupport.md"
        }

        # --- Scan for available networks only if we have exactly one adapter ---
        $netshOutput = netsh wlan show networks mode=bssid 2>&1

        if ($netshOutput -match 'The wireless local area network interface is powered down') {
            Write-Host "[!] WLAN interface is powered down." -ForegroundColor Red
            "WLAN interface is powered down." | Out-File -Append -FilePath "$logDir/WifiSupport.md"
        }
        elseif ($netshOutput -match 'There are 0 networks currently visible') {
            Write-Host "[!!!] No Wi-Fi networks detected." -ForegroundColor Red
            "No Wi-Fi networks detected." | Out-File -Append -FilePath "$logDir/WifiSupport.md"
        }
        else {
            Write-Host "[+] Visible Wi-Fi networks detected." -ForegroundColor Green
            "Visible Wi-Fi networks detected." | Out-File -Append -FilePath "$logDir/WifiSupport.md"
        }
    }
}
catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
    "An error occurred: $_" | Out-File -Append -FilePath "$logDir/WifiSupport.md"
}
