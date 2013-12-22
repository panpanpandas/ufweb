<%inherit file="/base.mako"/>

<%def name="head()">
<title>Ultra Finance</title>
</%def>

<h2>Ultra Finance</h3>
<a href="./crawler">Crawler</a>
</br>
<button onclick="startCrawler({})">Start Crawler</button>
</br>
</br>
<a href="./backtest/results">Backtest Result</a>
</br>
% for configFile in configs:
	<h4>Strategy ${configFile}</h4>
	<button onclick="startBacktest({'configFile': '${configFile}'})">Start Backtest</button>
	<button onclick="start2007Backtest('${configFile}')">Start Backtest(2007-2009)</button>
	<button onclick="start2009Backtest('${configFile}')">Start Backtest(2009-2013)</button>
	<button onclick="start2006Backtest('${configFile}')">Start Backtest(2006-2013)</button>
% endfor

<script>
function start2006Backtest(configFile) {
	startBacktest({"configFile": configFile, "startTickDate": 20060101, "startTradeDate": 20060101, "endTradeDate": 20131210});
}

function start2007Backtest(configFile) {
	startBacktest({"configFile": configFile, "startTickDate": 20060101, "startTradeDate": 20070901, "endTradeDate": 20090901});
}

function start2009Backtest(configFile) {
	startBacktest({"configFile": configFile, "startTickDate": 20080101, "startTradeDate": 20090901, "endTradeDate": 20131210});
}


function startBacktest(data) {
	$.ajax({
	    type: "POST",
	    url: "./backtest",
	    processData: false,
	    contentType: 'application/json',
	    data: JSON.stringify(data),
	    success: function(r) {
		    window.location.replace("./backtest/results");
	    }
	});
}

function startCrawler(data) {
	$.ajax({
	    type: "POST",
	    url: "./crawler",
	    processData: false,
	    contentType: 'application/json',
	    data: JSON.stringify(data),
	    success: function(r) {
		    window.location.replace("./crawler");
	    }
	});
}
</script>

