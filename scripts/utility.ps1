# Script: utility.ps1

# Function Load Configuration
function Load-Configuration {
    return Import-PowerShellDataFile -Path 'scripts/configuration.psd1'
}

# Function Save Configuration
function Save-Configuration ($config) {
    $psd1Content = "@{"
    foreach ($key in $config.Keys) {
        $value = $config[$key]
        if ($value -is [System.Array]) {
            $arrayContent = $value -join ' '
            $psd1Content += "`n    $key = @($arrayContent)"
        } else {
            $psd1Content += "`n    $key = '$value'"
        }
    }
    $psd1Content += "`n}"
    try {
        $psd1Content | Out-File -FilePath 'scripts/configuration.psd1'
    } catch {
        Write-Host "Failed to save configuration. Please check file permissions."
    }
}

# Function Rotate Dailyrecords
function Rotate-DailyRecords ([ref]$dayRecords, $newRecord) {
    $dayRecords.Value = $dayRecords.Value[1..9] + @($newRecord)
}

# Function Update Financialdata
function Update-FinancialData ($amountChange) {
    if (-not [int]::TryParse($amountChange, [ref]$null)) {
        Write-Host "Invalid amount change. Please enter a valid number."
        return
    }
    $config = Load-Configuration
    Update-CurrentTotal $config $amountChange
    Update-DailyRecords $config $amountChange
	Update-HighLowRecords $config
    Save-Configuration $config
}

function Update-HighLowRecords ($config) {
    $config.HighestCreditHigh = [math]::Max($config.HighestCreditHigh, $config.DayCreditHigh)
    $config.LowestCreditLow = [math]::Min($config.LowestCreditLow, $config.DayCreditLow)
}

# Function Rotate Higherorderrecords
function Rotate-HigherOrderRecords ($config) {
    $currentDate = Get-Date
    $daysSinceLast10DayRotation = ($currentDate - $config.LastRotation10Day).Days
    $daysSinceLast100DayRotation = ($currentDate - $config.LastRotation100Day).Days
    if ($daysSinceLast10DayRotation -ge 10) {
        for ($i = 0; $i -lt [math]::Floor($daysSinceLast10DayRotation / 10); $i++) {
            $config.DayRecords_10 = $config.DayRecords_10[1..9] + @($config.DayRecords_1[-1])
        }
        $config.LastRotation10Day = $currentDate
    }
    if ($daysSinceLast100DayRotation -ge 100) {
        for ($i = 0; $i -lt [math]::Floor($daysSinceLast100DayRotation / 100); $i++) {
            $config.DayRecords_100 = $config.DayRecords_100[1..9] + @($config.DayRecords_10[-1])
        }
        $config.LastRotation100Day = $currentDate
    }
    return $config
}

# Function Handle Higherorderrecordsrotation
function Handle-HigherOrderRecordsRotation ($config) {
    $config = Rotate-HigherOrderRecords $config
    return $config
}

function Get-PredictedValues($config) {
    $predictedValues = @()
    $totalRecentChanges = 0
    $numRecords = $config.DayRecords_1.Count

    # Calculate the average of recent changes
    for ($i = 0; $i -lt $numRecords; $i++) {
        $totalRecentChanges += $config.DayRecords_1[$i]
    }
    $averageChange = $totalRecentChanges / $numRecords

    # Predict future values using the average change
    $currentValue = $config.CurrentTotal
    for ($i = 0; $i -lt $numRecords; $i++) {
        $currentValue += $averageChange
        $predictedValues += $currentValue
    }

    return $predictedValues
}


# Function Abs
function Abs($number) {
    if ($number -lt 0) { return -$number }
    return $number
}

# Function Update Monthlyexpenses
function Update-MonthlyExpenses ($newCharge) {
    $config = Load-Configuration
    $config.MonthlyExpenses = $newCharge
    Save-Configuration $config
}

# Function Update Current Total with Precision Handling
function Update-CurrentTotal ($config, $amountChange) {
    $roundedChange = [math]::Round($amountChange, 2) # rounding to 2 decimal places
    $config.CurrentTotal += $roundedChange
    $config.LastFinanceChange = $roundedChange
}


# Function Update Dailyrecords
function Update-DailyRecords ($config, $amountChange) {
    Rotate-DailyRecords ([ref]$config.DayRecords_1) $amountChange
    Handle-HigherOrderRecordsRotation $config
}