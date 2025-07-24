#Requires Autohotkey v2

/*
  ╭────────────────────────────────────────────────────────────────────╮
  │ About...Dialog Box                                                 │
  │ The dialog box the appears when you select "About FLOW Effortless" │
  ├────────────────────────────────────────────────────────────────────┤
  │                                                                    │
  ╰────────────────────────────────────────────────────────────────────╯
*/
ShowHelpAbout(*) {
  static aboutDlg := ""
  dlgWidth := 760
  dlgHeight := 560

  ; If dialog exists and is visible, bring it to front and return
  try {
    ; aboutDlg.Show("w" dlgWidth " h" dlgHeight)
    aboutDlg.Restore()
    return
  } catch Any {
    ; If dialog does not exist, create it
    aboutDlg := ShowAboutDialog()
    aboutDlg.Show("w" dlgWidth " h" dlgHeight)
  }

  aboutDlg.OnEvent("Escape", (*) => aboutDlg.Destroy())
  aboutDlg.OnEvent("Close", (*) => aboutDlg.Destroy())
  ; aboutDlg.OnEvent("Size", (dlg, *) => (
  ;   mainTab.Move("w" . (dlg.ClientPos.W - 16) . " h" . (dlg.ClientPos.H - 80)),
  ;   aboutDlg["StatusBar"].Move("w" . dlg.ClientPos.W)
  ; ))
  
  ; Prevent attempts handle the "Size" event to ignore resizing from WinMove
  aboutDlg.OnEvent("Size", (*) => aboutDlg.Show("w" dlgWidth " h" dlgHeight))
}

