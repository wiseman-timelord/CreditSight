# Script: display.ps1

# Function Display Graphandsummary
function Display-GraphAndSummary {
    Clear-Host
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
    $predictedValues = Get-PredictedValues $config
    foreach ($predictedValue in $predictedValues) {
        $volatility = $config.DayCreditHigh - $config.DayCreditLow
        $startY = [math]::Max(0, $predictedValue - $volatility / 2)
        $endY = [math]::Min($graphHeight, $predictedValue + $volatility / 2)
        $line = [char]::WhiteSpace * $graphWidth
        for ($y = $startY; $y -le $endY; $y++) {
            $line[$y] = "*"  
        }
        $predictionGraph += $line
    }
    $predictionGraph -join "`n"
}

# Function Create Historygraph
function Create-HistoryGraph($config) {
    $maxValue = ($config.DayRecords_1 + $config.DayRecords_10 + $config.DayRecords_100) | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
    $graphWidth = 50  
    $graphHeight = 10  
    $scalingFactor = $graphHeight / $maxValue
    $historyGraph = @()
    foreach ($value in $config.DayRecords_1 + $config.DayRecords_10 + $config.DayRecords_100) {
        $y = [math]::Round($value * $scalingFactor)
        $line = [char]::WhiteSpace * $graphWidth
        $line[$y] = "*"  
        $historyGraph += $line
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
    Write-Host "Current Total: $($config.CurrentTotal)"
    Write-Host "Last Finance Change: $($config.LastFinanceChange)"
    Write-Host "Day Credit Low: $($config.DayCreditLow)"
    Write-Host "Day Credit High: $($config.DayCreditHigh)"
    Write-Host "Day Credit Now: $($config.DayCreditNow)"
	Write-Host "Monthly Expenses: $($config.MonthlyExpenses)"
}
