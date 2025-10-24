# Critical Patterns Learned - .NET 6 Migration

## 📋 Quick Reference & Overview

### Program Naming Convention
- Format: `ABZ00099`
- AB = Module (SA=System Admin, GS=General System, etc.)
- Z = Type (M=Master, I=Inquiry, B=Batch, T=Transaction, R=Report)
- 000 = Program code
- 99 = Sub program/page number (00 = main entry)

### Standard .NET 6 Project Structure
```
BACK/{module}/{ProgramName}Back/           → Business Logic + Logger/Activity
├── DTOs/
│   ├── Logger{ProgramName}.cs            → R_NetCoreLoggerBase<Logger{ProgramName}>
│   └── {ProgramName}Activity.cs          → R_ActivitySourceBase
├── {ProgramName}Cls.cs                   → R_BusinessObjectAsync<{ProgramName}DTO>
└── {ProgramName}Back.csproj

BACK/{module}/{ProgramName}BackResources/ → Resources ONLY (root folder)
├── {ProgramName}BackResources_msgrsc.resx
├── {ProgramName}BackResources_msgrsc.id.resx
├── {ProgramName}BackResources_msgrsc.Designer.cs
├── Resources_Dummy_Class.cs
└── {ProgramName}BackResources.csproj

COMMON/{module}/{ProgramName}Common/      → DTOs + Interfaces ONLY
├── DTOs/ (all DTOs here)
├── I{ProgramName}.cs                     → R_IServiceCRUDAsyncBase<{ProgramName}DTO>
├── Requests/ (request DTOs)
└── {ProgramName}Common.csproj

SERVICE/{module}/{ProgramName}Service/    → API Controllers
├── {ProgramName}Controller.cs           → Implements I{ProgramName}
└── {ProgramName}Service.csproj

FRONT/{ProgramName}Model/                 → Service Client
├── {ProgramName}Model.cs                → Implements I{ProgramName}
├── VMs/ (view models)
└── {ProgramName}Model.csproj

FRONT/{ProgramName}FrontResources/        → Frontend Resources (root folder)
├── {ProgramName}FrontResources_msgrsc.resx
├── {ProgramName}FrontResources_msgrsc.id.resx
├── {ProgramName}FrontResources_msgrsc.Designer.cs
├── Resources_Dummy_Class.cs
└── {ProgramName}FrontResources.csproj

FRONT/{ProgramName}Front/                 → Blazor Frontend
├── {ProgramName}.razor
├── {ProgramName}.razor.cs
├── _Imports.razor
└── {ProgramName}Front.csproj
```

## 🏗️ Backend Implementation Patterns

### 1. Logger Pattern (MUST FOLLOW)
**Location**: In **Back** project only (NOT Common)
```csharp
using R_CommonFrontBackAPI.Log;

namespace {ProgramName}Back
{
    public class Logger{ProgramName} : R_NetCoreLoggerBase<Logger{ProgramName}>
    {
        // Empty - base class provides all functionality
    }
}
```

### 2. Activity Pattern (MUST FOLLOW)
**Location**: In **Back** project only (NOT Common)
```csharp
using R_OpenTelemetry;

namespace {ProgramName}Back
{
    public class {ProgramName}Activity : R_ActivitySourceBase
    {
        // Empty - base class provides all functionality
    }
}
```

### 3. Service Interface Pattern
**Location**: In **Common** project
```csharp
public interface I{ProgramName} : R_IServiceCRUDAsyncBase<{ProgramName}DTO>
{
    IAsyncEnumerable<{GetListResultDTO}> GetList(); // Pattern for getting List
    Task<{ProgramName}ResultDTO<{GetAnythingResultDTO}>> GetAnything({GetAnythingParameterDTO} poParameter); // Pattern for everything other than list
}
```
**CRITICAL**: Use `R_IServiceCRUDAsyncBase` NOT `R_IServiceCRUDBase`, must not use `Async` as suffix.

### 4. Back Business Logic Pattern
**Location**: In **Back** project
```csharp
public class {ProgramName}Cls : R_BusinessObjectAsync<{ProgramName}DTO>
{
    private readonly {RSP_NAME}Resources.Resources_Dummy_Class loRsp = new(); // Repeat as much as RSP used
    private readonly Logger{ProgramName} _logger;
    private readonly ActivitySource _activitySource;

    public {ProgramName}Cls()
    {
        _logger = Logger{ProgramName}.R_GetInstanceLogger();
        _activitySource = {ProgramName}Activity.R_GetInstanceActivitySource(); // → used in Back (fetches already initialized one)
    }

    public async Task<List<{GetListResultDTO}>> GetListAsync(GetListParameterDTO poParameter)
    {
        R_Exception loEx = new R_Exception();
        R_Db loDb = new R_Db();
        List<{GetListResultDTO}> loResult = new List<{GetListResultDTO}>();

        try
        {
            using DbConnection loConn = await loDb.GetConnectionAsync();
            using DbCommand loCmd = loDb.GetCommand();

            var lcQuery = "RSP_GS_GET_LIST"; // Changed based on business process
            loCmd.CommandText = lcQuery;
            loCmd.CommandType = CommandType.StoredProcedure;

            loDb.R_AddCommandParameter(loCmd, "@CCOMPANY_ID", DbType.String, 50, poParameter.CCOMPANY_ID); // Example Parameter, size is based on SP max input or Column Max Size
            loDb.R_AddCommandParameter(loCmd, "@CUSER_ID", DbType.String, 50, poParameter.CUSER_ID); // Example Parameter, size is based on SP max input or Column Max Size

            var loDataTable = await loDb.SqlExecQueryAsync(loConn, loCmd, true);
            loResult = R_Utility.R_ConvertTo<{GetListResultDTO}>(loDataTable).ToList();
        }
        catch (Exception ex)
        {
            loEx.Add(ex);
        }
        finally 
        {
            if (loDb != null) 
                loDb = null;
        }

        loEx.ThrowExceptionIfErrors();

        return loResult ?? new List<{GetListResultDTO}>();
    }

    public async Task<{GetAnythingResultDTO}> GetAnythingAsync({GetAnythingParameterDTO} poParameter) 
    {
        R_Exception loEx = new R_Exception();
        R_Db loDb = new R_Db();
        {GetAnythingResultDTO} loRtn = new {GetAnythingResultDTO}();
        
        try
        {
            using DbConnection loConn = await loDb.GetConnectionAsync();
            using DbCommand loCmd = loDb.GetCommand();

            var lcQuery = "RSP_GS_GET_ANYTHING"; // Changed based on business process
            loCmd.CommandText = lcQuery;
            loCmd.CommandType = CommandType.StoredProcedure;

            loDb.R_AddCommandParameter(loCmd, "@CCOMPANY_ID", DbType.String, 50, poParameter.CCOMPANY_ID); // Example Parameter, size is based on SP max input or Column Max Size
            loDb.R_AddCommandParameter(loCmd, "@CUSER_ID", DbType.String, 50, poParameter.CUSER_ID); // Example Parameter, size is based on SP max input or Column Max Size

            var loDataTable = await loDb.SqlExecQueryAsync(loConn, loCmd, true);
            var loResult = R_Utility.R_ConvertTo<{GetAnythingResultDTO}>(loDataTable).FirstOrDefault();
            loRtn.Data = loResult;
        }
        catch (Exception ex)
        {
            loEx.Add(ex);
        }
        finally 
        {
            if (loDb != null) 
                loDb = null;
        }

        loEx.ThrowExceptionIfErrors();

        return loRtn ?? new {GetAnythingResultDTO}();
    }
}
```

### 5. Database Operation Pattern
**CRITICAL**: Use `using var` for connections and commands
```csharp
R_Db? loDb = null;
try
{
    loDb = new R_Db();
    using var loConn = await loDb.GetConnectionAsync();  // Auto-disposal
    using var loCmd = loDb.GetCommand();                 // Auto-disposal
    
    loDb.R_AddCommandParameter(loCmd, "@PARAM", DbType.String, size, value);
    var loDataTable = await loDb.SqlExecQueryAsync(loConn, loCmd, true);
}
finally
{
    if (loDb != null) { loDb = null; }  // Always cleanup
}
```

### 6. Controller Pattern
```csharp
[ApiController]
[Route("api/[controller]/[action]")]
public class {ProgramName}Controller : ControllerBase, I{ProgramName}
{
    private readonly Logger{ProgramName} _logger;
    private readonly ActivitySource _activitySource;

    public {ProgramName}Controller(ILogger<Logger{ProgramName}> logger)
    {
        Logger{ProgramName}.R_InitializeLogger(logger);
        _logger = Logger{ProgramName}.R_GetInstanceLogger();
        _activitySource = {ProgramName}Activity.R_InitializeAndGetActivitySource(nameof({ProgramName}Controller)); // → used in Controller (initializes once)
    }

    [HttpPost]
    public async IAsyncEnumerable<{GetListResultDTO}> GetList()
    {
        R_Exception loEx = new R_Exception();
        {ProgramName}Cls loCls = new {ProgramName}Cls();
        List<{GetListResultDTO}> loRtn = new List<{GetListResultDTO}>();
        try
        {
            var loParam = new GetListParameterDTO()
            {
                // Example of things that use global variable
                CCOMPANY_ID = R_BackGlobalVar.COMPANY_ID,
                CUSER_ID = R_BackGlobalVar.USER_ID,
                {OtherParameterField} = R_Utility.R_GetStreamingContext<{OtherParameterFieldType}>(ContextConstant.{OtherParameterField}), // List will use streaming context because you are not allowed to send parameter
                ...
            };

            loRtn = await loCls.GetListAsync(loParam);
        }
        catch (Exception ex)
        {
            loEx.Add(ex);
        }

        loEx.ThrowExceptionIfErrors();

        foreach ({GetListResultDTO} loItem in loRtn)
        {
            yield return loItem;
        }
    }

    [HttpPost]
    public async Task<{ProgramName}ResultDTO<{GetAnythingResultDTO}>> GetAnything({GetAnythingParameterDTO} poParameter) 
    {
        R_Exception loEx = new R_Exception();
        {ProgramName}Cls loCls = new {ProgramName}Cls();
        {ProgramName}ResultDTO<{GetAnythingResultDTO}> loRtn = new {ProgramName}ResultDTO<{GetAnythingResultDTO}>();
        
        try
        {
            loRtn = await loCls.GetAnythingAsync(poParameter);
        }
        catch (Exception ex)
        {
            loEx.Add(ex);
        }

        loEx.ThrowExceptionIfErrors();

        return loRtn;
    }
}
```

