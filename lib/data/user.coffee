sys = require("sys")
UserBase = require("./base/user-base.coffee")
Global = require "../global.coffee"

class User extends UserBase
	@cast = (baseClass) ->
		if baseClass != null
			baseClass.__proto__ = User::
		return baseClass
	@loadRow = (row) ->
		 User.cast(UserBase.loadRow row)
	@loadByAuthCode: (authCode, cb) ->
		User.loadFromQuery "SELECT * FROM Users WHERE ?", {auth_code: authCode}, cb
	@loadByEmail: (email, cb) ->
		sys.puts email
		User.loadFromQuery "SELECT * FROM Users WHERE email_address=" + Global.escape(email), {}, cb
	@loadByEmailPassword: (email, password, cb) ->
		User.loadFromQuery "SELECT * FROM Users WHERE email_address=" + Global.escape(email) + " and password=" + Global.escape(password), {}, cb
	@loadFromQuery = ( query, params, cb ) ->
		UserBase.loadFromQuery query, params, (data) ->
			cb User.cast(data)
module.exports = User