#Requires AutoHotkey v2.0

/*
╭──────────────────────────────────────────────────────────────╮
│ Mello.Ops - AutoHotkey Script                                │
│ Automations leveraging AutoHotkey for enhanced productivity  │
╰──────────────────────────────────────────────────────────────╯
*/

#SingleInstance Force
SendMode "Input"    ; Use default Windows response to built-in responses to keyboard shortcutsm, e.g. [Alt]+[<-]
SetTitleMatchMode 2 ; Default matching behavior for searches using WinTitle, e.g. WinWait
InstallKeybdHook  ; Install the keyboard hook to capture key events
; InstallMouseHook

/*
╭────────────────────────╮
│ GLOBAL SCOPE VARIABLES │
╰────────────────────────╯
*/
global __StartTime := A_TickCount
global __Uptime := 99999 ; Placeholder for uptime, will be updated later
global thisapp_name := "Mello.Ops"
global thisapp_version := "0.9.1_alpha (2024-06-17)"
global process_theme := ""
global app_ico := ".\media\icons\Mello.Ops.ico"
global toggle_sound_file_startrun := A_Windir "\Media\Windows Unlock.wav"
global toggle_sound_file_enabled := ".\media\sounds\01_enable.wav"
global toggle_sound_file_disabled := ".\media\sounds\01_disable.wav"
global sound_file_start := ".\media\sounds\start-13691.wav"
global sound_file_stop := ".\media\sounds\stop-13692.wav"
global regkey_sticky_keys := "HKEY_CURRENT_USER\Control Panel\Accessibility\StickyKeys"
global Aux_HotKeySupport := true
global Aux_HotStringSupport := true

; --- Splash Screen Modal ---
global app_splashGUI := Gui("+AlwaysOnTop +ToolWindow -Caption", "Mello.Ops Splash")
app_splashGUI.BackColor := "White"
app_splashGUI.SetFont("s14", "Segoe UI")
app_splashGUI.AddPicture("x20 y20 w48 h48 Icon1", app_ico)
app_splashGUI.SetFont("s16 bold", "Segoe UI")
app_splashGUI.AddText("x80 y20", "Mello.Ops")
app_splashGUI.SetFont("s9 norm", "Segoe UI")
app_splashGUI.AddText("x80 y50", "Version " thisapp_version)
app_splashGUI.Show("w300 h90 Center")
; --- End Splash Screen ---

/*
╭────────────────────────────────────╮
│ ** PERSONAL CUSTOMIZATIONS HERE ** │
╰────────────────────────────────────╯
*/
if !FileExist(".\custom\_custom_functions.ahk") {
  ; FileCreate ".\custom\_custom_functions.ahk"
  FileAppend "
  (
  ; ╭─────────────────────────────────────────────╮
  ; │ Custom Functions for Mello.Ops             │
  ; │ Add your personal functions and hotkeys here│
  ; ╰─────────────────────────────────────────────╯

  ; Example custom hotkey:
  ; ^!j::MsgBox('Custom hotkey Ctrl+Alt+J triggered!')

  )", ".\custom\_custom_functions.ahk"
  ; FileCopy ".\custom\_custom_functions.ahk.example", ".\custom\_custom_functions.ahk"
}
#Include ".\custom\_custom_functions.ahk"

/*
╭────────────────────────╮
│ LIBRARY INCLUDES       │
╰────────────────────────╯
*/
#Include <_traymenu>
#Include <_help_about>
#Include <app-automate>
#Include <hotkeys-core>
; #Include <hotstrings-core>  ; TODO: Split the hotstrings-aux into two files: hotstrings-core and hotstrings-aux
#Include <hotstrings-aux>
#Include <hotkeys-aux>
#include <arpeggios>
#include <winui-mgmt>
#Include <cursor-mgmt>
#Include %A_ScriptDir%\lib\WiseGui.ahk ; TODO: Remove this line when WiseGui is available
; #Include <_alerts>  ; TODO: Under construction


/*
╭────────────────────────╮
│ INITIALIZATION         │
╰────────────────────────╯
*/
SetWorkingDir(A_ScriptDir)
DisplayTrayMenu()

; Hide splash after tray menu is ready
app_splashGUI.Destroy()

/*
╭────────────────────────╮
│ FUNCTIONS              │
╰────────────────────────╯
*/
ReloadAndReturn(*)
{
  Reload
}

EditAndReturn(*)
{
  Edit
  Return
}

EndScript(*)
{
  ExitApp
}

; ╭─────────────────────────────────────────────────────────────╮
; │       KEY HOTKEY DEFINITIONS: CORE FUNCTIONALITY            │
; │   Not affected by ToggleAuxHotkeys and ToggleAuxHotstrings  │
; ├─────────────────────────────────────────────────────────────┤
; │  [Ctrl]+[Win]+[Alt]+[K]    Toggle Aux Hotkeys (DISABLED)    │
; │  [Ctrl]+[Win]+[Alt]+[S]    Toggle Aux Hotstrings (DISABLED) │
; │  [Ctrl]+[Win]+[Alt]+[R]    Reload this app                  │
; │  [Ctrl]+[Win]+[Alt]+[E]    Edit this AHK (default editor)   │
; │  [Ctrl]+[Win]+[Alt]+[F2]   AutoHotKey Help File             │
; │  [Ctrl]+[Win]+[Alt]+[F12]  Put system to Sleep              │
; │  [Win]+[F]                 Open the user's Documents folder │
; ╰─────────────────────────────────────────────────────────────╯

; [Ctrl]+[Alt]+[Win]+[K]: Toggle Aux Hotkeys
; ^#!k:: {
;   ToggleAuxHotkeys()
; }

; [Ctrl]+[Alt]+[Win]+[S]: Toggle Aux Hotstrings
; ^#!s:: {
;   ToggleAuxHotstrings()
; }

; [Ctrl]+[Alt]+[Win]+[R] to Reload this script
^#!r:: {
  ReloadAndReturn()
}

; [Ctrl]+[Alt]+[Win]+[E] to edit this script
^!#e:: {
  EditAndReturn()
}

; [Ctrl]+[Alt]+[Win]+[F2] to open the AutoHotkey Help File
^!#F2:: {
  ShowHelp()
}

; [Ctrl]+[Alt]+[Win]+[F1] to open this App's Help -> About dialog
^!#F1:: {
  ShowHelpAbout()
}

; [Ctrl]+[Alt]+[Win]+[F12] to go to sleep mode
^!#F12:: {
  Run "rundll32.exe powrprof.dll,SetSuspendState 0,1,0"
}

; [Ctrl]+[Alt]+[Win]+[F] to open this script's folder in File Explorer
^!#f:: {
  Run "explorer.exe " A_ScriptDir
}

; [Win]+[F] to open the File Explorer in the user's Documents folder
#f:: {
  Run "explorer.exe ~"
}
