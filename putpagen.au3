; PuTTY colour palette generator
; Cezary Salbut

#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <ColorChooser.au3>
#Include <ColorPicker.au3>

Global Enum $BASE_R, $BASE_G, $BASE_B

Global $gui_width = 620
Global $gui_height = 400
Global $testline_width = 300
Global $testline_height = 15
Global $testline_x = $gui_width - $testline_width
Global $testline_y = 0
Global $colorlist_width = 150
Global $colorlist_height = 300
Global $colorlist_x = $gui_width - $testline_width - $colorlist_width
Global $colorlist_y = 0

Global $num_colors = 22
Global $num_base_colors = 3
Global $colors[$num_colors] = [ 0xff0000, 0x00ff00, 0x0077ff ]
Global $current_rgb[$num_base_colors] = [0x64, 0x64, 0x64]
Global $picker = 0

; Enum Putty Color
Global Enum _
   $ePC_FOREGROUND, _
   $ePC_FOREGROUND_BOLD, _
   $ePC_BACKGROUND, _
   $ePC_BACKGROUND_BOLD, _
   $ePC_CURSOR_TEXT, _
   $ePC_CURSOR_COLOUR, _
   $ePC_BLACK, _
   $ePC_BLACK_BOLD, _
   $ePC_RED, _
   $ePC_RED_BOLD, _
   $ePC_GREEN, _
   $ePC_GREEN_BOLD, _
   $ePC_YELLOW, _
   $ePC_YELLOW_BOLD, _
   $ePC_BLUE, _
   $ePC_BLUE_BOLD, _
   $ePC_MAGENTA, _
   $ePC_MAGENTA_BOLD, _
   $ePC_CYAN, _
   $ePC_CYAN_BOLD, _
   $ePC_WHITE, _
   $ePC_WHITE_BOLD

; Array of Putty color text identifiers
Global $aPcTexts[$num_colors] = [ _
   "Default Foreground", _
   "Default Bold Foreground", _
   "Default Background", _
   "Default Bold Background", _
   "Cursor Text", _
   "Cursor Colour", _
   "Black", _
   "Black Bold", _
   "Red", _
   "Red Bold", _
   "Green", _
   "Green Bold", _
   "Yellow", _
   "Yellow Bold", _
   "Blue", _
   "Blue Bold", _
   "Magenta", _
   "Magenta Bold", _
   "Cyan", _
   "Cyan Bold", _
   "White", _
   "White Bold" _
]


GUICreate("PuTTY palette generator", $gui_width, $gui_height)
Global $console = GUICtrlCreateList("Debug console", 0, 30, 150, 300, $WS_VSCROLL)
GUICtrlCreateButton("Save", 10, 330, 100, 30)

TestAreaInit()
PickerInit()
ColorListInit()

; GUI MESSAGE LOOP
GUISetState(@SW_SHOW)

While 1
   Local $id = GUIGetMsg()

   Switch $id

      Case $ColorList
         $ColorText = GUICtrlRead($ColorList)
         $ColorNum = GetColorNum($ColorText)
         _GUIColorPicker_SetColor($picker, $colors[$ColorNum])

      Case $picker
         PickerHandler()

      Case $GUI_EVENT_CLOSE
         Exit

   EndSwitch

WEnd


Func PickerInit()
   $picker = _GUIColorPicker_Create('', 5, 5, 60, 23, 0, $CP_FLAG_CHOOSERBUTTON, 0, -1, -1, 0, '', 'Custom...', '_ColorChooserDialog')
EndFunc


Func ColorListInit()
   Local $style = 0
   Global $ColorList = GUICtrlCreateList( "", _
          $colorlist_x, $colorlist_y, $colorlist_width, $colorlist_height, $style )

   For $i = 0 To ($num_colors - 1)
      GUICtrlSetData($ColorList, $aPcTexts[$i])
   Next

EndFunc


Func TestAreaInit()
   ; Palette test area
   Global $id_testline[$num_colors] 
   Global $testline_width = 300
   Local $id = 0
   GUISetCoord($testline_x, $testline_y - $testline_height, $testline_width, $testline_height)
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


Func PickerHandler()
   Local $ColorNew = _GUIColorPicker_GetColor($picker)
   $colors[GetSelColorNum()] = $ColorNew
   GUICtrlSetData($console, $ColorNew)
EndFunc


Func ColorListHandler()
EndFunc


Func GetColorNum($PcText)
   Local $i = 0
   Local $color = 0

   For $color In $aPcTexts

      If $color = $PcText Then
         Return $i
      EndIf 

      $i = $i + 1

   Next
EndFunc


; Return number of the currently selected putty color
Func GetSelColorNum()
   Local $SelColorText = GUICtrlRead($ColorList)
   Return GetColorNum($ColorText)
EndFunc
