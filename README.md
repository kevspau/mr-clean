# mr-clean
clean up your taskbar/desktop/start menu


## Status - **usable for the most part(1-2 bugs)**

## basic stuff
- Linux support is planned, but as of right now only Windows is supported
- Only about 3-4 of the settings actually work/do something right now
- settings are in json format in the `.config` file
- this app basically lists all executables in your path(and in the custom directories that you can add in .config) and allows you to run them all from the same app, allowing ease of access and organization.


## known issues
- microsoftedge and other execs appear twice(i think because of shortcuts)
- an executable called main.exe appears without a path(may be the program itself) [SOLVED]
