# Standardized Event Migration Pattern File Structure

This document defines the standardized structure for all event migration pattern files (event handlers migration from NET4 to NET6).

## Standard Structure Template

```markdown
---
description: "Migration pattern for [NET4 Event] → [NET6 Event]"
alwaysApply: false
---

# [NET4 Event] → [NET6 Event]

- NET4: `[NET4 Event Description]`
- NET6: `[NET6 Event Description]` with `[EventArgs Type]` (if applicable)

## Use
- [Use case 1]
- [Use case 2]
- [Use case 3]

## Bindings
- [Component type]: `R_EventName="HandlerMethodName"` (+ usual services, `R_ViewModel` if applicable).
- [Additional component types if applicable]

## Handler
- Prefer: `private void HandlerMethodName([EventArgsType] eventArgs)` OR `private async Task HandlerMethodName([EventArgsType] eventArgs)` (based on event type category - see Event Type Categories below).
- Async allowed if needed: `private async Task HandlerMethodName([EventArgsType] eventArgs)` (add this line when handler prefers `void`).
- Override pattern (for R_Page events): `protected override async Task [ReturnType] EventName([EventArgsType] eventArgs)`.
- Data object access: `var loData = (MyDto)eventArgs.Data;` (if applicable).
- Cancellation: `eventArgs.Cancel = true;` (if applicable).

## Parameter mapping
### [Component/Context Type]
- NET4 `[Parameter]` → NET6 `[Mapping]`
- NET4 `[Parameter]` → NET6 `[Mapping]`

### [Additional Component/Context Type]
- NET4 `[Parameter]` → NET6 `[Mapping]`

## Workaround
### (NET4 `[Specific Parameter]`)
- Pattern: NET4 `[Usage Pattern]` → NET6 `[Migration Pattern]`
- Non-standard usages: `// TODO: Implement {things to do} for "[Property]"`

## Example
```csharp
[Code example showing standard handler pattern]
```

## NET4 → NET6 mapping examples
- NET4 VB usage:
  - `[VB.NET Handler Signature]`
- NET6:
  - `EventName="@HandlerName"` on `ComponentName` → `private void HandlerName(EventArgsType eventArgs)`
  - **Format rules**: Use "NET6:" prefix (not "NET6 Razor usage:"), backticks only around individual code parts (not the entire line), include handler signature after → arrow

## Notes
- [Additional notes if applicable]
- [Special considerations]

