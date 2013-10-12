passport = require "passport"
sys = require "sys"
http = require "http"
path = require "path"
express = require "express"
Config = require "../config.coffee"

Error = require '../lib/data/error.coffee'
Routes = require "./routes/index.coffee"

app = express()

app.configure () ->
	app.set 'port', process.env.PORT || 3100
	app.set 'views', __dirname + '/views'
	app.set 'view engine', 'jade'
	app.locals._ = require "underscore"
	app.use express.favicon(__dirname + '/public/favicon.ico')
	app.use express.bodyParser
		uploadDir: __dirname + "/tmp",
		keepExtensions: true
	app.use express.logger('dev')
	app.use express.methodOverride()
	app.use express.cookieParser(Config.cookieSecret)
	app.use express.session()
	app.use passport.initialize()
	app.use passport.session()
	app.use app.router
	app.use require('stylus').middleware(__dirname + '/public')
	app.use express.static(path.join(__dirname, 'public'))
	app.use Routes.Static.log404
	app.use (err, req, res, next) ->
		userId = 0
		userId = req.user.id if req.user?
		Error.log userId,err.stack,req.url, () ->
		console.log "Caught exception: " + err
		res.send(500, 'An unexpected error occurred.  Please return to the home page and try again.');

Routes.Login.setupPassport()

app.post "/auth/login", passport.authenticate("local", {successRedirect: '/cp/', failureRedirect: '/'})
app.post "/cp/location/save", Routes.CP.locationSave
app.post "/cp/location/delete", Routes.CP.locationDelete
app.post "/cp/thermostat/save", Routes.CP.thermostatSave
app.post "/cp/thermostat/delete", Routes.CP.thermostatDelete
app.post "/cp/user/save", Routes.CP.userSave

app.get "/", Routes.Static.home
app.get "/auth/login", passport.authenticate("local", {successRedirect: '/cp/', failureRedirect: '/'})
app.get "/auth/logout", Routes.Login.logout
app.get "/auth/forgot", Routes.Login.forgotPassword
app.get "/auth/register", Routes.Login.register
app.get "/cp/", Routes.CP.cp
app.get "/cp/charts/delta/:thermostatId", Routes.Chart.deltaChart
app.get "/cp/charts/hours/:thermostatId", Routes.Chart.hourChart
app.get "/cp/charts/temps", Routes.Chart.tempsChart
app.get "/cp/charts/conditions", Routes.Chart.conditionsChart
app.get "/cp/charts/cycles", Routes.Chart.cyclesChart

app.get "/cp/location/edit/:locationId", Routes.CP.locationEdit
app.get "/cp/location/config/:locationId", Routes.CP.downloadConfig
app.get "/cp/thermostat/edit/:thermostatId", Routes.CP.thermostatEdit
app.get "/cp/thermostat/:thermostatId", Routes.CP.thermostat
app.get "/cp/thermostat/:thermostatId/csv/cycles", Routes.CP.csvCycles
app.get "/cp/thermostat/:thermostatId/csv/summary", Routes.CP.csvSummary
app.get "/cp/account", Routes.CP.userEdit
app.get "/csv/thermostats", Routes.CP.csvThermostats
app.get "/csv/export", Routes.CP.csvExport

app.get "/cp/thermostat/:thermostatId/reports", Routes.CP.thermostatReport
app.get "/cp/thermostat/:thermostatId/day/:date", Routes.CP.thermostatDay
app.get "/terms", Routes.Static.terms

http.createServer(app).listen app.get('port'), ()->
  console.log "Express server listening on port " + app.get('port')


process.on "uncaughtException", (err) ->
	Error.log 0,err,'', () ->
		console.log "Caught exception: " + err