#Requires AutoHotkey v2.0
#SingleInstance Force

SqueezeAndPose(screen_percent, resize_percent := 0) {
  ; ╭───────────────────────────────────────────────────────────────────────────────────────────╮
  ; │ SqueezeAndPose: Resize and center the active window to a percentage of the screen size.   │
  ; │ screen_percent: Percentage of the screen size to resize the window to (e.g., 50 for 50%). │
  ; │ resize_percent: Percentage of the screen size to resize the window by (e.g., -5 for 5%    │
  ; │                 smaller, 5 for 5% larger).                                                │
  ; │ If both are zero, do nothing.                                                             │
  ; ╰───────────────────────────────────────────────────────────────────────────────────────────╯
  ; Validate input
  if (screen_percent = 0 && resize_percent = 0)
    return

  ; Get the total Monitor Work Area
  totalWorkAreawidth := SysGet(78) ; Total Work Area Width
  totalWorkAreaHeight := SysGet(79) ; Total Work Area Height
  totalWorkArea := SysGet(80) ; Total Work Area (as an object)

  ; Get the active window handle
  winX := 0, winY := 0, winW := 0, winH := 0
  active_hwnd := WinGetID("A")
  if !active_hwnd {
    MsgBox("No active window handle found!")
    return
  }
  WinGetPos(&winX, &winY, &winW, &winH, active_hwnd)

  ; get the center coordinates of the active window
  center_x := winX + Floor(winW / 2)
  center_y := winY + Floor(winH / 2)

  ; Get the active window's position, size and monitor information
  MonitorCount := MonitorGetCount()
  MonitorPrimary := MonitorGetPrimary()

  ; Find which monitor the window is on and get its work area
  MonitorGetWorkAreaNum := 1
  Loop MonitorCount
  {
    MonitorGet(A_Index, &L, &T, &R, &B)
    if (center_x >= L && center_x <= R && center_y >= T && center_y <= B) {
      MonitorGetWorkAreaNum := A_Index
      break
    }
  }

  MonitorGetWorkArea(MonitorGetWorkAreaNum, &screenX, &screenY, &screenW, &screenH)
  screenW := screenW - screenX
  screenH := screenH - screenY

  if (screen_percent > 0) {
    ; Resize to screen_percent% of monitor, then apply resize_percent
    percent := (screen_percent + resize_percent) / 100
    newW := Round(screenW * percent)
    newH := Round(screenH * percent)
  } else {
    ; Keep window size, but adjust by resize_percent of monitor
    newW := winW + Round(screenW * (resize_percent / 100))
    newH := winH + Round(screenH * (resize_percent / 100))
  }

  newX := screenX + Floor((screenW - newW) / 2)
  newY := screenY + Floor((screenH - newH) / 2)

  ; MsgBox("Handle: " . active_hwnd . " Title: " . WinGetTitle(active_hwnd))
  ; if (WinGetMinMax(active_hwnd) = 1)  ; 1 = Maximized
  WinRestore(active_hwnd) ; WinrRestore tends to keep the window animation smooth
  WinMove(newX, newY, newW, newH, active_hwnd)
}

ResizeWindowBorders(leftDelta := 0, bottomDelta := 0, topDelta := 0, rightDelta := 0) {
  ; ╭────────────────────────────────────────────────────────────────────────────────────────────────╮
  ; │ ResizeWindowBorders: Resize the active window by moving its borders in specified directions.   │
  ; │   leftDelta: Pixels to move the left border (negative to decrease width).                      │
  ; │   bottomDelta: Pixels to move the bottom border (negative to decrease height).                 │
  ; │   topDelta: Pixels to move the top border (negative to decrease height).                       │
  ; │   rightDelta: Pixels to move the right border (negative to decrease width).                    │
  ; ╰────────────────────────────────────────────────────────────────────────────────────────────────╯
  ; Get the active window handle and its current position/size
  winX := 0, winY := 0, winW := 0, winH := 0
  active_hwnd := WinGetID("A")
  if !active_hwnd {
    MsgBox("No active window handle found!")
    return
  }
  WinGetPos(&winX, &winY, &winW, &winH, active_hwnd)

  ; Calculate new position and size
  newX := winX - leftDelta
  newY := winY - topDelta
  newW := winW + leftDelta + rightDelta
  newH := winH + topDelta + bottomDelta

  ; Prevent negative width/height
  if (newW < 1)
    newW := 100
  if (newH < 1)
    newH := 100

  WinRestore(active_hwnd) ; WinrRestore tends to keep the window animation smooth
  WinMove(newX, newY, newW, newH, active_hwnd)
}

