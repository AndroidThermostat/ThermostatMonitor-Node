ThermostatsBase = require("./base/thermostats-base.coffee")
Thermostat = require("./thermostat.coffee")
sys = require("sys")
Utils = require "../utils.coffee"

class Thermostats extends ThermostatsBase
	getIds: () =>
		result = []
		@forEach (item) =>
			result.push item.id
		result
	@getCsv: (thermostats, locations, cb) ->
		data = []
		thermostats.forEach (thermostat) ->
			location = locations.getById thermostat.locationId
			if location.shareData
				data.push [thermostat.id, thermostat.locationId, thermostat.acTons, thermostat.acSeer, thermostat.acKilowatts, thermostat.fanKilowatts, thermostat.heatBtuPerHour, location.zipCode, location.electricityPrice, location.heatFuelPrice, location.timezone ]
		output = Utils.getCsv ['Id','LocationId','AcTons','AcSeer','AcKilowatts','FanKilowatts','HeatBtuPerHour','ZipCode','ElectricityPrice','HeatFuelPrice','Timezone'], data
		cb output
	@cast = (baseClass) ->
		baseClass.__proto__ = Thermostats::
		return baseClass
	@loadByLocation: (locationId, cb) ->
		Thermostats.loadFromQuery "SELECT * FROM thermostats WHERE ?", {location_id:locationId}, cb
	@loadFromQuery = ( query, params, cb ) ->
		ThermostatsBase.loadFromQuery query, params, (data) ->
			cb Thermostats.cast(data)
			
module.exports = Thermostats
