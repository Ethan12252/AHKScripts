#Requires AutoHotkey v2.0
#SingleInstance Force

#HotIf WinActive("ahk_class PotPlayer64 ahk_exe PotPlayerMini64.exe")

Right::     ; 模仿Bilibili長按快進功能：長按0.3秒方向右鍵進行倍速播放，松開時恢覆
{
    if !(KeyWait("Right", "T0.3")) { ; 按下按鍵持續0.3s
        Send("ccccccccccccccc")      ; 加速x3播放，每個c表示+0.1x，可以自行修改c的數量
        ToolTip(">>>")   ; 腳本執行的提示符
        KeyWait("Right") ; 松開按鍵
        Send("z")        ; 播放速度復原
        ToolTip("")
    }
    else {
        Send("{Right}")  ; 如果按鍵按下未持續0.3s，則觸發Potplayer原始快捷鍵
     }
    return
}
#HotIf