ShowAboutDialog(*) {
  ; Detect the active private working memory usage of this process
  pid := DllCall("GetCurrentProcessId")
  ; Open process with query info rights
  hProcess := DllCall("OpenProcess", "UInt", 0x1000, "Int", false, "UInt", pid, "Ptr")
  if hProcess {
    PROCESS_MEMORY_COUNTERS := Buffer(40, 0)
    NumPut("UInt", 40, PROCESS_MEMORY_COUNTERS, 0) ; cb
    if DllCall("psapi\GetProcessMemoryInfo", "Ptr", hProcess, "Ptr", PROCESS_MEMORY_COUNTERS.Ptr, "UInt", 40) {
      ; For 32-bit AHK, PROCESS_MEMORY_COUNTERS.PrivateWorkingSetSize is at offset 32 (DWORD)
      ; This is
      workingSetSize := NumGet(PROCESS_MEMORY_COUNTERS, 32, "UInt")
      memMB := Round(workingSetSize / 1024 / 1024, 2)
    } else {
      memMB := "??"
    }
    DllCall("CloseHandle", "Ptr", hProcess)
  } else {
    memMB := "?"
  }

  ; Calculate Uptime
  __Uptime := A_TickCount - __StartTime
  __days := Floor(__Uptime / 86400000)
  __hours := Floor(Mod(__Uptime, 86400000) / 3600000)
  __minutes := Floor(Mod(__Uptime, 3600000) / 60000)
  __seconds := Floor(Mod(__Uptime, 60000) / 1000)
  UptimeString := __days " Days " __hours " Hrs " __minutes " Mins " __seconds " Secs"

  ; Dialog Construction
  aboutDlg := Gui()
  aboutDlg.SetFont("q5 s11", "Segoe UI")
  aboutDlg.Opt("-MinimizeBox -MaximizeBox +AlwaysOnTop")

  ; First Line with link to docs
  aboutDlg.Add("Link", "x9 y12 h23",
    "All items below are frequently used features. Visit the <a href=`"https://github.com/voltaire-toledo/Mello.Ops/tree/main/docs`">Official Documentation</a> for a more comprehensive list."
  )

  ; Status Bar
  aboutDlg.Add("StatusBar", "x0 y540 w750 h30 vStatusBar", "  Hit the [Esc] key to close this window.")

  ; Tab Control
  mainTab := aboutDlg.Add("Tab3", "x8 y42 w748 h520",
    ["About      ",
      "Hotkeys         ",
      "Hotstrings      ",
      "Arpeggios       ",
      "Higher F-Keys   ",
      "Other Options   "])

  ; Tab 1 - About
  mainTab.UseTab(1)
  ; Logo and Title, version number, and license
  aboutDlg.Add("Picture", "x16 y74 w48 h48", A_ScriptDir "\media\icons\Mello.Ops.ico")
  ; aboutDlg.SetFont("c3e3d32", "Segoe UI")
  aboutDlg.SetFont("c039314 Bold s21", "Segoe UI")
  aboutDlg.Add("Text", "x72 y74 w470 h50", "Mello.Ops")
  aboutDlg.SetFont("c353881 q5 s10", "Segoe UI")
  aboutDlg.Add("Text", "x72 y120 w300 h23", "Version: " thisapp_version)
  aboutDlg.Add("Text", "x372 y120 w300 h23", "Private Memory Usage: " memMB " MB")
  aboutDlg.Add("Text", "x72 y140 w600 h23", "Licensed under the MIT License")
  aboutDlg.Add("Text", "x372 y140 w600 h23", "Uptime: " UptimeString)

  ; Tagline
  aboutDlg.Add("GroupBox", "x72 y232 w500 h56", "")
  aboutDlg.SetFont("Bold Italic s14", "Segoe UI")
  aboutDlg.Add("Text", "x80 y250 w400 h23 ", "Chill. Flow. Repeat.")
  
  ; Horizontal Line
  ; aboutDlg.Add("menu", "x16 y200 w732 h1 c353881")
  
  ; Credit Section and Links to other resources
  aboutDlg.SetFont("c039314 Bold q5 s11", "Segoe UI")
  aboutDlg.Add("Text", "x72 y405 w600 h23", "Credits and Resources")
  aboutDlg.SetFont("c000000 Norm q5 s10", "Segoe UI")
  aboutDlg.Add("Link", "x72 y430 w600 h23",
    "AutoHotkey (version " A_AhkVersion ") is available at <a href=`"https://www.autohotkey.com`">autohotkey.com</a>")
  aboutDlg.Add("Link", "x72 y450 w600 h23", "Icons by <a href=`"https://icons8.com`">icons8.com</a>")
  aboutDlg.Add("Link", "x72 y470 w600 h23",
    "<a href=`"https://www.autohotkey.com/boards/viewtopic.php?f=83&t=94044`">WiseGUI.ahk library</a> by <a href=`"https://www.autohotkey.com/boards/memberlist.php?mode=viewprofile&u=54&sid=f3bac845536fc1eace03994a9e73273e`">SKAN</a>")
  aboutDlg.Add("Link", "x72 y490 w300 h23",
    "<a href=`"https://github.com/FuPeiJiang/VD.ahk/tree/v2_port`">VD.ahk library</a> by <a href=`"https://github.com/FuPeiJiang`">FuPeiJiang</a>")
  ; aboutDlg.Add("Link", "x72 y270 w300 h23",
  ; "<a href=`"https://github.com/Ciantic/VirtualDesktopAccessor`">VirtualDesktopAccessor</a> by <a href=`"https://github.com/Ciantic`">Ciantic</a>")

  ; Tab 2 - Hotkeys
  mainTab.UseTab(2)
  ; aboutDlg.SetFont("norm s11", "Segoe UI")
  ; aboutDlg.Add("Text", "x16 y78 w690 h26", "Hotkeys")
  aboutDlg.SetFont("norm s11", "Segoe UI")
  aboutDlg.Add("Text", "x16 y74 w705 h23", "Hotkeys are synonymous to keyboard shortcuts. Go ahead and try them out!")
  ; aboutDlg.Add("Text", "x16 y120 w720 h23", "You can also add your own hotkeys in the script file, or use the auxiliary hotkeys feature to create custom hotkeys on the fly.")
  ; Add ListView for Hotkeys
  ; aboutDlg.SetFont("c353881 Norm q5 s11", "Segoe UI")
  lv_corehkeys := aboutDlg.Add("ListView", "r16 w732 -LV0x10 -Multi NoSort c353881", ["Action", "Hotkey", "Description"])
  lv_corehkeys.Opt("+Report") ; +Sort")
  ; Set the column widths
  
  ; Example hotkeys - replace/add as needed for your project
  lv_corehkeys.Opt("-Redraw")
  lv_corehkeys.Add(, "Reload and Restart " thisapp_name, "[Ctrl] + [⊞] + [Alt] + [R] ", "Reload and restart " thisapp_name)
  lv_corehkeys.Add(, "AutoHotkey Help", "[Ctrl] + [⊞] + [Alt] + [F2]`t", "Open the AutoHotkey help docs")
  lv_corehkeys.Add(, "Sleep", "[Ctrl] + [⊞] + [Alt] + [F12]`t", "Put this system to sleep")
  lv_corehkeys.Add(, thisapp_name " Help", "[Ctrl] + [⊞] + [Alt] + [F1]`t", "Display this dialog")
  lv_corehkeys.Add(, "Open the user's folder", "[⊞] + [F]`t", "Open the user's directory in File Explorer")
  
  lv_corehkeys.Add(, "", "", "")
  lv_corehkeys.Add(, "**Window Management**", "", "")
  lv_corehkeys.Add(, "Edit this script", "[Ctrl] + [⊞] + [Alt] + [E]`t", "Open the main " thisapp_name " script (default editor)")
  lv_corehkeys.Add(, "Open the " thisapp_name " folder", "[Ctrl] + [⊞] + [Alt] + [F]`t", "Open the " thisapp_name " folder in File Explorer")
  lv_corehkeys.Add(, "Windows Terminal", "[Ctrl] + [Alt] + [T]`t", "Open or focus the Windows Terminal window")
  lv_corehkeys.Add(, "Windows Terminal (Elevated)", "[Ctrl] + [Shift] + [Alt] + [T]`t", "Open an elevated Windows Terminal instance")
  lv_corehkeys.Add(, "Open Calculator", "2 × [Right_Ctrl]`t", "Open or focus the Calculator app")
  lv_corehkeys.Add(, "Resize Window to 70%", "[CapsLock] + [/]`t", "Resize the active window to 70% of the screen size.")
  lv_corehkeys.Add(, "Decrease Window Size", "[CapsLock] + [LBracket]`t", "Decrease active window size by 5%.")
  lv_corehkeys.Add(, "Increase Window Size", "[CapsLock] + [RBracket]`t", "Increase active window size by 5%.")
  lv_corehkeys.Add(, "Move Window Up", "[CapsLock] + [↑]`t", "Move the active window up.")
  lv_corehkeys.Add(, "Move Window Down", "[CapsLock] + [↓]`t", "Move the active window down.")
  lv_corehkeys.Add(, "Move Window Left", "[CapsLock] + [←]`t", "Move the active window left.")
  lv_corehkeys.Add(, "Move Window Right", "[CapsLock] + [→]`t", "Move the active window right.")
  lv_corehkeys.Add(, "Expand Window Vertically", "[CapsLock] + [Ctrl] + [↑]`t", "Expand the active window vertically.")
  lv_corehkeys.Add(, "Shrink Window Vertically", "[CapsLock] + [Ctrl] + [↓]`t", "Shrink the active window vertically.")
  lv_corehkeys.Add(, "Expand Window Horizontally", "[CapsLock] + [Ctrl] + [→]`t", "Expand the active window horizontally.")
  lv_corehkeys.Add(, "Shrink Window Horizontally", "[CapsLock] + [Ctrl] + [←]`t", "Shrink the active window horizontally.")
  lv_corehkeys.ModifyCol() ; Auto-size the first column
  lv_corehkeys.ModifyCol(2) ; Auto-size the second column
  lv_corehkeys.ModifyCol(3)
  lv_corehkeys.Opt("+Redraw")

  ; Tab 3 - Hotstrings
  mainTab.UseTab(3)
  ; aboutDlg.SetFont("Bold s10", "Segoe UI")
  ; aboutDlg.Add("Text", "x16 y70 w690 h30", "Hotstrings")
  aboutDlg.SetFont("c000000 Norm q5 s11", "Segoe UI")
  aboutDlg.Add("Text", "x16 y74 w705 h54", "Hotstrings are basically aliases or string replacements. Just type the hotsring followed by a trigger key (like [Space] or [Enter]) and it will be replaced with the corresponding text.")

  ; --- Radio Buttons and Dynamic ListViews ---
  ; GroupBox for visual clarity (optional)
  aboutDlg.SetFont("norm s10", "Segoe UI")
  aboutDlg.Add("GroupBox", "x16 y120 w732 h50", "Hotstring Groups")

  ; Radio Buttons (horizontal)
  hs_rb_ansi := aboutDlg.Add("Radio", "x32 y140 w90 h23 vhs_rb_ansi", "ANSI")
  hs_rb_kaomoji := aboutDlg.Add("Radio", "x120 y140 w90 h23 vhs_rb_kaomoji", "Kaomoji")
  hs_rb_emoji := aboutDlg.Add("Radio", "x220 y140 w90 h23 vhs_rb_emoji", "Emojis")
  hs_rb_boxes := aboutDlg.Add("Radio", "x320 y140 w100 h23 vhs_rb_boxes", "Tables `& Boxes")
  hs_rb_custom := aboutDlg.Add("Radio", "x460 y140 w90 h23 vhs_rb_custom", "Custom")

  hs_rb_ansi.Value := true ; Default selection
  aboutDlg.SetFont("c000000 Norm q5 s11", "Segoe UI")
  aboutDlg.Add("Text", "x16 y175 w732 h54 vhs_rb_text", "Aux Hotstrings include optional expansions and modifiers for advanced use.")

  ; ListViews for each category (stacked, only one visible at a time)

  ; ANSI/ASCII Alt Codes
  aboutDlg.SetFont("c353881 Norm q5 s11", "Segoe UI")
  hs_lv_ansi := aboutDlg.Add("ListView", "x16 y205 w732 r12 vhs_lv_ansi", ["Hotstring", "Replacement", "Comments"])
  hs_lv_ansi.Opt("+Report") ; +Sort")
  hs_lv_ansi.Opt("-Redraw")
  hs_lv_ansi.Add(, "`!bullet", "•", "Standard paragraph bullet")
  hs_lv_ansi.Add(, "`!degree", "°", "Degree character")
  hs_lv_ansi.Add(, "`!smiley", "☺️", "")
  hs_lv_ansi.Add(, "`!sun", "☼", "")
  hs_lv_ansi.Add(, "`!multiply", "×", "Math symbol")
  hs_lv_ansi.Add(, "`!divide", "÷", "Math symbol")
  hs_lv_ansi.Add(, "`!registered", "®", "")
  hs_lv_ansi.Add(, "`!copyright", "©", "")
  hs_lv_ansi.Add(, "`!trademark", "™", "")
  hs_lv_ansi.Add(, "`!uparrow", "↑", "")
  hs_lv_ansi.Add(, "`!downarrow", "↓", "")
  hs_lv_ansi.Add(, "`!rightarrow", "→", "")
  hs_lv_ansi.Add(, "`!leftarrow", "←", "")
  hs_lv_ansi.Add(, "`!updownarrow", "↕", "")
  hs_lv_ansi.Add(, "`!leftrightarrow", "↔", "")
  hs_lv_ansi.Add(, "`!upleftarrow", "↖", "")
  hs_lv_ansi.Add(, "`!uprightarrow", "↗", "")
  hs_lv_ansi.Add(, "`!downleftarrow", "↙", "")
  hs_lv_ansi.Add(, "`!downrightarrow   ", "↘", "")
  hs_lv_ansi.Add(, "`!tricolon", "⁝", "")
  hs_lv_ansi.Add(, "`!fahrenheit", "℉", "")
  hs_lv_ansi.Add(, "`!windows", "⊞", "Math symbol; also used as a Windows key")
  hs_lv_ansi.Add(, "`!checkansi", "✓", "ANSI version of checkmark")
  hs_lv_ansi.Add(, "`!capslock", "⇪", "")
  hs_lv_ansi.Add(, "`!backspace", "⌫", "")
  hs_lv_ansi.Add(, "`!enter", "↵", "")
  hs_lv_ansi.Add(, "`!escape", "⎋", "")
  hs_lv_ansi.Add(, "`!tab", "⇥", "")
  hs_lv_ansi.Add(, "`!space", "␣", "")
  hs_lv_ansi.Add(, "`!delete", "⌦", "")
  hs_lv_ansi.Add(, "`!insert", "⎀", "")
  hs_lv_ansi.ModifyCol() ; Auto-size the first column
  hs_lv_ansi.ModifyCol(2, 100) ; Auto-size the second column
  hs_lv_ansi.ModifyCol(3, 100)
  hs_lv_ansi.Opt("+Redraw")

  ; Japanese Emoticons (Kaomoji)  aboutDlg.SetFont("c2c6934 Norm q5 s11", "Segoe UI")
  aboutDlg.SetFont("c353881 Norm q5 s11", "Segoe UI")
  hs_lv_kaomoji := aboutDlg.Add("ListView", "x16 y205 w732 r12 vhs_lv_kaomoji", ["Hotstring", "Replacement", "Comments"])
  hs_lv_kaomoji.Opt("+Report")
  hs_lv_kaomoji.Opt("-Redraw")
  hs_lv_kaomoji.Add(, "`!idk", "¯\\(°_o)/¯", "")
  hs_lv_kaomoji.Add(, "`!shrug", "¯\\\_(ツ)_/¯", "")
  hs_lv_kaomoji.Add(, "`!ohshit", "( º﹃º )", "")
  hs_lv_kaomoji.Add(, "`!tableflip   ", "(ノಠ益ಠ)ノ彡┻━┻", "")
  hs_lv_kaomoji.Add(, "`!fuckoff", "୧༼ಠ益ಠ╭∩╮༽", "")
  hs_lv_kaomoji.Add(, "`!fuckyou", "┌П┐(ಠ_ಠ)", "")
  hs_lv_kaomoji.ModifyCol(1) ; Auto-size the first column
  hs_lv_kaomoji.ModifyCol(2) ; Auto-size the second column
  hs_lv_kaomoji.ModifyCol(3, 100)
  hs_lv_kaomoji.Opt("+Redraw")


  ; Emojis/
  aboutDlg.SetFont("c353881 Norm q5 s11", "Segoe UI")
  hs_lv_emoji := aboutDlg.Add("ListView", "x16 y205 w732 r12 vhs_lv_emoji", ["Hotstring", "Replacement", "Comments"])
  hs_lv_emoji.Opt("+Report")
  hs_lv_emoji.Opt("-Redraw")
  hs_lv_emoji.Add(, "`!smile", "😀", "Emoji")
  hs_lv_emoji.Add(, "`!info", "ℹ️", "Emoji")
  hs_lv_emoji.Add(, "`!check", "✔️", "Emoji")
  hs_lv_emoji.Add(, "`!x", "❌", "Emoji")
  hs_lv_emoji.Add(, "`!warning", "⚠️", "Emoji")
  hs_lv_emoji.Add(, "`!error", "❗", "Emoji")
  hs_lv_emoji.Add(, "`!question", "❓", "Emoji")
  hs_lv_emoji.Add(, "`!lookup", "🔍", "Emoji")
  hs_lv_emoji.Add(, "`!search", "🔎", "Emoji")
  hs_lv_emoji.Add(, "`!star", "⭐", "Emoji")
  hs_lv_emoji.Add(, "`!star2", "🌟", "Emoji")
  hs_lv_emoji.Add(, "`!star3", "✨", "Emoji")
  hs_lv_emoji.Add(, "`!star4", "💫", "Emoji")
  hs_lv_emoji.Add(, "`!zap", "⚡", "Emoji")
  hs_lv_emoji.Add(, "`!fire", "🔥", "Emoji")
  hs_lv_emoji.Add(, "`!heart", "❤️", "Emoji")
  hs_lv_emoji.Add(, "`!noob", "🔰", "Emoji")
  hs_lv_emoji.Add(, "`!yellowcircle", "🟡", "Emoji")
  hs_lv_emoji.Add(, "`!greencircle", "🟢", "Emoji")
  hs_lv_emoji.Add(, "`!bluecircle", "🔵", "Emoji")
  hs_lv_emoji.Add(, "`!purplecircle", "🟣", "Emoji")
  hs_lv_emoji.Add(, "`!blackcircle", "⚫", "Emoji")
  hs_lv_emoji.Add(, "`!home", "🏠", "Emoji")
  hs_lv_emoji.Add(, "`!bug", "🕷️", "Emoji")
  hs_lv_emoji.Add(, "`!lightbulb", "💡", "Emoji")
  hs_lv_emoji.Add(, "`!thumbsup", "👍", "Emoji")
  hs_lv_emoji.Add(, "`!thumbsdown   ", "👎", "Emoji")
  hs_lv_emoji.Add(, "`!ok", "👌", "Emoji")
  hs_lv_emoji.Add(, "`!wait", "⏳", "Emoji")
  hs_lv_emoji.Add(, "`!clock", "⏰", "Emoji")
  hs_lv_emoji.Add(, "`!checkmark", "✅", "Emoji")
  hs_lv_emoji.Add(, "`!crossmark", "❎", "Emoji")
  hs_lv_emoji.ModifyCol(1) ; Auto-size the first column
  hs_lv_emoji.ModifyCol(2, 100)
  hs_lv_emoji.ModifyCol(3, 100)
  hs_lv_emoji.Opt("+Redraw")

  ; ASCII Art / Boxes
  aboutDlg.SetFont("c353881 Norm q5 s11", "Segoe UI")
  hs_lv_boxes := aboutDlg.Add("ListView", "x16 y205 w732 r12 vhs_lv_boxes", ["Hotstring", "Replacement", "Comments"])
  hs_lv_boxes.Opt("+Report")
  hs_lv_boxes.Opt("-Redraw")
  hs_lv_boxes.Add(, "##table##", "A simple table", "")
  hs_lv_boxes.Add(, "##rbox##", "A round-cornered box", "")
  hs_lv_boxes.Add(, "##rbox-insert-row##   ", "A split row in a round-cornered box", "")
  hs_lv_boxes.Add(, "##rtable##", "A round-cornered table", "")
  hs_lv_boxes.Add(, "##box##", "A simple box", "")
  hs_lv_boxes.Add(, "##box-addrow##", "Adds a row to a simple box", "")
  hs_lv_boxes.Add(, "##box-addcol##", "Adds a column to a simple box", "")
  hs_lv_boxes.Add(, "##tbox##", "A complex ASCII box", "")
  hs_lv_boxes.Add(, "##box-thick##", "A thick-bordered box", "")
  hs_lv_boxes.Add(, "##box-hthick##", "A box with thick horizontal lines", "")
  hs_lv_boxes.Add(, "##box-vthick##", "A box with thick vertical lines", "")
  hs_lv_boxes.ModifyCol(1) ; Auto-size the first column
  hs_lv_boxes.ModifyCol(2) ; Auto-size the second column
  hs_lv_boxes.ModifyCol(3, 100)
  hs_lv_boxes.Opt("+Redraw")

  hs_lv_custom := aboutDlg.Add("ListView", "x16 y205 w732 r12 vhs_lv_custom", ["Hotstring", "Example Replacement", "Comments"])
  hs_lv_custom.Opt("+Report")
  hs_lv_custom.Opt("-Redraw")
  hs_lv_custom.Add(, "`!me", "[Your Name]", "")
  hs_lv_custom.Add(, "`!nickname", "[Your Nickname]", "")
  hs_lv_custom.Add(, "`!sig", "Name`{ENTER`}Email`{ENTER`}Phone#`{ENTER`}", "")
  hs_lv_custom.Add(, "`!myphone", "[Your Phone Number]", "")
  hs_lv_custom.Add(, "`!email", "[Your E-mail address]", "")
  hs_lv_custom.ModifyCol() ; Auto-size the first column
  hs_lv_custom.ModifyCol(2) ; Auto-size the second column
  hs_lv_custom.ModifyCol(3, 100)
  hs_lv_custom.Opt("+Redraw")
  hs_lv_custom.Visible := false

  ; Handler to switch ListViews
  hs_switchListView(*) {
    hs_lv_ansi.Visible := hs_rb_ansi.Value
    hs_lv_kaomoji.Visible := hs_rb_kaomoji.Value
    hs_lv_boxes.Visible := hs_rb_boxes.Value
    hs_lv_emoji.Visible := hs_rb_emoji.Value
    hs_lv_custom.Visible := hs_rb_custom.Value
    if (hs_rb_ansi.Value)
      aboutDlg["hs_rb_text"].Value := "ANSI Hotstrings allow you to use special characters and symbols. Here are some examples:"
    else if (hs_rb_custom.Value)
      aboutDlg["hs_rb_text"].Value := "Add your Custom Hotstrings in the LIB\_HOTSTRINGS.ahk file. Here are some examples below:"
    else if (hs_rb_kaomoji.Value)
      aboutDlg["hs_rb_text"].Value := "Kaomojis are Japanese emoticons that can be used in text. Here are some examples:"
    else if (hs_rb_boxes.Value)
      aboutDlg["hs_rb_text"].Value := "ASCII Art Boxes can be used to create visually appealing text layouts. Here are some examples:"
    else if (hs_rb_emoji.Value)
      aboutDlg["hs_rb_text"].Value := "Emojis can be used to add visual elements to your text. Here are some examples:"
  }
  hs_rb_ansi.OnEvent("Click", hs_switchListView)
  hs_rb_kaomoji.OnEvent("Click", hs_switchListView)
  hs_rb_boxes.OnEvent("Click", hs_switchListView)
  hs_rb_emoji.OnEvent("Click", hs_switchListView)
  hs_rb_custom.OnEvent("Click", hs_switchListView)


  ; Tab 4 - Arpeggios
  mainTab.UseTab(4)
  ; aboutDlg.SetFont("Bold s10", "Segoe UI")
  ; aboutDlg.Add("Text", "x16 y70 w690 h30", "Arpeggios")
  aboutDlg.SetFont("c000000 Norm q5 s11", "Segoe UI")
  aboutDlg.Add("Text", "x16 y74 w732 h60", "Instead of using a hotkey or hotstring, an Arpeggio is made up of a sequence of keys/hotkeys. Think of it like playing musical notes: press [Caps Lock] + [O] to set the Mood, then tap [N] and  voilà — Notion launches like you meant business!")

  ; --- Radio Buttons and Dynamic ListViews ---
  ; GroupBox for visual clarity (optional)
  aboutDlg.SetFont("c000000 Norm q5 s10", "Segoe UI")
  aboutDlg.Add("GroupBox", "x16 y160 w732 h60", "Mood")

  ; Radio Buttons (horizontal)
  a_rb_apps := aboutDlg.Add("Radio", "x32 y185 w120 h23 ", "Applications")
  a_rb_clip := aboutDlg.Add("Radio", "x172 y185 w120 h23 ", "Selected Text")
  a_rb_nav := aboutDlg.Add("Radio", "x312 y185 w120 h23 ", "Navigation")

  a_rb_apps.Value := true ; Default selection

  ; ListViews for each category (stacked, only one visible at a time)
  a_lv_apps := aboutDlg.Add("ListView", "x16 y220 w732 r10 va_lvapps", ["Arpgeggio", "Action", "Description"])
  a_lv_apps.Opt("+Report +Sort")
  a_lv_apps.Opt("-Redraw")
  a_lv_apps.Add(, "A1", "B1")
  a_lv_apps.Add(, "A2", "B2")
  a_lv_apps.Add(, "A3", "B3")
  a_lv_apps.Opt("+Redraw")

  a_lv_clip := aboutDlg.Add("ListView", "x16 y220 w705 r10 va_lv_clip", ["Arpgeggio", "Action", "Description"])
  a_lv_clip.Add(, "X1", "Y1")
  a_lv_clip.Add(, "X2", "Y2")
  a_lv_clip.Visible := false

  a_lv_nav := aboutDlg.Add("ListView", "x16 y220 w705 r10 va_lv_nav", ["Arpgeggio", "Action", "Description"])
  a_lv_nav.Add(, "F1", "B1")
  a_lv_nav.Add(, "F2", "B2")
  a_lv_nav.Visible := false

  ; Handler to switch ListViews
  a_switchListView(*) {
    a_lv_apps.Visible := a_rb_apps.Value
    a_lv_clip.Visible := a_rb_clip.Value
    a_lv_nav.Visible := a_rb_nav.Value
  }
  a_rb_apps.OnEvent("Click", a_switchListView)
  a_rb_clip.OnEvent("Click", a_switchListView)
  a_rb_nav.OnEvent("Click", a_switchListView)


  aboutDlg.Title := "Mello.Ops - About"
  return aboutDlg
}