MoveActiveWindow(leftDelta := 0, topDelta := 0) {
  ; ╭──────────────────────────────────────────────────────────────────────────────╮
  ; │ MoveActiveWindow: Move the active window by the specified pixel amounts.     │
  ; │   leftDelta: Pixels to move the window left (negative to move right).        │
  ; │   topDelta: Pixels to move the window up (negative to move down).            │
  ; ╰──────────────────────────────────────────────────────────────────────────────╯

  ; Exit function if the active window is "Snap Assist" or "Task View"
  if (WinGetClass("A") = "Windows.UI.Core.CoreWindow" || WinGetClass("A") = "Shell_TrayWnd") {
    MsgBox("Cannot move the Snap Assist or Task View window!")
    return
  }
  ; Get the active window handle and its current position/size
  winX := 0, winY := 0, winW := 0, winH := 0
  active_hwnd := WinGetID("A")
  if !active_hwnd {
    MsgBox("No active window handle found!")
    return
  }
  ; Get the current position and size of the active window
  WinGetPos(&winX, &winY, &winW, &winH, active_hwnd)

  if (WinGetMinMax(active_hwnd) = 1) { ; 1 = Maximized
    WinRestore(active_hwnd) ; WinrRestore tends to keep the window animation smooth
  } else if (WinGetMinMax(active_hwnd) = -1) { ; -1 = Minimized
    return ; Do not move minimized windows
  }

  ; Calculate new position and size
  newX := winX + leftDelta
  newY := winY + topDelta

  WinMove(newX, newY, , , active_hwnd)
}

