# Copies the built FMBridge.dll into FM26's BepInEx plugins directory.
# Run scripts/build_bridge.ps1 first. Restart (or launch) the game afterwards
# for the plugin to load.
#
#   $env:FM26_DIR = "D:\path\to\Football Manager 26"
#   .\scripts\deploy_bridge.ps1

$ErrorActionPreference = "Stop"
$Here = Split-Path -Parent $PSScriptRoot
$Game = if ($env:FM26_DIR) { $env:FM26_DIR } else { "C:\Program Files (x86)\Steam\steamapps\common\Football Manager 26" }
$Dll = Join-Path $Here "bridge\FMBridge\bin\Release\net6.0\FMBridge.dll"

if (-not (Test-Path $Dll)) { throw "ERROR: $Dll not found - run scripts/build_bridge.ps1 first" }
if (-not (Test-Path (Join-Path $Game "BepInEx"))) { throw "ERROR: BepInEx not found under $Game (set `$env:FM26_DIR if FM26 is installed elsewhere)" }

$Dest = Join-Path $Game "BepInEx\plugins\FMBridge"
New-Item -ItemType Directory -Force -Path $Dest | Out-Null
Copy-Item $Dll (Join-Path $Dest "FMBridge.dll") -Force
Write-Output "deployed: $Dest\FMBridge.dll"

# Record where node, the chat service, and a usable PATH live so the bridge
# can start the chat service itself when the game launches (the game's own
# environment has none of them). Without node this just warns:
# the plugin skips autostart and the service can be run by hand.
$NodeBin = (Get-Command node -ErrorAction SilentlyContinue).Source
if ($NodeBin) {
    $lines = @(
        "NODE=$NodeBin",
        "SCRIPT=$Here\scripts\dof_chat_service.mjs",
        "PATH=$env:PATH"
    )
    # Optional provider/model overrides for the DoF's replies. The game-spawned
    # service can't see your shell env, so they ride along here.
    if ($env:DOF_CHAT_PROVIDER) { $lines += "PROVIDER=$env:DOF_CHAT_PROVIDER" }
    if ($env:DOF_CHAT_MODEL) { $lines += "MODEL=$env:DOF_CHAT_MODEL" }
    $lines | Set-Content -Path (Join-Path $Dest "chat_service.env") -Encoding Ascii
    Write-Output "chat service autostart configured (chat_service.env)"
} else {
    Write-Warning "node not found on PATH - chat service autostart disabled"
}

Write-Output "Restart Football Manager 26 for the plugin to take effect."
