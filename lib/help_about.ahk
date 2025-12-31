#Requires Autohotkey v2.0
; ╭════════════════════════════════════════════════════════════════════════════════════════════════════════════════─╮
; ║  _HELP_ABOUT.AHK                                                                                                    ║
; ╰═════════════════════════════════════════════════════════════════════════════════════════════════════════════════╯

; ╭────────────────────────╮
; │ GLOBAL SCOPE VARIABLES │
; ╰────────────────────────╯
global aboutDlg := ""
global dlgWidth := 760
global dlgHeight := 560

class ThisPC {
  static CPUInfo := Map()
  static RAM := ""
  static OS := Map()
  static Motherboard := Map()
  static Network := []
  static ExternalIP := ""
  static Battery := Map()
  static Uptime := ""

  static CollectInfo() {
    ThisPC.CPUInfo := ThisPC.CPUInfoClass()
    ThisPC.RAM := ThisPC.GetRAMInfo()
    ThisPC.OS := ThisPC.GetOSInfo()
    ThisPC.Motherboard := ThisPC.GetMotherboardInfo()
    ThisPC.Network := ThisPC.GetNetworkInfo()
    ThisPC.ExternalIP := ThisPC.GetExternalIP()
    ThisPC.Battery := ThisPC.GetBatteryInfo()
    ThisPC.Uptime := ThisPC.GetUptime()
  }

  class CPUInfoClass {
    Name := ""
    Manufacturer := ""
    Description := ""
    NumberOfCores := ""
    NumberOfLogicalProcessors := ""
    MaxClockSpeed := ""
    Architecture := ""
    ProcessorId := ""

    __New() {
      for cpu in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Processor") {
        this.Name := cpu.Name
        this.Manufacturer := cpu.Manufacturer
        this.Description := cpu.Description
        this.NumberOfCores := cpu.NumberOfCores
        this.NumberOfLogicalProcessors := cpu.NumberOfLogicalProcessors
        this.MaxClockSpeed := cpu.MaxClockSpeed
        this.Architecture := cpu.Architecture
        this.ProcessorId := cpu.ProcessorId
        break
      }
    }
  }

  static GetRAMInfo() {
    total := 0
    for mem in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_PhysicalMemory")
      total += mem.Capacity
    return Round(total / (1024 ** 3), 2) ; GiB
  }

  static GetOSInfo() {
    for os in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_OperatingSystem") {
      ; Convert install date from WMI format
      installDate := os.InstallDate
      if installDate
        installDate := SubStr(installDate, 1, 4) "-" SubStr(installDate, 5, 2) "-" SubStr(installDate, 7, 2) " " SubStr(installDate, 9, 2) ":" SubStr(installDate, 11, 2)
      return Map(
        "Name", os.Caption,
        "Version", os.Version,
        "BuildNumber", os.BuildNumber,
        "Architecture", os.OSArchitecture,
        "InstallDate", installDate
      )
    }
    return Map()
  }

  static GetMotherboardInfo() {
    for board in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_BaseBoard") {
      return Map(
        "Manufacturer", board.Manufacturer,
        "Product", board.Product,
        "SerialNumber", board.SerialNumber
      )
    }
    return Map()
  }

  static GetNetworkInfo() {
    info := []
    for nic in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_NetworkAdapterConfiguration WHERE IPEnabled=TRUE") {
      info.Push(Map(
        "Description", nic.Description,
        "MACAddress", nic.MACAddress,
        "IPAddress", nic.IPAddress ? nic.IPAddress[0] : "",
        "Gateway", nic.DefaultIPGateway ? nic.DefaultIPGateway[0] : ""
      ))
    }
    return info
  }

  static GetExternalIP() {
    try {
      whr := ComObject("WinHttp.WinHttpRequest.5.1")
      whr.Open("GET", "https://api.ipify.org/", true)
      whr.Send()
      whr.WaitForResponse()
      return whr.ResponseText
    } catch {
      return "Unavailable"
    }
  }

  static GetBatteryInfo() {
    for bat in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Battery") {
      return Map(
        "Status", bat.BatteryStatus,
        "EstimatedChargeRemaining", bat.EstimatedChargeRemaining,
        "EstimatedRunTime", bat.EstimatedRunTime
      )
    }
    return Map()
  }

  static GetUptime() {
    for os in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_OperatingSystem") {
      lastBoot := os.LastBootUpTime
      if lastBoot {
        ; Parse WMI datetime: yyyymmddHHMMSS.xxxxxx±UUU
        yyyy := SubStr(lastBoot, 1, 4)
        MM := SubStr(lastBoot, 5, 2)
        dd := SubStr(lastBoot, 7, 2)
        hh := SubStr(lastBoot, 9, 2)
        mi := SubStr(lastBoot, 11, 2)
        ss := SubStr(lastBoot, 13, 2)
        lastBootTime := yyyy . MM . dd . hh . mi . ss
        ; Calculate seconds since last boot
        uptimeSec := DateDiff(A_Now, lastBootTime, "Seconds")
        days := Floor(uptimeSec / 86400)
        hours := Floor(Mod(uptimeSec, 86400) / 3600)
        mins := Floor(Mod(uptimeSec, 3600) / 60)
        return days "d " hours "h " mins "m"
      }
    }
    return "Unavailable"
  }
}

