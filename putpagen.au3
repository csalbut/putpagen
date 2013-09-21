; PuTTY colour palette generator
; Cezary Salbut

#include <GuiConstantsEx.au3>
#include <AVIConstants.au3>
#include <TreeViewConstants.au3>

Global Enum $BASE_R, $BASE_G, $BASE_B

Global $gui_width = 620
Global $gui_height = 400
Global $num_colors = 3
Global $num_base_colors = 3
Global $colors[$num_colors] = [ 0xff0000, 0x00ff00, 0x0077ff ]
Global $current_rgb[$num_base_colors] = [0x64, 0x64, 0x64]

; GUI
GUICreate("PuTTY palette generator", $gui_width, $gui_height)

; EDIT
GUICtrlCreateEdit(@CRLF & "  Sample Edit Control", 10, 110, 150, 70)

; LIST
GUICtrlCreateList("", 5, 190, 100, 90)
GUICtrlSetData(-1, "A.Sample|B.List|C.Control|D.Here", "B.List")

; LIST VIEW
Local $iListView = GUICtrlCreateListView("Sample|ListView|", 110, 190, 110, 80)
GUICtrlCreateListViewItem("A|One", $iListView)
GUICtrlCreateListViewItem("B|Two", $iListView)
GUICtrlCreateListViewItem("C|Three", $iListView)

Global $console = GUICtrlCreateEdit("Debug console:" & @CRLF, 320, 100, 300, 300)

; BUTTON
GUICtrlCreateButton("Save", 10, 330, 100, 30)

SlidersInit()
TestAreaInit()

; GUI MESSAGE LOOP
GUISetState(@SW_SHOW)

While 1
   Local $id = GUIGetMsg()
   Switch $id
	  Case $id_sliders[$BASE_R]
		 SliderHandler($id)
	  Case $id_sliders[$BASE_G]
		 SliderHandler($id)
	  Case $id_sliders[$BASE_B]
		 SliderHandler($id)
	  Case $GUI_EVENT_CLOSE
		 Exit

   EndSwitch
WEnd


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


Func SlidersInit()
   $left_margin = 5
   $label_width = 10
   $input_width = 40
   $slider_width = 256
   $slider_height = 25

   Global $id_sliders[$num_base_colors] 
   Global $id_updowns[$num_base_colors] 
   Global $id_inputs[$num_base_colors] 

   GUISetCoord($left_margin, -$slider_height)
   Opt("GUICoordMode", 2)
   
   GUICtrlCreateLabel("R", -1, 0, 10, $slider_height)
   GUICtrlCreateLabel("G", -1, 0, 10, $slider_height)
   GUICtrlCreateLabel("B", -1, 0, 10, $slider_height)

   GUISetCoord($left_margin + $label_width, -$slider_height)

   $id_sliders[$BASE_R] = GUICtrlCreateSlider(-1, 0, $slider_width, $slider_height)
   $id_sliders[$BASE_G] = GUICtrlCreateSlider(-1, 0, $slider_width, $slider_height)
   $id_sliders[$BASE_B] = GUICtrlCreateSlider(-1, 0, $slider_width, $slider_height)

   GUISetCoord($left_margin + $label_width + $slider_width, -$slider_height)
   
   $id_inputs[$BASE_R]  = GUICtrlCreateInput($current_rgb[$BASE_R], -1, 0, $input_width, $slider_height)
   $id_updowns[$BASE_R] = GUICtrlCreateUpdown($id_inputs[$BASE_R])

   $id_inputs[$BASE_G]  = GUICtrlCreateInput($current_rgb[$BASE_G], -1, 0, $input_width, $slider_height)
   $id_updowns[$BASE_G] = GUICtrlCreateUpdown($id_inputs[$BASE_G])

   $id_inputs[$BASE_B]  = GUICtrlCreateInput($current_rgb[$BASE_B], -1, 0, $input_width, $slider_height)
   $id_updowns[$BASE_B] = GUICtrlCreateUpdown($id_inputs[$BASE_B])

   GUICtrlSetLimit($id_sliders[$BASE_R], 255)
   GUICtrlSetLimit($id_sliders[$BASE_G], 255)
   GUICtrlSetLimit($id_sliders[$BASE_B], 255)
   GUICtrlSetLimit($id_updowns[$BASE_R], 255)
   GUICtrlSetLimit($id_updowns[$BASE_G], 255)
   GUICtrlSetLimit($id_updowns[$BASE_B], 255)

   GUICtrlSetData($id_sliders[$BASE_R], $current_rgb[$BASE_R])
   GUICtrlSetData($id_updowns[$BASE_R], $current_rgb[$BASE_R])

   Opt("GUICoordMode", 1)   
EndFunc   


Func SliderHandler($id)
    Local $base_color

    Switch $id
	Case $id_sliders[$BASE_R]
	   $base_color = $BASE_R 
	Case $id_sliders[$BASE_G]
	   $base_color = $BASE_G 
	Case $id_sliders[$BASE_B]
	   $base_color = $BASE_B 
    EndSwitch

    $current_rgb[$base_color] = GUICtrlRead($id)
    GUICtrlSetData($id_inputs[$base_color], $current_rgb[$base_color])
    
    ;GUICtrlSetData($id_updowns[$BASE_G], $id)   
    ;GUICtrlSetData($id_inputs[$BASE_G], $current_rgb[$BASE_G])
    ;GUICtrlSetData($id_inputs[$BASE_B], $current_rgb[$BASE_B])
    GUICtrlSetData($console, "RGB: " & $current_rgb[$BASE_R] & " " & $current_rgb[$BASE_G] & " " & $current_rgb[$BASE_B])
EndFunc
