#Requires AutoHotkey v2.0

; ╭════════════════════════════════════════════════════════════════════════════════════════════════════════════════─╮
; ║  _TrayMenu.AHK                                                                                                  ║
; ║    - Manages most things related to the tray menu's appearance and behavior.                                    ║
; ╰═════════════════════════════════════════════════════════════════════════════════════════════════════════════════╯

; ╭───────────╮
; │ VARIABLES │
; ╰───────────╯
; Notification Tray Icons
trayico_default := icons_path . thisapp_name . ".ico"
trayico_osxkeybd := icons_path . thisapp_name . "-AK.ico"
trayico_rdsh := icons_path . thisapp_name . "-RDP.ico"
trayico_rdsh_osxkeybd := icons_path . thisapp_name . "-RAK.ico"
trayico_suspend := icons_path . thisapp_name . "-suspended.ico"

; Menu Items
trayitem_app_ref := "About " . thisapp_name . "`t[Ctrl]+[⊞]+[Alt/⌥]+[F1]"
trayitem_app_ref_ico := trayico_default
trayitem_reload := "&Reload Script`t[Ctrl]+[⊞]+[Alt/⌥]+[R]"
trayitem_reload_ico := icons_path . "reload.ico"
trayitem_debug := "AutoHotkey Native Tools"
trayitem_debug_ico := icons_path . "debug.ico"
trayitem_ahkhelp := "AutoHotkey Help`t[Ctrl]+[⊞]+[Alt/⌥]+[F2]"
trayitem_ahkhelp_ico := icons_path . "help.ico"
trayitem_exit := "E&xit " . thisapp_name
trayitem_exit_ico := icons_path . "stop.ico"
trayitem_edit := "E&dit Script`t[Ctrl]+[⊞]+[Alt/⌥]+[E]"
trayitem_edit_ico := icons_path . "edit.ico"
trayitem_runatstartup := "Launch at Startup"
trayitem_usingmackeybd := "Using Mac Keyboard Layout"
trayitem_openappdir := "Open script &folder`t[Ctrl]+[⊞]+[Alt/⌥]+[F]"
trayitem_openappdir_ico := icons_path . "icons8-code-folder-32.ico"
traymenu_icon_checked := icons_path . "checked.ico"
traymenu_icon_unchecked := icons_path . "unchecked.ico"
; trayitem_toggle_hstrings := "&Text Expansions"            ; `t[Ctrl]+[⊞]+[Alt/⌥]+[S]"
; trayitem_toggle_hstrings_ico := traymenu_icon_checked
; trayitem_toggle_hkeys := "&Keyboard Shortcuts"                  ; `t[Ctrl]+[⊞]+[Alt/⌥]+[K]"
; trayitem_toggle_hkeys_ico := traymenu_icon_checked

this_script_shortcut := A_Startup . "\" . thisapp_name . ".lnk"
if (FileExist(this_script_shortcut)) {
  trayitem_runatstartup_ico := traymenu_icon_checked
}
else {
  trayitem_runatstartup_ico := traymenu_icon_unchecked
}

