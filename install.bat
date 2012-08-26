@echo OFF
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
set LOCALCONFIG=files\localconfig

set ADDON=Bugzilla

set BIN=installer\bin
REM using %MYTMP% in this script because install-module.pl fails to install
REM some modules if %TMP% is changed from default. might need to open a bug with bugzilla
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

REM download Bugzilla archive to temp directory
echo 	Downloading %ADDON% binaries to temp directory...
wget.exe -nd -q -P %MYTMP% %BUGZILLA_DOWNLOAD%

REM unzip the downloaded source files and install them
echo 	Extracting the files from the downloaded archive...
gzip.exe -d %MYTMP%\%BUGZILLA_FILE%.tar.gz
REM FIXME tar and the -C switch doesn't want to work with %MYTMP%. currently treats
REM installer\temp as installer + \t + emp. might be able to resolve by using a different
REM tar binary for windows. (unxutils?). this might also keep installer\bin cleaner by not
REM requiring the dll dependancies.
tar.exe -xf %MYTMP%\%BUGZILLA_FILE%.tar -C "installer\\temp"

REM install the binary files in the WampServer install directory
echo 	Moving the files to the WampServer install directory...
ren %MYTMP%\%BUGZILLA_FILE% %BUGZILLA_DIR%
move %MYTMP%\%BUGZILLA_DIR% %WAMP_APPS%

REM install extra perl modules needed by Bugzilla
REM FIXME: this needs cleaned up: this installs some extras that aren't
REM FIXME really needed (db drivers and such) maybe have a minimal install list
REM FIXME of missing modules and install them and then a full which is everything
REM FIXME except the unneccessary db modules. Also need to better understand
REM FIXME what's going on so that packaging/removal is easier.

REM FIXME install-module.pl will not work unless in the bugzilla install directory. might need to open bug
echo 	Installing extra Perl modules needed by Bugzilla...
echo 		This could take several minutes. Please be patient.
cd %WAMP_BUGZILLA%
perl install-module.pl --all > NUL 2>&1
cd %~dp0%

REM install the apache config file for Bugzilla
echo 	Installing %ADDON% configuration files...
copy wamp\alias\%BUGZILLA_ALIAS% %WAMP_ALIAS%

REM fix shbang so windows can guess CGI interpreter without requiring registry edits
for /R %WAMP_BUGZILLA% %%i in (*.cgi *.pl) do perl -p -i.bak -e "s@/usr/bin/@@" %%i
REM FIXME getting some access denied errors on delete.
for /R %WAMP_BUGZILLA% %%i in (*.bak) do del %%i

REM setup MySQL database/user for Bugzilla
echo 	Setting up the %ADDON% database
mysql -u %MYSQL_USER% < %DB_SETUP_SCRIPT%
copy %LOCALCONFIG% %WAMP_BUGZILLA%
REM FIXME had trouble running answer script when not inside %WAMP_BUGZILLA%
REM FIXME answers.txt is hard coded.
REM FIXME checksetup.pl appears to look for files relative to path of script.
copy %BUGZILLA_ANSWERS% %WAMP_BUGZILLA%
perl %WAMP_BUGZILLA%\checksetup.pl answers.txt > NUL 2>&1 
del %WAMP_BUGZILLA%\answers.txt

REM clean up temp files
echo 	Cleaning up temp files...
rd /S /Q %MYTMP%

echo %ADDON% is installed successfully. Please restart WampServer.

pause
