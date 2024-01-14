# Script: config.ps1

# Function Manage Settings
function Manage-ConfigSettings {
    param(
        [Parameter(Mandatory=$true)]
        [string]$action,
        [Parameter()]
        [hashtable]$config
    )
    $filePath = 'scripts/settings.psd1'
    switch ($action) {
        "Load" {
            Write-Host "Loading: $filePath.."
            if (Test-Path $filePath) {
                Write-Host "$filePath Found."
                try {
                    $config = Import-PowerShellDataFile -Path $filePath
                    Write-Host "Config Loaded."
                    return @{
                        DatingKeys = $config.DatingKeys
                        CurrentKeys = $config.CurrentKeys
                        IntermittantKeys = $config.IntermittantKeys
                        HistoryKeys = $config.HistoryKeys
                    }
                } catch {
                    Write-Host "Load Failed: Error: $_"
                    throw
                }
            } else {
                Write-Host "Config Missing: $filePath"
                throw "Config Missing"
            }
        }
        "Save" {
            if ($null -eq $config) {
                Write-Host "Config Data Empty."
                return
            }
            $psd1Content = "@{"
            foreach ($key in $config.Keys) {
                $value = $config[$key]
                if ($value -is [System.Array]) {
                    $arrayContent = $value -join ' '
                    $psd1Content += "`n    $key = @($arrayContent)"
                } else {
                    $psd1Content += "`n    $key = '$value'"
                }
            }
            $psd1Content += "`n}"
            try {
                $psd1Content | Out-File -FilePath $filePath
                Write-Host "Config Saved."
            } catch {
                Write-Host "Save Failed."
            }
        }
        default {
            Write-Host "Invalid action."
        }
    }
}