# Script: main.ps1

# Initialization and Imports
[Console]::ForegroundColor = [ConsoleColor]::Black
[Console]::BackgroundColor = [ConsoleColor]::DarkGray
[Console]::Clear() 
Write-Host "`n`CreditSight Started....`n`n"

# Imports
. .\scripts\utility.ps1   # Utility Functions
. .\scripts\display.ps1   # Display Functions
. .\scripts\config.ps1    # Configuration Management
. .\scripts\graph.ps1    # create graphs

# Global Variables
$global:graphWidth = 60
$global:graphHeight = 15
$global:filePath = 'scripts/settings.psd1'
$global:config = Manage-ConfigSettings -action "Load" # Centralized Config Loading

# Error Logging Function
function Log-Error {
    param($ErrorMessage)
    $logFilePath = ".\Error-Crash.Log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "${timestamp}: $ErrorMessage"
    try {
        Add-Content -Path $logFilePath -Value $logEntry
    }
    catch {
        Write-Host "Error logging failed: $_"
    }
}

# First-Run Initialize Dates
if ($global:config.DatingKeys.LastRotation1Day -eq '01/01/0000') {
    $currentDate = Get-Date -Format "MM/dd/yyyy"
    $global:config.DatingKeys.LastRotation1Day = $global:config.DatingKeys.LastRotation10Days = $global:config.DatingKeys.LastRotation100Days = $currentDate
    Manage-ConfigSettings -action "Save" -config $global:config
}

# Function Performexitroutine
function PerformExitRoutine {
    Write-Host "Exiting..."
    Exit
}

# Main Execution Loop
try {
    Start-Sleep -Seconds 1
    while ($true) {
        ShowDisplay-HandleInput
    }
} catch {
    Log-Error $_.Exception.Message
    Write-Host "An unexpected error occurred."
}
