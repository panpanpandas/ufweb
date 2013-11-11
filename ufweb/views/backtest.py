'''
Created on Aug 13, 2013

@author: ppa
'''
from pyramid.view import view_config
from ultrafinance.module.backTester import BackTester
from ultrafinance.lib.util import string2EpochTime
from ultrafinance.backTest.stateSaver.sqlSaver import listTableNames
import time

from ultrafinance.ufConfig.pyConfig import PyConfig
from ultrafinance.backTest.constant import *

from threading import Thread
import logging
LOG = logging.getLogger()


class BackTest(object):
    thread = None
    startTime = None
    endTime = None
    latestStates = None
    metrics = None
    holdings = None

    def __init__(self, request):
        self.request = request
        self.params = request.params
        self.session = request.session
        self.settings = request.registry.settings

    def __startBackTester(self, startTickDate, startTradeDate, endTradeDate, symbolLists):
        ''' start googleCrawler '''
        backTester = BackTester(configFile = self.settings["ultrafinance.config"], startTickDate = startTickDate,
                                startTradeDate = startTradeDate, endTradeDate = endTradeDate, cash = 150000,
                                symbolLists = symbolLists)
        backTester.setup()
        backTester.runTests()
        BackTest.metrics = backTester.getMetrics().values()[0]
        BackTest.latestStates = backTester.getLatestStates()
        BackTest.holdings = backTester.getHoldings()

        BackTest.endTime = time.asctime()


    ###############################################################################
    # controller functions
    @view_config(route_name='backtest', request_method="POST", renderer='json')
    def PostBackTest(self):
        ''' start crawler '''
        if BackTest.thread and BackTest.thread.is_alive():
            return {"status": "BackTest is running from %s" % BackTest.startTime}
        else:
            startTickDate = 20111005
            startTradeDate = 20131017
            endTradeDate = None
            symbols = None

            body = {}
            try:
                body = self.request.json_body
            except Exception:
                LOG.debug("Can't decode request body")

            if "startTickDate" in body and int(body["startTickDate"]) > 0:
                startTickDate = int(body["startTickDate"])

            if "startTradeDate" in body and int(body["startTradeDate"]) > 0:
                startTradeDate = int(body["startTradeDate"])

            if "endTradeDate" in body and int(body["endTradeDate"]) > 0:
                endTradeDate = int(body["endTradeDate"])

            if "symbols" in body:
                symbols = body["symbols"].split()

            LOG.debug("Get backtest request: startTickDate %d, startTradeDate %d, endTradeDate %d" % (startTickDate, startTradeDate, endTradeDate if endTradeDate else -1))
            BackTest.thread = Thread(target = self.__startBackTester,
                                     args=[startTickDate, startTradeDate, endTradeDate, [symbols] if symbols else None])
            BackTest.startTime = time.asctime()
            BackTest.endTime = None

            BackTest.thread.daemon = False
            BackTest.thread.start()
            return {"status": "BackTest started."}


    @view_config(route_name='backtest/tables', request_method="GET",
                 renderer='json')
    def GetBackTestTables(self):
        ''' get backtest status'''
        self.__config = PyConfig()
        self.__config.setSource(self.settings["ultrafinance.config"])

        outputDb = self.__config.getOption(CONF_ULTRAFINANCE_SECTION, CONF_OUTPUT_DB)
        return listTableNames(outputDb)

    @view_config(route_name='backtest', request_method="GET",
                 renderer='ufweb:templates/backtest/getBackTestResult.mako')
    def GetBackTestResult(self):
        ''' get backtest status'''
        return self.__getBackTestJson()

    @view_config(route_name='backtest.json', request_method="GET", renderer='json')
    def GetBackTestJsonResult(self):
        ''' get backtest status'''
        return self.__getBackTestJson()

    def __getBackTestJson(self):
        ''' get backtest json result '''
        ret = {}

        if BackTest.thread is None:
            return ret
        elif BackTest.thread and BackTest.thread.is_alive():
            return {"startDate": BackTest.startTime}
        else:
            return {"startDate": BackTest.startTime,
                    "endDate": BackTest.endTime,
                    "metrics": BackTest.metrics,
                    "latestStates": BackTest.latestStates,
                    "timeAndPostionList": [[string2EpochTime(str(state['time'])) * 1000, float(state['account'])]
                                           for state in BackTest.latestStates] if BackTest.latestStates else [],
                    "timeAndHoldingList": [[string2EpochTime(str(state['time'])) * 1000, float(state['holdingValue'])]
                                           for state in BackTest.latestStates] if BackTest.latestStates else [],
                    "holdings": self.__convertHoldingsToList(BackTest.holdings[0]) \
                    if BackTest.holdings and len(BackTest.holdings) > 0 else {}}

    def __convertHoldingsToList(self, holding):
        ''' convert holding to dict'''
        ret = []
        for symbol, (share, price) in holding.items():
            if share <= 0:
                continue

            ret.append({"symbol": symbol,
                        "share": int(share),
                        "price": "%.2f" % price})

        return ret

    def __convertOrderToDict(self, date, order):
        ''' convert order to dict '''
        return {"status": order.status,
                "action": order.action,
                "share": int(order.share),
                "symbol": order.symbol,
                "type": order.type,
                "price": "%.2f" % order.price,
                "date": date}