REM @echo OFF
REM script requires mysql to be running
REM TODO use the call command to set some variables common to both the installer/uninstaller
set BUGZILLA_VERSION=4.2rc1
set APACHE_VERSION=2.2.21
set WAMP_VERSION=2.2a
set MYSQL_VERSION=5.5.16

set MYSQL_USER=root
set MYSQL_PASSWORD=

set BUGZILLA_ANSWERS=files\answers.txt
set DB_SETUP_SCRIPT=files\createdb.sql

set ADDON=Bugzilla

set BIN=installer\bin
REM using %MYTMP% in this script because install-module.pl fails to install
REM some modules if %TMP% is changed from default.
set MYTMP=installer\temp

set WAMP=c:\wamp
set WAMP_ALIAS=%WAMP%\alias
set WAMP_APPS=%WAMP%\apps
set WAMP_MYSQL=%WAMP%\bin\mysql\mysql%MYSQL_VERSION%\bin
set WAMP_BUGZILLA=%WAMP_APPS%\bugzilla%BUGZILLA_VERSION%

set BUGZILLA_FILE=bugzilla-%BUGZILLA_VERSION%
set BUGZILLA_DIR=Bugzilla%BUGZILLA_VERSION%
set BUGZILLA_BIN=%WAMP_BUGZILLA%

set BUGZILLA_DOWNLOAD=http://ftp.mozilla.org/pub/mozilla.org/webtools/%BUGZILLA_FILE%.tar.gz

set BUGZILLA_ALIAS=bugzilla.conf

set PATH=%PATH%;%BIN%;%WAMP_MYSQL%

echo Welcome to the %ADDON% Addon installer for WampServer %WAMP_VERSION%

REM set up the temp directory
IF NOT EXIST %MYTMP% GOTO MKTMP
echo 	Temp directory found from previous install: DELETING
rd /S /Q %MYTMP%

:MKTMP
echo 	Setting up the temp directory...
mkdir %MYTMP%
pause

REM download Bugzilla archive to temp directory
echo 	Downloading %ADDON% binaries to temp directory...
wget.exe -nd -q -P %MYTMP% %BUGZILLA_DOWNLOAD%
pause

REM unzip the downloaded source files and install them
echo 	Extracting the files from the downloaded archive...
gzip.exe -d %MYTMP%\%BUGZILLA_FILE%.tar.gz
REM FIXME tar and the -C switch doesn't want to work with %MYTMP%. currently treats
REM installer\temp as installer + \t + emp
tar.exe -xf %MYTMP%\%BUGZILLA_FILE%.tar -C "installer\\temp"
pause

REM install the binary files in the WampServer install directory
echo 	Moving the files to the WampServer install directory...
ren %MYTMP%\%BUGZILLA_FILE% %BUGZILLA_DIR%
move %MYTMP%\%BUGZILLA_DIR% %WAMP_APPS%
pause

REM install the apache config file for Bugzilla
REM FIXME: may be able to skip moving to %MYTMP% and just copy to %WAMP_APPS%
REM FIXME: and rename during that copy command
echo 	Installing %ADDON% configuration files...
copy wamp\alias\%BUGZILLA_ALIAS% %WAMP_ALIAS%
pause

REM install extra perl modules needed by Bugzilla
REM FIXME: this needs cleaned up: this installs some extras that aren't
REM FIXME really needed (db drivers and such) maybe have a minimal install list
REM FIXME of missing modules and install them and then a full which is everything
REM FIXME except the unneccessary db modules. Also need to better understand
REM FIXME what's going on so that packaging/removal is easier.

REM FIXME install-module.pl will not work unless in the bugzilla install directory. might need to open bug
cd %WAMP_BUGZILLA%
REM FIXME: install-module.pl fails to install some modules because we changed %TMP%. need to figure out why this occurs or open bug with bugzilla
perl install-module.pl --all
cd %~dp0%
pause

REM setup MySQL database/user for Bugzilla
REM FIXME: automated login does not work. still getting prompted
mysql -u %MYSQL_USER% -p "%MYSQL_PASSWORD%" < %DB_SETUP_SCRIPT%

REM configuring bugzilla
REM FIXME: checksetup needs to be run at least once so that localconfig can
REM FIXME: can be generated. this might be skipped by just copying a default
REM FIXME: localconfig and then only having to run checksetup.pl once
perl %WAMP_BUGZILLA%\checksetup.pl --check-modules
perl %WAMP_BUGZILLA%\checksetup.pl < %BUGZILLA_ANSWERS%
pause

REM fix shbang so windows can guess CGI interpreter without requiring registry edits
REM FIXME clean up this regex
REM FIXME windows perl can not do inplace edits without backup need to delete backup files after. need to delete those
for /R %WAMP_BUGZILLA% %%i in (*.cgi *.pl) do perl -p -i'.bak' -e "s@/usr/bin/@@" %%i
pause

REM clean up temp files
echo 	Cleaning up temp files...
rd /S /Q %MYTMP%

echo %ADDON% is installed successfully. Please restart WampServer.

pause
