# Readme

### 1. Navigation Modes

| Mode            | Description             | Indicator             | Toggle           |
| --------------- | ----------------------- | --------------------- | ---------------- |
| **Insert Mode** | Normal typing (default) | "Insert Mode" tooltip | Hold CapsLock    |
| **Normal Mode** | Navigation and commands | "Normal Mode" tooltip | Release CapsLock |

### 2. CapsLock Management

| Key Combination       | Function                          |
| --------------------- | --------------------------------- |
| `CapsLock`            | Toggle between Insert/Normal mode |
| `Ctrl+Shift+CapsLock` | Manual CapsLock on/off            |

### 3. Navigation Keys (Normal Mode Only)

| Key | Basic Movement    |
| --- | ----------------- |
| `i` | Up arrow          |
| `k` | Down arrow        |
| `j` | Left arrow        |
| `l` | Right arrow       |
| `u` | Word left         |
| `o` | Word right        |
| `h` | Home (line start) |
| `;` | End (line end)    |
| `y` | Page Up           |
| `n` | Page Down         |

*Note: Ctrl+Shift, Ctrl+Alt, and Ctrl+Shift+Alt combinations are also supported*

### 4. Normal Mode Commands

| Command | Action               | Description                |
| ------- | -------------------- | -------------------------- |
| `dj`    | Delete char before   | Backspace                  |
| `dl`    | Delete char after    | Delete key                 |
| `du`    | Delete word before   | Ctrl+Backspace             |
| `do`    | Delete word after    | Ctrl+Delete                |
| `dd`    | Delete entire line   | Select whole line + Delete |
| `dh`    | Delete to line start | Select to Home + Delete    |
| `d;`    | Delete to line end   | Select to End + Delete     |
| `di`    | Delete to prev line  | Select up + Delete         |
| `dk`    | Delete to next line  | Select down + Delete       |
| `x`     | Cut                  | Ctrl+X                     |
| `c`     | Copy                 | Ctrl+C                     |
| `v`     | Paste                | Ctrl+V                     |

*Press `d` then the second key within 0.6 seconds for delete commands*

### 5. Undo/Redo & Repeat

| Key       | Function         | Notes                        |
| --------- | ---------------- | ---------------------------- |
| `r`       | Undo             | Ctrl+Z                       |
| `Shift+r` | Redo             | Ctrl+Y                       |
| `1-9`     | Set repeat count | Next command repeats N times |

### 6. Quick Reference

| What you want to do       | Key combination |
| ------------------------- | --------------- |
| Move cursor up 3 times    | `3` then `i`    |
| Delete entire line        | `dd`            |
| Select word to the right  | `Shift+o`       |
| Delete word before cursor | `du`            |
| Go to start of document   | `Ctrl+h`        |
| Cut selected text         | `x`             |
| Copy selected text        | `c`             |
| Paste clipboard content   | `v`             |
| Switch to typing mode     | `CapsLock`      |

### 7. Additional Shortcuts

| Shortcut              | Function              | Notes                                              |
| --------------------- | --------------------- | -------------------------------------------------- |
| `Ctrl+Alt+T`          | Open Windows Terminal | Opens in current folder if File Explorer is active |
| `\maile`              | Email shortcut        | Expands to ``                    |
| `\mailr`              | Email shortcut        | Expands to `[redacted-email]`                     |
| `Ctrl+Shift+CapsLock` | Toggle CapsLock       | Manual CapsLock control                            |

### 8. PotPlayer Enhancement

| Action                  | Trigger           | Result                                 |
| ----------------------- | ----------------- | -------------------------------------- |
| Long-press Right Arrow  | Hold >0.3 seconds | 3x speed playback with ">>>" indicator |
| Short-press Right Arrow | Quick press       | Normal seek forward                    |
| Release key             | After long-press  | Return to normal speed                 |

## Tips

- In Windows, to run on startup, create a link to %APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup (for current user startup list)
- When the tray icon is red we are in the normal mode, green insert mode.
