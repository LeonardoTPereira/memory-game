param(
    [string]$TestPath = "res://tests/memory_game",
    [switch]$ContinueOnFailure,
    [switch]$IgnoreHeadlessMode
)

$ErrorActionPreference = "Stop"

function Resolve-GodotBinary {
    if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) {
        return $env:GODOT_BIN
    }

    $proc = Get-Process | Where-Object { $_.ProcessName -like "godot*" } | Select-Object -First 1
    if ($proc -and $proc.Path -and (Test-Path $proc.Path)) {
        return $proc.Path
    }

    throw "Godot executable not found. Set GODOT_BIN or start Godot Editor once."
}

$godot = Resolve-GodotBinary

$args = @(
    "--headless",
    "--path", ".",
    "-s", "res://addons/gdUnit4/bin/GdUnitCmdTool.gd",
    "-a", $TestPath
)

if ($ContinueOnFailure) {
    $args += "-c"
}

if ($IgnoreHeadlessMode) {
    $args += "--ignoreHeadlessMode"
}

Write-Host "Using Godot: $godot"
Write-Host "Running: $($args -join ' ')"

& $godot @args
$exitCode = $LASTEXITCODE

Write-Host "GdUnit exit code: $exitCode"
exit $exitCode
