; constants for CreateWindow() in deathcounter.ahk
global WINDOW_WIDTH    := 264 
global WINDOW_HEIGHT   := 480
global WINDOW_STATS_X  := 42
global WINDOW_STATS_Y  := 10
global WINDOW_INPUT_X  := 49
global WINDOW_INPUT_Y  := 420
global WINDOW_INPUT_W  := 80
global WINDOW_INPUT_H  := 25
global WINDOW_BUTTON_X := 135
global WINDOW_BUTTON_Y := 420
global WINDOW_BUTTON_W := WINDOW_INPUT_W
global WINDOW_BUTTON_H := WINDOW_INPUT_H

; constants for CreateOverlay() in deathcounter.ahk
global OVERLAY_X_RATIO := 0.866 ; lower number moves left, higher number moves right
global OVERLAY_Y_RATIO := 0.899 ; lower number moves up, higher number moves down
global OVERLAY_WIDTH   := 0.100 ; width - raise this number if text wrapping occurs

; constants for font sizes used in deathcounter.ahk
global FONT_SIZE_8  := 8
global FONT_SIZE_11 := 11
global FONT_SIZE_18 := 18

; constants for font colors used in deathcounter.ahk
global COLOR_WHITE     := "FFFFFF"
global COLOR_BLACK     := "000000"
global COLOR_DARK_GREY := "3D3D3D"

; constants for the intervals in deathcounter.ahk and settings.ahk
global TICK_INTERVAL   := 1000 
global HOTKEY_INTERVAL := 3000 

; constant for the timeout in gamedata.ahk and memory.ahk
global TIMEOUT_MS := 5000 ; delay before retrying memory or launch operations

; constants for memory handling in memory.ahk
global PROCESS_QUERY_INFORMATION := 0x0400
global PROCESS_VM_READ           := 0x0010
global PROCESS_ACCESS            := PROCESS_QUERY_INFORMATION | PROCESS_VM_READ
global STRING_BUFFER_SIZE        := 32
GLOBAL STRING_BYTE_LENGTH        := 16
