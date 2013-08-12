'''
Created on Aug 13, 2013

@author: ppa
'''
from pyramid.view import view_config
from ultrafinance.module.backTester import BackTester
import time

from threading import Thread
import logging
LOG = logging.getLogger()


class BackTest(object):
    thread = None
    startTime = None
    endTime = None
    latestOrders = None
    metrics = None

    def __init__(self, request):
        self.request = request
        self.params = request.params
        self.session = request.session
        self.settings = request.registry.settings

    def __startBackTester(self):
        ''' start googleCrawler '''
        backTester = BackTester(startTickDate = 20000101, startTradeDate = 20020601)
        backTester.setup()
        backTester.runTests()
        BackTest.metrics = backTester.getMetrics()
        BackTest.latestOrders = backTester.getLatestOrders()

        BackTest.endTime = time.asctime()


    ###############################################################################
    # controller functions
    @view_config(route_name='backtest', request_method="POST", renderer='json')
    def PostBackTest(self):
        ''' start crawler '''
        if BackTest.thread and BackTest.thread.is_alive():
            return {"status": "BackTest is running from %s" % BackTest.startTime}
        else:
            BackTest.thread = Thread(target = self.__startBackTester)
            BackTest.startTime = time.asctime()
            BackTest.endTime = None

            BackTest.thread.daemon = False
            BackTest.thread.start()
            return {"status": "BackTest started."}

    @view_config(route_name='backtest', request_method="GET", renderer='json')
    def GetBackTest(self):
        ''' get backtest status'''
        if BackTest.thread is None:
            return {"status": "BackTest haven't run yet."}
        elif BackTest.thread and BackTest.thread.is_alive():
            return {"status": "BackTest is running from %s." % BackTest.startTime}
        else:
            return {"status": "BackTest run from %s to %s" % (BackTest.startTime, BackTest.endTime),
                    "metrics": BackTest.metrics,
                    "latestOrders": BackTest.latestOrders}

