; PuTTY colour palette generator
; Copyright (c) 2013, Cezary Salbut
; All rights reserved.
;
; TODO:
; * Allow user to select an export file (standard "save as" dialog)
; * Add "save" button, to save current color settings to Windows registry
; * Add version information to titlebar
; * Font configurable via ini file
; * Disable exiting with Esc
; * Add a button to set default ANSI colours

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

Global $iColorlistWidth = 140
Global $iColorlistHeight = 300
Global $iColorlistX = 0
Global $iColorlistY = 0

Global $iTestlineWidth = 300
Global $iTestlineHeight = 16
Global $iTestlineX = $iColorlistX + $iColorlistWidth + 1
Global $iTestlineY = 0

Global $iPickerWidth = $iColorlistWidth
Global $iPickerHeight = 40
Global $iPickerX = $iColorlistX
Global $iPickerY = $iColorlistY + $iColorlistHeight - 10

Global $iSessionListWidth = $iTestlineWidth - 20
Global $iSessionListHeight = 20
Global $iSessionListX = $iTestlineX + 10
Global $iSessionListY = $iPickerY + 18

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

Global $iTipBarWidth = $iColorlistWidth + $iTestlineWidth + $iDbgWidth
Global $iTipBarHeight = 15
Global $iTipBarX = 0
Global $iTipBarY = $iColorlistHeight + $iPickerHeight + $iBtnHeight - 5

Global $iGuiWidth = $iColorlistWidth + $iTestlineWidth + $iDbgWidth
Global $iGuiHeight = $iColorlistHeight + $iPickerHeight + $iBtnHeight + $iTipBarHeight - 5

Global $iBtnWidth = $iGuiWidth / 2
Global $iBtnY = $iColorlistHeight + $iPickerHeight - 6

Global $aiCurrentRgb[$iNumBaseColors]
Global $aiColorsRgb[$iNumColors]

Global $asSessions[1]
Global $sSessionNow = ""


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
Local $aiGuiPos[2]
$aiGuiPos= GetGuiPos("putpagen.ini")
Local $iGuiX = $aiGuiPos[0]
Local $iGuiY = $aiGuiPos[1]

Global $hGuiApp = GUICreate("PuTTY palette generator", $iGuiWidth, $iGuiHeight, $iGuiX, $iGuiY)
GuiSetIcon("putpagen.ico")

TestAreaInit()
PickerInit()
ColorListInit()
ButtonsInit()
DbgInit()
SessionsFind($asSessions)
SessionListInit($asSessions)
$sSessionNow = $asSessions[0]
ReadPalette($sSessionNow)
TipBarInit()

; GUI MESSAGE LOOP
GUISetState(@SW_SHOW)

While 1
   Local $h = GUIGetMsg()

   Switch $h

      Case $hColorList
         ColorListHandler()

      Case $hSessionList
         SessionListHandler()

      Case $hPicker
         PickerHandler()

      Case $hTestline[0]
        Print("Testline[0] clicked!")

      Case $hBtnExport
         BtnExportHandler()

      Case $hBtnUpdate
         BtnUpdateHandler()

      Case $GUI_EVENT_CLOSE
         ConfFileUpdate()
         Exit

   EndSwitch

   HoverHandler()

WEnd


; Function definitions
; -----------------------------------------------------------------------------
Func GetGuiPos($sConfFile)
   Local $hConfFile = FileOpen($sConfFile, $FO_READ)
   Local $aRetPos[2]

   If $hConfFile <> -1 Then
      Local $aConfEntry

      $aConfEntry = StringSplit(StringStripWs(FileReadLine($hConfFile, 1), _
                           $STR_STRIPALL), "=", 2)
      $aRetPos[0] = $aConfEntry[1]

      $aConfEntry = StringSplit(StringStripWs(FileReadLine($hConfFile, 2), _
                           $STR_STRIPALL), "=", 2)
      $aRetPos[1] = $aConfEntry[1]

      FileClose($hConfFile)
   Else
      $aRetPos[0] = -1
      $aRetPos[1] = -1
   EndIf

   Return $aRetPos
