mysql = require "mysql"
sys = require "sys"
Config = require "../config.coffee"

class Global
	@escape: (param) ->
		return mysql.escape param
	@getPool: (cb) ->
		if not @pool?
			@pool = mysql.createPool({ host: Config.dbHost, user: Config.dbUser, password: Config.dbPass, database:Config.dbName})
		@pool.getConnection (err, conn) ->
			sys.puts err if err?
			cb conn
	@query: (query, params, cb) ->
		sys.puts query
		@getPool (conn) ->
			conn.query query, params, (err, rows) ->
				sys.puts err if err?
				conn.end()
				cb err, rows
module.exports = Global