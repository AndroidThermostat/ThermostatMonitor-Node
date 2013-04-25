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
module.exports = Temperature