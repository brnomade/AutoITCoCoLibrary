#include-once
#include <MsgBoxConstants.au3>

; Created by Andre Ballista - 2019

Const $ini_file_name       = 0
Const $emulator_name       = 1
Const $emulator_handle     = 2
Const $left_margin         = 3
Const $top_margin          = 4
Const $background_checksum = 5
Const $loop_delay          = 6

Global $global_mConfiguration[7]


Func IniReadWrapper($sFile, $sSection, $sKey)
    If Not FileExists(@ScriptDir & "\" & $sFile) Then
        MsgBox($MB_SYSTEMMODAL, "Error", "[" & @ScriptDir & $sFile & "] not found!")
        Exit;
    EndIf
    Local $sIniValue = IniRead(@ScriptDir & "\" & $sFile, $sSection, $sKey,"")
    RETURN $sIniValue;
EndFunc


Func initialise_automation()
   
    $global_mConfiguration[$ini_file_name] = "autoit_trscolor_automation_library.ini"
    
    Local $value 
    
    $value = IniReadWrapper($global_mConfiguration[$ini_file_name], "Control Values", "KeyPressDuration")
    If $value = "" Then
        MsgBox($MB_OK + $MB_ICONERROR, "Error while initialising automation.", "Couldn't find Section [Control Values] or Key [KeyPressDuration] on file " & @ScriptDir & "\" & $global_mConfiguration[$ini_file_name] & ". Press OK to return to editor.")
        exit
    else
        AutoItSetOption ("SendKeyDownDelay" , int($value))
    EndIf

    $value = IniReadWrapper($global_mConfiguration[$ini_file_name], "Control Values", "DelayBeforeKeyPress")
    If $value = "" Then
        MsgBox($MB_OK + $MB_ICONERROR, "Error while initialising automation.", "Couldn't find Section [Control Values] or Key [DelayBeforeKeyPress] on file " & @ScriptDir & "\" & $global_mConfiguration[$ini_file_name] & ". Press OK to return to editor.")
        exit
    else
        AutoItSetOption ("SendKeyDelay" , int($value))
    EndIf
    
    $global_mConfiguration[$loop_delay] = IniReadWrapper($global_mConfiguration[$ini_file_name], "Control Values","LoopDelay")
    If $global_mConfiguration[$loop_delay] = "" Then
        MsgBox($MB_OK + $MB_ICONERROR, "Error reading from INI file", "Couldn't find Section [Control Values] or Key [LoopDelay] on file " & @ScriptDir & $global_mConfiguration[$ini_file_name] & ". Press OK to return to editor.")
        exit
    EndIf
    
    $global_mConfiguration[$emulator_name] = IniReadWrapper($global_mConfiguration[$ini_file_name], "Emulator Configuration", "EmulatorName")
    If $global_mConfiguration[$emulator_name] = "" Then
        MsgBox($MB_OK + $MB_ICONERROR, "Error while initialising automation.", "Couldn't find Section [Emulator Configuration] or Key [EmulatorName] on INI file " & @ScriptDir & $global_mConfiguration[$ini_file_name] & ". Press OK to return to editor.")
        exit
    Else
        $global_mConfiguration[$emulator_handle] = decode_emulator_name_to_window_class($global_mConfiguration[$emulator_name])
        If not WinExists($global_mConfiguration[$emulator_handle]) Then
            MsgBox($MB_OK + $MB_ICONERROR, "Error during execution", "Couldn't find a running [" & $global_mConfiguration[$emulator_name] & "] Emulator. Press OK to return to editor.")
            exit        
        Else
            initialise_emulator($global_mConfiguration[$emulator_name])
        EndIf
    EndIf
    
    AutoItSetOption("MouseCoordMode",0)
    AutoItSetOption("PixelCoordMode",0)
EndFunc


Func finalise_automation()
    WinClose($global_mConfiguration[$emulator_handle], "")
EndFunc


Func decode_emulator_name_to_window_class($sEmulatorName)
    Local $sEmulatorString
    If $sEmulatorName = "XROAR" Then
        $sEmulatorString = "[CLASS:SDL_app]"
    ElseIf $sEmulatorName = "MAME" then
        $sEmulatorString = "[TITLE:MAME: Color Computer 2B [coco2b]]"
    Else
        MsgBox($MB_OK + $MB_ICONERROR, "Error during execution", "Emulator [" & $sEmulatorName & "] is not supported or recognised. Press OK to return to editor.")
        exit
    EndIf
    RETURN $sEmulatorString
EndFunc


Func initialise_emulator($sEmulatorName)
    Local $sWindowSize
    
    If $sEmulatorName = "XROAR" Then
        $sWindowSize = IniReadWrapper($global_mConfiguration[$ini_file_name], "XROAR Configuration", "WindowSize")
        If $sWindowSize = "" Then
            MsgBox($MB_OK + $MB_ICONERROR, "Error while initialising emulator.", "Couldn't find Section [XROAR Configuration] or Key [WindowSize] on file " & @ScriptDir & "\" & $global_mConfiguration[$ini_file_name] & ". Press OK to return to editor.")
            exit
        Else
            $sWindowSize = StringSplit($sWindowSize,",")
            WinMove($global_mConfiguration[$emulator_handle], "", 10, 10, $sWindowSize[1], $sWindowSize[2])
        EndIf
        
        $global_mConfiguration[$left_margin] = IniReadWrapper($global_mConfiguration[$ini_file_name], "XRoar Configuration", "LeftMargin")
        If $global_mConfiguration[$left_margin] = "" Then
            MsgBox($MB_OK + $MB_ICONERROR, "Error while initialising emulator.", "Couldn't find Section [XROAR Configuration] or Key [LeftMargin] on file " & @ScriptDir & "\" & $global_mConfiguration[$ini_file_name] & ". Press OK to return to editor.")
            exit
        EndIf

        $global_mConfiguration[$top_margin] = IniReadWrapper($global_mConfiguration[$ini_file_name], "XRoar Configuration", "TopMargin")
        If $global_mConfiguration[$top_margin] = "" Then
            MsgBox($MB_OK + $MB_ICONERROR, "Error while initialising emulator.", "Couldn't find Section [XROAR Configuration] or Key [TopMargin] on file " & @ScriptDir & "\" & $global_mConfiguration[$ini_file_name] & ". Press OK to return to editor.")
            exit
        EndIf
        
        $global_mConfiguration[$background_checksum] = IniReadWrapper($global_mConfiguration[$ini_file_name], "Xroar Configuration", "GreenChecksum")
        If $global_mConfiguration[$background_checksum] = "" Then
            MsgBox($MB_OK + $MB_ICONERROR, "Error while initialising emulator.", "Couldn't find Section [XROAR Configuration]  or Key [GreenChecksum] on file " & @ScriptDir & "\" & $global_mConfiguration[$ini_file_name] & ". Press OK to return to editor.")
            exit
        EndIf  
    Else
        MsgBox($MB_OK + $MB_ICONERROR, "Error during execution", "Emulator [" & $sEmulatorName & "] is not supported or recognised. Press OK to return to editor.")
        exit
    EndIf
EndFunc


Func position_mouse_at_location($column_number, $line_number)
    Local $iX = $global_mConfiguration[$left_margin] + ($column_number * 16)
    Local $iY = $global_mConfiguration[$top_margin] + ($line_number * 24)
    MouseMove($iX, $iY,0)
EndFunc


Func get_color_at_location($column_number, $line_number)
    
    Local $aOriginalPosition 
    Local $aCurrentPosition
    Local $iColor
    
    $aOriginalPosition = MouseGetPos()
    position_mouse_at_location($column_number, $line_number)
    $aCurrentPosition = MouseGetPos()
    $iColor = PixelGetColor($aCurrentPosition[0], $aCurrentPosition[1])
    MouseMove($aOriginalPosition[0], $aOriginalPosition[1], 0)
    return $iColor
EndFunc


Func get_color_checksum_at_location($column_number, $line_number)
    
    Local $aOriginalPosition 
    Local $aCurrentPosition
    Local $iSum
    
    $aOriginalPosition = MouseGetPos()
    position_mouse_at_location($column_number, $line_number)
    $aCurrentPosition = MouseGetPos()
    $iSum = PixelChecksum($aCurrentPosition[0] - 3, $aCurrentPosition[1] - 3, $aCurrentPosition[0] + 3, $aCurrentPosition[1] + 3)
    MouseMove($aOriginalPosition[0], $aOriginalPosition[1], 0)
    return $iSum
EndFunc


Func prompt_is_at_location($column_number, $line_number)
    Return get_color_checksum_at_location($column_number, $line_number) <> $global_mConfiguration[$background_checksum]
EndFunc


Func location_is_empty($column_number, $line_number)
    Return get_color_checksum_at_location($column_number, $line_number) = $global_mConfiguration[$background_checksum]
EndFunc


Func debug_xroar_screen()
    AutoItSetOption ("SendKeyDownDelay" , 5)
    AutoItSetOption ("SendKeyDelay" , 5)
    WinActivate($global_mConfiguration[$emulator_handle], "")      
    for $y = 1 to 10
        for $x = 1 to 32
            position_mouse_at_location($x,$y)
            Local $iColor = get_color_at_location($x,$y)
            Local $iSum = get_color_checksum_at_location($x,$y)
            WinActivate("[CLASS:Notepad++]")
            Send("[" & $x & "," & $y & ":" & $iColor & "," & $iSum & "]")
            WinActivate($global_mConfiguration[$emulator_handle], "")
        Next
        WinActivate("[CLASS:Notepad++]")
        Send("{ENTER}")
        WinActivate($global_mConfiguration[$emulator_handle], "")
    Next
EndFunc


Func waitForPrompt($sSection, $sKey)
    ; Wait until the prompt cursor is presented on the screen
    Local $sPosition
    Local $bTest

    $sPosition = IniReadWrapper($global_mConfiguration[$ini_file_name], $sSection, $sKey)
    $sPosition = StringSplit($sPosition,",")
    If $sPosition[0] <> 2 Then
        MsgBox($MB_OK + $MB_ICONERROR, "Error reading from INI file", "Couldn't find Section '" & $sSection & "' or Key '" & $sKey & "' on file " & @ScriptDir & "\" & $global_mConfiguration[$ini_file_name] & ". Press OK to return to editor.")
        exit
    EndIf
  
    Do
        WinActivate($global_mConfiguration[$emulator_handle], "")
        Sleep($global_mConfiguration[$loop_delay])
    Until not location_is_empty($sPosition[1], $sPosition[2])
    
EndFunc


