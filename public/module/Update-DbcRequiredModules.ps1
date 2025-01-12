<#
.SYNOPSIS
Updates all required modules, including dbadisa.

.DESCRIPTION
Updates all required modules, including dbadisa.

.PARAMETER EnableException
By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

.EXAMPLE
Update-DbsRequiredModules

Updates all required modules including dbadisa

.LINK
https://dbadisa.readthedocs.io/en/latest/functions/Update-DbsRequiredModules/

#>
function Update-DbsRequiredModules {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    param (
        [switch]$EnableException
    )

    $ModuleManifest = Import-PowerShellDataFile -Path "$script:ModuleRoot\dbadisa.psd1"
    foreach ($Module in $ModuleManifest.RequiredModules) {
        if ($pscmdlet.ShouldProcess("Install $($Module.ModuleName) version $($Module.ModuleVersion) from repository")) {
            try {
                Write-PSFMessage -Level Output -Message "Updating $($Module.ModuleName)"
                Update-Module -Name $Module.ModuleName -ErrorAction Stop
            } catch {
                Stop-PSFFunction -Message "Failure" -ErrorRecord $_
            }
        }
    }
    if ($pscmdlet.ShouldProcess("Install latest dbadisa from repository")) {
        try {
            Write-PSFMessage -Level Output -Message "Updating dbadisa"
            Update-Module -Name dbadisa -ErrorAction Stop
        } catch {
            Stop-PSFFunction -Message "Failure" -ErrorRecord $_
        }
    }
}