sys = require("sys")
CycleBase = require("./base/cycle-base.coffee")

class Cycle extends CycleBase
	getMinutes: () =>
		diffMs = @endDate - @startDate
		Math.round(diffMs / 1000.0 / 60.0 * 100.0) / 100.0
	@logCycle: (thermostatId, cycleType, startDate, endDate, startPrecision, endPrecision, cb) ->
		c = new Cycle()
		c.cycleType = cycleType
		c.thermostatId = thermostatId
		c.startDate = startDate
		c.endDate = endDate
		c.startPrecision = startPrecision
		c.endPrecision = endPrecision
		c.save cb
	@cast = (baseClass) ->
		if baseClass != null
			baseClass.__proto__ = Cycle::
		return baseClass
	@loadRow = (row) ->
		 Cycle.cast(CycleBase.loadRow row)
	@loadFromQuery = ( query, params, cb ) ->
		CycleBase.loadFromQuery query, params, (data) ->
			cb Cycle.cast(data)
module.exports = Cycle