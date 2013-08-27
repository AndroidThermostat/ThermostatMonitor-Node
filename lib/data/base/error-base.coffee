sys = require("sys")
Global = require("../../global.coffee")

class ErrorBase
	constructor: ( @id, @userId, @logDate, @errorMessage, @url ) ->
		@id = 0 if not @id?
	save: (cb) =>
		columns = { user_id: @userId, log_date: @logDate, error_message: @errorMessage, url: @url }
		if @id == 0
			Global.query "INSERT INTO errors SET ?", columns, (err, result) =>
				sys.puts err if err?
				@id=result.insertId
				cb()
		else
			Global.query "UPDATE errors SET ? WHERE id = " + @id, columns, cb
	@load = ( id, cb ) ->
		Global.query "SELECT * FROM errors where id = " + id, null, (err, rows) =>
			result = ErrorBase.loadRow rows[0] if (rows.length>0)
			cb(result);
	@delete = ( id, cb ) ->
		Global.query "DELETE FROM errors where id = " + id, null, (err, rows) =>
			cb();
	@loadRow = (row) ->
		return new ErrorBase row.id, row.user_id, row.log_date, row.error_message, row.url
	@loadFromQuery = ( query, params, cb ) ->
		Global.query query, params, (err, rows) =>
			sys.puts err if err?
			result = null
			result = ErrorBase.loadRow rows[0] if rows.length>0
			cb(result);

module.exports = ErrorBase