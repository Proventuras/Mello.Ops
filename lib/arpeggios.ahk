#Requires AutoHotkey v2.0

; ╭════════════════════════════════════════════════════════════════════════════════════════════════════════════════─╮
; ║  ARPEGGIOS.AHK                                                                                                  ║
; ║    Hit the [CapsLock]+[?] To enter the MODE, then follow it with another key to complete the ARPEGGIO.          ║
; ╠═════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
; ║  MODES:                                                                                                         ║
; ║  [B] BROWSE WEB     Open your favorite sites                                                                    ║
; ║  [O] OPEN APP       Open Application Mode                                                                       ║
; ║  [P] POWERTOYS      Shortcuts to PowerToys utils                                                                ║
; ║  [C] CLIP UTILs     Cliboard Utilities                                                                          ║
; ║  [U] UTILITIES      Utilities                                                                                   ║
; ╰═════════════════════════════════════════════════════════════════════════════════════════════════════════════════╯

; ╭─────────────────────────────────╮
; │  Helper Function: KeyWaitAny()  │
; ╰─────────────────────────────────╯
KeyWaitAny(*) {
  ; This function waits for a key to be pressed and returns the key name.
  ; It uses an InputHook to capture the keypress WITHIN a specific time frame (4 seconds).
  ; The key name is returned as a string.
  ih := InputHook("C L1 T4 M")
  ; ih.KeyOpt("{All}", "E")  ; End
  ih.Start()
  ih.Wait()

  ; if (ih.EndReason = "Max")
  ;       msg := 'You entered "{1}", which is the maximum length of text. (Endkey: {2})'
  ;   else if (ih.EndReason = "Timeout")
  ;       msg := 'You entered "{1}" at which time the input timed out.'
  ;   else if (ih.EndReason = "EndKey")
  ;       msg := 'You entered "{1}" and terminated the input with {2}.'

  ;   if msg  ; If an EndReason was found, skip the rest below.
  ;   {
  ;       MsgBox Format(msg, ih.Input, ih.EndKey)
  ;       return
  ;   }
  ; return ih.EndKey  ; Return the key name
  ; MsgBox "You entered: " ih.Input
  return ih.Input  ; Return the input string
}

