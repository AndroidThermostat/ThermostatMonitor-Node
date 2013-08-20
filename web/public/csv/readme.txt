This work (Thermostat Monitor Database), is free of known copyright restrictions.



thermostats.csv
*******************************************
Column		Data Type	Description
*******************************************
Id		Integer		A unique id, referenced as ThermostatId in other files
LocationId	Integer		A unique id for the location
AcTons		Decimal (10,2)	The size of the air conditioning unit
AcSeer		Decimal (10,2)	The efficiency of the air conditioning unit
AcKilowatts	Decimal (10,2)	The total energy usage of the air conditioning unit
FanKilowatts	Decimal (10,2)	The energy usage for the furnace blower fan, used for both heat and cool.
HeatBtuPerHour	Integer		The total heat output the heater in British thermal units
ZipCode		String		The postal code for this location
ElectricityPriceDecimal (10,2)	The cost of electricity in cents per kilowatt hour
HeatFuelPrice	Decimal (10,2)	The cost of heating fuel (gas, propane, electricity, etc) in dollars per Dekatherm
Timezone	Decimal (10,2)	The time zone offset from GMT

summary.csv
*******************************************
Column		Data Type	Description
*******************************************
ThermostatId	Integer		Unique Id for this thermostat
LogDate		(YYYY-MM-DD)	Summary Date
OutsideMin	Integer		Lowest Outside Temperature
OutsideMax	Integer		Highest Outside Temperature
HeatCycles	Integer		Number of Heating Cycles in the Day
HeatMinutes	Decimal (10,2)	Number of Heating Minutes in the Day
HeatAverage	Decimal (10,2)	Average Number of Heating Minutes per Cycle HeatMinutes / HeatCycles
CoolCycles	Integer		Number of Cooling Cycles in the Day
CoolMinutes	Decimal (10,2)	Number of Cooling Minutes in the Day
CoolAverage	Decimal (10,2)	Average Number of Cooling Minutes per Cycle CoolMinutes / CoolCycles


cycles.csv
*******************************************
Column		Data Type	Description
*******************************************
ThermostatId	Integer		Unique Id for this thermostat
CycleType	String		Cycle of Unit
StartTime	Date and Time	Start Time of Cycle
EndTime		Date and Time	End Time of Cycle
Minutes		Decimal (10,2)	Number of Minutes in Cycle
kwH		Decimal (10,2)	kilowatt Hours Used - Cool + Fan
BTUs		Decimal (10,2)	British Thermal Units Used - Heat Only



inside.csv
*******************************************
Column		Data Type	Description
*******************************************
ThermostatId	Integer		Unique Id for this thermostat
LogDate		Date and Time	Logged Time of Temperature
Degrees		Integer		Degrees Observed Inside



outside.csv
*******************************************
Column		Data Type	Description
*******************************************
LocationId	Integer		Unique Id for this location
LogDate		Date and Time	Logged Time of Temperature
Degrees		Integer		Degrees Observed Outside








