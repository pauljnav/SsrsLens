# SSRSLens Roadmap: What Comes Next

This document defines the implementation roadmap for SSRSLens after the initial architecture and command surface design have been established.

The goal is to move from design discussions to a working vertical slice that proves the module's core value proposition.

---

# Guiding Principle

Stop designing.

Start validating assumptions.

The first objective is not to build a complete SSRS module.

The first objective is to prove that the entire pipeline works:

```text
SSRS REST API
    ↓
Report Discovery
    ↓
Report Definition Retrieval
    ↓
RDL Parsing
    ↓
SQL Extraction
```

Once this works reliably in PowerShell 7, everything else becomes incremental.

---

# Milestone 1: Get-Report

## Purpose

Report discovery is the foundation of the module.

Every other command depends on locating reports.

---

## Public Command

```powershell
Get-Report
```

---

## Parameters

```powershell
-ReportServerUri
-Path
-Recurse
```

---

## Output Type

```text
SSRSLens.Report
```

---

## Suggested Properties

```powershell
Name
Path
Id
Type
CreatedDate
ModifiedDate
Description
```

---

## Success Criteria

The command can:

- Connect to SSRS REST API v2.0
- Enumerate reports beneath a folder
- Support recursive traversal
- Return typed PowerShell objects

---

## Risks to Validate

- Folder traversal strategy
- Recursive performance
- REST API behavior across SSRS versions

---

# Milestone 2: Retrieve Report Definitions

## Purpose

Validate that a report can be converted into usable RDL content.

This is the highest-risk portion of the project.

---

## Private Function

```powershell
Get-ReportContent
```

or

```powershell
Get-ReportDefinitionContent
```

---

## Input

```text
SSRSLens.Report
```

---

## Output

```powershell
[string]
```

Raw RDL XML text.

---

## Important

Do not return:

```powershell
[xml]
```

Do not expose XML publicly.

At this stage we are only proving retrieval.

---

## Success Criteria

```text
Report
    ↓
Raw RDL
```

works reliably.

---

## Validation Targets

Ideally test against:

```text
SSRS 2017
SSRS 2019
Power BI Report Server
```

before proceeding.

---

# Milestone 3: Parse Datasets

## Purpose

Extract meaningful information from RDL files.

At this stage the module begins to provide actual value.

---

## Public Command

```powershell
Get-DataSet
```

---

## Input

```text
SSRSLens.Report
```

or

```text
SSRSLens.ReportDefinition
```

---

## Output Type

```text
SSRSLens.DataSet
```

---

## Suggested Properties

```powershell
ReportName
ReportPath
Name
DataSourceName
CommandType
CommandText
```

---

## Success Criteria

The command can identify:

- Inline SQL
- Stored procedures
- Dataset names
- Associated data sources

---

# Milestone 4: The Flagship Command

## Purpose

Deliver the primary value proposition of SSRSLens.

This command should become the reason users install the module.

---

## Public Command

```powershell
Get-ReportSql
```

---

## Processing Flow

```text
Report
    ↓
Retrieve RDL
    ↓
Extract DataSets
    ↓
Flatten SQL Metadata
```

---

## Output Type

```text
SSRSLens.ReportSql
```

---

## Suggested Properties

```powershell
ReportName
ReportPath
DataSetName
DataSourceName
CommandType
CommandText
```

---

## Example

```powershell
Get-ReportSql -Path '/Finance'
```

---

## Success Criteria

The command can inventory:

- SQL statements
- Stored procedures
- Dataset ownership
- Report-to-SQL relationships

---

# Parallel Workstream: Object Model

While implementing milestones, establish stable public types.

---

## Public Object Types

```text
SSRSLens.ReportFolder
SSRSLens.Report
SSRSLens.ReportDefinition
SSRSLens.DataSet
SSRSLens.DataSource
SSRSLens.ReportSql
```

---

## Creation Pattern

Preferred:

```powershell
[pscustomobject]@{
    PSTypeName = 'SSRSLens.Report'
}
```

Avoid:

```powershell
$Object.PSObject.TypeNames.Insert(...)
```

where possible.

---

# Parallel Workstream: Testing

## Create an Offline Test Corpus

One of the biggest challenges with SSRS development is requiring a live server.

Build a set of sample reports that can be used to test XML parsing independently.

---

## Suggested Structure

```text
Tests/
└── Reports/
    ├── SimpleQuery.rdl
    ├── StoredProcedure.rdl
    ├── MultiDataset.rdl
    └── SharedDataSource.rdl
```

---

## Goals

Allow:

```powershell
Get-DataSet
```

and

```powershell
Get-ReportSql
```

to be tested entirely offline.

---

# First Release Scope

Keep version 0.1 intentionally small.

---

## Ship

```powershell
Get-Report
Get-DataSet
Get-ReportSql
```

---

## Why

These three commands represent the complete discovery workflow:

```text
Discover Report
    ↓
Inspect Dataset
    ↓
Extract SQL
```

This is enough to provide immediate value.

---

# Defer to Version 0.2

Do not build these until 0.1 is proven.

---

## Candidate Features

```powershell
Get-DataSource
Get-ReportDefinition
Get-ReportDependency
Get-SharedDataSet
```

---

## Future Vision

Enable report lineage and dependency analysis.

Example:

```powershell
Get-ReportSql |
    Group-Object DataSourceName
```

Possible future outputs include:

- Data source inventories
- Report-to-database mappings
- Stored procedure usage reports
- Column lineage analysis
- Governance and audit reporting

---

# Definition of Done for v0.1

The module is considered successful when a user can run:

```powershell
Get-ReportSql -Path '/Finance'
```

and receive a complete inventory containing:

```text
Report Name
Report Path
Dataset Name
Data Source Name
Command Type
SQL Statement / Stored Procedure
```

using only PowerShell 7 and SSRS REST APIs plus RDL parsing.
