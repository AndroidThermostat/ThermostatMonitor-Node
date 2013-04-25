sys = require "sys"
passport = require "passport"
pHash = require "password-hash"
email = require "emailjs"
LocalStrategy = require("passport-local").Strategy
User = require "../../lib/data/user.coffee"
Config = require "../../config.coffee"

class LoginRoute
	@setupPassport: () ->
		strategy = new LocalStrategy (username, password, cb) ->
			User.loadByEmail username, (user) ->
				if user?
					return cb(null,user) if pHash.verify(password, user.password) or user.password==password
				return cb(null, false, {message:'Login failed'}) 
		passport.use strategy
		passport.serializeUser (user,cb) ->
			cb(null, JSON.stringify(user))
		passport.deserializeUser (data, cb) ->
			user = eval('(' + data + ')')
			cb null, user
	@logout: (req, res)  ->
		req.logout();
		res.redirect('/');
	@login: (req, res)  ->
		func = passport.authenticate("local", {successRedirect: '/cp/', failureRedirect: '/'})
		func req,res
	@register: (req, res) ->
		username = req.query['username']
		password = req.query['password']
		User.loadByEmail username, (user) ->
			if user!=null
				res.redirect '/'
			else
				user = new User()
				user.emailAddress = username
				user.password = pHash.generate(password)
				user.save (err, results) ->
					sys.puts err
					LoginRoute.setupPassport()
					LoginRoute.login req, res
	@forgotPassword: (req, res) ->
		username = req.query['username']
		sys.puts 'loading ' + username
		User.loadByEmail username, (user) ->
			sys.puts JSON.stringify user
			if user==null
				res.redirect '/'
			else
				link = Config.baseUrl + '/auth/login?username=' + user.emailAddress + '&password=' + user.password
				server = email.server.connect {user: Config.emailAddress, password: Config.emailPassword, host: Config.emailHost, ssl: Config.emailSsl}	
				message = 
					text: 'Click here to reset your password: ' + link,
					from: Config.emailName + '<' + Config.EmailAddress + '>',
					to: user.emailAddress,
					subject: 'Password Reset',
					attachment: [ {data: '<html>Click <a href="' + link + '">here</a> to reset your password.', alternative:true } ]
				sys.puts 'sending'
				server.send message, (err, message) ->
					sys.puts err
					sys.puts message
					res.redirect '/'
module.exports = LoginRoute