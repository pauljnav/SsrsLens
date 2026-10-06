function Get-Report {
    [CmdletBinding()]
    [OutputType('Lens.Report')]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [switch]$Recurse
    )

    $normalizedPath = $null
    if ($PSBoundParameters.ContainsKey('Path')) {
        $trimmedPath = $Path.Trim().Trim('/')
        $normalizedPath = if ([string]::IsNullOrEmpty($trimmedPath)) { '/' } else { "/$trimmedPath" }
    }

    foreach ($item in Get-CatalogItem) {
        $itemType = [string](Get-ObjectPropertyValue -InputObject $item -Name 'Type')
        if ($itemType -notin @('Report', '2', 'LinkedReport', '4')) {
            continue
        }

        $itemPath = [string](Get-ObjectPropertyValue -InputObject $item -Name 'Path')
        if ([string]::IsNullOrWhiteSpace($itemPath)) {
            continue
        }

        if ($null -ne $normalizedPath) {
            if ($itemPath -ne $normalizedPath) {
                if ($Recurse) {
                    $pathPrefix = if ($normalizedPath -eq '/') { '/' } else { "$normalizedPath/" }
                    if (-not $itemPath.StartsWith($pathPrefix, [StringComparison]::OrdinalIgnoreCase)) {
                        continue
                    }
                }
                else {
                    $separatorIndex = $itemPath.LastIndexOf('/')
                    $parentPath = if ($separatorIndex -le 0) { '/' } else { $itemPath.Substring(0, $separatorIndex) }
                    if ($parentPath -ne $normalizedPath) {
                        continue
                    }
                }
            }
        }

        [pscustomobject]@{
            PSTypeName   = 'Lens.Report'
            Name         = Get-ObjectPropertyValue -InputObject $item -Name 'Name'
            Path         = $itemPath
            Id           = Get-ObjectPropertyValue -InputObject $item -Name 'Id'
            Description  = Get-ObjectPropertyValue -InputObject $item -Name 'Description'
            CreatedDate  = Get-ObjectPropertyValue -InputObject $item -Name 'CreatedDate'
            ModifiedDate = Get-ObjectPropertyValue -InputObject $item -Name 'ModifiedDate'
        }
    }
}
