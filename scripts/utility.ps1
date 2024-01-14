# Script: utility.ps1

# Function Rotate-Records
function Rotate-Records {
    param(
        [ref]$dayRecords,
        $newRecord,
        $config,
        $rotationInterval,
        $dayRecordField,
        $lastRotationField
    )
    $dayRecords.Value = $dayRecords.Value[1..9] + @($newRecord)

    $currentDate = Get-Date
    $daysSinceLastRotation = ($currentDate - $config.DatingKeys.$lastRotationField).Days
    if ($daysSinceLastRotation -ge $rotationInterval) {
        $sumRotationPeriod = ($config.HistoryKeys.$dayRecordField | Measure-Object -Sum).Sum
        $dayRecords.Value = $dayRecords.Value[1..9] + @($sumRotationPeriod)
        $config.DatingKeys.$lastRotationField = $currentDate
        Manage-ConfigSettings -action "Save" -config $config
    }
}

# Function Process Rotation
function Process-Rotation {
    param($config, $rotationInterval, $dayRecordField, $lastRotationField)
    $daysSinceLastRotation = ($currentDate - $config.$lastRotationField).Days
    if ($daysSinceLastRotation -ge $rotationInterval) {
        $iterations = [math]::Floor($daysSinceLastRotation / $rotationInterval)
        for ($i = 0; $i -lt $iterations; $i++) {
            $config.$dayRecordField = $config.$dayRecordField[1..9] + @($config.DayRecords_1[-1])
        }
        $config.$lastRotationField = $currentDate
    }
}

# Function Get Predictedvalues
function Get-PredictedValues($historyKeys) {
    $predictedValues = @()
    $totalRecentChanges = ($historyKeys.DayRecords_1 | Measure-Object -Sum).Sum
    $numRecords = $historyKeys.DayRecords_1.Count
    if ($numRecords -eq 0) { return $predictedValues }
    $averageChange = $totalRecentChanges / $numRecords
    $currentValue = $historyKeys.DayRecords_1[-1]
    foreach ($record in $historyKeys.DayRecords_1) {
        $currentValue += $averageChange
        $predictedValues += $currentValue
    }
    return $predictedValues
}

# Function Update Financialdata
function Update-FinancialData {
    param([string]$amountChange, [string]$inputType)
    if (-not (IsValidNumber $amountChange)) {
        Write-Host "Invalid Number."
        return
    }
    $config = Manage-ConfigSettings -action "Load"
    switch ($inputType) {
        "CreditChange" {
            Update-CurrentTotal $config.CurrentKeys $amountChange
            Update-FinancialRecords $config.HistoryKeys $amountChange
            Update-HighLowRecords $config.IntermittantKeys $config.CurrentKeys
        }
        "MonthlyExpenses" {
            Update-MonthlyExpenses $amountChange
        }
    }
    Manage-ConfigSettings -action "Save" -config $config
}

function IsValidNumber($number) {
    return [int]::TryParse($number, [ref]$null)
}


function Update-FinancialRecords {
    param(
        [Parameter(Mandatory = $true)]
        [ref]$historyKeys,
        [Parameter(Mandatory = $true)]
        [int]$amountChange
    )
    $config = Manage-ConfigSettings -action "Load"
    Rotate-Records -dayRecords $historyKeys.Value.DayRecords_1 -newRecord $amountChange -config $config -rotationInterval 10 -dayRecordField "DayRecords_10" -lastRotationField "LastRotation10Days"
    Rotate-Records -dayRecords $historyKeys.Value.DayRecords_1 -newRecord $amountChange -config $config -rotationInterval 100 -dayRecordField "DayRecords_100" -lastRotationField "LastRotation100Days"
    Manage-ConfigSettings -action "Save" -config $config
}

# Function Update Monthlyexpenses
function Update-MonthlyExpenses ($newCharge) {
    $config = Manage-ConfigSettings -action "Load"
    $config.MonthlyExpenses = $newCharge
    Manage-ConfigSettings -action "Save" -config $config
}