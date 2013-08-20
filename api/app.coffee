sys = require "sys"
http = require "http"
path = require "path"
express = require "express"
Config = require "../config.coffee"

ApiRoute = require "./routes/api-route.coffee"


app = express()

app.configure () ->
	app.set 'port', process.env.PORT || 3101
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
	app.use app.router
	app.use require('stylus').middleware(__dirname + '/public')
	app.use express.static(path.join(__dirname, 'public'))
	app.use ApiRoute.log404

app.get "/v2", ApiRoute.v2
app.get "/v2/", ApiRoute.v2


http.createServer(app).listen app.get('port'), ()->
  console.log "Express server listening on port " + app.get('port')
