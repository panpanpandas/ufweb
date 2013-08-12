'''
Created on Aug 13, 2013

@author: ppa
'''
from pyramid.view import view_config
from ultrafinance.module.googleCrawler import GoogleCrawler
import time

from threading import Thread
import logging
LOG = logging.getLogger()


class Crawler(object):
    thread = None
    startTime = None
    endTime = None
    succeeded = []
    failed = []

    def __init__(self, request):
        self.request = request
        self.params = request.params
        self.session = request.session
        self.settings = request.registry.settings
        self.symbolFile = "../conf/SPY500.list"
        self.symbols = []

        with open(self.symbolFile, 'r') as f:
            for line in f.readlines():
                self.symbols.append(line.strip())

    def __startCrawler(self):
        ''' start googleCrawler '''
        googleCrawler = GoogleCrawler(self.symbols, "19900101")
        googleCrawler.getAndSaveSymbols()
        Crawler.succeeded = googleCrawler.succeeded
        Crawler.failed = googleCrawler.failed
        Crawler.endTime = time.asctime()

        LOG.info("Sqlite location: %s" % googleCrawler.sqlLocation)
        LOG.info("Succeeded: %s" % googleCrawler.succeeded)
        LOG.info("Failed: %s" % googleCrawler.failed)

    ###############################################################################
    # controller functions
    @view_config(route_name='crawler', request_method="POST", renderer='json')
    def StartCrawler(self):
        ''' start crawler '''
        if Crawler.thread and Crawler.thread.is_alive():
            return {"status": "Crawler is running from %s" % Crawler.startTime}
        else:
            Crawler.thread = Thread(target = self.__startCrawler)
            Crawler.startTime = time.asctime()
            Crawler.endTime = None

            Crawler.thread.daemon = False
            Crawler.thread.start()
            return {"status": "Crawler started."}

    @view_config(route_name='crawler', request_method="GET", renderer='json')
    def GetCrawler(self):
        ''' get crawler status'''
        if Crawler.thread is None:
            return {"symbol": self.symbols,
                    "status": "Crawler haven't run yet."}
        elif Crawler.thread and Crawler.thread.is_alive():
            return {"symbol": self.symbols,
                    "status": "Crawler is running from %s." % Crawler.startTime}
        else:
            return {"symbol": self.symbols,
                    "status": "Crawler run from %s to %s" % (Crawler.startTime, Crawler.endTime),
                    "succeeded": Crawler.succeeded,
                    "failed": Crawler.failed}

