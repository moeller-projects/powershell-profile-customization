# Ensure the script can run with elevated privileges
function Check-Administrator {
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "$($PSStyle.Foreground.Red)Please run this script as an Administrator!$($PSStyle.Reset)"
        exit
    }
}

# Function to test internet connectivity
function Test-InternetConnection {
    try {
        Test-Connection -ComputerName www.google.com -Count 1 -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        Write-Host "$($PSStyle.Foreground.Yellow)Internet connection is required but not available. Please check your connection.$($PSStyle.Reset)"
        return $false
    }
}

# Main script execution
Check-Administrator

if (-not (Test-InternetConnection)) {
    exit
}

$scriptName = "CTTCustom.ps1"
$installPath = (Get-Item -Path $PROFILE.CurrentUserAllHosts).DirectoryName
if (-not (Test-Path -Path $installPath)) {
    New-Item -Path $installPath -ItemType Directory | Out-Null
    Write-Host "$($PSStyle.Foreground.Green)Created profile directory at [$installPath].$($PSStyle.Reset)"
}
$scriptPath = Join-Path -Path $installPath -ChildPath $scriptName
$repoURL = "https://raw.githubusercontent.com/moeller-projects/powershell-profile-customization/main/CTTcustom.ps1"

function CreateOrUpdateProfile {
    param (
        [string]$scriptPath,
        [string]$repoURL
    )

    # Ensure the profile path exists
    $profilePath = Get-PowerShellProfilePath
    if (-not (Test-Path -Path $profilePath)) {
        New-Item -Path $profilePath -ItemType "directory" | Out-Null
        Write-Host "$($PSStyle.Foreground.Green)Created profile directory at [$profilePath].$($PSStyle.Reset)"
    }

    if (-not (Test-Path -Path $scriptPath -PathType Leaf)) {
        try {
            Invoke-RestMethod $repoURL -OutFile $scriptPath
            Write-Host "$($PSStyle.Foreground.Cyan)The Customization @ [$scriptPath] has been created.$($PSStyle.Reset)"
            Write-Host "$($PSStyle.Foreground.Yellow)Note: The updater in the installed Customization may overwrite changes.$($PSStyle.Reset)"
        }
        catch {
            Write-Error "$($PSStyle.Foreground.Red)Failed to create or update the profile. Error: $_$($PSStyle.Reset)"
        }
    }
    else {
        try {
            Move-Item -Path $scriptPath -Destination (Join-Path -Path $installPath -ChildPath "old$scriptName") -Force
            Invoke-RestMethod $repoURL -OutFile $scriptPath
            Write-Host "$($PSStyle.Foreground.Green)Backup created. Please save any important components from the old Customization.$($PSStyle.Reset)"
        }
        catch {
            Write-Error "$($PSStyle.Foreground.Red)Failed to backup and update the Customization. Error: $_$($PSStyle.Reset)"
        }
    }
}

# Function to get the appropriate PowerShell profile path
function Get-PowerShellProfilePath {
    if ($PSVersionTable.PSEdition -eq "Core") {
        return "$env:userprofile\Documents\Powershell"
    }
    elseif ($PSVersionTable.PSEdition -eq "Desktop") {
        return "$env:userprofile\Documents\WindowsPowerShell"
    }
}

# Execute the profile creation or update
CreateOrUpdateProfile -scriptPath $scriptPath -repoURL $repoURL

# Final check and message to the user
if (Test-Path -Path $scriptPath) {
    Write-Host "$($PSStyle.Foreground.Green)Setup completed successfully. Please restart your PowerShell session to apply changes.$($PSStyle.Reset)"
}
else {
    Write-Host "$($PSStyle.Foreground.Red)Setup completed with errors. Please check the error messages above.$($PSStyle.Reset)"
}
