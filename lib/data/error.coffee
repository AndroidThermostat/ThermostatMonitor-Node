sys = require("sys")
ErrorBase = require("./base/error-base.coffee")

class Error extends ErrorBase
	@cast = (baseClass) ->
		if baseClass != null
			baseClass.__proto__ = Error::
		return baseClass
	@loadRow = (row) ->
		 Error.cast(ErrorBase.loadRow row)
	@loadFromQuery = ( query, params, cb ) ->
		ErrorBase.loadFromQuery query, params, (data) ->
			cb Error.cast(data)
module.exports = Error