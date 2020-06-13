#include <MsgBoxConstants.au3>
;#include "autoit_trscolor_automation_library.au3"

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
If not WinExists($emulator_handle) Then
    MsgBox($MB_OK + $MB_ICONERROR, "Error during execution", "Couldn't find a running [" & $emulator_name & "] Emulator. Press OK to return to editor.")
    exit        
EndIf
run("notepad.exe")

; as we don't have yet control over the emulator, we will wait a fixed number of seconds before
; atempting to call the emulator
Sleep(5000)

setup_configuration_file($emulator_name)

setup_window_calibration($emulator_handle)
create_window_calibration($emulator_handle)
tear_down_window_calibration($emulator_handle)

setup_cell_calibration($emulator_handle)
;create_cell_calibration(emulator_handle)
;tear_down_cell_calibration(emulator_handle)

;setup_color_definitions($emulator)
;create_color_definitions()
;tear_down_color_definitions()




; Exit Script
MsgBox($MB_OK, "Message", "Press OK to close script.")
;finalise_automation()

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

Func _find_cell_boundaries_2($window_handle, $start_x, $start_y)
    WinActivate($window_handle, "")   
    ; AutoItSetOption('MouseCoordMode', 0)
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
    ;AutoItSetOption('MouseCoordMode', 1)
    Return $aResult
EndFunc

Func setup_window_calibration($window_handle)
    ; create the configuration program on the emulator
    WinActivate($window_handle, "")   
    Send('{ENTER}')
    Send('NEW{ENTER}')
    Send('10 CLS 1{ENTER}')
    Send('20 A$=INKEY$: IF A$="" GOTO 20{ENTER}')
    Send('RUN{ENTER}')
    ;
    $return = MsgBox($MB_YESNO, "Message", "Has the code run without syntax errors?")
    If $return = $IDNO Then
        Exit
    EndIf
EndFunc

Func create_window_calibration($window_handle)
    ; window size
    Local $aWindowSpec = WinGetPos($window_handle)
    WinActivate("[CLASS:Notepad]", "")
    Send('WindowSize=' & $aWindowSpec[2] & ', ' & $aWindowSpec[3] & '{ENTER}')
    ; find borders
    ;WinActivate($handle, "")   
    ;AutoItSetOption('MouseCoordMode', 0)
    Local $iposx = int($aWindowSpec[2] / 2)
    Local $iposy = int($aWindowSpec[3] / 2)
    Local $aBoundaries = _find_cell_boundaries_2($window_handle, int($aWindowSpec[2] / 2), int($aWindowSpec[3] / 2))
    ;MouseMove($iposx, $iposy)
    ;Local $startPosition = MouseGetPos()
    ;Local $color_code = PixelGetColor($startPosition[0], $startPosition[1])
    ;Local $new_color_code = $color_code
    ;While $new_color_code = $color_code
    ;    $startPosition[0] = $startPosition[0] - 1
    ;    MouseMove($startPosition[0], $startPosition[1])
    ;    $new_color_code = PixelGetColor($startPosition[0], $startPosition[1])
    ;WEnd
    ;Local $left_boundary = $startPosition[0] + 1
    WinActivate("[CLASS:Notepad]")
    Send('TopMargin:' & $aBoundaries[4] & '{ENTER}')
    Send('LowerMargin:' & $aBoundaries[3] & '{ENTER}')
    Send('RightMargin:' & $aBoundaries[2] & '{ENTER}')
    Send('LeftMargin:' & $aBoundaries[1] & '{ENTER}')
    ;AutoItSetOption('MouseCoordMode', 1)
EndFunc

Func tear_down_window_calibration($window_handle)
    ; finalise the configuration routine
    WinActivate($window_handle, "")
    Send('{ENTER}')
EndFunc

