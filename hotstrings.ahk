#Requires AutoHotkey v2.0-a
#SingleInstance Force

IniRead mailE, config.ini, Email, personal
IniRead mailR, config.ini, Email, work
IniRead mailMS, config.ini, Email, school
IniRead nameData, config.ini, Name, fullname

; Email
::\maile::%mailE%
::\mailr::%mailR%
::\mailms::%mailMS%

; Name
::\name::%nameData%


