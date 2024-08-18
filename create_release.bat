@echo off

set DST_MOD_DIR=D:\Steam\steamapps\common\Don't Starve Together\mods
set ICEY2_MOD_DIR=%DST_MOD_DIR%\icey2
set RELEASE_MOD_DIR=%DST_MOD_DIR%\icey2_release

@REM cd "%ICEY2_MOD_DIR%"
git clone "%ICEY2_MOD_DIR%" "%RELEASE_MOD_DIR%" 

@REM cd %RELEASE_MOD_DIR%
@REM rm -rf .git