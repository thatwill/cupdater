#cs
   Updater for Chocolatey
   This application will run chocolatey and check for updates. It is designed to be placed in Windows' Task Scheduler.

   Public domain, no rights reserved. It might not work for you, use at your own risk, etc.
   This is not made by the Chocolatey team nor is it anything to do with them.
#ce

;autoit settings
#include <Array.au3>
#include <TrayConstants.au3>
#include <File.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <ListViewConstants.au3>
#include <WindowsConstants.au3>
AutoItSetOption("TrayAutoPause",0)
AutoItSetOption("TrayMenuMode",3)

; Toast by Melba
; https://www.autoitscript.com/forum/topic/108445-how-to-make-toast-bugfix-version-16-jul-14
; "Any of my own code posted anywhere on the forum is available for use by others without any restriction of any kind."
; Slightly edited by me to make it clickable.
#include "Toast.au3"

;init global vars
Global Const $ChocoExe=@AppDataCommonDir&"\chocolatey\choco.exe"
Global Const $AppName = "Chocolatey Updater"
Global $iNumUpdates
Global $arOutdated
Global $DoUpdates = false
;set tray
TraySetToolTip($AppName)
TraySetIcon($ChocoExe)
$trRunChoco = TrayCreateItem("Run "&$AppName)
$trExit = TrayCreateItem("Exit")

; start
; main app flow
if Not (FileExists($ChocoExe)) Then
   msgbox(16,$AppName,"Chocolatey is not found."&@CRLF&"Ensure Chocolatey is located and accessible at:"&@CRLF&@CRLF&$ChocoExe)
   Exit
EndIf

;start update check
TraySetToolTip($AppName& " is checking for updates...")
$tmpfile = _TempFile()
;$tmpfile = @scriptDir &"\test1.txt" ;testing purposes
RunWait(@ComSpec & " /c" & $ChocoExe & " outdated -r > "& $tmpfile, @ScriptDir, @SW_HIDE)
$arOutdated = FileReadToArray($tmpfile)
FileDelete($tmpfile)

;check for pinned apps and remove from list (apps which will not be updated), and remove lines which do not contain other apps.
;lines ending in "true" will be pinned apps (wont be updated). Lines not ending in "false" are not apps.
$todelete=""
For $i = 0 to UBound($arOutdated)-1
   $strPinned = StringRight($arOutdated[$i],5)
   if $strPinned=="|true" or $strPinned<>"false" Then
	  $todelete = $todelete & $i & ";"
   EndIf
Next
If $todelete<>"" Then
   $todelete=StringTrimRight($todelete,1)
   $iNumUpdates = _ArrayDelete($arOutdated,$todelete)
EndIf

if $iNumUpdates>0 Then
   TraySetToolTip($AppName &" - "& $iNumUpdates & " updates")
   _Toast_Set(5,"0x2B6091","0xFFFFFF","0xF1EFE1","0x202F3C")
   _Toast_Show($ChocoExe, $AppName, $iNumUpdates & " updates available.", 5,False)
Else
   Exit ; if no updates now, exit app.
EndIf

;main wait loop
While 1
   Switch TrayGetMsg()
	  case $trRunChoco
		 RunChoco()
	  case $trExit
		 Exit
	  EndSwitch
   if $DoUpdates Then RunChoco();from toast
WEnd

Func RunChoco()
   Local $arlvItems[$iNumUpdates]

   _ArrayTrim($arOutdated,6,1);trim "|false" from the end of each line.

   ;GUI window for update selection
   $frmUpdater = GUICreate("Chocolatey Updater", 320, 274, 192, 124)
   GUISetIcon($ChocoExe)
   $lvUpdateList = GUICtrlCreateListView("Package name|Current ver|Available ver", 8, 8, 302, 217, $GUI_SS_DEFAULT_LISTVIEW, BitOR($WS_EX_CLIENTEDGE,$LVS_EX_CHECKBOXES, $LVS_EX_FULLROWSELECT))
   $btnCancel = GUICtrlCreateButton("Cancel", 253, 232, 57, 33)
   $btnInstall = GUICtrlCreateButton("Install", 8, 232, 57, 33)
   $chkShutdown = GUICtrlCreateCheckbox("Shutdown when done", 72, 240, 121, 17)

   for $i = 0 to $iNumUpdates-1
	  $arlvItems[$i] = GUICtrlCreateListViewItem($arOutdated[$i], $lvUpdateList)
	  GUICtrlSetState (-1,$GUI_CHECKED)
   Next


   _GUICtrlListView_AddColumn($lvUpdateList,"",0);add dummy column to work around Windows' USEHEADER width calculation behaviour
   _GUICtrlListView_SetColumnWidth($lvUpdateList,1,$LVSCW_AUTOSIZE_USEHEADER)
   _GUICtrlListView_SetColumnWidth($lvUpdateList,2,$LVSCW_AUTOSIZE_USEHEADER)
   _GUICtrlListView_DeleteColumn($lvUpdateList,3)
   $width1=_GUICtrlListView_GetColumnWidth($lvUpdateList,1)
   $width2=_GUICtrlListView_GetColumnWidth($lvUpdateList,2)
   $width0=302-$width1-$width2-5
   _GUICtrlListView_SetColumnWidth($lvUpdateList,0,$width0)

   GUISetState(@SW_SHOW)

   ;gui wait loop
   While 1
	  $nMsg = GUIGetMsg()
	  Switch $nMsg
		 Case $GUI_EVENT_CLOSE,$btnCancel
			Exit
		 Case $btnInstall
			Local $strToUpdate = ""

			for $i = 0 to $iNumUpdates-1
			   if GUICtrlRead($arlvItems[$i],1)==$GUI_CHECKED Then
				  $iPos = StringInStr($arOutdated[$i],"|",2,1)
				  $strAppName = StringLeft($arOutdated[$i],$iPos-1)
				  $strToUpdate = $strToUpdate & " " & $strAppName
			   EndIf
			next
			$ChocoUpdateCommand =  $ChocoExe & " upgrade " & $strToUpdate & " -r -y"

			If GUICtrlRead($chkShutdown)==$GUI_CHECKED Then
				$PostUpdateCommand = "shutdown /s /f /t 30"
			Else
				$PostUpdateCommand = "pause"
			EndIf
			ShellExecute(@ComSpec,"/c title " & $AppName & " & " & $ChocoUpdateCommand & " & " & $PostUpdateCommand,"","runas")
		 Exit
	  EndSwitch
	WEnd
EndFunc