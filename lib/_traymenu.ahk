#Requires AutoHotkey v2.0

; ╭───────────╮
; │ VARIABLES │
; ╰───────────╯
tray_icon_normal := ".\media\icons\Mello.Ops.ico"
tray_icon_pause_all := ".\media\icons\sl-pause.ico"
tray_icon_pause_hotkeys := ".\media\icons\sl-pause.ico"
tray_icon_pause_hotstrings := ".\media\icons\sl-pause-hs.ico"
tray_icon_suspend := ".\media\icons\sl-suspended.ico"
traymenu_icon_checked := ".\media\icons\checked.ico"
traymenu_icon_unchecked := ".\media\icons\unchecked.ico"

; custom tray menu items
trayitem_app_ref := "About Mello.Ops`t[Ctrl]+[⊞]+[Alt]+[F1]"
trayitem_app_ref_ico := tray_icon_normal
trayitem_reload := "&Reload Script`t[Ctrl]+[⊞]+[Alt]+[R]"
trayitem_reload_ico := ".\media\icons\reload.ico"
trayitem_toggle_hstrings := "&Text Expansions"            ; `t[Ctrl]+[⊞]+[Alt]+[S]"
trayitem_toggle_hstrings_ico := traymenu_icon_checked
trayitem_toggle_hkeys := "&Keyboard Shortcuts"                  ; `t[Ctrl]+[⊞]+[Alt]+[K]"
trayitem_toggle_hkeys_ico := traymenu_icon_checked
trayitem_debug := "AutoHotkey Native Tools"
trayitem_debug_ico := ".\media\icons\debug.ico"
trayitem_ahkhelp := "AutoHotkey Help`t[Ctrl]+[⊞]+[Alt]+[F2]"
trayitem_ahkhelp_ico := ".\media\icons\help.ico"
trayitem_exit := "E&xit Mello.Ops"
trayitem_exit_ico := ".\media\icons\stop.ico"
trayitem_edit := "E&dit Script`t[Ctrl]+[⊞]+[Alt]+[E]"
trayitem_edit_ico := ".\media\icons\edit.ico"
trayitem_runatstartup := "Run at Startup"
trayitem_openappdir := "Open script &folder`t[Ctrl]+[⊞]+[Alt]+[F]"
trayitem_openappdir_ico := ".\media\icons\icons8-code-folder-32.ico"

this_script_shorcut := A_Startup " \" SubStr(A_ScriptName, 1, StrLen(A_ScriptName) - 4) ".lnk"
if (FileExist(this_script_shorcut)) {
    trayitem_runatstartup_ico := traymenu_icon_checked
}
else {
    trayitem_runatstartup_ico := traymenu_icon_unchecked
}

; ╭───────────────────────╮
; │  Build the Tray menu  │
; ╰───────────────────────╯

