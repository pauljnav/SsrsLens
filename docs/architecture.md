---
id: architecture
title: SSRSLens Architecture
description: Technical architecture, public contracts, and design decisions for SSRSLens.
---

# SSRSLens Architecture

This document defines the technical architecture and public contracts of SSRSLens.

The architecture document is the authoritative source for:

- Public commands
- Public object contracts
- Module boundaries
- Design principles
- Internal structure

Contributor guidance is located in:

```text
../copilot-instructions.md
```

Implementation planning is located in:

```text
roadmap.md
```

---

# Architecture Goals

SSRSLens exists to provide:

- Report discovery
- Dataset inspection
- SQL extraction
- Data source analysis
- Dependency analysis

SSRSLens is intentionally:

- Read-only
- PowerShell 7 native
- REST-first
- Object-oriented
- Pipeline-friendly

---

# Architectural Boundaries

SSRSLens is an analysis module.

SSRSLens is not an administration module.

Examples intentionally outside scope:

- Report deployment
- Report creation
- Report modification
- Subscription management
- Security administration
- Encryption key management
- SSRS server configuration

---

# Runtime Requirements

## PowerShell

Minimum version:

```text
PowerShell 7+
```

Supported platforms:

```text
Windows
Linux
macOS
```

assuming connectivity to the target SSRS instance.

`Connect-SSRSLens` persists the user-scoped `SSRSServer` value on Windows and
sets the process-scoped value on every supported platform. On Linux and macOS,
the target is available for the current process only; the user must configure
their shell environment separately for persistence across sessions.

---

# Retrieval Strategy

Preferred order:

```text
SSRS REST API v2.0
        ↓
RDL Parsing
```

Avoid:

```text
SOAP
```

unless a future architectural decision requires it.

---

# High-Level Architecture

```text
SSRS
REST API
        ↓
Retrieval Layer
        ↓
Report Definition Layer
        ↓
RDL Parsing Layer
        ↓
Object Creation Layer
        ↓
Public Commands
```

Consumers interact only with public commands and typed objects.

---

# Public Command Surface

Version 0.1 command surface:

```powershell
Connect-SSRSLens
Get-Report
Get-DataSet
Get-ReportSql
```

`Connect-SSRSLens` is the sole approved public command that does not use the
`Get-` verb. It selects the active SSRS server target; it does not authenticate,
establish a network session, or modify SSRS. It supports `-WhatIf` and
`-Confirm` for the local environment-setting changes it performs.

Future commands may be introduced through architectural review.

See:

```text
roadmap.md
```

---

## Connection Model

SSRSLens uses a single active connection target.

Select the target using:

```powershell
Connect-SSRSLens -Server '<mySsrsServer>'
```

`-Server` accepts the server identifier, not a URL. SSRSLens generates the
SSRS URL from that identifier using the project's established URL-generation
function. Selecting a target does not test connectivity or credentials; the
first data command reports any such failures.

`Connect-SSRSLens` stores the target in the user-scoped `SSRSServer` environment
variable on Windows so it is available to future sessions. On Linux and macOS,
it warns that persistent user-scope environment updates are unsupported and
sets the target only in the current process. On every platform, it also sets
`$env:SSRSServer` so subsequent commands in that session use the target
immediately:

```powershell
Get-Report
Get-DataSet
Get-ReportSql
```

Read the target currently used by this process:

```powershell
$env:SSRSServer
```

Clearing `$env:SSRSServer` only clears the current process value; it does not
remove the persistent user-scoped value. To remove the persistent value:

```powershell
[Environment]::SetEnvironmentVariable('SSRSServer', $null, 'User')
```

To set the persistent value directly, for example:

```powershell
[Environment]::SetEnvironmentVariable(
    'SSRSServer',
    '<mySsrsServer>',
    'User'
)
```

Setting the user-scoped variable directly affects subsequently started
processes, not the current process. Use `Connect-SSRSLens -Server ...` to set
both the persistent value and the current process value.

### Resolution

In version 0.1, data commands use the process's `SSRSServer` environment
variable. If it is unset or empty, they return a clear error explaining how to
select a target. An explicit server parameter on data commands may be considered
in a future architecture revision; if introduced, it will take precedence over
the environment variable.

The intended workflow is:

```powershell
Connect-SSRSLens -Server '<mySsrsServer>'

Get-Report
Get-DataSet
Get-ReportSql
```

without requiring connection objects or repetitive server parameters.

---

# Public Object Model

The following types are public contracts and should be considered stable.

---

## Type Name Prefix: Lens

`Lens` is the intentional prefix for SSRSLens public object type names. Public
objects use PowerShell type names such as `Lens.Report` and `Lens.DataSet`.

All listed properties below are required members of the v0.1 public contract.
When SSRS does not provide a value, the property remains present with a null
value.

The v0.1 commands return `Lens.Report`, `Lens.DataSet`, and `Lens.ReportSql`.
`Lens.ReportDefinition`, `Lens.DataSource`, and `Lens.ReportFolder` are
reserved public type contracts for future commands; they are not emitted by
the v0.1 command surface.

## Lens.Report

Represents an SSRS report (SSRS Lens report).

Required v0.1 properties:

```powershell
Name
Path
Id
Description
CreatedDate
ModifiedDate
```

Example:

```text
Lens.Report
```

---

# Lens.ReportDefinition

Represents parsed report metadata.

Required v0.1 properties:

```powershell
ReportName
ReportPath
SchemaVersion
DataSetCount
DataSourceCount
```

Purpose:

- Intermediate object
- Report inspection
- Metadata analysis

Raw XML should not be exposed.

---

# Lens.DataSet

Represents a dataset defined within a report.

Required v0.1 properties:

