#Requires AutoHotkey v2.0

; ╭──────────────────────────────────────────────────────────────╮
; │ Mello.Ops - AutoHotkey Script                                │
; │ Automations leveraging AutoHotkey for enhanced productivity  │
; ╰──────────────────────────────────────────────────────────────╯

#SingleInstance Force
SendMode "Input"    ; Use default Windows response to built-in responses to keyboard shortcutsm, e.g. [Alt/⌥]+[<-]
SetTitleMatchMode 2 ; Default matching behavior for searches using WinTitle, e.g. WinWait
InstallKeybdHook  ; Install the keyboard hook to capture key events

; ╭──────────────────────────────────────────────────────────────╮
; │ GLOBAL SCOPE VARIABLES                                       │
; ╰──────────────────────────────────────────────────────────────╯
global __StartTime := A_TickCount
global __Uptime := 99999 ; Placeholder for uptime, will be updated later
global thisapp_name := "Mello.Ops"
global thisapp_version := "0.9.2 (2025-12-09)"
global process_theme := ""
global media_path := ".\media"
global icons_path := media_path . "\icons\"
global sounds_path := media_path . "\sounds\"
global app_ico := icons_path . thisapp_name . ".ico"
; global toggle_sound_file_startrun := A_Windir "\Media\Windows Unlock.wav"
global toggle_sound_file_startrun := sounds_path . "start_app.wav"
global toggle_sound_file_enabled := sounds_path . "01_enable.wav"
global toggle_sound_file_disabled := sounds_path . "01_disable.wav"
global sound_file_start := sounds_path . "start_app.wav"
global sound_file_stop := sounds_path . "stop-13692.wav"
global regkey_sticky_keys := "HKEY_CURRENT_USER\Control Panel\Accessibility\StickyKeys"
global IsMacKeyboard := false

; ╭──────────────────────────────────────────────────────────────╮
; │ HANDLERS                                                     │
; ╰──────────────────────────────────────────────────────────────╯
OnExit ExitAppFunction

; ╭──────────────────────────────────────────────────────────────╮
; │ Display Splash Screen (Modal)                                │
; ╰──────────────────────────────────────────────────────────────╯
global app_splashGUI := Gui("+AlwaysOnTop +ToolWindow -Caption", thisapp_name " Splash")
app_splashGUI.BackColor := "White"
app_splashGUI.SetFont("s14", "Segoe UI")
app_splashGUI.AddPicture("x20 y20 w48 h48 Icon1", app_ico)
app_splashGUI.SetFont("s16 bold", "Segoe UI")
app_splashGUI.AddText("x80 y20", thisapp_name)
app_splashGUI.SetFont("s9 norm", "Segoe UI")
app_splashGUI.AddText("x80 y50", "Version " thisapp_version)
app_splashGUI.Show("w300 h90 Center")
; --- End Splash Screen ---


; ╭──────────────────────────────────────────────────────────────╮
; │ LIBRARY INCLUDES                                             │
; ╰──────────────────────────────────────────────────────────────╯
#Include ".\custom\_custom_functions.ahk"
#Include <traymenu>
#Include <help_about>
#Include <app-automate>
#include <winui-mgmt>
#include <arpeggios>
#Include <cursor-mgmt>
#Include <hotkeys-core>
#Include <hotstrings-mgmt>
#Include <app-dyn>

; ╭──────────────────────────────────────────────────────────────╮
; │ ** PERSONAL CUSTOMIZATIONS HERE **                           │
; ╰──────────────────────────────────────────────────────────────╯
if !FileExist(".\custom\_custom_functions.ahk") {
  ; FileCreate ".\custom\_custom_functions.ahk"
  FileAppend "
  (
  ; ╭─────────────────────────────────────────────╮
  ; │ Custom Functions for Mello.Ops              │
  ; │ Add your personal functions and hotkeys here│
  ; ╰─────────────────────────────────────────────╯

  ; Example custom hotkey:
  ; ^!j::MsgBox('Custom hotkey Ctrl+Alt+J triggered!')

  )",
    ".\custom\_custom_functions.ahk"
  ; FileCopy ".\custom\_custom_functions.ahk.example", ".\custom\_custom_functions.ahk"
}
DisplayTrayMenu()
SoundPlay toggle_sound_file_startrun
; Hide splash after tray menu is ready
app_splashGUI.Destroy()
; End of the auto-execute section. The script is now persistent and will wait for hotkeys.

; ╭──────────────────────────────────────────────────────────────╮
; │ FUNCTIONS                                                    │
; ╰──────────────────────────────────────────────────────────────╯
IsRemoteSession() {
  ; Returns non-zero if running in an RDP/remote session
  return DllCall("user32.dll\GetSystemMetrics", "Int", 0x1000)
}

ReloadAndReturn(*) {
  Reload  ; INFO: Reload creates a new PID
}

EditAndReturn(*) {
  Edit
  return
}

EndScript(*) {
  ExitApp
}

ExitAppFunction(ExitReason, ExitCode)
{
  ; Cleanup or undo any systems settings set by Mello.Ops

  ; Example 1: Reset mouse cursor size
  ; DllCall("SystemParametersInfo", "UInt", SPI_SETCURSORS, "UInt", 0, "Ptr", origCursorSize, "UInt", SPIF_UPDATEINIFILE | SPIF_SENDCHANGE) ; Update the cursor to apply changes , "Ptr", 0, "UInt", SPIF_UPDATEINIFILE | SPIF_SENDCHANGE) ; Update the cursor to apply changes

  Switch ExitReason, false
  {
    Case "Logoff":  ; User logged off
      ; Result := MsgBox("Are you sure you want to exit?", , 4)
      ; if Result = "No" {
      ;   return 1  ; Callbacks must return non-zero to avoid exit.
      ; }
    Case "Shutdown":  ; Computer is shutting down
      ; Result := MsgBox("Are you sure you want to exit?", , 4)
      ; if Result = "No" {
      ;   return 1  ; Callbacks must return non-zero to avoid exit.
      ; }
    Case "Close":     ; Received WM_CLOSE or WM_QUIT message
    Case "Error":     ; Runtime error
    Case "Menu":      ; Standard tray menu exit
    Case "Exit":      ; User-initiated exit (Exit or ExitApp)
    Case "Reload":    ; Only applies when the Reload function is called within the script
    Case "Single":    ; User tried to start another instance; Only applies when the SingleInstance function; doesn't apply on its own Reload()
      Result := MsgBox("Loading a new instance?", , 4)
      if Result = "No" {
        return 1  ; Callbacks must return non-zero to avoid exit.
      }
    Default:          ; Only if it was able to catch an exception
  }
}


