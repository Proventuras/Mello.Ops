#Requires AutoHotkey v2.0

; AutoHotkey v2 Script: Hourly Time Announcer
; Description: Visually and audibly announces the time every hour on the hour

#Requires AutoHotkey v2.0

SetTimer(AnnounceTime, 60000) ; Check every minute

AnnounceTime() {
    static lastHour := ""
    currentHour := FormatTime(A_Now, "HH")
    
    if (currentHour != lastHour && FormatTime(A_Now, "mm") = "00") {
        lastHour := currentHour
        timeStr := FormatTime(A_Now, "h tt") ; e.g., "1 PM"
        
        ; Visual Announcement
        ToolTip "The time is now " timeStr
        SetTimer(() => ToolTip(), -3000) ; Hide after 3 seconds

        ; Audible Announcement
        SoundBeep 750, 300
        SoundBeep 1000, 300

        ; Use TTS if available
        try {
            voice := ComObject("SAPI.SpVoice")
            voice.Speak("The time is now " timeStr)
        } catch {
            MsgBox "The time is now " timeStr
        }
    }
}