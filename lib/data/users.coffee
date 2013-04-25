UsersBase = require("./base/users-base.coffee")
User = require("./user.coffee")
sys = require("sys")


class Users extends UsersBase
	getIds: () =>
		result = []
		@forEach (item) =>
			result.push item.id
		result
	@cast = (baseClass) ->
		baseClass.__proto__ = Users::
		return baseClass
	@loadFromQuery = ( query, params, cb ) ->
		UsersBase.loadFromQuery query, params, (data) ->
			cb Users.cast(data)
			
module.exports = Users
