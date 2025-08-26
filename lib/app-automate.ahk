#Requires AutoHotkey v2.0
; ╭════════════════════════════════════════════════════════════════════════════════════════════════════════════════─╮
; ║  APP-AUTOMATE.AHK                                                                                               ║
; ║    - Manages the location and dimensions of the Active Window using performant DllCalls.                        ║
; ║    - Refactored for maximum readability, maintainability, and performance.                                      ║
; ╰═════════════════════════════════════════════════════════════════════════════════════════════════════════════════╯
;╭──────────────────────────────────────────╮
;│ APPS & AUTOMATIONS                       │
;╰──────────────────────────────────────────╯
LaunchCalculator(*) 
{
  ; Single Instance condition. Do not create a new process and used the last one created
  If WinExist("Calculator", "Calculator")
  {
    WinActivate
    WinShow
    Return
  }
  Else
  {
    Run "calc.exe"
    WinWait "Calculator"
    WinActivate
  }
}

LaunchTerminal(*)
{
  If WinExist("ahk_exe WindowsTerminal.exe")
  {
    WinActivate
    WinShow
    Return
  }
  Else
  {
    Run "wt.exe -w 0 new-tab --title (ツ)_/¯{Terminal} --suppressApplicationTitle", , , &wt_pid
    Sleep 1000
    If WinExist("ahk_exe WindowsTerminal.exe") or WinExist("ahk_title Terminal")
    {
      WinActivate
      WinShow
    }
    Return
  }
}

ShowActionSplash(actionMessage, actionIcon := "") {
  ; This function displays a splash screen with a message in the center of the screen.
  ; It uses a GUI to show the message and positions it at the center of the active monitor.
  global arpeActionGUI, arpeGUIWidth, arpeGUIHeight

  ; If the GUI already exists, destroy it first
  If  IsSet(arpeActionGUI) {
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
  arpeActionGUI.Move((thisMonRight - thisMonLeft - arpeGUIWidth) // 2, (thisMonBottom - thisMonTop - arpeGUIHeight) // 2)
}

LaunchApp(appName, asAdmin := 0) {
  ; The shell:AppsFolder is a special folder that contains an enumeration of all installed apps (per machine, per user, windows store, etc.)
  ; Note: Any shortcuts in the list will not have the same parameters as the original app, so we need to handle them separately.
  For app in ComObject("Shell.Application").NameSpace("shell:AppsFolder").Items
  {
    ; myApps.= app.Name ": " app.Path "`n"
    If (app.Name = appName)
    {
      ; NOT A BUG: But a limitation of using AutoHotkey 32-bit - you cannot retrieve the icon of a 64-bit application
      ; ╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
      ; │ Display all properties of the app (https://learn.microsoft.com/en-us/windows/win32/shell/folderitem)                                            │
      ; │ Any GUIDs displayed are Known Folders (https://learn.microsoft.com/en-us/windows/win32/shell/knownfolderid)                                        │
      ; │ MsgBox("App Name: " app.Name "`nApp Path: " app.Path "`nIsLink: " app.IsLink "`nName: " app.Name "`nSize: " app.Size "`nType: " app.Type, , 64) │
      ; ╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
      if (asAdmin = 0) {
        app.InvokeVerb("Open")
      } else {
        ; If the app is a link, we need to run it as admin
        app.InvokeVerb("Run as administrator")

      }
    }
  }
    arpeActionGUI.Destroy()
  ; MsgBox("Available Apps:`n" myApps, "Available Apps", 64)
}

GetKnownFolderPath(FolderGUID) {
  ; Ensure the GUID is wrapped in braces
  if !RegExMatch(FolderGUID, "^\{.+\}$"){
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