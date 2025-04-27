game := {
    name: "Elden Ring",
    userDir: A_AppData . "\EldenRing\DeathCounter",
    gameDir: "C:\Program Files (x86)\Steam\steamapps\common\ELDEN RING\Game\",
    exe: "eldenring.exe",
    pointer: 0x03D5DF38,
    offsets: {
        character: [ {offset: +0x08, type: "UInt64"}, {offset: +0x9C, type: "String"} ],
        level: [ {offset: +0x08, type: "UInt64"}, {offset: +0x68, type: "UInt"} ],
        vig: [ {offset: +0x08, type: "UInt64"}, {offset: +0x288, type: "UInt"} ],
        mnd: [ {offset: +0x08, type: "UInt64"}, {offset: +0x28C, type: "UInt"} ],
        end: [ {offset: +0x08, type: "UInt64"}, {offset: +0x290, type: "UInt"} ],
        str: [ {offset: +0x08, type: "UInt64"}, {offset: +0x298, type: "UInt"} ],
        dex: [ {offset: +0x08, type: "UInt64"}, {offset: +0x29C, type: "UInt"} ],
        int: [ {offset: +0x08, type: "UInt64"}, {offset: +0x2A0, type: "UInt"} ],
        fth: [ {offset: +0x08, type: "UInt64"}, {offset: +0x2A4, type: "UInt"} ],
        arc: [ {offset: +0x08, type: "UInt64"}, {offset: +0x2A8, type: "UInt"} ],
        hp: [ {offset: +0x08, type: "UInt64"}, {offset: +0x14, type: "UInt"} ],
        fp: [ {offset: +0x08, type: "UInt64"}, {offset: +0x20, type: "UInt"} ],
        stamina: [ {offset: +0x08, type: "UInt64"}, {offset: +0x2C, type: "UInt"} ],
        runes: [ {offset: +0x08, type: "UInt64"}, {offset: +0x6C, type: "UInt"} ],
        soulsmemory: [ {offset: +0x08, type: "UInt64"}, {offset: +0x70, type: "UInt"} ],
        deaths: [ {offset: +0x94, type: "UInt"} ],
    },
    hwnd: 0, x: 0, y: 0, w: 0, h: 0, deathsTotal: 0, deathsOffset: 0, loadedHex: 0,
}

DetectGame(game) {
    if pid := ProcessExist(game.exe) {
        game.pid := pid
        game.baseAddress := GetBaseAddress(pid)
        game.pointer := game.pointer
        game.offsets := game.offsets
        game.settings := game.userDir . "\settings.ini"
    }

    return ValidateGame(game)
}

ValidateGame(game) {
    hwnd := WinExist("ahk_pid " . (game.pid ?? 0))

    if hwnd && ProcessExist("EasyAntiCheat_EOS.exe") {
        warning := "Easy Anti-Cheat has been detected in Elden Ring.`n`n"
            . "This program will be blocked by EAC unless disabled.`n"
            . "Please close Elden Ring then press OK to launch the game with`n"
            . "EAC disabled, or press Cancel to close the program.`n`n"
            . "This program will attempt run Elden Ring with EAC disabled on launch."
        WarningBox(warning, "EAC Detected", () => BypassEAC(game))
    } else if !hwnd {
        warning := "Unable to detect Elden Ring.`n`n"
            . "Press OK to launch the game with Easy Anti-Cheat`n"
            . "disabled, or press Cancel to close the program."
        WarningBox(warning, game.name . " not found", () => BypassEAC(game))
    }

    WinGetPos(&game.x, &game.y, &game.w, &game.h, hwnd)
    LoadSettings(game)

    return true
}

BypassEAC(game) {
    time := A_TickCount
    path := game.gameDir . game.exe

    DllCall("SetEnvironmentVariable", "Str", "SteamAppId", "Str", "1245620")
    Run('cmd.exe /c ""' . path . '""', game.gameDir , "Hide", &pid)
    
    time := A_TickCount
    while (A_TickCount - time < 5000) {
        if ProcessExist(game.exe) {
            break
        }
    }

    if (A_TickCount - time >= 5000) {
        warning := "Failed to launch Elden Ring.`n`n"
            . "Press OK to try launching the game again,`n"
            . "or press Cancel to close the program."
            WarningBox(warning, "Failed to launch", () => BypassEAC(game))
    }

    ProcessClose(pid)
    Sleep(5000)
    DetectGame(game) ? "" : DetectGame(game)
}

CharacterData(game) {
    deaths := RetrieveMemory(game, game.offsets.deaths)
    counter := deaths - game.deathsOffset
    counter := (counter != deaths) ? counter . " (" . deaths . ")" : counter

    data := ("Character: " . RetrieveMemory(game, game.offsets.character) . "`n" 
        . "`n    Level: " . RetrieveMemory(game, game.offsets.level) . "`n" 
        . "`n      VIG: " . RetrieveMemory(game, game.offsets.vig) 
        . "`n      MND: " . RetrieveMemory(game, game.offsets.mnd) 
        . "`n      END: " . RetrieveMemory(game, game.offsets.end) 
        . "`n      STR: " . RetrieveMemory(game, game.offsets.str) 
        . "`n      DEX: " . RetrieveMemory(game, game.offsets.dex) 
        . "`n      INT: " . RetrieveMemory(game, game.offsets.int) 
        . "`n      FTH: " . RetrieveMemory(game, game.offsets.fth) 
        . "`n      ARC: " . RetrieveMemory(game, game.offsets.arc) . "`n" 
        . "`n       HP: " . RetrieveMemory(game, game.offsets.hp)
        . "`n       FP: " . RetrieveMemory(game, game.offsets.fp)
        . "`n  Stamina: " . RetrieveMemory(game, game.offsets.stamina) "`n" 
        . "`n    Runes: " . RetrieveMemory(game, game.offsets.runes) . "`n" 
        . "`n   Deaths: " . counter . "`n`n"  
        . "`n   Author: Yosna" 
    )
    return data
}