### 6.1. Service Layer R_BackGlobalVar Pattern (CRITICAL)
**RULE**: For list methods in Service layer, use `R_BackGlobalVar` directly for IClientHelper data, NOT streaming context. Streaming Context is used for custom parameters that is not provided in IClientHelper;

#### ✅ Correct Service Pattern for List Methods
```csharp
[HttpPost]
public async IAsyncEnumerable<{ResultDTO}> GetList{Description}()
{
    var lcMethod = nameof(GetList{Description});
    using var activity = _activitySource.StartActivity(lcMethod);
    var loEx = new R_Exception();
    var loCls = new {ProgramName}Cls();
    List<{ResultDTO}> loRtn = new List<{ResultDTO}>();

    try
    {
        // ✅ CORRECT: Use R_BackGlobalVar directly (IClientHelper sets it automatically)
        var lcCompanyId = R_BackGlobalVar.COMPANY_ID;
        
        _logger.LogInfo("Start method GetList{Description}Async in {0}", lcMethod);
        loRtn = await loCls.GetList{Description}Async(lcCompanyId);
    }
    catch (Exception ex)
    {
        loEx.Add(ex);
        _logger.LogError(loEx);
    }

    loEx.ThrowExceptionIfErrors();

    foreach ({ResultDTO} loItem in loRtn)
    {
        yield return loItem;
    }
}
```

#### ❌ Wrong Service Pattern
```csharp
// ❌ WRONG: Don't use streaming context for IClientHelper data
var lcCompanyId = R_Utility.R_GetStreamingContext<string>(ContextConstant.CCOMPANY_ID);

// ❌ WRONG: Don't set R_BackGlobalVar manually
R_BackGlobalVar.COMPANY_ID = "COMPANY_ID_VALUE";
```

#### Key Points:
1. **IClientHelper automatically sets R_BackGlobalVar values** - you only read from them
2. **Use streaming context only for custom parameters** - not for IClientHelper data
3. **R_APIBackEnd reference required** - to access R_BackGlobalVar in Service layer
4. **Pattern applies to list methods** - where parameters are passed via streaming context from frontend

**LOGGER & ACTIVITY PATTERN EXAMPLE IN BACK**
```csharp
public async Task<{ExampleMethodResultDTO}> ExampleMethodAsync(ExampleMethodParameterDTO poParam)
{
    string lcMethod = nameof(ExampleMethodAsync);
    using var activity = _activitySource.StartActivity(lcMethod);
    _logger.LogInfo("START method {MethodName}", lcMethod);

    var loEx = new R_Exception();
    var loDb = new R_Db();
    {ExampleMethodResultDTO} loResult = new();

    try
    {
        using DbConnection loConn = await loDb.GetConnectionAsync();
        using DbCommand loCmd = loDb.GetCommand();

        loCmd.Parameters.Clear();
        loCmd.CommandText = "SELECT ... FROM ... WHERE ... = @Param";
        loDb.R_AddCommandParameter(loCmd, "@Param", DbType.String, 50, poParam);

        var loDbParams = loCmd.Parameters.Cast<DbParameter>()
            .Where(x => x != null && x.ParameterName.StartsWith("@"))
            .ToDictionary(x => x.ParameterName, x => x.Value);

        _logger.LogDebug("{@ObjectQuery} {@Parameter}", loCmd.CommandText, loDbParams);

        var loDataTable = await loDb.SqlExecQueryAsync(loConn, loCmd, false);
        loResult = R_Utility.R_ConvertTo<{ExampleMethodResultDTO}>(loDataTable).FirstOrDefault();
    }
    catch (Exception ex)
    {
        loEx.Add(ex);
        _logger.LogError(loEx);
    }

    loEx.ThrowExceptionIfErrors();
    _logger.LogInfo("END method {MethodName}", lcMethod);

    return loResult;
}
```

**LOGGER & ACTIVITY PATTERN EXAMPLE IN CONTROLLER**
```csharp
public async Task<{ProgramName}ResultDTO<{ExampleMethodResultDTO}>> ExampleMethodAsync(ExampleMethodParameterDTO poParam)
{
    string lcMethod = nameof(ExampleMethodAsync);
    using var activity = _activitySource.StartActivity(lcMethod);
    _logger.LogInfo("START method {MethodName}", lcMethod);

    var loEx = new R_Exception();
    {ProgramName}ResultDTO<{ExampleMethodResultDTO}> loRtn = new {ProgramName}ResultDTO<{ExampleMethodResultDTO}>();

    try
    {
        var loCls = new {ProgramName}Cls();

        _logger.LogInfo("Calling ExampleMethodAsync from {MethodName}", lcMethod);
        loRtn.Data = await loCls.ExampleMethodAsync(poParam);
    }
    catch (Exception ex)
    {
        loEx.Add(ex);
        _logger.LogError(loEx);
    }

    loEx.ThrowExceptionIfErrors();
    _logger.LogInfo("END method {MethodName}", lcMethod);

    return loRtn;
}
```

## 🌐 Frontend Implementation Patterns

### 7. Frontend Model Pattern
**Location**: In **Model** project
```csharp
public class {ProgramName}Model : R_BusinessObjectServiceClientBase<{ProgramName}DTO>, I{ProgramName}
{
    private const string DEFAULT_HTTP_NAME = "R_DefaultServiceUrl{ModuleName}"; // ModuleName is filled only if module is not GS or SA
    private const string DEFAULT_SERVICEPOINT_NAME = "api/{ProgramName}";
    private const string DEFAULT_MODULE = "{ModuleName}";

    public {ProgramName}Model()
        : base(DEFAULT_HTTP_NAME, DEFAULT_SERVICEPOINT_NAME, DEFAULT_MODULE, true, true)
    {
    }

    // Get List Pattern -- Not used — interface compliance only
    public IAsyncEnumerable<{GetListResultDTO}> GetList()
    {
        throw new System.NotImplementedException();
    }

    // Get List Pattern -- this is actual logic to get the data from API
    public async Task<{ProgramName}ResultDTO<List<{GetListResultDTO}>>> GetListAsync()
    {
        R_Exception loEx = new R_Exception();

        {ProgramName}ResultDTO<List<{GetListResultDTO}>> loRtn = new {ProgramName}ResultDTO<List<{GetListResultDTO}>>();

        try
        {
            R_HTTPClientWrapper.httpClientName = _HttpClientName;
            loRtn.Data = await R_HTTPClientWrapper.R_APIRequestStreamingObject<{GetListResultDTO}>(
                _RequestServiceEndPoint,
                nameof(I{ProgramName}.GetList),
                _ModuleName,
                true,
                true
            );
        }
        catch (Exception ex)
        {
            loEx.Add(ex);
        }

        loEx.ThrowExceptionIfErrors();

        return loRtn;
    }

    public async Task<{ProgramName}ResultDTO<{GetAnythingResultDTO}>> GetAnything({GetAnythingParameterDTO} poParameter) 
    {
        R_Exception loEx = new R_Exception();

        {ProgramName}ResultDTO<{GetAnythingResultDTO}> loRtn = new {ProgramName}ResultDTO<{GetAnythingResultDTO}>();

        try
        {
            R_HTTPClientWrapper.httpClientName = _HttpClientName;
            loRtn.Data = await R_HTTPClientWrapper.R_APIRequestObject<{GetAnythingResultDTO}, {GetAnythingParameterDTO}>( // remove second type if no parameter e.g. {GetAnythingParameterDTO}
                _RequestServiceEndPoint,
                nameof(I{ProgramName}.GetAnything),
                poParameter, // remove this if no parameter
                _ModuleName,
                true,
                true
            );
        }
        catch (Exception ex)
        {
            loEx.Add(ex);
        }

        loEx.ThrowExceptionIfErrors();

        return loRtn;
    }
}
```

### 8. Frontend Global Variable Pattern (CRITICAL)
**RULE**: Never use `R_FrontGlobalVar` in ViewModels. Use `IClientHelper` injection in .razor.cs and pass values as parameters.

#### ❌ Wrong Pattern - Using R_FrontGlobalVar in ViewModel
```csharp
// WRONG - Don't use R_FrontGlobalVar in ViewModel
public async Task GetRateTypeListAsync()
{
    var request = new SAM00110GetListRequest
    {
        CCOMPANY_ID = R_FrontGlobalVar.COMPANY_ID  // ❌ This class doesn't exist in .NET 6
    };
    // ...
}
```

#### ✅ Correct Pattern - Use IClientHelper Injection
**Step 1: Inject IClientHelper in .razor.cs**
```csharp
// In .razor.cs file
[Inject] private IClientHelper _globalVar { get; set; } = default!;
```

**Step 2: Update ViewModel method to accept parameters**
```csharp
// In ViewModel
public async Task GetRateTypeListAsync(string companyId)
{
    var request = new SAM00110GetListRequest
    {
        CCOMPANY_ID = companyId  // ✅ Use parameter instead of global variable
    };
    // ...
}
```

**Step 3: Pass values from .razor.cs to ViewModel**
```csharp
// In .razor.cs file
private async Task Grid_R_ServiceGetListRecord(R_ServiceGetListRecordEventArgs eventArgs)
{
    // ✅ Pass _globalVar.CompanyId to ViewModel method
    await _sam00110VM.GetRateTypeListAsync(_globalVar.CompanyId);
    eventArgs.ListEntityResult = _sam00110VM.RateTypeList;
}
```

#### Available IClientHelper Properties
- `_globalVar.CompanyId` - Company ID
- `_globalVar.UserId` - User ID
- `_globalVar.CultureId` - Culture ID

