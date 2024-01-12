function Load-Configuration {
    return Import-PowerShellDataFile -Path 'scripts/configuration.psd1'
}

function Save-Configuration ($config) {
    $config | Export-Clixml -Path 'scripts/configuration.psd1'
}

function Rotate-DailyRecords ([ref]$dayRecords, $newRecord) {
    # Append new record to the end and remove the oldest entry
    $dayRecords.Value = $dayRecords.Value[1..9] + @($newRecord)
}

function Update-FinancialData ($amountChange) {
    if (-not [int]::TryParse($amountChange, [ref]$null)) {
        Write-Host "Invalid amount change. Please enter a valid number."
        return
    }

    $config = Load-Configuration
    $config.CurrentTotal += $amountChange
    $config.LastFinanceChange = $amountChange

    Rotate-DailyRecords ([ref]$config.DayRecords_1) $amountChange
    Handle-HigherOrderRecordsRotation $config

    Save-Configuration $config
}

function Rotate-HigherOrderRecords ($config) {
    $currentDate = Get-Date

    $daysSinceLast10DayRotation = ($currentDate - $config.LastRotation10Day).Days
    $daysSinceLast100DayRotation = ($currentDate - $config.LastRotation100Day).Days

    if ($daysSinceLast10DayRotation -ge 10) {
        $config.DayRecords_10 = $config.DayRecords_10[1..9] + @($config.DayRecords_1[-1])
        $config.LastRotation10Day = $currentDate
    }

    if ($daysSinceLast100DayRotation -ge 100) {
        $config.DayRecords_100 = $config.DayRecords_100[1..9] + @($config.DayRecords_10[-1])
        $config.LastRotation100Day = $currentDate
    }

    return $config
}


function Handle-HigherOrderRecordsRotation ($config) {
    # Rotate DayRecords_10 and DayRecords_100 if required
    $config = Rotate-HigherOrderRecords $config

    return $config
}
function Abs($number) {
    if ($number -lt 0) { return -$number }
    return $number
}

# Placeholder for Create-Graph function and other utility functions
