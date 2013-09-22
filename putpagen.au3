; PuTTY colour palette generator
; Cezary Salbut

#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <ColorChooser.au3>
#Include <ColorPicker.au3>

Global Enum $BASE_R, $BASE_G, $BASE_B

Global $iGuiWidth = 620
Global $iGuiHeight = 400
Global $iTestlineWidth = 300
Global $iTestlineHeight = 15
Global $iTestlineX = $iGuiWidth - $iTestlineWidth
Global $iTestlineY = 0
Global $iColorlistWidth = 150
Global $iColorlistHeight = 300
Global $iColorlistX = $iGuiWidth - $iTestlineWidth - $iColorlistWidth
Global $iColorlistY = 0

Global $iNumColors = 22
Global $iNumBaseColors = 3

Global $aiCurrentRgb[$iNumBaseColors] = [0x64, 0x64, 0x64]
Global $aiColorsRgb[$iNumColors] = [ 0xff0000, 0x00ff00, 0x0077ff ]

; Array of Putty color text identifiers
Global $asColorsText[$iNumColors] = [ _
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

; Program start
; -----------------------------------------------------------------------------
GUICreate("PuTTY palette generator", $iGuiWidth, $iGuiHeight)
Global $hDbg = GUICtrlCreateList("Debug console", 0, 30, 150, 300, $WS_VSCROLL)
GUICtrlCreateButton("Save", 10, 330, 100, 30)

TestAreaInit()
PickerInit()
ColorListInit()

; GUI MESSAGE LOOP
GUISetState(@SW_SHOW)

While 1
   Local $h = GUIGetMsg()

   Switch $h

      Case $hColorList
         ColorListHandler()

      Case $hPicker
         PickerHandler()

      Case $hTestline[0]
         GUICtrlSetData($hDbg, "Testline[0] clicked!")

      Case $GUI_EVENT_CLOSE
         Exit

   EndSwitch

WEnd


; Function definitions
; -----------------------------------------------------------------------------
Func PickerInit()
   Global $hPicker = _GUIColorPicker_Create('', 5, 5, 60, 23, 0, $CP_FLAG_CHOOSERBUTTON, 0, -1, -1, 0, '', 'Custom...', '_ColorChooserDialog')
EndFunc


Func ColorListInit()
   Local $style = 0
   Global $hColorList = GUICtrlCreateList( "", _
          $iColorlistX, $iColorlistY, $iColorlistWidth, $iColorlistHeight, $style )

   For $i = 0 To ($iNumColors - 1)
      GUICtrlSetData($hColorList, $asColorsText[$i])
   Next

EndFunc


Func TestAreaInit()
   Global $hTestline[$iNumColors] 
   Global $iTestlineWidth = 300
   Local $h = 0

   GUISetCoord($iTestlineX, $iTestlineY - $iTestlineHeight, $iTestlineWidth, $iTestlineHeight)
   Opt("GUICoordMode", 2)
 
   For $i = 0 To ($iNumColors - 1)
      $h = GUICtrlCreateLabel("Sample text, 0123456789 -:.;'", -1, 0)
      GUICtrlSetBkColor($h, 0x000000)
      GUICtrlSetColor($h, $aiColorsRgb[$i])
      GUICtrlSetFont($h, 10, 400, 1, "Consolas")
      $hTestline[$i] = $h
   Next

   Opt("GUICoordMode", 1)
EndFunc


Func PickerHandler()
   Local $iColorNew = _GUIColorPicker_GetColor($hPicker)
   Local $iColorNum = GetSelColorNum()
   $aiColorsRgb[$iColorNum] = $iColorNew
   GUICtrlSetColor($hTestline[$iColorNum], $aiColorsRgb[$iColorNum])
EndFunc


Func ColorListHandler()
   $sColorText = GUICtrlRead($hColorList)
   $iColorNum = GetColorNum($sColorText)
   _GUIColorPicker_SetColor($hPicker, $aiColorsRgb[$iColorNum])
EndFunc


Func GetColorNum($sColorText)
   Local $i = 0
   Local $sColor = 0

   For $sColor In $asColorsText

      If $sColor = $sColorText Then
         Return $i
      EndIf 

      $i = $i + 1

   Next
EndFunc


; Return number of the currently selected putty color
Func GetSelColorNum()
   Local $sSelColorText = GUICtrlRead($hColorList)
   Return GetColorNum($sSelColorText)
EndFunc
