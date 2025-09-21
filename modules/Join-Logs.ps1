# Direct paths for logs and combined file
$logDir = "C:/temp/pccheck/logs"
$combinedFile = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'), "PcCheckLogs.md")

# Delete the existing combined log file if it exists
if (Test-Path $combinedFile) {
    Remove-Item $combinedFile -Force
}

# Ensure the 'logs' directory exists (silent creation)
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

# Combine all .md files into the combined Markdown file
"# BetterChecker | By @annabxlla`n" | Out-File -FilePath $combinedFile -Encoding utf8

# list of preferred order (just the names)
$preferredOrder = @(
    'SecureBoot.md',
    'WiFiSupport.md',
    'InstalledBrowsers.md',
    'PrefetchFiles.md',
    'Jumplist.md',
    'RecentFiles.md',
    'InstalledApplications.md',
    'RegistryEntries.md'
)

# all .md files in directory
$allLogFiles = Get-ChildItem -Path $logDir -Filter '*.md' -File

# ordered files first
foreach ($name in $preferredOrder) {
    $file = $allLogFiles | Where-Object { $_.Name -ieq $name }
    if ($file) {
        Get-Content -Path $file.FullName | Out-File -Append -FilePath $combinedFile -Encoding utf8
        '' | Out-File -Append -FilePath $combinedFile
    }
}

# then any remaining .md files not in preferred order
$otherFiles = $allLogFiles | Where-Object { $preferredOrder -notcontains $_.Name }
foreach ($file in $otherFiles) {
    Get-Content -Path $file.FullName | Out-File -Append -FilePath $combinedFile -Encoding utf8
    '' | Out-File -Append -FilePath $combinedFile
}