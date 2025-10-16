# Critical Patterns Learned from Code Review

## Absolute Must-Follow Rules

### 1. Logger and Activity Location
**RULE**: Logger and Activity classes go in **Back** project ONLY, never in Common
**Reason**: These are backend-only utilities, not shared across frontend/backend

```
❌ WRONG:
PYM00100Common/
  ├── LoggerPYM00100.cs
  └── PYM00100Activity.cs

✅ CORRECT:
PYM00100Back/
  ├── LoggerPYM00100.cs
  └── PYM00100Activity.cs
```

### 2. Logger Implementation
**RULE**: NEVER implement logger yourself, just inherit from R_NetCoreLoggerBase<T>

```csharp
❌ WRONG - Custom Implementation (66 lines):
public class LoggerPYM00100 : R_ILogger
{
    private ILogger? _logger;
    private static LoggerPYM00100? _instance = null;
    
    public static void R_InitializeLogger(ILogger poLogger)
    {
        // custom implementation
    }
    // ... 60 more lines
}

✅ CORRECT - Base Class (7 lines):
using R_CommonFrontBackAPI.Log;

namespace PYM00100Back
{
    public class LoggerPYM00100 : R_NetCoreLoggerBase<LoggerPYM00100>
    {
    }
}
```

**WHY**: R_NetCoreLoggerBase provides all functionality - singleton pattern, initialization, logging methods, thread safety.

### 3. Activity Implementation
**RULE**: NEVER implement activity yourself, just inherit from R_ActivitySourceBase

```csharp
❌ WRONG - Custom Implementation (30 lines):
public class PYM00100Activity
{
    private static ActivitySource? _activitySource = null;
    
    public static ActivitySource R_InitializeAndGetActivitySource(string pcName)
    {
        // custom implementation
    }
    // ... more lines
}

✅ CORRECT - Base Class (6 lines):
using R_OpenTelemetry;

namespace PYM00100Back
{
    public class PYM00100Activity : R_ActivitySourceBase
    {
    }
}
```

**WHY**: R_ActivitySourceBase provides R_InitializeAndGetActivitySource() and R_GetInstanceActivitySource() automatically.

### 4. Using Statements for Database Resources
**RULE**: Always use `using var` for DbConnection and DbCommand, never manual disposal

```csharp
❌ WRONG - Manual Disposal:
DbConnection? loConn = null;
DbCommand? loCmd = null;

try
{
    loConn = await loDb.GetConnectionAsync();
    loCmd = loDb.GetCommand();
    // operations
}
finally
{
    if (loConn != null)
    {
        if (loConn.State != ConnectionState.Closed)
        {
            await loConn.CloseAsync();
        }
        await loConn.DisposeAsync();
    }
    if (loCmd != null)
    {
        loCmd.Dispose();
    }
}

✅ CORRECT - Using Statements:
R_Db? loDb = null;

try
{
    loDb = new R_Db();
    using var loConn = await loDb.GetConnectionAsync();
    using var loCmd = loDb.GetCommand();
    // operations - automatic disposal when scope exits
}
finally
{
    if (loDb != null) { loDb = null; }
}
```

**WHY**: Using statements guarantee disposal, are exception-safe, and reduce boilerplate by 90%.

### 5. R_Db Cleanup in Finally
**RULE**: Always null out R_Db instance in finally block

```csharp
✅ CORRECT:
R_Db? loDb = null;

try
{
    loDb = new R_Db();
    // operations
}
finally
{
    if (loDb != null)
    {
        loDb = null;  // CRITICAL: Always do this
    }
}
```

**WHY**: Ensures database helper instance is properly cleaned up.

### 6. Interface Naming
**RULE**: Service interfaces inherit from R_IServiceCRUDAsyncBase (not Base or BaseAsync)

```csharp
❌ WRONG:
public interface IPYM00100 : R_IServiceCRUDBase<PYM00100DTO>
public interface IPYM00100 : R_IServiceCRUDBaseAsync<PYM00100DTO>

✅ CORRECT:
public interface IPYM00100 : R_IServiceCRUDAsyncBase<PYM00100DTO>
```

**WHY**: Correct interface name in R_CommonFrontBackAPI library.

### 7. No Separate Business Interface
**RULE**: Don't create separate business interfaces with async - use business class directly

```
❌ WRONG:
PYM00100Back/
  └── Interfaces/
      └── IPYM00100.cs  (business interface - unnecessary)

✅ CORRECT:
PYM00100Back/
  └── PYM00100Cls.cs  (use directly)
```

**WHY**: With async, we don't need migration layer from sync to async anymore.

### 8. Service Project SDK
**RULE**: Use Microsoft.NET.Sdk (not Sdk.Web) with FrameworkReference

```xml
❌ WRONG:
<Project Sdk="Microsoft.NET.Sdk.Web">
    <ItemGroup>
        <PackageReference Include="Swashbuckle.AspNetCore" />
    </ItemGroup>
</Project>

✅ CORRECT:
<Project Sdk="Microsoft.NET.Sdk">
    <ItemGroup>
        <FrameworkReference Include="Microsoft.AspNetCore.App" />
    </ItemGroup>
</Project>
```

**WHY**: Matches HDM00100 pattern, avoids unnecessary dependencies.

### 9. Controller Implementation
**RULE**: Controller implements service interface from Common project

```csharp
✅ CORRECT:
public class PYM00100Controller : ControllerBase, PYM00100Common.IPYM00100
{
    private readonly LoggerPYM00100 _logger;
    private readonly ActivitySource _activitySource;

    public PYM00100Controller(ILogger<LoggerPYM00100> logger)
    {
        LoggerPYM00100.R_InitializeLogger(logger);
        _logger = LoggerPYM00100.R_GetInstanceLogger();
        _activitySource = PYM00100Activity.R_InitializeAndGetActivitySource(nameof(PYM00100Controller));
    }
}
```

### 10. Context Injection Pattern
**RULE**: Always inject COMPANY_ID and USER_ID in controller from R_BackGlobalVar

```csharp
✅ CORRECT:
[HttpPost]
public async Task<R_ServiceSaveResultDTO<DTO>> R_ServiceSave(
    R_ServiceSaveParameterDTO<DTO> poParameter)
{
    poParameter.Entity.CCOMPANY_ID = R_BackGlobalVar.COMPANY_ID;  // CRITICAL
    poParameter.Entity.CUSER_ID = R_BackGlobalVar.USER_ID;        // CRITICAL
    poParameter.Entity.DDATE = DateTime.Now;
    
    var loCls = new [Program]Cls();
    loRtn.data = await loCls.R_SaveAsync(poParameter.Entity, poParameter.CRUDMode);
}
```

**WHY**: Context comes from HTTP headers, automatically set by middleware.

## Quick Reference Checklist

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

## Always Reference

1. **Template**: `net6/PYM00100/` - Complete working example
2. **Sample**: `DEV (FMC)/HDM00100*/` - Reference implementation
3. **Docs**: `Library/net-core-library.md` - Library reference
4. **Guide**: `net6/MIGRATION_GUIDE.md` - Step-by-step instructions

