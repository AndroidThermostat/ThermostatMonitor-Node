ErrorsBase = require("./base/errors-base.coffee")
Error = require("./error.coffee")
sys = require("sys")


class Errors extends ErrorsBase
	getIds: () =>
		result = []
		@forEach (item) =>
			result.push item.id
		result
	@cast = (baseClass) ->
		baseClass.__proto__ = Errors::
		return baseClass
	@loadFromQuery = ( query, params, cb ) ->
		ErrorsBase.loadFromQuery query, params, (data) ->
			cb Errors.cast(data)
			
module.exports = Errors
