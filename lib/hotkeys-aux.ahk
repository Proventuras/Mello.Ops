#Requires AutoHotkey v2.0

; ╭─────────────────────────────────────────────────────────────╮
; │  Helper Function: Wrapper for MsgBox for undefined HotClix  │
; ╰─────────────────────────────────────────────────────────────╯
ModalMsg(message_string := "No Action Assigned", app_in_use := "No App Defined", app_icon := 0, timeout_in_seconds := 3) {
  ; Dictionary for the hotkeys
  Switch A_ThisHotkey
  {
    case "F13": trigger_key := "⌨️  [F13] `n🖱️  [Onboard_Cycle]     `n#️⃣  [Num_###?]"
    case "F14": trigger_key := "⌨️  [F14] `n🖱️  [G + Scroll_Left]   `n#️⃣  [Num_###?]"
    case "F15": trigger_key := "⌨️  [F15] `n🖱️  [G + Middle_Click]  `n#️⃣  [Num_8]"
    case "F16": trigger_key := "⌨️  [F16] `n🖱️  [G + Scroll_Right]  `n#️⃣  [Num_6]"
    case "F17": trigger_key := "⌨️  [F17] `n🖱️  [Top_Forward]       `n#️⃣  [Num_Lock]"
    case "F18": trigger_key := "⌨️  [F18] `n🖱️  [G + Top_Forward]   `n#️⃣  [Num_8]"
    case "F19": trigger_key := "⌨️  [F19] `n🖱️  [Top_Back]          `n#️⃣  [Num_7]"
    case "F20": trigger_key := "⌨️  [F20] `n🖱️  [G + Top_Back]      `n#️⃣  [Num_###?]"
    case "F21": trigger_key := "⌨️  [F21] `n🖱️  [G + Side_Forward]  `n#️⃣  [Num_4]"
      ; case "F22": trigger_key := "⌨️  [F22] `n🖱️  [G + OnBoard_Cycle] `n#️⃣  [Num_2]"
    case "F23": trigger_key := "⌨️  [F23] `n🖱️  [G + Btn_Right]     `n#️⃣  [Num_9]"
    case "F24": trigger_key := "⌨️  [F24] `n🖱️  [G + Side_Back]     `n#️⃣  [Num_1]"
  }

  if message_string = ""
    message_string := "NO ACTION ASSIGNED"

  ; This function is used to display a message box with the specified message and app in use.
  theMsg := "App:  " . app_in_use . "`n`n" . trigger_key . "`n`n" . message_string
  theIcon := 64 ; ℹ️ icon
  theModality := 262144 ; Modal
  theTimeout := "T" . timeout_in_seconds
  theOptions := Format("{1} {2}", theTimeout, (theIcon + theModality))

  static guiMsg := Gui("+AlwaysOnTop -Caption +ToolWindow", "Info")
  guiMsg.Destroy() ; Ensure previous instance is closed

  guiMsg := Gui("+AlwaysOnTop -Caption +ToolWindow", "Info")
  guiMsg.BackColor := "White"
  guiMsg.SetFont("s12", "Segoe UI")

  ; Application logo (emoji) on top
  guiMsg.Add("Picture",)

  ; Application in Use
  guiMsg.Add("Text", "Center xm y+10 h30", app_in_use)

  ; Main message
  guiMsg.Add("Text", "xm y+10", trigger_key)
  guiMsg.Add("Text", "xm y+10", message_string)

  ; Center on screen
  guiMsg.Show("AutoSize Center")

  ; Apply rounded corners using SetRegion after showing the GUI
  guiMsg.GetClientPos(, , &w, &h)
  WinSetRegion("0-0 w" . w . " h" . h . " r16-16", guiMsg.Hwnd)

  SetTimer () => guiMsg.Destroy(), -timeout_in_seconds * 1000
}

