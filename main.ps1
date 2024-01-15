# Script: main.ps1

# Initialization
[Console]::ForegroundColor = [ConsoleColor]::Black
[Console]::BackgroundColor = [ConsoleColor]::DarkGray
[Console]::Clear() 
Write-Host "`n`CreditSight Started....`n`n"

# Imports
. .\scripts\utility.ps1   
. .\scripts\display.ps1   
. .\scripts\config.ps1    
. .\scripts\graph.ps1    

# Variables
$global:graphWidth = 90
$global:graphHeight = 15
$global:filePath = 'scripts/settings.psd1'
$global:config = Manage-ConfigSettings -action "Load" 

# Function Log Error
function Log-Error {
    param(
        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord
    )
    $logFilePath = ".\Error-Crash.Log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    # Extracting detailed information from the error record
    $scriptName = $ErrorRecord.InvocationInfo.ScriptName
    $functionName = $ErrorRecord.InvocationInfo.MyCommand
    $line = $ErrorRecord.InvocationInfo.ScriptLineNumber
    $message = $ErrorRecord.Exception.Message
    $stackTrace = $ErrorRecord.ScriptStackTrace
    $command = $ErrorRecord.InvocationInfo.Line

    # Creating the log entry with additional details
    $logEntry = "${timestamp}: [Script: $scriptName] [Function: $functionName] [Line: $line] [Command: $command] Error: $message`nStack Trace: $stackTrace"

    try {
        Add-Content -Path $logFilePath -Value $logEntry
    }
    catch {
        Write-Host "Error logging failed: $_"
    }
}



# Function Initializefirstrun
function InitializeFirstRun {
    param($config)
    if ($config.DatingKeys.LastRotation1Day -eq '01/01/0000') {
        $currentDate = Get-Date -Format "MM/dd/yyyy"
        $config.DatingKeys.LastRotation1Day = $config.DatingKeys.LastRotation10Days = $config.DatingKeys.LastRotation100Days = $currentDate
        Manage-ConfigSettings -action "Save" -config $config
    }
}

# Function Rotateonlastrun
function RotateOnLastRun {
    param($config)
    $currentDate = Get-Date
    if ($config.DatingKeys.LastApplicationRun -ne $currentDate.ToString("MM/dd/yyyy")) {
        HandleDataRotation -config $config -currentDate $currentDate
    }
}

# Entry Point
try {
    Start-Sleep -Seconds 1
    InitializeFirstRun -config $global:config
    RotateOnLastRun -config $global:config
    while ($true) {
        ShowDisplay-HandleInput
    }
} catch {
    Log-Error -ErrorRecord $_
    Write-Host "An unexpected error occurred."
}
