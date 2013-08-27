SnapshotsBase = require("./base/snapshots-base.coffee")
Snapshot = require("./snapshot.coffee")
sys = require("sys")
Global = require "../global.coffee"
Utils = require "../utils.coffee"
async = require "async"

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
	@generate: (thermostat, cb) ->
		startDate = new Date(2000,1,1)
		Snapshot.loadLast thermostat.id, (lastSnapshot) ->
			startDate = new Date(lastSnapshot.startTime.getTime()) if lastSnapshot!=null
			dayBefore = new Date(startDate.getTime())
			dayBefore = dayBefore.setDays(dayBefore.getDates() - 1)
			async.parallel [(callback) =>
				cycles.loadRange thermostat.id, startDate, new Date(), (cycles) ->
					callback null, cycles
			, (callback) =>
				temperatures.loadRange thermostat.id, dayBefore, new Date(), (temperatures) ->
					callback null, temperatures
			, (callback) =>
				conditions.loadRange thermostat.locationId, dayBefore, new Date(), (conditions) ->
					callback null, conditions
			], (err, results) ->
				cycles.removeIncomple()
				if cycles.length==0
					cb()
				else
					lastCycleEndDate = new Date(cycles[0].startDate.getTime())
					lastCycleEndDate = new Date(startDate.getTime()) if lastSnapShot!=null
					results[0].forEach (cycle) ->
						Snapshots.logOffCycle thermostat.id, cycle, lastCycleEndDate, results[1], results[2]
						Snapshots.logOnCycle thermostat.id, cycle, results[1], results[2]
						lastCycleEndDate = new Date(cycles[0].endDate.getTime());
					cb()
	@logOffCycle: (thermostatId, cycle, lastCycleEndDate, allTemperatures, allConditions, cb) ->
		temperatures = allTemperatures.getRange(lastCycleEndDate, cycle.startDate)
		conditions = allConditions.getRange(lastCycleEndDate, cycle.startDate)
		previousTemperature = allTemperatures.getByTime(lastCycleEndDate)
		previousCondition = allConditions.getByTime(lastCycleEndDate)
		temperatures.insert 0, previousTemperature
		conditions.insert 0, previousCondition
		if cycle.startDate <= lastCycleEndDate or (conditions.length==0 or temperatures.length==0)
			cb()
		else
			endDate = new Date(cycle.startDate.getTime())
			s = new Snapshot()
			s.startTime = new Date(lastCycleEndDate)
			s.seconds = Math.round((cycle.startDate.getTime() - lastCycleEndDate.getTime()) / 1000)
			s.thermostatId = thermostatId
			s.mode = 'Off'
			s.insideTempAverage = cycles.getTempAverage(lastCycleEndDate, cycle.startDate)
			s.insideTempHigh = cycles.getTempHigh()
			s.insideTempLow = cycles.getTempLow()
			s.outsideTempAverage = conditions.getTempAverage(lastCycleEndDate, cycle.startDate)
			s.outsideTempHigh = conditions.getTempHigh()
			s.outsideTempLow = conditions.getTempLow()
			if (s.seconds > 10 and s.seconds< 86400) #significant and less than a day
				s.save () ->
					cb()
			else
				cb()
	@logOnCycle: (thermostatId, cycle, allTemperatures, allConditions, cb) ->
		temperatures = allTemperatures.getRange(cycle.startDate, cycle.endDate)
		conditions = allConditions.getRange(cycle.startDate, cycle.endDate)
		previousTemperature = allTemperatures.getByTime(cycle.startDate)
		previousCondition = allConditions.getByTime(cycle.startDate)
		temperatures.insert 0, previousTemperature
		conditions.insert 0, previousCondition
		if conditions.length==0 or temperatures.length==0
			cb()
		else
			endDate = new Date(cycle.startDate.getTime())
			s = new Snapshot()
			s.startTime = new Date(lastCycleEndDate)
			s.seconds = Math.round((cycle.startDate.getTime() - lastCycleEndDate.getTime()) / 1000)
			s.thermostatId = thermostatId
			s.mode = 'Off'
			s.insideTempAverage = cycles.getTempAverage(lastCycleEndDate, cycle.startDate)
			s.insideTempHigh = cycles.getTempHigh()
			s.insideTempLow = cycles.getTempLow()
			s.outsideTempAverage = conditions.getTempAverage(lastCycleEndDate, cycle.startDate)
			s.outsideTempHigh = conditions.getTempHigh()
			s.outsideTempLow = conditions.getTempLow()
			if (s.seconds > 10 and s.seconds< 86400) #significant and less than a day
				s.save () ->
					cb()
			else
				cb()



	@getDailySummaryCsv: (thermostat, location, startDate, endDate, cb) ->
		Snapshots.loadDailySummary thermostat, location, startDate, endDate, (rows) =>
			data = []
			prevDate = null
			rows.forEach (row) ->
				data.push [thermostat.id,row.linkDate,row.low,row.high,row.heatCycles,row.heatMinutes,row.heatAverage,row.coolCycles,row.coolMinutes,row.coolAverage]	
			output = Utils.getCsv ['ThermostatId','LogDate','OutsideMin','OutsideMax','HeatCycles','HeatMinutes','HeatAverage','CoolCycles','CoolMinutes','CoolAverage'], data
			cb output
	@loadDailySummary: (thermostat, location, startDate, endDate, cb) ->
		days = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']
		result = []
		sql = 'SELECT date(start_time) as report_date, mode, count(*) as cycles, sum(seconds) as total_seconds, min(outside_temp_low) as low, max(outside_temp_high) as high FROM thermostatmonitor.snapshots where thermostat_id=' + Global.escape(thermostat.id) + ' and start_time between ' + Global.escape(startDate) + ' and ' + Global.escape(endDate) + ' group by date(start_time), mode'
		Global.query sql, null, (err, rows) =>
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
					totalKw = row.total_seconds / 3600.0 * (thermostat.acKilowatts + thermostat.fanKilowatts)
					data.coolCost = '$' + (totalKw * location.electricityPrice / 100.0).toFixed(2)
				else if row.mode=='Heat'
					data.heatCycles = row.cycles
					data.heatMinutes = Math.round(row.total_seconds / 60.0 * 10.0) / 10.0
					data.heatAverage = Math.round(row.total_seconds / row.cycles / 60.0 * 10.0) / 10.0
					data.heatCost = '$' + (row.total_seconds / 3600.0 * (thermostat.heatBtuPerHour * location.heatFuelPrice / 1000000.0)).toFixed(2)
			cb result
	@loadDeltas: (thermostatId, startDate, endDate, cb) ->
		sql = 'select outside_temp_average - inside_temp_average as delta, mode, sum(seconds) as total_seconds from snapshots where thermostat_id=' + Global.escape(thermostatId) + ' and start_time BETWEEN ' + Global.escape(startDate) + ' AND ' + Global.escape(endDate) + ' group by outside_temp_average - inside_temp_average, mode order by delta'
		Global.query sql, null, (err, rows) =>
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
