sys = require "sys"
Config = require "../../config.coffee"

class StaticRoute
	@home: (req, res) ->
		res.render "home", {title: "Thermostat Monitor", cdn: Config.cdn, user: req.user}
	@terms: (req, res) ->
		res.render "terms", {title: "Thermostat Monitor Terms of Use", cdn: Config.cdn, user: req.user}
module.exports = StaticRoute