; Text conversion script: Toggle between Simplified and Traditional Chinese
; Ctrl+Alt+F: Copy selected text, convert, and paste back

MODE_SIMPLIFIED := 0x02000000
MODE_TRADITIONAL := 0x04000000
LOCALE_DEFAULT := 0x400

global ToggleMode := MODE_SIMPLIFIED

^!f:: {
    global ToggleMode
    ClipSaved := ClipboardAll()
    A_Clipboard := "" 
    Send "^c"
    
    if !ClipWait(0.5) {
        A_Clipboard := ClipSaved
        return
    }
    
    SourceText := A_Clipboard
    ConvertedText := WinConvert(SourceText, ToggleMode)
    A_Clipboard := ConvertedText
    Send "^v"
    Sleep 150
    A_Clipboard := ClipSaved
    
    ToggleMode := (ToggleMode = MODE_SIMPLIFIED) ? MODE_TRADITIONAL : MODE_SIMPLIFIED
}

WinConvert(str, mode) {
    if (str = "")
        return ""
    
    size := StrLen(str)
    VarSetStrCapacity(&out, size)
    DllCall("kernel32.dll\LCMapStringW", "UInt", 0x400, "UInt", mode, "Str", str, "Int", size, "Str", out, "Int", size)
    return out
}  