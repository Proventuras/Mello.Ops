; filepath: blur_screen.ahk
; AutoHotkey v2 script
; Press Ctrl+Alt+B to toggle the blur overlay

#Requires AutoHotkey v2.0
#SingleInstance Force

global BlurOn := false
global BlurGui := Gui('+AlwaysOnTop -Caption +ToolWindow +E0x20')

^!b:: { ; Ctrl+Alt+B to toggle blur
    global BlurOn, BlurGui
    if BlurOn {
        BlurGui.Destroy()
        BlurOn := false
        BlurGui := Gui('+AlwaysOnTop -Caption +ToolWindow +E0x20')
    } else {
        BlurGui.BackColor := 'Black'
        BlurGui.Show('x0 y0 w' A_ScreenWidth ' h' A_ScreenHeight ' NA')
        BlurGui.Add('Text', 'Center cWhite BackgroundTrans x0 y0 w' A_ScreenWidth ' h' A_ScreenHeight ' +0x200 +0x1000 vBlurLabel', 'Screen is blurred\nPress Ctrl+Alt+B to remove overlay')
        WinSetTransparent(200, BlurGui.Hwnd) ; 200/255 transparency
        BlurOn := true
    }
}

WinSetTransparent(alpha, hwnd) {
  ; Ensure the window has WS_EX_LAYERED
  exStyle := WinGetExStyle(hwnd)
  if !(exStyle & 0x80000) ; WS_EX_LAYERED
  WinSetExStyle('+0x80000', hwnd)

  ; alpha: 0 (fully transparent) to 255 (opaque)
  WinSetAttr := DllCall('SetLayeredWindowAttributes', 'ptr', hwnd, 'uint', 0, 'uchar', alpha, 'uint', 0x2)
}