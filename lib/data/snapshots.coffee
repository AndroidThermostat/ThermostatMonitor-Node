SnapshotsBase = require("./base/snapshots-base.coffee")
Snapshot = require("./snapshot.coffee")
sys = require("sys")
Global = require "../global.coffee"
Utils = require "../utils.coffee"

class Snapshots extends SnapshotsBase
	getHourlyStats: (tzOffset) ->
		result = [] #hour, cool, heat
		totalSeconds = []
		totalCool = []
		totalHeat = []
		for i in [0..23]
			displayTime = i.toString() + "am"
			displayTime = (i - 12).toString() + "pm" if (i >= 13)
			displayTime = "12pm" if (displayTime == "12am")
			displayTime = "12am" if (displayTime == "0am")
			result.push [displayTime,0,0]
			totalSeconds.push 0
			totalCool.push 0
			totalHeat.push 0
		@forEach (snapshot) ->
			seconds = snapshot.getSecondsPerHour tzOffset
			for hour of seconds
				totalSeconds[hour] += seconds[hour]
				if (snapshot.mode=='Cool')
					totalCool[hour] += seconds[hour]
				else if (snapshot.mode=='Heat')
					totalHeat[hour] += seconds[hour]
		for i in [0..23]
			totalSeconds[i] = 1 if totalSeconds[i]==0
			result[i][1] = Math.round(totalCool[i] / totalSeconds[i] * 10000) / 100
			result[i][2] = Math.round(totalHeat[i] / totalSeconds[i] * 10000) / 100
		result
	getIds: () =>
		result = []
		@forEach (item) =>
			result.push item.id
		result
	@getDailySummaryCsv: (thermostat, location, startDate, endDate, cb) ->
		Snapshots.loadDailySummary thermostat, location, startDate, endDate, (rows) =>
			data = []
			prevDate = null
			rows.forEach (row) ->
				data.push [row.linkDate,row.low,row.high,row.heatCycles,row.heatAverage,row.heatMinutes,row.coolCycles,row.coolAverage,row.coolMinutes]	
			output = Utils.getCsv ['LogDate','OutsideMin','OutsideMax','HeatCycles','HeatMinutes','HeatAverage','CoolCycles','CoolMinutes','CoolAverage'], data
			cb output
	@loadDailySummary: (thermostat, location, startDate, endDate, cb) ->
		days = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']
		result = []
		sql = 'SELECT date(start_time) as report_date, mode, count(*) as cycles, sum(seconds) as total_seconds, min(outside_temp_low) as low, max(outside_temp_high) as high FROM thermostatmonitor.snapshots where thermostat_id=' + Global.escape(thermostat.id) + ' and start_time between ' + Global.escape(startDate) + ' and ' + Global.escape(endDate) + ' group by date(start_time), mode'
		Global.getPool().query sql, null, (err, rows) =>
			sys.puts err if err?
			rows.forEach (row) ->
				#sys.puts row.report_date
				row.report_date.setHours(row.report_date.getHours() + 5)
				result.push {reportDate: row.report_date, reportDay: days[row.report_date.getDay()], linkDate: Utils.getDisplayDate(row.report_date,'yyyy-mm-dd') } if result.length==0 or result[result.length-1].reportDate.getDay() != row.report_date.getDay()
				data = result[result.length-1]

				data.low = row.low if not data.low? or row.low<data.low
				data.high = row.high if not data.high? or row.high<data.high
				if row.mode=='Cool'
					data.coolCycles = row.cycles
					data.coolMinutes = Math.round(row.total_seconds / 60.0 * 10.0) / 10.0
					data.coolAverage = Math.round(row.total_seconds / row.cycles / 60.0 * 10.0) / 10.0
					data.coolCost = '$' + (row.total_seconds / 3600.0 * (thermostat.acKilowatts + thermostat.fanKilowatts)).toFixed(2)
				else if row.mode=='Heat'
					data.heatCycles = row.cycles
					data.heatMinutes = Math.round(row.total_seconds / 60.0 * 10.0) / 10.0
					data.heatAverage = Math.round(row.total_seconds / row.cycles / 60.0 * 10.0) / 10.0
					data.heatCost = '$' + (row.total_seconds / 3600.0 * (thermostat.heatBtuPerHour * location.heatFuelPrice / 1000000.0)).toFixed(2)
			cb result
	@loadDeltas: (thermostatId, startDate, endDate, cb) ->
		sql = 'select outside_temp_average - inside_temp_average as delta, mode, sum(seconds) as total_seconds from snapshots where thermostat_id=' + Global.escape(thermostatId) + ' and start_time BETWEEN ' + Global.escape(startDate) + ' AND ' + Global.escape(endDate) + ' group by outside_temp_average - inside_temp_average, mode order by delta'
		Global.getPool().query sql, null, (err, rows) =>
			sys.puts err if err?
			result = []
			rows.forEach (row) ->
				result.push 
					delta: row.delta, mode: row.mode, totalSeconds: row.total_seconds
			cb result
	@loadRange: (thermostatId, startDate, endDate, cb) ->
		Snapshots.loadFromQuery "SELECT * FROM Snapshots WHERE thermostat_id=" + Global.escape(thermostatId) + " and start_time BETWEEN " + Global.escape(startDate) + " AND " + Global.escape(endDate) + " ORDER BY start_time",null, cb
	@cast = (baseClass) ->
		baseClass.__proto__ = Snapshots::
		return baseClass
	@loadFromQuery = ( query, params, cb ) ->
		SnapshotsBase.loadFromQuery query, params, (data) ->
			cb Snapshots.cast(data)
			
module.exports = Snapshots
