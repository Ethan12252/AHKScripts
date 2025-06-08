#Requires AutoHotkey v2.0
#SingleInstance Force

; Default speed
global FastSpeed := 3.0
global ResetSpeed := 1.0

; tray menu
A_TrayMenu.Add()  ; Separator
A_TrayMenu.Add("~Configs~", ShowSettings)

#HotIf WinActive("ahk_class PotPlayer64 ahk_exe PotPlayerMini64.exe")

Right::     ; 模仿Bilibili長按快進功能
{
    if !(KeyWait("Right", "T0.3")) {
        SetSpeed(FastSpeed)
        ToolTip(">>> " . FastSpeed . "x")
        KeyWait("Right")
        Send("z") ; reset to original
        SetSpeed(ResetSpeed)
        ToolTip("")
    }
    else {
        Send("{Right}")
     }
    return
}

#HotIf

SetSpeed(targetSpeed) {
    speedDiff := 0
    cCount := 0
  
    if (targetSpeed != 1.0) {
        speedDiff := targetSpeed - 1.0
        
        if (speedDiff > 0) {
            ; Speed up: each 'c' is up 0.1x
            cCount := Round(speedDiff * 10)
            Loop cCount {
                Send("c")
                Sleep(10)
            }
        } else if (speedDiff < 0) {
            ; Slow down: each 'x' is down 0.1x
            xCount := Round(Abs(speedDiff) * 10)
            Loop xCount {
                Send("x")
                Sleep(10)
            }
        }
    }
    Sleep(50)
}

ShowSettings(*) {
    global FastSpeed, ResetSpeed
    
    SettingsGui := Gui("+AlwaysOnTop", "Configs")
    SettingsGui.MarginX := 30
    SettingsGui.MarginY := 30
    
    SettingsGui.Add("Text", , "FastForward Speed (1.0-5.0): ")
    FastEdit := SettingsGui.Add("Edit", "w100", FastSpeed)
    
    SettingsGui.Add("Text", "xm y+15", "Reset Speed (0.5-2.0): ")
    ResetEdit := SettingsGui.Add("Edit", "w100", ResetSpeed)
    
    SettingsGui.Add("Button", "xm y+20 w80", "確定").OnEvent("Click", SaveSettings)
    SettingsGui.Add("Button", "x+10 w80", "取消").OnEvent("Click", (*) => SettingsGui.Destroy())
    
    SaveSettings(*) {
        newFastSpeed := Float(FastEdit.Text)
        newResetSpeed := Float(ResetEdit.Text)
        
        if (newFastSpeed >= 1.0 && newFastSpeed <= 5.0 && 
            newResetSpeed >= 0.5 && newResetSpeed <= 2.0) {
            FastSpeed := newFastSpeed
            ResetSpeed := newResetSpeed
            ToolTip("設定已保存! FastForward:" . FastSpeed . "x, Reset:" . ResetSpeed . "x")
            SetTimer(() => ToolTip(""), -2000)
            SettingsGui.Destroy()
        } else {
            MsgBox("FastForward: 1.0-5.0`nReset: 0.5-2.0", "Value Error")
        }
    }
    
    SettingsGui.Show()
}