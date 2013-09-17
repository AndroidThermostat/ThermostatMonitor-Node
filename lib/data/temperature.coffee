sys = require("sys")
TemperatureBase = require("./base/temperature-base.coffee")

class Temperature extends TemperatureBase
	@cast = (baseClass) ->
		if baseClass != null
			baseClass.__proto__ = Temperature::
		return baseClass
	@loadRow = (row) ->
		 Temperature.cast(TemperatureBase.loadRow row)
	@loadFromQuery = ( query, params, cb ) ->
		TemperatureBase.loadFromQuery query, params, (data) ->
			cb Temperature.cast(data)
	@log: (thermostatId, degrees, precision) ->
		t = new Temperature(0,thermostatId,new Date(),degrees,precision)
		t.save () ->
module.exports = Temperature