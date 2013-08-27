outputPath = "../lib/data/base/"

mysql = require "mysql"
sys = require "sys"
fs = require "fs"
Config = require "../config.coffee"

generateBaseClass = (tableName, columns) ->
	className = getClassName tableName
	fields = []
	mappings = []
	rowFields = []
	columns.forEach (column) ->
		fields.push "@" + pascalToCamel(underscoreToPascal(column))
		mappings.push column + ": @" + pascalToCamel(underscoreToPascal(column)) if column != "id"
		rowFields.push "row." + column
	result = []
	result.push "sys = require(\"sys\")" + newline()
	result.push "Global = require(\"../../global.coffee\")" + newline(2)
	result.push "class " + className + "Base" + newline()
	result.push tab(1) + "constructor: ( " + fields.join(", ") + " ) ->" + newline()
	result.push tab(2) + "@id = 0 if not @id?" + newline()
	result.push tab(1) + "save: (cb) =>" + newline()
	result.push tab(2) + "columns = { " + mappings.join(", ") + " }" + newline()
	result.push tab(2) + "if @id == 0" + newline()
	result.push tab(3) + "Global.query \"INSERT INTO " + tableName + " SET ?\", columns, (err, result) =>" + newline()
	result.push tab(4) + "sys.puts err if err?" + newline()
	result.push tab(4) + "@id=result.insertId" + newline()
	result.push tab(4) + "cb()" + newline()
	result.push tab(2) + "else" + newline()
	result.push tab(3) + "Global.query \"UPDATE " + tableName + " SET ? WHERE id = \" + @id, columns, cb" + newline()
	result.push tab(1) + "@load = ( id, cb ) ->" + newline()
	result.push tab(2) + "Global.query \"SELECT * FROM " + tableName + " where id = \" + id, null, (err, rows) =>" + newline()
	result.push tab(3) + "result = " + className + "Base.loadRow rows[0] if (rows.length>0)" + newline()
	result.push tab(3) + "cb(result);" + newline()
	result.push tab(1) + "@delete = ( id, cb ) ->" + newline()
	result.push tab(2) + "Global.query \"DELETE FROM " + tableName + " where id = \" + id, null, (err, rows) =>" + newline()
	result.push tab(3) + "cb();" + newline()
	result.push tab(1) + "@loadRow = (row) ->" + newline()
	result.push tab(2) + "return new " + className + "Base " + rowFields.join(", ") + newline()
	result.push tab(1) + "@loadFromQuery = ( query, params, cb ) ->" + newline()
	result.push tab(2) + "Global.query query, params, (err, rows) =>" + newline()
	result.push tab(3) + "sys.puts err if err?" + newline()
	result.push tab(3) + "result = null" + newline()
	result.push tab(3) + "result = " + className + "Base.loadRow rows[0] if rows.length>0" + newline()
	result.push tab(3) + "cb(result);" + newline(2)
	result.push "module.exports = " + className + "Base"
	output = result.join ""
	fileName = outputPath + getSingular(tableName).toLowerCase().replace("_","-") + "-base.coffee"
	fs.writeFile fileName, output, (err) ->
		sys.puts fileName

generateBaseCollection = (tableName) ->
	className = getClassName tableName
	collectionName = underscoreToPascal tableName
	result = []
	result.push "sys = require(\"sys\")" + newline()
	result.push "async = require(\"async\")" + newline()
	result.push "Global = require(\"../../global.coffee\")" + newline()
	result.push className + " = require(\"../" + getSingular(tableName).toLowerCase().replace("_","-") + ".coffee\")" + newline(2)
	result.push "class " + collectionName + "Base extends Array" + newline()
	result.push tab(1) + "constructor:  ->" + newline()
	result.push tab(1) + "save: (cb) =>" + newline()
	result.push tab(2) + "async.forEach @, ((item, c) -> item.save(c)), cb" + newline()
	result.push tab(1) + "sort_by: (field, reverse, primer) ->" + newline()
	result.push tab(2) + "key = (x) ->" + newline()
	result.push tab(3) + "(if primer then primer(x[field]) else x[field])" + newline()
	result.push tab(2) + "sortFunction = (a, b) ->" + newline()
	result.push tab(3) + "A = key(a)" + newline()
	result.push tab(3) + "B = key(b)" + newline()
	result.push tab(3) + "result = (if (A < B) then -1 else (if (A > B) then +1 else 0))" + newline()
	result.push tab(3) + "result * [-1, 1][+!!reverse]" + newline()
	result.push tab(2) + "sortFunction" + newline()
	result.push tab(1) + "@loadAll = ( cb ) ->" + newline()
	result.push tab(2) + collectionName + "Base.loadFromQuery \"select * from " + tableName + "\", {}, cb" + newline()
	result.push tab(1) + "@loadFromQuery = ( query, params, cb ) ->" + newline()
	result.push tab(2) + "Global.query query, params, (err, rows) =>" + newline()
	result.push tab(3) + "sys.puts err if err?" + newline()
	result.push tab(3) + "result = new " + collectionName + "Base()" + newline()
	result.push tab(3) + "rows.forEach (row) ->" + newline()
	result.push tab(4) + "result.push " + className + ".loadRow row" + newline()
	result.push tab(3) + "cb(result);" + newline(2)
	result.push "module.exports = " + collectionName + "Base"
	output = result.join ""
	fileName = outputPath + tableName.toLowerCase().replace("_","-") + "-base.coffee"
	fs.writeFile fileName, output, (err) ->
		sys.puts fileName

tab = (count=1) ->
	result = ""
	result += "\t" for num in [1..count]
	result

newline = (count=1) ->
	result = ""
	result += "\r\n" for num in [1..count]
	result

getSingular = (name) ->
	name = name.substring(0, name.length-1) if name.substring(name.length-1, name.length) == "s"
getClassName = (tableName) ->
	underscoreToPascal(getSingular(tableName))
underscoreToPascal = (underscoreName) ->
	parts = underscoreName.split "_"
	result = ""
	parts.forEach (part) ->
		result += part.substring(0,1).toUpperCase()
		result += part.substring(1,part.length)
	return result
pascalToCamel = (pascalName) ->
	pascalName.substring(0,1).toLowerCase() + pascalName.substring(1,pascalName.length)


conn = mysql.createConnection({ host: Config.dbHost, user: Config.dbUser, password: Config.dbPass, database:Config.dbName})

conn.query "show tables", {}, (err, rows) =>
	parts = Config.connectionString.split("/")
	database = parts[parts.length-1]
	rows.forEach (row) ->
		tableName = row["Tables_in_" + database]
		conn.query "SHOW COLUMNS from " + tableName, {}, (err, subRows) =>
			columns = []
			subRows.forEach (subRow) ->
				columns.push subRow.Field
			generateBaseClass tableName, columns
			generateBaseCollection tableName
	conn.end()
	