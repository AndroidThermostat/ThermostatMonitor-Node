CyclesBase = require("./base/cycles-base.coffee")
Cycle = require("./cycle.coffee")
sys = require("sys")
Global = require '../global.coffee'
Utils = require '../utils.coffee'

class Cycles extends CyclesBase
	getIds: () =>
		result = []
		@forEach (item) =>
			result.push item.id
		result
	getComplete: () =>
		result = new Cycles
		@forEach (cycle) ->
			result.push cycle if cycle.endDate? and cycle.endDate!=null
		result
	@getCsv: (thermostat, cb) ->
		data = []
		Cycles.loadRange thermostat.id, new Date('2000-01-01'), new Date(), (cycles) =>
			cycles.forEach (cycle) ->
				btus = 0
				kwH = 0
				btus = Math.round(cycle.getMinutes() * thermostat.heatBtuPerHour / 60.0 * 100.0)/100.0 if cycle.cycleType=='Heat'
				kwH = Math.round(cycle.getMinutes() * thermostat.fanKilowatts / 60.0 * 100.0) / 100.0 if cycle.cycleType=='Heat'
				kwH = Math.round(cycle.getMinutes() * (thermostat.acKilowatts + thermostat.fanKilowatts) / 60.0 * 100.0) / 100.0 if cycle.cycleType=='Cool'
				data.push [thermostat.id, cycle.cycleType, Utils.getDisplayDate(cycle.startDate,'yyyy-mm-dd HH:MM:ss'), Utils.getDisplayDate(cycle.endDate,'yyyy-mm-dd HH:MM:ss'), cycle.getMinutes(), kwH, btus]
			output = Utils.getCsv ['ThermostatId','CycleType','StartTime','EndTime','Minutes','kwH','BTUs'], data
			cb output

	@loadRange: (thermostatId, startDate, endDate, cb) ->
		sql = 'SELECT * FROM cycles WHERE thermostat_id=' + Global.escape(thermostatId) + ' AND start_date BETWEEN ' + Global.escape(startDate) + ' and ' + Global.escape(endDate) + ' ORDER BY start_date'
		Cycles.loadFromQuery sql, null, cb
	@cast = (baseClass) ->
		baseClass.__proto__ = Cycles::
		return baseClass
	@loadFromQuery = ( query, params, cb ) ->
		CyclesBase.loadFromQuery query, params, (data) ->
			cb Cycles.cast(data)
			
module.exports = Cycles
