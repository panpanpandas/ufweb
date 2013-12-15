<%inherit file="/base.mako"/>

<%def name="head()">
<script src="http://code.highcharts.com/stock/highstock.js"></script>
<script src="http://code.highcharts.com/stock/modules/exporting.js"></script>
<script src="/static/js/sorttable.js"></script>
<title>UF Backtest</title>
</%def>



<!-------------------------------- body ------------------------------------- -->
<h2>Backtest Results</h2>
% if running:
	<h4>${running}</h4>
% endif
<table id="resultTable" class="sortable">
	<caption>Available Backtest Results</caption>
	<thead>
		<tr>
			<td>Symbol</td>
			<td>Strategy</td>
			<td>Start Date</td>
			<td>End Date</td>
			<td>Detail</td>
		</tr>
	</thead>
	<tbody>
		% for result in results:
			% if len(result.split("__")) == 4:
				<tr>
				% for field in result.split("__"):
					<td>${field}</td>
				% endfor
				<td><a href="/backtest/result/${result}">Detail</a></td>
				</tr>
			% endif
		% endfor
	</tbody>
</table>

