#Requires AutoHotkey v2.0

; ╭════════════════════════════════════════════════════════════════════════════════════════════════════════════════─╮
; ║  HOTSTRINGS-AUX.AHK                                                                                             ║
; ║    Hotstrings that can be enabled or disabled without closing the utility.                                      ║
; ╠═════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
; ║  NOTE: Hotstrings are not working for certain apps like Windows 11 22H2 Notepad                                 ║
; ╰═════════════════════════════════════════════════════════════════════════════════════════════════════════════════╯


#HotIf (Aux_HotStringSupport = true)
{
  /*
  ╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
  │ BOXES, TABLES and TREES                                                                                         │
  ├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ NOTE: These AutoPhrases will use the current active font; they work best with monospace fonts.                  │
  ├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ TIP: If you want the boxes to only work on specific apps, replace the #HotIf line with the following and        │
  │      customize the conditions to your liking. For example:                                                      │
  │      // #HotIf (WinActive("ahk_exe WindowsTerminal.exe") or WinActive("ahk_exe code.exe")                       │
  │      //    or WinActive("ahk_exe notepad.exe"))                                                                 │
  │      //    and (Aux_HotStringSupport = true)                                                                    │
  ╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯*/
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


#HotIf (Aux_HotStringSupport = true)
{
  ; ╭────────────────────────────────────────────────────────────────────────────────────╮
  ; │AUXILLARY HOTSTRINGS                                                                │
  ; ├────────────────────────────────────────────────────────────────────────────────────┤
  ; │ NOTE: Short length hotstrings better in UWP apps like the Win11 version of Notepad.|
  ; ╰────────────────────────────────────────────────────────────────────────────────────╯
  ; #HotString SI K-1
  ; Common Emojis (trimmed)
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

  ; ANSI/ASCII (Often monospaced when using the right font)
  ::`!idk::¯\(°_o)/¯                        ; Freq
  ::`!shrug::¯\_(ツ)_/¯                     ; Freq
  ::`!ohshit::( º﹃º )
  ::`!tableflip::(ノಠ益ಠ)ノ彡┻━┻
  ::`!fuckoff::୧༼ಠ益ಠ╭∩╮༽
  ::`!fuckyou::┌П┐(ಠ_ಠ)
  ::`!bullet::•                             ; 7
  ::`!multiply::×                           ; 0215
  ::`!divide::÷                             ; 0247
  ::`!registered::®                         ; 0174
  ::`!copyright::©                          ; 0169
  ::`!trademark::™                          ; 0153
  ::`!uparrow::↑                            ; 24
  ::`!downarrow::↓                          ; 25
  ::`!rightarrow::→                         ; 26
  ::`!leftarrow::←                          ; 27
  ::`!tricolon::⁝                           ; Freq
  ::`!windows::⊞
  ::`!capslock::⇪
  ::`!backspace::⌫
  ::`!enter::↵
  ::`!escape::⎋
  ::`!tab::⇥
  ::`!space::␣
  ::`!delete::⌦
  ::`!insert::⎀


  ; Common AI Prompts. Prefix used is '[[''
  ::`[`[rnr::Review and revise the following text:
}
#HotIf

#HotIf (Aux_HotStringSupport = true)
{
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
}
#HotIf

; ╭────────────────────────────────────────────────────────────────────────────────────╮
; │ HELPER FUNCTIONS                                                                   │
; ├────────────────────────────────────────────────────────────────────────────────────┤
; │ StrRepeat (str, count): Returns a string of 'str' repeated 'count' number of times │
; ╰────────────────────────────────────────────────────────────────────────────────────╯
StrRepeat(str, count) {
  ; ╭────────────────────────────────────────────────────────────────────────────────────╮
  ; │ StrRepeat (str, count): Returns a string of 'str' repeated 'count' number of times │
  ; ╰────────────────────────────────────────────────────────────────────────────────────╯
  result := ""
  Loop count
    result .= str
  return result
}