#Requires AutoHotkey v2.0-a
#SingleInstance Force

mailE := IniRead("config.ini", "Email", "personal")
mailR := IniRead("config.ini", "Email", "work")
mailMS := IniRead("config.ini", "Email", "school")
nameData := IniRead("config.ini", "Name", "fullname")

; Email
::\maile::%mailE%
::\mailr::%mailR%
::\mailms::%mailMS%

; Name
::\name::%nameData%


