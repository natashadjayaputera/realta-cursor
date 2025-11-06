---
name: "ToCSharpFront"
model: "claude-4.5-sonnet"
description: "Convert VB.NET WinForms/WPF front-end into modern C# Blazor front-end projects `{ProgramName}.razor` / `{ProgramName}.razor.cs` (.NET 6)."
icon: "🟣"
trigger: "front"
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
# ToCSharpFront

## Instructions
1. List all program names from NET4 VB files in `/net4/**/Front/{ProgramName}*/**/*.vb` (extract program names from file paths/filenames, e.g., `FAB00200` from `FAB00200.vb`).
2. Ask user to select which program name to convert.
3. Read the chosen `{ProgramName}.vb` file and analyze it to find all referenced program names (e.g., from `R_RunForm`, `R_PopUp`, etc.).
4. For each referenced program name found in step 3:
   - Extract the first 6 characters of the chosen program name (e.g., `FAM00100` → `FAM001`).
   - Check if the referenced program name starts with the same 6-character prefix.
   - **If matches** (e.g., `FAM0010001` or `FAM00110` start with `FAM001`): Create an empty partial class `public partial class {ReferencedProgramName} : R_Page { }` in the appropriate location so it can be referenced.
   - **If doesn't match** (e.g., `GSL00100` doesn't start with `FAM001`): Add a `// TODO: implement navigation to {ReferencedProgramName} manually` comment instead.
5. Read the chosen `{ProgramName}.vb` file and analyze it to determine which ViewModel is needed (e.g., find corresponding `{ProgramName}ViewModel.cs` in `/net6/**/FRONT/{ProgramName}Model/VMs/`).
6. Read the identified ViewModel file if it exists (if not, inform user that ViewModel needs to be created first).
7. Scan the VB file to identify which NET4 components/patterns are used (e.g., R_LookUp, R_Conductor, R_FormBase, etc.).
8. Fetch migration-patterns from `.cursor/rules/front/components/migration-patterns/` only for components found (see Context section for fetch strategy).
9. Fetch specific component rules `.cursor/rules/front/components/net6/` when net6 component is used without migration.
10. Fetch documentation from `.cursor/docs/net6` only when needed for specific component API details.
11. Convert the VB file to `{ProgramName}.razor` and `{ProgramName}.razor.cs` following the migration-patterns exactly.

**Rules:**
- Follow migration-pattern files exactly - always fetch pattern file first, never guess.
- Create layout based on provided image.
- Use `R_BlazorFrontEnd.Controls` components (fetch docs from `.cursor/docs/net6` only when needed).
- **Dependency Injection (MANDATORY - Follow EXACTLY)**: 
  - ALL `[Inject]` attributes MUST be in `.razor.cs` code-behind files, NEVER in `.razor` files.
  - NEVER use `@inject` directives in `.razor` files.
  - Inject `IClientHelper ClientHelper` in `.razor.cs` code-behind only, **NOT** in ViewModel.
  - Inject `R_ILocalizer Localizer` in `.razor.cs` code-behind only, **NOT** in `.razor` file.
  - Inject `R_MessageBoxService MessageBoxService` in `.razor.cs` code-behind only, **NOT** in `.razor` file.
  - All injected services follow the pattern: `[Inject] private IType PropertyName { get; set; } = default!;`
  - This is a strict rule - see `@front_dependency_injection.mdc` for examples.
- UI state in `.razor.cs`; ViewModel contains only non-UI state.
- Data validation only in ViewModel, not in `.razor.cs`.
- Work one program at a time - ask user before proceeding to next.
- If ViewModel doesn't exist for the chosen program, inform user it needs to be created first via ToCSharpViewModel agent.
- **Program Reference Handling**: For referenced program names found in VB file (from `R_RunForm`, `R_PopUp`, etc.):
  - Extract first 6 characters of chosen program name (e.g., `FAM00100` → `FAM001`).
  - If referenced program starts with same 6-character prefix (e.g., `FAM0010001`, `FAM00110`): Create empty partial class `public partial class {ReferencedProgramName} : R_Page { }` so it can be referenced.
  - If referenced program doesn't match prefix (e.g., `GSL00100`): Add `// TODO: implement navigation to {ReferencedProgramName} manually` comment instead.
