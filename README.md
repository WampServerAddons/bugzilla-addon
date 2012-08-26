bugzilla-addon
==============

Bugzilla support for WampServer

Apache version: 2.2.21

About:
 This is an addon for WampServer 2.2a that enables use of the Bugzilla
 bug-tracking system.

Where to download Bugzilla:
 Official: http://ftp.mozilla.org/pub/mozilla.org/webtools/

Required Addons:
 * Perl

Optionally Required:

Manual install instructions:
 (assumes wamp is already installed and working)

 1. install the required addons
 2. download the zip file listed above
 3. extract the files to a temporary directory
 4. inside of the folder that was extracted you should see a directory named
    bugzilla-%VERSION%
 5. rename this folder to bugzilla%VERSION% and move it to c:\wamp\apps
 6. copy bugzilla.conf file to c:\wamp\alias and edit as needed
 7. create the 'bugs' database and the 'bugs' user using phpMyAdmin or the script
    in the files\ directory
 8. run 'install-module.pl --all' from inside c:\wamp\apps\bugzilla%VERSION% to
    install any missing Perl modules.
 9. run the 'checksetup.pl --check-modules' script to verify all the required modules
    are installed. This will also generate the localconfig file need to run bugzilla
 10. make any necessary changes to localconfig
 11. run 'checksetup.pl' again. This complete any needed configuration changes.
 12. remove '/usr/bin/' path from the first line of every .cgi and .pl file. This is
     so Apache can find the perl executable to run the CGI scripts without requiring
     edits to the registry.
 13. restart Wamp

Using the Installer:
 usage: installer.bat


TODO:
 * section on troubleshooting
 * integration with wampserver manager menu on systray
 * SSL encryption
 * virtual hosting (bugs.*)
 * check for any other configuration notes that might be benificial

FIXME:
 * spelling/capitalization check on all files
