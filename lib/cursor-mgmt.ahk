#Requires AutoHotkey v2.0
; #SingleInstance Force
; Persistent

; ╭════════════════════════════════════════════════════════════════════════════════════════════════════════════════─╮
; ║  CURSOR-MGMT.AHK                                                                                                 ║
; ║    - Manages the location and dimensions of the Active Window using performant DllCalls.                        ║
; ║    - Refactored for maximum readability, maintainability, and performance.                                      ║
; ╰═════════════════════════════════════════════════════════════════════════════════════════════════════════════════╯

SPI_SETCURSORS := 0x2029
SPIF_UPDATEINIFILE := 0x01
SPIF_SENDCHANGE := 0x01
CURSOR_MIN := 32
CURSOR_MAX := 256
CURSOR_STEP := 16
sizeKey := "HKEY_CURRENT_USER\Control Panel\Cursors"
valueName := "CursorBaseSize"
global origCursorSize := RegRead(sizeKey, valueName, 32)

; ╭────────────────────────────────────────────────────────────────────────────────────────────╮
; │ SetCursorSize(newSize)                                                                     │
; │   newSize: Integer. Value of 1 for 16 px until it reachess 255 px.                         │
; ╰────────────────────────────────────────────────────────────────────────────────────────────╯
SetCursorSize(newSize) {
  ; Get Current cursor size
  currSize := RegRead(sizeKey, valueName, CURSOR_MIN)
  newSize := currSize + (newSize * CURSOR_STEP)

  ; Clamp value between CURSOR_MIN and CURSOR_MAX
  newSize := Max(CURSOR_MIN, Min(CURSOR_MAX, newSize))
  
  ; RegWrite(newSize, "REG_DWORD", sizeKey, valueName) ; Uncomment if you want to persist the value
  DllCall("SystemParametersInfo", "UInt", SPI_SETCURSORS, "UInt", 0, "Ptr", newSize, "UInt", SPIF_UPDATEINIFILE | SPIF_SENDCHANGE)
  ToolTip "Cursor Size: " Round((newSize - CURSOR_STEP) / 16)
  SetTimer () => ToolTip(, , , 1), -1000
}

; ╭────────────────────────────────────────────────────────────────────────────────────────────╮
; │ Hotkeys for increasing and decreasing the mouse cursor size.                               │
; │ {}                                                                                         │
; ╰────────────────────────────────────────────────────────────────────────────────────────────╯
#PgUp:: {
  ; [Win]+[PgUp] to increase mouse cursor size
  SetCursorSize(+1)
}

#PgDn:: {
  ; [Win]+[PgDn] to decrease mouse cursor size
  SetCursorSize(-1)
}

OnExit ExitFunc

ExitFunc(ExitReason, ExitCode)
{
  ; Reset the mouse cursor to size 48
  DllCall("SystemParametersInfo", "UInt", SPI_SETCURSORS, "UInt", 0, "Ptr", origCursorSize, "UInt", SPIF_UPDATEINIFILE | SPIF_SENDCHANGE) ; Update the cursor to apply changes , "Ptr", 0, "UInt", SPIF_UPDATEINIFILE | SPIF_SENDCHANGE) ; Update the cursor to apply changes

  Switch ExitReason, false
  {
    Case "Logoff":
      Result := MsgBox("Are you sure you want to exit?", , 4)
      if Result = "No" {
        return 1  ; Callbacks must return non-zero to avoid exit.
      }
    Case "Shutdown":
      Result := MsgBox("Are you sure you want to exit?", , 4)
      if Result = "No" {
        return 1  ; Callbacks must return non-zero to avoid exit.
      }
    Case "Close":
    Case "Error":
    Case "Menu":
    Case "Exit":
      ; User-initiated exit
    Case "Reload":
      ; Only applies when the Reload function is called within the script
    Case "Single":
      ; Only applies when the SingleInstance function is called within the script
      Result := MsgBox("Loading a new instance?", , 4)
      if Result = "No" {
        return 1  ; Callbacks must return non-zero to avoid exit.
      }
    Default:
      ; do nothing
  }
}