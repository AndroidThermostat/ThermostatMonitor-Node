echo off
sc stop ThermostatMonitorClient
nssm remove ThermostatMonitorClient confirm
echo.
echo. 
echo. 
echo ****************************************************************
echo Thermostat Monitor Client has been stopped and the Windows Service has been removed.  You can now delete the Thermostat Monitor Client folder.
echo ****************************************************************
echo. 
pause
