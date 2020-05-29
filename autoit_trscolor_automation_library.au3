#include-once
#include <MsgBoxConstants.au3>

; Created by Andre Ballista - 2019
; GNU General Public License v3.0 - See LICENSE file for details.

Const $ini_file_name       = 0
Const $emulator_name       = 1
Const $emulator_handle     = 2
Const $left_margin         = 3
Const $top_margin          = 4
Const $background_checksum = 5
Const $loop_delay          = 6
Const $cell_width          = 7
Const $cell_height         = 8

Global $global_mConfiguration[9]


; Internal function to wrap the standard IniRead function
Func _IniReadWrapper($sFile, $sSection, $sKey)
    If Not FileExists(@ScriptDir & "\" & $sFile) Then
        MsgBox($MB_SYSTEMMODAL, "Error", "[" & @ScriptDir & $sFile & "] not found!")
        Exit;
    EndIf
    Local $sIniValue = IniRead(@ScriptDir & "\" & $sFile, $sSection, $sKey,"")
    RETURN $sIniValue;
EndFunc


; Initialise the library for use. If parameter $a_string is empty, the emulator name to be used is taken from the INI file. 
; Valid emulator names are XROAR and MAME
; This is a required function and must be called at the start of the script.
Func initialise_automation($a_string)
   
    $global_mConfiguration[$ini_file_name] = "autoit_trscolor_automation_library.ini"
    
    Local $value 
    
    $value = _IniReadWrapper($global_mConfiguration[$ini_file_name], "Control Values", "KeyPressDuration")
    If $value = "" Then
        MsgBox($MB_OK + $MB_ICONERROR, "Error while initialising automation.", "Couldn't find Section [Control Values] or Key [KeyPressDuration] on file " & @ScriptDir & "\" & $global_mConfiguration[$ini_file_name] & ". Press OK to return to editor.")
        exit
    else
        AutoItSetOption ("SendKeyDownDelay" , int($value))
    EndIf

    $value = _IniReadWrapper($global_mConfiguration[$ini_file_name], "Control Values", "DelayBeforeKeyPress")
    If $value = "" Then
        MsgBox($MB_OK + $MB_ICONERROR, "Error while initialising automation.", "Couldn't find Section [Control Values] or Key [DelayBeforeKeyPress] on file " & @ScriptDir & "\" & $global_mConfiguration[$ini_file_name] & ". Press OK to return to editor.")
        exit
    else
        AutoItSetOption ("SendKeyDelay" , int($value))
    EndIf
    
    $global_mConfiguration[$loop_delay] = _IniReadWrapper($global_mConfiguration[$ini_file_name], "Control Values","LoopDelay")
    If $global_mConfiguration[$loop_delay] = "" Then
        MsgBox($MB_OK + $MB_ICONERROR, "Error reading from INI file", "Couldn't find Section [Control Values] or Key [LoopDelay] on file " & @ScriptDir & $global_mConfiguration[$ini_file_name] & ". Press OK to return to editor.")
        exit
    EndIf
    
    If $a_string = "" Then
        $global_mConfiguration[$emulator_name] = _IniReadWrapper($global_mConfiguration[$ini_file_name], "Emulator Configuration", "EmulatorName")
    else
        $global_mConfiguration[$emulator_name] = $a_string
    EndIf
    
    If $global_mConfiguration[$emulator_name] = "" Then
        MsgBox($MB_OK + $MB_ICONERROR, "Error while initialising automation.", "Couldn't find Section [Emulator Configuration] or Key [EmulatorName] on INI file " & @ScriptDir & $global_mConfiguration[$ini_file_name] & ". Press OK to return to editor.")
        exit
    Else
        $global_mConfiguration[$emulator_handle] = _decode_emulator_name_to_window_class($global_mConfiguration[$emulator_name])
        If not WinExists($global_mConfiguration[$emulator_handle]) Then
            MsgBox($MB_OK + $MB_ICONERROR, "Error during execution", "Couldn't find a running [" & $global_mConfiguration[$emulator_name] & "] Emulator. Press OK to return to editor.")
            exit        
        Else
            _initialise_emulator($global_mConfiguration[$emulator_name])
        EndIf
    EndIf
    
    AutoItSetOption("MouseCoordMode",0)
    AutoItSetOption("PixelCoordMode",0)
EndFunc


; Optional function. Finalise the automation closing the Emulator screen
Func finalise_automation()
    WinClose($global_mConfiguration[$emulator_handle], "")
EndFunc


; Function to bring the emulator window into focus
Func activate_emulator_window()
    WinActivate($global_mConfiguration[$emulator_handle], "")   
EndFunc


; internal function to detect the emulator window handlers
Func _decode_emulator_name_to_window_class($sEmulatorName)
    Local $sEmulatorString
    If $sEmulatorName = "XROAR" Then
        $sEmulatorString = "[CLASS:SDL_app]"
    ElseIf $sEmulatorName = "MAME" then
        $sEmulatorString = "[CLASS:MAME]"
    Else
        MsgBox($MB_OK + $MB_ICONERROR, "Error during execution", "Emulator [" & $sEmulatorName & "] is not supported or recognised. Press OK to return to editor.")
        exit
    EndIf
    RETURN $sEmulatorString
EndFunc


; internal function to load the emulator specific configuration from the ini file.
Func _initialise_emulator($sEmulatorName)
    Local $sWindowSize
    Local $sIniSection
    
    If $sEmulatorName = "XROAR" Then
        $sIniSection = "XROAR Configuration"
    ElseIf $sEmulatorName = "MAME" Then
        $sIniSection = "MAME Configuration"
    Else
        MsgBox($MB_OK + $MB_ICONERROR, "Error during execution", "Emulator [" & $sEmulatorName & "] is not supported or recognised. Press OK to return to editor.")
        exit
    EndIf

    $sWindowSize = _IniReadWrapper($global_mConfiguration[$ini_file_name], $sIniSection, "WindowSize")
    If $sWindowSize = "" Then
        MsgBox($MB_OK + $MB_ICONERROR, "Error while initialising emulator.", "Couldn't find Section [" & $sIniSection & "] or Key [WindowSize] on file " & @ScriptDir & "\" & $global_mConfiguration[$ini_file_name] & ". Press OK to return to editor.")
        exit
    Else
        $sWindowSize = StringSplit($sWindowSize,",")
        WinMove($global_mConfiguration[$emulator_handle], "", 10, 10, $sWindowSize[1], $sWindowSize[2])
    EndIf
        
    $global_mConfiguration[$left_margin] = _IniReadWrapper($global_mConfiguration[$ini_file_name], $sIniSection, "LeftMargin")
    If $global_mConfiguration[$left_margin] = "" Then
        MsgBox($MB_OK + $MB_ICONERROR, "Error while initialising emulator.", "Couldn't find Section [" & $sIniSection & "] or Key [LeftMargin] on file " & @ScriptDir & "\" & $global_mConfiguration[$ini_file_name] & ". Press OK to return to editor.")
        exit
    EndIf

    $global_mConfiguration[$top_margin] = _IniReadWrapper($global_mConfiguration[$ini_file_name], $sIniSection, "TopMargin")
    If $global_mConfiguration[$top_margin] = "" Then
        MsgBox($MB_OK + $MB_ICONERROR, "Error while initialising emulator.", "Couldn't find Section [" & $sIniSection & "] or Key [TopMargin] on file " & @ScriptDir & "\" & $global_mConfiguration[$ini_file_name] & ". Press OK to return to editor.")
        exit
    EndIf
        
    $global_mConfiguration[$background_checksum] = _IniReadWrapper($global_mConfiguration[$ini_file_name], $sIniSection, "GreenChecksum")
    If $global_mConfiguration[$background_checksum] = "" Then
        MsgBox($MB_OK + $MB_ICONERROR, "Error while initialising emulator.", "Couldn't find Section [" & $sIniSection & "] or Key [GreenChecksum] on file " & @ScriptDir & "\" & $global_mConfiguration[$ini_file_name] & ". Press OK to return to editor.")
        exit
    EndIf  

    $global_mConfiguration[$cell_width] = _IniReadWrapper($global_mConfiguration[$ini_file_name], $sIniSection, "CellWidth")
    If $global_mConfiguration[$cell_width] = "" Then
        MsgBox($MB_OK + $MB_ICONERROR, "Error while initialising emulator.", "Couldn't find Section [" & $sIniSection & "] or Key [CellWidth] on file " & @ScriptDir & "\" & $global_mConfiguration[$ini_file_name] & ". Press OK to return to editor.")
        exit
    EndIf  

    $global_mConfiguration[$cell_height] = _IniReadWrapper($global_mConfiguration[$ini_file_name], $sIniSection, "CellHeight")
    If $global_mConfiguration[$cell_height] = "" Then
        MsgBox($MB_OK + $MB_ICONERROR, "Error while initialising emulator.", "Couldn't find Section [" & $sIniSection & "] or Key [CellHeight] on file " & @ScriptDir & "\" & $global_mConfiguration[$ini_file_name] & ". Press OK to return to editor.")
        exit
    EndIf  
EndFunc


; Position the mouse on the specific column and line numbers.
; This function takes in consideration the emulator specific configuration
Func position_mouse_at_location($column_number, $line_number)
    Local $iX = $global_mConfiguration[$left_margin] + ($column_number * $global_mConfiguration[$cell_width])
    Local $iY = $global_mConfiguration[$top_margin] + ($line_number * $global_mConfiguration[$cell_height])
    MouseMove($iX, $iY,0)
EndFunc


; Returns the color code at the given location
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


; Returns the color checksum at the given location
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


; Function to test if the blinking cursor is at the given location. 
Func prompt_is_at_location($column_number, $line_number)
    Return get_color_checksum_at_location($column_number, $line_number) <> $global_mConfiguration[$background_checksum]
EndFunc


; Function to test if the given location is empty, i.e. the background color matches the configured background color
Func location_is_empty($column_number, $line_number)
    Return get_color_checksum_at_location($column_number, $line_number) = $global_mConfiguration[$background_checksum]
EndFunc


; Function to pause and wait until the blinking cursor is detected at the specific given location
Func wait_for_prompt_at_location($column_number, $line_number) 
    Do
        Sleep($global_mConfiguration[$loop_delay])
        WinActivate($global_mConfiguration[$emulator_handle], "")
    Until not location_is_empty($column_number, $line_number)
EndFunc


; Function to pause and wait until the blinking cursor is detected at the location specified by the section and tag defined in the configuration file
Func wait_for_prompt($sSection, $sKey)
    ; Wait until the prompt cursor is presented on the screen
    Local $sPosition

    $sPosition = _IniReadWrapper($global_mConfiguration[$ini_file_name], $sSection, $sKey)
    $sPosition = StringSplit($sPosition,",")
    If $sPosition[0] <> 2 Then
        MsgBox($MB_OK + $MB_ICONERROR, "Error reading from INI file", "Couldn't find Section '" & $sSection & "' or Key '" & $sKey & "' on file " & @ScriptDir & "\" & $global_mConfiguration[$ini_file_name] & ". Press OK to return to editor.")
        exit
    EndIf
  
    wait_for_prompt_at_location($sPosition[1], $sPosition[2])
EndFunc
