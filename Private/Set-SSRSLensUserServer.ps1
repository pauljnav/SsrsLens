function Set-SSRSLensUserServer {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param(
        [Parameter(Mandatory)]
        [string]$Server
    )

    if ($PSCmdlet.ShouldProcess('Current user environment', 'Set SSRSServer')) {
        [Environment]::SetEnvironmentVariable(
            'SSRSServer',
            $Server,
            [EnvironmentVariableTarget]::User
        )
    }
}
