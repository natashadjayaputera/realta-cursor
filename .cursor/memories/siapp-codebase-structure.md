# SIAPP Codebase Structure

## Repository Organization

### Root: `d:\RealCode\RSF\SIAPP\7.06\PROGRAM\SIAPP MENU\SOURCE\BACK\PY`

### Main Directories

#### `Library/` - Internal Framework Libraries
- **`Library/net core/`** - .NET 6 libraries (microservices, async, REST API)
- **`Library/net framework/`** - .NET Framework 4.0 libraries (WCF, Windows Forms)
- **Documentation**: See `Library/net-core-library.md` and `Library/net-framework-library.md`

#### `Dll Back/` - Runtime DLLs for .NET 6
Contains all compiled .NET 6 libraries used by programs:
- R_APIBackEnd.dll
- R_APICommon.dll
- R_APICommonDTO.dll
- R_CommonFrontBackAPI.dll
- R_OpenTelemetry.dll
- R_ContextBackEnd.dll
- R_MultiTenantDb.dll
- And 30+ more libraries

#### `Dll Engine/` - Background Job Scheduler DLLs
- R_Scheduler.dll
- R_Scheduler.MultiTenantDb.dll

#### `Dll Front/` - Frontend Libraries
.NET 6 Blazor and client libraries

#### `DEV (FMC)/` - .NET 6 Sample Implementation
**HDM00100** - Reference implementation showing:
- Project structure pattern
- Logger and Activity usage
- Controller implementation
- Business class patterns

**ALWAYS reference HDM00100 when migrating programs**

#### `net6/` - New .NET 6 Conversions
All migrated programs go here following the standard 4-project structure:
- **PYM00100** - First conversion, serves as template

#### Legacy .NET Framework 4.0 Programs
Programs like:
- PYM00100BACK, PYM00100COMMON, PYM00100BackResources (VB.NET, .NET 4)
- PYB*, PYM*, PYT*, PYI*, PYR* series
- All use old WCF architecture

## Naming Conventions

### Program Codes
- **PYM** = Payroll Master data
- **PYB** = Payroll Batch
- **PYT** = Payroll Transaction
- **PYI** = Payroll Inquiry
- **PYR** = Payroll Report
- **HDM** = Help Desk Master (in DEV (FMC))

### Project Suffixes
- **BACK** = Backend business logic
- **COMMON** = Shared DTOs and interfaces
- **BackResources** = Localized resource files
- **Front** = Frontend UI (Windows Forms or Blazor)
- **Model** = Frontend model layer (optional)
- **Service** = API Controller layer (.NET 6)

## Migration Workflow

1. Identify source program in root (e.g., PYM00100BACK)
2. Check HDM00100 in `DEV (FMC)/` for .NET 6 patterns
3. Create `net6/[ProgramName]/` structure
4. Follow patterns from PYM00100 reference implementation
5. Build in order: Common → BackResources → Back → Service

## Database Naming Patterns

### Tables
- **PYM_*** = Payroll Master tables
- **PYT_*** = Payroll Transaction tables
- **GSM_*** = General System Master tables
- Suffix **_HD** = Header table
- Suffix **_DT** = Detail table

### Stored Procedures
- **RSP_*** = REALTA Stored Procedure
- Pattern: `RSP_[MODULE]_[ACTION]_[ENTITY]`
- Example: `RSP_HD_GET_SYSTEM_PARAM`

## Key Technical Decisions

1. **Target Framework**: .NET 6 (not .NET 7 or 8)
2. **Common Libraries**: netstandard2.1 for cross-compatibility
3. **Backend/Service**: net6.0
4. **Language**: C# (migrated from VB.NET)
5. **Architecture**: Microservices with REST API
6. **Authentication**: JWT token-based
7. **ORM**: Direct SQL with R_Db (not EF Core)
8. **UI**: Blazor (not Windows Forms)

## Important File Locations

- **Library docs**: `Library/net-core-library.md`, `Library/net-framework-library.md`
- **Migration guide**: `net6/MIGRATION_GUIDE.md`
- **Reference implementation**: `net6/PYM00100/`
- **Sample implementation**: `DEV (FMC)/HDM00100*/`
- **Runtime DLLs**: `Dll Back/`, `Dll Front/`, `Dll Engine/`

