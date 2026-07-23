#Requires AutoHotkey v2.0
#SingleInstance Force

; tray menu
A_TrayMenu.Add()  ; Separator
A_TrayMenu.Add("~Configs~", ShowSettings)


ShowSettings(*) {
    global FastSpeed, ResetSpeed

    ; Prefer live globals; fall back to config.ini
    if (FastSpeed = "")
        FastSpeed := IniRead(".\config.ini", "PotPlayerFastFoward", "FastSpeed", "2.5")
    if (ResetSpeed = "")
        ResetSpeed := IniRead(".\config.ini", "PotPlayerFastFoward", "ResetSpeed", "1.0")

    SettingsGui := Gui("+AlwaysOnTop", "Configs")
    SettingsGui.MarginX := 15
    SettingsGui.MarginY := 15

    SettingsGui.Add("Text", , "FastForward Speed (1.0-5.0): ")
    FastEdit := SettingsGui.Add("Edit", "w100", FastSpeed)

    SettingsGui.Add("Text", "xm y+15", "Reset Speed (0.5-2.0): ")
    ResetEdit := SettingsGui.Add("Edit", "w100", ResetSpeed)

    SettingsGui.Add("Text", "xm y+20 Section", "Shortcuts (reminder):")
    info := "
    (
Ctrl+Alt+T  Windows Terminal (default profile, e.g. pwsh 7)
Ctrl+Alt+P  MSYS2 UCRT64 (WT profile)
Ctrl+Alt+U  WSL (profile from config.ini)
Ctrl+Alt+Y  VS Code
Ctrl+Alt+G  SourceGit
Ctrl+Alt+F  SC/TC Chinese toggle (selection)

CapsLock/F13 hold  Navigation mode (ijkl, etc.)
Player Right hold  Speed-up (PotPlayer / MPC-BE)
    )"
    SettingsGui.Add("Edit", "xm y+6 w320 r11 ReadOnly -WantReturn", info)

    SettingsGui.Add("Button", "xm y+15 w80 Default", "OK").OnEvent("Click", SaveSettings_cb)
    SettingsGui.Add("Button", "x+10 w80", "Cancel").OnEvent("Click", (*) => SettingsGui.Destroy())
    SettingsGui.Add("Button", "x+10 w80", "Help").OnEvent("Click", OpenReadme)

    SaveSettings_cb(*) {
        newFastSpeed := Float(FastEdit.Text)
        newResetSpeed := Float(ResetEdit.Text)

        if (newFastSpeed >= 1.0 && newFastSpeed <= 5.0 &&
            newResetSpeed >= 0.5 && newResetSpeed <= 2.0) {
            FastSpeed := newFastSpeed
            ResetSpeed := newResetSpeed
            ToolTip("Temp FastForward: " . FastSpeed . "x, Reset: " . ResetSpeed . "x")
            SetTimer(() => ToolTip(), -2000)
            SettingsGui.Destroy()
        } else {
            MsgBox("FastForward: 1.0-5.0`nReset: 0.5-2.0", "Value Error")
        }
    }

    SettingsGui.Show()
}

; Same folder as main.ahk / config.ini (A_ScriptDir). out\ is release output only - not used here.
ResolveReadmePath() {
    for name in ["readme.md", "README.md"] {
        path := A_ScriptDir "\" name
        if FileExist(path)
            return path
    }
    return ""
}

OpenReadme(*) {
    path := ResolveReadmePath()
    if (path = "") {
        MsgBox(
            "readme.md not found next to the script.`n`nExpected:`n" A_ScriptDir "\readme.md",
            "Help",
            "Icon!"
        )
        return
    }
    try {
        Run path  ; default .md association
    } catch as err {
        try Run 'notepad.exe "' path '"'
        catch
            MsgBox("Could not open:`n" path "`n`n" err.Message, "Help", "Icon!")
    }
}
