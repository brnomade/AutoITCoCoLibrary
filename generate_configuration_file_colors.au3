#include <MsgBoxConstants.au3>

; Created by Andre Ballista - 2020
; GNU General Public License v3.0 - See LICENSE file for details.

; This generates the configuration file containing the color definitions for the start computer.
; It will overwrite any existing file. 

; Initialisations
AutoItSetOption("MouseCoordMode", 0)
AutoItSetOption("PixelCoordMode", 0)
AutoItSetOption ("SendKeyDelay" , 70)
AutoItSetOption ("SendKeyDownDelay" , 70)
Local $emulator_name = "XROAR"
Local $emulator_handle = decode_emulator_name_to_window_class($emulator_name)

; TODO: ask user to adjust the screen-size
; TODO: test auto-it speed dinamically instead of forcing a value of 70
; TODO: if cellsize has unexpected dimensions, rerun the test in another position of the screen

If not WinExists($emulator_handle) Then
    MsgBox($MB_OK + $MB_ICONERROR, "Error during execution", "Couldn't find a running [" & $emulator_name & "] Emulator. Press OK to return to editor.")
    exit        
EndIf
run("notepad.exe")

; as we don't have yet control over the emulator, we wait a fixed number of seconds before atempting to call it
Sleep(5000)

setup_configuration_file($emulator_name)

setup_window_calibration($emulator_handle)
Local $aResult = create_window_calibration($emulator_handle)
tear_down_window_calibration($emulator_handle)

setup_cell_calibration($emulator_handle)
create_cell_calibration($emulator_handle, $aResult[5], $aResult[6])
tear_down_cell_calibration($emulator_handle)

setup_color_definitions($emulator_name, $emulator_handle)
create_color_definitions($emulator_handle, $aResult[5], $aResult[6])
tear_down_color_definitions($emulator_handle)

; Exit Script
MsgBox($MB_OK, "Message", "Press OK to close script.")

; --- SCRIPT END

Func decode_emulator_name_to_window_class($sEmulatorName)
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


Func setup_configuration_file($emulator_name)
    ; add a section on the configuration file
    WinActivate("[CLASS:Notepad]", "")
    Send('[Emulator Configuration]{ENTER}')
    Send('; valid values are MAME and XROAR{ENTER}')
    Send('EmulatorName=' & $emulator_name & '{ENTER}')
    Send('{ENTER}')
    Send('[' & $emulator_name & ' Configuration]{ENTER}')
EndFunc


Func _find_cell_boundaries($window_handle, $start_x, $start_y)
    ;
    WinActivate($window_handle, "")   
    ;
    ; find the left boundary of the current color
    MouseMove($start_x, $start_y)
    Local $startPosition = MouseGetPos()
    Local $color_code = PixelGetColor($startPosition[0], $startPosition[1])
    Local $new_color_code = $color_code
    While $new_color_code = $color_code
        $startPosition[0] = $startPosition[0] - 1
        $new_color_code = PixelGetColor($startPosition[0], $startPosition[1])
    WEnd
    Local $left_boundary = $startPosition[0] + 1
    ;
    ; find the right boundary of the current color
    MouseMove($start_x, $start_y)
    Local $startPosition = MouseGetPos()
    Local $color_code = PixelGetColor($startPosition[0], $startPosition[1])
    Local $new_color_code = $color_code
    While $new_color_code = $color_code
        $startPosition[0] = $startPosition[0] + 1
        $new_color_code = PixelGetColor($startPosition[0], $startPosition[1])
    WEnd
    Local $right_boundary = $startPosition[0] - 1
    ;
    ; find the higher boundary of the current color
    MouseMove($start_x, $start_y)
    Local $startPosition = MouseGetPos()
    Local $color_code = PixelGetColor($startPosition[0], $startPosition[1])
    Local $new_color_code = $color_code
    While $new_color_code = $color_code
        $startPosition[1] = $startPosition[1] + 1
        $new_color_code = PixelGetColor($startPosition[0], $startPosition[1])
    WEnd
    Local $higher_boundary = $startPosition[1] - 1
    ;
    ; find the lower boundary of the current color
    MouseMove($start_x, $start_y)
    Local $startPosition = MouseGetPos()
    Local $color_code = PixelGetColor($startPosition[0], $startPosition[1])
    Local $new_color_code = $color_code
    While $new_color_code = $color_code
        $startPosition[1] = $startPosition[1] - 1
        $new_color_code = PixelGetColor($startPosition[0], $startPosition[1])
    WEnd
    Local $lower_boundary = $startPosition[1] + 1
    ;
    Local $aResult[5] = [$color_code, $left_boundary, $right_boundary, $higher_boundary, $lower_boundary]
    Return $aResult
EndFunc


Func setup_window_calibration($window_handle)
    ; create the configuration program on the emulator
    WinActivate($window_handle, "")   
    Send('{ENTER}')
    Send('NEW{ENTER}')
    Send('10 CLS1{ENTER}')
    Send('20 A$=INKEY$:IFA$=""GOTO20{ENTER}')
    Send('RUN{ENTER}')
    ;
    $return = MsgBox($MB_YESNO, "Message", "Has the code run without syntax errors?")
    If $return = $IDNO Then
        Exit
    EndIf
