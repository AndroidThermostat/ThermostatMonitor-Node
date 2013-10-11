sys = require "sys"
Config = require "../../config.coffee"
ApiModel = require "../models/api-model.coffee"
Thermostat = require "../../lib/data/thermostat.coffee"

class ApiRoute
	@v2: (req, res) ->
		key = req.query["k"]
		action = req.query["a"]
		mode = req.query["m"]
		duration = req.query["d"]
		precision = req.query["p"]
		temperature = req.query["t"]

		if action=='location'
			query = req.query["q"]
			query = req.query["z"] if query==null or query==''
			ApiModel.returnLocation query, (data) ->
				res.end data
		else
			Thermostat.loadByKey key, (thermostat) ->
				if thermostat==null
					res.end "Invalid API Key"
				else
					switch action
						when "cycle"
							ApiModel.logCycle thermostat, mode, duration
							res.end "OK"
						when "temp"
							ApiModel.logTemp thermostat, temperature
						when "conditions"
							ApiModel.logConditions thermostat.locationId, temperature
						when "snapshotdebug"
							ApiModel.generateSnapshots thermostat
						#when "stats"
							#ApiModel.redirectToStats thermostat
						else
							res.end "Invalid action"
	@log404: (req, res, next) ->
		res.redirect "/"
module.exports = ApiRoute