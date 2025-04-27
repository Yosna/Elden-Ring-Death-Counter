#Requires AutoHotkey v2.0
#SingleInstance Force

#Include utils.ahk
#Include settings.ahk

CreateWindow() {
    window := Gui(, "ER Death Counter")
    window.BackColor := "3D3D3D"
    window.size := "w264 h480"
    window.OnEvent("Close", (*) => ExitApp())

    ; stats for the detected character
    window.SetFont("s11 cWhite", "Cascadia Code")
    window.stats := window.AddText("x42 y10 " . window.size)

    ; input field to change the death counter
    window.SetFont("s11 cBlack", "Cascadia Code")
    window.deathInput := window.AddEdit("x49 y420 w80 h25 Number Right")
    window.deathInput.Color := "White"

    ; button to set the death counter
    window.SetFont("s8 cWhite", "Cascadia Code")
    window.deathSet := window.AddButton("x135 y420 w80 h25", "Set Deaths")
    window.deathSet.OnEvent("Click", (*) => SetDeathCounter(window.deathInput.Value))

    ; this helps prevent elements from disappearing when the window is updated
    window.unfocus := window.AddText("x0 y0 w0 h0")

    window.Show(window.size)

    return window
}

CreateOverlay() {
    overlay := Gui("+AlwaysOnTop -Caption +ToolWindow")
    overlay.BackColor := "Black"

    ; position of the overlay
    overlay.x := Floor(game.x + (game.w * 0.866)) ; lower number moves left, higher number moves right
    overlay.y := Floor(game.y + (game.h * 0.899)) ; lower number moves up, higher number moves down
    overlay.pos := "x" . overlay.x . " y" . overlay.y

    ; size of the overlay
    overlay.w := "w" . Floor(game.w * 0.100) ; width - raise this number if text wrapping occurs

    ; settings string for the overlay
    overlay.settings := overlay.pos . " " . overlay.w . " NoActivate"

    ; add the text and make it click-and-draggable
    overlay.SetFont("s18 cWhite")
    overlay.deaths := overlay.AddText(overlay.w)
    overlay.deaths.OnEvent("Click", (*) => PostMessage(0xA1, 2,,, "ahk_id " . overlay.Hwnd))

    overlay.Show(overlay.settings)

    ; make the background color transparent
    WinSetTransColor("Black", "ahk_id " . overlay.Hwnd)

    return overlay
}

SetDeathCounter(counter) {
    deaths := RetrieveMemory(game, game.offsets.deaths)
    game.deathsOffset := deaths - (!isNumber(counter) || (counter > deaths) ? deaths : counter)
    window.deathInput.Value := ""

    SaveSettings(game)
}

Update() {
    deathsTotal := RetrieveMemory(game, game.offsets.deaths)
    deaths := deathsTotal - game.deathsOffset

    ; if deaths fall below 0 or change by more than 1, assume the
    ; user is on the title screen or loaded a different character
    if deaths < 0 || Abs(deathsTotal - game.deathsTotal) > 1 {
        ReloadSettings(game, overlay)
    }

    content := "Deaths: " . deaths
    updateContent := overlay.deaths.Value != content
    if (updateContent) {
        overlay.deaths.Value := content
    }

    stats := CharacterData(game)

    if (window.stats.Value != stats) {
        window.stats.Value := stats

        window.deathInput.Focus() ; these elements become invisible if the
        window.deathSet.Focus()   ; character data is updated without this;
        window.unfocus.Focus()    ; I couldn't figure out a better solution
    }

    if game.deathsOffset != 0 {
        SaveSettings(game)
    }
}

F8::HideOverlay(overlay)
F12::ReloadProgram

; set the timer to update the overlay once the game is detected
DetectGame(game) ? SetTimer(() => Update(), 1000) : ""

; show the hotkeys only if a new session is launched 
; the delay is to ensure the hotkeys appear on top of the window
(!A_Args.Length) ? SetTimer(() => ShowHotkeys(), -2000) : ""

window := CreateWindow()
overlay := CreateOverlay()