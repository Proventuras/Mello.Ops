#Requires Autohotkey v2

/*
  ╭────────────────────────────────────────────────────────────────────╮
  │ About...Dialog Box                                                 │
  │ The dialog box the appears when you select "About FLOW Effortless" │
  ├────────────────────────────────────────────────────────────────────┤
  │                                                                    │
  ╰────────────────────────────────────────────────────────────────────╯
*/
; class CPUInfo {
;   static Name := ""
;   static Manufacturer := ""
;   static Description := ""
;   static NumberOfCores := ""
;   static NumberOfLogicalProcessors := ""
;   static MaxClockSpeed := ""
;   static Architecture := ""
;   static ProcessorId := ""

;   static Init() {
;     for cpu in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Processor") {
;       CPUInfo.Name := cpu.Name
;       CPUInfo.Manufacturer := cpu.Manufacturer
;       CPUInfo.Description := cpu.Description
;       CPUInfo.NumberOfCores := cpu.NumberOfCores
;       CPUInfo.NumberOfLogicalProcessors := cpu.NumberOfLogicalProcessors
;       CPUInfo.MaxClockSpeed := cpu.MaxClockSpeed
;       CPUInfo.Architecture := cpu.Architecture
;       CPUInfo.ProcessorId := cpu.ProcessorId
;       break ; Only use the first CPU
;     }
;   }
; }

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


  ; Dialog Construction
  aboutDlg := Gui()
  aboutDlg.SetFont("q5 s11", "Segoe UI")
  aboutDlg.Opt("-MinimizeBox -MaximizeBox +AlwaysOnTop")

  ; First Line with link to docs
  aboutDlg.Add("Link", "x9 y12 h23",
    "All items below are frequently used features. Visit the <a href=`"https://github.com/Proventuras/Mello.Ops/tree/main/docs`">Official Documentation</a> for a more comprehensive list."
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
      "Higher F-Keys  ",
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

  ; Credit Section and Links to other resources
  aboutDlg.SetFont("c039314 Bold q5 s11", "Segoe UI")
  aboutDlg.Add("Text", "x72 y400 w600 h23", "Credits and Resources")  ; Fixed location
  aboutDlg.SetFont("c000000 Norm q5 s10", "Segoe UI")
  aboutDlg.Add("Picture", "x72 y+0 w16 h16", A_ScriptDir "\media\icons\autohotkey.ico")
  aboutDlg.Add("Link", "yp w400 h23",
    "AutoHotkey (version " A_AhkVersion ") is available at <a href=`"https://www.autohotkey.com`">autohotkey.com</a>")

  aboutDlg.Add("Picture", "x70 yp+20 w20 h20", A_ScriptDir "\media\icons\icons8.ico")
  aboutDlg.Add("Link", "yp w600 h23", "Icons by <a href=`"https://icons8.com`">icons8.com</a>")

  aboutDlg.Add("Picture", "x70 yp+20 w20 h20", A_ScriptDir "\media\icons\icons8-github-windows-10-16.png")
  aboutDlg.Add("Link", "yp w600 h23",
    "<a href=`"https://www.autohotkey.com/boards/viewtopic.php?f=83&t=94044`">WiseGUI.ahk library</a> by <a href=`"https://www.autohotkey.com/boards/memberlist.php?mode=viewprofile&u=54&sid=f3bac845536fc1eace03994a9e73273e`">SKAN</a>")

  aboutDlg.Add("Picture", "x70 yp+20 w20 h20", A_ScriptDir "\media\icons\icons8-github-windows-10-16.png")
  aboutDlg.Add("Link", "yp w300 h23",
    "<a href=`"https://github.com/FuPeiJiang/VD.ahk/tree/v2_port`">VD.ahk library</a> by <a href=`"https://github.com/FuPeiJiang`">FuPeiJiang</a>")
  ; aboutDlg.Add("Link", "x72 y270 w300 h23",
  ; "<a href=`"https://github.com/Ciantic/VirtualDesktopAccessor`">VirtualDesktopAccessor</a> by <a href=`"https://github.com/Ciantic`">Ciantic</a>")

  ; ╭───────────────────────────────────────────────────────────────────────────────────────╮
  ; │ Tab 2 - Hotkeys                                                                       │
  ; ╰───────────────────────────────────────────────────────────────────────────────────────╯
  mainTab.UseTab(2)
  ; aboutDlg.SetFont("norm s11", "Segoe UI")
  ; aboutDlg.Add("Text", "x16 y78 w690 h26", "Hotkeys")
  aboutDlg.SetFont("Bold s11", "Segoe UI")
  aboutDlg.Add("Text", "x16 y74 w705 h23", "Hotkeys = keyboard shortcuts. Go ahead and try them out!")

  ; --- Radio Buttons and Dynamic ListViews ---
  ; GroupBox for visual clarity (optional)
  aboutDlg.SetFont("Bold s10", "Segoe UI")
  aboutDlg.Add("GroupBox", "x16 y100 w732 h50", "Hotkey Groups")

  ; Radio Buttons (horizontal)
  aboutDlg.SetFont("Norm s10", "Segoe UI")
  hk_rb_core := aboutDlg.Add("Radio", "x32 y118 h23 vhk_rb_core", "Core Hotkeys")
  hk_rb_aux := aboutDlg.Add("Radio", "xp+200 h23 vhk_rb_aux", "Aux Hotkeys")

  hk_rb_core.Value := true ; Default selection
  aboutDlg.SetFont("c000000 Norm q5 s11", "Segoe UI")
  aboutDlg.Add("Text", "x16 y155 w732 h54 vhk_rb_text", "Hotkeys - Keyboard Shortcuts")

  ; Add ListView for Hotkeys
  aboutDlg.SetFont("c353881 Norm q5 s10", "Segoe UI")
  lv_corehkeys := aboutDlg.Add("ListView", "x16 y185 w732 r15 c353881", ["Action", "Hotkey", "Description"])
  lv_corehkeys.Opt("+Report") ; +Sort")

  ; Example hotkeys - replace/add as needed for your project
  lv_corehkeys.Opt("+Report") ; +Sort")
  lv_corehkeys.Opt("-Redraw")
  lv_corehkeys.Add(, "Reload and Restart " thisapp_name, "[Ctrl] + [⊞] + [Alt] + [R] ", "Reload and restart " thisapp_name)
  lv_corehkeys.Add(, "AutoHotkey Help", "[Ctrl] + [⊞] + [Alt] + [F2]`t", "Open the AutoHotkey help docs")
  lv_corehkeys.Add(, "Sleep", "[Ctrl] + [⊞] + [Alt] + [F12]`t", "Put this system to sleep")
  lv_corehkeys.Add(, thisapp_name " Help", "[Ctrl] + [⊞] + [Alt] + [F1]`t", "Display this dialog")
  lv_corehkeys.Add(, "Open the user's folder", "[⊞] + [F]`t", "Open the user's Documents folder in File Explorer")
  lv_corehkeys.Add(, "Edit this script", "[Ctrl] + [⊞] + [Alt] + [E]`t", "Open the main " thisapp_name " script (default editor)")
  lv_corehkeys.Add(, "Open the " thisapp_name " folder", "[Ctrl] + [⊞] + [Alt] + [F]`t", "Open the " thisapp_name " folder in File Explorer")
  lv_corehkeys.Add(, "Windows Terminal", "[Ctrl] + [Alt] + [T]`t", "Open or focus the Windows Terminal window")
  lv_corehkeys.Add(, "Windows Terminal (Elevated)", "[Ctrl] + [Shift] + [Alt] + [T]`t", "Open an elevated Windows Terminal instance")
  lv_corehkeys.Add(, "Open Calculator", "2 × [Right_Ctrl]`t", "Open or focus the Calculator app")
  lv_corehkeys.ModifyCol() ; Auto-size the first column
  lv_corehkeys.ModifyCol(2) ; Auto-size the second column
  lv_corehkeys.ModifyCol(3)
  lv_corehkeys.Opt("+Redraw")

  ; Example hotkeys - replace/add as needed for your project
  lv_auxhkeys := aboutDlg.Add("ListView", "x16 y185 w732 r12 vhk_lv_aux", ["Action", "Hotkey", "Description"])
  lv_auxhkeys.Opt("+Report")
  lv_auxhkeys.Opt("-Redraw")
  lv_auxhkeys.Add(, "Yayaya " thisapp_name, "[Ctrl] + [⊞] + [Alt] + [R] ", "Reload and restart " thisapp_name)
  lv_auxhkeys.Add(, "Yayay Help", "[Ctrl] + [⊞] + [Alt] + [F2]`t", "Open the AutoHotkey help docs")
  lv_auxhkeys.ModifyCol() ; Auto-size the first column
  lv_auxhkeys.ModifyCol(2) ; Auto-size the second column
  lv_auxhkeys.ModifyCol(3)
  lv_auxhkeys.Opt("+Redraw")
  lv_auxhkeys.Visible := false

  ; Handler to switch ListViews
  hk_switchListView(*) {
    lv_corehkeys.Visible := hk_rb_core.Value
    lv_auxhkeys.Visible := hk_rb_aux.Value
    if (hk_rb_core.Value)
      aboutDlg["hk_rb_text"].Value := "Core Hotkeys are required to manage this utiliy, or use alternative modifiers, double-press, etc."
    else if (hk_rb_aux.Value)
      aboutDlg["hs_rb_text"].Value := "Aux Hotkeys can be redefined or use traditional modifier keys."
  }
  hk_rb_core.OnEvent("Click", hk_switchListView)
  hk_rb_aux.OnEvent("Click", hk_switchListView)

  ; ╭───────────────────────────────────────────────────────────────────────────────────────╮
  ; │ Tab 3 - Hotstrings                                                                    │
  ; ╰───────────────────────────────────────────────────────────────────────────────────────╯
  mainTab.UseTab(3)
  ; aboutDlg.SetFont("Bold s10", "Segoe UI")
  ; aboutDlg.Add("Text", "x16 y70 w690 h30", "Hotstrings")
  aboutDlg.SetFont("c000000 Bold q5 s11", "Segoe UI")
  aboutDlg.Add("Text", "x16 y74 w705 h54", "Hotstrings = string replacements. Just hit [End] or [Enter] to expand them!")
  aboutDlg.SetFont("c000000 Norm q5 s11", "Segoe UI")

  ; --- Radio Buttons and Dynamic ListViews ---
  ; GroupBox for visual clarity (optional)
  aboutDlg.SetFont("Bold s10", "Segoe UI")
  aboutDlg.Add("GroupBox", "x16 y100 w732 h50", "Hotstring Groups")

  ; Radio Buttons (horizontal)
  aboutDlg.SetFont("Norm s10", "Segoe UI")
  hs_rb_ansi := aboutDlg.Add("Radio", "x32 y120 w90 h23 vhs_rb_ansi", "ANSI")
  hs_rb_kaomoji := aboutDlg.Add("Radio", "x120 y120 w90 h23 vhs_rb_kaomoji", "Kaomoji")
  hs_rb_emoji := aboutDlg.Add("Radio", "x220 y120 w90 h23 vhs_rb_emoji", "Emojis")
  hs_rb_boxes := aboutDlg.Add("Radio", "x320 y120 w100 h23 vhs_rb_boxes", "Tables `& Boxes")
  hs_rb_custom := aboutDlg.Add("Radio", "x460 y120 w90 h23 vhs_rb_custom", "Custom")

  hs_rb_ansi.Value := true ; Default selection
  aboutDlg.SetFont("c000000 Norm q5 s11", "Segoe UI")
  aboutDlg.Add("Text", "x16 y155 w732 h54 vhs_rb_text", "Aux Hotstrings include optional expansions and modifiers for advanced use.")

  ; ANSI/ASCII Alt Codes
  aboutDlg.SetFont("c353881 Norm q5 s10", "Segoe UI")
  hs_lv_ansi := aboutDlg.Add("ListView", "x16 y185 w732 r15 vhs_lv_ansi", ["Hotstring", "Replacement", "Comments"])
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
  ; aboutDlg.SetFont("c353881 Norm q5 s11", "Segoe UI")
  hs_lv_kaomoji := aboutDlg.Add("ListView", "x16 y185 w732 r12 vhs_lv_kaomoji", ["Hotstring", "Replacement", "Comments"])
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
  hs_lv_kaomoji.Visible := false

  ; Emojis/
  ; aboutDlg.SetFont("c353881 Norm q5 s11", "Segoe UI")
  hs_lv_emoji := aboutDlg.Add("ListView", "x16 y185 w732 r12 vhs_lv_emoji", ["Hotstring", "Replacement", "Comments"])
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
  hs_lv_emoji.Visible := false

  ; ASCII Art / Boxes
  ; aboutDlg.SetFont("c353881 Norm q5 s11", "Segoe UI")
  hs_lv_boxes := aboutDlg.Add("ListView", "x16 y185 w732 r12 vhs_lv_boxes", ["Hotstring", "Replacement", "Comments"])
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
  aboutDlg.Add("Text", "x16 y74 w732 h60", "Give yourself more control to the size and location of an active window with the CapsLock(⇪) key!")

  ; --- Radio Buttons and Dynamic ListViews ---

  ; GroupBox for visual clarity (optional)
  aboutDlg.SetFont("c000000 Bold q5 s10", "Segoe UI")
  aboutDlg.Add("GroupBox", "x16 y100 w732 h50", "Modality")

  ; Radio Buttons (horizontal)
  aboutDlg.SetFont("c000000 Norm q5 s10", "Segoe UI")
  wm_rb_keeb := aboutDlg.Add("Radio", "x32 y120 w120 h23 ", "CapsLock ⇪ Only")
  wm_rb_keyclick := aboutDlg.Add("Radio", "x172 y120 w200 h23 ", "CapsLock ⇪  + Mouse 🖱️ ")

  wm_rb_keeb.Value := true ; Default selection
  ; ListViews for each category (stacked, only one visible at a time)
  aboutDlg.SetFont("c353881 Norm q5 s10", "Segoe UI")
  wm_lv_keeb := aboutDlg.Add("ListView", "x16 y185 w732 r15 vwm_lv_keeb", ["Action", "Hotkey", "Description"])
  wm_lv_keeb.Opt("+Report") ; +Sort")
  wm_lv_keeb.Opt("-Redraw")
  wm_lv_keeb.Add(, "Resize Window to 70%", "[CapsLock] + [/]`t", "Resize the window to 70% of the monitor.")
  wm_lv_keeb.Add(, "Decrease Window Size", "[CapsLock] + [LBracket]`t", "Decrease window size by 5%.")
  wm_lv_keeb.Add(, "Increase Window Size", "[CapsLock] + [RBracket]`t", "Increase window size by 5%.")
  wm_lv_keeb.Add(, "Move Window Up", "[CapsLock] + [↑]`t", "Move the window up.")
  wm_lv_keeb.Add(, "Move Window Down", "[CapsLock] + [↓]`t", "Move the window down.")
  wm_lv_keeb.Add(, "Move Window Left", "[CapsLock] + [←]`t", "Move the window left.")
  wm_lv_keeb.Add(, "Move Window Right", "[CapsLock] + [→]`t", "Move the window right.")
  wm_lv_keeb.Add(, "Expand Window Vertically", "[CapsLock] + [Ctrl] + [↑]`t", "Expand the window vertically.")
  wm_lv_keeb.Add(, "Shrink Window Vertically", "[CapsLock] + [Ctrl] + [↓]`t", "Shrink the window vertically.")
  wm_lv_keeb.Add(, "Expand Window Horizontally", "[CapsLock] + [Ctrl] + [→]`t", "Expand the window horizontally.")
  wm_lv_keeb.Add(, "Shrink Window Horizontally", "[CapsLock] + [Ctrl] + [←]`t", "Shrink the window horizontally.")
  wm_lv_keeb.Add(, "Extend Window to Top", "[CapsLock] + [Alt] + [↑]`t", "Extend the window to the top of the monitor.")
  wm_lv_keeb.Add(, "Extend Window to Bottom", "[CapsLock] + [Alt] + [↓]`t", "Extend the window to the bottom of the monitor.")
  wm_lv_keeb.Add(, "Extend Window to Left", "[CapsLock] + [Alt] + [←]`t", "Extend the window to the left of the monitor.")
  wm_lv_keeb.Add(, "Extend Window to Right", "[CapsLock] + [Alt] + [→]`t", "Extend the window to the right of the monitor.")
  wm_lv_keeb.Add(, "Move Window to Center", "[CapsLock] + [Ctrl] + [M]`t", "Move the window to the center of the monitor.")

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
  ; │ Tab 6 - Higher F-Keys                                                                 │
  ; ╰───────────────────────────────────────────────────────────────────────────────────────╯

  ; ╭───────────────────────────────────────────────────────────────────────────────────────╮
  ; │ Tab 7 - Other Options                                                                 │
  ; ╰───────────────────────────────────────────────────────────────────────────────────────╯

  ; ╭───────────────────────────────────────────────────────────────────────────────────────╮
  ; │ Tab 8 - This.Info                                                                     │
  ; ╰───────────────────────────────────────────────────────────────────────────────────────╯
  mainTab.UseTab(8)
  aboutDlg.SetFont("Bold s11", "Segoe UI")
  aboutDlg.Add("Text", "x16 y74 w705 h23", "This.Info")

  ; Host information container
  aboutDlg.SetFont("c353881 Norm q5 s10", "Segoe UI")

  ; Function to copy text to clipboard
  CopyToClipboard(text, *) {
    A_Clipboard := text
    ToolTip("Copied to clipboard!", , , 1)
    SetTimer () => ToolTip(, , , 1), -1000
  }

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
  cpuText := aboutDlg.Add("Text", "yp", cpuProperty)
  cpuText.OnEvent("Click", (*) => GetPCInfo())
  copyBtn5 := aboutDlg.Add("Picture", "xm yp+0 w14 h14 Hidden", A_ScriptDir "\media\icons\icons8-copy-16.png")
  copyBtn5.OnEvent("Click", (*) => CopyToClipboard(cpuProperty))

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

  ; ╭──╮
  ; │ Helper function: GetPCInfo()  │
  ; ╰──╯
  GetPCInfo(*) {
    cpuText.Text := "Please wait..."
    ThisPC.CollectInfo()
    cpuProperty := ThisPC.CPUInfo.Name ; . " (" . ThisPC.CPUInfo.NumberOfCores . "/" . ThisPC.CPUInfo.NumberOfLogicalProcessors . ") @ " . Round(ThisPC.CPUInfo.MaxClockSpeed / 1000, 1) . "GHz"
    copyBtn5.Visible := true
    cpuText.Text := cpuProperty

  }
}