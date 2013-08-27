sys = require("sys")
Global = require("../../global.coffee")

class OutsideConditionBase
	constructor: ( @id, @degrees, @logDate, @locationId ) ->
		@id = 0 if not @id?
	save: (cb) =>
		columns = { degrees: @degrees, log_date: @logDate, location_id: @locationId }
		if @id == 0
			Global.query "INSERT INTO outside_conditions SET ?", columns, (err, result) =>
				sys.puts err if err?
				@id=result.insertId
				cb()
		else
			Global.query "UPDATE outside_conditions SET ? WHERE id = " + @id, null, columns, cb
	@load = ( id, cb ) ->
		Global.query "SELECT * FROM outside_conditions where id = " + id, null, (err, rows) =>
			result = OutsideConditionBase.loadRow rows[0] if (rows.length>0)
			cb(result);
	@delete = ( id, cb ) ->
		Global.query "DELETE FROM outside_conditions where id = " + id, null, (err, rows) =>
			cb();
	@loadRow = (row) ->
		return new OutsideConditionBase row.id, row.degrees, row.log_date, row.location_id
	@loadFromQuery = ( query, params, cb ) ->
		Global.query query, params, (err, rows) =>
			sys.puts err if err?
			result = null
			result = OutsideConditionBase.loadRow rows[0] if rows.length>0
			cb(result);

module.exports = OutsideConditionBase