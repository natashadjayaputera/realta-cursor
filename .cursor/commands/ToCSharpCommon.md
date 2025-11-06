---
name: "ToCSharpCommon"
model: "claude-4.5-sonnet"
description: "Convert VB.NET DTOs/enums/interfaces into a modern C# `{ProgramName}Common` library (focus: DTOs, enums, interfaces; no business logic)."
icon: "🟢"
trigger: "common"
color: "green"
actions:
  auto_apply_edits: false
  auto_run: true
  auto_fix_errors: true
tools:
  all: true
  search:
    codebase: true
    web: false
    fetch_rules: true
    read_file: true
  edit:
    edit_and_reapply: true
    create_file: true
    delete_file: false
  run:
    terminal: false
---
# ToCSharpCommon

## Overview
Agent purpose: convert VB.NET (.NET Framework 4) Back and Common Projects into C# (.NET 6) `{ProgramName}Common` project. Produce clean, idiomatic C# targeting the csproj rules below. **No business logic** in Common — only DTOs, enums, interfaces, and constants.

## Instructions
- Convert VB.NET DTOs & related types to modern C# (C# 10 / nullable enabled).
- Create a `{ProgramName}Common` library/project (follow csproj block below).
- Place **all DTOs, enums, interfaces** here.
- Interfaces must inherit/implement `R_IServiceCRUDAsyncBase` where applicable for service contracts.
- Each CRUD patterns in Back Project must have each own Interface inheriting `R_IServiceCRUDAsyncBase<{ProgramName}DTO>` with each own EntityDTO (`{ProgramName}DTO`)
- Each methods gets its own ResultDTO and ParameterDTO (NEVER reuse EntityDTO)
- **Do not** move business logic into Common.
- Keep naming consistent with project conventions.

## Context (project files to reference)
- Automatically fetch all modular `.mdc` rules matching `*ToCSharpCommon*`.
- Start with `*MigrationChecklist*` and then use `*CommonMigrationChecklist*` for project tracking and verification.

## CSProj (library settings — keep as project template)
```xml
<PropertyGroup>
  <TargetFramework>netstandard2.1</TargetFramework>
  <LangVersion>10.0</LangVersion>
  <Nullable>enable</Nullable>
  <ImplicitUsings>disable</ImplicitUsings>
</PropertyGroup>
<ItemGroup>
  <Reference Include="R_APICommonDTO">
    <HintPath>..\..\..\..\..\SYSTEM\SOURCE\LIBRARY\Back\R_APICommonDTO.dll</HintPath>
  </Reference>
  <Reference Include="R_CommonFrontBackAPI">
    <HintPath>..\..\..\..\..\SYSTEM\SOURCE\LIBRARY\Back\R_CommonFrontBackAPI.dll</HintPath>
  </Reference>
</ItemGroup>
```

## Outputs / Deliverables

* A new `{ProgramName}Common` project with:
  * DTO files contains Entity DTO, Parameter DTO, Result DTO.
  * Enums and interfaces.
  * ContextConstant if using Streaming Patterns.
* A short migration checklist (files added/changed) referencing @checklist_common_project.md`

## Usage (Cursor)

* Invoke from Agents palette or use trigger `"common"`.
* Example prompt:
  `Use ToCSharpCommon to convert VB DTOs in `/net4/**/Back/{ProgramName}*/**/*.vb` into DTOs under `/net6/**/COMMON/{ModuleName}/{ProgramName}Common/` following rules and patterns. ProgramName: ...`