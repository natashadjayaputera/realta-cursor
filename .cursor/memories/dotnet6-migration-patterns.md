# .NET 6 Migration Patterns - Key Learnings

## Project Architecture Pattern

### Standard .NET 6 Project Structure (4 Projects)
```
net6/[ProgramName]/
├── [ProgramName]Common/        # netstandard2.1 - DTOs, Interfaces, Constants
├── [ProgramName]Back/          # net6.0 - Business logic, Logger, Activity
├── [ProgramName]Service/       # net6.0 - API Controllers
└── [ProgramName]BackResources/ # netstandard2.1 - Resource files
```

### Project Responsibilities
1. **Common**: DTOs, service interfaces, context constants - SHARED between front/back
2. **Back**: Business classes, logger, activity source - BACKEND ONLY
3. **Service**: API controllers implementing service interfaces
4. **BackResources**: Localized error messages (.resx files)

## Critical Implementation Patterns

### 1. Logger Pattern (MUST FOLLOW)
**Location**: In **Back** project only (NOT Common)
```csharp
using R_CommonFrontBackAPI.Log;

namespace [ProgramName]Back
{
    public class Logger[ProgramName] : R_NetCoreLoggerBase<Logger[ProgramName]>
    {
        // Empty - base class provides all functionality
    }
}
```
**Usage**:
```csharp
// In Controller constructor:
Logger[ProgramName].R_InitializeLogger(logger);
_logger = Logger[ProgramName].R_GetInstanceLogger();

// In business class constructor:
_logger = Logger[ProgramName].R_GetInstanceLogger();
```

### 2. Activity Pattern (MUST FOLLOW)
**Location**: In **Back** project only (NOT Common)
```csharp
using R_OpenTelemetry;

namespace [ProgramName]Back
{
    public class [ProgramName]Activity : R_ActivitySourceBase
    {
        // Empty - base class provides all functionality
    }
}
```
**Usage**:
```csharp
// In Controller:
_activitySource = [ProgramName]Activity.R_InitializeAndGetActivitySource(nameof([ProgramName]Controller));

// In business class:
_activitySource = [ProgramName]Activity.R_GetInstanceActivitySource();
```

### 3. Service Interface Pattern
**Location**: In **Common** project
```csharp
public interface I[ProgramName] : R_IServiceCRUDAsyncBase<[MainDTO]>
{
    IAsyncEnumerable<ListDTO> GetList();  // For streaming operations
    SpecificType CustomMethod();          // For custom operations
}
```
**CRITICAL**: Use `R_IServiceCRUDAsyncBase` NOT `R_IServiceCRUDBase`

### 4. Business Class Pattern
**Location**: In **Back** project
```csharp
public class [ProgramName]Cls : R_BusinessObjectAsync<[MainDTO]>
{
    private readonly Resources_Dummy_Class loRsp = new();
    private readonly Logger[ProgramName] _logger;
    private readonly ActivitySource _activitySource;

    public [ProgramName]Cls()
    {
        _logger = Logger[ProgramName].R_GetInstanceLogger();
        _activitySource = [ProgramName]Activity.R_GetInstanceActivitySource();
    }

    protected override async Task<[MainDTO]> R_DisplayAsync([MainDTO] poEntity)
    {
        var loEx = new R_Exception();
        R_Db? loDb = null;
        
        try
        {
            loDb = new R_Db();
            using var loConn = await loDb.GetConnectionAsync();
            using var loCmd = loDb.GetCommand();
            // operations with using statements for auto-disposal
        }
        catch (Exception ex)
        {
            loEx.Add(ex);
            _logger.LogError(loEx);
        }
        finally
        {
            if (loDb != null) { loDb = null; }  // CRITICAL: Always null loDb
        }
        
        loEx.ThrowExceptionIfErrors();
        return loResult;
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
public class [ProgramName]Controller : ControllerBase, [ProgramName]Common.I[ProgramName]
{
    private readonly Logger[ProgramName] _logger;
    private readonly ActivitySource _activitySource;

    public [ProgramName]Controller(ILogger<Logger[ProgramName]> logger)
    {
        Logger[ProgramName].R_InitializeLogger(logger);
        _logger = Logger[ProgramName].R_GetInstanceLogger();
        _activitySource = [ProgramName]Activity.R_InitializeAndGetActivitySource(nameof([ProgramName]Controller));
    }

    [HttpPost]
    public async Task<R_ServiceGetRecordResultDTO<[MainDTO]>> R_ServiceGetRecord(
        R_ServiceGetRecordParameterDTO<[MainDTO]> poParameter)
    {
        // Inject context automatically
        poParameter.Entity.CCOMPANY_ID = R_BackGlobalVar.COMPANY_ID;
        poParameter.Entity.CUSER_ID = R_BackGlobalVar.USER_ID;
    }
}
```

