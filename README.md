# Script Guide

There are a few scripts available in the root folder:

1. `clean_build_folder.bat` — cleans all `bin`, `obj`, and `packages` folders in all nested directories. Run this first if you want to copy the whole project.
2. `copy_realta_blazor_library.bat` — copies new library DLLs to the current working folder for .NET 6.
3. `restore_app_razor_programs.ps1` and `restore_project_references.ps1` — called automatically by `copy_realta_blazor_library.bat`.
4. `update_all_git_repos.bat` — updates files in `.library` to the latest version from the `master` branch (works only if you have access to the repository).

<br>

# Folder Guide

[`.library`](.library) — folder for Library Source Code.

1. [`.net-core-library`](.library/net-core-library) — for .NET 6 Source Code.
2. [`.net-framework-library`](.library/net-framework-library) — for .NET 4 Source Code.

[`net4`](net4) — folder for .NET 4 Program Samples.
[`net6`](net6) — folder for .NET 6 Program Samples.

## Net Core Library

There are 4 folders inside:

1. [`BlazorTraining`](.library/net-core-library/BlazorTraining) — example of how to use the components for Front End Library.
2. [`RealtaBlazorLibrary`](.library/net-core-library/RealtaBlazorLibrary) — latest delivered DLLs for developers.

   * Used in [`Working Folder Library`](net6/RSF/BIMASAKTI_11/1.00/PROGRAM/SYSTEM/SOURCE).
   * To copy from library to the working folder, run `copy_realta_blazor_library.bat`.
3. [`RealtaLibrary`](.library/net-core-library/RealtaLibrary) — source code for microservices, engines, etc.
4. [`RealtaNetCoreLibrary`](.library/net-core-library/RealtaNetCoreLibrary) — source code for Blazor (mostly front-end components for GS and SA programs).

### RealtaNetCoreLibrary contains:

1. [`Library`](.library/net-core-library/RealtaNetCoreLibrary/Library) — contains **Blazor Components**.
2. [`Library Back`](.library/net-core-library/RealtaNetCoreLibrary/Library%20Back) — contains any library related to **Back & Services**.
3. [`Front`](.library/net-core-library/RealtaNetCoreLibrary/Front) — contains **Front and Model** projects for GS and SA programs.
4. [`Common`](.library/net-core-library/RealtaNetCoreLibrary/Common) — contains **Common** projects for GS and SA programs.
5. [`Resources`](.library/net-core-library/RealtaNetCoreLibrary/Resources) — contains **Resources** projects for GS and SA programs.
6. [`Services`](.library/net-core-library/RealtaNetCoreLibrary/Services) — contains **Services** projects for GS and SA programs.
7. [`Back`](.library/net-core-library/RealtaNetCoreLibrary/Back) — contains **Back** projects for GS and SA programs.

## Net Framework Library
### RealtaLibrary contains:

1. [`REL_FrontEnd`](.library/net-framework-library/Realta-Library/REL_FrontEnd) — contains **Front** Library Source Code.
2. [`REL_BackEnd`](.library/net-framework-library/Realta-Library/REL_BackEnd) — contains **Back** Library Source Code.
3. [`REL_Common`](.library/net-framework-library/Realta-Library/REL_Common) — contains **Common** Library Source Code.
4. [`MenuCls`](.library/net-framework-library/Realta-Library/MenuCls) — contains **Back & Common** projects for GS and SA programs.
5. [`MenuFront`](.library/net-framework-library/Realta-Library/MenuFront) — contains **Front & FrontResources** projects for GS and SA programs.
6. [`TelerikMenuService`](.library/net-framework-library/Realta-Library/TelerikMenuService) — contains **Services** projects for GS and SA programs and also the **Entry Point for Back End**.
7. [`TelerikMenu`](.library/net-framework-library/Realta-Library/TelerikMenu) — contains **Entry Point for Front End**.

---

