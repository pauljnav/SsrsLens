Describe 'SSRSLens SSRS REST smoke tests' -Tag 'SmokeTest' {
    BeforeAll {
        $script:smokeServer = $env:SSRSLENS_SMOKE_SERVER
        if ([string]::IsNullOrWhiteSpace($script:smokeServer)) {
            throw 'Set SSRSLENS_SMOKE_SERVER to a test server identifier to run smoke tests.'
        }

        $modulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\SSRSLens.psd1'
        Import-Module -Name $modulePath -Force
        $script:previousProcessServer = $env:SSRSServer
    }

    AfterAll {
        $env:SSRSServer = $script:previousProcessServer
    }

    It 'connects, discovers reports, retrieves RDL, and extracts SQL' {
        Mock Set-SSRSLensUserServer -ModuleName SSRSLens {}

        Connect-SSRSLens -Server $script:smokeServer -WarningAction SilentlyContinue
        $reports = @(Get-Report)
        $sqlItems = @(Get-ReportSql)

        $reports | Should -Not -BeNullOrEmpty
        $sqlItems | Should -Not -BeNullOrEmpty
        $sqlItems[0].PSTypeNames | Should -Contain 'Lens.ReportSql'
        if ($IsWindows) {
            Should -Invoke Set-SSRSLensUserServer -ModuleName SSRSLens -Times 1 -Exactly
        }
        else {
            Should -Invoke Set-SSRSLensUserServer -ModuleName SSRSLens -Times 0 -Exactly
        }
    }
}
