Config = require "./config.coffee"
sys = require "sys"
request = require("request")

previousOutsideTemp = -100



logTempChange = (thermostat, temp) ->
	sys.puts "Logging inside temperature change for: " + thermostat.name + ' - ' + temp
	url = Config.apiUrl + "?k=" + thermostat.apiKey + '&a=temp&t=' + temp
	request url, (error, response, body) =>
	thermostat.previousTemp = temp

logWeatherChange = (temp) ->
	sys.puts "Logging outside temperature change - " + temp
	url = Config.apiUrl + "?k=" + Config.thermostats[0].apiKey + '&a=conditions&t=' + temp
	request url, (error, response, body) =>
	previousOutsideTemp = temp

logCycleComplete = (thermostat) ->
	sys.puts "Logging completed " + thermostat.previousState + ' cycle'
	duration = Math.round((new Date().getTime() - thermostat.startTime) / 1000)
	url = Config.apiUrl + "?k=" + thermostat.apiKey + '&a=cycle&m=' + thermostat.previousState + '&p=60&d=' + duration
	request url, (error, response, body) =>

handleStateChange = (thermostat, state) ->
	if thermostat.previousState? and thermostat.previousState != 'Off'
		logCycleComplete thermostat

	thermostat.previousState = state
	thermostat.startTime = new Date()


checkThermostats = ->
	Config.thermostats.forEach (thermostat) ->
		url = 'http://' + thermostat.ipAddress + '/tstat'
		request url, (error, response, body) =>
			try
				data = eval('(' + body + ')')
				temp = Math.round(data.temp-0.5)
				switch data.tstate
					when 0
						state = 'Off'
					when 1
						state = 'Heat'
					when 2
						state = 'Cool'
				#state = 'Fan' if state == 'Off' and data.fstate = 1 #Fan remains on after AC
				logTempChange thermostat, temp if temp>0 and (not thermostat.previousTemp? or thermostat.previousTemp!=temp)
				handleStateChange thermostat,state if not thermostat.previousState? or thermostat.previousState!=state
			catch err
				sys.puts "Invalid thermostat response - " + data

checkWeather = ->
	url = 'http://openweathermap.org/data/2.1/weather/city/' + Config.openWeatherMapStation
	request url, (error, response, body) =>
		try
			data = eval('(' + body + ')')
			tempK = data.main.temp
			tempC = tempK - 272.15
			tempF = Math.round ((tempC * 9 / 5 + 32) * 10) / 10
			logWeatherChange tempF if not previousOutsideTemp? or previousOutsideTemp!=tempF
		catch err
			sys.puts "Invalid weather response - " + body

sys.puts "Running"
setInterval checkThermostats, 60000
setInterval checkWeather, 300000
checkThermostats()
checkWeather()