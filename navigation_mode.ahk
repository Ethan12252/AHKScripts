#Requires AutoHotkey v2.0
#SingleInstance Force

; ===== GLOBAL VARIABLES =====
global normalMode := true
global repeatCount := 1
global waitingForSecondD := false
global repeatBuffer := ""
global repeatTimer := 0
global waitingForReplace := false

; ===== CONFIG =====
global CONFIG := {
    REPEAT_TIMEOUT: 2000,
    D_COMMAND_TIMEOUT: 800,
    TOOLTIP_DELAY: 1000,
    MAX_REPEAT_COUNT: 9999, 
    MAX_BUFFER_LENGTH: 3,
    
    EDITOR_PROGRAMS: [
        "Code.exe",
        "devenv.exe", 
        "clion64.exe"
    ],
    
    ICONS: {
        NORMAL: "./res/ahk_normal.ico",
        NAV: "./res/ahk_red.ico"
    }
}

; ===== UTILITY FUNCTIONS =====
IsEditorProgram() {
    try {
        activeProcess := WinGetProcessName("A")
        for program in CONFIG.EDITOR_PROGRAMS {
            if (activeProcess = program) {
                return true
            }
        }
    }
    return false
}

ClearRepeatTimer() {
    global repeatTimer
    if (repeatTimer) {
        SetTimer repeatTimer, 0
        repeatTimer := 0
    }
}

ShowModeTooltip() {
    global normalMode, repeatBuffer
    if (repeatBuffer != "") {
        ToolTip "Repeat: " repeatBuffer
    } else {
        ToolTip (normalMode ? "" : "↔")
    }
}

ShowCommandTooltip(command, delay := 0) {
    if (delay > 0) {
        ToolTip command
        SetTimer () => ShowModeTooltip(), -delay
    } else {
        ToolTip command
    }
}

ResolveIconPath(path) {
    normalized := StrReplace(path, "/", "\\")
    normalized := RegExReplace(normalized, "^\.\\")
    candidates := [
        A_ScriptDir "\\" normalized,
        A_WorkingDir "\\" normalized,
        normalized
    ]

    for candidate in candidates {
        if (FileExist(candidate)) {
            return candidate
        }
    }

    return ""
}

SetModeTrayIcon(normalMode) {
    iconPath := ResolveIconPath(normalMode ? CONFIG.ICONS.NORMAL : CONFIG.ICONS.NAV)

    if (iconPath != "") {
        try {
            TraySetIcon(iconPath)
            return
        }
    }

    ; Fallback icons from shell32.dll avoid hard failure if custom file is invalid.
    TraySetIcon("shell32.dll", normalMode ? 44 : 110)
}

; ===== MODE MANAGEMENT =====
SwitchMode(mode := "") {
    global normalMode, repeatCount, repeatBuffer, waitingForSecondD
    
    ; Determine new mode
    switch mode {
        case "normal":
            normalMode := true
        case "navigation":
            normalMode := false
        case "toggle":
            normalMode := !normalMode
        default:
            normalMode := true
    }
    
    ; Update tray icon
    SetModeTrayIcon(normalMode)
    
    ShowModeTooltip()
    
    ; Reset state when switching to normal mode
    if (mode == "normal") {
        repeatCount := 1
        repeatBuffer := ""
        waitingForSecondD := false
        ClearRepeatTimer()
    }
}

; ===== REPEAT COUNT MANAGEMENT =====
ProcessRepeatBuffer() {
    global repeatBuffer, repeatCount
    if (repeatBuffer != "") {
        num := Integer(repeatBuffer)
        if (num > 0 && num <= CONFIG.MAX_REPEAT_COUNT) {
            repeatCount := num
        } else {
            repeatCount := 1
        }
        repeatBuffer := ""
    }
    ClearRepeatTimer()
}

ResetRepeatBuffer() {
    global repeatBuffer, repeatCount
    repeatBuffer := ""
    repeatCount := 1
    ShowModeTooltip()
}

RepeatKey(key) {
    global repeatCount, normalMode
    ProcessRepeatBuffer()
    
    ; Show execution tooltip for multiple repeats
    if (repeatCount > 1) {
        ShowCommandTooltip("Executing " repeatCount)
        ShowModeTooltip()
    }
    
    ; Build and send key sequence
    keySequence := ""
    Loop repeatCount {
        keySequence .= key
    }
    Send keySequence
    repeatCount := 1
}

; ===== D COMMAND STATE MANAGEMENT =====
ResetDState() {
    global waitingForSecondD
    if (waitingForSecondD) {
        waitingForSecondD := false
        ShowCommandTooltip("d timeout", CONFIG.TOOLTIP_DELAY)
    }
}

