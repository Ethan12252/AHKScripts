#Requires AutoHotkey v2.0-a
#SingleInstance Force

mailE := Trim(IniRead("config.ini", "Email", "personal"))
mailR := Trim(IniRead("config.ini", "Email", "work"))
mailMS := Trim(IniRead("config.ini", "Email", "school"))

; Read name with proper UTF-8 handling
FileObj := FileOpen("config.ini", "r", "UTF-8")
content := FileObj.Read()
FileObj.Close()

nameData := ""
loop Parse content, "`n", "`r" {
    if (A_LoopField ~= "^\s*fullname\s*=") {
        nameData := Trim(SubStr(A_LoopField, InStr(A_LoopField, "=") + 1))
        break
    }
}

; Email
Hotstring("::\maile", mailE)
Hotstring("::\mailr", mailR)
Hotstring("::\mailms", mailMS)

; Name
Hotstring("::\name", nameData)
