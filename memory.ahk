#Include gamedata.ahk

OpenProcess(pid) {
    PROCESS_QUERY_INFORMATION := 0x0400
    PROCESS_VM_READ := 0x0010
    access := PROCESS_QUERY_INFORMATION | PROCESS_VM_READ

    process := DllCall("OpenProcess"
        , "UInt", access
        , "Int", False
        , "UInt", pid
        , "Ptr"
    ) 
    
    if !process {
        warning := "Failed to open process. PID: " . pid . "`nError code: " . A_LastError . "`n"
            . "Press OK to reload, or Cancel to close the program."
        WarningBox(warning, "Error " . A_LastError, ReloadProgram)
    }

    return process
}

CloseProcess := (hProcess) => DllCall("CloseHandle", "Ptr", hProcess)

GetBaseAddress(pid) {
    hProcess := OpenProcess(pid)
    baseAddress := 0
    module := Buffer(A_PtrSize)
    cbNeeded := 0

    if !DllCall("Psapi.dll\EnumProcessModulesEx"
        , "Ptr", hProcess
        , "Ptr", module
        , "UInt", A_PtrSize
        , "UInt*", cbNeeded
        , "UInt", 0x03
    ) {
        warning := "EnumProcessModulesEx failed. Error code: " . A_LastError . "`n"
            . "Press OK to reload, or Cancel to close the program."
        DllCall("CloseHandle", "Ptr", hProcess)
        WarningBox(warning, "Error " . A_LastError, ReloadProgram)
    }

    baseAddress := NumGet(module, 0, "Ptr")

    if !baseAddress {
        warning := "Failed to retrieve the base address." . "`n"
            . "Press OK to reload, or Cancel to close the program."
        WarningBox(warning, "Error " . A_LastError, ReloadProgram)
    }

    CloseProcess(hProcess)

    return baseAddress
}

RetrieveMemory(game, offsets) {
    dereference := ReadMemory(game.pid, game.baseAddress + game.pointer, "UInt64")

    for data in offsets {
        dereference := ReadMemory(game.pid, dereference + data.offset, data.type)
    }
    
    return dereference
}

ReadMemory(pid, address, type := "UInt") {
    hProcess := OpenProcess(pid)
    size := (type == "String") ? 32 : A_PtrSize ; strings need a bigger buffer
    memory := Buffer(size)
    bytesRead := 0

    if !DllCall("kernel32.dll\ReadProcessMemory"
        , "Ptr", hProcess
        , "Ptr", address
        , "Ptr", memory
        , "Ptr", size
        , "Ptr*", bytesRead
    ) {
        warning := "Failed to read memory. Error code: " . A_LastError . "`n"
            . "Retrying in 5 seconds. Please wait..."
        DllCall("CloseHandle", "Ptr", hProcess)
        TempMsgBox(warning, 5000)
        Sleep(5000)
        Reload()
    }

    value := (type == "String") ? StrGet(memory, 16, "UTF-16") : NumGet(memory, 0, type)

    CloseProcess(hProcess)

    return value
}