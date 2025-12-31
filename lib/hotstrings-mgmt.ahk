#Requires AutoHotkey v2.0

; ╭════════════════════════════════════════════════════════════════════════════════════════════════════════════════─╮
; ║  HOTSTRINGS-MGMT.AHK                                                                                            ║
; ║    Hotstrings that can be enabled or disabled without closing the utility.                                      ║
; ╠═════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
; ║  NOTE: Hotstrings are not working for certain apps like Windows 11 22H2 Notepad                                 ║
; ╰═════════════════════════════════════════════════════════════════════════════════════════════════════════════════╯

; ╭════════════════════════════════════════════════════════════════════════════════════════════════════════════════─╮
; │ ** HELPER FUNCTIONS **                                                                                          │
; ╰═════════════════════════════════════════════════════════════════════════════════════════════════════════════════╯

StrRepeat(str, count) {
  ; ╭────────────────────────────────────────────────────────────────────────────────────╮
  ; │ StrRepeat (str, count): Returns a string of 'str' repeated 'count' number of times │
  ; ╰────────────────────────────────────────────────────────────────────────────────────╯
  result := ""
  Loop count
    result .= str
  return result
}

PasteWith(strValaue) {
  ; ╭────────────────────────────────────────────────────────────────────────────────────╮
  ; │ ReplaceWith │
  ; ╰────────────────────────────────────────────────────────────────────────────────────╯
  clpInit := ClipboardAll()  ; Save all clipboard content
  A_Clipboard := strValaue
  Send "^v"
  Sleep 500  ; Wait a bit for Ctrl+V to be processed
  A_Clipboard := clpInit  ; Restore previous clipboard content
}

; ╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
; │ BOXES, TABLES and TREES                                                                                         │
; ├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
; │ NOTE: These AutoPhrases will use the current active font; they work best with monospace fonts.                  │
; ├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
; │ TIP: If you want the boxes to only work on specific apps, replace the #HotIf line with the following and        │
; │      customize the conditions to your liking. For example:                                                      │
; │      // #HotIf (WinActive("ahk_exe WindowsTerminal.exe") or WinActive("ahk_exe code.exe")                       │
; │      //    or WinActive("ahk_exe notepad.exe"))                                                                 │
; │      //    and (Aux_HotStringSupport = true)                                                                    │
; ╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
#HotString SE K40
/* ------------------------------------
BASIC BOX (basicbox)
+--+
|  |
+--+
*/
:*:##sbox##:: {
  Sleep 100
  Send "{+}--{+}{ENTER}"
  Send "|  |{ENTER}"
  Send "{+}--{+}"
  Send "{Blind}{Shift up}"
}

/*
BASIC TABLES ()
+--+--+
|  |  |
+--+--+
|  |  |
+--+--+
*/
:*:`{`{basictable::
:*:##stable##:: {
  Sleep 100
  Send "{+}--{+}--{+}{ENTER}"
  Send "|  |  |{ENTER}"
  Send "{+}--{+}--{+}{ENTER}"
  Send "|  |  |{ENTER}"
  Send "{+}--{+}--{+}{ENTER}"
  Send "{Blind}{Shift up}"
}

/* ------------------------------------
ROUND-CORNERED BOX
╭──╮
│  │
╰──╯
*/
:*:##rbox##:: {
  Sleep 100
  Send "╭──╮{ENTER}"
  Send "│  │{ENTER}"
  Send "╰──╯{ENTER}"
  Send "{Blind}{Shift up}"
}

