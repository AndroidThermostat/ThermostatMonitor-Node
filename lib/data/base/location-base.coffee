sys = require("sys")
Global = require("../../global.coffee")

class LocationBase
	constructor: ( @id, @userId, @name, @apiKey, @zipCode, @electricityPrice, @shareData, @timezone, @daylightSavings, @heatFuelPrice, @openWeatherCityId ) ->
		@id = 0 if not @id?
	save: (cb) =>
		columns = { user_id: @userId, name: @name, api_key: @apiKey, zip_code: @zipCode, electricity_price: @electricityPrice, share_data: @shareData, timezone: @timezone, daylight_savings: @daylightSavings, heat_fuel_price: @heatFuelPrice, open_weather_city_id: @openWeatherCityId }
		if @id == 0
			Global.query "INSERT INTO locations SET ?", columns, (err, result) =>
				sys.puts err if err?
				@id=result.insertId
				cb()
		else
			sys.puts "updating"
			Global.query "UPDATE locations SET ? WHERE id = " + @id, columns, cb
	@load = ( id, cb ) ->
		Global.query "SELECT * FROM locations where id = " + id, null, (err, rows) =>
			result = LocationBase.loadRow rows[0] if (rows.length>0)
			cb(result);
	@delete = ( id, cb ) ->
		Global.query "DELETE FROM locations where id = " + id, null, (err, rows) =>
			cb();
	@loadRow = (row) ->
		return new LocationBase row.id, row.user_id, row.name, row.api_key, row.zip_code, row.electricity_price, row.share_data, row.timezone, row.daylight_savings, row.heat_fuel_price, row.open_weather_city_id
	@loadFromQuery = ( query, params, cb ) ->
		Global.query query, params, (err, rows) =>
			sys.puts err if err?
			result = null
			result = LocationBase.loadRow rows[0] if rows.length>0
			cb(result);

module.exports = LocationBase