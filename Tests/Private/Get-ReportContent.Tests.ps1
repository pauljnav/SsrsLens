BeforeAll {
    $modulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\SSRSLens.psd1'
    Import-Module -Name $modulePath -Force
}

Describe 'Get-ReportContent' {
    BeforeEach {
        $script:previousServer = $env:SSRSServer
        $env:SSRSServer = 'ssrs-test'
        Mock Invoke-WebRequest -ModuleName SSRSLens {
            [pscustomobject]@{
                Content = '<Report>'
            }
        }
    }

    AfterEach {
        $env:SSRSServer = $script:previousServer
    }

    It 'reports malformed report content as an invalid-data error' {
        InModuleScope SSRSLens {
            $report = [pscustomobject]@{
                Name = 'BadReport'
                Path = '/BadReport'
                Id   = '00000000-0000-0000-0000-000000000001'
            }

            { Get-ReportContent -Report $report } | Should -Throw '*not valid RDL XML*'
        }
    }
}
