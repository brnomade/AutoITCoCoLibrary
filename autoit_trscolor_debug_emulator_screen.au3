#include <MsgBoxConstants.au3>
#include "autoit_trscolor_automation_library.au3"

; Created by Andre Ballista - 2019
; GNU General Public License v3.0 - See LICENSE file for details.

; Initialise
initialise_automation()

; Start Script
activate_emulator_window()
waitForPrompt("Power Up","Boot")

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

;Script Body
activate_emulator_window()
for $y = 1 to 7
    for $x = 1 to 32
        position_mouse_at_location($x,$y)
        Local $iColor = get_color_at_location($x,$y)
        Local $iSum = get_color_checksum_at_location($x,$y)
        WinActivate("[CLASS:Notepad++]")
        Send("[" & $x & "," & $y & ":" & $iColor & "," & $iSum & "]")
        activate_emulator_window()
    Next
    WinActivate("[CLASS:Notepad++]")
    Send("{ENTER}")
    activate_emulator_window()
Next

; Exit Script
MsgBox($MB_OK, "Message", "Press OK to close script.")
finalise_automation()
