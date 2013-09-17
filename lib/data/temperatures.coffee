TemperaturesBase = require("./base/temperatures-base.coffee")
Temperature = require("./temperature.coffee")
sys = require("sys")
Global = require "../global.coffee"
Utils = require '../utils.coffee'

class Temperatures extends TemperaturesBase
	getIds: () =>
		result = []
		@forEach (item) =>
			result.push item.id
		result
	getRange: (startDate, endDate) =>
		result = new Temperatures
		@forEach (item) =>
			result.push item if item.logDate>=startDate and item.logDate<=endDate
		result
	getByTime: (time) =>
		result = null
		@forEach (item) =>
			result = item if item.logDate<=time
		result
	getTempHigh: () =>
		result = -999
		@forEach (item) =>
			result = item.degrees if (item.degrees>result)
		result
	getTempLow: () =>
		result = 999
		@forEach (item) =>
			result = item.degrees if (item.degrees<result)
		result
	getTempAverage: (startTime, endTime) =>
		totalSeconds = 0.0
		totalDegrees = 0.0
		i = 0
		@forEach (item) =>
			tempStart = item.logDate
			tempEnd = endTime
			tempStart = startTime if (startTime.getTime() > tempStart.getTime())
			tempEnd = @[i+1].logDate if @length > i + 1
			seconds = (tempEnd.getTime() - tempStart.getTime()) / 1000
			totalSeconds += seconds
			totalDegrees += item.degrees * seconds
			i++
		result = Math.round(totalDegrees / totalSeconds, 1)
		result
	@getCsv: (thermostatId, cb) ->
		data = []
		Temperatures.loadRange thermostatId, new Date('2000-01-01'), new Date(), (temps) =>
			temps.forEach (temp) ->
				data.push [thermostatId, Utils.getDisplayDate(temp.logDate,'yyyy-mm-dd HH:MM:ss'), temp.degrees]
			output = Utils.getCsv ['ThermostatId','LogDate','Degrees'], data
			cb output
	@cast = (baseClass) ->
		baseClass.__proto__ = Temperatures::
		return baseClass
	@loadRange: (thermostatId, startDate, endDate, cb) ->
		Temperatures.loadFromQuery "SELECT * FROM temperatures WHERE thermostat_id=" + Global.escape(thermostatId) + " and log_date BETWEEN " + Global.escape(startDate) + " AND " + Global.escape(endDate) + " ORDER BY log_date",null, cb
	@loadFromQuery = ( query, params, cb ) ->
		TemperaturesBase.loadFromQuery query, params, (data) ->
			cb Temperatures.cast(data)
			
module.exports = Temperatures
