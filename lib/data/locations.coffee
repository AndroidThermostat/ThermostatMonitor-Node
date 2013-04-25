LocationsBase = require("./base/locations-base.coffee")
Location = require("./location.coffee")
sys = require("sys")


class Locations extends LocationsBase
	getIds: () =>
		result = []
		@forEach (item) =>
			result.push item.id
		result
	getById: (id) =>
		result = null
		@forEach (location) ->
			result = location if location.id==id
		return result
	@cast = (baseClass) ->
		baseClass.__proto__ = Locations::
		return baseClass
	@loadByUser: (userId, cb) ->
		Locations.loadFromQuery "SELECT * FROM locations WHERE ?", {user_id:userId}, cb
	@loadFromQuery = ( query, params, cb ) ->
		LocationsBase.loadFromQuery query, params, (data) ->
			cb Locations.cast(data)
			
module.exports = Locations
