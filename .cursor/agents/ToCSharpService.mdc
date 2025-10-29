---
name: "ToCSharpService"
model: "claude-4.5-sonnet"
description: "Convert VB.NET backend to `{ProgramName}Service` controllers and service layer (ASP.NET Core .NET 6)."
icon: "🩵"
trigger: "service"
color: "teal"
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
# ToCSharpService

## Overview
Agent purpose: produce  C# (.NET 6) `{ProgramName}Service` project (controllers / API layer) that implements Common interfaces and delegates to Back business logic. 

## Instructions
- Implement controller and service layer classes that correspond to Common interfaces.
- Implement method bodies to call business logic in `{ProgramName}Back`.
- Use `R_BackGlobalVar` to obtain `IClientHelper` where needed.
- Use streaming context for custom parameters as specified — adopt `R_Utility.R_GetStreamingContext()` conventions where applicable for streaming DTOs.
- Preserve authorization, routing, and expected signatures. Do not duplicate business logic; call Back.

## Context (project files to reference)
- Automatically fetch all modular `.mdc` rules matching `*ToCSharpService*`.
- Start with `*MigrationChecklist*` and then use `*ServiceMigrationChecklist*` for project tracking and verification.

## CSProj (Service project template)
```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net6.0</TargetFramework>
    <LangVersion>10.0</LangVersion>
    <Nullable>enable</Nullable>
    <ImplicitUsings>disable</ImplicitUsings>
  </PropertyGroup>

  <ItemGroup>
    <FrameworkReference Include="Microsoft.AspNetCore.App" />
  </ItemGroup>

  <ItemGroup>
    <Reference Include="R_APIBackEnd">
      <HintPath>..\..\..\..\..\SYSTEM\SOURCE\LIBRARY\Back\R_APIBackEnd.dll</HintPath>
    </Reference>
    <Reference Include="R_APICommon">
      <HintPath>..\..\..\..\..\SYSTEM\SOURCE\LIBRARY\Back\R_APICommon.dll</HintPath>
    </Reference>
    <Reference Include="R_APIStartUp">
      <HintPath>..\..\..\..\..\SYSTEM\SOURCE\LIBRARY\Back\R_APIStartUp.dll</HintPath>
    </Reference>
    <Reference Include="R_CommonFrontBackAPI">
      <HintPath>..\..\..\..\..\SYSTEM\SOURCE\LIBRARY\Back\R_CommonFrontBackAPI.dll</HintPath>
    </Reference>
    <Reference Include="R_OpenTelemetry">
      <HintPath>..\..\..\..\..\SYSTEM\SOURCE\LIBRARY\Back\R_OpenTelemetry.dll</HintPath>
    </Reference>
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\..\..\BACK\{module}\{ProgramName}Back\{ProgramName}Back.csproj" />
    <ProjectReference Include="..\..\..\COMMON\{module}\{ProgramName}Common\{ProgramName}Common.csproj" />
  </ItemGroup>
</Project>
```

## Outputs / Deliverables

* `{ProgramName}Service` controllers that implement Common interfaces.

## Usage (Cursor)

* Invoke from Agents palette or use trigger `"service"`.
* Example prompt: `Use ToCSharpService to implement Common interfaces as controllers in `/net6/**/SERVICE/{ModuleName}/{ProgramName}Service/` following rules and patterns, calling the Back project for business logic. ProgramName: ...`