; -------------------------------- hotstrings.ahk -------------------------------- 

::\maile::
::\mailr::[redacted-email]
::\mailms::[redacted-email]; -------------------------------- launch_terminal.ahk -------------------------------- 

; -------------------------------------------- Run Terminal --------------------------------------------
; Run Windows Terminal with Ctrl+Alt+T (opens at current File Explorer path if focused)
^!t:: {
    ; Check if File Explorer is the active window
    if WinActive("ahk_class CabinetWClass") || WinActive("ahk_class ExploreWClass") {
        ; Get the current path from File Explorer
        ; Get path from address bar
        currentPath := GetFileExplorerPath()
        if (currentPath != "") {
            Run 'wt.exe -d "' currentPath '"'
            return
        }
    }
    ; Run normally
    Run "wt.exe"
}

GetFileExplorerPath() {
    ; Get the active File Explorer window
    hwnd := WinGetID("A")
    for window in ComObject("Shell.Application").Windows {
        if (window.hwnd == hwnd) {
            return window.Document.Folder.Self.Path
        }
    }
    return ""
}
; -------------------------------------------- WSL Ubuntu Launcher --------------------------------------------
; Launch WSL Ubuntu with Ctrl+Alt+U
^!u:: {
    ; Check if File Explorer is the active window
    if WinActive("ahk_class CabinetWClass") || WinActive("ahk_class ExploreWClass") {
        ; Get the current path from File Explorer
        currentPath := GetFileExplorerPath()
        if (currentPath != "") {
            ; Convert Windows path to WSL path
            wslPath := ConvertToWSLPath(currentPath)
            Run 'wt.exe wsl -d Ubuntu-20.04 --cd "' wslPath '"'
            return
        }
    }
    ; Run WSL Ubuntu normally
    Run "wt.exe wsl -d Ubuntu-24.04"
}

