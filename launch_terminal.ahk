#Requires AutoHotkey v2.0-a
#SingleInstance Force

/*
    - Ctrl+Alt+T: Windows Terminal default profile (pwsh 7 if that is WT default)
    - Ctrl+Alt+P: MSYS2 (WT profile from config.ini)
    - Ctrl+Alt+U: WSL (WT profile from config.ini)
    - Ctrl+Alt+Y: VS Code
    - Ctrl+Alt+G: SourceGit
    - Opens at the File Explorer path when Explorer is focused.

    Profiles (config.ini [LaunchTerminal]):
      WslProfileName   e.g. archlinux
      MsysProfileName  e.g. UCRT64 / MSYS2
*/

; Run Windows Terminal with Ctrl+Alt+T (default profile; opens at Explorer path if focused)
^!t:: {
    if WinActive("ahk_class CabinetWClass") || WinActive("ahk_class ExploreWClass") {
        currentPath := GetFileExplorerPath()
        if (currentPath != "") {
            Run 'wt.exe -d "' currentPath '"'
            return
        }
    }
    Run "wt.exe"
}

; Run MSYS2 profile with Ctrl+Alt+P
^!p:: {
    msysProfile := IniRead(".\config.ini", "LaunchTerminal", "MsysProfileName", "UCRT64 / MSYS2")
    if WinActive("ahk_class CabinetWClass") || WinActive("ahk_class ExploreWClass") {
        currentPath := GetFileExplorerPath()
        if (currentPath != "") {
            Run 'wt.exe -p "' msysProfile '" -d "' currentPath '"'
            return
        }
    }
    Run 'wt.exe -p "' msysProfile '"'
}

GetFileExplorerPath() {
    hwnd := WinGetID("A")
    for window in ComObject("Shell.Application").Windows {
        if (window.hwnd == hwnd) {
            return window.Document.Folder.Self.Path
        }
    }
    return ""
}

; Launch WSL (profile name from config.ini)
^!u:: {
    wslConfigName := IniRead(".\config.ini", "LaunchTerminal", "WslProfileName", "archlinux")
    if WinActive("ahk_class CabinetWClass") || WinActive("ahk_class ExploreWClass") {
        currentPath := GetFileExplorerPath()
        if (currentPath != "") {
            wslPath := ConvertToWSLPath(currentPath)
            Run 'wt.exe -p "' wslConfigName '" -d "' wslPath '"'
            return
        }
    }
    Run 'wt.exe -p "' wslConfigName '"'
}

; Convert Windows path to a WSL/Linux path under /mnt/<drive>
ConvertToWSLPath(windowsPath) {
    if (RegExMatch(windowsPath, "^([A-Za-z]):", &match)) {
        drive := StrLower(match[1])
        wslPath := "/mnt/" drive SubStr(windowsPath, 3)
        wslPath := StrReplace(wslPath, "\", "/")
        return wslPath
    }
    return windowsPath
}

; Run VSCodium with Ctrl+Alt+Y (opens at Explorer path if focused)
^!y:: {
    if WinActive("ahk_class CabinetWClass") || WinActive("ahk_class ExploreWClass") {
        currentPath := GetFileExplorerPath()
        if (currentPath != "") {
            Run 'cmd /c start /B codium "' . currentPath . '"', , "Hide"
            return
        }
    }
    Run "cmd /c codium"
}

; Run SourceGit with Ctrl+Alt+G (opens at Explorer path if focused)
^!g:: {
    if WinActive("ahk_class CabinetWClass") || WinActive("ahk_class ExploreWClass") {
        currentPath := GetFileExplorerPath()
        if (currentPath != "") {
            Run 'cmd /c start /B sourcegit "' . currentPath . '"', , "Hide"
            return
        }
    }
    Run "sourcegit"
}
