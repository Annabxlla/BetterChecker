Add-Type -AssemblyName System.Collections

$zipRarFiles = @()
$searchPaths = @($env:UserProfile, "$env:UserProfile\Downloads")

# thread-safe dictionary for de-duplication
$uniquePaths = New-Object 'System.Collections.Concurrent.ConcurrentDictionary[string,bool]'

$maxThreads = [Math]::Min([System.Environment]::ProcessorCount, 12)

$logDir = "C:\temp\pccheck\logs"

if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

$zipRarHeader = "## Zip and Rar Files`n"

Write-Host "[*] Scanning for .zip and .rar files." -ForegroundColor DarkYellow

# create a runspace pool with up to 8 threads (adjust to your CPU)
$pool = [runspacefactory]::CreateRunspacePool(1, $maxThreads)
$pool.ApartmentState = 'MTA'
$pool.Open()

$jobs = @()

foreach ($path in $searchPaths) {
    $ps = [powershell]::Create()
    $ps.RunspacePool = $pool

    $null = $ps.AddScript({
            param ($path, $uniquePaths)

            $found = @()

            if (Test-Path $path) {
                # two fast filtered calls instead of -Include
                $files = Get-ChildItem -Path $path -Recurse -File -Depth 2 -Filter '*.zip'
                $files += Get-ChildItem -Path $path -Recurse -File -Depth 2 -Filter '*.rar'

                foreach ($file in $files) {
                    if ($file.FullName -notmatch 'minecraft|node_modules|go') {
                        if ($uniquePaths.TryAdd($file.FullName, $true)) {
                            $found += $file
                        }
                    }
                }
            }

            return $found
        }).AddArgument($path).AddArgument($uniquePaths)

    $jobs += @{
        PS     = $ps
        Handle = $ps.BeginInvoke()
    }
}

# collect results
foreach ($job in $jobs) {
    $result = $job.PS.EndInvoke($job.Handle)
    $job.PS.Dispose()
    $zipRarFiles += $result
}

# clean up runspace pool
$pool.Close()
$pool.Dispose()

# log the results
if ($zipRarFiles.Count -gt 0) {
    Write-Host "    [+] Found $($zipRarFiles.Count) .zip and .rar files." -ForegroundColor Green
    $zipRarHeader | Out-File -Append -FilePath "$logDir\ZipRarFiles.md"
    foreach ($file in $zipRarFiles) {
        "- $($file.FullName)" | Out-File -Append -FilePath "$logDir\ZipRarFiles.md"
    }
}
else {
    Write-Host "    [!!] No .zip or .rar files found." -ForegroundColor Red
    "No .zip or .rar files found." | Out-File -Append -FilePath "$logDir\ZipRarFiles.md"
}
