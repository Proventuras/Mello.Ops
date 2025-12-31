#Requires AutoHotkey v2.0
; ╭════════════════════════════════════════════════════════════════════════════════════════════════════════════════─╮
; ║  APP-AUTOMATE.AHK                                                                                               ║
; ║    - Manages the location and dimensions of the Active Window using performant DllCalls.                        ║
; ║    - Refactored for maximum readability, maintainability, and performance.                                      ║
; ╰═════════════════════════════════════════════════════════════════════════════════════════════════════════════════╯
;╭──────────────────────────────────────────╮
;│ APPS & AUTOMATIONS                       │
;╰──────────────────────────────────────────╯
LaunchCalculator(*) {
  ; Single Instance condition. Do not create a new process and used the last one created
  if WinExist("Calculator", "Calculator") {
    WinActivate
    WinShow
    return
  }
  else {
    Run "calc.exe"
    WinWait "Calculator"
    WinActivate
  }
}

LaunchTerminal(*) {
  Run "wt.exe --size 0,45 --window last new-tab --tabColor #367d55 --title (ツ)_/¯ --focus", , , &wt_pid
  Sleep 1000
  if WinExist("ahk_exe WindowsTerminal.exe") or WinExist("ahk_title Terminal") {
    WinActivate
    WinShow
  }
  return
}


ShowActionSplash(actionMessage, actionIcon := "") {
  ; This function displays a splash screen with a message in the center of the screen.
  ; It uses a GUI to show the message and positions it at the center of the active monitor.
  global arpeActionGUI, arpeGUIWidth, arpeGUIHeight

  ; If the GUI already exists, destroy it first
  if IsSet(arpeActionGUI) {
    arpeActionGUI.Destroy()
    arpeActionGUI := ""
  }
  arpeActionGUI := Gui("+AlwaysOnTop -Caption +ToolWindow")
  arpeActionGUI.BackColor := "White"
  arpeActionGUI.SetFont("s11", "Segoe UI")
  arpeActionGUI.AddText("w250 left cGreen", "Action in progress:")
  arpeActionGUI.SetFont("s11", "Segoe UI")
  arpeActionGUI.AddText("w250 left cGray", actionMessage)
  arpeActionGUI.Show("NoActivate AutoSize Center")
  ; Position center of active monitor
  thisMonitor := MonitorGetWorkArea(, &thisMonLeft, &thisMonTop, &thisMonRight, &thisMonBottom)
  arpeActionGUI.GetPos(&__, &__, &arpeGUIWidth, &arpeGUIHeight)
  arpeActionGUI.Move((thisMonRight - thisMonLeft - arpeGUIWidth) // 2, (thisMonBottom - thisMonTop - arpeGUIHeight) //
    2)
}

