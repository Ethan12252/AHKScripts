#Requires AutoHotkey v2.0-a
#SingleInstance Force

; Run Windows Terminal with Ctrl+Alt+T (opens at current File Explorer path if focused)
^!t:: {
    ; Check if File Explorer is the active window
    if WinActive("ahk_class CabinetWClass") || WinActive("ahk_class ExploreWClass") {
        ; Get the current path from File Explorer
        ; Get path from address bar
        currentPath := GetFileExplorerPath()
        if (currentPath != "") {
            Run 'wt.exe -d "' currentPath '"'
            return
        }
    }
    ; Run normally
    Run "wt.exe"
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
            return
        }
    }
    ; Run WSL Ubuntu normally
    Run "wt.exe -p `"" . wslConfigName . "`""

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