#### Why This Pattern is Required
1. **Dependency Injection**: .NET 6 uses proper DI instead of global static variables
2. **Testability**: Parameters make methods easier to unit test
3. **Maintainability**: Clear data flow from UI to business logic
4. **Consistency**: Follows established .NET 6 patterns

### 9. Streaming Context Pattern (CRITICAL)
**RULE**: For list methods, use streaming context to pass parameters instead of method parameters. This applies to both Controller and ViewModel layers.

#### Method Naming Convention
- **Interface method**: `GetList{Description}()` (e.g., `GetListRateType()`)
- **Implementation method**: `GetList{Description}Async()` (e.g., `GetListRateTypeAsync()`)
- **Interface compliance**: `IAsyncEnumerable<{ResultDTO}> GetList{Description}()` throws `NotImplementedException`

#### Parameter Handling Rules
- **IClientHelper data** (CompanyId, UserId): Set in Controller using `R_BackGlobalVar`
- **Custom parameters**: Set in ViewModel using `R_FrontContext.R_SetStreamingContext()`
- **Streaming context**: Use `R_Utility.R_GetStreamingContext<Type>(ContextConstant.Key)` in Controller

#### ✅ Correct Controller Pattern
```csharp
[HttpPost]
public async IAsyncEnumerable<{ResultDTO}> GetList{Description}()
{
    var lcMethod = nameof(GetList{Description});
    using var activity = _activitySource.StartActivity(lcMethod);
    var loEx = new R_Exception();
    var loCls = new {ProgramName}Cls();
    List<{ResultDTO}> loRtn = new List<{ResultDTO}>();

    try
    {
        // Set IClientHelper data using R_BackGlobalVar
        R_BackGlobalVar.COMPANY_ID = "COMPANY_ID_VALUE";
        R_BackGlobalVar.USER_ID = "USER_ID_VALUE";
        
        // Get custom parameters from streaming context
        var loCustomParam = R_Utility.R_GetStreamingContext<{ParameterType}>(ContextConstant.{ParameterKey});

        _logger.LogInfo("Start method GetList{Description}Async in {0}", lcMethod);
        loRtn = await loCls.GetList{Description}Async();
    }
    catch (Exception ex)
    {
        loEx.Add(ex);
        _logger.LogError(loEx);
    }

    loEx.ThrowExceptionIfErrors();

    foreach ({ResultDTO} loItem in loRtn)
    {
        yield return loItem;
    }
}
```

#### ✅ Correct ViewModel Pattern
```csharp
public async Task GetList{Description}Async(string companyId, {OtherParameterType} otherParam)
{
    var loEx = new R_Exception();

    try
    {
        // Set streaming context for non-IClientHelper parameters
        R_FrontContext.R_SetStreamingContext("CCOMPANY_ID", companyId);
        R_FrontContext.R_SetStreamingContext("OTHER_PARAM_KEY", otherParam);

        var loResult = await _sam00110Model.GetList{Description}Async();

        List{Description} = new ObservableCollection<{ResultDTO}>(loResult.Data ?? new List<{ResultDTO}>());
    }
    catch (Exception ex)
    {
        loEx.Add(ex);
    }

    loEx.ThrowExceptionIfErrors();
}
```

#### ✅ Correct Model Pattern
```csharp
// Interface compliance method
public IAsyncEnumerable<{ResultDTO}> GetList{Description}()
{
    throw new System.NotImplementedException();
}

// Actual implementation method
public async Task<{ProgramName}ResultDTO<List<{ResultDTO}>>> GetList{Description}Async()
{
    var loEx = new R_Exception();
    {ProgramName}ResultDTO<List<{ResultDTO}>> loResult = new {ProgramName}ResultDTO<List<{ResultDTO}>>();

    try
    {
        R_HTTPClientWrapper.httpClientName = _HttpClientName;
        loResult.Data = await R_HTTPClientWrapper.R_APIRequestStreamingObject<{ResultDTO}>(
            _RequestServiceEndPoint,
            nameof(I{ProgramName}.GetList{Description}),
            _ModuleName,
            true,
            true
        );
    }
    catch (Exception ex)
    {
        loEx.Add(ex);
    }

    loEx.ThrowExceptionIfErrors();

    return loResult;
}
```

#### Key Benefits of Streaming Context Pattern
1. **Consistency**: All list methods follow the same pattern
2. **Scalability**: Easy to add new parameters without changing method signatures
3. **Maintainability**: Clear separation between IClientHelper and custom parameters
4. **Performance**: Streaming allows for better memory management with large datasets

## 🧱 Error Handling & Resource Message Rules

### 10. Error Retrieval Pattern (CRITICAL)

**Purpose**:
To ensure consistent localization and maintainability across all modules, **no hardcoded error message strings** are allowed.
All error messages must be stored and retrieved from **resource (.resx)** files.

### Standard Error Retrieval Method

**Location**: Inside `Back` project (usually within the Business Logic Class)

```csharp
private R_Error GetError(string pcErrorId)
{
    try
    {
        return R_Utility.R_GetError(typeof(Resources_Dummy_Class), pcErrorId);
    }
    catch (Exception)
    {
        throw;
    }
}
```

**Explanation:**

* `pcErrorId` = The message key defined in the resource file (e.g. `"ERR_INVALID_PARAMETER"`).
* `Resources_Dummy_Class` = Dummy class inside the same resource project, used to resolve the namespace for resource lookups.
* The `R_Utility.R_GetError()` method automatically retrieves the localized message text from:

  * `{ProgramName}BackResources_msgrsc.resx` (default)
  * `{ProgramName}BackResources_msgrsc.id.resx` (for Indonesian, etc.)

### ❌ Forbidden Pattern — Hardcoded Messages

**DO NOT:**

```csharp
throw new Exception("Invalid company ID.");
_logger.LogError("User ID not found");
```

### ✅ Correct Pattern — Use Resource-Based Messages

**DO:**

```csharp
R_Exception loEx = new R_Exception();
loEx.Add(GetError("ERR_INVALID_COMPANY_ID"));
_logger.LogError(GetError("ERR_USER_NOT_FOUND"));
```

## 📁 Project File Templates

### Back Project (.csproj)
```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net6.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

  <ItemGroup>
    <ProjectReference Include="..\..\..\COMMON\{module}\{ProgramName}Common\{ProgramName}Common.csproj" />
    <ProjectReference Include="..\{ProgramName}BackResources\{ProgramName}BackResources.csproj" />
  </ItemGroup>

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
    <Reference Include="BackExtension">
      <HintPath>..\..\..\..\..\SYSTEM\SOURCE\LIBRARY\MenuBack\BackExtension.dll</HintPath>
    </Reference>
  </ItemGroup>
</Project>
```

### Common Project (.csproj)
```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>netstandard2.1</TargetFramework>
    <ImplicitUsings>disable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

  <ItemGroup>
    <Reference Include="R_APICommonDTO">
      <HintPath>..\..\..\..\..\SYSTEM\SOURCE\LIBRARY\Back\R_APICommonDTO.dll</HintPath>
    </Reference>
    <Reference Include="R_CommonFrontBackAPI">
      <HintPath>..\..\..\..\..\SYSTEM\SOURCE\LIBRARY\Back\R_CommonFrontBackAPI.dll</HintPath>
    </Reference>
  </ItemGroup>
</Project>
```

### Service Project (.csproj)
```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net6.0</TargetFramework>
    <ImplicitUsings>disable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

  <ItemGroup>
    <FrameworkReference Include="Microsoft.AspNetCore.App" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\..\..\BACK\{module}\{ProgramName}Back\{ProgramName}Back.csproj" />
    <ProjectReference Include="..\..\..\COMMON\{module}\{ProgramName}Common\{ProgramName}Common.csproj" />
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
</Project>
```

### Model Project (.csproj)
```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>netstandard2.1</TargetFramework>
    <ImplicitUsings>disable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

  <ItemGroup>
    <ProjectReference Include="..\..\COMMON\{module}\{ProgramName}Common\{ProgramName}Common.csproj" />
    <ProjectReference Include="..\{ProgramName}FrontResources\{ProgramName}FrontResources.csproj" />
  </ItemGroup>

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
</Project>
```

## 🗄️ Database Parameter Management

### Critical Pattern: Parameter Handling
- **Use**: `loDb.R_AddCommandParameter(loCmd, "@ParameterName", DbType, size, value)` 
- **NOT**: `loCmd.AddDbCommandParameter` (deprecated/incorrect)
- **Always**: Call `loCmd.Parameters.Clear()` before reusing command objects
- **Method signature**: 5 parameters - command object, parameter name, DbType, size (int), value

## 🔄 Batch Process Implementation Patterns

### R_IBatchProcess Interface Implementation
**RULE**: Implement both sync and async methods for batch processing

```csharp
public class {ProgramName}Cls : R_BusinessObjectAsync<{ProgramName}DTO>, R_IBatchProcess
{
    // Sync method required by interface
    public void R_BatchProcess(R_BatchProcessPar poBatchProcessPar)
    {
        var lcMethod = nameof(R_BatchProcess);
        using var activity = _activitySource.StartActivity(lcMethod);
        var loEx = new R_Exception();

        try
        {
            _ = _BatchProcessAsync(poBatchProcessPar); // Run and forget
        }
        catch (Exception ex)
        {
            loEx.Add(ex);
            _logger.LogError(loEx);
        }

        loEx.ThrowExceptionIfErrors();
    }

    // Async implementation for actual work
    private async Task _BatchProcessAsync(R_BatchProcessPar poBatchProcessPar)
    {
        // Implementation details...
    }
}
```

### Batch Process Data Deserialization
**RULE**: Use R_NetCoreUtility for deserializing batch data

```csharp
✅ CORRECT:
var loObject = R_NetCoreUtility.R_DeserializeObjectFromByte<List<{ProgramName}ExcelDTO>>(poBatchProcessPar.BigObject);

❌ WRONG:
var loObject = R_Utility.Deserialize<List<{ProgramName}ExcelDTO>>(poBatchProcessPar.BigObject);
```

### Batch Process Transaction Management
**RULE**: Use TransactionScope with async flow option for batch processing

