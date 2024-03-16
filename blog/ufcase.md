---
title: UFCase README
date: 2023-09-13 00:00:00
description: "Deep dive into \"Servicing Stack\""
---

[GitHub Repository](https://github.com/seven-mile/UFCase)

> **IMPORTANT**
> 
> This tool is experimental and requires full control on your PC. Please DO NOT use it under production environment, especially for the mutation functionalities, which are not properly tested for now.

Windows Servicing Stack is the main infrastructure that integrated with the update of Windows internal components (generally).

UFCase (Utility Functions Case) provides overall enumeration (and possibly deployment in the future) of multi-level abstractions of these Windows components.

The article [Understanding Component-Based Servicing
](https://techcommunity.microsoft.com/t5/ask-the-performance-team/understanding-component-based-servicing/ba-p/373012) provides the overview on the Servicing Stack and how it roughly works when an update is installed or removed.

### Releases

I'll publish breaking changes for UFCase in the [GitHub releases](https://github.com/seven-mile/UFCase/releases). And the CI will upload nightly build artifacts of the newest commit. Goto [GitHub actions](https://github.com/seven-mile/UFCase/actions), click the commit you prefer and download `UFCase_portable.zip` from the row `Artifacts`.

### Glossary

All the descriptions below are woven by my own understanding. For your information only.

Firstly, let's take a look at the underlying mechanisms, which interact with our well-known filesystems and registry.

* **Assembly**, is a core concept from .Net but used by Windows Componentization Platform. [Assemblies in .NET](https://learn.microsoft.com/en-us/dotnet/standard/assembly/)
  * The concept of assembly connects different layers of servicing stack.
  * Its **Manifest** uses xml format with schema denoted as `urn:schemas-microsoft-com:asm.v[1~3]`. This article [Manifest File Schema](https://learn.microsoft.com/en-us/windows/win32/sbscs/manifest-file-schema) describes the public parts. But most of the schema about windows native components is stripped. There's also a binary representation rather than dumb XML format.
* **Component**, is a native assembly that compose Windows in the end. Almost everything in Windows can be traced back to a component, including NT Kernel, NTFS driver, servicing stack itself, C runtime framework, system apps and localization resources. The main contents of a real component are a group of files and registry values, with other metadata like
  * the source and target concerning installation 
  * security descriptors signing how they are protected by the system (Windows Resource Protection)
  * hash values validating the integrity of the component
  * other registration mechanisms like COM interfaces and Win32 window classes
  * dependencies
* **Deployment**, is a special component that defines a bunch of deployable contents by its assembly dependencies.
* **WinSxS**, or **Component Store**, is a strong naming, dependency-aware, version-controlled, digitally-signed, corruption-detectable, transactional and hark linking component store organized by assemblies. Popularly speaking, a private package manager for windows itself.
  * `SxS` expands to `Side by Side`, denoting the components with multiple versions can live within your system side by side.
  * Built on the filesystem and registry directly. So compared with databases, its behaves like a turtle.
  * The directory `%WINDIR%\WinSxS`
  * The registry hive `HKEY_LOCAL_MACHINE\COMPONENTS` from `%WINDIR%\System32\config`
  * The registry key `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\SideBySide`
* **Windows Componentization Platform**, a.k.a. `wcp.dll` from servicing stack, is a native implementation of assembly store, or technically "Isolation Interface". Correspondingly, .Net Framework used to have its own isolation implementation. Many DLLs *probably* had a version that implemented isolation, includes `sxs.dll`, `isowin32.dll`, `isoman.dll`, `clr.dll`, `coreclr.dll`, and even `ntdll.dll`.

---

Now let's change our point of view to the upper layers. After the **Updates (Windows Update)** are downloaded into the `SoftwareDistribution`, what information do they take and which contents do they ship?

* **Update (Windows Update)**, also known as `*.msu`. The `.msu` file archives some other `.cab` recursively - some contain metadata (`CompDB` or `OfflineSyncPackage`), some are the payloads, which are in fact called "Package".
* **Package (CBS)**, is a high-level assembly. They can be queried using `Dism /Online /Get-Packages`. The package has many available formats. Some well known technologies like msdelta a delta package format are used on it. But again and again... all of them have two parts: manifest and payload. The manifest of packages ends with `.mum`, describing:
  * which updates (CBS) are included, this is the payload descriptor
  * which packages are its parents, some pack has lang packs as their children
* **Capability (CBS)**, also known as **Feature on Demand**. They canbe queried with `Dism /Online /Get-Capabilities`. Capabilities are generally a bunch of packages. They are not present in your disk at the first time, and can be downloaded from Windows Update Server.
* **Update (CBS)**, is a logical concept that only exists in the manifest of packages. It reference to an assembly, wrappered by
  * a `component` element, which is an ordinary WinSxS assembly component
  * a `package` element, which refer to another package
  * a `driver` element, which is a driver
* **Feature (CBS)**, is actually should be called **Optional Feature**, differing from **Feature on Demand**. Features are the updates of the special package `Microsoft-Windows-Foundation-Package`, and can be queried by `Dism /Online /Get-Features`. These features are staged in WinSxS but not usable directly. If you need it you can enable it *without network connection*.

