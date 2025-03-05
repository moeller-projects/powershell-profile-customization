# CTTCustom.ps1 - Self-Updating PowerShell Script
# Version: 1.0.0

$repoURL = "https://raw.githubusercontent.com/moeller-projects/powershell-profile-customization/main/CTTcustom.ps1"
$timeFilePath = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\PowerShell\LastCustomizationUpdate.txt"

# Update interval in days (Set to -1 for always update)
$updateInterval = 7

function Update-Script {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()

    if ($PSCmdlet.ShouldProcess("Updating script at $scriptPath")) {
        Write-Verbose "Checking for updates..."

        try {
            $scriptContent = Invoke-RestMethod -Uri $repoURL -UseBasicParsing
            if ($scriptContent) {
                Write-Verbose "Update found! Applying update..."
                $scriptPath = $Script:MyInvocation.MyCommand.Path
                $scriptContent | Set-Content -Path $scriptPath -Force

                # Save update timestamp
                Get-Date | Set-Content -Path $timeFilePath -Force
                Write-Output "Update applied. Please restart your session."
                exit
            }
        }
        catch {
            Write-Error "Failed to update script: $_"
        }
    }
}

function Test-UpdateNeeded {
    if (-Not (Test-Path $timeFilePath)) { return $true }

    $lastUpdate = Get-Content $timeFilePath | Get-Date
    $daysSinceLastUpdate = (New-TimeSpan -Start $lastUpdate -End (Get-Date)).Days

    return $daysSinceLastUpdate -ge $updateInterval
}

if ($updateInterval -eq -1 -or (Test-UpdateNeeded)) {
    Update-Script
}