; ╭───────────────────────────────────────────────────────────────────╮
; │  Build the Tray menu                                              │
; ╰───────────────────────────────────────────────────────────────────╯
DisplayTrayMenu() {

  ; Set the Tray icon
  SetNotificationIcon(IsRemoteSession(), IsMacKeyboard)

  ; Set the Tray icon tooltip
  global Tray := A_TrayMenu ; For convenience.
  __LoadDuration := A_TickCount - __StartTime
  __LoadDuration := Round(__LoadDuration / 1000, 2) ; Convert to seconds and round to 2 decimal places
  IconTipString := "
    (
      Mello.Ops Shortcuts
      Startup Duration: `s
    )" __LoadDuration " ms
    (
      `nScript: `s
    )" A_ScriptFullPath
  A_IconTip := IconTipString

  ; Delete the standard items. Not Required unless replacing
  Tray.Delete()

  ; Define the menu items
  Tray.Add(trayitem_app_ref, ShowHelpAbout)
  Tray.SetIcon(trayitem_app_ref, trayitem_app_ref_ico)

  Tray.Add() ; separator

  ; Tray.Add(trayitem_toggle_hstrings, ToggleAuxHotstrings)
  ; Tray.SetIcon(trayitem_toggle_hstrings, trayitem_toggle_hstrings_ico)

  ; Tray.Add(trayitem_toggle_hkeys, ToggleAuxHotkeys)
  ; Tray.SetIcon(trayitem_toggle_hkeys, trayitem_toggle_hkeys_ico)

  Tray.Add(trayitem_runatstartup, ToggleRunAtStartup)
  Tray.SetIcon(trayitem_runatstartup, trayitem_runatstartup_ico)

  Tray.Add(trayitem_usingmackeybd, ToggleMacKeyboard)
  Tray.SetIcon(trayitem_usingmackeybd, traymenu_icon_unchecked)

  Tray.Add() ; separator

  ; Mello.Ops Script-Related Actions
  AHKActionsMenu := Menu()
  Tray.Add("Mello.Ops Script-Related Actions", AHKActionsMenu)

  AHKActionsMenu.Add(trayitem_reload, ReloadAndReturn)
  AHKActionsMenu.SetIcon(trayitem_reload, trayitem_reload_ico)

  AHKActionsMenu.Add(trayitem_openappdir, OpenScriptDir)
  AHKActionsMenu.SetIcon(trayitem_openappdir, trayitem_openappdir_ico)

  AHKActionsMenu.Add(trayitem_edit, EditAndReturn)
  AHKActionsMenu.SetIcon(trayitem_edit, trayitem_edit_ico)

  ; AutoHotkey Native Tools
  AhkNativeMenu := Menu()
  Tray.Add("AutoHotkey Native Tools", AhkNativeMenu)
  AhkNativeMenu.Add("AutoHotkey WindowSpy", ShowAHKSpy)
  AhkNativeMenu.Add(trayitem_ahkhelp, ShowHelp)
  AhkNativeMenu.Add("Key & Mouse Button History", ShowListLines)
  AhkNativeMenu.Add("ListHotKeys", ListSimpleHotkeys)
  AhkNativeMenu.Add("Coming: KeyHistory", ShowListLines)
  AhkNativeMenu.Disable("Coming: KeyHistory")
  AhkNativeMenu.Add("Coming: ListVars", ShowListLines)
  AhkNativeMenu.Disable("Coming: ListVars")

  ; Options
  OptionsMenu := Menu()
  Tray.Add("Options", OptionsMenu)

  MouseMenu := Menu()
  OptionsMenu.Add("Mouse Cursor Actions", MouseMenu)
  MouseMenu.Add("Increase Mouse Cursor Size`t [Ctrl] ⊞ ]", IncCursorSize)
  MouseMenu.Add("Decrease Mouse Cursor Size`t [Ctrl] ⊞ [", DecCursorSize)
  MouseMenu.Add("Increase Mouse Cursor Speed", IncMouseSpeed)
  MouseMenu.Disable("Increase Mouse Cursor Speed")
  MouseMenu.Add("Decrease Mouse Cursor Speed", DecMouseSpeed)
  MouseMenu.Disable("Decrease Mouse Cursor Speed")

  OptionsMenu.Add("Toggle Light/Dark Theme", ToggleTheme)
  OptionsMenu.Disable("Toggle Light/Dark Theme")
  OptionsMenu.Add("Toggle Show/Auto-Hide Taskbar", ToggleTaskbar)
  OptionsMenu.Disable("Toggle Show/Auto-Hide Taskbar")
  OptionsMenu.Add("Toggle Show/Hide Desktop Icons", ToggleDesktopIcons)
  OptionsMenu.Disable("Toggle Show/Hide Desktop Icons")

  Tray.Add() ; separator

  ; Custom Tools
  CustomMenu := Menu()
  Tray.Add("Custom Tools", CustomMenu)
  CustomMenu.Add("Custom Notes", ShowCustomNotes)
  CustomMenu.Disable("Custom Notes")
  CustomMenu.Add("Focus Window Highlighter", ToggleWindowHighlighter)
  CustomMenu.Disable("Focus Window Highlighter")
  CustomMenu.Add("OverFlow Notifier", ToggleOverflowNotifier)
  CustomMenu.Disable("OverFlow Notifier")
  CustomMenu.Add("Chime", ToggleChime)
  CustomMenu.Disable("Chime")

  Tray.Add() ; separator

  Tray.Add(trayitem_exit, EndScript)
  Tray.SetIcon(trayitem_exit, trayitem_exit_ico)

  ; Set the default menu item for double-clicking the tray icon
  Tray.Default := trayitem_app_ref
}