HandleDCommand(secondKey, action, actionName) {
    global waitingForSecondD
    ProcessRepeatBuffer()
    
    if (waitingForSecondD) {
        waitingForSecondD := false
        RepeatKey(action)
        ShowCommandTooltip(actionName, CONFIG.TOOLTIP_DELAY)
    } else {
        ; Should be handled as a normal key
        return false
    }
    return true
}

; ===== CAPSLOCK REMAPPING =====
^+CapsLock:: {
    if GetKeyState("CapsLock", "T")
        SetCapsLockState "Off"
    else
        SetCapsLockState "On"
}

CapsLock:: {
    SwitchMode("navigation")
    KeyWait("CapsLock")
    SwitchMode("normal")
    return
}

^CapsLock:: return
+CapsLock:: return

; ===== NAVIGATION HOTKEYS =====
#HotIf !normalMode
    Esc:: {
        SwitchMode("normal")
        Send("{Esc}")
        return
    }
    
    ; === D COMMAND HANDLER ===
    d:: {
        global waitingForSecondD
        ProcessRepeatBuffer()
        
        if (waitingForSecondD) {
            ; dd: Delete entire line
            waitingForSecondD := false
            action := IsEditorProgram() ? "^l" : "{Home}+{End}{Delete}"
            RepeatKey(action)
            ShowCommandTooltip("dd", CONFIG.TOOLTIP_DELAY)
        } else {
            ; First d pressed - wait for second key
            waitingForSecondD := true
            ShowCommandTooltip("d")
            SetTimer ResetDState, -CONFIG.D_COMMAND_TIMEOUT
        }
        return
    }

    ; === NAVIGATION KEYS WITH D COMMANDS ===
    u:: {
        if (!HandleDCommand("u", "^{Backspace}", "du")) {
            RepeatKey("^{Left}")
        }
        return
    }

    o:: {
        if (!HandleDCommand("o", "^{Delete}", "do")) {
            RepeatKey("^{Right}")
        }
        return
    }

    i:: {
        if (!HandleDCommand("i", "+{Up}{Delete}", "di")) {
            RepeatKey("{Up}")
        }
        return
    }

    k:: {
        if (!HandleDCommand("k", "+{Down}{Delete}", "dk")) {
            RepeatKey("{Down}")
        }
        return
    }

    j:: {
        if (!HandleDCommand("j", "+{Left}{Delete}", "dj")) {
            RepeatKey("{Left}")
        }
        return
    }

    l:: {
        if (!HandleDCommand("l", "{Delete}", "dl")) {
            RepeatKey("{Right}")
        }
        return
    }

    h:: {
        if (!HandleDCommand("h", "+{Home}{Delete}", "dh")) {
            RepeatKey("{Home}")
        }
        return
    }

    `;:: {
        if (!HandleDCommand(";", "+{End}{Delete}", "d;")) {
            RepeatKey("{End}")
        }
        return
    }

    y:: {
        if (!HandleDCommand("y", "", "dy - not implemented")) {
            RepeatKey("{PgUp}")
        }
        return
    }

    n:: {
        if (!HandleDCommand("n", "", "dn - not implemented")) {
            RepeatKey("{PgDn}")
        }
        return
    }
    
    ; === NAVIGATION KEYS WITH R COMMAND ===
    
    r:: {
    global waitingForReplace
    
    if (waitingForReplace) {
        return
    }
    
    waitingForReplace := true
    
    ; Select current character
    Send "+{Right}"
    ShowCommandTooltip("r")
    waitingForReplace := false
    return
    }

    ; === BASIC COMMANDS ===
    z::RepeatKey("^z")      ; Undo
    +z::RepeatKey("^y")     ; Redo
    x::RepeatKey("^x")      ; Cut
    c::RepeatKey("^c")      ; Copy
    v::RepeatKey("^v")      ; Paste
    
    ; === CTRL MODIFIERS ===
    ^i::RepeatKey("^{Up}")
    ^k::RepeatKey("^{Down}")
    ^j::RepeatKey("^{Left}")
    ^l::RepeatKey("^{Right}")
    ^u::RepeatKey("^{Left}")
    ^o::RepeatKey("^{Right}")
    ^h::RepeatKey("^{Home}")
    ^`;::RepeatKey("^{End}")
    ^y::RepeatKey("^{PgUp}")
    ^n::RepeatKey("^{PgDn}")
    
    ; === SHIFT MODIFIERS ===
    +i::RepeatKey("+{Up}")
    +k::RepeatKey("+{Down}")
    +j::RepeatKey("+{Left}")
    +l::RepeatKey("+{Right}")
    +u::RepeatKey("+^{Left}")
    +o::RepeatKey("+^{Right}")
    +h::RepeatKey("+{Home}")
    +`;::RepeatKey("+{End}")
    +y::RepeatKey("+{PgUp}")
    +n::RepeatKey("+{PgDn}")
    
    ; === ALT MODIFIERS ===
    !i::RepeatKey("!{Up}")
    !k::RepeatKey("!{Down}")
    !j::RepeatKey("!{Left}")
    !l::RepeatKey("!{Right}")
    !u::RepeatKey("!^{Left}")
    !o::RepeatKey("!^{Right}")
    !h::RepeatKey("!{Home}")
    !`;::RepeatKey("!{End}")
    !y::RepeatKey("!{PgUp}")
    !n::RepeatKey("!{PgDn}")
    
    ; === CTRL+SHIFT MODIFIERS ===
    ^+i::RepeatKey("^+{Up}")
    ^+k::RepeatKey("^+{Down}")
    ^+j::RepeatKey("^+{Left}")
    ^+l::RepeatKey("^+{Right}")
    ^+u::RepeatKey("^+{Left}")
    ^+o::RepeatKey("^+{Right}")
    ^+h::RepeatKey("^+{Home}")
    ^+`;::RepeatKey("^+{End}")
    ^+y::RepeatKey("^+{PgUp}")
    ^+n::RepeatKey("^+{PgDn}")
    
    ; === CTRL+ALT MODIFIERS ===
    ^!i::RepeatKey("^!{Up}")
    ^!k::RepeatKey("^!{Down}")
    ^!j::RepeatKey("^!{Left}")
    ^!l::RepeatKey("^!{Right}")
    ^!u::RepeatKey("^!{Left}")
    ^!o::RepeatKey("^!{Right}")
    ^!h::RepeatKey("^!{Home}")
    ^!`;::RepeatKey("^!{End}")
    ^!y::RepeatKey("^!{PgUp}")
    ^!n::RepeatKey("^!{PgDn}")
    
    ; === SHIFT+ALT MODIFIERS ===
    +!i::RepeatKey("+!{Up}")
    +!k::RepeatKey("+!{Down}")
    +!j::RepeatKey("+!{Left}")
    +!l::RepeatKey("+!{Right}")
    +!u::RepeatKey("+!{Left}")
    +!o::RepeatKey("+!{Right}")
    +!h::RepeatKey("+!{Home}")
    +!`;::RepeatKey("+!{End}")
    +!y::RepeatKey("+!{PgUp}")
    +!n::RepeatKey("+!{PgDn}")
    
    ; === CTRL+SHIFT+ALT MODIFIERS ===
    ^!+i::RepeatKey("^!+{Up}")
    ^!+k::RepeatKey("^!+{Down}")
    ^!+j::RepeatKey("^!+{Left}")
    ^!+l::RepeatKey("^!+{Right}")
    ^!+u::RepeatKey("^!+{Left}")
    ^!+o::RepeatKey("^!+{Right}")
    ^!+h::RepeatKey("^!+{Home}")
    ^!+`;::RepeatKey("^!+{End}")
    ^!+y::RepeatKey("^!+{PgUp}")
    ^!+n::RepeatKey("^!+{PgDn}")
