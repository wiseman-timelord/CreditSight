# Script: graph.ps1

# Function Display Graph
function Display-Graph {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("History", "Prediction")]
        [string] $GraphType
    )

    $global:config = Manage-ConfigSettings -action "Load"
    $DayRecords = Get-ScaledDataPoints -DayRecords $global:config.HistoryKeys.DayRecords_1

    if ($GraphType -eq "History") {
        Show-HistoryGraph -DayRecords $DayRecords
    } elseif ($GraphType -eq "Prediction") {
        $PredictedValues = Get-PredictedValues -DayRecords $DayRecords
        Show-PredictionGraph -DayRecords $PredictedValues
    }
}

# Function Update Financialrecord
Function Show-HistoryGraph {
    Param(
        [Parameter(Mandatory = $true)]
        [int[]] $DayRecords
    )

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

    # Calculate maximum and minimum values using Measure-Object
    $maxHistoryValue = ($DayRecords | Measure-Object -Maximum).Maximum
    $minHistoryValue = ($DayRecords | Measure-Object -Minimum).Minimum
    $average = [Math]::Round(($maxHistoryValue + $minHistoryValue) / 2)

    $PredictedValues = @()
    foreach ($record in $DayRecords) {
        $invertedValue = $average - ($record - $average)  # Inverting around the average
        $PredictedValues += $invertedValue
    }

    return $PredictedValues
}


Function Get-ScaledDataPoints {
    Param(
        [Parameter(Mandatory = $true)]
        [int[]] $DayRecords
    )

    $ScaledRecords = @()
    for ($i = 0; $i -lt 10; $i++) {
        $ScaledRecords += $DayRecords[$i]
    }
    for ($i = 10; $i -lt 20; $i++) {
        $ScaledRecords += [Math]::Round($DayRecords[$i] / 10)
    }
    for ($i = 20; $i -lt 30; $i++) {
        $ScaledRecords += [Math]::Round($DayRecords[$i] / 100)
    }
    return $ScaledRecords
}

