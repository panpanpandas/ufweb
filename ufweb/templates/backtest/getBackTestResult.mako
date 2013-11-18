<%inherit file="/base.mako"/>

<%def name="head()">
<script src="http://code.highcharts.com/stock/highstock.js"></script>
<script src="http://code.highcharts.com/stock/modules/exporting.js"></script>
<title>UF Backtest</title>
</%def>



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
	            <td>Lowest Date - Value</td>
	            <td>Higest Date - Value</td>
	            <td>End Date - Value</td>
	            <td>Sharpe Ratio</td>
	            <td>Max Drawdown</td>
	        </tr>
	    </thead>
	    <tbody>
	        <tr>
	        	<td>${metrics['startTime']} - ${metrics['endTime']}</td>
	            <td>${metrics['minTimeValue'][0]} - ${"%.1f" % metrics['minTimeValue'][1]}</td>
	            <td>${metrics['maxTimeValue'][0]} - ${"%.1f" % metrics['maxTimeValue'][1]}</td>
	            <td>${metrics['endTime']} - ${"%.1f" % metrics['endValue']}</td>
	            <td>${"%.2f" % metrics['sharpeRatio']}</td>
	            <td>${metrics['maxDrawDown'][0]} - ${"%.1f%%" % (metrics['maxDrawDown'][1] * 100)}</td>
	        </tr>
	    </tbody>
	</table>

	<div id="positionDiv" style="height: 200; width: 50%"></div>
	<script>
	$('#positionDiv').highcharts('StockChart', {
		rangeSelector : {
			selected : 0
		},

		title : {
			text : 'Account Position'
		},

		series : [{"name": "account", "data": ${timeAndPostionList}},
				  {"name": "Holdings", "data": ${timeAndHoldingList}},
				  {"name": "benchMark", "data": ${timeAndBenchmarkList}}],

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
        	% for state in latestStates[-30:]:
	            <tr>
	            <td>${state['time']}</td>
	            <td>${state['account']}</td>
	            <td colspan="6"><table>
		        % for order in state['placedOrders']:
					<tr>
			            <td>${order['symbol']}</td>
			            <td>${order['action']}</td>
			            <td>${order['share']}</td>
			            <td>${order['price']}</td>
			            <td>${order['type']}</td>
			            <td>${order['status']}</td>
		            </tr>
		        % endfor
		        </table></td>

		        <td colspan="6"><table>
		        % for order in state['updatedOrders']:
					<tr>
			            <td>${order['symbol']}</td>
			            <td>${order['action']}</td>
			            <td>${order['share']}</td>
			            <td>${order['price']}</td>
			            <td>${order['type']}</td>
			            <td>${order['status']}</td>
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
        	% for holding in holdings:
		        <tr>
		            <td>${holding['symbol']}</td>
		            <td>${holding['share']}</td>
		            <td>${holding['price']}</td>
		        </tr>
	        % endfor
        </tbody>
	</table>
% endif