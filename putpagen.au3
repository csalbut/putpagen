; PuTTY colour palette generator
; Cezary Salbut

#include <GuiConstantsEx.au3>
#Include <ColorChooser.au3>
#Include <ColorPicker.au3>

Global Enum $BASE_R, $BASE_G, $BASE_B

Global $gui_width = 620
Global $gui_height = 400
Global $num_colors = 3
Global $num_base_colors = 3
Global $colors[$num_colors] = [ 0xff0000, 0x00ff00, 0x0077ff ]
Global $current_rgb[$num_base_colors] = [0x64, 0x64, 0x64]
Global $picker = 0

; GUI
GUICreate("PuTTY palette generator", $gui_width, $gui_height)

Global $console = GUICtrlCreateEdit("Debug console:" & @CRLF, 320, 100, 300, 300)

; BUTTON
GUICtrlCreateButton("Save", 10, 330, 100, 30)




TestAreaInit()
PickerInit()

; GUI MESSAGE LOOP
GUISetState(@SW_SHOW)

While 1
   Local $id = GUIGetMsg()
   Switch $id
	  Case $GUI_EVENT_CLOSE
		 Exit
   EndSwitch
WEnd


Func PickerInit()
   $picker = _GUIColorPicker_Create('', 5, 5, 60, 23, 0, $CP_FLAG_CHOOSERBUTTON, 0, -1, -1, 0, '', 'Custom...', '_ColorChooserDialog')
EndFunc


Func TestAreaInit()
   ; Palette test area
   Global $id_testline[$num_colors] 
   Global $testline_width = 300
   Local $id = 0
   GUISetCoord($gui_width - $testline_width, -15, $testline_width, 15)
   Opt("GUICoordMode", 2)
 
   For $i = 0 To ($num_colors - 1)
	  $id = GUICtrlCreateLabel("Sample text, 0123456789 -:.;'", -1, 0)
	  GUICtrlSetBkColor($id, 0x000000)
	  GUICtrlSetColor($id, $colors[$i])
	  GUICtrlSetFont($id, 10, 400, 1, "Consolas")
	  $id_testline[$i] = $id
   Next

   Opt("GUICoordMode", 1)
    Global $dbg = $id_testline[2]
EndFunc


