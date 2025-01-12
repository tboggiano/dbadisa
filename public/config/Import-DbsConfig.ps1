﻿<#
.SYNOPSIS
Imports dbadisa configs from a json file

.DESCRIPTION
   Imports dbadisa configs from a json file

.PARAMETER Path
The path to import from, by default is "$script:localapp\config.json"

.PARAMETER Temporary
The settings are not persisted outside the current session.
By default, settings will be remembered across all PowerShell sessions.

.PARAMETER EnableException
By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

.EXAMPLE
Import-DbsConfig

Imports config from "$script:localapp\config.json"

.EXAMPLE
Import-DbsConfig -Path \\nas\projects\config.json

Imports config from \\nas\projects\config.json

.LINK
https://dbadisa.readthedocs.io/en/latest/functions/Import-DbsConfig/

#>

function Import-DbsConfig {
    [CmdletBinding()]
    param (
        [string]$Path = "$script:localapp\config.json",
        [switch]$Temporary,
        [switch]$EnableException
    )

    process {
        if (-not (Test-Path -Path $Path)) {
            Stop-PSFFunction -Message "$Path does not exist. Run Export-DbsConfig to create."
            return
        }

        try {
            $results = Get-Content -Path $Path -Raw | ConvertFrom-Json
        } catch {
            Stop-PSFFunction -Message "Failure" -ErrorRecord $_
            return
        }

        foreach ($result in $results) {
            Set-DbsConfig -Name $result.Name -Value $result.Value -Temporary:$Temporary
        }
    }
}