ShowArpeggioSplash(message, icon := "none") {
  ; This function displays a splash screen with a message in the bottom right corner.
  ; It uses a GUI to show the message and positions it at the bottom right of the active monitor.
  ; The GUI will fade in and out, and it will not activate the window.
  global arpeGUI, arpeGUIWidth, arpeGUIHeight

  ; If the GUI already exists, destroy it first
  if IsSet(arpeGUI) {
    arpeGUI.Destroy()
    arpeGUI := ""
  }

  ; Display a dialog in the bottom right corner with a list, fade in/out
  arpeGUI := Gui("+AlwaysOnTop -Caption +ToolWindow")
  arpeGUI.BackColor := "White"
  arpeGUI.SetFont("s11", "Segoe UI")
  arpeGUI.AddText("w250 left cGreen", "Press a Key to start an application:")
  arpeGUI.SetFont("s11", "Segoe UI")
  arpeGUI.AddText("w250 left cGray", message)
  arpeGUI.Show("NoActivate AutoSize")
  ; Position bottom right of active monitor
  thisMonitor := MonitorGetWorkArea(, &thisMonLeft, &thisMonTop, &thisMonRight, &thisMonBottom)
  arpeGUI.GetPos(&__, &__, &arpeGUIWidth, &arpeGUIHeight)
  arpeGUI.Move(thismonRight - arpeGUIWidth - 20, thisMonBottom - arpeGUIHeight - 20)
}
; ╭──────────────────────────────────────────╮
; │  ⊞ [Alt/⌥] o. OPEN APPLICTATION Mode   │
; ├──────────────────────────────────────────┤
; │  [B] Beyond Compare                      │
; │  [C] Visual Studio Code                  |
; │  [E] Epic Pen                            │
; │  [N] Notion                              │
; |  [T] Windows Terminal                    │
; |  [!] Windows Terminal (ADMIN)            │
; │  [w] Warp Terminal                       │
; ├──────────────────────────────────────────┤
; │  NOTE: Modify with [ShiftPossible Candidates               │
; │  [w] Terminal (WSL)                      │
; ╰──────────────────────────────────────────╯
; CapsLock & o::
!#o::
{
  KeyWait "CapsLock"
  OptionWindow := "AppModeOptions"

  AppModeOptionsString := (
    "`nb`t Beyond Compare 4"
    "`nc`t VS Code"
    "`ne`t Epic Pen"
    "`nn`t Notion"
    "`nN`t Notepad"
    "`nt`t Windows Terminal"
    "`nw`t Warp Terminal"
  )

  ShowArpeggioSplash(AppModeOptionsString)
  ; Begin the 4 second wait before fading out the GUI
  retKeyHook := KeyWaitAny()

  ; Fade Out
  AW_BLEND := 0x00080000, AW_HIDE := 0x00010000
  DllCall("user32.dll\AnimateWindow", "Ptr", arpeGUI.hwnd, "UInt", 250, "UInt", AW_BLEND | AW_HIDE)
  arpeGUI.Destroy()

  ; Use a value switch on the captured key to avoid expression fall-through
  switch retKeyHook
  {
    case "b":
      LaunchApp("Beyond Compare 4")
      return
    case "c":
      LaunchApp("Visual Studio Code")
      return
    case "e":
      LaunchApp("Epic Pen")
      return
    case "n":
      LaunchApp("Notion")
      return
    case "N":
      LaunchApp("Notepad")
      return
    case "t":
      ShowActionSplash("Starting Windows Terminal...")
      LaunchTerminal()
      arpeActionGUI.Destroy()
      return
    case "T":
      ShowActionSplash("Starting Windows Terminal (Admin)...")
      try {
        Run "*RunAs wt.exe -w 0 new-tab --title Terminal(Admin) --suppressApplicationTitle"
      }
      arpeActionGUI.Destroy()
      return
    case "w":
      LaunchApp("Warp", false)
      return
    case "": return
    default:
      MsgBox "Invalid key pressed: " retKeyHook
      return
  }
  ; ; If the user did not press a key, exit the function
  ; if (retKeyHook = "") {
  ;   return
  ; }
  ; if (retKeyHook = "b") {
  ;   ShowActionSplash("Starting Beyond Compare 4...")
  ;   LaunchApp("Beyond Compare 4")
  ;   arpeActionGUI.Destroy()
  ; }
  ; else if (retKeyHook = "c") {
  ;   ShowActionSplash("Starting Visual Studio Code...")
  ;   LaunchApp("Visual Studio Code")
  ;   arpeActionGUI.Destroy()
  ; }
  ; else if (retKeyHook = "e") {
  ;   ShowActionSplash("Starting Epic Pen...")
  ;   LaunchApp("Epic Pen")
  ;   arpeActionGUI.Destroy()
  ; }
  ; else if (retKeyHook = "n") {
  ;   ShowActionSplash("Starting Notion...")
  ;   LaunchApp("Notion")
  ;   arpeActionGUI.Destroy()
  ; }
  ; ; Else If (retKeyHook = "o") {
  ; ;   ShowActionSplash("Starting Outlook...")
  ; ;   Send "^!+#o"
  ; ; }
  ; ; Else If (retKeyHook = "p") {
  ; ;   WiseGui(OptionWindow)
  ; ;   SplashGUI("Starting MS PowerPoint...", 2000)
  ; ;   Send "^!+#p"
  ; ; }
  ; ; Else If (retKeyHook = "w") {
  ; ;   WiseGui(OptionWindow)
  ; ;   SplashGUI("Starting MS Word...", 2000)
  ; ;   Send "^!+#w"
  ; ; }
  ; ; Else If (retKeyHook = "x") {
  ; ;   WiseGui(OptionWindow)
  ; ;   SplashGUI("Starting MS Excel...", 2000)
  ; ;   Send "^!+#x"
  ; ; }
  ; else if (retKeyHook = "T") {
  ;   ShowActionSplash("Starting Windows Terminal (Admin)...")
  ;   try {
  ;     Run "*RunAs wt.exe -w 0 new-tab --title Terminal(Admin) --suppressApplicationTitle"
  ;   }
  ;   arpeActionGUI.Destroy()
  ; }
  ; else if (retKeyHook = "t") {
  ;   ShowActionSplash("Starting Windows Terminal...")
  ;   LaunchTerminal()
  ;   arpeActionGUI.Destroy()
  ; }
  ; else if (retKeyHook = "w") {
  ;   ShowActionSplash("Starting Warp Terminal...")
  ;   LaunchApp("Warp")
  ;   arpeActionGUI.Destroy()
  ; }
  ; else {
  ;   ; MsgBox("Invalid key pressed: " retKeyHook)
  ; }
}

!#p::
{
  KeyWait "CapsLock"
  ShowArpeggioSplash(
    "Window Management Mode:`nArrows: move / Ctrl+Arrows: resize / Alt+Arrows: extend to edge`nNumpad 7..9 / 4..6 / 1..3 → grid`nPress [Tab] to exit"
  )

  prev := {}

  ; Movement deltas for arrow keys
  deltas := { Left: { dx: -50, dy: 0 }, Right: { dx: 50, dy: 0 }, Up: { dx: 0, dy: -50 }, Down: { dx: 0, dy: 50 } }

  ; Numpad -> Snap mapping (uses SnapActiveWindow from winui-mgmt.ahk)
  numpadMap := {}
  numpadMap["Numpad7"] := { zone: "top", side: "left", size: "half" }
  numpadMap["Numpad8"] := { zone: "top", side: "full", size: "half" }
  numpadMap["Numpad9"] := { zone: "top", side: "right", size: "half" }
  numpadMap["Numpad4"] := { zone: "middle", side: "left", size: "full" }
  numpadMap["Numpad5"] := { zone: "middle", side: "full", size: "full" }
  numpadMap["Numpad6"] := { zone: "middle", side: "right", size: "full" }
  numpadMap["Numpad1"] := { zone: "bottom", side: "left", size: "half" }
  numpadMap["Numpad2"] := { zone: "bottom", side: "full", size: "half" }
  numpadMap["Numpad3"] := { zone: "bottom", side: "right", size: "half" }

  loop {
    Sleep 30

    ; Exit when Tab is pressed
    if GetKeyState("Tab", "P")
      break

    ctrl := GetKeyState("LCtrl", "P") || GetKeyState("RCtrl", "P")
    alt := GetKeyState("LAlt", "P") || GetKeyState("RAlt", "P")

    ; Arrow key handling
    for key, delta in deltas {
      state := GetKeyState(key, "P")
      if state && !prev[key] {
        if ctrl {
          ; Resize via percentages (matches winui-mgmt.ahk conventions)
          if (key = "Up")
            ResizeWindowBorders(0, 5, 5, 0)
          else if (key = "Down")
            ResizeWindowBorders(0, -5, -5, 0)
          else if (key = "Left")
            ResizeWindowBorders(-5, 0, 0, -5)
          else if (key = "Right")
            ResizeWindowBorders(5, 0, 0, 5)
        }
        else if alt {
          if (key = "Up")
            ExtendToMonitorEdge("top")
          else if (key = "Down")
            ExtendToMonitorEdge("bottom")
          else if (key = "Left")
            ExtendToMonitorEdge("left")
          else if (key = "Right")
            ExtendToMonitorEdge("right")
        }
        else {
          ; Move the active window
          MoveActiveWindow(delta.dx, delta.dy)
        }
      }
      prev[key] := state
    }

    ; Numpad handling (snap)
    for k, spec in numpadMap {
      state := GetKeyState(k, "P")
      if state && !prev[k] {
        SnapActiveWindow(spec[1], spec[2], spec[3])
      }
      prev[k] := state
    }
  }

  ; Fade out & destroy splash
  AW_BLEND := 0x00080000, AW_HIDE := 0x00010000
  if IsSet(arpeGUI) {
    DllCall("user32.dll\AnimateWindow", "Ptr", arpeGUI.hwnd, "UInt", 150, "UInt", AW_BLEND | AW_HIDE)
    arpeGUI.Destroy()
    arpeGUI := ""
  }

  return
}
; ╭──────────────────────────────────────────╮
; │  [CapsLock]+[C]. Clipboard Utilities     │
; ├──────────────────────────────────────────┤
; │  [c] Open selected into Google           │
; │  [d] Open selected into ChatGPT          │
; │  [g] Open selected into NotebookLM       │
; │  [i] Open selected into Google AI Studio │
; │  [p] portal.azure.com                    │
; │  [y] youtube.com                         │
; ├──────────────────────────────────────────┤
; │  [?] Perplexity                          │
; │  [?] mail.google.com                     │
; │  [?]                                     │
; │  [?]                                     │
; ╰──────────────────────────────────────────╯
;================================================================================================
; Hot keys with CapsLock modifier. See https://autohotkey.com/docs/Hotkeys.htm#combo
;================================================================================================
; Get DEFINITION of selected word.
; CapsLock & d:: {
;   ClipboardGet()
;   Run, http: // www.google.com / search ? q = define + %clipboard% ; Launch with contents of clipboard
;     ClipboardRestore()
;     Return
;       }

;   ; GOOGLE the selected text.
;   CapsLock & g:: {
;     ClipboardGet()
;     Run, http: // www.google.com / search ? q = %clipboard% ; Launch with contents of clipboard
;       ClipboardRestore()
;       Return
;         }

;     ; Do THESAURUS of selected word
;     CapsLock & t:: {
;       ClipboardGet()
;       Run http: // www.thesaurus.com / browse / %Clipboard% ; Launch with contents of clipboard
;       ClipboardRestore()
;       Return
;     }

;     ; Do WIKIPEDIA of selected word
;     CapsLock & w:: {
;       ClipboardGet()
;       Run, https: // en.wikipedia.org / wiki / %clipboard% ; Launch with contents of clipboard
;       ClipboardRestore()
;       Return
;     }

;     ClipboardGet()
;     {
;       OldClipboard := ClipboardAll ;Save existing clipboard.
;       Clipboard := ""
;       Send, ^ c ;Copy selected test to clipboard
;       ClipWait 0
;       If ErrorLevel
;       {
;         MsgBox, No Text Selected !
;           Return
;       }
;     }

;     ClipboardRestore()
;     {
;       Clipboard := OldClipboard
;     }

; ╭──────────────────────────────────────────╮
; │  [CapsLock]+[B]. OPEN Web Sites          │
; ├──────────────────────────────────────────┤
; │  [c] chat.openai.com                     │
; │  [d] dev.azure.com                       │
; │  [g] github.com                          │
; │  [i] icons8.com                          │
; │  [p] portal.azure.com                    │
; │  [y] youtube.com                         │
; ├──────────────────────────────────────────┤
; │  [?] Perplexity                          │
; │  [?] mail.google.com                     │
; │  [?]                                     │
; │  [?]                                     │
; ╰──────────────────────────────────────────╯
