sys = require("sys")
LocationBase = require("./base/location-base.coffee")

class Location extends LocationBase
	@loadOrCreate: (locationId, cb) ->
		if parseInt(locationId) == 0
			cb new Location()
		else
			Location.load locationId, cb
	@cast = (baseClass) ->
		if baseClass != null
			baseClass.__proto__ = Location::
		return baseClass
	@loadRow = (row) ->
		 Location.cast(LocationBase.loadRow row)
	@loadFromQuery = ( query, params, cb ) ->
		LocationBase.loadFromQuery query, params, (data) ->
			cb Location.cast(data)
module.exports = Location