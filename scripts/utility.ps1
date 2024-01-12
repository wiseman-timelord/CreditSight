function Load-Configuration {
    return Import-PowerShellDataFile -Path 'scripts/configuration.psd1'
}

function Save-Configuration ($config) {
    $config | Export-Clixml -Path 'scripts/configuration.psd1'
}

function Update-FinancialData ($amountChange) {
    $config = Load-Configuration
    # ... Update logic for CurrentTotal, LastFinanceChange, etc.
    Save-Configuration $config
}

function Rotate-DailyRecords ([ref]$dayRecords, $newRecord) {
    # ... Logic to rotate daily records
}

function Create-Graph {
    $config = Load-Configuration
    # ... Logic to create the ASCII art graph
    # Placeholder for detailed graph creation logic
}

# Placeholder for additional utility functions

# Example usage of Create-Graph
Write-Host (Create-Graph)
