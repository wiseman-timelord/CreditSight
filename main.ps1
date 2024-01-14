# Script: main.ps1

# Initialization
. .\scripts\utility.ps1
. .\scripts\display.ps1
# Clear-Host
Write-Host "`n`CreditSight Started....`n`n"

# Function Log Error Enhanced
function Log-Error {
    param($ErrorMessage)
    $logFilePath = ".\Error-Crash.Log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "${timestamp}: $ErrorMessage"
    try {
        Add-Content -Path $logFilePath -Value $logEntry
    }
    catch {
        Write-Host "Error logging failed. Please check file permissions."
    }
}


# Variables
$config = Load-Configuration
if ($config.LastRotation1Day -eq '01/01/0000') {
    $currentDate = Get-Date -Format "MM/dd/yyyy"
    $config.LastRotation1Day = $config.LastRotation10Days = $config.LastRotation100Days = $currentDate
    Save-Configuration $config
}

# Entry Point
Start-Sleep -Seconds 1
while ($true) {
    Display-GraphAndSummary
    Handle-UserInput
}