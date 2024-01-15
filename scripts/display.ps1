# Script: display.ps1

# Function Showdisplay Handleinput
function ShowDisplay-HandleInput {
    $global:config = Manage-ConfigSettings -action "Load"
    $HistoryDays = Get-TotalDays -DayRecords1 $global:config.HistoryKeys.DayRecords_1 -DayRecords10 $global:config.HistoryKeys.DayRecords_10 -DayRecords100 $global:config.HistoryKeys.DayRecords_100
    $HistoryDays = AdjustForZeroes -DayRecords $global:config.HistoryKeys.DayRecords_1 -TotalDays $HistoryDays
    Write-Host ("=" * 90)
    Write-Host "History ($HistoryDays Days):"
    Display-Graph -GraphType "History" -DayRecords1 $global:config.HistoryKeys.DayRecords_1 -DayRecords10 $global:config.HistoryKeys.DayRecords_10 -DayRecords100 $global:config.HistoryKeys.DayRecords_100
    Write-Host ("-" * 90)
    Write-Host "Prediction ($HistoryDays Days):"
    Display-Graph -GraphType "Prediction" -DayRecords1 $global:config.HistoryKeys.DayRecords_1 -DayRecords10 $global:config.HistoryKeys.DayRecords_10 -DayRecords100 $global:config.HistoryKeys.DayRecords_100
    Write-Host ("=" * 90)
    Display-FinancialSummary
    Write-Host "`nSelect, Credit Change = C, Monthly Income = I, Monthly Expenses = M, Exit Program = X: " -NoNewline
    $input = Read-Host
    switch ($input.ToLower()) {
        "x" { PerformExitRoutine }
        "c" { Prompt-UserInput -inputType "CreditChange" }
        "m" { Prompt-UserInput -inputType "MonthlyExpenses" }
        default { Write-Host "Invalid option." }
    }
}


# Function Prompt Userinput
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

# Function Isvalidnumber
function IsValidNumber($number) {
    return [int]::TryParse($number, [ref]$null)
}

# Function Display Financialsummary
function Display-FinancialSummary {
    $config = Manage-ConfigSettings -action "Load"
    Write-Host "`n                        Current Credit: $($config.CurrentKeys.CurrentTotal), Last Change: $($config.IntermittantKeys.LastFinanceChange),"
	Write-Host "`n                       Monthly Income: , Monthly Expenses: $($config.IntermittantKeys.MonthlyExpenses),"
	Write-Host "`n                        Current High: $($config.CurrentKeys.DayCreditHigh), Highest High: $($config.IntermittantKeys.HighestCreditHigh),"
	Write-Host "                         Current Low: $($config.CurrentKeys.DayCreditLow), Lowest Low: $($config.IntermittantKeys.LowestCreditLow).`n"
}

# for display on top of graphs
function Get-TotalDays {
    param(
        [Parameter(Mandatory = $true)]
        [int[]] $DayRecords1,
        [Parameter(Mandatory = $true)]
        [int[]] $DayRecords10,
        [Parameter(Mandatory = $true)]
        [int[]] $DayRecords100
    )
    
    $totalDays = 0
    $totalDays += $DayRecords1.Count
    $totalDays += $DayRecords10.Count * 10
    $totalDays += $DayRecords100.Count * 100

    return $totalDays
}



# Function Performexitroutine
function PerformExitRoutine {
    Write-Host "Exiting..."
    Exit
}
