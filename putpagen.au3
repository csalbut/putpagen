; PuTTY colour palette generator
; Copyright (c) 2013, Cezary Salbut
; All rights reserved.

#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Constants.au3>
#include <ScrollBarConstants.au3>
#Include <ColorChooser.au3>
#Include <ColorPicker.au3>
#include <GUIListBox.au3>
#include <GuiTreeView.au3>
#include <GuiEdit.au3>

; Global variables
; -----------------------------------------------------------------------------
Global $bDbgEnabled = 0

Global $iNumColors = 22
Global $iNumBaseColors = 3

Global $iColorlistWidth = 150
Global $iColorlistHeight = 300
Global $iColorlistX = 0
Global $iColorlistY = 0

Global $iTestlineWidth = 300
Global $iTestlineHeight = 15
Global $iTestlineX = $iColorlistX + $iColorlistWidth
Global $iTestlineY = 0

Global $iPickerWidth = $iColorlistWidth
Global $iPickerHeight = $iTestlineHeight * $iNumColors - $iColorlistHeight + 10
Global $iPickerX = $iColorlistX
Global $iPickerY = $iColorlistY + $iColorlistHeight - 10

If $bDbgEnabled Then
   Global $iDbgWidth = 200
   Global $iDbgHeight = $iColorlistHeight + $iPickerHeight - 10
   Global $iDbgX = $iTestlineX + $iTestlineWidth
   Global $iDbgY = 0
Else
   Global $iDbgWidth = 0
   Global $iDbgHeight = 0
   Global $iDbgX = 0
   Global $iDbgY = 0
Endif

Global $iBtnHeight = 30
Global $iNumBtns = 2

Global $iGuiWidth = $iColorlistWidth + $iTestlineWidth + $iDbgWidth
Global $iGuiHeight = $iColorlistHeight + $iPickerHeight + $iBtnHeight

Global $iBtnWidth = $iGuiWidth / 2
Global $iBtnY = $iColorlistHeight + $iPickerHeight - 6

Global $aiCurrentRgb[$iNumBaseColors]
Global $aiColorsRgb[$iNumColors]


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
Global $hGuiApp = GUICreate("PuTTY palette generator", $iGuiWidth, $iGuiHeight, 900, 500)
GuiSetIcon("putpagen.ico")

TestAreaInit()
PickerInit()
ColorListInit()
ButtonsInit()
DbgInit()
ReadPalette("arch")

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
        Print("Testline[0] clicked!")

      Case $hBtnSave
         BtnSaveHandler()

      Case $hBtnUpdate
         BtnUpdateHandler()

      Case $GUI_EVENT_CLOSE
         Exit

   EndSwitch

WEnd


; Function definitions
; -----------------------------------------------------------------------------
Func PickerInit()
   Global $hPicker = _GUIColorPicker_Create('', $iPickerX, $iPickerY, _
                     $iPickerWidth, $iPickerHeight, 0, $CP_FLAG_CHOOSERBUTTON, _
                     0, -1, -1, 0, '', 'Custom...', '_ColorChooserDialog')
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
      If NOT IsColorSpecial($i) Then
         $h = GUICtrlCreateLabel("Sample text, " & $asColorsText[$i], -1, 0)
         GUICtrlSetBkColor($h, 0x00000000)
         $aiColorsRgb[$i] = 0x808080
         GUICtrlSetColor($h, $aiColorsRgb[$i])
         GUICtrlSetFont($h, 10, 400, 1, "Consolas")
         $hTestline[$i] = $h
      Endif
   Next

   Opt("GUICoordMode", 1)
EndFunc


Func ButtonsInit()
   Global $hBtnSave = GUICtrlCreateButton("&Save", _
                     0, $iBtnY, $iBtnWidth, $iBtnHeight)
   Global $hBtnUpdate = GUICtrlCreateButton("&Update PuTTY", _
                     $iBtnWidth * 1, $iBtnY, $iBtnWidth, $iBtnHeight)
EndFunc


Func DbgInit()
   If $bDbgEnabled Then
      Global $hDbg = GUICtrlCreateEdit("", $iDbgX, $iDbgY, $iDbgWidth, $iDbgHeight, _
                     $ES_AUTOVSCROLL + $ES_MULTILINE + $ES_READONLY + $WS_VSCROLL)
   Endif
EndFunc


Func PickerHandler()
   Local $iColorNew = _GUIColorPicker_GetColor($hPicker)
   Local $iColorNum = GetSelColorNum()
   $aiColorsRgb[$iColorNum] = $iColorNew
   GUICtrlSetColor($hTestline[$iColorNum], $aiColorsRgb[$iColorNum])
   If $iColorNum = 2 Then
      BgUpdate()
   EndIf
EndFunc


Func ColorListHandler()
   $sColorText = GUICtrlRead($hColorList)
   $iColorNum = GetColorNum($sColorText)
   _GUIColorPicker_SetColor($hPicker, $aiColorsRgb[$iColorNum])
EndFunc


Func BtnSaveHandler()
   Local $sFileName = "putty_colors.reg"
   Local $hFile = FileOpen($sFileName, $FO_OVERWRITE)
   Local $sSessionName = "arch"

   If $hFile <> -1 Then
      WritePalette($hFile, $sSessionName)
      FileClose($hFile)
   Else
      MsgBox($MB_OK, "Error", "Unable to save the file.")
   Endif

EndFunc


