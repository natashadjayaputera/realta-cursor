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

Here’s a **chronologically corrected and clarified version** of your Cursor custom command instructions — keeping all your rules intact but ordering them logically for workflow and clarity:

---

## Instructions

1. Follow the plan generation from @plan_generation.mdc
2. **Understand Common DTOs**
   * Read the `{ProgramName}Common` project to understand the required `ResultDTO` and `ParameterDTO` for each method.
   * Follow the design standard in **@common_dto_design.mdc**.
   * ⚠️ *This is non-negotiable.*
3. **Plan the Migration**
   * Migrate existing VB.NET business classes and services into a **C# .NET 6** project structure.
   * Ensure the new structure aligns with the `{ProgramName}` solution layout (`Common`, `Back`, `Service`, etc.).
4. **Implement Business Logic**
   * Implement all business logic classes inside the `{ProgramName}Back` project.
   * Follow the **class separation rule** strictly (see **@back_class_separation.mdc**).
   * This is the **most important rule**.
5. **Project Responsibilities**
   * Create a `{ProgramName}BackResources` project dedicated **only** for error messages and resource strings.
   * Keep **Logger** and **Activity** handling **only** within the Back project — never move them into Common or Front.
   * Must follow the **Logger Pattern** and **Activity Pattern**.
6. **Database Rules**
   * Follow existing database access patterns.
   * **Never rename or modify SQL or stored procedure names** — always call them *as-is*.
7. **Asynchronous Implementation**
   * Convert all methods into `async Task` patterns where applicable.
   * Preserve existing **transaction** handling and **error semantics** during migration.
   * Streaming method must follow this rule **@back_streaming_method_pattern.mdc**
8. **Interface**
   * Interfaces defined in `{ProgramName}Common` are **not** to be implemented in Back classes — they are meant for the Service project.
9. **{ProgramName}Cls.cs**
   * Do **not** directly access `R_BackGlobalVar` or `R_Utility.R_GetStreamingContext` inside methods in Back classes. 
   * These values must be **passed from the Controller** in the Service project to the Back class using **{MethodName}ParameterDTO**.
   * **This is non-negotiable**

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

* Type `/ToCSharpBack` (custom commands)
* Copy: `convert `/net4/**/Back/{ProgramName}*/**/*.vb` into Back and Back Resources Project under `/net6/**/BACK/{ModuleName}/{ProgramName}Back/` following rules and patterns defined in `.cursor/rules`. ProgramName: ...`