; ToggleAuxHotstrings(*)
; {
;   ; ╭─────────────────────────────────────────────────────────────────────╮
;   ; │  Enable or Disable Auxillary hotkeys defined in AUX_HOTSTRINGS.AHK  │
;   ; ╰─────────────────────────────────────────────────────────────────────╯
;   global Aux_HotStringSupport := !Aux_HotStringSupport
;   if (Aux_HotStringSupport = true) {
;     IndicateToggle("Auxillary HotStrings", "hotkeys", true, true, true)
;     trayitem_toggle_hstrings_ico := traymenu_icon_checked
;   } else {
;     IndicateToggle("Auxillary HotStrings", "hotkeys", false, true, true)
;     trayitem_toggle_hstrings_ico := traymenu_icon_unchecked
;   }

;   Tray.SetIcon(trayitem_toggle_hstrings, trayitem_toggle_hstrings_ico)
; }

ToggleRunAtStartup(*)
{
  ; Build a valid shortcut path in the Startup folder
  this_script_shortcut := A_Startup . "\" . thisapp_name . ".lnk"

  if (FileExist(this_script_shortcut)) {
    FileDelete(this_script_shortcut)
    trayitem_runatstartup_ico := traymenu_icon_unchecked
  }
  else {
    ; Ensure trayico_default resolves to an absolute path
    iconFile := trayico_default
    if (SubStr(iconFile, 1, 2) = ".\") {
      iconFile := A_ScriptDir . "\" . SubStr(iconFile, 3)
    } else {
      ; Detect absolute paths without using RegExMatch (drive letter or UNC)
      driveColon := (StrLen(iconFile) >= 3) ? (SubStr(iconFile, 2, 1) = ":") : false
      thirdIsSlash := (StrLen(iconFile) >= 3) ? (SubStr(iconFile, 3, 1) = "\" || SubStr(iconFile, 3, 1) = "/") : false
      isUNC := (StrLen(iconFile) >= 2) ? (SubStr(iconFile, 1, 2) = "\\") : false
      if !(driveColon && thirdIsSlash) && !isUNC {
        ; Not absolute -> assume relative to script dir
        iconFile := A_ScriptDir . "\" . iconFile
      }
    }

    ; Create the shortcut:
    ; FileCreateShortcut(Target, ShortcutFile [, WorkingDir, Parameters, Description, IconFile, IconNumber, RunState])
    FileCreateShortcut(A_AhkPath            ; Target executable (AutoHotkey)
      , this_script_shortcut  ; Shortcut destination
      , A_ScriptDir           ; Working directory
      , thisapp_name . ".ahk" ; Parameters
      , A_ScriptFullPath      ; Description (use script full path)
      , iconFile              ; Icon file (absolute path)
      , 0)                    ; Icon index

    trayitem_runatstartup_ico := traymenu_icon_checked
  }

  Tray.SetIcon(trayitem_runatstartup, trayitem_runatstartup_ico)
}

ToggleMacKeyboard(*)
{
  global IsMacKeyboard := !IsMacKeyboard
  SetNotificationIcon(IsRemoteSession(), IsMacKeyboard)
}


ShowListLines(*)
{
  ; ╭──────────────────────────────────────────────────────────────────────╮
  ; │ ShowListLines                                                        │
  ; ╰──────────────────────────────────────────────────────────────────────╯
  ListLines
}

ListSimpleHotkeys(*)
{
  ; ╭──────────────────────────────────────────────────────────────────────╮
  ; │ ListSimpleHotkeys                                                    │
  ; ╰──────────────────────────────────────────────────────────────────────╯
  ListHotkeys
}

OpenScriptDir(*)
{
  ; ╭──────────────────────────────────────────────────────────────────────╮
  ; │ OpenScriptDir                                                        │
  ; ╰──────────────────────────────────────────────────────────────────────╯
  Run A_ScriptDir
}


ShowHelp(*)
{
  ; ╭──────────────────────────────────────────────────────────────────────╮
  ; │ ShowHelp                                                             │
  ; ╰──────────────────────────────────────────────────────────────────────╯
  ; Open the regular help file
  ; Determine AutoHotkey's location:
  if A_AhkPath
    SplitPath A_AhkPath, , &ahk_dir
  else if FileExist("..\..\AutoHotkey.chm")
    ahk_dir := "..\.."
  else if FileExist(A_ProgramFiles "\AutoHotkey\AutoHotkey.chm")
    ahk_dir := A_ProgramFiles "\AutoHotkey"
  else {
    MsgBox "Could not find the AutoHotkey folder."
    return
  }
  Run ahk_dir "\AutoHotkey.chm"
  ; Run A_ProgramFiles "\AutoHotkey\v2\AutoHotkey.chm"

  return
}


ShowAHKSpy(*)
{
  ; ╭──────────────────────────────────────────────────────────────────────╮
  ; │ ShowAHKSpy                                                           │
  ; ╰──────────────────────────────────────────────────────────────────────╯
  ; Open the regular help file
  ; Determine AutoHotkey's location:
  if A_AhkPath
    SplitPath A_AhkPath, , &ahk_dir
  else {
    MsgBox "Could not find the AutoHotkey folder."
    return
  }
  ; Run the WindowsSpy script
  ; MsgBox "Running WindowsSpy.ahk from: " ahk_dir
  Run A_AhkPath " " ahk_dir "\WindowSpy.ahk"
  ; Run A_ProgramFiles "\AutoHotkey\v2\AutoHotkey.chm"
  
  return
}

SetNotificationIcon(isRDSH := false, isOSXKeybd := false)
{
  ; ╭───────────────────────────────────────────────────────────────────────────────╮
  ; │ SetNotificationIcon(isRDSH, isOSXKeybd)                                       │                        
  ; │   - isRDSH [opt, bool, default=false]: Is running in RDP/Remote Session       │
  ; │   - isOSXKeybd [opt, bool, default=false]: Using Mac keybd to control Windows │
  ; ├───────────────────────────────────────────────────────────────────────────────┤
  ; │ Return Value:  Path to current ICO file                                       │
  ; ╰───────────────────────────────────────────────────────────────────────────────╯
  if (isRDSH && isOSXKeybd) {
    current_tray_icon := trayico_rdsh_osxkeybd
  } else if (isRDSH && !isOSXKeybd) {
    current_tray_icon := trayico_rdsh
  } else if (!isRDSH && isOSXKeybd) {
    current_tray_icon := trayico_osxkeybd
  } else {
    current_tray_icon := trayico_default
  }
  TraySetIcon current_tray_icon
  TraySetIcon , , true
  return current_tray_icon
}

; Placeholder functions for future menu items
IncCursorSize(*)
{
  SetCursorSize(+1)
}
DecCursorSize(*)
{
  SetCursorSize(-1)
}
IncMouseSpeed(*)
{ }
DecMouseSpeed(*)
{ }
ToggleTheme(*)
{ }
ToggleTaskbar(*)
{ }
ToggleDesktopIcons(*)
{ }
ShowCustomNotes(*)
{ }
ToggleWindowHighlighter(*)
{ }
ToggleOverflowNotifier(*)
{ }
ToggleChime(*)
{ }