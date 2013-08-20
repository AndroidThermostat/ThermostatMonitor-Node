OutsideConditionsBase = require("./base/outside-conditions-base.coffee")
OutsideCondition = require("./outside-condition.coffee")
sys = require("sys")
Global = require "../global.coffee"
Utils = require '../utils.coffee'

class OutsideConditions extends OutsideConditionsBase
	getIds: () =>
		result = []
		@forEach (item) =>
			result.push item.id
		result
	@getCsv: (locationId, cb) ->
		data = []
		OutsideConditions.loadRange locationId, new Date('2000-01-01'), new Date(), (temps) =>
			temps.forEach (temp) ->
				data.push [locationId,Utils.getDisplayDate(temp.logDate,'yyyy-mm-dd HH:MM:ss'), temp.degrees]
			output = Utils.getCsv ['LocationId','LogDate','Degrees'], data
			cb output
	@loadRange: (locationId, startDate, endDate, cb) ->
		OutsideConditions.loadFromQuery "SELECT * FROM outside_conditions WHERE location_id=" + Global.escape(locationId) + " and log_date BETWEEN " + Global.escape(startDate) + " AND " + Global.escape(endDate) + " ORDER BY log_date",null, cb
	@cast = (baseClass) ->
		baseClass.__proto__ = OutsideConditions::
		return baseClass
	@loadFromQuery = ( query, params, cb ) ->
		OutsideConditionsBase.loadFromQuery query, params, (data) ->
			cb OutsideConditions.cast(data)
			
module.exports = OutsideConditions
