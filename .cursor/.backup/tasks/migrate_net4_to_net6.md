
---
title: "Plan Migration from .NET Framework 4 (VB) to .NET 6 (C#)"
description: "AI-guided migration plan generator for converting .NET Framework 4 (VB) projects into .NET 6 (C#) equivalents using internal Realta libraries."
tags: [migration, dotnet, csharp, vbnet, cursor-ai, realtalibrary]
---

# 🧭 AI Task: Plan Migration from .NET Framework 4 (VB) to .NET 6 (C#)

---

## 🎯 Goal

Migrate an existing **.NET Framework 4 (VB)** program using **internal libraries** into a **.NET 6 (C#)** program using updated **.NET 6 internal library equivalents**, ensuring **full behavioral parity**.

---

## ⚠️ Constraint (Do NOT change)

> **Never modify business logic, SQL queries, or Stored Procedures.**

* All data access and logic must behave identically to the original.
* If async or library API differences require refactoring, use wrappers/adapters — never alter SQL text or Stored Procedure names unless approved by the DB team.

---

## 📁 Folder Reference Rules

### Source (.NET Framework 4)
```

.cursor/docs/net4/

```

### Destination (.NET 6)
```

.cursor/docs/net6/

````

**Rules:**
* Always read `.cursor/docs/net6/` first to find target equivalents.  
* Use `.cursor/docs/net4/` only to understand old patterns.  
* Never mix namespaces from both frameworks in one file.  
* Always use updated internal libraries from `.cursor/docs/net6/RealtaLibrary` or `.cursor/docs/net6/RealtaNetCoreLibrary`.
* Always read `.cursor/memories/` for structures and templates.  
* Use GSM02500 as reference example for net6 structures and templates.  

---

## 🏗 Project Structure Mapping

| .NET 4 (VB) Project | .NET 6 (C#) Project(s) | Description |
|----------------------|------------------------|--------------|
| `{ProgramName}Back.vbproj` | `{ProgramName}Back.csproj` + `{ProgramName}Service.csproj` | Business logic + REST API |
| `{ProgramName}Common.vbproj` | `{ProgramName}Common.csproj` | Shared DTOs, interfaces |
| `{ProgramName}Front.vbproj` | `{ProgramName}Model.csproj` + `{ProgramName}Front.csproj` | Blazor UI + ViewModels |
| `{ProgramName}FrontResources.vbproj` | `{ProgramName}FrontResources.csproj` | Static assets and localization |

---

## ⚙️ Ordered Creation Workflow

Migrate **one project at a time**, in this order.  
Each step must be **confirmed** before moving on.

| Step | Project | Description | Confirmation Focus |
|------|----------|--------------|--------------------|
| 1️⃣ | **Common** | Shared DTOs, interfaces, enums | DTO parity, no logic leaks |
| 2️⃣ | **Back** | Business logic layer | SQL/SP names unchanged |
| 3️⃣ | **Service** | REST API wrapper layer | Endpoint parity with WCF |
| 4️⃣ | **Model** | Models for Blazor/ViewModel use | DTO consistency |
| 5️⃣ | **ViewModel** | Blazor-compatible logic | No direct DB access |
| 6️⃣ | **Front** | Blazor UI components | Binding and service wiring OK |
| 7️⃣ | **Build** | Final compile/test | Integration + smoke tests |

> 💡 **Tip:** Commit or branch after each confirmed project.

---

## 🔁 Migration Rules

### 🧩 Language Conversion
* VB.NET → C#
* Match naming and namespaces with `.cursor/docs/net6`
* Apply `async/await` patterns where applicable

### ⚙️ Framework Conversion
| From | To | Notes |
|------|----|-------|
| WCF | REST API Controllers | Replace service contracts |
| WinForms | Blazor Components | Port form logic into ViewModels |
| NHibernate | EF Core (if applicable) | Validate model compatibility |

> 🧠 **AI Hint:** Always verify replacements under `.cursor/docs/net6/RealtaLibrary` before mapping or refactoring.

---

## ✅ Automated Checklist Template (Per Project)

```markdown
### Project: {ProgramName}Back.vbproj

**Target Projects:**
- {ProgramName}Back.csproj
- {ProgramName}Service.csproj

**Conversion Tasks:**
- [ ] Convert `.vb` → `.cs`
- [ ] Replace `Imports R_*` → `using R_*` (.NET 6 equivalents)
- [ ] Update base: `R_BusinessObject<T>` → `R_BusinessObjectAsync<T>`
- [ ] Move service logic into API Controller classes
- [ ] Verify DTOs align with `{ProgramName}Common`
- [ ] Use `R_APIResultBaseDTO` for results
- [ ] Confirm async/await correctness

**Extra Validations:**
- [ ] Business logic parity confirmed (unit/integration tests)
- [ ] SQL / SP names & parameters unchanged
- [ ] DB smoke test passed
````

---

## 🗂 Output File Structure

```plaintext
/migration_plans/
├── {ProgramName}/
│   ├── migration_plan.md
│   ├── checklist_Back.md
│   ├── checklist_Common.md
│   ├── checklist_Front.md
│   └── library_diff.md
```

Each generated file must include:

* Files to convert
* Library replacements
* Config and test notes

---

## 🧠 AI Hints (for Cursor)

When generating the plan:

1. Start with a **high-level overview** of all `.vbproj` files in `.cursor/docs/net4/`.
2. Create a **structured checklist** for each project (using the template).
3. Always **cross-reference replacements** from `.cursor/docs/net6`.
4. Summarize **risks** and **manual migration tasks** clearly.
5. Validate **DLL/class existence** under `.cursor/docs/net6/`.
6. If a .NET 4 API is missing, search for its **async** or **REST** version before suggesting a rewrite.

---

## 🚨 Key Rule Reminder

> Always analyze `.cursor/docs/net6` first before assuming library or class mappings.

Maintain **zero-deviation** on:

* Business logic
* SQL / Stored Procedures
* API contracts

---
