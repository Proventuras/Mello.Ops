#Requires AutoHotkey v2.0

; ╭════════════════════════════════════════════════════════════════════════════════════════╮
; ║  HOTKEYS-CORE.AHK                                                                      ║
; ║  Core, mandatory hotkeys that are usually exempt from suspend                          ║
; ╰════════════════════════════════════════════════════════════════════════════════════════╯

; Use Hotkey() with function objects so the Send runs when the hotkey fires.
; Create named function-object handlers first (some AHK versions/parsers
; reject inline anonymous lambdas passed directly to Hotkey()).
sendPgUpKey := () => Send("{Blind>^}{PgUp}")
sendPgDnKey := () => Send("{Blind>^}{PgDn}")
sendHomeKey := () => Send("{Blind>^}{Home}")
sendEndKey := () => Send("{Blind>^}{End}")

; ╭────────────────────────────────────────────────────────────────────────────────────────────╮
; │  Core Hotkeys - Always Exempt from SUSPEND                                                 │
; ╰────────────────────────────────────────────────────────────────────────────────────────────╯
#SuspendExempt
; [Ctrl]+[Alt/⌥]+[Win]+[S] (MacOS: ⌘+^+⌥+R) Suspend this script
^!#s:: {
  Suspend (-1)
  if (A_IsSuspended = true) {
    TraySetIcon trayico_suspend
    TraySetIcon , , true
  } else {
    TraySetIcon trayico_default
    TraySetIcon , , true
  }
}

; [Ctrl]+[Alt/⌥]+[Win]+[R] (MacOS: ⌘+^+⌥+R) Reload this script
^#!r:: {
  if WinActive
    ReloadAndReturn
}

; [Ctrl]+[Alt/⌥]+[Win]+[E] (MacOS: ⌘+^+⌥+E) to edit this script
^!#e:: {
  EditAndReturn
}

; [Ctrl]+[Alt/⌥]+[Win]+[F2] (MacOS: ⌘+^+⌥+F2) to open the AutoHotkey Help File
^!#F2:: {
  ShowHelp
}

; [Ctrl]+[Alt/⌥]+[Win]+[F1] (MacOS: ⌘+^+⌥+F1) to open this App's Help -> About dialog
^!#F1:: {
  ShowHelpAbout
}

; [Ctrl]+[Alt/⌥]+[Win]+[F12] (MacOS: ⌘+^+⌥+F12) to go to sleep mode
^!#F12:: {
  Run "rundll32.exe powrprof.dll,SetSuspendState 0,1,0"
}

; [Ctrl]+[Alt/⌥]+[Win]+[F] (MacOS: ⌘+^+⌥+F) to open this script's folder in File Explorer
^!#f:: {
  Run "explorer.exe " A_ScriptDir
}

; [Ctrl][Win][F] to open this script's folder in File Explorer
^#f:: {
  Run "explorer.exe " A_MyDocuments
}
#SuspendExempt False

; ╭────────────────────────────────────────────────────────────────────────────────────────────╮
; │ Hotkey declarations; these are not exempt from suspend                                     │
; ╰────────────────────────────────────────────────────────────────────────────────────────────╯
; For local use of standard TKL keyboard without dedicated PgUp, PgDn, Home, End keys
~RCtrl & Up:: Send("{Blind>^}{PgUp}")
~RCtrl & Down:: Send("{Blind>^}{PgDn}")
~RCtrl & Left:: Send("{Blind>^}{Home}")
~RCtrl & Right:: Send("{Blind>^}{End}")

#f:: {
  if IsRemoteSession() {
    ; Cmd+F -> Ctrl+F (Find)
    Send "^f"
  } else {
    ; Win+F (Windows Feedback) =Replace=> Open User's Home Folder
    Run "explorer.exe ~"
  } }

#l:: Send "^l"   ; Cmd+L -> Ctrl+L (Focus address bar) **NOT WORKING**

#w:: {
  if IsRemoteSession() {
    Send "^w"         ; Cmd+W -> Ctrl+W (Close tab/window)
  } }

#s:: {
  if IsRemoteSession() {
    Send "^s"
  } }


; ╭────────────────────────────────────────────────────────────────────────────────────────────╮
; │ Hotkeys that are disabled when a Remote Desktop session or Virtual Machine console is active │
; ╰────────────────────────────────────────────────────────────────────────────────────────────╯
#HotIf (WinActive("ahk_class TscShellContainerClass")) or (WinActive("ahk_class VMConnectWindowClass"))
; ╭──────────────────────────────────────────────────────────────────────────────────────────╮
; │ NOTE: The #HotIf Condition is designed to prevent layers of keyboard shortcuts in virtual  │
; │       desktop overlays, e.g. RDP Sessions, VM Console overlays, etc.                       │
; ╰──────────────────────────────────────────────────────────────────────────────────────────╯
; For use when using a Mac keyboard to control a remote Windows machine
~RAlt & Up:: Send "{Blind>!}{PgUp}"
~RAlt & Down:: Send "{Blind>!}{PgDn}"
~RAlt & Left:: Send "{Blind>!}{Home}"
~RAlt & Right:: Send "{Blind>!}{End}"
~RAlt & Backspace:: Send "{Blind>!}{Del}"


; ╭─────────────────────────────────────────────────────────────────────────╮
; │ Common MacOS Keyboard typos in RDP session                              │
; ╰─────────────────────────────────────────────────────────────────────────╯
; Remap common MacOS keyboard shortcuts to their Windows equivalents
; when in a Remote Desktop session.
#+p:: Send "^+p"  ; Cmd+Shift+P -> Ctrl+Shift+P (Command Palette)
#i:: Send "^i"    ; Cmd+I -> Ctrl+I (Italic)
#b:: Send "^b"    ; Cmd+B -> Ctrl+B (Bold)
#y:: Send "^y"    ; Cmd+Y -> Ctrl+Y (Redo)
; #c:: Send "^c"    ; Cmd+C -> Ctrl+C (Copy)
; #v:: Send "^v"    ; Cmd+V -> Ctrl+V (Paste)
; #x:: Send "^x"    ; Cmd+X -> Ctrl+X (Cut)
; #a:: Send "^a"    ; Cmd+A -> Ctrl+A (Select All)
; #z:: Send "^z"    ; Cmd+Z -> Ctrl+Z (Undo)

#HotIf ; Turn off context sensitivity