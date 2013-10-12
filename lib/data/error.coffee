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
	@log: (userId, errorMessage, url, cb) ->
		e = new Error()
		e.logDate = new Date()
		e.userId = userId if userId? and userId>0
		e.errorMessage = errorMessage
		e.url = url
		e.save cb
module.exports = Error