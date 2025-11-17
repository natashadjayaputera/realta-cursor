# Post-Command Review Checklist

## Overview

This checklist provides critical rules and validation points that **MUST** be reviewed after executing each custom migration command. Use this checklist to ensure code quality, rule compliance, and prevent migration failures.

**Legend:**
- ⚠️ **CRITICAL** - Must be checked, failure to comply will cause migration issues
- ✅ **RECOMMENDED** - Should be checked for code quality and best practices
- 📋 **VERIFY** - Verify correctness of implementation

---

## General Validation Rules (Apply to All Commands)

### Pre-Execution Checks
- [ ] Source VB.NET code is accessible in `net4/` directory
- [ ] Target directory structure exists in `net6/`
- [ ] Libraries are up to date (run `copy_realta_blazor_library.bat` if needed)
- [ ] Cursor rules and patterns are available in `.cursor/rules/`
- [ ] Documentation is available in `.cursor/docs/`

### Post-Execution Checks
- [ ] Plan was generated and saved to `/plan/` directory
- [ ] Plan was reviewed and approved before execution
- [ ] All generated files follow naming conventions: `{ProgramName}{Layer}`
- [ ] Projects are in correct directories (COMMON/, BACK/, SERVICE/, FRONT/)
- [ ] Variable naming follows conventions (type prefixes: `lc` for string, `li` for int, etc.)
- [ ] Error handling uses `R_Exception` pattern (if applicable)
- [ ] All error messages come from resource files (if applicable)

---

## 1. ToCSharpCommon

**Purpose**: Convert VB.NET DTOs, enums, and interfaces to C# Common project.

**When to Review**: After executing `/ToCSharpCommon` command.

### ⚠️ Critical Rules

#### DTO Structure
- [ ] ⚠️ **NO business logic in Common layer** - Only DTOs, interfaces, and enums
- [ ] ⚠️ **Each method has its own ParameterDTO and ResultDTO** - Never reuse EntityDTO as parameter/result
- [ ] ⚠️ **String defaults use `string.Empty`** - Not `null` or empty string literal
- [ ] ⚠️ **DateTime properties are NOT nullable** - Use `DateTime`, not `DateTime?`

#### Interface Requirements
- [ ] ⚠️ **All interfaces inherit `R_IServiceCRUDAsyncBase`** where applicable
- [ ] ⚠️ **Interface method signatures match VB.NET exactly** - Parameter and return types preserved
- [ ] ⚠️ **All methods are async** - Return `Task` or `Task<T>`

#### Enum Conversion
- [ ] ⚠️ **Enum values preserved exactly** - No value changes from VB.NET
- [ ] ⚠️ **Enum naming matches VB.NET** - Case and spelling preserved

### ✅ Code Quality Checks

#### Project Structure
- [ ] ✅ Project file `{ProgramName}Common.csproj` exists
- [ ] ✅ DTOs are in `DTOs/` folder
- [ ] ✅ Interfaces are in root or appropriate folder
- [ ] ✅ Enums are in appropriate location
- [ ] ✅ Project references are correct (minimal DLL references)
- [ ] ✅ DLL references use HintPath (not PackageReference)

#### Type Mapping
- [ ] ✅ Property types follow prefix-based mapping rules
- [ ] ✅ Property names match VB.NET (preserve exact naming)
- [ ] ✅ Collection types use appropriate generic types
- [ ] ✅ Nullable types only where appropriate (DateTime is NOT nullable)

### 📋 Verification

- [ ] 📋 Compare DTO structure with original VB.NET DTOs
- [ ] 📋 Verify all methods from VB.NET have corresponding ParameterDTO/ResultDTO
- [ ] 📋 Check that no calculation or business logic exists in DTOs
- [ ] 📋 Verify project builds successfully (run build test)

---

## 2. ToCSharpBack

**Purpose**: Convert VB.NET business logic to C# Back project with logging and activity patterns.

**When to Review**: After executing `/ToCSharpBack` command.

### ⚠️ Critical Rules

