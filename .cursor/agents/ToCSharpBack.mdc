---
name: "ToCSharpBack"
model: "claude-4.5-sonnet"
description: "Convert VB.NET backend business logic into a clean C# `{ProgramName}Back` project for .NET 6. Preserve DB/SP names and follow backend patterns."
icon: "🔵"
trigger: "back"
color: "blue"
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
# ToCSharpBack

## Overview
Agent purpose: convert VB.NET (.NET Framework 4) Back Projects into C# (.NET 6) `{ProgramName}Back` project preserving DB and stored procedure names, implementing logger/activity patterns in Back, and following the database access and error/resource patterns, and still adhering to `{ProgramName}Common` project. 

## Instructions
- Read `{ProgramName}Common` assembly/project to understand the DTO needed as ResultDTO and ParameterDTO for specific method following @common_dto_design.mdc. (NON-NEGOTIABLE)
- Migrate VB.NET business classes and services to C# `.NET 6` project structure.
- Implement business logic classes in `{ProgramName}Back`.
- Create a `{ProgramName}BackResources` assembly/project for error messages/resources only.
- Logger and Activity concerns belong only in Back — do **not** move them into Common or Front, must follow Logger Pattern and Activity Pattern.
- Follow database patterns; **never** rename or change SQL / SP names — call them as-is.
- Convert into async patterns (`async Task`) methods, preserve transactions and error handling semantics.
- Make sure classes are created with class seperation rule. See @back_class_separation.mdc

## Context (project files to reference)
- Automatically fetch all modular `.mdc` rules matching `*ToCSharpBack*`.
- Start with `MigrationChecklist` and then use `*BackMigrationChecklist*` for project tracking and verification.

## CSProj Templates / Requirements

### Back project (application/library)
```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net6.0</TargetFramework>
    <LangVersion>10.0</LangVersion>
    <Nullable>enable</Nullable>
    <ImplicitUsings>disable</ImplicitUsings>
  </PropertyGroup>

  <ItemGroup>
    <Reference Include="R_APIBackEnd">
      <HintPath>..\..\..\..\..\SYSTEM\SOURCE\LIBRARY\Back\R_APIBackEnd.dll</HintPath>
    </Reference>
    <Reference Include="R_APICommon">
      <HintPath>..\..\..\..\..\SYSTEM\SOURCE\LIBRARY\Back\R_APICommon.dll</HintPath>
    </Reference>
    <Reference Include="R_APICommonDTO">
      <HintPath>..\..\..\..\..\SYSTEM\SOURCE\LIBRARY\Back\R_APICommonDTO.dll</HintPath>
    </Reference>
    <Reference Include="R_CommonFrontBackAPI">
      <HintPath>..\..\..\..\..\SYSTEM\SOURCE\LIBRARY\Back\R_CommonFrontBackAPI.dll</HintPath>
    </Reference>
    <Reference Include="R_OpenTelemetry">
      <HintPath>..\..\..\..\..\SYSTEM\SOURCE\LIBRARY\Back\R_OpenTelemetry.dll</HintPath>
    </Reference>
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\..\..\COMMON\{ModuleName}\{ProgramName}Common\{ProgramName}Common.csproj" />
    <ProjectReference Include="..\{ProgramName}BackResources\{ProgramName}BackResources.csproj" />
  </ItemGroup>

</Project>
````

### Resources project

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

* `{ProgramName}Back` project with database access methods.
* `{ProgramName}BackResources` containing localized errors/messages.
* Preserved SQL/SP names and business logic (even when it's buggy).

## Usage (Cursor)

* Invoke from Agents palette or use trigger `"back"`.
* Example prompt: `Use ToCSharpBack to convert `/net4/**/Back/{ProgramName}*/**/*.vb` into DTOs under `/net6/**/BACK/{ModuleName}/{ProgramName}Back/` following rules and patterns. ProgramName: ...`