<%inherit file="/base.mako"/>

<%def name="head()">
<script src="http://code.highcharts.com/stock/highstock.js"></script>
<script src="http://code.highcharts.com/stock/modules/exporting.js"></script>
<title>UF Backtest</title>
</%def>


<%import json%>



<!-- body ----------------------------------------------------------- -->
% if startDate is UNDEFINED:
	<h2>Backtest havn't run yet</h2>
% elif endDate is UNDEFINED:
	<h2>Running backtest from ${startDate}</h2>
% else:
	<h2>Backtest completed successfully from ${startDate} to ${endDate} </h2>
	<br>
	<table id="tableBactTestMetrics">
		<caption>Metrics</caption>
	    <thead>
	        <tr>
	            <td>Period</td>
	            <td>Lowest Value</td>
	            <td>Higest Value</td>
	            <td>End Value</td>
	            <td>Sharpe Ratio</td>
	            <td>Max Drawdown</td>
	            <td>R Squared</td>
	        </tr>
	    </thead>
	    <tbody>
	        <tr>
	            <td>${metrics['startDate']} - ${metrics['endDate']}</td>
	            <td>${"%.1f" % float(metrics['lowestValue'])}</td>
	            <td>${"%.1f" % float(metrics['highestValue'])}</td>
	            <td>${"%.1f" % float(metrics['endValue'])}</td>
	            <td>${"%.2f" % float(metrics['sharpeRatio'])}</td>
	            <td>${"%.1f%%" % (float(metrics['maxDrawDown']) * 100)}</td>
	            <td>${"%.1f" % float(metrics['rSquared'])}</td>
	        </tr>
	    </tbody>
	</table>

	<div id="positionDiv" style="height: 500px; width: 50%"></div>
	<script>
	$('#positionDiv').highcharts('StockChart', {
		rangeSelector : {
			selected : 0
		},

		title : {
			text : 'Account Position'
		},

		yAxis: [{
            title: {
                text: 'Account'
            },
            height: 200,
            lineWidth: 2
        }, {
            title: {
                text: 'Holdings'
            },
            top: 300,
            height: 100,
            offset: 0,
            lineWidth: 2
        }],

		series : [{"name": "account", "compare": "percent", "data": ${timeAndPostionList}},
		          {"name": "benchMark", "compare": "percent", "data": ${timeAndBenchmarkList}},
				  {"name": "holdings", yAxis: 1, "data": ${timeAndHoldingList}}],

	});
	</script>

	<br>
	<table id="tableBactTestLastestOrders">
    	<caption>Latest Orders</caption>
    	<thead>
	        <tr>
	            <td rowspan="2">Date</td>
	            <td rowspan="2">Account Value</td>
	            <td colspan="6">Latest Orders</td>
	            <td colspan="6">Excuted Orders</td>
	        </tr>
    	        <td>Symbol</td>
	            <td>Action</td>
	            <td>Share</td>
	            <td>Price</td>
	            <td>Type</td>
	            <td>Status</td>
	            <td>Symbol</td>
	            <td>Action</td>
	            <td>Share</td>
	            <td>Price</td>
	            <td>Type</td>
	            <td>Status</td>
	        <tr>
	        </tr>
        </thead>
        <tbody>
        	% for state in latestStates[-200:]:
	            <tr>
	            <td>${state['time']}</td>
	            <td>${state['account']}</td>
	            <td colspan="6"><table>
		        % for order in json.loads(state['placedOrders']):
					<tr>
			            <td>${json.loads(order)['symbol']}</td>
			            <td>${json.loads(order)['action']}</td>
			            <td>${json.loads(order)['share']}</td>
			            <td>${json.loads(order)['price']}</td>
			            <td>${json.loads(order)['type']}</td>
			            <td>${json.loads(order)['status']}</td>
		            </tr>
		        % endfor
		        </table></td>

		        <td colspan="6"><table>
		        % for order in json.loads(state['updatedOrders']):
					<tr>
			            <td>${json.loads(order)['symbol']}</td>
			            <td>${json.loads(order)['action']}</td>
			            <td>${json.loads(order)['share']}</td>
			            <td>${json.loads(order)['price']}</td>
			            <td>${json.loads(order)['type']}</td>
			            <td>${json.loads(order)['status']}</td>
		            </tr>
		        % endfor
		        </table></td>
		        </tr>
	        % endfor
        </tbody>
	</table>

	<br>
	<table id="tableBactTestHodlings">
		<caption>Holdings</caption>
    	<thead>
	        <tr>
	            <td>Symbol</td>
	            <td>Share</td>
	            <td>Price</td>
	        </tr>
        </thead>
        <tbody>
        	% for holding in json.loads(metrics["endHoldings"]):
		        <tr>
		            <td>${holding['symbol']}</td>
		            <td>${holding['share']}</td>
		            <td>${holding['price']}</td>
		        </tr>
	        % endfor
        </tbody>
	</table>
% endif
