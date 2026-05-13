# Diligex LAPS Reader Package

This folder contains two delivery options for Diligex users:

- `LapsReader.exe` (self-contained binary)
- `Get-MyLaps.ps1` (PowerShell GUI script)

Both options retrieve the Windows LAPS password for the currently signed-in user's local Entra-joined machine.

## Option 1: Binary (Self-Contained)

`LapsReader.exe` is self-contained. No .NET SDK/runtime installation is required.

### Run

```powershell
.\LapsReader.exe
```

### What it does

1. Detects local Entra device ID (`dsregcmd /status`).
2. Prompts user sign-in to Entra.
3. Calls Microsoft Graph for LAPS credentials.
4. Decodes and displays the local admin password.

## Option 2: PowerShell Script

`Get-MyLaps.ps1` provides a GUI-based retrieval flow.

### Prerequisite

Install Microsoft Graph in user scope:

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
```

### Run with execution policy bypass

```powershell
powershell -ExecutionPolicy Bypass -File .\Get-MyLaps.ps1
```

## Elevation Note (When "Run as administrator" is blocked)

Some endpoint policies block standard "Run as administrator" actions.

Use `runas` instead:

```cmd
runas /user:<machinename>\WLapsAdmn cmd
```

When prompted, enter the password for `WLapsAdmn` (provided by your internal IT/security process).

From that elevated command prompt, start either:

```cmd
LapsReader.exe
```

or

```cmd
powershell -ExecutionPolicy Bypass -File .\Get-MyLaps.ps1
```

## Permissions Reminder

The signed-in user must already have Entra permissions to read LAPS credentials for the device scope.
