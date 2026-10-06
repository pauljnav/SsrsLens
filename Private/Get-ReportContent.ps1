function Get-ReportContent {
    [CmdletBinding()]
    [OutputType([System.Xml.XmlDocument])]
    param(
        [Parameter(Mandatory)]
        [psobject]$Report
    )

    $reportId = [string](Get-ObjectPropertyValue -InputObject $Report -Name 'Id')
    if ([string]::IsNullOrWhiteSpace($reportId)) {
        throw "Report '$((Get-ObjectPropertyValue -InputObject $Report -Name 'Path'))' has no catalog ID; its definition cannot be retrieved."
    }

    $escapedId = [uri]::EscapeDataString($reportId)
    $requestUri = '{0}/CatalogItems({1})/Content/$value' -f (Get-RestApiUri), $escapedId

    try {
        $response = Invoke-WebRequest -Uri $requestUri -Method Get -UseDefaultCredentials -ErrorAction Stop
    }
    catch {
        $caughtError = $_
        throw [InvalidOperationException]::new(
            "Failed to retrieve the definition for report '$((Get-ObjectPropertyValue -InputObject $Report -Name 'Path'))': $($caughtError.Exception.Message)",
            $caughtError.Exception
        )
    }

    $reader = $null
    $textReader = $null
    try {
        $settings = [System.Xml.XmlReaderSettings]::new()
        $settings.DtdProcessing = [System.Xml.DtdProcessing]::Prohibit
        $settings.XmlResolver = $null
        $textReader = [System.IO.StringReader]::new([string]$response.Content)
        $reader = [System.Xml.XmlReader]::Create($textReader, $settings)
        $document = [System.Xml.XmlDocument]::new()
        $document.XmlResolver = $null
        $document.Load($reader)
        return $document
    }
    catch {
        $caughtError = $_
        throw [System.IO.InvalidDataException]::new(
            "The definition for report '$((Get-ObjectPropertyValue -InputObject $Report -Name 'Path'))' is not valid RDL XML: $($caughtError.Exception.Message)",
            $caughtError.Exception
        )
    }
    finally {
        if ($null -ne $reader) {
            $reader.Dispose()
        }
        if ($null -ne $textReader) {
            $textReader.Dispose()
        }
    }
}
