#Requires AutoHotkey v2.0 
#SingleInstance Force

StartX := 0
StartY := 0

; Right mouse button down - record position
RButton::
{
    global StartX, StartY
    MouseGetPos(&StartX, &StartY)
}

; Right mouse button up - check movement and act
RButton Up::
{
    global StartX, StartY
    
    MouseGetPos(&CurrentX, &CurrentY)
    Movement := CurrentX - StartX
    
    if (Movement < -50) {
        ; Dragged left - go foward (send alt+right)
        Send("!{Right}")
    } else if (Movement > 50) {
        ; Dragged right - go back (send alt+left)
        Send("!{Left}")
    } else {
        ; Small movement - normal right click
        Click("Right")
    }
}