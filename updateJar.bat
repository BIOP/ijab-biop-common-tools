@ECHO OFF
setlocal enabledelayedexpansion

REM Set name of ActionBar
set actionBarName=BIOP_Common_Tools


ECHO Packing ActionBar: "%actionBarName%"

REM Get the version of the ActionBar

git describe --abbrev=0 --tags > tmpFile
set /p version= < tmpFile
del tmpFile

ECHO Version: "%version%"

set finalName=%actionBarName%_%version%.jar

echo Final Name: "%finalName%"

REM Create the plugins.config file from the plugins.config.defaults and replace the 
REM 'actionBarName' text with the complete name of the actionbar

ECHO Getting string from plugins.config.default
set /p configString= < plugins.config.default
call set configString=%%configString:ActionBarName=!finalName!%%

ECHO Writing 'plugins.config' file...
echo %configString% >> plugins.config

REM Create JAR File
ECHO Creating JAR File
jar cf %finalName% plugins.config icons *.ijm
del plugins.config
ECHO Done.

PAUSE