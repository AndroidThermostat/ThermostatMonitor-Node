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
	getRange: (startDate, endDate) =>
		result = new OutsideConditions
		@forEach (item) =>
			result.push item if item.logDate>=startDate and item.logDate<=endDate
		result
	getByTime: (time) =>
		result = null
		@forEach (item) =>
			result = item if item.logDate<=time
		result
	getTempHigh: () =>
		result = -999
		@forEach (item) =>
			result = item.degrees if (item.degrees>result)
		result
	getTempLow: () =>
		result = 999
		@forEach (item) =>
			result = item.degrees if (item.degrees<result)
		result
	getTempAverage: (startTime, endTime) =>
		totalSeconds = 0.0
		totalDegrees = 0.0
		i = 0
		@forEach (item) =>
			if item?
				tempStart = item.logDate
				tempEnd = endTime
				tempStart = startTime if (startTime.getTime() > tempStart.getTime())
				tempEnd = @[i+1].logDate if @length > i + 1 and @[i+1]?
				seconds = (tempEnd.getTime() - tempStart.getTime()) / 1000
				totalSeconds += seconds
				totalDegrees += item.degrees * seconds
				i++
		result = 0;
		result = Math.round(totalDegrees / totalSeconds, 1) if totalSeconds>0
		result
	@getCsv: (locationId, cb) ->
		data = []
		OutsideConditions.loadRange locationId, new Date('2000-01-01'), new Date(), (temps) =>
			temps.forEach (temp) ->
				data.push [locationId,Utils.getDisplayDate(temp.logDate,'yyyy-mm-dd HH:MM:ss'), temp.degrees]
			output = Utils.getCsv ['LocationId','LogDate','Degrees'], data
			cb output
	@loadRange: (locationId, startDate, endDate, adjustedTimezone, cb) ->
		OutsideConditions.loadFromQuery "SELECT * FROM outside_conditions WHERE location_id=" + Global.escape(locationId) + " and log_date BETWEEN " + Global.escape(Utils.getServerDate(startDate, adjustedTimezone)) + " AND " + Global.escape(Utils.getServerDate(endDate, adjustedTimezone)) + " ORDER BY log_date",null, (conds) ->
			conds.forEach (cond) ->
				cond.logDate = Utils.getUserDate(cond.logDate, adjustedTimezone)
			cb conds

	@cast = (baseClass) ->
		baseClass.__proto__ = OutsideConditions::
		return baseClass
	@loadFromQuery = ( query, params, cb ) ->
		OutsideConditionsBase.loadFromQuery query, params, (data) ->
			cb OutsideConditions.cast(data)
			
module.exports = OutsideConditions
