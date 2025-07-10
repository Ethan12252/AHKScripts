# Simple script to add shortcut
param(
    [string]$TargetPath,
    [string]$DestinationFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
)

# Help message
if (-not $TargetPath) {
    Write-Host "Usage: .\create_shortcut.ps1 <TargetPath> <DestinationFolder>" 
    Write-Host "Example:"
    Write-Host "  .\script.ps1 './main.ahk'" 
    Write-Host "  .\script.ps1 'C:\Apps\MyApp.exe' 'C:\Users\Desktop'"
    exit
}

$AbsolutePath = (Resolve-Path $TargetPath).Path
$ItemName = Split-Path -Leaf $AbsolutePath
$ShortcutPath = Join-Path $DestinationFolder "$ItemName.lnk"

$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $AbsolutePath
$Shortcut.Save()

Write-Host "Shortcut created: $ShortcutPath"