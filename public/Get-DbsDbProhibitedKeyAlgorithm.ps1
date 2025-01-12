function Get-DbsDbProhibitedKeyAlgorithm {
    <#
    .SYNOPSIS
        Gets a list of prohibited key algorithms

    .DESCRIPTION
        Gets a list of prohibited key algorithms

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
        Tags:
        Author: Chrissy LeMaire (@cl), netnerds.net

        Copyright: (c) 2020 by Chrissy LeMaire, licensed under MIT
        License: MIT https://opensource.org/licenses/MIT

    .EXAMPLE
        PS C:\> Get-DbsDbProhibitedKeyAlgorithm -SqlInstance sql2017, sql2016, sql2012

        Gets a list of prohibited key algorithms for all databases on sql2017, sql2016 and sql2012

    #>

    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [DbaInstanceParameter[]]$SqlInstance,
        [PsCredential]$SqlCredential,
        [switch]$EnableException
    )
    process {
        $dbs = Connect-DbaInstance -SqlInstance $SqlInstance -SqlCredential $SqlCredential | Get-DbaDatabase
        foreach ($db in $dbs) {
            try {
                Write-Message -Level Verbose -Message "Processing $($db.Name)"
                $db.Query("SELECT DISTINCT @@SERVERNAME as SqlInstance, DB_NAME() as [Database],
                Name, algorithm_desc as Description
                FROM sys.symmetric_keys
                WHERE key_algorithm NOT IN ('D3','A3')
                ORDER BY name")
            } catch {
                Stop-Function -Message "Failure for $($db.Name) on $($db.Parent.Name)" -ErrorRecord $_ -Continue -EnableException:$EnableException
            }
        }
    }
}