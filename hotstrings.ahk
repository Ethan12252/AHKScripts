#Requires AutoHotkey v2.0-a
#SingleInstance Force

; Hotstring expansions live in config.ini so a compiled exe works across
; machines without recompiling — just edit the ini next to the exe and reload:
;
;   [Hotstrings]
;   \maile=your@email1.here
;
; The key is the trigger body ("::" is prepended automatically), the value is
; the expansion text. A missing section and blank values are skipped.

configPath := A_ScriptDir "\config.ini"

RegisterHotstringsFromIni(configPath, "Hotstrings")

; Reads every key=value pair in an ini section and registers one hotstring
; per entry. Never throws: a missing file, a missing section, or a bad line
; is simply skipped.
RegisterHotstringsFromIni(configPath, section) {
    try {
        raw := IniRead(configPath, section)
    } catch {
        return
    }

    loop Parse raw, "`n", "`r" {
        line := Trim(A_LoopField)
        if (line == "" || SubStr(line, 1, 1) == ";" || !InStr(line, "="))
            continue
        trigger := Trim(SubStr(line, 1, InStr(line, "=") - 1))
        expansion := Trim(SubStr(line, InStr(line, "=") + 1))
        if (trigger == "" || expansion == "")
            continue
        try {
            Hotstring("::" trigger, expansion)
        }
    }
}
