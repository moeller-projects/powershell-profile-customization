# CTTCustom.ps1 - Self-Updating PowerShell Script
# Version: 1.0.0

$debug = $false

$repoURL = "https://raw.githubusercontent.com/moeller-projects/powershell-profile-customization/main/CTTcustom.ps1"
$timeFilePath = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\PowerShell\LastCustomizationUpdate.txt"

# Update interval in days (Set to -1 for always update)
$updateInterval = 7

function Update-Script {
    Write-Host "$($PSStyle.Foreground.Cyan)Checking for updates...$($PSStyle.Reset)"

    try {
        $scriptContent = Invoke-RestMethod -Uri $repoURL -UseBasicParsing
        if ($scriptContent) {
            Write-Host "$($PSStyle.Foreground.Yellow)Update found! Applying update...$($PSStyle.Reset)"
            $scriptPath = $MyInvocation.MyCommand.Path
            $scriptContent | Set-Content -Path $scriptPath -Force

            # Save update timestamp
            Get-Date | Set-Content -Path $timeFilePath -Force
            Write-Host "$($PSStyle.Foreground.Green)Update applied. Please restart your session.$($PSStyle.Reset)"
            exit
        }
    }
    catch {
        Write-Host "$($PSStyle.Foreground.Red)Failed to update script: $_$($PSStyle.Reset)"
    }
}

function Should-Update {
    if (-Not (Test-Path $timeFilePath)) { return $true }

    $lastUpdate = Get-Content $timeFilePath | Get-Date
    $daysSinceLastUpdate = (New-TimeSpan -Start $lastUpdate -End (Get-Date)).Days

    return $daysSinceLastUpdate -ge $updateInterval
}

if ($updateInterval -eq -1 -or (Should-Update)) {
    Update-Script
}
else {
    Write-Host "$($PSStyle.Foreground.Green)Script is up to date.$($PSStyle.Reset)"
}