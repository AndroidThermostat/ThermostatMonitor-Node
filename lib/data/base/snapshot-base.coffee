sys = require("sys")
Global = require("../../global.coffee")

class SnapshotBase
	constructor: ( @id, @thermostatId, @startTime, @seconds, @mode, @insideTempHigh, @insideTempLow, @insideTempAverage, @outsideTempHigh, @outsideTempLow, @outsideTempAverage ) ->
		@id = 0 if not @id?
	save: (cb) =>
		columns = { thermostat_id: @thermostatId, start_time: @startTime, seconds: @seconds, mode: @mode, inside_temp_high: @insideTempHigh, inside_temp_low: @insideTempLow, inside_temp_average: @insideTempAverage, outside_temp_high: @outsideTempHigh, outside_temp_low: @outsideTempLow, outside_temp_average: @outsideTempAverage }
		if @id == 0
			Global.query "INSERT INTO snapshots SET ?", columns, (err, result) =>
				sys.puts err if err?
				@id=result.insertId
				cb()
		else
			Global.query "UPDATE snapshots SET ? WHERE id = " + @id, columns, cb
	@load = ( id, cb ) ->
		Global.query "SELECT * FROM snapshots where id = " + id, null, (err, rows) =>
			result = SnapshotBase.loadRow rows[0] if (rows.length>0)
			cb(result);
	@delete = ( id, cb ) ->
		Global.query "DELETE FROM snapshots where id = " + id, null, (err, rows) =>
			cb();
	@loadRow = (row) ->
		return new SnapshotBase row.id, row.thermostat_id, row.start_time, row.seconds, row.mode, row.inside_temp_high, row.inside_temp_low, row.inside_temp_average, row.outside_temp_high, row.outside_temp_low, row.outside_temp_average
	@loadFromQuery = ( query, params, cb ) ->
		Global.query query, params, (err, rows) =>
			sys.puts err if err?
			result = null
			result = SnapshotBase.loadRow rows[0] if rows.length>0
			cb(result);

module.exports = SnapshotBase