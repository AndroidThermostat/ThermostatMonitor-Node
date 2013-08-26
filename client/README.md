#Thermostat Monitor Client

This folder contains the open source Node.js client that is used to relay the current temperature and  operating state of your thermostat to ThermosatMonitor.com.  Installation is simple, just complete the following three steps:

## Setup

### Step 1
Download [Node.js](http://nodejs.org/) and run the install

### Step 2
Register and log into the control panel at [ThermosatMonitor.com](http://thermostatmonitor.com/), enter your location and thermostat details.  Download and unzip the application.  Download your config file and save it in the folder where you unzipped the application, overwriting the example `config.coffee` file.

### Step 3

The Thermostat Monitor Client installs as a background service that runs silently whenever your computer starts.  You only need to install it once and it will automatically run from that point on.  Follow the installation instructions for your operating system.

- **Windows** -  Run the `install.bat` file in the `/install` sub folder.

- **Macintosh** - Copy the extracted client application with your custom config file to `/usr/bin/thermostat-monitor-client/`.  From that folder, run `npm install` to install the dependencies.  Copy the `install/com.thermostatmonitor.client.plist` file to `/Library/LaunchDaemons/` so the daemon will automatically run on startup.  Reboot

- **Ubuntu** - From the folder where you've extracted the client, run `npm install` to download and install the dependencies.  Edit `install/thermostat-monitor-client.conf`, changing `YOURPATHHERE` to be the path where you have extracted the client.  Copy `install/thermostat-monitor-client.conf` to `/etc/init/`.  Reboot.

- **Arch/Fedora/Suse** - From the folder where you've extracted the client, run `npm install` to download and install the dependencies.  Edit the `install/thermostat-monitor-client.service` file, replacing `YOURUSERNAMEHERE` with your user name.  Copy `install/thermostat-monitor-client.service` to `/etc/systemd/system/`.  Reboot

## License

Copyright (C) 2013 Trilitech, LLC

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.