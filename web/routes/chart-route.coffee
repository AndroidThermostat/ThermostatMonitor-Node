sys = require "sys"
Config = require "../../config.coffee"
ChartModel = require "../models/chart-model.coffee"

class ChartRoute
	@hourChart: (req, res) ->
		ChartModel.hourChart req.params.thermostatId, req, (data) ->
			res.render "cp/charts/hour-chart", data
	@deltaChart: (req, res) ->
		ChartModel.deltaChart req.params.thermostatId, req, (data) ->
			res.render "cp/charts/delta-chart", data
	@tempsChart: (req, res) ->
		ChartModel.tempsChart req.query['thermostatId'], new Date(req.query['date']), req, (data) ->
			res.render "cp/charts/temps-chart", data
	@conditionsChart: (req, res) ->
		ChartModel.conditionsChart req.query['locationId'], new Date(req.query['date']), req, (data) ->
			res.render "cp/charts/conditions-chart", data
	@cyclesChart: (req, res) ->
		ChartModel.cyclesChart req.query['thermostatId'], new Date(req.query['date']), req, (data) ->
			res.render "cp/charts/cycles-chart", data
module.exports = ChartRoute