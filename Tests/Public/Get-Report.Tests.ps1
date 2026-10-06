BeforeAll {
    $modulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\SSRSLens.psd1'
    Import-Module -Name $modulePath -Force
}

Describe 'Get-Report' {
    BeforeEach {
        Mock Get-CatalogItem -ModuleName SSRSLens {
            [pscustomobject]@{
                Type         = 'Report'
                Name         = 'Summary'
                Path         = '/Finance/Summary'
                Id           = '00000000-0000-0000-0000-000000000001'
                Description  = 'Finance report'
                CreatedDate  = $null
                ModifiedDate = $null
            }
            [pscustomobject]@{
                Type         = 'Report'
                Name         = 'Detail'
                Path         = '/Finance/Archive/Detail'
                Id           = '00000000-0000-0000-0000-000000000002'
                Description  = $null
                CreatedDate  = $null
                ModifiedDate = $null
            }
            [pscustomobject]@{
                Type = 'Folder'
                Name = 'Finance'
                Path = '/Finance'
                Id   = '00000000-0000-0000-0000-000000000003'
            }
        }
    }

    It 'returns report objects with the Lens.Report type name and required properties' {
        $reports = @(Get-Report)

        $reports | Should -HaveCount 2
        $reports[0].PSTypeNames | Should -Contain 'Lens.Report'
        $reports[0].PSObject.Properties.Name | Should -Contain 'CreatedDate'
        $reports[0].PSObject.Properties.Name | Should -Contain 'ModifiedDate'
    }

    It 'returns direct children by path unless Recurse is specified' {
        @(Get-Report -Path '/Finance') | Should -HaveCount 1
        @(Get-Report -Path '/Finance' -Recurse) | Should -HaveCount 2
    }
}
