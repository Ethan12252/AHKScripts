#Requires AutoHotkey v2.0-a
#SingleInstance Force

/*
    - Ctrl+Alt+T: Open msys2 
    - Ctrl+Alt+P: Open PowerShell  
    - Ctrl+Alt+U: Open WSL profile 
    - Ctrl+Alt+Y: Open VS Code
    - Will open at the File Explorer if focused.
    
    - WSL profile name is read from config.ini
*/

; Run Windows Terminal with Ctrl+Alt+T (opens at current File Explorer path if focused)
^!t:: {
    ; Check if File Explorer is the active window
    if WinActive("ahk_class CabinetWClass") || WinActive("ahk_class ExploreWClass") {
        ; Get the current path from File Explorer
        ; Get path from address bar
        currentPath := GetFileExplorerPath()
        if (currentPath != "") {
            Run 'wt.exe -d "' currentPath '"'
            PositionTerminalWindow()
            return
        }
    }
    ; Run normally
    Run "wt.exe"
    PositionTerminalWindow()
}

; Run Windows Terminal powershell with Ctrl+Alt+P (opens at current File Explorer path if focused)
^!p:: {
    ; Check if File Explorer is the active window
    if WinActive("ahk_class CabinetWClass") || WinActive("ahk_class ExploreWClass") {
        ; Get the current path from File Explorer
        ; Get path from address bar
        currentPath := GetFileExplorerPath()
        if (currentPath != "") {
            Run "wt.exe -p `"" . "Windows PowerShell" . "`" -d `"" . currentPath . "`""
            PositionTerminalWindow()
            return
        }
    }
    ; Run normally
    Run "wt.exe -p `"" . "Windows PowerShell" . "`""
    PositionTerminalWindow()
}

GetFileExplorerPath() {
    ; Get the active File Explorer window
    hwnd := WinGetID("A")
    for window in ComObject("Shell.Application").Windows {
        if (window.hwnd == hwnd) {
            return window.Document.Folder.Self.Path
        }
    }
    return ""
}

; Launch WSL Ubuntu with Ctrl+Alt+U
^!u:: {
    ; Get the wsl config name from the ini file
    wslConfigName := IniRead(".\config.ini", "LaunchTerminal", "WslProfileName")
    ; Check if File Explorer is the active window
    if WinActive("ahk_class CabinetWClass") || WinActive("ahk_class ExploreWClass") {
        ; Get the current path from File Explorer
        currentPath := GetFileExplorerPath()
        if (currentPath != "") {
            ; Convert Windows path to WSL path
            wslPath := ConvertToWSLPath(currentPath)
            Run "wt.exe -p `"" . wslConfigName . "`" -d `"" . wslPath . "`""
            PositionTerminalWindow()
            return
        }
    }
    ; Run WSL Ubuntu normally
    Run "wt.exe -p `"" . wslConfigName . "`""
    PositionTerminalWindow()
}

; Convert Windows path to unix path
ConvertToWSLPath(windowsPath) {
    ; Replace drive letter (C:) with /mnt/c
    if (RegExMatch(windowsPath, "^([A-Za-z]):", &match)) {
        drive := StrLower(match[1])
        wslPath := "/mnt/" drive SubStr(windowsPath, 3)

        wslPath := StrReplace(wslPath, "\", "/")
        return wslPath
    }
    return windowsPath
}

; Run vscode with Ctrl+Alt+Y (opens at current File Explorer path if focused)
^!y:: {
    ; Check if File Explorer is the active window
    if WinActive("ahk_class CabinetWClass") || WinActive("ahk_class ExploreWClass") {
        ; Get the current path from File Explorer
        ; Get path from address bar
        currentPath := GetFileExplorerPath()
        if (currentPath != "") {
            ; Run "cmd /c code `"" . currentPath . "`""
            Run 'cmd /c start /B code "' . currentPath . '"', , "Hide"
            return
        }
    }
    ; Run normally
    Run "cmd /c code"
}

PositionTerminalWindow() {
    WinWait("ahk_exe WindowsTerminal.exe", , 3)
    ; For my laptop 1920x1200 screen: x=300, y=100, width=1320, height=900 (slightly bigger)
    WinMove(300, 100, 1320, 900, "ahk_exe WindowsTerminal.exe")
    ; MsgBox "Repos fin", "dbg", 'OK'
}
