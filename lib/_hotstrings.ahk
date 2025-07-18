#Requires AutoHotkey v2.0

/*
╔═════════════════════════════════════════════════════════════╗
║  AUXILLARY HOTSTRINGS                                       ║
╠═════════════════════════════════════════════════════════════╣
║  Hotstrings that can be enabled or disabled without closing ║
║  the utility.                                               ║
╠═════════════════════════════════════════════════════════════╣
║  NOTE: Hotstrings are not working for certain apps like     ║
║  • Windows 11 22H2 Notepad                                  ║
╚═════════════════════════════════════════════════════════════╝
*/

/*
┌────────────────────────────────────────────────────────────────────────┐
│  Basic tables and boxes for dev and other text editing workflows       │
├────────────────────────────────────────────────────────────────────────┤
│  involving monospace fonts; customize the conditions to your liking.   │
└────────────────────────────────────────────────────────────────────────┘

*/

; If you want the boxes to only work on specific apps, replace the #HotIf line with the following and customize the conditions to your liking:
; #HotIf (WinActive("ahk_exe WindowsTerminal.exe") or WinActive("ahk_exe code.exe") or WinActive("ahk_exe notepad.exe")) and (Aux_HotStringSupport = true)
#HotIf (Aux_HotStringSupport = true)
{
  #HotString SE K40
  /* ------------------------------------
  SIMPLE BOX (sbox)
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
  SIMPLE TABLES (stable)
  +--+--+
  |  |  |
  +--+--+
  |  |  |
  +--+--+
  */
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
    splitRow := newRowLeftEdge StrRepeat(newRowHLine, rowLen - 2) newRowRightEdge
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
  :*:##tbox##:: {
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
}
#HotIf


/*
┌───────────────────────────────────────────────────────────┐
│  Aux set of Hotsrings                                     │
│  NOTE: Short length hotstrings work reliably in UWP apps  |
|        like the Windows 11 version of Notepad.            │
└───────────────────────────────────────────────────────────┘
*/

#HotIf (Aux_HotStringSupport = true)
{
  ; #HotString SI K-1
  ; Common Emojis (trimmed)
  ::`!idk::¯\(°_o)/¯
  ::`!shrug::¯\_(ツ)_/¯
  ::`!ohshit::( º﹃º )
  ::`!tableflip::(ノಠ益ಠ)ノ彡┻━┻
  ::`!fuckoff::୧༼ಠ益ಠ╭∩╮༽
  ::`!fuckyou::┌П┐(ಠ_ಠ)
  ::`!smile::😀
  ::`!info::ℹ️
  ::`!check::✔️
  ::`!x::❌
  ::`!warning::⚠️
  ::`!error::❗
  ::`!question::❓
  ::`!lookup::🔍
  ::`!search::🔎
  ::`!star::⭐
  ::`!zap::⚡
  ::`!fire::🔥
  ::`!heart::❤️
  ::`!noob::🔰
  ::`!yellowcircle::🟡
  ::`!greencircle::🟢
  ::`!bluecircle::🔵
  ::`!purplecircle::🟣
  ::`!blackcircle::⚫
  ::`!home::🏠
  ::`!bug::🕷️
  ::`!lightbulb::💡
  ::`!thumbsup::👍
  ::`!thumbsdown::👎
  ::`!ok::👌
  ::`!wait::⏳
  ::`!clock::⏰
  ::`!checkmark::✅
  ::`!crossmark::❎
  ::`!file::📄
  ::`!folder::📁
  ::`!folderopen::📂
  ::`!link::🔗

  ; ANSI/ASCII Alt Codes
  ::`!bullet::•         ; 7

  ::`!multiply::×       ; 0215
  ::`!divide::÷         ; 0247

  ::`!registered::®     ; 0174
  ::`!copyright::©      ; 0169
  ::`!trademark::™      ; 0153

  ::`!uparrow::↑        ; 24
  ::`!downarrow::↓      ; 25
  ::`!rightarrow::→     ; 26
  ::`!leftarrow::←      ; 27

  ::`!tricolon::⁝       ; 8234
  ::`!windows::⊞         ; 8992 Used for Windows key or Windows logo
  ::`!checkansi::✓       ; 10003
  ::`!capslock::⇪        ; 10548 Used for Caps Lock key
  ::`!backspace::⌫       ; 9003 Used for Backspace key
  ::`!enter::↵           ; 9167 Used for Enter key
  ::`!escape::⎋         ; 9001 Used for Escape key
  ::`!tab::⇥             ; 9194 Used for Tab key
  ::`!space::␣          ; 8199 Used for Space key
  ::`!delete::⌦         ; 9004 Used for Delete key
  ::`!insert::⎀         ; 9005 Used for Insert key

}
#HotIf


; Helper function to repeat a string n times
StrRepeat(str, count) {
  result := ""
  Loop count
    result .= str
  return result
}