; #HotIf (Aux_HotKeySupport = true)
; {
  ; ╭══════════════════════╮
  ; │ Higher Function Keys │
  ; ╰══════════════════════╯
  CapsLock & F3::F23
  CapsLock & F4::F24
  CapsLock & F5::F15
  CapsLock & F6::F16
  CapsLock & F7::F17
  CapsLock & F8::F18
  CapsLock & F9::F19
  CapsLock & F10::F20
  CapsLock & F11::F21
  CapsLock & F12::F22

  ; Notion-specific hotkeys
  #HotIf WinActive("ahk_exe Notion.exe")
  app_notion := "✏️ Notion"
  F13:: Send "^+{h}"                           ; Open current page in full screen
  F14:: Send "{Home}{Enter}>{Space}"              ; Convert to a Toggle text block
  F15:: Send "^+L"                                ; Toggle between light and dark mode
  F16:: ModalMsg "", app_notion, 2
  F17:: Send "{Home}{Enter}{# 2}{Space}>{Space}"  ; Convert to a Toggle Heading 2
  F18:: Send "^+L"                              ; Toggle between light and dark mode
  F19:: Send "{Home}{Enter}{# 3}{Space}>{Space}"  ; Convert to a Toggle Heading 3
  F20:: ModalMsg "", app_notion, 2
  F21:: ModalMsg "", app_notion, 2
  ; F22:: ModalMsg "", app_notion, 2
  F23:: Send "^{/}"                   ; Open Format Menu
  #HotIf

  ; MS Word-specific hotkeys
  #HotIf WinActive("ahk_exe WINWORD.exe")
  app_msword := "📝 MS Word"
  F13:: Click
  F14:: ModalMsg "", app_msword, 2
  F15:: ModalMsg "", app_msword, 2
  F16:: ModalMsg "", app_msword, 2
  F17:: ModalMsg "", app_msword, 2
  F18:: ModalMsg "", app_msword, 2
  F19:: ModalMsg "", app_msword, 2
  F20:: ModalMsg "", app_msword, 2   ; /block equation
  F21:: ModalMsg "", app_msword, 2   ; /blockequation
  ; F22:: ModalMsg "", app_msword, 2   ; /turntoggleheading2
  F23:: ModalMsg "", app_msword, 2   ; /turntoggleheading1
  #HotIf

  ; GMail-specific hotkeys
  #HotIf (WinActive(" - Gmail and ") OR WinActive(" - Gmail - Google Chrome"))
  
  app_gmail := "📫 GMail"
  F13:: Click
  F14:: Send "k"                      ; Navigate to previous message
  F15:: ModalMsg "", app_gmail, 2
  F16:: Send "j"                      ; Navigate to next message
  F17:: Send "+u"                     ; Mark as unread
  F18:: Send "{z}"                    ; Undo last action
  F19:: Send "+i"                     ; Mark as read
  F20:: ModalMsg "", app_gmail, 2
  F21:: ModalMsg "", app_gmail, 2
  ; F22:: ModalMsg "", app_gmail, 2
  F23:: Send "{#}"   ; Delete the current email
  #HotIf

  ; ╭─────────────────────╮
  ; │  VS Code: CODE.EXE  │
  ; ╰─────────────────────╯
  #HotIf WinActive("ahk_exe Code.exe")
  app_vscode := "💻 VS Code"
  F13:: Click
  F14:: Send "^["                         ; Increase Indent
  F15:: ModalMsg "", app_vscode
  F16:: Send "^]"                         ; Decrease Indent
  F17:: ModalMsg "", app_vscode
  F18:: ModalMsg "", app_vscode
  F19:: ModalMsg "", app_vscode
  F20:: ModalMsg "", app_vscode
  F21:: ModalMsg "", app_vscode
  ; F22:: ModalMsg "", app_vscode
  F23:: ModalMsg "", app_vscode
  #HotIf

  /*
  ╭──────────────────────────────────────────────────────────────────────╮
  │  YouTube (Broswer): Browser Window title [ - YouTube and ]           │
  │  ⚡ These functions only apply in the playback page, NOT the YouTube  │
  │    home/search/browse pages, which uses the mouse actions for the    │
  │    browser (or default).                                             │
  ╰──────────────────────────────────────────────────────────────────────╯ */
  #HotIf WinActive(" - YouTube and ")
  app_yt := "🎬 YouTube"
  F13:: Click
  ^F14:: Send "{<}"                     ; Switch to the previous tab
  F15:: ModalMsg "", app_yt
  ^F16:: Send "{>}"                    ; Switch to the previous tab
  F18:: ModalMsg "", app_yt
  F17:: Send "{>}"                     ; Speed up the playback
  F19:: Send "{<}"                     ; Slow down the playback
  F21:: ModalMsg "", app_yt
  F20:: ModalMsg "", app_yt
  ; F22:: ModalMsg "", app_yt
  F23:: Send "^{w}"                    ; Close the current tab
  ^WheelUp:: Send "{Volume_Up 1}"      ; Increase the volume
  ^WheelDown:: Send "{Volume_Down 1}"  ; Decrease the volume
  WheelRight:: Send "{l}"              ; Fast forward 10s
  WheelLeft:: Send "{j}"               ; Rewind 10s
  +WheelRight:: Send "^{Right}"        ; Seek to next chapter
  +WheelLeft:: Send "^{Left}"          ; Seek to previous chapter
  #HotIf

  /*
  ╭────────────────────────────────────╮
  │  Microsoft "New" Outlook: OLK.EXE  │
  ╰────────────────────────────────────╯ */
  #HotIf WinActive("ahk_exe olk.exe")
  app_msolk_new := "📬 NEW Outlook"
  F13:: Send "^q"                                       ; Mark as Read
  F14:: {
    if WinActive(, "Calendar -") {
      Send "^!{Left}"                                   ; If in Calendar view - Previous week (This was changed from Alt+Up to Ctrl+Alt+Left)
    } else {
      Send "^,"                                         ; If in Mail view - Previous Message
    }
  }
  F15:: ModalMsg "", app_msolk_new
  F16:: {
    if WinActive(, "Calendar -") {
      Send "^!{Right}"                                  ; If in Calendar view - Next week (This was changed from Alt+Down to Ctrl+Alt+Right)
    } else {
      Send "^."                                         ; If in Mail view - Next Message
    }
  }
  F18:: Send "^t"                                       ; Post a reply
  F17:: Send "^{1}"                                     ; Switch to Mail view
  F19:: Send "^{2}"                                     ; Switch to Calendar view
  F21:: ModalMsg "", app_msolk_new
  F20:: Send "^U"                                       ; Mark as Unread
  ; F22:: ModalMsg "", app_msolk_new
  F23:: Send "{Del}"                                    ; Delete Current Email
  F24:: ModalMsg "", app_msolk_new
  #HotIf

  /*
  ╭────────────────────────────────────────────╮
  │  Microsoft "Classic" Outlook: OUTLOOK.EXE  │
  ╰────────────────────────────────────────────╯ */
  #HotIf WinActive("ahk_exe OUTLOOK.exe")
  app_msolk := "📧 CLASSIC Outlook"
  F13:: Send "^q"                                       ; Mark as Read
  F14:: {
    if WinActive("Calendar -") {
      Send "!{Up}"                                    ; If in Calendar view - Previous week
    } else {
      Send "^,"                                       ; If in Mail view - Previous Message
    }
  }
  F15:: ModalMsg "", app_msolk
  F16:: {
    if WinActive("Calendar -") {
      Send "!{Down}"                                  ; If in Calendar view - Next week
    } else {
      Send "^."                                       ; If in Mail view - Next Message
    }
  }
  F18:: Send "^+r"                                      ; Post a reply to all
  F17:: Send "^{1}"                                     ; Switch to Mail view
  F19:: Send "^{2}"                                     ; Switch to Calendar view
  F21:: ModalMsg "", app_msolk
  F20:: Send "^U"                                       ; Mark as Unread
  ; F22:: ModalMsg "", app_msolk
  F23:: Send "{Del}"                                    ; Delete Current Email
  F24:: ModalMsg "", app_msolk
  #HotIf

  /*
  ╭────────────────────────────────────╮
  │  Microsoft Excel: EXCEL.EXE        │
  ╰────────────────────────────────────╯ */
  #HotIf WinActive("ahk_exe EXCEL.exe")
  app_msexcel := "📊 MS Excel"
  F13:: ModalMsg "", app_msexcel
  F14:: Send "^{PgUp}"                                 ; Previous Worksheet
  F15:: ModalMsg "", app_msexcel
  F16:: Send "^{PgDn}"                                 ; Next Worksheet
  F18:: {
    Send "^!{v}"                                 ; Paste the clipboard's format only
    Send "{t}"
    Send "{Enter}"
  }
  F17:: Send "^+{v}"                                    ; Paste as plain textt
  F19:: Send "^{c}"                                     ; Copy
  F20:: ModalMsg "", app_msexcel
  F21:: ModalMsg "", app_msexcel
  ; F22:: ModalMsg "", app_msexcel
  F23:: ModalMsg "", app_msexcel
  F24:: ModalMsg "", app_msexcel
  NumpadSub:: Send "^{y}"                               ; Redo
  NumpadAdd:: Send "^{z}"                               ; Undo
  #HotIf

  /*
  ╭────────────────────────────────────╮
  │  Microsoft Teams: MS-TEAMS.EXE     │
  ╰────────────────────────────────────╯ */
  #HotIf WinActive("ahk_exe ms-teams.exe")
  app_msteams := "💻 MS Teams"
  F13:: ModalMsg "", app_msteams
  F14:: Send "^{PgUp}"                                 ; Previous Worksheet
  F15:: ModalMsg "", app_msteams
  F16:: Send "^{PgDn}"                                 ; Next Worksheet
  F18:: {
    Send "^!{v}"                                 ; Paste the clipboard's format only
    Send "{t}"
    Send "{Enter}"
  }
  F17:: Send "^{2}"                                     ; Chat View
  F19:: Send "^{4}"                                     ; Calendar View
  F20:: Send "^{3}"                                     ; Teams View
  F21:: ModalMsg "", app_msteams
  ; F22:: ModalMsg "", app_msteams
  F23:: ModalMsg "", app_msteams
  F24:: ModalMsg "", app_msteams
  NumpadSub:: Send "^{y}"                               ; Redo
  NumpadAdd:: Send "^{z}"                               ; Undo
  #HotIf

  /*
  ╭──────────────────────────────╮
  │  Microsoft Edge: MSEDGE.EXE  │
  ╰──────────────────────────────╯ */
  #HotIf WinActive("ahk_exe msedge.exe")
  app_msedge := "🧭 MS Edge"
  F13:: Send "^+{v}"                                    ; Ctrl+Shift+V to Paste as plain text
  F14:: Send "^+{Tab}"                                  ; Ctrl+Shift+Tab to switch to the previous tab
  F15:: Send "^+{u}"                                    ; Ctrl+Shift+U to Read Out Loud
  F16:: Send "^{Tab}"                                   ; Ctrl+Tab to switch to the next tab
  F18:: ModalMsg "", app_msedge
  F17:: Send "{Home}"                                   ; "{Home}" to go to the top of the page
  F19:: Send "{End}"                                    ; "{End}" to go to the bottom of the page
  F20:: ModalMsg "", app_msedge
  F21:: ModalMsg "", app_msedge
  ; F22:: ModalMsg "", app_msedge
  F23:: Send "^{w}"                                     ; Ctrl+W to close the current tab

  #HotIf

  /*
  ╭════════════════════════════════════════════════╮
  │ EVERYTHING ELSE: Default Mouse Button Hotkeys  │
  ╰════════════════════════════════════════════════╯ */
  F13:: Click
  F14:: Send "^+{Tab}"                                  ; Ctrl+Shift+Tab
  F15:: ModalMsg "", ""
  F16:: Send "^{Tab}"                                   ; Ctrl+Tab
  F17:: Send "#{Tab}"                                   ; Win+Tab
  F18:: ModalMsg "", ""
  F19:: ModalMsg "", ""
  F20:: ModalMsg "", ""
  F21:: ModalMsg "", ""
  ; F22:: ModalMsg "", ""
  F23:: Send "^{w}"                                     ; Ctrl+W
  F24:: ModalMsg "", ""

  +F19:: ModalMsg "No Definition Assigned", "Default"
