# SSRSLens

A PowerShell 7+ module for exploring and analyzing SQL Server Reporting Services (SSRS).

SSRSLens focuses on discovery, inventory, metadata inspection, and SQL extraction from SSRS reports using the SSRS REST API and report definitions (RDL).

The module is intentionally read-only and safe for production environments.

---

# Why SSRSLens?

Most existing SSRS PowerShell tooling focuses on administration, deployment, and configuration.

SSRSLens focuses on answering questions like:

- What reports exist?
- Which reports use a specific database?
- What SQL is executed by a report?
- Which stored procedures are used?
- Which datasets exist in a report?
- What data sources are referenced?
- How are reports related to one another?

Examples:

```powershell
Get-Report

Get-ReportSql

Get-ReportSql -Path '/Finance'

Get-Report |
    Get-ReportSql
```

---

# Design Goals

## PowerShell 7 First

SSRSLens targets modern PowerShell.

Supported:

```text
PowerShell 7+
```

Not required:

```text
Windows PowerShell
SOAP proxies
New-WebServiceProxy
```

---

## Read-Only

SSRSLens does not modify SSRS.

Examples of intentionally unsupported functionality:

- Deploying reports
- Creating reports
- Modifying reports
- Managing subscriptions
- Managing security
- Managing encryption keys
- Managing report server configuration

---

## REST API First

SSRSLens prefers SSRS REST API v2.0 whenever possible.

Report definitions are parsed directly when required to access metadata that is unavailable through REST endpoints.

---

## Object-Oriented

Commands return typed PowerShell objects.

No screen scraping.

No formatted text processing.

No XML contracts exposed publicly.

---

# Installation

## From PSGallery

```powershell
Install-Module SSRSLens
```

## Import Module

```powershell
Import-Module SSRSLens
```

## Optional Command Prefix

Users can isolate commands by applying a module prefix:

```powershell
Import-Module SSRSLens -Prefix Ssrs
```

This automatically provides:

```powershell
Get-SsrsReport
Get-SsrsReportSql
```

without requiring separate command implementations.

---

# Command Surface (v0.1)

## Get-Report

Discover SSRS reports.

### Examples

```powershell
Get-Report
```

```powershell
Get-Report -Path '/Finance'
```

```powershell
Get-Report -Path '/Finance' -Recurse
```

### Returns

```text
SSRSLens.Report
```

---

## Get-DataSet

Retrieve dataset metadata from reports.

### Examples

```powershell
Get-Report |
    Get-DataSet
```

### Returns

```text
SSRSLens.DataSet
```

---

## Get-ReportSql

Extract SQL and stored procedure calls from reports.

### Examples

```powershell
Get-ReportSql
```

```powershell
Get-ReportSql -Path '/Finance'
```

```powershell
Get-Report |
    Get-ReportSql
```

### Returns

```text
SSRSLens.ReportSql
```

---

# Public Object Types

The following object types are considered part of the public API.

```text
SSRSLens.ReportFolder
SSRSLens.Report
SSRSLens.ReportDefinition
SSRSLens.DataSet
SSRSLens.DataSource
SSRSLens.ReportSql
```

---

# Examples

## Inventory Reports

```powershell
Get-Report -Path '/'
```

---

## Find Stored Procedures

```powershell
Get-ReportSql |
    Where-Object CommandType -eq 'StoredProcedure'
```

---

## Export SQL Inventory

```powershell
Get-ReportSql |
    Export-Csv .\ReportSql.csv -NoTypeInformation
```

---

## Group Reports By Data Source

```powershell
Get-ReportSql |
    Group-Object DataSourceName
```

---

# Architecture

SSRSLens follows a simple pipeline:

```text
REST API
    ↓
Report Discovery
    ↓
Report Definition Retrieval
    ↓
RDL Parsing
    ↓
Object Creation
```

XML is treated as an implementation detail.

Public commands return SSRSLens objects rather than XML documents.

---

# Development Principles

- Read-only by design
- PowerShell 7 native
- REST API first
- Object-oriented output
- Pipeline friendly
- Minimal dependencies
- Production-safe execution
- Stable public object contracts

---

# Roadmap

## Version 0.1

```powershell
Get-Report
Get-DataSet
Get-ReportSql
```

Primary focus:

- Report discovery
- Dataset inspection
- SQL extraction

---

## Future Candidates

Potential future functionality includes:

```powershell
Get-DataSource
Get-ReportDefinition
Get-SharedDataSet
Get-ReportDependency
```

Future releases may introduce lineage and dependency analysis capabilities while maintaining the module's read-only philosophy.

---

# License

MIT License.
