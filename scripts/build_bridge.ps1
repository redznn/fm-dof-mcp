# Builds the FMBridge BepInEx plugin (Release).
#
# Requires the .NET SDK and a Football Manager 26 install with BepInEx 6
# (IL2CPP) already installed, since the build references BepInEx's own
# core + interop assemblies.
#
#   $env:FM26_DIR = "D:\path\to\Football Manager 26"
#   .\scripts\build_bridge.ps1

$ErrorActionPreference = "Stop"
$Here = Split-Path -Parent $PSScriptRoot
$Game = if ($env:FM26_DIR) { $env:FM26_DIR } else { "C:\Program Files (x86)\Steam\steamapps\common\Football Manager 26" }
$Core = Join-Path $Game "BepInEx\core"
$Interop = if ($env:FM26_INTEROP_DIR) { $env:FM26_INTEROP_DIR } else { Join-Path $Game "BepInEx\interop" }

if (-not (Test-Path $Core)) { throw "ERROR: BepInEx core not found at $Core (set `$env:FM26_DIR if FM26 is installed elsewhere)" }

dotnet build (Join-Path $Here "bridge\FMBridge\FMBridge.csproj") -c Release "-p:CoreDir=$Core" "-p:InteropDir=$Interop"
Write-Output "Built: $Here\bridge\FMBridge\bin\Release\net6.0\FMBridge.dll"