## References
- `[Documentation path]`
- `[Additional references]`
```

## Section Order Guidelines

The recommended section order is:

1. **Frontmatter** (required)
   - `description`: Brief description of the event migration pattern
   - `alwaysApply`: Always set to `false`

2. **Title with NET4 → NET6 mapping** (required)
   - Shows NET4 event description and NET6 event description
   - Include EventArgs type if applicable

3. **Use** (required)
   - List of use cases for the event
   - Typical scenarios where the event is used

4. **Bindings** (required)
   - How to bind the event handler in NET6 Razor syntax
   - Component-specific binding requirements
   - Required services or dependencies

5. **Handler** (required)
   - Handler method signature conventions
   - Return type (Task, Task<T>, void)
   - Access modifiers (private, protected override)
   - Common patterns (data access, cancellation, async)

6. **Parameter mapping** (required)
   - Maps NET4 event parameters to NET6 event args properties
   - Group by component/context type if multiple variants exist
   - Use subsections for Conductor vs Grid differences

7. **Workaround** (optional)
   - Only include if NET4 has parameters that don't map directly
   - Common cases: `poGridCellCollection`, complex object access
   - Provide migration patterns and TODO markers for non-standard cases

8. **Example** (optional but recommended)
   - Include NET4 and NET6 code examples
   - Show standard handler pattern with error handling
   - Demonstrate common use cases

9. **NET4 → NET6 mapping examples** (optional but recommended)
   - Side-by-side comparison of NET4 VB.NET and NET6 Razor usage
   - Show actual syntax differences

10. **Notes** (optional)
    - Additional implementation notes
    - Special considerations or best practices
    - Common pitfalls

11. **References** (optional)
    - Links to NET6 documentation files
    - Related migration pattern files
    - Component documentation

## Event Type Categories

### CRUD Lifecycle Events
- **Before Events**: `R_BeforeAdd`, `R_BeforeEdit`, `R_BeforeDelete`, `R_BeforeCancel`
  - Typically have `Cancel` property in EventArgs
  - Used for validation and pre-checks
  - **Handler preference**: `private void` with "Async allowed if needed"
  - Example: `private void Grid_R_BeforeAdd(R_BeforeAddEventArgs eventArgs)`

- **After Events**: `R_AfterAdd`, `R_AfterSave`, `R_AfterDelete`, `R_AfterSaveBatch`
  - Typically have `Data` property in EventArgs
  - Used for post-operation actions
  - **Handler preference**: `private void` with "Async allowed if needed"
  - Example: `private void Conductor_R_AfterSave(R_AfterSaveEventArgs eventArgs)`

### Navigation Events
- **Before Open Events**: `R_Before_Open_Popup`, `R_Before_Open_Lookup`, `R_Before_Open_Detail`, `R_Before_Open_Grid_Lookup`, `R_Before_Open_Grid_Popup`, etc.
  - Component-specific event handlers
  - Set target page and parameters
  - **Handler preference**: `private void` with "Async allowed if needed"
  - Example: `private void BtnName_R_Before_Open_Popup(R_BeforeOpenPopupEventArgs eventArgs)`

- **Return Events**: `R_After_Open_Lookup`, `R_After_Open_Find`, `R_After_Open_Detail`, `R_After_Open_Popup`, `R_AfterOpenPredefinedDock`, etc.
  - Handle result when navigation page closes
  - Populate fields based on returned result
  - **Handler preference**: `private void` with "Async allowed if needed"
  - Example: `private void btnName_R_After_Open_Lookup(R_AfterOpenLookupEventArgs eventArgs)`

### Service Events
- **Service Events**: `R_ServiceSave`, `R_ServiceGetRecord`, `R_ServiceGetListRecord`, `R_ServiceDelete`
  - Call ViewModel/Model async methods
  - Perform save/get/delete operations via service
  - **Handler preference**: Always `private async Task` (required async)
  - Example: `private async Task Conductor_R_ServiceSave(R_ServiceSaveEventArgs eventArgs)`

### Page Lifecycle Events
- **Override Methods**: `R_Init_From_Master`, `R_LockUnlock`
  - Override methods on `R_Page`
  - Protected access modifier
  - Return `Task` or `Task<T>`

### Batch Events
- **Batch-specific**: `R_AfterSaveBatch`
  - Special batch operation handlers
  - Use `R_AfterSaveBatchEventArgs`

## Key Standardization Rules

1. **Consistent section order**: Follow the order outlined above for consistency across all event files
2. **Handler signatures**: Always specify return type, access modifier, and parameter types based on event type category
3. **Handler return types**:
   - **Navigation events** (before-open and return): Prefer `private void` with "Async allowed if needed"
   - **Service events**: Always `private async Task` (required)
   - **CRUD events**: Prefer `private void` with "Async allowed if needed"
   - **Page lifecycle events**: `protected override async Task` or `protected override async Task<T>`
4. **NET6 Razor usage format**:
   - Use "NET6:" prefix (not "NET6 Razor usage:")
   - Format: `EventName="@HandlerName"` on `ComponentName` → `handler signature`
   - **Do NOT wrap entire line in backticks** - only use backticks around individual code parts
   - Example: `R_After_Open_Lookup="@btnName_R_After_Open_Lookup"` on `R_Lookup` → `private void btnName_R_After_Open_Lookup(R_AfterOpenLookupEventArgs eventArgs)`
5. **Parameter mapping**: Group by component type (Conductor vs Grid) when different
6. **Examples**: Include standard error handling pattern with `R_Exception`
7. **Workarounds**: Only include when direct mapping is not possible
8. **Cancellation pattern**: Use `eventArgs.Cancel = true` consistently for cancelable events
9. **Data access**: Use `var loData = (MyDto)eventArgs.Data;` pattern consistently
10. **Async support**: Always mention "Async allowed if needed" when handler prefers `void`

## Common Patterns

### Cancellable Events (CRUD Before Events)
```csharp
private void EventName(CancellableEventArgs eventArgs)
{
    var loEx = new R_Exception();
    try
    {
        // Validation logic
        if (validation fails)
            eventArgs.Cancel = true;
    }
    catch (Exception ex)
    {
        loEx.Add(ex);
    }
    loEx.ThrowExceptionIfErrors();
}
```

### Data Access Events (CRUD After Events)
```csharp
private void EventName(DataEventArgs eventArgs)
{
    var loEx = new R_Exception();
    try
    {
        var loData = (MyDto)eventArgs.Data;
        // Use loData
    }
    catch (Exception ex)
    {
        loEx.Add(ex);
    }
    loEx.ThrowExceptionIfErrors();
}
```

### Navigation Return Events
```csharp
private void HandlerName(R_AfterOpenLookupEventArgs eventArgs)
{
    var loEx = new R_Exception();
    try
    {
        if (eventArgs.Result is null) return;
        var loResult = (MyDto)eventArgs.Result;
        // Process result
    }
    catch (Exception ex)
    {
        loEx.Add(ex);
    }
    loEx.ThrowExceptionIfErrors();
}
```

### Navigation Before-Open Events
```csharp
private void HandlerName(R_BeforeOpenPopupEventArgs eventArgs)
{
    var loEx = new R_Exception();
    try
    {
        eventArgs.PageNamespace = "OtherProject.Pages.TargetPage";
        eventArgs.Parameter = loParameter;
    }
    catch (Exception ex)
    {
        loEx.Add(ex);
    }
    loEx.ThrowExceptionIfErrors();
}
```

### Service Events (Always Async)
```csharp
private async Task EventName(R_ServiceSaveEventArgs eventArgs)
{
    var loEx = new R_Exception();
    try
    {
        var loEntity = (MyDto)eventArgs.Data;
        await _viewModel.SaveRecordAsync(loEntity, (eCRUDMode)eventArgs.ConductorMode);
        eventArgs.Result = _viewModel.CurrentRecord;
    }
    catch (Exception ex)
    {
        loEx.Add(ex);
    }
    loEx.ThrowExceptionIfErrors();
}
```

### Override Methods
```csharp
protected override async Task R_Init_From_Master(object? poParameter)
{
    var loEx = new R_Exception();
    try
    {
        // Implementation
    }
    catch (Exception ex)
    {
        loEx.Add(ex);
    }
    loEx.ThrowExceptionIfErrors();
}
```

## Notes

- All sections marked as optional should only be included if relevant to the specific event
- Sections marked as required must be present in every event migration pattern file
- Maintain consistency in formatting, terminology, and error handling patterns across all files
- When in doubt, refer to existing standardized event files as reference examples

