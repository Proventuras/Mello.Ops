#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir A_ScriptDir

; ╭════════════════════════════════════════════════════════════════════════════════════════════════════════════════─╮
; ║  WINDOW_MGR.AHK (v2502_beta)                                                                                    ║
; ║  Manages the location and dimensions of the Active Window using performant DllCalls.                            ║
; ║  Refactored for maximum readability, maintainability, and performance.                                          ║
; ╰═════════════════════════════════════════════════════════════════════════════════════════════════════════════════╯

; ╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
; │ Configuration                                                                                                   │
; ╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
global GESTURE_TOLERANCE := 60  ; Pixels the mouse must move to trigger a gesture.
global GESTURE_MIN_TIME := 50   ; Minimum milliseconds for a gesture to register.
global GESTURE_LONG_TIME := 200 ; Minimum milliseconds for a "down" gesture to avoid accidental triggers.

; ╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
; │ Hotkeys (CapsLock is the modifier key)                                                                          │
; ╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯

CapsLock & LButton:: HandleWindowDrag()
CapsLock & RButton:: HandleWindowResize()
CapsLock & MButton:: HandleWindowGesture()

; ╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
; │ Numpad Hotkeys for Snapping                                                                                     │
; ╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
CapsLock & Numpad1:: SnapActiveWindow("bottom", "left", "half")
CapsLock & Numpad2:: SnapActiveWindow("bottom", "full", "half")
CapsLock & Numpad3:: SnapActiveWindow("bottom", "right", "half")
CapsLock & Numpad4:: SnapActiveWindow("top", "left", "full")
CapsLock & Numpad5:: ToggleActiveWindowMaximize()
CapsLock & Numpad6:: SnapActiveWindow("top", "right", "full")
CapsLock & Numpad7:: SnapActiveWindow("top", "left", "half")
CapsLock & Numpad8:: SnapActiveWindow("top", "full", "half")
CapsLock & Numpad9:: SnapActiveWindow("top", "right", "half")

; ╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
; │ Sizing and Posing                                                                                               │
; ╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
CapsLock & /:: SqueezeAndPose(70)         ; [⇪]+[/]: Resize to 70% of the screen and center
CapsLock & <:: SqueezeAndPose(0, -5)      ; [⇪]+[<]: Decrease size by 5% of the screen
CapsLock & >:: SqueezeAndPose(0, 5)       ; [⇪]+[>]: Increase size by 5% of the screen

; --- Arrow Key Combinations ---
CapsLock & Up:: {
  if GetKeyState("LCtrl", "P") {
    ResizeWindowBorders(0, 5, 5, 0)       ; [⇪]+[LCtrl]+[↑]: Expand window vertically by 10%
  }
  else if GetKeyState("LAlt", "P") {      
    ExtendToMonitorEdge("top")            ; [⇪]+[LAlt]+[↑]: Extend window to the top of the monitor
  } else {
    MoveActiveWindow(0, -50)              ; [⇪]+[↑]: Move window up
  }
}

CapsLock & Down:: {
  if GetKeyState("LCtrl", "P") {
    ResizeWindowBorders(0, -5, -5, 0)       ; [⇪]+[LCtrl]+[↓]: Shrink window vertically by 10%
  }
  else if GetKeyState("LAlt", "P") {        
    ExtendToMonitorEdge("bottom")           ; [⇪]+[LAlt]+[↓]: Extend window to the bottom of the monitor
  }
  else {
    MoveActiveWindow(0, 50)               ; [⇪]+[↓]: Move window down
  }
}

CapsLock & Left:: {
  if GetKeyState("LCtrl", "P") {
    ResizeWindowBorders(-5, 0, 0, -5)       ; [⇪]+[LCtrl]+[←]: Shrink window horizontally by 10%
  }
  else if GetKeyState("LAlt", "P") {
    ExtendToMonitorEdge("left")             ; [⇪]+[LAlt]+[←]: Extend window to the left of the monitor
  }
  else {
    MoveActiveWindow(-50, 0)                ; [⇪]+[←]: Move window left
  }
}