DisplayTrayMenu() {
    /*
    ╒═══════════════════════════════════════════════════════════════════════╕
    │ Custom menu items                                                     │
    ╞═══════════════════════════════════════════════════════════════════════╡
    │ Reference: https://www.autohotkey.com/docs/v2/lib/Menu.htm#ExTray     │
    └───────────────────────────────────────────────────────────────────────┘
    */

    ; Startup sound
    SoundPlay toggle_sound_file_startrun
    ; SoundPlay "*16"

    ; Light/Dark Theme-safe colored Tray Icon
    TraySetIcon tray_icon_normal

    ; Set the Tray icon tooltip
    global Tray := A_TrayMenu ; For convenience.
    __LoadDuration := A_TickCount - __StartTime
    __LoadDuration := Round(__LoadDuration / 1000, 2) ; Convert to seconds and round to 2 decimal places
    IconTipString := "
    (
      Mello.Ops Shortcuts
      Startup Duration: `s
    )" __LoadDuration " ms
    (
      `nScript: `s
    )" A_ScriptFullPath
    A_IconTip := IconTipString

    ; Delete the standard items. Not Required unless replacing
    Tray.Delete()

    ; Define the menu items
    Tray.Add(trayitem_app_ref, ShowHelpAbout)
    Tray.SetIcon(trayitem_app_ref, trayitem_app_ref_ico)
    
    Tray.Add(trayitem_reload, ReloadAndReturn)
    Tray.SetIcon(trayitem_reload, trayitem_reload_ico)

    Tray.Add(trayitem_openappdir, OpenScriptDir)
    Tray.SetIcon(trayitem_openappdir, trayitem_openappdir_ico)

    Tray.Add(trayitem_edit, EditAndReturn)
    Tray.SetIcon(trayitem_edit, trayitem_edit_ico)

    Tray.Add(trayitem_toggle_hstrings, ToggleAuxHotstrings)
    Tray.SetIcon(trayitem_toggle_hstrings, trayitem_toggle_hstrings_ico)

    Tray.Add(trayitem_toggle_hkeys, ToggleAuxHotkeys)
    Tray.SetIcon(trayitem_toggle_hkeys, trayitem_toggle_hkeys_ico)

    Tray.Add(trayitem_runatstartup, ToggleRunAtStartup)
    Tray.SetIcon(trayitem_runatstartup, trayitem_runatstartup_ico)

    Tray.Add() ; separator

    ; AutoHotkey Native Tools
    AhkNativeMenu := Menu()
    Tray.Add("AutoHotkey Native Tools", AhkNativeMenu)
    AhkNativeMenu.Add("AutoHotkey WindowSpy", ShowAHKSpy)
    AhkNativeMenu.Add(trayitem_ahkhelp, ShowHelp)
    AhkNativeMenu.Add("Key & Mouse Button History", ShowListLines)
    AhkNativeMenu.Add("ListHotKeys", ListSimpleHotkeys)
    AhkNativeMenu.Add("Coming: KeyHistory", ShowListLines)
    AhkNativeMenu.Disable("Coming: KeyHistory")
    AhkNativeMenu.Add("Coming: ListVars", ShowListLines)
    AhkNativeMenu.Disable("Coming: ListVars")

    ; Options
    OptionsMenu := Menu()
    Tray.Add("Options", OptionsMenu)

    MouseMenu := Menu()
    OptionsMenu.Add("Mouse Cursor Actions", MouseMenu)
    MouseMenu.Add("Increase Mouse Cursor Size", IncCursorSize)
    MouseMenu.Disable("Increase Mouse Cursor Size")
    MouseMenu.Add("Decrease Mouse Cursor Size", DecCursorSize)
    MouseMenu.Disable("Decrease Mouse Cursor Size")
    MouseMenu.Add("Increase Mouse Cursor Speed", IncMouseSpeed)
    MouseMenu.Disable("Increase Mouse Cursor Speed")
    MouseMenu.Add("Decrease Mouse Cursor Speed", DecMouseSpeed)
    MouseMenu.Disable("Decrease Mouse Cursor Speed")

    OptionsMenu.Add("Toggle Light/Dark Theme", ToggleTheme)
    OptionsMenu.Disable("Toggle Light/Dark Theme")
    OptionsMenu.Add("Toggle Show/Auto-Hide Taskbar", ToggleTaskbar)
    OptionsMenu.Disable("Toggle Show/Auto-Hide Taskbar")
    OptionsMenu.Add("Toggle Show/Hide Desktop Icons", ToggleDesktopIcons)
    OptionsMenu.Disable("Toggle Show/Hide Desktop Icons")

    Tray.Add() ; separator

    ; Custom Tools
    CustomMenu := Menu()
    Tray.Add("Custom Tools", CustomMenu)
    CustomMenu.Add("Custom Notes", ShowCustomNotes)
    CustomMenu.Disable("Custom Notes")
    CustomMenu.Add("Focus Window Highlighter", ToggleWindowHighlighter)
    CustomMenu.Disable("Focus Window Highlighter")
    CustomMenu.Add("OverFlow Notifier", ToggleOverflowNotifier)
    CustomMenu.Disable("OverFlow Notifier")
    CustomMenu.Add("Chime", ToggleChime)
    CustomMenu.Disable("Chime")

    Tray.Add() ; separator

    Tray.Add(trayitem_exit, EndScript)
    Tray.SetIcon(trayitem_exit, trayitem_exit_ico)

    ; Set the default menu item for double-clicking the tray icon
    Tray.Default := trayitem_app_ref
}

; ╭─────────────────────────────────────────────────────────────────────╮
; │  Enable or Disable Auxillary hotkeys defined in AUX_HOTSTRINGS.AHK  │
; ╰─────────────────────────────────────────────────────────────────────╯
ToggleAuxHotstrings(*)
{
    global Aux_HotStringSupport := !Aux_HotStringSupport
    if (Aux_HotStringSupport = true) {
        IndicateToggle("Auxillary HotStrings", "hotkeys", true, true, true)
        trayitem_toggle_hstrings_ico := traymenu_icon_checked
    } else {
        IndicateToggle("Auxillary HotStrings", "hotkeys", false, true, true)
        trayitem_toggle_hstrings_ico := traymenu_icon_unchecked
    }

    Tray.SetIcon(trayitem_toggle_hstrings, trayitem_toggle_hstrings_ico)
}

; ╭──────────────────────────────────────────────────────────────────╮
; │  Enable or Disable Auxillary hotkeys defined in AUX_HOTKEYS.AHK  │
; ╰──────────────────────────────────────────────────────────────────╯
ToggleAuxHotkeys(*)
{
    global Aux_HotKeySupport := !Aux_HotKeySupport
    if (Aux_HotKeySupport = true) {
        IndicateToggle("Auxillary HotKeys", "hotstrings", true, true, true)
        trayitem_toggle_hkeys_ico := traymenu_icon_checked
    } else {
        IndicateToggle("Auxiliary HotKeys", "hotstrings", false, true, true)
        trayitem_toggle_hkeys_ico := traymenu_icon_unchecked
    }

    Tray.SetIcon(trayitem_toggle_hkeys, trayitem_toggle_hkeys_ico)
}

; ╭─────────────────────────────────────────────────╮
; │  This will allow the script to run at startup.  │
; ╰─────────────────────────────────────────────────╯
ToggleRunAtStartup(*)
{

    ; DEBUG
    global this_script_shorcut := A_Startup " \" SubStr(A_ScriptName, 1, StrLen(A_ScriptName) - 4) ".lnk"

    run A_Startup
    if (FileExist(this_script_shorcut)) {
        FileDelete(this_script_shorcut)
        trayitem_runatstartup_ico := traymenu_icon_unchecked
    }
    else {
        ; ICO issue fixed. See https://learn.microsoft.com/en-us/answers/questions/1162419/shortcut-icon-blank-when-ico-file-is-located-on-a
        FileCreateShortcut(A_AhkPath, this_script_shorcut, A_ScriptDir, A_ScriptFullPath, "A script", A_ScriptDir tray_icon_normal, , ,
        )
        trayitem_runatstartup_ico := traymenu_icon_checked
    }
    Tray.SetIcon(trayitem_runatstartup, trayitem_runatstartup_ico)
}

; ╭──────────────────────────────────────────────────────────────────────╮
; │  Update the Tray Menu UI to indicate if a feature is enabled or not  │
; ╰──────────────────────────────────────────────────────────────────────╯
IndicateToggle(AppFeatureName, AppFeature, IsEnabled := false, DisplayChange := false, PlaySound := false) {
    ; AppFeatureName is a string that indicates the FLOW feature being toggled

    ; AppFeature is an Evaluated string that indicates the FLOW feature being toggled
    ; Acceptable values (based on variable names): "hotkeys", "hotstrings", "all"

    ; IsEnabled is a boolean that indicates whether the FLOW feature is enabled or disabled
    if (Aux_HotStringSupport = false) and (Aux_HotKeySupport = false) {
        ; Both features are off
        AppFeature := "all"
        TraySetIcon tray_icon_pause_%AppFeature% ; Set the normal icon
    }

    ; PlaySound parameter is a boolean that indicates whether to play a sound when toggling
    if (PlaySound = true) {
        if (IsEnabled = true) {
            ; SoundPlay toggle_sound_file_enabled
            SoundPlay "*16"
        } else {
            ; SoundPlay toggle_sound_file_disabled
            SoundPlay "*48"
        }
    }

    ; DisplayChange parameter is a boolean that indicates whether to display a message when toggling
    if (DisplayChange = true) {
        if (IsEnabled = true) {
            gui_message := AppFeatureName " Enabled"
            gui_theme := "Success"
            TraySetIcon tray_icon_normal
        } else {
            gui_message := AppFeatureName " Disabled"
            gui_theme := "Warning"
            TraySetIcon tray_icon_pause_%AppFeature%
        }

        WiseGui(AppFeature
            , "Theme:       " gui_theme
            , "MainText:    " gui_message
            , "Transparency: 192"
            , "Show:         SlideWest@400ms"
            , "Hide:         SlideEast@400ms"
            , "Move:         -10, -1"
            , "Timer:        2500"
        )
    }
}

/*
╭────────────────╮
│ ShowListLines  │
╰────────────────╯ */
ShowListLines(*)
{
    ListLines
}

/*
╭────────────────────╮
│ ListSimpleHotkeys  │
╰────────────────────╯ */
ListSimpleHotkeys(*)
{
    ListHotkeys
}

/*
╭──────────────╮
│ DisplayAbout │
╰──────────────╯ */
DisplayAbout(*)
{
    ; MsgBox "You selected " ItemName " (position " ItemPos ")"
    HelpMessage := "
    (
        [CTRL]+[ALT]+[WIN]+[R]::`treload this script`n
        [CTRL]+[ALT]+[Win]+[E]::`tedit this script`n
        [CTRL]+[Win]+[B]::`tinsert a bullet point in any document`n
        [LShift]+[RShift]+[T]::`trun Terminal`n
        [LShift]+[RShift]+[CTRL]+[T]::`trun Terminal as Admin`n
        [LShift]+[RShift]+[N]::`trun Notepad `n
    )"
    MsgBox HelpMessage, "FLOW Shortcut Keys"
}

/*
╭───────────────╮
│ OpenScriptDir │
╰───────────────╯ */
OpenScriptDir(*)
{
    Run A_ScriptDir
}

/*
╭──────────╮
│ ShowHelp │
╰──────────╯ */
ShowHelp(*)
{
    ; Open the regular help file
    ; Determine AutoHotkey's location:
    if A_AhkPath
        SplitPath A_AhkPath, , &ahk_dir
    else if FileExist("..\..\AutoHotkey.chm")
        ahk_dir := "..\.."
    else if FileExist(A_ProgramFiles "\AutoHotkey\AutoHotkey.chm")
        ahk_dir := A_ProgramFiles "\AutoHotkey"
    else {
        MsgBox "Could not find the AutoHotkey folder."
        return
    }
    Run ahk_dir "\AutoHotkey.chm"
    ; Run A_ProgramFiles "\AutoHotkey\v2\AutoHotkey.chm"

    return
}

/*
╭────────────╮
│ ShowAHKSpy │
╰────────────╯ */
ShowAHKSpy(*)
{
    ; Open the regular help file
    ; Determine AutoHotkey's location:
    if A_AhkPath
        SplitPath A_AhkPath, , &ahk_dir
    else {
        MsgBox "Could not find the AutoHotkey folder."
        return
    }
    ; Run the WindowsSpy script
    ; MsgBox "Running WindowsSpy.ahk from: " ahk_dir
    Run A_AhkPath " " ahk_dir "\WindowSpy.ahk"
    ; Run A_ProgramFiles "\AutoHotkey\v2\AutoHotkey.chm"

    return
}

; Placeholder functions for disabled menu items
IncCursorSize(*)
{}
DecCursorSize(*)
{}
IncMouseSpeed(*)
{}
DecMouseSpeed(*)
{}
ToggleTheme(*)
{}
ToggleTaskbar(*)
{}
ToggleDesktopIcons(*)
{}
ShowCustomNotes(*)
{}
ToggleWindowHighlighter(*)
{}
ToggleOverflowNotifier(*)
{}
ToggleChime(*)
{}
