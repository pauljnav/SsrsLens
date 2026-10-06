# SSRSLens Implementation Instructions

## Mission

Build **SSRSLens**, a PowerShell 7+ module focused exclusively on **read-only discovery, inventory, inspection, and analysis** of SQL Server Reporting Services environments.

SSRSLens must never modify SSRS state.

Non-goals:

- Report deployment
- Folder creation
- Permission management
- Subscription management
- Data source modification
- Encryption key operations

Those concerns are already addressed by existing SSRS tooling.

SSRSLens should answer questions such as:

- What reports exist?
- Where are reports located?
- What SQL does a report execute?
- Which data sources are used?
- What dependencies exist?
- Which reports use a particular stored procedure?

---

# Design Principles

## PowerShell First

Follow standard PowerShell design patterns:

- Approved verbs only
- Pipeline-friendly
- Object output only
- No formatted text output
- Strong parameter validation
- Meaningful error records

---

## PowerShell 7 Native

Do not use:

```powershell
New-WebServiceProxy
```

Do not depend on:

```powershell
Windows PowerShell
```

Use:

```powershell
Invoke-RestMethod
Invoke-WebRequest
System.Xml
System.Uri
System.UriBuilder
```

only.

---

## Read-Only By Design

Every public command must:

- Perform GET-style operations
- Never issue POST/PUT/PATCH/DELETE requests
- Never alter ReportServer database content
- Never alter SSRS configuration

---

## URI Safety

Avoid string concatenation for URI construction.

Bad:

```powershell
"https://$Server/reports/api/v2.0/CatalogItems"
```

Good:

```powershell
[UriBuilder]
```

All internal URI construction should use:

```powershell
[uri]
[uribuilder]
```

where practical.

---

## Authentication

Initial implementation:

```powershell
UseDefaultCredentials
```

only.

Future credential support may be added without breaking public API.

---

# Naming Strategy

Module Name:

```text
SSRSLens
```

Public commands should not contain "SSRS" in the noun.

Examples:

```text
Get-Report
Get-ReportDefinition
Get-ReportDataSet
Get-ReportSql
Get-DataSource
```

Consumers can optionally import with:

```powershell
Import-Module SSRSLens -Prefix Ssrs
```

which automatically provides:

```text
Get-SsrsReport
Get-SsrsReportSql
```

---

# Object Model

All output should use custom type names.

Example:

```powershell
[pscustomobject]@{
    PSTypeName = 'SSRSLens.Report'

    Name = $Name
    Path = $Path
    Id   = $Id
}
```

Suggested initial type hierarchy:

```text
SSRSLens.Report
SSRSLens.ReportDefinition
SSRSLens.DataSet
SSRSLens.ReportSql
SSRSLens.DataSource
```

---

# Public API Roadmap

Implement incrementally.

---

# Stage 1 - Report Discovery

## Goal

Discover reports beneath a folder.

## Public Command

```powershell
Get-Report
```

## Parameters

```powershell
-Server
-Path
-Recurse
```

### Example

```powershell
Get-Report `
    -Server SSRS01 `
    -Path '/Finance'
```

### Output

```text
Name
Path
Id
```

Example object:

```powershell
[pscustomobject]@{
    PSTypeName = 'SSRSLens.Report'

    Name = 'MonthlySales'
    Path = '/Finance/MonthlySales'
    Id   = 'guid'
}
```

## Success Criteria

- Connect to SSRS REST API v2.0
- Enumerate reports
- Support recursion
- Return report objects

---

# Stage 2 - Report Definitions

## Goal

Retrieve RDL definitions.

## Public Command

```powershell
Get-ReportDefinition
```

## Pipeline Support

```powershell
Get-Report |
    Get-ReportDefinition
```

## Output

Initial implementation may return:

```powershell
[xml]
```

Later versions may introduce custom objects.

## Success Criteria

- Retrieve report definition
- Parse XML
- Handle namespaces

---

# Stage 3 - Dataset Discovery

## Goal

Extract datasets from RDL.

## Public Command

```powershell
Get-ReportDataSet
```

## Output

