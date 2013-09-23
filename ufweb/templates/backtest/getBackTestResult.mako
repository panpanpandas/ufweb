<%inherit file="/base.mako"/>

<%def name="head()">
</%def>

<!-- body ----------------------------------------------------------- -->
% if startDate is UNDEFINED:
	<h2>Backtest havn't run yet</h2>
% elif endDate is UNDEFINED:
	<h2>Running backtest from ${startDate}</h2>
% else:
	<h2>Backtest completed successfully from ${startDate} to ${endDate} </h2>
	<br>
	<h3>Metrics</h3>
	<table id="tableBactTestMetrics">
	    <thead>
	        <tr>
	            <td>Lowest Date&Value</td>
	            <td>Higest Date&Value</td>
	            <td>End Date&Value</td>
	            <td>Sharpe Ratio</td>
	        </tr>
	    </thead>
	    <tbody>
	        <tr>
	            <td>${metrics['minTimeValue'][0]} - ${metrics['minTimeValue'][1]}</td>
	            <td>${metrics['maxTimeValue'][0]} - ${metrics['maxTimeValue'][1]}</td>
	            <td>${metrics['endTime']} - ${metrics['endValue']}</td>
	            <td>${metrics['sharpeRatio']}</td>
	        </tr>
	    </tbody>
	</table>

	<br>
	<h3>Latest Orders</h3>
	<table id="tableBactTestLastestOrders">
    	<thead>
	        <tr>
	            <td>Date</td>
	            <td>Symbol</td>
	            <td>Action</td>
	            <td>Share</td>
	            <td>Price</td>
	            <td>Type</td>
	        </tr>
        </thead>
        <tbody>
        	% for order in latestOrders:
		        <tr>
		            <td>${order['date']}</td>
		            <td>${order['symbol']}</td>
		            <td>${order['action']}</td>
		            <td>${order['share']}</td>
		            <td>${order['price']}</td>
		            <td>${order['type']}</td>
		        </tr>
	        % endfor
        </tbody>
	</table>

	<br>
	<h3>Holdings</h3>
	<table id="tableBactTestHodlings">
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