; Convert Windows path to unix path
ConvertToWSLPath(windowsPath) {
    ; Replace drive letter (C:) with /mnt/c
    if (RegExMatch(windowsPath, "^([A-Za-z]):", &match)) {
        drive := StrLower(match[1])
        wslPath := "/mnt/" drive SubStr(windowsPath, 3)
        ; Replace backslashes with forward slashes
        wslPath := StrReplace(wslPath, "\", "/")
        return wslPath
    }
    return windowsPath
}
; -------------------------------- navigation_mode.ahk -------------------------------- 

SetCapsLockState "AlwaysOff"

global normalMode := true  
global repeatCount := 1    
global waitingForSecondD := false  ; State for d leader key
global repeatBuffer := ""  ; Buffer to build multi-digit repeat counts
global repeatTimer := 0    ; Timer handle for repeat count timeout

SwitchMode(mode := "")
{
	global normalMode, repeatCount, repeatBuffer
	
	; switch mode based on parameter
	if(mode == "normal") {
		normalMode := true  
	} else if (mode == "navigation"){
		normalMode := false 
	} else if (mode == "toggle") {
		normalMode := !normalMode
	} else{
		normalMode := true  
	}

	; Change tray icon to indecate current mode
	if(!normalMode) {
		TraySetIcon("./res/ahk_red.icon")
	} else {
		TraySetIcon("./res/ahk_normal.icon")
	}
	
    ; Show ToolTip to indicate current mode
	ToolTip (normalMode ? "": "Navigation Mode") 

	; Reset repeat count and buffer when switching modes
	if (mode == "normal") {
		repeatCount := 1
		repeatBuffer := ""
		waitingForSecondD := false    ; Reset the 'd' command state
		ClearRepeatTimer()
	}
}

; Clear the repeat timer
ClearRepeatTimer() {
	global repeatTimer
	if (repeatTimer) {
		SetTimer repeatTimer, 0
		repeatTimer := 0
	}
}

; Reset repeat buffer after timeout
ResetRepeatBuffer() {
	global repeatBuffer, repeatCount
	repeatBuffer := ""
	repeatCount := 1

	; Show ToolTip to indicate current mode
	ToolTip (normalMode ? "": "Navigation Mode") 
}

; Process the accumulated repeat buffer
ProcessRepeatBuffer() {
	global repeatBuffer, repeatCount
	if (repeatBuffer != "") {
		; Convert buffer to number, with bounds checking
		num := Integer(repeatBuffer)
		if (num > 0 && num <= 9999) {  ; Reasonable upper limit
			repeatCount := num
		} else {
			repeatCount := 1
		}
		repeatBuffer := ""
	}
	ClearRepeatTimer()
}

; Remap Ctrl + Shift + CapsLock to toggle CapsLock
^+CapsLock:: {
    if GetKeyState("CapsLock", "T")
        SetCapsLockState "Off"
    else
        SetCapsLockState "On"
}

CapsLock:: {
	SwitchMode("navigation")      ; Enter navigation mode immediately
    KeyWait("CapsLock")          ; Wait until CapsLock is released
    SwitchMode("normal")         ; Return to normal mode when released
    return
}

; Reset d state on timeout
ResetDState() {
    global waitingForSecondD, normalMode
    if (waitingForSecondD) {
        waitingForSecondD := false
        ToolTip "d timeout"
        SetTimer () => ToolTip(normalMode ? "": "Navigation Mode") , -1000	
    }
}

; Repeat key sequence based on repeatCount
RepeatKey(key) {
    global repeatCount, normalMode
    ; Process any pending repeat buffer first
    ProcessRepeatBuffer()
    
    ; Show execution tooltip if repeat count > 1
    if (repeatCount > 1) {
        ToolTip "Executing " repeatCount
        ; SetTimer () => ToolTip(), -800  ; Clear after 0.8 seconds
        ; Show ToolTip to indicate current mode
		ToolTip (normalMode ? "": "Navigation Mode") 
    }
    
    buf := ""
    Loop repeatCount {
        buf .= key
    }
    Send buf
    repeatCount := 1
}

; Navigation mappings in navigation mode
#HotIf !normalMode
	Esc::{
		SwitchMode("normal")
		Send("{Esc}")
		return
	}

	; Delete functions
	d::{
		global waitingForSecondD
		ProcessRepeatBuffer()  ; Process any pending repeat count
		
		if (waitingForSecondD) {  ; Had pressed d
			waitingForSecondD := false
			RepeatKey("{Home}+{End}{Delete}")  ; dd: Delete entire line
			ToolTip "dd"
			SetTimer () => ToolTip(normalMode ? "": "Navigation Mode") , -1000	
		} else {
			; First d pressed - wait for second key
			waitingForSecondD := true
			ToolTip "d"
			SetTimer ResetDState, -800 ; 0.8 second timeout
		}
		return
	}

	u::{
		global waitingForSecondD
		ProcessRepeatBuffer()
		
		if (waitingForSecondD) {
			waitingForSecondD := false
			RepeatKey("^{Backspace}")  ; du: Delete word before
			ToolTip "du"
			SetTimer () => ToolTip(normalMode ? "": "Navigation Mode") , -1000	
		} else {
			RepeatKey("^{Left}")  ; Normal u 
		}
		return
	}

	o::{
		global waitingForSecondD
		ProcessRepeatBuffer()
		
		if (waitingForSecondD) {
			waitingForSecondD := false
			RepeatKey("^{Delete}")  ; do: Delete word after
			ToolTip "do"
			SetTimer () => ToolTip(normalMode ? "": "Navigation Mode") , -1000	
		} else {
			RepeatKey("^{Right}")  ; Normal o
		}
		return
	}

	i::{
		global waitingForSecondD
		ProcessRepeatBuffer()
		
		if (waitingForSecondD) {
			waitingForSecondD := false
			RepeatKey("+{Up}{Delete}")  ; di: Delete to previous line
			ToolTip "di"
			SetTimer () => ToolTip(normalMode ? "": "Navigation Mode") , -1000	
		} else {
			RepeatKey("{Up}")  ; Normal i 
		}
		return
	}

	k::{
		global waitingForSecondD
		ProcessRepeatBuffer()
		
		if (waitingForSecondD) {
			waitingForSecondD := false
			RepeatKey("+{Down}{Delete}")  ; dk: Delete to next line
			ToolTip "dk"
			SetTimer () => ToolTip(normalMode ? "": "Navigation Mode") , -1000	
		} else {
			RepeatKey("{Down}")  ; Normal k 
		}
		return
	}

	j::{
		global waitingForSecondD
		ProcessRepeatBuffer()
		
		if (waitingForSecondD) {
			waitingForSecondD := false
			RepeatKey("+{Left}{Delete}")  ; dj: Delete character before
			ToolTip "dj"
			SetTimer () => ToolTip(normalMode ? "": "Navigation Mode") , -1000	
		} else {
			RepeatKey("{Left}")  ; Normal j 
		}
		return
	}

	l::{
		global waitingForSecondD
		ProcessRepeatBuffer()
		
		if (waitingForSecondD) {
			waitingForSecondD := false
			RepeatKey("{Delete}")  ; dl: Delete character after
			ToolTip "dl"
			SetTimer () => ToolTip(normalMode ? "": "Navigation Mode") , -1000	
		} else {
			RepeatKey("{Right}")  ; Normal l
		}
		return
	}

	h::{
		global waitingForSecondD
		ProcessRepeatBuffer()
		
		if (waitingForSecondD) {
			waitingForSecondD := false
			RepeatKey("+{Home}{Delete}")  ; dh: Delete to start of line
			ToolTip "dh"
			SetTimer () => ToolTip(normalMode ? "": "Navigation Mode") , -1000	
		} else {
			RepeatKey("{Home}")  ; Normal h 
		}
		return
	}

	`;::{
		global waitingForSecondD
		ProcessRepeatBuffer()
		
		if (waitingForSecondD) {
			waitingForSecondD := false
			RepeatKey("+{End}{Delete}")  ; d;: Delete to end of line
			ToolTip "d;"
			SetTimer () => ToolTip(normalMode ? "": "Navigation Mode") , -1000	
		} else {
			RepeatKey("{End}")  
		}
		return
	}

	y::{
		global waitingForSecondD
		ProcessRepeatBuffer()
		
		if (waitingForSecondD) {
			waitingForSecondD := false
			ToolTip "dy - not implemented"
			SetTimer () => ToolTip(normalMode ? "": "Navigation Mode") , -1000	
		} else {
			RepeatKey("{PgUp}")  ; Normal y 
		}
		return
	}

	n::{
		global waitingForSecondD
		ProcessRepeatBuffer()
		
		if (waitingForSecondD) {
			waitingForSecondD := false
			ToolTip "dn - not implemented"
			SetTimer () => ToolTip(normalMode ? "": "Navigation Mode") , -1000	
		} else {
			RepeatKey("{PgDn}")  ; Normal n 
		}
		return
	}

	r::RepeatKey("^z")  ; r: Undo (Ctrl+Z)
	+r::RepeatKey("^y")  ; Shift+r: Redo (Ctrl+Y)
	x::RepeatKey("^x")  ; x: Cut (Ctrl+X)
	c::RepeatKey("^c")  ; c: Copy (Ctrl+C)
	v::RepeatKey("^v")  ; v: Paste (Ctrl+V)
    
    ; With Ctrl modifier
    ^i::RepeatKey("^{Up}")
    ^k::RepeatKey("^{Down}")
    ^j::RepeatKey("^{Left}")
    ^l::RepeatKey("^{Right}")
    
    ^u::RepeatKey("^{Left}")
    ^o::RepeatKey("^{Right}")
    
    ^h::RepeatKey("^{Home}")
    ^`;::RepeatKey("^{End}")
    
    ^y::RepeatKey("^{PgUp}")
    ^n::RepeatKey("^{PgDn}")
    
    ; With Shift
    +i::RepeatKey("+{Up}")
    +k::RepeatKey("+{Down}")
    +j::RepeatKey("+{Left}")
    +l::RepeatKey("+{Right}")
    
    +u::RepeatKey("+^{Left}")
    +o::RepeatKey("+^{Right}")
    
    +h::RepeatKey("+{Home}")
    +`;::RepeatKey("+{End}")
    
    +y::RepeatKey("+{PgUp}")
    +n::RepeatKey("+{PgDn}")
    
    ; With Alt
    !i::RepeatKey("!{Up}")
    !k::RepeatKey("!{Down}")
    !j::RepeatKey("!{Left}")
    !l::RepeatKey("!{Right}")
    
    !u::RepeatKey("!^{Left}")
    !o::RepeatKey("!^{Right}")
    
    !h::RepeatKey("!{Home}")
    !`;::RepeatKey("!{End}")
    
    !y::RepeatKey("!{PgUp}")
    !n::RepeatKey("!{PgDn}")
    
    ; With Ctrl+Shift
    ^+i::RepeatKey("^+{Up}")
    ^+k::RepeatKey("^+{Down}")
    ^+j::RepeatKey("^+{Left}")
    ^+l::RepeatKey("^+{Right}")
    
    ^+u::RepeatKey("^+{Left}")
    ^+o::RepeatKey("^+{Right}")
    
    
    ^+h::RepeatKey("^+{Home}")
    ^+`;::RepeatKey("^+{End}")
    
    ^+y::RepeatKey("^+{PgUp}")
    ^+n::RepeatKey("^+{PgDn}")
    
    ; With Ctrl+Alt
    ^!i::RepeatKey("^!{Up}")
    ^!k::RepeatKey("^!{Down}")
    ^!j::RepeatKey("^!{Left}")
    ^!l::RepeatKey("^!{Right}")
    
    ^!u::RepeatKey("^!{Left}")
    ^!o::RepeatKey("^!{Right}")
    
    ^!h::RepeatKey("^!{Home}")
    ^!`;::RepeatKey("^!{End}")
    
    ^!y::RepeatKey("^!{PgUp}")
    ^!n::RepeatKey("^!{PgDn}")
    
    ; With Shift+Alt
    +!i::RepeatKey("+!{Up}")
    +!k::RepeatKey("+!{Down}")
    +!j::RepeatKey("+!{Left}")
    +!l::RepeatKey("+!{Right}")
    
    +!u::RepeatKey("+!{Left}")
    +!o::RepeatKey("+!{Right}")
    
    +!h::RepeatKey("+!{Home}")
    +!`;::RepeatKey("+!{End}")
    
    +!y::RepeatKey("+!{PgUp}")
    +!n::RepeatKey("+!{PgDn}")
    
    ; With Ctrl+Shift+Alt
    ^!+i::RepeatKey("^!+{Up}")
    ^!+k::RepeatKey("^!+{Down}")
    ^!+j::RepeatKey("^!+{Left}")
    ^!+l::RepeatKey("^!+{Right}")
    
    ^!+u::RepeatKey("^!+{Left}")
    ^!+o::RepeatKey("^!+{Right}")
    
    ^!+h::RepeatKey("^!+{Home}")
    ^!+`;::RepeatKey("^!+{End}")
    
    ^!+y::RepeatKey("^!+{PgUp}")
    ^!+n::RepeatKey("^!+{PgDn}")
#HotIf

; Init num keys for repeat count
Loop 10 {
    num := A_Index - 1  ; 0-9
    Hotkey "*" num, SetRepeatCount
}

; Set repeat count in navigation mode
SetRepeatCount(ThisHotkey) {
    num := SubStr(ThisHotkey, 2)  ; Extract number from hotkey (e.g."*1" -> "1")
    global normalMode, repeatBuffer, repeatTimer
    
    if (normalMode) {
        ; Normal mode, send the number with any modifier
        modifiers := (GetKeyState("Shift", "P") ? "+" : "") . (GetKeyState("Ctrl", "P") ? "^" : "") . (GetKeyState("Alt", "P") ? "!" : "") . (GetKeyState("LWin", "P") ? "#" : "")
        Send modifiers . num
    } else {
        ; Navigation mode, build multi digit repeat count
        ; Skip leading zeros unless it's the only digit
        if (num == "0" && repeatBuffer == "") {
            return  
        }
        
        ; Add digit to buffer
        repeatBuffer .= num
        
        ; Limit buffer length to prevent excessive numbers
        if (StrLen(repeatBuffer) > 3) {
            repeatBuffer := SubStr(repeatBuffer, 1, 3)
        }
        
        ToolTip "Repeat: " repeatBuffer
        
        ; Clear any existing timer and set a new one
        ClearRepeatTimer()
        repeatTimer := () => ResetRepeatBuffer()
        SetTimer repeatTimer, -2000  ; 2 second timeout
    }
}

; -------------------------------- potplayer_fastforward.ahk -------------------------------- 

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