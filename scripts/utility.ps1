function Load-Configuration {
    return Import-PowerShellDataFile -Path 'scripts/configuration.psd1'
}

function Save-Configuration ($config) {
    $config | Export-Clixml -Path 'scripts/configuration.psd1'
}

function Update-FinancialData ($amountChange) {
    $config = Load-Configuration
    $config.CurrentTotal += $amountChange
    $config.LastFinanceChange = $amountChange

    # Update DayRecords_1 directly
    Rotate-DailyRecords $config.DayRecords_1 $amountChange

    # Handle rotation for higher order records
    Handle-HigherOrderRecordsRotation $config

    Save-Configuration $config
}

function Rotate-DailyRecords ([ref]$dayRecords, $newRecord) {
    $dayRecords.Value = $dayRecords.Value[1..9] + @($newRecord)
}

function Rotate-HigherOrderRecords ($config) {
    # Logic to determine when to rotate DayRecords_10 and DayRecords_100
    # Placeholder for rotation logic for higher-order records

    return $config
}

function Handle-HigherOrderRecordsRotation ($config) {
    # Check the current date against the last rotation dates
    # Rotate DayRecords_10 and DayRecords_100 as needed
    # Update LastRotation dates in configuration

    # Placeholder for rotation logic for higher-order records

    return $config
}


function Abs($number) {
    if ($number -lt 0) { return -$number }
    return $number
}

# Placeholder for Create-Graph function and other utility functions
