sys = require("sys")
SnapshotBase = require("./base/snapshot-base.coffee")

class Snapshot extends SnapshotBase
	getSecondsPerHour: (tzOffset) ->
		startHour = @startTime.getHours()
		endTime = new Date(@startTime)
		endTime.setSeconds(endTime.getSeconds() + @seconds)
		endHour = endTime.getHours()
		result = {}
		for i in [startHour..endHour]
			totalSeconds = 3600
			totalSeconds = endTime.getMinutes() * 60 + endTime.getSeconds() if i==endHour
			totalSeconds = totalSeconds - @startTime.getMinutes() * 60 - @startTime.getSeconds() if i==startHour
			adjustedHour = i + tzOffset
			adjustedHour = 24 + adjustedHour if adjustedHour < 0
			adjustedHour = adjustedHour - 24 if adjustedHour > 23
			result[adjustedHour] = totalSeconds
		result
	@loadLast: (thermostatId, cb) ->
		Snapshot.loadFromQuery "SELECT * FROM snapshots where thermostat_id=" + thermostatId + " and start_time = (select MAX(start_time) from snapshots where thermostat_id=" + thermostatId + ")",[], cb
	@cast = (baseClass) ->
		if baseClass != null
			baseClass.__proto__ = Snapshot::
		return baseClass
	@loadRow = (row) ->
		 Snapshot.cast(SnapshotBase.loadRow row)
	@loadFromQuery = ( query, params, cb ) ->
		SnapshotBase.loadFromQuery query, params, (data) ->
			cb Snapshot.cast(data)
module.exports = Snapshot