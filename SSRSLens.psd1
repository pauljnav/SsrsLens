@{
    RootModule        = 'SSRSLens.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = 'de12a9cf-2c2d-46fb-8076-03c760e70d2d'
    Author            = 'Paul Naughton tecknikp@gmail.com'
    Description       = 'Read-only SSRS discovery and report SQL analysis.'
    PowerShellVersion = '7.0'
    CompatiblePSEditions = @('Core')
    FunctionsToExport = @(
        'Connect-SSRSLens'
        'Get-Report'
        'Get-DataSet'
        'Get-ReportSql'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}
