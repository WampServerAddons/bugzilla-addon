REM @echo OFF
REM script requires mysql to be running
REM TODO use the call command to set some variables common to both the installer/uninstaller
set BUGZILLA_VERSION=4.2rc1
set APACHE_VERSION=2.2.21
set WAMP_VERSION=2.2a
set MYSQL_VERSION=5.5.16

set MYSQL_USER=root
set MYSQL_PASSWORD=

set BUGZILLA_ANSWERS="answers.txt"
set DB_SETUP_SCRIPT=%CD%\files\createdb.sql

set ADDON=Bugzilla

set BIN=installer\bin
set TMP=installer\temp

set WAMP=c:\wamp
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
IF NOT EXIST %TMP% GOTO MKTMP
echo 	Temp directory found from previous install: DELETING
rd /S /Q %TMP%

:MKTMP
echo 	Setting up the temp directory...
mkdir %TMP%

REM download Bugzilla archive to temp directory
echo 	Downloading %ADDON% binaries to temp directory...
wget.exe -nd -q -P %TMP% %BUGZILLA_DOWNLOAD%

REM unzip the downloaded source files and install them
echo 	Extracting the files from the downloaded archive...
gzip.exe -d %TMP%\%BUGZILLA_FILE%.tar.gz
REM tar and the -C switch doesn't want to work with %TMP%. currently treats
REM installer\temp as installer + \t + emp
tar.exe -xf %TMP%\%BUGZILLA_FILE%.tar -C "installer\\temp"
ren %TMP%\%BUGZILLA_FILE% %BUGZILLA_DIR%

REM install the binary files in the WampServer install directory
echo 	Moving the files to the WampServer install directory...
move %TMP%\%BUGZILLA_DIR% %WAMP%\apps

REM install the apache config file for Bugzilla
REM FIXME: may be able to skip moving to%TMP% and just copy to %WAMP_APPS%
REM FIXME: and rename during that copy command
echo 	Installing %ADDON% configuration files...
copy wamp\alias\%BUGZILLA_ALIAS% %WAMP%\alias
REM FIXME: having trouble getting paths with spaces being recognized by
REM FIXME: input redirection, so I will copy the answers file to %WAMP_BUGZILLA%
REM FIXME: as a workaround. Path origionally used was %PROFILE%\desktop\wamp-bugzilla-addon
copy files\%BUGZILLA_ANSWERS% %WAMP_BUGZILLA%
pause

REM install extra perl modules needed by Bugzilla
REM FIXME: this needs cleaned up: this installs some extras that aren't
REM really needed (db drivers and such) maybe have a minimal install list
REM of missing modules and install them and then a full which is everything
REM except the unneccessary db modules. Also need to better understand
REM what's going on so that packaging/removal is easier. may even consider
REM adding this to it's own installer.
REM FIXME: this cd line is needed. calling install-module.pl from the addon
REM directory causes exceptions to be thrown
cd %WAMP_BUGZILLA%
REM FIXME: for some weird reason the install-module.pl script fails to detect
REM FIXME: the compiler and can't install some modules because we have changed %TMP%
REM FIXME: need to figure out why this occurs
set TMP=%TEMP%
perl install-module.pl --all

REM setup MySQL database/user for Bugzilla
REM FIXME: automated login does not work. still getting prompted
mysql -u %MYSQL_USER% -p "%MYSQL_PASSWORD%" < "%DB_SETUP_SCRIPT%"

REM configuring bugzilla
REM FIXME: checksetup needs to be run at least once so that localconfig can
REM FIXME: can be generated. this might be skipped by just copying a default
REM FIXME: localconfig and then only having to run checksetup.pl once
perl checksetup.pl --check-modules
perl checksetup.pl < %WAMP_BUGZILLA%\%BUGZILLA_ANSWERS%
pause

REM fix shbang on cgi and pl files to work better with windows cgi without
REM requiring registry edits
REM FIXME clean up this regex
REM FIXME windows perl can not do inplace edits without backup need to delete backup files after
for /R . %%i in (*.cgi *.pl) do 	perl -p -i'.bak' -e "s@/usr/bin/@@" %%i
pause

REM clean up temp files
echo 	Cleaning up temp files...
REM FIXME set %TMP% back to our value so that we don't accidently delete the system %TMP% dir
REM FIXME this is to fix a bug relating to the install-module.pl script needing %TMP% needing
REM FIXME to be set to the system value so that certain modules get built.
REM rd /S /Q %TMP%
REM del %WAMP_BUGZILLA%\%BUGZILLA_ANSWERS%
cd %~dp0%

echo %ADDON% is installed successfully. Please restart WampServer.

pause