; Any Box - Split or Insert a row above the current line
:*:##insert-row##::
:*:##split-row##:: {
  A_Clipboard := ""  ; Clear the clipboard
  Send "{Up}{Home}+{End}"
  Send "^c"
  Sleep 100

  if (!ClipWait(2, 1) or StrLen(A_Clipboard) = 0) {
    Send "An attempt to measure the previous line's length failed. Please try again."
    return
  } else if (StrLen(A_Clipboard) > 256) {
    Send "An unusually high length of " StrLen(A_Clipboard) " characters was detected in the previous line. Please try again."
    return
  } else {
    ; MsgBox "Previous line is " StrLen(A_Clipboard) " characters long"
  }
  prevLine := A_Clipboard

  ; Determine the length between the left and right edge characters
  ; Find the first and last non-space character
  leftEdge := ""
  rightEdge := ""
  rowLen := 0
  if (StrLen(prevLine) >= 2) {
    leftEdge := SubStr(prevLine, 1, 1)
    if (leftEdge = "╔" or leftEdge = "║" or leftEdge = "╠") {
      newRowLeftEdge := "╠"
      newRowHLine := "═"
      newRowRightEdge := "╣"
    } else if (leftEdge = "┌" or leftEdge = "╭" or leftEdge = "│" or leftEdge = "├") {
      newRowLeftEdge := "├"
      newRowHLine := "─"
      newRowRightEdge := "┤"
    } else if (leftEdge = "+" or leftEdge = "|") {
      newRowLeftEdge := "{+}"
      newRowHLine := "-"
      newRowRightEdge := "{+}"
    } else {
      return
    }

    rightEdge := SubStr(prevLine, -0, 1)
    rowLen := StrLen(prevLine)
  }
  ; MsgBox "Left Edge: " newRowLeftEdge "`nRight Edge: " newRowRightEdge "`nRow Length: " rowLen

  ; Build the split row
  Send "{Down}{Home}"
  splitRow := newRowLeftEdge StrRepeat(newRowHLine, rowLen - 2) newRowRightEdge . "{ENTER}" . leftEdge StrRepeat(" ", rowLen - 2) leftEdge
  Send splitRow . "{ENTER}"
  Send "{Blind}{Shift up}"
}

; ROUND-CORNERED table
:*:##rtable##:: {
  Sleep 100
  Send "╭──┬──╮{ENTER}"
  Send "│  │  │{ENTER}"
  Send "├──┼──┤{ENTER}"
  Send "│  │  │{ENTER}"
  Send "╰──┴──╯{ENTER}"
  Send "{Blind}{Shift up}"
}


/* ------------------------------------
Gen1 Box of ole' (tbox)
┌──┐
│  │
└──┘
*/
:*:##box##:: {
  Sleep 100
  Send "┌──┐{ENTER}"
  Send "│  │{ENTER}"
  Send "└──┘{ENTER}"
  Send "{Blind}{Shift up}"
}

/* ------------------------------------
Gen1 Box of ole' with THICK lines (tbox-thick)
╔══╗
║  ║
╚══╝
*/
:*:##tbox-thick##:: {
  Sleep 100
  Send "╔══╗{ENTER}"
  Send "║  ║{ENTER}"
  Send "╚══╝{ENTER}"
  Send "{Blind}{Shift up}"
}

; ╭─────────────────────────────────────────────────────────────────────────────────────────╮
; │AUXILLARY HOTSTRINGS                                                                     │
; ├─────────────────────────────────────────────────────────────────────────────────────────┤
; │ NOTE: Short length hotstrings better in UWP apps like the Win11 version of Notepad.     |
; │ :X: Will execute the function instead of replacing the string with the literal value.   |
; │ :*: Ending characters not required.                                                     |
; │ :c: Case semsotove.                                                     |
; ╰─────────────────────────────────────────────────────────────────────────────────────────╯
; #HotString SI K-1
; Common Emojis (trimmed)
:X:`!`!blackcircle::PasteWith("⚫")
:X:`!`!bluecircle::PasteWith("🔵")
:X:`!`!bug::PasteWith("🕷")
:X:`!`!check::PasteWith("✔")
:X:`!`!checkmark::PasteWith("✅")
:X:`!`!clock::PasteWith("⏰")
:X:`!`!crossmark::PasteWith("❎")
:X:`!`!error::PasteWith("❗")
:X:`!`!file::PasteWith("📄")
:X:`!`!fire::PasteWith("🔥")
:X:`!`!folder::PasteWith("📁")
:X:`!`!folderopen::PasteWith("📂")
:X:`!`!greencircle::PasteWith("🟢")
:X:`!`!heart::PasteWith("❤")
:X:`!`!home::PasteWith("🏠")
:X:`!`!info::PasteWith("ℹ")
:X:`!`!lightbulb::PasteWith("💡")
:X:`!`!link::PasteWith("🔗")
:X:`!`!lookup::PasteWith("🔍")
:X:`!`!noob::PasteWith("🔰")
:X:`!`!ok::PasteWith("👌")
:X:`!`!purplecircle::PasteWith("🟣")
:X:`!`!question::PasteWith("❓")
:X:`!`!sarcsmile::PasteWith("🙃")
:X:`!`!search::PasteWith("🔎")
:X:`!`!smile::PasteWith("😀")
:X:`!`!star::PasteWith("⭐")
:X:`!`!thumbsdown::PasteWith("👎")
:X:`!`!thumbsup::PasteWith("👍")
:X:`!`!wait::PasteWith("⏳")
:X:`!`!warning::PasteWith("⚠")
:X:`!`!x::PasteWith("❌")
:X:`!`!yellowcircle::PasteWith("🟡")
:X:`!`!zap::PasteWith("⚡")

