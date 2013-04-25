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
	@getCsv: (thermostatId, cb) ->
		data = []
		Temperatures.loadRange thermostatId, new Date('2000-01-01'), new Date(), (temps) =>
			temps.forEach (temp) ->
				data.push [Utils.getDisplayDate(temp.logDate,'yyyy-mm-dd HH:MM:ss'), temp.degrees]
			output = Utils.getCsv ['LogDate','Degrees'], data
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