```text
ReportName
ReportPath
DataSetName
DataSourceName
CommandType
```

---

# Stage 4 - SQL Discovery

## Goal

Extract underlying SQL and stored procedure calls.

## Public Command

```powershell
Get-ReportSql
```

## Example

```powershell
Get-ReportSql `
    -Server SSRS01 `
    -Path '/Finance'
```

## Output

```text
ReportPath
DataSetName
DataSourceName
CommandType
CommandText
```

Example:

```powershell
[pscustomobject]@{
    PSTypeName    = 'SSRSLens.ReportSql'

    ReportPath    = '/Finance/Sales'
    DataSetName   = 'SalesData'
    DataSourceName= 'DW'
    CommandType   = 'Text'
    CommandText   = 'SELECT * FROM Sales'
}
```

---

# Stage 5 - Dependency Analysis

Future milestone.

## Planned Commands

```powershell
Get-ReportDataSource
Get-ReportDependency
```

Questions supported:

- Which reports use datasource X?
- Which reports call stored procedure Y?
- Which datasets reference datasource Z?

---

# Module Structure

```text
SSRSLens
│
├─ Public
│  ├─ Get-Report.ps1
│  ├─ Get-ReportDefinition.ps1
│  ├─ Get-ReportDataSet.ps1
│  └─ Get-ReportSql.ps1
│
├─ Private
│  ├─ Get-ServerUri.ps1
│  ├─ Get-RestUri.ps1
│  ├─ Invoke-RestRequest.ps1
│  ├─ Get-CatalogItem.ps1
│  ├─ Get-FolderContent.ps1
│  ├─ Get-ReportContent.ps1
│  ├─ Get-XmlNamespaceManager.ps1
│  ├─ Get-DataSetNode.ps1
│  └─ Get-DataSetQuery.ps1
│
├─ Tests
├─ Formats
└─ Types
```

---

# Internal Responsibilities

## Get-ServerUri

Convert server name to base URI.

Input:

```powershell
-Server SSRS01
```

Output:

```powershell
[uri]
```

Default convention:

```text
https://server/reports
```

Future enhancements may add:

```powershell
-Port
-VirtualDirectory
-Scheme
```

without affecting callers.

---

## Get-RestUri

Build REST endpoint URIs.

Must use:

```powershell
[UriBuilder]
```

Returns:

```powershell
[uri]
```

---

## Invoke-RestRequest

Single internal wrapper around:

```powershell
Invoke-RestMethod
```

Responsibilities:

- Authentication
- Error handling
- Logging hooks
- Retry policy (future)

No REST calls should be issued directly elsewhere.

---

## Get-CatalogItem

Retrieve CatalogItems.

Must return raw REST data.

No filtering.

No formatting.

---

## Get-FolderContent

Traverse folders.

Responsibilities:

- Recursion
- Report filtering
- Folder navigation

---

## Get-XmlNamespaceManager

Create namespace manager for RDL processing.

Must support varying RDL schema namespaces.

Example:

```xml
http://schemas.microsoft.com/sqlserver/reporting/2016/01/reportdefinition
```

and future variants.

---

## Get-DataSetNode

Locate datasets within RDL XML.

Returns XML nodes only.

---

## Get-DataSetQuery

Extract:

```text
DatasetName
DataSourceName
CommandType
CommandText
```

from dataset nodes.

---

# Parameter Philosophy

Prefer:

```powershell
-Server
```

over:

```powershell
-Uri
```

SSRS endpoint structure is well-known and can be built internally.

Provide advanced URI support later if needed.

---

# Error Handling

Bad report definitions should not halt inventory operations.

Preferred:

```powershell
Write-Error
```

or

```powershell
Write-Warning
```

and continue processing.

Avoid:

```powershell
throw
```

for individual report failures.

Inventory operations should be resilient.

---

# Documentation Message

All documentation should reinforce:

> SSRSLens is a read-only PowerShell module for discovering, inventorying, and understanding SQL Server Reporting Services environments.

That sentence should appear in:

- README
- Module manifest description
- PSGallery metadata
- Project homepage
- Help content

It defines the identity and boundaries of the project.
