---
name: "ToCSharpModel"
model: "claude-4.5-sonnet"
description: "Generate the `{ProgramName}Model` layer based on existing Service project interfaces. Produces service-layer client implementations targeting netstandard2.1."
icon: "🟣"
trigger: "model"
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
# ToCSharpModel

## Overview
Agent purpose: generate C# (.NET 6) `{ProgramName}Model` project, which provides lightweight service-layer client classes based on the existing Service project and Common interfaces. The Model layer targets `netstandard2.1` and is designed for ViewModel layer consumption.  

## Instructions
- Follow the plan generation from @plan_generation.mdc
- Add a `{ProgramName}Model` project that implements service client classes using the signatures defined in Common interfaces.
- Keep Models thin: **no business/domain logic** that belongs in Back.
- Reference required DLLs and use standard project template below.

## Context (project files to reference)
- Automatically fetch all modular `.mdc` rules matching `*ToCSharpModel*`.
- Start with `*MigrationChecklist*` and then use `*ModelMigrationChecklist*` for project tracking and verification.

## CSProj (Model project template)
```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>netstandard2.1</TargetFramework>
    <LangVersion>10.0</LangVersion>
    <Nullable>enable</Nullable>
    <ImplicitUsings>disable</ImplicitUsings>
  </PropertyGroup>

  <ItemGroup>
    <Reference Include="R_APIClient">
        <HintPath>..\..\..\SYSTEM\SOURCE\LIBRARY\Front\R_APIClient.dll</HintPath>
    </Reference>
    <Reference Include="R_APICommonDTO">
        <HintPath>..\..\..\SYSTEM\SOURCE\LIBRARY\Front\R_APICommonDTO.dll</HintPath>
    </Reference>
    <Reference Include="R_BusinessObjectFront">
        <HintPath>..\..\..\SYSTEM\SOURCE\LIBRARY\Front\R_BusinessObjectFront.dll</HintPath>
    </Reference>
    <Reference Include="R_CommonFrontBackAPI">
        <HintPath>..\..\..\SYSTEM\SOURCE\LIBRARY\Front\R_CommonFrontBackAPI.dll</HintPath>
    </Reference>
    <Reference Include="R_BlazorFrontEnd">
        <HintPath>..\..\..\SYSTEM\SOURCE\LIBRARY\Front\R_BlazorFrontEnd.dll</HintPath>
    </Reference>
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\..\COMMON\{module}\{ProgramName}Common\{ProgramName}Common.csproj" />
  </ItemGroup>

</Project>
```

## Outputs / Deliverables

* `{ProgramName}Model` project.

## Usage (Cursor)

* Invoke from Agents palette or use trigger `"model"`.
* Example prompt: `Use ToCSharpModel to create service-layer clients for `/net6/**/SERVICE/{ModuleName}/{ProgramName}Service/*Controller.cs` signatures into `/net6/**/FRONT/{ProgramName}Model/*Model.cs` following rules and patterns. ProgramName: ...`