hide := false

; official AHK v2 documentation says "/restart" works compiled, but it doesn't seem to recognize the argument
; on reload and starts it as a new session. "/reload /restart" is being used here instead, because "/restart"
; terminates the instance, while "/reload" ensures it's handled as the current session since it isn't a switch
; this is so ShowHotkeys() is only shown on a new session, as it might be a nuisance to close it every reload.
ReloadProgram := () => Run(A_IsCompiled
    ? A_ScriptFullPath " /reload /restart"                 ; .exe
    : A_AhkPath " '" A_ScriptFullPath "' /reload /restart" ; .ahk
)

ShowHotkeys() {
    MsgBox(" "
        . " F8: Hide Overlay `n`n" 
        . "F12: Reload Program"
        , "Hotkeys"
    )
}

HideOverlay(overlay) {
    global hide
    hide := !hide
    hide ? overlay.Hide() : overlay.Show()
}

TempMsgBox(text, timeout := 3000) {
    message := Gui("+AlwaysOnTop +ToolWindow -Caption")
    message.Add("Text", , text)
    message.Show("AutoSize Center")
    SetTimer(() => message.Destroy(), -timeout)
}

WarningBox(message, title := "Warning", Accept := (*) => "") {
    MsgBox(message, title, "OKCancel Icon!") = "OK" ? Accept() : ExitApp()
}