<%inherit file="/base.mako"/>

<%def name="head()">
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
<title>Ultra Finance</title>
</%def>

<h3>Ultra Finance</h3>
<a href="./crawler">Crawler</a>
</br>
<button onclick="startCrawler({})">Start Crawler</button>
</br>
</br>
<a href="./backtest">Backtest</a>
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
	$.post("./backtest", function(data) {
	  window.location.replace("./backtest");
	});
}

function startCrawler(data) {
	$.post("./crawler", function(data) {
	  window.location.replace("./crawler");
	});
}
</script>

