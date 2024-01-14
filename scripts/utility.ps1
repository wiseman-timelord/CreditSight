# Script: utility.ps1

# Function Manage Configuration
function Manage-Configuration {
    param(
        [Parameter(Mandatory=$true)]
        [string]$action,
        [Parameter()]
        [hashtable]$config
    )
    $filePath = 'scripts/configuration.psd1'
    switch ($action) {
        "Load" {
            Write-Host "Attempting to load configuration from: $filePath"
            if (Test-Path $filePath) {
                Write-Host "Configuration file found."
                try {
                    $config = Import-PowerShellDataFile -Path $filePath
                    Write-Host "Configuration loaded successfully."
                    return @{
                        DatingKeys = $config.DatingKeys
                        CurrentKeys = $config.CurrentKeys
                        IntermittantKeys = $config.IntermittantKeys
                        HistoryKeys = $config.HistoryKeys
                    }
                } catch {
                    Write-Host "Failed to import configuration file. Error: $_"
                    throw
                }
            } else {
                Write-Host "Configuration file not found at path: $filePath"
                throw "Configuration file not found"
            }
        }
        "Save" {
            if ($null -eq $config) {
                Write-Host "No configuration data provided to save."
                return
            }
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
                $psd1Content | Out-File -FilePath $filePath
                Write-Host "Configuration saved successfully."
            } catch {
                Write-Host "Failed to save configuration. Please check file permissions."
            }
        }
        default {
            Write-Host "Invalid action specified. Please use 'Load' or 'Save'."
        }
    }
}

# Function Rotate Dailyrecords
function Rotate-DailyRecords ([ref]$dayRecords, $newRecord) {
    $dayRecords.Value = $dayRecords.Value[1..9] + @($newRecord)
}

# Function Update Financialdata
function Update-FinancialData {
    param(
        [Parameter(Mandatory=$true)]
        [string]$amountChange,
        [Parameter(Mandatory=$true)]
        [string]$inputType
    )

    if (-not [int]::TryParse($amountChange, [ref]$null)) {
        Write-Host "Invalid amount change. Please enter a valid number."
        return
    }
    $config = Manage-Configuration -action "Load"
    if ($inputType -eq "CreditChange") {
        Update-CurrentTotal $config.CurrentKeys $amountChange
        Update-FinancialRecords $config.HistoryKeys $amountChange
        Update-HighLowRecords $config.IntermittantKeys $config.CurrentKeys
    } elseif ($inputType -eq "MonthlyExpenses") {
        Update-MonthlyExpenses $amountChange
    }
    Manage-Configuration -action "Save" -config $config
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

# Function Get Predictedvalues
function Get-PredictedValues($historyKeys) {
    $predictedValues = @()
    $totalRecentChanges = 0
    $numRecords = $historyKeys.DayRecords_1.Count
    if ($numRecords -eq 0) {
        return $predictedValues  
    }
    for ($i = 0; $i -lt $numRecords; $i++) {
        $totalRecentChanges += $historyKeys.DayRecords_1[$i]
    }
    $averageChange = $totalRecentChanges / $numRecords
    $currentValue = $historyKeys.DayRecords_1[-1]  
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

# Function Update Currenttotal
function Update-CurrentTotal ($currentKeys, $amountChange) {
    $roundedChange = [math]::Round($amountChange, 2)
    $currentKeys.CurrentTotal += $roundedChange
    $currentKeys.LastFinanceChange = $roundedChange
}

# Function Update Highlowrecords
function Update-HighLowRecords ($intermittantKeys, $currentKeys) {
    $intermittantKeys.HighestCreditHigh = [math]::Max($intermittantKeys.HighestCreditHigh, $currentKeys.DayCreditHigh)
    $intermittantKeys.LowestCreditLow = [math]::Min($intermittantKeys.LowestCreditLow, $currentKeys.DayCreditLow)
}

# Function Update FinancialRecords
function Update-FinancialRecords {
    param(
        [Parameter(Mandatory=$true)]
        [ref]$historyKeys,
        [Parameter(Mandatory=$true)]
        [int]$amountChange
    )
    Rotate-DailyRecords $historyKeys.DayRecords_1 $amountChange
    Handle-HigherOrderRecordsRotation $historyKeys
}
