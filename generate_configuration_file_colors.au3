#include <MsgBoxConstants.au3>
#include "autoit_trscolor_automation_library.au3"

; Created by Andre Ballista - 2020
; GNU General Public License v3.0 - See LICENSE file for details.

; This generates the configuration file containing the color definitions for the current computer.
; It will overwrite any existing file. 

; Initialise
initialise_automation("XROAR")
run("notepad.exe")

; Start Script

; as we don't have yet control over the emulator, we will wait a fixed number of seconds before
; atempting to call the emulator
Sleep(5000)

; open the new configuration file
WinActivate("[CLASS:Notepad]", "")
Send('; Color Definitions{ENTER}')
Send('[XROAR]{ENTER}')

; enable the emulator screen
activate_emulator_window()

; create the color changing program
Send('{ENTER}')
Send('NEW{ENTER}')
Send('10 A$=INKEY${ENTER}')
Send('20 IF A$="" GOTO 10{ENTER}')
Send('30 CLS VAL(A$){ENTER}')
Send('40 GOTO 10{ENTER}')
Send('RUN{ENTER}')

$return = MsgBox($MB_YESNO, "Message", "Has the code run without syntax errors?")
If $return = $IDNO Then
    Exit
EndIf

;Script Body
Local $color_list = ['black', 'green', 'yellow', 'blue', 'red', 'buff', 'cyan', 'magenta', 'orange']
Local $x = 10
Local $y = 10
for $coco_color = 0 to 8
    activate_emulator_window()
    position_mouse_at_location($x,$y)
    Send($coco_color)
    Local $iColor = get_color_at_location($x,$y)
    Local $iSum = get_color_checksum_at_location($x,$y)
    WinActivate("[CLASS:Notepad]")
    Send($coco_color & ' : ' & $color_list[$coco_color] & ', ' & $iColor & ', ' & $iSum & '{ENTER}')
Next



; Exit Script
MsgBox($MB_OK, "Message", "Press OK to close script.")
finalise_automation()