#### Business Logic Preservation
- [ ] ⚠️ **SQL queries are NOT renamed** - Use exact names from VB.NET
- [ ] ⚠️ **Stored procedure names are NOT changed** - Preserve exact names
- [ ] ⚠️ **Business logic is 100% preserved** - Even if original code contains bugs
- [ ] ⚠️ **Data types match VB.NET conventions** - `I` prefix = int, etc.
- [ ] ⚠️ **All calculations are identical** - No logic modifications

#### Error Handling
- [ ] ⚠️ **All error messages come from resource files** - No hardcoded strings
- [ ] ⚠️ **Error handling uses `R_Exception` pattern** - Aggregate with `loEx.Add(ex)`, throw with `loEx.ThrowExceptionIfErrors()`
- [ ] ⚠️ **Resource keys exist in BackResources project** - All error messages have corresponding resource keys

#### Async Implementation
- [ ] ⚠️ **All methods are async** - Return `async Task` or `async Task<T>`
- [ ] ⚠️ **Database calls are async** - Use async database access patterns

### ✅ Code Quality Checks

#### Logger and Activity Patterns
- [ ] ✅ Logger class exists: `Logger{ProgramName}.cs`
- [ ] ✅ Logger inherits `R_NetCoreLoggerBase<Logger{ProgramName}>`
- [ ] ✅ Activity class exists: `{ProgramName}Activity.cs`
- [ ] ✅ Activity inherits `R_ActivitySourceBase`
- [ ] ✅ Logger and Activity are properly injected in business class

#### Project Structure
- [ ] ✅ Back project `{ProgramName}Back.csproj` exists
- [ ] ✅ BackResources project `{ProgramName}BackResources.csproj` exists
- [ ] ✅ Business logic class `{ProgramName}Cls.cs` exists
- [ ] ✅ Logger and Activity classes are in `DTOs/` folder
- [ ] ✅ Resource files exist: `.resx`, `.id.resx`, `.Designer.cs`
- [ ] ✅ `Resources_Dummy_Class.cs` exists in BackResources project

#### Resource Files
- [ ] ✅ All error messages from VB.NET are in resource files
- [ ] ✅ Resource keys follow naming conventions
- [ ] ✅ Resource files are included in project
- [ ] ✅ Resource access uses `R_BackResources.{KeyName}` pattern

#### Project References
- [ ] ✅ Back project references Common project
- [ ] ✅ Back project references BackResources project
- [ ] ✅ DLL references use HintPath
- [ ] ✅ Minimal DLL references (only required ones)

### 📋 Verification

- [ ] 📋 Compare SQL queries with original VB.NET - verify exact names
- [ ] 📋 Compare stored procedure calls - verify exact names
- [ ] 📋 Review business logic calculations - verify they match VB.NET
- [ ] 📋 Check all error messages are in resource files
- [ ] 📋 Verify project builds successfully
- [ ] 📋 Test that resource keys are accessible

---

## 3. ToCSharpService

**Purpose**: Create ASP.NET Core API controllers that implement Common interfaces.

**When to Review**: After executing `/ToCSharpService` command.

### ⚠️ Critical Rules

#### Controller Implementation
- [ ] ⚠️ **Controllers implement interfaces from Common layer** - All interface methods are implemented
- [ ] ⚠️ **NO business logic in controllers** - Controllers only delegate to Back classes
- [ ] ⚠️ **All controller methods are async** - Return `Task` or `Task<T>`
- [ ] ⚠️ **Controllers use `R_BackGlobalVar` for `IClientHelper` access** - Not direct injection

#### Error Handling
- [ ] ⚠️ **Exceptions are handled with `R_Exception` pattern** - Proper error aggregation and throwing
- [ ] ⚠️ **Error responses are properly formatted** - Consistent error response structure

### ✅ Code Quality Checks

#### Controller Structure
- [ ] ✅ Controller class `{ProgramName}Controller.cs` exists
- [ ] ✅ Controller has `[ApiController]` attribute
- [ ] ✅ Controller has `[Route]` attribute with correct path
- [ ] ✅ Controller implements Common interface
- [ ] ✅ All interface methods are implemented in controller

#### Method Implementation
- [ ] ✅ Methods extract parameters from HTTP request correctly
- [ ] ✅ Methods call corresponding Back class methods
- [ ] ✅ Methods handle streaming context for custom parameters
- [ ] ✅ Methods return appropriate HTTP responses
- [ ] ✅ Authorization attributes are applied where needed