EndFunc

Func ConfFileUpdate()
   Local $hConfFile = FileOpen("putpagen.ini", $FO_OVERWRITE)
   If $hConfFile <> -1 Then
      Local $aiGuiPos = WinGetPos($hGuiApp)
      FileWriteLine($hConfFile, "gui_x = " & $aiGuiPos[0])
      FileWriteLine($hConfFile, "gui_y = " & $aiGuiPos[1])
      FileClose($hConfFile)
   Else
      MsgBox($MB_OK, "Error", "Unable to open configuration file.")
      Exit
   Endif

EndFunc

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


Func SessionListInit($asList)
   GUICtrlCreateLabel("Session" , $iSessionListX + 2, $iSessionListY - 13)
   Global $hSessionList = GUICtrlCreateCombo($asList[0], _
          $iSessionListX, $iSessionListY, $iSessionListWidth, $iSessionListHeight)

   Print("size: " & UBound($asList))
   For $i = 0 To UBound($asList) - 1
      GUICtrlSetData($hSessionList, $asList[$i])
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
   Global $hBtnExport = GUICtrlCreateButton("&Export", _
                     $iBtnWidth * 1, $iBtnY, $iBtnWidth, $iBtnHeight)
   Global $hBtnUpdate = GUICtrlCreateButton("&Update PuTTY", _
                     0, $iBtnY, $iBtnWidth, $iBtnHeight)
   SeparatorHoriz(0, $iBtnY - 2, $iGuiWidth)
EndFunc


Func TipBarInit()
   Global $hTipBar = GUICtrlCreateLabel("", _
                     $iTipBarX, $iTipBarY, $iTipBarWidth, $iTipBarHeight)
   SeparatorHoriz(0, $iTipBarY, $iGuiWidth)
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


Func SessionListHandler()
   Local $s = GUICtrlRead($hSessionList)
   Print("Combo: " & $s)
   $sSessionNow = $s
   ReadPalette($sSessionNow)
EndFunc


Func BtnExportHandler()
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

   TipBarPrint("Updated")
EndFunc


Func HoverHandler()
   Local $aMouse = GUIGetCursorInfo()
   Static Local $hPrev = 0

   If NOT @error Then
      Local $h = $aMouse[4]

      If $h <> $hPrev Then
         Switch $h

            Case $hBtnUpdate
               TipBarPrint("Set current color settings to opened PuTTY window (Alt+U)")
            Case $hBtnExport
               TipBarPrint("Export current color settings to a registry file (Alt+E)")
            Case $hSessionList
               TipBarPrint("List of your saved PuTTY sessions")
            Case $hPicker
               TipBarPrint("Modify selected color")
            Case Else
               TipBarPrint("")

         EndSwitch
      EndIf
   EndIf

   $hPrev = $h
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

   Print("Trying to read:" & @CRLF & "HKEY_CURRENT_USER\Software\SimonTatham\PuTTY\Sessions\" _
         & $sSession)

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


Func TipBarPrint($sText)
   GUICtrlSetdata($hTipBar, $sText)
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


Func SessionsFind(ByRef $asOut)
   Local $i = 0

   While True
      Local $sKey = RegEnumKey("HKEY_CURRENT_USER\Software\SimonTatham\PuTTY\Sessions\", $i + 1)
      If @error Then ExitLoop

      If UBound($asOut) < $i + 1 Then
         ReDim $asOut[UBound($asOut) + 1]
      Endif

      $asOut[$i] = $sKey
      Print("asOut:" & $asOut[$i])
      Print($sKey & ", error: " & @error)
      $i = $i + 1
   Wend
EndFunc


Func SeparatorHoriz($iX, $iY, $iLen)
   GUICtrlCreateLabel("", $iX, $iY, $iLen, 1)
   GUICtrlSetBkColor(-1, 0x999999)
EndFunc
