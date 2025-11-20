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
Here’s a **chronologically and logically ordered** version of your instructions, keeping your original intent intact but improving flow and clarity:

---

## Instructions
1. Follow the plan generation from @plan_generation.mdc
2. **Create the `{ProgramName}Common` project**
   * Follow the `.csproj` structure provided below.
   * Maintain consistent naming according to project conventions (see `@core_variable_naming_rules.mdc`).
3. **Extract all methods from the `{ProgramName}Back` project**
   * For each method, create both a **ParameterDTO** and a **ResultDTO**.
   * **Do not use Stream DTOs** under any circumstances.
   * **Do not reuse EntityDTOs** — every method must have its own dedicated DTOs.
4. **Create Generic Result DTO** 
   * {ProgramName}ResultDTO — Must inherit `R_APIResultBaseDTO` (see `@common_generic_result_dto_pattern.mdc`).
5. **Place all DTOs, enums, and interfaces** inside the `{ProgramName}Common` project.
   * Keep this project strictly for shared contracts and types.
   * **Do not** include or move any business logic here.
6. **Define interfaces for service contracts**
   * Interfaces must inherit or implement `R_IServiceCRUDAsyncBase` where applicable.
   * For each CRUD pattern in the `{ProgramName}Back` project, create a corresponding interface that inherits
     `R_IServiceCRUDAsyncBase<{ProgramName}DTO>` and uses its own dedicated `EntityDTO` (`{ProgramName}DTO`).
7. **Convert existing VB.NET DTOs and related types**
   * Rewrite them into modern C# (C# 10, nullable enabled).
   * Ensure code style and syntax follow C# best practices and project conventions.

## Context (project files to reference)
- Automatically fetch all modular `.mdc` rules matching `*ToCSharpCommon*`.
- Start with `*MigrationChecklist*` and then use `*CommonMigrationChecklist*` for project tracking and verification.
- Follow the plan generation from @plan_generation.mdc

## CSProj (project settings — keep as project template)
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

## Usage (Cursor)

* Type `/ToCSharpCommon` (custom commands)
* Copy: `convert VB DTOs in `/net4/**/Back/{ProgramName}*/**/*.vb` into DTOs under `/net6/**/COMMON/{ModuleName}/{ProgramName}Common/` following rules and patterns defined in `.cursor/rules`. ProgramName: ...`