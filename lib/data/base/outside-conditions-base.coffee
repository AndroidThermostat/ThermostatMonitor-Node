sys = require("sys")
async = require("async")
Global = require("../../global.coffee")
OutsideCondition = require("../outside-condition.coffee")

class OutsideConditionsBase extends Array
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
		OutsideConditionsBase.loadFromQuery "select * from outside_conditions", {}, cb
	@loadFromQuery = ( query, params, cb ) ->
		Global.query query, params, (err, rows) =>
			sys.puts err if err?
			result = new OutsideConditionsBase()
			rows.forEach (row) ->
				result.push OutsideCondition.loadRow row
			cb(result);

module.exports = OutsideConditionsBase