@ECHO OFF

SETLOCAL ENABLEDELAYEDEXPANSION

REM Set name of ActionBar
set actionBarName=BIOP_Common_Tools

copy "C:\Fiji.app\plugins\ActionBar\BIOP_Common_Tools.ijm" BIOP_Common_Tools.ijm
copy "C:\Fiji.app\plugins\ActionBar\channelManipToolsSubBar.ijm" channelManipToolsSubBar.ijm

ECHO Packing ActionBar: "%actionBarName%"

REM Get the version of the ActionBar
git describe --abbrev=0 --tags > tmpFile
set /p version= < tmpFile
del tmpFile

ECHO Version: "%version%"

set finalName=%actionBarName%.jar

echo Final Name: "%finalName%"

REM Create JAR File
ECHO Creating JAR File
jar cf %finalName% plugins.config *.ijm
ECHO Done.

copy %finalName% "C:\Fiji.app\plugins\BIOP\%finalName%"
PAUSE