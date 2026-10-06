function Get-RestApiUri {
    [CmdletBinding()]
    param(
        [string]$Server = $env:SSRSServer
    )

    if ([string]::IsNullOrWhiteSpace($Server)) {
        throw "No SSRS server is selected. Run Connect-SSRSLens -Server '<mySsrsServer>' first."
    }

    $serverIdentifier = $Server.Trim()
    if ($serverIdentifier -match '://|[/\\?#@]') {
        throw "Server identifier '$serverIdentifier' must be a host name, not a URL or path."
    }

    $parsedUri = $null
    if (-not [uri]::TryCreate("https://$serverIdentifier/reports/api/v2.0/", [UriKind]::Absolute, [ref]$parsedUri)) {
        throw "Server identifier '$serverIdentifier' is not a valid host name."
    }

    if ([string]::IsNullOrWhiteSpace($parsedUri.Host)) {
        throw "Server identifier '$serverIdentifier' is not a valid host name."
    }

    return $parsedUri.AbsoluteUri.TrimEnd('/')
}
