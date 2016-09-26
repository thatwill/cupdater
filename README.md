# cupdater
##Overview
Updater for Chocolatey.

This application will check for new updates in Chocolatey, and inform the user by toast popup window and system tray icon. The updates can then be started by clicking the toast, or from the system tray. You'll be able to select the applications you want to update, which will then be run in a command prompt window using `choco upgrade`.

It does not have any ability to schedule itself for automatic checking - it is designed to be placed in Windows' Task Scheduler.

##Download
Download 0.2 [here](https://github.com/thatwill/cupdater/releases/tag/0.2).

###Other information
Haphazardly written in Autoit. My code is public domain. It does not contain any code or any other part of Chocolatey itself, and it is not created by or related to the Chocolatey team. It is simply a wrapper around the command line tools. 

Uses Toast by Melba at the AutoIt forums.  
https://www.autoitscript.com/forum/topic/108445-how-to-make-toast-bugfix-version-16-jul-14  
Toast is under a "public domain" style licence: "Any of my own code posted anywhere on the forum is available for use by others without any restriction of any kind."  
Slightly modified by me.