### 7. Streaming Endpoint Pattern
```csharp
[HttpPost]
public IAsyncEnumerable<ItemDTO> GetItemList()
{
    return GetItemListStream();
}

private async IAsyncEnumerable<ItemDTO> GetItemListStream()
{
    var loEx = new R_Exception();
    List<ItemDTO>? loRtn = null;
    
    try
    {
        var loCls = new [ProgramName]Cls();
        loRtn = await loCls.GetItemList(param);
    }
    catch (Exception ex) { loEx.Add(ex); }
    
    loEx.ThrowExceptionIfErrors();
    
    if (loRtn != null)
    {
        foreach (var item in loRtn)
        {
            yield return item;  // Streaming one by one
        }
    }
}
```

## Project File Templates

### Common Project (.csproj)
```xml
<Project Sdk="Microsoft.NET.Sdk">
    <PropertyGroup>
        <TargetFramework>netstandard2.1</TargetFramework>
        <Nullable>enable</Nullable>
    </PropertyGroup>
    <ItemGroup>
        <Reference Include="R_APICommonDTO">
            <HintPath>..\..\Dll Back\R_APICommonDTO.dll</HintPath>
        </Reference>
        <Reference Include="R_CommonFrontBackAPI">
            <HintPath>..\..\Dll Back\R_CommonFrontBackAPI.dll</HintPath>
        </Reference>
    </ItemGroup>
</Project>
```

### Back Project (.csproj)
```xml
<Project Sdk="Microsoft.NET.Sdk">
    <PropertyGroup>
        <TargetFramework>net6.0</TargetFramework>
        <ImplicitUsings>enable</ImplicitUsings>
        <Nullable>enable</Nullable>
    </PropertyGroup>
    <ItemGroup>
        <ProjectReference Include="..\[ProgramName]Common\[ProgramName]Common.csproj" />
        <ProjectReference Include="..\[ProgramName]BackResources\[ProgramName]BackResources.csproj" />
    </ItemGroup>
    <ItemGroup>
        <Reference Include="R_APIBackEnd">
            <HintPath>..\..\Dll Back\R_APIBackEnd.dll</HintPath>
        </Reference>
        <Reference Include="R_APICommon">
            <HintPath>..\..\Dll Back\R_APICommon.dll</HintPath>
        </Reference>
        <Reference Include="R_APICommonDTO">
            <HintPath>..\..\Dll Back\R_APICommonDTO.dll</HintPath>
        </Reference>
        <Reference Include="R_CommonFrontBackAPI">
            <HintPath>..\..\Dll Back\R_CommonFrontBackAPI.dll</HintPath>
        </Reference>
        <Reference Include="R_OpenTelemetry">
            <HintPath>..\..\Dll Back\R_OpenTelemetry.dll</HintPath>
        </Reference>
    </ItemGroup>
</Project>
```

### Service Project (.csproj)
```xml
<Project Sdk="Microsoft.NET.Sdk">
    <PropertyGroup>
        <TargetFramework>net6.0</TargetFramework>
        <ImplicitUsings>enable</ImplicitUsings>
        <Nullable>enable</Nullable>
    </PropertyGroup>
    <ItemGroup>
        <FrameworkReference Include="Microsoft.AspNetCore.App" />
    </ItemGroup>
    <ItemGroup>
        <ProjectReference Include="..\[ProgramName]Back\[ProgramName]Back.csproj" />
        <ProjectReference Include="..\[ProgramName]Common\[ProgramName]Common.csproj" />
    </ItemGroup>
    <ItemGroup>
        <Reference Include="R_APIBackEnd">
            <HintPath>..\..\Dll Back\R_APIBackEnd.dll</HintPath>
        </Reference>
        <Reference Include="R_APICommon">
            <HintPath>..\..\Dll Back\R_APICommon.dll</HintPath>
        </Reference>
        <Reference Include="R_APIStartUp">
            <HintPath>..\..\Dll Back\R_APIStartUp.dll</HintPath>
        </Reference>
        <Reference Include="R_CommonFrontBackAPI">
            <HintPath>..\..\Dll Back\R_CommonFrontBackAPI.dll</HintPath>
        </Reference>
        <Reference Include="R_OpenTelemetry">
            <HintPath>..\..\Dll Back\R_OpenTelemetry.dll</HintPath>
        </Reference>
    </ItemGroup>
</Project>
```
**CRITICAL**: Use `Microsoft.NET.Sdk` (not Sdk.Web), with `FrameworkReference` to AspNetCore.App

### BackResources Project (.csproj)
```xml
<Project Sdk="Microsoft.NET.Sdk">
    <PropertyGroup>
        <TargetFramework>netstandard2.1</TargetFramework>
        <Nullable>enable</Nullable>
    </PropertyGroup>
    <ItemGroup>
        <Compile Update="[ProgramName]BackResources_msgrsc.Designer.cs">
            <DesignTime>True</DesignTime>
            <AutoGen>True</AutoGen>
            <DependentUpon>[ProgramName]BackResources_msgrsc.resx</DependentUpon>
        </Compile>
    </ItemGroup>
    <ItemGroup>
        <EmbeddedResource Update="[ProgramName]BackResources_msgrsc.resx">
            <Generator>ResXFileCodeGenerator</Generator>
            <LastGenOutput>[ProgramName]BackResources_msgrsc.Designer.cs</LastGenOutput>
        </EmbeddedResource>
    </ItemGroup>
</Project>
```

