sys = require("sys")
Global = require("../../global.coffee")

class ThermostatBase
	constructor: ( @id, @ipAddress, @displayName, @acTons, @acSeer, @acKilowatts, @fanKilowatts, @brand, @locationId, @heatBtuPerHour, @keyName ) ->
		@id = 0 if not @id?
	save: (cb) =>
		columns = { ip_address: @ipAddress, display_name: @displayName, ac_tons: @acTons, ac_seer: @acSeer, ac_kilowatts: @acKilowatts, fan_kilowatts: @fanKilowatts, brand: @brand, location_id: @locationId, heat_btu_per_hour: @heatBtuPerHour, key_name: @keyName }
		if @id == 0
			Global.getPool().query "INSERT INTO thermostats SET ?", columns, (err, result) =>
				sys.puts err if err?
				@id=result.insertId
				cb()
		else
			Global.getPool().query "UPDATE thermostats SET ? WHERE id = " + @id, columns, cb
	@load = ( id, cb ) ->
		Global.getPool().query "SELECT * FROM thermostats where id = " + id, (err, rows) =>
			result = ThermostatBase.loadRow rows[0] if (rows.length>0)
			cb(result);
	@delete = ( id, cb ) ->
		Global.getPool().query "DELETE FROM thermostats where id = " + id, (err, rows) =>
			cb();
	@loadRow = (row) ->
		return new ThermostatBase row.id, row.ip_address, row.display_name, row.ac_tons, row.ac_seer, row.ac_kilowatts, row.fan_kilowatts, row.brand, row.location_id, row.heat_btu_per_hour, row.key_name
	@loadFromQuery = ( query, params, cb ) ->
		Global.getPool().query query, params, (err, rows) =>
			sys.puts err if err?
			result = null
			result = ThermostatBase.loadRow rows[0] if rows.length>0
			cb(result);

module.exports = ThermostatBase