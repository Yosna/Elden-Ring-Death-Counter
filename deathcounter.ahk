#Requires AutoHotkey v2.0
#SingleInstance Force

#Include constants.ahk
#Include utils.ahk
#Include settings.ahk

F8::HideOverlay(overlay)
F12::ReloadProgram

global window, overlay

CreateWindow() {
    global window
    local font, options

    window := Gui(, "ER Death Counter")
    window.BackColor := COLOR_DARK_GREY
    window.OnEvent("Close", (*) => ExitApp())

    ; stats for the detected character
    font := FormatFont(FONT_SIZE_11, COLOR_WHITE)
    options := FormatOptions(WINDOW_STATS_X, WINDOW_STATS_Y, WINDOW_WIDTH, WINDOW_HEIGHT)
    window.SetFont(font, "Cascadia Code")
    window.stats := window.AddText(options)

    ; input field to change the death counter
    font := FormatFont(FONT_SIZE_11, COLOR_WHITE)
    options := FormatOptions(WINDOW_INPUT_X, WINDOW_INPUT_Y, WINDOW_INPUT_W, WINDOW_INPUT_H, "Number Right")
    window.SetFont(font, "Cascadia Code")
    window.deathInput := window.AddEdit(options)
    window.deathInput.Color := COLOR_WHITE

    ; button to set the death counter
    font := FormatFont(FONT_SIZE_8, COLOR_WHITE)
    options := FormatOptions(WINDOW_BUTTON_X, WINDOW_BUTTON_Y, WINDOW_BUTTON_W, WINDOW_BUTTON_H)
    window.SetFont(font, "Cascadia Code")
    window.deathSet := window.AddButton(options, "Set Deaths")
    window.deathSet.OnEvent("Click", (*) => SetDeathCounter(window.deathInput.Value))

    ; this helps prevent elements from disappearing when the window is updated
    window.unfocus := window.AddText()

    options := FormatOptions(,,WINDOW_WIDTH, WINDOW_HEIGHT)
    window.Show(options)
}

CreateOverlay() {
    global overlay
    local font, options

    overlay := Gui("+AlwaysOnTop -Caption +ToolWindow")
    overlay.BackColor := COLOR_BLACK

    ; options for the overlay
    overlay.x := Floor(game.x + (game.w * OVERLAY_X_RATIO)) 
    overlay.y := Floor(game.y + (game.h * OVERLAY_Y_RATIO)) 
    overlay.w := Floor(game.w * OVERLAY_WIDTH) 
    
    ; add the text and make it click-and-draggable
    font := FormatFont(FONT_SIZE_18, COLOR_WHITE)
    options := FormatOptions(,, overlay.w)
    overlay.SetFont(font)
    overlay.deaths := overlay.AddText(options, "Deaths: 0")
    overlay.deaths.OnEvent("Click", (*) => PostMessage(0xA1, 2,,, "ahk_id " . overlay.Hwnd))

    options := FormatOptions(overlay.x, overlay.y, overlay.w,, "NoActivate")
    overlay.Show(options)

    ; make the background color transparent
    WinSetTransColor(COLOR_BLACK, "ahk_id " . overlay.Hwnd)
}

FormatOptions(x := "", y := "", w := "", h := "", extra := "") {
    local options := "" 
        . (x ? " x" . x : "") . (y ? " y" . y : "")
        . (w ? " w" . w : "") . (h ? " h" . h : "")
        . (extra ? " " . extra : "")

    return RegExReplace(options, "^\s+") ; removes leading spaces
}

FormatFont(s := "", c := "") {
    local font := (s ? " s" . s : "") . (c ? " c" . c : "")

    return RegExReplace(font, "^\s+") ; removes leading spaces
}

SetDeathCounter(counter) {
    local deaths := RetrieveMemory(game, game.offsets.deaths)
    game.deathsOffset := deaths - (!isNumber(counter) || (counter > deaths) ? deaths : counter)
    window.deathInput.Value := ""

    SaveSettings(game)
}

Update() {
    local deathsTotal := RetrieveMemory(game, game.offsets.deaths)
    local deaths := deathsTotal - game.deathsOffset

    ; if deaths fall below 0 or change by more than 1, assume the
    ; user is on the title screen or loaded a different character
    if deaths < 0 || Abs(deathsTotal - game.deathsTotal) > 1 {
        game.deathsTotal := deathsTotal
        ReloadSettings(game, overlay)
    }

    local content := "Deaths: " . deaths
    local updateContent := overlay.deaths.Value != content

    if (updateContent) {
        overlay.deaths.Value := content
    }

    local stats := CharacterData(game)

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

InitializeGUI() {
    DetectGame(game)
    CreateWindow()
    CreateOverlay()
    SetTimer(() => Update(), TICK_INTERVAL)

    ; show the hotkeys only if a new session is launched 
    ; the delay is to ensure the hotkeys appear on top of the window
    (!A_Args.Length) ? SetTimer(() => ShowHotkeys(), -HOTKEY_INTERVAL) : ""
}

InitializeGUI()
