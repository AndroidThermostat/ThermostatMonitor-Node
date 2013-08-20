mysql = require "mysql"
sys = require "sys"
Config = require "../config.coffee"

class Global
	@escape: (param) ->
		return mysql.escape param
	@poolLength: 20
	@handleDisconnect: (conn) ->
		conn.on "error", (err) ->
			return if not err.fatal
			conn = mysql.createConnection(Config.connectionString) if not conn?
			Global.handleDisconnect(conn)
			conn.connect()
	@getConnection: () ->
		if not @conn?
			@conn = mysql.createConnection(Config.connectionString) 
			Global.handleDisconnect(@conn)
		@conn
	@getPool: () ->
		if not @pool?
			@pool = []
			for num in [0..@poolLength - 1]
				conn = mysql.createConnection(Config.connectionString) 
				Global.handleDisconnect(conn)
				@pool.push conn
				@poolIndex = 0
		@poolIndex++
		@poolIndex = 0 if @poolIndex == @poolLength
		@pool[@poolIndex]
	@closePool: () ->
		for num in [0..@poolLength - 1]
			@pool[num].end()
module.exports = Global