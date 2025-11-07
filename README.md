# Folder Guide

[`net4`](net4) — folder for .NET 4 Program Samples.
[`net6`](net6) — folder for .NET 6 Program Samples.

# Prompt Guide

To migrate, use this prompt with mode **PLAN**
Read ['Agents'](.cursor/agents/) - contains **ALL Agents** used to migrate

## Common
Example prompt: 
- type `/ToCSharpCommon` (custom commands)
- copy `convert VB DTOs in `/net4/**/Back/{ProgramName}*/**/*.vb` into DTOs under `/net6/**/COMMON/{ModuleName}/{ProgramName}Common/` following rules and patterns defined in `.cursor/rules`. ProgramName: ...`

## Back
Example prompt: 
- type `/ToCSharpBack` (custom commands)
- copy `convert `/net4/**/Back/{ProgramName}*/**/*.vb` into Back and Back Resources Project under `/net6/**/BACK/{ModuleName}/{ProgramName}Back/` following rules and patterns defined in `.cursor/rules`. ProgramName: ...`

## Service
Example prompt: 
- type `/ToCSharpService` (custom commands)
- copy `implement Common interfaces as controllers in `/net6/**/SERVICE/{ModuleName}/{ProgramName}Service/` following rules and patterns defined in `.cursor/rules`, calling the Back project for business logic. ProgramName: ...`

## Model
Example prompt: 
- type `/ToCSharpModel` (custom commands)
- copy `create service-layer clients for `/net6/**/SERVICE/{ModuleName}/{ProgramName}Service/*Controller.cs` signatures into `/net6/**/FRONT/{ProgramName}Model/*Model.cs` following rules and patterns defined in `.cursor/rules`. ProgramName: ...`

## ViewModel
Example prompt: 
- type `/ToCSharpViewModel` (custom commands)
- copy `convert each CRUD mode inside each pages in `/net4/**/Front/{ProgramName}*/**/*.vb` into each respective `/net6/**/FRONT/{ProgramName}Model/VMs/{PageName}ViewModel.cs` that use `/net6/**/FRONT/{ProgramName}Model/*Model.cs` to get the data needed for Front layer. ProgramName: ...`

## Front
Example prompt: 
- type `/ToCSharpFront` (custom commands)
- copy `convert {ProgramName} .NET4 VB Forms to {ProgramName} Blazor components. Before starting the conversion, load and apply the migration-patterns. While analyzing the .NET4 source files, detect any conflicts or deviations from the migration-patterns. If conflicts are found, dynamically update and adjust the migration plan to fully comply with the migration-patterns before proceeding with code generation. ProgramName: ... and start with page: ...`

## ValidationAndBuild
Example prompt: 
- type `/ValidationAndBuild` (custom commands)
- copy `validate and build `/net6/**/{ProgramName}*.csproj` following `*MigrationChecklist*`. Run builds and return BUILD SUMMARY reports for All projects. ProgramName: ...`

## SolutionManager
Example prompt: 
- type `/SolutionManager`
- copy `add ...`

## Front Component NET4 to NET6 Migration Patterns
Example Prompt:
```md
Create migration pattern rules for {ComponentName} and put it inside `.cursor/rules/front/components/migration-patterns/ with file name `{ComponentName.toLowerCase}`.
Find migration example from `/net4/**/Front/**/*.vb` to `/net6/**/FRONT/**/*`.
If you cannot find any example, infer it from `.cursor/docs/net4` and `.cursor/docs/net6`
ComponentName: `...`.
Do not include project file references only include documentation references.
Keep rules under 60 lines.
Follow this style exactly ...
```