```csharp
using var transScope = new TransactionScope(TransactionScopeOption.Required, TransactionScopeAsyncFlowOption.Enabled);
// ... batch operations ...
transScope.Complete();
```

## 🎨 UI Components & Navigation Patterns

### Navigation Component Usage (CRITICAL)
**RULE**: Use the correct navigation component based on purpose

#### Event Arguments Properties (CRITICAL)
**Available Properties in BeforeOpen Events:**

**For R_InstantiateDockEventArgs and R_BeforeOpenTabPageEventArgs:**
- `TargetPageType` - Type of the page to open (use when referencing pages in same project)
- `Parameter` - Object to pass to R_Page.R_Init_From_Master(object? poParameter) (optional)
- `FormAccess` - Override form access (rarely used)
- `Cancel` - Cancel the operation (R_InstantiateDockEventArgs only)

**For R_BeforeOpenModalEventArgsBase (Detail, Popup, Lookup, Find):**
- `TargetPageType` - Type of the page to open (use when referencing pages in same project)
- `PageNamespace` - Namespace of the page to open (PREFERRED - use when referencing .razor in other front projects)
- `Parameter` - Object to pass to R_Page.R_Init_From_Master(object? poParameter) (optional)
- `PageTitle` - Override page title (rarely used)
- `FormAccess` - Override form access (rarely used)

**Available Properties in AfterOpen Events:**
- `Result` - Return value from the navigation component (can be any logic, not just conductor data)
- `Success` - Success status (R_AfterOpenPopupEventArgs only)

#### 1. R_PredefinedDock - For tabs shown on page load, cannot be closed
```razor
<R_PredefinedDock R_InstantiateDock="@R_InstantiateDock"
                  Title="Predefined Dock Title"
                  R_AfterOpenPredefinedDock="R_AfterOpenPredefinedDock" />
```

```csharp
private void R_InstantiateDock(R_InstantiateDockEventArgs eventArgs)
{
    // R_InstantiateDockEventArgs does NOT have PageNamespace - only TargetPageType
    eventArgs.TargetPageType = typeof(SubProgramPage);
    
    // Optional: Pass parameter to R_Page.R_Init_From_Master()
    eventArgs.Parameter = _conductorRef.R_GetCurrentData();
}

private async Task R_AfterOpenPredefinedDock(R_AfterOpenPredefinedDockEventArgs eventArgs)
{
    if (eventArgs.Result is null) return;
    // You can do any logic here, not just conductor data
    await _conductorRef.R_SetCurrentData(eventArgs.Result);
}
```

#### 2. R_Detail - For tabs shown on click, can be closed
```razor
<R_Detail R_Before_Open_Detail="@R_Before_Open_Detail"
          R_After_Open_Detail="@R_After_Open_Detail">
    Detail Text
</R_Detail>
```

```csharp
private void R_Before_Open_Detail(R_BeforeOpenDetailEventArgs eventArgs)
{
    // PREFERRED: Use PageNamespace for referencing .razor in other front projects
    eventArgs.PageNamespace = "OtherProject.Pages.DetailPage";
    // OR use TargetPageType for pages in same project
    // eventArgs.TargetPageType = typeof(DetailPage);
    
    // Optional: Pass parameter to R_Page.R_Init_From_Master()
    eventArgs.Parameter = _conductorRef.R_GetCurrentData();
}

private async Task R_After_Open_Detail(R_AfterOpenDetailEventArgs eventArgs)
{
    if (eventArgs.Result is null) return;
    // You can do any logic here, not just conductor data
    await _conductorRef.R_SetCurrentData(eventArgs.Result);
}
```

#### 3. R_Popup - For showing R_Page components in modal windows

```razor
<R_Popup R_Before_Open_Popup="@R_Before_Open_Popup"
         R_After_Open_Popup="@R_After_Open_Popup"
         >Popup Text</R_Popup>
```

```csharp
public void R_Before_Open_Popup(R_BeforeOpenPopupEventArgs eventArgs)
{
    // PREFERRED: Use PageNamespace for referencing .razor in other front projects
    eventArgs.PageNamespace = "OtherProject.Pages.PopupPage";
    // OR use TargetPageType for pages in same project
    // eventArgs.TargetPageType = typeof(PopupPage);
    
    // Optional: Pass parameter to R_Page.R_Init_From_Master()
    eventArgs.Parameter = _conductorRef?.R_GetCurrentData();
}

public async Task R_After_Open_Popup(R_AfterOpenPopupEventArgs eventArgs)
{
    if (!eventArgs.Success || eventArgs.Result is null) return;
    // You can do any logic here, not just conductor data
    if (_conductorRef is not null)
        await _conductorRef.R_SetCurrentData(eventArgs.Result);
    // For grid refresh after upload operations
    if (_gridRef is not null)
        await _gridRef.R_RefreshGrid(null);
}
```

#### 4. R_Lookup - For lookup pattern (selecting records)
```razor
<R_Lookup R_Before_Open_Lookup="@R_Before_Open_Lookup"
          R_After_Open_Lookup="@R_After_Open_Lookup"
          >Lookup Text</R_Lookup>
```

```csharp
private void R_Before_Open_Lookup(R_BeforeOpenLookupEventArgs eventArgs)
{
    // PREFERRED: Use PageNamespace for referencing .razor in other front projects
    eventArgs.PageNamespace = "OtherProject.Pages.LookupPage";
    // OR use TargetPageType for pages in same project
    // eventArgs.TargetPageType = typeof(LookupPage);
    
    // Optional: Pass parameter to R_Page.R_Init_From_Master()
    eventArgs.Parameter = "Dari Lookup";
    
    // Rarely used: Override page title
    // eventArgs.PageTitle = "Title dari event argument";
}

public async Task R_After_Open_Lookup(R_AfterOpenLookupEventArgs eventArgs)
{
    if (eventArgs.Result is null) return;
    // You can do any logic here, not just conductor data
    await _conductorRef.R_SetCurrentData(eventArgs.Result);
}
```

#### 5. R_Find - For finding/selecting records
```razor
<R_Find R_FindModel="@R_FindModel" // This is to change caller R_Page Access (OPTIONAL)
        R_Before_Open_Find="@R_Before_Open_Find"
        R_After_Open_Find="@R_After_Open_Find"
        >Find Text</R_Find>
```

```csharp
private void R_Before_Open_Find(R_BeforeOpenFindEventArgs eventArgs)
{
    // PREFERRED: Use PageNamespace for referencing .razor in other front projects
    eventArgs.PageNamespace = "OtherProject.Pages.FindPage";
    // OR use TargetPageType for pages in same project
    // eventArgs.TargetPageType = typeof(FindPage);
    
    // Optional: Pass parameter to R_Page.R_Init_From_Master()
    eventArgs.Parameter = "Dari Find";
    
    // Rarely used: Override page title
    // eventArgs.PageTitle = "Title dari event argument";
}

private void R_FindModel(R_FindModelEventArgs eventArgs)
{
    eventArgs.FindModel = R_eFindModel.Normal; // or NoDisplay, ViewOnly
}

public async Task R_After_Open_Find(R_AfterOpenFindEventArgs eventArgs)
{
    if (eventArgs.Result == null) return;
    // You can do any logic here, not just conductor data
    var loData = (ProductDTO)eventArgs.Result;
    await _conductorRef.R_SetCurrentData(loData);
}
```

#### 6. R_TabPage - For tab navigation within same page
```razor
<R_TabStrip>
    <R_TabStripTab Title="Tab 1">
        <!-- Content -->
    </R_TabStripTab>
    <R_TabStripTab Title="Tab 2">
        <R_TabPage R_After_Open_TabPage="R_After_Open_TabPage" 
                   R_Before_Open_TabPage="R_Before_Open_TabPage"></R_TabPage>
    </R_TabStripTab>
</R_TabStrip>
```

```csharp
private void R_Before_Open_TabPage(R_BeforeOpenTabPageEventArgs eventArgs)
{
    // R_BeforeOpenTabPageEventArgs does NOT have PageNamespace - only TargetPageType
    eventArgs.TargetPageType = typeof(TabPage);
    
    // Optional: Pass parameter to R_Page.R_Init_From_Master()
    var loParam = _conductorRef.R_GetCurrentData();
    eventArgs.Parameter = loParam;
}

private async Task R_After_Open_TabPage(R_AfterOpenTabPageEventArgs eventArgs)
{
    if (eventArgs.Result is null) return;
    // You can do any logic here, not just conductor data
    await _conductorRef.R_SetCurrentData(eventArgs.Result);
}
```

#### 7. Service-Based Navigation (Alternative to R_Button)
```csharp
[Inject] public R_PopupService PopupService { get; set; }
[Inject] public R_LookupService LookupService { get; set; }

// Popup from service
private async Task popupButtonOnClick()
{
    var loPopupSettings = new R_PopupSettings
    {
        PageTitle = "Custom Title Override Only",
        Page = this,
    };

    var loResult = await PopupService.Show(typeof(PopupPage), 
                                          _conductorRef.R_GetCurrentData(), 
                                          poPopupSettings: loPopupSettings);
    
    var loData = (ProductDTO)loResult.Result;
    await _conductorRef.R_SetCurrentData(loData);
}

// Lookup from service
private async Task lookupButtonOnClick()
{
    var loLookupSettings = new R_LookupSettings
    {
        PageTitle = "Custom Title Override Only",
        Page = this,
    };

    var loResult = await LookupService.Show(typeof(LookupPage), 
                                           "Dari LookupService", 
                                           loLookupSettings);
}
```

**❌ NEVER USE R_Button for navigation** - Always use appropriate navigation components above or service-based navigation.

### MessageBox Dialog Usage (CRITICAL)
**RULE**: Use MessageBoxService for dialogs, NOT R_Popup. R_Popup is for R_Page components only.

