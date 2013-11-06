<%inherit file="/base.mako"/>

<%def name="head()">
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
<title>Ultra Finance</title>
</%def>

<h3>Ultra Finance</h3>
<a href="./crawler">Crawler</a>
</br>
<a href="./backtest">Backtest</a>

<button onclick="startBacktest({})">start backtest</button>
<button onclick="start2007Backtest()">start backtest(2007-2009)</button>
<button onclick="start2009Backtest()">start backtest(2009-2013)</button>

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
</script>