#### Project Structure
- [ ] ✅ Service project `{ProgramName}Service.csproj` exists
- [ ] ✅ Project references Common project
- [ ] ✅ Project references Back project
- [ ] ✅ DLL references use HintPath
- [ ] ✅ Minimal DLL references

### 📋 Verification

- [ ] 📋 Verify all Common interface methods are implemented
- [ ] 📋 Check that no business logic exists in controller
- [ ] 📋 Verify controller delegates to Back class correctly
- [ ] 📋 Test that API endpoints are accessible
- [ ] 📋 Verify project builds successfully

---

## 4. ToCSharpModel

**Purpose**: Create service client classes for ViewModels to call the API.

**When to Review**: After executing `/ToCSharpModel` command.

### ⚠️ Critical Rules

#### Model Implementation
- [ ] ⚠️ **Models are thin wrappers** - NO business logic in Model classes
- [ ] ⚠️ **Models only handle HTTP communication** - Serialization, HTTP calls, deserialization
- [ ] ⚠️ **Models use HTTP client to call Service layer** - Proper HTTP client injection

#### Streaming vs Non-Streaming
- [ ] ⚠️ **Streaming pattern implemented for list methods** - Uses `R_FrontContext` for streaming
- [ ] ⚠️ **Non-streaming pattern for CRUD methods** - Standard HTTP POST/GET

### ✅ Code Quality Checks

#### Model Structure
- [ ] ✅ Model class `{ProgramName}Model.cs` exists
- [ ] ✅ Model inherits `R_APIClient` or uses HTTP client pattern
- [ ] ✅ Model has HTTP client injected via constructor
- [ ] ✅ `VMs/` folder exists (for ViewModels later)

#### Method Implementation
- [ ] ✅ All Service controller endpoints have corresponding Model methods
- [ ] ✅ Methods build HTTP requests correctly (GET/POST)
- [ ] ✅ Methods serialize parameters correctly
- [ ] ✅ Methods deserialize responses correctly
- [ ] ✅ Methods return appropriate DTO types

#### Project Structure
- [ ] ✅ Model project `{ProgramName}Model.csproj` exists
- [ ] ✅ Project references Common project
- [ ] ✅ DLL references use HintPath
- [ ] ✅ Minimal DLL references

### 📋 Verification

- [ ] 📋 Verify all Service endpoints have Model wrappers
- [ ] 📋 Check that no business logic exists in Model
- [ ] 📋 Verify HTTP client configuration is correct
- [ ] 📋 Test that Model methods can call Service endpoints
- [ ] 📋 Verify project builds successfully

---

## 5. ToCSharpViewModel

**Purpose**: Convert VB.NET UI logic to ViewModels that manage data state.

**When to Review**: After executing `/ToCSharpViewModel` command.

### ⚠️ Critical Rules

#### ViewModel Inheritance
- [ ] ⚠️ **ViewModels MUST inherit `R_ViewModel<T>`** - T is the Entity DTO type
- [ ] ⚠️ **DO NOT redefine `Data` property** - Inherited from `R_ViewModel<T>`
- [ ] ⚠️ **One CRUD entity per ViewModel** - Map from VB.NET conductor controls

#### Forbidden Patterns
- [ ] ⚠️ **NO `R_FrontGlobalVar` usage in ViewModels** - This is forbidden
- [ ] ⚠️ **NO `IClientHelper` in ViewModels** - Only allowed in `.razor.cs` (code-behind)
- [ ] ⚠️ **NO `R_BackGlobalVar` in ViewModels** - This is forbidden

#### State Separation
- [ ] ⚠️ **Data state goes in ViewModel** - Entity data, validation state
- [ ] ⚠️ **UI-only state goes in Razor.cs** - Component visibility, loading state
- [ ] ⚠️ **Data validation ONLY in ViewModels** - NOT in code-behind

### ✅ Code Quality Checks

