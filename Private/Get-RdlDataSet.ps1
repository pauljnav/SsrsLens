function Get-RdlDataSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Xml.XmlDocument]$XmlDocument,

        [Parameter(Mandatory)]
        [string]$ReportName,

        [Parameter(Mandatory)]
        [string]$ReportPath
    )

    $nodes = $XmlDocument.SelectNodes("/*[local-name()='Report']/*[local-name()='DataSets']/*[local-name()='DataSet']")
    foreach ($node in $nodes) {
        $queryNode = $node.SelectSingleNode("./*[local-name()='Query']")
        $dataSourceNameNode = $null
        $commandTypeNode = $null
        $commandTextNode = $null

        if ($null -ne $queryNode) {
            $dataSourceNameNode = $queryNode.SelectSingleNode("./*[local-name()='DataSourceName']")
            $commandTypeNode = $queryNode.SelectSingleNode("./*[local-name()='CommandType']")
            $commandTextNode = $queryNode.SelectSingleNode("./*[local-name()='CommandText']")
        }

        $dataSetName = [string]$node.GetAttribute('Name')
        $dataSourceName = if ($null -ne $dataSourceNameNode) { [string]$dataSourceNameNode.InnerText } else { $null }
        $commandType = if ($null -ne $commandTypeNode) { [string]$commandTypeNode.InnerText } else { $null }
        $commandText = if ($null -ne $commandTextNode) { [string]$commandTextNode.InnerText } else { $null }

        [pscustomobject]@{
            PSTypeName    = 'Lens.DataSet'
            ReportName    = $ReportName
            ReportPath    = $ReportPath
            Name          = $dataSetName
            DataSourceName = $dataSourceName
            CommandType   = $commandType
            CommandText   = $commandText
        }
    }
}
