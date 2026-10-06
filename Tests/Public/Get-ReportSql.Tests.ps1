BeforeAll {
    $modulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\SSRSLens.psd1'
    Import-Module -Name $modulePath -Force
}

Describe 'Get-ReportSql' {
    BeforeEach {
        Mock Get-ReportContent -ModuleName SSRSLens {
            [xml]@'
<Report xmlns="http://schemas.microsoft.com/sqlserver/reporting/2016/01/reportdefinition">
  <DataSets>
    <DataSet Name="ProcedureCall">
      <Query>
        <DataSourceName>MainDb</DataSourceName>
        <CommandType>StoredProcedure</CommandType>
        <CommandText>dbo.GetSummary</CommandText>
      </Query>
    </DataSet>
  </DataSets>
</Report>
'@
        }
    }

    It 'extracts report, dataset, data-source, command-type, and command-text fields' {
        $report = [pscustomobject]@{
            PSTypeName = 'Lens.Report'
            Name       = 'Summary'
            Path       = '/Finance/Summary'
            Id         = '00000000-0000-0000-0000-000000000001'
        }

        $sqlItems = @($report | Get-ReportSql)

        $sqlItems | Should -HaveCount 1
        $sqlItems[0].PSTypeNames | Should -Contain 'Lens.ReportSql'
        $sqlItems[0].ReportName | Should -Be 'Summary'
        $sqlItems[0].ReportPath | Should -Be '/Finance/Summary'
        $sqlItems[0].DataSetName | Should -Be 'ProcedureCall'
        $sqlItems[0].DataSourceName | Should -Be 'MainDb'
        $sqlItems[0].CommandType | Should -Be 'StoredProcedure'
        $sqlItems[0].CommandText | Should -Be 'dbo.GetSummary'
    }
}
