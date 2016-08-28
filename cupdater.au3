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

;set tray
TraySetToolTip($AppName)
TraySetIcon($ChocoExe)
$trRunChoco = TrayCreateItem("Run "&$AppName)
$trExit = TrayCreateItem("Exit")

Func UpdateCheck()
   TraySetToolTip($AppName& " is checking for updates...")
   $tmpfile = _TempFile()
   RunWait(@ComSpec & " /c" & $ChocoExe & " outdated -r > "& $tmpfile, @ScriptDir, @SW_HIDE)
   ;$tmpfile = @scriptDir &"\test.dat" ;testing purposes
   $arOutdated = FileReadToArray($tmpfile)
   FileDelete($tmpfile)

   ;check for pinned apps and remove from list (apps which will not be updated), and remove lines which do not contain other apps.
   ;lines ending in "true" will be pinned apps. Lines not ending in "false" are not apps.
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
EndFunc

Func RunChoco()
   if $iNumUpdates<>0 Then

	  ;reformat from array & remove useless info
	  $strUpdates = _ArrayToString($arOutdated,@CRLF)
	  $strUpdates = StringReplace($strUpdates,"|false","")

	  $msgResponse = MsgBox(4,"Updates available",$strUpdates&@CRLF&"Would you like to update?")
   Else
	  $msgResponse = MsgBox(4,"No updates available","No new updates on last check. Would you like to run an update anyway?")
   EndIf

   if $msgResponse = 6 Then
	  ShellExecute(@ComSpec,"/c title " & $AppName & $ChocoExe & " upgrade all -r -y","","runas")
	  Exit
	EndIf
EndFunc


if Not (FileExists($ChocoExe)) Then
   msgbox(16,$AppName,"Chocolatey is not found."&@CRLF&"Ensure Chocolatey is located and accessible at:"&@CRLF&@CRLF&$ChocoExe)
   Exit
EndIf
UpdateCheck()

While 1
   Switch TrayGetMsg()
	  case $trRunChoco
		 RunChoco()
	  case $trExit
		 Exit
   EndSwitch
WEnd