CapsLock & Right:: {
  if GetKeyState("LCtrl", "P") {
    ResizeWindowBorders(5, 0, 0, 5)         ; [⇪]+[LCtrl]+[→]: Expand window horizontally by 10%
  }
  else if GetKeyState("LAlt", "P") {
    ExtendToMonitorEdge("right")            ; [⇪]+[LAlt]+[→]: Extend window to the right of the monitor
  }
  else {
    MoveActiveWindow(50, 0)                 ; [⇪]+[→]: Move window right
  }
}

; ╭───────────────────────────────────────────────────────────────────────────────────────────────────╮
; │ Core Functions                                                                                    │
; ╰───────────────────────────────────────────────────────────────────────────────────────────────────╯

SqueezeAndPose(screen_percent, resize_percent := 0) {
  ; ╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
  ; │ Squeezes, Poses, or Resizes the active window relative to its current monitor.                              │
  ; ├─────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
  ; │ Parameters:                                                                                                 │
  ; │   screen_percent: If > 0, resizes the window to this percentage of the monitor's work area.                 │
  ; │   resize_percent: Adjusts the window's size by this percentage of the monitor's work area.                  │
  ; │                   A negative value shrinks the window, a positive value expands it.                         │
  ; ╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
  active_hwnd := WinExist("A")
  if (IsExcludedWindow(active_hwnd) || (screen_percent = 0 && resize_percent = 0))
    return

  ; Get the window's current monitor and its dimensions
  monitor_index := GetMonitorIndexFromWindow(active_hwnd)
  MonitorGetWorkArea(monitor_index, &monX, &monY, &monRight, &monBottom)
  monW := monRight - monX
  monH := monBottom - monY

  WinGetPos(&outX, &outY, &winW, &winH, active_hwnd)

  ; Calculate the new width and height
  newW := 0
  newH := 0
  if (screen_percent > 0) {
    ; Base the new size on a percentage of the screen, then apply the resize adjustment
    percent := (screen_percent + resize_percent) / 100
    newW := Round(monW * percent)
    newH := Round(monH * percent)
  } else {
    ; Adjust the current window size by a percentage of the screen
    newW := winW + Round(monW * (resize_percent / 100))
    newH := winH + Round(monH * (resize_percent / 100))
  }

  ; Calculate the new position to center the window on the monitor
  newX := monX + Floor((monW - newW) / 2)
  newY := monY + Floor((monH - newH) / 2)

  ; Restore the window if maximized/minimized and move it
  WinRestore(active_hwnd)
  WinMove(newX, newY, newW, newH, active_hwnd)
}

ResizeWindowBorders(left_percent := 0, bottom_percent := 0, top_percent := 0, right_percent := 0) {
  ; ╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
  ; │ Resizes the active window by moving its borders by a specified percentage of the current monitor's size.    │
  ; ├─────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
  ; │ Parameters (in percent of monitor size):                                                                    │
  ; │   left_percent:   Positive expands left, negative shrinks from the left.                                    │
  ; │   bottom_percent: Positive expands down, negative shrinks from the bottom.                                  │
  ; │   top_percent:    Positive expands up, negative shrinks from the top.                                       │
  ; │   right_percent:  Positive expands right, negative shrinks from the right.                                  │
  ; ╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
  ; Get the active window handle and its current position/size

  ; Cancel operation if the active window is a Remote Deskto Connection or a Snap Assist window
  if (WinGetClass("A") = "TscShellContainerClass" or WinGetTitle("A") = "Snap Assist" or WinGetClass("A") = "XamlExplorerHostIslandWindow") {
    return
  }
  active_hwnd := WinGetID("A")

  if IsExcludedWindow(active_hwnd)
    return

  ; Get the window's current monitor and its dimensions
  monitor_index := GetMonitorIndexFromWindow(active_hwnd)
  MonitorGetWorkArea(monitor_index, &monX, &monY, &monRight, &monBottom)
  monW := monRight - monX
  monH := monBottom - monY

  ; Calculate pixel deltas from percentages
  leftDelta := Round(monW * (left_percent / 100))
  rightDelta := Round(monW * (right_percent / 100))
  topDelta := Round(monH * (top_percent / 100))
  bottomDelta := Round(monH * (bottom_percent / 100))

  WinGetPos(&winX, &winY, &winW, &winH, active_hwnd)

  ; Calculate new position and size based on deltas
  newX := winX - leftDelta
  newY := winY - topDelta
  newW := winW + leftDelta + rightDelta
  newH := winH + topDelta + bottomDelta

  ; Ensure the window does not become smaller than a minimum size
  if (newW < 100)
    newW := 100
  if (newH < 100)
    newH := 100

  ; WinRestore(active_hwnd)
  WinMove(newX, newY, newW, newH, active_hwnd)
}

