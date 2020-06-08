#include <MsgBoxConstants.au3>
#include "autoit_trscolor_automation_library.au3"

; Created by Andre Ballista - 2020
; GNU General Public License v3.0 - See LICENSE file for details.

; This generates the configuration file containing the color definitions for the current computer.
; It will overwrite any existing file. 

;
$emulator = "XROAR"

; Initialise
initialise_automation($emulator)
run("notepad.exe")

; as we don't have yet control over the emulator, we will wait a fixed number of seconds before
; atempting to call the emulator
Sleep(5000)

;setup_color_definitions($emulator)
;create_color_definitions()
;tear_down_color_definitions()

setup_position_calibration($emulator)
create_position_calibration()

; Exit Script
MsgBox($MB_OK, "Message", "Press OK to close script.")
finalise_automation()


Func setup_color_definitions($emulator)
    ; open the new configuration file
    WinActivate("[CLASS:Notepad]", "")
    Send('[Emulator Configuration]{ENTER}')
    Send('; valid values are MAME and XROAR{ENTER}')
    Send('EmulatorName=' & $emulator & '{ENTER}')
    Send('{ENTER}')
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
    ; finalise the previous configuration program
    activate_emulator_window()
    Send('X')
    Send('{ENTER}')
EndFunc

Func setup_position_calibration($emulator)
    ; add new section on configuration file
    WinActivate("[CLASS:Notepad]")
    Send('{ENTER}')
    Send('[' & $emulator & ' Configuration]{ENTER}')

    ; create the configuration program on the emulator
    activate_emulator_window()
    Send('10 CLS{ENTER}')
    Send('20 FOR Y = 1 TO 4: FOR X = 143 TO 255 STEP 16{ENTER}')
    Send('30 PRINT CHR$(X);{ENTER}')
    Send('40 NEXT X, Y{ENTER}')
    Send('50 A$=INKEY$: IF A$="" GOTO 50{ENTER}')
    Send('RUN{ENTER}')

    ; calibrate the cell size
    $return = MsgBox($MB_YESNO, "Message", "Has the code run without syntax errors?")
    If $return = $IDNO Then
        Exit
    EndIf
EndFunc

Func create_position_calibration()
    activate_emulator_window()
    position_mouse_at_location(1,1)
    $aCurrentPosition = MouseGetPos()
    $color_code = PixelGetColor($aCurrentPosition[0], $aCurrentPosition[1])
    WinActivate("[CLASS:Notepad]")
    Send($color_code & '{ENTER}')
    ; MouseMove($aOriginalPosition[0], $aOriginalPosition[1], 0)
EndFunc
