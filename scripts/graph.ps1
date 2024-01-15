# Script: graph.ps1

# Function Display Graph
function Display-Graph {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("History", "Prediction")]
        [string] $GraphType,
        [int[]] $DayRecords1,
        [int[]] $DayRecords10,
        [int[]] $DayRecords100
    )
    $global:config = Manage-ConfigSettings -action "Load"
    $DayRecords = Get-ScaledDataPoints -DayRecords1 $DayRecords1 -DayRecords10 $DayRecords10 -DayRecords100 $DayRecords100
    if ($GraphType -eq "History") {
        Show-HistoryGraph -DayRecords $DayRecords
    } elseif ($GraphType -eq "Prediction") {
        $PredictedValues = Get-PredictedValues -DayRecords $DayRecords
        Show-PredictionGraph -DayRecords $PredictedValues
    }
}



Function Show-HistoryGraph {
    Param(
        [Parameter(Mandatory = $true)]
        [int[]] $DayRecords
    )

    if (-not $DayRecords -or $DayRecords.Count -eq 0) {
        Write-Host "No data available for History Graph."
        return
    }

    $CharactersPerStat = [Math]::Floor($global:graphWidth / 30)
    $MaxValue = ($DayRecords | Measure-Object -Maximum).Maximum
    $MinValue = ($DayRecords | Measure-Object -Minimum).Minimum
    $GraphHeightScale = ($MaxValue - $MinValue) / $global:graphHeight

    for ($height = $global:graphHeight; $height -ge 0; $height--) {
        foreach ($record in $DayRecords) {
            $ScaledValue = [Math]::Floor(($record - $MinValue) / $GraphHeightScale)
            if ($ScaledValue -eq $height) {
                $Color = if ($height -ge $global:graphHeight * 0.75) { "Green" }
                         elseif ($height -le $global:graphHeight * 0.25) { "Red" }
                         else { "Yellow" }
                $GraphSymbol = '█' * $CharactersPerStat
            } else {
                $Color = "Gray" # Default color for empty space
                $GraphSymbol = ' ' * $CharactersPerStat
            }
            Write-Host $GraphSymbol -NoNewline -ForegroundColor $Color
        }
        Write-Host ""
    }
}





Function Show-PredictionGraph {
    Param(
        [Parameter(Mandatory = $true)]
        [int[]] $DayRecords
    )

    if (-not $DayRecords -or $DayRecords.Count -eq 0) {
        Write-Host "No data available for Prediction Graph."
        return
    }

    $config = Manage-ConfigSettings -action "Load"
    $MaxValue = ($DayRecords | Measure-Object -Maximum).Maximum
    $MinValue = ($DayRecords | Measure-Object -Minimum).Minimum
    $GraphHeightScale = ($MaxValue - $MinValue) / $global:graphHeight
    $CharactersPerStat = [Math]::Floor($global:graphWidth / 30)

    for ($height = $global:graphHeight; $height -ge 0; $height--) {
        foreach ($record in $DayRecords) {
            $volatilityUpper = $record + (([double]$config.IntermittantKeys.HighestCreditHigh - $record) / 2)
            $volatilityLower = $record - (($record - [double]$config.IntermittantKeys.LowestCreditLow) / 2)
            $ScaledValue = [Math]::Floor(($record - $MinValue) / $GraphHeightScale)
            $ScaledVolatilityUpper = [Math]::Floor(($volatilityUpper - $MinValue) / $GraphHeightScale)
            $ScaledVolatilityLower = [Math]::Floor(($volatilityLower - $MinValue) / $GraphHeightScale)

            if ($height -ge $ScaledVolatilityLower -and $height -le $ScaledVolatilityUpper) {
                $Color = if ($height -ge $global:graphHeight * 0.75) { "Green" }
                         elseif ($height -le $global:graphHeight * 0.25) { "Red" }
                         else { "Yellow" }
                $GraphSymbol = '█' * $CharactersPerStat
            } else {
                $Color = "Gray" # Default color for non-volatility sections
                $GraphSymbol = ' ' * $CharactersPerStat
            }
            Write-Host $GraphSymbol -NoNewline -ForegroundColor $Color
        }
        Write-Host ""
    }
}








Function Get-PredictedValues {
    Param(
        [Parameter(Mandatory = $true)]
        [int[]] $DayRecords
    )
    $maxHistoryValue = ($DayRecords | Measure-Object -Maximum).Maximum
    $minHistoryValue = ($DayRecords | Measure-Object -Minimum).Minimum
    $average = [Math]::Round(($maxHistoryValue + $minHistoryValue) / 2)
    $PredictedValues = @()
    foreach ($record in $DayRecords) {
        $invertedValue = $average - ($record - $average)  
        $PredictedValues += $invertedValue
    }
    return $PredictedValues
}


Function Get-ScaledDataPoints {
    Param(
        [Parameter(Mandatory = $true)]
        [int[]] $DayRecords1,
        [int[]] $DayRecords10,
        [int[]] $DayRecords100
    )
    $ScaledRecords = @()
    foreach ($record in $DayRecords1) {
        $ScaledRecords += $record
    }
    foreach ($record in $DayRecords10) {
        $ScaledRecords += [Math]::Round($record / 10)
    }
    foreach ($record in $DayRecords100) {
        $ScaledRecords += [Math]::Round($record / 100)
    }
    return $ScaledRecords
}
