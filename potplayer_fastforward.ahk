#Requires AutoHotkey v2.0
#SingleInstance Force

; Default speed
global FastSpeed := 3.0
global ResetSpeed := 1

#HotIf WinActive("ahk_class PotPlayer64 ahk_exe PotPlayerMini64.exe")

Right::     ; 模仿Bilibili長按快進功能
{
    try {
        global FastSpeed := IniRead(".\config.ini", "PotPlayerFastFoward", "FastSpeed")
        global ResetSpeed := IniRead(".\config.ini", "PotPlayerFastFoward", "ResetSpeed")
    }

    if !(KeyWait("Right", "T0.3")) {
        SetSpeed(FastSpeed - (ResetSpeed - 1))
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
                ; Sleep(10)
            }
        } else if (speedDiff < 0) {
            ; Slow down: each 'x' is down 0.1x
            xCount := Round(Abs(speedDiff) * 10)
            Loop xCount {
                Send("x")
                ; Sleep(10)
            }
        }
    }
    Sleep(50)
}
