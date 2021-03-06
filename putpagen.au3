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
Global $iNumBtns = 4

Global $iTipBarWidth = $iColorlistWidth + $iTestlineWidth + $iDbgWidth
Global $iTipBarHeight = 15
Global $iTipBarX = 0
Global $iTipBarY = $iColorlistHeight + $iPickerHeight + $iBtnHeight - 5

Global $iGuiWidth = $iColorlistWidth + $iTestlineWidth + $iDbgWidth
Global $iGuiHeight = $iColorlistHeight + $iPickerHeight + $iBtnHeight + $iTipBarHeight - 5

Global $iBtnWidth = $iGuiWidth / $iNumBtns
Global $iBtnY = $iColorlistHeight + $iPickerHeight - 6

Global $aiCurrentRgb[$iNumBaseColors]
Global $aiColorsRgb[$iNumColors]

Global $asSessions[1]
Global $sSessionNow = ""
Global $iSessionsNum = 0

Global $sFont = "Consolas"
Global $iFontSize = 10

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

Global $asColorsDefault[$iNumColors] = [ _
   "187,187,187", _
   "255,255,255", _
   "0,0,0", _
   "85,85,85", _
   "0,0,0", _
   "0,255,0", _
   "0,0,0", _
   "85,85,85", _
   "187,0,0", _
   "255,85,85", _
   "0,187,0", _
   "85,255,85", _
   "187,187,0", _
   "255,255,85", _
   "0,0,187", _
   "85,85,255", _
   "187,0,187", _
   "255,85,255", _
   "0,187,187", _
   "85,255,255", _
   "187,187,187", _
   "255,255,255"  _
]


; Program start
; -----------------------------------------------------------------------------
AutoItSetOption("GUICloseOnESC", 0)
Local $sConfFileDir = @WorkingDir
Local $sConfFile = $sConfFileDir & "\putpagen.ini"

Local $aiGuiPos[2]
$aiGuiPos= GetGuiPos($sConfFile)
Local $iGuiX = $aiGuiPos[0]
Local $iGuiY = $aiGuiPos[1]

Global $hGuiApp = GUICreate("Putpagen v1.0", $iGuiWidth, $iGuiHeight, $iGuiX, $iGuiY)
GuiSetIcon("putpagen.ico")

DbgInit()
TestAreaInit()
PickerInit()
ColorListInit()
ButtonsInit()
$iSessionsNum = SessionsFind($asSessions)
SessionListInit($asSessions)
$sSessionNow = $asSessions[0]

If NoSessionsDefined() Then
    ReadPaletteDefault()
Else
    ReadPalette($sSessionNow)
EndIf

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

      Case $hBtnSave
         BtnSaveHandler()

      Case $hBtnLoadDefault
         BtnLoadDefaultHandler()

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
   $aRetPos[0] = -1
   $aRetPos[1] = -1

   If $hConfFile <> -1 Then
      Local $aConfEntry

      $aConfEntry = StringSplit(StringStripWs(FileReadLine($hConfFile, 1), _
                           $STR_STRIPALL), "=", 2)

      If NOT @error Then
         $aRetPos[0] = $aConfEntry[1]
      EndIf

      $aConfEntry = StringSplit(StringStripWs(FileReadLine($hConfFile, 2), _
                           $STR_STRIPALL), "=", 2)

      If NOT @error Then
         $aRetPos[1] = $aConfEntry[1]
      EndIf

      FileClose($hConfFile)
   EndIf

   Return $aRetPos
EndFunc

Func GetPreviewFont($sConfFile)
   Local $hConfFile = FileOpen($sConfFile, $FO_READ)
   Local $sRetFont = "Consolas"

   If $hConfFile <> -1 Then
      Local $aConfEntry
      $aConfEntry = StringSplit(FileReadLine($hConfFile, 3), "=", 2)

      If NOT @error Then
         $sRetFont = StringStripWs($aConfEntry[1], _
                  $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)
      EndIf

      FileClose($hConfFile)
   EndIf

   Print("Font = " & $sRetFont)
   Return $sRetFont
EndFunc

Func GetPreviewFontSize($sConfFile)
   Local $hConfFile = FileOpen($sConfFile, $FO_READ)
   Local $iRetSize = 10

   If $hConfFile <> -1 Then
      Local $aConfEntry
      $aConfEntry = StringSplit(FileReadLine($hConfFile, 4), "=", 2)

      If NOT @error Then
         $aConfEntry[1] = StringStripWs($aConfEntry[1], $STR_STRIPALL)
         If StringIsInt($aConfEntry[1]) Then
            $iRetSize =  $aConfEntry[1]
         EndIf
      EndIf

      FileClose($hConfFile)
   EndIf

   Print("Size = " & $iRetSize)
   Return $iRetSize
EndFunc

