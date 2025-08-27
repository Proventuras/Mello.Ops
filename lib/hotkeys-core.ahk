#Requires AutoHotkey v2.0

; ╭════════════════════════════════════════════════════════════════════════════════════════════════════════════════─╮
; ║  HOTKEYS-CORE.AHK                                                                                               ║
; ║  Core, mandatory hotkeys                                                                                        ║
; ╰═════════════════════════════════════════════════════════════════════════════════════════════════════════════════╯

; #HotIf (Aux_HotKeySupport = true) && !(WinActive("ahk_class TscShellContainerClass"))
#HotIf !(WinActive("ahk_class TscShellContainerClass"))
{
  /*╭────────────────────────────────────────────────────────────────────────────────────────────╮
    │ NOTE: The #HotIf Condition is designed to prevent layers of keyboard shortcuts in virtual  |
    │       desktop overlays, e.g. RDP Sessions, VM Console overlays, etc.                       │
    ╰────────────────────────────────────────────────────────────────────────────────────────────╯*/
  ; ┌──────────────────────────────────────┐
  ; │ [LShift]+[RShift]+[n] to run Notepad │
  ; └──────────────────────────────────────┘
  RShift & n::
  {
    ; [LShift]+[RShift]+[n] to run an elevated Notepad process
    If GetKeyState("LShift", "P") && GetKeyState("RShift", "P") && GetKeyState("Ctrl", "P")
    {
      Run "notepad"
      exit ; return will only exit the current condition
    }

    If GetKeyState("LShift", "P") && GetKeyState("RShift", "P")
    {
      If WinExist("ahk_class Notepad")
      {
        WinActivate
        WinShow
        Return
      }
      Else
      {
        Run "notepad.exe"
        ; WinActivate
        Return
      }
    }
    Else
    {
      Send "N" ; This is to respond to [RShift}+[N]; otherwise, nothing will be sent
    }
  }

  ; ┌─────────────────────────────┐
  ; │ [RCtrl]x2 to run Calculator │
  ; └─────────────────────────────┘
  ~RControl::
  {
    ; Detects when a key has been double-pressed (similar to double-click). KeyWait is used to
    ; stop the keyboard's auto-repeat feature from creating an unwanted double-press when you
    ; hold down the RControl key to modify another key. It does this by keeping the hotkey's
    ; thread running, which blocks the auto-repeats by relying upon #MaxThreadsPerHotkey being
    ; at its default setting of 1. For a more elaborate script that distinguishes between
    ; single, double and triple-presses, see SetTimer example #3.
    if (A_PriorHotkey != "~RControl" or A_TimeSincePriorHotkey > 400)
    {
      ; Too much time between presses, so this isn't a double-press.
      KeyWait "RControl"
      return
    }

    ; A double-press of the RControl key has occurred.
    LaunchCalculator()
  }

  ;╭───────────────────────────────────────────────────────╮
  ;│  [Ctrl]+[Alt]+[T] for Terminal                        │
  ;│  [Ctrl]+[Alt]+[Shift]+[T] for Terminal in Admin Mode  │
  ;╰───────────────────────────────────────────────────────╯
  LAlt & t::
  {
    ; [Ctrl]+[Alt]+[T] to run Terminal
    If GetKeyState("LShift", "P") && GetKeyState("Alt", "P") && GetKeyState("LCtrl", "P")
    {
      ; MsgBox "Run wt.exe as Admin"  ; DEBUG
      Run "*RunAs wt.exe -w 0 new-tab --title Terminal(Admin) --suppressApplicationTitle"
      exit ; return will only exit the current condition
    }

    If GetKeyState("LCtrl", "P") && GetKeyState("LAlt", "P")
    {
      LaunchTerminal()
    }
    Else
    {
      Send "T" ; This is to respond to [RShift}+[T]; otherwise, nothing will be sent
    }
  }

  /*╭───────────────────────────────────────────────────────────────────────────────╮
    │  Directional keys to scroll the active window. Useful for TKL keyboards       │
    │  like laptops and those that use Fn key combinations for [PgUp], [PgDn],      │
    │  [Home], and [End].                                                           │
    │                                                                               │
    │  Directional keys to scroll the active window. Useful for TKL keyboards       │
    │  like laptops and those that use Fn key combinations for [PgUp], [PgDn],      │
    │  [Home], and [End].                                                           │
    │                                                                               │
    │  To use, simply lay your left thumb on the right Control key and use the      │
    │  arrow keys.                                                                  │
    │                                                                               │
    │  +-------------------------------------------------------------------------+  │
    │  | ⚡ The {Blind^} prevents misinterpretation by ignoring the Ctrl modifier │  │
    │  +-------------------------------------------------------------------------+  │
    ╰───────────────────────────────────────────────────────────────────────────────╯*/
  ~RCtrl & Up:: Send "{Blind>^}{PgUp}"
  ~RCtrl & Down:: Send "{Blind>^}{PgDn}"
  ~RCtrl & Left:: Send "{Blind>^}{Home}"
  ~RCtrl & Right:: Send "{Blind>^}{End}"
  ~RCtrl & Backspace:: Send "{Blind>^}{Del}"
}
#HotIf

; ╭─────────────────────────────────────────╮
; │ UNUSED: Reserved for when it's required │
; ╰─────────────────────────────────────────╯
; MouseIsOver(WinTitle) {
;   MouseGetPos , , &Win

;   return WinExist(WinTitle " ahk _id " Win)
; }