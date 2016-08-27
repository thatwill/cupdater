#cs
   Updater for Chocolatey
   This application will run chocolatey and check for updates. It is designed to be placed in Windows' Task Scheduler.

   Public domain, no rights reserved. It might not work for you, use at your own risk, etc.
   This is not made by the Chocolatey team nor is it anything to do with them.
#ce

;autoit settings
#include <Array.au3>
#include <TrayConstants.au3>
AutoItSetOption("TrayAutoPause",0)
AutoItSetOption("TrayMenuMode",2)

;init global vars
Global Const $ChocoExe=@AppDataCommonDir&"\chocolatey\choco.exe"
Global Const $AppName = "Chocolatey Updater"
Global $iNumUpdates
Global $arOutdated

;set tray
TraySetToolTip($AppName)
TraySetIcon($ChocoExe)
$trRunChoco = TrayCreateItem("Run "&$AppName)

Func UpdateCheck()
   RunWait(@ComSpec & " /c" & $ChocoExe & " outdated -r > outdated.dat", @ScriptDir, @SW_HIDE)
   $hOutdated = FileOpen(@ScriptDir&"\outdated.dat",0)
   $arOutdated = FileReadToArray($hOutdated)
   FileClose($hOutdated)
   FileDelete(@ScriptDir&"\outdated.dat")

   ;check for pinned apps and remove from list (apps which will not be updated), and remove lines which do not contain other apps.
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
	  TrayTip($AppName,$iNumUpdates & " updates available.",0)
	  TraySetToolTip($AppName &" - "& $iNumUpdates & " updates")
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

UpdateCheck()

While 1
   Switch TrayGetMsg()
	  case $trRunChoco
		 RunChoco()
   EndSwitch
WEnd