Func ConfFileUpdate()
   Local $hConfFile = FileOpen($sConfFile, $FO_OVERWRITE)
   If $hConfFile <> -1 Then
      Local $aiGuiPos = WinGetPos($hGuiApp)
      FileWriteLine($hConfFile, "gui_x = " & $aiGuiPos[0])
      FileWriteLine($hConfFile, "gui_y = " & $aiGuiPos[1])
      FileWriteLine($hConfFile, "font = " & $sFont)
      FileWriteLine($hConfFile, "font size = " & $iFontSize)
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
   $sFont = GetPreviewFont($sConfFile)
   $iFontSize = GetPreviewFontSize($sConfFile)
   Local $h = 0

   GUISetCoord($iTestlineX, $iTestlineY - $iTestlineHeight, $iTestlineWidth, $iTestlineHeight)
   Opt("GUICoordMode", 2)

   For $i = 0 To ($iNumColors - 1)
      If NOT IsColorSpecial($i) Then
         $h = GUICtrlCreateLabel("Sample text, " & $asColorsText[$i], -1, 0)
         GUICtrlSetBkColor($h, 0x00000000)
         $aiColorsRgb[$i] = 0x808080
         GUICtrlSetColor($h, $aiColorsRgb[$i])
         GUICtrlSetFont($h, $iFontSize, 400, 1, $sFont)
         $hTestline[$i] = $h
      Endif
   Next

   Opt("GUICoordMode", 1)
EndFunc


Func ButtonsInit()
   Global $hBtnUpdate = GUICtrlCreateButton("&Update PuTTY", _
                     0, $iBtnY, $iBtnWidth, $iBtnHeight)
   Global $hBtnSave = GUICtrlCreateButton("&Save", _
                     $iBtnWidth * 1, $iBtnY, $iBtnWidth, $iBtnHeight)
   Global $hBtnExport = GUICtrlCreateButton("&Export", _
                     $iBtnWidth * 2, $iBtnY, $iBtnWidth, $iBtnHeight)
   Global $hBtnLoadDefault = GUICtrlCreateButton("Load &Defaults", _
                     $iBtnWidth * 3, $iBtnY, $iBtnWidth, $iBtnHeight)
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

   Local $sSessionName = ""
   If NoSessionsDefined() Then
      While $sSessionName = ""
         $sSessionName = InputBox("No PuTTY sessions defined", _
              "Give a name for a PuTTY session:", _
              "my_ssh_session", "", "", 100)
         If @error Then
            Return
         Endif
         $sSessionName = StringStripWs($sSessionName, $STR_STRIPALL)
      Wend
   Else
      $sSessionName = $sSessionNow
   Endif

   Local $sFilePath = FileSaveDialog("Export PuTTy colour settings to a file", "", _
         "Windows registry file (*.reg)", _
         $FD_PATHMUSTEXIST + $FD_PROMPTOVERWRITE, _
         "putty_colours.reg")

   If (NOT @error) Then

      Local $sExt = StringRight($sFilePath, 4)
      If ($sExt <> ".reg") Then
         $sFilePath = $sFilePath & ".reg"
      EndIf

      Local $hFile = FileOpen($sFilePath, $FO_OVERWRITE)
      If $hFile <> -1 Then
         ExportPalette($hFile, $sSessionName)
         FileClose($hFile)
      Else
         MsgBox($MB_OK, "Error", "Unable to save the file.")
      Endif
   Endif

EndFunc


Func BtnUpdateHandler()

   Local $hPutty = WinGetHandle ("[CLASS:PuTTY]")
   If @error Then
      MsgBox(0, "Putpagen error", "I cannot find any open PuTTY window!")
      Return
   Endif

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


Func BtnSaveHandler()
   If NoSessionsDefined() Then
      MsgBox(0, "Info", "You don't have any saved PuTTY sessions!")
   Else
      WritePalette($sSessionNow)
      TipBarPrint("Colour settings saved!")
   Endif
EndFunc


Func BtnLoadDefaultHandler()
   ReadPaletteDefault()
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
               TipBarPrint("Export current color settings to a session registry file (Alt+E)")
            Case $hBtnSave
               TipBarPrint("Make PuTTY remember current settings for chosen session (Alt+S)")
            Case $hBtnLoadDefault
               TipBarPrint("Load default PuTTY colour settings (Alt+D)")
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
Func ExportPalette($hFile, $sSessionName)
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


; Load default PuTTY colour palette
Func ReadPaletteDefault()

   For $i = 0 To ($iNumColors - 1)
      $aiColorsRgb[$i] = RgbStoI($asColorsDefault[$i])
      GUICtrlSetColor($hTestline[$i], $aiColorsRgb[$i])
   Next

   BgUpdate()
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


; Save a colour palette to an existing putty session
Func WritePalette($sSession)

   Print("Trying to write:" & @CRLF & "HKEY_CURRENT_USER\Software\SimonTatham\PuTTY\Sessions\" _
         & $sSession)

   For $i = 0 To ($iNumColors - 1)

      $sColorRgb = RgbItoS($aiColorsRgb[$i])
      Print($sColorRgb)
      Print("HKEY_CURRENT_USER\Software\SimonTatham\PuTTY\Sessions\" & $sSession)
      Print("Colour" & String($i))

      RegWrite( _
            "HKEY_CURRENT_USER\Software\SimonTatham\PuTTY\Sessions\" & $sSession, _
            "Colour" & String($i), "REG_SZ", _
            $sColorRgb)

      If @error Then
         MsgBox($MB_OK, "Error", "Error while writing to Windows registry")
      EndIf
   Next

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


; Returns number of sessions found. And fills the $asOut array with session
; names
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

   Return $i
EndFunc


Func NoSessionsDefined()
    If $iSessionsNum = 0 Then
        Return True
    Else
        Return False
    EndIf
EndFunc


Func SeparatorHoriz($iX, $iY, $iLen)
   GUICtrlCreateLabel("", $iX, $iY, $iLen, 1)
   GUICtrlSetBkColor(-1, 0x999999)
EndFunc
