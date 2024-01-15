# Script: display.ps1

# Function Display Graphandsummary
function ShowDisplay-HandleInput {

    # Draw graphs (history days is same number as predicted)
    $global:config = Manage-ConfigSettings -action "Load"
    $HistoryRecords = Get-ScaledDataPoints -DayRecords $global:config.HistoryKeys.DayRecords_1
    $HistoryDays = $HistoryRecords.Count
    Write-Host ("=" * 60)
    Write-Host "History ($HistoryDays Days):"
    Display-Graph -GraphType "History"
    Write-Host ("-" * 60)
    Write-Host "Prediction ($HistoryDays Days):"
    Display-Graph -GraphType "Prediction"
    Write-Host ("=" * 60)

    # Draw summary
	Display-FinancialSummary

    # User input and options
    Write-Host "`nSelect, Credit Change = C, Set Monthly = M, Exit Program = X: " -NoNewline
    $input = Read-Host
    switch ($input.ToLower()) {
        "x" { PerformExitRoutine }
        "c" { Prompt-UserInput -inputType "CreditChange" }
        "m" { Prompt-UserInput -inputType "MonthlyExpenses" }
        default { Write-Host "Invalid option." }
    }
}


# Updated Function: Prompt-UserInput
function Prompt-UserInput {
    param($inputType)
    $prompt = $inputType -eq "CreditChange" ? "Enter Amount Change: " : "Enter Monthly Expense: "
    $change = Read-Host $prompt
    if (IsValidNumber $change) {
        Update-FinancialData -amountChange $change -inputType $inputType
    } else {
        Write-Host "Invalid number. Please enter a valid numeric value."
    }
}

# Utility Function: IsValidNumber
function IsValidNumber($number) {
    return [int]::TryParse($number, [ref]$null)
}

# Function Display Financialsummary
function Display-FinancialSummary {
    $config = Manage-ConfigSettings -action "Load"
    Write-Host "`n              Current Credit: $($config.CurrentKeys.CurrentTotal), Last Change: $($config.IntermittantKeys.LastFinanceChange),"
	Write-Host "`n                      Monthly Expenses: $($config.IntermittantKeys.MonthlyExpenses),"
	Write-Host "`n              Current High: $($config.CurrentKeys.DayCreditHigh), Highest High: $($config.IntermittantKeys.HighestCreditHigh),"
	Write-Host "               Current Low: $($config.CurrentKeys.DayCreditLow), Lowest Low: $($config.IntermittantKeys.LowestCreditLow).`n"
}

