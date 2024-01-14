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
            Write-Host "Loading: $filePath.."
            if (Test-Path $filePath) {
                Write-Host "$filePath Found."
                try {
                    $config = Import-PowerShellDataFile -Path $filePath
                    Write-Host "Config Loaded."
                    return @{
                        DatingKeys = $config.DatingKeys
                        CurrentKeys = $config.CurrentKeys
                        IntermittantKeys = $config.IntermittantKeys
                        HistoryKeys = $config.HistoryKeys
                    }
                } catch {
                    Write-Host "Load Failed: Error: $_"
                    throw
                }
            } else {
                Write-Host "Config Missing: $filePath"
                throw "Config Missing"
            }
        }
        "Save" {
            if ($null -eq $config) {
                Write-Host "Config Data Empty."
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
                Write-Host "Config Saved."
            } catch {
                Write-Host "Save Failed."
            }
        }
        default {
            Write-Host "Invalid action."
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
        Write-Host "Invalid Number."
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

function Update-FinancialData {
    param(
        [string]$updateType,
        [string]$amountChange
    )
    switch ($updateType) {
        "CurrentTotal" {
            $roundedChange = [math]::Round($amountChange, 2)
            $global:config.CurrentKeys.CurrentTotal += $roundedChange
            $global:config.CurrentKeys.LastFinanceChange = $roundedChange
        }
        "HighLowRecords" {
            $global:config.IntermittantKeys.HighestCreditHigh = [math]::Max($global:config.IntermittantKeys.HighestCreditHigh, $global:config.CurrentKeys.DayCreditHigh)
            $global:config.IntermittantKeys.LowestCreditLow = [math]::Min($global:config.IntermittantKeys.LowestCreditLow, $global:config.CurrentKeys.DayCreditLow)
        }
        default {
            Write-Host "Invalid update type: $updateType"
        }
    }
    Manage-Configuration -action "Save" -config $global:config
}

# Function Update FinancialRecords
function Update-FinancialRecords {
    param(
        [Parameter(Mandatory=$true)]
        [ref]$historyKeys,
        [Parameter(Mandatory=$true)]
        [int]$amountChange
    )
    # Update DayRecords_1
    Rotate-DailyRecords $historyKeys.DayRecords_1 $amountChange

    # Check if 10 days have passed for DayRecords_10
    if ($global:config.DatingKeys.LastRotation10Days.AddDays(10) -le (Get-Date)) {
        $sumLast10Days = ($historyKeys.Value.DayRecords_1 | Measure-Object -Sum).Sum
        Rotate-DailyRecords $historyKeys.DayRecords_10 $sumLast10Days
        $global:config.DatingKeys.LastRotation10Days = Get-Date
    }

    # Check if 100 days have passed for DayRecords_100
    if ($global:config.DatingKeys.LastRotation100Days.AddDays(100) -le (Get-Date)) {
        $sumLast100Days = ($historyKeys.Value.DayRecords_10 | Measure-Object -Sum).Sum
        Rotate-DailyRecords $historyKeys.DayRecords_100 $sumLast100Days
        $global:config.DatingKeys.LastRotation100Days = Get-Date
    }

    # Save updated rotation dates
    Manage-Configuration -action "Save" -config $global:config
}

