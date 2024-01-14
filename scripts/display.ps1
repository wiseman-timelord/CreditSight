# Script: display.ps1

# Function Display Graphandsummary
function Display-GraphAndSummary {
    Display-Graph
    Display-FinancialSummary
    Write-Host "`nOptions: C, M, X: " -NoNewline
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
    Write-Host "Exiting..."
    Exit
}

# Function Prompt UserInput
function Prompt-UserInput {
    param($inputType)
    $prompt = $inputType -eq "CreditChange" ? "Amount=" : "Expense="
    $change = Read-Host $prompt
    if ($change -match '^-?\d+$') {
        Update-FinancialData -amountChange $change -inputType $inputType
    } else {
        Write-Host "Invalid number."
    }
}

# Function Update Financialrecord
function Update-FinancialRecord {
    $amountChange = Read-Host "Amount Change:"
    if ($amountChange -match '^-?\d+$') {
        Update-FinancialData $amountChange
        Write-Host "Record updated."
    } else {
        Write-Host "Invalid amount."
    }
}

# Create Graph
function Create-Graph {
    param([string]$graphType, [int]$graphWidth, [int]$graphHeight)
    switch ($graphType) {
        "Prediction" { Create-PredictionGraph $graphWidth $graphHeight }
        "History" { Create-HistoryGraph $graphWidth $graphHeight }
        default { Write-Host "Invalid type: $graphType" }
    }
}

# Create Prediction Graph
function Create-PredictionGraph {
    param(
        [int]$graphWidth,
        [int]$graphHeight
    )
    $predictionGraph = @()
    $predictedValues = Get-PredictedValues $global:config.HistoryKeys
    foreach ($predictedValue in $predictedValues) {
        $historicalVolatility = $global:config.IntermittantKeys.HighestCreditHigh - $global:config.IntermittantKeys.LowestCreditLow
        $dailyVolatility = $global:config.CurrentKeys.DayCreditHigh - $global:config.CurrentKeys.DayCreditLow
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
    return $predictionGraph -join "`n"
}

# Function Create History Graph
function Create-HistoryGraph {
    param(
        [int]$graphWidth,
        [int]$graphHeight
    )
    $historyGraph = @()
    $maxValue = ($global:config.HistoryKeys.DayRecords_1 + $global:config.HistoryKeys.DayRecords_10 + $global:config.HistoryKeys.DayRecords_100) | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum

    if ($maxValue -eq 0) {
        $maxValue = 1
    }
    $scalingFactor = $graphHeight / $maxValue

    foreach ($value in $global:config.HistoryKeys.DayRecords_1 + $global:config.HistoryKeys.DayRecords_10 + $global:config.HistoryKeys.DayRecords_100) {
        $y = [math]::Round($value * $scalingFactor)
        $line = (' ' * $graphWidth).ToCharArray()
        if ($y -ge 0 -and $y -lt $line.Length) {
            $line[$y] = "*"
        }
        $historyGraph += -join $line
    }
    [array]::Reverse($historyGraph)
    return $historyGraph -join "`n"
}

# Function Display Graph
function Display-Graph {
    Write-Host (Create-Graph "History" $global:graphWidth $global:graphHeight)
}

# Function Display Financialsummary
function Display-FinancialSummary {
    $config = Manage-ConfigSettings -action "Load"
    Write-Host "Total: $($config.CurrentKeys.CurrentTotal)"
    Write-Host "Last Change: $($config.CurrentKeys.LastFinanceChange)"
    Write-Host "Low: $($config.CurrentKeys.DayCreditLow)"
    Write-Host "High: $($config.CurrentKeys.DayCreditHigh)"
    Write-Host "Now: $($config.CurrentKeys.DayCreditNow)"
    Write-Host "Expenses: $($config.IntermittantKeys.MonthlyExpenses)"
}
