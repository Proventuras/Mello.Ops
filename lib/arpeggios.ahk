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
KeyWaitAny(*)
{
  ; This function waits for a key to be pressed and returns the key name.
  ; It uses an InputHook to capture the keypress WITHIN a specific time frame (4 seconds).
  ; The key name is returned as a string.
  ih := InputHook("L1 T4 M")
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

  return ih.Input  ; Return the input string
}

ShowArpeggioSplash(message, icon := "none") {
  ; This function displays a splash screen with a message in the bottom right corner.
  ; It uses a GUI to show the message and positions it at the bottom right of the active monitor.
  ; The GUI will fade in and out, and it will not activate the window.
  global arpeGUI, arpeGUIWidth, arpeGUIHeight

  ; If the GUI already exists, destroy it first
  If IsSet(arpeGUI) {
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
; │  [CapsLock]+[o]. OPEN APPLICTATION Mode  │
; ├──────────────────────────────────────────┤
; │  [B] ✓ Beyond Compare 4                  │
; │  [C] ✓ Visual Studio Code                |
; │  [E] ✓ Epic Pen                          │
; │  [N] ✓ Notion                            │
; |  [O] ✓ Outlook                           │
; |  [T] ✓ Windows Terminal                  │
; |  [!] ✓ Windows Terminal (ADMIN)          │
; │  [w] ✓ Warp Terminal                     │
; ├──────────────────────────────────────────┤
; │  TODO: Possible Candidates               │
; │  [w] Terminal (WSL)                      │
; ╰──────────────────────────────────────────╯
CapsLock & o::
{
  KeyWait "CapsLock"
  OptionWindow := "AppModeOptions"

  AppModeOptionsString := (
    "!`t Windows Terminal (Admin)"
    "`nB`t Beyond Compare 4"
    "`nC`t VS Code"
    "`nE`t Epic Pen"
    "`nN`t Notion"
    "`nT`t Windows Terminal"
    "`nW`t Warp Terminal"
  )

  ShowArpeggioSplash(AppModeOptionsString)
  ; Begin the 4 second wait before fading out the GUI
  retKeyHook := KeyWaitAny()

  ; Fade Out
  AW_BLEND := 0x00080000, AW_HIDE := 0x00010000
  DllCall("user32.dll\AnimateWindow", "Ptr", arpeGUI.hwnd, "UInt", 250, "UInt", AW_BLEND | AW_HIDE)
  arpeGUI.Destroy()

  ; If the user did not press a key, exit the function
  if (retKeyHook = "") {
    return
  }
  If (retKeyHook = "b") {
    ShowActionSplash("Starting Beyond Compare 4...")
    LaunchApp("Beyond Compare 4")
  }
  Else If (retKeyHook = "c") {
    ShowActionSplash("Starting Visual Studio Code...")
    LaunchApp("Visual Studio Code")
  }
  Else If (retKeyHook = "e") {
    ShowActionSplash("Starting Epic Pen...")
    LaunchApp("Epic Pen")
  }
  Else If (retKeyHook = "n") {
    ShowActionSplash("Starting Notion...")
    LaunchApp("Notion")
  }
  ; Else If (retKeyHook = "o") {
  ;   ShowActionSplash("Starting Outlook...")
  ;   Send "^!+#o"
  ; }
  ; Else If (retKeyHook = "p") {
  ;   WiseGui(OptionWindow)
  ;   SplashGUI("Starting MS PowerPoint...", 2000)
  ;   Send "^!+#p"
  ; }
  ; Else If (retKeyHook = "w") {
  ;   WiseGui(OptionWindow)
  ;   SplashGUI("Starting MS Word...", 2000)
  ;   Send "^!+#w"
  ; }
  ; Else If (retKeyHook = "x") {
  ;   WiseGui(OptionWindow)
  ;   SplashGUI("Starting MS Excel...", 2000)
  ;   Send "^!+#x"
  ; }
  Else If (retKeyHook = "t") {
    ShowActionSplash("Starting Windows Terminal...")
    LaunchTerminal()
  }
  Else If (retKeyHook = "w") {
    ShowActionSplash("Starting Warp Terminal...")
    LaunchApp("Warp")
  }
  Else If (retKeyHook = "!") {
    ShowActionSplash("Starting Windows Terminal (Admin)...")
    Run "*RunAs wt.exe -w 0 new-tab --title Terminal(Admin) --suppressApplicationTitle"
  }
  Else {
    ; MsgBox("Invalid key pressed: " retKeyHook)
  }
}

; ╭──────────────────────────────────────────╮
; │  [CapsLock]+[C]. Clipboard Utilities     │
; ├──────────────────────────────────────────┤
; │  [c] Open selected into Google           |
; │  [d] Open selected into ChatGPT          │
; │  [g] Open selected into NotebookLM       │
; |  [i] Open selected into Google AI Studio │
; |  [p] portal.azure.com                    │
; |  [y] youtube.com                         │
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
; │  [c] chat.openai.com                     |
; │  [d] dev.azure.com                       │
; │  [g] github.com                          │
; |  [i] icons8.com                          │
; |  [p] portal.azure.com                    │
; |  [y] youtube.com                         │
; ├──────────────────────────────────────────┤
; │  [?] Perplexity                          │
; │  [?] mail.google.com                     │
; │  [?]                                     │
; │  [?]                                     │
; ╰──────────────────────────────────────────╯
