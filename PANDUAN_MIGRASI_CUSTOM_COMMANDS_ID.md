# Panduan Penggunaan Custom Commands untuk Migrasi .NET 4 ke .NET 6

## Daftar Isi

1. [Pendahuluan - Mengapa Kita Membutuhkan AI Migrasi Ini?](#1-pendahuluan---mengapa-kita-membutuhkan-ai-migrasi-ini)
2. [Bagaimana AI Ini Membantu?](#2-bagaimana-ai-ini-membantu)
3. [Seberapa Besar Bantuan yang Diberikan?](#3-seberapa-besar-bantuan-yang-diberikan)
4. [Setup dan Persiapan](#4-setup-dan-persiapan)
5. [Cara Menggunakan Cursor IDE - Custom Commands](#5-cara-menggunakan-cursor-ide---custom-commands)
6. [Cara Kerja Custom Commands](#6-cara-kerja-custom-commands)

---

## 1. Pendahuluan - Mengapa Kita Membutuhkan AI Migrasi Ini?

### Tujuan Utama

Kami memerlukan AI migrasi ini untuk **mengonversi aplikasi dari .NET Framework 4 (VB.NET) ke .NET 6 (C#)** dengan waktu dan usaha yang jauh lebih sedikit dibandingkan migrasi manual.

### Tantangan Migrasi Manual

Migrasi manual dari VB.NET ke C# melibatkan:

- **Perbedaan Sintaks**: VB.NET dan C# memiliki sintaks yang sangat berbeda
- **Perubahan Arsitektur**: Dari WinForms/WPF ke Blazor WebAssembly
- **Framework Berbeda**: .NET Framework 4 ke .NET 6 dengan API yang berbeda
- **Volume Kode**: Ribuan baris kode yang harus dikonversi per program
- **Struktur Project**: Reorganisasi dari struktur lama ke struktur berlapis (layered architecture)
- **Business Logic**: Harus dipertahankan 100% tanpa perubahan
- **Database Operations**: Nama stored procedure dan query SQL tidak boleh berubah

Dengan kompleksitas ini, migrasi manual bisa memakan waktu berbulan-bulan untuk puluhan program.

### Solusi

AI migrasi dengan custom commands di Cursor IDE membantu mengotomasi sebagian besar proses konversi dengan tetap menjaga presisi dan mengikuti standar arsitektur yang telah ditentukan.

---

## 2. Bagaimana AI Ini Membantu?

AI migrasi ini membantu dalam berbagai aspek pengembangan:

### 2.1. Pembuatan Spesifikasi Stored Procedure
- Menganalisis kode VB.NET untuk mengidentifikasi stored procedure yang digunakan
- Mendokumentasikan parameter input dan output
- Membuat spesifikasi DTOs yang sesuai

### 2.2. Pembuatan Project Common
- **DTOs (Data Transfer Objects)**: Entity, Parameter, Result, Stream DTOs
- **Interfaces**: Service contracts yang inherit dari `R_IServiceCRUDAsyncBase`
- **Enums**: Enumerasi yang digunakan di seluruh aplikasi

### 2.3. Pembuatan Project Back dan BackResources
- **Business Logic**: Konversi logika bisnis dari VB.NET ke C# dengan preservasi 100%
- **Database Access**: Methods untuk akses database dengan stored procedures
- **Logger & Activity**: Implementasi logging dan activity tracking patterns
- **Error Messages**: Resource files untuk pesan error (BackResources project)

### 2.4. Pembuatan Project Service
- **API Controllers**: ASP.NET Core controllers yang implement interfaces dari Common
- **HTTP Endpoints**: RESTful API endpoints
- **Authorization**: Routing dan authorization patterns

### 2.5. Pembuatan Project Model
- **Service Clients**: Thin wrapper classes untuk memanggil API
- **HTTP Client**: Konfigurasi HTTP client untuk komunikasi dengan backend

### 2.6. Pembuatan Project ViewModel dan FrontResources
- **ViewModels**: Data state management dan validation logic
- **FrontResources**: Resource files untuk label dan pesan UI

### 2.7. Konversi Sintaks VB.NET ke C#
- Konversi sintaks dari VB.NET ke C#
- Konversi dari synchronous ke asynchronous patterns
- Konversi dari .NET Framework 4 API ke .NET 6 API
- Implementasi dependency injection patterns

---

## 3. Seberapa Besar Bantuan yang Diberikan?

### 3.1. Melewati Pembuatan Spesifikasi Sepenuhnya

AI dapat menganalisis kode VB.NET dan membuat struktur project baru **tanpa perlu pembuatan spesifikasi manual terlebih dahulu**. Ini menghemat sekitar **20-30%** waktu persiapan.

### 3.2. Bantuan Minimal 50% dari Total Pekerjaan Pengembangan

Berdasarkan pengalaman migrasi, custom commands membantu:

| Tahap Migrasi | Bantuan AI | Pekerjaan Manual |
|---------------|------------|------------------|
| Common Layer | ~70% | ~30% (review & adjustment) |
| Back Layer | ~60% | ~40% (complex business logic) |
| Service Layer | ~80% | ~20% (review) |
| Model Layer | ~90% | ~10% (review) |
| ViewModel Layer | ~50% | ~50% (UI state management) |
| Front Layer | **0%** | **100% (manual)** |
| Solution Integration | ~70% | ~30% (verification) |

**Total bantuan rata-rata: 50-60%** dari seluruh pekerjaan pengembangan.

### 3.3. Apa yang Masih Perlu Dilakukan Manual?

Meskipun AI membantu banyak, beberapa hal masih memerlukan intervensi manual:

- **Review Business Logic**: Memastikan logika bisnis kompleks terkonversi dengan benar
- **Complex UI Logic**: State management dan event handling yang kompleks di ViewModel
- **Front Layer**: Pembuatan Blazor components sepenuhnya manual (ToCSharpFront tidak diimplementasikan)
- **Testing**: Functional testing dan debugging
- **Fine-tuning**: Optimization dan performance tuning
- **Custom Requirements**: Logika khusus yang tidak mengikuti pattern standard

---

## 4. Setup dan Persiapan

### 4.1. Download dan Install Cursor IDE

1. **Download Cursor IDE**
   - Kunjungi [https://cursor.sh](https://cursor.sh)
   - Download installer untuk Windows
   - Jalankan installer dan ikuti instruksi instalasi

2. **Verifikasi Instalasi**
   - Buka Cursor IDE
   - Pastikan aplikasi berjalan dengan baik

### 4.2. Login ke Akun Cursor yang Aktif

1. **Buka Cursor IDE**

2. **Login atau Sign Up**
   - Klik tombol "Sign In" di pojok kanan atas
   - Login menggunakan akun yang sudah ada atau buat akun baru
   - Pilih subscription plan (Pro atau Trial)

3. **Konfigurasi Model AI**
   - Buka Settings (Ctrl + ,)
   - Pilih tab "AI"
   - Pilih model: **Auto** (akan otomatis memilih model terbaik)
   - Pastikan "Custom Commands" diaktifkan

### 4.3. Clone Repository GitHub

1. **Clone Repository**
   ```bash
   git clone [URL_REPOSITORY] D:\_Cursor
   cd D:\_Cursor
   ```

2. **Verifikasi Struktur Folder**
   Pastikan struktur folder berikut ada:
   ```
   D:\_Cursor\
   ├── .cursor\
   │   ├── commands\       # Custom command definitions
   │   ├── rules\          # Migration rules and patterns
   │   └── docs\           # Documentation
   ├── net4\               # Source VB.NET code
   │   └── FA\             # Module folders (FA, GS, SA, etc.)
   ├── net6\               # Target C# code
   │   └── RSF\
   └── plan\               # Migration plans (auto-generated)
   ```

### 4.4. Setup Struktur Folder yang Diperlukan

1. **Update Libraries**
   ```bash
   update_all_git_repos.bat
   ```
   Script ini akan update library files dari repository ke folder `.library`.

2. **Copy Library DLLs**
   ```bash
   copy_realta_blazor_library.bat
   ```
   Script ini akan copy DLL files ke working folder `net6/RSF/BIMASAKTI_11/1.00/PROGRAM/SYSTEM/SOURCE`.

3. **Verifikasi Structure**
   Pastikan folder berikut ada:
   ```
   net6\RSF\BIMASAKTI_11\1.00\PROGRAM\BS Program\SOURCE\
   ├── COMMON\
   ├── BACK\
   ├── SERVICE\
   └── FRONT\
   ```

4. **Clean Build (Optional)**
   Jika perlu membersihkan build folders:
   ```bash
   clean_build_folder.bat
   ```

### 4.5. Verifikasi Custom Commands Tersedia

1. **Buka Command Palette**
   - Tekan `Ctrl + Shift + P` (Windows)
   - Atau klik ikon ⚡ di sidebar kiri

2. **Lihat Custom Commands**
   Pastikan custom commands berikut tersedia:
   - `/ToCSharpCommon`
   - `/ToCSharpBack`
   - `/ToCSharpService`
   - `/ToCSharpModel`
   - `/ToCSharpViewModel`
   - `/ToCSharpFront` (tidak digunakan)
   - `/ValidationAndBuild`
   - `/SolutionManager`

---

## 5. Cara Menggunakan Cursor IDE - Custom Commands

### 5.1. ToCSharpCommon

**Tujuan**: Konversi VB.NET DTOs, enums, dan interfaces ke C# Common project.

**Kapan Digunakan**: Langkah pertama migrasi (sebelum layer lainnya).

**Cara Menggunakan**:

1. **Buka Command Palette**
   - Tekan `Ctrl + Shift + P`
   - Atau klik ikon ⚡ di sidebar kiri

2. **Pilih Mode PLAN**
   - Pilih "Plan Mode" di Cursor
   - Ini akan membuat AI merencanakan dulu sebelum eksekusi

3. **Ketik Custom Command**
   - Ketik `/ToCSharpCommon`
   - Atau ketik trigger: `common`

4. **Input Prompt**
   Copy dan paste prompt berikut (ganti `FAM00500` dengan program Anda):
   ```
   convert VB DTOs in `/net4/**/Back/FAM00500*/**/*.vb` into DTOs under `/net6/**/COMMON/FA/FAM00500Common/` following rules and patterns defined in `.cursor/rules`. ProgramName: FAM00500
   ```

5. **Review Plan**
   - AI akan generate plan
   - Review plan dengan teliti
   - Jika OK, approve plan
   - Plan akan otomatis tersimpan di folder `/plan/`

6. **Eksekusi**
   - AI akan mulai konversi
   - Monitor progress
   - Jika ada error, AI akan mencoba fix otomatis

**Output**:
```
net6/RSF/.../COMMON/FA/FAM00500Common/
├── DTOs/
│   ├── FAM00500DTO.cs           # Entity DTO
│   ├── GetListParameterDTO.cs   # Parameter DTOs
│   ├── GetListResultDTO.cs      # Result DTOs
│   └── ...
├── IFAM00500.cs                 # Interface
└── FAM00500Common.csproj
```

**Hal yang Perlu Diperhatikan**:
- ✅ Pastikan tidak ada business logic di Common layer
- ✅ Setiap method punya ParameterDTO dan ResultDTO sendiri
- ✅ Interfaces inherit dari `R_IServiceCRUDAsyncBase`
- ✅ String defaults menggunakan `string.Empty`
- ✅ DateTime properties TIDAK nullable

---

### 5.2. ToCSharpBack

**Tujuan**: Konversi VB.NET business logic ke C# Back project dengan logging dan activity patterns.

**Kapan Digunakan**: Setelah Common layer selesai.

**Cara Menggunakan**:

1. **Pastikan Common Layer Sudah Selesai**
   - Verifikasi `{ProgramName}Common` project sudah ada
   - Build common project untuk memastikan tidak ada error

2. **Pilih Mode PLAN**

3. **Ketik Custom Command**
   - Ketik `/ToCSharpBack`
   - Atau ketik trigger: `back`

4. **Input Prompt**
   ```
   convert `/net4/**/Back/FAM00500*/**/*.vb` into Back and Back Resources Project under `/net6/**/BACK/FA/FAM00500Back/` following rules and patterns defined in `.cursor/rules`. ProgramName: FAM00500
   ```

5. **Review Plan dan Approve**

6. **Eksekusi**

**Output**:
```
net6/RSF/.../BACK/FA/FAM00500Back/
├── DTOs/
│   ├── LoggerFAM00500.cs        # Logger class
│   └── FAM00500Activity.cs      # Activity class
├── FAM00500Cls.cs               # Business logic
└── FAM00500Back.csproj

net6/RSF/.../BACK/FA/FAM00500BackResources/
├── FAM00500BackResources_msgrsc.resx
├── FAM00500BackResources_msgrsc.id.resx
├── FAM00500BackResources_msgrsc.Designer.cs
├── Resources_Dummy_Class.cs
└── FAM00500BackResources.csproj
```

**Hal yang Perlu Diperhatikan**:
- ⚠️ **JANGAN rename SQL queries atau stored procedures**
- ✅ Preserve business logic 100% (bahkan jika ada bug)
- ✅ Implement Logger dan Activity patterns
- ✅ Gunakan `R_Exception` pattern untuk error handling
- ✅ Semua methods harus async (`async Task`)

---

### 5.3. ToCSharpService

**Tujuan**: Membuat ASP.NET Core API controllers yang implement Common interfaces.

**Kapan Digunakan**: Setelah Back layer selesai.

**Cara Menggunakan**:

1. **Pastikan Common dan Back Layer Sudah Selesai**

2. **Pilih Mode PLAN**

3. **Ketik Custom Command**
   - Ketik `/ToCSharpService`
   - Atau ketik trigger: `service`

4. **Input Prompt**
   ```
   implement Common interfaces as controllers in `/net6/**/SERVICE/FA/FAM00500Service/` following rules and patterns defined in `.cursor/rules`, calling the Back project for business logic. ProgramName: FAM00500
   ```

5. **Review Plan dan Approve**

6. **Eksekusi**

**Output**:
```
net6/RSF/.../SERVICE/FA/FAM00500Service/
├── FAM00500Controller.cs
└── FAM00500Service.csproj
```

**Hal yang Perlu Diperhatikan**:
- ✅ Controllers implement interfaces dari Common layer
- ✅ Controllers delegate ke Back classes (no business logic)
- ✅ Gunakan `R_BackGlobalVar` untuk `IClientHelper` access
- ✅ Handle streaming context untuk custom parameters

---

### 5.4. ToCSharpModel

**Tujuan**: Membuat service client classes yang akan digunakan ViewModels untuk call API.

**Kapan Digunakan**: Setelah Service layer selesai.

**Cara Menggunakan**:

1. **Pastikan Service Layer Sudah Selesai**

2. **Pilih Mode PLAN**

3. **Ketik Custom Command**
   - Ketik `/ToCSharpModel`
   - Atau ketik trigger: `model`

4. **Input Prompt**
   ```
   create service-layer clients for `/net6/**/SERVICE/FA/FAM00500Service/*Controller.cs` signatures into `/net6/**/FRONT/FAM00500Model/*Model.cs` following rules and patterns defined in `.cursor/rules`. ProgramName: FAM00500
   ```

5. **Review Plan dan Approve**

6. **Eksekusi**

**Output**:
```
net6/RSF/.../FRONT/FAM00500Model/
├── FAM00500Model.cs
├── VMs/                         # (akan diisi oleh ViewModel layer)
└── FAM00500Model.csproj
```

**Hal yang Perlu Diperhatikan**:
- ✅ Models adalah thin wrappers (no business logic)
- ✅ Models menggunakan HTTP client untuk call Service layer
- ✅ Models reference Common project untuk DTOs

---

### 5.5. ToCSharpViewModel

**Tujuan**: Konversi UI logic dari VB.NET forms ke ViewModels yang manage data state.

**Kapan Digunakan**: Setelah Model layer selesai.

**Cara Menggunakan**:

1. **Pastikan Model Layer Sudah Selesai**

2. **Pilih Mode PLAN**

3. **Ketik Custom Command**
   - Ketik `/ToCSharpViewModel`
   - Atau ketik trigger: `viewmodel`

4. **Input Prompt**
   ```
   convert each CRUD mode inside each pages in `/net4/**/Front/FAM00500*/**/*.vb` into each respective `/net6/**/FRONT/FAM00500Model/VMs/{PageName}ViewModel.cs` that use `/net6/**/FRONT/FAM00500Model/*Model.cs` to get the data needed for Front layer. ProgramName: FAM00500
   ```

5. **Review Plan dan Approve**

6. **Eksekusi**

**Output**:
```
net6/RSF/.../FRONT/FAM00500Model/
├── FAM00500Model.cs
├── VMs/
│   ├── FAM00500ViewModel.cs
│   └── ...
└── FAM00500Model.csproj

net6/RSF/.../FRONT/FAM00500FrontResources/
├── FAM00500FrontResources_msgrsc.resx
├── FAM00500FrontResources_msgrsc.id.resx
├── FAM00500FrontResources_msgrsc.Designer.cs
└── FAM00500FrontResources.csproj
```

**Hal yang Perlu Diperhatikan**:
- ✅ ViewModels HARUS inherit dari `R_ViewModel<T>`
- ⚠️ **JANGAN gunakan `R_FrontGlobalVar` di ViewModels**
- ✅ `IClientHelper` hanya boleh di `.razor.cs` (code-behind), BUKAN di ViewModels
- ✅ Data state di ViewModel; UI-only state di Razor.cs
- ✅ Data validation HANYA di ViewModels, BUKAN di code-behind
- ✅ Satu CRUD entity per ViewModel

---

### 5.6. ToCSharpFront

**Status**: ⚠️ **TIDAK DIIMPLEMENTASIKAN - Buat Project Front Secara Manual**

**Tujuan**: Konversi VB.NET WinForms/WPF UI ke Blazor components.

**Mengapa Tidak Diimplementasikan?**
- UI layer sangat kompleks dan memerlukan keputusan desain manual
- Binding dan event handling perlu disesuaikan per kasus
- Component layout memerlukan pertimbangan UX yang tidak bisa diotomasi sepenuhnya

**Cara Manual Membuat Front Layer**:

1. **Buat Project Structure**
   ```
   net6/RSF/.../FRONT/FAM00500Front/
   ├── FAM00500.razor
   ├── FAM00500.razor.cs
   ├── _Imports.razor
   └── FAM00500Front.csproj
   ```

2. **Buat .csproj File**
   - Copy dari project Front lain yang sudah ada
   - Adjust ProgramName dan references

3. **Buat _Imports.razor**
   - Tambahkan semua `@using` statements yang diperlukan
   - **JANGAN taruh `@using` di file `.razor` individual**

4. **Buat .razor.cs (Code-Behind)**
   - Implement `[Inject]` dependencies
   - **SEMUA `[Inject]` HARUS di `.razor.cs`, JANGAN di `.razor`**
   - Inject ViewModel dan services
   - Implement event handlers
   - UI state management

5. **Buat .razor (UI Markup)**
   - Implement Blazor component markup
   - Data binding ke ViewModel properties
   - Event binding ke code-behind methods
   - Gunakan R_Grid, R_TextBox, R_Button, dll.

6. **Referensi yang Perlu Dipelajari**:
   - Lihat contoh di folder `net6/.../FRONT/` untuk program lain
   - Baca `.cursor/docs/net6/` untuk component documentation
   - Ikuti migration patterns di `.cursor/rules/front/components/migration-patterns/`

---

### 5.7. ValidationAndBuild

**Tujuan**: Validasi struktur project dan build semua projects dengan error reporting.

**Kapan Digunakan**: Setelah menyelesaikan sebuah layer atau sebelum final integration.

**Cara Menggunakan**:

1. **Pilih Mode PLAN**

2. **Ketik Custom Command**
   - Ketik `/ValidationAndBuild`
   - Atau ketik trigger: `validate`

3. **Input Prompt**
   ```
   validate and build `/net6/**/FAM00500*.csproj` following `*MigrationChecklist*`. Run builds and return BUILD SUMMARY reports for All projects. ProgramName: FAM00500
   ```

4. **Review Plan dan Approve**

5. **Eksekusi dan Tunggu Build**

**Output**: BUILD SUMMARY report dengan format:
```
=== BUILD SUMMARY ===

Project: FAM00500Common
Status: ✓ SUCCESS
Warnings: 2 (1 Code, 1 External)
Errors: 0

Project: FAM00500Back
Status: ✓ SUCCESS
Warnings: 0
Errors: 0

...

=== TOTAL ===
Projects Built: 6
Success: 6
Failed: 0
```

**Hal yang Perlu Diperhatikan**:
- ✅ Pre-build validation (csproj settings, DLL references)
- ✅ Builds projects dalam urutan yang benar
- ✅ Klasifikasi warnings (Code, External, Infrastructure)
- ✅ Generate standardized BUILD SUMMARY report
- ✅ Attempt safe fixes otomatis

**Warning Classification**:
- **Code Warnings (CS####)**: Harus diperbaiki
- **External Warnings (NU####, MSB####)**: Dokumentasikan dengan alasan
- **Infrastructure Warnings**: Dokumentasikan jika acceptable

---

### 5.8. SolutionManager

**Tujuan**: Manage solution structure, menambahkan projects, dan integrasi dengan API/BlazorMenu.

**Kapan Digunakan**: Setelah semua layers telah dimigrasi dan validated.

**Cara Menggunakan**:

1. **Pastikan Semua Layers Sudah Selesai dan Validated**

2. **Pilih Mode PLAN**

3. **Ketik Custom Command**
   - Ketik `/SolutionManager`
   - Atau ketik trigger: `solution`

4. **Input Prompt**
   ```
   add FAM00500. ProgramName: FAM00500
   ```

5. **Review Plan dan Approve**

6. **Eksekusi**

**Apa yang Dilakukan**:

1. **Add Backend Projects ke BIMASAKTI11_BACK.sln**
   - FAM00500Common
   - FAM00500BackResources
   - FAM00500Back
   - FAM00500Service

2. **Add Frontend Projects ke BIMASAKTI11_FRONT.sln**
   - FAM00500Common
   - FAM00500Model
   - FAM00500FrontResources
   - FAM00500Front

3. **Add Service Project Reference ke Module API**
   - Add reference di `BIMASAKTI_FA_API.csproj`
   - Maintain alphabetical ordering

4. **Add Front Project Reference ke BlazorMenu**
   - Add reference di `BlazorMenu.csproj`
   - Add assembly entry di `BlazorMenu/App.razor`
   - Maintain alphabetical ordering

**Hal yang Perlu Diperhatikan**:
- ✅ Maintain GUID uniqueness untuk semua projects
- ✅ Maintain alphabetical ordering di semua references
- ✅ Verifikasi solution files bisa dibuka di Visual Studio
- ✅ Verifikasi API endpoints accessible
- ✅ Verifikasi BlazorMenu bisa load program

---

## 6. Cara Kerja Custom Commands

### 6.1. ToCSharpCommon - Apa yang Dilakukan?

**Input**: 
- VB.NET files dari `net4/**/Back/{ProgramName}*/**/*.vb`

**Proses**:
1. **Analisis VB.NET Code**
   - Scan semua VB.NET files untuk mencari class definitions
   - Identify DTOs, enums, dan interfaces

2. **Fetch Rules**
   - Load rules dari `.cursor/rules/common/`
   - Load patterns dari `.cursor/rules/patterns/`

3. **Generate DTOs**
   - Entity DTOs: untuk represent database tables
   - Parameter DTOs: untuk method inputs (satu per method)
   - Result DTOs: untuk method outputs (satu per method)
   - Stream DTOs: untuk streaming operations

4. **Generate Interfaces**
   - Extract method signatures dari VB.NET
   - Create C# interfaces yang inherit `R_IServiceCRUDAsyncBase`
   - Convert types dari VB.NET ke C#

5. **Generate Enums**
   - Convert VB.NET enums ke C# enums
   - Preserve values dan naming

6. **Create Project Structure**
   - Generate `{ProgramName}Common.csproj`
   - Setup DLL references dengan HintPath
   - Setup project references

7. **Validation**
   - Validate DTO structure
   - Validate interface inheritance
   - Validate naming conventions

8. **Save Plan**
   - Generate migration plan
   - Save ke `/plan/{timestamp}_ToCSharpCommon_{ProgramName}_plan.md`

**Output**:
- `{ProgramName}Common` project dengan struktur lengkap

---

### 6.2. ToCSharpBack - Apa yang Dilakukan?

**Input**: 
- VB.NET files dari `net4/**/Back/{ProgramName}*/**/*.vb`
- DTOs dari `{ProgramName}Common` project

**Proses**:
1. **Analisis Business Logic**
   - Scan VB.NET files untuk business logic classes
   - Identify methods, SQL queries, stored procedures
   - Extract error messages

2. **Fetch Rules**
   - Load rules dari `.cursor/rules/back/`
   - Load patterns untuk Logger, Activity, database access

3. **Generate Logger Class**
   - Create `Logger{ProgramName}.cs`
   - Inherit dari `R_NetCoreLoggerBase<Logger{ProgramName}>`
   - Implement logging patterns

4. **Generate Activity Class**
   - Create `{ProgramName}Activity.cs`
   - Inherit dari `R_ActivitySourceBase`
   - Implement activity tracking

5. **Convert Business Logic**
   - Convert VB.NET business classes ke C#
   - Preserve SQL queries dan stored procedure names **EXACTLY**
   - Convert synchronous methods ke async
   - Implement `R_Exception` error handling pattern
   - Replace error strings dengan resource keys

6. **Generate BackResources Project**
   - Create `{ProgramName}BackResources` project
   - Generate `.resx` files untuk error messages
   - Generate Designer.cs files
   - Create Resources_Dummy_Class.cs

7. **Create Project Structure**
   - Generate `{ProgramName}Back.csproj`
   - Generate `{ProgramName}BackResources.csproj`
   - Setup DLL references
   - Setup project references (reference ke Common)

8. **Validation**
   - Validate stored procedure names tidak berubah
   - Validate business logic preservation
   - Validate error handling patterns

**Output**:
- `{ProgramName}Back` project
- `{ProgramName}BackResources` project

**Critical Rules**:
- ⚠️ SQL queries dan stored procedure names **TIDAK BOLEH BERUBAH**
- ⚠️ Business logic **HARUS 100% sama** (even bugs)
- ⚠️ Semua error messages **HARUS dari resource files**

---

### 6.3. ToCSharpService - Apa yang Dilakukan?

**Input**: 
- Interfaces dari `{ProgramName}Common` project
- Business logic dari `{ProgramName}Back` project

**Proses**:
1. **Analisis Common Interfaces**
   - Read interface definitions
   - Extract method signatures
   - Identify parameter DTOs dan result DTOs

2. **Fetch Rules**
   - Load rules dari `.cursor/rules/service/`
   - Load controller patterns

3. **Generate API Controllers**
   - Create `{ProgramName}Controller.cs`
   - Implement interfaces dari Common
   - Add controller attributes: `[ApiController]`, `[Route]`
   - Add authorization attributes

4. **Implement Controller Methods**
   - For each interface method:
     - Create controller endpoint
     - Extract parameters dari HTTP request
     - Call corresponding Back method
     - Handle exceptions dengan `R_Exception`
     - Return result

5. **Handle Streaming Context**
   - Implement streaming context handling untuk custom parameters
   - Use `R_BackGlobalVar` untuk `IClientHelper` access

6. **Create Project Structure**
   - Generate `{ProgramName}Service.csproj`
   - Setup DLL references
   - Setup project references (ke Common dan Back)

7. **Validation**
   - Validate controller implements all interface methods
   - Validate routing patterns
   - Validate parameter passing

**Output**:
- `{ProgramName}Service` project dengan API controllers

**Critical Rules**:
- Controllers **TIDAK BOLEH** ada business logic
- Controllers hanya delegate ke Back classes
- Semua calls ke Back harus async

---

### 6.4. ToCSharpModel - Apa yang Dilakukan?

**Input**: 
- Controller signatures dari `{ProgramName}Service` project
- DTOs dari `{ProgramName}Common` project

**Proses**:
1. **Analisis Service Controllers**
   - Read controller definitions
   - Extract method signatures dan routes
   - Identify parameter DTOs dan result DTOs

2. **Fetch Rules**
   - Load rules dari `.cursor/rules/model/`
   - Load HTTP client patterns

3. **Generate Model Classes**
   - Create `{ProgramName}Model.cs`
   - Inherit dari `R_APIClient`
   - Inject HTTP client dependencies

4. **Implement Model Methods**
   - For each controller endpoint:
     - Create wrapper method
     - Build HTTP request (GET/POST)
     - Serialize parameters
     - Call API endpoint
     - Deserialize response
     - Return result DTO

5. **Handle Streaming vs Non-Streaming**
   - Implement streaming pattern untuk list methods
   - Implement non-streaming pattern untuk CRUD methods

6. **Create Project Structure**
   - Generate `{ProgramName}Model.csproj`
   - Create `VMs/` folder (untuk ViewModels nanti)
   - Setup DLL references
   - Setup project references (ke Common)

7. **Validation**
   - Validate semua API endpoints memiliki wrapper methods
   - Validate HTTP client configuration

**Output**:
- `{ProgramName}Model` project dengan service clients

**Critical Rules**:
- Models **HARUS thin wrappers** (no business logic)
- Models hanya bertanggung jawab untuk HTTP communication

---

### 6.5. ToCSharpViewModel - Apa yang Dilakukan?

**Input**: 
- VB.NET form files dari `net4/**/Front/{ProgramName}*/**/*.vb`
- Model classes dari `{ProgramName}Model` project

**Proses**:
1. **Analisis VB.NET Forms**
   - Scan VB.NET form files
   - Identify CRUD operations (Add, Edit, Delete, Display)
   - Extract validation logic
   - Extract data binding logic
   - Extract UI labels dan messages

2. **Fetch Rules**
   - Load rules dari `.cursor/rules/viewmodel/`
   - Load ViewModel patterns
   - Load resource patterns

3. **Generate ViewModel Classes**
   - For each form/page:
     - Create `{PageName}ViewModel.cs` di folder `VMs/`
     - Inherit dari `R_ViewModel<T>` (T = Entity DTO)
     - Inject Model dependencies
     - **TIDAK inject `IClientHelper`** (forbidden in ViewModels)

4. **Implement ViewModel Methods**
   - **GetListRecord**: Fetch list data dari API via Model
   - **GetRecord**: Fetch single record
   - **SaveRecord**: Save (insert/update) record
   - **DeleteRecord**: Delete record
   - **Validation**: Data validation logic
   - **ObservableCollections**: Untuk grid data binding

5. **Separate Data State vs UI State**
   - **Data state**: di ViewModel (entity data, validation)
   - **UI state**: akan di Razor.cs (component visibility, loading state)

6. **Generate FrontResources Project**
   - Create `{ProgramName}FrontResources` project
   - Extract UI labels dari VB.NET forms
   - Generate `.resx` files
   - Generate Designer.cs files

7. **Create Project Structure**
   - Update `{ProgramName}Model.csproj` untuk include VMs folder
   - Generate `{ProgramName}FrontResources.csproj`
   - Setup DLL references
   - Setup project references

8. **Validation**
   - Validate ViewModels inherit `R_ViewModel<T>`
   - Validate **NO `R_FrontGlobalVar`** usage
   - Validate data state separation
   - Validate ObservableCollections use ResultDTO (not EntityDTO)

**Output**:
- ViewModel classes di `{ProgramName}Model/VMs/`
- `{ProgramName}FrontResources` project

**Critical Rules**:
- ⚠️ ViewModels **HARUS inherit** dari `R_ViewModel<T>`
- ⚠️ **TIDAK BOLEH gunakan** `R_FrontGlobalVar` di ViewModels
- ⚠️ `IClientHelper` **HANYA di `.razor.cs`**, BUKAN di ViewModels
- ⚠️ Data validation **HANYA di ViewModels**
- ⚠️ Satu CRUD entity per ViewModel

---

### 6.6. ToCSharpFront - Tidak Diimplementasikan

**Status**: ⚠️ **TIDAK DIIMPLEMENTASIKAN**

Custom command ini tidak diimplementasikan karena:

1. **Kompleksitas UI**: Setiap aplikasi punya UI requirements yang unik
2. **Design Decisions**: Layout, styling, UX memerlukan keputusan manual
3. **Component Selection**: Pemilihan component (Grid, TextBox, etc.) butuh context
4. **Event Handling**: Event flows sangat bervariasi per aplikasi
5. **State Management**: UI state management kompleks dan case-by-case

**Alternatif**:
- Buat Front layer secara **manual** mengikuti contoh dari program lain
- Gunakan migration patterns di `.cursor/rules/front/components/migration-patterns/`
- Referensi documentation di `.cursor/docs/net6/`

---

### 6.7. ValidationAndBuild - Apa yang Dilakukan?

**Input**: 
- Project files (`{ProgramName}*.csproj`)
- Migration checklists

**Proses**:
1. **Pre-Build Validation**
   - Check `.csproj` structure dan settings
   - Validate DLL references (HintPath correctness)
   - Validate project references (relative paths)
   - Check namespace conventions
   - Check file organization

2. **Fetch Checklists**
   - Load checklists dari `.cursor/rules/checklist/`
   - Load layer-specific validation rules

3. **Build Projects in Order**
   - Determine build order berdasarkan dependencies
   - Build Common project first
   - Build Resources projects
   - Build Back project
   - Build Service project
   - Build Model project
   - Build Front project (if exists)

4. **Capture Build Output**
   - Capture compiler warnings dan errors
   - Classify warnings:
     - **Code Warnings (CS####)**: dari code Anda
     - **External Warnings (NU####, MSB####)**: dari external tools
     - **Infrastructure Warnings**: dari build infrastructure

5. **Attempt Safe Fixes**
   - For common errors, attempt automatic fixes
   - Rerun builds after fixes
   - Track fixed vs unfixed issues

6. **Generate BUILD SUMMARY**
   - Create standardized report format
   - List all projects dengan status
   - Categorize warnings
   - Provide fix recommendations

7. **Save Report**
   - Save build report
   - Document warnings dan rationale

**Output**:
- BUILD SUMMARY report
- Build error logs (if any)
- Recommendations untuk fixes

**Critical Rules**:
- Code Warnings (CS####) **HARUS diperbaiki**
- External Warnings **didokumentasikan** dengan alasan
- Build order **HARUS correct** (dependencies first)

---

### 6.8. SolutionManager - Apa yang Dilakukan?

**Input**: 
- Program name
- Semua project files yang sudah migrasi

**Proses**:
1. **Identify Projects**
   - Find all `{ProgramName}*.csproj` files
   - Categorize: Backend vs Frontend
   - Extract project GUIDs

2. **Fetch Rules**
   - Load rules dari `.cursor/rules/solution/`
   - Load solution structure patterns

3. **Update Backend Solution (BIMASAKTI11_BACK.sln)**
   - Add Common project
   - Add BackResources project
   - Add Back project
   - Add Service project
   - Maintain alphabetical ordering
   - Generate unique GUIDs if needed

4. **Update Frontend Solution (BIMASAKTI11_FRONT.sln)**
   - Add Common project
   - Add Model project
   - Add FrontResources project
   - Add Front project (if exists)
   - Maintain alphabetical ordering

5. **Integrate with Module API**
   - Identify module (FA, GS, SA, etc.)
   - Find corresponding API project (e.g., `BIMASAKTI_FA_API.csproj`)
   - Add Service project reference
   - Maintain alphabetical ordering

6. **Integrate with BlazorMenu**
   - Add Front project reference to `BlazorMenu.csproj`
   - Add assembly entry to `BlazorMenu/App.razor`:
     ```csharp
     typeof({ProgramName}Front.{ProgramName}).Assembly
     ```
   - Maintain alphabetical ordering

7. **Validation**
   - Validate solution files syntax
   - Validate GUID uniqueness
   - Validate project paths correctness
   - Test solution dapat dibuka di Visual Studio

8. **Save Changes**
   - Save solution files
   - Save project reference updates

**Output**:
- Updated `BIMASAKTI11_BACK.sln`
- Updated `BIMASAKTI11_FRONT.sln`
- Updated `BIMASAKTI_{Module}_API.csproj`
- Updated `BlazorMenu.csproj` dan `App.razor`

**Critical Rules**:
- Project GUIDs **HARUS unique**
- References **HARUS alphabetically ordered**
- Solution files **HARUS valid syntax**
- API integration **HARUS correct module**

---

## Kesimpulan

Custom commands di Cursor IDE memberikan bantuan signifikan dalam proses migrasi dari .NET Framework 4 (VB.NET) ke .NET 6 (C#). Dengan memahami cara kerja setiap custom command dan mengikuti workflow yang benar, Anda dapat menghemat **50-60%** waktu pengembangan.

**Workflow Lengkap**:
1. Setup environment dan repository
2. Jalankan `ToCSharpCommon` untuk Common layer
3. Jalankan `ToCSharpBack` untuk Back layer
4. Jalankan `ToCSharpService` untuk Service layer
5. Jalankan `ToCSharpModel` untuk Model layer
6. Jalankan `ToCSharpViewModel` untuk ViewModel layer
7. **Buat Front layer secara manual** (ToCSharpFront tidak diimplementasikan)
8. Jalankan `ValidationAndBuild` untuk validasi
9. Jalankan `SolutionManager` untuk integrasi solution
10. Test dan debug

**Hal Penting yang Harus Diingat**:
- ⚠️ **JANGAN skip steps** atau ubah urutan migrasi
- ⚠️ **SELALU review plans** sebelum approve
- ⚠️ **PRESERVE business logic** 100% (jangan ubah SQL/SP names)
- ⚠️ **Front layer dibuat manual** (ToCSharpFront tidak diimplementasikan)
- ⚠️ **Gunakan Mode PLAN** untuk semua custom commands

Selamat bermigrasi! 🚀