#### ViewModel Structure
- [ ] ✅ ViewModel classes exist in `{ProgramName}Model/VMs/` folder
- [ ] ✅ Each page has corresponding ViewModel: `{PageName}ViewModel.cs`
- [ ] ✅ ViewModels inherit `R_ViewModel<T>` correctly
- [ ] ✅ ViewModels inject Model dependencies (not `IClientHelper`)

#### Method Implementation
- [ ] ✅ `GetListRecord` method fetches list data via Model
- [ ] ✅ `GetRecord` method fetches single record
- [ ] ✅ `SaveRecord` method saves (insert/update) record
- [ ] ✅ `DeleteRecord` method deletes record
- [ ] ✅ `Validation` method contains data validation logic
- [ ] ✅ ObservableCollections use ResultDTO (not EntityDTO)

#### FrontResources Project
- [ ] ✅ FrontResources project `{ProgramName}FrontResources.csproj` exists
- [ ] ✅ Resource files exist: `.resx`, `.id.resx`, `.Designer.cs`
- [ ] ✅ UI labels from VB.NET forms are in resource files
- [ ] ✅ `Resources_Dummy_Class.cs` exists
- [ ] ✅ Error messages use `R_FrontUtility.R_GetError` pattern

#### Project Structure
- [ ] ✅ ViewModels are in `VMs/` folder under Model project
- [ ] ✅ Model project includes VMs folder
- [ ] ✅ Project references are correct
- [ ] ✅ DLL references use HintPath

### 📋 Verification

- [ ] 📋 Verify all ViewModels inherit `R_ViewModel<T>`
- [ ] 📋 Search for `R_FrontGlobalVar` - should not exist in ViewModels
- [ ] 📋 Search for `IClientHelper` - should not exist in ViewModels
- [ ] 📋 Verify data state is in ViewModel, UI state is in Razor.cs
- [ ] 📋 Check that validation logic is only in ViewModels
- [ ] 📋 Verify ObservableCollections use ResultDTO
- [ ] 📋 Verify project builds successfully

---

## 6. ToCSharpFront

**Purpose**: Convert VB.NET WinForms/WPF UI to Blazor components (Manual Process).

**When to Review**: After manually creating Front layer or using `/ToCSharpFront` command.

### ⚠️ Critical Rules

#### Dependency Injection
- [ ] ⚠️ **ALL `[Inject]` attributes MUST be in `.razor.cs` files** - NEVER in `.razor` files
- [ ] ⚠️ **ALL `@using` statements MUST be in `_Imports.razor`** - NEVER in individual `.razor` files
- [ ] ⚠️ **Injected properties follow pattern**: `[Inject] private IType PropertyName { get; set; } = default!;`

#### State Separation
- [ ] ⚠️ **UI state in `.razor.cs`** - Component visibility, loading state, UI-only properties
- [ ] ⚠️ **Data state in ViewModel** - Entity data, validation (already verified in ViewModel checklist)
- [ ] ⚠️ **Data validation ONLY in ViewModel** - NOT in code-behind

### ✅ Code Quality Checks

#### Project Structure
- [ ] ✅ Front project `{ProgramName}Front.csproj` exists
- [ ] ✅ `.razor` files exist for each page
- [ ] ✅ `.razor.cs` files exist (code-behind) for each page
- [ ] ✅ `_Imports.razor` file exists with all `@using` statements
- [ ] ✅ Project references Model project
- [ ] ✅ Project references FrontResources project

#### Code-Behind (.razor.cs)
- [ ] ✅ All `[Inject]` attributes are in `.razor.cs` files
- [ ] ✅ ViewModel is injected in code-behind
- [ ] ✅ `IClientHelper` is injected in code-behind (if needed)
- [ ] ✅ Event handlers are implemented
- [ ] ✅ UI state management is in code-behind

#### Razor Markup (.razor)
- [ ] ✅ No `[Inject]` attributes in `.razor` files
- [ ] ✅ No `@using` statements in `.razor` files (only in `_Imports.razor`)
- [ ] ✅ Data binding to ViewModel properties
- [ ] ✅ Event binding to code-behind methods
- [ ] ✅ Components use R_Grid, R_TextBox, R_Button, etc.

#### Migration Patterns
- [ ] ✅ Migration patterns from `.cursor/rules/front/components/migration-patterns/` are followed
- [ ] ✅ Component usage matches NET6 patterns
- [ ] ✅ Event handling follows NET6 patterns

