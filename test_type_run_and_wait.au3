#include <MsgBoxConstants.au3>
#include "autoit_trscolor_automation_library.au3"

; Created by Andre Ballista - 2019
; GNU General Public License v3.0 - See LICENSE file for details.


; This demonstrate the use of position_mouse_at_location and wait_for_prompt_at_location functions
; Such functions allow the precise positioning of the cursor on the emulator screen and detection of the blinking prompt


; Initialise
initialise_automation("XROAR")

; Start Script
activate_emulator_window()
wait_for_prompt("Power Up","Boot")

Send("NEW{ENTER}")
Send("1 CLS{ENTER}")
Send("2 FOR Y = 1 TO 2{ENTER}")
Send("3 FOR X = 1 TO 255{ENTER}")
Send("4 PRINT CHR$(X);{ENTER}")
Send("5 NEXT X{ENTER}")
Send("6 NEXT Y{ENTER}")
Send("7 END{ENTER}")
Send("RUN{ENTER}")

; Change settings
AutoItSetOption ("SendKeyDownDelay" , 5)
AutoItSetOption ("SendKeyDelay" , 5)

position_mouse_at_location(1,16)
wait_for_prompt_at_location(1,16)

; Exit Script
MsgBox($MB_OK, "Message", "Cursor detected at line 16 column 1. Press OK to close script.")
finalise_automation()
