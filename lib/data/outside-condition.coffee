sys = require("sys")
OutsideConditionBase = require("./base/outside-condition-base.coffee")

class OutsideCondition extends OutsideConditionBase
	@cast = (baseClass) ->
		if baseClass != null
			baseClass.__proto__ = OutsideCondition::
		return baseClass
	@loadRow = (row) ->
		 OutsideCondition.cast(OutsideConditionBase.loadRow row)
	@loadFromQuery = ( query, params, cb ) ->
		OutsideConditionBase.loadFromQuery query, params, (data) ->
			cb OutsideCondition.cast(data)
module.exports = OutsideCondition