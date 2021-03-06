sys = require("sys")
Global = require("../../global.coffee")

class UserBase
	constructor: ( @id, @emailAddress, @password, @authCode ) ->
		@id = 0 if not @id?
	save: (cb) =>
		columns = { email_address: @emailAddress, password: @password, auth_code: @authCode }
		if @id == 0
			Global.query "INSERT INTO users SET ?", columns, (err, result) =>
				sys.puts err if err?
				@id=result.insertId
				cb()
		else
			Global.query "UPDATE users SET ? WHERE id = " + @id, columns, cb
	@load = ( id, cb ) ->
		Global.query "SELECT * FROM users where id = " + id, null, (err, rows) =>
			result = UserBase.loadRow rows[0] if (rows.length>0)
			cb(result);
	@delete = ( id, cb ) ->
		Global.query "DELETE FROM users where id = " + id, null, (err, rows) =>
			cb();
	@loadRow = (row) ->
		return new UserBase row.id, row.email_address, row.password, row.auth_code
	@loadFromQuery = ( query, params, cb ) ->
		Global.query query, params, (err, rows) =>
			sys.puts err if err?
			result = null
			result = UserBase.loadRow rows[0] if rows.length>0
			cb(result);

module.exports = UserBase