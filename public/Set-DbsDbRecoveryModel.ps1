function Set-DbsDbRecoveryModel {
    <#
    .SYNOPSIS
        Sets all user databases to the FULL recovery model.

    .DESCRIPTION
        Sets all user databases to the FULL recovery model.

    .PARAMETER SqlInstance
        The target SQL Server instance or instances.

    .PARAMETER SqlCredential
        Login to the target instance using alternative credentials. Accepts PowerShell credentials (Get-Credential).

        Windows Authentication, SQL Server Authentication, Active Directory - Password, and Active Directory - Integrated are all supported.

        For MFA support, please use Connect-DbaInstance.

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .NOTES
        Tags: DISA, STIG
        Author: Chrissy LeMaire (@cl), netnerds.net

        Copyright: (c) 2020 by Chrissy LeMaire, licensed under MIT
        License: MIT https://opensource.org/licenses/MIT

    .EXAMPLE
        PS C:\> Set-DbsDbRecoveryModel -SqlInstance sql2017, sql2016, sql2012

        Sets all user databases to the FULL recovery model on sql2017, sql2016, and sql2012
    #>

    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [DbaInstanceParameter[]]$SqlInstance,
        [PsCredential]$SqlCredential,
        [switch]$EnableException
    )
    process {
        $null = Get-DbaDatabase @PSBoundParameters -ExcludeSystem | Set-DbaDbRecoveryModel -RecoveryModel Full
        $rec = Get-DbaDatabase @PSBoundParameters -ExcludeSystem
        Select-DefaultView -InputObject $rec -Property SqlInstance, 'Name as Database', RecoveryModel
    }
}