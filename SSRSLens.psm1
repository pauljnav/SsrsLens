$privatePath = Join-Path -Path $PSScriptRoot -ChildPath 'Private'
$publicPath = Join-Path -Path $PSScriptRoot -ChildPath 'Public'

foreach ($scriptFile in Get-ChildItem -LiteralPath $privatePath -Filter '*.ps1' | Sort-Object -Property Name) {
    . $scriptFile.FullName
}

foreach ($scriptFile in Get-ChildItem -LiteralPath $publicPath -Filter '*.ps1' | Sort-Object -Property Name) {
    . $scriptFile.FullName
}

Export-ModuleMember -Function @(
    'Connect-SSRSLens'
    'Get-Report'
    'Get-DataSet'
    'Get-ReportSql'
)