; ╭─────────────────────────────────────────────────────────────────────────────────────────╮
; │ Shortcuts for resizing window using the CapsLock[⇪] modifier:                           │
; │ ✓                [⇪]+[/]: Resize to 70% of the screen size                              │
; │ ✓ [⇪]+[Lt Square Brackt]: Decrease size by 5% of the screen size                        │
; │ ✓ [⇪]+[Rt Square Brackt]: Increase size by 5% of the screen size                        │
; │ ✓          [⇪]+[← ↑ ↓ →]: Move the active window                                        │
; │ ✓  [⇪]+[LCtrl]+[← ↑ ↓ →]: Expand(↑,→) or shrink(↓,←) window vertically or horizontally  │
; │ ×       [⇪]+[LShift]+[↑]: Expand window to the TOP EDGE of the screen                   │
; │ ×       [⇪]+[LShift]+[↓]: Expand window to the BOTTOM EDGE dimensions of the screen     │
; │ ×       [⇪]+[LShift]+[←]: Expand window to the LEFT EDGE dimension of the screen        │
; │ ×       [⇪]+[LShift]+[→]: Expand window to the RIGHT EDGE of the screen                 │
; │ ×    [⇪]+[LAlt]+[← ↑ ↓ ]: Shrink window by moving border inwards in the key direction   │
; │ ×      [⇪]+[⊞]+[← ↑ ↓ ]: Shrink window by moving border inwards in the key direction   │
; ╰─────────────────────────────────────────────────────────────────────────────────────────╯
Capslock & /:: { ; [⇪]+[/]: Resize to 70% of the screen size
  SqueezeAndPose(70)
  return
}
CapsLock & [:: { ; [⇪]+[Left Square Bracket]: Decrease size by 5% of the screen size
  SqueezeAndPose(0, -5)
  return
}
CapsLock & ]:: { ; [⇪]+[Right Square Bracket]: Increase size by 5% of the screen size
  SqueezeAndPose(0, 5)
  return
}
CapsLock & Up:: {
  if GetKeyState("LCtrl", "P") {
    ResizeWindowBorders(0, 25, 25, 0)     ; [⇪]+[LCtrl]+[↑]: Expand the window vertically (50px)
  } else if GetKeyState("LShift", "P") {
    return                                ;   ResizeWindowBorders(0, 0, 25, 0)      ; [⇪]+[LShift]+[↑]: ???
  } else if GetKeyState("LWin", "P") {
    return                                ;   ResizeWindowBorders(0, 0, 0, 25)     ; [⇪]+[⊞]+[→]: ???
  } else if GetKeyState("LAlt", "P") {
    ResizeWindowBorders(0, -25, 0, 0)   ; [⇪]+[LAlt]+[↑]: Shrink & move bottom border upwards (25 pixels)
  } else {
    MoveActiveWindow(0, -50)              ; [⇪]+[↑]: Move the window up by 50 pixels
  }
  return
}
CapsLock & Right:: {
  if GetKeyState("LCtrl", "P") {
    ResizeWindowBorders(25, 0, 0, 25)     ; [⇪]+[LCtrl]+[→]: Expand the window horizontally (50px)
  } else if GetKeyState("LShift", "P") {
    return                                ;   ResizeWindowBorders(0, 0, 0, 25)     ; [⇪]+[LShift]+[→]: ???
  } else if GetKeyState("LWin", "P") {
    return                                ;   ResizeWindowBorders(0, 0, 0, 25)     ; [⇪]+[⊞]+[→]: ???
  } else if GetKeyState("LAlt", "P") {
    ResizeWindowBorders(-25, 0, 0, 0)  ; [⇪]+[LAlt]+[→]: Shrink & move left border inwards (25 pixels)
  } else {
    MoveActiveWindow(50, 0)            ; [⇪]+[→]: Move the window right by 50px
  }
  return
}
CapsLock & Down:: {
  if GetKeyState("LCtrl", "P") {
    ResizeWindowBorders(0, -25, -25, 0)   ; [⇪]+[LCtrl]+[↓]: Shrink the window vertically (50px)
  } else if GetKeyState("LShift", "P") {
    return                                ;   ResizeWindowBorders(0, 0, -25, 0)     ; [⇪]+[LShift]+[↓]: ???
  } else if GetKeyState("LWin", "P") {
    return                                ;   ResizeWindowBorders(0, 0, 0, 25)     ; [⇪]+[⊞]+[→]: ???
  } else if GetKeyState("LAlt", "P") {
    ResizeWindowBorders(0, 0, -25, 0)    ; [⇪]+[LAlt]+[↓]: Shrink & move top border inwards (25 pixels)
  } else {
    MoveActiveWindow(0, 50)               ; [⇪]+[↓]: Move the window down by 50 pixels
  }
  return
}
CapsLock & Left:: {
  if GetKeyState("LCtrl", "P") {
    ResizeWindowBorders(-25, 0, 0, -25)     ; [⇪]+[LCtrl]+[←]: Shrink the window horizontally (50px)
  } else if GetKeyState("LShift", "P") {
    return                                  ;ResizeWindowBorders(0, 0, -25, 0) ; [⇪]+[LShift]+[↓]: ???
  } else if GetKeyState("LWin", "P") {
    return                                ;   ResizeWindowBorders(0, 0, 0, 25)     ; [⇪]+[⊞]+[→]: ???
  } else if GetKeyState("LAlt", "P") {
    ResizeWindowBorders(0, 0, 0, -25)   ; [⇪]+[LAlt]+[←]: Shrink & move right border inwards by 25 pixels
  } else {
    MoveActiveWindow(-50, 0)     ; [⇪]+[←]: Move the window left by 50 pixels
  }
  return
}