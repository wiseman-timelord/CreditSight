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

    # Determine the magnitude of change and update the appropriate DayRecords
    if ($amountChange -ge 1000) {
        Rotate-DailyRecords $config.DayRecords_1000 ($amountChange / 1000)
    } elseif ($amountChange -ge 100) {
        Rotate-DailyRecords $config.DayRecords_100 ($amountChange / 100)
    } elseif ($amountChange -ge 10) {
        Rotate-DailyRecords $config.DayRecords_10 ($amountChange / 10)
    } else {
        Rotate-DailyRecords $config.DayRecords_1 $amountChange
    }

    Save-Configuration $config
}

function Rotate-DailyRecords ([ref]$dayRecords, $newRecord) {
    $dayRecords.Value = $dayRecords.Value[1..($dayRecords.Value.Length - 2)] + @($newRecord)
}

# Example usage of Update-FinancialData
# Update-FinancialData 120 # Update the financial data with a change of 120

# Placeholder for Create-Graph function and other utility functions