#### MessageBoxService Usage
```csharp
[Inject] public R_MessageBoxService MessageBoxService { get; set; }

// Simple OK dialog
private async Task ShowOKDialog()
{
    await MessageBoxService.Show("Title", "Message", R_eMessageBoxButtonType.OK);
}

// Yes/No dialog
private async Task ShowYesNoDialog()
{
    var result = await MessageBoxService.Show("Title", "Message", R_eMessageBoxButtonType.YesNo);
    if (result == R_eMessageBoxResult.Yes)
    {
        // Handle Yes
    }
}

// OK/Cancel dialog
private async Task ShowOKCancelDialog()
{
    var result = await MessageBoxService.Show("Title", "Message", R_eMessageBoxButtonType.OKCancel);
    if (result == R_eMessageBoxResult.OK)
    {
        // Handle OK
    }
}

// Yes/No/Cancel dialog
private async Task ShowYesNoCancelDialog()
{
    var result = await MessageBoxService.Show("Title", "Message", R_eMessageBoxButtonType.YesNoCancel);
    switch (result)
    {
        case R_eMessageBoxResult.Yes:
            // Handle Yes
            break;
        case R_eMessageBoxResult.No:
            // Handle No
            break;
        case R_eMessageBoxResult.Cancel:
            // Handle Cancel
            break;
    }
}
```

#### Available MessageBox Button Types
Based on R_MessageBoxContainer.razor:
- `R_eMessageBoxButtonType.OK` - Shows OK button only
- `R_eMessageBoxButtonType.OKCancel` - Shows OK and Cancel buttons
- `R_eMessageBoxButtonType.YesNo` - Shows Yes and No buttons
- `R_eMessageBoxButtonType.YesNoCancel` - Shows Yes, No, and Cancel buttons

#### Available MessageBox Results
- `R_eMessageBoxResult.OK` - User clicked OK
- `R_eMessageBoxResult.Yes` - User clicked Yes
- `R_eMessageBoxResult.No` - User clicked No
- `R_eMessageBoxResult.Cancel` - User clicked Cancel or closed dialog

### Conductor Source Patterns (CRITICAL)
**RULE**: Conductor source depends on which conductor controls the access (A,U,D,P,V) for the operation

#### Conductor Source Parameter Mapping
- **R_Conductor** → Use `R_ConductorSource="@_conductorRef"` (for form-based access control)
- **R_ConductorGrid** → Use `R_ConductorGridSource="@_conductorGridRef"` (for grid-based access control)

#### When to Use Each Conductor Source

##### Use R_ConductorGridSource when:
- **R_Grid performs CRUD operations** (R_eGridType.Original or R_eGridType.Batch)
- **Grid controls access** to Add, Update, Delete, Print, View operations
- **Components that implement R_IConductorControl operation depends on grid state** (e.g., you can only open popup if grid is not in CRUD mode)

```razor
<!-- Grid with CRUD operations controls access -->
<R_Grid @ref="_gridRef"
        R_ConductorGridSource="@_conductorGridRef"
        R_GridType="@R_eGridType.Original"
        AllowAddNewRow
        AllowEditRow
        AllowDeleteRow
        ... />

<!-- Popup uses same conductor grid for access control -->
<R_Popup R_ConductorGridSource="@_conductorGridRef"
         R_Before_Open_Popup="@R_Before_Open_Popup"
         R_After_Open_Popup="@R_After_Open_Popup"
         >
    @_localizer["_PopupText"]"
</R_Popup>
```

##### Use R_ConductorSource when:
- **Form-based layout** controls access (no grid CRUD)
- **R_Grid is Navigator type** (R_eGridType.Navigator) - grid only for selection
- **No R_Grid at all** - pure form-based page
- **Form controls access** to operations

```razor
<!-- Form-based conductor controls access -->
<R_Conductor @ref="_conductorRef" />

<!-- Popup uses conductor for access control -->
<R_Popup R_ConductorSource="@_conductorRef"
         R_Before_Open_Popup="@R_Before_Open_Popup"
         R_After_Open_Popup="@R_After_Open_Popup"
         >
    @_localizer["_PopupText"]
</R_Popup>
```

##### No Conductor Source when:
- **Component always enabled** regardless of CRUD mode
- **No access control needed** for the operation
- **Independent functionality** not tied to form/grid state

```razor
<!-- Always enabled - no conductor source needed -->
<R_Popup R_Before_Open_Popup="@R_Before_Open_Popup"
         R_After_Open_Popup="@R_After_Open_Popup">
    @_localizer["_PopupText"]
</R_Popup>
```

#### Code-Behind Pattern
```csharp
public partial class MainPage : R_Page
{
    // For grid-based access control
    private R_ConductorGrid? _conductorGridRef;  // Controls grid CRUD access
    private R_Grid<DataDTO>? _gridRef;           // Performs grid operations
    
    // For form-based access control  
    private R_Conductor? _conductorRef;          // Controls form access
    
    public void R_Before_Open_Popup(R_BeforeOpenPopupEventArgs eventArgs)
    {
        eventArgs.TargetPageType = typeof(UploadPage);
        // Optional: Pass parameter based on conductor type
        // eventArgs.Parameter = _conductorGridRef?.R_GetCurrentData();
        // OR
        // eventArgs.Parameter = _conductorRef?.R_GetCurrentData();
    }

    public async Task R_After_Open_Popup(R_AfterOpenPopupEventArgs eventArgs)
    {
        if (!eventArgs.Success || eventArgs.Result is null) return;
        // Refresh grid after operations if needed
        if (_gridRef is not null)
            await _gridRef.R_RefreshGrid(null);
    }
}
```

## ❌ Common Mistakes to Avoid

