<%inherit file="/base.mako"/>

<%def name="head()">
<title>Ultra Finance</title>
</%def>

<h3>Ultra Finance</h3>
<a href="./crawler">Crawler</a>
</br>
<button onclick="startCrawler({})">Start Crawler</button>
</br>
</br>
<a href="./backtest/results">Backtest Result</a>
</br>
<button onclick="startBacktest({})">Start Backtest</button>
<button onclick="start2007Backtest()">Start Backtest(2007-2009)</button>
<button onclick="start2009Backtest()">Start Backtest(2009-2013)</button>

<script>
function start2007Backtest() {
	startBacktest({"startTickDate": 20060101, "startTradeDate": 20070901, "endTradeDate": 20090901});
}

function start2009Backtest() {
	startBacktest({"startTickDate": 20080101, "startTradeDate": 20090901, "endTradeDate": 20131010});
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

