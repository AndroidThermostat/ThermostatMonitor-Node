#Thermostat Monitor Client

This folder contains the open source Node.js client that is used to relay the current temperature and  operating state of your thermostat to ThermosatMonitor.com.  Installation is simple, just complete the following three steps:

## Setup

### Step 1

Download [Node.js](http://nodejs.org/) and run the install

### Step 2

Register and log into the control panel at [ThermosatMonitor.com](http://thermostatmonitor.com/), enter your location and thermostat details, download the config file and save it in this folder as config.coffee.

### Step 3

Run the installer for your operating system:

#### Windows

The Thermostat Monitor Client installs as a Windows Service that runs in the background automatically whenever Windows starts.  You only need to install it once and it will automatically run from that point on.  To install it run the install.bat file in the /install sub folder.


## License

Copyright (C) 2013 Trilitech, LLC

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.