1. ❌ **Logger in Common project** → ✅ Put in Back project
2. ❌ **Activity in Common project** → ✅ Put in Back project
3. ❌ **Custom Logger implementation** → ✅ Just inherit from R_NetCoreLoggerBase<T>
4. ❌ **Custom Activity implementation** → ✅ Just inherit from R_ActivitySourceBase
5. ❌ **R_IServiceCRUDBase** → ✅ Use R_IServiceCRUDAsyncBase
6. ❌ **Manual connection disposal** → ✅ Use `using var` statements
7. ❌ **Forgetting loDb = null in finally** → ✅ Always add
8. ❌ **Microsoft.NET.Sdk.Web** for Service → ✅ Use Microsoft.NET.Sdk + FrameworkReference
9. ❌ **Resources in subfolders** → ✅ Resources in root folder of resource projects
10. ❌ **DTOs in Back project** → ✅ DTOs ONLY in Common project
11. ❌ **Business Logic in Front project** → ✅ Business Logic should always be in Model Project as ViewModel, Front Project is how you show the data from ViewModel
12. ❌ **Creating separate projects for sub-programs** → ✅ Sub-programs should share the same project structure as main program
13. ❌ **Creating separate Model classes unnecessarily** → ✅ Only create separate Model classes if using different Controllers
14. ❌ **Using R_Button for navigation** → ✅ Use R_Popup, R_PredefinedDock, R_Detail, or R_Lookup based on purpose
15. ❌ **Wrong navigation component usage** → ✅ R_PredefinedDock (page load, can't close), R_Detail (on click, can close), R_Popup (R_Page modal), R_Lookup (lookup pattern)
16. ❌ **Using R_Popup for dialogs** → ✅ Use MessageBoxService for dialogs, R_Popup only for R_Page components
17. ❌ **Missing R_IExcel dependency** → ✅ Always add R_BlazorFrontEnd.Excel reference for batch processing
18. ❌ **Missing R_ProcessAndUploadFront dependency** → ✅ Always add R_ProcessAndUploadFront reference for batch processing
19. ❌ **Using R_FrontGlobalVar in ViewModels** → ✅ Use IClientHelper injection in .razor.cs and pass values as parameters to ViewModel methods
20. ❌ **Passing parameters to list methods** → ✅ Use streaming context pattern with R_FrontContext.R_SetStreamingContext() for custom parameters
21. ❌ **Using R_Context directly in ViewModels** → ✅ Use R_FrontContext.R_SetStreamingContext() static method
22. ❌ **Wrong method naming for list methods** → ✅ Use GetList{Description}() for interface, GetList{Description}Async() for implementation
23. ❌ **Using wrong conductor source for access control** → ✅ Use R_ConductorGridSource when grid controls CRUD access, R_ConductorSource when form controls access
24. ❌ **Calling R_SaveBatch on R_ConductorGrid** → ✅ Call R_SaveBatch on R_Grid component, not R_ConductorGrid
25. ❌ **Adding conductor source when component is always enabled** → ✅ Only add conductor source when component needs access control (A,U,D,P,V)
26. ❌ **Using streaming context for IClientHelper data in Service layer** → ✅ Use R_BackGlobalVar.COMPANY_ID directly (IClientHelper sets it automatically)
27. ❌ **Setting R_BackGlobalVar values manually in Service layer** → ✅ IClientHelper automatically sets R_BackGlobalVar values, only read from them
28. ❌ **Missing R_APIBackEnd reference in Service project** → ✅ Always add R_APIBackEnd reference to access R_BackGlobalVar
29. ❌ **Using ContextConstant without proper reference** → ✅ Only use streaming context for custom parameters, not IClientHelper data
30. ❌ **Using underscore prefix for public properties in ViewModels** → ✅ Public properties (including ViewModel fields) should use PascalCase, not underscore prefix
31. ❌ **Mixing naming patterns within same scope** → ✅ Be consistent: Private use `_snakeCase`, Public use `PascalCase`, Local use `l{typePrefix}`
32. ❌ **Not updating all references when renaming variables** → ✅ Always search and replace systematically to update all usages
33. ❌ **Assuming all ViewModel fields are private** → ✅ Check access modifier - public fields for data binding should use PascalCase

## Multi-Program Project Structure (CRITICAL)

### When Multiple Programs Share Same Module
**RULE**: Sub-programs (like SAM00110) should be integrated into the main program's project structure, NOT created as separate projects.

**CORRECT Structure:**
```
SAM00100Model/
├── SAM00100Model.cs          → Main program model
├── SAM00110Model.cs          → Sub-program model (same project)
└── VMs/
    ├── SAM00100ViewModel.cs  → Main program view model
    ├── SAM00110ViewModel.cs  → Sub-program view model (same project)
    └── SAM00100UploadViewModel.cs → Upload view model

SAM00100FrontResources/
├── SAM00100FrontResources_msgrsc.resx     → Contains ALL resources
├── SAM00100FrontResources_msgrsc.id.resx  → Contains ALL resources
└── Resources_Dummy_Class.cs

SAM00100Front/
├── SAM00100.razor           → Main program page
├── SAM00110.razor           → Sub-program page (same project)
├── SAM00100Upload.razor     → Upload page (same project)
└── SAM00100Front.csproj     → References ALL components
```

**WRONG Structure:**
```
❌ SAM00100Model/ (separate)
❌ SAM00110Model/ (separate) 
❌ SAM00100FrontResources/ (separate)
❌ SAM00110FrontResources/ (separate)
```

### Service Endpoint Constants Pattern
**RULE**: Create separate Model classes ONLY if they use different Controllers. If same controller, use one Model class.

**Why**: Controllers use `[Route("api/[controller]/[action]")]` - different controllers = different service endpoints.

```csharp
// Different Controllers = Separate Models
// SAM00100Controller → SAM00100Model.cs
private const string DEFAULT_SERVICEPOINT_NAME = "api/SAM00100";

// SAM00110Controller → SAM00110Model.cs  
private const string DEFAULT_SERVICEPOINT_NAME = "api/SAM00110";

// Same Controller = Same Model
// Both use SAM00100Controller → Use SAM00100Model.cs only
```

### Conductor Source Patterns (CRITICAL)
**RULE**: Conductor source depends on which conductor controls the access (A,U,D,P,V) for the operation

#### Conductor Source Parameter Mapping
- **R_Conductor** → Use `R_ConductorSource="@_conductorRef"` (for form-based access control)
- **R_ConductorGrid** → Use `R_ConductorGridSource="@_conductorGridRef"` (for grid-based access control)

#### When to Use Each Conductor Source

##### Use R_ConductorGridSource when:
- **R_Grid performs CRUD operations** (R_eGridType.Original or R_eGridType.Batch)
- **Grid controls access** to Add, Update, Delete, Print, View operations
- **Components that implement R_IConductorControl operation depends on grid state** (e.g., you can only open popup if grid is not in CRUD mode)

```razor
<!-- Grid with CRUD operations controls access -->
<R_Grid @ref="_gridRef"
        R_ConductorGridSource="@_conductorGridRef"
        R_GridType="@R_eGridType.Original"
        AllowAddNewRow
        AllowEditRow
        AllowDeleteRow
        ... />

<!-- Popup uses same conductor grid for access control -->
<R_Popup R_ConductorGridSource="@_conductorGridRef"
         R_Before_Open_Popup="@R_Before_Open_Popup"
         R_After_Open_Popup="@R_After_Open_Popup"
         >
    @_localizer["_PopupText"]"
</R_Popup>
```

##### Use R_ConductorSource when:
- **Form-based layout** controls access (no grid CRUD)
- **R_Grid is Navigator type** (R_eGridType.Navigator) - grid only for selection
- **No R_Grid at all** - pure form-based page
- **Form controls access** to operations

```razor
<!-- Form-based conductor controls access -->
<R_Conductor @ref="_conductorRef" />

<!-- Popup uses conductor for access control -->
<R_Popup R_ConductorSource="@_conductorRef"
         R_Before_Open_Popup="@R_Before_Open_Popup"
         R_After_Open_Popup="@R_After_Open_Popup"
         >
    @_localizer["_PopupText"]
</R_Popup>
```

##### No Conductor Source when:
- **Component always enabled** regardless of CRUD mode
- **No access control needed** for the operation
- **Independent functionality** not tied to form/grid state

```razor
<!-- Always enabled - no conductor source needed -->
<R_Popup R_Before_Open_Popup="@R_Before_Open_Popup"
         R_After_Open_Popup="@R_After_Open_Popup">
    @_localizer["_PopupText"]
</R_Popup>
```

#### Code-Behind Pattern
```csharp
public partial class MainPage : R_Page
{
    // For grid-based access control
    private R_ConductorGrid? _conductorGridRef;  // Controls grid CRUD access
    private R_Grid<DataDTO>? _gridRef;           // Performs grid operations
    
    // For form-based access control  
    private R_Conductor? _conductorRef;          // Controls form access
    
    public void R_Before_Open_Popup(R_BeforeOpenPopupEventArgs eventArgs)
    {
        eventArgs.TargetPageType = typeof(UploadPage);
        // Optional: Pass parameter based on conductor type
        // eventArgs.Parameter = _conductorGridRef?.R_GetCurrentData();
        // OR
        // eventArgs.Parameter = _conductorRef?.R_GetCurrentData();
    }

    public async Task R_After_Open_Popup(R_AfterOpenPopupEventArgs eventArgs)
    {
        if (!eventArgs.Success || eventArgs.Result is null) return;
        // Refresh grid after operations if needed
        if (_gridRef is not null)
            await _gridRef.R_RefreshGrid(null);
    }
}
```

### Navigation Component Usage (CRITICAL)
**RULE**: Use the correct navigation component based on purpose

#### Event Arguments Properties (CRITICAL)
**Available Properties in BeforeOpen Events:**

**For R_InstantiateDockEventArgs and R_BeforeOpenTabPageEventArgs:**
- `TargetPageType` - Type of the page to open (use when referencing pages in same project)
- `Parameter` - Object to pass to R_Page.R_Init_From_Master(object? poParameter) (optional)
- `FormAccess` - Override form access (rarely used)
- `Cancel` - Cancel the operation (R_InstantiateDockEventArgs only)

**For R_BeforeOpenModalEventArgsBase (Detail, Popup, Lookup, Find):**
- `TargetPageType` - Type of the page to open (use when referencing pages in same project)
- `PageNamespace` - Namespace of the page to open (PREFERRED - use when referencing .razor in other front projects)
- `Parameter` - Object to pass to R_Page.R_Init_From_Master(object? poParameter) (optional)
- `PageTitle` - Override page title (rarely used)
- `FormAccess` - Override form access (rarely used)

**Available Properties in AfterOpen Events:**
- `Result` - Return value from the navigation component (can be any logic, not just conductor data)
- `Success` - Success status (R_AfterOpenPopupEventArgs only)

#### 1. R_PredefinedDock - For tabs shown on page load, cannot be closed
```razor
<R_PredefinedDock R_InstantiateDock="@R_InstantiateDock"
                  Title="Predefined Dock Title"
                  R_AfterOpenPredefinedDock="R_AfterOpenPredefinedDock" />
```

```csharp
private void R_InstantiateDock(R_InstantiateDockEventArgs eventArgs)
{
    // R_InstantiateDockEventArgs does NOT have PageNamespace - only TargetPageType
    eventArgs.TargetPageType = typeof(SubProgramPage);
    
    // Optional: Pass parameter to R_Page.R_Init_From_Master()
    eventArgs.Parameter = _conductorRef.R_GetCurrentData();
}

private async Task R_AfterOpenPredefinedDock(R_AfterOpenPredefinedDockEventArgs eventArgs)
{
    if (eventArgs.Result is null) return;
    // You can do any logic here, not just conductor data
    await _conductorRef.R_SetCurrentData(eventArgs.Result);
}
```

#### 2. R_Detail - For tabs shown on click, can be closed
```razor
<R_Detail R_Before_Open_Detail="@R_Before_Open_Detail"
          R_After_Open_Detail="@R_After_Open_Detail">
    Detail Text
</R_Detail>
```

```csharp
private void R_Before_Open_Detail(R_BeforeOpenDetailEventArgs eventArgs)
{
    // PREFERRED: Use PageNamespace for referencing .razor in other front projects
    eventArgs.PageNamespace = "OtherProject.Pages.DetailPage";
    // OR use TargetPageType for pages in same project
    // eventArgs.TargetPageType = typeof(DetailPage);
    
    // Optional: Pass parameter to R_Page.R_Init_From_Master()
    eventArgs.Parameter = _conductorRef.R_GetCurrentData();
}

private async Task R_After_Open_Detail(R_AfterOpenDetailEventArgs eventArgs)
{
    if (eventArgs.Result is null) return;
    // You can do any logic here, not just conductor data
    await _conductorRef.R_SetCurrentData(eventArgs.Result);
}
```

#### 3. R_Popup - For showing R_Page components in modal windows

```razor
<R_Popup R_Before_Open_Popup="@R_Before_Open_Popup"
         R_After_Open_Popup="@R_After_Open_Popup"
         >Popup Text</R_Popup>
```


```csharp
public void R_Before_Open_Popup(R_BeforeOpenPopupEventArgs eventArgs)
{
    // PREFERRED: Use PageNamespace for referencing .razor in other front projects
    eventArgs.PageNamespace = "OtherProject.Pages.PopupPage";
    // OR use TargetPageType for pages in same project
    // eventArgs.TargetPageType = typeof(PopupPage);
    
    // Optional: Pass parameter to R_Page.R_Init_From_Master()
    eventArgs.Parameter = _conductorRef?.R_GetCurrentData();
}

public async Task R_After_Open_Popup(R_AfterOpenPopupEventArgs eventArgs)
{
    if (!eventArgs.Success || eventArgs.Result is null) return;
    // You can do any logic here, not just conductor data
    if (_conductorRef is not null)
        await _conductorRef.R_SetCurrentData(eventArgs.Result);
    // For grid refresh after upload operations
    if (_gridRef is not null)
        await _gridRef.R_RefreshGrid(null);
}
```

#### 4. R_Lookup - For lookup pattern (selecting records)
```razor
<R_Lookup R_Before_Open_Lookup="@R_Before_Open_Lookup"
          R_After_Open_Lookup="@R_After_Open_Lookup"
          >Lookup Text</R_Lookup>
```

```csharp
private void R_Before_Open_Lookup(R_BeforeOpenLookupEventArgs eventArgs)
{
    // PREFERRED: Use PageNamespace for referencing .razor in other front projects
    eventArgs.PageNamespace = "OtherProject.Pages.LookupPage";
    // OR use TargetPageType for pages in same project
    // eventArgs.TargetPageType = typeof(LookupPage);
    
    // Optional: Pass parameter to R_Page.R_Init_From_Master()
    eventArgs.Parameter = "Dari Lookup";
    
    // Rarely used: Override page title
    // eventArgs.PageTitle = "Title dari event argument";
}

public async Task R_After_Open_Lookup(R_AfterOpenLookupEventArgs eventArgs)
{
    if (eventArgs.Result is null) return;
    // You can do any logic here, not just conductor data
    await _conductorRef.R_SetCurrentData(eventArgs.Result);
}
```

#### 5. R_Find - For finding/selecting records
```razor
<R_Find R_FindModel="@R_FindModel" // This is to change caller R_Page Access (OPTIONAL)
        R_Before_Open_Find="@R_Before_Open_Find"
        R_After_Open_Find="@R_After_Open_Find"
        >Find Text</R_Find>
```

```csharp
private void R_Before_Open_Find(R_BeforeOpenFindEventArgs eventArgs)
{
    // PREFERRED: Use PageNamespace for referencing .razor in other front projects
    eventArgs.PageNamespace = "OtherProject.Pages.FindPage";
    // OR use TargetPageType for pages in same project
    // eventArgs.TargetPageType = typeof(FindPage);
    
    // Optional: Pass parameter to R_Page.R_Init_From_Master()
    eventArgs.Parameter = "Dari Find";
    
    // Rarely used: Override page title
    // eventArgs.PageTitle = "Title dari event argument";
}

private void R_FindModel(R_FindModelEventArgs eventArgs)
{
    eventArgs.FindModel = R_eFindModel.Normal; // or NoDisplay, ViewOnly
}

public async Task R_After_Open_Find(R_AfterOpenFindEventArgs eventArgs)
{
    if (eventArgs.Result == null) return;
    // You can do any logic here, not just conductor data
    var loData = (ProductDTO)eventArgs.Result;
    await _conductorRef.R_SetCurrentData(loData);
}
```

#### 6. R_TabPage - For tab navigation within same page
```razor
<R_TabStrip>
    <R_TabStripTab Title="Tab 1">
        <!-- Content -->
    </R_TabStripTab>
    <R_TabStripTab Title="Tab 2">
        <R_TabPage R_After_Open_TabPage="R_After_Open_TabPage" 
                   R_Before_Open_TabPage="R_Before_Open_TabPage"></R_TabPage>
    </R_TabStripTab>
</R_TabStrip>
```

```csharp
private void R_Before_Open_TabPage(R_BeforeOpenTabPageEventArgs eventArgs)
{
    // R_BeforeOpenTabPageEventArgs does NOT have PageNamespace - only TargetPageType
    eventArgs.TargetPageType = typeof(TabPage);
    
    // Optional: Pass parameter to R_Page.R_Init_From_Master()
    var loParam = _conductorRef.R_GetCurrentData();
    eventArgs.Parameter = loParam;
}

private async Task R_After_Open_TabPage(R_AfterOpenTabPageEventArgs eventArgs)
{
    if (eventArgs.Result is null) return;
    // You can do any logic here, not just conductor data
    await _conductorRef.R_SetCurrentData(eventArgs.Result);
}
```

#### 7. Service-Based Navigation (Alternative to R_Button)
```csharp
[Inject] public R_PopupService PopupService { get; set; }
[Inject] public R_LookupService LookupService { get; set; }

// Popup from service
private async Task popupButtonOnClick()
{
    var loPopupSettings = new R_PopupSettings
    {
        PageTitle = "Custom Title Override Only",
        Page = this,
    };

    var loResult = await PopupService.Show(typeof(PopupPage), 
                                          _conductorRef.R_GetCurrentData(), 
                                          poPopupSettings: loPopupSettings);
    
    var loData = (ProductDTO)loResult.Result;
    await _conductorRef.R_SetCurrentData(loData);
}

// Lookup from service
private async Task lookupButtonOnClick()
{
    var loLookupSettings = new R_LookupSettings
    {
        PageTitle = "Custom Title Override Only",
        Page = this,
    };

    var loResult = await LookupService.Show(typeof(LookupPage), 
                                           "Dari LookupService", 
                                           loLookupSettings);
}
```

**❌ NEVER USE R_Button for navigation** - Always use appropriate navigation components above or service-based navigation.

### MessageBox Dialog Usage (CRITICAL)
**RULE**: Use MessageBoxService for dialogs, NOT R_Popup. R_Popup is for R_Page components only.

#### MessageBoxService Usage
```csharp
[Inject] public R_MessageBoxService MessageBoxService { get; set; }

// Simple OK dialog
private async Task ShowOKDialog()
{
    await MessageBoxService.Show("Title", "Message", R_eMessageBoxButtonType.OK);
}

// Yes/No dialog
private async Task ShowYesNoDialog()
{
    var result = await MessageBoxService.Show("Title", "Message", R_eMessageBoxButtonType.YesNo);
    if (result == R_eMessageBoxResult.Yes)
    {
        // Handle Yes
    }
}

// OK/Cancel dialog
private async Task ShowOKCancelDialog()
{
    var result = await MessageBoxService.Show("Title", "Message", R_eMessageBoxButtonType.OKCancel);
    if (result == R_eMessageBoxResult.OK)
    {
        // Handle OK
    }
}

// Yes/No/Cancel dialog
private async Task ShowYesNoCancelDialog()
{
    var result = await MessageBoxService.Show("Title", "Message", R_eMessageBoxButtonType.YesNoCancel);
    switch (result)
    {
        case R_eMessageBoxResult.Yes:
            // Handle Yes
            break;
        case R_eMessageBoxResult.No:
            // Handle No
            break;
        case R_eMessageBoxResult.Cancel:
            // Handle Cancel
            break;
    }
}
```

#### Available MessageBox Button Types
Based on R_MessageBoxContainer.razor:
- `R_eMessageBoxButtonType.OK` - Shows OK button only
- `R_eMessageBoxButtonType.OKCancel` - Shows OK and Cancel buttons
- `R_eMessageBoxButtonType.YesNo` - Shows Yes and No buttons
- `R_eMessageBoxButtonType.YesNoCancel` - Shows Yes, No, and Cancel buttons

#### Available MessageBox Results
- `R_eMessageBoxResult.OK` - User clicked OK
- `R_eMessageBoxResult.Yes` - User clicked Yes
- `R_eMessageBoxResult.No` - User clicked No
- `R_eMessageBoxResult.Cancel` - User clicked Cancel or closed dialog

### Excel Batch Processing Pattern
**RULE**: Always implement R_IProcessProgressStatus for batch processing

```csharp
public class UploadViewModel : R_IProcessProgressStatus
{
    public Action<DataSet> ShowErrorAction { get; set; }
    public Action StateChangeAction { get; set; }
    public Action ShowSuccessAction { get; set; }
    public string Message { get; set; }
    public int Percentage { get; set; }
    public bool IsFileSelected { get; set; }
    public long MaximumFileSize => 5 * 1024 * 1024; // 5MB

    public async Task SaveBatchDataAsync(DataSet poExcelDataSet)
    {
        var loDataList = R_FrontUtility.R_ConvertTo<DataDTO>(poExcelDataSet.Tables[0]).ToList();
        
        var loCls = new R_ProcessAndUploadClient(
            plSendWithContext: true,
            plSendWithToken: true,
            poProcessProgressStatus: this);

        var loBatchPar = new R_BatchParameter();
        loBatchPar.COMPANY_ID = R_FrontGlobalVar.COMPANY_ID;
        loBatchPar.USER_ID = R_FrontGlobalVar.USER_ID;
        loBatchPar.ClassName = "BackProject.ClassName";
        loBatchPar.BigObject = loDataList;
        
        var lcGuid = await loCls.R_BatchProcess<List<DataDTO>>(loBatchPar, 10);
    }

    // Implement R_IProcessProgressStatus methods...
}
```

### Required Dependencies for Batch Processing
**RULE**: Always add these references for Excel batch processing

```xml
<!-- In .csproj file -->
<Reference Include="R_BlazorFrontEnd.Excel">
  <HintPath>..\..\..\SYSTEM\SOURCE\LIBRARY\Front\R_BlazorFrontEnd.Excel.dll</HintPath>
</Reference>
<Reference Include="R_ProcessAndUploadFront">
  <HintPath>..\..\..\SYSTEM\SOURCE\LIBRARY\Front\R_ProcessAndUploadFront.dll</HintPath>
</Reference>
```

### R_SaveBatch Method Usage Pattern
**CRITICAL**: R_SaveBatch method is available on R_Grid, NOT on R_ConductorGrid

```csharp
// ✅ CORRECT - Use R_Grid reference
private async Task OnProcess()
{
    R_Exception loException = new R_Exception();
    try
    {
        await _gridUploadCurrencyRef.R_SaveBatch(); // R_Grid has R_SaveBatch
    }
    catch (Exception ex)
    {
        loException.Add(ex);
    }
    loException.ThrowExceptionIfErrors();
}

// ❌ WRONG - R_ConductorGrid does not have R_SaveBatch
await _conductorGridRef.R_SaveBatch(); // This will cause compilation error
```

**Key Points:**
- R_SaveBatch is a method of R_Grid component
- R_ConductorGrid is used for conductor functionality, not batch operations
- Always use the grid reference for batch save operations
- Ensure proper error handling with R_Exception pattern

### Resource Consolidation Pattern
**RULE**: All related programs should share the same resource files

```xml
<!-- Single resource file contains ALL program resources -->
<data name="_MainProgram" xml:space="preserve">
  <value>Main Program</value>
</data>
<data name="_SubProgram" xml:space="preserve">
  <value>Sub Program</value>
</data>
<data name="_UploadProgram" xml:space="preserve">
  <value>Upload Program</value>
</data>
```

## 🔧 Build Order (Always Follow)
1. Back
```bash
# Build order (dependencies first)
dotnet build "{ProgramName}Common" 
dotnet build "{ProgramName}BackResources"
dotnet build "{ProgramName}Back"
dotnet build "{ProgramName}Service"
dotnet build "BIMASAKTI_GS_API"
```
2. Front
```bash
# Build order (dependencies first)
dotnet build "{ProgramName}Common" 
dotnet build "{ProgramName}FrontResources"
dotnet build "{ProgramName}Model"
dotnet build "{ProgramName}Front"
dotnet build "BlazorMenu"
```

## 🚨 Common Compilation Errors & Solutions

### Debugging Guidelines (CRITICAL)
**RULE**: When building and encountering errors:
1. **First attempt**: Try to fix straightforward errors (missing using statements, typos, etc.)
2. **Second attempt**: If not fixed, try alternative approaches (different references, syntax changes)
3. **Ask for help**: If still not fixed after 2 attempts, **ASK THE USER** for the solution
4. **Never comment code**: Do not comment out code as a "fix" - this is not acceptable

**Examples of straightforward errors to fix:**
- Missing using statements
- Typos in variable/method names
- Missing semicolons
- Incorrect syntax

**Examples of complex errors to ask about:**
- Dependency resolution issues
- Complex reference problems
- Framework-specific compilation errors
- Architecture-related build failures

### Warning Handling Guidelines (CRITICAL)
**RULE**: After successful build, when asked to fix compiler warnings:
1. **Fix clear warnings**: Address straightforward warnings (unused variables, missing null checks, etc.)
2. **Ask for ambiguous fixes**: If the fix approach is unclear or has multiple valid solutions, **ASK THE USER** for guidance
3. **Never suppress warnings**: Do not use `#pragma warning disable` or similar suppression techniques
4. **Maintain code quality**: Ensure fixes improve code quality and don't introduce new issues

**Examples of clear warnings to fix:**
- Unused variables/parameters
- Missing null checks
- Obsolete method usage
- Unreachable code

**Examples of ambiguous warnings to ask about:**
- Multiple valid approaches to fix the same warning
- Warnings that might require business logic decisions
- Performance-related warnings with trade-offs
- Warnings that might affect functionality

### Missing Using Statements
**Error**: `CS0246: The type or namespace name 'X' could not be found`
**Solution**: Add missing using statements to access classes from other projects

```csharp
// Common missing using statements
using R_BackEnd;                    // For R_BackGlobalVar
using R_CommonFrontBackAPI;         // For base classes
```

### R_BackGlobalVar Not Found in Service Layer
**Error**: `CS0103: The name 'R_BackGlobalVar' does not exist in the current context`
**Solution**: Add R_APIBackEnd reference to Service project

```xml
<!-- In Service .csproj -->
<Reference Include="R_APIBackEnd">
  <HintPath>..\..\..\..\..\SYSTEM\SOURCE\LIBRARY\Back\R_APIBackEnd.dll</HintPath>
</Reference>
```
## 📝 Variable Naming Convention (CRITICAL)

**RULE**: Follow consistent variable naming patterns for maintainability and readability

### 1. [Inject] Properties
- **Always private** and use **PascalCase**
- **Always assign `default!`**
- **Example**: `[Inject] private IClientHelper ClientHelper { get; set; } = default!;`

### 2. Private Properties for a class
- **Always start with underscore "_" and followed by snakeCase**
- **Do NOT add "l{typePrefix}"**
- **Example**: `private string _companyId;`

### 3. Public Properties for a class
- **Use PascalCase**
- **Example**: `public string CompanyId { get; set; }`

### 4. Local Variables
- **Always start with "l{typePrefix}"**
- **Example**: `string lcCompanyId;`

### 5. Method Parameters
- **Always start with "p{typePrefix}"**
- **Example**: `public void Method(string pcParameter)`
- **Multiple parameters**: Convert to `{MethodName}ParameterDTO` object when more than 1 parameter
- **Example**: `public async Task GetDataAsync(GetDataParameterDTO poParameter)` instead of `public async Task GetDataAsync(string pcCompanyId, string pcUserId, bool plIsActive)`

### 6. Method Results
- **Result DTOs**: Use `{MethodName}ResultDTO` object for return values
- **Example**: `public async Task<GetDataResultDTO> GetDataAsync(GetDataParameterDTO poParameter)`
- **Single value**: Can return directly if only one value
- **Example**: `public async Task<string> GetCompanyNameAsync(string pcCompanyId)`

### 7. Type-Specific Prefixes
- **"c"** for string (char/string)
- **"l"** for boolean (logical)
- **"i"** for int (integer)
- **"n"** for decimal (numeric)
- **"d"** for DateTime (date)
- **"e"** for enum
- **"o"** for objects and others

### 8. Complete Examples
```csharp
// [Inject] properties - private, PascalCase, assign default!
[Inject] private IClientHelper ClientHelper { get; set; } = default!;
[Inject] private R_MessageBoxService MessageBoxService { get; set; } = default!;

// Private properties - start with "_", snakeCase, NO type prefix
private string _companyId;
private bool _isValid;
private int _count;
private decimal _amount;
private DateTime _date;
private R_eGridType _gridType;
private R_Db _db;

// Public properties - PascalCase
public string CompanyId { get; set; }
public bool IsValid { get; set; }
public int Count { get; set; }

// Method parameters - start with "p" + type prefix
// Single parameter
public async Task GetDataAsync(string pcCompanyId)
{
    // Local variables - start with "l" + type prefix
    string lcCompanyId = "COMP001";
    bool llIsValid = true;
    int liCount = 0;
    decimal lnAmount = 100.50m;
    DateTime ldDate = DateTime.Now;
    R_eGridType leGridType = R_eGridType.Original;
    R_Db loDb = new R_Db();
    // Method implementation
}

// Multiple parameters - use ParameterDTO object
public async Task GetDataAsync(GetDataParameterDTO poParameter)
{
    // Local variables - start with "l" + type prefix
    string lcCompanyId = "COMP001";
    bool llIsValid = true;
    int liCount = 0;
    decimal lnAmount = 100.50m;
    DateTime ldDate = DateTime.Now;
    R_eGridType leGridType = R_eGridType.Original;
    R_Db loDb = new R_Db();
    // Access properties: poParameter.CompanyId, poParameter.IsValid, poParameter.Count
    // Method implementation
}

// Single value return
public async Task<string> GetCompanyNameAsync()
{
    // Return single value directly
    // Method implementation
}

// Multiple value Return - use ResultDTO object
public async Task<GetDataResultDTO> GetDataAsync()
{
    // Return GetDataResultDTO object
    // Method implementation
}
```

### 9. Naming Pattern Summary
- **[Inject]**: `private IType PropertyName { get; set; } = default!;`
- **Private**: `private Type _propertyName;` (NO type prefix)
- **Public**: `public Type PropertyName { get; set; }` (PascalCase, NO type prefix)
- **Local**: `Type l[type]VariableName;`
- **Parameter**: `Type p[type]ParameterName;` (single parameter)
- **Multiple Parameters**: `{MethodName}ParameterDTO poParameter` (preferred for 2+ parameters)
- **Result**: `{MethodName}ResultDTO` (for complex return values)
- **Single Result**: `Type` (for simple return values)

**CRITICAL**: Always follow this naming convention for consistency across all projects.

### 10. Systematic Naming Fix Process
When fixing variable naming across multiple projects:

1. **Identify the scope**: Private vs Public vs Local
2. **Apply correct pattern**: 
   - Private: `_snakeCase` (no type prefix)
   - Public: `PascalCase` (no type prefix)
   - Local: `l{typePrefix}VariableName`
3. **Update all references**: Ensure all usages are updated consistently
4. **Verify builds**: Test that all projects build successfully after changes

### 11. Common Mistakes to Avoid
- ❌ **Don't use underscore for public properties** - even in ViewModels
- ❌ **Don't mix naming patterns** - be consistent within each scope
- ❌ **Don't forget to update all references** - search and replace systematically
- ❌ **Don't assume all fields are private** - check the access modifier

## ✅ Quick Reference Checklist

When converting a new program, verify:
- [ ] Logger in Back project (inherits R_NetCoreLoggerBase<T>)
- [ ] Activity in Back project (inherits R_ActivitySourceBase)
- [ ] Interface uses R_IServiceCRUDAsyncBase
- [ ] Using var for loConn and loCmd
- [ ] loDb = null in finally
- [ ] Service uses Microsoft.NET.Sdk + FrameworkReference
- [ ] All required DLL references added
- [ ] Controller injects COMPANY_ID and USER_ID
- [ ] No separate business interface
- [ ] Resources in root folder of resource projects
- [ ] DTOs ONLY in Common project
- [ ] Sub-programs integrated into main program projects (not separate)
- [ ] Separate Model classes only if using different Controllers
- [ ] R_PredefinedDock (page load, can't close), R_Detail (on click, can close), R_Popup (R_Page modal), R_Lookup (lookup)
- [ ] Use MessageBoxService for dialogs, R_Popup only for R_Page components
- [ ] NEVER use R_Button for navigation - use appropriate navigation components
- [ ] R_IProcessProgressStatus implemented for batch processing
- [ ] R_BlazorFrontEnd.Excel and R_ProcessAndUploadFront references added
- [ ] All related resources consolidated in single resource files
- [ ] List methods use streaming context pattern (R_FrontContext.R_SetStreamingContext())
- [ ] Method naming follows GetList{Description}() / GetList{Description}Async() convention
- [ ] IClientHelper data set in Controller, custom parameters in ViewModel via streaming context
- [ ] Conductor source chosen based on access control: R_ConductorGridSource for grid CRUD, R_ConductorSource for form access
- [ ] R_SaveBatch called on R_Grid component, not R_ConductorGrid
- [ ] Conductor source only added when component needs access control (A,U,D,P,V)
- [ ] No conductor source for always-enabled components
- [ ] Service layer uses R_BackGlobalVar.COMPANY_ID directly (IClientHelper sets it automatically)
- [ ] R_APIBackEnd reference added to Service project for R_BackGlobalVar access
- [ ] Streaming context only used for custom parameters, not IClientHelper data
- [ ] All required using statements added (R_Common, etc.)
- [ ] All method parameters passed correctly to Back layer methods
- [ ] Projects built in correct dependency order
- [ ] Variable naming follows correct patterns: Private `_snakeCase`, Public `PascalCase`, Local `l{typePrefix}`
- [ ] Public properties in ViewModels use PascalCase (not underscore prefix)
- [ ] All variable references updated consistently when renaming
- [ ] Access modifiers checked before applying naming patterns