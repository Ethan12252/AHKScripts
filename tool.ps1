#Requires -Version 5.0

param(
    [string]$Command = "",
    [string]$Arg = ""
)

function Merge-AhkFiles {
    $output = "main.ahk"
    $backup = "$output.old"
    
    # Backup existing main.ahk by moving it
    if (Test-Path $output) {
        Move-Item $output $backup -Force -ErrorAction SilentlyContinue
    }
    
    # Create new main.ahk with header
    $header = @"
#Requires AutoHotkey v2.0 
#SingleInstance Force
"@
    Set-Content $output $header
    
    # Include all .ahk files except main.ahk
    Get-ChildItem -Filter "*.ahk" | 
        Where-Object { $_.Name -ne $output -and $_.Name -ne "${output}.old" } |
        ForEach-Object {
            Write-Host "Appending: $($_.Name)"
            Add-Content $output "#Include $($_.Name)"
        }
    
    # Ask to delete backup
    $confirm = Read-Host "Delete the backup for original $backup (Y/n)"
    if ($confirm -match "^[yY]$") {
        Remove-Item $backup -ErrorAction SilentlyContinue
        Write-Host "Backup deleted."
    }
    
    exit 0
}

function Generate-Config {
    Generate-ExampleConfig -OutPath "config.ini"
    Write-Host "config.ini template generated as UTF-8."
}

function Add-Startup {
    & ".\create_shortcut.ps1" ".\main.ahk"
    Write-Host "Added a shortcut to the startup folder"
}

function Generate-ExampleConfig {
    param([string]$OutPath = "config.ini")
    $config = @"
[global]
device="your_device_name"

[Hotstrings]
; Format: \trigger=expansion text
; These are registered as AutoHotkey hotstrings.
\maile=your@email1.here
\mailr=your@email2.here
\mailms=your@email3.here
\name=Your Name Here
\stn=Your Student ID Here

[LaunchTerminal]
WslProfileName="Ubuntu 20.04 (WSL)"
MsysProfileName="UCRT64 / MSYS2"

[PotPlayerFastFoward]
; Used by video_fastfoward.ahk (PotPlayer / MPC-BE).
FastSpeed=3.0
ResetSpeed=1.0
"@
    Set-Content $OutPath $config -Encoding UTF8
}

function Build-Release {
    param([string]$Version = "")

    $ahk2exe = "$env:LOCALAPPDATA\Programs\AutoHotkey\Compiler\Ahk2Exe.exe"
    if (-not (Test-Path $ahk2exe)) {
        Write-Host "Error: Ahk2Exe.exe not found at $ahk2exe" -ForegroundColor Red
        exit 1
    }

    # Determine version
    if ([string]::IsNullOrEmpty($Version)) {
        $Version = (git describe --tags --abbrev=0 2>$null)
        if ([string]::IsNullOrEmpty($Version)) {
            Write-Host "Error: No version specified and no git tags found." -ForegroundColor Red
            Write-Host "Usage: .\tool.ps1 release [version]  (e.g. .\tool.ps1 release v0.5.0)"
            exit 1
        }
        Write-Host "Using latest git tag: $Version"
    }
    # Ensure version starts with 'v'
    if (-not $Version.StartsWith("v")) { $Version = "v$Version" }

    $outDir = ".\out"
    $resDir = "$outDir\res"
    $exePath = "$outDir\main.exe"
    $configPath = "$outDir\config.ini"
    $readmePath = "$outDir\readme.md"
    $iconSrc = ".\res\ahk_nav_red.ico"
    $zipName = "AHKScripts-$Version-win-x64.zip"
    $zipPath = "$outDir\$zipName"

    # Clean output directory
    if (Test-Path $outDir) {
        Remove-Item "$outDir\*" -Recurse -Force
    } else {
        New-Item $outDir -ItemType Directory | Out-Null
    }
    New-Item $resDir -ItemType Directory -Force | Out-Null

    # 1. Compile main.ahk → main.exe (uses default AHK icon)
    Write-Host "Compiling main.ahk -> main.exe..."
    $proc = Start-Process -FilePath $ahk2exe -ArgumentList "/in", ".\main.ahk", "/out", $exePath -Wait -PassThru -NoNewWindow -RedirectStandardOutput "$env:TEMP\ahk2exe_out.txt" -RedirectStandardError "$env:TEMP\ahk2exe_err.txt"
    $compilerOutput = Get-Content "$env:TEMP\ahk2exe_out.txt" -ErrorAction SilentlyContinue
    if ($compilerOutput) { Write-Host "  $compilerOutput" }
    if ($proc.ExitCode -ne 0 -or -not (Test-Path $exePath)) {
        $compilerErr = Get-Content "$env:TEMP\ahk2exe_err.txt" -ErrorAction SilentlyContinue
        if ($compilerErr) { Write-Host "  $compilerErr" -ForegroundColor Red }
        Write-Host "Error: Compilation failed (exit code $($proc.ExitCode))." -ForegroundColor Red
        exit 1
    }
    Write-Host "  Compiled: $exePath ($('{0:N0}' -f (Get-Item $exePath).Length) bytes)"

    # 2. Generate example config.ini
    Generate-ExampleConfig -OutPath $configPath
    Write-Host "  Generated: $configPath"

    # 3. Copy readme.md
    Copy-Item ".\readme.md" $readmePath
    Write-Host "  Copied: $readmePath"

    # 4. Copy icon resource (needed at runtime for tray icon switching)
    Copy-Item $iconSrc "$resDir\"
    Write-Host "  Copied: $resDir\ahk_nav_red.ico"

    # 5. Create zip
    Write-Host "Creating $zipName..."
    $filesToZip = @($exePath, $configPath, $readmePath, $resDir)
    Compress-Archive -Path $filesToZip -DestinationPath $zipPath -Force
    Write-Host "  Created: $zipPath ($('{0:N0}' -f (Get-Item $zipPath).Length) bytes)"

    Write-Host ""
    Write-Host "Release $Version built successfully!" -ForegroundColor Green
    Write-Host "Output: $zipPath"
}

function Launch-Compiler {
    $ahk2exe = "$env:LOCALAPPDATA\Programs\AutoHotkey\Compiler\Ahk2Exe.exe"
    if (Test-Path $ahk2exe) {
        & $ahk2exe
    } else {
        Write-Host "Error: Ahk2Exe.exe not found at $ahk2exe"
    }
}

function Show-Help {
    Write-Host @"
Usage: .\tool.ps1 [command] [args]

Commands:
  merge              Merge all .ahk files into main.ahk (default)
  startup            Add main.ahk to startup via shortcut
  genconfig          Generate config.ini template
  release [version]  Compile to exe + create release zip (e.g. release v0.5.0)
  compiler           Launch Ahk2exe GUI
  help               Show this help message
"@
}

# Execute command
if ([string]::IsNullOrEmpty($Command) -or $Command -eq "-h" -or $Command -eq "--help") {
    Show-Help
    exit 0
}

switch ($Command) {
    "merge" {
        Merge-AhkFiles
    }
    "startup" {
        Add-Startup
    }
    "genconfig" {
        Generate-Config
    }
    "release" {
        Build-Release -Version $Arg
    }
    "compiler" {
        Launch-Compiler
    }
    "help" {
        Show-Help
    }
    default {
        Write-Host "Parameter error"
        exit 1
    }
}
