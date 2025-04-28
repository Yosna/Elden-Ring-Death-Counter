#Include gamedata.ahk

OpenProcess(pid) {
    local process := DllCall("OpenProcess"
        , "UInt", PROCESS_ACCESS
        , "Int", False
        , "UInt", pid
        , "Ptr"
    ) 
    
    if !process {
        local warning := "Failed to open process. PID: " . pid . "`nError code: " . A_LastError . "`n"
            . "Press OK to reload, or Cancel to close the program."

        WarningBox(warning, "Error " . A_LastError, ReloadProgram)
    }

    return process
}

CloseProcess := (hProcess) => DllCall("CloseHandle", "Ptr", hProcess)

GetBaseAddress(pid) {
    local hProcess := OpenProcess(pid)
    local module := Buffer(A_PtrSize)
    local cbNeeded := 0

    local success := DllCall("Psapi.dll\EnumProcessModulesEx"
        , "Ptr", hProcess
        , "Ptr", module
        , "UInt", A_PtrSize
        , "UInt*", cbNeeded
        , "UInt", 0x03
    ) 
    
    if !success {
        local warning := "EnumProcessModulesEx failed. "
            . "Error code: " . A_LastError . "`n"
            . "Press OK to reload, or Cancel to close the program."

        CloseProcess(hProcess)
        WarningBox(warning, "Error " . A_LastError, ReloadProgram)
    }

    local baseAddress := NumGet(module, "Ptr")
    
    if !baseAddress {
        local warning := "Failed to retrieve the base address." . "`n"
            . "Press OK to reload, or Cancel to close the program."

        CloseProcess(hProcess)
        WarningBox(warning, "Error " . A_LastError, ReloadProgram)
    }

    CloseProcess(hProcess)

    return baseAddress
}

RetrieveMemory(game, offsets) {
    local dereference := ReadMemory(game.pid, game.baseAddress + game.pointer, "UInt64")

    for data in offsets {
        dereference := ReadMemory(game.pid, dereference + data.offset, data.type)
    }
    
    return dereference
}

ReadMemory(pid, address, type := "UInt") {
    local hProcess := OpenProcess(pid)
    local size := (type == "Str") ? STRING_BUFFER_SIZE : A_PtrSize ; strings need a bigger buffer
    local memory := Buffer(size)
    local bytesRead := 0

    local success := DllCall("kernel32.dll\ReadProcessMemory"
        , "Ptr", hProcess
        , "Ptr", address
        , "Ptr", memory
        , "Ptr", size
        , "Ptr*", bytesRead
    ) 

    if !success {
        local warning := "Failed to read memory. Error code: " . A_LastError . "`n"
            . "Retrying in 5 seconds. Please wait..."

        CloseProcess(hProcess)
        TempMsgBox(warning, TIMEOUT_MS)
        WaitToContinue(TIMEOUT_MS, () => Reload())
    }

    local value := (type == "Str") 
        ? StrGet(memory, STRING_BYTE_LENGTH, "UTF-16") 
        : NumGet(memory, type)

    CloseProcess(hProcess)

    return value
}
