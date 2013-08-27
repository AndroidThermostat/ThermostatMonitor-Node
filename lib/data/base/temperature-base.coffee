sys = require("sys")
Global = require("../../global.coffee")

class TemperatureBase
	constructor: ( @id, @thermostatId, @logDate, @degrees, @logPrecision ) ->
		@id = 0 if not @id?
	save: (cb) =>
		columns = { thermostat_id: @thermostatId, log_date: @logDate, degrees: @degrees, log_precision: @logPrecision }
		if @id == 0
			Global.query "INSERT INTO temperatures SET ?", columns, (err, result) =>
				sys.puts err if err?
				@id=result.insertId
				cb()
		else
			Global.query "UPDATE temperatures SET ? WHERE id = " + @id, columns, cb
	@load = ( id, cb ) ->
		Global.query "SELECT * FROM temperatures where id = " + id, null, (err, rows) =>
			result = TemperatureBase.loadRow rows[0] if (rows.length>0)
			cb(result);
	@delete = ( id, cb ) ->
		Global.query "DELETE FROM temperatures where id = " + id, null, (err, rows) =>
			cb();
	@loadRow = (row) ->
		return new TemperatureBase row.id, row.thermostat_id, row.log_date, row.degrees, row.log_precision
	@loadFromQuery = ( query, params, cb ) ->
		Global.query query, params, (err, rows) =>
			sys.puts err if err?
			result = null
			result = TemperatureBase.loadRow rows[0] if rows.length>0
			cb(result);

module.exports = TemperatureBase