## Common Mistakes to Avoid

1. ❌ **Logger in Common project** → ✅ Put in Back project
2. ❌ **Activity in Common project** → ✅ Put in Back project
3. ❌ **Custom Logger implementation** → ✅ Just inherit from R_NetCoreLoggerBase<T>
4. ❌ **Custom Activity implementation** → ✅ Just inherit from R_ActivitySourceBase
5. ❌ **R_IServiceCRUDBase** → ✅ Use R_IServiceCRUDAsyncBase
6. ❌ **R_IServiceCRUDBaseAsync** → ✅ Use R_IServiceCRUDAsyncBase
7. ❌ **Manual connection disposal** → ✅ Use `using var` statements
8. ❌ **Forgetting loDb = null in finally** → ✅ Always add
9. ❌ **Microsoft.NET.Sdk.Web** for Service → ✅ Use Microsoft.NET.Sdk + FrameworkReference
10. ❌ **Missing R_APICommonDTO reference** → ✅ Always include in Back and Service

## VB.NET to C# Conversion Rules

### Naming Conventions (Keep Consistent)
- **lo** prefix = local object (loDb, loConn, loCmd)
- **lc** prefix = local character/string (lcQuery)
- **po** prefix = parameter object (poEntity, poParameter)
- **ll** prefix = local logical/boolean (llResult)
- **ln** prefix = local numeric (lnCount)

### Common Conversions
| VB.NET | C# |
|--------|-----|
| `IsNot Nothing` | `!= null` |
| `Nothing` | `null` |
| `AndAlso` | `&&` |
| `OrElse` | `\|\|` |
| `CType(x, Type)` | `(Type)x` |
| `String.Format("{0}", x)` | `$"{x}"` |
| `Function ... As Type` | `Type MethodName()` |
| `Sub MethodName` | `void MethodName()` |

### Async Conversion
```vb
' VB.NET (.NET 4)
Public Function GetData(poParam As DTO) As DTO
    Dim loDb As New R_Db()
    Dim loConn = loDb.GetConnection()
    ' ...
    Return loResult
End Function
```

```csharp
// C# (.NET 6)
public async Task<DTO> GetData(ParamDTO poParam)
{
    R_Db? loDb = null;
    try
    {
        loDb = new R_Db();
        using var loConn = await loDb.GetConnectionAsync();
        using var loCmd = loDb.GetCommand();
        // ...
        return loResult;
    }
    finally
    {
        if (loDb != null) { loDb = null; }
    }
}
```

## Build Order (Always Follow)
```bash
1. dotnet build [Program]Common/[Program]Common.csproj
2. dotnet build [Program]BackResources/[Program]BackResources.csproj
3. dotnet build [Program]Back/[Program]Back.csproj
4. dotnet build [Program]Service/[Program]Service.csproj
```

## Required DLL References

### Common Project
- R_APICommonDTO.dll
- R_CommonFrontBackAPI.dll

### Back Project
- R_APIBackEnd.dll
- R_APICommon.dll
- R_APICommonDTO.dll
- R_CommonFrontBackAPI.dll
- R_OpenTelemetry.dll

### Service Project
- R_APIBackEnd.dll
- R_APICommon.dll
- R_APIStartUp.dll
- R_CommonFrontBackAPI.dll
- R_OpenTelemetry.dll

**All DLLs are in**: `Dll Back/` folder

## Key Migration Checklist

- [ ] Create 4 project structure (Common, Back, Service, BackResources)
- [ ] Logger inherits from R_NetCoreLoggerBase<T> in Back project
- [ ] Activity inherits from R_ActivitySourceBase in Back project
- [ ] Interface inherits from R_IServiceCRUDAsyncBase<T> in Common project
- [ ] Business class inherits from R_BusinessObjectAsync<T>
- [ ] Use `using var` for DbConnection and DbCommand
- [ ] Always null loDb in finally block
- [ ] Service uses Microsoft.NET.Sdk with FrameworkReference AspNetCore.App
- [ ] All DLL references added correctly
- [ ] Context constants in Common (if needed)
- [ ] Resource files with Designer.cs auto-generated

## Documentation to Create

For each conversion, create:
1. **README.md** - Program overview, API endpoints, usage
2. **Build and verify** - Ensure 0 errors

## Reference Implementation

**PYM00100** in `net6/PYM00100/` is the gold standard reference for all conversions.

## Library Documentation

- **net-core-library.md** - Complete .NET 6 library guide
- **net-framework-library.md** - Complete .NET Framework 4.0 library guide

Use these as primary reference for understanding the library architecture and available components.