MoveActiveWindow(leftDelta := 0, topDelta := 0) {
  ; ╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
  ; │ Moves the active window by the specified pixel amounts.                                                     │
  ; ├─────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
  ; │ Parameters (in pixels):                                                                                     │
  ; │   leftDelta: Positive moves right, negative moves left.                                                     │
  ; │   topDelta:  Positive moves down, negative moves up.                                                        │
  ; ╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
  active_hwnd := WinExist("A")
  if IsExcludedWindow(active_hwnd)
    return

  ; Do not move minimized windows
  if WinGetMinMax(active_hwnd) = -1
    return

  WinGetPos(&winX, &winY, , , active_hwnd)

  ; Calculate new position
  newX := winX + leftDelta
  newY := winY + topDelta

  ; WinRestore(active_hwnd)
  WinMove(newX, newY, , , active_hwnd)
}

ExtendToMonitorEdge(direction) {
  ; ╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
  ; │ Extends the active window to the edge of the monitor in the specified direction.                             │
  ; ├─────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
  ; │ Parameters:                                                                                                 │
  ; │   direction: "left", "right", "top", or "bottom".                                                           │
  ; ╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
  active_hwnd := WinExist("A")
  if IsExcludedWindow(active_hwnd)
    return

  WinGetPos(&winX, &winY, &winW, &winH, active_hwnd)
  monitor_index := GetMonitorIndexFromWindow(active_hwnd)
  MonitorGetWorkArea(monitor_index, &monX, &monY, &monRight, &monBottom)

  if (direction = "left") {
    WinMove(monX, winY, winW + (winX - monX), winH, active_hwnd)
  } else if (direction = "right") {
    WinMove(winX, winY, monRight - winX, winH, active_hwnd)
  } else if (direction = "top") {
    WinMove(winX, monY, winW, winH + (winY - monY), active_hwnd)
  } else if (direction = "bottom") {
    WinMove(winX, winY, winW, monBottom - winY, active_hwnd)
  }
}
HandleWindowDrag() {
  ; ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
  ; │ Handles moving a window with LWin + Left Mouse Button.                                          │
  ; ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
  MouseGetPos , , &window_id
  if IsDesktop(window_id)
    return

  ; If window is maximized, restore it and center the mouse cursor before dragging
  if WinGetMinMax(window_id) {
    WinRestore(window_id)
    WinGetPos(&winX, &winY, &winW, &winH, window_id)
    MouseMove((winX + winW / 2), (winY + winH / 2), 0)
  }

  MouseGetPos(&startX, &startY)
  WinGetPos(&startWinX, &startWinY, , , window_id)

  Loop {
    if !GetKeyState("LButton", "P")
      break
    MouseGetPos(&currentX, &currentY)
    offsetX := currentX - startX
    offsetY := currentY - startY
    newWinX := startWinX + offsetX
    newWinY := startWinY + offsetY
    WinMove(newWinX, newWinY, , , window_id)
  }
}

