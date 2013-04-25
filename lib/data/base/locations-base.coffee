sys = require("sys")
async = require("async")
Global = require("../../global.coffee")
Location = require("../location.coffee")

class LocationsBase extends Array
	constructor:  ->
	save: (cb) =>
		async.forEach @, ((item, c) -> item.save(c)), cb
	sort_by: (field, reverse, primer) ->
		key = (x) ->
			(if primer then primer(x[field]) else x[field])
		sortFunction = (a, b) ->
			A = key(a)
			B = key(b)
			result = (if (A < B) then -1 else (if (A > B) then +1 else 0))
			result * [-1, 1][+!!reverse]
		sortFunction
	@loadAll = ( cb ) ->
		LocationsBase.loadFromQuery "select * from locations", {}, cb
	@loadFromQuery = ( query, params, cb ) ->
		Global.getPool().query query, params, (err, rows) =>
			sys.puts err if err?
			result = new LocationsBase()
			rows.forEach (row) ->
				result.push Location.loadRow row
			cb(result);

module.exports = LocationsBase