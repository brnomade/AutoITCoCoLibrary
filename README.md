# AutoITCoCoLibrary
AutoIT library for the Tandy Color Computer (CoCo) and emulators (XROAR and MESS)

Requirements:
Windows platform only (constrained by AUTOIT)
AUTOIT needs to be installed - https://www.autoitscript.com/site/autoit/
XROAR needs to be installed
MAME needs to be installed

How to Use It:
See autoit_trscolor_debug_emulator_screen.au3 as an example on how to use
General pattern:
1. ensure the configuration file (autoit_trscolor_automation_library.ini) is updated
2. call initialise_automation()
3. use activate_emulator_window() to bring the emulator window into focus. The function assumes the emulator is already running on the computer.
4. 

Main functions:
