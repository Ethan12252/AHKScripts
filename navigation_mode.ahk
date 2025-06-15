#Requires AutoHotkey v2.0-a
#SingleInstance Force

SetCapsLockState "AlwaysOff"

global normalMode := true  
global repeatCount := 1    
global waitingForSecondD := false  ; State for d leader key
global repeatBuffer := ""  ; Buffer to build multi-digit repeat counts
global repeatTimer := 0    ; Timer handle for repeat count timeout

IsEditorProgram() {
    ; Get the active window's process name
    try {
        activeProcess := WinGetProcessName("A")
        
        ; List of programs that support Ctrl+L for delete line
		; Can check the program name using window spy
        ctrlLPrograms := [
            "Code.exe",           ; VS Code
            "devenv.exe",         ; Visual Studio    
        ]
        
        for program in ctrlLPrograms {
            if (activeProcess = program) {
                return true
            }
        }
    }
    return false
}

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
	ToolTip (normalMode ? "": "NAV") 
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
	SwitchMode("navigation")      
    KeyWait("CapsLock")           
    SwitchMode("normal")          
    return
}

; Reset d state on timeout
ResetDState() {
    global waitingForSecondD, normalMode
    if (waitingForSecondD) {
        waitingForSecondD := false
        ToolTip "d timeout"
        SetTimer () => ToolTip(normalMode ? "": "NAV") , -1000	
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
		ToolTip (normalMode ? "": "NAV") 
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
			; dd: Delete entire line
			waitingForSecondD := false
			if (IsEditorProgram()) {
				RepeatKey("^l")
			} else {
				RepeatKey("{Home}+{End}{Delete}")  
			}
			ToolTip "dd"
			SetTimer () => ToolTip(normalMode ? "": "NAV") , -1000	
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
			SetTimer () => ToolTip(normalMode ? "": "NAV") , -1000	
		} else {
			RepeatKey("^{Left}")  
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
			SetTimer () => ToolTip(normalMode ? "": "NAV") , -1000	
		} else {
			RepeatKey("^{Right}")  
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
			SetTimer () => ToolTip(normalMode ? "": "NAV") , -1000	
		} else {
			RepeatKey("{Up}")  
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
			SetTimer () => ToolTip(normalMode ? "": "NAV") , -1000	
		} else {
			RepeatKey("{Down}")
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
			SetTimer () => ToolTip(normalMode ? "": "NAV") , -1000	
		} else {
			RepeatKey("{Left}") 
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
			SetTimer () => ToolTip(normalMode ? "": "NAV") , -1000	
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
			SetTimer () => ToolTip(normalMode ? "": "NAV") , -1000	
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
			SetTimer () => ToolTip(normalMode ? "": "NAV") , -1000	
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
			SetTimer () => ToolTip(normalMode ? "": "NAV") , -1000	
		} else {
			RepeatKey("{PgUp}")  
		}
		return
	}

	n::{
		global waitingForSecondD
		ProcessRepeatBuffer()
		
		if (waitingForSecondD) {
			waitingForSecondD := false
			ToolTip "dn - not implemented"
			SetTimer () => ToolTip(normalMode ? "": "NAV") , -1000	
		} else {
			RepeatKey("{PgDn}") 
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

