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
│  involving monospace fonts; customize the conditions to your liking.   │
└────────────────────────────────────────────────────────────────────────┘

*/

; If you want the boxes to only work on specific apps, replace the #HotIf line with the following and customize the conditions to your liking:
; #HotIf (WinActive("ahk_exe WindowsTerminal.exe") or WinActive("ahk_exe code.exe") or WinActive("ahk_exe notepad.exe")) and (Aux_HotStringSupport = true)
#HotIf (Aux_HotStringSupport = true)
{
  #HotString SE K40
  /*
  :*:##tbl-thin##::
  :*:##tbl##::{
      Sleep 100
      Send "┌──┬──┐{ENTER}"
      Send "│  │  │{ENTER}"
      Send "├──┼──┤{ENTER}"
      Send "│  │  │{ENTER}"
      Send "└──┴──┘{ENTER}"
      Send "{Blind}{Shift up}"
  }
  
  :*:##tbl-thick##::
  :*:##tbl-thicc##::{
      Sleep 100
      Send "╔══╦══╗{ENTER}"
      Send "║  ║  ║{ENTER}"
      Send "╠══╬══╣{ENTER}"
      Send "║  ║  ║{ENTER}"
      Send "╚══╩══╝{ENTER}"
      Send "{Blind}{Shift up}"
  }
  
  :*:##tbl-hthick##::
  :*:##tbl-hthicc##::
  :*:##tbl-vthin##::
  :*:##tbl-thinv##::
  {
    Sleep 100
    Send "╒══╦══╕{ENTER}"
    Send "│  │  │{ENTER}"
    Send "╞══╬══╡{ENTER}"
    Send "│  │  │{ENTER}"
    Send "╘══╩══╛{ENTER}"
    Send "{Blind}{Shift up}"
  }
  
  :*:##tbl-vthick##::
  :*:##tbl-vthicc##::
  :*:##tbl-hthin##::
  :*:##tbl-thinh##::
  {
      Sleep 100
      Send "╓──╥──╖{ENTER}"
      Send "║  ║  ║{ENTER}"
      Send "╟──╫──╢{ENTER}"
      Send "║  ║  ║{ENTER}"
      Send "╙──╨──╜{ENTER}"
      Send "{Blind}{Shift up}"
  }
  
  :*:##tbl-simple##::
  :*:##tbl-basic##::
  :*:##tbl-simp##::{
      Sleep 100
      Send "{+}--{+}--{+}{ENTER}"
      Send "|  |  |{ENTER}"
      Send "{+}--{+}--{+}{ENTER}"
      Send "|  |  |{ENTER}"
      Send "{+}--{+}--{+}{ENTER}"
      Send "{Blind}{Shift up}"
  }
  */
  ; SIMPLE TABLES
  :*:##tabl##::
  :*:##table##:: {
    Sleep 100
    Send "{+}--{+}--{+}{ENTER}"
    Send "|          |          |{ENTER}"
    Send "{+}--{+}--{+}{ENTER}"
    Send "|          |          |{ENTER}"
    Send "{+}--{+}--{+}{ENTER}"
    Send "{Blind}{Shift up}"
  }

  ; ROUND-CORNERED BOX
  :*:##rbox##:: {
    Sleep 100
    Send "╭──╮{ENTER}"
    Send "│  │{ENTER}"
    Send "╰──╯{ENTER}"
    Send "{Blind}{Shift up}"
  }
  
  ; ROUND-CORNERED BOX - INSERT/SPLIT ROW
    :*:##rbox-insert-row##:: 
    :*:##rbox-split-row##:: {
    Sleep 100
    ; Get the previous line's text
    ClipSaved := ClipboardAll

    Send "{Up}{Home}+{End}"
    Send "^c"

    if !ClipWait(2) {
      MsgBox "Unable to read the line above the cursor"
      return
    }
    prevLine := A_Clipboard

    ; Determine the length between the left and right edge characters
    ; Find the first and last non-space character
    leftEdge := ""
    rightEdge := ""
    rowLen := 0
    if (StrLen(prevLine) >= 2) {
      leftEdge := SubStr(prevLine, 1, 1)
      rightEdge := SubStr(prevLine, -0, 1)
      rowLen := StrLen(prevLine)
    }

    ; Build the split row
    ; Use "├" + (rowLen-2) times "-" + "┤"
    Send "{Down}{Home}"
    splitRow := "├" . StrRepeat("-", rowLen-2) . "┤{ENTER}"

    Send splitRow
    Send "{Blind}{Shift up}"
  }
  ; ROUND-CORNERED table
  :*:##rtbl##::
  :*:##rtable##::
  {
    Sleep 100
    Send "╭──┬──╮{ENTER}"
    Send "│  │  │{ENTER}"
    Send "├──┼──┤{ENTER}"
    Send "│  │  │{ENTER}"
    Send "╰──┴──╯{ENTER}"
    Send "{Blind}{Shift up}"
  }



  ; SIMPLE BOXES
  :*:##box##:: {
    Sleep 100
    Send "{+}--{+}{ENTER}"
    Send "|  |{ENTER}"
    Send "{+}--{+}"
    Send "{Blind}{Shift up}"
  }

  :*:##box-addrow##:: {
    Sleep 100
    Send "|  |{ENTER}"
    Send "{+}--{+}"
    Send "{Blind}{Shift up}"
  }

  :*:##box-addcol##:: {
    Sleep 100
    Send "{+}--{+}{down}{end}"
    Send "  |{down}{end}"
    Send "--{+}{down}{end}"
    Send "{Blind}{Shift up}"
  }

  ; Complex ASCII boxes
  :*:##tbox##:: 
  :*:##box##:: {
    Sleep 100
    Send "┌──┐{ENTER}"
    Send "│  │{ENTER}"
    Send "└──┘{ENTER}"
    Send "{Blind}{Shift up}"
  }

  :*:##box-thick##::
  :*:##box-thicc##:: {
    Sleep 100
    Send "╔══╗{ENTER}"
    Send "║  ║{ENTER}"
    Send "╚══╝{ENTER}"
    Send "{Blind}{Shift up}"
  }



  ; Fancy boxes with THIN vertical lines and THICK horizontal lines
  :*:##box-hthick##::
  :*:##box-hthicc##::
  :*:##box-vthin##::
  :*:##box-thinv##::
  {
    Sleep 100
    Send "╒══╕{ENTER}"
    Send "│  │{ENTER}"
    Send "╘══╛{ENTER}"
    Send "{Blind}{Shift up}"
  }

  ; Fancy boxes with THICK vertical lines and THIN horizontal lines
  :*:##box-vthick##::
  :*:##box-vthicc##::
  :*:##box-hthin##::
  :*:##box-thinh##::
  {
    Sleep 100
    Send "╓──╖{ENTER}"
    Send "║  ║{ENTER}"
    Send "╙──╜{ENTER}"
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
  ; Common Emojis
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
  ::`!star2::🌟
  ::`!star3::✨
  ::`!star4::💫
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

  ; ANSI/ASCII Alt Codes
  ::`!bullet::•         ; 7
  ::`!degree::°         ; 0176
  ::`!smiley::☺️         ; 1
  ::`!sun::☼            ; 15

  ::`!multiply::×       ; 0215
  ::`!divide::÷         ; 0247

  ::`!registered::®     ; 0174
  ::`!copyright::©      ; 0169
  ::`!trademark::™      ; 0153

  ::`!uparrow::↑        ; 24
  ::`!downarrow::↓      ; 25
  ::`!rightarrow::→     ; 26
  ::`!leftarrow::←      ; 27
  ::`!updownarrow::↕    ; 18
  ::`!leftrightarrow::↔ ; 29
  ::`!upleftarrow::↖    ; 2196
  ::`!uprightarrow::↗   ; 2197
  ::`!downleftarrow::↙  ; 2199
  ::`!downrightarrow::↘ ; 2198
  
  ::`!tricolon::⁝       ; 8234
  ::`!fahrenheit::℉   ; 8457
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
  
  ; Common Misspellings

}
#HotIf

/*
*/

; Helper function to repeat a string n times
StrRepeat(str, count) {
    result := ""
    Loop count
        result .= str
    return result
}

