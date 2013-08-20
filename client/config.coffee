class Config
	@apiUrl: 'http://api.thermostatmonitor.com/v2/',
	@thermostats: [
		{apiKey: 'abcd1234', ipAddress: '192.168.1.103', name: 'Downstairs'}
	],
	@openWeatherMapStation: '5328041'
module.exports = Config