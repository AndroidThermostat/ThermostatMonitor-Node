passport = require "passport"
sys = require "sys"
http = require "http"
path = require "path"
express = require "express"
Config = require "../config.coffee"

CpRoute = require "./routes/cp-route.coffee"
ChartRoute = require "./routes/chart-route.coffee"
StaticRoute = require "./routes/static-route.coffee"
LoginRoute = require "./routes/login-route.coffee"


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

LoginRoute.setupPassport()

app.post "/auth/login", passport.authenticate("local", {successRedirect: '/cp/', failureRedirect: '/'})
app.post "/cp/location/save", CpRoute.locationSave
app.post "/cp/thermostat/save", CpRoute.thermostatSave

app.get "/", StaticRoute.home
app.get "/auth/login", passport.authenticate("local", {successRedirect: '/cp/', failureRedirect: '/'})
app.get "/auth/logout", LoginRoute.logout
app.get "/auth/forgot", LoginRoute.forgotPassword
app.get "/auth/register", LoginRoute.register
app.get "/cp/", CpRoute.cp
app.get "/cp/charts/delta/:thermostatId", ChartRoute.deltaChart
app.get "/cp/charts/hours/:thermostatId", ChartRoute.hourChart
app.get "/cp/charts/temps", ChartRoute.tempsChart
app.get "/cp/charts/conditions", ChartRoute.conditionsChart
app.get "/cp/charts/cycles", ChartRoute.cyclesChart

app.get "/cp/location/edit/:locationId", CpRoute.locationEdit
app.get "/cp/thermostat/edit/:thermostatId", CpRoute.thermostatEdit
app.get "/cp/thermostat/:thermostatId", CpRoute.thermostat
app.get "/cp/thermostat/:thermostatId/csv/cycles", CpRoute.csvCycles
app.get "/cp/thermostat/:thermostatId/csv/summary", CpRoute.csvSummary
app.get "/csv/thermostats", CpRoute.csvThermostats
app.get "/csv/export", CpRoute.csvExport

app.get "/cp/thermostat/:thermostatId/reports", CpRoute.thermostatReport
app.get "/cp/thermostat/:thermostatId/day/:date", CpRoute.thermostatDay
app.get "/terms", StaticRoute.terms

http.createServer(app).listen app.get('port'), ()->
  console.log "Express server listening on port " + app.get('port')
