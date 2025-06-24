#Requires AutoHotkey v2.0
#SingleInstance Force

; tray menu
A_TrayMenu.Add()  ; Separator
A_TrayMenu.Add("~Configs~", ShowSettings)


ShowSettings(*) {
    global FastSpeed, ResetSpeed
    
    SettingsGui := Gui("+AlwaysOnTop", "Configs")
    SettingsGui.MarginX := 15
    SettingsGui.MarginY := 15
    
    SettingsGui.Add("Text", , "FastForward Speed (1.0-5.0): ")
    FastEdit := SettingsGui.Add("Edit", "w100", FastSpeed)
    
    SettingsGui.Add("Text", "xm y+15", "Reset Speed (0.5-2.0): ")
    ResetEdit := SettingsGui.Add("Edit", "w100", ResetSpeed)
    
    SettingsGui.Add("Button", "xm y+20 w80", "確定").OnEvent("Click", SaveSettings_cb)
    SettingsGui.Add("Button", "x+10 w80", "取消").OnEvent("Click", (*) => SettingsGui.Destroy())


    
    SaveSettings_cb(*) {
        newFastSpeed := Float(FastEdit.Text)
        newResetSpeed := Float(ResetEdit.Text)
        
        if (newFastSpeed >= 1.0 && newFastSpeed <= 5.0 && 
            newResetSpeed >= 0.5 && newResetSpeed <= 2.0) {
            FastSpeed := newFastSpeed
            ResetSpeed := newResetSpeed
            ToolTip("暫時設定以保存 FastForward:" . FastSpeed . "x, Reset:" . ResetSpeed . "x")
            SetTimer(() => ToolTip(""), -2000)
            SettingsGui.Destroy()
        } else {
            MsgBox("FastForward: 1.0-5.0`nReset: 0.5-2.0", "Value Error")
        }
    }
    
    SettingsGui.Show()
}