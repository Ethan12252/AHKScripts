#Requires AutoHotkey v2.0
#SingleInstance Force

; Hold Right = Bilibili-style speed-up; short press = normal seek (Right).
; Speeds: config.ini [PotPlayerFastFoward] FastSpeed / ResetSpeed
; mpv primary path is hold_fastforward.lua; AHK mpv block below is a commented fallback.

global FastSpeed := ""
global ResetSpeed := ""

EnsureSpeeds() {
    global FastSpeed, ResetSpeed
    if (FastSpeed == "" or ResetSpeed == "") {
        FastSpeed := IniRead(".\config.ini", "PotPlayerFastFoward", "FastSpeed", "2.5")
        ResetSpeed := IniRead(".\config.ini", "PotPlayerFastFoward", "ResetSpeed", "1.0")
    }
}

; --- PotPlayer / MPC-BE (active fallback players) ---
; #HotIf WinActive("ahk_class MediaPlayerClassicW ahk_exe mpc-hc64.exe")
#HotIf WinActive("ahk_class PotPlayer64 ahk_exe PotPlayerMini64.exe") or WinActive("ahk_class MPC-BE ahk_exe mpc-be64.exe")

Right:: {
    EnsureSpeeds()
    global FastSpeed, ResetSpeed

    if !(KeyWait("Right", "T0.3")) {
        ; Hold: ramp from ~1.0 using player hotkeys (c = +0.1x, x = -0.1x)
        SetSpeedRelative(FastSpeed - (ResetSpeed - 1))
        ToolTip(">>> " . FastSpeed . "x")
        KeyWait("Right")
        Send("z")  ; player "reset speed" (PotPlayer/MPC binding)
        SetSpeedRelative(ResetSpeed)
        ToolTip()
    } else {
        Send("{Right}")
    }
}

#HotIf

/*
; --- mpv AHK fallback (leave commented; prefer scripts/hold_fastforward.lua) ---
; Requirements if you enable this:
;   1) Disable or remove hold_fastforward.lua keybind (otherwise both fight for RIGHT)
;   2) Optional but recommended: in mpv.conf set
;        input-ipc-server = \\.\pipe\mpvpipe
;      so speed can be set absolutely via IPC. Without IPC, speed uses }/{ +/- 0.1 steps.
;
#HotIf WinActive("ahk_exe mpv.exe")

Right:: {
    EnsureSpeeds()
    global FastSpeed, ResetSpeed

    if !(KeyWait("Right", "T0.3")) {
        MpvSetSpeed(FastSpeed)
        ToolTip(">>> " . FastSpeed . "x")
        KeyWait("Right")
        MpvSetSpeed(ResetSpeed)
        ToolTip()
    } else {
        Send("{Right}")
    }
}

#HotIf

MpvSetSpeed(speed) {
    speed := Number(speed)
    if !IsNumber(speed)
        return

    ; JSON IPC (mpv --input-ipc-server=\\.\pipe\mpvpipe)
    pipeNames := ["\\.\pipe\mpvpipe", "\\.\pipe\mpv"]
    cmd := Format('{{"command":["set_property","speed",{1}]}}`n', speed)
    for pipe in pipeNames {
        try {
            f := FileOpen(pipe, "w")
            if f {
                f.Write(cmd)
                f.Close()
                return
            }
        }
    }

    ; Fallback: step with } / { (+/- 0.1). Assumes bindings from input_uosc.conf.
    ; Only reliable if current speed is near 1.0.
    cur := 1.0
    steps := Round((speed - cur) * 10)
    if (steps > 0) {
        Loop steps
            Send("}")
    } else if (steps < 0) {
        Loop Abs(steps)
            Send("{")
    }
}
*/

; Relative speed for PotPlayer / MPC via c (+0.1) / x (-0.1)
SetSpeedRelative(targetSpeed) {
    targetSpeed := Number(targetSpeed)
    if !IsNumber(targetSpeed)
        return

    if (targetSpeed != 1.0) {
        speedDiff := targetSpeed - 1.0
        if (speedDiff > 0) {
            Loop Round(speedDiff * 10)
                Send("c")
        } else if (speedDiff < 0) {
            Loop Round(Abs(speedDiff) * 10)
                Send("x")
        }
    }
    Sleep(50)
}

; Screenshot and open LocalSend (MPC-BE)
#HotIf WinActive("ahk_class MPC-BE ahk_exe mpc-be64.exe")
; #HotIf WinActive("ahk_class MediaPlayerClassicW ahk_exe mpc-hc64.exe")

^!i::{
    Send("!i")
    Sleep(500)
    Send("{Enter}")

    Run("explorer.exe C:\Users\ethbr\Pictures")
    Run("C:\Users\ethbr\AppData\Local\Programs\LocalSend\localsend_app.exe")
}

!i::{
    Send("!i")
    Sleep(300)
    Send("{Enter}")
}
#HotIf
