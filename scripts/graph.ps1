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

    # Check for null or empty $DayRecords
    if (-not $DayRecords -or $DayRecords.Count -eq 0) {
        Write-Host "No data available for History Graph."
        return
    }

    $CharactersPerStat = $global:graphWidth / 30
    $MaxValue = ($DayRecords | Measure-Object -Maximum).Maximum
    $MinValue = ($DayRecords | Measure-Object -Minimum).Minimum
    $GraphHeightScale = ($MaxValue - $MinValue) / $global:graphHeight

    for ($line = $global:graphHeight; $line -ge 0; $line--) {
        foreach ($record in $DayRecords) {
            $ScaledValue = [Math]::Floor(($record - $MinValue) / $GraphHeightScale)
            $Color = if ($ScaledValue -ge $line) { 
                        if ($line -ge $global:graphHeight * 0.75) { "Green" }
                        elseif ($line -le $global:graphHeight * 0.25) { "Red" }
                        else { "Yellow" }
                     } else { "Yellow" }

            $GraphSymbol = if ($ScaledValue -ge $line) { '█' * $CharactersPerStat } else { ' ' * $CharactersPerStat }
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

    # Check for null or empty $DayRecords
    if (-not $DayRecords -or $DayRecords.Count -eq 0) {
        Write-Host "No data available for Prediction Graph."
        return
    }

    $CharactersPerStat = $global:graphWidth / 30
    $MaxValue = ($DayRecords | Measure-Object -Maximum).Maximum
    $MinValue = ($DayRecords | Measure-Object -Minimum).Minimum
    $GraphHeightScale = ($MaxValue - $MinValue) / $global:graphHeight

    for ($line = $global:graphHeight; $line -ge 0; $line--) {
        foreach ($record in $DayRecords) {
            $ScaledValue = [Math]::Floor(($record - $MinValue) / $GraphHeightScale)
            $Color = if ($ScaledValue -ge $line) { 
                        if ($line -ge $global:graphHeight * 0.75) { "Green" }
                        elseif ($line -le $global:graphHeight * 0.25) { "Red" }
                        else { "Yellow" }
                     } else { "Yellow" }

            $GraphSymbol = if ($ScaledValue -ge $line) { '█' * $CharactersPerStat } else { ' ' * $CharactersPerStat }
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
