sys = require "sys"
async = require "async"
fs = require "fs"
Thermostats = require "../../lib/data/thermostats.coffee"
Cycles = require "../../lib/data/cycles.coffee"
Locations = require "../../lib/data/locations.coffee"
Location = require "../../lib/data/location.coffee"
Thermostat = require "../../lib/data/thermostat.coffee"
Snapshots = require "../../lib/data/snapshots.coffee"
Temperatures = require "../../lib/data/temperatures.coffee"
User = require "../../lib/data/user.coffee"
OutsideConditions = require "../../lib/data/outside-conditions.coffee"
Config = require "../../config.coffee"
LoginRoute = require "../routes/login-route.coffee"
Weather = require "../../lib/weather.coffee"
Utils = require "../../lib/utils.coffee"


class CpModel
	@downloadConfig: (locationId, cb) ->
		Location.load locationId, (location) ->
			Thermostats.loadByLocation location.id, (thermostats) ->
				firstThermostat = true
				result = "class Config\r\n\t@apiUrl: 'http://api.thermostatmonitor.com/v2/',\r\n\t@thermostats: [\r\n"
				thermostats.forEach (thermostat) ->
					if thermostat.brand == 'RTCOA'
						result += "\t\t"
						result += ", " if !firstThermostat
						result += "{apiKey: '" + thermostat.keyName + "', ipAddress: '" + thermostat.ipAddress + "', name: '" + thermostat.displayName.replace(/'/g,'') + "'}\r\n"
						firstThermostat = false
				result += "\t],\r\n\t@openWeatherMapStation: '" + location.openWeatherCityId + "'\r\nmodule.exports = Config"
				cb result
	@checkAuth: (req, res) ->
		res.redirect('/') if not req.user?
	@cpHome: (req, cb) ->
		Locations.loadByUser req.user.id, (locations) ->
			async.each locations, (location, cb2) ->
				Thermostats.loadByLocation location.id, (thermostats) ->
					location.thermostats = thermostats
					location.showInstall = false
					thermostats.forEach (thermostat) ->
						location.showInstall = true if thermostat.brand == 'RTCOA'
					cb2() 
			, (err) ->
				cb
					title: "Control Panel", user: req.user, cdn: Config.cdn, locations: locations

	@userEdit: (userId, req, cb) ->
		cb
			title: "Edit Account", user: req.user, cdn: Config.cdn
	@userSave: (userId, req, cb) ->
		errors = []
		pHash = require "password-hash"
		req.user.emailAddress = req.body['email']
		req.user.password = pHash.generate(req.body['password'])
		user = User.cast(req.user)
		user.save (err, results) ->
			cb errors

	@locationEdit: (locationId, req, cb) ->
		Location.loadOrCreate locationId, (location) ->
			if location.id==0
				location.name = 'New Location'
				location.shareData = true
				location.timezone = -6
				location.daylightSavings = true
			cb
				title: "Edit Location", user: req.user, cdn: Config.cdn, location: location, timeZones: CpModel.getTimeZones()
	@locationSave: (locationId, req, cb) ->
		errors = []
		Location.loadOrCreate locationId, (location) ->
			location.name = req.body['name']
			location.zipCode = req.body['zipCode']
			location.electricityPrice = req.body['electricity']
			location.heatFuelPrice = req.body['heat']
			location.timezone = req.body['timezone']
			location.daylightSavings = req.body['daylightSavings']=='on'
			location.shareData = req.body['shareData']=='on'

			Weather.getCityId location.zipCode, (cityId) ->
				location.cityId = cityId
				location.apiKey = Utils.generateGuid() if location.id==0
				location.userId = req.user.id if location.id==0
				location.save (err, results) ->
					cb errors
	@locationDelete: (locationId, req, cb) ->
		Location.load locationId, (location) ->
			if location.userId == req.user.id
				Location.delete locationId, () ->
					cb()
	@thermostatEdit: (thermostatId, req, cb) ->
		Thermostat.loadOrCreate thermostatId, (thermostat) ->
			if thermostat.id==0
				thermostat.name = 'New Thermostat'
				thermostat.locationId = req.query['locationId']
			cb
				title: "Edit Thermostat", user: req.user, cdn: Config.cdn, thermostat: thermostat
	@thermostatSave: (thermostatId, req, cb) ->
		errors = []
		Thermostat.loadOrCreate thermostatId, (thermostat) ->
			thermostat.displayName = req.body['displayName']
			thermostat.brand = req.body['brand']
			thermostat.ipAddress = req.body['ipAddress']
			thermostat.acSeer = parseFloat(req.body['acSeer'])
			thermostat.acTons = parseFloat(req.body['acTons'])
			thermostat.fanKilowatts = parseFloat(req.body['fanKilowatts'])
			thermostat.heatBtuPerHour = parseFloat(req.body['heatBtuPerHour'])
			thermostat.acKilowatts = (thermostat.acTons * 12.0) / thermostat.acSeer
			thermostat.locationId = req.body['locationId'] if thermostat.id==0
			sys.puts thermostat.keyName
			thermostat.keyName = Utils.key() if not thermostat.keyName? or thermostat.keyName==null or thermostat.keyName==''
			thermostat.save (err, results) ->
				cb errors
	@thermostatDelete: (thermostatId, req, cb) ->
		Thermostat.load thermostatId, (thermostat) ->
			Location.load thermostat.locationId, (location) ->
				if location.userId == req.user.id
					Thermostat.delete thermostatId, () ->
						cb()
	@thermostat: (thermostatId, req, cb) ->
		now = new Date()
		endDate = Utils.removeTime(new Date)
		startDate = Utils.removeTime(new Date)
		startDate.setDate(startDate.getDate()-6)
		endDate.setDate(endDate.getDate()+1)

		Thermostat.load thermostatId, (thermostat) ->
			Location.load thermostat.locationId, (location) ->
				tz = Utils.getAdjustedTimezone location.timezone, location.daylightSavings
				Snapshots.loadDailySummary thermostat, location, startDate, endDate, tz, (summary) ->
					cb
						title: 'Thermostat: ' + thermostat.displayName, user: req.user, cdn: Config.cdn, thermostat: thermostat, summary: summary
	@thermostatDay: (thermostatId, reportDate, req, cb) ->
		endDate = new Date(reportDate.getTime())
		endDate.setDate(endDate.getDate()+1)
		Thermostat.load thermostatId, (thermostat) ->
			cb
				title: thermostat.displayName + ' - Summary for ' + Utils.getDisplayDate(reportDate, 'ddd, mmmm d, yyyy'), user: req.user, cdn: Config.cdn, thermostat: thermostat, linkDate: Utils.getDisplayDate(reportDate,'yyyy-mm-dd'), linkEndDate: Utils.getDisplayDate(endDate,'yyyy-mm-dd')
	@thermostatReport: (thermostatId, req, cb) ->
		startDate = new Date
		startDate.setHours 0,0,0,0
		endDate = new Date(startDate.getTime())
		prevStartDate = new Date(startDate.getTime())
		prevEndDate = new Date(startDate.getTime())

		startDate.setDate(startDate.getDate()-7)
		endDate.setDate(endDate.getDate()-1)
		prevStartDate.setDate(prevStartDate.getDate()-14)
		prevEndDate.setDate(prevEndDate.getDate()-8)
		compare = true

		sys.puts req.query['startDate']
		startDate = new Date(req.query['startDate']) if req.query['startDate']
		endDate = new Date(req.query['endDate']) if req.query['endDate']
		prevStartDate = new Date(req.query['prevStartDate']) if req.query['prevStartDate']
		prevEndDate = new Date(req.query['prevEndDate']) if req.query['prevEndDate']
		compare = req.query['compare']=='true' if req.query['compare']

		Thermostat.load thermostatId, (thermostat) ->
			cb
				title: 'Report for Thermostat: ' + thermostat.displayName, user: req.user, cdn: Config.cdn, thermostat: thermostat, startDate: Utils.getDisplayDate(startDate), endDate: Utils.getDisplayDate(endDate), prevStartDate: Utils.getDisplayDate(prevStartDate), prevEndDate: Utils.getDisplayDate(prevEndDate), compare: compare
	@csvCycles: (thermostatId, req, cb) ->
		Thermostat.load thermostatId, (thermostat) ->
			Cycles.getCsv thermostat, cb
				
	@csvSummary: (thermostatId, req, cb) ->
		startDate = new Date('2000-01-01')
		endDate = new Date()
		Thermostat.load thermostatId, (thermostat) =>
			Location.load thermostat.locationId, (location) =>
				Snapshots.getDailySummaryCsv thermostat, location, startDate, endDate, cb
	@csvThermostats: (cb) ->
		async.parallel [(callback) =>
			Thermostats.loadAll (thermostats) =>
				callback null, thermostats
		, (callback) =>
			Locations.loadAll (locations) =>
				callback null, locations
		], (err, results) ->
			locations = Locations.cast(results[1])
			Thermostats.getCsv results[0], locations, cb
	@csvExport: (cb) ->
		async.parallel [(callback) =>
			Thermostats.loadAll (thermostats) =>
				callback null, thermostats
		, (callback) =>
			Locations.loadAll (locations) =>
				callback null, locations
		], (err, results) ->
			folder = './public/csv/'
			locations = Locations.cast(results[1])
			snapshotsCsv = ''
			cyclesCsv = ''
			insideCsv = ''
			outsideCsv = ''
			async.parallel [(callback2) =>
				Thermostats.getCsv results[0], locations, (csv) ->
					fs.writeFile folder + 'thermostats.csv', csv, (output) ->
						callback2 null, output
			, (callback2) =>
				q = async.queue (task, callback3) ->
					Snapshots.getDailySummaryCsv task.thermostat, task.location, new Date('2000-01-01'), new Date(), (csv) ->
						#fs.writeFile folder + 't' + task.thermostat.id + '_summary.csv', csv, (output) ->
						snapshotsCsv += csv + '\r\n'
						callback3()
				q.drain = () ->
					fs.writeFile folder + 'summary.csv', snapshotsCsv, (output) ->
						snapshotsCsv = ''
						callback2 null, "Summary"
				results[0].forEach (thermostat) ->
					location = locations.getById thermostat.locationId
					q.push {thermostat: thermostat, location:location} if location.shareData
			, (callback2) =>
				q = async.queue (task, callback3) ->
					Cycles.getCsv task.thermostat, (csv) ->
						cyclesCsv += csv + '\r\n'
						#fs.writeFile folder + 't' + task.thermostat.id + '_cycles.csv', csv, (output) ->
						callback3()
				q.drain = () ->
					fs.writeFile folder + 'cycles.csv', cyclesCsv, (output) ->
						cyclesCsv = ''
						callback2 null, "Cycles"
				results[0].forEach (thermostat) ->
					location = locations.getById thermostat.locationId
					q.push {thermostat: thermostat, location:location} if location.shareData
			, (callback2) =>
				q = async.queue (task, callback3) ->
					Temperatures.getCsv task.thermostat.id, (csv) ->
						#fs.writeFile folder + 't' + task.thermostat.id + '_inside.csv', csv, (output) ->
						insideCsv += csv + '\r\n'
						callback3()
				q.drain = () ->
					fs.writeFile folder + 'inside.csv', insideCsv, (output) ->
						insideCsv = ''
						callback2 null, "Temps"
				results[0].forEach (thermostat) ->
					location = locations.getById thermostat.locationId
					q.push {thermostat: thermostat, location:location} if location.shareData
			, (callback2) =>
				q = async.queue (task, callback3) ->
					OutsideConditions.getCsv task.location.id, (csv) ->
						#fs.writeFile folder + 'l' + task.location.id + '_outside.csv', csv, (output) ->
						outsideCsv += csv + '\r\n'
						callback3()
				q.drain = () ->
					fs.writeFile folder + 'outside.csv', outsideCsv, (output) ->
						outsideCsv = ''
						callback2 null, "OutsideConditions"
				results[0].forEach (thermostat) ->
					location = locations.getById thermostat.locationId
					q.push {thermostat: thermostat, location:location} if location.shareData
			], (err2, results2) ->
				fs.unlinkSync folder + 'export.zip'
				files = fs.readdirSync folder
				fileArray = []
				files.forEach (file) ->
					fileArray.push { name: file, path: folder + file }
				sys.puts JSON.stringify fileArray
				zip = require "node-native-zip"				
				archive = new zip()
				archive.addFiles fileArray, (err) ->
					buff = archive.toBuffer()
					fs.writeFileSync folder + 'export.zip', buff
					files.forEach (file) ->
						fs.unlinkSync folder + file if file.indexOf('.csv')>-1
					cb()


	@getTimeZones: () ->
		result = []
		result.push { value:-12, name: '(GMT -12:00) Eniwetok, Kwajalein' }
		result.push { value:-11, name: '(GMT -11:00) Midway Island, Samoa' }
		result.push { value:-10, name: '(GMT -10:00) Hawaii' }
		result.push { value:-9, name: '(GMT -9:00) Alaska' }
		result.push { value:-8, name: '(GMT -8:00) Pacific Time (US & Canada)' }
		result.push { value:-7, name: '(GMT -7:00) Mountain Time (US & Canada)' }
		result.push { value:-6, name: '(GMT -6:00) Central Time (US & Canada), Mexico City' }
		result.push { value:-5, name: '(GMT -5:00) Eastern Time (US & Canada), Bogota, Lima' }
		result.push { value:-4, name: '(GMT -4:00) Atlantic Time (Canada), Caracas, La Paz' }
		result.push { value:-3, name: '(GMT -3:00) Brazil, Buenos Aires, Georgetown' }
		result.push { value:-2, name: '(GMT -2:00) Mid-Atlantic' }
		result.push { value:-1, name: '(GMT -1:00 hour) Azores, Cape Verde Islands' }
		result.push { value:0, name: '(GMT) Western Europe Time, London, Lisbon, Casablanca' }
		result.push { value:1, name: '(GMT +1:00 hour) Brussels, Copenhagen, Madrid, Paris' }
		result.push { value:2, name: '(GMT +2:00) Kaliningrad, South Africa' }
		result.push { value:3, name: '(GMT +3:00) Baghdad, Riyadh, Moscow, St. Petersburg' }
		result.push { value:4, name: '(GMT +4:00) Abu Dhabi, Muscat, Baku, Tbilisi' }
		result.push { value:5, name: '(GMT +5:00) Ekaterinburg, Islamabad, Karachi, Tashkent' }
		result.push { value:6, name: '(GMT +6:00) Almaty, Dhaka, Colombo' }
		result.push { value:7, name: '(GMT +7:00) Bangkok, Hanoi, Jakarta' }
		result.push { value:8, name: '(GMT +8:00) Beijing, Perth, Singapore, Hong Kong' }
		result.push { value:9, name: '(GMT +9:00) Tokyo, Seoul, Osaka, Sapporo, Yakutsk' }
		result.push { value:10, name: '(GMT +10:00) Eastern Australia, Guam, Vladivostok' }
		result.push { value:11, name: '(GMT +11:00) Magadan, Solomon Islands, New Caledonia' }
		result.push { value:12, name: '(GMT +12:00) Auckland, Wellington, Fiji, Kamchatka' }
		return result
module.exports = CpModel