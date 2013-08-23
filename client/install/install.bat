echo off
cd ..
call npm install
cd install
nssm install ThermostatMonitorClient node.exe app.js
sc config ThermostatMonitorClient start= auto
sc start ThermostatMonitorClient
echo.
echo. 
echo. 
echo ****************************************************************
echo Thermostat Monitor Client has been installed and is running in the background as a Windows service.  It is configured to automatically start up when Windows starts.
echo ****************************************************************
echo. 
pause
