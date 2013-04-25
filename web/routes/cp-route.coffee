sys = require "sys"
Config = require "../../config.coffee"
CpModel = require "../models/cp-model.coffee"

class CpRoute
	@cp: (req, res) ->
		CpModel.checkAuth req, res
		CpModel.cpHome req, (data) ->
			res.render "cp/default", data
	@userEdit: (req, res) ->
		CpModel.checkAuth req, res
		CpModel.userEdit req.user.id, req, (data) ->
			res.render "cp/user-edit", data
	@userSave: (req, res) ->
		CpModel.checkAuth req, res
		CpModel.userSave req.user.id, req, (data) ->
			res.redirect "/cp/"
	@locationEdit: (req, res) ->
		CpModel.checkAuth req, res
		CpModel.locationEdit req.params.locationId, req, (data) ->
			res.render "cp/location-edit", data
	@locationSave: (req, res) ->
		CpModel.checkAuth req, res
		CpModel.locationSave req.body.locationId, req, (data) ->
			res.redirect "/cp/"
	@thermostatEdit: (req, res) ->
		CpModel.checkAuth req, res
		CpModel.thermostatEdit req.params.thermostatId, req, (data) ->
			res.render "cp/thermostat-edit", data
	@thermostatSave: (req, res) ->
		CpModel.checkAuth req, res
		CpModel.thermostatSave req.body.thermostatId, req, (data) ->
			#if data.errors.length>0
			#	res.render "location-edit", data
			#else
			res.redirect "/cp/"
	@thermostat: (req, res) ->
		CpModel.checkAuth req, res
		CpModel.thermostat req.params.thermostatId, req, (data) ->
			res.render "cp/thermostat", data
	@thermostatDay: (req, res) ->
		CpModel.checkAuth req, res
		CpModel.thermostatDay req.params.thermostatId, new Date(req.params.date), req, (data) ->
			res.render "cp/thermostat-day", data
	@thermostatReport: (req, res) ->
		CpModel.checkAuth req, res
		CpModel.thermostatReport req.params.thermostatId, req, (data) ->
			res.render "cp/thermostat-report", data
	@csvCycles: (req, res) ->
		CpModel.checkAuth req, res
		CpModel.csvCycles req.params.thermostatId, req, (data) ->
			res.setHeader 'Content-Type', 'text/csv'
			res.setHeader 'Content-Disposition', 'attachment; filename=cycles.csv'
			res.end data
	@csvSummary: (req, res) ->
		CpModel.checkAuth req, res
		CpModel.csvSummary req.params.thermostatId, req, (data) ->
			res.setHeader 'Content-Type', 'text/csv'
			res.setHeader 'Content-Disposition', 'attachment; filename=summary.csv'
			res.end data
	@csvThermostats: (req, res) ->
		CpModel.csvThermostats (data) ->
			res.setHeader 'Content-Type', 'text/csv'
			res.setHeader 'Content-Disposition', 'attachment; filename=thermostats.csv'
			res.end data
	@csvExport: (req, res) ->
		CpModel.csvExport (data) ->
			res.end ""
module.exports = CpRoute