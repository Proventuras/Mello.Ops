#Requires AutoHotkey v2.0

/*╭─────────────────────────────────────────────────────────╮
  │  [CapsLock] ARPEGGIOS                                   │
  │  Hit the [CapsLock]+[?] To enter the MODE, then         │
  │  follow it with another key to complete the ARPEGGIO.   │
  ├─────────────────────────────────────────────────────────┤
  │  MODES:                                                 │
  │  [B] BROWSE WEB     Open your favorite sites            │
  │  [O] OPEN APP       Open Application Mode               │
  │  [P] POWERTOYS      Shortcuts to PowerToys utils        │
  │  [C] CLIP UTILs     Cliboard Utilities                  │
  │  [U] UTILITIES      Utilities                           │
╰─────────────────────────────────────────────────────────╯*/
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

; ╭────────────────────────────────────────────────╮
; │  Helper Function: SplashGUI(Message, TimeOut)  │
; ╰────────────────────────────────────────────────╯
SplashGUI(message, timeout) {
  WiseGui("MelloAppSplash"
    , "Margins:       3,3,0,4"
    ; , "Theme:,,," . LoadPicture(A_AhkPath, "Icon1", &ImageType)
    , "Theme:,,," LoadPicture(app_ico, "Icon1", &ImageType)
    , "FontMain:     S14, Arial"
    , "MainText:     " message
    ; , "FontSub:      S14, Consolas"
    ; , "SubText:" . A_AhkVersion
    , "SubAlign:     +1"
    ; , "Show:         Fade@400ms"
    , "Hide:         Fade@1000ms"
    , "Timer:        2000"
  )
}

; ╭──────────────────────────────────────────╮
; │  [CapsLock]+[o]. OPEN APPLICTATION Mode  │
; ├──────────────────────────────────────────┤
; │  [C] ✓ Visual Studio Code                |
; │  [E] ✓ Epic Pen                          │
; │  [N] ✓ Notion                            │
; |  [O] ✓ Outlook                           │
; |  [P] ✓ PowerPoint                        │
; |  [T] ✓ Windows Terminal                  │
; |  [!] ✓ Windows Terminal (ADMIN)          │
; |  [W] ✓ Word                              │
; |  [X] ✓ Excel                             │
; ├──────────────────────────────────────────┤
; │  TODO: Possible Candidates               │
; │  [b] Bitwarden                           │
; │  [w] Terminal (WSL)                      │
; ╰──────────────────────────────────────────╯
CapsLock & o::
{
  KeyWait "CapsLock"
  OptionWindow := "AppModeOptions"

  AppModeOptionsString := (
    "[!] Windows Terminal (Admin)`n"
    "[C] VS Code`n"
    "[E] Epic Pen`n"
    "[N] Notion`n"
    "[O] Outlook`n"
    "[P] PowerPoint`n"
    "[T] Windows Terminal`n"
    "[W] Word`n"
    "[X] Excel"
  )
  ; Display the options for the user
  WiseGui(OptionWindow
    , "Margins:       3,3,0,4"
    , "Theme:,,," LoadPicture(app_ico, "Icon1", &ImageType)
    , "FontMain:     S12 Bold, Arial"
    , "MainText:     Press a key to start an app:"
    , "MainAlign:    0"
    , "FontSub:      S11 Norm, Segoe UI"
    , "SubText:    " AppModeOptionsString
    , "SubAlign:     -1"
    , "Timer:        3500"
  )

  retKeyHook := KeyWaitAny()

  If (retKeyHook = "c") {
    WiseGui(OptionWindow)
    SplashGUI("Starting VS Code...", 2000)
    LaunchApp("Visual Studio Code")
    ; Run "cmd.exe /c code.cmd"
  }
  Else If (retKeyHook = "e") {
    WiseGui(OptionWindow)
    SplashGUI("Starting Epic Pen...", 2000)
    Run EnvGet("ProgramFiles(x86)") "\Epic Pen\EpicPen.exe"
  }
  Else If (retKeyHook = "n") {
    WiseGui(OptionWindow)
    SplashGUI("Starting Notion...", 2000)
    LaunchApp("Notion")
    ; LaunchNotion()
  }
  Else If (retKeyHook = "o") {
    WiseGui(OptionWindow)
    SplashGUI("Starting MS Outlook...", 2000)
    Send "^!+#o"
  }
  Else If (retKeyHook = "p") {
    WiseGui(OptionWindow)
    SplashGUI("Starting MS PowerPoint...", 2000)
    Send "^!+#p"
  }
  Else If (retKeyHook = "w") {
    WiseGui(OptionWindow)
    SplashGUI("Starting MS Word...", 2000)
    Send "^!+#w"
  }
  Else If (retKeyHook = "x") {
    WiseGui(OptionWindow)
    SplashGUI("Starting MS Excel...", 2000)
    Send "^!+#x"
  }
  Else If (retKeyHook = "t") {
    WiseGui(OptionWindow)
    SplashGUI("Starting Terminal...", 2000)
    LaunchTerminal()
  }
  Else If (retKeyHook = "!") {
    SplashGUI("Starting Terminal (Privileged)...", 2000)
    Run "*RunAs wt.exe -w 0 new-tab --title Terminal(Admin) --suppressApplicationTitle"
  }
  Else {
    MsgBox("Invalid key pressed: " retKeyHook)
    WiseGui(OptionWindow)
    ;Send "O" ; This is to respond to [LShift}+[o]; otherwise, nothing will be sent
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