Func BtnUpdateHandler()
   Local $hPutty = WinGetHandle ("[CLASS:PuTTY]")
   Print("hPutty: " & $hPutty)

   _PostMessage($hPutty, $WM_SYSCOMMAND, 0x0050, 0x0)
   Local $hConfig = WinWait("PuTTY Reconfiguration", "", 3)
   WinActivate("PuTTY Reconfiguration")
   Print("hConfig: " & $hConfig)

   Local $hTree = ControlGetHandle($hConfig, "", "[CLASS:SysTreeView32]")
   Print("hTree: " & $hTree)
   ControlTreeView($hConfig, "", $hTree, "Select", "Window|Colours")
   ControlSend($hTree, "", Default, "{DOWN}")

   Local $hList = GetChildWindow($hConfig, "ListBox")
   Print("hList: " & $hList)

   For $i = 0 To ($iNumColors - 1)
      _GUICtrlListBox_SetCurSel($hList, $i)
      ControlSetText("", "", 0x41E, GetR($aiColorsRgb[$i]))
      ControlSetText("", "", 0x420, GetG($aiColorsRgb[$i]))
      ControlSetText("", "", 0x422, GetB($aiColorsRgb[$i]))
   Next

   ; Apply
   ControlClick("", "", 0x3F1)
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


; Writes the colour palette to an open file
Func WritePalette($hFile, $sSessionName)
   FileWriteLine($hFile, "Windows Registry Editor Version 5.00")
   FileWriteLine($hFile, "")
   FileWriteLine($hFile, _
         "[HKEY_CURRENT_USER\Software\SimonTatham\PuTTY\Sessions\" & _
         $sSessionName & "]")

   For $i = 0 To ($iNumColors - 1)
      Local $iRgb = $aiColorsRgb[$i]
      Local $sRgb = RgbItoS($iRgb)
      FileWriteLine($hFile, '"Colour' & $i & '"="' & $sRgb & '"')
   Next
EndFunc


; Return R value from RGB integer
Func GetR($iRgb)
   Return BitShift(BitAnd($iRgb, 0xff0000), 2 * 8)
EndFunc

; Return G value from RGB integer
Func GetG($iRgb)
   Return BitShift(BitAnd($iRgb, 0x00ff00), 1 * 8)
EndFunc

; Return B value from RGB integer
Func GetB($iRgb)
   Return BitShift(BitAnd($iRgb, 0x0000ff), 0 * 8)
EndFunc

; Convert RGB integer to putty-format string (comma-separated decimals)
Func RgbItoS($iRgb)
   Local $iR = GetR($iRgb)
   Local $iG = GetG($iRgb)
   Local $iB = GetB($iRgb)

   Local $sRgb = String($iR) & "," & String($iG) & "," & String($iB)
   return $sRgb
EndFunc


; Convert RGB string (comma-separated decimals) to integer
Func RgbStoI($sRgb)
   Local $asRgb[$iNumBaseColors]
   $asRgb = StringSplit($sRgb, ",", 2)

   Local $iR = Number($asRgb[0])
   Local $iG = Number($asRgb[1])
   Local $iB = Number($asRgb[2])

   Local $iRgb = BitShift($iR, -2 * 8) _
               + BitShift($iG, -1 * 8) _
               + BitShift($iB, -0 * 8)

   return $iRgb
EndFunc


; Load a colour palette from saved putty session
Func ReadPalette($sSession)

   For $i = 0 To ($iNumColors - 1)

      Local $sRgb = RegRead( _
            "HKEY_CURRENT_USER\Software\SimonTatham\PuTTY\Sessions\" _
            & $sSession, "Colour" & String($i))

      $aiColorsRgb[$i] = RgbStoI($sRgb)
      GUICtrlSetColor($hTestline[$i], $aiColorsRgb[$i])
   Next

   BgUpdate()
EndFunc


; Update background color to what is currently configured
Func BgUpdate()
   For $i = 0 To ($iNumColors - 1)
      GUICtrlSetBkColor($hTestline[$i], $aiColorsRgb[2])
   Next
EndFunc


; Backgrounds and cursor stuff are special
Func IsColorSpecial($iColorNum)
   If $iColorNum >= 2 AND $iColorNum <= 5 Then
      Return True
   Else
      Return False
   Endif
EndFunc


; Print a string to the debug console
Func Print($sText)
   If $bDbgEnabled Then
      $iEnd = StringLen(GUICtrlRead($hDbg))
      _GUICtrlEdit_SetSel($hDbg, $iEnd, $iEnd)
      _GUICtrlEdit_Scroll($hDbg, $SB_SCROLLCARET)
      GUICtrlSetData($hDbg, $sText & @CRLF, 1)
   EndIf
EndFunc


; see _SendMessage in SendMessage.au3
Func _PostMessage($hWnd, $iMsg, $wParam = 0, $lParam = 0, $iReturn = 0, _
                $wParamType = "wparam", $lParamType = "lparam", $sReturnType = "lresult")
        Local $aResult = DllCall("user32.dll", $sReturnType, "PostMessageW", "hwnd", _
                $hWnd, "uint", $iMsg, $wParamType, $wParam, $lParamType, $lParam)
        If @error Then Return SetError(@error, @extended, "")
        If $iReturn >= 0 And $iReturn <= 4 Then Return $aResult[$iReturn]
        Return $aResult
EndFunc


Func GetChildWindow($hWnd, $sClassName)
        If $hWnd = 0 Then Return 0
        Local $hChild = _WinAPI_GetWindow($hWnd, $GW_CHILD)
        While $hChild
                If _WinAPI_GetClassName($hChild) = $sClassName Then Return $hChild
                $hChild = _WinAPI_GetWindow($hChild, $GW_HWNDNEXT)
        WEnd
        Return 0
EndFunc

