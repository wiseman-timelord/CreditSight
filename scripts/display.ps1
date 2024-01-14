# Script: display.ps1

# Function Display Graphandsummary
function Display-GraphAndSummary {
    # Clear-Host
    Display-Graph
    Display-FinancialSummary
    Write-Host "`nSelect, Credit Change=C, Monthly Charge=M, Exit Program=X: " -NoNewline
}

# Function Handle Userinput
function Handle-UserInput {
    $input = Read-Host
    switch ($input.ToLower()) {
        "x" { PerformExitRoutine }
        "c" { Prompt-CreditChange }
        "m" { Prompt-MonthlyCharge }
        default { Write-Host "Invalid option." }
    }
}

# Function Performexitroutine
function PerformExitRoutine {
    Write-Host "Exiting CreditSight..."
    Exit
}

# Function Prompt Creditchange
function Prompt-CreditChange {
    $change = Read-Host "Enter Credit Change Amount="
    if ($change -match '^-?\d+$') {
        Update-FinancialData $change
    } else {
        Write-Host "Enter valid number."
    }
}

# Function Prompt Monthlycharge
function Prompt-MonthlyCharge {
    $newMonthlyCharge = Read-Host "Enter New Total For Monthly Expenses="
    if ($newMonthlyCharge -match '^\d+$') {
        Update-MonthlyExpenses $newMonthlyCharge
    } else {
        Write-Host "Enter valid number."
    }
}

# Function Update Financialrecord
function Update-FinancialRecord {
    $amountChange = Read-Host "Enter the finance amount change (positive or negative)"
    if ($amountChange -match '^-?\d+$') {
        Update-FinancialData $amountChange
        Write-Host "Finance record updated."
    } else {
        Write-Host "Invalid input. Please enter a numeric value."
    }
}

# Function Create Graph
function Create-Graph {
    $config = Load-Configuration
    $predictionGraph = Create-PredictionGraph $config
    $historyGraph = Create-HistoryGraph $config
    $graph = $predictionGraph + "`n" + $historyGraph
    return $graph
}

# Function Create Predictiongraph
function Create-PredictionGraph($config) {
    $graphWidth = 50  
    $graphHeight = 10  
    $predictionGraph = @()
    $predictedValues = Get-PredictedValues $config.HistoryKeys

    foreach ($predictedValue in $predictedValues) {
        $historicalVolatility = $config.IntermittantKeys.HighestCreditHigh - $config.IntermittantKeys.LowestCreditLow
        $dailyVolatility = $config.CurrentKeys.DayCreditHigh - $config.CurrentKeys.DayCreditLow
        $volatility = [math]::Max($historicalVolatility, $dailyVolatility)

        $startY = [math]::Max(0, $predictedValue - $volatility / 2)
        $endY = [math]::Min($graphHeight - 1, $predictedValue + $volatility / 2)
        $line = (' ' * $graphWidth).ToCharArray()
        
        for ($y = $startY; $y -le $endY; $y++) {
            if ($y -ge 0 -and $y -lt $line.Length) {
                $line[$y] = "*"
            }
        }
        $predictionGraph += -join $line
    }

    $predictionGraph -join "`n"
}




# Function Create Historygraph
function Create-HistoryGraph($config) {
    $maxValue = ($config.HistoryKeys.DayRecords_1 + $config.HistoryKeys.DayRecords_10 + $config.HistoryKeys.DayRecords_100) | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum

    if ($maxValue -eq 0) {
        $maxValue = 1  # Avoid division by zero
    }

    $graphWidth = 50  
    $graphHeight = 10  
    $scalingFactor = $graphHeight / $maxValue
    $historyGraph = @()

    foreach ($value in $config.HistoryKeys.DayRecords_1 + $config.HistoryKeys.DayRecords_10 + $config.HistoryKeys.DayRecords_100) {
        $y = [math]::Round($value * $scalingFactor)
        $line = (' ' * $graphWidth).ToCharArray()

        if ($y -ge 0 -and $y -lt $line.Length) {
            $line[$y] = "*"
        }
        $historyGraph += -join $line
    }
    [array]::Reverse($historyGraph)
    $historyGraph -join "`n"
}




# Function Display Graph
function Display-Graph {
    Write-Host (Create-Graph)
}

# Function Display Financialsummary
function Display-FinancialSummary {
    $config = Load-Configuration
    Write-Host "Current Total: $($config.CurrentKeys.CurrentTotal)"
    Write-Host "Last Finance Change: $($config.CurrentKeys.LastFinanceChange)"
    Write-Host "Day Credit Low: $($config.CurrentKeys.DayCreditLow)"
    Write-Host "Day Credit High: $($config.CurrentKeys.DayCreditHigh)"
    Write-Host "Day Credit Now: $($config.CurrentKeys.DayCreditNow)"
    Write-Host "Monthly Expenses: $($config.IntermittantKeys.MonthlyExpenses)"
}

