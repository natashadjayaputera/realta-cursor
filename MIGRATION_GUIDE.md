# Cursor Migration Guide: .NET 4 to .NET 6

## Table of Contents

1. [Introduction and Architecture Overview](#introduction-and-architecture-overview)
2. [Prerequisites and Setup](#prerequisites-and-setup)
3. [Migration Workflow (Step-by-Step)](#migration-workflow-step-by-step)
4. [Agent Reference Guide](#agent-reference-guide)
5. [Best Practices and Tips](#best-practices-and-tips)
6. [Troubleshooting Common Issues](#troubleshooting-common-issues)
7. [Validation and Quality Assurance](#validation-and-quality-assurance)

---

## Introduction and Architecture Overview

### What is This Guide?

This guide explains how to use Cursor's AI-powered agents to systematically migrate VB.NET (.NET Framework 4) applications to modern C# (.NET 6) applications. The migration follows a structured, layer-by-layer approach that preserves business logic while modernizing the codebase.

### Migration Architecture

The migration follows a **layered architecture** where each layer is migrated in a specific order:

```
┌─────────────────────────────────────────────────────────┐
│  Layer 1: Common (DTOs, Interfaces, Enums)               │
│  ─────────────────────────────────────────────────────  │
│  Layer 2: Back (Business Logic + Resources)             │
│  ─────────────────────────────────────────────────────  │
│  Layer 3: Service (API Controllers)                    │
│  ─────────────────────────────────────────────────────  │
│  Layer 4: Model (Service Clients)                      │
│  ─────────────────────────────────────────────────────  │
│  Layer 5: ViewModel (Data State Management)             │
│  ─────────────────────────────────────────────────────  │
│  Layer 6: Front (Blazor Components)                    │
│  ─────────────────────────────────────────────────────  │
│  Layer 7: Solution Integration                         │
└─────────────────────────────────────────────────────────┘
```

### Project Structure

After migration, your projects will be organized as follows:

```
net6/RSF/BIMASAKTI_11/1.00/PROGRAM/BS Program/SOURCE/
├── COMMON/{Module}/{ProgramName}Common/          # DTOs, Interfaces, Enums
├── BACK/{Module}/{ProgramName}Back/              # Business Logic
├── BACK/{Module}/{ProgramName}BackResources/      # Error Messages
├── SERVICE/{Module}/{ProgramName}Service/          # API Controllers
├── FRONT/{ProgramName}Model/                     # Service Clients
├── FRONT/{ProgramName}FrontResources/             # UI Labels
└── FRONT/{ProgramName}Front/                      # Blazor Components
```

### Key Principles

1. **Business Logic Preservation**: Never modify SQL queries, stored procedure names, or business calculations. Replicate VB.NET logic exactly, even if it contains bugs.

2. **Error Handling**: Always use the standardized `R_Exception` pattern with resource-based error messages.

3. **Layer Separation**: Each layer has strict responsibilities:
   - **Common**: Only DTOs, interfaces, and enums (no business logic)
   - **Back**: Business logic, logging, and database access
   - **Service**: API controllers that delegate to Back
   - **Model**: Thin service clients for ViewModels
   - **ViewModel**: Data state and validation (no UI logic)
   - **Front**: UI components and presentation logic

4. **Variable Naming**: Follow strict naming conventions with type prefixes (e.g., `lcName` for string, `liCount` for int).

---

## Prerequisites and Setup

### Required Folder Structure

Ensure you have the following directory structure:

```
_Cursor/
├── .cursor/                 # Cursor configuration
│   ├── commands/            # Agent definitions
│   ├── rules/               # Migration rules and patterns
│   └── docs/                # Documentation references
├── net4/                    # Source VB.NET code (.NET Framework 4)
│   └── {Module}/            # Module folders (FA, GS, SA, etc.)
│       └── Development/
│           ├── Back/        # Backend VB.NET code
│           └── Front/       # Frontend VB.NET code
├── net6/                    # Target C# code (.NET 6)
│   └── RSF/BIMASAKTI_11/1.00/PROGRAM/BS Program/SOURCE/
│       ├── COMMON/          # Common projects
│       ├── BACK/            # Back projects
│       ├── SERVICE/         # Service projects
│       └── FRONT/           # Front projects
└── plan/                    # Migration plans (auto-generated)
```

### Library Setup

Before starting migration, ensure libraries are up to date:

1. **Update Libraries**: Run `update_all_git_repos.bat` to update library files
2. **Copy Libraries**: Run `copy_realta_blazor_library.bat` to copy DLLs to working folder
3. **Clean Build Folders**: Run `clean_build_folder.bat` if needed

### Understanding Source Code Location

- **NET4 Source**: Located in `net4/{Module}/Development/`
  - Back code: `net4/{Module}/Development/Back/{ProgramName}*/**/*.vb`
  - Front code: `net4/{Module}/Development/Front/{ProgramName}*/**/*.vb`

- **NET6 Target**: Located in `net6/RSF/BIMASAKTI_11/1.00/PROGRAM/BS Program/SOURCE/`
  - Organized by layer: `COMMON/`, `BACK/`, `SERVICE/`, `FRONT/`

### Cursor Configuration

Cursor is pre-configured with:
- **Agents**: Custom commands for each migration layer
- **Rules**: Migration patterns and validation rules
- **Documentation**: Reference docs for NET4 and NET6 libraries

---

## Migration Workflow (Step-by-Step)

### Overview

The migration process follows a strict sequence. **Do not skip steps** or migrate layers out of order, as each layer depends on the previous one.

### Step 1: Common Layer (DTOs, Interfaces, Enums)

**Purpose**: Create shared contracts (DTOs, interfaces, enums) that will be used across all layers.

**Agent**: `ToCSharpCommon` (trigger: `common`)

**What Gets Migrated**:
- Entity DTOs (data transfer objects)
- Parameter DTOs (method input parameters)
- Result DTOs (method return values)
- Stream DTOs (for streaming operations)
- Interfaces (service contracts)
- Enums (enumerations)

**Example Prompt**:
- Type `/ToCSharpCommon` (custom commands)
- Copy: `convert VB DTOs in `/net4/**/Back/{ProgramName}*/**/*.vb` into DTOs under `/net6/**/COMMON/{ModuleName}/{ProgramName}Common/` following rules and patterns defined in `.cursor/rules`. ProgramName: FAM00500`

**Key Rules**:
- No business logic in Common layer
- Each method must have its own ParameterDTO and ResultDTO (never reuse EntityDTO)
- Interfaces must inherit `R_IServiceCRUDAsyncBase` where applicable
- All DTOs use `string.Empty` for string defaults
- DateTime properties are NOT nullable

**Output**: `{ProgramName}Common` project with DTOs and interfaces

---

### Step 2: Back Layer (Business Logic)

**Purpose**: Convert business logic from VB.NET to C# while preserving all database operations and calculations.

**Agent**: `ToCSharpBack` (trigger: `back`)

**What Gets Migrated**:
- Business logic classes
- Database access methods
- Logger and Activity classes
- Error messages (to BackResources project)

**Example Prompt**:
- Type `/ToCSharpBack` (custom commands)
- Copy: `convert `/net4/**/Back/{ProgramName}*/**/*.vb` into Back and Back Resources Project under `/net6/**/BACK/{ModuleName}/{ProgramName}Back/` following rules and patterns defined in `.cursor/rules`. ProgramName: FAM00500`

**Key Rules**:
- **Never rename SQL queries or stored procedures**
- Preserve all business logic exactly (even bugs)
- Implement Logger and Activity patterns
- Create separate `{ProgramName}BackResources` project for error messages
- Use `R_Exception` pattern for all error handling
- All methods must be async (`async Task`)

**Output**: 
- `{ProgramName}Back` project (business logic)
- `{ProgramName}BackResources` project (error messages)

---

### Step 3: Service Layer (API Controllers)

**Purpose**: Create ASP.NET Core API controllers that implement Common interfaces and delegate to Back business logic.

**Agent**: `ToCSharpService` (trigger: `service`)

**What Gets Migrated**:
- API controllers
- HTTP endpoints
- Authorization and routing

**Example Prompt**:
- Type `/ToCSharpService` (custom commands)
- Copy: `implement Common interfaces as controllers in `/net6/**/SERVICE/{ModuleName}/{ProgramName}Service/` following rules and patterns defined in `.cursor/rules`, calling the Back project for business logic. ProgramName: FAM00500`

**Key Rules**:
- Controllers implement interfaces from Common layer
- Controllers delegate to Back classes (no business logic in controllers)
- Use `R_BackGlobalVar` for `IClientHelper` access
- Handle streaming context for custom parameters
- Preserve authorization and routing patterns

**Output**: `{ProgramName}Service` project with API controllers

---

### Step 4: Model Layer (Service Clients)

**Purpose**: Create lightweight service client classes that ViewModels will use to call the API.

**Agent**: `ToCSharpModel` (trigger: `model`)

**What Gets Migrated**:
- Service client classes
- HTTP client wrappers

**Example Prompt**:
- Type `/ToCSharpModel` (custom commands)
- Copy: `create service-layer clients for `/net6/**/SERVICE/{ModuleName}/{ProgramName}Service/*Controller.cs` signatures into `/net6/**/FRONT/{ProgramName}Model/*Model.cs` following rules and patterns defined in `.cursor/rules`. ProgramName: FAM00500`

**Key Rules**:
- Models are thin wrappers (no business logic)
- Models use HTTP client to call Service layer
- Models reference Common project for DTOs

**Output**: `{ProgramName}Model` project with service clients

---

### Step 5: ViewModel Layer (Data State Management)

**Purpose**: Convert UI logic from VB.NET forms into ViewModels that manage data state and validation.

**Agent**: `ToCSharpViewModel` (trigger: `viewmodel`)

**What Gets Migrated**:
- ViewModel classes (in `VMs/` folder under Model project)
- FrontResources project (UI labels and messages)

**Example Prompt**:
- Type `/ToCSharpViewModel` (custom commands)
- Copy: `convert each CRUD mode inside each pages in `/net4/**/Front/{ProgramName}*/**/*.vb` into each respective `/net6/**/FRONT/{ProgramName}Model/VMs/{PageName}ViewModel.cs` that use `/net6/**/FRONT/{ProgramName}Model/*Model.cs` to get the data needed for Front layer. ProgramName: FAM00500`

**Key Rules**:
- ViewModels MUST inherit from `R_ViewModel<T>`
- **Never use `R_FrontGlobalVar` in ViewModels**
- `IClientHelper` is only allowed in `.razor.cs` (code-behind), not in ViewModels
- Data state goes in ViewModel; UI-only state stays in Razor.cs
- Data validation is ONLY in ViewModels, not in code-behind
- One CRUD entity per ViewModel

**Output**: 
- ViewModel classes in `{ProgramName}Model/VMs/`
- `{ProgramName}FrontResources` project (UI labels)

---

### Step 6: Front Layer (Blazor Components)

**Purpose**: Convert VB.NET WinForms/WPF UI into modern Blazor components.

**Agent**: `ToCSharpFront` (trigger: `front`)

**What Gets Migrated**:
- `.razor` files (UI markup)
- `.razor.cs` files (code-behind)
- Component bindings and event handlers

**Example Prompt**:
- Type `/ToCSharpFront` (custom commands)
- Copy: `convert {ProgramName} .NET4 VB Forms to {ProgramName} Blazor components. Before starting the conversion, load and apply the migration-patterns. While analyzing the .NET4 source files, detect any conflicts or deviations from the migration-patterns. If conflicts are found, dynamically update and adjust the migration plan to fully comply with the migration-patterns before proceeding with code generation. ProgramName: FAM00500 and start with page: FAM00500`

**Key Rules**:
- **ALL `[Inject]` attributes MUST be in `.razor.cs` files, NEVER in `.razor` files**
- **ALL `@using` statements MUST be in `_Imports.razor`, NEVER in `.razor` files**
- UI state in `.razor.cs`; data state in ViewModel
- Follow migration patterns exactly (fetch from `.cursor/rules/front/components/migration-patterns/`)
- Work one program at a time

**Output**: 
- `{ProgramName}.razor` files (UI markup)
- `{ProgramName}.razor.cs` files (code-behind)
- `_Imports.razor` file (using statements)

---

### Step 7: Solution Integration

**Purpose**: Add migrated projects to Visual Studio solutions and integrate with API and BlazorMenu.

**Agent**: `SolutionManager` (trigger: `solution`)

**What Gets Migrated**:
- Solution file entries
- Project references in API projects
- BlazorMenu integration

**Example Prompt**:
- Type `/SolutionManager` (custom commands)
- Copy: `add {ProgramName}. ProgramName: FAM00500`

**Key Rules**:
- Add backend projects to `BIMASAKTI11_BACK.sln`
- Add frontend projects to `BIMASAKTI11_FRONT.sln`
- Add Service project reference to module API project (e.g., `BIMASAKTI_FA_API.csproj`)
- Add Front project reference to `BlazorMenu.csproj`
- Add assembly entry to `BlazorMenu/App.razor` for lazy loading
- Maintain alphabetical ordering in all references

**Output**: 
- Updated solution files
- Updated API project references
- Updated BlazorMenu integration

---

## Agent Reference Guide

### ToCSharpCommon

**Purpose**: Convert VB.NET DTOs, enums, and interfaces into C# Common project.

**When to Use**: First step of migration (before any other layer).

**Trigger**: Type `/ToCSharpCommon` or use trigger `"common"`

**Input**: VB.NET DTO files from `net4/**/Back/{ProgramName}*/**/*.vb`

**Output**: `{ProgramName}Common` project with:
- Entity DTOs
- Parameter DTOs
- Result DTOs
- Stream DTOs
- Interfaces
- Enums

**Example Prompt**:
- Type `/ToCSharpCommon` (custom commands)
- Copy: `convert VB DTOs in `/net4/**/Back/{ProgramName}*/**/*.vb` into DTOs under `/net6/**/COMMON/{ModuleName}/{ProgramName}Common/` following rules and patterns defined in `.cursor/rules`. ProgramName: FAM00500`

**Key Features**:
- Automatically fetches Common layer rules
- Validates DTO structure
- Generates interfaces inheriting `R_IServiceCRUDAsyncBase`
- Creates plan and saves to `/plan/` directory

---

### ToCSharpBack

**Purpose**: Convert VB.NET business logic into C# Back project with logging and activity patterns.

**When to Use**: After Common layer is complete.

**Trigger**: Type `/ToCSharpBack` or use trigger `"back"`

**Input**: VB.NET business logic files from `net4/**/Back/{ProgramName}*/**/*.vb`

**Output**: 
- `{ProgramName}Back` project (business logic)
- `{ProgramName}BackResources` project (error messages)

**Example Prompt**:
- Type `/ToCSharpBack` (custom commands)
- Copy: `convert `/net4/**/Back/{ProgramName}*/**/*.vb` into Back and Back Resources Project under `/net6/**/BACK/{ModuleName}/{ProgramName}Back/` following rules and patterns defined in `.cursor/rules`. ProgramName: FAM00500`

**Key Features**:
- Preserves SQL queries and stored procedure names
- Implements Logger and Activity patterns
- Creates separate Resources project
- Uses `R_Exception` error handling pattern
- Validates against Back layer rules

---

### ToCSharpService

**Purpose**: Create ASP.NET Core API controllers that implement Common interfaces.

**When to Use**: After Back layer is complete.

**Trigger**: Type `/ToCSharpService` or use trigger `"service"`

**Input**: Common interfaces from `{ProgramName}Common` project

**Output**: `{ProgramName}Service` project with API controllers

**Example Prompt**:
- Type `/ToCSharpService` (custom commands)
- Copy: `implement Common interfaces as controllers in `/net6/**/SERVICE/{ModuleName}/{ProgramName}Service/` following rules and patterns defined in `.cursor/rules`, calling the Back project for business logic. ProgramName: FAM00500`

**Key Features**:
- Implements Common interfaces
- Delegates to Back classes
- Handles streaming context
- Preserves authorization and routing

---

### ToCSharpModel

**Purpose**: Create service client classes for ViewModels to call the API.

**When to Use**: After Service layer is complete.

**Trigger**: Type `/ToCSharpModel` or use trigger `"model"`

**Input**: Service controller signatures from `{ProgramName}Service` project

**Output**: `{ProgramName}Model` project with service clients

**Example Prompt**:
- Type `/ToCSharpModel` (custom commands)
- Copy: `create service-layer clients for `/net6/**/SERVICE/{ModuleName}/{ProgramName}Service/*Controller.cs` signatures into `/net6/**/FRONT/{ProgramName}Model/*Model.cs` following rules and patterns defined in `.cursor/rules`. ProgramName: FAM00500`

**Key Features**:
- Thin wrapper classes (no business logic)
- Uses HTTP client to call Service layer
- References Common project for DTOs

---

### ToCSharpViewModel

**Purpose**: Convert VB.NET UI logic into ViewModels that manage data state.

**When to Use**: After Model layer is complete.

**Trigger**: Type `/ToCSharpViewModel` or use trigger `"viewmodel"`

**Input**: VB.NET form files from `net4/**/Front/{ProgramName}*/**/*.vb`

**Output**: 
- ViewModel classes in `{ProgramName}Model/VMs/`
- `{ProgramName}FrontResources` project

**Example Prompt**:
- Type `/ToCSharpViewModel` (custom commands)
- Copy: `convert each CRUD mode inside each pages in `/net4/**/Front/{ProgramName}*/**/*.vb` into each respective `/net6/**/FRONT/{ProgramName}Model/VMs/{PageName}ViewModel.cs` that use `/net6/**/FRONT/{ProgramName}Model/*Model.cs` to get the data needed for Front layer. ProgramName: FAM00500`

**Key Features**:
- Enforces `R_ViewModel<T>` inheritance
- Prohibits `R_FrontGlobalVar` usage
- Separates data state from UI state
- Creates FrontResources project

---

### ToCSharpFront

**Purpose**: Convert VB.NET WinForms/WPF UI into Blazor components.

**When to Use**: After ViewModel layer is complete.

**Trigger**: Type `/ToCSharpFront` or use trigger `"front"`

**Input**: VB.NET form files from `net4/**/Front/{ProgramName}*/**/*.vb`

**Output**: 
- `.razor` files (UI markup)
- `.razor.cs` files (code-behind)
- `_Imports.razor` file

**Example Prompt**:
- Type `/ToCSharpFront` (custom commands)
- Copy: `convert {ProgramName} .NET4 VB Forms to {ProgramName} Blazor components. Before starting the conversion, load and apply the migration-patterns. While analyzing the .NET4 source files, detect any conflicts or deviations from the migration-patterns. If conflicts are found, dynamically update and adjust the migration plan to fully comply with the migration-patterns before proceeding with code generation. ProgramName: FAM00500 and start with page: FAM00500`

**Key Features**:
- Fetches migration patterns automatically
- Enforces dependency injection rules
- Separates UI state from data state
- Works one program at a time

---

### ValidationAndBuild

**Purpose**: Validate project structure and build all projects with error reporting.

**When to Use**: After completing a layer or before final integration.

**Trigger**: Type `/ValidationAndBuild` or use trigger `"validate"`

**Input**: Project files to validate

**Output**: BUILD SUMMARY report with warnings and errors

**Example Prompt**:
- Type `/ValidationAndBuild` (custom commands)
- Copy: `validate and build `/net6/**/{ProgramName}*.csproj` following `*MigrationChecklist*`. Run builds and return BUILD SUMMARY reports for All projects. ProgramName: FAM00500`

**Key Features**:
- Pre-build validation (csproj settings, DLL references)
- Builds projects in correct order
- Classifies warnings (Code, External, Infrastructure)
- Generates standardized BUILD SUMMARY report
- Attempts safe fixes automatically

---

### SolutionManager

**Purpose**: Manage solution structure, add projects, and integrate with API/BlazorMenu.

**When to Use**: After all layers are migrated and validated.

**Trigger**: Type `/SolutionManager` or use trigger `"solution"`

**Input**: Program name to integrate

**Output**: 
- Updated solution files
- Updated API project references
- Updated BlazorMenu integration

**Example Prompt**:
- Type `/SolutionManager` (custom commands)
- Copy: `add {ProgramName}. ProgramName: FAM00500`

**Key Features**:
- Adds projects to appropriate solutions
- Maintains GUID uniqueness
- Integrates with API projects
- Integrates with BlazorMenu
- Maintains alphabetical ordering

---

## Best Practices and Tips

### Plan Generation

**Always generate and save plans** before starting migration:

1. Agent will automatically generate a plan
2. Review the plan carefully
3. Plan is saved to `/plan/` directory with format: `{yyyyMMdd}_{HHmmss}_{agent}_plan.md`
4. Plans serve as documentation and reference

**Example Plan Location**:
```
plan/20251104_095848_ToCSharpCommon_FAM00500_plan.md
```

### Error Handling Pattern

**Always use the standardized error handling pattern**:

```csharp
public async Task MethodName()
{
    var loEx = new R_Exception();
    try
    {
        // code here
    }
    catch (Exception ex)
    {
        loEx.Add(ex);
    }
    loEx.ThrowExceptionIfErrors();
}
```

**Key Points**:
- All error messages must come from resource files
- Never hardcode exception text
- Aggregate exceptions with `loEx.Add(ex)`
- Throw using `loEx.ThrowExceptionIfErrors()`
- Log before rethrow if in backend

### Code Review Checkpoints

**Review at each layer** before proceeding:

1. **After Common**: Verify DTOs match VB.NET structure
2. **After Back**: Verify business logic is preserved exactly
3. **After Service**: Verify controllers delegate correctly
4. **After Model**: Verify service clients are thin wrappers
5. **After ViewModel**: Verify no `R_FrontGlobalVar` usage
6. **After Front**: Verify dependency injection rules followed

### Validation Workflow

**Run validation after each layer**:

1. Use `ValidationAndBuild` agent
2. Review BUILD SUMMARY report
3. Fix any compilation errors
4. Address warnings (Code warnings should be fixed)
5. Document External/Infrastructure warnings

**Build Order**:
- Backend: Common → Resources → Back → Service
- Frontend: Common → Resources → Model → Front

### Variable Naming

**Follow strict naming conventions**:

| Type | Prefix | Example |
|------|--------|---------|
| string | c | `lcName` |
| bool | l | `llIsActive` |
| int | i | `liCount` |
| decimal | n | `lnAmount` |
| DateTime | d | `ldCreated` |
| enum | e | `leType` |
| object | o | `loResult` |

**Property Rules**:
- `[Inject]`: `private IType PropertyName { get; set; } = default!;`
- Private: `private Type _propertyName;`
- Public: `public Type PropertyName { get; set; }`

### Working with Multiple Programs

**For programs with sub-programs** (e.g., `SAM00100` with `SAM00110`):

- Sub-programs must be part of the main program's project
- Do NOT create separate projects for sub-programs
- Structure: `{ProgramName}Model/` contains all related models
- Structure: `{ProgramName}Front/` contains all related razor files

**Example**:
```
SAM00100Model/
├── SAM00100Model.cs
├── SAM00110Model.cs
└── VMs/
    ├── SAM00100ViewModel.cs
    ├── SAM00110ViewModel.cs
    └── SAM00100UploadViewModel.cs
```

### Migration Pattern Discovery

**When migrating Front layer**, the agent will:

1. Identify components used in VB.NET file
2. Fetch migration patterns from `.cursor/rules/front/components/migration-patterns/`
3. Apply patterns exactly (never guess)
4. Fetch component rules from `.cursor/rules/front/components/net6/` if needed
5. Fetch documentation from `.cursor/docs/net6` only when needed

**Do not manually apply patterns** - let the agent fetch them automatically.

---

## Troubleshooting Common Issues

### Compilation Errors

#### "Type not found" or "Namespace not found"

**Cause**: Missing using statements or project references.

**Solution**:
1. Check `_Imports.razor` for Front projects
2. Check `.csproj` for project references
3. Verify DLL HintPath is correct
4. Run `copy_realta_blazor_library.bat` to update DLLs

#### "Cannot convert type X to type Y"

**Cause**: Type mismatch between layers (e.g., using EntityDTO instead of ParameterDTO).

**Solution**:
1. Verify each method has its own ParameterDTO and ResultDTO
2. Check Common layer DTOs match expected structure
3. Review plan to ensure DTOs were created correctly

#### "R_Exception not found"

**Cause**: Missing DLL reference or using statement.

**Solution**:
1. Check `.csproj` for `R_APICommon` or `R_APIBackEnd` reference
2. Verify HintPath points to correct DLL location
3. Add using statement: `using R_CommonFrontBackAPI;`

### Build Issues

#### "Project reference not found"

**Cause**: Project reference path is incorrect or project doesn't exist.

**Solution**:
1. Verify project exists in expected location
2. Check relative path in `.csproj` is correct
3. Use SolutionManager to add projects to solution first

#### "DLL not found" or "HintPath not found"

**Cause**: DLL files are missing or HintPath is incorrect.

**Solution**:
1. Run `copy_realta_blazor_library.bat` to copy DLLs
2. Verify DLL exists at HintPath location
3. Check HintPath uses relative path from project location

#### "Build order error" or "Circular dependency"

**Cause**: Projects are referenced in wrong order or circular reference exists.

**Solution**:
1. Verify build order: Common → Resources → Back → Service → Model → Front
2. Check for circular references (should not exist with proper layer separation)
3. Use ValidationAndBuild agent to identify dependency issues

### Solution Integration Problems

#### "Project not found in solution"

**Cause**: Project was not added to solution file.

**Solution**:
1. Use SolutionManager agent to add project
2. Verify project GUID is unique
3. Check solution file syntax

#### "BlazorMenu not loading program"

**Cause**: Missing project reference or assembly entry.

**Solution**:
1. Verify `BlazorMenu.csproj` has project reference
2. Check `App.razor` has assembly entry: `typeof({ProgramName}Front.{ProgramName}).Assembly`
3. Ensure alphabetical ordering in both locations

#### "API not exposing endpoints"

**Cause**: Service project not referenced in API project.

**Solution**:
1. Verify API project (e.g., `BIMASAKTI_FA_API.csproj`) has Service project reference
2. Check reference is in correct ItemGroup
3. Verify alphabetical ordering

### Front Layer Issues

#### "Component not found" or "R_Grid not found"

**Cause**: Missing using statement or DLL reference.

**Solution**:
1. Check `_Imports.razor` has required using statements
2. Verify `.csproj` has `R_BlazorFrontEnd.Controls` reference
3. Check HintPath is correct

#### "[Inject] not working" or "Dependency injection error"

**Cause**: `[Inject]` attribute in wrong location or missing service registration.

**Solution**:
1. **ALL `[Inject]` MUST be in `.razor.cs` files, NEVER in `.razor` files**
2. Verify service is registered in dependency injection container
3. Check property follows pattern: `[Inject] private IType PropertyName { get; set; } = default!;`

#### "ViewModel not found" or "Data property not found"

**Cause**: ViewModel not created or wrong property name.

**Solution**:
1. Verify ViewModel exists in `{ProgramName}Model/VMs/`
2. Check ViewModel inherits `R_ViewModel<T>`
3. Verify property names match between ViewModel and Razor.cs

### Back Layer Issues

#### "Logger not found" or "Activity not found"

**Cause**: Logger/Activity classes not created or missing using statements.

**Solution**:
1. Verify Logger class exists: `Logger{ProgramName}.cs` inheriting `R_NetCoreLoggerBase<Logger{ProgramName}>`
2. Verify Activity class exists: `{ProgramName}Activity.cs` inheriting `R_ActivitySourceBase`
3. Check using statements in Back class

#### "Resource key not found"

**Cause**: Error message key missing in BackResources project.

**Solution**:
1. Verify resource key exists in `{ProgramName}BackResources_msgrsc.resx`
2. Check key is used correctly: `R_BackResources.{KeyName}`
3. Verify resource file is included in project

#### "Stored procedure not found"

**Cause**: Stored procedure name changed or database connection issue.

**Solution**:
1. **Never rename stored procedures** - use exact name from VB.NET
2. Verify database connection string
3. Check stored procedure exists in database

---

## Validation and Quality Assurance

### Pre-Migration Checklist

Before starting migration, verify:

- [ ] Source VB.NET code is accessible in `net4/` directory
- [ ] Target directory structure exists in `net6/`
- [ ] Libraries are up to date (run `copy_realta_blazor_library.bat`)
- [ ] Cursor rules and patterns are available in `.cursor/rules/`
- [ ] Documentation is available in `.cursor/docs/`

### Per-Layer Validation

**After each layer**, run validation:

1. **Use ValidationAndBuild agent**:
   - Type `/ValidationAndBuild` (custom commands)
   - Copy: `validate and build `/net6/**/{ProgramName}*.csproj` following `*MigrationChecklist*`. Run builds and return BUILD SUMMARY reports for All projects. ProgramName: {ProgramName}`

2. **Review BUILD SUMMARY**:
   - **Code Warnings (CS####)**: Should be fixed
   - **External Warnings (NU####, MSB####)**: Document with reason
   - **Infrastructure Warnings**: Document if acceptable

3. **Check Migration Checklist**:
   - Agent automatically fetches `*MigrationChecklist*` rules
   - Verify all checklist items are met
   - Document any deviations

### Final Validation

**Before marking migration complete**:

1. **Build All Projects**:
   - Backend solution: `BIMASAKTI11_BACK.sln`
   - Frontend solution: `BIMASAKTI11_FRONT.sln`

2. **Verify Integration**:
   - API endpoints are accessible
   - BlazorMenu loads program correctly
   - All project references are correct

3. **Review Plans**:
   - All plans saved in `/plan/` directory
   - Plans document what was migrated
   - Plans serve as reference for future changes

### Quality Gates

**Migration is complete when**:

- [ ] All layers migrated (Common → Back → Service → Model → ViewModel → Front)
- [ ] All projects build successfully (0 errors)
- [ ] Code warnings are addressed or documented
- [ ] Solution integration complete
- [ ] API integration complete
- [ ] BlazorMenu integration complete
- [ ] All plans saved to `/plan/` directory

### Common Validation Rules

**Project Structure**:
- [ ] Projects follow naming convention: `{ProgramName}{Layer}`
- [ ] Projects are in correct directories (COMMON/, BACK/, SERVICE/, FRONT/)
- [ ] Resources projects exist (BackResources, FrontResources)

**Code Quality**:
- [ ] Error handling uses `R_Exception` pattern
- [ ] All error messages come from resource files
- [ ] Variable naming follows conventions
- [ ] No business logic in Common layer
- [ ] No `R_FrontGlobalVar` in ViewModels
- [ ] Dependency injection rules followed in Front layer

**Build Quality**:
- [ ] All projects compile (0 errors)
- [ ] Code warnings addressed or documented
- [ ] DLL references use HintPath (not PackageReference)
- [ ] Project references use relative paths

---

## Additional Resources

### File Locations

- **Migration Plans**: `/plan/` directory
- **Migration Rules**: `.cursor/rules/` directory
- **Migration Patterns**: `.cursor/rules/front/components/migration-patterns/`
- **Documentation**: `.cursor/docs/net6/` and `.cursor/docs/net4/`
- **Agent Definitions**: `.cursor/commands/` directory

### Scripts

- `clean_build_folder.bat` - Clean all bin/obj folders
- `copy_realta_blazor_library.bat` - Copy library DLLs
- `update_all_git_repos.bat` - Update library source code
- `restore_app_razor_programs.ps1` - Restore Razor program references
- `restore_project_references.ps1` - Restore project references

### Getting Help

1. **Review Plans**: Check `/plan/` for similar migrations
2. **Check Rules**: Review `.cursor/rules/` for specific patterns
3. **Read Documentation**: Check `.cursor/docs/` for API references
4. **Run Validation**: Use ValidationAndBuild agent to identify issues

---

## Conclusion

This guide provides a comprehensive overview of using Cursor agents for .NET 4 to .NET 6 migration. Follow the step-by-step workflow, use the agent reference guide for specific tasks, and refer to troubleshooting section when issues arise.

**Remember**:
- Always migrate in order (Common → Back → Service → Model → ViewModel → Front)
- Generate and review plans before starting
- Validate after each layer
- Preserve business logic exactly
- Follow naming conventions and patterns strictly

Happy migrating!

