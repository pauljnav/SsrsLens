---
id: copilot-instructions
title: SSRSLens Copilot Instructions
description: Contributor and agent guidance for the SSRSLens project.
---

# Copilot Instructions

These instructions govern contributions to SSRSLens.

The architecture document is the source of truth:

```text
docs/architecture.md
```

The roadmap is the implementation plan:

```text
docs/roadmap.md
```

When a conflict appears:

```text
architecture.md
    wins over
roadmap.md
```

because architecture defines contracts while roadmap defines planned work.

---

# Project Identity

SSRSLens is a PowerShell 7+ module for read-only exploration and analysis of SQL Server Reporting Services (SSRS).

The module focuses on:

- Report discovery
- Dataset inspection
- SQL extraction
- Data source analysis
- Dependency analysis

The module is not an administration tool.

---

# Scope Boundaries

Before adding functionality ask:

> Does this help users discover, inspect, inventory, or analyze SSRS content?

If the answer is no, the functionality likely belongs in another project.

Examples of functionality intentionally out of scope:

- Report deployment
- Report creation
- Report modification
- Subscription management
- Security administration
- Encryption key management
- SSRS server configuration

---

# Command Rules

Public data commands must use:

```powershell
Get-
```

`Connect-SSRSLens` is the sole approved public-command exception. It selects
and persists the active server target and does not authenticate, establish a
network session, or modify SSRS. Preserve its `-WhatIf` and `-Confirm`
behavior for local environment changes.

Do not introduce:

```powershell
Set-
New-
Add-
Update-
Remove-
Invoke-
```

without an explicit architectural decision.

---

# Command Surface

The currently approved public command set is defined in:

```text
docs/architecture.md
```

Do not introduce new public commands without updating:

```text
docs/architecture.md
```

and

```text
docs/roadmap.md
```

as appropriate.

---

# Read-Only Requirement

SSRSLens is read-only by design. Its SSRS interactions must not modify server
state; read-only operation does not by itself guarantee zero production impact.

Allowed operations:

```text
GET
HEAD
```

Disallowed operations:

```text
POST
PUT
PATCH
DELETE
```

unless approved by a future architecture revision.

---

# PowerShell Requirements

Target:

```text
PowerShell 7+
```

Do not introduce dependencies on:

```powershell
New-WebServiceProxy
```

Do not introduce Windows PowerShell-only functionality.

Prefer:

```powershell
Invoke-RestMethod
Invoke-WebRequest
System.Xml
```

and cross-platform .NET APIs.

`Connect-SSRSLens` must persist the user-scoped `SSRSServer` value on Windows
and set `$env:SSRSServer` for the current process on every supported platform.
On Linux and macOS, warn that persistence must be configured separately by the
user.

---

# REST First

Prefer SSRS REST API v2.0 whenever possible.

Direct RDL parsing is acceptable when information is not available via REST.

SOAP should be avoided unless a future architectural decision explicitly approves its use.

---

# Public Object Contracts

The following object types are public contracts:

```text
Lens.Report
Lens.ReportDefinition
Lens.DataSet
Lens.DataSource
Lens.ReportSql
Lens.ReportFolder
```

Do not rename public types.

Do not remove public properties without an architecture update.

The object model is defined in:

```text
docs/architecture.md
```

Every property listed for a public type in the architecture is required for
v0.1. Keep the property present and set it to `$null` when the source does not
provide a value.
Version 0.1 commands emit `Lens.Report`, `Lens.DataSet`, and `Lens.ReportSql`;
do not emit the other documented types unless a command contract is added.

---

# Object Creation

Preferred pattern:

```powershell
[pscustomobject]@{
    PSTypeName = 'Lens.Report'
}
```

Apply a PSTypeName at creation time whenever possible.

Objects should be designed for:

- Pipeline usage
- Formatting views
- Future type extensions

---

# Pipeline First

Prefer:

```powershell
Get-Report |
    Get-DataSet
```

and

```powershell
Get-Report |
    Get-ReportSql
```

over repeated lookup patterns.

Public commands should accept pipeline input whenever it creates a natural workflow.

---

# XML Handling

RDL XML is an implementation detail.

Do not expose raw XML as part of a public contract.

Preferred flow:

```text
RDL XML
    ↓
Parser
    ↓
Lens Object
```

Avoid:

```text
RDL XML
    ↓
Public Output
```

Consumers should interact with `Lens` object types rather than XML schemas.

---

# Error Handling

Inventory operations should continue whenever possible.

Preferred behavior:

```text
Report A → Success
Report B → Warning
Report C → Success
```

Avoid terminating an entire inventory operation because a single report cannot be parsed.

Use warnings and non-terminating errors where appropriate.

---

# Testing Requirements

Parsing functionality should be testable without a live SSRS environment.

Prefer tests built around example RDL files.

Recommended structure:

```text
Tests/
├── Public/
│   ├── <command>.Tests.ps1
│   └── ...
├── Private/
│   ├── <helper>.Tests.ps1
│   └── ...
├── Smoke/
│   └── ReportSql.Smoke.Tests.ps1
└── Reports/
    ├── SimpleQuery.rdl
    ├── StoredProcedure.rdl
    ├── MultiDataset.rdl
    └── SharedDataSource.rdl
```

Parser coverage should not require an active report server whenever possible.
Smoke tests are opt-in. Mock all user-scoped environment persistence in tests;
never modify the real user's persistent environment settings. If a test sets
the process-scoped `SSRSServer` value, restore its previous value afterward.
Smoke tests are tagged `SmokeTest` and excluded by default through
`PesterConfiguration.psd1` (`Filter.ExcludeTag`). To run them, set
`SSRSLENS_SMOKE_SERVER` to a test server identifier and run
`Invoke-Pester -Path ./Tests/Smoke -TagFilter SmokeTest`.

---

# Internal Design Principles

Public commands orchestrate.

Private functions perform a single responsibility.

Prefer:

```text
Public/
    Get-Report.ps1

Private/
    Get-CatalogItem.ps1
```

over large multi-purpose functions.

Keep responsibilities narrowly focused.

---

# Decision Priorities

When multiple implementations are possible, prefer:

1. Stable public contracts
2. Simplicity
3. Pipeline usability
4. Readability
5. Performance
6. Feature completeness

Avoid premature optimization.

---

# Modification Checklist

Before submitting a change:

- Does it preserve the read-only model?
- Does it preserve PowerShell 7 compatibility?
- Does it preserve public object contracts?
- Does it follow the architecture document?
- Does it improve discovery, inspection, inventory, or analysis?

If the answer to any of these is no, reconsider the change.

---

# References

Architecture:

```text
docs/architecture.md
```

Roadmap:

```text
docs/roadmap.md
```

README:

```text
README.md
```