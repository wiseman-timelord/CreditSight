function Main-Menu {
    Clear-Host
    Write-Host "Personal Finance Tracker"
    Write-Host "1. View Financial Summary"
    Write-Host "2. Update Finance Record"
    Write-Host "3. Display Financial Graph"
    Write-Host "4. Exit"
    $choice = Read-Host "Select an option"
    
    switch ($choice) {
        '1' {
            Display-FinancialSummary
        }
        '2' {
            Update-FinancialRecord
        }
        '3' {
            Display-Graph
        }
        '4' {
            Write-Host "Exiting..."
            Exit
        }
        default {
            Write-Host "Invalid option, please try again."
        }
    }
    Pause
}

function Update-FinancialRecord {
    $amountChange = Read-Host "Enter the finance amount change (positive or negative)"
    if ($amountChange -match '^-?\d+$') {
        Update-FinancialData $amountChange
        Write-Host "Finance record updated."
    } else {
        Write-Host "Invalid input. Please enter a numeric value."
    }
}

function Create-Graph {
    $config = Load-Configuration
    $graph = ""

    # Implement logic to map day records to ASCII characters
    # Develop prediction logic based on a moving average or similar method
    # Ensure the graph is centered around the current day

    # Placeholder for detailed graph creation logic

    return $graph
}





function Display-Graph {
    Write-Host (Create-Graph)
}

function Display-FinancialSummary {
    $config = Load-Configuration
    Write-Host "Current Total: $($config.CurrentTotal)"
    Write-Host "Last Finance Change: $($config.LastFinanceChange)"
    Write-Host "Day Credit Low: $($config.DayCreditLow)"
    Write-Host "Day Credit High: $($config.DayCreditHigh)"
    Write-Host "Day Credit Now: $($config.DayCreditNow)"
    # Additional summary information can be added here as needed
}

# Placeholder for additional display-related functions
