sys = require "sys"
async = require "async"
Cycle = require "../../lib/data/cycle.coffee"
OutsideCondition = require "../../lib/data/outside-condition.coffee"
Snapshots = require "../../lib/data/snapshots.coffee"
Temperature = require "../../lib/data/temperature.coffee"
Thermostats = require "../../lib/data/thermostats.coffee"
Weather = require "../../lib/weather.coffee"
Config = require "../../config.coffee"

class ApiModel
	@returnLocation: (query, cb) ->
		Weather.getCityId query, (id) ->
			cb id.toString()
	@logCycle: (thermostat, mode, duration) ->
		endDate = new Date()
		startDate = new Date()
		sys.puts duration
		#startDate.setMinutes(startDate.getMinutes - duration)
		startDate = new Date(startDate - duration * 1000)
		Cycle.logCycle thermostat.id, mode, startDate, endDate, 0, 0, () ->
			Snapshots.generate thermostat, () ->
	@generateSnapshots: (thermostat) ->
		#Snapshots.generate thermostat, () ->
		Thermostats.loadFromQuery "select * from thermostats where id in (select distinct(thermostat_id) from cycles where start_date>'2013-10-01')", {}, (thermostats) ->
			async.eachSeries thermostats, (thermostat, cb) ->
				sys.puts thermostat.id
				Snapshots.generate thermostat, () ->
					cb()
	@logConditions: (locationId, temperature) ->
		OutsideCondition.log locationId, temperature
	@logTemp: (thermostat, temperature) ->
		Temperature.log thermostat.id, temperature, 0
module.exports = ApiModel