; ANSI/ASCII (Often monospaced when using the right font)
:X:`!`!arrowdown::PasteWith("↓")       
:X:`!`!arrowleft::PasteWith("←")       
:X:`!`!arrowright::PasteWith("→")      
:X:`!`!arrowup::PasteWith("↑")         
:X:`!`!bullet::PasteWith("•")          
:X:`!`!copyright::PasteWith("©")       
:X:`!`!divide::PasteWith("÷")          
:X:`!`!fuckoff::PasteWith("୧༼ಠ益ಠ╭∩╮༽")
:X:`!`!fuckyou::PasteWith("┌П┐(ಠ_ಠ)")
:X:`!`!idk::PasteWith("¯\(°_o)/¯")
:X:`!`!insert::PasteWith("⎀")
:X:`!`!keyalt::PasteWith("⌥")
:X:`!`!keybackspace::PasteWith("⌫")
:X:`!`!keycmd::PasteWith("⌘")
:X:`!`!keycaps::PasteWith("⇪")
:X:`!`!keydel::PasteWith("⌦")
:X:`!`!keyenter::PasteWith("↵")
:X:`!`!keyescape::PasteWith("⎋")
:X:`!`!keyins::PasteWith("⎀")
:X:`!`!keyshift::PasteWith("⇧")
:X:`!`!keytab::PasteWith("⇥")
:X:`!`!keyspace::PasteWith("␣")
:X:`!`!keytab::PasteWith("⇥")
:X:`!`!keywin::PasteWith("⊞")
:X:`!`!multiply::PasteWith("×")        
:X:`!`!ohshit::PasteWith("( º﹃º )")
:X:`!`!registered::PasteWith("®")      
:X:`!`!shrug::PasteWith("¯\_(ツ)_/¯")
:X:`!`!tableflip::PasteWith("(ノಠ益ಠ)ノ彡┻━┻")
:X:`!`!trademark::PasteWith("™")
:X:`!`!hdots::PasteWith("⋯")
:X:`!`!vdots::PasteWith("⋮")
:X:`!`!ddots::PasteWith("⋱")
:X:`!`!udots::PasteWith("⋰")


; Common AI Prompts. Prefix used is '[[''
::`[`[rnr::Review and revise the following text:
; }
; #HotIf

; {
; ╭────────────────────────────────────────────────────────────────────────────────────╮
; │AUXILLARY HOTSTRINGS                                                                │
; ├────────────────────────────────────────────────────────────────────────────────────┤
; │ NOTE: Short length hotstrings better in UWP apps like the Win11 version of Notepad.|
; ╰────────────────────────────────────────────────────────────────────────────────────╯
; #HotString SI K-1
; Common Emojis (trimmed)
::/ask-q::😀
; Common AI Prompts. Prefix used is '[[''
::/ask-rnr::Review and revise the following text:
; }
; #HotIf
