# AHK Scripts

A collection of AutoHotkey v2.0 scripts I use.

## Scripts Overview

### **main.ahk**
Entry point that loads all other modules.

### **navigation_mode.ahk**
Modal editing mode activated by holding **CapsLock**. Once activated, use letter keys for navigation and editing instead of arrow keys.

**Quick Start:**
- Hold **CapsLock** to enter navigation mode (tray icon changes to red)
- Use ijkl and semicolon (;) for movement
- Type a number before a command to repeat it (e.g., `5j` = move down 5 times)
- Release **CapsLock** to exit back to normal mode

**Movement Layout:**
```
                    ↑  
     ←(word) ┌───┐┌───┐┌───┐ →(word)
             │ u ││ i ││ o │
             └───┘└───┘└───┘
   Home ┌───┐┌───┐┌───┐┌───┐┌───┐ End
        │ h ││ j ││ k ││ l ││ ; │
        └───┘└───┘└───┘└───┘└───┘
               ←    ↓    →
```
- **h** = Line start  
- **;** = Line end
- **y** / **n**: Page up/Page down

**Editing Commands:**

| Command | Action |
|---------|--------|
| **d** + movement key | Delete (e.g., `dj` = delete left, `di` = delete up) |
| **dd** | Delete entire line |
| **r** | Replace character |
| **x** / **c** / **v** | Cut / Copy / Paste |
| **z** / **Shift+z** | Undo / Redo |

### **hotstrings.ahk**
Text expansion shortcuts:
- `\maile`  → your@email1.here
- `\mailr`  → your@email2.here
- `\mailms` → your@email3.here
- `\name` → Your Name Here

### **launch_terminal.ahk**
Quick terminal/editor launcher with path awareness:
- **Ctrl+Alt+T**: Windows Terminal (MSYS2)
- **Ctrl+Alt+P**: Windows PowerShell
- **Ctrl+Alt+U**: WSL profile (configured in config.ini)
- **Ctrl+Alt+Y**: VS Code
- Auto-opens at current File Explorer path when available

### **chinese_text_toggle.ahk**
Text conversion utility:
- **Ctrl+Alt+F**: Copy selected text, convert between Simplified/Traditional Chinese, and paste back
- Toggles between modes with each invocation

### **mouse_gesture.ahk**
Right-click mouse gestures:
- Drag right → Alt+Left (back in browser)
- Drag left → Alt+Right (forward in browser)
- Small movement → Normal right-click

### **video_fastfoward.ahk**
Media player speed control (PotPlayer, MPC-BE, MPC-HC):
- Right arrow (long press): Speed up (Bilibili-style)
- Right arrow (short press): Normal seek
- Speed settings configurable via tray menu GUI or config.ini
- Screen capture and LocalSend integration

### **ConfigMenu.ahk**
Settings GUI for video fastforward speeds:
- Configure FastForward speed (1.0-5.0x)
- Configure Reset speed (0.5-2.0x)
- Accessible from tray menu

## Requirements
- AutoHotkey v2.0 or newer [Download Here](https://www.autohotkey.com/)

## Build & Setup

Use the build tools to automate common tasks:

**PowerShell:**
```powershell
.\tool.ps1 merge        # Merge all .ahk files into main.ahk
.\tool.ps1 startup      # Add main.ahk to Windows startup
.\tool.ps1 genconfig    # Generate config.ini template
.\tool.ps1 compiler     # Launch Ahk2exe compiler
```

**Bash:**
```bash
./tool.sh merge        # Merge all .ahk files into main.ahk
./tool.sh startup      # Add main.ahk to Windows startup
./tool.sh genconfig    # Generate config.ini template
./tool.sh compiler     # Launch Ahk2exe compiler
```

## Configuration
Settings are read from `config.ini`:
- WSL profile name for `launch_terminal.ahk`
- Video playback speeds for `video_fastfoward.ahk`

## Assets
- `res/ahk_normal.icon` - Normal mode tray icon
- `res/ahk_red.icon` - Navigation mode tray icon
