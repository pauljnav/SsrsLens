function Get-CatalogItem {
    [CmdletBinding()]
    param()

    $requestUri = '{0}/CatalogItems' -f (Get-RestApiUri)
    $nextUri = $requestUri

    while (-not [string]::IsNullOrWhiteSpace($nextUri)) {
        try {
            $response = Invoke-RestMethod -Uri $nextUri -Method Get -UseDefaultCredentials -ErrorAction Stop
        }
        catch {
            $caughtError = $_
            throw [InvalidOperationException]::new(
                "Failed to retrieve SSRS catalog items from '$nextUri': $($caughtError.Exception.Message)",
                $caughtError.Exception
            )
        }

        if ($response -is [array]) {
            $items = $response
            $nextLink = $null
        }
        else {
            $valueProperty = $response.PSObject.Properties['value']
            if ($null -eq $valueProperty) {
                throw [System.IO.InvalidDataException]::new(
                    "The SSRS catalog response from '$nextUri' did not contain a 'value' collection."
                )
            }

            $items = @($valueProperty.Value)
            $nextLinkProperty = $response.PSObject.Properties['@odata.nextLink']
            $nextLink = if ($null -ne $nextLinkProperty) { [string]$nextLinkProperty.Value } else { $null }
        }

        foreach ($item in $items) {
            Write-Output $item
        }

        if ([string]::IsNullOrWhiteSpace($nextLink)) {
            $nextUri = $null
        }
        else {
            $nextUri = ([uri]::new([uri]$requestUri, $nextLink)).AbsoluteUri
        }
    }
}
