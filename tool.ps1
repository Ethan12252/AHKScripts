#Requires -Version 5.0

param(
    [string]$Command = ""
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
    $config = @"
[global]
device="msi_laptop"

[Email]
personal=
work=
school=

[Name]
fullname=

[LaunchTerminal]
WslProfileName="Ubuntu 20.04 (WSL)"

[PotPlayerFastFoward]
FastSpeed=3.0
ResetSpeed=1.0
"@
    Set-Content "config.ini" $config -Encoding UTF8
    Write-Host "config.ini template generated as UTF-8."
}

function Add-Startup {
    & ".\create_shortcut.ps1" ".\main.ahk"
    Write-Host "Added a shortcut to the startup folder"
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
Usage: .\tool.ps1 [command]

Commands:
  merge      Merge all .ahk files into main.ahk (default)
  startup    Add main.ahk to startup via shortcut
  genconfig  Generate config.ini template
  compiler   Launch Ahk2exe
  help       Show this help message
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
