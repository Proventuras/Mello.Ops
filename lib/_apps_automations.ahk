#Requires AutoHotkey v2.0

;╭──────────────────────────────────────────╮
;│ APPS & AUTOMATIONS                       │
;╰──────────────────────────────────────────╯
LaunchCalculator(*)
{
  ; Single Instance condition. Do not create a new process and used the last one created
  If WinExist("Calculator", "Calculator")
  {
    WinActivate
    WinShow
    Return
  }
  Else
  {
    Run "calc.exe"
    WinWait "Calculator"
    WinActivate
  }
}

LaunchTerminal(*)
{
  If WinExist("ahk_exe WindowsTerminal.exe")
  {
    WinActivate
    WinShow
    Return
  }
  Else
  {
    Run "wt.exe -w 0 new-tab --title (ツ)_/¯{Terminal} --suppressApplicationTitle", , , &wt_pid
    Sleep 1000
    If WinExist("ahk_exe WindowsTerminal.exe") or WinExist("ahk_title Terminal")
    {
      WinActivate
      WinShow
    }
    Return
  }
}

LaunchNotion(*) {
  ; Path to Notion.exe
  static notionIconPath := RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\661f0cc6-343a-59cb-a5e8-8f6324cc6998", "DisplayIcon")
  static notionPath := SubStr(notionIconPath, 1, InStr(notionIconPath, ",") - 1)
  If WinExist("ahk_exe Notion.exe")
  {
    WinActivate
    SoundPlay sound_file_start
    WinShow
    Return
  }
  Else
  {
    If FileExist(notionPath)
    {
      Run notionPath
      ; SoundPlay "*48"
      Return
    }
    Else
    {
      SoundPlay sound_file_stop
      Return
    }
  }
}
