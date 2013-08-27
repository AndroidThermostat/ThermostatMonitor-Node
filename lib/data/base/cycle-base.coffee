sys = require("sys")
Global = require("../../global.coffee")

class CycleBase
	constructor: ( @id, @thermostatId, @cycleType, @startDate, @endDate, @startPrecision, @endPrecision ) ->
		@id = 0 if not @id?
	save: (cb) =>
		columns = { thermostat_id: @thermostatId, cycle_type: @cycleType, start_date: @startDate, end_date: @endDate, start_precision: @startPrecision, end_precision: @endPrecision }
		if @id == 0
			Global.query "INSERT INTO cycles SET ?", columns, (err, result) =>
				sys.puts err if err?
				@id=result.insertId
				cb()
		else
			Global.query "UPDATE cycles SET ? WHERE id = " + @id, columns, cb
	@load = ( id, cb ) ->
		Global.query "SELECT * FROM cycles where id = " + id, null, (err, rows) =>
			result = CycleBase.loadRow rows[0] if (rows.length>0)
			cb(result);
	@delete = ( id, cb ) ->
		Global.query "DELETE FROM cycles where id = " + id, null, (err, rows) =>
			cb();
	@loadRow = (row) ->
		return new CycleBase row.id, row.thermostat_id, row.cycle_type, row.start_date, row.end_date, row.start_precision, row.end_precision
	@loadFromQuery = ( query, params, cb ) ->
		Global.query query, params, (err, rows) =>
			sys.puts err if err?
			result = null
			result = CycleBase.loadRow rows[0] if rows.length>0
			cb(result);

module.exports = CycleBase