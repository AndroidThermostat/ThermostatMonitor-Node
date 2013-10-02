sys = require "sys"
async = require "async"
Thermostats = require "../../lib/data/thermostats.coffee"
Locations = require "../../lib/data/locations.coffee"
Cycles = require "../../lib/data/cycles.coffee"
Location = require "../../lib/data/location.coffee"
Thermostat = require "../../lib/data/thermostat.coffee"
Snapshots = require "../../lib/data/snapshots.coffee"
Temperatures = require "../../lib/data/temperatures.coffee"
OutsideConditions = require "../../lib/data/outside-conditions.coffee"
Config = require "../../config.coffee"
Utils = require "../../lib/utils.coffee"

class ChartModel
	@tempsChart: (thermostatId, reportDate, req, cb) ->
		startDate = new Date(reportDate.toString())
		endDate = new Date(reportDate.toString())
		endDate.setDate(endDate.getDate() + 1)
		Thermostat.load thermostatId, (thermostat) ->
			Location.load thermostat.locationId, (location) ->
				tz = Utils.getAdjustedTimezone location.timezone, location.daylightSavings
				Temperatures.loadRange thermostatId, startDate, endDate, tz, (temps) ->
					startDate.setHours(startDate.getHours() - tz)
					endDate.setHours(endDate.getHours() - tz)

					result = []
					prevTemp = 0


					result.push [Utils.getDisplayDate(startDate,'yyyy/mm/dd HH:MM:ss'), temps[0].degrees]

					temps.forEach (temp) ->
						if prevTemp>0
							timeMinusOne = new Date(temp.logDate)
							timeMinusOne.setSeconds(timeMinusOne.getSeconds()-1)
							result.push [Utils.getDisplayDate(timeMinusOne,'yyyy/mm/dd HH:MM:ss'), prevTemp]
						result.push [Utils.getDisplayDate(temp.logDate,'yyyy/mm/dd HH:MM:ss'), temp.degrees]
						prevTemp = temp.degrees

					startDate.setHours(23,59,59,0)
					result.push [Utils.getDisplayDate(startDate,'yyyy/mm/dd HH:MM:ss'), prevTemp]

					cb
						data: JSON.stringify(result)
	@conditionsChart: (locationId, reportDate, req, cb) ->
		startDate = new Date(reportDate.toString())
		endDate = new Date(reportDate.toString())
		endDate.setDate(endDate.getDate() + 1)
		Location.load locationId, (location) ->
			tz = Utils.getAdjustedTimezone location.timezone, location.daylightSavings
			OutsideConditions.loadRange locationId, startDate, endDate, tz, (conditions) ->
				startDate.setHours(startDate.getHours() - tz)
				endDate.setHours(endDate.getHours() - tz)
				result = []
				prevTemp = 0
				result.push [Utils.getDisplayDate(startDate,'yyyy/mm/dd HH:MM:ss'), conditions[0].degrees]
				conditions.forEach (condition) ->
					#if prevTemp>0
						#timeMinusOne = new Date(condition.logDate)
						#timeMinusOne.setSeconds(timeMinusOne.getSeconds()-1)
						#result.push [Utils.getDisplayDate(timeMinusOne,'yyyy/mm/dd HH:MM:ss'), prevTemp]
					result.push [Utils.getDisplayDate(condition.logDate,'yyyy/mm/dd HH:MM:ss'), condition.degrees]
					prevTemp = condition.degrees
				startDate.setHours(23,59,59,0)
				result.push [Utils.getDisplayDate(startDate,'yyyy/mm/dd HH:MM:ss'), prevTemp]

				cb
					data: JSON.stringify(result)
	@cyclesChart: (thermostatId, reportDate, req, cb) ->
		startDate = new Date(reportDate.toString())
		endDate = new Date(reportDate.toString())
		endDate.setDate(endDate.getDate() + 1)
		Thermostat.load thermostatId, (thermostat) ->
			Location.load thermostat.locationId, (location) ->
				tz = Utils.getAdjustedTimezone location.timezone, location.daylightSavings
				Cycles.loadRange thermostatId, startDate, endDate, tz, (cycles) ->
					result = []
					startDate = Utils.getUserDate(Utils.getUtc(startDate), tz)
					endDate = Utils.getUserDate(Utils.getUtc(endDate), tz)
					result.push [Utils.getDisplayDate(startDate,'yyyy/mm/dd HH:MM:ss'), 0]
					cycles.forEach (cycle) ->
						cycle.endDate = endDate if cycle.endDate==null
						startMinusOne = new Date(cycle.startDate)
						startMinusOne.setSeconds(startMinusOne.getSeconds()-1)
						endMinusOne = new Date(cycle.endDate)
						endMinusOne.setSeconds(endMinusOne.getSeconds()-1)

						result.push [Utils.getDisplayDate(startMinusOne,'yyyy/mm/dd HH:MM:ss'), 0]
						result.push [Utils.getDisplayDate(cycle.startDate,'yyyy/mm/dd HH:MM:ss'), 1]
						result.push [Utils.getDisplayDate(endMinusOne,'yyyy/mm/dd HH:MM:ss'), 1]
						result.push [Utils.getDisplayDate(cycle.endDate,'yyyy/mm/dd HH:MM:ss'), 0]
					result.push [Utils.getDisplayDate(endDate,'yyyy/mm/dd HH:MM:ss'),0]
					sys.puts result.length
					cb 
						data: JSON.stringify(result)
	@hourChart: (thermostatId, req, cb) ->
		startDate = new Date(2000,1,1)
		endDate = new Date()
		prevStartDate = new Date(2000,1,1)
		prevEndDate = new Date()
		compare = false;

		startDate = new Date(req.query['startDate']) if req.query['startDate']
		endDate = new Date(req.query['endDate']) if req.query['endDate']
		prevStartDate = new Date(req.query['prevStartDate']) if req.query['prevStartDate']
		prevEndDate = new Date(req.query['prevEndDate']) if req.query['prevEndDate']
		compare = req.query['compare']=='true' if req.query['compare']

		Thermostat.load thermostatId, (thermostat) ->
			Location.load thermostat.locationId, (location) ->
				tz = Utils.getAdjustedTimezone location.timezone, location.daylightSavings
				Snapshots.loadRange thermostatId, startDate, endDate, tz, (snapshots) ->
					data = snapshots.getHourlyStats(tz)
					if !compare
						data.unshift ['Hour','Cool','Heat']
						cb data:JSON.stringify(data)
					else
						Snapshots.loadRange thermostatId, prevStartDate, prevEndDate,tz, (prevSnapshots) ->
							prevData = prevSnapshots.getHourlyStats(tz)
							prevData.forEach (row) ->
								existingRow = ChartModel.getRowByKey(data, row[0])
								existingRow[3] = row[1] #cool
								existingRow[4] = row[2] #heat
							data.unshift ['Hour','Cool','Heat','PrevCool','PrevHeat']
							cb data:JSON.stringify(data)
	@deltaChart: (thermostatId, req, cb) ->
		startDate = new Date(2000,1,1)
		endDate = new Date()
		prevStartDate = new Date(2000,1,1)
		prevEndDate = new Date()
		compare = false;

		startDate = new Date(req.query['startDate']) if req.query['startDate']
		endDate = new Date(req.query['endDate']) if req.query['endDate']
		prevStartDate = new Date(req.query['prevStartDate']) if req.query['prevStartDate']
		prevEndDate = new Date(req.query['prevEndDate']) if req.query['prevEndDate']
		compare = req.query['compare']=='true' if req.query['compare']

		Snapshots.loadDeltas thermostatId, startDate, endDate, (data) ->
			outputData = ChartModel.smoothPercents(ChartModel.smoothPercents(ChartModel.getDeltaPercents data))
			if !compare
				outputData.forEach (row) ->
					row[0] = row[0].toString() + '°'
				outputData.unshift ['Delta','Cool','Heat']
				cb data:JSON.stringify(outputData)
			else
				outputData.forEach (row) ->
					row[3] = 0
					row[4] = 0
				Snapshots.loadDeltas thermostatId, prevStartDate, prevEndDate, (prevData) ->
					prevData = ChartModel.smoothPercents(ChartModel.smoothPercents(ChartModel.getDeltaPercents prevData))
					prevData.forEach (row) ->
						#sys.puts row[0]
						existingRow = ChartModel.getRowByKey(outputData, row[0])
						if existingRow?
							existingRow[3] = row[1] #cool
							existingRow[4] = row[2] #heat
					outputData.forEach (row) ->
						row[0] = row[0].toString() + '°'
					outputData.unshift ['Delta','Cool','Heat','PrevCool','PrevHeat']
					cb data:JSON.stringify(outputData)

	@getRowByKey: (data, key) ->
		result = null
		data.forEach (row) ->
			result = row if row[0]==key
		result
	


	@getDeltaPercents: (data) ->
		result = []
		for i in [-100..100]
			deltaRows = ChartModel.getRowsByDelta data, i
			if deltaRows.length>0
				heatSeconds = ChartModel.getSecondsByMode deltaRows, "Heat"
				coolSeconds = ChartModel.getSecondsByMode deltaRows, "Cool"
				totalSeconds = ChartModel.getSecondsByMode deltaRows, ""
				heatPercent = heatSeconds / totalSeconds * 100.0
				coolPercent = coolSeconds / totalSeconds * 100.0
				result.push [i, coolPercent, heatPercent ]
		result

	@getRowsByDelta: (data, delta) ->
		result = []
		data.forEach (row) ->
			result.push row if row.delta == delta
		result

	@getSecondsByMode: (data, mode) ->
		result = 0
		data.forEach (row) ->
			result += row.totalSeconds if row.mode==mode or mode==""
		result
	@smoothPercents: (data) ->
		result = []
		if data.length > 0
			for i in [0..data.length-1]
				totalRows = 1
				totalCool = data[i][1]
				totalHeat = data[i][2]
				if i>0
					totalRows++
					totalCool += data[i-1][1]
					totalHeat += data[i-1][2]
				if i + 1 < data.length
					totalRows++
					totalCool += data[i+1][1]
					totalHeat += data[i+1][2]
				result.push [data[i][0], Math.round(totalCool / totalRows * 100.0) / 100.0, Math.round(totalHeat / totalRows * 100.0) / 100.0]
		result
module.exports = ChartModel