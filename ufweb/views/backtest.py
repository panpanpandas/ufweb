'''
Created on Aug 13, 2013

@author: ppa
'''
from pyramid.view import view_config
from ultrafinance.module.backTester import BackTester
from ultrafinance.lib.util import string2EpochTime
from ultrafinance.backTest.stateSaver.sqlSaver import listTableNames
from ultrafinance.backTest.stateSaver.stateSaverFactory import StateSaverFactory

from ultrafinance.ufConfig.pyConfig import PyConfig
from ultrafinance.backTest.constant import *

import os
import time
import json

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


    def __startBackTester(self, configFile, startTickDate, startTradeDate, endTradeDate, symbolLists):
        ''' start googleCrawler '''
        backTester = BackTester(configFile = configFile, startTickDate = startTickDate,
                                startTradeDate = startTradeDate, endTradeDate = endTradeDate, cash = 150000,
                                symbolLists = symbolLists)
        backTester.setup()
        backTester.runTests()


    ###############################################################################
    # controller functions
    @view_config(route_name='backtest', request_method="POST", renderer='json')
    def postBackTest(self):
        ''' start crawler '''
        if BackTest.thread and BackTest.thread.is_alive():
            return {"status": "BackTest is running from %s" % BackTest.startTime}
        else:
            configFile = "zscorePortfolio.prod.ini"
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

            if "configFile" in body:
                configFile = body["configFile"]

            if "symbols" in body:
                symbols = body["symbols"].split()

            LOG.debug("Get backtest request: startTickDate %d, startTradeDate %d, endTradeDate %d" % (startTickDate, startTradeDate, endTradeDate if endTradeDate else -1))
            BackTest.thread = Thread(target = self.__startBackTester,
                                     args=[self.settings["ultrafinance.config.path.prefix"] + configFile,
                                           startTickDate,
                                           startTradeDate,
                                           endTradeDate,
                                           [symbols] if symbols else None])
            BackTest.startTime = time.asctime()
            BackTest.endTime = None

            BackTest.thread.daemon = False
            BackTest.thread.start()
            return {"status": "BackTest started."}


    @view_config(route_name='backtestResults', request_method="GET",
                 renderer='ufweb:templates/backtest/listBackTestResults.mako')
    def getBackTestResults(self):
        ''' get backtest results in json format '''
        return self.__getBackTestResultsJson()


    @view_config(route_name='backtestResults.json', request_method="GET",
                 renderer='json')
    def getBackTestResultsJosn(self):
        ''' get backtest results in json format '''
        return self.__getBackTestResultsJson()


    def __getBackTestResultsJson(self):
        ''' get results in json '''
        outputDirPath = self.settings["backtest.output_db_prefix"]
        if outputDirPath:
            # filter name like EBAY__zscorePortfolio__19901010__20131010
            resultFileNames = filter(lambda x: len(x.split("__")) == 4,
                                     os.listdir(outputDirPath.split("sqlite:///")[1]))
            ret = {"results": resultFileNames}
            if BackTest.thread and BackTest.thread.is_alive():
                ret["running"] = "One backTest is running from %s" % BackTest.startTime

            return ret
        else:
            return {"results": [], "running": ""}

    @view_config(route_name='backtestResult', request_method="GET",
                 renderer='ufweb:templates/backtest/getBackTestResult.mako')
    def getBackTestResult(self):
        ''' get backtest status'''
        name = self.request.matchdict['name']
        return self.__getBackTestJson(name)

    @view_config(route_name='backtestResult.json', request_method="GET", renderer='json')
    def getBackTestJsonResult(self):
        ''' get backtest status'''
        name = self.request.matchdict['name']
        return self.__getBackTestJson(name)

    def __getBackTestJson(self, resultName):
        ''' get one backtest result '''
        symbolOrNum, strategyName, startDate, endDate = self.__parseTableName(resultName)

        saver = self.__getSaver(resultName)

        latestStates = saver.getStates(0, None)

        metrics = saver.getMetrics()
        return {"symbolOrNum": symbolOrNum,
                "strategyName": strategyName,
                "startDate": startDate,
                "endDate": endDate,
                "metrics": metrics,
                "latestStates": latestStates,
                "timeAndPostionList": [[string2EpochTime(str(state['time'])) * 1000, float(state['account'])]
                                       for state in latestStates] if latestStates else [],
                "timeAndHoldingList": [[string2EpochTime(str(state['time'])) * 1000, float(state['holdingValue'])]
                                       for state in latestStates] if BackTest.latestStates else [],
                "timeAndBenchmarkList": [[string2EpochTime(str(state['time'])) * 1000, float(state['indexPrice'])]
                                         for state in latestStates] if latestStates else [],
                "holdings": metrics["endHoldings"]}

    def __getSaver(self, tableName):
        ''' get create it if not exist'''
        saver = None
        saverName = self.__config.getOption(CONF_ULTRAFINANCE_SECTION, CONF_SAVER)
        outputDb = self.__config.getOption(CONF_ULTRAFINANCE_SECTION, CONF_OUTPUT_DB_PREFIX) + tableName
        if saverName > 0:
            saver = StateSaverFactory.createStateSaver(saverName, {'db': outputDb})

        return saver

    def __getLatestStates(self, tableName):
        ''' get latest state'''
        return [json.loads(str(result)) for result in self.__getSaver(tableName).getStates(0, None)]

    def __parseTableName(self, tableName):
        ''' parse table name and return symbol, strategy, startDate, endDate '''
        if tableName:
            return tableName.split("__")
        else:
            return ["", "", "", ""]

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
