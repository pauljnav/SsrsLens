---
id: roadmap
title: SSRSLens Roadmap
description: Implementation plan, milestones, backlog, and release strategy for SSRSLens.
---

# SSRSLens Roadmap

This document tracks implementation milestones.

Architecture is defined in:

```text
architecture.md
```

---

# Current Goal

Deliver a working vertical slice:

```text
Report Discovery
    ↓
RDL Retrieval
    ↓
Dataset Parsing
    ↓
SQL Extraction
```

The objective is to validate the core SSRSLens workflow before expanding the command surface.

---

# Milestone 1

## Get-Report

Deliver:

```powershell
Get-Report
```

Returns:

```text
Lens.Report
```

Success criteria:

- Report discovery works
- Folder traversal works
- Recursive discovery works
- REST API integration works
- Typed PowerShell objects are returned

Prove:

```text
SSRS
    ↓
Reports
```

---

# Milestone 2

## RDL Retrieval

Implement internal retrieval of report definitions.

This is a private capability and does not need a public command in v0.1.

Success criteria:

```text
Report
    ↓
RDL
```

works reliably.

Validate against:

- SSRS 2017
- SSRS 2019
- Power BI Report Server (if available)

RDL content should be retrievable and consumable by the parsing layer.

---

# Milestone 3

## Get-DataSet

Deliver:

```powershell
Get-DataSet
```

Returns:

```text
Lens.DataSet
```

Success criteria:

- Dataset extraction works
- Dataset names are identified
- Data source references are identified
- SQL statements are identified
- Stored procedures are identified

Prove:

```text
RDL
    ↓
Datasets
```

---

# Milestone 4

## Get-ReportSql

Deliver:

```powershell
Get-ReportSql
```

Returns:

```text
Lens.ReportSql
```

Success criteria:

- SQL inventory produced
- Stored procedure inventory produced
- Pipeline scenarios work
- Report-to-query mappings are returned

Example:

```powershell
Get-ReportSql -Path '/Finance'
```

Pipeline scenario:

```powershell
Get-Report |
    Get-ReportSql
```

Prove:

```text
Report
    ↓
Dataset
    ↓
SQL
```

---

# Parallel Workstream

## Public Object Types

Implement and stabilize:

```text
Lens.Report
Lens.ReportDefinition
Lens.DataSet
Lens.DataSource
Lens.ReportSql
Lens.ReportFolder
```

Object contracts are defined in:

```text
architecture.md
```

The v0.1 commands emit `Lens.Report`, `Lens.DataSet`, and `Lens.ReportSql`.
The other listed types are reserved contracts for future commands; they are
not emitted by the v0.1 command surface.

---

# Parallel Workstream

## Test Corpus

Create representative RDL files for parser testing.

Suggested structure:

```text
Tests/
├── Public/
│   ├── <command>.Tests.ps1
│   └── ...
├── Private/
│   ├── Get-RdlDataSet.Tests.ps1
│   ├── Get-RestApiUri.Tests.ps1
│   └── ...
├── Smoke/
│   └── <testitem>.Smoke.Tests.ps1
└── Reports/
    ├── SimpleQuery.rdl
    ├── StoredProcedure.rdl
    ├── MultiDataset.rdl
    └── SharedDataSource.rdl
```

Goal:

- Unit tests, including parser tests using the RDL fixtures, run offline without
  a live SSRS environment.
- Smoke tests are a separate Pester test set that exercises the end-to-end
  workflow against a configured SSRS REST API v2.0 instance.
- Name smoke test files `<testitem>.Smoke.Tests.ps1`, for example
  `ReportSql.Smoke.Tests.ps1`.
- Tests must mock user-scoped environment persistence and must not change the
  real user's persistent `SSRSServer` setting. Smoke tests may set the
  process-scoped value temporarily and must restore its previous value.
- Smoke tests are tagged `SmokeTest` and excluded by default through
  `PesterConfiguration.psd1` (`Filter.ExcludeTag`). To run them, set
  `SSRSLENS_SMOKE_SERVER` to a test server identifier and run
  `Invoke-Pester -Path ./Tests/Smoke -TagFilter SmokeTest`.

---

# Version 0.1 Scope

The initial release intentionally remains small.

Deliver:

```powershell
Connect-SSRSLens
Get-Report
Get-DataSet
Get-ReportSql
```

This command set supports the complete discovery workflow:

```text
Discover Report
    ↓
Inspect Dataset
    ↓
Extract SQL
```

---

# Version 0.1 Definition Of Done

Version 0.1 is complete when:

- The module runs on PowerShell 7+ and uses the SSRS REST API v2.0 without
  SOAP.
- `Connect-SSRSLens -Server '<mySsrsServer>'` sets the process-scoped
  `SSRSServer` value on all supported platforms and persists it in the
  user-scoped environment on Windows. On Linux and macOS, it warns that
  persistence must be configured separately by the user.
- `Get-Report` discovers reports, including recursive folder discovery, and
  returns `Lens.Report` objects.
- `Get-DataSet` and `Get-ReportSql` accept reports through the pipeline and
  return `Lens.DataSet` and `Lens.ReportSql` objects.
- `Get-ReportSql` returns report, dataset, and data-source references, command
  type, and command text for supported report datasets.
- Offline Pester unit tests pass using the RDL fixtures in `Tests/Reports/`.
  They cover query text, stored-procedure commands, multiple datasets, and
  data-source references without requiring an SSRS instance.
- A separate Pester smoke test, named `<testitem>.Smoke.Tests.ps1`, passes
  against at least one SSRS instance with REST API v2.0 enabled. It verifies
  connection, report discovery, RDL retrieval, and SQL extraction end to end.

---

# Deferred Features

The following functionality is not part of v0.1:

```powershell
Get-DataSource
Get-ReportDefinition
Get-SharedDataSet
Get-ReportDependency
```

These features may be introduced after the core workflow is validated.

---

# Future Vision

Future releases may expand into:

- Data source inventories
- Dependency analysis
- Dataset lineage
- Shared dataset inspection
- Governance reporting
- Estate-wide analysis

Example scenarios:

```powershell
Get-ReportSql |
    Group-Object 