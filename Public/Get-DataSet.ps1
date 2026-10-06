function Get-DataSet {
    [CmdletBinding()]
    [OutputType('Lens.DataSet')]
    param(
        [Parameter(ValueFromPipeline)]
        [psobject]$InputObject,

        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [switch]$Recurse
    )

    begin {
        $reportsWereProvided = $MyInvocation.ExpectingInput -or $PSBoundParameters.ContainsKey('InputObject')
        $reportsToRead = @()
        if (-not $reportsWereProvided) {
            $reportParameters = @{}
            if ($PSBoundParameters.ContainsKey('Path')) {
                $reportParameters.Path = $Path
            }
            if ($Recurse) {
                $reportParameters.Recurse = $true
            }
            $reportsToRead = @(Get-Report @reportParameters)
        }
    }

    process {
        $reports = if ($reportsWereProvided) { @($InputObject) } else { $reportsToRead }
        foreach ($report in $reports) {
            if ($null -eq $report) {
                continue
            }

            $reportName = [string](Get-ObjectPropertyValue -InputObject $report -Name 'Name')
            $reportPath = [string](Get-ObjectPropertyValue -InputObject $report -Name 'Path')
            try {
                $document = Get-ReportContent -Report $report
                Get-RdlDataSet -XmlDocument $document -ReportName $reportName -ReportPath $reportPath
            }
            catch {
                $caughtError = $_
                Write-Error -Message "Unable to inspect report '$reportPath': $($caughtError.Exception.Message)" -TargetObject $report -Category InvalidData -ErrorAction Continue
            }
        }
    }
}
