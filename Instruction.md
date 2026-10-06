
# GitHub Copilot Instructions

## Project: SSRSLens

SSRSLens is a PowerShell 7+ module for read-only exploration and analysis of SQL Server Reporting Services (SSRS).

The module is intentionally focused on:

- Discovery
- Metadata inspection
- Report inventory
- Dataset inspection
- SQL extraction
- Data source analysis

The module does **not** perform administrative actions.

Examples of out-of-scope functionality:

- Deploying reports
- Creating reports
- Updating reports
- Modifying subscriptions
- Security administration
- SSRS instance configuration
- Encryption key management

The module should remain safe to use in production environments.

---

# Design Principles

## Read-only first

Every public command should be read-only.

All HTTP operations should use:

- GET
- HEAD

No command should modify SSRS state.

---

## PowerShell 7 first

Minimum supported PowerShell version:

```text
PowerShell 7.x
```

Do not use:

```powershell
New-WebServiceProxy
```

Do not depend on:

```powershell
Windows PowerShell
```

Prefer:

```powershell
Invoke-RestMethod
Invoke-WebRequest
System.Xml
```

---

## REST API first

Prefer SSRS REST API v2.0 APIs whenever possible.

XML parsing of RDL files is acceptable when information is unavailable through REST.

SOAP should be avoided.

---

## Simple command names

SSRSLens deliberately does not bake "Ssrs" into command names.

Examples:

```powershell
Get-Report
Get-ReportDefinition
Get-DataSet
Get-DataSource
Get-ReportSql
Get-ReportFolder
```

Users who require command isolation can import with a prefix:

```powershell
Import-Module SSRSLens -Prefix Ssrs
```

which automatically creates:

```powershell
Get-SsrsReport
Get-SsrsReportSql
```

without requiring duplicate commands.

---

## Object-first design

Commands should return typed PowerShell objects.

Never return formatted text.

Never parse console output.

Always design around pipeline objects.

---

## XML is an implementation detail

RDL XML should never be exposed as a public object contract.

Avoid functions that return:

```powershell
[xml]
```

for downstream consumption.

Instead:

```text
Download XML
Parse XML
Return SSRSLens object
```

The SSRS schema should remain encapsulated.

---

# Public Commands (v0.1)

## Get-Report

Discover reports.

Returns:

```text
SSRSLens.Report
```

Example:

```powershell
Get-Report -Path '/Finance'
```

---

## Get-ReportDefinition

Retrieve parsed report definitions.

Input:

```text
SSRSLens.Report
```

Returns:

```text
SSRSLens.ReportDefinition
```

Example:

```powershell
Get-Report |
    Get-ReportDefinition
```

---

## Get-DataSet

Extract report datasets.

Input:

```text
SSRSLens.Report
SSRSLens.ReportDefinition
```

Returns:

```text
SSRSLens.DataSet
```

---

## Get-DataSource

Inspect report data sources.

Returns:

```text
SSRSLens.DataSource
```

---

## Get-ReportSql

Primary value proposition of the module.

Extract SQL statements and stored procedure calls from reports.

Input:

```text
SSRSLens.Report
SSRSLens.ReportDefinition
```

Returns:

```text
SSRSLens.ReportSql
```

Example:

```powershell
Get-ReportSql -Path '/Finance'
```

---

## Get-ReportFolder

Enumerate SSRS folders.

Returns:

```text
SSRSLens.ReportFolder
```

---

# Public Object Types

The following type names form the public contract of the module.

They should be considered stable.

```text
SSRSLens.ReportFolder
SSRSLens.Report
SSRSLens.ReportDefinition
SSRSLens.DataSet
SSRSLens.DataSource
SSRSLens.ReportSql
```

---

# Object Design Rules

## Type Names

Always assign a PSTypeName.

Example:

```powershell
[pscustomobject]@{
    PSTypeName = 'SSRSLens.Report'
}
```

Preferred over:

```powershell
$obj.PSObject.TypeNames.Insert(...)
```

during object creation.

---

## Pipeline Compatibility

Commands should support:

```powershell
Get-Report |
    Get-ReportSql
```

and

```powershell
Get-Report |
    Get-DataSet
```

Pipeline scenarios are preferred over repeated path lookups.

---

# Authentication

## v0.1

Default authentication:

```powershell
-UseDefaultCredentials
```

No credential parameter is required initially.

Future versions may introduce:

```powershell
-Credential
```

without breaking compatibility.

---

# Internal Architecture

Public functions should orchestrate.

Private functions should perform one responsibility only.

Example structure:

```text
Public/
    Get-Report.ps1
    Get-ReportDefinition.ps1
    Get-DataSet.ps1
    Get-DataSource.ps1
    Get-ReportSql.ps1
    Get-ReportFolder.ps1

Private/
    Get-CatalogItem.ps1
    Get-ReportContent.ps1
    Get-RdlDataSet.ps1
    Get-RdlDataSource.ps1
    Get-RdlCommand.ps1
    Get-RestApiUri.ps1
```

---

# Error Handling

Inventory operations should continue when possible.

Prefer:

```powershell
Write-Warning
Write-Error
```

for single-item failures.

Avoid terminating the entire operation because one report cannot be parsed.

Goal:

```text
Report A -> Success
Report B -> Warning
Report C -> Success
```

---

# Formatting and Views

Future versions may include:

```text
SSRSLens.Types.ps1xml
SSRSLens.Format.ps1xml
```

The object model should be designed with custom formatting in mind.

Default views should emphasize:

- Name
- Path
- Dataset
- Data Source
- Command Type

without truncating critical information.

---

# Scope Management

Before adding a feature ask:

> Does this help users discover, inspect, inventory, or analyze SSRS content?

If the answer is no, the feature probably does not belong in SSRSLens.

SSRSLens is an analysis tool, not an administration tool.
