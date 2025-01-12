function Set-DbsAuditStartupState {
    <#
    .SYNOPSIS
        Sets startup state for compliance audit to ON.

    .DESCRIPTION
        Sets startup state for compliance audit to ON.

    .PARAMETER SqlInstance
        The target SQL Server instance or instances. Server version must be SQL Server version 2012 or higher.

    .PARAMETER SqlCredential
        Login to the target instance using alternative credentials. Accepts PowerShell credentials (Get-Credential).

        Windows Authentication, SQL Server Authentication, Active Directory - Password, and Active Directory - Integrated are all supported.

        For MFA support, please use Connect-DbaInstance.

    .PARAMETER Audit
       The name of the DISA Audit.

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .NOTES
        Tags: V-79141
        Author: Chrissy LeMaire (@cl), netnerds.net

        Copyright: (c) 2020 by Chrissy LeMaire, licensed under MIT
        License: MIT https://opensource.org/licenses/MIT

    .EXAMPLE
        PS C:\> Set-DbsAuditStartupState -SqlInstance sql2017, sql2016, sql2012

        Gets a list of non-compliant audit states on sql2017, sql2016 and sql2012

    .EXAMPLE
        PS C:\> Set-DbsAuditStartupState -SqlInstance sql2017, sql2016, sql2012

        Gets a list of non-compliant audit states on sql2017, sql2016 and sql2012

    .EXAMPLE
        PS C:\> Set-DbsAuditStartupState -SqlInstance sql2017, sql2016, sql2012 | Export-Csv -Path D:\DISA\auditstartup.csv -NoTypeInformation

        Gets a list of non-compliant audit startup states sql2017, sql2016 and sql2012 to D:\disa\auditstartup.csv
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [DbaInstanceParameter[]]$SqlInstance,
        [string[]]$Audit = (Get-PSFConfigValue -FullName dbadisa.app.auditname),
        [PsCredential]$SqlCredential,
        [switch]$EnableException
    )
    process {
        $servers = Connect-DbaInstance -SqlInstance $SqlInstance -SqlCredential $SqlCredential
        foreach ($server in $servers) {
            foreach ($currentaudit in $audit) {
                try {
                    $sql = "ALTER SERVER AUDIT [$Audit] WITH (STATE = ON)"
                    Write-Message -Message $sql -Level Verbose
                    $null = $server.Query($sql)
                    [pscustomobject]@{
                        SqlInstance  = $server.Name
                        Audit        = $currentaudit
                        StartupState = "ON"
                    }
                } catch {
                    Stop-Function -Message "Failure for $($server.Name)" -ErrorRecord $_ -Continue -EnableException:$EnableException
                }
            }
        }
    }
}