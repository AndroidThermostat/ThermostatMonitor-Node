sys = require("sys")
ThermostatBase = require("./base/thermostat-base.coffee")

class Thermostat extends ThermostatBase
	@loadOrCreate: (thermostatId, cb) ->
		if parseInt(thermostatId) == 0
			cb new Thermostat()
		else
			Thermostat.load thermostatId, cb
	@loadByKey: (key, cb) ->
		Thermostat.loadFromQuery "SELECT * FROM thermostats WHERE ?", {key_name:key}, cb
	@cast = (baseClass) ->
		if baseClass != null
			baseClass.__proto__ = Thermostat::
		return baseClass
	@loadRow = (row) ->
		 Thermostat.cast(ThermostatBase.loadRow row)
	@loadFromQuery = ( query, params, cb ) ->
		ThermostatBase.loadFromQuery query, params, (data) ->
			cb Thermostat.cast(data)
module.exports = Thermostat