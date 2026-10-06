BeforeAll {
    $modulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\SSRSLens.psd1'
    Import-Module -Name $modulePath -Force
}

Describe 'Get-RestApiUri' {
    It 'maps a server host identifier to the SSRS REST API v2.0 base URL' {
        $uri = InModuleScope SSRSLens {
            Get-RestApiUri -Server 'ssrs-test'
        }

        $uri | Should -Be 'https://ssrs-test/reports/api/v2.0'
    }

    It 'rejects URL and path input instead of treating it as a host identifier' {
        {
            InModuleScope SSRSLens {
                Get-RestApiUri -Server 'https://ssrs-test/reports'
            }
        } | Should -Throw '*must be a host name*'
    }
}
