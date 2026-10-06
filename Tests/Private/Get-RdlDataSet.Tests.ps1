BeforeAll {
    $modulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\SSRSLens.psd1'
    Import-Module -Name $modulePath -Force
    $script:fixturePath = Join-Path -Path $PSScriptRoot -ChildPath '..\Reports'
}

Describe 'Get-RdlDataSet' {
    It 'extracts command and data-source metadata from a simple query fixture' {
        $document = [xml](Get-Content -LiteralPath (Join-Path $script:fixturePath 'SimpleQuery.rdl') -Raw)
        $dataSets = @(InModuleScope SSRSLens -Parameters @{ Rdl = $document } {
            param($Rdl)
            Get-RdlDataSet -XmlDocument $Rdl -ReportName 'Summary' -ReportPath '/Finance/Summary'
        })

        $dataSets | Should -HaveCount 1
        $dataSets[0].Name | Should -Be 'MainQuery'
        $dataSets[0].DataSourceName | Should -Be 'MainDb'
        $dataSets[0].CommandText | Should -Be 'SELECT 1'
    }

    It 'preserves multiple datasets from a report fixture' {
        $document = [xml](Get-Content -LiteralPath (Join-Path $script:fixturePath 'MultiDataset.rdl') -Raw)
        $dataSets = @(InModuleScope SSRSLens -Parameters @{ Rdl = $document } {
            param($Rdl)
            Get-RdlDataSet -XmlDocument $Rdl -ReportName 'Summary' -ReportPath '/Finance/Summary'
        })

        $dataSets | Should -HaveCount 2
    }

    It 'extracts a stored-procedure command from its fixture' {
        $document = [xml](Get-Content -LiteralPath (Join-Path $script:fixturePath 'StoredProcedure.rdl') -Raw)
        $dataSets = @(InModuleScope SSRSLens -Parameters @{ Rdl = $document } {
            param($Rdl)
            Get-RdlDataSet -XmlDocument $Rdl -ReportName 'Summary' -ReportPath '/Finance/Summary'
        })

        $dataSets[0].CommandType | Should -Be 'StoredProcedure'
        $dataSets[0].CommandText | Should -Be 'dbo.GetSummary'
    }
}