EndFunc


Func create_window_calibration($window_handle)
    ; get window size
    Local $aWindowSpec = WinGetPos($window_handle)
    WinActivate("[CLASS:Notepad]", "")
    Send('WindowSize=' & $aWindowSpec[2] & ', ' & $aWindowSpec[3] & '{ENTER}')
    ;
    ; find boundaries
    Local $aBoundaries = _find_cell_boundaries($window_handle, int($aWindowSpec[2] / 2), int($aWindowSpec[3] / 2))
    WinActivate("[CLASS:Notepad]")
    Send('TopMargin:' & $aBoundaries[4] & '{ENTER}')
    Send('LowerMargin:' & $aBoundaries[3] & '{ENTER}')
    Send('RightMargin:' & $aBoundaries[2] & '{ENTER}')
    Send('LeftMargin:' & $aBoundaries[1] & '{ENTER}')
    ;
    Local $aResult[7] = [$aBoundaries[0], $aBoundaries[1], $aBoundaries[2], $aBoundaries[3], $aBoundaries[4], $aWindowSpec[2], $aWindowSpec[3] ]
    Return $aResult
EndFunc


Func tear_down_window_calibration($window_handle)
    ; finalise the configuration routine
    WinActivate($window_handle, "")
    Send('{ENTER}')
EndFunc


Func setup_cell_calibration($window_handle)
    ; create the configuration program on the emulator
    WinActivate($window_handle, "")   
    Send('{ENTER}')
    Send('NEW{ENTER}')
    Send('10 CLS0{ENTER}')
    Send('20 A$=CHR$(143){+}CHR$(159){+}CHR$(175){ENTER}')
    Send('30 FORY=1TO170:PRINTA$;:NEXTY{ENTER}')
    Send('40 A$=INKEY$:IFA$=""GOTO40{ENTER}')
    Send('RUN{ENTER}')
    ;
    $return = MsgBox($MB_YESNO, "Message", "Has the code run without syntax errors?")
    If $return = $IDNO Then
        Exit
    EndIf
EndFunc

 
Func create_cell_calibration($window_handle, $windowWidth, $windowHeight)
    ; calibrate the cell size
    Local $aBoundaries = _find_cell_boundaries($window_handle, int($windowWidth / 2), int($windowHeight / 2))
    ;
    WinActivate("[CLASS:Notepad]")
    Send('CellWidth:' & $aBoundaries[2] - $aBoundaries[1] & '{ENTER}')
    Send('CellHeight:' & $aBoundaries[3] - $aBoundaries[4] & '{ENTER}')
    Return $aBoundaries
EndFunc


Func tear_down_cell_calibration($window_handle)
    ; finalise the configuration routine
    WinActivate($window_handle, "")
    Send('{ENTER}')
EndFunc


Func setup_color_definitions($emulator_name, $window_handle)
    ; add a section on the configuration file
    WinActivate("[CLASS:Notepad]", "")
    Send('{ENTER}')
    Send('[' & $emulator_name & ' Color Definitions]{ENTER}')
    ;
    ; create the configuration program on the emulator
    WinActivate($window_handle, "")  
    Send('{ENTER}')
    Send('NEW{ENTER}')
    Send('10 A$="1"{ENTER}')
    Send('20 CLSVAL(A$){ENTER}')
    Send('30 A$=INKEY$:IFA$=""GOTO30{ENTER}')
    Send('40 IFA$="X"GOTO60{ENTER}')
    Send('50 GOTO20{ENTER}')
    Send('60 END{ENTER}')
    Send('RUN{ENTER}')
    ;
    $return = MsgBox($MB_YESNO, "Message", "Has the code run without syntax errors?")
    If $return = $IDNO Then
        Exit
    EndIf
EndFunc


Func create_color_definitions($window_handle, $windowWidth, $windowHeight)
    ; detect the color code and checksum and store those in the configuration file
    Local $color_list = ['black', 'green', 'yellow', 'blue', 'red', 'buff', 'cyan', 'magenta', 'orange']
    Local $icolor = 0
    Local $iSum = 0
    for $color_code = 0 to 8
        WinActivate($window_handle, "")  
        MouseMove(int($windowWidth / 2), int($windowHeight / 2))
        Local $startPosition = MouseGetPos()
        Send($color_code)
        Local $iColor = PixelGetColor($startPosition[0], $startPosition[1])
        Local $iSum = PixelChecksum($startPosition[0] - 3, $startPosition[1] - 3, $startPosition[0] + 3, $startPosition[1] + 3)
        WinActivate("[CLASS:Notepad]")
        Send($color_code & ' : ' & $color_list[$color_code] & ', ' & $iColor & ', ' & $iSum & '{ENTER}')
    Next
EndFunc


Func tear_down_color_definitions($window_handle)
    ; finalise the configuration routine
    WinActivate($window_handle, "")
    Send('X')
EndFunc

