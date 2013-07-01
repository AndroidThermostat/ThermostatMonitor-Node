function showAPIKey(keyType, key)
{
	if (keyType=='location') $('#apiKeyModalBody').html('<p>The API key you need to enter into the Thermostat Monitor Desktop application is <b>' + key + '</b>.  This key and the desktop application are only needed to track the usage of Radio Thermostat brand thermostats.</p><p>If you haven\'t already done so, you will need to download the desktop application (<a href="/downloads/thermostatmonitor.zip">Windows</a> | <a href="/downloads/thermostatmonitor_mac.zip">Mac</a> | <a href="https://github.com/AndroidThermostat/ThermostatMonitor-Net/tree/master/ThermostatMonitor_RubyClient">Linux</a>).</p>');
	else $('#apiKeyModalBody').html('<p>The API key you need to enter into the Android Thermostat application is <b>' + key + '</b>.  This key is only needed if you\'re using an Android Thermostat device.  The desktop application is not needed.</p>');
	$('#apiKeyModal').modal();
	return false;
}

function toggleBrand() { if ($('#brand').val()=='RTCOA') { $('#ipLabel').show(); $('#ipAddress').show(); } else { $('#ipLabel').hide(); $('#ipAddress').hide(); } }


function drawTempsChart()
{
	var data = new google.visualization.DataTable(); //google.visualization.arrayToDataTable(chartData);
	data.addColumn('date', 'Time');
	data.addColumn('number', 'Temp');
	data.addRows(chartData.length);
	for (var i=0;i<chartData.length;i++)
	{
		data.setValue(i,0,new Date(chartData[i][0]));
		data.setValue(i,1,chartData[i][1]);
	}
	var chart = new google.visualization.AnnotatedTimeLine($('#chartDiv')[0]);
	var startDate = new Date(chartData[0][0]);
	chart.draw(data, {width: 910, height: 200, interpolateNulls: true, pointSize: 1, displayLegendDots:false, displayLegendValues:false, displayRangeSelector:false, displayZoomButtons:false, fill:100, dateFormat:'h:mm', scaleType:'maximized', zoomStartTime:startDate });

}

function drawConditionsChart()
{
	var data = new google.visualization.DataTable(); //google.visualization.arrayToDataTable(chartData);
	data.addColumn('date', 'Time');
	data.addColumn('number', 'Temp');
	data.addRows(chartData.length);
	for (var i=0;i<chartData.length;i++)
	{
		data.setValue(i,0,new Date(chartData[i][0]));
		data.setValue(i,1,chartData[i][1]);
	}
	var chart = new google.visualization.AnnotatedTimeLine($('#chartDiv')[0]);
	var startDate = new Date(chartData[0][0]);
	chart.draw(data, {width: 910, height: 200, interpolateNulls: true, pointSize: 1, displayLegendDots:false, displayLegendValues:false, displayRangeSelector:false, displayZoomButtons:false, fill:100, dateFormat:'h:mm', scaleType:'maximized', zoomStartTime:startDate, colors: ['#dc3912', '#97acd5', '#dc8773'] });
}

function drawHourChart()
{
	var data = google.visualization.arrayToDataTable(chartData);
	var chart = new google.visualization.AreaChart($('#chartDiv')[0]);
	chart.draw(data, {width: 940, height: 200, scaleType:'maximized', legend:'none', hAxis: { showTextEvery:2 }, chartArea: { width:885 }, colors: ['#4c78d1', '#dc3912', '#97acd5', '#dc8773'] });
}

function drawDeltaChart()
{
	var data = google.visualization.arrayToDataTable(chartData);
	var chart = new google.visualization.AreaChart($('#chartDiv')[0]);
	chart.draw(data, {width: 940, height: 200, scaleType:'maximized', legend:'none', hAxis: { showTextEvery:5 }, chartArea: { width:875 }, colors: ['#4c78d1', '#dc3912', '#97acd5', '#dc8773'] });
}

function drawCyclesChart()
{
	var data = new google.visualization.DataTable(); //google.visualization.arrayToDataTable(chartData);
	data.addColumn('date', 'Time');
	data.addColumn('number', 'Cycles');
	data.addRows(chartData.length);
	for (var i=0;i<chartData.length;i++)
	{
		data.setValue(i,0,new Date(chartData[i][0]));
		data.setValue(i,1,chartData[i][1]);
	}
	var chart = new google.visualization.AnnotatedTimeLine($('#chartDiv')[0]);
	var startDate = new Date(chartData[0][0]);
	chart.draw(data, {width: 940, height: 100, interpolateNulls: true, pointSize: 1, displayRangeSelector:false, displayZoomButtons:false, fill:100, dateFormat:'h:mm', scaleType:'maximized', zoomStartTime:startDate });

}

function updateReports()
{
	path = $(location).attr('href').split('?')[0];
	path += '?startDate=' + $('#startDate').val();
	path += '&endDate=' + $('#endDate').val();
	path += '&prevStartDate=' + $('#prevStartDate').val();
	path += '&prevEndDate=' + $('#prevEndDate').val();
	if ($('#compare').prop("checked")) path += '&compare=true'; else path += '&compare=false';
	location.href = path;
}

function register()
{
	if ($('#username').val()=='' || $('#password').val()=='')
	{
		alert('Please enter an email address and password first.');
	} else {
		$('#loginForm')[0].action='/auth/register';
		$('#loginForm')[0].submit();
	}
	return false;
}

function forgotPassword()
{
	if ($('#username').val()=='')
	{
		alert('Please enter an email address first.');
	} else {
		$('#loginForm')[0].action='/auth/forgot';
		$('#loginForm')[0].submit();
	}
	return false;
}