# Script: utility.ps1

# Function Rotate Records
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

# Function Rotate Records
function Rotate-Records {
    param(
        [ref]$dayRecords,
        $newRecord,
        $config,
        $rotationInterval,
        $dayRecordField,
        $lastRotationField
    )
    
    # Ensure the newRecord is an integer
    $newRecord = [int]$newRecord
    $currentDate = Get-Date

    # Safely parse the last rotation date or use the current date if invalid
    try {
        $lastRotationDate = [datetime]::ParseExact($config.DatingKeys.$lastRotationField, "MM/dd/yyyy", $null)
    } catch {
        Write-Host "Invalid last rotation date format in config for $lastRotationField. Setting to current date."
        $lastRotationDate = $currentDate
        $config.DatingKeys.$lastRotationField = $currentDate.ToString("MM/dd/yyyy")
    }

    # Calculate the number of days since the last rotation
    $daysSinceLastRotation = [math]::Abs(($currentDate - $lastRotationDate).Days)

    if ($daysSinceLastRotation -ge $rotationInterval) {
        $sumRotationPeriod = [Math]::Round(($config.HistoryKeys.$dayRecordField | Measure-Object -Sum).Sum)
        $dayRecords.Value = $dayRecords.Value[1..9] + @($sumRotationPeriod)
        $config.DatingKeys.$lastRotationField = $currentDate.ToString("MM/dd/yyyy")
        Manage-ConfigSettings -action "Save" -config $config
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

# Function Isvalidnumber
function IsValidNumber($number) {
    return [int]::TryParse($number, [ref]$null)
}

# Function Update Financialrecords
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

# Function Adjustforzeroes
function AdjustForZeroes {
    param($DayRecords, $TotalDays)
    for ($i = 0; $i -lt $DayRecords.Count; $i++) {
        if ($DayRecords[$i] -eq 0) {
            return $i  
        }
    }
    return $TotalDays
}

# Function Handledatarotation
function HandleDataRotation {
    param(
        [Parameter(Mandatory)]
        $config,
        [Parameter(Mandatory)]
        $currentDate
    )

    # Ensure $currentDate is a datetime object
    $currentDate = [datetime]$currentDate

    # Parse the LastApplicationRun date or use the current date if invalid
    try {
        $lastRunDate = [datetime]::ParseExact($config.DatingKeys.LastApplicationRun, "MM/dd/yyyy", $null)
    } catch {
        Write-Host "Invalid LastApplicationRun date format in config. Setting to current date."
        $lastRunDate = $currentDate
        $config.DatingKeys.LastApplicationRun = $currentDate.ToString("MM/dd/yyyy")
    }

    # Calculate the number of days since the last run
    $daysSinceLastRun = [math]::Abs(($currentDate - $lastRunDate).Days)

    # The logic for rotating records based on days since last run
    for ($i = 0; $i -lt $daysSinceLastRun; $i++) {
        $newRecord = [int]$config.CurrentKeys.CurrentTotal
        Rotate-Records -dayRecords ([ref]$config.HistoryKeys.DayRecords_1) -newRecord $newRecord -config $config -rotationInterval 1 -dayRecordField "DayRecords_1" -lastRotationField "LastRotation1Day"
    }
    if ($daysSinceLastRun -ge 10) {
        $iterations = [math]::Floor($daysSinceLastRun / 10)
        for ($i = 0; $i -lt $iterations; $i++) {
            $sumLast10Days = ($config.HistoryKeys.DayRecords_1 | Select-Object -Last 10 | Measure-Object -Sum).Sum
            Rotate-Records -dayRecords ([ref]$config.HistoryKeys.DayRecords_10) -newRecord $sumLast10Days -config $config -rotationInterval 10 -dayRecordField "DayRecords_10" -lastRotationField "LastRotation10Days"
        }
    }
    if ($daysSinceLastRun -ge 100) {
        $iterations = [math]::Floor($daysSinceLastRun / 100)
        for ($i = 0; $i -lt $iterations; $i++) {
            $sumLast100Days = ($config.HistoryKeys.DayRecords_10 | Select-Object -Last 10 | Measure-Object -Sum).Sum
            Rotate-Records -dayRecords ([ref]$config.HistoryKeys.DayRecords_100) -newRecord $sumLast100Days -config $config -rotationInterval 100 -dayRecordField "DayRecords_100" -lastRotationField "LastRotation100Days"
        }
    }

    # Update the last application run date
    $config.DatingKeys.LastApplicationRun = $currentDate.ToString("MM/dd/yyyy")
    Manage-ConfigSettings -action "Save" -config $config
}