Func setup_color_definitions($emulator)
    ; add a section on the configuration file
    WinActivate("[CLASS:Notepad]", "")
    Send('[' & $emulator & ' Color Definitions]{ENTER}')

    ; create the configuration program on the emulator
    activate_emulator_window()
    Send('{ENTER}')
    Send('NEW{ENTER}')
    Send('10 A$=INKEY$: IF A$="" GOTO 10{ENTER}')
    Send('20 IF A$="X" GOTO 50{ENTER}')
    Send('30 CLS VAL(A$){ENTER}')
    Send('40 GOTO 10{ENTER}')
    Send('50 NEW{ENTER}')
    Send('RUN{ENTER}')

    $return = MsgBox($MB_YESNO, "Message", "Has the code run without syntax errors?")
    If $return = $IDNO Then
        Exit
    EndIf
EndFunc

Func create_color_definitions()
    ; detect the color code and checksum and store those in the configuration file
    Local $color_list = ['black', 'green', 'yellow', 'blue', 'red', 'buff', 'cyan', 'magenta', 'orange']
    Local $x = 10
    Local $y = 10
    Local $icolor = 0
    Local $iSum = 0
    for $color_code = 0 to 8
        activate_emulator_window()
        position_mouse_at_location($x,$y)
        Send($color_code)
        $iColor = get_color_at_location($x,$y)
        $iSum = get_color_checksum_at_location($x,$y)
        WinActivate("[CLASS:Notepad]")
        Send($color_code & ' : ' & $color_list[$color_code] & ', ' & $iColor & ', ' & $iSum & '{ENTER}')
    Next
EndFunc

Func tear_down_color_definitions()
    ; finalise the configuration routine
    activate_emulator_window()
    Send('X')
    Send('{ENTER}')
EndFunc

Func setup_cell_calibration($window_handle)
    ; add new section on configuration file
    ;WinActivate("[CLASS:Notepad]")
    ;Send('{ENTER}')
    ;Send('[' & $emulator & ' Configuration]{ENTER}')

    ; create the configuration program on the emulator
    WinActivate($window_handle, "")   
    Send('{ENTER}')
    Send('NEW{ENTER}')
    Send('10 CLS 0{ENTER}')
    Send('20 FOR Y = 1 TO 4: FOR X = 143 TO 255 STEP 16{ENTER}')
    Send('30 PRINT CHR$(X);{ENTER}')
    Send('40 NEXT X, Y{ENTER}')
    Send('50 A$=INKEY$: IF A$="" GOTO 50{ENTER}')
    Send('RUN{ENTER}')

    $return = MsgBox($MB_YESNO, "Message", "Has the code run without syntax errors?")
    If $return = $IDNO Then
        Exit
    EndIf
EndFunc

Func _find_cell_boundaries( $start_x, $start_y)
    activate_emulator_window()
    ;
    ; find the left boundary of the current color
    position_mouse_at_location($start_x, $start_y)
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
    position_mouse_at_location($start_x, $start_y)
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
    position_mouse_at_location($start_x, $start_y)
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
    position_mouse_at_location($start_x, $start_y)
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
 
Func create_cell_calibration($window_handle)
    ; calibrate the cell size
    Local $aBoundaries_1 = find_cell_boundaries( 1, 1)
    Local $aBoundaries_2 = find_cell_boundaries( 15, 1)
    Local $aBoundaries_3 = find_cell_boundaries( 30, 1)
    WinActivate("[CLASS:Notepad]")
    Send('[CellWidth:' & $aBoundaries_1[2] - $aBoundaries_1[1] & ']{ENTER}')
    Send('[CellHeight:' & $aBoundaries_1[3] - $aBoundaries_1[4] & ']{ENTER}')
    Send('[CellWidth:' & $aBoundaries_2[2] - $aBoundaries_2[1] & ']{ENTER}')
    Send('[CellHeight:' & $aBoundaries_2[3] - $aBoundaries_2[4] & ']{ENTER}')
    Send('[CellWidth:' & $aBoundaries_3[2] - $aBoundaries_3[1] & ']{ENTER}')
    Send('[CellHeight:' & $aBoundaries_3[3] - $aBoundaries_3[4] & ']{ENTER}')
EndFunc

Func tear_down_cell_calibration()
    ; finalise the configuration routine
    activate_emulator_window()
    Send('{ENTER}')
EndFunc