HandleWindowResize() {
  ; ╭───────────────────────────────────────────────────────────────────────────────────────────────╮
  ; │ Handles resizing a window with LWin + Right Mouse Button.                                     │
  ; ╰───────────────────────────────────────────────────────────────────────────────────────────────╯
  MouseGetPos(&startX, &startY, &window_id)

  if IsDesktop(window_id) || WinGetMinMax(window_id)
    return ; Abort on desktop or maximized windows

  WinGetPos(&winX, &winY, &winW, &winH, window_id)

  ; Determine resize direction based on initial cursor position
  isLeftThird := startX < (winX + winW / 3)
  isRightThird := startX > (winX + 2 * winW / 3)
  isTopThird := startY < (winY + winH / 3)
  isBottomThird := startY > (winY + 2 * winH / 3)

  ; Determine how position and size should change based on which "third" of the window is grabbed
  posChangeX := isLeftThird ? 1 : 0
  sizeChangeW := isRightThird ? 1 : (isLeftThird ? -1 : 0)
  posChangeY := isTopThird ? 1 : 0
  sizeChangeH := isBottomThird ? 1 : (isTopThird ? -1 : 0)

  ; If grabbing the exact center, treat it as a move action
  if (sizeChangeW = 0 && sizeChangeH = 0 && posChangeX = 0 && posChangeY = 0) {
    posChangeX := 1
    posChangeY := 1
  }

  Loop {
    if !GetKeyState("RButton", "P")
      break
    MouseGetPos(&currentX, &currentY)
    WinGetPos(&loopWinX, &loopWinY, &loopWinW, &loopWinH, window_id)

    offsetX := currentX - startX
    offsetY := currentY - startY

    WinMove(loopWinX + (posChangeX * offsetX),
      loopWinY + (posChangeY * offsetY),
      loopWinW + (sizeChangeW * offsetX),
      loopWinH + (sizeChangeH * offsetY),
      window_id)

    startX := currentX
    startY := currentY
  }
}

HandleWindowGesture() {
  ; ╭───────────────────────────────────────────────────────────────────────────────────────────────╮
  ; │ Detects mouse gestures after a middle-click and triggers actions.                             │
  ; ╰───────────────────────────────────────────────────────────────────────────────────────────────╯
  MouseGetPos(&startX, &startY, &window_id)
  if IsDesktop(window_id)
    return

  KeyWait("MButton")
  MouseGetPos(&endX, &endY)

  ; No movement = Minimize
  if (A_TimeSinceThisHotkey > GESTURE_MIN_TIME && startX = endX && startY = endY) {
    WinMinimize(window_id)
    return
  }

  deltaX := endX - startX
  deltaY := endY - startY
  absDeltaX := Abs(deltaX)
  absDeltaY := Abs(deltaY)

  ; Determine gesture direction
  isUp := deltaY < 0 && absDeltaY >= GESTURE_TOLERANCE
  isDown := deltaY > 0 && absDeltaY >= GESTURE_TOLERANCE && A_TimeSinceThisHotkey > GESTURE_LONG_TIME
  isLeft := deltaX < 0 && absDeltaX >= GESTURE_TOLERANCE
  isRight := deltaX > 0 && absDeltaX >= GESTURE_TOLERANCE

  ; Diagonal Gestures (Snap to Quarter)
  if isUp && isRight {
    SnapWindowByHandle(window_id, "top", "right", "half")
  }
  else if isDown && isRight {
    SnapWindowByHandle(window_id, "bottom", "right", "half")
  }
  else if isUp && isLeft {
    SnapWindowByHandle(window_id, "top", "left", "half")
  }
  else if isDown && isLeft {
    SnapWindowByHandle(window_id, "bottom", "left", "half")
  }
  ; Cardinal Gestures
  else if isUp {
    ToggleMaximize(window_id)
  }
  else if isDown {
    WinSetAlwaysOnTop(-1, window_id)
  }
  else if isLeft {
    SnapWindowByHandle(window_id, "top", "left", "full")
  }
  else if isRight {
    SnapWindowByHandle(window_id, "top", "right", "full")
  }
}

; ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
; │ Snapping and Utility Functions                                                                  │
; ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯

SnapActiveWindow(vPos, hPos, hSize) {
  ; Helper function to snap the currently active window. Aborts if it's the desktop.
  activeWin := WinExist("A")
  if IsDesktop(activeWin)
    return
  SnapWindowByHandle(activeWin, vPos, hPos, hSize)
}

