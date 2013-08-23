Thermostat Monitor Client

This folder contains the open source Node.js client that is used to relay the current temperature and 
operating state of your thermostat to ThermosatMonitor.com.  Installation is simple, just complete
the following three steps:


** Step 1 **

Download Node.js from http://nodejs.org/ and run the install


** Step 2 **

Register and log into the control panel http://thermostatmonitor.com/, enter your location and thermostat details, download the config
file and save it in this folder as config.coffee.

** Step 3 **

Run the installer for your operating system:

  * Windows *

  The Thermostat Monitor Client installs as a Windows Service that runs in the background automatically whenever
  Windows starts.  You only need to install it once and it will automatically run from that point on.  To install
  it run the install.bat file in the /install sub folder.