LaunchApp(appName, asAdmin := 0) {
  if (asAdmin = true) {
    splashMsg := "Starting " . appName . " (Elevated Priv)..."
  } else {
    splashMsg := "Starting " . appName . "..."
  }
  ShowActionSplash(splashMsg)
  ; The shell:AppsFolder is a special folder that contains an enumeration of all installed apps (per machine, per user, windows store, etc.)
  ; Note: Any shortcuts in the list will not have the same parameters as the original app, so we need to handle them separately.
  for app in ComObject("Shell.Application").NameSpace("shell:AppsFolder").Items {
    ; myApps.= app.Name ": " app.Path "`n"
    if (app.Name = appName) {
      ; NOT A BUG: But a limitation of using AutoHotkey 32-bit - you cannot retrieve the icon of a 64-bit application
      ; ╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
      ; │ Display all properties of the app (https://learn.microsoft.com/en-us/windows/win32/shell/folderitem)                                            │
      ; │ Any GUIDs displayed are Known Folders (https://learn.microsoft.com/en-us/windows/win32/shell/knownfolderid)                                        │
      ; │ MsgBox("App Name: " app.Name "`nApp Path: " app.Path "`nIsLink: " app.IsLink "`nName: " app.Name "`nSize: " app.Size "`nType: " app.Type, , 64) │
      ; ╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
      if (asAdmin = 0) {
        app.InvokeVerb("Open")
      } else {
        ; Debug: don't attempt the localized label. Show available verbs instead.
        app.InvokeVerb("Open new window")  ; commented out for debugging

        ; Debug: Show available verbs for the app
        verbs := ""
        try {
          for v in app.Verbs {
            name := ""
            verb := ""
            try
              name := v.Name
            catch Error as e
              name := ""
            try
              verb := v.Verb
            catch Error as e
              verb := ""
            if (name || verb) {
              verbs .= (name ? name : "(no name)") "    [" (verb ? verb : "no-verb") "]`n"
            } else {
              verbs .= "(unknown verb object)`n"
            }
          }
        } catch Error as e {
          verbs := "Error enumerating verbs: " e.Message
        }

        MsgBox("Available verbs for: " app.Name "`n`n" verbs, "Debug: App Verbs")
      }
    }
  }
  arpeActionGUI.Destroy()
}

GetKnownFolderPath(FolderGUID) {
  ; Ensure the GUID is wrapped in braces
  if !RegExMatch(FolderGUID, "^\{.+\}$") {
    FolderGUID := "{" FolderGUID "}"
  }
  ; Convert the GUID string to a format suitable for SHGetKnownFolderPath
  GUID := Buffer(16, 0)
  if DllCall("ole32\CLSIDFromString", "WStr", FolderGUID, "Ptr", GUID.Ptr) != 0 {
    MsgBox "Invalid GUID format: " FolderGUID, "Error", 48
    return "" ; Invalid GUID format
  }
  pPath := 0
  hr := DllCall("Shell32\SHGetKnownFolderPath", "Ptr", GUID.Ptr, "UInt", 0, "Ptr", 0, "Ptr*", &pPath)
  if hr != 0 || !pPath {
    MsgBox "Failed to get the path for " FolderGUID "`nHRESULT: " hr, "Error", 48
    return ""
  }
  path := StrGet(pPath, "UTF-16")
  DllCall("ole32\CoTaskMemFree", "Ptr", pPath)
  return path
}

; ; ╭──────────────────────────────────────────────────────────────────────────────────────────╮
; ; │ [LShift]+[RShift]+[n] to run Notepad                                                     │
; ; ╰──────────────────────────────────────────────────────────────────────────────────────────╯
; +n::
; {
;   ; [LShift]+[RShift]+[n] to run an elevated Notepad process
;   if GetKeyState("LShift", "P") && GetKeyState("RShift", "P") && GetKeyState("Ctrl", "P") {
;     Run "notepad"
;     return ; end this hotkey thread (was `exit` which terminates the script)
;   }

;   if GetKeyState("LShift", "P") && GetKeyState("RShift", "P") {
;     if WinExist("ahk_class Notepad") {
;       WinActivate
;       WinShow
;       return
;     }
;     else {
;       Run "notepad.exe"
;       ; WinActivate
;       return
;     }
;   }
;   else {
;     Send "N" ; This is to respond to [RShift}+[N]; otherwise, nothing will be sent
;   }
; }

; ╭──────────────────────────────────────────────────────────────────────────────────────────╮
; │ [RCtrl]x2 to run Calculator                                                               │
; ╰──────────────────────────────────────────────────────────────────────────────────────────╯
~RCtrl::
{
  ; Detects when a key has been double-pressed (similar to double-click). KeyWait is used to
  ; stop the keyboard's auto-repeat feature from creating an unwanted double-press when you
  ; hold down the RAlt key to modify another key. It does this by keeping the hotkey's
  ; thread running, which blocks the auto-repeats by relying upon #MaxThreadsPerHotkey being
  ; at its default setting of 1. For a more elaborate script that distinguishes between
  ; single, double and triple-presses, see SetTimer example #3.
  if (A_PriorHotkey != "~RCtrl" or A_TimeSincePriorHotkey > 400) {
    ; Too much time between presses, so this isn't a double-press.
    KeyWait "RCtrl"
    return
  }

  ; A double-press of the RAlt key has occurred.
  LaunchCalculator()
}

; ╭──────────────────────────────────────────────────────────────────────────────────────────╮
; │ [Ctrl]+[Alt]+[T] for Terminal                                                            │
; │ [Ctrl]+[Alt]+[Shift]+[T] for Terminal in Admin Mode                                      │
; ╰──────────────────────────────────────────────────────────────────────────────────────────╯
LAlt & t::
{
  ; [Ctrl]+[Alt/⌥]+[T] to run Terminal as Admin
  if GetKeyState("LShift", "P") && GetKeyState("Alt", "P") && GetKeyState("LCtrl", "P") {
    try {
      Run "*RunAs wt.exe -w 0 new-tab --title Terminal(Admin) --suppressApplicationTitle"
    } catch {
      ; user cancelled UAC or launch failed — swallow the error and return
      return
    }
    return   ; end this hotkey thread
  }

  if GetKeyState("LCtrl", "P") && GetKeyState("LAlt", "P") {
    LaunchTerminal()
  }
  else {
    Send "T"
  }
}