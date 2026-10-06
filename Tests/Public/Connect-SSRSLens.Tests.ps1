BeforeAll {
    $modulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\SSRSLens.psd1'
    Import-Module -Name $modulePath -Force
}

Describe 'Connect-SSRSLens' {
    BeforeEach {
        $script:previousServer = $env:SSRSServer
        Mock Set-SSRSLensUserServer -ModuleName SSRSLens {}
    }

    AfterEach {
        $env:SSRSServer = $script:previousServer
    }

    It 'sets the process target and requests persistent storage on Windows' {
        Connect-SSRSLens -Server 'ssrs-test' -WarningAction SilentlyContinue

        $env:SSRSServer | Should -Be 'ssrs-test'
        if ($IsWindows) {
            Should -Invoke Set-SSRSLensUserServer -ModuleName SSRSLens -Times 1 -Exactly -ParameterFilter {
                $Server -eq 'ssrs-test'
            }
        }
        else {
            Should -Invoke Set-SSRSLensUserServer -ModuleName SSRSLens -Times 0 -Exactly
        }
    }

    It 'rejects a URL because Server must be a host identifier' {
        { Connect-SSRSLens -Server 'https://ssrs-test/reports' } | Should -Throw '*must be a host name*'
    }

    It 'does not change either target when WhatIf is used' {
        $previousServer = $env:SSRSServer

        Connect-SSRSLens -Server 'ssrs-test' -WhatIf -WarningAction SilentlyContinue

        $env:SSRSServer | Should -Be $previousServer
        Should -Invoke Set-SSRSLensUserServer -ModuleName SSRSLens -Times 0 -Exactly
    }
}