#HotIf

; ===== REPEAT COUNT INPUT =====
SetRepeatCount(ThisHotkey) {
    num := SubStr(ThisHotkey, 2)  ; Extract number from hotkey
    global normalMode, repeatBuffer, repeatTimer
    
    if (normalMode) {
        ; Normal mode - send number with modifiers
        modifiers := ""
        modifiers .= GetKeyState("Shift", "P") ? "+" : ""
        modifiers .= GetKeyState("Ctrl", "P") ? "^" : ""
        modifiers .= GetKeyState("Alt", "P") ? "!" : ""
        modifiers .= GetKeyState("LWin", "P") ? "#" : ""
        Send modifiers . num
    } else {
        ; Navigation mode - build repeat count
        ; Skip leading zeros unless it's the only digit
        if (num == "0" && repeatBuffer == "") {
            return
        }
        
        ; Add digit to buffer with length limit
        repeatBuffer .= num
        if (StrLen(repeatBuffer) > CONFIG.MAX_BUFFER_LENGTH) {
            repeatBuffer := SubStr(repeatBuffer, 1, CONFIG.MAX_BUFFER_LENGTH)
        }
        
        ShowModeTooltip()
        
        ; Set timeout timer
        ClearRepeatTimer()
        repeatTimer := () => ResetRepeatBuffer()
        SetTimer repeatTimer, -CONFIG.REPEAT_TIMEOUT
    }
}

; Initialize number key hotkeys
Loop 10 {
    num := A_Index - 1  ; 0-9
    Hotkey "*" num, SetRepeatCount
}