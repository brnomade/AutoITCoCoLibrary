#include <MsgBoxConstants.au3>
#include "autoit_trscolor_automation_library.au3"

; Created by Andre Ballista - 2020
; GNU General Public License v3.0 - See LICENSE file for details.

; This generates the configuration file containing the color definitions for the current computer.
; It will overwrite any existing file. 

; Initialise
initialise_automation("XROAR")

; Start Script

; as we don't have yet control over the emulator, we will wait a fixed number of seconds before
; atempting to call the emulator
Sleep(5000)

; enable the emulator screen
activate_emulator_window()

; create the color changing program
Send("{ENTER}")
Send("{ENTER}")
Send("NEW{ENTER}")
Send("10 CLS{ENTER}")
Send("20 FOR C = 0 TO 8{ENTER}")
Send("30 CLS C{ENTER}")
Send("40 FOR X = 1 TO 2000{ENTER}")
Send("50 NEXT X{ENTER}")
Send("60 NEXT C{ENTER}")
Send("70 END{ENTER}")
Send("RUN{ENTER}")

; Exit Script
MsgBox($MB_OK, "Message", "Press OK to close script.")
finalise_automation()