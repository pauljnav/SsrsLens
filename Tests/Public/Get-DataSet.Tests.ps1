BeforeAll {
    $modulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\SSRSLens.psd1'
    Import-Module -Name $modulePath -Force
}

Describe 'Get-DataSet' {
    BeforeEach {
        Mock Get-ReportContent -ModuleName SSRSLens {
            [xml]@'
<Report xmlns="http://schemas.microsoft.com/sqlserver/reporting/2016/01/reportdefinition">
  <DataSets>
    <DataSet Name="MainQuery">
      <Query>
        <DataSourceName>MainDb</DataSourceName>
        <CommandType>Text</CommandType>
        <CommandText>SELECT 1</CommandText>
      </Query>
    </DataSet>
  </DataSets>
</Report>
'@
        }
    }

    It 'parses the report dataset and emits a Lens.DataSet object' {
        $report = [pscustomobject]@{
            PSTypeName = 'Lens.Report'
            Name       = 'Summary'
            Path       = '/Finance/Summary'
            Id         = '00000000-0000-0000-0000-000000000001'
        }

        $dataSets = @($report | Get-DataSet)

        $dataSets | Should -HaveCount 1
        $dataSets[0].PSTypeNames | Should -Contain 'Lens.DataSet'
        $dataSets[0].Name | Should -Be 'MainQuery'
        $dataSets[0].DataSourceName | Should -Be 'MainDb'
        $dataSets[0].CommandText | Should -Be 'SELECT 1'
    }
}
