function Connect-SSRSLens {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Connect-SSRSLens is the approved public command name.')]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Server
    )

    $serverIdentifier = $Server.Trim()
    $null = Get-RestApiUri -Server $serverIdentifier

    if (-not $PSCmdlet.ShouldProcess("SSRSServer target '$serverIdentifier'", 'Select and save SSRS server target')) {
        return
    }

    if ($IsWindows) {
        Set-SSRSLensUserServer -Server $serverIdentifier -Confirm:$false -WhatIf:$false
        $env:SSRSServer = $serverIdentifier
    }
    else {
        $env:SSRSServer = $serverIdentifier
        Write-Warning 'Persistent user-scope environment updates are supported only on Windows. SSRSServer is set for this session; configure persistence in your shell environment if needed.'
    }
}
