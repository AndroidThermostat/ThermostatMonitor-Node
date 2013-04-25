sys = require("sys")
request = require("request")

class Weather
	@getCoordinates: (location, cb) ->
		url = "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20geo.placefinder%20where%20text%3D%22" + escape(location) + "%22&format=json"
		request url, (error, response, body) =>
			data = eval('(' + body + ')')
			lat = data.query.results.Result.latitude
			lon = data.query.results.Result.longitude
			cb [lat, lon]
	@getCityId: (location, cb) ->
		Weather.getCoordinates location, (coords) ->
			url = "http://openweathermap.org/data/2.1/find/city?lat=" + coords[0].toString() + "&lon=" + coords[1].toString() + "&cnt=1"
			request url, (error, response, body) =>
				data = eval('(' + body + ')')
				cb data.list[0].id
module.exports = Weather