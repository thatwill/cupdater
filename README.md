# cupdater
##Overview
Updater for Chocolatey.

This application will check for new updates in Chocolatey, and inform the user by toast popup window and system tray icon. The updates can then be started by clicking the toast, or from the system tray. The update is currently run as a regular `choco upgrade` in a command prompt window.

It is designed to be placed in Windows' Task Scheduler, for automatic checking.

##Download
Download 0.1 [here](https://github.com/thatwill/cupdater/releases/tag/0.1)

###Other information
Haphazardly written in Autoit. My code is public domain. It does not contain any code or any other part of Chocolatey itself, and it is not created by or related to the Chocolatey team. It is simply a wrapper around the command line tools. 

Uses Toast by Melba at the AutoIt forums.  
https://www.autoitscript.com/forum/topic/108445-how-to-make-toast-bugfix-version-16-jul-14  
Toast is under a "public domain" style licence: "Any of my own code posted anywhere on the forum is available for use by others without any restriction of any kind."  
Slightly modified by me.