#### Project References
- [ ] ✅ Project references Model project
- [ ] ✅ Project references FrontResources project
- [ ] ✅ Project references Common project (if needed)
- [ ] ✅ DLL references use HintPath

### 📋 Verification

- [ ] 📋 Search for `[Inject]` in `.razor` files - should not exist
- [ ] 📋 Search for `@using` in `.razor` files (except `_Imports.razor`) - should not exist
- [ ] 📋 Verify all `[Inject]` are in `.razor.cs` files
- [ ] 📋 Verify UI state is in code-behind, data state is in ViewModel
- [ ] 📋 Check that migration patterns are followed correctly
- [ ] 📋 Verify project builds successfully
- [ ] 📋 Test that Blazor components render correctly

---

## 7. ValidationAndBuild

**Purpose**: Validate project structure and build all projects with error reporting.

**When to Review**: After executing `/ValidationAndBuild` command.

### ⚠️ Critical Rules

#### Build Results
- [ ] ⚠️ **All projects build successfully (0 errors)** - No compilation errors
- [ ] ⚠️ **Code Warnings (CS####) MUST be fixed** - These are from your code
- [ ] ⚠️ **Build order is correct** - Dependencies built first

#### Warning Classification
- [ ] ⚠️ **Code Warnings (CS####) are addressed** - Fixed or documented with reason
- [ ] ⚠️ **External Warnings (NU####, MSB####) are documented** - With acceptable reason
- [ ] ⚠️ **Infrastructure Warnings are documented** - If acceptable

### ✅ Code Quality Checks

#### Pre-Build Validation
- [ ] ✅ `.csproj` structure and settings are validated
- [ ] ✅ DLL references (HintPath correctness) are validated
- [ ] ✅ Project references (relative paths) are validated
- [ ] ✅ Namespace conventions are checked
- [ ] ✅ File organization is validated

#### Build Process
- [ ] ✅ Projects built in correct order (dependencies first)
- [ ] ✅ Common project built first
- [ ] ✅ Resources projects built
- [ ] ✅ Back project built
- [ ] ✅ Service project built
- [ ] ✅ Model project built
- [ ] ✅ Front project built (if exists)

#### BUILD SUMMARY Report
- [ ] ✅ Standardized BUILD SUMMARY report is generated
- [ ] ✅ All projects listed with status
- [ ] ✅ Warnings are categorized (Code, External, Infrastructure)
- [ ] ✅ Error count is accurate
- [ ] ✅ Warning count is accurate
- [ ] ✅ Fix recommendations are provided

### 📋 Verification

- [ ] 📋 Review BUILD SUMMARY report carefully
- [ ] 📋 Verify all projects show SUCCESS status
- [ ] 📋 Check that Code Warnings are addressed
- [ ] 📋 Verify External Warnings are documented
- [ ] 📋 Check that build order was correct
- [ ] 📋 Verify no compilation errors exist

---

## 8. SolutionManager

**Purpose**: Manage solution structure, add projects, and integrate with API/BlazorMenu.

**When to Review**: After executing `/SolutionManager` command.

### ⚠️ Critical Rules

#### Solution Integration
- [ ] ⚠️ **All projects added to correct solutions** - Backend to BACK.sln, Frontend to FRONT.sln
- [ ] ⚠️ **Project GUIDs are unique** - No duplicate GUIDs
- [ ] ⚠️ **Alphabetical ordering maintained** - In all references and solution entries

#### API Integration
- [ ] ⚠️ **Service project referenced in Module API** - Correct module API project
- [ ] ⚠️ **Alphabetical ordering in API references** - Maintained

#### BlazorMenu Integration
- [ ] ⚠️ **Front project referenced in BlazorMenu.csproj** - Project reference exists
- [ ] ⚠️ **Assembly entry added to BlazorMenu/App.razor** - `typeof({ProgramName}Front.{ProgramName}).Assembly`
- [ ] ⚠️ **Alphabetical ordering in BlazorMenu references** - Maintained

### ✅ Code Quality Checks

#### Backend Solution (BIMASAKTI11_BACK.sln)
- [ ] ✅ Common project added
- [ ] ✅ BackResources project added
- [ ] ✅ Back project added
- [ ] ✅ Service project added
- [ ] ✅ Projects in alphabetical order
- [ ] ✅ Project paths are correct

#### Frontend Solution (BIMASAKTI11_FRONT.sln)
- [ ] ✅ Common project added
- [ ] ✅ Model project added
- [ ] ✅ FrontResources project added
- [ ] ✅ Front project added (if exists)
- [ ] ✅ Projects in alphabetical order
- [ ] ✅ Project paths are correct

#### Module API Integration
- [ ] ✅ Correct module API project identified (e.g., `BIMASAKTI_FA_API.csproj`)
- [ ] ✅ Service project reference added
- [ ] ✅ Reference in correct ItemGroup
- [ ] ✅ Alphabetical ordering maintained

#### BlazorMenu Integration
- [ ] ✅ Front project reference added to `BlazorMenu.csproj`
- [ ] ✅ Assembly entry added to `BlazorMenu/App.razor`
- [ ] ✅ Assembly entry in correct location
- [ ] ✅ Alphabetical ordering maintained

#### Solution File Validation
- [ ] ✅ Solution files have valid syntax
- [ ] ✅ All project GUIDs are unique
- [ ] ✅ Project paths are relative and correct
- [ ] ✅ Solution can be opened in Visual Studio

### 📋 Verification

- [ ] 📋 Open solution files in Visual Studio - verify they load correctly
- [ ] 📋 Check that all projects appear in solutions
- [ ] 📋 Verify project GUIDs are unique (search for duplicates)
- [ ] 📋 Verify alphabetical ordering in all references
- [ ] 📋 Test that API endpoints are accessible
- [ ] 📋 Test that BlazorMenu loads program correctly
- [ ] 📋 Verify solution files are valid

---

## Final Validation Checklist

Before marking migration as complete, verify:

### Build Status
- [ ] All projects build successfully (0 errors)
- [ ] Code warnings are addressed or documented
- [ ] External warnings are documented with reasons

### Integration
- [ ] Solution integration complete
- [ ] API integration complete
- [ ] BlazorMenu integration complete

### Documentation
- [ ] All plans saved to `/plan/` directory
- [ ] Plans document what was migrated
- [ ] Any deviations are documented

### Code Quality
- [ ] Error handling uses `R_Exception` pattern
- [ ] All error messages come from resource files
- [ ] Variable naming follows conventions
- [ ] No business logic in Common layer
- [ ] No `R_FrontGlobalVar` in ViewModels
- [ ] Dependency injection rules followed in Front layer

### Project Structure
- [ ] Projects follow naming convention: `{ProgramName}{Layer}`
- [ ] Projects are in correct directories
- [ ] Resources projects exist
- [ ] DLL references use HintPath
- [ ] Project references use relative paths

---

## Quick Reference

### Command Execution Order
1. ToCSharpCommon
2. ToCSharpBack
3. ToCSharpService
4. ToCSharpModel
5. ToCSharpViewModel
6. ToCSharpFront (Manual)
7. ValidationAndBuild (after each layer)
8. SolutionManager (after all layers)

### Critical Rules Summary
- ⚠️ **Never rename SQL queries or stored procedures**
- ⚠️ **Preserve business logic 100% (even bugs)**
- ⚠️ **ViewModels MUST inherit `R_ViewModel<T>`**
- ⚠️ **NO `R_FrontGlobalVar` in ViewModels**
- ⚠️ **ALL `[Inject]` in `.razor.cs`, NEVER in `.razor`**
- ⚠️ **ALL `@using` in `_Imports.razor`, NEVER in `.razor`**

---

## Related Documentation

- **Migration Guide**: See `MIGRATION_GUIDE.md` for detailed workflow
- **Custom Commands Guide**: See `PANDUAN_MIGRASI_CUSTOM_COMMANDS_ID.md` for command usage
- **Migration Rules**: See `.cursor/rules/` for detailed rules and patterns
- **Migration Plans**: See `/plan/` directory for generated migration plans

---

**Last Updated**: Generated from migration documentation
**Version**: 1.0