```powershell
ReportName
ReportPath
Name
DataSourceName
CommandType
CommandText
```

Examples:

```text
SELECT statements
Stored procedure calls
```

---

# Lens.DataSource

Represents a report data source.

Required v0.1 properties:

```powershell
Name
Path
Provider
ConnectionString
```

---

# Lens.ReportSql

Represents SQL extracted from a report.

Required v0.1 properties:

```powershell
ReportName
ReportPath
DataSetName
DataSourceName
CommandType
CommandText
```

Purpose:

- SQL inventory
- Data source inventory
- Stored procedure inventory
- Report lineage

---

# Lens.ReportFolder

Represents an SSRS folder.

Required v0.1 properties:

```powershell
Name
Path
Id
ParentPath
```

---

# Object Creation

Preferred pattern:

```powershell
[pscustomobject]@{
    PSTypeName = 'Lens.Report'
}
```

Apply type information as early as possible.

Avoid exposing anonymous PSCustomObject output.

---

# Pipeline Design

Pipeline usability is a primary design goal.

Supported workflows should include:

```powershell
Get-Report | Get-DataSet
```

```powershell
Get-Report | Get-ReportSql
```

Object output should be designed to support idiomatic PowerShell pipeline scenarios.

---

# Authentication Model

Version 0.1 uses:

```powershell
-UseDefaultCredentials
```

Future versions may introduce:

```powershell
-Credential [PSCredential]
```

without changing the public object model.

Authentication should remain centralised within the retrieval layer.

---

# XML Strategy

RDL files are XML documents.

XML is considered an implementation detail.

Preferred flow:

```text
XML
 ↓
Parser
 ↓
Typed Object
```

Avoid:

```text
XML
 ↓
Public Output
```

Public commands should never require consumers to understand SSRS XML schemas.

---

# Error Handling

Inventory operations should be resilient.

Preferred behavior:

```text
Report A → Success
Report B → Warning
Report C → Success
```

Avoid terminating large inventory operations because a single report fails.

Use warnings and non-terminating errors where appropriate.

---

# Internal Structure

Recommended repository structure:

```text
SSRSLens/

README.md
copilot-instructions.md

SSRSLens.psd1
SSRSLens.psm1

docs/
├── architecture.md
└── roadmap.md

Public/
├── Connect-SSRSLens.ps1
├── Get-Report.ps1
├── Get-DataSet.ps1
└── Get-ReportSql.ps1

Private/
├── Get-CatalogItem.ps1
├── Get-ReportContent.ps1
├── Get-RdlDataSet.ps1
├── Get-RdlCommand.ps1
└── Get-RestApiUri.ps1

Tests/
├── Public/
│   ├── Connect-SSRSLens.Tests.ps1
│   ├── Get-Report.Tests.ps1
│   ├── Get-DataSet.Tests.ps1
│   └── Get-ReportSql.Tests.ps1
├── Private/
│   ├── Get-RdlDataSet.Tests.ps1
│   ├── Get-ReportContent.Tests.ps1
│   └── Get-RestApiUri.Tests.ps1
├── Smoke/
│   └── ReportSql.Smoke.Tests.ps1
└── Reports/
```

---

# Function Design

Public commands should orchestrate.

Private functions should perform a single responsibility.

Connection setup is a prerequisite to running data commands, not part of their
internal call chain. `Connect-SSRSLens` selects and persists the active target;
data commands then use it independently.

Preferred:

```text
Get-ReportSql
    ↓
Get-ReportContent
    ↓
Get-RdlDataSet
    ↓
Get-RdlCommand
```

Avoid large functions that perform retrieval, parsing, transformation, and formatting simultaneously.

---

# Testing Strategy

Parser functionality should be testable without a live SSRS environment.

Recommended structure:

```text
Tests/
├── Public/
│   └── Connect-SSRSLens.Tests.ps1
└── Reports/
    ├── SimpleQuery.rdl
    ├── StoredProcedure.rdl
    ├── MultiDataset.rdl
    └── SharedDataSource.rdl
```

Example report fixtures:

```text
SimpleQuery.rdl
StoredProcedure.rdl
MultiDataset.rdl
SharedDataSource.rdl
```

Goals:

- Fast tests
- Deterministic tests
- Minimal infrastructure requirements
- Smoke tests are opt-in and must mock user-scoped environment persistence so
  they never change the real user's persistent `SSRSServer` setting. They may
  set the process-scoped value for the test and must restore its prior value.
- Unit tests must mock user-scoped persistence; they must never write the
  developer's real user-scoped environment settings.
- Smoke tests are tagged `SmokeTest` and excluded by default through
  `PesterConfiguration.psd1` (`Filter.ExcludeTag`). To run them, set
  `SSRSLENS_SMOKE_SERVER` to a test server identifier and run
  `Invoke-Pester -Path ./Tests/Smoke -TagFilter SmokeTest`.

---

# Dependency Philosophy

Prefer built-in PowerShell and .NET functionality.

Examples:

```powershell
Invoke-RestMethod -UseDefaultCredentials
Invoke-WebRequest
System.Xml
```

Avoid unnecessary third-party dependencies.

---

# Formatting Philosophy

Objects must be useful by default.

Future enhancements should include:

```text
Types.ps1xml
Format.ps1xml
```

The object model should remain stable regardless of formatting decisions.

---

# Architectural Priorities

When choosing between implementation options, prefer:

1. Stable public contracts
2. Simplicity
3. Pipeline usability
4. Readability
5. Reliability
6. Performance
7. Feature completeness

Avoid premature optimization.

---

# Architecture Review Triggers

An architectural review should occur when proposing:

- New public commands
- New public object types
- Changes to public contracts
- Write operations
- SOAP dependencies
- Significant external dependencies

Changes affecting public contracts must update this document.