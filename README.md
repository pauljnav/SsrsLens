---
id: readme
title: SSRSLens
description: A PowerShell 7+ module for discovering, inspecting, and analyzing SQL Server Reporting Services.
---

# SSRSLens

A PowerShell 7+ module for discovering, inspecting, and analyzing SQL Server Reporting Services (SSRS).

SSRSLens focuses on report inventory, dataset inspection, and SQL extraction using the SSRS REST API and RDL parsing. Dependency analysis is a future direction.

The module is intentionally read-only.

---

# Why SSRSLens?

Most SSRS tooling focuses on deployment and administration.

SSRSLens focuses on answering questions such as:

- What reports exist?
- What SQL does a report execute?
- Which stored procedures are used?
- Which data sources are referenced?
- Which reports use a particular database?

---

# Features

## ReportServer connection

```powershell
Connect-SSRSLens -Server '<mySsrsServer>'
```

This updates `$env:SSRSServer` in the current session on all supported
platforms. On Windows, it also saves the server identifier in the user-scoped
environment variable for future sessions, until you change or remove it. On
Linux and macOS, configure persistence in your shell environment separately.
Data commands reuse the current process value; connection setup does not test
server connectivity or authenticate. Use `-WhatIf` to preview the local
environment-setting change without applying it.

## Report Discovery

```powershell
Get-Report
```

Discover reports within an SSRS instance using the REST API.

---

## Dataset Inspection

```powershell
Get-DataSet
```

Inspect report datasets, command types, and data source references.

---

## SQL Extraction

```powershell
Get-ReportSql
```

Extract SQL statements and stored procedure references from report definitions.

---

# Design Principles

- Read-only by design
- PowerShell 7 native
- REST API first
- Object-oriented output
- Pipeline-friendly
- Minimal dependencies
- Safe read-only execution

---

# Installation

```powershell
Install-Module SSRSLens -Scope CurrentUser
```

---

# Importing the Module

```powershell
Import-Module SSRSLens
```

Optional prefixing:

```powershell
Import-Module SSRSLens -Prefix Ssrs
```

Resulting commands:

```powershell
Connect-SsrsSSRSLens
Get-SsrsReport
Get-SsrsDataSet
Get-SsrsReportSql
```

without requiring additional implementations.

---

# Examples

Select the ReportServer once for this user and session:

```powershell
Connect-SSRSLens -Server '<mySsrsServer>'
```

The examples below assume this target is already selected. Data commands
reuse `$env:SSRSServer`.

## Discover Reports

```powershell
Get-Report
```

---

## Discover Reports in a Folder

```powershell
Get-Report -Path '/Finance'
```

---

## Discover Reports Recursively

```powershell
Get-Report -Path '/Finance' -Recurse
```

---

## Extract SQL From All Reports

```powershell
Get-ReportSql
```

---

## Extract SQL From a Folder

```powershell
Get-ReportSql -Path '/Finance'
```

---

## Pipeline Usage

```powershell
Get-Report |
    Get-ReportSql
```

---

## Find Stored Procedure Usage

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

## Group Reports by Data Source

```powershell
Get-ReportSql |
    Group-Object DataSourceName
```

---

# Public Commands

Version 0.1 intentionally focuses on a small command surface:

```text
Connect-SSRSLens
Get-Report
Get-DataSet
Get-ReportSql
```

Future commands are documented in:

```text
docs/roadmap.md
```

---

# Public Object Types

The v0.1 commands return these public object types:

```text
Lens.Report
Lens.DataSet
Lens.ReportSql
```

Reserved type contracts for future public commands:

```text
Lens.ReportDefinition
Lens.DataSource
Lens.ReportFolder
```

Object definitions and contracts are documented in:

```text
docs/architecture.md
```

---

# Documentation

Architecture:

```text
docs/architecture.md
```

Contributor and agent guidance:

```text
copilot-instructions.md
```

Implementation roadmap:

```text
docs/roadmap.md
```

---

# Project Philosophy

SSRSLens exists to help users understand their reporting estate.

It is intentionally focused on discovery and analysis rather than administration.

If a feature does not help users discover, inspect, inventory, or analyze SSRS content, it probably belongs in a different module.

---

# License

MIT License.