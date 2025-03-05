param (
    [string]$ScriptPath
)

# Ensure PSScriptAnalyzer is installed
if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
    Write-Output "$($PSStyle.Foreground.Yellow)PSScriptAnalyzer module not found. Installing...$($PSStyle.Reset)"
    try {
        Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force -SkipPublisherCheck
        Write-Output "$($PSStyle.Foreground.Green)PSScriptAnalyzer installed successfully.$($PSStyle.Reset)"
    }
    catch {
        Write-Error "$($PSStyle.Foreground.Red)Failed to install PSScriptAnalyzer: $_$($PSStyle.Reset)"
        exit 1
    }
} else {
    Write-Output "$($PSStyle.Foreground.Cyan)PSScriptAnalyzer module is already available.$($PSStyle.Reset)"
}

# Analyze the specified script
Write-Output "$($PSStyle.Foreground.Cyan)Analyzing script at path: $ScriptPath...$($PSStyle.Reset)"
$results = Invoke-ScriptAnalyzer -Path $ScriptPath -Recurse

# Output results as a table
if ($results) {
    $results | Format-Table -Property RuleName, Severity, ScriptName, Line, Message -AutoSize
    Write-Output "$($PSStyle.Foreground.Yellow)Analysis complete. Review the results above.$($PSStyle.Reset)"
} else {
    Write-Output "$($PSStyle.Foreground.Green)No issues found during analysis.$($PSStyle.Reset)"
}