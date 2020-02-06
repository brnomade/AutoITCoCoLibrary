#include <MsgBoxConstants.au3>
#include "autoit_trscolor_automation_library.au3"

; Created by Andre Ballista - 2019
; GNU General Public License v3.0 - See LICENSE file for details.

; This demonstrate the use of get_color_at_location and get_color_checksum_at_location functions
; Such functions can be used to identify the precise colour codes used by the emulators on the user computer. 
; The precise colour codes are needed for the ini file configuration.
; This script requires an active emulator and a Notepad++ page tab where the color codes will be printed. 

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
