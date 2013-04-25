DateFormatter = require ("./date-formatter.coffee")
sys = require("sys")

class Utils
	@generateGuid: () ->
		return Utils.s4() + Utils.s4() + '-' + Utils.s4() + '-' + Utils.s4() + '-' + Utils.s4() + '-' + Utils.s4() + Utils.s4() + Utils.s4()
	@s4: () ->
		return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1).toUpperCase()
	@key: () ->
		new Date().getTime().toString(36)
	@getDisplayDate: (date, format) ->
		format = "m/d/yyyy" if not format?
		result = ""
		result = DateFormatter.format date, format if date? and date!=null
		return result
	@getCsv: (headers, data) ->
		first = true
		output = ''
		headers.forEach (header) ->
			output += ',' if not first
			output += '"' + header + '"'
			first = false
		output += '\r\n'
		data.forEach (row) ->
			first = true
			row.forEach (cell) ->
				output += ',' if not first
				output += cell.toString() if cell?
				first = false
			output += '\r\n'
		return output
module.exports = Utils