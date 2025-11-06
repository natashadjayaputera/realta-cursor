---
name: "ToCSharpViewModel"
model: "claude-4.5-sonnet"
description: "Convert VB.NET UI forms into C# ViewModels (part of Model project); ensure strict ViewModel conventions and inherit from R_ViewModel<T>."
icon: "🟣"
trigger: "viewmodel"
color: "purple"
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
# ToCSharpViewModel

## Overview
Agent purpose: create `{ProgramName}ViewModel` classes converted from VB.NET UI code and `{ProgramName}FrontResources` project. ViewModels belong in `VMs/` under the Model project and must follow strict rules (inherit `R_ViewModel<T>`, no `R_FrontGlobalVar`, `IClientHelper` only in Razor.cs, etc). Business logic, data operations and data validation only.

## Instructions
- Follow the plan generation from @plan_generation.mdc
- Create `{ProgramName}FrontResources` project.
- Place ViewModel classes under `VMs/` within the `{ProgramName}Model` project.
- Each ViewModel **MUST** inherit from `R_ViewModel<T>` where `T` is the entity/data object.
- Do not use `R_FrontGlobalVar` in ViewModels.
- `IClientHelper` is allowed only in `.razor.cs` (code-behind) — not in viewmodels.
- Store front-end data state in ViewModel; UI-only state may remain in Razor.cs.
- Use `R_FrontContext.R_SetStreamingContext()` for custom parameter DTOs in Streaming Patterns when calling model methods.
- Data Validation is allowed only in viewmodels — not in `.razor.cs` (code-behind)

## Context (project files to reference)
- Automatically fetch all modular `.mdc` rules matching `*ToCSharpViewModel*`.
- Start with `*MigrationChecklist*` and then use `*ViewModelMigrationChecklist*` for project tracking and verification.

## CSProj (Resources / Model snippet)

### Model Project (ADD Front Resource Reference)
```xml
  <ProjectReference Include="..\{ProgramName}FrontResources\{ProgramName}FrontResources.csproj" />
```

### Resources Project
```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>netstandard2.1</TargetFramework>
    <LangVersion>10.0</LangVersion>
    <Nullable>enable</Nullable>
    <ImplicitUsings>disable</ImplicitUsings>
  </PropertyGroup>

</Project>
```

## Outputs / Deliverables

* ViewModel classes saved to `/net6/**/FRONT/{ProgramName}Model/VMs/`
* `{ProgramName}FrontResources` project files
* Migration notes describing where Razor.cs vs ViewModel state lives

## Usage (Cursor)

* Invoke from Agents palette or use trigger `"viewmodel"`.
* Example prompt: `Convert WinForm OrderForm.vb to OrderViewModel.cs under /src/{ProgramName}Model/VMs/, inherit from R_ViewModel<OrderDTO>, and wire calls to OrderModel client. Follow viewmodel_rules.mdc.`

* Example prompt: `Use ToCSharpViewModel to convert each CRUD mode inside each pages in `/net4/**/Front/{ProgramName}*/**/*.vb` into each respective `/net6/**/FRONT/{ProgramName}Model/VMs/{PageName}ViewModel.cs` that use `/net6/**/FRONT/{ProgramName}Model/*Model.cs` to get the data needed for Front layer. ProgramName: ...`