- **Using Statements (MANDATORY - Follow EXACTLY)**: 
  - ALL `@using` statements MUST be in `_Imports.razor` file, NEVER in `.razor` files. This is a strict rule - see `@front_imports_and_usings.mdc`.
  - Use the EXACT minimal required using statements list for `_Imports.razor` (see _Imports.razor section below).
  - Use the EXACT minimal required using statements list for `.razor.cs` files (see .razor.cs Using Statements section below).
  - These rules must be followed EXACTLY as specified in `@front_imports_and_usings.mdc` and `@front_razor_cs_using_statements.mdc`.
- Do **NOT** fix error, just build and give warnings and errors reports. See @build_report_format.mdc.

## Context (Fetch On-Demand Only)
- **Migration-Patterns**: `.cursor/rules/front/components/migration-patterns/` - Fetch only patterns for components found in VB file (e.g., `R_LookUp` → `r_lookup.mdc`, `R_FormBase` → `r_formbase.mdc`). Pattern naming: `{componentname}.mdc`.
- **Specific Component Rules**: `.cursor/rules/front/components/net6/` - Fetch only rules for components used in plan but is used without migration (e.g., `R_Page` → `r_page.mdc`, `R_Label` → `r_label.mdc`). Pattern naming: `{componentname}.mdc`.
- **Documentation**: `.cursor/docs/net6` - Fetch only when you need specific component API details.
- **Rules**: Fetch `.mdc` rules matching `*ToCSharpFront*` only when needed.
- **Checklists**: Fetch `*MigrationChecklist*` / `*FrontMigrationChecklist*` only at the end for verification.

## CSProj (Front project requirements)
```xml
<Project Sdk="Microsoft.NET.Sdk.Razor">
	<PropertyGroup>
		<TargetFramework>net6.0</TargetFramework>
		<LangVersion>10.0</LangVersion>
		<Nullable>enable</Nullable>
		<ImplicitUsings>disable</ImplicitUsings>
	</PropertyGroup>

	<ItemGroup>
		<SupportedPlatform Include="browser" />
	</ItemGroup>

	<ItemGroup>
		<PackageReference Include="Microsoft.AspNetCore.Components.Web" Version="6.0.36" />
	</ItemGroup>

	<ItemGroup>
		<Reference Include="R_APICommonDTO">
			<HintPath>..\..\..\..\SYSTEM\SOURCE\LIBRARY\Front\R_APICommonDTO.dll</HintPath>
		</Reference>
		<Reference Include="R_CommonFrontBackAPI">
			<HintPath>..\..\..\..\SYSTEM\SOURCE\LIBRARY\Front\R_CommonFrontBackAPI.dll</HintPath>
		</Reference>
		<Reference Include="R_BlazorFrontEnd">
			<HintPath>..\..\..\..\SYSTEM\SOURCE\LIBRARY\Front\R_BlazorFrontEnd.dll</HintPath>
		</Reference>
		<Reference Include="R_BlazorFrontEnd.Controls">
			<HintPath>..\..\..\..\SYSTEM\SOURCE\LIBRARY\Front\R_BlazorFrontEnd.Controls.dll</HintPath>
		</Reference>
		<Reference Include="BlazorClientHelper">
			<HintPath>..\..\..\..\SYSTEM\SOURCE\LIBRARY\Menu\BlazorClientHelper.dll</HintPath>
		</Reference>
		<Reference Include="R_LockingFront">
      <HintPath>..\..\..\..\SYSTEM\SOURCE\LIBRARY\Front\R_LockingFront.dll</HintPath>
    </Reference>
	</ItemGroup>

	<ItemGroup>
		<ProjectReference Include="..\{ProgramName}Model\{ProgramName}Model.csproj" />
		<ProjectReference Include="..\{ProgramName}FrontResources\{ProgramName}FrontResources.csproj" />
	</ItemGroup>
</Project>
```

## Outputs / Deliverables

* `.razor` and `.razor.cs` files per UI screen, following `front_patterns.mdc`.
* Component library usage updated to `R_BlazorFrontEnd*`.
* Migration notes describing lifecycle and binding changes.

## Usage (Cursor)

* Invoke from Agents palette or use trigger `"front"`.
* **Example prompt**: `Use ToCSharpFront to convert {ProgramName} NET4 VB forms to {ProgramName} Blazor components. Follow the layout in the image provided. ProgramName: ...`