# Script: config.ps1

# Function Convertto Psd1content
function ConvertTo-Psd1Content {
    param([hashtable]$Hashtable)
    $content = "@{"
    foreach ($key in $Hashtable.Keys) {
        $value = $Hashtable[$key]
        if ($value -is [hashtable]) {
            $nestedContent = ConvertTo-Psd1Content -Hashtable $value
            $content += "`n    $key = $nestedContent"
        } elseif ($value -is [System.Array]) {
            # Correctly format the array values
            $arrayContent = $($value -join ', ')
            $content += "`n    $key = @($arrayContent)"
        } else {
            $content += "`n    $key = '$value'"
        }
    }
    $content += "`n}"
    return $content
}


# Function Manage Configsettings
function Manage-ConfigSettings {
    param(
        [Parameter(Mandatory)]
        [string]$action,
        [Parameter()]
        [hashtable]$config,
        [string]$filePath = 'scripts/settings.psd1'
    )
    if ($action -eq "Save" -and $null -eq $config) {
        Write-Host "Empty Config Data"
        return
    }
    switch ($action) {
        "Load" {
            if (Test-Path $filePath) {
                try {
                    $config = Import-PowerShellDataFile -Path $filePath
                    return $config
                } catch {
                    Write-Host "Load Error: $_"
                    Log-Error "Load Error: $_" 
                    return $null
                }
            } else {
                Write-Host "Config Missing: $filePath"
                Log-Error "Config Missing: $filePath" 
                throw "Config Missing"
            }
        }
        "Save" {
            try {
                $psd1Content = ConvertTo-Psd1Content -Hashtable $config
                $psd1Content | Out-File -FilePath $filePath
                Write-Host "Config Saved"
            } catch {
                Write-Host "Save Error: $_"
                Log-Error "Save Error: $_" 
            }
        }
        default {
            Write-Host "Invalid Action"
        }
    }
}