ShowHelpAbout(*) {


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
  isInfoLoaded := false
  isInfoLoaded := false
  ; Detect the active private working memory usage of this process
  pid := DllCall("GetCurrentProcessId")
  ; Open process with query info rights
  hProcess := DllCall("OpenProcess", "UInt", 0x1000, "Int", false, "UInt", pid, "Ptr")
  if hProcess {
    ; PROCESS_MEMORY_COUNTERS structure is 72 bytes on 64-bit, 40 bytes on 32-bit
    structSize := (A_PtrSize = 8) ? 72 : 40

    ; PROCESS_MEMORY_COUNTERS := Buffer(structSize, 0)
    ; NumPut("UInt", structSize, PROCESS_MEMORY_COUNTERS, 0)
    ; if DllCall("psapi\GetProcessMemoryInfo", "Ptr", hProcess, "Ptr", PROCESS_MEMORY_COUNTERS.Ptr, "UInt", structSize) {
    ;   Offsets for PROCESS_MEMORY_COUNTERS (see MSDN)
    ;   cnt := ""
    ;   cnt .= "PageFaultCount: " NumGet(PROCESS_MEMORY_COUNTERS, 4, "UInt") "`n"
    ;   cnt .= "PeakWorkingSetSize: " Round(NumGet(PROCESS_MEMORY_COUNTERS, 8, (A_PtrSize=8)?"UInt64":"UInt") / 1024, 2) " MB`n"
    ;   cnt .= "WorkingSetSize: " Round(NumGet(PROCESS_MEMORY_COUNTERS, 8 + A_PtrSize, (A_PtrSize=8)?"UInt64":"UInt") / 1024, 2) " MB`n"
    ;   cnt .= "QuotaPeakPagedPoolUsage: " Round(NumGet(PROCESS_MEMORY_COUNTERS, 8 + 2*A_PtrSize, (A_PtrSize=8)?"UInt64":"UInt") / 1024, 2) " MB`n"
    ;   cnt .= "QuotaPagedPoolUsage: " Round(NumGet(PROCESS_MEMORY_COUNTERS, 8 + 3*A_PtrSize, (A_PtrSize=8)?"UInt64":"UInt") / 1024, 2) " MB`n"
    ;   cnt .= "QuotaPeakNonPagedPoolUsage: " Round(NumGet(PROCESS_MEMORY_COUNTERS, 8 + 4*A_PtrSize, (A_PtrSize=8)?"UInt64":"UInt") / 1024, 2) " MB`n"
    ;   cnt .= "QuotaNonPagedPoolUsage: " Round(NumGet(PROCESS_MEMORY_COUNTERS, 8 + 5*A_PtrSize, (A_PtrSize=8)?"UInt64":"UInt") / 1024, 2) " MB`n"
    ;   cnt .= "PagefileUsage: " Round(NumGet(PROCESS_MEMORY_COUNTERS, 8 + 6*A_PtrSize, (A_PtrSize=8)?"UInt64":"UInt") / 1024, 2) " MB`n"
    ;   cnt .= "PeakPagefileUsage: " Round(NumGet(PROCESS_MEMORY_COUNTERS, 8 + 7*A_PtrSize, (A_PtrSize=8)?"UInt64":"UInt") / 1024, 2) " MB"
    ;   MsgBox(cnt, "Process Memory Counters (MB)")
    ; }

    ; Get the active private working set and calculate in MB
    PROCESS_MEMORY_COUNTERS := Buffer(structSize, 0)
    NumPut("UInt", structSize, PROCESS_MEMORY_COUNTERS, 0)
    if DllCall("psapi\GetProcessMemoryInfo", "Ptr", hProcess, "Ptr", PROCESS_MEMORY_COUNTERS.Ptr, "UInt", structSize) {
      ; PrivateWorkingSetSize is at offset 32 (UInt64 for 64-bit, UInt for 32-bit)
      ; if (A_PtrSize = 8) {
      ;   workingSetSize := NumGet(PROCESS_MEMORY_COUNTERS, 32, "UInt64")
      ; }
      ; else {
      workingSetSize := NumGet(PROCESS_MEMORY_COUNTERS, 32, "UInt")
      ; }
      memMB := Round(workingSetSize / (1024 * 1024), 2)
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

  ; Get terminal/parent process info
  termInfo := GetTerminalInfo()


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
  aboutDlg.SetFont("q5 s10", "Segoe UI")
  mainTab := aboutDlg.Add("Tab3", "x8 y42 w748 h520",
    ["About",
      "Hotkeys  ",
      "Hotstrings  ",
      "Window Management  ",
      "Arpeggios  ",
      "App Controls  ",
      "Other Options ",
      "Other Info"])
  ; mainTab.OnEvent("Change",

  ; ╭───────────────────────────────────────────────────────────────────────────────────────╮
  ; │ Tab 1 - About                                                                         │
  ; ╰───────────────────────────────────────────────────────────────────────────────────────╯
  mainTab.UseTab(1)
  ; Logo and Title, version number, and license
  aboutDlg.Add("Picture", "x16 y74 w48 h48", A_ScriptDir "\media\icons\Mello.Ops.ico")
  ; aboutDlg.SetFont("c3e3d32", "Segoe UI")
  aboutDlg.SetFont("c039314 Bold s21", "Segoe UI")
  aboutDlg.Add("Text", "x72 y74 w470", "Mello.Ops")

  ; Tagline
  aboutDlg.SetFont("Bold Italic s14", "Segoe UI")
  aboutDlg.Add("Text", "yp+38 w400 h23 ", "Chill. Flow. Repeat.")

  ; Version and License
  ; aboutDlg.Add("Text", "xp-30 yp+20 w600 h23", "Margin: " aboutDlg.MarginX " px, " aboutDlg.MarginY " px")
  aboutDlg.SetFont("c353881 q5 s10", "Segoe UI")
  aboutDlg.Add("Text", "xp yp+25 w300", "Version: " thisapp_version)
  aboutDlg.Add("Text", "yp w300", "Private Memory Usage: " memMB " MB")
  aboutDlg.Add("Text", "xp-308 yp+20 w300", "Licensed under the MIT License")
  aboutDlg.Add("Text", "yp w300", "Uptime: " UptimeString)
  aboutDlg.Add("Text", "yp w300", "Terminal Host: " (termInfo.IsTerminalHost ? "Yes - " termInfo.HostProcess : "No"))
  aboutDlg.Add("Text", "yp w300 c808080 s9", "Parent chain: " (termInfo.ParentChain ? termInfo.ParentChain : "N/A"))


  ; Credit Section and Links to other resources
  aboutDlg.SetFont("c039314 Bold q5 s11", "Segoe UI")
  aboutDlg.Add("Text", "x72 y400 w600 h23", "Credits and Resources")  ; Fixed location
  aboutDlg.SetFont("c000000 Norm q5 s10", "Segoe UI")
  aboutDlg.Add("Picture", "x72 y+0 w16 h16", A_ScriptDir "\media\icons\apps\autohotkey.ico")
  aboutDlg.Add("Link", "yp w400 h23",
    "AutoHotkey (version " A_AhkVersion ") is available at <a href=`"https://www.autohotkey.com`">autohotkey.com</a>")

  aboutDlg.Add("Picture", "x70 yp+20 w20 h20", A_ScriptDir "\media\icons\apps\icons8.ico")
  aboutDlg.Add("Link", "yp w600 h23", "Icons by <a href=`"https://icons8.com`">icons8.com</a>")

  aboutDlg.Add("Picture", "x70 yp+20 w20 h20", A_ScriptDir "\media\icons\icons8-github-windows-10-16.png")
  ; aboutDlg.Add("Link", "yp w600 h23",
  ;   "<a href=`"https://www.autohotkey.com/boards/viewtopic.php?f=83&t=94044`">WiseGUI.ahk library</a> by <a href=`"https://www.autohotkey.com/boards/memberlist.php?mode=viewprofile&u=54&sid=f3bac845536fc1eace03994a9e73273e`">SKAN</a>")

  aboutDlg.Add("Picture", "x70 yp+20 w20 h20", A_ScriptDir "\media\icons\icons8-github-windows-10-16.png")
  aboutDlg.Add("Link", "yp w300 h23",
    "<a href=`"https://github.com/FuPeiJiang/VD.ahk/tree/v2_port`">VD.ahk library</a> by <a href=`"https://github.com/FuPeiJiang`">FuPeiJiang</a>")
  ; aboutDlg.Add("Link", "x72 y270 w300 h23",
  ; "<a href=`"https://github.com/Ciantic/VirtualDesktopAccessor`">VirtualDesktopAccessor</a> by <a href=`"https://github.com/Ciantic`">Ciantic</a>")

  ; ╭───────────────────────────────────────────────────────────────────────────────────────╮
  ; │ Tab 2 - Hotkeys                                                                       │
  ; ╰───────────────────────────────────────────────────────────────────────────────────────╯
  mainTab.UseTab(2)
  aboutDlg.SetFont("Bold s11", "Segoe UI")
  aboutDlg.Add("Text", "x16 y74 w705 h23", "Hotkeys = keyboard shortcuts. Go ahead and try them out!")

  ; Add ListView for Hotkeys
  aboutDlg.SetFont("c353881 Norm q5 s10", "Segoe UI")
  lv_corehkeys := aboutDlg.Add("ListView", "x16 y100 w732 r19 c353881", ["Action", "Hotkey", "Description"])
  lv_corehkeys.Opt("+Report") ; +Sort")

  ; Example hotkeys - replace/add as needed for your project
  lv_corehkeys.Opt("+Report") ; +Sort")
  lv_corehkeys.Opt("-Redraw")
  lv_corehkeys.Add(, "Reload and Restart " thisapp_name, "[Ctrl/^] [Alt/⌥] ⊞ R ", "Reload and restart " thisapp_name)
  lv_corehkeys.Add(, "AutoHotkey Help", "[Ctrl/^] [Alt/⌥] ⊞ F2", "Open the AutoHotkey help docs")
  lv_corehkeys.Add(, "Sleep", "[Ctrl/^] [Alt/⌥] ⊞ F12", "Put this system to sleep")
  lv_corehkeys.Add(, thisapp_name " Help", "[Ctrl/^] [Alt/⌥] ⊞ F1", "Display this dialog")
  lv_corehkeys.Add(, "Open the user's folder", "⊞ F", "Open the user's Documents folder in File Explorer")
  lv_corehkeys.Add(, "Edit this script", "[Ctrl/^] [Alt/⌥] ⊞ E", "Open the main " thisapp_name " script (default editor)")
  ; lv_corehkeys.Add(, "Open the " thisapp_name " folder", "[Ctrl/^] [Alt/⌥] ⊞ F", "Open the " thisapp_name " folder in File Explorer")
  lv_corehkeys.Add(, "Windows Terminal", "[Ctrl] [Alt/⌥] T", "Open or focus the Windows Terminal window")
  lv_corehkeys.Add(, "Windows Terminal (Elevated)", "[Ctrl] [Shift] [Alt/⌥] T", "Open an elevated Windows Terminal instance")
  lv_corehkeys.Add(, "Open Calculator", "2 × [Right_Alt/⌥]", "Open or focus the Calculator app")
  lv_corehkeys.Add(, "Increase Mouse Pointer Size", "[Ctrl/^] [Alt/⌥] ⊞ ]", "Incrase the mouse cursor size (Settings > Accessibility)")
  lv_corehkeys.Add(, "Decrease Mouse Pointer Size", "[Ctrl/^] [Alt/⌥] ⊞ [", "Decrease  the mouse cursor size (Settings > Accessibility)")
  lv_corehkeys.Add(, "Home", "[RCtrl] ←", "[Right_Alt/⌥] supported inside an RDP connection.")
  lv_corehkeys.Add(, "End", "[RCtrl] →", "[Right_Alt/⌥] supported inside an RDP connection.")
  lv_corehkeys.Add(, "PgUp", "[RCtrl] ↑", "[Right_Alt/⌥] supported inside an RDP connection.")
  lv_corehkeys.Add(, "PgDn", "[RCtrl] ↓", "[Right_Alt/⌥] supported inside an RDP connection.")
  ; lv_corehkeys.Add(, "Set current window to 70%", "[Ctrl/^] [Alt/⌥] ⊞ /","")
  ; lv_corehkeys.Add(, "Shrink current window", "[Ctrl/^] [Alt/⌥] ⊞ <", "5% smaller")
  ; lv_corehkeys.Add(, "Expand current window", "[Ctrl/^] [Alt/⌥] ⊞ >", "5% larger")
  ; lv_corehkeys.Add(, "Extend current window's top border", "[Ctrl/^] [Alt/⌥] I", "Extend windo to the top of the screen")
  ; lv_corehkeys.Add(, "Extend current window's bottom border", "[Ctrl/^] [Alt/⌥] K", "Extend windo to the bottom of the screen")
  ; lv_corehkeys.Add(, "Extend current window's left border", "[Ctrl/^] [Alt/⌥] J", "Extend windo to the left of the screen")
  ; lv_corehkeys.Add(, "Extend current window's right border", "[Ctrl/^] [Alt/⌥] L", "Extend windo to the right of the screen")
  ; lv_corehkeys.Add(, "Move current window up", "[Ctrl/^] [Alt/⌥] ⊞ I", "Move window up by 10%")
  ; lv_corehkeys.Add(, "Move current window down", "[Ctrl/^] [Alt/⌥] ⊞ K", "Move window down by 10%")
  ; lv_corehkeys.Add(, "Move current window left", "[Ctrl/^] [Alt/⌥] ⊞ J", "Move window left by 10%")
  ; lv_corehkeys.Add(, "Move current window right", "[Ctrl/^] [Alt/⌥] ⊞ L", "Move window right by 10%")
  lv_corehkeys.ModifyCol() ; Auto-size the first column
  lv_corehkeys.ModifyCol(2) ; Auto-size the second column
  lv_corehkeys.ModifyCol(3)
  lv_corehkeys.Opt("+Redraw")
  lv_corehkeys.Visible := True

  ; ╭───────────────────────────────────────────────────────────────────────────────────────╮
  ; │ Tab 3 - Hotstrings                                                                    │
  ; ╰───────────────────────────────────────────────────────────────────────────────────────╯
  mainTab.UseTab(3)
  aboutDlg.SetFont("c000000 Bold q5 s11", "Segoe UI")
  aboutDlg.Add("Text", "x16 y74 w705 h54", "Hotstrings = string replacements. Just hit [End] or [Enter] to expand them!")
  aboutDlg.SetFont("c000000 Norm q5 s11", "Segoe UI")

  ; --- Radio Buttons and Dynamic ListViews ---
  aboutDlg.SetFont("Bold s10", "Segoe UI")
  aboutDlg.Add("GroupBox", "x16 y100 w732 h50", "Hotstring Groups")

  aboutDlg.SetFont("Norm s10", "Segoe UI")
  hs_rb_ansi := aboutDlg.Add("Radio", "x32 y120 w90 h23 vhs_rb_ansi", "ANSI")
  hs_rb_kaomoji := aboutDlg.Add("Radio", "x120 y120 w90 h23 vhs_rb_kaomoji", "Kaomoji")
  hs_rb_emoji := aboutDlg.Add("Radio", "x220 y120 w90 h23 vhs_rb_emoji", "Emojis")
  hs_rb_boxes := aboutDlg.Add("Radio", "x320 y120 w100 h23 vhs_rb_boxes", "Tables `& Boxes")
  hs_rb_custom := aboutDlg.Add("Radio", "x460 y120 w90 h23 vhs_rb_custom", "Custom")

  hs_rb_ansi.Value := true ; Default selection
  aboutDlg.SetFont("c000000 Norm q5 s11", "Segoe UI")
  aboutDlg.Add("Text", "x16 y155 w732 h54 vhs_rb_text", "Hotstrings include optional expansions and modifiers for advanced use.")

  ; ANSI/ASCII Alt Codes
  aboutDlg.SetFont("c353881 Norm q5 s10", "Segoe UI")
  hs_lv_ansi := aboutDlg.Add("ListView", "x16 y185 w732 r15 vhs_lv_ansi", ["Hotstring", "Replacement", "Comments"])
  hs_lv_ansi.Opt("+Report")
  hs_lv_ansi.Opt("-Redraw")
  hs_lv_ansi.Add(, "`~arrowdown", "↓", "ANSI 25")
  hs_lv_ansi.Add(, "`~arrowleft", "←", "ANSI 27")
  hs_lv_ansi.Add(, "`~arrowright", "→", "ANSI 26")
  hs_lv_ansi.Add(, "`~arrowup", "↑", "ANSI 24")
  hs_lv_ansi.Add(, "`~backspace", "⌫", "")
  hs_lv_ansi.Add(, "`~bullet", "•", "ANSI 7")
  hs_lv_ansi.Add(, "`~copyright", "©", "ANSI 0169")
  hs_lv_ansi.Add(, "`~delete", "⌦", "")
  hs_lv_ansi.Add(, "`~divide", "÷", "ANSI 0247")
  hs_lv_ansi.Add(, "`~enter", "↵", "")
  hs_lv_ansi.Add(, "`~escape", "⎋", "")
  hs_lv_ansi.Add(, "`~insert", "⎀", "")
  hs_lv_ansi.Add(, "`~keybackspace", "⌫", "")
  hs_lv_ansi.Add(, "`~keycaps", "⇪", "")
  hs_lv_ansi.Add(, "`~keydel", "⌦", "")
  hs_lv_ansi.Add(, "`~keyenter", "↵", "")
  hs_lv_ansi.Add(, "`~keyescape", "⎋", "")
  hs_lv_ansi.Add(, "`~keyins", "⎀", "")
  hs_lv_ansi.Add(, "`~keyshift", "⇧", "")
  hs_lv_ansi.Add(, "`~keytab", "⇥", "")
  hs_lv_ansi.Add(, "`~keyspace", "␣", "")
  hs_lv_ansi.Add(, "`~keywin", "⊞", "")
  hs_lv_ansi.Add(, "`~multiply", "×", "ANSI 0215")
  hs_lv_ansi.Add(, "`~registered", "®", "ANSI 0174")
  hs_lv_ansi.Add(, "`~space", "␣", "")
  hs_lv_ansi.Add(, "`~trademark", "™", "ANSI 0153")
  hs_lv_ansi.Add(, "`~tricolon", "⁝", "")
  hs_lv_ansi.ModifyCol()
  hs_lv_ansi.ModifyCol(2, 100)
  hs_lv_ansi.ModifyCol(3, 100)
  hs_lv_ansi.Opt("+Redraw")

  ; Japanese Emoticons (Kaomoji)
  hs_lv_kaomoji := aboutDlg.Add("ListView", "x16 y185 w732 r12 vhs_lv_kaomoji", ["Hotstring", "Replacement", "Comments"])
  hs_lv_kaomoji.Opt("+Report")
  hs_lv_kaomoji.Opt("-Redraw")
  hs_lv_kaomoji.Add(, "`~fuckoff", "୧༼ಠ益ಠ╭∩╮༽", "")
  hs_lv_kaomoji.Add(, "`~fuckyou", "┌П┐(ಠ_ಠ)", "")
  hs_lv_kaomoji.Add(, "`~idk", "¯\(°_o)/¯", "")
  hs_lv_kaomoji.Add(, "`~ohshit", "( º﹃º )", "")
  hs_lv_kaomoji.Add(, "`~shrug", "¯\_(ツ)_/¯", "")
  hs_lv_kaomoji.Add(, "`~tableflip", "(ノಠ益ಠ)ノ彡┻━┻", "")
  hs_lv_kaomoji.ModifyCol(1)
  hs_lv_kaomoji.ModifyCol(2)
  hs_lv_kaomoji.ModifyCol(3, 100)
  hs_lv_kaomoji.Opt("+Redraw")
  hs_lv_kaomoji.Visible := false

  ; Emojis
  hs_lv_emoji := aboutDlg.Add("ListView", "x16 y185 w732 r12 vhs_lv_emoji", ["Hotstring", "Replacement", "Comments"])
  hs_lv_emoji.Opt("+Report")
  hs_lv_emoji.Opt("-Redraw")
  hs_lv_emoji.Add(, "`~blackcircle", "⚫", "Emoji")
  hs_lv_emoji.Add(, "`~bluecircle", "🔵", "Emoji")
  hs_lv_emoji.Add(, "`~bug", "🕷️", "Emoji")
  hs_lv_emoji.Add(, "`~check", "✔️", "Emoji")
  hs_lv_emoji.Add(, "`~checkmark", "✅", "Emoji")
  hs_lv_emoji.Add(, "`~clock", "⏰", "Emoji")
  hs_lv_emoji.Add(, "`~crossmark", "❎", "Emoji")
  hs_lv_emoji.Add(, "`~error", "❗", "Emoji")
  hs_lv_emoji.Add(, "`~file", "📄", "Emoji")
  hs_lv_emoji.Add(, "`~fire", "🔥", "Emoji")
  hs_lv_emoji.Add(, "`~folder", "📁", "Emoji")
  hs_lv_emoji.Add(, "`~folderopen", "📂", "Emoji")
  hs_lv_emoji.Add(, "`~greencircle", "🟢", "Emoji")
  hs_lv_emoji.Add(, "`~heart", "❤️", "Emoji")
  hs_lv_emoji.Add(, "`~home", "🏠", "Emoji")
  hs_lv_emoji.Add(, "`~info", "ℹ️", "Emoji")
  hs_lv_emoji.Add(, "`~lightbulb", "💡", "Emoji")
  hs_lv_emoji.Add(, "`~link", "🔗", "Emoji")
  hs_lv_emoji.Add(, "`~lookup", "🔍", "Emoji")
  hs_lv_emoji.Add(, "`~noob", "🔰", "Emoji")
  hs_lv_emoji.Add(, "`~ok", "👌", "Emoji")
  hs_lv_emoji.Add(, "`~purplecircle", "🟣", "Emoji")
  hs_lv_emoji.Add(, "`~question", "❓", "Emoji")
  hs_lv_emoji.Add(, "`~sarcsmile", "🙃", "Emoji")
  hs_lv_emoji.Add(, "`~search", "🔎", "Emoji")
  hs_lv_emoji.Add(, "`~smile", "😀", "Emoji")
  hs_lv_emoji.Add(, "`~star", "⭐", "Emoji")
  hs_lv_emoji.Add(, "`~thumbsdown", "👎", "Emoji")
  hs_lv_emoji.Add(, "`~thumbsup", "👍", "Emoji")
  hs_lv_emoji.Add(, "`~wait", "⏳", "Emoji")
  hs_lv_emoji.Add(, "`~warning", "⚠️", "Emoji")
  hs_lv_emoji.Add(, "`~x", "❌", "Emoji")
  hs_lv_emoji.Add(, "`~yellowcircle", "🟡", "Emoji")
  hs_lv_emoji.Add(, "`~zap", "⚡", "Emoji")
  hs_lv_emoji.ModifyCol(1)
  hs_lv_emoji.ModifyCol(2, 100)
  hs_lv_emoji.ModifyCol(3, 100)
  hs_lv_emoji.Opt("+Redraw")
  hs_lv_emoji.Visible := false

  ; ASCII Art / Boxes
  hs_lv_boxes := aboutDlg.Add("ListView", "x16 y185 w732 r12 vhs_lv_boxes", ["Hotstring", "Description", "Comments"])
  hs_lv_boxes.Opt("+Report")
  hs_lv_boxes.Opt("-Redraw")
  hs_lv_boxes.Add(, "##sbox##", "A simple box", "")
  hs_lv_boxes.Add(, "##stable##", "A simple table", "")
  hs_lv_boxes.Add(, "##rbox##", "A round-cornered box", "")
  hs_lv_boxes.Add(, "##insert-row##", "Insert a row above the current line", "")
  hs_lv_boxes.Add(, "##split-row##", "Split a row", "")
  hs_lv_boxes.Add(, "##rtable##", "A round-cornered table", "")
  hs_lv_boxes.Add(, "##tbox##", "A complex ASCII box", "")
  hs_lv_boxes.Add(, "##tbox-thick##", "A thick-bordered box", "")
  hs_lv_boxes.ModifyCol(1)
  hs_lv_boxes.ModifyCol(2)
  hs_lv_boxes.ModifyCol(3, 100)
  hs_lv_boxes.Opt("+Redraw")
  hs_lv_boxes.Visible := false

  hs_lv_custom := aboutDlg.Add("ListView", "x16 y185 w732 r12 vhs_lv_custom", ["Hotstring", "Example Replacement", "Comments"])
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

  ; ╭───────────────────────────────────────────────────────────────────────────────────────╮
  ; │ Tab 4 - Window Management                                                             │
  ; ╰───────────────────────────────────────────────────────────────────────────────────────╯
  mainTab.UseTab(4)
  aboutDlg.SetFont("c000000 Bold q5 s11", "Segoe UI")
  aboutDlg.Add("Text", "x16 y74 w732 h60", "Control to the size and location of an active window with hotkeys and mouse-based adjustments!")

  ; ; --- Radio Buttons and Dynamic ListViews ---

  ; ; GroupBox for visual clarity (optional)
  ; aboutDlg.SetFont("c000000 Bold q5 s10", "Segoe UI")
  ; aboutDlg.Add("GroupBox", "x16 y100 w732 h50", "Modality")

  ; ; Radio Buttons (horizontal)
  ; aboutDlg.SetFont("c000000 Norm q5 s10", "Segoe UI")
  ; wm_rb_keeb := aboutDlg.Add("Radio", "x32 y120 w120 h23 ", "")
  ; wm_rb_keyclick := aboutDlg.Add("Radio", "x172 y120 w200 h23 ", "CapsLock ⇪  + Mouse 🖱️ ")

  ; wm_rb_keeb.Value := true ; Default selection
  ; ListViews for each category (stacked, only one visible at a time)
  aboutDlg.SetFont("c353881 Norm q5 s10", "Segoe UI")
  wm_lv_keeb := aboutDlg.Add("ListView", "x16 y100 w732 r19 vwm_lv_keeb", ["Action", "Hotkey", "Description"])
  wm_lv_keeb.Opt("+Report") ; +Sort")
  wm_lv_keeb.Opt("-Redraw")
  wm_lv_keeb.Add(, "Resize Window to 70%", "[Ctrl/^] [Alt/⌥] ⊞ /", "Resize the window to 70% of the monitor.")
  wm_lv_keeb.Add(, "Shrink current window", "[Ctrl/^] [Alt/⌥] ⊞ <", "5% smaller")
  wm_lv_keeb.Add(, "Expand current window", "[Ctrl/^] [Alt/⌥] ⊞ >", "5% larger")
  wm_lv_keeb.Add(, "Extend current window's top border", "[Ctrl/^] [Alt/⌥] I", "Extend windo to the top of the screen")
  wm_lv_keeb.Add(, "Extend current window's bottom border", "[Ctrl/^] [Alt/⌥] K", "Extend windo to the bottom of the screen")
  wm_lv_keeb.Add(, "Extend current window's left border", "[Ctrl/^] [Alt/⌥] J", "Extend windo to the left of the screen")
  wm_lv_keeb.Add(, "Extend current window's right border", "[Ctrl/^] [Alt/⌥] L", "Extend windo to the right of the screen")
  wm_lv_keeb.Add(, "Resize window with mouse", "[Ctrl/^] [Alt/⌥] ⊞ Right🖱️ drag", "Extend windo to the right of the screen")
  wm_lv_keeb.Add(, "Move window up", "[Ctrl/^] [Alt/⌥] ⊞ I", "Move window up by 10%")
  wm_lv_keeb.Add(, "Move window down", "[Ctrl/^] [Alt/⌥] ⊞ K", "Move window down by 10%")
  wm_lv_keeb.Add(, "Move window left", "[Ctrl/^] [Alt/⌥] ⊞ J", "Move window left by 10%")
  wm_lv_keeb.Add(, "Move window right", "[Ctrl/^] [Alt/⌥] ⊞ L", "Move window right by 10%"),
    wm_lv_keeb.Add(, "Move window with mouse", "[Ctrl/^] [Alt/⌥] ⊞ Left🖱️ drag", "Move window with mouse")
  ; wm_lv_keeb.Add(, "Move Window to Center", "[Ctrl/^] [Alt/⌥] ⊞ M", "Move the window to the center of the monitor.")
  wm_lv_keeb.Add(, "Expand Window Vertically", "[Ctrl/^] [Alt/⌥] [Shift/⇧] I", "Expand the window vertically.")
  wm_lv_keeb.Add(, "Shrink Window Vertically", "[Ctrl/^] [Alt/⌥] [Shift/⇧] J", "Shrink the window vertically.")
  wm_lv_keeb.Add(, "Expand Window Horizontally", "[Ctrl/^] [Alt/⌥] [Shift/⇧] K", "Expand the window horizontally.")
  wm_lv_keeb.Add(, "Shrink Window Horizontally", "[Ctrl/^] [Alt/⌥] [Shift/⇧] L", "Shrink the window horizontally.")

  wm_lv_keeb.ModifyCol(1) ; Auto-size the first column
  wm_lv_keeb.ModifyCol(2) ; Auto-size the second column
  wm_lv_keeb.ModifyCol(3)
  wm_lv_keeb.Opt("+Redraw")

  ; ╭───────────────────────────────────────────────────────────────────────────────────────╮
  ; │ Tab 5 - Arpeggios                                                                     │
  ; ╰───────────────────────────────────────────────────────────────────────────────────────╯
  mainTab.UseTab(5)
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


  ; ╭───────────────────────────────────────────────────────────────────────────────────────╮
  ; │ Tab 6 - App Controls                                                                │
  ; ╰───────────────────────────────────────────────────────────────────────────────────────╯

  ; ╭───────────────────────────────────────────────────────────────────────────────────────╮
  ; │ Tab 7 - Other Options                                                                 │
  ; ╰───────────────────────────────────────────────────────────────────────────────────────╯

  ; ╭───────────────────────────────────────────────────────────────────────────────────────╮
  ; │ Tab 8 - This.Info                                                                     │
  ; ╰───────────────────────────────────────────────────────────────────────────────────────╯
  mainTab.UseTab(8)
  aboutDlg.SetFont("Bold s11", "Segoe UI")
  aboutDlg.Add("Text", "x16 y74 w705 h23", "ThisSystem.Info")

  ; Host information container
  aboutDlg.SetFont("c353881 Norm q5 s10", "Segoe UI")

  ; Create text controls with copy buttons
  yPos := 100
  spacing := 24

  ; Host Name

  aboutDlg.Add("Text", "x20 y" yPos " w120", "Host Name:")
  hostText := aboutDlg.Add("Text", "yp", A_ComputerName)
  copyBtn1 := aboutDlg.Add("Picture", "yp+0 w14 h14", A_ScriptDir "\media\icons\icons8-copy-16.png")
  copyBtn1.OnEvent("Click", (*) => CopyToClipboard(A_ComputerName))

  ; Current User
  yPos += spacing
  aboutDlg.Add("Text", "x20 y" yPos " w120", "Current User:")
  userText := aboutDlg.Add("Text", "yp", A_UserName . (A_IsAdmin ? " (Admin)" : ""))
  copyBtn2 := aboutDlg.Add("Picture", "yp+0 w14 h14", A_ScriptDir "\media\icons\icons8-copy-16.png")
  copyBtn2.OnEvent("Click", (*) => CopyToClipboard(A_UserName . (A_IsAdmin ? " (Admin)" : "")))

  ; OS Version
  yPos += spacing
  aboutDlg.Add("Text", "x20 y" yPos " w120", "OS Version:")
  osText := aboutDlg.Add("Text", "yp", A_OSVersion)
  copyBtn3 := aboutDlg.Add("Picture", "yp+0 w14 h14", A_ScriptDir "\media\icons\icons8-copy-16.png")
  copyBtn3.OnEvent("Click", (*) => CopyToClipboard(A_OSVersion))

  ; Word Size
  yPos += spacing
  aboutDlg.Add("Text", "x20 y" yPos " w120", "Word Size:")
  wordText := aboutDlg.Add("Text", "yp", A_Is64bitOS ? "64-bit" : "32-bit")
  copyBtn4 := aboutDlg.Add("Picture", "yp+0 w14 h14", A_ScriptDir "\media\icons\icons8-copy-16.png")
  copyBtn4.OnEvent("Click", (*) => CopyToClipboard(A_Is64bitOS ? "64-bit" : "32-bit"))

  ; CPU Info
  yPos += spacing
  aboutDlg.Add("Text", "x20 y" yPos " w120", "CPU:")
  cpuProperty := "Click here to display CPU info" ; . ThisPC.CPUInfo.Name
  cpuText := aboutDlg.Add("Text", "yp w400", cpuProperty)
  ; Pass an info type and the control reference so GetPCInfo can
  ; replace the control and rebind the copy button correctly.
  cpuText.OnEvent("Click", (*) => GetPCInfo("CPUInfo"))
  ; copyBtn5 := aboutDlg.Add("Picture", "xm yp+0 w14 h14 Hidden", A_ScriptDir "\media\icons\icons8-copy-16.png")
  ; copyBtn5.OnEvent("Click", (*) => CopyToClipboard(cpuProperty))

  ; ; Memory
  ; yPos += spacing
  ; aboutDlg.Add("Text", "x20 y" yPos " w120", "Memory:")
  ; memText := aboutDlg.Add("Text", "yp", "xx GiB/ 127.78 GiB")
  ; copyBtn6 := aboutDlg.Add("Picture", "yp+0 w14 h14", A_ScriptDir "\media\icons\icons8-copy-16.png")
  ; copyBtn6.OnEvent("Click", (*) => CopyToClipboard(memText.Text))

  ; ; Local IP
  ; yPos += spacing
  ; aboutDlg.Add("Text", "x20 y" yPos " w120", "Local IP:")
  ; ipText := aboutDlg.Add("Text", "yp", "192.168.1.1")
  ; copyBtn7 := aboutDlg.Add("Picture", "yp+0 w14 h14", A_ScriptDir "\media\icons\icons8-copy-16.png")
  ; copyBtn7.OnEvent("Click", (*) => CopyToClipboard(ipText.Text))

  ; ; External IP
  ; yPos += spacing
  ; aboutDlg.Add("Text", "x20 y" yPos " w120", "External IP:")
  ; extIpText := aboutDlg.Add("Text", "yp", "xxx.xxx.xxx.xxx")
  ; copyBtn8 := aboutDlg.Add("Picture", "yp+0 w14 h14", A_ScriptDir "\media\icons\icons8-copy-16.png")
  ; copyBtn8.OnEvent("Click", (*) => CopyToClipboard(extIpText.Text))

  aboutDlg.Title := "Mello.Ops - About"
  return aboutDlg


}

/*
╭───────────────────╮
│ HELPER FUNCTION: GetPCInfo(
│   _GuiControlObj(Object): Built-in parameter containing the GUIControlObject that calls this function.  │
│   infoType(String)      : Built-in parameter containing the GUIControlObject that calls this function.  │
╰───────────────────╯*/
GetPCInfo(_GuiControlObj, infoType := "CPUInfo") {
  ; Helper: collect PC info, replace the calling GUI control
  ; with a new Text control containing the full cpuProperty string,
  ; then show and bind the copy button to copy that value.
  cpuText.Text := "Please wait..."
  ThisPC.CollectInfo()
  cpuProperty := ThisPC.CPUInfo.Name . " (" . ThisPC.CPUInfo.NumberOfCores . "/" . ThisPC.CPUInfo.NumberOfLogicalProcessors . ") @ " . Round(ThisPC.CPUInfo.MaxClockSpeed / 1000, 1) . "GHz"

  ; If we received the calling control as an object, remove or hide it.
  if (IsObject(_GuiControlObj)) {
    _GuiControlObj.Delete()
  }

  ; Create a new Text control populated with the expanded CPU info
  newCpuText := aboutDlg.Add("Text", "yp w400", cpuProperty)
  newCpuText.Value := cpuProperty

  ; Point outer-scope cpuText at the new control so other code uses it
  cpuText := newCpuText

  ; Measure the rendered text width and size the control accordingly
  hDC := DllCall("GetDC", "Ptr", cpuText.Hwnd, "Ptr")
  hFont := DllCall("SendMessage", "Ptr", cpuText.Hwnd, "UInt", 0x31, "Ptr", 0, "Ptr")
  hOldFont := DllCall("SelectObject", "Ptr", hDC, "Ptr", hFont, "Ptr")

  size := Buffer(8)
  DllCall("GetTextExtentPoint32", "Ptr", hDC, "Str", cpuProperty, "Int", StrLen(cpuProperty), "Ptr", size.Ptr)
  textWidth := NumGet(size, 0, "Int") + 8

  DllCall("SelectObject", "Ptr", hDC, "Ptr", hOldFont)
  DllCall("ReleaseDC", "Ptr", cpuText.Hwnd, "Ptr", hDC)

  cpuText.Move(, , textWidth)

  ; Reuse the existing hidden copy button if present, otherwise create one.
  try {
    if (!IsObject(copyBtn5))
      throw "no-copy-btn"
    copyBtn5.Visible := true
    cpuText.GetPos(&_textGuiXPos, &__, &_textGuiWidth, &__)
    ; Move the copy button just after the text control
    copyBtn5.Move(_textGuiXPos + _textGuiWidth + 6, , 14, 14)
    copyBtn5.OnEvent("Click", (*) => CopyToClipboard(cpuText.Value))
  } catch {
    copyBtn5 := aboutDlg.Add("Picture", "xm yp+0 w14 h14", A_ScriptDir "\media\icons\icons8-copy-16.png")
    copyBtn5.OnEvent("Click", (*) => CopyToClipboard(cpuText.Value))
  }

  ; Rebind the text control so clicking it refreshes the info again.
}

; Function to copy text to clipboard
CopyToClipboard(text, *) {
  A_Clipboard := text
  ToolTip("Copied to clipboard!", , , 1)
  SetTimer () => ToolTip(, , , 1), -1000
  return
}

GetTerminalInfo() {
  info := Map("IsTerminalHost", false, "HostProcess", "", "ParentChain", "")
  try {
    pid := DllCall("GetCurrentProcessId")
    parent := 0
    for p in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where ProcessId=" pid) {
      parent := p.ParentProcessId
      break
    }
    chain := []
    depth := 0
    while parent && depth < 8 {
      for q in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where ProcessId=" parent) {
        name := q.Name
        path := q.ExecutablePath ? q.ExecutablePath : ""
        entry := name
        if path
          entry := entry " (" path ")"
        chain.Push(entry)
        lname := StrLower(name)
        if (lname = "wt.exe" || lname = "windowsterminal.exe") {
          info.IsTerminalHost := true
          info.HostProcess := name
          parent := 0
          break
        }
        parent := q.ParentProcessId
      }
      depth++
    }
    ; Build parent chain string
    parentChain := ""
    for i, e in chain {
      parentChain := (i = 1) ? e : parentChain " <- " e
    }
    info.ParentChain := parentChain
  } catch {
  }
  return info
}