SnapWindowByHandle(window_id, vPos, hPos, hSize) {
  ; Snaps a window (specified by its ID) to a position and size based on its monitor's work area.
  heightOffset := 7
  widthOffset := 15
  xOffset := 7

  if WinGetMinMax(window_id)
    WinRestore(window_id)

  activeMon := GetMonitorIndexFromWindow(window_id)
  MonitorGetWorkArea(activeMon, &monLeft, &monTop, &monRight, &monBottom)

  monWidth := monRight - monLeft
  monHeight := monBottom - monTop

  if (hSize = "half") {
    height := monHeight / 2 + heightOffset
  } else if (hSize = "full") {
    height := monHeight + heightOffset
  } else if (hSize = "third") {
    height := monHeight / 3
  }

  if (hPos = "left") {
    posX := monLeft - xOffset
    width := monWidth / 2 + widthOffset
  } else if (hPos = "right") {
    posX := monLeft + monWidth / 2 - xOffset
    width := monWidth / 2 + widthOffset
  } else { ; "full"
    posX := monLeft - xOffset
    width := monWidth + widthOffset
  }

  if (vPos = "bottom") {
    posY := monBottom - height + heightOffset
  } else if (vPos = "middle") {
    posY := monTop + height
  } else { ; "top"
    posY := monTop
  }

  WinMove(posX, posY, width, height, window_id)
}

; ╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
; │ Utility Functions                                                                                               │
; ╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯

GetMonitorIndexFromWindow(windowHandle) {
  ; ╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
  ; │ Determines which monitor a window is on using the DllCall method. Returns the monitor index (starts with 1).│
  ; ╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
  monitorIndex := 1
  monitorInfo := Buffer(40)
  NumPut('UInt', 40, monitorInfo)

  if (monitorHandle := DllCall("MonitorFromWindow", "Ptr", windowHandle, "UInt", 0x2)) ; MONITOR_DEFAULTTONEAREST
    && DllCall("GetMonitorInfo", "Ptr", monitorHandle, "Ptr", monitorInfo) {
    monitorLeft := NumGet(monitorInfo, 4, "Int")
    monitorTop := NumGet(monitorInfo, 8, "Int")
    monitorRight := NumGet(monitorInfo, 12, "Int")
    monitorBottom := NumGet(monitorInfo, 16, "Int")

    Loop MonitorGetCount() {
      MonitorGet(A_Index, &tempMonLeft, &tempMonTop, &tempMonRight, &tempMonBottom)
      if (monitorLeft = tempMonLeft && monitorTop = tempMonTop && monitorRight = tempMonRight && monitorBottom = tempMonBottom) {
        monitorIndex := A_Index
        break
      }
    }
  }
  return monitorIndex
}

IsExcludedWindow(active_hwnd) {
  ; ╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
  ; │ Checks if a window should be ignored by this script to prevent unintended behavior.                         │
  ; ╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
  if !active_hwnd
    return true

  winClass := WinGetClass(active_hwnd)
  winTitle := WinGetTitle(active_hwnd)

  ; Add any window classes, titles, or executables to this list to exclude them.
  excludedClasses := ["TscShellContainerClass", "XamlExplorerHostIslandWindow", "Windows.UI.Core.CoreWindow", "Shell_TrayWnd"]
  excludedTitles := ["Snap Assist", thisapp_name . " - About"]

  for _, title in excludedTitles {
    if InStr(winTitle, title)
      return true
  }

  for _, class in excludedClasses {
    if InStr(winClass, class)
      return true
  }

  return false
}

ToggleActiveWindowMaximize() {
  ; Toggles the maximized state of the active window.
  activeWin := WinExist("A")
  if IsDesktop(activeWin)
    return
  ToggleMaximize(activeWin)
}

ToggleMaximize(window_id) {
  ; Toggles the maximized state of a specific window.
  WinGetMinMax(window_id) ? WinRestore(window_id) : WinMaximize(window_id)
}

IsDesktop(window_id) {
  ; Checks if the given window handle belongs to the desktop.
  return WinGetClass(window_id) = "WorkerW"
}