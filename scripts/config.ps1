# Script: config.ps1

# function ConvertTo-Psd1Content 
function ConvertTo-Psd1Content {
    param([hashtable]$Hashtable)
    $content = "@{"
    foreach ($key in $Hashtable.Keys) {
        $value = $Hashtable[$key]
        if ($value -is [hashtable]) {
            $nestedContent = ConvertTo-Psd1Content -Hashtable $value
            $content += "`n    $key = $nestedContent"
        } elseif ($value -is [System.Array]) {
            $arrayContent = $value -join ', '
            $content += "`n    $key = @($arrayContent)"
        } else {
            $content += "`n    $key = '$value'"
        }
    }
    $content += "`n}"
    return $content
}

# Function Manage ConfigSettings
function Manage-ConfigSettings {
    param(
        [Parameter(Mandatory)]
        [string]$action,
        [Parameter()]
        [hashtable]$config,
        [string]$filePath = 'scripts/settings.psd1'
    )
    switch ($action) {
        "Load" {
            if (Test-Path $filePath) {
                try {
                    $config = Import-PowerShellDataFile -Path $filePath
                    return $config
                } catch {
                    Write-Host "Load Error: $_"
                    throw
                }
            } else {
                Write-Host "Config Missing: $filePath"
                throw "Config Missing"
            }
        }
        "Save" {
            if ($null -eq $config) {
                Write-Host "Empty Config Data"
                return
            }
            try {
                $psd1Content = ConvertTo-Psd1Content -Hashtable $config
                $psd1Content | Out-File -FilePath $filePath
                Write-Host "Config Saved"
            } catch {
                Write-Host "Save Error"
            }
        }
        default {
            Write-Host "Invalid Action"
        }
    }
}
