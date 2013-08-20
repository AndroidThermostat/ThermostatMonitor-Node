sys = require "sys"
async = require "async"
Cycle = require "../../lib/data/cycle.coffee"
OutsideCondition = require "../../lib/data/outside-condition.coffee"
Snapshots = require "../../lib/data/snapshots.coffee"
Temperature = require "../../lib/data/temperature.coffee"
Weather = require "../../lib/weather.coffee"
Config = require "../../config.coffee"

class ApiModel
	@returnLocation: (query, cb) ->
		Weather.getCityId query, (id) ->
			cb id.toString()
	@logCycle: (thermostat, mode, duration) ->
		endDate = new Date()
		startDate = new Date()
		startDate.setMinutes(startDate.getMinutes - duration)
		Cycle.logCycle thermostat.id, startDate, endDate, 0, 0, () ->
			Snapshots.generate thermostat.id
	@logConditions: (locationId, temperature) ->
		OutsideCondition.log locationId, temperature
	@logTemp: (thermosatat, temperature) ->
		Temperature.logTemperature thermostat.id, temperature, 0
module.exports = ApiModel